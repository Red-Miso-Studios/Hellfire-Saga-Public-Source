		dc.w heart-Ani_Flesh	; ������.
		dc.w bone-Ani_Flesh		; �����.
		dc.w gut-Ani_Flesh		; �����.
		dc.w meat-Ani_Flesh		; ����� ����.
		dc.w gut2-Ani_Flesh		; ����� 2(��� �� ��� ���...).
		dc.w blood-Ani_Flesh	; ����� �����.
heart:	dc.b 5, 1, 2, 3, 4, $FF	; ������ � ������ ������.
bone:	dc.b 5, 5, 6, 7, 8, $FF	; ������ � ������ ������.
gut:	dc.b 5, 9, $A, $B, $C, $FF	; ������ � ������ ������.
meat:	dc.b 5, $D, $E, $F, $10, $FF	; ������ � ������ ������.
gut2:	dc.b 5, $11, $12, $13, $14, $FF	; ������ � ������ ������.
blood:	dc.b 2, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F, $20, $FE, 1	; ��������� ��������� ���� ���������.
	even