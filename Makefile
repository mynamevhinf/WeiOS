#SOURCES = 
OBJS =  \
    kern/init.o  \
    kern/cmos.o  \
    kern/cga.o   \
    kern/console.o   \
    kern/kbd.o   \
    kern/picirq.o \
    lib/printfmt.o  \
    lib/string.o 	\
    kern/prink.o \
    kern/monitor.o  \
    kern/gdt_flush.o    \
    kern/lock.o 	\
    kern/proc.o 	\
    kern/swtch.o 	\
    kern/sched.o 	\
    kern/sysfunc.o 	\
    kern/trap.o \
    kern/trapentry.o \
    kern/time.o 	\
    kern/buddy.o 	\
    kern/slab.o 	\
    kern/kmalloc.o 	\
    kern/pmap.o 	\
    kern/ide.o  \
    kern/bio.o 	\
    kern/log.o 	\
    kern/file.o \
    kern/fs.o 	\
    kern/inode.o \
    kern/pipe.o  \
    kern/sysfile.o \
    kern/syscall.o 	\

# turn off the verbose commands
V = @

TOP = . 

CC := gcc -pipe
AS := gas
AR := ar
LD := ld
OBJCOPY := objcopy
OBJDUMP := objdump

CFLAGS = -fno-pic -static -fno-builtin -I$(TOP) -fno-strict-aliasing -O2 -Wall -MD -ggdb -m32 -Werror -fno-omit-frame-pointer -Wno-unused
CFLAGS += -fno-stack-protector

ASFLAGS = -m32 -gdwarf-2 -Wa,-divide 
LDFLAGS += -m elf_i386

WeiOS: bootblock kernel fs.img
	dd if=/dev/zero of=WeiOS count=10000
	dd if=bootblock of=WeiOS conv=notrunc
	dd if=kernel of=WeiOS seek=1 conv=notrunc

bootblock: boot/boot.S boot/bootmain.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -c boot/bootmain.c
	$(CC) $(CFLAGS) -fno-pic -nostdinc -c boot/boot.S
	$(LD) $(LDFLAGS) -N -e start_16 -Ttext 0x7c00 -o bootblock.o boot.o bootmain.o
	$(OBJDUMP) -S bootblock.o > ./obj/boot/bootblock.asm
	$(OBJCOPY) -S -O binary bootblock.o bootblock

initprocess: kern/initprocess.S
	$(CC) $(CFLAGS) -nostdinc -I. -c kern/initprocess.S
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x08048000 -o initprocess initprocess.o
	$(OBJDUMP) -S initprocess.o > ./obj/user/initprocess.asm

kernel: $(OBJS) entry.o initprocess kernel.ld 
	$(LD) $(LDFLAGS) -T kernel.ld -nostdlib -o kernel entry.o $(OBJS) -b binary initprocess
	$(OBJDUMP) -S kernel > ./obj/kernel/kernel.asm
	$(OBJDUMP) -t kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > ./obj/kernel/kernel.sym

entry.o: kern/entry.S
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -c kern/entry.S

ULIB = user/uprintf.o user/ustring.o user/usys.o
SHELLLIB = $(ULIB) user/umalloc.o lib/krbfunc.o

_sh: uentry.o user/sh.o $(SHELLLIB)
	$(LD) $(LDFLAGS) -N -e _ustart -Ttext 0x08048000 -o $@ $^
_%: uentry.o user/%.o $(ULIB)
	$(LD) $(LDFLAGS) -N -e _ustart -Ttext 0x08048000 -o $@ $^
	$(OBJDUMP) -S $@ > $*.asm

uentry.o: user/uentry.S
	$(CC) $(CFLAGS) -nostdinc -I. -c user/uentry.S

mkfs: lib/mkfs.c lib/mkfs.h
	gcc -Werror -Wall -o mkfs lib/mkfs.c

UPROGS = \
	_init\
	_sh\
	_ls\
	_cat\
	_mkdir\
	_cd\
	_cp\
	_mv\
	_rm\

fs.img: mkfs $(UPROGS)
	./mkfs fs.img Makefile cattest.txt $(UPROGS)

all: WeiOS

cleanWOS:
	$(V)rm WeiOS kernel bootblock fs.img

clean:
	$(V)rm -f mkfs kern/*.o kern/*.d lib/*.o lib/*.d \
				user/*.o user/*.d *.asm _* \
				*.o *.d *.out kernel bootblock initprocess

