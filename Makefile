IMAGE?=cpcsdk/crossdev
VERSION?=3.0

INSTALL_ROOT?=/usr/local


# Build the docker container
build:
	docker build -t $(IMAGE) .


# Create the tag of the current version and push it to the docker hub
tag_and_push:
	docker tag  \
		$$(  docker images | grep cpcsdk/crossdev | grep latest | sed -e 's/.*latest\W*//'  -e 's/\(\w*\).*/\1/') \
		$(IMAGE):$(VERSION)
	docker push $(IMAGE):$(VERSION)


test:
	cd examples/experts  && \
		./bootstrap.sh make distclean && \
		./bootstrap.sh make ALL && \
		./bootstrap.sh test


open:
	docker run -e DISPLAY=$(DISPLAY) \
		-v /tmp/.X11-unix:/tmp/.X11-unix   \
	      	-v /dev/snd:/dev/snd \
		 -v /dev/shm:/dev/shm \
		 -v /etc/machine-id:/etc/machine-id \
		 -v /run/user/$$(id -u)/pulse:/run/user/$$(id -u)/pulse \
		 -v /var/lib/dbus:/var/lib/dbus \
		 -v ~/.pulse:/home/arnold/.pulse \
		 --privileged \
		 --rm=true \
		 -e LOCAL_USER_ID=$$(id -u $$USER) \
		 -v "$$(pwd):/home/arnold/project" \
		 -w /home/arnold/project \
		-i -t $(IMAGE)

# Install on the host machine the scripts
install_wrappers:
	for file in wrappers/* ; do \
		sudo cp $$file $(INSTALL_ROOT)/bin ; \
		done
