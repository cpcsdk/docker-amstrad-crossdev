
 org 0x500

BOOT equ 0x8500
PLAMA_TEXTE=0x1E8B

 ld a, 2
 call 0xBC0E ;- SCR SET MODE

 ld hl, TEXTE
.loop
 ld a, (hl)
 or a
 jr z, .endloop
 push hl
 call 0xbb5a
 pop hl
 inc hl
 jr .loop
.endloop

.select_music
 call &BB06 ;- KM WAIT CHAR
 cp '1' 
	 jr z, first_music
 cp '2' 
	 jr z, second_music
 cp '3' 
	 jr z, third_music
 jr .select_music

second_music ld a, 2 
	 jr next
third_music ld a, 3 
	jr next
first_music ld a, 1

next
 di
 ld i, a
 ld bc, 0xbc01 
	 out (c), c
 inc b : dec c 
	 out (c), c

 ld sp, 0x100
 ld hl, data_b
 ld de, BOOT
 ld bc, data_e - data_b
 ldir

 jp BOOT

TEXTE
 db  'Choose your music:', "\r\n\r\n"
 defb '1. State of confusion/Tao (atari transfert)', "\r\n"
 defb '2. Take Off/McKlain (winner of music contest)', "\r\n"
 defb '3. ???/Count Zero (atari transfert)', "\r\n"
 db 0


data_b
 rorg BOOT
 jp uncrunch

data
 incbin plasma.exo
 assert $>0x8775
mcklain
 incbin data/MCKLAIN2.EXO
count
 incbin data/COUNT.EXO
uncrunch
 ld hl, data
 ld de, 0x100
 call deexo

;;Patch player to avoid music distortion
 ld a, 0x90
 ld (0x4498+1), a
 ld (0x44c5+1), a

;;MUSIC

 ld a, i
 cp 1
 jp z, 0x100

 cp 2
 jr nz, .select_count

 ld hl, mcklain
 ld de, 0x4800 
 call deexo
 ld hl, 0x4800 + 128
 ld de, 0x4800
 ld bc, 8192
 ldir
 ld de, PLAMA_TEXTE + 4*16-(mcklainstr_end-mcklainstr)
 ld hl, mcklainstr
 ld bc, mcklainstr_end-mcklainstr
 ldir
 jp 0x100

.select_count
  ld hl, count
 ld de, 0x4800 
 call deexo
 ld hl, 0x4800 + 128
 ld de, 0x4800
 ld bc, 11264
 ldir
 ld de, PLAMA_TEXTE + 4*16-(countzerostr_end-countzerostr)
 ld hl, countzerostr
 ld bc, countzerostr_end-countzerostr
 ldir

 jp 0x100

mcklainstr
 abyte -'A'+1 'MCKLAIN'
mcklainstr_end
countzerostr
 abyte -'A'+1 'COUNTZERO'
countzerostr_end

 include src/deexo.asm
 assert $ < 0xffff and $>0xc000
 rend
data_e
 assert $ < BOOT
