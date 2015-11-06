    output readme.o
    org 0x9000

    ld a, 2 : call 0xBC0E
    ld a, 0 : ld b, 3 : ld c, b : push bc : call 0xBC32 : pop bc : call 0xBC38
    ld a, 1 : ld b, 24 : ld c, b : call 0xBC32
    ld hl, TEXT1 : call display_text


    call 0xbb18

  
    call FDCON  
    xor a : ld b, a
    call FDCVARS

    ld hl, filename
    ld de, 0x1000
    ld bc, de
    call LOADFILE

    call FDCOFF
    jp 0x1000


;; the filename to load
;; disc filenames are a maximum of 12 characters long
;; 8 characters for name, and 3 characters for extension
filename
 defb "EXPERTS  BIN"
end_filename



 include src/READAMSD.MXM

display_text
.text_loop
    ld a, (hl)
    or a
    jr z, .text_end
    push hl
    call 0xbb5a
    pop hl
    inc hl
    jr .text_loop
.text_end

    ret


FNAME db '4k.bnd'
TEXT1
	 db '        _____            _                     _____             _       ' : db "\r\n"
	 db '       / ____|          | |                   / ____|           (_)      ' : db "\r\n"
	 db '      | (___   ___ _ __ | |_ ___ _   _ _ __  | (___   __ _ _ __  _ _ __  ' : db "\r\n"
	 db '       \___ \ / _ \ ',"'",'_ \| __/ _ \ | | | ',"'",'__|  \___ \ / _` | ',"'",'_ \| | ',"'",'_ \ ' : db "\r\n"
	 db '       ____) |  __/ | | | ||  __/ |_| | |     ____) | (_| | |_) | | | | |' : db "\r\n"
	 db '      |_____/ \___|_| |_|\__\___|\__,_|_|    |_____/ \__,_| .__/|_|_| |_|' : db "\r\n"
	 db '                                                          | |            ' : db "\r\n"
	 db '                                                          |_|            ' : db "\r\n"
    db "                                        \r\n"
    db "\r\n"
    db "Code ........... Krusty/Benediction\r\n"
    db "Music .......... Count Zero (Atari transfert)\r\n"
    db "Design ......... Beb/Overlanders?!\r\n"
    db "                                     Released for the demo compo of RST0\r\n"
    db "                                                            25 june 2011\r\n\r\n"
    db "Nothing is lost, nothing is created, everything is transformed at Benediction,\r\n"
    db "you have in your hands one of my oldest codes (almost 10 years old ...).\r\n\r\n"
    db '        Works on a 64Kb machine'
    db 0



