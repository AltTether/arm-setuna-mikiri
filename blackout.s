
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
	.global	blackout

blackout:
	push	{r0-r12, r14}

		@ LEDとディスレイ用のIOポートを出力に設定する
	ldr     r0, =GPIO_BASE
	ldr     r1, =GPFSEL_VEC0
	str     r1, [r0, #GPFSEL0 + 0]
	ldr     r1, =GPFSEL_VEC1
	str     r1, [r0, #GPFSEL0 + 4]
	ldr     r1, =GPFSEL_VEC2
	str     r1, [r0, #GPFSEL0 + 8]
	
	mov     r1, #(1 << COL1_PORT)
	str     r1, [r0, #GPCLR0]
	mov     r1, #(1 << COL2_PORT)
	str     r1, [r0, #GPCLR0]
	mov     r1, #(1 << COL3_PORT)
	str     r1, [r0, #GPCLR0]
	mov     r1, #(1 << COL4_PORT)
	str     r1, [r0, #GPCLR0]
	mov     r1, #(1 << COL5_PORT)
	str     r1, [r0, #GPCLR0]
	mov     r1, #(1 << COL6_PORT)
	str     r1, [r0, #GPCLR0]
	mov     r1, #(1 << COL7_PORT)
	str     r1, [r0, #GPCLR0]
	mov     r1, #(1 << COL8_PORT)
	str     r1, [r0, #GPCLR0]
	
	    @   第1行だけ点灯
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

	mov     r1, #0x1f0000
1:      subs    r1, r1, #1      		@ 何もしないまま 0x00001f から 0 までカウントダウン
        bne     1b				@ 1b = 直前の1というラベルという意味	
	
	pop 	{r0-r12, r14}
	bx	r14
loop6:
	b	loop6
