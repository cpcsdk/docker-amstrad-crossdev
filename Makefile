IMAGE?=cpcsdk/crossdev
VERSION?=1.0

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

# Install on the host machine the scripts
install_wrappers:
	for file in wrappers/* ; do \
		sudo cp $$file $(INSTALL_ROOT)/bin ; \
		done
