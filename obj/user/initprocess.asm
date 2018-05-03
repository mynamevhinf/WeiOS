
initprocess.o:     file format elf32-i386


Disassembly of section .text:

00000000 <start>:
#include <include/syscall.h>
#include <include/trap.h>

.globl start
start:
  movl $init_statement_1, %edx
   0:	ba 94 00 00 00       	mov    $0x94,%edx
  movl $SYS_puts, %eax
   5:	b8 00 00 00 00       	mov    $0x0,%eax
  int $T_SYSCALL
   a:	cd 80                	int    $0x80
  
  movl $init_statement_2, %edx
   c:	ba dc 00 00 00       	mov    $0xdc,%edx
  movl $SYS_puts, %eax
  11:	b8 00 00 00 00       	mov    $0x0,%eax
  int $T_SYSCALL
  16:	cd 80                	int    $0x80

  movl $init_statement_8, %edx
  18:	ba f1 00 00 00       	mov    $0xf1,%edx
  movl $SYS_puts, %eax
  1d:	b8 00 00 00 00       	mov    $0x0,%eax
  int $T_SYSCALL
  22:	cd 80                	int    $0x80
  
  movl $init_statement_3, %edx
  24:	ba 36 01 00 00       	mov    $0x136,%edx
  movl $SYS_puts, %eax
  29:	b8 00 00 00 00       	mov    $0x0,%eax
  int $T_SYSCALL
  2e:	cd 80                	int    $0x80
  
  movl $init_statement_4, %edx
  30:	ba 7a 01 00 00       	mov    $0x17a,%edx
  movl $SYS_puts, %eax
  35:	b8 00 00 00 00       	mov    $0x0,%eax
  int $T_SYSCALL
  3a:	cd 80                	int    $0x80
  
  movl $init_statement_5, %edx
  3c:	ba bc 01 00 00       	mov    $0x1bc,%edx
  movl $SYS_puts, %eax
  41:	b8 00 00 00 00       	mov    $0x0,%eax
  int $T_SYSCALL
  46:	cd 80                	int    $0x80
  
  movl $init_statement_6, %edx
  48:	ba fc 01 00 00       	mov    $0x1fc,%edx
  movl $SYS_puts, %eax
  4d:	b8 00 00 00 00       	mov    $0x0,%eax
  int $T_SYSCALL
  52:	cd 80                	int    $0x80

  movl $init_statement_9, %edx
  54:	ba 25 02 00 00       	mov    $0x225,%edx
  movl $SYS_puts, %eax
  59:	b8 00 00 00 00       	mov    $0x0,%eax
  int $T_SYSCALL
  5e:	cd 80                	int    $0x80
  
  movl $init_statement_7, %edx
  60:	ba 45 02 00 00       	mov    $0x245,%edx
  movl $SYS_puts, %eax
  65:	b8 00 00 00 00       	mov    $0x0,%eax
  int $T_SYSCALL
  6a:	cd 80                	int    $0x80

  movl $argv, %ecx 
  6c:	b9 8c 00 00 00       	mov    $0x8c,%ecx
  movl $init, %edx
  71:	ba 84 00 00 00       	mov    $0x84,%edx
  movl $SYS_exec, %eax
  76:	b8 21 00 00 00       	mov    $0x21,%eax
  int $T_SYSCALL
  7b:	cd 80                	int    $0x80

  movl $SYS_exit, %eax
  7d:	b8 01 00 00 00       	mov    $0x1,%eax
  int $T_SYSCALL
  82:	cd 80                	int    $0x80

00000084 <init>:
  84:	2f                   	das    
  85:	69 6e 69 74 00 00 90 	imul   $0x90000074,0x69(%esi),%ebp

0000008c <argv>:
  8c:	84 00                	test   %al,(%eax)
  8e:	00 00                	add    %al,(%eax)
  90:	00 00                	add    %al,(%eax)
	...

00000094 <init_statement_1>:
  94:	20 20                	and    %ah,(%eax)
  96:	20 2f                	and    %ch,(%edi)
  98:	2a 2a                	sub    (%edx),%ch
  9a:	2a 2a                	sub    (%edx),%ch
  9c:	2a 2a                	sub    (%edx),%ch
  9e:	2a 2a                	sub    (%edx),%ch
  a0:	2a 2a                	sub    (%edx),%ch
  a2:	2a 2a                	sub    (%edx),%ch
  a4:	2a 2a                	sub    (%edx),%ch
  a6:	2a 2a                	sub    (%edx),%ch
  a8:	2a 2a                	sub    (%edx),%ch
  aa:	2a 2a                	sub    (%edx),%ch
  ac:	2a 2a                	sub    (%edx),%ch
  ae:	2a 2a                	sub    (%edx),%ch
  b0:	2a 2a                	sub    (%edx),%ch
  b2:	2a 2a                	sub    (%edx),%ch
  b4:	2a 2a                	sub    (%edx),%ch
  b6:	2a 2a                	sub    (%edx),%ch
  b8:	2a 2a                	sub    (%edx),%ch
  ba:	2a 2a                	sub    (%edx),%ch
  bc:	2a 2a                	sub    (%edx),%ch
  be:	2a 2a                	sub    (%edx),%ch
  c0:	2a 2a                	sub    (%edx),%ch
  c2:	2a 2a                	sub    (%edx),%ch
  c4:	2a 2a                	sub    (%edx),%ch
  c6:	2a 2a                	sub    (%edx),%ch
  c8:	2a 2a                	sub    (%edx),%ch
  ca:	2a 2a                	sub    (%edx),%ch
  cc:	2a 2a                	sub    (%edx),%ch
  ce:	2a 2a                	sub    (%edx),%ch
  d0:	2a 2a                	sub    (%edx),%ch
  d2:	2a 2a                	sub    (%edx),%ch
  d4:	2a 2a                	sub    (%edx),%ch
  d6:	2a 2a                	sub    (%edx),%ch
  d8:	2a 2a                	sub    (%edx),%ch
  da:	0a 00                	or     (%eax),%al

000000dc <init_statement_2>:
  dc:	09 09                	or     %ecx,(%ecx)
  de:	48                   	dec    %eax
  df:	65 6c                	gs insb (%dx),%es:(%edi)
  e1:	6c                   	insb   (%dx),%es:(%edi)
  e2:	6f                   	outsl  %ds:(%esi),(%dx)
  e3:	2c 20                	sub    $0x20,%al
  e5:	73 74                	jae    15b <init_statement_3+0x25>
  e7:	72 61                	jb     14a <init_statement_3+0x14>
  e9:	6e                   	outsb  %ds:(%esi),(%dx)
  ea:	67 65 72 73          	addr16 gs jb 161 <init_statement_3+0x2b>
  ee:	21 0a                	and    %ecx,(%edx)
	...

000000f1 <init_statement_8>:
  f1:	20 20                	and    %ah,(%eax)
  f3:	20 20                	and    %ah,(%eax)
  f5:	20 20                	and    %ah,(%eax)
  f7:	20 20                	and    %ah,(%eax)
  f9:	4d                   	dec    %ebp
  fa:	79 20                	jns    11c <init_statement_8+0x2b>
  fc:	6e                   	outsb  %ds:(%esi),(%dx)
  fd:	61                   	popa   
  fe:	6d                   	insl   (%dx),%es:(%edi)
  ff:	65 20 69 73          	and    %ch,%gs:0x73(%ecx)
 103:	20 57 65             	and    %dl,0x65(%edi)
 106:	69 51 69 6e 67 46 75 	imul   $0x7546676e,0x69(%ecx),%edx
 10d:	2c 20                	sub    $0x20,%al
 10f:	46                   	inc    %esi
 110:	72 6f                	jb     181 <init_statement_4+0x7>
 112:	6d                   	insl   (%dx),%es:(%edi)
 113:	20 55 45             	and    %dl,0x45(%ebp)
 116:	53                   	push   %ebx
 117:	54                   	push   %esp
 118:	43                   	inc    %ebx
 119:	2e 20 52 65          	and    %dl,%cs:0x65(%edx)
 11d:	61                   	popa   
 11e:	63 68 69             	arpl   %bp,0x69(%eax)
 121:	6e                   	outsb  %ds:(%esi),(%dx)
 122:	67 20 68 65          	and    %ch,0x65(%bx,%si)
 126:	72 65                	jb     18d <init_statement_4+0x13>
 128:	20 6d 65             	and    %ch,0x65(%ebp)
 12b:	61                   	popa   
 12c:	6e                   	outsb  %ds:(%esi),(%dx)
 12d:	73 20                	jae    14f <init_statement_3+0x19>
 12f:	74 68                	je     199 <init_statement_4+0x1f>
 131:	61                   	popa   
 132:	74 20                	je     154 <init_statement_3+0x1e>
 134:	0a 00                	or     (%eax),%al

00000136 <init_statement_3>:
 136:	20 20                	and    %ah,(%eax)
 138:	20 20                	and    %ah,(%eax)
 13a:	20 20                	and    %ah,(%eax)
 13c:	20 20                	and    %ah,(%eax)
 13e:	57                   	push   %edi
 13f:	65 69 4f 53 20 72 75 	imul   $0x6e757220,%gs:0x53(%edi),%ecx
 146:	6e 
 147:	20 70 65             	and    %dh,0x65(%eax)
 14a:	72 66                	jb     1b2 <init_statement_4+0x38>
 14c:	65 63 74 6c 79       	arpl   %si,%gs:0x79(%esp,%ebp,2)
 151:	20 73 6f             	and    %dh,0x6f(%ebx)
 154:	20 66 61             	and    %ah,0x61(%esi)
 157:	72 2e                	jb     187 <init_statement_4+0xd>
 159:	20 49 66             	and    %cl,0x66(%ecx)
 15c:	20 79 6f             	and    %bh,0x6f(%ecx)
 15f:	75 20                	jne    181 <init_statement_4+0x7>
 161:	68 61 76 65 20       	push   $0x20657661
 166:	66 6f                	outsw  %ds:(%esi),(%dx)
 168:	75 6e                	jne    1d8 <init_statement_5+0x1c>
 16a:	64 20 61 6e          	and    %ah,%fs:0x6e(%ecx)
 16e:	79 20                	jns    190 <init_statement_4+0x16>
 170:	62 75 67             	bound  %esi,0x67(%ebp)
 173:	73 20                	jae    195 <init_statement_4+0x1b>
 175:	69                   	.byte 0x69
 176:	6e                   	outsb  %ds:(%esi),(%dx)
 177:	20 0a                	and    %cl,(%edx)
	...

0000017a <init_statement_4>:
 17a:	20 20                	and    %ah,(%eax)
 17c:	20 20                	and    %ah,(%eax)
 17e:	20 20                	and    %ah,(%eax)
 180:	20 20                	and    %ah,(%eax)
 182:	74 68                	je     1ec <init_statement_5+0x30>
 184:	65 20 6b 65          	and    %ch,%gs:0x65(%ebx)
 188:	72 6e                	jb     1f8 <init_statement_5+0x3c>
 18a:	65 6c                	gs insb (%dx),%es:(%edi)
 18c:	2c 20                	sub    $0x20,%al
 18e:	70 6c                	jo     1fc <init_statement_6>
 190:	65 61                	gs popa 
 192:	73 65                	jae    1f9 <init_statement_5+0x3d>
 194:	20 73 65             	and    %dh,0x65(%ebx)
 197:	6e                   	outsb  %ds:(%esi),(%dx)
 198:	64 20 61 6e          	and    %ah,%fs:0x6e(%ecx)
 19c:	20 65 6d             	and    %ah,0x6d(%ebp)
 19f:	61                   	popa   
 1a0:	69 6c 20 74 6f 20 76 	imul   $0x6876206f,0x74(%eax,%eiz,1),%ebp
 1a7:	68 
 1a8:	69 6e 66 32 30 34 37 	imul   $0x37343032,0x66(%esi),%ebp
 1af:	40                   	inc    %eax
 1b0:	67 6d                	insl   (%dx),%es:(%di)
 1b2:	61                   	popa   
 1b3:	69 6c 2e 63 6f 6d 2e 	imul   $0xa2e6d6f,0x63(%esi,%ebp,1),%ebp
 1ba:	0a 
	...

000001bc <init_statement_5>:
 1bc:	09 09                	or     %ecx,(%ecx)
 1be:	6f                   	outsl  %ds:(%esi),(%dx)
 1bf:	74 68                	je     229 <init_statement_9+0x4>
 1c1:	65 72 77             	gs jb  23b <init_statement_9+0x16>
 1c4:	69 73 65 2c 20 63 6f 	imul   $0x6f63202c,0x65(%ebx),%esi
 1cb:	6e                   	outsb  %ds:(%esi),(%dx)
 1cc:	74 61                	je     22f <init_statement_9+0xa>
 1ce:	63 74 20 74          	arpl   %si,0x74(%eax,%eiz,1)
 1d2:	6f                   	outsl  %ds:(%esi),(%dx)
 1d3:	20 6d 65             	and    %ch,0x65(%ebp)
 1d6:	20 77 69             	and    %dh,0x69(%edi)
 1d9:	74 68                	je     243 <init_statement_9+0x1e>
 1db:	20 6d 79             	and    %ch,0x79(%ebp)
 1de:	20 77 65             	and    %dh,0x65(%edi)
 1e1:	63 68 61             	arpl   %bp,0x61(%eax)
 1e4:	74 20                	je     206 <init_statement_6+0xa>
 1e6:	6e                   	outsb  %ds:(%esi),(%dx)
 1e7:	75 6d                	jne    256 <init_statement_7+0x11>
 1e9:	62 65 72             	bound  %esp,0x72(%ebp)
 1ec:	3a 20                	cmp    (%eax),%ah
 1ee:	61                   	popa   
 1ef:	6f                   	outsl  %ds:(%esi),(%dx)
 1f0:	65 77 71             	gs ja  264 <init_statement_7+0x1f>
 1f3:	66 31 39             	xor    %di,(%ecx)
 1f6:	39 37                	cmp    %esi,(%edi)
 1f8:	2e 20 0a             	and    %cl,%cs:(%edx)
	...

000001fc <init_statement_6>:
 1fc:	20 20                	and    %ah,(%eax)
 1fe:	20 20                	and    %ah,(%eax)
 200:	20 20                	and    %ah,(%eax)
 202:	20 20                	and    %ah,(%eax)
 204:	49                   	dec    %ecx
 205:	27                   	daa    
 206:	6c                   	insb   (%dx),%es:(%edi)
 207:	6c                   	insb   (%dx),%es:(%edi)
 208:	20 61 70             	and    %ah,0x70(%ecx)
 20b:	70 72                	jo     27f <init_statement_7+0x3a>
 20d:	65 63 69 61          	arpl   %bp,%gs:0x61(%ecx)
 211:	74 65                	je     278 <init_statement_7+0x33>
 213:	20 69 74             	and    %ch,0x74(%ecx)
 216:	20 76 65             	and    %dh,0x65(%esi)
 219:	72 79                	jb     294 <init_statement_7+0x4f>
 21b:	20 6d 75             	and    %ch,0x75(%ebp)
 21e:	63 68 21             	arpl   %bp,0x21(%eax)
 221:	21 21                	and    %esp,(%ecx)
 223:	0a 00                	or     (%eax),%al

00000225 <init_statement_9>:
 225:	20 20                	and    %ah,(%eax)
 227:	20 20                	and    %ah,(%eax)
 229:	20 20                	and    %ah,(%eax)
 22b:	20 20                	and    %ah,(%eax)
 22d:	46                   	inc    %esi
 22e:	72 69                	jb     299 <init_statement_7+0x54>
 230:	64 61                	fs popa 
 232:	79 2c                	jns    260 <init_statement_7+0x1b>
 234:	20 32                	and    %dh,(%edx)
 236:	30 20                	xor    %ah,(%eax)
 238:	41                   	inc    %ecx
 239:	70 72                	jo     2ad <init_statement_7+0x68>
 23b:	69 6c 20 32 30 31 38 	imul   $0x2e383130,0x32(%eax,%eiz,1),%ebp
 242:	2e 
 243:	0a 00                	or     (%eax),%al

00000245 <init_statement_7>:
 245:	20 20                	and    %ah,(%eax)
 247:	20 2a                	and    %ch,(%edx)
 249:	2a 2a                	sub    (%edx),%ch
 24b:	2a 2a                	sub    (%edx),%ch
 24d:	2a 2a                	sub    (%edx),%ch
 24f:	2a 2a                	sub    (%edx),%ch
 251:	2a 2a                	sub    (%edx),%ch
 253:	2a 2a                	sub    (%edx),%ch
 255:	2a 2a                	sub    (%edx),%ch
 257:	2a 2a                	sub    (%edx),%ch
 259:	2a 2a                	sub    (%edx),%ch
 25b:	2a 2a                	sub    (%edx),%ch
 25d:	2a 2a                	sub    (%edx),%ch
 25f:	2a 2a                	sub    (%edx),%ch
 261:	2a 2a                	sub    (%edx),%ch
 263:	2a 2a                	sub    (%edx),%ch
 265:	2a 2a                	sub    (%edx),%ch
 267:	2a 2a                	sub    (%edx),%ch
 269:	2a 2a                	sub    (%edx),%ch
 26b:	2a 2a                	sub    (%edx),%ch
 26d:	2a 2a                	sub    (%edx),%ch
 26f:	2a 2a                	sub    (%edx),%ch
 271:	2a 2a                	sub    (%edx),%ch
 273:	2a 2a                	sub    (%edx),%ch
 275:	2a 2a                	sub    (%edx),%ch
 277:	2a 2a                	sub    (%edx),%ch
 279:	2a 2a                	sub    (%edx),%ch
 27b:	2a 2a                	sub    (%edx),%ch
 27d:	2a 2a                	sub    (%edx),%ch
 27f:	2a 2a                	sub    (%edx),%ch
 281:	2a 2a                	sub    (%edx),%ch
 283:	2a 2a                	sub    (%edx),%ch
 285:	2a 2a                	sub    (%edx),%ch
 287:	2a 2a                	sub    (%edx),%ch
 289:	2a 2f                	sub    (%edi),%ch
 28b:	0a 00                	or     (%eax),%al
