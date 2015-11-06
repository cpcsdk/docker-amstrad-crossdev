;
;PLAY-AY.SCE  OVerLanders 24/5/2000
;v0.5
;
; Concu avec dams en #3e8 / #C0 / M#6600
;
;   Pour placer manuellement ses tampons de decompression, definir OFTAB0 etc,
;mettre  les bons JUMP en V0 etc et enlever CALL ATTRIBU
;
;C'est quand on vit seul qu'on a le plus besoin d'un lit a deux places.
;
	ORG	#6D00
FLAGLOAD	DS	1
TEST	DW	
;	ENT	$
WANTLOOP	EQU	1	;0 = ne boucle pas (routine + rapide)
DECRUBUF	EQU	#E000	;doit valoir x000 ou x800 (cf ATTRIBU)
YMLZ	EQU	#7600	;Adresse fichier compacte
DUREE	EQU	YMLZ	;Indiquee dans le header
;
;
	CALL	LOAD
;
	DI	
	LD	BC,#7F10
	OUT	(C),C
	LD	A,#54
	OUT	(C),A
;
	LD	HL,(#38)
	LD	(INTER+1),HL
	LD	HL,#C9FB
	LD	(#38),HL
	EXX	
	EX	AF,AF'
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	EI	
	CALL	READHEAD
	CALL	ATTRIBU
	CALL	CREEPLAY
	CALL	POKECODE
	CALL	RAZVAR
	CALL	RAZ_PSG
;
;Il faut preparer quelques donnees d'avances
;
	LD	A,(NBR_REG)
AMORCE
	PUSH	AF
	CALL	GETREG
	POP	AF
	DEC	A
	JR	NZ,AMORCE
;
;
;
MAIN
	LD	BC,#F501
SYNC_1
	IN	A,(C)
	AND	C
	JR	Z,SYNC_1
;
	HALT	
	HALT	
	HALT	
FASTFOWA
	LD	BC,#7F10
	OUT	(C),C
	LD	A,#44
	OUT	(C),A
	CALL	GETREG
	LD	BC,#7F10
	OUT	(C),C
	LD	A,#56
	OUT	(C),A
	CALL	PLAYREG
	LD	BC,#7F10
	OUT	(C),C
	LD	A,#54
	OUT	(C),A
;
	IF	WANTLOOP
	ELSE	
MESURE	LD	HL,0
	DEC	HL
	LD	(MESURE+1),HL
	LD	A,H
	OR	L
	JR	Z,FIN
	END	
;
	LD	A,#40
	CALL	TST_KEY
	RLA	
	JR	NC,FASTFOWA
;
	LD	A,#45
	CALL	TST_KEY
	AND	128
	JP	NZ,MAIN
;
FIN
	DI	
INTER	LD	HL,0
	LD	(#38),HL
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	EX	AF,AF'
	EXX	
	EI	
	JP	#BCA7
;
RAZ_PSG
;
;La routine de PLAY ne met pas a jour les registres s'ils ne sont pas modifies.
;Or, ils sont consideres a 0 lors de la 1er interation.
;On doit donc reelement les mettre a 0. (nb 7 a 0 : canaux et bruit ouverts)
;
	LD	B,14
	LD	C,13	;Volumes raz avant reg 7
	XOR	A
RP_LP
	PUSH	BC
	CALL	PSG
	POP	BC
	DEC	C
	DJNZ	RP_LP
;
	RET	
;
;
PSG
	LD	B,#F4
	OUT	(C),C
	LD	BC,#F6C0
	OUT	(C),C
	DB	#ED,#71
	LD	B,#F4
	OUT	(C),A
	LD	BC,#F680
	OUT	(C),C
	DB	#ED,#71
	RET	
;
TST_KEY
	DI	
	LD	BC,#F40E
	OUT	(C),C
	LD	BC,#F6C0
	OUT	(C),C
	DB	#ED,#71
	LD	BC,#F792
	OUT	(C),C
	LD	B,#F6
	OUT	(C),A
	LD	A,#F4
	IN	A,(0)
	DB	#ED,#71
	LD	BC,#F782
	OUT	(C),C
	EI	
	RET	
;
;
MODELE
	LD	A,(HL)
	CP	0
	JR	Z,MO_SAME
	LD	(0),A	;0 remplace dans CREEPLAY
;
MO_SUITE
	OUT	(C),C	;Registre
	EXX	
	DB	#ED,#71	; OUT (C),0
	LD	B,H
	OUT	(C),A
	LD	B,L
	OUT	(C),E
	OUT	(C),D
	EXX	
MO_SAME
	INC	C
MO_END
;
MO2
	INC	DE
	LD	A,D
	AND	#3
	LD	D,A
	LD	(PLAYPLAG+1),DE
	RET	
MO2_END
;
;
PLAYREG
	LD	DE,#C080
	LD	HL,#F4F6
	LD	B,L
	OUT	(C),D
	EXX	
PLAYPLAG	LD	DE,0	;Fourni poids faible (sur 8 et 10 bits)
; PLAYPLAG est remis a jour la fin
	LD	L,E
	LD	B,#F4
	LD	C,0
;
;
;Partie  cree par CREEPLAY
;
PLAYCODE	DS	MO_END-MODELE+4*14
	DS	MO2_END-MO2
;
GETREG
	DI	
	LD	(SAVETMP+1),SP
	LD	A,(NBR_REG)	;Necessaire pour V1 a V13
	DEC	A	;mais pas pour VMESURE/V0 
	IF	WANTLOOP
	DB	#DD
DECALEH	LD	H,0
	END	
	LD	IY,GET_RET
GETWITCH	JP	V0	;Quelle routine ?
GET_RET
	LD	HL,(GETWITCH+1)
	DEC	HL
	LD	D,(HL)	;Recupere adresse
	DEC	HL
	LD	E,(HL)
	LD	(GETWITCH+1),DE
SAVETMP	LD	SP,0
	EI	
	RET	
;
;
	DW	V1	;Adresse prochaine routine
VMESURE
	IF	WANTLOOP
;
;S'il reste moins que "NBR_REG" donnees a recuperer,
;on recupere ces quelques donnees, on reset (methode brute pour l'instant),
;puis on recupere qq donnees complementaire.
;
;Sinon, on saute normallement a V0, et le test ne sera pas effectue
;de V1 a V13 ...
;
MESURE	LD	HL,0
	LD	C,L
	LD	D,0
	LD	A,(NBR_REG)
	LD	E,A
	OR	A
	SBC	HL,DE
	LD	(MESURE+1),HL
	DEC	A
	JP	NC,V0
;
;Pour V1 etc..., on ne refera pas le test precedent
;
	LD	B,D
	LD	DE,RETIENT
	LD	(GETWITCH+1),DE
	LD	DE,(DUREE)
	ADD	HL,DE
	LD	(MESURE+1),HL
	LD	A,C
	LD	(COMPLETE+1),A
	LD	(RETIENT+1),A
;
;On doit determiner la position destination dans les buffers
;
	LD	HL,(PLAYPLAG+1)
	ADD	HL,BC
	LD	A,(NBR_REG)
	LD	C,A
	ADD	HL,BC
	LD	A,H
	AND	#3
	LD	(DECALEH+1),A
	LD	A,L
	LD	(DECALEL+1),A
;
RETIENT	LD	A,0
	DEC	A
	JP	M,CAS0	;0 data ? Il faut reseter
	LD	IY,GET_RET_
GETWITC_	JP	V0
;
CAS0
	LD	A,(NBR_REG)
	JR	RESET
;
GET_RET_
	LD	A,(NBR_REG)
COMPLETE	LD	B,0
	SUB	B
;
RESET
	LD	HL,(GETWITC_+1)
	INC	HL
	LD	E,(HL)	;Plage de variable
	INC	HL
	LD	D,(HL)
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	LD	HL,REGSCOPY-REGS+1
	ADD	HL,DE
	EX	DE,HL
DECALEL	LD	(HL),0
	INC	HL
	EX	DE,HL
	LDI	
	LDI	
	LDI	
	LDI	
	LDI	
;
	LD	IY,GET_RET2
	DEC	A
	JR	GETWITC_
GET_RET2
	LD	HL,(GETWITC_+1)
	DEC	HL
	LD	D,(HL)	;Recupere adresse
	DEC	HL
	LD	E,(HL)
	LD	HL,-VMESURE-1	;Pour redirection, il faut boucler sur 
	ADD	HL,DE	;V0
	JR	C,REGLP_OK
	LD	HL,VMESURE
	LD	(GETWITCH+1),DE
	LD	DE,V0
REGLP_OK
	LD	(GETWITC_+1),DE
	LD	SP,(SAVETMP+1)
	EI	
	RET	
;
;
	DW	V1
	END	
V0
	LD	SP,REGS	;!!! PLACER le LD SP apres le label !!!
VROUT	JP	DECOMP4	;ATTENTION ! L'ecart doit rester
	DW	V2
V1
	LD	SP,REGS+10
VROUT_	JP	DECOMP0	;constant pour les modifs d'ATTRIBU
	DW	V3
V2
	LD	SP,REGS+20
	JP	DECOMP4
	DW	V4
V3
	LD	SP,REGS+30
	JP	DECOMP0
	DW	V5
V4
	LD	SP,REGS+40
	JP	DECOMP4
	DW	V6
V5
	LD	SP,REGS+50
	JP	DECOMP0
	DW	V7
V6
	LD	SP,REGS+60
	JP	DECOMP0
	DW	V8
V7
	LD	SP,REGS+70
	JP	DECOMP0
	DW	V9
V8
	LD	SP,REGS+80
	JP	DECOMP0
	DW	V10
V9
	LD	SP,REGS+90
	JP	DECOMP0
	DW	V11
V10
	LD	SP,REGS+100
	JP	DECOMP0
	DW	V12
V11
	LD	SP,REGS+110
	JP	DECOMP0
	DW	V13
V12
	LD	SP,REGS+120
	JP	DECOMP0
	DW	VMESURE	;!!! BOUCLE EN CONCORDANCE AVEC NBR_REG
V13
	LD	SP,REGS+130
	JP	DECOMP0
	DW	V15
V14
	LD	SP,REGS+140
	JP	DECOMP0
	DW	V0
V15
	LD	SP,REGS+150
	JP	DECOMP0
;
;
D0_CHR
;
;Place  en premier pour etre atteint par JR
;
	EX	AF,AF'
	LD	A,(HL)
	INC	HL
	EXX	
	LD	(DE),A
	INC	E
	EX	AF,AF'
;
;On decremente nbr de caracteres restants.
;
	DEC	A
	EXX	
	JP	P,D0_NEXT
;
;
	PUSH	HL
	PUSH	BC
	EXX	
;
	PUSH	BC	;B DOIT ETRE NUL ICI
	PUSH	HL	;Bidon
	PUSH	DE
	JP	(IY)
;
;
DECOMP0
;
;Entree  : A  = nbr de donnees a decompacter - 1
;          IY = adr de retour
;On suppose que longueur est code en negatif (ie -2 -> 2 caracteres)
;
;On recupere adr destination dans tous les cas
;(Remarque : D ne change pas, il y a peut etre moyen d'optimiser cela)
;
	POP	DE
	POP	HL	;Adresse source pour copie chaine
;
;On recupere B = nbr de caracteres a copier   C est inutilise
;
	POP	BC
	INC	B
	DEC	B
	JR	Z,D0_FLAG
;
D0_MESUR
;
;On regarde si longueur de chaine restante > nbr de donnees a fournir
;
	IF	WANTLOOP
	EXX	
	LD	D,A
	EXX	
	ADD	A,B	;longueur codee en negatif
	JR	NC,D0_AL_
	ELSE	
	ADD	A,B
	JR	NC,D0_ALL
	END	
;
	EX	AF,AF'
D0_LP1
	LD	A,(HL)
	INC	L
	LD	(DE),A
	INC	E
	INC	B
	JR	NZ,D0_LP1
	EX	AF,AF'
;
D0_FLAG
;
;On recupere FLAGs et pointeur donnees compressees
;(B inutilise)
;
	EXX	
	POP	BC
	POP	HL
;
;
;On extrait nouveau flag
;
D0_NEXT
	SLA	C
	JR	NZ,D0_FLGOK
;
	LD	C,(HL)
	INC	HL
	DB	#CB,#31	;SLL C
D0_FLGOK
	JR	NC,D0_CHR
;
;Test similaire au precedent
;
	LD	B,(HL)
	INC	HL
	LD	D,A	;Sauve pour D0_LEFT
	ADD	A,B
	JR	NC,D0_LEFT
;
;Il restera (A+1) donnees a fournir apres copie de la chaine
;
	EX	AF,AF'
	LD	A,B
	EXX	
	LD	B,A
	EXX	
	LD	A,(HL)
	INC	HL
	EXX	
	IF	WANTLOOP
	ADD	A,C
	END	
	LD	L,A
D0_LP2
	LD	A,(HL)
	INC	L
	LD	(DE),A
	INC	E
	INC	B
	JR	NZ,D0_LP2
	EX	AF,AF'
	EXX	
	JR	D0_NEXT
;
D0_LEFT
;
;Idem que D0_ALL mais sur moins de donnees.
;
	EX	AF,AF'	;Pour l'instant on conserve A-B
	LD	A,D	;Nombre de valeur restantes a copier-1
	EXX	
	LD	B,A
	INC	B
	EXX	
	LD	A,(HL)
	INC	HL
	PUSH	HL
	PUSH	BC
	EXX	
	IF	WANTLOOP
	ADD	A,C
	END	
	LD	L,A
D0_LP3
	LD	A,(HL)
	INC	L
	LD	(DE),A
	INC	E
	DJNZ	D0_LP3
	EX	AF,AF'
	LD	B,A
	INC	B	;Longueur restante pour prochaine fois
	PUSH	BC
;
	PUSH	HL
	PUSH	DE
	JP	(IY)
;
	IF	WANTLOOP
D0_AL_
;
;  D0_ALL ne convient pas quand on veut changer dynamiquement le nombre
;  de valeurs a recuperer (c'est le cas pour le bouclage).
;
	INC	A
	LD	B,A
	PUSH	BC
	EXX	
	LD	A,D
	EXX	
	LD	B,A
	INC	B
;
D0_AL_LP	LD	A,(HL)
	LD	(DE),A
	INC	L
	INC	E
	DJNZ	D0_AL_LP
;
	PUSH	HL
	PUSH	DE
	JP	(IY)
;
	ELSE	
;
D0_ALL
;
;La chaine a copier fournie toutes les donnees
;
	INC	A
	LD	B,A	;Longueur restante pour prochaine fois
	PUSH	BC
;
D0_COPY	LD	A,(HL)
	LD	(DE),A
	INC	L
	INC	E
	DS	80	;Place pour NBR_REG copies
	DS	5	;Place pour D0_MODEL
;
D0_MODEL			;Sera copie a la suite des LDI
	PUSH	HL
	PUSH	DE
	JP	(IY)
D0_MODE_
;
	END	
;
;
D4_CHR
;
;Place  en premier pour etre atteint par JR
;
	EX	AF,AF'
	LD	A,(HL)
	INC	HL
	EXX	
	LD	(DE),A
	INC	DE
	RES	2,D
	EX	AF,AF'
;
;On decremente nbr de caracteres restants.
;
	DEC	A
	EXX	
	JP	P,D4_NEXT
;
;
	PUSH	HL
	PUSH	BC
	EXX	
;
	PUSH	BC	;B DOIT ETRE NUL ICI
	PUSH	HL	;Bidon
	PUSH	DE
	JP	(IY)
;
;
DECOMP4
;
;Base sur DECOMP0
;Entree  : A  = nbr de donnees a decompacter - 1
;          IY = adr de retour
;On suppose que longueur est code en negatif (ie -2 -> 2 caracteres)
;
;On recupere adr destination dans tous les cas
;(Remarque : D ne change pas, il y a peut etre moyen d'optimiser cela)
;
	POP	DE
	POP	HL	;Adresse source pour copie chaine
;
;On recupere B = nbr de caracteres a copier   C est inutilise
;
	POP	BC
	INC	B
	DEC	B
	JR	Z,D4_FLAG
;
D4_MESUR
;
;On regarde si longueur de chaine restante > nbr de donnees a fournir
;
	IF	WANTLOOP
	EXX	
	LD	D,A
	EXX	
	ADD	A,B	;longueur codee en negatif
	JR	NC,D4_AL_
	ELSE	
	ADD	A,B
	JR	NC,D4_ALL
	END	
;
	EX	AF,AF'
D4_LP1
	LD	A,(HL)
	INC	HL
	RES	2,H
	LD	(DE),A
	INC	DE
	RES	2,D
	INC	B
	JR	NZ,D4_LP1
	EX	AF,AF'
;
D4_FLAG
;
;On recupere FLAGs et pointeur donnees compressees
;(B inutilise)
;
	EXX	
	POP	BC
	POP	HL
;
;
;On extrait nouveau flag
;
D4_NEXT
	SLA	C
	JR	NZ,D4_FLGOK
;
	LD	C,(HL)
	INC	HL
	DB	#CB,#31	;SLL C
D4_FLGOK
	JR	NC,D4_CHR
;
;Test similaire au precedent
;
	LD	B,(HL)
	INC	HL
	LD	D,A	;Sauve pour D4_LEFT
	ADD	A,B
	JR	NC,D4_LEFT
;
;Il restera (A+1) donnees a fournir apres copie de la chaine
;
	EX	AF,AF'
	LD	A,B
	EXX	
	LD	B,A
	EXX	
	LD	A,(HL)
	INC	HL
	EXX	
	IF	WANTLOOP
	ADD	A,C
	LD	L,A
	LD	A,D
	RES	0,A
	RES	1,A
	EXX	
	ADC	A,(HL)
	DB	#DD
	ADD	A,H
	AND	#FB
	ELSE	
	LD	L,A
	LD	A,D
	AND	#FC
	EXX	
	OR	(HL)
	END	
	INC	HL
	EXX	
	LD	H,A
D4_LP2
	LD	A,(HL)
	INC	HL
	RES	2,H
	LD	(DE),A
	INC	DE
	RES	2,D
	INC	B
	JR	NZ,D4_LP2
	EX	AF,AF'
	EXX	
	JR	D4_NEXT
;
D4_LEFT
;
;Idem que D4_ALL mais sur moins de donnees.
;
	EX	AF,AF'	;Pour l'instant on conserve A-B
	LD	A,D	;Nombre de valeur restantes a copier-1
	EXX	
	LD	B,A
	INC	B
	EXX	
	LD	A,(HL)
	INC	HL
	EXX	
	IF	WANTLOOP
	ADD	A,C
	LD	L,A
	LD	A,D
	RES	0,A
	RES	1,A
	EXX	
	ADC	A,(HL)
	DB	#DD
	ADD	A,H
	AND	#FB
	ELSE	
	LD	L,A
	LD	A,D
	AND	#FC
	EXX	
	OR	(HL)
	END	
	INC	HL
	PUSH	HL
	PUSH	BC
	EXX	
	LD	H,A
D4_LP3
	LD	A,(HL)
	INC	HL
	RES	2,H
	LD	(DE),A
	INC	DE
	RES	2,D
	DJNZ	D4_LP3
	EX	AF,AF'
	LD	B,A
	INC	B	;Longueur restante pour prochaine fois
	PUSH	BC
;
	PUSH	HL
	PUSH	DE
	JP	(IY)
;
	IF	WANTLOOP
D4_AL_
;
;  D0_ALL ne convient pas quand on veut changer dynamiquement le nombre
;  de valeurs a recuperer (c'est le cas pour le bouclage).
;
	INC	A
	LD	B,A
	PUSH	BC
	EXX	
	LD	A,D
	EXX	
	LD	B,A
	INC	B
;
D4_AL_LP	LD	A,(HL)
	LD	(DE),A
	INC	HL
	RES	2,H
	INC	DE
	RES	2,D
	DJNZ	D4_AL_LP
;
	PUSH	HL
	PUSH	DE
	JP	(IY)
;
	ELSE	
;
D4_ALL
;
;La chaine a copier fournie toutes les donnees
;
	INC	A
	LD	B,A	;Longueur restante pour prochaine fois
	PUSH	BC
;
D4_COPY	LD	A,(HL)
	LD	(DE),A
	INC	HL
	RES	2,H
	INC	DE
	RES	2,D
	DS	154	;Place pour NBR_REG copies
	DS	5	;Place pour D0_MODEL
;
D4_MODEL			;Sera copie a la suite des LDI
	PUSH	HL
	PUSH	DE
	JP	(IY)
D4_MODE_
;
	END	
;
;
READHEAD
;
;On va   analyser le header
;
	LD	HL,(DUREE)
	LD	(MESURE+1),HL
;
	RET	
;
;
ATTRIBU
;
;On reparti les tampons de decompressions. Ceux de #400 de long se placent
;     en #?000 ou #?800 pour faciliter le modulo, et la routine intercale
;ceux de #100 dans les trous (pile poil).
;
;On place d'abord ceux de #400
;
	LD	HL,OFBUF0
	LD	D,DECRUBUF/#100
	EXX	
	LD	HL,(ADRTEMP)
	INC	HL
	INC	HL	;Flag Decomp400 ou Decomp100
	PUSH	HL
	LD	DE,3
	LD	A,(NBR_REG)
	LD	B,A	;B=cpt loop, C = nbr de buffer400
	LD	C,0
ATT_LP
	LD	A,(HL)
	CP	1
	JR	Z,ATT_BUF1
	EXX	
	LD	(HL),D
	INC	HL
	LD	(HL),4
	DEC	HL
	LD	A,D
	ADD	A,8
	LD	D,A
	EXX	
	INC	C
ATT_BUF1
	EXX	
	INC	HL
	INC	HL
	EXX	
	ADD	HL,DE
	DJNZ	ATT_LP
;
;Maintenant on va placer les buffer100
;
	LD	HL,OFBUF0
	LD	D,DECRUBUF/#100
	LD	B,3	;Pour intercaler 4 buffer100
	EXX	
	POP	HL
	PUSH	HL
	LD	DE,3
	LD	A,(NBR_REG)
	LD	B,A
ATT_LP2
	LD	A,(HL)
	CP	4	;On l'a deja traite
	JR	Z,ATT_BUF4
	EXX	
	LD	A,B
	INC	A
	AND	3
	LD	B,A
	JR	NZ,ATT_OK	;On est pas sur une adr congrue a #400
	LD	A,C
	OR	A
	JR	Z,ATT_OK	;On a passe tout les buffer #100
	DEC	C
	LD	A,D	;Sinon on saute buffer #400
	ADD	A,4
	LD	D,A
ATT_OK	LD	(HL),D
	INC	HL
	LD	(HL),1
	DEC	HL
	INC	D
	EXX	
ATT_BUF4
	EXX	
	INC	HL
	INC	HL
	EXX	
	ADD	HL,DE
	DJNZ	ATT_LP2
;
;Un dernier passage pour passer les bons JUMP
;
	LD	HL,VROUT+1
	LD	BC,VROUT_-VROUT-1
	EXX	
	POP	HL
	LD	DE,3
	LD	A,(NBR_REG)
	LD	B,A
ATT_LP3
	LD	A,(HL)
	CP	1
	EXX	
	LD	DE,DECOMP0
	JR	Z,ATT_R1
	LD	DE,DECOMP4
ATT_R1
	LD	(HL),E
	INC	HL
	LD	(HL),D
	ADD	HL,BC
	EXX	
	ADD	HL,DE
	DJNZ	ATT_LP3
	RET	
;
POKECODE
;
;Code bon nombre de LDIs dans routines de decompression
;
	IF	WANTLOOP
	ELSE	
;
	LD	A,(NBR_REG)
	DEC	A
	SLA	A
	SLA	A
	LD	C,A
	LD	B,0
	LD	HL,D0_COPY
	LD	DE,D0_COPY+4
	LDIR	
	LD	HL,D0_MODEL
	LD	BC,D0_MODE_-D0_MODEL
	LDIR	
;
	LD	A,(NBR_REG)
	DEC	A
	SLA	A
	SLA	A
	SLA	A
	LD	C,A
	LD	B,0
	LD	HL,D4_COPY
	LD	DE,D4_COPY+8
	LDIR	
	LD	HL,D4_MODEL
	LD	BC,D4_MODE_-D4_MODEL
	LDIR	
;
	END	
	RET	
;
CREEPLAY
;
;Cree routine PLAYREG suivant taille des BUFFERS
;
	LD	HL,OFBUF0
	LD	DE,PLAYCODE
;
	LD	B,(HL)	;Poids fort du 1er tampon
	INC	HL
	LD	A,(HL)	;Taille
	INC	HL
	CP	1
	CALL	Z,CP_1
	CALL	NZ,CP_4
;
	LD	B,13	;13 premiers registre
CP_LP
	PUSH	BC
	CALL	CP_COPY
;
	LD	B,(HL)
	INC	HL
	LD	A,(HL)
	CP	4
	CALL	Z,CP_4
	JR	Z,CP_SUI
;
;on verifie si buffer precedent etait de taille 1,
;et s'il etait place cote @ cote, pour pouvoir mettre  INC L
;
	DEC	HL
	DEC	HL
	CP	(HL)
	CALL	NZ,CP_1
	JR	NZ,CP_SUI0
;
	DEC	HL
	LD	A,(HL)	;Adr precedente buffer
	INC	HL
	SUB	B
	INC	A
	CALL	Z,CP_1INC
	CALL	NZ,CP_1
CP_SUI0
	INC	HL
	INC	HL
;
CP_SUI
	INC	HL
	POP	BC
	DJNZ	CP_LP
;
;le registre 13 a un traitement different
;on le joue meme en cas de valeur identique, sauf si c'est #FF
;
	EX	DE,HL
	LD	(HL),#7E	;LD A,(HL)
	INC	HL
	LD	(HL),#3C	;INC A
	INC	HL
	LD	(HL),#28	;JR Z,
	INC	HL
	LD	(HL),MO_SAME-MO_SUITE+1
	INC	HL
	LD	(HL),#3D	;DEC A
	INC	HL
	EX	DE,HL
;
	LD	HL,MO_SUITE
	LD	BC,MO_END-MO_SUITE
	LDIR	
;
	DEC	DE	;On ecrase dernier INC C
	LD	HL,MO2
	LD	BC,MO2_END-MO2
	LDIR	
;
	RET	
;
;
CP_COPY
;
;On copie partie OUTs
;
	PUSH	HL
	LD	HL,MODELE
	LDI		;LD A,(HL)
	LDI		;CP 0
	LD	B,D	;on stocke nn...
	LD	C,#FF	;Pour que LDI ne modifisse pas B !
	LD	A,E
	LDI	
	LDI		;JR Z,MO_SAME
	LDI	
	LDI		;LD (nn),A
	LD	(DE),A	;...et ici on copie nn !
	INC	DE
	LD	A,B
	LD	(DE),A
	INC	DE
;
CP_COPY2	LD	HL,MO_SUITE
	LD	BC,MO_END-MO_SUITE
	LDIR	
	POP	HL
	RET	
;
;
CP_1
;
;Si tampon de taille #100 on code
;    LD   H,n
;
	EX	DE,HL
	LD	(HL),#26
	INC	HL
	LD	(HL),B
	INC	HL
	EX	DE,HL
	RET	
;
CP_1INC
;
;Quand 2 tampon de taille #100 successif, on code
;    INC  H
;
	LD	A,#24
	LD	(DE),A
	INC	DE
	RET	
;
CP_4
;
;Si c'est un tampon de taille #400, on code
;     LD   A,n
;     OR   D
;     LD   H,A
;
	EX	DE,HL
	LD	(HL),#3E
	INC	HL
	LD	(HL),B
	INC	HL
	LD	(HL),#B2
	INC	HL
	LD	(HL),#67
	INC	HL
	EX	DE,HL
	RET	
;
RAZVAR
;
;Toutes les auto-modifs pour la gestion
;
	LD	HL,VMESURE
	LD	(GETWITCH+1),HL
	IF	WANTLOOP
	LD	HL,V0
	LD	(GETWITC_+1),HL
	XOR	A
	LD	(DECALEH+1),A
	END	
	LD	HL,0
	LD	(PLAYPLAG+1),HL
;
	CALL	SETVAR
;
	LD	HL,REGS	;On copier variable pour reset/bouclage
	LD	DE,REGSCOPY
	LD	BC,16*10
	LDIR	
;
	RET	
;
;
SETVAR
;
;Init variables REGS pour la decompression.
;
	LD	HL,OFBUF0
	EXX	
	LD	A,(NBR_REG)
	LD	B,A	;Nombre registres traites
	LD	DE,(ADRTEMP)	;Pointe sur donnees (en relatif)
	INC	DE
	INC	DE	;Saute "longueur"
	LD	HL,REGS
RAZLOOP
	PUSH	BC
;
;On place adr DEST
;
	EXX	
	LD	A,(HL)
	INC	HL
	INC	HL
	EXX	
	LD	(HL),0
	INC	HL
	LD	(HL),A
	INC	HL
;
;Adr source pour copie chaine : forcement meme poids fort qd fenetre #100
;
	INC	HL
	LD	(HL),A
	INC	HL
;
;Valeur decalage (quand boucle, les donnees ne sont plus placees a partir de 0,
;les references absolues doivent etre corrigees)
;
	LD	(HL),0
	INC	HL
;
;On place nbr de chr restant a copier = 0
;
	LD	(HL),0
	INC	HL
;
;Octet flag a #40 pour copie 1er octet et enclencher lecture nouveaux flags
;
	LD	(HL),#40
	INC	HL
	INC	HL
;
;Maintenant il faut lire adr debut donnees compresses,
;donnees en relatif par rapport a position courante dans header
;
	EX	DE,HL
	INC	HL	;On saute type compression
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
;
	PUSH	HL
	ADD	HL,BC
	LD	B,H
	LD	C,L
	POP	HL
;
	INC	HL
	EX	DE,HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
	INC	HL
;
	POP	BC
	DJNZ	RAZLOOP
	RET	
;
;
;
STORE
	LD	BC,#7FC5	;Sauve DAMS
	OUT	(C),C
	LD	HL,#800
	LD	DE,#4000
	LD	BC,#3800
	LDIR	
	RET	
;
LOAD
	LD	A,(FLAGLOAD)
	OR	A
	RET	NZ
	INC	A
	LD	(FLAGLOAD),A
;
	LD	HL,YMNAME
	LD	DE,YMLZ
	PUSH	DE
	LD	B,14
	CALL	#BC77
	POP	HL	;Adresse
	CALL	#BC83
	CALL	#BC7A
;
	RET	
;
;
RESTORE
	LD	BC,#7FC6
	OUT	(C),C
	LD	HL,#4000
	LD	DE,#3000
	LD	BC,#1000
	LDIR	
	RET	
;
;
;
YMNAME	DM	0:FOFT    .BIN
;
VAR			;Variables de travail
;
REGS	DS	16*10	;Variables pour chaque registre
REGSCOPY	DS	16*10	;Pour reset lors du bouclage
;
; Pour chaque registre, on a :
;
; Adresse destination     (DE)
; Adresse source chaine   (HL)  ne sert pas forcement
; Flag/compteur chaine    (BC)  C : poids faible decalage
; Octet flags             (BC') B' inutilise
; Source data compresses  (HL')
;
DATA
;
;NBR_REG est une constante qui permet de determiner combien recuperer
;de donnees a la fois. Si NBR_REG = 14, on recupere 14 donnees par registre et
;par VBL. Au bout de 14 VBL, on peut jouer 14 fois tous les reg., le temps de
;recuperer 14*14 nouvelles donnees.
;
NBR_REG	DB	14	;!!! MODIFIER (V14-2) EN CONSEQUENCE !!
;
;
ADRTEMP	DW	YMLZ
;
;
;
OFBUF0	DB	#C0	;Poids fort adresse
	DB	4	;Taille (1 ou 4) pour CREEPLAY 
;
;Attention les tampons de #400 doivent commencer en #x000 ou #x800
;
	DB	#C4,1,#C8,4,#C5,1,#D0,4
	DB	#C6,1,#C7,1,#CC,1,#CD,1
	DB	#CE,1,#CF,1,#D4,1,#D5,1
	DB	#D6,1,#D7,1,#D8,1
;
