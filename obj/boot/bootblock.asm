
bootblock.o:     file format elf32-i386


Disassembly of section .text:

00007c00 <start_16>:
#include <include/boot.h>

.code16
.globl start_16
start_16:
    cli
    7c00:	fa                   	cli    
    xorw    %ax, %ax
    7c01:	31 c0                	xor    %eax,%eax
    movw    %ax, %ds
    7c03:	8e d8                	mov    %eax,%ds
    movw    %ax, %es
    7c05:	8e c0                	mov    %eax,%es
    movw    %ax, %ss
    7c07:	8e d0                	mov    %eax,%ss
    movw    $start_16, %sp
    7c09:	bc                   	.byte 0xbc
    7c0a:	00                   	.byte 0x0
    7c0b:	7c                   	.byte 0x7c

00007c0c <setupA20_1>:

setupA20_1:
    inb     $0x64, %al      # Wait for not busy
    7c0c:	e4 64                	in     $0x64,%al
    testb   $0x2, %al
    7c0e:	a8 02                	test   $0x2,%al
    jnz     setupA20_1
    7c10:	75 fa                	jne    7c0c <setupA20_1>
    
    movb    $0xd1, %al
    7c12:	b0 d1                	mov    $0xd1,%al
    outb    %al, $0x64
    7c14:	e6 64                	out    %al,$0x64

00007c16 <setupA20_2>:

setupA20_2:
    inb     $0x64, %al
    7c16:	e4 64                	in     $0x64,%al
    testb   $0x2, %al
    7c18:	a8 02                	test   $0x2,%al
    jnz     setupA20_2
    7c1a:	75 fa                	jne    7c16 <setupA20_2>

    movb    $0xdf, %al
    7c1c:	b0 df                	mov    $0xdf,%al
    outb    %al, $0x60
    7c1e:	e6 60                	out    %al,$0x60

    # It time to load gdt
    lgdt    gdtdesc
    7c20:	0f 01 16             	lgdtl  (%esi)
    7c23:	64 7c 0f             	fs jl  7c35 <start_32+0x1>
    movl    %cr0, %eax
    7c26:	20 c0                	and    %al,%al
    orl     $0x1, %eax          # segment protection
    7c28:	66 83 c8 01          	or     $0x1,%ax
    movl    %eax, %cr0
    7c2c:	0f 22 c0             	mov    %eax,%cr0
    ljmp    $(KERNEL_CODE), $start_32
    7c2f:	ea                   	.byte 0xea
    7c30:	34 7c                	xor    $0x7c,%al
    7c32:	08 00                	or     %al,(%eax)

00007c34 <start_32>:

.code32
start_32:
    movw    $(KERNEL_DATA), %ax 
    7c34:	66 b8 10 00          	mov    $0x10,%ax
    movw    %ax, %es
    7c38:	8e c0                	mov    %eax,%es
    movw    %ax, %ds
    7c3a:	8e d8                	mov    %eax,%ds
    movw    %ax, %ss
    7c3c:	8e d0                	mov    %eax,%ss
    movl    $0x7c00, %esp
    7c3e:	bc 00 7c 00 00       	mov    $0x7c00,%esp

    call    bootmain
    7c43:	e8 e2 00 00 00       	call   7d2a <bootmain>

00007c48 <deadloop>:

deadloop:
    jmp     deadloop    
    7c48:	eb fe                	jmp    7c48 <deadloop>
    7c4a:	66 90                	xchg   %ax,%ax

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00                   	.byte 0x0
    7c61:	92                   	xchg   %eax,%edx
    7c62:	cf                   	iret   
	...

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
	...

00007c6a <waitfordisk>:

/************************************************
                Useful function
************************************************/
void waitfordisk(void)
{
    7c6a:	55                   	push   %ebp
    7c6b:	89 e5                	mov    %esp,%ebp
#define LBA 0x40

static inline uchar inb(ushort port)
{
    uchar data;
    asm volatile ("inb %1, %0":"=a" (data):"d" (port));
    7c6d:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c72:	ec                   	in     (%dx),%al
    while ((inb(0x1f7) & 0xC0) != 0x40)
    7c73:	83 e0 c0             	and    $0xffffffc0,%eax
    7c76:	3c 40                	cmp    $0x40,%al
    7c78:	75 f8                	jne    7c72 <waitfordisk+0x8>
        ;
}
    7c7a:	5d                   	pop    %ebp
    7c7b:	c3                   	ret    

00007c7c <readdisk>:

// read a single block into memory.
// void outb(ushort port, uchar data)
void readdisk(void *dst, uint sec_num)
{
    7c7c:	55                   	push   %ebp
    7c7d:	89 e5                	mov    %esp,%ebp
    7c7f:	57                   	push   %edi
    7c80:	53                   	push   %ebx
    7c81:	8b 5d 0c             	mov    0xc(%ebp),%ebx

    waitfordisk();
    7c84:	e8 e1 ff ff ff       	call   7c6a <waitfordisk>
}


static inline void outb(ushort port, uchar data)
{
    asm volatile ("outb %1, %w0"::"d" (port), "a" (data));
    7c89:	b8 01 00 00 00       	mov    $0x1,%eax
    7c8e:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c93:	ee                   	out    %al,(%dx)
    7c94:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7c99:	89 d8                	mov    %ebx,%eax
    7c9b:	ee                   	out    %al,(%dx)
    7c9c:	89 d8                	mov    %ebx,%eax
    7c9e:	c1 e8 08             	shr    $0x8,%eax
    7ca1:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7ca6:	ee                   	out    %al,(%dx)
    7ca7:	89 d8                	mov    %ebx,%eax
    7ca9:	c1 e8 10             	shr    $0x10,%eax
    7cac:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7cb1:	ee                   	out    %al,(%dx)
    7cb2:	89 d8                	mov    %ebx,%eax
    7cb4:	c1 e8 18             	shr    $0x18,%eax
    7cb7:	83 e0 0f             	and    $0xf,%eax
    7cba:	83 c8 e0             	or     $0xffffffe0,%eax
    7cbd:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cc2:	ee                   	out    %al,(%dx)
    7cc3:	b8 20 00 00 00       	mov    $0x20,%eax
    7cc8:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7ccd:	ee                   	out    %al,(%dx)
    outb(0x1f4, (sec_num>>8) & 0xff);
    outb(0x1f5, (sec_num>>16) & 0xff);
    outb(0x1f6, LBA|0xA0|((sec_num>>24) & 0x0f));
    outb(0x1f7, 0x20);

    waitfordisk();
    7cce:	e8 97 ff ff ff       	call   7c6a <waitfordisk>
    return data;
}

static inline void insl(int port, void *addr, int count)
{
    asm volatile ("cld\n\trepne\n\tinsl"
    7cd3:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cd6:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cdb:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7ce0:	fc                   	cld    
    7ce1:	f2 6d                	repnz insl (%dx),%es:(%edi)
    insl(0x1f0, dst, BLKSIZE/4);
}
    7ce3:	5b                   	pop    %ebx
    7ce4:	5f                   	pop    %edi
    7ce5:	5d                   	pop    %ebp
    7ce6:	c3                   	ret    

00007ce7 <readsegment>:

// read a segment into memory
// offset relatives to the start of the kernel.
void readsegment(uchar *pa, uint bytes, uint offset)
{
    7ce7:	55                   	push   %ebp
    7ce8:	89 e5                	mov    %esp,%ebp
    7cea:	57                   	push   %edi
    7ceb:	56                   	push   %esi
    7cec:	53                   	push   %ebx
    7ced:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7cf0:	8b 45 10             	mov    0x10(%ebp),%eax
    uint  sec_num;
    uchar *epa = pa + bytes;
    7cf3:	89 df                	mov    %ebx,%edi
    7cf5:	03 7d 0c             	add    0xc(%ebp),%edi
    
    sec_num = offset / BLKSIZE + 1;
    7cf8:	89 c6                	mov    %eax,%esi
    7cfa:	c1 ee 09             	shr    $0x9,%esi
    7cfd:	83 c6 01             	add    $0x1,%esi
    for (pa -= (offset%BLKSIZE); pa < epa; sec_num++, pa += BLKSIZE)  
    7d00:	25 ff 01 00 00       	and    $0x1ff,%eax
    7d05:	29 c3                	sub    %eax,%ebx
    7d07:	39 df                	cmp    %ebx,%edi
    7d09:	76 17                	jbe    7d22 <readsegment+0x3b>
        readdisk(pa, sec_num);
    7d0b:	56                   	push   %esi
    7d0c:	53                   	push   %ebx
    7d0d:	e8 6a ff ff ff       	call   7c7c <readdisk>
{
    uint  sec_num;
    uchar *epa = pa + bytes;
    
    sec_num = offset / BLKSIZE + 1;
    for (pa -= (offset%BLKSIZE); pa < epa; sec_num++, pa += BLKSIZE)  
    7d12:	83 c6 01             	add    $0x1,%esi
    7d15:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d1b:	83 c4 08             	add    $0x8,%esp
    7d1e:	39 df                	cmp    %ebx,%edi
    7d20:	77 e9                	ja     7d0b <readsegment+0x24>
        readdisk(pa, sec_num);
}
    7d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d25:	5b                   	pop    %ebx
    7d26:	5e                   	pop    %esi
    7d27:	5f                   	pop    %edi
    7d28:	5d                   	pop    %ebp
    7d29:	c3                   	ret    

00007d2a <bootmain>:

void readdisk(void *dst, uint sec_num);
void readsegment(uchar *pa, uint bytes, uint offset);

void bootmain(void)
{
    7d2a:	55                   	push   %ebp
    7d2b:	89 e5                	mov    %esp,%ebp
    7d2d:	57                   	push   %edi
    7d2e:	56                   	push   %esi
    7d2f:	53                   	push   %ebx
    7d30:	83 ec 0c             	sub    $0xc,%esp
    struct Elf32_Phdr      *ph;
    void (*kernel_entry)(void);
    uchar* pa;

    e = (struct Elf32_Ehdr *)0x10000;
    readsegment((uchar *)e, 4096, 0);
    7d33:	6a 00                	push   $0x0
    7d35:	68 00 10 00 00       	push   $0x1000
    7d3a:	68 00 00 01 00       	push   $0x10000
    7d3f:	e8 a3 ff ff ff       	call   7ce7 <readsegment>
    // check wether the image is a legal elf file.
    if (e->e_magic != ELF_MAGIC)
    7d44:	83 c4 0c             	add    $0xc,%esp
    7d47:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d4e:	45 4c 46 
    7d51:	75 59                	jne    7dac <bootmain+0x82>
        return ;

    ph = (struct Elf32_Phdr *)((uchar *)e + e->e_phoff);
    7d53:	a1 1c 00 01 00       	mov    0x1001c,%eax
    7d58:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
    for (int i = 0; i < e->e_phnum; i++, ph++) {
    7d5e:	66 83 3d 2c 00 01 00 	cmpw   $0x0,0x1002c
    7d65:	00 
    7d66:	74 3e                	je     7da6 <bootmain+0x7c>
    7d68:	be 00 00 00 00       	mov    $0x0,%esi
        pa = (uchar *)ph->p_paddr;
    7d6d:	8b 7b 0c             	mov    0xc(%ebx),%edi
        readsegment(pa, ph->p_filesz, ph->p_offset);
    7d70:	ff 73 04             	pushl  0x4(%ebx)
    7d73:	ff 73 10             	pushl  0x10(%ebx)
    7d76:	57                   	push   %edi
    7d77:	e8 6b ff ff ff       	call   7ce7 <readsegment>
        if (ph->p_memsz > ph->p_filesz)
    7d7c:	8b 43 14             	mov    0x14(%ebx),%eax
    7d7f:	8b 53 10             	mov    0x10(%ebx),%edx
    7d82:	83 c4 0c             	add    $0xc,%esp
    7d85:	39 d0                	cmp    %edx,%eax
    7d87:	76 0c                	jbe    7d95 <bootmain+0x6b>
                  :"cc");
}

static inline void stosb(void *desc, int value, int bytes)
{
    asm volatile ("cld; rep stosb"
    7d89:	01 d7                	add    %edx,%edi
    7d8b:	29 d0                	sub    %edx,%eax
    7d8d:	b9 00 00 00 00       	mov    $0x0,%ecx
    7d92:	fc                   	cld    
    7d93:	f3 aa                	rep stos %al,%es:(%edi)
    // check wether the image is a legal elf file.
    if (e->e_magic != ELF_MAGIC)
        return ;

    ph = (struct Elf32_Phdr *)((uchar *)e + e->e_phoff);
    for (int i = 0; i < e->e_phnum; i++, ph++) {
    7d95:	83 c6 01             	add    $0x1,%esi
    7d98:	83 c3 20             	add    $0x20,%ebx
    7d9b:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
    7da2:	39 f0                	cmp    %esi,%eax
    7da4:	7f c7                	jg     7d6d <bootmain+0x43>
        if (ph->p_memsz > ph->p_filesz)
            stosb(pa + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
    }

    kernel_entry = (void (*)(void))(e->e_entry);
    kernel_entry();
    7da6:	ff 15 18 00 01 00    	call   *0x10018
}
    7dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7daf:	5b                   	pop    %ebx
    7db0:	5e                   	pop    %esi
    7db1:	5f                   	pop    %edi
    7db2:	5d                   	pop    %ebp
    7db3:	c3                   	ret    
