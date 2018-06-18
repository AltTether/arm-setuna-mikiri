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
	.global	display
display:
	@mov     sp, #STACK

	push	{r0-r12, r14}
	
	@ LEDとディスレイ用のIOポートを出力に設定する
	ldr     r0, =GPIO_BASE
	ldr     r1, =GPFSEL_VEC0
	str     r1, [r0, #GPFSEL0 + 0]
	ldr     r1, =GPFSEL_VEC1
	str     r1, [r0, #GPFSEL0 + 4]
	ldr     r1, =GPFSEL_VEC2
	str     r1, [r0, #GPFSEL0 + 8]

	mov	r11, #100

@ switch_flag の初期化
	ldr	r1, =switch_flag
	mov	r2, #0
	strb	r2, [r1]

@ judge_の初期化
	ldr	r1, =judge_
	mov	r2, #0
	strb	r2, [r1, #0]

	ldr     r1, =judge_
        mov     r2, #0
        strb    r2, [r1, #1]

	ldr     r1, =judge_
        mov     r2, #0
        strb    r2, [r1, #2]

	ldr     r1, =judge_
        mov     r2, #0
        strb    r2, [r1, #3]
@ countの初期化
	ldr	r1, =count
	mov	r2, #0
	strb	r2, [r1]

input:	
	ldr	r3, =number0	@ 10の位
	mov	r9, #10		@ ループ回数
	
firstloop:	
	ldr	r4, =number0	@ 1の位
	mov	r10, #10	@ ループ回数
	
secondloop:
	ldr	r2, =frame_buffer	@ フレームバッファ
	mov	r5, #8		@ ループ回数
	
	ldr	r6, =count
	ldrb	r7, [r6]
	add	r7, r7, #1
	strb	r7, [r6]

writebuffer:
	ldrb	r6, [r3]	@ 10の位の1バイトを読み出し
	lsl	r6, #4		@ 左に4ビットシフト
	ldrb	r7, [r4]	@ 1の位の1バイトを読み出し
	add	r8, r6, r7	@ 10の位と1の位を合わせる
	strb	r8, [r2]	@ フレームバッファの1バイトに格納
	add	r2, r2, #1	@ 次のバッファへ
	add	r4, r4, #1	@ 1の位で次のバイトへ
	add	r3, r3, #1	@ 10の位で次のバイトへ
	
	subs	r5, r5, #1	@ ループ回数をカウント
	bne	writebuffer

out:	
	ldr	r1, =TIMER_BASE
	ldr	r7, [r1, #TIMER_CLO]
	
	ldr	r6, =9200
	add	r6, r6, r7
1:	ldr	r8, [r1, #TIMER_CLO]
	bl	output
	cmp	r8, r6
	bcc	1b
			
	ldr	r6, =switch_flag
	ldrb	r7, [r6]
	cmp	r7, #1
	bne	wait
	subeqs	r11, r11, #1
	bne	out

	b	next
	@beq	判定をディスプレイに表示する

wait:	
	subeq	r3, r3, #8
	subeq	r4, r4, #8
	beq	secondloop

	subs	r10, r10, #1	@ ループ回数をカウント
	subne	r3, r3, #8	@ 10の位はそのままに
	bne	secondloop
	
	subs	r9, r9, #1	@ ループ回数をカウント
	bne	firstloop

next:
	
	pop	{r0-r12, r14}
	ldr	r2, =judge_
	bx	r14
	@b	input

loop4:	
	b	loop4

	
output:
	push	{r0-r12, r14}
	
	ldr	r2, =frame_buffer	@ フレームバッファを読み込む
	ldr	r4, =row_port		@ 行ポートを読み込む
	mov	r10, #8			@ ループ回数
row:
	ldr	r3, =col_port		@ 列ポートを読み込む
	
	@ 行の初期化
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

	ldrb	r5, [r2]	@ フレームバッファの1バイトデータを格納
	mov	r9, #8		@ ループ回数
	
check_buffer:
	and	r6, r5, #1	@ フレームバッファの２進数の一桁目だけ取り出す
	cmp	r6, #1
	mov	r7, #GPCLR0
	moveq	r7, #GPSET0	@ r6が1ならば点灯する
	ldrb	r8, [r3]	@ 現在の列ポート番号を格納
	mov	r1, #1
	mov	r1, r1, lsl r8
	str	r1, [r0, r7]	@ 列の点灯
	
	lsr	r5, #1		@ フレームバッファの1バイトとデータを右シフト
	add	r3, r3, #1	@ 次の列へ
	subs	r9, r9, #1	@ ループ回数をカウント
	bne	check_buffer	@ ループ回数分だけループ

	ldrb	r11, [r4]	@ 行の1バイトを格納
	mov	r1, #1
	mov	r1, r1, lsl r11
	str	r1, [r0, #GPCLR0]	@ 行の点灯

	ldr	r1, =TIMER_BASE
	ldr	r9, [r1, #TIMER_CLO]
	ldr	r7, =100
	add	r9, r9, r7
	
1:	ldr	r8, [r1, #TIMER_CLO]
	ldr 	r6, =switch_flag
	ldrb	r12, [r6]
	cmp	r12, #1
	beq	5f
	
	mov	r5, #(1 << (SW1_PORT % 32))
	ldr	r6, [r0, #(GPLEV0 + SW1_PORT / 32 * 4)]
	and	r6, r6, r5
	cmp	r6, r5
	bne	2f
	ldr	r6, =switch_flag
	mov	r5, #1
	strb	r5, [r6]
	ldr	r7, =judge_
	strb	r5, [r7]
	b 	5f
	
2:	
	mov	r5, #(1 << (SW2_PORT % 32))
	ldr	r6, [r0, #(GPLEV0 + SW2_PORT / 32 * 4)]
	and	r6, r6, r5
	cmp	r6, r5
	bne	3f
	ldr	r6, =switch_flag
	mov	r5, #1
	strb	r5, [r6]
	ldr	r7, =judge_
	strb	r5, [r7, #1]
	b 	5f
	
3:	
	mov	r5, #(1 << (SW3_PORT % 32))
	ldr	r6, [r0, #(GPLEV0 + SW3_PORT / 32 * 4)]
	and	r6, r6, r5
	cmp	r6, r5
	bne	4f
	ldr	r6, =switch_flag
	mov	r5, #1
	strb	r5, [r6]
	ldr	r7, =judge_
	strb	r5, [r7, #2]
	b	5f
	
4:	
	mov	r5, #(1 << (SW4_PORT % 32))
	ldr	r6, [r0, #(GPLEV0 + SW4_PORT / 32 * 4)]
	and	r6, r6, r5
	cmp	r6, r5
	bne	5f
	ldr	r6, =switch_flag
	mov	r5, #1
	strb	r5, [r6]
	ldr	r7, =judge_
	strb	r5, [r7, #3]
	b	5f
	
5:	

	cmp	r8, r9
	bcc	1b

	add	r4, r4, #1	@ 次の行へ
	add	r2, r2, #1	@ 次の1バイトのフレームバッファへ
	subs	r10, r10, #1	@ ループ回数をカウント
	bne	row		@ ループ回数分だけループ
	
	pop    {r0-r12, r14}
	bx	r14
loop3:
	b	loop3



	
	.section .data
frame_buffer:
	.byte 0, 0, 0, 0, 0, 0, 0, 0

col_port:
	.byte 4, 17, 22, 24, 23, 25, 8, 27 
row_port:
	.byte 14, 15, 21, 18, 12, 20, 7, 16

number0:
	.byte 0, 0x0e, 0x0a, 0x0a, 0x0a, 0x0e, 0, 0
number1:
	.byte 0, 0x04, 0x0c, 0x04, 0x04, 0x0e, 0, 0
number2:
	.byte 0, 0x0e, 0x02, 0x0e, 0x08, 0x0e, 0, 0
number3:
	.byte 0, 0x0e, 0x02, 0x0e, 0x02, 0x0e, 0, 0
number4:
	.byte 0, 0x0a, 0x0a, 0x0e, 0x02, 0x02, 0, 0
number5:
	.byte 0, 0x0e, 0x08, 0x0e, 0x02, 0x0e, 0, 0
number6:
	.byte 0, 0x0e, 0x08, 0x0e, 0x0a, 0x0e, 0, 0
number7:
	.byte 0, 0x0e, 0x0a, 0x02, 0x02, 0x02, 0, 0
number8:
	.byte 0, 0x0e, 0x0a, 0x0e, 0x0a, 0x0e, 0, 0
number9:
	.byte 0, 0x0e, 0x0a, 0x0e, 0x02, 0x0e, 0, 0
switch_flag:
	.byte 0
count:
	.byte 0	
judge_:
	.byte 0, 0, 0, 0
