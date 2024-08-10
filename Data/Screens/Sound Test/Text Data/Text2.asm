; ===========================================================================
; Main
; ===========================================================================

Off_MusicAuthor_Text: offsetTable
		offsetTableEntry.w .n1
		offsetTableEntry.w .n2
		offsetTableEntry.w .n3
		offsetTableEntry.w .n4
		offsetTableEntry.w .n5
		offsetTableEntry.w .n6
		offsetTableEntry.w .n7
		offsetTableEntry.w .n8
		offsetTableEntry.w .n9
		offsetTableEntry.w .n10
		offsetTableEntry.w .n11
		offsetTableEntry.w .n12
		offsetTableEntry.w .n13
		offsetTableEntry.w .n14
		offsetTableEntry.w .n15
		offsetTableEntry.w .n16
		offsetTableEntry.w .n17
		offsetTableEntry.w .n18
		offsetTableEntry.w .n19
		offsetTableEntry.w .n20
		offsetTableEntry.w .n21
		offsetTableEntry.w .n22
		offsetTableEntry.w .n23
		offsetTableEntry.w .n24
		offsetTableEntry.w .n25
; ---------------------------------------------------------------------------

.n1:		; FDZ1.1
		dc.b $FE									; calc pos
		namemstr "Actraiser"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Filmore"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED"
		dc.b -1									; end

.n2:		; FDZ1.2
		dc.b $FE									; calc pos
		namemstr "Rusty (PC-98)"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Queen In The Dark Night"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. John **Joy** Tay"
		dc.b -1									; end

.n3:		; FDZ2
		dc.b $FE									; calc pos
		namemstr "Super Castlevania IV"
		dc.b $80, $FE							; next line, calc pos
		namemstr "The Forest of Monsters"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED"
		dc.b -1									; end

.n4:		; SCZ1
		dc.b $FE									; calc pos
		namemstr "Castlevania: Portrait of Ruin"
		dc.b $80, $FE							; next line, calc pos
		namemstr "The Gears Go Awry"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED, GENATAR_i"
		dc.b -1									; end

.n5:		; SCZ2
		dc.b $FE									; calc pos
		namemstr "Periphery"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Captain On"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED, GENATAR_i"
		dc.b -1									; end

.n6:		; SCZ3
		dc.b $FE									; calc pos
		namemstr "Dahna: Megami Tanjou"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Stage 7-2"
		dc.b $80, $FE							; next line, calc pos
		namemstr "port. TheBlad768"
		dc.b -1									; end

.n7:		; MGZ1
		dc.b $FE									; calc pos
		namemstr "Castlevania: Symphony of the Night"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Dracula*s Castle"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED"
		dc.b -1									; end

.n8:		; MGZ2
		dc.b $FE									; calc pos
		namemstr "Castlevania: Aria of Sorrow"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Clock Tower"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED, GENATAR_i"
		dc.b -1									; end

.n9:		; MGZ3
		dc.b $FE									; calc pos
		namemstr "Rusty (PC-98)"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Mysterious Chapel"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED"
		dc.b -1									; end

.n10:	; Microboss Theme
		dc.b $FE									; calc pos
		namemstr "Akumajou Dracula"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Creatures in the Depth"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED, N-BAH"
		dc.b -1									; end

.n11:		; Miniboss Theme
		dc.b $FE									; calc pos
		namemstr "HS original - by iwontbeforgotten"
		dc.b $80, $FE							; next line, calc pos
		namemstr "                              "
		dc.b $80, $FE							; next line, calc pos
		namemstr "                              "
		dc.b -1									; end

.n12:	; Options
		dc.b $FE									; calc pos
		namemstr "Dragon*s Fury"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Bonus Table 6"
		dc.b $80, $FE							; next line, calc pos
		namemstr "port. TheBlad768"
		dc.b -1									; end

.n13:	; Sin City Major Boss
		dc.b $FE									; calc pos
		namemstr "Gerry Trevino"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Imhotep"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED, GENATAR_i"
		dc.b -1									; end

.n14:	; Malicious Glance Major Boss
		dc.b $FE									; calc pos
		namemstr "Doom Eternal"
		dc.b $80, $FE							; next line, calc pos
		namemstr "BFG-10000"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED"
		dc.b -1									; end

.n15:	; Main Theme
		dc.b $FE									; calc pos
		namemstr "HS original - by Gerry Trevino"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Through Hell and Fire"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. GENATAR_i, FoxConED"
		dc.b -1									; end

.n16:	; FDZ3
		dc.b $FE									; calc pos
		namemstr "Dahna: Megami Tanjou"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Stage 5-1"
		dc.b $80, $FE							; next line, calc pos
		namemstr "port. TheBlad768"
		dc.b -1									; end

.n17:	; Forest of Decay Major Boss
		dc.b $FE									; calc pos
		namemstr "Rusty (PC-98)"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Rhythm of the Dark"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED, GENATAR_i"
		dc.b -1									; end

.n18:	; Title Theme
		dc.b $FE									; calc pos
		namemstr "HS original - by Gerry Trevino"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED, GENATAR_i"
		dc.b $80, $FE							; next line, calc pos
		namemstr "                              "
		dc.b -1									; end

.n19:	; Spirit World
		dc.b $FE									; calc pos
		namemstr "HS original - by GENATAR_i"
		dc.b $80, $FE							; next line, calc pos
		namemstr "                              "
		dc.b $80, $FE							; next line, calc pos
		namemstr "                              "
		dc.b -1									; end

.n20:	; Death Jingle
		dc.b $FE									; calc pos
		namemstr "Castlevania: Bloodlines"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Live Lost"
		dc.b $80, $FE							; next line, calc pos
		namemstr "port. TheBlad768"
		dc.b -1									; end

.n21:	; Notice
		dc.b $FE									; calc pos
		namemstr "Megami Tanjou"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Game Over"
		dc.b $80, $FE							; next line, calc pos
		namemstr "port. TheBlad768"
		dc.b -1									; end

.n22:	; Results
		dc.b $FE									; calc pos
		namemstr "HS original - by GENATAR_i"
		dc.b $80, $FE							; next line, calc pos
		namemstr "                              "
		dc.b $80, $FE							; next line, calc pos
		namemstr "                              "
		dc.b -1									; end

.n23:	; Credits
		dc.b $FE									; calc pos
		namemstr "One Ok Rock"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Vandalize"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. John **Joy** Tay"
		dc.b -1									; end

.n24:	; Final Boss Phase 2
		dc.b $FE									; calc pos
		namemstr "Periphery"
		dc.b $80, $FE							; next line, calc pos
		namemstr "Follow your ghost"
		dc.b $80, $FE							; next line, calc pos
		namemstr "arr. FoxConED, pixelcat"
		dc.b -1									; end		
.n25:	; Final Boss Phase 2
		dc.b $FE									; calc pos
		namemstr "HS original - by pixelcat"
		dc.b $80, $FE							; next line, calc pos
		namemstr "                              "
		dc.b $80, $FE							; next line, calc pos
		namemstr "                              "
		dc.b -1									; end				

	even
