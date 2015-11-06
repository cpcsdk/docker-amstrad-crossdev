    ORG #100

;
;
;
;
; 
;
; D{sol{ j'ai un peu modifi{ l'introduction de ta demo
; Il me  fallait imperativement un raster sur 3 couleures
; C'est  donc chose faite.         
;
; L'adresse Graph a ete deplacee en #C000
; Pour   mieux apprecier l'ecran :)          Beb/Ovl
;
;
;        dams charge en #400
;
;
;
;
;
;
;   ENT $
;
HAUTEUR EQU 31
LARGEUR EQU 31
NOMBRE  EQU 38

;
;
;
    LD  a,r
    LD  (postab6+1),a
    DI  

    LD  HL,#C9FB
    LD  (#38),HL
;
    EXX 
    EX  AF,AF'
    PUSH    IX
    PUSH    IY
    PUSH    AF
    PUSH    HL
    PUSH    DE
    PUSH    BC
    EXX 
    EX  AF,AF'
    EI  
;
    CALL    INIT
;        CALL INIT MUS1
;
;
DEBUT   CALL    VBL
;        CALL PLAY MUS1
;        CALL EFFET1
;        CALL WRITTER
;        JR DEBUT
;
;
;        CALL STOP MUS1
;
;
    call 0x4000
    CALL    BORDER
    xor a
    ld (VBL_QUIT), a

 
   ;
;
;
    DI  
    LD  B,0 ;BOUCLE DE TEMPORISATION
    DJNZ    $   ;OBLIGATOIRE POUR RAISONS
    LD  A,#C3   ;INCONNUES
    LD  HL,ROUT
    LD  (#38),A
    LD  (#39),HL
    LD  a,r
    LD  (postab1+1),a

;Prog. principal
;
demo    CALL    VBL
    EI  
rout1   CALL    PLASMA
posbl1  LD  hl,buffer
posbl2  LD  de,BLOCKS
    LDI 
    LDI 
    LDI 
    LDI 
    LD  (posbl1+1),hl
    LD  (posbl2+1),de
var256  LD  a,0
    DEC a
    DEC a
    DEC a
    DEC a
    LD  (var256+1),a
    JR  nz,demo
;
    LD  hl,rout2+1
    LD  (posa+1),hl
    LD  (posb+1),hl
    LD  hl,(rout1+1)
    LD  (rout1+1),hl
DEMO    CALL    VBL
rout2   CALL    PLASMA
vara    LD  a,100
    DEC a
    LD  (vara+1),a
    JR  nz,DEMO
;
    XOR a
    LD  (VAR1+1),a
    LD  (VAR2+1),a
    LD  hl,rout3+1
    LD  (posa+1),hl
    LD  (posb+1),hl
    LD  hl,(rout2+1)
    LD  (rout3+1),hl
;
wait1   CALL    VBL
rout3   CALL    PLASMA
vara1   LD  a,6
    DEC a
    LD  (vara1+1),a
    JR  nz,wait1
    LD  hl,CHANGE+1
    LD  (posa+1),hl
    LD  (posb+1),hl
    LD  hl,(rout3+1)
    LD  (CHANGE+1),hl
;
prog    CALL    VBL
;
CHANGE  CALL    OPTIMUS
 jp prog

VALEUR  DB  31
;
;
;
;
;
;
OPTIMUS LD  a,0
    INC a
    LD  (OPTIMUS+1),A
    BIT 0,A
    JR  Z,OPTIMUS2
OPTIMUS1
    LD  hl,(#31*256)+#f0
    LD  bc,#bc00+12
    OUT (c),c
    INC b
    OUT (c),h
    DEC b
    INC c
    OUT (c),c
    INC b
    OUT (c),l
    LD  hl,ADRESSE
    LD  (NUMTAB+2),hl
    JR  OPTIMUS3
OPTIMUS2
    LD  hl,(#30*256)+0
    LD  bc,#bc00+12
    OUT (c),c
    INC b
    OUT (c),h
    INC c
    DEC b
    OUT (c),c
    INC b
    OUT (c),l
    LD  hl,ADRESSE2
    LD  (NUMTAB+2),hl
OPTIMUS3    LD  B,0
incdecb INC B
    LD  A,B
    LD  (OPTIMUS3+1),a
;
sine1   LD  H,courbe2/255
sine2   LD  D,courbe1/255
POSE    LD  E,0
    EXX 
    LD  B,BLOCKS/255
    LD  L,8
    LD  H,8*3
    EXX 
;
NUMTAB  LD  IX,ADRESSE2
;
;
OPTIY1  LD  L,0
    EXX 
    LD  E,(IX+0)
    LD  D,(IX+1)
    DB  #DD
    INC L
    DB  #DD
    INC L
    EXX 
    CALL    OPTIX1
    INC E
OPTIY2  defs  (OPTIY2-OPTIY1)*HAUTEUR, 0
    RET 
;
OPTIX1  LD  A,L
    ADD A,B
    LD  C,L
    LD  L,A
    LD  A,(HL)
    LD  L,C
    ADD A,E
    LD  C,E
    SBC A,B ;
    ADD A,L
    LD  E,A
    LD  A,(DE)
    LD  E,C
    ADD A,(HL)
    INC L
    SUB E
;
    EXX 
    ADD A,A
    ADD A,A ;A=A*4
;
    LD  C,A
    LD  A,(BC)
    INC C
    LD  (DE),A
    LD  A,D
    ADD A,L
    LD  D,A
    LD  A,(BC)
    INC C
    LD  (DE),A
    LD  A,D
    ADD A,L
    LD  D,A
    LD  A,(BC)
    INC C
    LD  (DE),A
    LD  A,D
    ADD A,L
    LD  D,A
    LD  A,(BC)
    LD  (DE),A
    LD  A,D
    SUB H
    LD  D,A
    INC E
    EXX 
;
OPTIX2  defs  (OPTIX2-OPTIX1)*LARGEUR, 0
    RET 
;
;
;
PLASMA  LD  a,0
    INC a
    LD  (PLASMA+1),A
    BIT 0,A
    JR  Z,PLASMA2
PLASMA1
    LD  hl,(#31*256)+#f0
    LD  bc,#bc00+12
    OUT (c),c
    INC b
    OUT (c),h
    DEC b
    INC c
    OUT (c),c
    INC b
    OUT (c),l
    LD  hl,ADRESSE
    LD  (numtab+2),hl
    JR  PLASMA3
PLASMA2
    LD  hl,(#30*256)+0
    LD  bc,#bc00+12
    OUT (c),c
    INC b
    OUT (c),h
    INC c
    DEC b
    OUT (c),c
    INC b
    OUT (c),l
    LD  hl,ADRESSE2
    LD  (numtab+2),hl
PLASMA3 CALL    CALCPLAS
    RET 
;
NEW
tampon  LD  a,0
    DEC a
    LD  (tampon+1),a
    JP  nz,tampon2
;
TAMPON  LD  A,0
    INC A
    LD  (TAMPON+1),A
    BIT 0,A
    JP  Z,read
;
    LD  a,(incdec0)
    AND %11000111
    LD  (incdecb),a
;
    LD  a,r
    BIT 3,a
    JR  nz,courbn2
courbn1 LD  a,courbe1/255
    JR  pok
courbn2 LD  a,courbe2/255
pok LD  (sine1+1),a
    LD  a,(sine+1)
    LD  (sine2+1),a
;
    LD  HL,OPTIMUS
posa    LD  (rout1+1),HL
    LD  A,R
    LD  (POSE+1),A
    LD  A,(B4+1)
VARB    EQU OPTIY2-OPTIY1
    LD  (OPTIY1+1),A
    LD  (VARB+OPTIY1+1),A
    LD  (VARB*2+OPTIY1+1),A
    LD  (VARB*3+OPTIY1+1),A
    LD  (VARB*4+OPTIY1+1),A
    LD  (VARB*5+OPTIY1+1),A
    LD  (VARB*6+OPTIY1+1),A
    LD  (VARB*7+OPTIY1+1),A
    LD  (VARB*8+OPTIY1+1),A
    LD  (VARB*9+OPTIY1+1),A
    LD  (VARB*10+OPTIY1+1),A
    LD  (VARB*11+OPTIY1+1),A
    LD  (VARB*12+OPTIY1+1),A
    LD  (VARB*13+OPTIY1+1),A
    LD  (VARB*14+OPTIY1+1),A
    LD  (VARB*15+OPTIY1+1),A
    LD  (VARB*16+OPTIY1+1),A
    LD  (VARB*17+OPTIY1+1),A
    LD  (VARB*18+OPTIY1+1),A
    LD  (VARB*19+OPTIY1+1),A
    LD  (VARB*20+OPTIY1+1),A
    LD  (VARB*21+OPTIY1+1),A
    LD  (VARB*22+OPTIY1+1),A
    LD  (VARB*23+OPTIY1+1),A
    LD  (VARB*24+OPTIY1+1),A
    LD  (VARB*25+OPTIY1+1),A
    LD  (VARB*26+OPTIY1+1),A
    LD  (VARB*27+OPTIY1+1),A
    LD  (VARB*28+OPTIY1+1),A
    LD  (VARB*29+OPTIY1+1),A
    LD  (VARB*30+OPTIY1+1),A
    LD  (VARB*31+OPTIY1+1),A
    JP  saut
;
read
    LD  HL,PLASMA
posb    LD  (rout1+1),hl
postab1 LD  hl,table1
    LD  a,(hl)
    LD  (incdec0),a
    LD  (var+incdec0),a
    LD  (var*2+incdec0),a
    LD  (var*3+incdec0),a
    LD  (var*4+incdec0),a
    LD  (var*5+incdec0),a
    LD  (var*6+incdec0),a
    LD  (var*7+incdec0),a
    LD  (var*8+incdec0),a
    LD  (var*9+incdec0),a
    LD  (var*10+incdec0),a
    LD  (var*11+incdec0),a
    LD  (var*12+incdec0),a
    LD  (var*13+incdec0),a
    LD  (var*14+incdec0),a
    LD  (var*15+incdec0),a
    LD  (var*16+incdec0),a
    LD  (var*17+incdec0),a
    LD  (var*18+incdec0),a
    LD  (var*19+incdec0),a
    LD  (var*20+incdec0),a
    LD  (var*21+incdec0),a
    LD  (var*22+incdec0),a
    LD  (var*23+incdec0),a
    LD  (var*24+incdec0),a
    LD  (var*25+incdec0),a
    LD  (var*26+incdec0),a
    LD  (var*27+incdec0),a
    LD  (var*28+incdec0),a
    LD  (var*29+incdec0),a
    LD  (var*30+incdec0),a
    LD  (var*31+incdec0),a
    INC l
    LD  (postab1+1),hl
postab2 LD  hl,table1+16
    LD  a,(hl)
    LD  (incdec1),a
    LD  (var+incdec1),a
    LD  (var*2+incdec1),a
    LD  (var*3+incdec1),a
    LD  (var*4+incdec1),a
    LD  (var*5+incdec1),a
    LD  (var*6+incdec1),a
    LD  (var*7+incdec1),a
    LD  (var*8+incdec1),a
    LD  (var*9+incdec1),a
    LD  (var*10+incdec1),a
    LD  (var*11+incdec1),a
    LD  (var*12+incdec1),a
    LD  (var*13+incdec1),a
    LD  (var*14+incdec1),a
    LD  (var*15+incdec1),a
    LD  (var*16+incdec1),a
    LD  (var*17+incdec1),a
    LD  (var*18+incdec1),a
    LD  (var*19+incdec1),a
    LD  (var*20+incdec1),a
    LD  (var*21+incdec1),a
    LD  (var*22+incdec1),a
    LD  (var*23+incdec1),a
    LD  (var*24+incdec1),a
    LD  (var*25+incdec1),a
    LD  (var*26+incdec1),a
    LD  (var*27+incdec1),a
    LD  (var*28+incdec1),a
    LD  (var*29+incdec1),a
    LD  (var*30+incdec1),a
    LD  (var*31+incdec1),a
    DEC l
    LD  (postab2+1),hl
postab3 LD  hl,table1+50
    LD  a,(hl)
    LD  (incdec2),a
    LD  (var+incdec2),a
    LD  (var*2+incdec2),a
    LD  (var*3+incdec2),a
    LD  (var*4+incdec2),a
    LD  (var*5+incdec2),a
    LD  (var*6+incdec2),a
    LD  (var*7+incdec2),a
    LD  (var*8+incdec2),a
    LD  (var*9+incdec2),a
    LD  (var*10+incdec2),a
    LD  (var*11+incdec2),a
    LD  (var*12+incdec2),a
    LD  (var*13+incdec2),a
    LD  (var*14+incdec2),a
    LD  (var*15+incdec2),a
    LD  (var*16+incdec2),a
    LD  (var*17+incdec2),a
    LD  (var*18+incdec2),a
    LD  (var*19+incdec2),a
    LD  (var*20+incdec2),a
    LD  (var*21+incdec2),a
    LD  (var*22+incdec2),a
    LD  (var*23+incdec2),a
    LD  (var*24+incdec2),a
    LD  (var*25+incdec2),a
    LD  (var*26+incdec2),a
    LD  (var*27+incdec2),a
    LD  (var*28+incdec2),a
    LD  (var*29+incdec2),a
    LD  (var*30+incdec2),a
    LD  (var*31+incdec2),a
    INC l
    INC l
    LD  (postab3+1),hl
postab4 LD  hl,table2
    LD  a,(hl)
    LD  (incdec3),a
    INC l
    LD  (postab4+1),hl
postab5 LD  hl,table2+20
    LD  a,(hl)
    LD  (incdec4),a
    DEC l
    DEC l
    DEC l
    LD  (postab5+1),hl
postab6 LD  hl,table2+45
    LD  a,(hl)
    LD  (incdec5),a
    INC l
    INC l
    LD  (postab6+1),hl
postab7 LD  hl,table2+64
    LD  a,(hl)
    LD  (incdec6),a
    DEC l
    LD  (postab7+1),hl
;
    LD  a,r
    BIT 3,a
    JR  nz,courbno2
courbno1    LD  a,courbe1/255
    JR  poke
courbno2    LD  a,courbe2/255
poke    LD  (sine+1),a
;
saut    XOR a
    LD  (tampon+1),a
;
tampon2 LD  a,4
    DEC a
    DEC a
    LD  (tampon2+1),a
    RET nz
poscoul LD  hl,TABCOUL
    LD  a,(hl)
    OR  a
    JR  nz,nozero
    LD  hl,TABCOUL
nozero  LD  a,(hl)
    LD  (Encre0+1),a
    INC hl
    LD  a,(hl)
    LD  (Encre1+1),a
    INC hl
    LD  a,(hl)
    LD  (Encre2+1),a
    INC hl
    LD  a,(hl)
    LD  (Encre3+1),a
    INC hl
    LD  (poscoul+1),hl
;
    RET 
;
;
DECAL   DB  0
DECAL2
    PUSH    BC
    PUSH    HL
;
    LD  bc,#7f00
Encre0  LD  a,#5c
    OUT (c),c
    OUT (c),a
    INC c
Encre1  LD  a,#4c
    OUT (c),c
    OUT (c),a
    INC c
Encre2  LD  a,#4e
    OUT (c),c
    OUT (c),a
    INC c
Encre3  LD  a,#4a
    OUT (c),c
    OUT (c),a
;
    LD  A,(DECAL)
    LD  H,A
    LD  A,63
    SUB H
POS2    LD  L,34
;
    defs  60-46-2, 0
    LD  BC,#7F8D
    OUT (C),C
    LD  BC,#BC00
    OUT (C),C
    INC B
    OUT (C),A
    DEC B
    INC C
    INC C   ;LD BC,#BC02
    OUT (C),C
    INC B
    OUT (C),L
    DEC B
    DEC C
    DEC C
    OUT (C),C   ;LD BC,#BC00
    INC B
    LD  A,63
    OUT (C),A
;
    POP HL
    POP BC
VAR2    LD  A,1
    OR  A
    JP  Z,DECALA2
;
    POP AF
    EI  
    RET 
;
DECALA1 LD  A,24
    DEC A
    LD  (DECALA2+1),A
    JR  NZ,DECALA22
    LD  A,1
    LD  (VAR2+1),A
    POP AF
    EI  
    RET 
;
DECALA22    LD  A,(DECAL)
DEC21   INC A
    LD  (DECAL),A
    LD  A,(POS2+1)
DEC22   INC A
    LD  (POS2+1),A
    POP AF
    EI  
    RET 
;
DECAL1
    PUSH    BC
    PUSH    HL
    LD  BC,#7F8C
    OUT (C),C
    LD  A,(DECAL)
    ADD A,63
POS1    LD  L,34
;
    LD  BC,#BC00
    OUT (C),C
    INC B
    OUT (C),A
    DEC B
    INC C
    INC C
    OUT (C),C   ;LD BC,#BC02
    INC B
    OUT (C),L
    DEC B
    DEC C
    DEC C
    OUT (C),C   ; LD BC,#BC00
    INC B
    defs  20, 0
    LD  A,63
    OUT (C),A
;
    LD  bc,#7f00
ink0    LD  a,#54
    OUT (c),c
    OUT (c),a
    INC c
ink1    LD  a,#54
    OUT (c),c
    OUT (c),a
    INC c
ink2    LD  a,#54
    OUT (c),c
    OUT (c),a
    INC c
ink3    LD  a,#54
    OUT (c),c
    OUT (c),a
;
    LD  BC,#7F10
    OUT (C),C
    LD  C,COULEUR1
    OUT (C),C
    POP HL
    POP BC
VAR1    LD  A,1
    OR  A
    JP  Z,DECALA1
;
    POP AF
    EI  
    RET 
;
DECALA2 LD  A,24
    DEC A
    LD  (DECALA1+1),A
    JR  NZ,DECALA12
    LD  A,1
    LD  (VAR1+1),A
    POP AF
    EI  
    RET 
;
DECALA12    LD  A,(DECAL)
DEC11   INC A
    LD  (DECAL),A
    LD  A,(POS1+1)
INC12   DEC A
    LD  (POS1+1),A
    POP AF
    EI  
    RET 
;
;
ROUT
    PUSH    AF
FLAG    LD  A,0
    INC A
    LD  (FLAG+1),A
    CP  1
    JP  Z,DECAL1
    CP  4
    JP  Z,DECAL2
    CP  5
    JP  Z,TEST
    CP  6
    JR  NZ,FROUT
;
    PUSH    IX
    PUSH    HL
    PUSH    DE
    PUSH    BC
    EX  AF,AF'
    PUSH    AF
    CALL   #4003
    CALL    NEW
    POP AF
    EX  AF,AF'
    POP BC
    POP DE
    POP HL
    POP IX
;
    LD  A,0
    LD  (FLAG+1),A
FROUT   POP AF
    EI  
    RET 
;
TEST
    PUSH    HL
    PUSH    DE
    PUSH    BC
;
    LD  BC,#7F10
    OUT (C),C
    LD  c,COULI1
    OUT (c),c
    defs  64-6, 0
    LD  C,COULEUR2
    OUT (C),C
    defs  64*4-7, 0
    LD  c,COULI2
    OUT (c),c
    defs  64-6, 0
    LD  C,COULEUR3
    OUT (C),C
;
    POP BC
    POP DE
    POP HL
    POP AF
    EI  
    RET 
;
;
VBL LD  B,#F5
NOVBL   IN  A,(C)
    RRA 
    JR  NC,NOVBL

VBL_QUIT ret
    call gestion_writer
    RET 
;
;

	; completo
wVb
	call	wVb1
	; normal
wVb2
	ld 	b,#f5
vbLoop2
	IN 	A,(C)		; mientras bit 0 de #f5 = 0
        RRA
        JR 	NC,vbLoop2
	ret

	; inicial
wVb1
	ld 	b,#f5
vbLoop1
	IN 	A,(C)
        RRA			; mientras bit 0 de #f5 = 1
        JR 	C, vbLoop1
	ret



	; h = x, l = w
	; d = y, e = h
redim_screen

	call	wVb ; wait vb

	ld	bc,#bc01	; w
	out	(c),c
	inc	b
	out	(c),l

	ld	bc,#bc02	; x
	out	(c),c
	inc	b
	ld	a, 34
	add	a,h
	out	(c),a

	ld	bc,#bc06	; h
	out	(c),c
	inc	b
	out	(c),e

currentR7
	ld	a, 0x1e
	sub	d
	jr	z,screen_ok
	add	38		; a = r4 value

	ld	bc,#bc04
	out	(c),c
	inc	b
	out	(c),a		; r4 = a

	ld	a,d
	ld	c,2
	cp	33
	jr	nc,wait_halts
	inc	c
	cp	27
	jr	nc,wait_halts
	inc	c
	cp	21
	jr	nc,wait_halts
	inc	c
	cp	14
	jr	nc,wait_halts
	inc	c
wait_halts
	halt
	dec	c
	jr	nz,wait_halts

	ld	c,38
	out	(c),c		; r4 = 38

	ld	bc,#bc07
	out	(c),c
	inc	b
	out	(c),d		; r7 = d

	ld	a,d
	ld	(currentR7+1),a
screen_ok
	ret


 include src/couleurs_effets.asm
 include src/CRTC_detection.asm

;
BC26    LD  A,H
    ADD A,8
    LD  H,A
    RET NC
    LD  BC,#C000+32
    ADD HL,BC
    RET 
;
;
CALCPLAS    LD  DE,#0000
sine    LD  H,courbe1/255
;
numtab  LD  IX,ADRESSE
    EXX 
    LD  B,BLOCKS/255
    LD  L,8
    LD  H,8*3
    EXX 
;
    EX  AF,AF'
    LD  A,HAUTEUR+1
FORY
    EX  AF,AF'
    LD  BC,(B4+1)
    EXX 
    LD  E,(IX+0)
    LD  D,(IX+1)
    EXX 
    CALL    FORX
    INC D
    INC D
    INC E
    DB  #DD
    INC L
    DB  #DD
    INC L
    EX  AF,AF'
    DEC A
    JR  NZ,FORY
    EX  AF,AF'
;
    LD  HL,(CALCPLAS+1)
    INC H
    DEC L
    DEC L
    LD  (CALCPLAS+1),HL
;
B4  LD  HL,0
incdec3 DEC H
incdec4 INC L
incdec5 INC L
incdec6 INC L
    LD  (B4+1),HL
;
    RET 
;
;
FORX    
    LD  L,D
    LD  A,(HL)
    LD  L,E
    ADD A,(HL)
    LD  L,B
    ADD A,(HL)
    LD  L,C
    ADD A,(HL)
;
    EXX 
    ADD A,A
    ADD A,A ;A=A*4
;
    LD  C,A
    LD  A,(BC)
    INC C
    LD  (DE),A
    LD  A,D
    ADD A,L
    LD  D,A
    LD  A,(BC)
    INC C
    LD  (DE),A
    LD  A,D
    ADD A,L
    LD  D,A
    LD  A,(BC)
    INC C
    LD  (DE),A
    LD  A,D
    ADD A,L
    LD  D,A
    LD  A,(BC)
    LD  (DE),A
    LD  A,D
    SUB H
    LD  D,A
    INC E
    EXX 
;
incdec0 INC B
incdec1 INC C
incdec2 INC C
;
ENDFORX defs  (ENDFORX-FORX)*LARGEUR, 0
    RET 
;
;
var EQU (ENDFORX-FORX)
;
buffer
 defs 256,0 



COLOR  
       ld bc,&7f00
BOUCOLOR
       out (c),c
       ld a,(hl)
       or a
       ret z
       out (c),a
       inc hl
       inc c
       jp BOUCOLOR

IMAGE_COLOR
 include src/image_colors.asm
 db 0

 include src/writer.asm

 align 8
BINARY_DATA
 incbin data/ALL_BINARY_DATA.bin
 
courbe2 EQU BINARY_DATA
courbe1 EQU courbe2 + 0x100
ADRESSE EQU courbe1 + 0x100
ADRESSE2    EQU ADRESSE+64
BLOCKS  EQU ADRESSE + 0x100
table1  EQU BLOCKS + 0x100
table2  EQU table1+ 0x100
 defs 512



	org 0x4000
Player
 incbin "data/PLAYER.BIN", 128

	org 0x4800
Music
 incbin "data/STATE.AYC", 128
 defs 128
GRAPH  
 incbin "data/image.bin", 128

PLASMA_END


INIT
.detect_crtc
    call TestCRTC
    cp 1
    jr z, .modif_code_border
    jr .pas_modif_code_border
.modif_code_border
    ; Patch le code d'affichage de border
    ld a, 6 
 ld (BORDER0.val1+1), a
    ld hl, 0x0000 + (31 )*256
 ld (BORDER0.val2+1), hl

.pas_modif_code_border


;
.loop_code_initialisation
    LD  HL,FORX
    LD  DE,ENDFORX
    LD  BC,(ENDFORX-FORX)*LARGEUR
    LDIR    
    LD  HL,OPTIX1
    LD  DE,OPTIX2
    LD  BC,(OPTIX2-OPTIX1)*LARGEUR
    LDIR    
    LD  HL,OPTIY1
    LD  DE,OPTIY2
    LD  BC,(OPTIY2-OPTIY1)*HAUTEUR
    LDIR    
    LD  hl,BLOCKS
    LD  de,buffer
    LD  bc,256
    LDIR    
    LD  hl,BLOCKS
    LD  de,BLOCKS+1
    LD  bc,255
    LD  (hl),0
    LDIR    
;

.clear_screen
    LD  HL,#C000
    LD  DE,#C001
    LD  BC,#3FFF
    LD  (HL), 0; 0xff
    LDIR    
;

.screen_table_computation
    LD  HL,#C000
    LD  A,4*30
BB  PUSH    AF
    push hl
	ld d, h
	ld e, l
    inc de
    ld bc, 31
    ld (hl), 0xff
    ldir
    pop hl
    CALL    BC26
    POP AF
    DEC A
    JR  NZ,BB
;
    LD  IX,ADRESSE
    LD  A,32
BOUCLE  LD  (IX+0),L
    LD  (IX+1),H
    INC IX
    INC IX
    PUSH    AF
    CALL    BC26
    CALL    BC26
    CALL    BC26
    CALL    BC26
    POP AF
    DEC A
    JR  NZ,BOUCLE
;
    PUSH    HL
;


 ld (BORDAFF2+1), hl
 ; Copy graph on screen
.graph_copy
    EX  DE,HL
    LD  HL,GRAPH
    LD  A,120
BAFF1   PUSH    HL
    PUSH    DE
    LD  BC,32
    LDIR    
    POP DE
    POP HL
    LD  BC,32
    ADD HL,BC
    EX  DE,HL
    PUSH    AF
    CALL    BC26
    POP AF
    EX  DE,HL
    DEC A
    JR  NZ,BAFF1
;
;
    POP HL
    LD  A,4*30
BBb PUSH    AF
    CALL    BC26
    POP AF
    DEC A
    JR  NZ,BBb
;
    LD  IX,ADRESSE2
    LD  A,32
BOUCLE2 LD  (IX+0),L
    LD  (IX+1),H
    INC IX
    INC IX
    PUSH    AF
    CALL    BC26
    CALL    BC26
    CALL    BC26
    CALL    BC26
    POP AF
    DEC A
    JR  NZ,BOUCLE2
;
;

.ink_selection
    LD  B,#7F
    XOR a
    LD  hl, IMAGE_COLOR
boucle  LD  c,(hl)
    OUT (c),a
    OUT (c),c
    INC hl
    INC a
    CP  17
    JR  nz,boucle
    LD  HL, IMAGE_COLOR
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


DIFF_REG7 = (34 - 30)
 call VBL
 ld bc, 0xbc00+4 
 out (c), c 
 ld bc, 0xbd00+38-DIFF_REG7 
 out (c), c
 halt
 halt
 ld bc, 0xbc00+4 
 out (c), c 
 ld bc, 0xbd00+38 
 out (c), c
 ld bc, 0xbc00+7 
 out (c), c 
 ld bc, 0xbd00+34 
 out (c), c


 
DIFF_REG2 equ 0x2e-0x22
 ld b, DIFF_REG2
.loop_reg2
 push bc
 call VBL
.val_reg2
 ld a, 0x2e
 ld bc, 0xbc02
 out (c),c 
 inc b
 out (c), a 
 dec a
 ld (.val_reg2+1), a
 pop bc
 djnz .loop_reg2
 
.crtc_initilisation
    LD  BC,#BC01
    OUT (C),C
    LD  BC,#BD00+16
    OUT (C),C
    LD  BC,#BC06
    OUT (C),C
    LD  BC,#BD00+31 - 120/8 -1
    OUT (C),C
    LD  BC,#BC02
    OUT (C),C
    LD  BC,#BD00+34 ; 0x22
    OUT (C),C

    RET 

 include src/transition.asm
 db 'File info original avant auto-censure pour eviter des guerre inutiles.'
 db 'Permet de combler la place libre ;)'
 incbin file.idz.original
 assert $<0xc000
