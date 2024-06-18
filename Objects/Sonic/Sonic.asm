
; =============== S U B R O U T I N E =======================================

Obj_Sonic:
		lea	(Sonic_Knux_top_speed).w,a4
		lea	(Distance_from_screen_top).w,a5
		lea	(v_Dust).w,a6

	if GameDebug=1
		tst.w	(Debug_placement_mode).w
		beq.s	Sonic_Normal

; Debug only code
		cmpi.b	#1,(Debug_placement_type).w
		beq.s	loc_10AD8
		btst	#button_B,(Ctrl_1_pressed).w
		beq.s	loc_10ABC
		clr.w	(Debug_placement_mode).w	; Leave debug mode

loc_10ABC:
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#((Map_Sonic_End-Map_Sonic)/2)-1,mapping_frame(a0)
		blo.s	loc_10ACE
		clr.b	mapping_frame(a0)

loc_10ACE:
		bsr.w	Sonic_Load_PLC
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_10AD8:
		jmp	(DebugMode).l
; ---------------------------------------------------------------------------
	endif

Sonic_Normal:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	Sonic_Index(pc,d0.w),d1
		jmp	Sonic_Index(pc,d1.w)
; ---------------------------------------------------------------------------

Sonic_Index: offsetTable
ptr_Sonic_Init:		offsetTableEntry.w Sonic_Init		; 0
ptr_Sonic_Control:	offsetTableEntry.w Sonic_Control	; 2
ptr_Sonic_Hurt:		offsetTableEntry.w Sonic_Hurt		; 4
ptr_Sonic_Death:		offsetTableEntry.w Sonic_Death		; 6
ptr_Sonic_Restart:	offsetTableEntry.w Sonic_Restart	; 8
					offsetTableEntry.w loc_12590		; A
ptr_Sonic_Drown:	offsetTableEntry.w loc_125AC		; C
; ---------------------------------------------------------------------------

Sonic_Init:	; Routine 0
		move.b	#Max_Water_Hurt_Delay,Water_hurt_delay.w; AF: give some time before water starts hurting
		addq.b	#2,routine(a0)				; => Obj01_Control
		move.b	#$13,y_radius(a0)				; this sets Sonic's collision height (2*pixels)
		move.b	#9,x_radius(a0)
		move.b	#$13,default_y_radius(a0)
		move.b	#9,default_x_radius(a0)
		move.l	#Map_Sonic,mappings(a0)
		move.w	#$100,priority(a0)
		move.b	#$18,width_pixels(a0)
		move.b	#$18,height_pixels(a0)
		move.b	#4,render_flags(a0)
		move.b	#0,character_id(a0)
		clr.w	(Sonic_Dead).w
		move.w	#$600,Sonic_Knux_top_speed-Sonic_Knux_top_speed(a4)
		move.w	#$C,Sonic_Knux_acceleration-Sonic_Knux_top_speed(a4)
		move.w	#$80,Sonic_Knux_deceleration-Sonic_Knux_top_speed(a4)
		tst.b	(Last_star_post_hit).w
		bne.s	Sonic_Init_Continued

		; only happens when not starting at a checkpoint:
		move.w	#make_art_tile(ArtTile_Sonic,0,0),art_tile(a0)
		move.b	#$C,top_solid_bit(a0)
		move.b	#$D,lrb_solid_bit(a0)

		; only happens when not starting at a Special Stage ring:
		move.w	x_pos(a0),(Saved_X_pos).w
		move.w	y_pos(a0),(Saved_Y_pos).w
		move.w	art_tile(a0),(Saved_art_tile).w
		move.w	top_solid_bit(a0),(Saved_solid_bits).w

		cmpi.w	#$200,(Current_zone_and_act).w
		bne.s	Sonic_Init_Continued
		cmpi.b	#0,(Dynamic_resize_routine).w
		bne.s	Sonic_Init_Continued
		move.w	#$C00,ground_vel(a0)

Sonic_Init_Continued:
		move.b	#0,flips_remaining(a0)
		move.b	#4,flip_speed(a0)
		move.b	#$1E,air_left(a0)
		subi.w	#$20,x_pos(a0)
		addi.w	#4,y_pos(a0)
		bsr.w	Reset_Player_Position_Array
		addi.w	#$20,x_pos(a0)
		subi.w	#4,y_pos(a0)
		rts

; ---------------------------------------------------------------------------
; Normal state for Sonic
; ---------------------------------------------------------------------------

Sonic_Control:								; Routine 2
	if GameDebug=1
		tst.w	(Debug_mode_flag).w			; is debug cheat enabled?
		beq.s	loc_10BF0					; if not, branch
		bclr	#button_A,(Ctrl_1_pressed).w		; is button A pressed?
		beq.s	loc_10BCE					; if not, branch
		addi.b	#$40,GravityAngle.w			; add to gravity angle

loc_10BCE:
		btst	#button_B,(Ctrl_1_pressed).w		; is button B pressed?
		beq.s	loc_10BF0					; if not, branch
		move.w	#1,(Debug_placement_mode).w	; change Sonic into a ring/item
		clr.b	(Ctrl_1_locked).w					; unlock control
		btst	#button_C,(Ctrl_1_held).w			; was button C held before pressing B?
		beq.s	locret_10BEE					; if not, branch
		move.w	#2,(Debug_placement_mode).w	; enter animation cycle mode

locret_10BEE:
		rts
; ---------------------------------------------------------------------------

loc_10BF0:
	endif
		tst.b	(Ctrl_1_locked).w					; are controls locked?
		bne.s	loc_10BFC					; if yes, branch
		move.w	(Ctrl_1).w,(Ctrl_1_logical).w	; copy new held buttons, to enable joypad control

loc_10BFC:
		btst	#0,object_control(a0)				; is Sonic interacting with another object that holds him in place or controls his movement somehow?
		beq.s	loc_10C0C					; if yes, branch to skip Sonic's control
		move.b	#0,double_jump_flag(a0)		; enable double jump
		bra.s	loc_10C26
; ---------------------------------------------------------------------------

loc_10C0C:
		movem.l	a4-a6,-(sp)
		moveq	#0,d0
		move.b	status(a0),d0
		andi.w	#6,d0
		move.w	Sonic_Modes(pc,d0.w),d1
		jsr	Sonic_Modes(pc,d1.w)	; run Sonic's movement control code
		movem.l	(sp)+,a4-a6

loc_10C26:
		cmpi.w	#-$100,(Camera_min_Y_pos).w	; is vertical wrapping enabled?
		bne.s	loc_10C36					; if not, branch
		move.w	(Screen_Y_wrap_value).w,d0
		and.w	d0,y_pos(a0)					; perform wrapping of Sonic's y position

loc_10C36:
		bsr.s	Sonic_Display
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Water
		move.b	(Primary_Angle).w,next_tilt(a0)
		move.b	(Secondary_Angle).w,tilt(a0)
		tst.b	(WindTunnel_flag).w
		beq.s	loc_10C62
		tst.b	anim(a0)
		bne.s	loc_10C62
		move.b	prev_anim(a0),anim(a0)

loc_10C62:
		btst	#1,object_control(a0)
		bne.s	loc_10C7E
		bsr.w	Animate_Sonic
		tst.b	GravityAngle.w
		bpl.s	loc_10C7A
		eori.b	#2,render_flags(a0)

loc_10C7A:
		bsr.w	Sonic_Load_PLC

loc_10C7E:
		move.b	object_control(a0),d0
		andi.b	#$A0,d0
		bne.s	locret_10C8E
		jsr	(TouchResponse).w

locret_10C8E:
		rts
; ---------------------------------------------------------------------------
; secondary states under state Sonic_Control

Sonic_Modes: offsetTable
		offsetTableEntry.w Sonic_MdNormal
		offsetTableEntry.w Sonic_MdAir
		offsetTableEntry.w Sonic_MdRoll
		offsetTableEntry.w Sonic_MdJump

; =============== S U B R O U T I N E =======================================

Sonic_Display:
		move.w	(Enlarged_InstaShield).w,d0
		beq.w	.cont

		sub.w	#1,(Enlarged_InstaShield).w
		move.w	(Enlarged_InstaShield).w,d0
		cmpi.w	#0,d0
		bne.w	.cont
		jsr	(Create_New_Sprite).w
		bne.s	.cont
		move.l	#Obj_SmoothPalette,(a1)
		move.w	#7,subtype(a1)
		move.l	#Pal_Sonic,$30(a1)
		move.w	#Normal_palette_line_1,$34(a1)
		move.w	#16-1,$38(a1)


.cont:
  		move.w	(Skull_Invulnerability).w,d0
		beq.s	+
		sub.w	#1,(Skull_Invulnerability).w
		move.w	(Skull_Invulnerability).w,d0
		cmpi.w	#0,d0
		bne.s 	++
		fadeout			; fade out music
+		move.b	invulnerability_timer(a0),d0
		beq.s	loc_10CA6
		subq.b	#1,invulnerability_timer(a0)
+		lsr.b	#2,d0
		bcc.s	Sonic_ChkInvin

loc_10CA6:
		jsr	(Draw_Sprite).w

Sonic_ChkInvin:										; Checks if invincibility has expired and disables it if it has.
		btst	#Status_Invincible,status_secondary(a0)
		beq.s	Sonic_ChkShoes
		tst.b	invincibility_timer(a0)
		beq.s	Sonic_ChkShoes						; If there wasn't any time left, that means we're in Super/Hyper mode
		move.b	(Level_frame_counter+1).w,d0
		andi.b	#7,d0
		bne.s	Sonic_ChkShoes
		subq.b	#1,invincibility_timer(a0)				; reduce invincibility_timer only on every 8th frame
		bne.s	Sonic_ChkShoes						; if time is still left, branch
		tst.b	(Boss_flag).w								; Don't change music if in a boss fight
		bne.s	Sonic_RmvInvin
		cmpi.b	#$C,air_left(a0)						; Don't change music if drowning
		blo.s	Sonic_RmvInvin
		move.w	(Level_music).w,d0
		st.b	(ForceMuteYM2612).w					; force YM2612 to mute
		jsr	dFractalQueue						; stop playing invincibility theme and resume normal level music

Sonic_RmvInvin:
		bclr	#Status_Invincible,status_secondary(a0)

Sonic_ChkShoes:										; Checks if Speed Shoes have expired and disables them if they have.
		btst	#Status_SpeedShoes,status_secondary(a0)	; does Sonic have speed shoes?
		beq.s	Sonic_ExitChk						; if so, branch
		tst.b	speed_shoes_timer(a0)
		beq.s	Sonic_ExitChk
		move.b	(Level_frame_counter+1).w,d0
		andi.b	#7,d0
		bne.s	Sonic_ExitChk
		subq.b	#1,speed_shoes_timer(a0)				; reduce speed_shoes_timer only on every 8th frame
		bne.s	Sonic_ExitChk
		move.w	#$600,(a4)							; set Sonic_Knux_top_speed
		move.w	#$C,2(a4)							; set Sonic_Knux_acceleration
		move.w	#$80,4(a4)							; set Sonic_Knux_deceleration
		bclr	#Status_SpeedShoes,status_secondary(a0)
		command	cmd_ShoesOff							; run music at normal speed

Sonic_ExitChk:
		rts
; ---------------------------------------------------------------------------
; Subroutine to record Sonic's previous positions for invincibility stars
; and input/status flags for Tails' AI to follow
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Sonic_RecordPos:
		move.w	(Pos_table_index).w,d0
		lea	(Pos_table).w,a1
		lea	(a1,d0.w),a1
		move.w	x_pos(a0),(a1)+			; write location to pos_table
		move.w	y_pos(a0),(a1)+
		addq.b	#4,(Pos_table_byte).w		; increment index as the post-increments did a1
		rts

; =============== S U B R O U T I N E =======================================

Reset_Player_Position_Array:
		lea	(Pos_table).w,a1
		move.w	#$3F,d0
-		move.w	x_pos(a0),(a1)+			; write location to pos_table
		move.w	y_pos(a0),(a1)+
		dbf	d0,-
		clr.w	(Pos_table_index).w
		rts
; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Sonic_Water:
		tst.b	(Water_flag).w			; does level have water?
		bne.s	Sonic_InWater		; if yes, branch

locret_10E2C:
		rts
; ---------------------------------------------------------------------------

Sonic_InWater:
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0			; is Sonic above the water?
		bge.s	Sonic_OutWater			; if yes, branch

		bsr.w	Sonic_RingWater
		bset	#Status_Underwater,status(a0)	; set underwater flag
		bne.s	locret_10E2C			; if already underwater, branch
		command	cmd_UnderwaterOn			; enable underwater mode

		addq.b	#1,(Water_entered_counter).w
		movea.l	a0,a1
		bsr.w	Player_ResetAirTimer
		move.l	#Obj_Air_CountDown,(v_Breathing_bubbles).w		; load Sonic's breathing bubbles
		move.b	#$81,(v_Breathing_bubbles+subtype).w
		move.l	a0,(v_Breathing_bubbles+$40).w
		move.w	#$300,Sonic_Knux_top_speed-Sonic_Knux_top_speed(a4)
		move.w	#6,Sonic_Knux_acceleration-Sonic_Knux_top_speed(a4)
		move.w	#$40,Sonic_Knux_deceleration-Sonic_Knux_top_speed(a4)

		tst.b	object_control(a0)
		bne.s	locret_10E2C
		asr	x_vel(a0)
		asr	y_vel(a0)	; memory operands can only be shifted one bit at a time
		asr	y_vel(a0)
		beq.s	locret_10E2C
		move.w	#$100,anim(a6)	; splash animation, write 1 to anim and clear prev_anim
		sfx	sfx_Splash, 1

Sonic_InWater_Return:
		rts
; ---------------------------------------------------------------------------

Sonic_OutWater:
		cmp.b	#Max_Water_Hurt_Delay,Water_hurt_delay.w; AF: check if this is max time
		bhs.s	.nomoretime				; if yes, don't give more time
		addq.b	#1,Water_hurt_delay.w			; give some more time underwater

.nomoretime
		bclr	#Status_Underwater,status(a0)	; unset underwater flag
		beq.w	locret_10E2C			; if already above water, branch
		command	cmd_UnderwaterOff			; disable underwater mode

		addq.b	#1,(Water_entered_counter).w
		movea.l	a0,a1
		bsr.w	Player_ResetAirTimer
		move.w	#$600,Sonic_Knux_top_speed-Sonic_Knux_top_speed(a4)
		move.w	#$C,Sonic_Knux_acceleration-Sonic_Knux_top_speed(a4)
		move.w	#$80,Sonic_Knux_deceleration-Sonic_Knux_top_speed(a4)

		cmpi.b	#4,routine(a0)		; is Sonic falling back from getting hurt?
		beq.s	loc_10EFC			; if yes, branch
		tst.b	object_control(a0)
		bne.s	loc_10EFC
		move.w	y_vel(a0),d0
		cmpi.w	#-$400,d0
		blt.s	loc_10EFC
		asl	y_vel(a0)

loc_10EFC:
		cmpi.b	#id_Null,anim(a0)	; is Sonic in his 'blank' animation
		beq.w	locret_10E2C			; if so, branch
		tst.w	y_vel(a0)
		beq.w	locret_10E2C
		move.w	#$100,anim(a6)		; splash animation, write 1 to anim and clear prev_anim
		cmpi.w	#-$1000,y_vel(a0)
		bgt.s	loc_10F22
		move.w	#-$1000,y_vel(a0)	; limit upward y velocity exiting the water

loc_10F22:
		sfx	sfx_Splash, 1
; ---------------------------------------------------------------------------

Sonic_RingWater:
		btst	#6,status(a0)						; is Sonic already in water?
		beq.s	Sonic_RingWater_Return		; if not, branch

		btst	#Status_BublShield,status_secondary(a0)		; does Sonic have a Bubble Shield?
		bne.s	Sonic_RingWater_Return							; if not, branch
		tst.b	(Ring_count).w
		beq.s	Sonic_RingWater_Death
		subq.b	#1,Water_hurt_delay.w					; check if water goes owie
		bcc.s	Sonic_RingWater_Return					; not yet

		move.w	(Difficulty_Flag).w,d0					; load difficulty
		move.b	.delays(pc,d0.w),Water_hurt_delay.w			; water goes owie
		move.b	#$80,(Update_HUD_ring_count).w				; NOV: Update HP in the HUD
		subq.b	#1,v_rings.w						; AF remove 1 ring tick

		cmp.b	#4,v_rings.w						; check if we have more than 5 ticks left
		bge.s	.yes							; if so, then we dont kill
		clr.b	v_rings.w						; AF: go to 0 rings
		rts

.delays		dc.b Tick_Water_Hurt_Delay_A, Tick_Water_Hurt_Delay_N
		dc.b Tick_Water_Hurt_Delay_H, Tick_Water_Hurt_Delay_M

.yes
		moveq	#0,d1
		move.b	v_rings.w,d1
		divu.w	#5,d1							; AF: check if we passed a segment
		swap	d1							;
		cmp.w	#4,d1							;
		bne.s	Sonic_RingWater_Return					; if not, branch
		ringsfx	d0

Sonic_RingWater_Return:
		rts
; ---------------------------------------------------------------------------

Sonic_RingWater_Death:
		jmp	(Kill_Character).l

; =============== S U B R O U T I N E =======================================

Sonic_MdNormal:
		bsr.w	SonicKnux_Spindash
		bsr.w	Sonic_Jump
		bsr.w	Player_SlopeResist
		bsr.w	Sonic_Move
		bsr.w	SonicKnux_Roll
		bsr.w	Player_LevelBound
		jsr	(MoveSprite2_TestGravity).w
		bsr.w	Player_AnglePos
		bra.w	Player_SlopeRepel
; ---------------------------------------------------------------------------
; Start of subroutine Sonic_MdAir
; Called if Sonic is airborne, but not in a ball (thus, probably not jumping)
; Sonic_Stand_Freespace:
Sonic_MdAir:
		bsr.w	Sonic_ChgFallAnim
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_ChgJumpDir
		bsr.w	Player_LevelBound
		jsr	(MoveSprite_TestGravity).w
		btst	#Status_Underwater,status(a0)	; is Sonic underwater?
		beq.s	loc_10FD6			; if not, branch
		subi.w	#$28,y_vel(a0)			; reduce gravity by $28 ($38-$28=$10)

loc_10FD6:
		cmpi.w	#$1000,y_vel(a0)
		ble.s		.maxy
		move.w	#$1000,y_vel(a0)

.maxy
		bsr.w	Player_JumpAngle
		bra.w	Player_DoLevelCollision
; ---------------------------------------------------------------------------
; Start of subroutine Sonic_MdRoll
; Called if Sonic is in a ball, but not airborne (thus, probably rolling)
; Sonic_Spin_Path:
Sonic_MdRoll:
		tst.b	spin_dash_flag(a0)
		bne.s	loc_10FEA
		bsr.w	Sonic_Jump

loc_10FEA:
		bsr.w	sub_11DEE
		bsr.w	Sonic_RollSpeed
		bsr.w	Player_LevelBound
		jsr	(MoveSprite2_TestGravity).w
		bsr.w	Player_AnglePos
		bra.w	Player_SlopeRepel
; ---------------------------------------------------------------------------
; Start of subroutine Sonic_MdJump
; Called if Sonic is in a ball and airborne (he could be jumping but not necessarily)
; Notes: This is identical to Sonic_MdAir, at least at this outer level.
; Why they gave it a separate copy of the code, I don't know.
; Sonic_Spin_Freespace:
Sonic_MdJump:
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_ChgJumpDir
		bsr.w	Player_LevelBound
		jsr	(MoveSprite_TestGravity).w
		btst	#Status_Underwater,status(a0)		; is Sonic underwater?
		beq.s	loc_11056					; if not, branch
		subi.w	#$28,y_vel(a0)				; reduce gravity by $28 ($38-$28=$10)

loc_11056:
		cmpi.w	#$1000,y_vel(a0)
		ble.s		.maxy
		move.w	#$1000,y_vel(a0)

.maxy
		bsr.w	Player_JumpAngle
		bra.w	Player_DoLevelCollision
; ---------------------------------------------------------------------------
; Subroutine to make Sonic roll
; ---------------------------------------------------------------------------

Sonic_ChgFallAnim:
		btst	#Status_Roll,status(a0)			; is Sonic rolling?
		bne.s	.return					 	; if yes, branch
		btst	#Status_OnObj,status(a0)			; is Sonic standing on an object?
		bne.s	.return 						; if yes, branch
		tst.b	flip_angle(a0)					; flip angle?
		bne.s	.return 						; if yes, branch
		tst.b	anim(a0)						; walk animation?
		bne.s	.return 						; if not, branch
		moveq	#btnABC,d0					; read only A/B/C buttons
		and.b	(Ctrl_1_pressed_logical).w,d0	; get button presses
		beq.s	.return
		bset	#Status_Roll,status(a0)
		move.w	#bytes_to_word(28/2,14/2),y_radius(a0)	; set y_radius and x_radius
		move.b	#id_Roll,anim(a0)				; use "rolling"	animation
;		sfx	sfx_Roll			 				; play rolling sound

		addq.w	#5,y_pos(a0)
		tst.b	GravityAngle.w
		bpl.s	.return
		subi.w	#5+5,y_pos(a0)

.return
		rts

; ---------------------------------------------------------------------------
; Subroutine to make Sonic walk/run
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Sonic_Move:
		move.w	Sonic_Knux_top_speed-Sonic_Knux_top_speed(a4),d6		; set Sonic_Knux_top_speed
		move.w	Sonic_Knux_acceleration-Sonic_Knux_top_speed(a4),d5	; set Sonic_Knux_acceleration
		move.w	Sonic_Knux_deceleration-Sonic_Knux_top_speed(a4),d4	; set Sonic_Knux_deceleration
		tst.b	status_secondary(a0)				; is bit 7 set? (Infinite inertia)
		bmi.w	loc_11332					; if so, branch
		tst.w	move_lock(a0)
		bne.w	loc_112EA
		btst	#button_left,(Ctrl_1_logical).w		; is left being pressed?
		beq.s	Sonic_NotLeft				; if not, branch
		bsr.w	sub_113F6

Sonic_NotLeft:
		btst	#button_right,(Ctrl_1_logical).w	; is right being pressed?
		beq.s	Sonic_NotRight				; if not, branch
		bsr.w	sub_11482

Sonic_NotRight:
		move.w	hscroll_shift.w,d1			; ++
		beq.s	+
		bclr	#0,status(a0)
		tst.w	d1
		bpl.s	+
		bset	#0,status(a0)

+		move.b	angle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0					; is Sonic on a slope?
		bne.w	loc_112EA				; if yes, branch

		tst.w	ground_vel(a0)				; is Sonic moving?
		bne.w	loc_112EA				; if yes, branch
		tst.w	d1
		bne.w	loc_112EA

		bclr	#Status_Push,status(a0)
		move.b	#id_Wait,anim(a0)			; use standing animation
		btst	#Status_OnObj,status(a0)
		beq.w	Sonic_Balance
		movea.w	interact(a0),a1				; load interacting object's RAM space
		tst.b	status(a1)				; is status bit 7 set? (unused?)
		bmi.w	loc_11276				; if so, branch

		; Calculations to determine where on the object Sonic is, and make him balance accordingly
		moveq	#0,d1						; Clear d1
		move.b	width_pixels(a1),d1			; Load interacting object's width into d1
		move.w	d1,d2						; Move to d2 for seperate calculations
		add.w	d2,d2						; Double object width, converting it to X pos' units of measurement
		subq.w	#2,d2						; Subtract 2: This is the margin for 'on edge'
		add.w	x_pos(a0),d1					; Add Sonic's X position to object width
		sub.w	x_pos(a1),d1					; Subtract object's X position from width+Sonic's X pos, giving you Sonic's distance from left edge of object
		cmpi.w	#2,d1						; is Sonic within two units of object's left edge?
		blt.s	Sonic_BalanceOnObjLeft		; if so, branch
		cmp.w	d2,d1
		bge.s	Sonic_BalanceOnObjRight		; if Sonic is within two units of object's right edge, branch (Realistically, it checks this, and BEYOND the right edge of the object)
		bra.w	loc_11276					; if Sonic is more than 2 units from both edges, branch
; ---------------------------------------------------------------------------
; balancing checks for when you're on the right edge of an object

Sonic_BalanceOnObjRight:
		btst	#Status_Facing,status(a0)	; is Sonic facing right?
		bne.s	loc_11128			; if so, branch
		move.b	#id_Balance,anim(a0)	; Balance animation 1
		addq.w	#6,d2				; extend balance range
		cmp.w	d2,d1				; is Sonic within (two units before and) four units past the right edge?
		blt.w	loc_112EA			; if so branch
		move.b	#id_Balance2,anim(a0)	; if REALLY close to the edge, use different animation (Balance animation 2)
		bra.w	loc_112EA
loc_11128:	; +
		; Somewhat dummied out/redundant code from Sonic 2
		; Originally, Sonic displayed different animations for each direction faced
		; But now, Sonic uses only the one set of animations no matter what, making the check pointless, and the code redundant
		bclr	#Status_Facing,status(a0)
		move.b	#id_Balance,anim(a0)	; Balance animation 1
		addq.w	#6,d2				; extend balance range
		cmp.w	d2,d1				; is Sonic within (two units before and) four units past the right edge?
		blt.w	loc_112EA			; if so branch
		move.b	#id_Balance2,anim(a0)	; if REALLY close to the edge, use different animation (Balance animation 2)
		bra.w	loc_112EA
; ---------------------------------------------------------------------------

Sonic_BalanceOnObjLeft:
		btst	#Status_Facing,status(a0)	; is Sonic facing right?
		beq.s	loc_11166
		move.b	#id_Balance,anim(a0)	; Balance animation 1
		cmpi.w	#-4,d1		; is Sonic within (two units before and) four units past the left edge?
		bge.w	loc_112EA	; if so branch (instruction signed to match)
		move.b	#id_Balance2,anim(a0)	; if REALLY close to the edge, use different animation (Balance animation 2)
		bra.w	loc_112EA
loc_11166:	; +
		; Somewhat dummied out/redundant code from Sonic 2
		; Originally, Sonic displayed different animations for each direction faced
		; But now, Sonic uses only the one set of animations no matter what, making the check pointless, and the code redundant
		bset	#Status_Facing,status(a0)	; is Sonic facing right?
		move.b	#id_Balance,anim(a0)	; Balance animation 1
		cmpi.w	#-4,d1		; is Sonic within (two units before and) four units past the left edge?
		bge.w	loc_112EA	; if so branch (instruction signed to match)
		move.b	#id_Balance2,anim(a0)	; if REALLY close to the edge, use different animation (Balance animation 2)
		bra.w	loc_112EA
; ---------------------------------------------------------------------------
; balancing checks for when you're on the edge of part of the level
Sonic_Balance:
		move.w	x_pos(a0),d3
		bsr.w	ChooseChkFloorEdge
		cmpi.w	#$C,d1
		blt.w	loc_11276
		cmpi.b	#3,next_tilt(a0)
		bne.s	loc_111F6
		btst	#Status_Facing,status(a0)
		bne.s	loc_111CE
		move.b	#id_Balance,anim(a0)
		move.w	x_pos(a0),d3
		subq.w	#6,d3
		bsr.w	ChooseChkFloorEdge
		cmpi.w	#$C,d1
		blt.w	loc_112EA
		move.b	#id_Balance2,anim(a0)
		bra.w	loc_112EA
		; on right edge but facing left:
loc_111CE:	; +
		; Somewhat dummied out/redundant code from Sonic 2
		; Originally, Sonic displayed different animations for each direction faced
		; But now, Sonic uses only the one set of animations no matter what, making the check pointless, and the code redundant
		bclr	#Status_Facing,status(a0)
		move.b	#id_Balance,anim(a0)
		move.w	x_pos(a0),d3
		subq.w	#6,d3
		bsr.w	ChooseChkFloorEdge
		cmpi.w	#$C,d1
		blt.w	loc_112EA
		move.b	#id_Balance2,anim(a0)
		bra.w	loc_112EA
; ---------------------------------------------------------------------------

loc_111F6:
		cmpi.b	#3,$3B(a0)
		bne.s	loc_11276
		btst	#Status_Facing,status(a0)
		beq.s	loc_11228
		move.b	#id_Balance,anim(a0)
		move.w	$10(a0),d3
		addq.w	#6,d3
		bsr.w	ChooseChkFloorEdge
		cmpi.w	#$C,d1
		blt.w	loc_112EA
		move.b	#id_Balance2,anim(a0)
		bra.w	loc_112EA
; ---------------------------------------------------------------------------

loc_11228:
		bset	#Status_Facing,status(a0)
		move.b	#id_Balance,anim(a0)
		move.w	$10(a0),d3
		addq.w	#6,d3
		bsr.w	ChooseChkFloorEdge
		cmpi.w	#$C,d1
		blt.w	loc_112EA
		move.b	#id_Balance2,anim(a0)
		bra.w	loc_112EA
; ---------------------------------------------------------------------------

loc_11276:
		tst.w	hscroll_shift.w		; ++
		bne.s	loc_112B0
		btst	#1,(Ctrl_1_logical).w
		beq.s	loc_112B0
		move.b	#id_Duck,anim(a0)
		addq.b	#1,$39(a0)
		cmpi.b	#$78,$39(a0)
		bcs.s	loc_112F0
		move.b	#$78,$39(a0)
		tst.b	GravityAngle.w
		bmi.s	loc_112A6
		cmpi.w	#8,(a5)
		beq.s	loc_112FC
		subq.w	#2,(a5)
		bra.s	loc_112FC
; ---------------------------------------------------------------------------

loc_112A6:
		cmpi.w	#$D8,(a5)
		beq.s	loc_112FC
		addq.w	#2,(a5)
		bra.s	loc_112FC
; ---------------------------------------------------------------------------

loc_112B0:
		btst	#0,(Ctrl_1_logical).w
		beq.s	loc_112EA
		move.b	#id_LookUp,anim(a0)
		addq.b	#1,$39(a0)
		cmpi.b	#$78,$39(a0)
		bcs.s	loc_112F0
		move.b	#$78,$39(a0)
		tst.b	GravityAngle.w
		bmi.s	loc_112E0
		cmpi.w	#$C8,(a5)
		beq.s	loc_112FC
		addq.w	#2,(a5)
		bra.s	loc_112FC
; ---------------------------------------------------------------------------

loc_112E0:
		cmpi.w	#$18,(a5)
		beq.s	loc_112FC
		subq.w	#2,(a5)
		bra.s	loc_112FC
; ---------------------------------------------------------------------------

loc_112EA:
		move.b	#0,$39(a0)

loc_112F0:
		cmpi.w	#$60,(a5)
		beq.s	loc_112FC
		bcc.s	loc_112FA
		addq.w	#4,(a5)

loc_112FA:
		subq.w	#2,(a5)

loc_112FC:
		move.b	(Ctrl_1_logical).w,d0
		andi.b	#$C,d0
		bne.s	loc_11332
		move.w	ground_vel(a0),d0
		beq.s	loc_11332
		bmi.s	loc_11326
		sub.w	d5,d0
		bcc.s	loc_11320
		clr.w	d0

loc_11320:
		move.w	d0,ground_vel(a0)
		bra.s	loc_11332
; ---------------------------------------------------------------------------

loc_11326:
		add.w	d5,d0
		bcc.s	loc_1132E
		clr.w	d0

loc_1132E:
		move.w	d0,ground_vel(a0)

loc_11332:
		move.b	angle(a0),d0
		jsr	(GetSineCosine).w
		muls.w	ground_vel(a0),d1
		asr.l	#8,d1
		move.w	d1,x_vel(a0)
		muls.w	ground_vel(a0),d0
		asr.l	#8,d0
		move.w	d0,y_vel(a0)

loc_11350:
		btst	#6,object_control(a0)
		bne.w	locret_113F4
		move.b	angle(a0),d0
		andi.b	#$3F,d0
		beq.s	loc_11370
		move.b	angle(a0),d0
		addi.b	#$40,d0
		bmi.w	locret_113F4

loc_11370:
		move.b	#$40,d1
		tst.w	ground_vel(a0)
		beq.s	locret_113F4
		bmi.s	loc_1137E
		neg.w	d1

loc_1137E:
		move.b	angle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	CalcRoomInFront
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_113F4

		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_113F0
		cmpi.b	#$40,d0
		beq.s	loc_113D6
		cmpi.b	#$80,d0
		beq.s	loc_113D0

		add.w	d1,x_vel(a0)
		clr.w	ground_vel(a0)
		btst	#Status_Facing,status(a0)
		bne.s	locret_113CE
		bset	#5,status(a0)

locret_113CE:
		rts
; ---------------------------------------------------------------------------

loc_113D0:
		sub.w	d1,y_vel(a0)
		rts
; ---------------------------------------------------------------------------

loc_113D6:
		sub.w	d1,x_vel(a0)
		clr.w	ground_vel(a0)
		btst	#Status_Facing,status(a0)
		beq.s	locret_113CE
		bset	#Status_Push,status(a0)
		rts
; ---------------------------------------------------------------------------

loc_113F0:
		add.w	d1,y_vel(a0)

locret_113F4:
		rts
; End of function Sonic_Move

; =============== S U B R O U T I N E =======================================

sub_113F6:
		move.w	ground_vel(a0),d0
		beq.s	loc_113FE
		bpl.s	loc_11430

loc_113FE:
		tst.w	hscroll_shift.w		; ++
		bne.s	loc_11412
		bset	#Status_Facing,status(a0)
		bne.s	loc_11412
		bclr	#Status_Push,status(a0)
		move.b	#1,prev_anim(a0)

loc_11412:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_11424
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s	loc_11424
		move.w	d1,d0

loc_11424:
		move.w	d0,ground_vel(a0)
		move.b	#0,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_11430:
		sub.w	d4,d0
		bcc.s	loc_11438
		move.w	#-$80,d0

loc_11438:
		move.w	d0,ground_vel(a0)
		move.b	angle(a0),d1
		addi.b	#$20,d1
		andi.b	#$C0,d1
		bne.s	locret_11480
		cmpi.w	#$400,d0
		blt.s	locret_11480
		tst.b	$2D(a0)
		bmi.s	locret_11480
		sfx	sfx_Skid
		move.b	#id_Stop,anim(a0)
		bclr	#Status_Facing,status(a0)
		cmpi.b	#$C,$2C(a0)
		bcs.s	locret_11480
		move.b	#6,5(a6)
		move.b	#$15,$22(a6)

locret_11480:
		rts
; End of function sub_113F6

; =============== S U B R O U T I N E =======================================

sub_11482:
		move.w	ground_vel(a0),d0
		bmi.s	loc_114B6
		bclr	#0,status(a0)
		beq.s	loc_1149C
		bclr	#5,status(a0)
		move.b	#1,prev_anim(a0)

loc_1149C:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_114AA
		sub.w	d5,d0
		cmp.w	d6,d0
		bge.s	loc_114AA
		move.w	d6,d0

loc_114AA:
		move.w	d0,ground_vel(a0)
		move.b	#0,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_114B6:
		add.w	d4,d0
		bcc.s	loc_114BE
		move.w	#$80,d0

loc_114BE:
		move.w	d0,ground_vel(a0)
		move.b	angle(a0),d1
		addi.b	#$20,d1
		andi.b	#$C0,d1
		bne.s	locret_11506
		cmpi.w	#-$400,d0
		bgt.s	locret_11506
		tst.b	$2D(a0)
		bmi.s	locret_11506
		sfx	sfx_Skid
		move.b	#id_Stop,anim(a0)
		bset	#0,status(a0)
		cmpi.b	#$C,$2C(a0)
		bcs.s	locret_11506
		move.b	#6,5(a6)
		move.b	#$15,$22(a6)

locret_11506:
		rts
; End of function sub_11482

; =============== S U B R O U T I N E =======================================

Sonic_RollSpeed:
		move.w	(a4),d6
		asl.w	#1,d6
		move.w	2(a4),d5
		asr.w	#1,d5
		move.w	#$20,d4
		tst.b	$3D(a0)
		bmi.w	loc_115C6
		tst.b	status_secondary(a0)
		bmi.w	loc_115C6
		tst.w	$32(a0)
		bne.s	loc_1154E
		btst	#2,(Ctrl_1_logical).w
		beq.s	loc_11542
		bsr.w	sub_11608

loc_11542:
		btst	#3,(Ctrl_1_logical).w
		beq.s	loc_1154E
		bsr.w	sub_1162C

loc_1154E:
		move.w	ground_vel(a0),d0
		beq.s	loc_11570
		bmi.s	loc_11564
		sub.w	d5,d0
		bcc.s	loc_1155E
		clr.w	d0

loc_1155E:
		move.w	d0,ground_vel(a0)
		bra.s	loc_11570
; ---------------------------------------------------------------------------

loc_11564:
		add.w	d5,d0
		bcc.s	loc_1156C
		clr.w	d0

loc_1156C:
		move.w	d0,ground_vel(a0)

loc_11570:
		move.w	ground_vel(a0),d0
		bpl.s	loc_11578
		neg.w	d0

loc_11578:
		cmpi.w	#$80,d0
		bcc.s	loc_115C6
		tst.b	$3D(a0)
		bne.s	loc_115B4
		bclr	#2,status(a0)
		move.b	$1E(a0),d0
		move.b	$44(a0),$1E(a0)
		move.b	$45(a0),$1F(a0)
		move.b	#id_Wait,anim(a0)
		sub.b	$44(a0),d0
		ext.w	d0
		tst.b	GravityAngle.w
		bpl.s	loc_115AE
		neg.w	d0

loc_115AE:
		add.w	d0,$14(a0)
		bra.s	loc_115C6
; ---------------------------------------------------------------------------

loc_115B4:
		move.w	#$400,ground_vel(a0)
		btst	#0,status(a0)
		beq.s	loc_115C6
		neg.w	ground_vel(a0)

loc_115C6:
		cmpi.w	#$60,(a5)
		beq.s	loc_115D2
		bcc.s	loc_115D0
		addq.w	#4,(a5)

loc_115D0:
		subq.w	#2,(a5)

loc_115D2:
		move.b	angle(a0),d0
		jsr	(GetSineCosine).w
		move.w	ground_vel(a0),d2		; devon fix
		cmpi.w	#$1000,d2
		ble.s		loc_115F6
		move.w	#$1000,d2

loc_115F6:
		cmpi.w	#-$1000,d2
		bge.s	loc_11600
		move.w	#-$1000,d2

loc_11600:
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,y_vel(a0)
		muls.w	d2,d1
		asr.l	#8,d1
		move.w	d1,x_vel(a0)
		bra.w	loc_11350
; End of function Sonic_RollSpeed

; =============== S U B R O U T I N E =======================================

sub_11608:
		move.w	ground_vel(a0),d0
		beq.s	loc_11610
		bpl.s	loc_1161E

loc_11610:
		bset	#0,status(a0)
		move.b	#id_Roll,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_1161E:
		sub.w	d4,d0
		bcc.s	loc_11626
		move.w	#-$80,d0

loc_11626:
		move.w	d0,ground_vel(a0)
		rts
; End of function sub_11608

; =============== S U B R O U T I N E =======================================

sub_1162C:
		move.w	ground_vel(a0),d0
		bmi.s	loc_11640
		bclr	#0,status(a0)
		move.b	#id_Roll,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_11640:
		add.w	d4,d0
		bcc.s	loc_11648
		move.w	#$80,d0

loc_11648:
		move.w	d0,ground_vel(a0)
		rts
; End of function sub_1162C
; ---------------------------------------------------------------------------
; Subroutine for moving Sonic left or right when he's in the air
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Sonic_ChgJumpDir:
		move.w	Sonic_Knux_top_speed-Sonic_Knux_top_speed(a4),d6
		move.w	Sonic_Knux_acceleration-Sonic_Knux_top_speed(a4),d5
		asl.w	#1,d5
		tst.b	status_secondary(a0)				; is bit 7 set? (Infinite inertia)
		bmi.w	loc_116A2					; if so, branch
		btst	#Status_RollJump,status(a0)
		bne.s	loc_116A2
		move.w	x_vel(a0),d0
		btst	#2,(Ctrl_1_logical).w
		beq.s	loc_11682
		bset	#0,status(a0)
		tst.w	hscroll_shift.w		; ++
		beq.s	+
		bclr	#0,status(a0)
+		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_11682
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s		loc_11682
		move.w	d1,d0

loc_11682:
		btst	#3,(Ctrl_1_logical).w
		beq.s	loc_1169E
		bclr	#0,status(a0)
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s		loc_1169E
		sub.w	d5,d0
		cmp.w	d6,d0
		bge.s	loc_1169E
		move.w	d6,d0

loc_1169E:
		move.w	d0,x_vel(a0)

loc_116A2:
		cmpi.w	#$60,(a5)
		beq.s	loc_116AE
		bcc.s	loc_116AC
		addq.w	#4,(a5)

loc_116AC:
		subq.w	#2,(a5)

loc_116AE:
		cmpi.w	#-$400,y_vel(a0)
		bcs.s	locret_116DC
		move.w	x_vel(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_116DC
		bmi.s	loc_116D0
		sub.w	d1,d0
		bcc.s	loc_116CA
		clr.w	d0

loc_116CA:
		move.w	d0,x_vel(a0)
		rts
; ---------------------------------------------------------------------------

loc_116D0:
		sub.w	d1,d0
		bcs.s	loc_116D8
		clr.w	d0

loc_116D8:
		move.w	d0,x_vel(a0)

locret_116DC:
		rts
; End of function Sonic_ChgJumpDir

; =============== S U B R O U T I N E =======================================

Player_LevelBound:
		move.l	$10(a0),d1
		move.w	x_vel(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		swap	d1
		move.w	(Camera_min_X_pos).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0
		bhi.s	loc_11732
		move.w	(Camera_max_X_pos).w,d0
		addi.w	#$128,d0
		cmp.w	d1,d0
		bcs.s	loc_11732

Player_Boundary_CheckBottom:
		tst.b	GravityAngle.w
		bmi.s	loc_11722
		move.w	(Camera_max_Y_pos).w,d0
		cmp.w	(Camera_target_max_Y_pos).w,d0
		blt.s		locret_11720
		addi.w	#224,d0
		cmp.w	$14(a0),d0
		blt.w	Player_Boundary_Bottom

locret_11720:
		rts
; ---------------------------------------------------------------------------

loc_11722:
		move.w	(Camera_min_Y_pos).w,d0
		cmp.w	$14(a0),d0
		blt.s	locret_11720

Player_Boundary_Bottom:
		tst.b	(Sonic_NoKill).w
		bne.s	locret_11720
		jmp	(Kill_Character).l
; ---------------------------------------------------------------------------

loc_11732:
		move.w	d0,x_pos(a0)
		clr.w	2+x_pos(a0)
		clr.w	x_vel(a0)
		clr.w	ground_vel(a0)
		bra.s	Player_Boundary_CheckBottom
; End of function Player_LevelBound

; =============== S U B R O U T I N E =======================================

SonicKnux_Roll:
		tst.b	status_secondary(a0)
		bmi.s	locret_1177E
		tst.w	(HScroll_Shift).w
		bne.s	locret_1177E
		move.b	(Ctrl_1_logical).w,d0
		andi.b	#$C,d0
		bne.s	locret_1177E
		btst	#1,(Ctrl_1_logical).w
		beq.s	loc_11780
		move.w	ground_vel(a0),d0
		bpl.s	loc_1176A
		neg.w	d0

loc_1176A:
		cmpi.w	#$100,d0
		bcc.s	loc_11790
		btst	#3,status(a0)
		bne.s	locret_1177E
		move.b	#id_Duck,anim(a0)

locret_1177E:
		rts
; ---------------------------------------------------------------------------

loc_11780:
		cmpi.b	#id_Duck,anim(a0)
		bne.s	locret_1177E
		move.b	#id_Walk,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_11790:
		btst	#2,status(a0)
		beq.s	loc_1179A
		rts
; ---------------------------------------------------------------------------

loc_1179A:
		bset	#Status_Roll,status(a0)
		move.b	#$E,y_radius(a0)
		move.b	#7,x_radius(a0)
		move.b	#id_Roll,anim(a0)
		addq.w	#5,y_pos(a0)
		tst.b	GravityAngle.w
		bpl.s	loc_117C2
		subi.w	#$A,y_pos(a0)

loc_117C2:
		sfx	sfx_Roll
		tst.w	ground_vel(a0)
		bne.s	locret_117D8
		move.w	#$200,ground_vel(a0)

locret_117D8:
		rts
; End of function SonicKnux_Roll
; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Sonic_Jump:
		cmpi.w	#1,(Hand_Squeezes_Player).w
		beq.w	locret_118B2
		move.b	(Ctrl_1_pressed_logical).w,d0
		andi.b	#$70,d0
		beq.w	locret_118B2
		moveq	#0,d0
		move.b	angle(a0),d0
		tst.b	GravityAngle.w
		bpl.s	loc_117FC
		addi.b	#$40,d0
		neg.b	d0
		subi.b	#$40,d0

loc_117FC:
		addi.b	#$80,d0
		movem.l	a4-a6,-(sp)
		bsr.w	CalcRoomOverHead
		movem.l	(sp)+,a4-a6

		cmpi.w	#6,d1
		blt.w	locret_118B2
		move.w	#$680,d2
		btst	#Status_Underwater,status(a0)	; Test if underwater
		beq.s	loc_1182E
		move.w	#$380,d2

loc_1182E:
		moveq	#0,d0
		move.b	angle(a0),d0
		subi.b	#$40,d0
		jsr	(GetSineCosine).w

		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,x_vel(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,y_vel(a0)
		bset	#1,status(a0)
		bclr	#5,status(a0)
		addq.l	#4,sp
		move.b	#1,$40(a0)
		clr.b	$3C(a0)
		sfx	sfx_Jump
		move.b	default_y_radius(a0),y_radius(a0)
		move.b	default_x_radius(a0),x_radius(a0)
		btst	#Status_Roll,status(a0)
		bne.s	locret_118B2
		move.b	#$E,$1E(a0)
		move.b	#7,$1F(a0)
		move.b	#id_Roll,anim(a0)
		bset	#Status_Roll,status(a0)
		move.b	$1E(a0),d0
		sub.b	$44(a0),d0
		ext.w	d0
		tst.b	GravityAngle.w
		bpl.s	loc_118AE
		neg.w	d0

loc_118AE:
		sub.w	d0,y_pos(a0)

locret_118B2:
		rts
; End of function Sonic_Jump

; =============== S U B R O U T I N E =======================================

Sonic_JumpHeight:
		tst.b	jumping(a0)	; is Sonic jumping?
		beq.s	Sonic_UpVelCap						; if not, branch

		move.w	#-$400,d1
		btst	#Status_Underwater,status(a0)				; is Sonic underwater?
		beq.s	loc_118D2							; if not, branch
		move.w	#-$200,d1							; Underwater-specific

loc_118D2:
		cmp.w	y_vel(a0),d1							; is y speed greater than 4? (2 if underwater)
		ble.w	Sonic_InstaAndShieldMoves			; if not, branch
		move.b	(Ctrl_1_logical).w,d0
		andi.b	#$70,d0								; are buttons A, B or C being pressed?
		bne.s	locret_118E8							; if yes, branch
		move.w	d1,y_vel(a0)							; cap jump height

locret_118E8:
		rts
; ---------------------------------------------------------------------------

Sonic_UpVelCap:
		tst.b	spin_dash_flag(a0)						; is Sonic charging his spin dash?
		bne.s	locret_118FE							; if yes, branch
		cmpi.w	#-$FC0,y_vel(a0)						; is Sonic's Y speed faster (less than) than -15.75 (-$FC0)?
		bge.s	locret_118FE							; if not, branch
		move.w	#-$FC0,y_vel(a0)						; cap upward speed

locret_118FE:
		rts
; ---------------------------------------------------------------------------

Sonic_InstaAndShieldMoves:
		tst.b	double_jump_flag(a0)						; is Sonic currently performing a double jump?
		bne.w	locret_11A14							; if yes, branch
		move.b	(Ctrl_1_pressed_logical).w,d0
		andi.b	#$70,d0								; are buttons A, B, or C being pressed?
		beq.w	locret_11A14							; if not, branch
		bclr	#Status_RollJump,status(a0)

Sonic_FireShield:
		btst	#Status_Invincible,status_secondary(a0)		; first, does Sonic have invincibility?
		bne.w	locret_11A14							; if yes, branch
		btst	#Status_FireShield,status_secondary(a0)		; does Sonic have a Fire Shield?
		beq.s	Sonic_LightningShield					; if not, branch
		move.b	#1,(v_Shield+anim).w
		move.b	#1,double_jump_flag(a0)
		move.w	#$800,d0
		btst	#Status_Facing,status(a0)					; is Sonic facing left?
		beq.s	loc_11958							; if not, branch
		neg.w	d0									; reverse speed value, moving Sonic left

loc_11958:
		move.w	d0,x_vel(a0)							; apply velocity...
		move.w	d0,ground_vel(a0)					; ...both ground and air
		clr.w	y_vel(a0)							; kill y-velocity
		move.w	#$2000,(H_scroll_frame_offset).w
		bsr.w	Reset_Player_Position_Array
		sfx	sfx_FireAttack
		rts
; ---------------------------------------------------------------------------

Sonic_LightningShield:
		btst	#Status_LtngShield,status_secondary(a0)		; does Sonic have a Lightning Shield?
		beq.s	Sonic_BubbleShield					; if not, branch
		move.b	#1,(v_Shield+anim).w
		move.b	#1,double_jump_flag(a0)
		move.w	#-$580,y_vel(a0)						; bounce Sonic up, creating the double jump effect
		clr.b	jumping(a0)
		sfx	sfx_LightAttack
		rts
; ---------------------------------------------------------------------------

Sonic_BubbleShield:
		btst	#Status_BublShield,status_secondary(a0)		; does Sonic have a Bubble Shield
		beq.s	Sonic_InstaShield						; if not, branch
		move.b	#1,(v_Shield+anim).w
		move.b	#1,double_jump_flag(a0)
		clr.w	x_vel(a0)							; halt horizontal speed...
		clr.w	ground_vel(a0)					; ...both ground and air
		move.w	#$800,y_vel(a0)						; force Sonic down
		sfx	sfx_BubbleAttack
		rts
; ---------------------------------------------------------------------------

Sonic_InstaShield:
	;	cmpi.w	#1,(Spirit_Shield).w
	;	beq.s	Sonic_JumpDash

		btst	#Status_Shield,status_secondary(a0)		; does Sonic have an S2 shield (The Elementals were already filtered out at this point)?
		bne.s	locret_11A14							; if yes, branch
;		bra.w	Sonic_InstaShield_PerformItActually

; ---------------------------------------------------------------------------

;Sonic_JumpDash:
;		cmpi.w	#0,(Skull_Invulnerability).w
;		bne.s	Sonic_InstaShield_PerformItActually
;		music	mus_Invincible, 0
;		lea	(Pal_FDZSpirits+$20).l,a1
;		jsr	(PalLoad_Line2).w
;		lea	(Pal_FDZSpirits+$40).l,a1
;		jsr	(PalLoad_Line3).w
	;	move.b #$4,(Hyper_Sonic_flash_timer).w
	;	sfx	sfx_Teleport
	;	clr.w	obVelY(a0)		; clear Y-velocity
	;	jsr	(Obj_MSkull_Flash).l
	;	move.w	#360,(Skull_Invulnerability).w
	;	clr.w	(Spirit_Shield).w
	;	rts

Sonic_InstaShield_PerformItActually:
		move.b	#1,(v_Shield+anim).w
		move.b	#1,double_jump_flag(a0)
		sfx	sfx_InstaShield
; ---------------------------------------------------------------------------

locret_11A14:
		rts

; =============== S U B R O U T I N E =======================================

SonicKnux_Spindash:
		tst.b	$3D(a0)
		bne.s	loc_11C5E
		cmpi.b	#id_Duck,anim(a0)
		bne.s	locret_11A14
		move.b	(Ctrl_1_pressed_logical).w,d0
		andi.b	#$70,d0
		beq.s	locret_11A14
		move.b	#id_SpinDash,anim(a0)
		sfx	sfx_SpinDash
		addq.l	#4,sp
		move.b	#1,$3D(a0)
		clr.w	$3E(a0)
		cmpi.b	#$C,$2C(a0)
		bcs.s	loc_11C24
		move.b	#2,$20(a6)

loc_11C24:
		bsr.w	Player_LevelBound
		jmp	Player_AnglePos
; ---------------------------------------------------------------------------

loc_11C5E:
		move.b	(Ctrl_1_logical).w,d0
		btst	#1,d0
		bne.w	loc_11D16
		move.b	#$E,$1E(a0)
		move.b	#7,$1F(a0)
		move.b	#id_Roll,anim(a0)
		addq.w	#5,$14(a0)
		tst.b	GravityAngle.w
		bpl.s	loc_11C8C
		subi.w	#$A,$14(a0)

Spindash_Setgroundvel: macro	spdtable
		moveq	#0,d0
		move.b	$3E(a0),d0
		add.w	d0,d0
		move.w	spdtable(pc,d0.w),ground_vel(a0)
	endm

loc_11C8C:
		moveq	#0,d0
		move.b	d0,$3D(a0)
		move.b	$3E(a0),d0
		add.w	d0,d0
		move.w	word_11CF2(pc,d0.w),ground_vel(a0)
		move.w	ground_vel(a0),d0
		subi.w	#$800,d0
		add.w	d0,d0
		andi.w	#$1F00,d0
		neg.w	d0
		addi.w	#$2000,d0
		lea	(H_scroll_frame_offset).w,a1
		move.w	d0,(a1)
		btst	#0,status(a0)
		beq.s	loc_11CDC
		neg.w	ground_vel(a0)

loc_11CDC:
		bset	#Status_Roll,status(a0)
		move.b	#0,$20(a6)
		sfx	sfx_Teleport
		bra.s	loc_11D5E
; ---------------------------------------------------------------------------

word_11CF2:
		dc.w $800
		dc.w $880
		dc.w $900
		dc.w $980
		dc.w $A00
		dc.w $A80
		dc.w $B00
		dc.w $B80
		dc.w $C00
word_11D04:
		dc.w $B00
		dc.w $B80
		dc.w $C00
		dc.w $C80
		dc.w $D00
		dc.w $D80
		dc.w $E00
		dc.w $E80
		dc.w $F00
; ---------------------------------------------------------------------------

loc_11D16:
		tst.w	$3E(a0)
		beq.s	loc_11D2E
		move.w	$3E(a0),d0
		lsr.w	#5,d0
		sub.w	d0,$3E(a0)
		bcc.s	loc_11D2E
		clr.w	$3E(a0)

loc_11D2E:
		move.b	(Ctrl_1_pressed_logical).w,d0
		andi.b	#$70,d0
		beq.w	loc_11D5E
		move.w	#id_SpinDash<<8,anim(a0)
		sfx	sfx_SpinDash
		addi.w	#$200,$3E(a0)
		cmpi.w	#$800,$3E(a0)
		bcs.s	loc_11D5E
		move.w	#$800,$3E(a0)

loc_11D5E:
		Spindash_Setgroundvel	word_11CF2
		btst	#0,status(a0)
		beq.s	+
		neg.w	ground_vel(a0)
+		addq.l	#4,sp
		cmpi.w	#$60,(a5)
		beq.s	loc_11D6C
		bcc.s	loc_11D6A
		addq.w	#4,(a5)

loc_11D6A:
		subq.w	#2,(a5)

loc_11D6C:
		bsr.w	Player_LevelBound
		jmp	Player_AnglePos
; End of function SonicKnux_Spindash

; =============== S U B R O U T I N E =======================================

Player_SlopeResist:
		move.b	angle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bcc.s	locret_11DDA
		move.b	angle(a0),d0
		jsr	(GetSineCosine).w
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	ground_vel(a0)
		beq.s	loc_11DDC
		bmi.s	loc_11DD6
		tst.w	d0
		beq.s	locret_11DD4
		add.w	d0,ground_vel(a0)

locret_11DD4:
		rts
; ---------------------------------------------------------------------------

loc_11DD6:
		add.w	d0,ground_vel(a0)

locret_11DDA:
		rts
; ---------------------------------------------------------------------------

loc_11DDC:
		move.w	d0,d1
		bpl.s	loc_11DE2
		neg.w	d1

loc_11DE2:
		cmpi.w	#$D,d1
		bcs.s	locret_11DDA
		add.w	d0,ground_vel(a0)
		rts
; End of function Player_SlopeResist

; =============== S U B R O U T I N E =======================================

sub_11DEE:
		move.b	angle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bcc.s	locret_11E28
		move.b	angle(a0),d0
		jsr	(GetSineCosine).w
		muls.w	#$50,d0
		asr.l	#8,d0
		tst.w	ground_vel(a0)
		bmi.s	loc_11E1E
		tst.w	d0
		bpl.s	loc_11E18
		asr.l	#2,d0

loc_11E18:
		add.w	d0,ground_vel(a0)
		rts
; ---------------------------------------------------------------------------

loc_11E1E:
		tst.w	d0
		bmi.s	loc_11E24
		asr.l	#2,d0

loc_11E24:
		add.w	d0,ground_vel(a0)

locret_11E28:
		rts
; End of function sub_11DEE

; =============== S U B R O U T I N E =======================================

Player_SlopeRepel:
		nop
		tst.b	$3C(a0)
		bne.s	locret_11E6E
		tst.w	$32(a0)
		bne.s	loc_11E86
		move.b	angle(a0),d0
		addi.b	#$18,d0
		cmpi.b	#$30,d0
		bcs.s	locret_11E6E
		move.w	ground_vel(a0),d0
		bpl.s	loc_11E4E
		neg.w	d0

loc_11E4E:
		cmpi.w	#$280,d0
		bcc.s	locret_11E6E
		move.w	#$1E,$32(a0)
		move.b	angle(a0),d0
		addi.b	#$30,d0
		cmpi.b	#$60,d0
		bcs.s	loc_11E70
		bset	#Status_InAir,status(a0)

locret_11E6E:
		rts
; ---------------------------------------------------------------------------

loc_11E70:
		cmpi.b	#$30,d0
		bcs.s	loc_11E7E
		addi.w	#$80,ground_vel(a0)
		rts
; ---------------------------------------------------------------------------

loc_11E7E:
		subi.w	#$80,ground_vel(a0)
		rts
; ---------------------------------------------------------------------------

loc_11E86:
		subq.w	#1,$32(a0)
		rts
; End of function Player_SlopeRepel

; =============== S U B R O U T I N E =======================================

Player_JumpAngle:
		move.b	angle(a0),d0
		beq.s	loc_11EA6
		bpl.s	loc_11E9C
		addq.b	#2,d0
		bcc.s	loc_11E9A
		moveq	#0,d0

loc_11E9A:
		bra.s	loc_11EA2
; ---------------------------------------------------------------------------

loc_11E9C:
		subq.b	#2,d0
		bcc.s	loc_11EA2
		moveq	#0,d0

loc_11EA2:
		move.b	d0,angle(a0)

loc_11EA6:
		move.b	$27(a0),d0
		beq.s	locret_11EEA
		tst.w	ground_vel(a0)
		bmi.s	loc_11ECA

loc_11EB2:
		move.b	$31(a0),d1
		add.b	d1,d0
		bcc.s	loc_11EC8
		subq.b	#1,$30(a0)
		bcc.s	loc_11EC8
		move.b	#0,$30(a0)
		moveq	#0,d0

loc_11EC8:
		bra.s	loc_11EE6
; ---------------------------------------------------------------------------

loc_11ECA:
		tst.b	$2D(a0)
		bmi.s	loc_11EB2
		move.b	$31(a0),d1
		sub.b	d1,d0
		bcc.s	loc_11EE6
		subq.b	#1,$30(a0)
		bcc.s	loc_11EE6
		move.b	#0,$30(a0)
		moveq	#0,d0

loc_11EE6:
		move.b	d0,$27(a0)

locret_11EEA:
		rts
; End of function Player_JumpAngle

; =============== S U B R O U T I N E =======================================

; Sonic_Floor:
Player_DoLevelCollision:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,$46(a0)
		beq.s	loc_11F00
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

loc_11F00:
		move.b	$47(a0),d5
		move.w	x_vel(a0),d1
		move.w	y_vel(a0),d2
		jsr	(GetArcTan).w

		subi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_12012
		cmpi.b	#$80,d0
		beq.w	loc_1209E
		cmpi.b	#$C0,d0
		beq.w	loc_12102

		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	loc_11F44
		sub.w	d1,$10(a0)
		clr.w	x_vel(a0)

loc_11F44:
		bsr.w	CheckRightWallDist
		tst.w	d1
		bpl.s	loc_11F56
		add.w	d1,$10(a0)
		clr.w	x_vel(a0)

loc_11F56:
		bsr.w	sub_11FD6
		tst.w	d1
		bpl.s	locret_11FD4
		move.b	y_vel(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	loc_11F6E
		cmp.b	d2,d0
		blt.s	locret_11FD4

loc_11F6E:
		move.b	d3,angle(a0)
		tst.b	GravityAngle.w
		bpl.s	loc_11F7A
		neg.w	d1

loc_11F7A:
		add.w	d1,$14(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_11FAE
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_11F9C
		asr	y_vel(a0)
		bra.s	loc_11FC2
; ---------------------------------------------------------------------------

loc_11F9C:
		clr.w	y_vel(a0)
		move.w	x_vel(a0),ground_vel(a0)
		bra.w	Player_TouchFloor_Check_Spindash
; ---------------------------------------------------------------------------

loc_11FAE:
		clr.w	x_vel(a0)
		cmpi.w	#$FC0,y_vel(a0)
		ble.s	loc_11FC2
		move.w	#$FC0,y_vel(a0)

loc_11FC2:
		bsr.w	Player_TouchFloor_Check_Spindash
		move.w	y_vel(a0),ground_vel(a0)
		tst.b	d3
		bpl.s	locret_11FD4
		neg.w	ground_vel(a0)

locret_11FD4:
		rts
; End of function Player_DoLevelCollision

; =============== S U B R O U T I N E =======================================

sub_11FD6:
		tst.b	GravityAngle.w
		bpl.w	Sonic_CheckFloor
		bsr.w	Sonic_CheckCeiling2		; NAT: Sonic Team are a bunch of fucking dumbasses
		addi.b	#$40,d3
		neg.b	d3
		subi.b	#$40,d3
		rts
; End of function sub_11FD6

; =============== S U B R O U T I N E =======================================

sub_11FEE:
		tst.b	GravityAngle.w
		bpl.w	Sonic_CheckCeiling
		bsr.w	Sonic_CheckFloor2		; NAT: Sonic Team are a bunch of fucking dumbasses
		addi.b	#$40,d3
		neg.b	d3
		subi.b	#$40,d3
		rts
; End of function sub_11FEE

; =============== S U B R O U T I N E =======================================

ChooseChkFloorEdge:
		tst.b	GravityAngle.w
		bpl.w	ChkFloorEdge_Part2
		bra.w	ChkFloorEdge_ReverseGravity
; End of function ChooseChkFloorEdge
; ---------------------------------------------------------------------------

loc_12012:
		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	loc_1202A
		sub.w	d1,$10(a0)
		clr.w	x_vel(a0)
		move.w	y_vel(a0),ground_vel(a0)

loc_1202A:
		bsr.w	sub_11FEE
		tst.w	d1
		bpl.s	loc_12068
		neg.w	d1
		cmpi.w	#$14,d1
		bcc.s	loc_12054
		tst.b	GravityAngle.w
		bpl.s	loc_12042
		neg.w	d1

loc_12042:
		add.w	d1,$14(a0)
		tst.w	y_vel(a0)
		bpl.s	locret_12052
		clr.w	y_vel(a0)

locret_12052:
		rts
; ---------------------------------------------------------------------------

loc_12054:
		bsr.w	CheckRightWallDist
		tst.w	d1
		bpl.s	locret_12066
		add.w	d1,$10(a0)
		clr.w	x_vel(a0)

locret_12066:
		rts
; ---------------------------------------------------------------------------

loc_12068:
		tst.b	(WindTunnel_flag).w
		bne.s	loc_12074
		tst.w	y_vel(a0)
		bmi.s	locret_12066

loc_12074:
		bsr.w	sub_11FD6
		tst.w	d1
		bpl.s	locret_12066
		tst.b	GravityAngle.w
		bpl.s	loc_12084
		neg.w	d1

loc_12084:
		add.w	d1,$14(a0)
		move.b	d3,angle(a0)
		clr.w	y_vel(a0)
		move.w	x_vel(a0),ground_vel(a0)
		bra.w	Player_TouchFloor_Check_Spindash
; ---------------------------------------------------------------------------

loc_1209E:
		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	loc_120B0
		sub.w	d1,$10(a0)
		clr.w	x_vel(a0)

loc_120B0:
		jsr	(CheckRightWallDist).l
		tst.w	d1
		bpl.s	loc_120C2
		add.w	d1,$10(a0)
		clr.w	x_vel(a0)

loc_120C2:
		bsr.w	sub_11FEE
		tst.w	d1
		bpl.s	locret_12100
		tst.b	GravityAngle.w
		bpl.s	loc_120D2
		neg.w	d1

loc_120D2:
		sub.w	d1,$14(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_120EA
		clr.w	y_vel(a0)
		rts
; ---------------------------------------------------------------------------

loc_120EA:
		move.b	d3,angle(a0)
		bsr.w	Player_TouchFloor_Check_Spindash
		move.w	y_vel(a0),ground_vel(a0)
		tst.b	d3
		bpl.s	locret_12100
		neg.w	ground_vel(a0)

locret_12100:
		rts
; ---------------------------------------------------------------------------

loc_12102:
		jsr	(CheckRightWallDist).l
		tst.w	d1
		bpl.s	loc_1211A
		add.w	d1,$10(a0)
		clr.w	x_vel(a0)
		move.w	y_vel(a0),ground_vel(a0)

loc_1211A:
		bsr.w	sub_11FEE
		tst.w	d1
		bpl.s	loc_1213C
		tst.b	GravityAngle.w
		bpl.s	loc_1212A
		neg.w	d1

loc_1212A:
		sub.w	d1,$14(a0)
		tst.w	y_vel(a0)
		bpl.s	locret_1213A
		clr.w	y_vel(a0)

locret_1213A:
		rts
; ---------------------------------------------------------------------------

loc_1213C:
		tst.b	(WindTunnel_flag).w
		bne.s	loc_12148
		tst.w	y_vel(a0)
		bmi.s	locret_1213A

loc_12148:
		bsr.w	sub_11FD6
		tst.w	d1
		bpl.s	locret_1213A
		tst.b	GravityAngle.w
		bpl.s	loc_12158
		neg.w	d1

loc_12158:
		add.w	d1,$14(a0)
		move.b	d3,angle(a0)
		clr.w	y_vel(a0)
		move.w	x_vel(a0),ground_vel(a0)

; =============== S U B R O U T I N E =======================================

Player_TouchFloor_Check_Spindash:
		tst.b	$3D(a0)
		bne.s	loc_121D8
		move.b	#id_Walk,anim(a0)

Sonic_ResetOnFloor:
		move.b	$1E(a0),d0
		move.b	$44(a0),$1E(a0)
		move.b	$45(a0),$1F(a0)
		btst	#Status_Roll,status(a0)
		beq.s	loc_121D8
		bclr	#Status_Roll,status(a0)
		move.b	#id_Walk,anim(a0)
		sub.b	$44(a0),d0
		ext.w	d0
		tst.b	GravityAngle.w
		bpl.s	loc_121C4
		neg.w	d0

loc_121C4:
		move.w	d0,-(sp)
		move.b	angle(a0),d0
		addi.b	#$40,d0
		bpl.s	loc_121D2
		neg.w	(sp)

loc_121D2:
		move.w	(sp)+,d0
		add.w	d0,$14(a0)

loc_121D8:
		bclr	#Status_InAir,status(a0)
		bclr	#Status_Push,status(a0)
		bclr	#Status_RollJump,status(a0)
		move.b	#0,$40(a0)
		clr.w	(Chain_bonus_counter).w
		move.b	#0,$27(a0)
		move.b	#0,$2D(a0)
		move.b	#0,$30(a0)
		move.b	#0,$39(a0)
		tst.b	double_jump_flag(a0)
		beq.s	locret_12230
		tst.b	$38(a0)
		bne.s	loc_1222A
		btst	#Status_Invincible,status_secondary(a0)		; don't bounce when invincible
		bne.s	loc_1222A
		btst	#Status_BublShield,status_secondary(a0)
		beq.s	loc_1222A
		bsr.s	BubbleShield_Bounce

loc_1222A:
		move.b	#0,double_jump_flag(a0)

locret_12230:
		rts
; End of function Sonic_ResetOnFloor

; =============== S U B R O U T I N E =======================================

BubbleShield_Bounce:
		movem.l	d1-d2,-(sp)
		move.w	#$780,d2
		btst	#Status_Underwater,status(a0)
		beq.s	loc_12246
		move.w	#$400,d2

loc_12246:
		moveq	#0,d0
		move.b	angle(a0),d0
		subi.b	#$40,d0
		jsr	(GetSineCosine).w
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,x_vel(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,y_vel(a0)
		movem.l	(sp)+,d1-d2
		bset	#Status_InAir,status(a0)
		bclr	#Status_Push,status(a0)
		move.b	#1,$40(a0)
		clr.b	$3C(a0)
		move.b	#$E,$1E(a0)
		move.b	#7,$1F(a0)
		move.b	#id_Roll,anim(a0)
		bset	#Status_Roll,status(a0)
		move.b	$1E(a0),d0
		sub.b	$44(a0),d0
		ext.w	d0
		tst.b	GravityAngle.w
		bpl.s	loc_122AA
		neg.w	d0

loc_122AA:
		sub.w	d0,$14(a0)
		move.b	#2,(v_Shield+obAnim).w
		sfx	sfx_BubbleAttack
		rts
; ---------------------------------------------------------------------------

Sonic_Hurt:
	if GameDebug=1
		tst.w	(Debug_mode_flag).w
		beq.s	loc_122D8
		btst	#4,(Ctrl_1_pressed).w
		beq.s	loc_122D8
		move.w	#1,(Debug_placement_mode).w
		clr.b	(Ctrl_1_locked).w
		rts
; ---------------------------------------------------------------------------

loc_122D8:
	endif
		jsr	(MoveSprite2_TestGravity).w
		addi.w	#$30,y_vel(a0)
		btst	#Status_Underwater,status(a0)
		beq.s	loc_122F2
		subi.w	#$20,y_vel(a0)

loc_122F2:
		cmpi.w	#-$100,(Camera_min_Y_pos).w
		bne.s	loc_12302
		move.w	(Screen_Y_wrap_value).w,d0
		and.w	d0,$14(a0)

loc_12302:
		bsr.w	sub_12318
		bsr.w	Player_LevelBound
		bsr.w	Sonic_RecordPos
		bsr.w	sub_125E0
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_12318:
		tst.b	GravityAngle.w
		bmi.s	loc_12336
		move.w	(Camera_max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$14(a0),d0
		blt.w	loc_1238A
		bra.s	loc_12344
; ---------------------------------------------------------------------------

loc_12336:
		move.w	(Camera_min_Y_pos).w,d0
		cmp.w	$14(a0),d0
		blt.s	loc_12344
		bra.w	loc_1238A
; ---------------------------------------------------------------------------

loc_12344:
		movem.l	a4-a6,-(sp)
		bsr.w	Player_DoLevelCollision
		movem.l	(sp)+,a4-a6
		btst	#Status_InAir,status(a0)
		bne.s	locret_12388
		moveq	#0,d0
		move.w	d0,y_vel(a0)
		move.w	d0,x_vel(a0)
		move.w	d0,ground_vel(a0)
		move.b	d0,object_control(a0)
		move.b	#id_Walk,anim(a0)
		move.w	#$100,8(a0)
		move.b	#2,5(a0)
		move.b	#$78,$34(a0)
		move.b	#0,$3D(a0)

locret_12388:
		rts
; ---------------------------------------------------------------------------

loc_1238A:
		tst.b	(Sonic_NoKill).w
		bne.s	locret_12388
		jmp	Kill_Character
; ---------------------------------------------------------------------------

Sonic_Death:
	if GameDebug=1
		tst.w	(Debug_mode_flag).w
		beq.s	loc_123AA
		btst	#4,(Ctrl_1_pressed).w
		beq.s	loc_123AA
		move.w	#1,(Debug_placement_mode).w
		clr.b	(Ctrl_1_locked).w
		rts
; ---------------------------------------------------------------------------

loc_123AA:
	endif
		move.b	#id_SonicRestart,routine(a0)
		move.w	#3*60+30,$3E(a0)

		; death count
		cmpi.w	#999,(Death_count).w
		bhs.s	.return
		addq.w	#1,(Death_count).w

.return
		rts

;		bsr.w	sub_123C2
;		jsr	(MoveSprite_TestGravity).w
;		bsr.w	Sonic_RecordPos
;		bsr.w	sub_125E0
;		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

;sub_123C2:
;		move.w	(Camera_Y_pos).w,d0
;		move.b	#1,(Scroll_lock).w
;		move.b	#0,$3D(a0)
;		tst.b	GravityAngle.w
;		bpl.s	loc_123FA
;		subi.w	#$10,d0
;		cmp.w	$14(a0),d0
;		bge.s	loc_12410
;		rts
; ---------------------------------------------------------------------------

;loc_123FA:
;		addi.w	#$100,d0
;		cmp.w	$14(a0),d0
;		bge.s	locret_124C6

;loc_12410:
;		move.b	#8,5(a0)
;		move.w	#3*60,$3E(a0)

;locret_124C6:
;		rts
; ---------------------------------------------------------------------------

Sonic_Restart:
		tst.w	$3E(a0)
		beq.s	locret_1258E
		subq.w	#1,$3E(a0)
		bne.s	locret_1258E
		move.w	#1,(Restart_level_flag).w

locret_1258E:
		rts
; ---------------------------------------------------------------------------

loc_12590:
		tst.w	(Camera_RAM).w
		bne.s	loc_125A2
		tst.w	(V_scroll_amount).w
		bne.s	loc_125A2
		move.b	#2,5(a0)

loc_125A2:
		bsr.w	sub_125E0
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_125AC:
	if GameDebug=1
		tst.w	(Debug_mode_flag).w
		beq.s	loc_125C6
		btst	#4,(Ctrl_1_pressed).w
		beq.s	loc_125C6
		move.w	#1,(Debug_placement_mode).w
		clr.b	(Ctrl_1_locked).w
		rts
; ---------------------------------------------------------------------------

loc_125C6:
	endif
		jsr	(MoveSprite2_TestGravity).w
		addi.w	#$10,y_vel(a0)
		bsr.w	Sonic_RecordPos
		bsr.w	sub_125E0
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_125E0:
		bsr.s	Animate_Sonic
		tst.b	GravityAngle.w
		bpl.s	loc_125F4
		eori.b	#2,render_flags(a0)

loc_125F4:
		bra.w	Sonic_Load_PLC

; =============== S U B R O U T I N E =======================================

Animate_Sonic:
		lea	AniSonic.l,a1
		moveq	#0,d0
		move.b	anim(a0),d0
		cmp.b	prev_anim(a0),d0
		beq.s	SAnim_Do
		move.b	d0,prev_anim(a0)
		move.b	#0,anim_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		bclr	#Status_Push,status(a0)

SAnim_Do:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1
		move.b	(a1),d0
		bmi.s	SAnim_WalkRun
		move.b	status(a0),d1
		andi.b	#1,d1
		andi.b	#-4,4(a0)
		or.b	d1,4(a0)
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	SAnim_Delay
		move.b	d0,anim_frame_timer(a0)

SAnim_Do2:
		moveq	#0,d1
		move.b	anim_frame(a0),d1
		move.b	1(a1,d1.w),d0
		cmpi.b	#-4,d0
		bcc.s	SAnim_End_FF

SAnim_Next:
		move.b	d0,mapping_frame(a0)
		addq.b	#1,anim_frame(a0)

SAnim_Delay:
		rts
; ---------------------------------------------------------------------------

SAnim_End_FF:
		addq.b	#1,d0
		bne.s	SAnim_End_FE
		move.b	#0,anim_frame(a0)
		move.b	1(a1),d0
		bra.s	SAnim_Next
; ---------------------------------------------------------------------------

SAnim_End_FE:
		addq.b	#1,d0
		bne.s	SAnim_End_FD
		move.b	2(a1,d1.w),d0
		sub.b	d0,anim_frame(a0)
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0
		bra.s	SAnim_Next
; ---------------------------------------------------------------------------

SAnim_End_FD:
		addq.b	#1,d0
		bne.s	SAnim_End
		move.b	2(a1,d1.w),anim(a0)

SAnim_End:
		rts
; ---------------------------------------------------------------------------

SAnim_WalkRun:
		addq.b	#1,d0
		bne.w	loc_12A2A
		moveq	#0,d0
		tst.b	$2D(a0)
		bmi.w	loc_127C0
		move.b	$27(a0),d0
		bne.w	loc_127C0
		moveq	#0,d1
		move.b	angle(a0),d0
		bmi.s	loc_126C8
		beq.s	loc_126C8
		subq.b	#1,d0

loc_126C8:
		move.b	status(a0),d2
		andi.b	#1,d2
		bne.s	loc_126D4
		not.b	d0

loc_126D4:
		addi.b	#$10,d0
		bpl.s	loc_126DC
		moveq	#3,d1

loc_126DC:
		andi.b	#-4,4(a0)
		eor.b	d1,d2
		or.b	d2,4(a0)
		btst	#Status_Push,status(a0)
		bne.w	SAnim_Push
		lsr.b	#4,d0
		andi.b	#6,d0
		move.w	ground_vel(a0),d2
		bpl.s	loc_12700
		neg.w	d2

loc_12700:
		add.w	hscroll_shift.w,d2		; ++
		tst.b	status_secondary(a0)
		bpl.w	loc_1270A
		add.w	d2,d2

loc_1270A:
		lea	SonAni_Run.l,a1 	; use running	animation
		cmpi.w	#$600,d2
		bcc.s	loc_12724
		lea	SonAni_Walk.l,a1 	; use walking animation
		add.b	d0,d0

loc_12724:
		add.b	d0,d0
		move.b	d0,d3
		moveq	#0,d1
		move.b	anim_frame(a0),d1
		move.b	1(a1,d1.w),d0
		cmpi.b	#-1,d0
		bne.s	loc_12742
		move.b	#0,anim_frame(a0)
		move.b	1(a1),d0

loc_12742:
		move.b	d0,mapping_frame(a0)
		add.b	d3,mapping_frame(a0)
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	locret_12764
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	loc_1275A
		moveq	#0,d2

loc_1275A:
		lsr.w	#8,d2
		move.b	d2,anim_frame_timer(a0)
		addq.b	#1,anim_frame(a0)

locret_12764:
		rts
; ---------------------------------------------------------------------------

loc_127C0:
		move.b	$2D(a0),d1
		andi.w	#$7F,d1
		bne.w	loc_12872
		move.b	$27(a0),d0
		moveq	#0,d1
		move.b	status(a0),d2
		andi.b	#1,d2
		bne.s	loc_1281E
		andi.b	#-4,4(a0)
		tst.b	$2D(a0)
		bpl.s	loc_12806
		ori.b	#2,4(a0)
		neg.b	d0
		addi.b	#$8F,d0
		bra.s	loc_1280A
; ---------------------------------------------------------------------------

loc_12806:
		addi.b	#$B,d0

loc_1280A:
		divu.w	#$16,d0
		addi.b	#$31,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_1281E:
		andi.b	#-4,4(a0)
		ori.b	#3,4(a0)
		neg.b	d0
		addi.b	#$8F,d0
		divu.w	#$16,d0
		addi.b	#$31,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

byte_1286E:
		dc.b 0
		dc.b $3D
		dc.b $49
		dc.b $49
; ---------------------------------------------------------------------------

loc_12872:
		move.b	byte_1286E(pc,d1.w),d3
		cmpi.b	#1,d1
		bne.s	loc_128CA
		move.b	$27(a0),d0
		moveq	#0,d1
		move.b	status(a0),d2
		andi.b	#1,d2
		bne.s	loc_128A8
		andi.b	#-4,4(a0)
		addi.b	#-8,d0
		divu.w	#$16,d0
		add.b	d3,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_128A8:
		andi.b	#-4,4(a0)
		ori.b	#1,4(a0)
		addi.b	#-8,d0
		divu.w	#$16,d0
		add.b	d3,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_128CA:
		cmpi.b	#2,d1
		bne.s	loc_12920
		move.b	$27(a0),d0
		moveq	#0,d1
		move.b	status(a0),d2
		andi.b	#1,d2
		bne.s	loc_128FC
		andi.b	#-4,4(a0)
		addi.b	#$B,d0
		divu.w	#$16,d0
		add.b	d3,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_128FC:
		andi.b	#-4,4(a0)
		ori.b	#3,4(a0)
		neg.b	d0
		addi.b	#$8F,d0
		divu.w	#$16,d0
		add.b	d3,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_12920:
		cmpi.b	#3,d1
		bne.s	loc_1297C
		move.b	$27(a0),d0
		moveq	#0,d1
		move.b	status(a0),d2
		andi.b	#1,d2
		bne.s	loc_1295A
		andi.b	#-4,4(a0)
		ori.b	#2,4(a0)
		neg.b	d0
		addi.b	#$8F,d0
		divu.w	#$16,d0
		add.b	d3,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_1295A:
		andi.b	#-4,4(a0)
		ori.b	#1,4(a0)
		addi.b	#$B,d0
		divu.w	#$16,d0
		add.b	d3,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_1297C:
		cmpi.b	#4,d1
		bne.s	loc_129F6
		move.b	$27(a0),d0
		moveq	#0,d1
		move.b	status(a0),d2
		andi.b	#1,d2
		bne.s	loc_129BC
		andi.b	#-4,4(a0)
		tst.b	$2D(a0)
		bpl.s	loc_129A4
		addi.b	#$B,d0
		bra.s	loc_129A8
; ---------------------------------------------------------------------------

loc_129A4:
		addi.b	#$B,d0

loc_129A8:
		divu.w	#$16,d0
		addi.b	#$31,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_129BC:
		andi.b	#-4,4(a0)
		tst.b	$2D(a0)
		bpl.s	loc_129D6
		ori.b	#3,4(a0)
		neg.b	d0
		addi.b	#$8F,d0
		bra.s	loc_129E2
; ---------------------------------------------------------------------------

loc_129D6:
		ori.b	#3,4(a0)
		neg.b	d0
		addi.b	#$8F,d0

loc_129E2:
		divu.w	#$16,d0
		addi.b	#$31,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_129F6:
		move.b	$27(a0),d0
		andi.b	#-4,4(a0)
		moveq	#0,d1
		move.b	status(a0),d2
		andi.b	#1,d2
		beq.s	loc_12A12
		ori.b	#1,4(a0)

loc_12A12:
		addi.b	#$B,d0
		divu.w	#$16,d0
		addi.b	#$31,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_12A2A:
		move.b	status(a0),d1
		andi.b	#1,d1
		andi.b	#-4,4(a0)
		or.b	d1,4(a0)
		subq.b	#1,anim_frame_timer(a0)
		bpl.w	SAnim_Delay
		move.w	ground_vel(a0),d2
		bpl.s	loc_12A4C
		neg.w	d2

loc_12A4C:
		add.w	hscroll_shift.w,d2		; ++
		lea	SonAni_Roll2.l,a1
		cmpi.w	#$600,d2
		bcc.s	loc_12A5E
		lea	SonAni_Roll.l,a1

loc_12A5E:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	loc_12A68
		moveq	#0,d2

loc_12A68:
		moveq	#9,d1
		lsr.w	d1,d2
		move.b	d2,anim_frame_timer(a0)
		bra.w	SAnim_Do2
; ---------------------------------------------------------------------------

SAnim_Push:
		subq.b	#1,anim_frame_timer(a0)
		bpl.w	SAnim_Delay
		move.w	ground_vel(a0),d2
		bmi.s	loc_12A82
		neg.w	d2

loc_12A82:
		addi.w	#$800,d2
		bpl.s	loc_12A8A
		moveq	#0,d2

loc_12A8A:
		lsr.w	#6,d2
		move.b	d2,anim_frame_timer(a0)
		lea	SonAni_Push.l,a1
		bra.w	SAnim_Do2
; End of function Animate_Sonic

; =============== S U B R O U T I N E =======================================

Sonic_Load_PLC:
		moveq	#0,d0
		move.b	mapping_frame(a0),d0

Sonic_Load_PLC2:
		cmp.b	(v_SonFrameNum).w,d0
		beq.s	locret_12D20
		move.b	d0,(v_SonFrameNum).w
		lea	PLC_Sonic.l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	locret_12D20
		move.w	#$D000,d4
		move.l	#ArtUnc_Sonic>>1,d6

loc_12CF8:
		moveq	#0,d1
		move.w	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#4,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(Add_To_DMA_Queue).w
		dbf	d5,loc_12CF8

locret_12D20:
		rts
; End of function Sonic_Load_PLC



; ===========================================================================
; ---------------------------------------------------------------------------
; This is a special object which is designed to display Sonic somewhere other
; than his exact position - Used in the credits in the end where Sonic runs
; off-screen.
;
; Sonic is technically in the same place to allow the camera to follow correctly
; as it has done, but visually won't show.
; ---------------------------------------------------------------------------

Obj_SonicShift:
		lea	(Player_1).w,a1					; load Sonic's actual RAM
		move.b	#$04,invulnerability_timer(a1)			; force Sonic to hide

		move.l	obX(a0),d0					; store X position
		move.l	obY(a0),d1					; store Y position
		move.w	obInertia(a0),d2				; store X speed

		move.w	#(object_size/2)-1,d4				; size to copy
		pea	(a0)						; store object
	.Copy:	move.w	(a1)+,(a0)+					; copy everything about Sonic to this objects
		dbf	d4,.Copy					; '' (except below which were stored)
		move.l	(sp)+,a0					; restore object

		addq.w	#$08,d2						; increase speed
		move.w	d2,obInertia(a0)				; restore X speed
		ext.l	d2						; convert to QQQQ.FFFF
		asl.l	#$08,d2						; ''
		add.l	d2,d0						; change X position
		move.l	d0,obX(a0)					; update X position
		move.l	d1,obY(a0)					; restore Y position
		move.l	d2,d0						; get fraction of speed
		asr.l	#$03,d0						; ''
		sub.l	d0,d2						; ''
		add.l	d2,(CreditsTailsX).w				; move tails faster
		move.w	(Camera_X_pos).w,(CreditsTailsXCam).w		; store camera X position for tails calculation
		move.l	#Obj_SonicShift,address(a0)			; restore routine/address
		ori.w	#$8000,obGfx(a0)				; force to high plane
		jmp	(Draw_Sprite).w					; draw this object as if it were Sonic

	; --- Subroutine to create the shift object ---

CreateSonicShift:
		jsr	(Create_New_Sprite).w				; load a free object slot
		bne.s	.NoSlot						; if there's no slot, skip (see no reason not to be)
		move.l	#Obj_SonicShift,address(a1)			; set address
		move.w	(Player_1+obX).w,obX(a1)			; set X position
		move.w	(Player_1+obY).w,obY(a1)			; set Y position
		move.w	(Player_1+obInertia).w,obInertia(a1)		; set X speed
		move.w	(Camera_X_pos).w,(CreditsTailsX).w		; move tails to camera position (so the speed can be done properly)

	.NoSlot:
		rts							; return

; ===========================================================================



