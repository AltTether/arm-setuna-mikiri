@ ボタンをおされるまで待機するプログラム
	.equ	GPIO_BASE,  0x3f200000 @ GPIOベースアドレス
        .equ    GPFSEL0,    0x00       @ GPIOポートの機能を選択する番地のオフセット
        .equ    GPSET0,     0x1C       @ GPIOポートの出力値を1にするための番地のオフセット
        .equ    GPCLR0,     0x28       @ GPIOボートの出力値を0にするための番地のオフセット
	.equ	GPLEV0,     0x34
        .equ    SW1_PORT,   13          @ スイッチ1が接続されたGPIOのポート番号
        .equ    SW2_PORT,   26          @ スイッチ2が接続されたGPIOのポート番号
        .equ    SW3_PORT,   5           @ スイッチ3が接続されたGPIOのポート番号
        .equ    SW4_PORT,   6           @ スイッチ4が接続されたGPIOのポート番号
        .equ    GPFSEL_VEC0, 0x01201000 @ GPFSEL0 に設定する値 (GPIO #4, #7, #8 を出力用に設定)
        .equ    GPFSEL_VEC1, 0x11249041 @ GPFSEL1 に設定する値 (GPIO #10, #12, #14, #15, #16, #17, #18 を出力用に,#19をPWM1に設定)
        .equ    GPFSEL_VEC2, 0x209249 @ GPFSEL2 に設定する値 (GPIO #20, #21, #22, #23, #24, #25, #27 を出力用に設定)
        .equ    TIMER_BASE, 0x3f003000
        .equ    TIMER_CLO, 0x4

        .equ    LOWER32BIT, 0x4
        .equ    GPFSEL_OUT, 0x1          @ 出力用

        .equ    PWM_HZ, 9600 * 1000
        .equ    KEY_4A, PWM_HZ / 440    @ 440Hzの時の1周期のクロック数
        .equ    KEY_8A, PWM_HZ / 880    @ 880Hzの時の1周期のクロック数


        .equ    CM_BASE, 0x3f101000
        .equ    CM_PWMCTL, 0xa0
        .equ    CM_PWMDIV, 0xa4

        .equ    PWM_BASE, 0x3f20c000    @ PWMを制御するためのレジスタのベースアドレス
        .equ    PWM_RNG2, 0x20          @ PWMのチャンネル2の範囲
        .equ    PWM_DAT2, 0x24          @ PWMのチャンネル2のドュ−ティー比
        .equ    PWM_PWEN2, 0x8          @ CTLレジスタのPWEN2ビット
        .equ    PWM_MSEN2, 0xf          @ CTLレジスタのMSEN2ビット
        .equ    CTL, 0x0                @ CTLレジスタ

        .equ    COL1_PORT, 27
        .equ    COL2_PORT, 8
        .equ    COL3_PORT, 25
        .equ    COL4_PORT, 23
        .equ    COL5_PORT, 24
        .equ    COL6_PORT, 22
        .equ    COL7_PORT, 17
        .equ    COL8_PORT, 4
        .equ    ROW1_PORT, 14
        .equ    ROW2_PORT, 15
        .equ    ROW3_PORT, 21
        .equ    ROW4_PORT, 18
        .equ    ROW5_PORT, 12
        .equ    ROW6_PORT, 20
        .equ    ROW7_PORT, 7
        .equ    ROW8_PORT, 16

        .equ    STACK, 0x8000

	.section .text
	.global	wait_continue
wait_continue:
        push    {r0-r12, r14}
        @ LEDとディスレイ用のIOポートを出力に設定する
        ldr     r0, =GPIO_BASE
        ldr     r1, =GPFSEL_VEC0
        str     r1, [r0, #GPFSEL0 + 0]
        ldr     r1, =GPFSEL_VEC1
        str     r1, [r0, #GPFSEL0 + 4]
        ldr     r1, =GPFSEL_VEC2
        str     r1, [r0, #GPFSEL0 + 8]
wait_loop_:	
	bl	judge

	mov     r4, #(1 << (SW1_PORT % 32))
        ldr     r3, [r0, #(GPLEV0 + SW1_PORT / 32 * 4)]
        and     r3, r3, r4
        cmp     r3, r4
        beq     end_loop

        mov     r4, #(1 << (SW2_PORT % 32))
        ldr     r3, [r0, #(GPLEV0 + SW2_PORT / 32 * 4)]
        and     r3, r3, r4
        cmp     r3, r4
        beq     end_loop

        mov     r4, #(1 << (SW3_PORT % 32))
        ldr     r3, [r0, #(GPLEV0 + SW3_PORT / 32 * 4)]
        and     r3, r3, r4
        cmp     r3, r4
        beq     end_loop

        mov     r4, #(1 << (SW4_PORT % 32))
        ldr     r3, [r0, #(GPLEV0 + SW4_PORT / 32 * 4)]
        and     r3, r3, r4
        cmp     r3, r4
        beq     end_loop	
test_:
	b	wait_loop_

end_loop:
	pop	{r0-r12, r14}
	bx	r14

loop8:	b	loop8	
