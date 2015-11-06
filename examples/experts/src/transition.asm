


BORDER 


    ld hl, (BORDAFF+1) 
 ld (ADRESSE_ECRAN1), hl
    ld hl, (BORDAFF2+1) 
 ld (ADRESSE_ECRAN2), hl

    LD  BC,#7F10
    OUT (C),C

    ld b, 50*2
.tempo_loop1
    push bc
    call VBL
    halt
    halt
    halt
    pop bc
    djnz .tempo_loop1

    LD  BC,#BC06
    OUT (C),C
    LD  BC,#BD00+31 
    OUT (C),C

    ld b, 50*2
.tempo_loop2
    push bc
    call VBL
    halt
    halt
    halt
    pop bc
    djnz .tempo_loop2


BORDER0

    CALL    VBL
       DI  
    EXX 
.val1
    LD  BC,#BC08    ;6
.val2
    LD  HL,48   ;#0001
    EXX 
    LD  B,#7F
    LD  A,COULI1
    LD  C,COULEUR1
    LD  D,COULEUR2
    LD  E,COULI2
;
    OUT (C),C
    DI  
    defs  15-8,0 
BORDERA LD  H,1
BORDER1 defs  64-1-3, 0
    DEC H
    JR  NZ,BORDER1
    defs  64-4-4-4-4,  0
;
    EXX 
    OUT (C),C
    INC B
    OUT (C),L
    DEC B
    EXX 
    OUT (C),A
    defs  60
    OUT (C),D
    defs  64*4-4, 0
    OUT (C),E
    defs  60, 0
    LD  e,COULEUR3
    OUT (C),e
    EXX 
    OUT (C),C
    INC B
    OUT (C),H
    EXX 
;
    EI  
    HALT    
;
    LD  A,(BORDERA+1)
    CP  NOMBRE
    JR  C,BORDER2
    LD  E,A
    LD  A,NOMBRE+120
    CP  E
    JR  C,BORDER2
;
BORDAFF LD  DE,#C000
BORDAFF2    LD  HL,GRAPH
    LD  BC,32
    LDIR  
    LD  HL,(BORDAFF+1)
    CALL    BC26
    LD  (BORDAFF+1),HL
    LD  HL,(BORDAFF2+1)
    CALL    BC26
    LD  (BORDAFF2+1),HL

;
;
BORDER2 LD  A,(BORDERA+1)
    INC a
    LD  (BORDERA+1),A
    CP  209
;
    RET Z

;    ld hl, IMAGE_COLOR
;    call COLOR
    ld bc, 0x7f8c 
 out (c), c
  ld bc, 0x7f10 
 out (c), c

    JP  BORDER0

