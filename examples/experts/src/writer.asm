; Octet de la couleur de fond
OCTET_EFFACEMENT equ 0xff
;OCTET_EFFACEMENT equ 0
HAUTEUR_IMAGE equ 120



gestion_writer
.premiere_attente
    ld bc, 50*5
    ld a, b
    or c
    jr z, .poursuit
    dec bc
    ld (.premiere_attente+1), bc
    ret

.poursuit
    call gestion_effacement_ecran_double
    ret


gestion_effacement_ecran_double
    call gestion_effacement_ecran
    call gestion_effacement_ecran
    ret


gestion_effacement_ecran
.routine call initialize_effacement_ecran
    ret



efface_ecran_superieur
    ld a, HAUTEUR_IMAGE
    or a
    jr nz, .next

    ld hl, gestion_caractere
    ld (gestion_effacement_ecran.routine+1), hl

    ld hl,  WRITTER_PALETTE
    call COLOR
    ld hl, WRITTER_PALETTE
    LD  a,(hl)
    LD  (ink0+1),a
    INC hl
    LD  a,(hl)
    LD  (ink1+1),a
    INC hl
    LD  a,(hl)
    LD  (ink2+1),a
    INC hl
    LD  a,(hl)
    LD  (ink3+1),a

    ret

.next
    dec a
    ld (efface_ecran_superieur+1), a

.ecran1
    ld hl, (ADRESSE_ECRAN1_ACTUEL)
    push hl
    call efface_ecran_superieur_image
    pop hl
    call BC26
    ld (ADRESSE_ECRAN1_ACTUEL), hl

.ecran2
    ld hl, (ADRESSE_ECRAN2_ACTUEL)
    push hl
    call efface_ecran_superieur_image
    pop hl
    call BC26
    ld (ADRESSE_ECRAN2_ACTUEL), hl


    ret



efface_ecran_superieur_image
    ; Ecrase premier octet
    ld d, h
	ld e, l
    inc e
    ld (hl), OCTET_EFFACEMENT

    ; Efface les autres octets de la ligne
    repeat 32 -1
        ldi
    endr
    
    ret



initialize_effacement_ecran
    ; Reinitilise les adresses
    ld hl, (ADRESSE_ECRAN1) 
 ld (ADRESSE_ECRAN1_ACTUEL), hl 
 ld (gestion_caractere.adresse_ecran1+1), hl
    ld hl, (ADRESSE_ECRAN2) 
 ld (ADRESSE_ECRAN2_ACTUEL), hl 
 ld (gestion_caractere.adresse_ecran2+1), hl


    ; Reinitialise la routine a appeler
    ld hl, efface_ecran_superieur
    ld (gestion_effacement_ecran.routine+1), hl


    ld a, HAUTEUR_IMAGE
    ld (efface_ecran_superieur+1), a

    ld a, 50
    dec a
    ld (writter_pause+1), a

    ret




gestion_caractere

    call recupere_caractere
.adresse_ecran1
    ld hl, 0xc000
.adresse_ecran2
    ld bc, 0xc000

    push hl 
	 push bc
    call affiche_caractere
    pop bc 
	 pop hl


    ; Teste le type de mouvement (decalage horizontal ou ligne suivante)
.decalage_horizontal
    inc hl 
 inc hl 
 ld (.adresse_ecran1+1), hl

    inc bc 
 inc bc 
 ld (.adresse_ecran2+1), bc

.compteur_type_decalage
    ld a, 0
    inc a
    and 15
    ld (.compteur_type_decalage+1), a
    jr z, .decalage_vertical
    
    ret

.decalage_vertical
.compteur_decalage_vertical
    ld a, 0
    inc a
    cp 120/10
    jr nz, .pas_fin_ecran
    xor a
    ld (.compteur_decalage_vertical+1), a
    ld hl, writter_pause
    ld (gestion_effacement_ecran.routine+1), hl
    ret

    
.pas_fin_ecran
    ld (.compteur_decalage_vertical+1), a
    ld hl, (.adresse_ecran1+1)
    ;call BC26
    call BC26
    call BC26
    ld (.adresse_ecran1+1), hl

    ld hl, (.adresse_ecran2+1)
    ;call BC26
    call BC26
    call BC26
    ld (.adresse_ecran2+1), hl

    ret


affiche_caractere
    ld ixh, 9
.loop
.cp_octet1
    ld a, (de)
    ld (hl), a 
 ld (bc), a
    inc hl 
 inc bc 
 inc de
.cp_octet2
    ld a, (de)
    ld (hl), a 
 ld (bc), a
    dec hl 
 dec bc 
 inc de
    
    push bc
    call BC26
    pop BC


    push hl
	ld h, b
	ld l, c
    call BC26
	ld b, h
	ld c, l
    pop hl
    dec ixh
    jr nz, .loop    
    ret


recupere_caractere
.pointeur_texte
    ld hl, TEXTE
    ld a, (hl)
    cp 255
    jr nz, .pas_boucle
    ld hl, TEXTE
    ld a, (hl)
.pas_boucle
    inc hl
    ld (.pointeur_texte+1), hl

    ld h, 0
    ld l, a
	ld d, h
	ld e, l
    add hl, hl ; x2
	ld b, h
	ld c, l
    add hl, de ; x3
    add hl, bc ; x5
    add hl, hl ; x10
    add hl, hl ; x20

    ld de, FONT
    add hl, de
    ex de, hl

    ret



writter_pause
    ld a, 50

  ;  ret
    call initialize_effacement_ecran
    ret



ADRESSE_ECRAN2 dw 0xc000
ADRESSE_ECRAN1 dw 0xc000

ADRESSE_ECRAN1_ACTUEL dw 0
ADRESSE_ECRAN2_ACTUEL dw 0


FONT
 defs 20, OCTET_EFFACEMENT
 incbin "data/font.bin", 128
 defs 10


TEXTE
    incbin data/liner.dat
   db 255


WRITTER_PALETTE
 	db &5c
	db &4b
	db &4f
	db &58
	db &54
	db &43
	db &53
	db &57
	db &44
	db &45
	db &4e
	db &47
	db &42
	db &4a
	db &56
	db &40
	db &40
WRITTER_PALETTE_end
    db 0
