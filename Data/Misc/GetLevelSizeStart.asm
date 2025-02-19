
; =============== S U B R O U T I N E =======================================

Get_LevelSizeStart:
		moveq	#0,d0
		move.b	d0,(Deform_Lock).w
		move.b	d0,(Scroll_Lock).w
		move.b	d0,(Dynamic_Resize_Routine).w
		move.b	d0,(Fast_V_scroll_flag).w
		jsr	Change_ActSizes
		move.w	#$60,(Distance_from_screen_top).w
		move.w	#320/2,(Camera_X_Center).w
		move.w	#-1,(Screen_X_wrap_value).w
		move.w	#-1,(Screen_Y_wrap_value).w
		tst.b	(Last_star_post_hit).w				; have any lampposts been hit?
		beq.s	LevSz_StartLoc				; if not, branch
		jsr	(Load_Starpost_Settings).l
		move.w	(Player_1+x_pos).w,d1
		move.w	(Player_1+y_pos).w,d0
		bra.s	LevSz_SkipStartPos
; ---------------------------------------------------------------------------

LevSz_StartLoc:
		move.w	(Current_zone_and_act).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	StartLocArray(pc),a1			; load Sonic's start location

		tst.b (Extended_mode).w
		beq.s .skip
		lea StartLocArray2(pc),a1

.skip:
                lea (a1,d0.w),a1
		moveq	#0,d1
		move.w	(a1)+,d1
		cmpi.w	#$0300,(Current_zone).w				; MJ: is this DDZ?
		bne.s	.NoDDZ						; MJ: if not, continue normally
		tst.b	(FirstRun).w					; MJ: is this the first run?
		bne.s	.NoDDZ						; MJ: if so, skip
		move.w	#DDZ_BOSS_CENTRE_X-$100,d1			; MJ: set to start nearer the boss

	.NoDDZ:
		move.w	d1,(Player_1+x_pos).w			; set Sonic's position on x-axis
		moveq	#0,d0
		move.w	(a1),d0
		move.w	d0,(Player_1+y_pos).w			; set Sonic's position on y-axis

LevSz_SkipStartPos:
		subi.w	#160,d1						; is Sonic more than 160px from left edge?
		bcc.s	SetScr_WithinLeft			; if yes, branch
		moveq	#0,d1

SetScr_WithinLeft:
		move.w	(Camera_max_X_pos).w,d2
		cmp.w	d2,d1						; is Sonic inside the right edge?
		blo.s	SetScr_WithinRight			; if yes, branch
		move.w	d2,d1

SetScr_WithinRight:
		move.w	d1,(Camera_X_pos).w			; set horizontal screen position
		subi.w	#96,d0						; is Sonic within 96px of upper edge?
		bcc.s	SetScr_WithinTop			; if yes, branch
		moveq	#0,d0

SetScr_WithinTop:
		cmp.w	(Camera_max_Y_pos).w,d0	; is Sonic above the bottom edge?
		blt.s	SetScr_WithinBottom			; if yes, branch
		move.w	(Camera_max_Y_pos).w,d0

SetScr_WithinBottom:
		move.w	d0,(Camera_Y_pos).w			; set vertical screen position
		rts
; ---------------------------------------------------------------------------
; Sonic start location array
; ---------------------------------------------------------------------------

		include	"Misc Data/Start Location Array - Levels.asm"

; ---------------------------------------------------------------------------
; Level size array
; ---------------------------------------------------------------------------

		include	"Misc Data/Level Size Array.asm"
