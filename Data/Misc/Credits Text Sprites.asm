; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite rendering routine
; --- inputs ----------------------------------------------------------------
; d7.w = Number of sprites left
; a6.l = Sprite table address
; ---------------------------------------------------------------------------

CRE_SpriteRender:
		movem.l	d0-d6/a0-a5,-(sp)				; store registers
		cmpi.w	#$1180,(Camera_X_pos).w				; has the screen reached the plane credits area?
		bpl.w	.Finish						; if so, branch for clouds
		tst.b	(CreditsText_Ready).w				; are sprites allowed to show?
		bne.s	.Show						; if so, process the sprites
		movem.l	(sp)+,d0-d6/a0-a5				; restore registers
		rts							; return (skip the lot)

	.Show:
		lea	(CreditsLetters).l,a1				; load letter sprite SST
		move.b	CreShape(a1),d6					; is this the last slot?
		bmi.w	.Finish						; if so, branch

	.Next:
		tst.b	CreShow(a1)					; is the sprite hidden?
		beq.w	.Hidden						; if so, don't render

		subq.w	#$01,d7						; decrease sprite count
		bpl.s	.EnoughSpace					; if there's enough space, branch
		bcs.s	.EnoughSpace					; ''
		addq.w	#$01,d7						; keep it where it was
		bra.w	.Finish						; finish (no more space for letters)

	.EnoughSpace:
		move.w	CrePosY(a1),(a6)+				; save Y position
		move.b	d6,(a6)+					; save shape
		addq.w	#$01,a6						; skip link
		move.w	CrePattern(a1),(a6)+				; save pattern
		move.w	CrePosX(a1),(a6)+				; save X position

	.Hidden:
		lea	CreSize(a1),a1					; advance to next slot
		move.b	CreShape(a1),d6					; is this the last slot?
		bpl.w	.Next						; if not, process

	.Finish:
		movem.l	(sp)+,d0-d6/a0-a5				; restore registers
		rts							; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to render cloud sprites
; ---------------------------------------------------------------------------

CRE_MapTails:	binclude "Levels\CRE\Data\Tails\Map.bin"
		even

CRE_SpriteClouds:
		cmpi.w	#$0400,(Current_Zone).w				; is this the credits?
		bne.w	.Finish						; if not, skip
		cmpi.w	#$1180,(Camera_X_pos).w				; has the screen reached the plane credits area?
		bmi.w	.Finish						; if not, skip clouds
		movem.l	d0-d6/a0-a5,-(sp)				; store registers

	; --- Tails ---

		moveq	#$30,d3						; starting X position on screen
		add.w	(CreditsTailsX).w,d3				; add tails' camera position (for when moving off)
		sub.w	(CreditsTailsXCam).w,d3				; minus tails' current camera position (for when moving off)
		cmpi.w	#$0180,d3					; has tails gone off-screen yet?
		bge.s	.NoTails					; if so, skip tails
		lea	CRE_MapTails(pc),a2				; load tails mappings
		move.w	#$0000|(VRAM_CreditsTails/$20),d5		; base pattern index
		move.w	#$00B0,d4					; Y position on-screen for tails
		moveq	#$06,d0						; get animation frame (fast animation)
		and.w	(Level_frame_counter).w,d0			; ''
		tst.w	(CreditsTailsXCam).w				; is Tails now moving off-screen?
		bne.s	.FastAni					; if so, use fast animation
		moveq	#$0C,d0						; get animation frame (slow animation)
		and.w	(Level_frame_counter).w,d0			; ''
		lsr.b	#$01,d0						; align to frame number

	.FastAni:
		bsr.w	CRE_DrawSprites					; display tails on-screen

	.NoTails:

	; --- Clouds ---

		lea	CRE_MapClouds(pc),a2				; load cloud mappings
		move.w	#$6000|(VRAM_CreditsClouds/$20),d5		; base pattern index

		move.w	(Level_frame_counter).w,d1			; load frame timer
		neg.w	d1						; reverse direction
		add.w	d1,d1						; increase speed (no camera position for reference due to the pushback)
		lea	.List(pc),a3					; load cloud list
		move.w	(a3)+,d3					; load X position
		bmi.s	.EndList					; if list is finished, branch

	.Valid:
		add.w	d1,d3						; load frame counter
		move.w	(a3)+,d4					; load Y position
		move.w	(a3)+,d0					; load frame to use
		bsr.w	CRE_DrawSprites					; render the sprites
		move.w	(a3)+,d3					; load next entry
		bpl.s	.Valid						; if valid, branch

	.EndList:
		asr.w	#$01,d1						; slow scroll down for next list
		move.w	(a3)+,d3					; load next entry
		bpl.s	.Valid						; if valid, branch

		movem.l	(sp)+,d0-d6/a0-a5				; restore registers

	.Finish:
		rts							; return

	.List:

		dc.w	   0,  104, 4
		dc.w	 280,  104, 4
		dc.w	 140,  177, 6
		dc.w	 431,  199, 2
		dc.w	  45,   67, 0

		dc.w	-1

		dc.w	 138,  155, 2
		dc.w	 174,   44, 4
		dc.w	  85,    5, 4
		dc.w	 415,    5, 6

		dc.w	-1

		dc.w	 431,   44, 6
		dc.w	 394,  155, 4
		dc.w	  45,  116, 6
		dc.w	 278,  116, 0
		dc.w	-1

		dc.w	  47,  137, 2
		dc.w	 306,  137, 0
		dc.w	 211,   74, 2
		dc.w	 467,   74, 2
		dc.w	-1

		dc.w	-1

CRE_MapClouds:	binclude "Levels\CRE\Data\Clouds\Map.bin"
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Drawing basic sprites
; --- input -----------------------------------------------------------------
; d0.w = frame number x2
; d3.w = X position on-screen
; d4.w = Y position on-screen
; d5.w = base pattern index
; d7.w = sprite slots left
; a2.l = mapping list
; a6.l = sprite table buffer
; ---------------------------------------------------------------------------

CRE_DrawSprites:
		andi.w	#-2,d0						; clear odd bit
		lea	(a2),a1						; get mapping list
		adda.w	(a1,d0.w),a1					; advance to correct frame mappings
		move.w	(a1)+,d6					; load sprite count
		bmi.s	.Finish						; if there are no pieces, branch
		move.w	d6,d0						; subtract from remaining sprites
		addq.w	#$01,d0						; ''
		sub.w	d0,d7						; subtract from remaining sprites
		bpl.s	.NextPiece					; if there are still slots left, branch
		bcs.s	.NextPiece					; ''
		add.w	d7,d6						; correct remaining amount
		move.w	#-1,d7						; force to no slots left
		addq.w	#$01,d6						; correct due to -1 = 0
		bmi.s	.Finish						; if there are no sprites able to render, skip

	.NextPiece:
		move.w	(a1)+,d0					; load Y
		add.w	d4,d0						; add base Y
		move.w	d0,(a6)+					; save to sprite table
		move.w	(a1)+,d0					; load shape
		move.b	d0,(a6)+					; save to table
		addq.w	#$01,a6						; skip link
		move.w	(a1)+,d0					; load pattern
		add.w	d5,d0						; add base pattern
		move.w	d0,(a6)+					; save to sprite table
		move.w	(a1)+,d0					; load X
		add.w	d3,d0						; add base X
		andi.w	#$01FF,d0					; keep within boundary
		beq.s	.Mask						; if 0, branch to prevent masking
		move.w	d0,(a6)+					; save to table
		dbf	d6,.NextPiece					; repeat for all pieces
		rts							; return

	.Mask:
		move.w	#1,(a6)+					; set X to non-0 but off-screen
		dbf	d6,.NextPiece					; continue

	.Finish:
		rts							; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to handle text display for credits
; ---------------------------------------------------------------------------

CRE_RunText:
		move.l	(CreditsRoutine).w,d0				; load credits/text routine
		beq.s	.Finish						; if there is no routine, return
		movea.l	d0,a0						; set routine
		jmp	(a0)						; run routine

	.Finish:

CRE_MonitorWait:
		rts							; return

; ---------------------------------------------------------------------------
; Setting up sprites
; ---------------------------------------------------------------------------

CRE_RT_Start:
		lea	($C00000).l,a5					; load VDP data port
		lea	$04(a5),a6					; load VDP control port

		lea	(CreditsLetters).l,a1				; load letter sprite SST
		moveq	#$00,d0
		move.b	(CreditsMessage).w,d0
		move.b	d0,(CreditsLastMSG).w				; store as last message
		add.w	d0,d0
		add.w	d0,d0
		lea	CRE_TextList(pc),a0
		move.l	(a0,d0.w),a0


		moveq	#$00,d2						; reset shape
		move.w	#$0080+$08,d3					; X destination start location
		move.w	#$0080+$10,d4					; Y destination start location
		move.w	#$8000|(VRAM_CreditsChars/$20),d6		; reset pattern index where tiles are
		moveq	#$00,d7						; reset delay timer

		move.w	d3,-(sp)					; store X destination

	.NewLine:
		moveq	#-1,d5						; reset tile per sprite count
		moveq	#$00,d0						; load character
		move.b	(a0)+,d0					; ''
		bmi.w	.CheckEnd					; if finished, branch

	.CheckChar:
		bne.s	.Valid						; if it's not a space character, branch
		moveq	#-1,d5						; reset tile per sprite count
		bra.w	.NextPiece					; continue for next sprite

	.Valid:
		lsl.w	#$05,d0						; multiply by size of tile
		tst.b	d2						; are we using the larger art?
		beq.s	.Small						; if not, branch
		lsl.w	#$02,d0						; multiply to size of 4 tiles
		addi.l	#CRE_CredBigArt-$80,d0				; set art address
		movea.l	d0,a3						; ''
		move.l	#$40000000,d0					; load tile address as VRAM
		move.w	d6,d0						; ''
		lsl.w	#$05,d0						; ''
		rol.l	#$02,d0						; align as VDP long-word
		ror.w	#$02,d0						; ''
		swap	d0						; ''
		move.w	#$2700,sr					; disable interrupts
		move.l	d0,(a6)						; set VDP address
		moveq	#$04-1,d0					; set to do 4 tiles
	.NextTile:
		move.l	(a3)+,(a5)					; copy letter tile over
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		dbf	d0,.NextTile					; repeat for all 4 tiles
		move.w	#$2300,sr					; enable interrupts
		bra.s	.Large						; continue

	.Small:
		addi.l	#CRE_CreditsArt-$20,d0				; set art address
		movea.l	d0,a3						; ''
		move.l	#$40000000,d0					; load tile address as VRAM
		move.w	d6,d0						; ''
		lsl.w	#$05,d0						; ''
		rol.l	#$02,d0						; align as VDP long-word
		ror.w	#$02,d0						; ''
		swap	d0						; ''
		move.w	#$2700,sr					; disable interrupts
		move.l	d0,(a6)						; set VDP address
		move.l	(a3)+,(a5)					; copy letter tile over
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		move.l	(a3)+,(a5)					; ''
		move.w	#$2300,sr					; enable interrupts

	.Large:
		move.w	d3,CreDestX(a1)					; set X destination
		move.w	d4,CreDestY(a1)					; set Y destination
		jsr	RandomNumber					; get a random position off-screen

		add.b	d0,d0						; get X left or right
		scs.b	d1						; ''
		ext.w	d1						; ''
		andi.w	#320+$20,d1					; ''
		addi.w	#$80-$10,d1					; add void space and tile width
		move.w	d1,CrePosX(a1)					; set X position/side
		ext.w	d0						; get Y left or right
		smi.b	d0						; ''
		andi.w	#224+$20,d0					; ''
		addi.w	#$80-$10,d0					; add void space and tile height
		move.w	d0,CrePosY(a1)					; set Y position/side

		move.w	d6,CrePattern(a1)				; set pattern index
		sf.b	CreShow(a1)					; keep sprite hidden
		addq.w	#$01,d6						; advance to next pattern
		move.w	d7,CreTimer(a1)					; set delay timer
		bne.s	.NoShowFirst					; if it's not already 0, keep it hidden
		st.b	CreShow(a1)					; show first sprite right away

	.NoShowFirst:
		addq.w	#3,d7						; time between sprite pieces
		clr.w	CreSlot(a1)					; set no slot (set as master slot)
		move.b	d2,CreShape(a1)					; reset shape to single tile
		addq.b	#$01,d5						; increase tile per sprite count
		andi.b	#$03,d5						; wrap 4 tiles maximum
		beq.s	.MasterPiece					; if it's a master piece, branch
		move.w	a2,CreSlot(a1)					; set master
		move.b	d5,d0						; load slot as expected master shape
		add.b	d0,d0						; ''
		add.b	d0,d0						; ''
		move.b	d0,CreCount(a1)					; store for fusion checking later
		bra.s	.ChildPiece					; continue

	.MasterPiece:
		lea	(a1),a2						; store this piece as the master

	.ChildPiece:
		lea	CreSize(a1),a1					; advance to next slot

		tst.b	d2						; are we using the larger art?
		beq.s	.NoAdjustLarge					; if not, branch
		addq.b	#$01,d5						; increase tile per sprite count by another tile
		addq.w	#$08,d3						; move right another tile
		addq.w	#$03,d6						; advance to next pattern for 4x4

	.NoAdjustLarge:

	.NextPiece:
		addq.w	#$08,d3						; move right a character

	.NextChar:
		moveq	#$00,d0						; load character
		move.b	(a0)+,d0					; ''
		bpl.w	.CheckChar					; if not finished, branch

	.CheckEnd:
		addq.b	#$01,d0						; check if it's FF
		bcs.s	.Finish						; if so, branch
		add.b	d0,d0						; each line will be $C pixels from each other
		bpl.s	.NoColour					; if this is not a palette swap, branch
		add.b	d0,d0						; is this a letter expander?
		bpl.s	.NoLarge					; if not, branch
		eori.b	#$05,d2						; change shape
		moveq	#-1,d5						; reset tile per sprite count
		bra.s	.NextChar					; redo next character

	.NoLarge:
		eori.w	#$2000,d6					; swap the palette line
		moveq	#-1,d5						; reset tile per sprite count
		bra.s	.NextChar					; redo next character...

	.NoColour:
		add.w	d0,d0						; ''
		move.w	d0,d1						; ''
		add.w	d0,d0						; ''
		add.w	d1,d0						; ''
		add.w	d0,d4						; move Y down to next line(s)
		move.w	(sp),d3						; reload X destination
		bra.w	.NewLine					; repeat for all lines

	.Finish:
		st.b	CreShape(a1)					; set as the last slot
		addq.w	#$02,sp						; restore stack

		move.l	#CRE_RT_MoveIn,(CreditsRoutine).w		; set next routine
		rts							; return

CRE_CreditsArt:	binclude "Credits Text Art.unc"
CRE_CredBigArt:	binclude "Credits Text Art Large.unc"
CRE_CredArtEnd:

; ---------------------------------------------------------------------------
; Moving them into position
; ---------------------------------------------------------------------------

CRE_RT_MoveIn:
		lea	(CreditsLetters).l,a1				; load letter sprite SST
		moveq	#$00,d5						; clear finish flag
		move.b	CreShape(a1),d6					; is this the last slot?
		bmi.w	.Finish						; if so, branch

	.Next:
		subq.w	#$01,CreTimer(a1)				; decrease movement timer
		bne.s	.FirstMove					; if not just literally finished, branch
		st.b	CreShow(a1)					; set sprite to show

	.FirstMove:
		bcc.w	.Waiting					; if still counting, branch
		clr.w	CreTimer(a1)					; keep timer at finish
		tst.b	CreShow(a1)					; is the sprite hidden?
		beq.w	.Hidden						; if so, ignore piece now

		move.w	CreDestX(a1),d0					; get X distance
		sub.w	CrePosX(a1),d0					; ''
		move.w	d0,d1						; store for later
		beq.s	.NoX						; if X is reached, branch
		asr.w	#$04,d0						; get fraction for speed
		add.w	d0,d0						; ensure 0 (and FFFF) can still move the piece
		addq.w	#$01,d0						; ''
		add.w	d0,CrePosX(a1)					; move X

	.NoX:
		move.w	CreDestY(a1),d0					; get X distance
		sub.w	CrePosY(a1),d0					; ''
		beq.s	.NoY						; if Y is reached, branch (no need to fuse with X)
		or.w	d0,d1						; store with X for later
		asr.w	#$04,d0						; get fraction for speed
		add.w	d0,d0						; ensure 0 (and FFFF) can still move the piece
		addq.w	#$01,d0						; ''
		add.w	d0,CrePosY(a1)					; move Y

	.NoY:
		or.w	d1,d5						; store distances for checking if all pieces have finished (later)
		tst.w	d1						; is the piece in place on X and Y?
		bne.s	.NoStop						; if not, continue rendering normally
		moveq	#-1,d0						; load master address RAM space
		move.w	CreSlot(a1),d0					; ''
		beq.s	.NoStop						; if this IS the master, branch
		movea.l	d0,a2						; set master address
		move.w	CrePosX(a2),d0					; is the master in its place yet?
		sub.w	CreDestX(a2),d0					; '' For X
		move.w	CrePosY(a2),d1					; ''
		sub.w	CreDestY(a2),d1					; '' ...and for Y
		or.w	d1,d0						; ''
		bne.s	.Waiting					; if not, don't hide this piece yet
		move.b	CreCount(a1),d0					; load expected sprite count
		subq.b	#$04,d0						; move back to previous piece
		moveq	#$01,d1						; load Y shape
		and.b	CreShape(a2),d1					; ''
		or.b	d1,d0						; fuse with shape
		cmp.b	CreShape(a2),d0					; is this master big enough and ready to accept this letter?
		bne.s	.Waiting					; if not, branch
		addq.b	#$04,CreShape(a2)				; increase master's shape
		btst.b	#$00,CreShape(a2)				; is this a large sprite?
		beq.s	.Small						; if not, branch
		addq.b	#$04,CreShape(a2)				; increase shape by x2

	.Small:
		sf.b	CreShow(a1)					; hide this sprite
		bra.s	.NoStop

	.Waiting:
		st.b	d5						; mark as not finished

	.NoStop:

	.Hidden:
		lea	CreSize(a1),a1					; advance to next slot
		move.b	CreShape(a1),d6					; is this the last slot?
		bpl.w	.Next						; if not, process


		tst.w	d5						; have all peices finished?
		bne.s	.Finish						; if not, branch
		move.l	#CRE_RT_Hold,(CreditsRoutine).w			; set next routine
		sf.b	(CreditsHold).w					; reset timer

	.Finish:
		rts							; return

; ---------------------------------------------------------------------------
; Waiting for a while
; ---------------------------------------------------------------------------

CRE_RT_Hold:
		subq.b	#$01,(CreditsHold).w				; decrease delay timer
		bne.w	.Wait						; if still counting, branch
		move.w	#$4000,d0					; prepare maximum boundary
		cmpi.b	#$07,(CreditsMonCount).w			; have all monitors been collected?
		beq.s	.ForceBoundary					; if so, force boundary to maximum now
		moveq	#$00,d0						; load boundary flag
		move.b	(CreditsBoundary).w,d0				; ''
		move.w	.Bound+2(pc,d0.w),d0				; load correct boundary slot
		bmi.s	.DoneBound					; done the boundary
		addq.b	#$02,(CreditsBoundary).w			; advance to next boundary

	.ForceBoundary:
		move.w	d0,(CreditsBoundPos).w				; set boundary
		bra.s	.DoneBound					; continue

	.Bound:	dc.w	$00E0		; boundary for music monitor
		dc.w	$0360		; boundary for level design monitor
		dc.w	$0CE0		; boundary for exploration
		dc.w	$FFFF		; end of list

	.DoneBound:
		lea	(CreditsLetters).l,a1				; load letter sprite SST
		moveq	#$00,d5						; clear finish flag
		move.b	CreShape(a1),d6					; is this the last slot?
		bmi.w	.Finish						; if so, branch
		moveq	#$00,d7						; reset timer

	.Next:
		move.w	d7,CreTimer(a1)					; set timer
		addq.w	#1,d7						; increase timer for next piece
		jsr	RandomNumber					; get a random position off-screen
		add.b	d0,d0						; get X left or right
		scs.b	d1						; ''
		ext.w	d1						; ''
		add.w	d1,d1						; ensure it's FFFF or 0001
		addq.w	#$01,d1						; ''
		add.w	d1,CreDestX(a1)					; set direction on X
		ext.w	d0						; get Y left or right
		smi.b	d0						; ''
		add.w	d0,d0						; ensure it's FFFF or 0001
		addq.w	#$01,d0						; ''
		add.w	d0,CreDestY(a1)					; set direction on Y

		lea	CreSize(a1),a1					; advance to next slot
		move.b	CreShape(a1),d6					; is this the last slot?
		bpl.w	.Next						; if not, process

	.Finish:
		move.l	#CRE_RT_MoveOut,(CreditsRoutine).w		; set next routine
		move.b	#60,(CreditsHold).w				; set timer before boundary can open up fully

	.Wait:
		rts							; return

; ---------------------------------------------------------------------------
; Moving the pieces out
; ---------------------------------------------------------------------------

CRE_RT_MoveOut:
		subq.b	#$01,(CreditsHold).w				; decrease delay timer before fully opening boundaries
		bne.s	.BoundTime					; if still counting, branch
		sf.b	(CreditsHold).w					; stop timer

	.BoundTime:
		lea	(CreditsLetters).l,a1				; load letter sprite SST
		moveq	#$00,d5						; clear finish flag
		move.b	CreShape(a1),d6					; is this the last slot?
		bmi.w	.Finish						; if so, branch
		moveq	#$00,d7						; reset timer

	.Next:
		subq.w	#$01,CreTimer(a1)				; decrease timer
		bcc.w	.NoMove						; if not finished, branch
		clr.w	CreTimer(a1)					; keep timer at 0

		tst.w	CreSlot(a1)					; load master slot
		bne.w	.NoMove						; if this HAS a master, branch (shouldn't be possible, but just in-case)
		move.b	CreShape(a1),d0					; load shape
		subq.b	#$04,d0						; decrease shape width
		bcs.w	.NoSet						; if there are no peices afterwards, branch
		btst.b	#$00,CreShape(a1)				; is this a large letter?
		beq.s	.Small						; if so, branch
		cmpi.b	#$01,d0						; if this shape only ever had 1 piece, branch
		beq.s	.Large
		subq.b	#$04,d0						; decrease shape width by x2
		subq.b	#$08,CreShape(a1)				; reduce shape by x2
		bra.s	.Large						; skip over single tile setting...

	.Small:
		sf.b	CreShape(a1)					; force this shape to single tile now

	.Large:
		lea	CreSize(a1),a2					; load next slot
		tst.w	CreSlot(a2)					; is it its own master?
		beq.s	.NoSet						; if so, skip...
		move.b	d0,CreShape(a2)					; make this new piece the master
		clr.w	CreSlot(a2)					; ''
		st.b	CreShow(a2)					; show this sprite
		move.w	a2,d0						; load address
		bra.s	.StartCheck					; jump into the loop

	.Check:
		cmp.w	CreSlot(a2),a1					; was this a child too?
		bne.s	.NoSet						; if not, branch out of the loop
		move.w	d0,CreSlot(a2)					; make it point to the new master

	.StartCheck:
		lea	CreSize(a2),a2					; advance to next slot
		tst.b	CreShape(a2)					; is this the last slot?
		bpl.s	.Check						; if not, keep checking for child pieces

	.NoSet:
		move.w	CrePosX(a1),d0					; load X position
		move.w	d0,d1						; has it gone off-screen?
		subi.w	#$0080-$10,d1					; '' (account for void space and edge)
		cmpi.w	#320+$20,d1					; ''
		bhs.s	.HideSprite					; if so, finish moving
		sub.w	CreDestX(a1),d0					; get distance/direction to fly off
		move.w	d0,d1						; keep original
		asr.w	#$03,d0						; get fraction
		bne.s	.ValidX						; if it's not 0, branch
		move.w	d1,d0						; FORCE it to move off

	.ValidX:
		add.w	d0,CrePosX(a1)					; move on X
		move.w	CrePosY(a1),d0					; load Y position
		move.w	d0,d1						; has it gone off-screen?
		subi.w	#$0080-$10,d1					; '' (account for void space and edge)
		cmpi.w	#224+$20,d1					; ''
		bhs.s	.HideSprite					; if so, finish moving

		sub.w	CreDestY(a1),d0					; get distance/direction to move
		move.w	d0,d1						; keep a copy of original
		asr.w	#$03,d0						; get fraction
		bne.s	.ValidY						; if not 0, continue
		move.w	d1,d0						; force it to be non-zero so it'll move

	.ValidY:
		add.w	d0,CrePosY(a1)					; move on Y
		st.b	d5						; mark as not finished
		bra.s	.NoMove						; continue

	.HideSprite:
		sf.b	CreShow(a1)					; hide the sprite

	.NoMove:
	.Hidden:
		lea	CreSize(a1),a1					; advance to next slot
		move.b	CreShape(a1),d6					; is this the last slot?
		bpl.w	.Next						; if not, process

		tst.w	d5						; have all sprites moved off-screen?
		bne.s	.Finish						; if not, wait...
		st.b	(CreditsLetters+CreShape).l			; force first letter as last in list
		clr.l	(CreditsRoutine).w				; finish text routine

	.Finish:
		rts							; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to render text to a plane
; --- inputs ----------------------------------------------------------------
; d1.w = pattern index of letter art
; d2.l = VDP VRAM write address of plane location
; a0.l = string location
; ---------------------------------------------------------------------------

CRE_DrawText_NewLine:
		lsl.w	#$06,d0						; align to row slot
		swap	d0						; ''
		add.l	d0,d2						; advance VRAM address to correct line

CRE_DrawText:

	.NextLine:
		move.l	d2,(a6)						; set plane address
		moveq	#$00,d0						; load character
		move.b	(a0)+,d0					; ''
		bmi.s	.CheckEnd					; if finished, branch

	.DrawChar:
		add.w	d1,d0						; add base address
		move.w	d0,(a5)						; save character

	.NextChar:
		moveq	#$00,d0						; load character
		move.b	(a0)+,d0					; ''
		bpl.s	.DrawChar					; if not finished, branch

	.CheckEnd:
		addq.b	#$01,d0						; check if it's FF
		bcs.s	.Finish						; if so, branch
		add.b	d0,d0						; clear MSB
		bpl.s	CRE_DrawText_NewLine				; if it's not a palette switcher, branch
		eori.w	#$2000,d1					; switch palette line
		bra.s	.NextChar					; continue rendering tiles

	.Finish:
		rts							; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Special credits monitors
; ---------------------------------------------------------------------------
; This is called by the object itself, so treat it with respect, it's tied
; to the engine...
; ---------------------------------------------------------------------------

Monitor_Credits:
		addq.b	#$01,(CreditsMonCount).w			; increase monitor count
		move.w	.List(pc,d0.w),d0				; load correct routine to run
		jmp	.List(pc,d0.w)					; ''

	.List:	offsetTable
		offsetTableEntry.w MonCred_Null				; 0 (Null)
		offsetTableEntry.w MonCred_Music			; 1 (Robotnik)
		offsetTableEntry.w MonCred_LevelDesign			; 2 (Rings)
		offsetTableEntry.w MonCred_Boss				; 3 (Fire)
		offsetTableEntry.w MonCred_LevelArt			; 4 (Electro)
		offsetTableEntry.w MonCred_Engine			; 5 (Bubble)
		offsetTableEntry.w MonCred_Writing			; 6 (Blue)
		offsetTableEntry.w MonCred_Lead				; 7 (Sword)
		offsetTableEntry.w MonCred_Null				; 8 (Skull)
		offsetTableEntry.w MonCred_Null				; 9 (Random)

MonCred_Null:
		clr.l	(CreditsRoutine).w				; no routine
		rts							; return

	; --- Music credits ---

MonCred_Music:
;	move.b	#$07,(CreditsMonCount).w
;	move.b	#$04,(CreditsMessage).w				; set message for "Animated_Palette:" to use
;	st.b	(CreditsRead).w					; set to do the graphical swipe
;	music	mus_Credits, 0					; play credits music
;	rts							; return
		move.b	#$01,(CreditsMessage).w				; set message to use
		move.l	#CRE_RT_Start,(CreditsRoutine).w		; set to show the message
		music	mus_Credits, 0					; play credits music
		rts							; return

	; --- Level design/layout credits ---

MonCred_LevelDesign:
		move.b	#$02,(CreditsMessage).w				; set message to use
		move.l	#CRE_RT_Start,(CreditsRoutine).w		; set to show the message
		rts							; return

	; --- Boss programming ---

MonCred_Boss:
		move.b	#$03,(CreditsMessage).w				; set message to use
		move.l	#CRE_RT_Start,(CreditsRoutine).w		; set to show the message
		lea	.PosList(pc),a2					; load position list
		bra.s	.Start						; jump into the loop

	.Next:
		jsr	(Create_New_Sprite).w				; find a new object slot
		bne.s	.NoEnemy					; if none are available, skip
		move.l	#Obj_Feal,(a1)					; load the enemy
		add.w	(Camera_X_pos).w,d2				; add camera's position
		move.w	d2,obX(a1)					; set as X
		move.w	(a2)+,d2					; load Y position
		add.w	(Camera_Y_pos).w,d2				; add camera's position
		move.w	d2,obY(a1)					; set as Y

	.Start:
		move.w	(a2)+,d2					; load X position
		bpl.s	.Next						; if it's not the end of the list, branch

	.NoEnemy:
		rts							; return

	.PosList: ;	  X,   Y
		dc.w	  0,  82
		dc.w	  0, 132
		dc.w	320,  92
		dc.w	340, 112

		dc.w	-1	; end of list

	; --- Level art/graphics ---

MonCred_LevelArt:
		; see "Animate_Palette:" for setting the message routine itself
		move.b	#$04,(CreditsMessage).w				; set message for "Animated_Palette:" to use
		st.b	(CreditsRead).w					; set to do the graphical swipe
		rts							; return

	; --- Engine/General programming ---

MonCred_Engine:
		move.b	#$05,(CreditsMessage).w				; set message to use
		move.l	#CRE_RT_Start,(CreditsRoutine).w		; set to show the message
		rts							; return

	; --- Writing/Misc ---

MonCred_Writing:
		move.b	#$06,(CreditsMessage).w				; set message to use
		move.l	#CRE_RT_Start,(CreditsRoutine).w		; set to show the message

		pea	(a0)						; store monitor object
		st.b	(NoPause_flag).w
		st.b	(Level_end_flag).w				; move HUD off
		jsr	(Create_New_Sprite).w				; load a free object slot
		bne.s	.NoSlot						; if there's no slot, skip (see no reason not to be)
		move.l	#Obj_Dialog_Process,address(a1)
		move.b	#_Credits,routine(a1)
		move.l	#DialogCredits_Process_Index-4,$34(a1)
		move.b	#(DialogCredits_Process_Index_End-DialogCredits_Process_Index)/8,$39(a1)

	.NoSlot:
		lea	(ArtKosM_BlackStretch).l,a1			; load art for boarder
		move.w	#tiles_to_bytes($580),d2			; VRAM address of boarder
		jsr	(Queue_Kos_Module).w				; add kosinski art to queue
		jsr	Load_BlackStretch				; load boarder object
		move.l	(sp)+,a0					; restore monitor object
		rts							; return

	; --- Project lead ---

MonCred_Lead:
		move.b	#$07,(CreditsMessage).w				; set message to use
		move.l	#CRE_RT_Start,(CreditsRoutine).w		; set to show the message
		rts							; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Text list for credits
; ---------------------------------------------------------------------------
		CHARSET ' ', 0
		CHARSET '0','9', 1
		CHARSET 'A','Z', 19
		CHARSET 'a','z', 19
		CHARSET '?', 11
		CHARSET '!', 12
		CHARSET '-', 13
		CHARSET ',', 14
		CHARSET '@', 15
		CHARSET '.', 16
		CHARSET '*', 17
		CHARSET '/', 18
		CHARSET '_', 45
		CHARSET '%', $C0
		CHARSET '^', $E0
; ---------------------------------------------------------------------------

CRE_TextList:	dc.l	.Staff
		dc.l	.Music
		dc.l	.LevelDesign
		dc.l	.Boss
		dc.l	.LevelArt
		dc.l	.Engine
		dc.l	.Writing
		dc.l	.Lead
		dc.l	.Need
		dc.w	$FFFF

	.Staff:
		dc.b	"             STUDIOS STAFF",$84
		dc.b	"These are the people who have",$81
		dc.b	"stayed with us until the end.",$82
		dc.b	"  They are the ones who have",$81
		dc.b	"   made this game possible.",$FF

	.Music:
		dc.b	"              ^MUSIC^",$81
		dc.b	"    %FoxConED%",$80
		dc.b	"    GENATAR_i      iwontbeforgotten",$80
		dc.b	"    Gerry Trevino  N-BAH",$80
		dc.b 	"    pixelcat",$FF

	.LevelDesign:
		dc.b	"       ^LEVEL DESIGN^",$81
		dc.b	"    %pixelcat%",$80
		dc.b	"    DeltaWooloo",$FF

	.Boss:
		dc.b	"   ^BOSS PROGRAMMING^",$81
		dc.b	"    %TheBlad768%",$80
		dc.b	"    Narcologer       MarkeyJester",$80
		dc.b	"    ProjectFM",$87
		dc.b	"  ^ENEMY PROGRAMMING^",$81
		dc.b	"    Narcologer       TheBlad768",$FF

	.LevelArt:
		dc.b	"    ^UI AND LEVEL ART^",$81
		dc.b	"    %pixelcat%",$86
		dc.b	"          ^SPRITE ART^",$81
		dc.b	"    %pixelcat%  ",$80
		dc.b	"    Sergey ESN       Dolphman",$80
		dc.b	"    VAdaPEGA         MarkeyJester",$80
		dc.b	"    CatswellMeow",$FF

	.Engine:
		dc.b	"      ^GAME ENGINE^",$81
		dc.b	"    %TheBlad768%",$87
		dc.b	"^GENERAL PROGRAMMING^",$81
		dc.b	"    %TheBlad768%",$80
		dc.b	"    Narcologer       MarkeyJester",$80
		dc.b	"    lavagaming1      FoxConED",$FF

	.Writing:
		dc.b	"",$81	;"            ^WRITING^",$81
		dc.b	"",$86	;"    pixelcat         Hotmilk",$86
		dc.b	"      ^MISCELLANEOUS^",$81
		dc.b	"    SoS              - Final boss",$80
		dc.b	"                       concept art",$80
		dc.b	"    sndk             - Support",$80
		dc.b	"    Solareyn Eylinor - Cutscene",$80
		dc.b	"                       supervision",$FF

	.Lead:
		dc.b	"     ^PROJECT FOUNDER^",$81
		dc.b	"    %Narcologer%",$86
		dc.b	"          ^CORE LEADS^",$81
		dc.b	"    Narcologer       FoxConED",$80
		dc.b	"    pixelcat         TheBlad768",$FF

	.Need:	dc.b	"   ^FIND ALL MONITORS^",$81
		dc.b	"         ^TO CONTINUE^",$FF

CRE_FinalRoll:	dc.b	"       ^RETIRED STAFF^",$FF,$FF
		dc.b $FF
		dc.b	"  These are the people",$FF,$FF
		dc.b	"  who left the team before",$FF,$FF
		dc.b	"  the project was complete.",$FF,$FF
		dc.b	"  We thank them for",$FF,$FF
		dc.b	"  their contributions.",$FF,$FF
		dc.b $FF,$FF
		dc.b	"  %savok%        - Programming",$FF,$FF
		dc.b	"  %SHooTeR%      - Programming,",$FF
		dc.b	"                 early level design",$FF,$FF
		dc.b	"  %Naoto%        - Sprite art",$FF,$FF
		dc.b	"  %JustMe%       - Sprite art",$FF,$FF
		dc.b	"  %Dakras%       - Sprite art",$FF,$FF
		dc.b	"  %Trickster%    - Sprite art",$FF,$FF
		dc.b	"  %ViruSSoFT%    - Writing",$FF,$FF
		dc.b	"  %SuperEgg%     - Early level design",$FF,$FF
		dc.b	"  %LuigiXHero%   - Early level design",$FF,$FF
		dc.b	"  %AURORAFIELDS% - Programming,",$FF
		dc.b	"                 sound driver,",$FF
		dc.b	"                 error handler mod,",$FF
		dc.b	"                 level design",$FF,$FF
		dc.b $FF,$FF
		dc.b	"             ^OUTSIDE^",$FF,$FF
		dc.b	"        ^CONTRIBUTORS^",$FF,$FF
		dc.b $FF
		dc.b	"  Although they have not been",$FF,$FF
		dc.b	"  a permanent part of the team,",$FF,$FF
		dc.b	"  their open source or direct",$FF,$FF
		dc.b	"  contributions have been",$FF,$FF
		dc.b	"  invaluable to the project.",$FF,$FF
		dc.b $FF,$FF
		dc.b	"  %Vladikcomper% - Programming,",$FF
		dc.b	"                 improved Kosinski,",$FF
		dc.b	"                 Error Handler",$FF,$FF
		dc.b	"  %Flamewing%    - Ultra DMA Queue,",$FF
		dc.b	"                 improved Kosinski-M",$FF,$FF
		dc.b	"  %ralakimus%    - HUD and bugfixes",$FF,$FF
		dc.b	"  %cuberoot%     - Dev tools help",$FF,$FF
		dc.b	"  %VBL%          - Early draft of",$FF
		dc.b	"                 the final boss art",$FF,$FF
		dc.b	"  %shinbaloonba% - Sonic, Tails sprites",$FF,$FF
		dc.b	"  %Skylights%    - Tikal sprites",$FF,$FF
		dc.b	"  %teamhedgehog% - Honey sprites",$FF,$FF
		dc.b	"  %kuroya2mouse% - Mecha Sonic sprites",$FF,$FF
		dc.b	"  %Gabriel_aka_Frag% - Rouge sprites",$FF,$FF
		dc.b	"  %John @@Joy@@ Tay% - FDZ1.2 music,",$FF
		dc.b	"                       credits music",$FF,$FF
		dc.b $FF,$FF
		dc.b	"             ^TESTERS^",$FF,$FF
		dc.b $FF
		dc.b	"  These people helped us iron out",$FF,$FF
		dc.b	"  bugs and imperfections during",$FF,$FF
		dc.b	"  the game@s development.",$FF,$FF
		dc.b $FF,$FF
		dc.b	"  %malamus%",$FF,$FF
		dc.b	"  %Valeev%",$FF,$FF
		dc.b	"  %Tailsovich%",$FF,$FF
		dc.b	"  %pbj%",$FF,$FF
		dc.b 	"  %KGL%",$FF,$FF
		dc.b $FF,$FF
		dc.b	"         ^ART CREDITS^",$FF,$FF
		dc.b $FF
		dc.b	"  As a Sonic hack and a tribute to",$FF,$FF
		dc.b	"  other series, we have used art",$FF,$FF
		dc.b	"  from various games",$FF,$FF
		dc.b	"  to represent bosses and enemies.",$FF,$FF
		dc.b $FF,$FF
		dc.b	"  Most of it has been heavily",$FF,$FF
		dc.b	"  reworked, but we still want to",$FF,$FF
		dc.b	"  give credit where it is due.",$FF,$FF
		dc.b $FF,$FF
		dc.b	"  %Sonic the Hedgehog 1-3K%",$FF,$FF
		dc.b	"  %Castlevania  Bloodlines,%",$FF
		dc.b	"               %Rondo of Blood,%",$FF
		dc.b	"               %Dracula X,%",$FF
		dc.b	"               %SOTN, 4, Java%",$FF,$FF
		dc.b	"  %Ghosts @n Goblins ARCADE%",$FF,$FF
		dc.b	"  %Ghouls @n Ghosts",$FF,$FF
		dc.b	"  %Super Ghouls @n Ghosts%",$FF,$FF
		dc.b	"  %Kid Chameleon%",$FF,$FF
		dc.b	"  %TLOZ? A Link to the Past%",$FF,$FF
		dc.b	"  %Splatterhouse 2%",$FF,$FF
		dc.b	"  %Demon@s Crest, Sparkster 2%",$FF,$FF
		dc.b	"  %Castle of Illusion%",$FF,$FF
		dc.b	"  %GS Mikami, OMORI, Galares%",$FF,$FF
		dc.b	"  %The Adventures of Batman and Robin%",$FF,$FF
		dc.b	"  %Contra? Hard Corps%",$FF,$FF
		dc.b $FF,$FF
		dc.b	"        ^MUSIC CREDITS^",$FF,$FF
		dc.b $FF
		dc.b	"  The soundtrack of the hack",$FF,$FF
		dc.b	"  is comprised of both",$FF,$FF
		dc.b	"  original music and covers.",$FF,$FF
		dc.b $FF,$FF
		dc.b	"  The details for those",$FF,$FF
		dc.b	"  can be found in the Sound Test.",$FF,$FF
		dc.b $FF,$FF,$FF,$FF
		dc.b	"  We are grateful to every single",$FF,$FF
		dc.b	"  one of you who have supported us",$FF,$FF
		dc.b	"  over the course of these",$FF,$FF
		dc.b	"  long %five years%.",$FF,$FF
		dc.b $FF,$FF
		dc.b	"  We hope to meet the same amount",$FF,$FF
		dc.b	"  of support in our next ventures.",$FF,$FF
		dc.b $FF,$FF		
		dc.b	"  %https?//redmiso.studio/%",$FF,$FF
		dc.b	"  2023",$FF,$FF
		dc.b	"  Final bugfix build 2024",$FF,$FF
		dc.b $80

CRE_Thanks:	
		dc.b	"      See you next game!!",$81
		dc.b	"     Level select unlocked",$FF
		even

		CHARSET ; reset character set

; ===========================================================================