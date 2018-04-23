# CCBOOT requires 2219 byte of SRAM, we try to put it at the upper XDATA location
# by assigning --xram-loc and --xram-size closer to 0x2000 (CC253F256 has 8K SRAM)
SDCCCFLAGS = --model-large --opt-code-size --no-xinit-opt
ASLINKFLAGS = --model-large --code-loc 0x0000 --xram-loc 0x1400 --xram-size 0x0C00

# User program may overwrite any SRAM location of bootloader, except the passkey_index
# The --xram-size limit is exaclty the location of passkey_index (look at bootload.map)
EXSDCCCFLAGS = --model-large --opt-code-size --no-xinit-opt
EXASLINKFLAGS = --model-large --code-loc 0x1000 --xram-loc 0x0000 --xram-size 0x1400

%.rel : %.c
	sdcc $(SDCCCFLAGS) -c -mmcs51 $<

all: bootload example

bootload: bootload.rel clock.rel uart.rel flash.rel userprog.rel
	sdcc $(SDCCCFLAGS) $(ASLINKFLAGS) $^
	packihx bootload.ihx > bootload.hex
	objcopy -I ihex -O binary  bootload.hex   bootload.bin 

example: example.rel clock.rel uart.rel
	sdcc $(EXSDCCCFLAGS) $(EXASLINKFLAGS) $^
	packihx example.ihx > example.hex
	objcopy -I ihex -O binary example.hex  example.bin 

clean:
	rm -f bootload.asm bootload.cdb bootload.lk bootload.mem bootload.omf
	rm -f example.asm example.cdb example.lk example.mem example.omf
	rm -f *.asm *.bin *.hex *.ihx *.lnk *.lst *.map *.rel *.rst *.sym
