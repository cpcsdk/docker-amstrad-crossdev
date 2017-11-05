    org 0x4000



    di
        ld sp, $
        ld hl, 0xc9fb
        ld (0x38), hl
    ei


    di
        ld de, music
        call PLY_Init
    ei



loop
    ld b, 0xf5
    in a, (c)
    rra
    jr nc, loop



    halt
    halt

    ld bc, 0x7f10 : out (c), c
    ld bc, 0x7f4b : out (c), c
    di
        call PLY_Play
    ei
    ld bc, 0x7f54 : out (c), c

    jr loop


player
    include "/opt/Arkos Tracker 2/players/playerAky/sources/PlayerAkyAccurate.asm"

music
    include "A Harmless Grenade.aky"
