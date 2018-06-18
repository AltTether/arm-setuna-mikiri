	.equ	STACK, 0x8000
	.section .init
	.global	_start
_start:
	mov	sp, #STACK
	bl	se
	bl	wait_random_otetsuki
	cmp	r1, #1
	bleq	otetsuki
	beq	_start
	bl	indicate_starting
	bl	display
	bl 	blackout
	bl 	wait_continue
	b	_start
loop:	b	loop
