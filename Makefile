#マクロ定義
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
LDFLAGS = -m armelf -no-undefined
OBJ = arm-none-eabi-objcopy

%.o: %.s
	$(AS) $< -o $@


main.elf: main.o se.o wait_random.o indicate_starting.o display.o blackout.o judge.o wait_continue.o wait_random_otetsuki.o otetsuki.o
	$(LD) $(LDFLAGS) $+ -o $@



#擬似ターゲットであることを明示
.PHONY: main.img clean

main.img: main.elf
	$(OBJ) $+ -O binary $@

clean:
	rm -f *.o *.elf *.img
