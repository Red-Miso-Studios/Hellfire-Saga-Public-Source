; ===========================================================================
; Sonic the hedgehog in Hellfire Saga
; ===========================================================================

; Assembly options:

OptimiseSound:	  		= 1	; change to 1 to optimise sound queuing
zeroOffsetOptimization:	= 1	; If 1, makes a handful of zero-offset instructions smaller
VISUAL_DEBUG			= 0	; disable visual debugger
; ---------------------------------------------------------------------------

; Assembler code:
		cpu 68000
		include "MacroSetup.asm"		; include a few basic macros
		include "Macros.asm"			; include some simplifying macros and functions
		include "Constants.asm"
		include "Variables.asm"
		include "Misc Data/Debugger/ErrorHandler/Debugger.asm"

		RELAXED ON
		include "Fractal/Code/equ.asm"
		RELAXED OFF
; ---------------------------------------------------------------------------

StartOfROM:
	if * <> 0
		fatal "StartOfROM was $\{*} but it should be 0"
	endif
Vectors:
		dc.l System_stack, EntryPoint, BusError, AddressError		; 0
		dc.l IllegalInstr, ZeroDivide, ChkInstr, TrapvInstr			; 4
		dc.l PrivilegeViol, Trace, Line1010Emu, Line1111Emu		; 8
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept	; 12
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept	; 16
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept	; 20
		dc.l ErrorExcept, ErrorTrap, ErrorTrap, ErrorTrap			; 24
		dc.l H_int_jump, ErrorTrap, V_int_jump, ErrorTrap		; 28
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 32
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 36
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 40
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 44
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 48
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 52
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 56
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 60
Header:		dc.b "SEGA GENESIS    "
Copyright:	dc.b "(C)SEGA XXXX.XXX"                       ;
Domestic_Name:	dc.b "HELLFIRE SAGA V2.11                             "
Overseas_Name:	dc.b "HELLFIRE SAGA V2.11                             "
Serial_Number:	dc.b "GM MK-0000 -00"
Checksum:	dc.w 0
Input:		dc.b "J               "
RomStartLoc:	dc.l StartOfROM
RomEndLoc:	dc.l EndOfROM-1
RamStartLoc:	dc.l (RAM_start&$FFFFFF)
RamEndLoc:	dc.l (RAM_start&$FFFFFF)+$FFFF
	if DisableSRAM=1
CartRAM_Info:	dc.b "  "
CartRAM_Type:	dc.w %10000000100000
CartRAMStartLoc:dc.l $20202020	; SRAM start ($200001)
CartRAMEndLoc:	dc.l $20202020	; SRAM end ($20xxxx)
	else
CartRAM_Info:	dc.b "RA"
CartRAM_Type:	dc.b %11111000,%00100000
CartRAMStartLoc:dc.l $00200001	; SRAM start ($200001)
CartRAMEndLoc:	dc.l $002001FF	; SRAM end ($20xxxx)
	endif
Modem_Info:	dc.b "                                                    "
Country_Code:	dc.b "JUE             "

; ---------------------------------------------------------------------------
; Security Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Security Startup 1.asm"
		include "Data/Misc/Security Startup 2.asm"

; ---------------------------------------------------------------------------
; VDP Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/VDP.asm"

; ---------------------------------------------------------------------------
; Controllers Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Controllers.asm"

; ---------------------------------------------------------------------------
; DMA Queue Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/DMA Queue.asm"

; ---------------------------------------------------------------------------
; Plane Map To VRAM Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Plane Map To VRAM.asm"

; ---------------------------------------------------------------------------
; Decompression Subroutine
; ---------------------------------------------------------------------------

		include "Data/Decompression/Enigma Decompression.asm"
		include "Data/Decompression/Kosinski Decompression.asm"
		include "Data/Decompression/Kosinski Module Decompression.asm"

; ---------------------------------------------------------------------------
; Fading Palettes Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Fading Palette.asm"

; ---------------------------------------------------------------------------
; Load Palettes Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Load Palette.asm"

; ---------------------------------------------------------------------------
; Wait VSync Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Wait VSync.asm"

; ---------------------------------------------------------------------------
; Pause Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Pause Game.asm"

; ---------------------------------------------------------------------------
; Random Number Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Random Number.asm"

; ---------------------------------------------------------------------------
; Oscillatory Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Oscillatory Routines.asm"

; ---------------------------------------------------------------------------
; HUD Update Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/HUD Update.asm"

; ---------------------------------------------------------------------------
; Load Text Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Load Text.asm"

; ---------------------------------------------------------------------------
; Objects Process Subroutines
; ---------------------------------------------------------------------------

		include "Data/Objects/Process Sprites.asm"
		include "Data/Objects/Render Sprites.asm"

; ---------------------------------------------------------------------------
; Load Objects Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Load Objects.asm"

; ---------------------------------------------------------------------------
; Load Rings Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Load Rings.asm"

; ---------------------------------------------------------------------------
; Draw Level Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/DrawLevel.asm"

; ---------------------------------------------------------------------------
; Scroll Camera control routines
; ---------------------------------------------------------------------------

		include "Data/Misc/ScrollCamera.asm"

; ---------------------------------------------------------------------------
; Parallax Engine Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Parallax Engine.asm"

; ---------------------------------------------------------------------------
; Shake Screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Shake Screen.asm"

; ---------------------------------------------------------------------------
; Objects Subroutines
; ---------------------------------------------------------------------------

		include "Data/Objects/AnimateSprite.asm"
		include "Data/Objects/AnimateRaw.asm"
		include "Data/Objects/CalcAngle.asm"
		include "Data/Objects/CalcSine.asm"
		include "Data/Objects/CalcDist.asm"
		include "Data/Objects/DisplaySprite.asm"
		include "Data/Objects/FindFreeObj.asm"
		include "Data/Objects/DeleteObject.asm"
		include "Data/Objects/MoveSprite.asm"
		include "Data/Objects/MoveSprite Circular.asm"
		include "Data/Objects/Object Swing.asm"
		include "Data/Objects/Object Wait.asm"
		include "Data/Objects/ChangeFlip.asm"
		include "Data/Objects/CreateChildSprite.asm"
		include "Data/Objects/ChildGetPriority.asm"
		include "Data/Objects/CheckRange.asm"
		include "Data/Objects/ChkObjOnScreen.asm"
		include "Data/Objects/FindSonic.asm"
		include "Data/Objects/Misc.asm"
		include "Data/Objects/Palette Script.asm"
		include "Data/Objects/RememberState.asm"

; ---------------------------------------------------------------------------
; Objects Functions Subroutines
; ---------------------------------------------------------------------------

		include "Data/Objects/FindFloor.asm"
		include "Data/Objects/SolidObject.asm"
		include "Data/Objects/TouchResponse.asm"

; ---------------------------------------------------------------------------
; Interrupt Handler Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Interrupt Handler.asm"

; ---------------------------------------------------------------------------
; SRAM Handler
; ---------------------------------------------------------------------------

		include	"Data/Misc/SRAM.asm"

; ---------------------------------------------------------------------------
; Resize Events Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/DoResizeEvents.asm"

; ---------------------------------------------------------------------------
; Handle On screen Water Height Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/HandleOnscreenWaterHeight.asm"

; ---------------------------------------------------------------------------
; Animate Palette Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Animate Palette.asm"

; ---------------------------------------------------------------------------
; Animate Level Graphics Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Animate Tiles.asm"

; ---------------------------------------------------------------------------
; Get Level Size Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/GetLevelSizeStart.asm"

; ---------------------------------------------------------------------------
; Level Setup Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/LevelSetup.asm"

; ---------------------------------------------------------------------------
; Subroutine to load sonic object
; ---------------------------------------------------------------------------

		include "Objects/Sonic/Sonic.asm"
		include "Objects/Shields/Shields.asm"
		include "Objects/Spin Dust/SpinDust.asm"
		include "Objects/Trail/Trail.asm"

; ---------------------------------------------------------------------------
; Subroutine to load a objects
; ---------------------------------------------------------------------------

		include "Pointers/Objects Data.asm"

; ---------------------------------------------------------------------------
; AfterBoss Cleanup Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/AfterBoss Cleanup.asm"

; ---------------------------------------------------------------------------
; Special sprite transfer handler for pause/you died
; ---------------------------------------------------------------------------

		include "Data/Misc/Interrupt Sprites.asm"

; ---------------------------------------------------------------------------
; Level Screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Screens/Level Screen/Level.asm"

; ---------------------------------------------------------------------------
; Screens subroutines
; ---------------------------------------------------------------------------

		include "Data/Screens/Level Select Screen/Level Select.asm"

; ---------------------------------------------------------------------------
; Title Screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Screens/Title/Title.asm"

; ---------------------------------------------------------------------------
; Title Screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Screens/Options/Options.asm"

; ---------------------------------------------------------------------------
; Assist Warning Screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Screens/Assist/Assist.asm"

; ---------------------------------------------------------------------------
; Sound Test Screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Screens/Sound Test/Sound Test.asm"

; ---------------------------------------------------------------------------
; Sega Screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Screens/Sega/Sega.asm"

; ---------------------------------------------------------------------------
; Results Screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Screens/Results/Results.asm"

; ---------------------------------------------------------------------------
; EX Mode Screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Screens/EX Mode/EX Mode.asm"

; ---------------------------------------------------------------------------
; Dialog Screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Screens/Dialog/Dialog.asm"

	if GameDebug=1
; ---------------------------------------------------------------------------
; Debug Mode Subroutine
; ---------------------------------------------------------------------------

		include "Objects/Sonic/DebugMode.asm"
	endif

; ---------------------------------------------------------------------------
; Object Pointers
; ---------------------------------------------------------------------------

		include "Pointers/Object Pointers.asm"

; ---------------------------------------------------------------------------
; Subroutine to load sonic object data
; ---------------------------------------------------------------------------

		include "Objects/Sonic/Object data/Anim - Sonic.asm"
		include "Objects/Sonic/Object data/Map - Sonic.asm"
		include "Objects/Sonic/Object data/Sonic pattern load cues.asm"

; ---------------------------------------------------------------------------
; Subroutine to load level events
; ---------------------------------------------------------------------------

		include "Pointers/Levels Events.asm"

; ---------------------------------------------------------------------------
; DDZ Related
; ---------------------------------------------------------------------------

		include	"Levels/DDZ/Code/_Equates.asm"
		include	"Levels/DDZ/Code/_Macros.asm"
		include	"Levels/DDZ/Code/_V-Blank.asm"
		include	"Levels/DDZ/Code/SpriteControl.asm"
		include	"Levels/DDZ/Code/PreRot.asm"
		include	"Levels/DDZ/Code/PreSca.asm"
		include	"Levels/DDZ/Code/LevelInit.asm"
		include	"Levels/DDZ/Code/Events.asm"
		include "Levels/DDZ/Code/Scroll.asm"

; ---------------------------------------------------------------------------
; Pattern Load Cues pointers
; ---------------------------------------------------------------------------

		include "Pointers/Pattern Load Cues.asm"

; ---------------------------------------------------------------------------
; Levels data pointers
; ---------------------------------------------------------------------------

		include "Pointers/Levels Data.asm"

	if 0=1
GMZEmbers_LUT:
		include "Levels/GMZ/embers data.asm"
	endif

; ---------------------------------------------------------------------------
; DDZ Phase 2 special game/screen mode
; ---------------------------------------------------------------------------

		include "Levels/DDZ/Code/Phase 2.asm"

; ---------------------------------------------------------------------------
; DDZ Phase 2 Ending scene
; ---------------------------------------------------------------------------

		include "Levels/DDZ/Code/Ending Scene.asm"

; ---------------------------------------------------------------------------
; Thank you for playing screen
; ---------------------------------------------------------------------------

		include "Data/Screens/Thanks/Thanks.asm"

; ---------------------------------------------------------------------------
; Red Miso
; ---------------------------------------------------------------------------

		include "Data/Screens/Red Miso/Red Miso.asm"

; ---------------------------------------------------------------------------
; Large data for Credits
; ---------------------------------------------------------------------------

		include	"Data/Misc/Credits Text Sprites.asm"
		include "Data/Misc/Credits Render Tiles.asm"
		include "Data/Misc/Credits Render Sprites.asm"
		include	"Data/Misc/Credits Render List.asm"

; ---------------------------------------------------------------------------
; Palette data
; ---------------------------------------------------------------------------

		include "Pointers/Palette Pointers.asm"
		include "Pointers/Palette Data.asm"

; ---------------------------------------------------------------------------
; Kosinski Module compressed graphics pointers
; ---------------------------------------------------------------------------

		include "Pointers/Kosinski Module Data.asm"

; ---------------------------------------------------------------------------
; Kosinski compressed graphics pointers
; ---------------------------------------------------------------------------

		include "Pointers/Kosinski Data.asm"

; ---------------------------------------------------------------------------
; Enigma compressed graphics pointers
; ---------------------------------------------------------------------------

		include "Pointers/Enigma Data.asm"

; ---------------------------------------------------------------------------
; Uncompressed player graphics pointers
; ---------------------------------------------------------------------------

		align $8000

		include "Pointers/Uncompressed Player Data.asm"

; ---------------------------------------------------------------------------
; Uncompressed graphics pointers
; ---------------------------------------------------------------------------

;		align $8000

		include "Pointers/Uncompressed Data.asm"

; ---------------------------------------------------------------------------
; Music playlist Subroutine
; ---------------------------------------------------------------------------

		include "Misc Data/Music playlist.asm"

; ---------------------------------------------------------------------------
; Fractal sound driver subroutines
; ---------------------------------------------------------------------------

		include "Data/Misc/Fix Sound.asm"

		RELAXED ON
		include "Fractal/Code/extra.asm"
		include "Fractal/Code/main.asm"
		RELAXED OFF

; ---------------------------------------------------------------------------
; DualPCM include
; ---------------------------------------------------------------------------

DualPCM:
		binclude "Fractal/Code/DualPCM.kos"
		even

; ---------------------------------------------------------------------------
; 68k access samples
; ---------------------------------------------------------------------------

		include "Data/Misc/Play PCM.asm"
		include "Data/Misc/Play PCM Stereo.asm"

SEGA_Stereo:	binclude "Data/Screens/Red Miso/Data/SEGA Stereo.pcm"
SEGA_StereoEnd:	dc.b	$80,$80
SEGA:		binclude "Data/Screens/Red Miso/Data/SEGA.pcm"
SEGA_End:	dc.b	$80
Demons:		binclude "Fractal/Demons.raw"
Demons_End:	dc.b	$80

		even

; ---------------------------------------------------------------
; Error handling module
; ---------------------------------------------------------------

		include "Misc Data/Debugger/ErrorHandler/ErrorHandler.asm"

; end of 'ROM'
EndOfROM:

		END
