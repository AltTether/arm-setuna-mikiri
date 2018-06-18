	.equ    GPIO_BASE,  0x3f200000 @ GPIOベースアドレス
	.equ    GPFSEL0,    0x00       @ GPIOポートの機能を選択する番地のオフセット
	.equ    GPSET0,     0x1C       @ GPIOポートの出力値を1にするための番地のオフセット
	.equ    GPCLR0,     0x28       @ GPIOボートの出力値を0にするための番地のオフセット
	.equ	GPLEV0,	    0x34
	.equ	SW1_PORT,   13		@ スイッチ1が接続されたGPIOのポート番号
	.equ	SW2_PORT,   26		@ スイッチ2が接続されたGPIOのポート番号
	.equ	SW3_PORT,   5		@ スイッチ3が接続されたGPIOのポート番号
	.equ	SW4_PORT,   6		@ スイッチ4が接続されたGPIOのポート番号
	.equ	LED_PORT,   10	

	.equ    GPFSEL_VEC0, 0x01201000 @ GPFSEL0 に設定する値 (GPIO #4, #7, #8 を出力用に設定)
	.equ    GPFSEL_VEC1, 0x01249041 @ GPFSEL1 に設定する値 (GPIO #10, #12, #14, #15, #16, #17, #18 を出力用に設定)
	.equ    GPFSEL_VEC2, 0x209249 @ GPFSEL2 に設定する値 (GPIO #20, #21, #22, #23, #24, #25, #27 を出力用に設定)

	.equ	TIMER_BASE, 0x3f003000
	.equ	TIMER_CLO, 0x4

	.equ 	COL1_PORT, 27
	.equ 	COL2_PORT, 8
	.equ	COL3_PORT, 25
	.equ 	COL4_PORT, 23
	.equ 	COL5_PORT, 24
	.equ 	COL6_PORT, 22
	.equ	COL7_PORT, 17
	.equ	COL8_PORT, 4
	.equ	ROW1_PORT, 14
	.equ	ROW2_PORT, 15
	.equ	ROW3_PORT, 21
	.equ	ROW4_PORT, 18
	.equ	ROW5_PORT, 12
	.equ	ROW6_PORT, 20
	.equ	ROW7_PORT, 7
	.equ	ROW8_PORT, 16

	@.equ	STACK, 0x8000

	.section .text
	.global	otetsuki

otetsuki:
	mov	r1, #1
	push	{r0-r12, r14}

	@ LEDとディスレイ用のIOポートを出力に設定する
	ldr     r0, =GPIO_BASE
	ldr     r1, =GPFSEL_VEC0
	str     r1, [r0, #GPFSEL0 + 0]
	ldr     r1, =GPFSEL_VEC1
	str     r1, [r0, #GPFSEL0 + 4]
	ldr     r1, =GPFSEL_VEC2
	str     r1, [r0, #GPFSEL0 + 8]

	@ 押されたスイッチの判定
	@ display.sの主記憶領域r2 = judge_を読み込んで判別
	mov	r4, #1
label_:	
	ldrb	r3, [r2]
	cmp	r3, #1
	beq	hantei_
	add 	r4, r4, #1 	
	add	r2, r2, #1	 
	cmp	r4, #5
	bne	label_
	b	ending

	@ どの番号のスイッチが押されたか確認
hantei_:	
	cmp	r4, #4
	beq	SWI4
	cmp	r4, #3
	beq	SWI3
	cmp	r4, #2
	beq	SWI2
	cmp	r4, #1
	beq	SWI1

	@ 押されたスイッチのフレームバッファを読み込む
SWI4:
	ldr	r5, =batsu4
	b	cross
SWI3:
	ldr	r5, =batsu3
	b	cross
SWI2:
	ldr	r5, =batsu2
	b	cross
SWI1:
	ldr	r5, =batsu1
	b	cross
	
cross:	
	@ 表示
	ldr	r2, =0x1f00
	
repeat_:

	ldr	r4, =row_port	@ 行ポートを読み込む
	mov	r12, #8		@ ループ回数

ROW_:
	ldr	r7, =col_port	@ 列ポートを読み込む

	@行の初期化
	mov     r1, #(1 << ROW1_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW2_PORT)
	str     r1, [r0, #GPSET0]              
	mov     r1, #(1 << ROW3_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW4_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW5_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW6_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW7_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW8_PORT)
	str     r1, [r0, #GPSET0]

	ldrb	r6, [r5]	@ maru1の1バイトデータを格納
	mov	r8, #8		@ ループ回数
	
COL_:
	and	r9, r6, #1	@ maru1の２進数の一桁目だけ取り出す
	cmp	r9, #1
	mov	r10, #GPCLR0
	moveq	r10, #GPSET0	@ r9が1ならば点灯する
	ldrb	r11, [r7]	@ 現在の列ポート番号を格納
	mov	r1, #1
	mov	r1, r1, lsl r11
	str	r1, [r0, r10]	@ 列の点灯

	lsr	r6, #1		@ maruの1バイトとデータを右シフト
	add	r7, r7, #1	@ 次の列へ
	subs	r8, r8, #1	@ ループ回数をカウント
	bne	COL_		@ ループ回数分だけループ

	ldrb	r3, [r4]	@ 行の1バイトを格納
	mov	r1, #1
	mov	r1, r1, lsl r3
	str	r1, [r0, #GPCLR0]	@ 行の点灯

	@ 少し待つ
	ldr	r1, =TIMER_BASE
	ldr	r9, [r1, #TIMER_CLO]
	ldr	r10, =10
	add	r9, r9, r10
7:	ldr	r11, [r1, #TIMER_CLO]
	cmp	r11, r9
	bcc	7b

	ldrb	r3, [r4]	@ 行の1バイトを格納
	mov	r1, #1
	mov	r1, r1, lsl r3
	str	r1, [r0, #GPSET0]	@ 行の点灯
	
	add	r4, r4, #1	@ 次の行へ
	add	r5, r5, #1	@ maru1の次の1バイトへ
	subs	r12, r12, #1	@ ループ回数をカウント
	bne	ROW_		@ ループ回数分だけループ

	sub	r5, r5, #8	@ 	
	subs	r2, r2, #1
	bne	repeat_
	
ending:
	pop 	{r0-r12, r14}
	bx	r14
	
loop9:	b 	loop9

	
	.section .data
	
batsu4:
	.byte 9, 6, 6, 9, 0, 0, 0, 0
batsu3:
	.byte 144, 96, 96, 144, 0, 0, 0, 0
batsu2:
	.byte 0, 0, 0, 0, 9, 6, 6, 9
batsu1:
	.byte 0, 0, 0, 0, 144, 96, 96, 144

col_port:
	.byte 4, 17, 22, 24, 23, 25, 8, 27 
row_port:
	.byte 14, 15, 21, 18, 12, 20, 7, 16

