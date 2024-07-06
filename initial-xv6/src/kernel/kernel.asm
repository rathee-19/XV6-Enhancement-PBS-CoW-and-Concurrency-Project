
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	be813103          	ld	sp,-1048(sp) # 80008be8 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	bf070713          	addi	a4,a4,-1040 # 80008c40 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	5ce78793          	addi	a5,a5,1486 # 80006630 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdba4ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	f0c78793          	addi	a5,a5,-244 # 80000fb8 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for (i = 0; i < n; i++)
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
  {
    char c;
    if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	8d8080e7          	jalr	-1832(ra) # 80002a02 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	bf650513          	addi	a0,a0,-1034 # 80010d80 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	b84080e7          	jalr	-1148(ra) # 80000d16 <acquire>
  while (n > 0)
  {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	be648493          	addi	s1,s1,-1050 # 80010d80 <cons>
      if (killed(myproc()))
      {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	c7690913          	addi	s2,s2,-906 # 80010e18 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if (c == C('D'))
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if (c == '\n')
    800001ae:	4ca9                	li	s9,10
  while (n > 0)
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while (cons.r == cons.w)
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if (killed(myproc()))
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	970080e7          	jalr	-1680(ra) # 80001b30 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	684080e7          	jalr	1668(ra) # 8000284c <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	1ea080e7          	jalr	490(ra) # 800023c0 <sleep>
    while (cons.r == cons.w)
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if (c == C('D'))
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	79a080e7          	jalr	1946(ra) # 800029ac <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if (c == '\n')
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	b5a50513          	addi	a0,a0,-1190 # 80010d80 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	b9c080e7          	jalr	-1124(ra) # 80000dca <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	b4450513          	addi	a0,a0,-1212 # 80010d80 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	b86080e7          	jalr	-1146(ra) # 80000dca <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if (n < target)
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	baf72323          	sw	a5,-1114(a4) # 80010e18 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if (c == BACKSPACE)
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    uartputc_sync(' ');
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	ab450513          	addi	a0,a0,-1356 # 80010d80 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	a42080e7          	jalr	-1470(ra) # 80000d16 <acquire>

  switch (c)
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  {
  case C('P'): // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	766080e7          	jalr	1894(ra) # 80002a58 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	a8650513          	addi	a0,a0,-1402 # 80010d80 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	ac8080e7          	jalr	-1336(ra) # 80000dca <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch (c)
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	a6270713          	addi	a4,a4,-1438 # 80010d80 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	a3878793          	addi	a5,a5,-1480 # 80010d80 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	aa27a783          	lw	a5,-1374(a5) # 80010e18 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	9f670713          	addi	a4,a4,-1546 # 80010d80 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	9e648493          	addi	s1,s1,-1562 # 80010d80 <cons>
    while (cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while (cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if (cons.e != cons.w)
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	9aa70713          	addi	a4,a4,-1622 # 80010d80 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	a2f72a23          	sw	a5,-1484(a4) # 80010e20 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	96e78793          	addi	a5,a5,-1682 # 80010d80 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	9ec7a323          	sw	a2,-1562(a5) # 80010e1c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	9da50513          	addi	a0,a0,-1574 # 80010e18 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	12e080e7          	jalr	302(ra) # 80002574 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00011517          	auipc	a0,0x11
    80000464:	92050513          	addi	a0,a0,-1760 # 80010d80 <cons>
    80000468:	00001097          	auipc	ra,0x1
    8000046c:	81e080e7          	jalr	-2018(ra) # 80000c86 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00243797          	auipc	a5,0x243
    8000047c:	cf078793          	addi	a5,a5,-784 # 80243168 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00011797          	auipc	a5,0x11
    80000550:	8e07aa23          	sw	zero,-1804(a5) # 80010e40 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b9a50513          	addi	a0,a0,-1126 # 80008108 <digits+0xc8>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	68f72023          	sw	a5,1664(a4) # 80008c00 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00011d97          	auipc	s11,0x11
    800005c0:	884dad83          	lw	s11,-1916(s11) # 80010e40 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00011517          	auipc	a0,0x11
    800005fe:	82e50513          	addi	a0,a0,-2002 # 80010e28 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	714080e7          	jalr	1812(ra) # 80000d16 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	6d050513          	addi	a0,a0,1744 # 80010e28 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	66a080e7          	jalr	1642(ra) # 80000dca <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	6b448493          	addi	s1,s1,1716 # 80010e28 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	500080e7          	jalr	1280(ra) # 80000c86 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	67450513          	addi	a0,a0,1652 # 80010e48 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	4aa080e7          	jalr	1194(ra) # 80000c86 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	4d2080e7          	jalr	1234(ra) # 80000cca <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	4007a783          	lw	a5,1024(a5) # 80008c00 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	544080e7          	jalr	1348(ra) # 80000d6a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	3d07b783          	ld	a5,976(a5) # 80008c08 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	3d073703          	ld	a4,976(a4) # 80008c10 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	5e6a0a13          	addi	s4,s4,1510 # 80010e48 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	39e48493          	addi	s1,s1,926 # 80008c08 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	39e98993          	addi	s3,s3,926 # 80008c10 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	ce0080e7          	jalr	-800(ra) # 80002574 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	57850513          	addi	a0,a0,1400 # 80010e48 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	43e080e7          	jalr	1086(ra) # 80000d16 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	3207a783          	lw	a5,800(a5) # 80008c00 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	32673703          	ld	a4,806(a4) # 80008c10 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	3167b783          	ld	a5,790(a5) # 80008c08 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	54a98993          	addi	s3,s3,1354 # 80010e48 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	30248493          	addi	s1,s1,770 # 80008c08 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	30290913          	addi	s2,s2,770 # 80008c10 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	aa2080e7          	jalr	-1374(ra) # 800023c0 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	51448493          	addi	s1,s1,1300 # 80010e48 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	2ce7b423          	sd	a4,712(a5) # 80008c10 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	470080e7          	jalr	1136(ra) # 80000dca <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	48e48493          	addi	s1,s1,1166 # 80010e48 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	352080e7          	jalr	850(ra) # 80000d16 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	3f4080e7          	jalr	1012(ra) # 80000dca <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <incref>:
    refcount[(uint64)p/4096]=1;
    kfree(p);
  }
}

void incref(uint64 pa){
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
    800009f4:	892a                	mv	s2,a0
  int pagenumber=pa/PGSIZE;
    800009f6:	00c55493          	srli	s1,a0,0xc
  acquire(&kmem.lock);
    800009fa:	00010517          	auipc	a0,0x10
    800009fe:	48650513          	addi	a0,a0,1158 # 80010e80 <kmem>
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	314080e7          	jalr	788(ra) # 80000d16 <acquire>
  if(pa>=PHYSTOP || refcount[pagenumber]<1)
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f97363          	bgeu	s2,a5,80000a54 <incref+0x6c>
    80000a12:	2481                	sext.w	s1,s1
    80000a14:	00249713          	slli	a4,s1,0x2
    80000a18:	00010797          	auipc	a5,0x10
    80000a1c:	48878793          	addi	a5,a5,1160 # 80010ea0 <refcount>
    80000a20:	97ba                	add	a5,a5,a4
    80000a22:	439c                	lw	a5,0(a5)
    80000a24:	02f05863          	blez	a5,80000a54 <incref+0x6c>
    panic("incref");
  refcount[pagenumber]+=1; 
    80000a28:	048a                	slli	s1,s1,0x2
    80000a2a:	00010717          	auipc	a4,0x10
    80000a2e:	47670713          	addi	a4,a4,1142 # 80010ea0 <refcount>
    80000a32:	9726                	add	a4,a4,s1
    80000a34:	2785                	addiw	a5,a5,1
    80000a36:	c31c                	sw	a5,0(a4)
  release(&kmem.lock);
    80000a38:	00010517          	auipc	a0,0x10
    80000a3c:	44850513          	addi	a0,a0,1096 # 80010e80 <kmem>
    80000a40:	00000097          	auipc	ra,0x0
    80000a44:	38a080e7          	jalr	906(ra) # 80000dca <release>
}
    80000a48:	60e2                	ld	ra,24(sp)
    80000a4a:	6442                	ld	s0,16(sp)
    80000a4c:	64a2                	ld	s1,8(sp)
    80000a4e:	6902                	ld	s2,0(sp)
    80000a50:	6105                	addi	sp,sp,32
    80000a52:	8082                	ret
    panic("incref");
    80000a54:	00007517          	auipc	a0,0x7
    80000a58:	60c50513          	addi	a0,a0,1548 # 80008060 <digits+0x20>
    80000a5c:	00000097          	auipc	ra,0x0
    80000a60:	ae4080e7          	jalr	-1308(ra) # 80000540 <panic>

0000000080000a64 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a64:	1101                	addi	sp,sp,-32
    80000a66:	ec06                	sd	ra,24(sp)
    80000a68:	e822                	sd	s0,16(sp)
    80000a6a:	e426                	sd	s1,8(sp)
    80000a6c:	e04a                	sd	s2,0(sp)
    80000a6e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a70:	03451793          	slli	a5,a0,0x34
    80000a74:	ebbd                	bnez	a5,80000aea <kfree+0x86>
    80000a76:	84aa                	mv	s1,a0
    80000a78:	00244797          	auipc	a5,0x244
    80000a7c:	88878793          	addi	a5,a5,-1912 # 80244300 <end>
    80000a80:	06f56563          	bltu	a0,a5,80000aea <kfree+0x86>
    80000a84:	47c5                	li	a5,17
    80000a86:	07ee                	slli	a5,a5,0x1b
    80000a88:	06f57163          	bgeu	a0,a5,80000aea <kfree+0x86>
    panic("kfree");

  // Need to acquire lock for decrementing refs
  acquire(&kmem.lock);
    80000a8c:	00010517          	auipc	a0,0x10
    80000a90:	3f450513          	addi	a0,a0,1012 # 80010e80 <kmem>
    80000a94:	00000097          	auipc	ra,0x0
    80000a98:	282080e7          	jalr	642(ra) # 80000d16 <acquire>
  int pagenumber=(uint64)pa/PGSIZE;
    80000a9c:	00c4d793          	srli	a5,s1,0xc
    80000aa0:	2781                	sext.w	a5,a5
  if(refcount[pagenumber]<1)
    80000aa2:	00279693          	slli	a3,a5,0x2
    80000aa6:	00010717          	auipc	a4,0x10
    80000aaa:	3fa70713          	addi	a4,a4,1018 # 80010ea0 <refcount>
    80000aae:	9736                	add	a4,a4,a3
    80000ab0:	4318                	lw	a4,0(a4)
    80000ab2:	04e05463          	blez	a4,80000afa <kfree+0x96>
    panic("Kfree ref");
  refcount[pagenumber]-=1;
    80000ab6:	377d                	addiw	a4,a4,-1
    80000ab8:	0007091b          	sext.w	s2,a4
    80000abc:	078a                	slli	a5,a5,0x2
    80000abe:	00010697          	auipc	a3,0x10
    80000ac2:	3e268693          	addi	a3,a3,994 # 80010ea0 <refcount>
    80000ac6:	97b6                	add	a5,a5,a3
    80000ac8:	c398                	sw	a4,0(a5)
  int tmp=refcount[pagenumber];
  release(&kmem.lock);
    80000aca:	00010517          	auipc	a0,0x10
    80000ace:	3b650513          	addi	a0,a0,950 # 80010e80 <kmem>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	2f8080e7          	jalr	760(ra) # 80000dca <release>

  if(tmp>0) // NO need to free the page
    80000ada:	03205863          	blez	s2,80000b0a <kfree+0xa6>

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
    80000ade:	60e2                	ld	ra,24(sp)
    80000ae0:	6442                	ld	s0,16(sp)
    80000ae2:	64a2                	ld	s1,8(sp)
    80000ae4:	6902                	ld	s2,0(sp)
    80000ae6:	6105                	addi	sp,sp,32
    80000ae8:	8082                	ret
    panic("kfree");
    80000aea:	00007517          	auipc	a0,0x7
    80000aee:	57e50513          	addi	a0,a0,1406 # 80008068 <digits+0x28>
    80000af2:	00000097          	auipc	ra,0x0
    80000af6:	a4e080e7          	jalr	-1458(ra) # 80000540 <panic>
    panic("Kfree ref");
    80000afa:	00007517          	auipc	a0,0x7
    80000afe:	57650513          	addi	a0,a0,1398 # 80008070 <digits+0x30>
    80000b02:	00000097          	auipc	ra,0x0
    80000b06:	a3e080e7          	jalr	-1474(ra) # 80000540 <panic>
  memset(pa, 1, PGSIZE);
    80000b0a:	6605                	lui	a2,0x1
    80000b0c:	4585                	li	a1,1
    80000b0e:	8526                	mv	a0,s1
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	302080e7          	jalr	770(ra) # 80000e12 <memset>
  acquire(&kmem.lock);
    80000b18:	00010917          	auipc	s2,0x10
    80000b1c:	36890913          	addi	s2,s2,872 # 80010e80 <kmem>
    80000b20:	854a                	mv	a0,s2
    80000b22:	00000097          	auipc	ra,0x0
    80000b26:	1f4080e7          	jalr	500(ra) # 80000d16 <acquire>
  r->next = kmem.freelist;
    80000b2a:	01893783          	ld	a5,24(s2)
    80000b2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000b30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000b34:	854a                	mv	a0,s2
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	294080e7          	jalr	660(ra) # 80000dca <release>
    80000b3e:	b745                	j	80000ade <kfree+0x7a>

0000000080000b40 <freerange>:
{
    80000b40:	7139                	addi	sp,sp,-64
    80000b42:	fc06                	sd	ra,56(sp)
    80000b44:	f822                	sd	s0,48(sp)
    80000b46:	f426                	sd	s1,40(sp)
    80000b48:	f04a                	sd	s2,32(sp)
    80000b4a:	ec4e                	sd	s3,24(sp)
    80000b4c:	e852                	sd	s4,16(sp)
    80000b4e:	e456                	sd	s5,8(sp)
    80000b50:	e05a                	sd	s6,0(sp)
    80000b52:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b54:	6785                	lui	a5,0x1
    80000b56:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b5a:	953a                	add	a0,a0,a4
    80000b5c:	777d                	lui	a4,0xfffff
    80000b5e:	00e574b3          	and	s1,a0,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b62:	97a6                	add	a5,a5,s1
    80000b64:	02f5ea63          	bltu	a1,a5,80000b98 <freerange+0x58>
    80000b68:	892e                	mv	s2,a1
    refcount[(uint64)p/4096]=1;
    80000b6a:	00010b17          	auipc	s6,0x10
    80000b6e:	336b0b13          	addi	s6,s6,822 # 80010ea0 <refcount>
    80000b72:	4a85                	li	s5,1
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b74:	6a05                	lui	s4,0x1
    80000b76:	6989                	lui	s3,0x2
    refcount[(uint64)p/4096]=1;
    80000b78:	00c4d793          	srli	a5,s1,0xc
    80000b7c:	078a                	slli	a5,a5,0x2
    80000b7e:	97da                	add	a5,a5,s6
    80000b80:	0157a023          	sw	s5,0(a5)
    kfree(p);
    80000b84:	8526                	mv	a0,s1
    80000b86:	00000097          	auipc	ra,0x0
    80000b8a:	ede080e7          	jalr	-290(ra) # 80000a64 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b8e:	87a6                	mv	a5,s1
    80000b90:	94d2                	add	s1,s1,s4
    80000b92:	97ce                	add	a5,a5,s3
    80000b94:	fef972e3          	bgeu	s2,a5,80000b78 <freerange+0x38>
}
    80000b98:	70e2                	ld	ra,56(sp)
    80000b9a:	7442                	ld	s0,48(sp)
    80000b9c:	74a2                	ld	s1,40(sp)
    80000b9e:	7902                	ld	s2,32(sp)
    80000ba0:	69e2                	ld	s3,24(sp)
    80000ba2:	6a42                	ld	s4,16(sp)
    80000ba4:	6aa2                	ld	s5,8(sp)
    80000ba6:	6b02                	ld	s6,0(sp)
    80000ba8:	6121                	addi	sp,sp,64
    80000baa:	8082                	ret

0000000080000bac <kinit>:
{
    80000bac:	1141                	addi	sp,sp,-16
    80000bae:	e406                	sd	ra,8(sp)
    80000bb0:	e022                	sd	s0,0(sp)
    80000bb2:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000bb4:	00007597          	auipc	a1,0x7
    80000bb8:	4cc58593          	addi	a1,a1,1228 # 80008080 <digits+0x40>
    80000bbc:	00010517          	auipc	a0,0x10
    80000bc0:	2c450513          	addi	a0,a0,708 # 80010e80 <kmem>
    80000bc4:	00000097          	auipc	ra,0x0
    80000bc8:	0c2080e7          	jalr	194(ra) # 80000c86 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000bcc:	45c5                	li	a1,17
    80000bce:	05ee                	slli	a1,a1,0x1b
    80000bd0:	00243517          	auipc	a0,0x243
    80000bd4:	73050513          	addi	a0,a0,1840 # 80244300 <end>
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f68080e7          	jalr	-152(ra) # 80000b40 <freerange>
}
    80000be0:	60a2                	ld	ra,8(sp)
    80000be2:	6402                	ld	s0,0(sp)
    80000be4:	0141                	addi	sp,sp,16
    80000be6:	8082                	ret

0000000080000be8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000be8:	1101                	addi	sp,sp,-32
    80000bea:	ec06                	sd	ra,24(sp)
    80000bec:	e822                	sd	s0,16(sp)
    80000bee:	e426                	sd	s1,8(sp)
    80000bf0:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000bf2:	00010497          	auipc	s1,0x10
    80000bf6:	28e48493          	addi	s1,s1,654 # 80010e80 <kmem>
    80000bfa:	8526                	mv	a0,s1
    80000bfc:	00000097          	auipc	ra,0x0
    80000c00:	11a080e7          	jalr	282(ra) # 80000d16 <acquire>
  r = kmem.freelist;
    80000c04:	6c84                	ld	s1,24(s1)
  if(r){
    80000c06:	c4bd                	beqz	s1,80000c74 <kalloc+0x8c>
    kmem.freelist = r->next;
    80000c08:	609c                	ld	a5,0(s1)
    80000c0a:	00010717          	auipc	a4,0x10
    80000c0e:	28f73723          	sd	a5,654(a4) # 80010e98 <kmem+0x18>
    int pagenumber = (uint64)r/PGSIZE; // finding page number
    80000c12:	00c4d793          	srli	a5,s1,0xc
    80000c16:	2781                	sext.w	a5,a5
    if(refcount[pagenumber]!=0)
    80000c18:	00279693          	slli	a3,a5,0x2
    80000c1c:	00010717          	auipc	a4,0x10
    80000c20:	28470713          	addi	a4,a4,644 # 80010ea0 <refcount>
    80000c24:	9736                	add	a4,a4,a3
    80000c26:	4318                	lw	a4,0(a4)
    80000c28:	ef15                	bnez	a4,80000c64 <kalloc+0x7c>
      panic("HOW is a new page already referenced");
    refcount[pagenumber]=1; // initialising ref to 1
    80000c2a:	078a                	slli	a5,a5,0x2
    80000c2c:	00010717          	auipc	a4,0x10
    80000c30:	27470713          	addi	a4,a4,628 # 80010ea0 <refcount>
    80000c34:	97ba                	add	a5,a5,a4
    80000c36:	4705                	li	a4,1
    80000c38:	c398                	sw	a4,0(a5)
  }
  release(&kmem.lock);
    80000c3a:	00010517          	auipc	a0,0x10
    80000c3e:	24650513          	addi	a0,a0,582 # 80010e80 <kmem>
    80000c42:	00000097          	auipc	ra,0x0
    80000c46:	188080e7          	jalr	392(ra) # 80000dca <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000c4a:	6605                	lui	a2,0x1
    80000c4c:	4595                	li	a1,5
    80000c4e:	8526                	mv	a0,s1
    80000c50:	00000097          	auipc	ra,0x0
    80000c54:	1c2080e7          	jalr	450(ra) # 80000e12 <memset>
  return (void*)r;
}
    80000c58:	8526                	mv	a0,s1
    80000c5a:	60e2                	ld	ra,24(sp)
    80000c5c:	6442                	ld	s0,16(sp)
    80000c5e:	64a2                	ld	s1,8(sp)
    80000c60:	6105                	addi	sp,sp,32
    80000c62:	8082                	ret
      panic("HOW is a new page already referenced");
    80000c64:	00007517          	auipc	a0,0x7
    80000c68:	42450513          	addi	a0,a0,1060 # 80008088 <digits+0x48>
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	8d4080e7          	jalr	-1836(ra) # 80000540 <panic>
  release(&kmem.lock);
    80000c74:	00010517          	auipc	a0,0x10
    80000c78:	20c50513          	addi	a0,a0,524 # 80010e80 <kmem>
    80000c7c:	00000097          	auipc	ra,0x0
    80000c80:	14e080e7          	jalr	334(ra) # 80000dca <release>
  if(r)
    80000c84:	bfd1                	j	80000c58 <kalloc+0x70>

0000000080000c86 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c86:	1141                	addi	sp,sp,-16
    80000c88:	e422                	sd	s0,8(sp)
    80000c8a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c8c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c8e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c92:	00053823          	sd	zero,16(a0)
}
    80000c96:	6422                	ld	s0,8(sp)
    80000c98:	0141                	addi	sp,sp,16
    80000c9a:	8082                	ret

0000000080000c9c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c9c:	411c                	lw	a5,0(a0)
    80000c9e:	e399                	bnez	a5,80000ca4 <holding+0x8>
    80000ca0:	4501                	li	a0,0
  return r;
}
    80000ca2:	8082                	ret
{
    80000ca4:	1101                	addi	sp,sp,-32
    80000ca6:	ec06                	sd	ra,24(sp)
    80000ca8:	e822                	sd	s0,16(sp)
    80000caa:	e426                	sd	s1,8(sp)
    80000cac:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000cae:	6904                	ld	s1,16(a0)
    80000cb0:	00001097          	auipc	ra,0x1
    80000cb4:	e64080e7          	jalr	-412(ra) # 80001b14 <mycpu>
    80000cb8:	40a48533          	sub	a0,s1,a0
    80000cbc:	00153513          	seqz	a0,a0
}
    80000cc0:	60e2                	ld	ra,24(sp)
    80000cc2:	6442                	ld	s0,16(sp)
    80000cc4:	64a2                	ld	s1,8(sp)
    80000cc6:	6105                	addi	sp,sp,32
    80000cc8:	8082                	ret

0000000080000cca <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000cca:	1101                	addi	sp,sp,-32
    80000ccc:	ec06                	sd	ra,24(sp)
    80000cce:	e822                	sd	s0,16(sp)
    80000cd0:	e426                	sd	s1,8(sp)
    80000cd2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd4:	100024f3          	csrr	s1,sstatus
    80000cd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cdc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cde:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ce2:	00001097          	auipc	ra,0x1
    80000ce6:	e32080e7          	jalr	-462(ra) # 80001b14 <mycpu>
    80000cea:	5d3c                	lw	a5,120(a0)
    80000cec:	cf89                	beqz	a5,80000d06 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000cee:	00001097          	auipc	ra,0x1
    80000cf2:	e26080e7          	jalr	-474(ra) # 80001b14 <mycpu>
    80000cf6:	5d3c                	lw	a5,120(a0)
    80000cf8:	2785                	addiw	a5,a5,1
    80000cfa:	dd3c                	sw	a5,120(a0)
}
    80000cfc:	60e2                	ld	ra,24(sp)
    80000cfe:	6442                	ld	s0,16(sp)
    80000d00:	64a2                	ld	s1,8(sp)
    80000d02:	6105                	addi	sp,sp,32
    80000d04:	8082                	ret
    mycpu()->intena = old;
    80000d06:	00001097          	auipc	ra,0x1
    80000d0a:	e0e080e7          	jalr	-498(ra) # 80001b14 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d0e:	8085                	srli	s1,s1,0x1
    80000d10:	8885                	andi	s1,s1,1
    80000d12:	dd64                	sw	s1,124(a0)
    80000d14:	bfe9                	j	80000cee <push_off+0x24>

0000000080000d16 <acquire>:
{
    80000d16:	1101                	addi	sp,sp,-32
    80000d18:	ec06                	sd	ra,24(sp)
    80000d1a:	e822                	sd	s0,16(sp)
    80000d1c:	e426                	sd	s1,8(sp)
    80000d1e:	1000                	addi	s0,sp,32
    80000d20:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d22:	00000097          	auipc	ra,0x0
    80000d26:	fa8080e7          	jalr	-88(ra) # 80000cca <push_off>
  if(holding(lk))
    80000d2a:	8526                	mv	a0,s1
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	f70080e7          	jalr	-144(ra) # 80000c9c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d34:	4705                	li	a4,1
  if(holding(lk))
    80000d36:	e115                	bnez	a0,80000d5a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d38:	87ba                	mv	a5,a4
    80000d3a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d3e:	2781                	sext.w	a5,a5
    80000d40:	ffe5                	bnez	a5,80000d38 <acquire+0x22>
  __sync_synchronize();
    80000d42:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d46:	00001097          	auipc	ra,0x1
    80000d4a:	dce080e7          	jalr	-562(ra) # 80001b14 <mycpu>
    80000d4e:	e888                	sd	a0,16(s1)
}
    80000d50:	60e2                	ld	ra,24(sp)
    80000d52:	6442                	ld	s0,16(sp)
    80000d54:	64a2                	ld	s1,8(sp)
    80000d56:	6105                	addi	sp,sp,32
    80000d58:	8082                	ret
    panic("acquire");
    80000d5a:	00007517          	auipc	a0,0x7
    80000d5e:	35650513          	addi	a0,a0,854 # 800080b0 <digits+0x70>
    80000d62:	fffff097          	auipc	ra,0xfffff
    80000d66:	7de080e7          	jalr	2014(ra) # 80000540 <panic>

0000000080000d6a <pop_off>:

void
pop_off(void)
{
    80000d6a:	1141                	addi	sp,sp,-16
    80000d6c:	e406                	sd	ra,8(sp)
    80000d6e:	e022                	sd	s0,0(sp)
    80000d70:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d72:	00001097          	auipc	ra,0x1
    80000d76:	da2080e7          	jalr	-606(ra) # 80001b14 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d7a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d7e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d80:	e78d                	bnez	a5,80000daa <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d82:	5d3c                	lw	a5,120(a0)
    80000d84:	02f05b63          	blez	a5,80000dba <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d88:	37fd                	addiw	a5,a5,-1
    80000d8a:	0007871b          	sext.w	a4,a5
    80000d8e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d90:	eb09                	bnez	a4,80000da2 <pop_off+0x38>
    80000d92:	5d7c                	lw	a5,124(a0)
    80000d94:	c799                	beqz	a5,80000da2 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d96:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d9a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d9e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000da2:	60a2                	ld	ra,8(sp)
    80000da4:	6402                	ld	s0,0(sp)
    80000da6:	0141                	addi	sp,sp,16
    80000da8:	8082                	ret
    panic("pop_off - interruptible");
    80000daa:	00007517          	auipc	a0,0x7
    80000dae:	30e50513          	addi	a0,a0,782 # 800080b8 <digits+0x78>
    80000db2:	fffff097          	auipc	ra,0xfffff
    80000db6:	78e080e7          	jalr	1934(ra) # 80000540 <panic>
    panic("pop_off");
    80000dba:	00007517          	auipc	a0,0x7
    80000dbe:	31650513          	addi	a0,a0,790 # 800080d0 <digits+0x90>
    80000dc2:	fffff097          	auipc	ra,0xfffff
    80000dc6:	77e080e7          	jalr	1918(ra) # 80000540 <panic>

0000000080000dca <release>:
{
    80000dca:	1101                	addi	sp,sp,-32
    80000dcc:	ec06                	sd	ra,24(sp)
    80000dce:	e822                	sd	s0,16(sp)
    80000dd0:	e426                	sd	s1,8(sp)
    80000dd2:	1000                	addi	s0,sp,32
    80000dd4:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000dd6:	00000097          	auipc	ra,0x0
    80000dda:	ec6080e7          	jalr	-314(ra) # 80000c9c <holding>
    80000dde:	c115                	beqz	a0,80000e02 <release+0x38>
  lk->cpu = 0;
    80000de0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000de4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000de8:	0f50000f          	fence	iorw,ow
    80000dec:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000df0:	00000097          	auipc	ra,0x0
    80000df4:	f7a080e7          	jalr	-134(ra) # 80000d6a <pop_off>
}
    80000df8:	60e2                	ld	ra,24(sp)
    80000dfa:	6442                	ld	s0,16(sp)
    80000dfc:	64a2                	ld	s1,8(sp)
    80000dfe:	6105                	addi	sp,sp,32
    80000e00:	8082                	ret
    panic("release");
    80000e02:	00007517          	auipc	a0,0x7
    80000e06:	2d650513          	addi	a0,a0,726 # 800080d8 <digits+0x98>
    80000e0a:	fffff097          	auipc	ra,0xfffff
    80000e0e:	736080e7          	jalr	1846(ra) # 80000540 <panic>

0000000080000e12 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e18:	ca19                	beqz	a2,80000e2e <memset+0x1c>
    80000e1a:	87aa                	mv	a5,a0
    80000e1c:	1602                	slli	a2,a2,0x20
    80000e1e:	9201                	srli	a2,a2,0x20
    80000e20:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e24:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e28:	0785                	addi	a5,a5,1
    80000e2a:	fee79de3          	bne	a5,a4,80000e24 <memset+0x12>
  }
  return dst;
}
    80000e2e:	6422                	ld	s0,8(sp)
    80000e30:	0141                	addi	sp,sp,16
    80000e32:	8082                	ret

0000000080000e34 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e34:	1141                	addi	sp,sp,-16
    80000e36:	e422                	sd	s0,8(sp)
    80000e38:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e3a:	ca05                	beqz	a2,80000e6a <memcmp+0x36>
    80000e3c:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000e40:	1682                	slli	a3,a3,0x20
    80000e42:	9281                	srli	a3,a3,0x20
    80000e44:	0685                	addi	a3,a3,1
    80000e46:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	0005c703          	lbu	a4,0(a1)
    80000e50:	00e79863          	bne	a5,a4,80000e60 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e58:	fed518e3          	bne	a0,a3,80000e48 <memcmp+0x14>
  }

  return 0;
    80000e5c:	4501                	li	a0,0
    80000e5e:	a019                	j	80000e64 <memcmp+0x30>
      return *s1 - *s2;
    80000e60:	40e7853b          	subw	a0,a5,a4
}
    80000e64:	6422                	ld	s0,8(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret
  return 0;
    80000e6a:	4501                	li	a0,0
    80000e6c:	bfe5                	j	80000e64 <memcmp+0x30>

0000000080000e6e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e6e:	1141                	addi	sp,sp,-16
    80000e70:	e422                	sd	s0,8(sp)
    80000e72:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000e74:	c205                	beqz	a2,80000e94 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e76:	02a5e263          	bltu	a1,a0,80000e9a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e7a:	1602                	slli	a2,a2,0x20
    80000e7c:	9201                	srli	a2,a2,0x20
    80000e7e:	00c587b3          	add	a5,a1,a2
{
    80000e82:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e84:	0585                	addi	a1,a1,1
    80000e86:	0705                	addi	a4,a4,1
    80000e88:	fff5c683          	lbu	a3,-1(a1)
    80000e8c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e90:	fef59ae3          	bne	a1,a5,80000e84 <memmove+0x16>

  return dst;
}
    80000e94:	6422                	ld	s0,8(sp)
    80000e96:	0141                	addi	sp,sp,16
    80000e98:	8082                	ret
  if(s < d && s + n > d){
    80000e9a:	02061693          	slli	a3,a2,0x20
    80000e9e:	9281                	srli	a3,a3,0x20
    80000ea0:	00d58733          	add	a4,a1,a3
    80000ea4:	fce57be3          	bgeu	a0,a4,80000e7a <memmove+0xc>
    d += n;
    80000ea8:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000eaa:	fff6079b          	addiw	a5,a2,-1
    80000eae:	1782                	slli	a5,a5,0x20
    80000eb0:	9381                	srli	a5,a5,0x20
    80000eb2:	fff7c793          	not	a5,a5
    80000eb6:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000eb8:	177d                	addi	a4,a4,-1
    80000eba:	16fd                	addi	a3,a3,-1
    80000ebc:	00074603          	lbu	a2,0(a4)
    80000ec0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000ec4:	fee79ae3          	bne	a5,a4,80000eb8 <memmove+0x4a>
    80000ec8:	b7f1                	j	80000e94 <memmove+0x26>

0000000080000eca <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000eca:	1141                	addi	sp,sp,-16
    80000ecc:	e406                	sd	ra,8(sp)
    80000ece:	e022                	sd	s0,0(sp)
    80000ed0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	f9c080e7          	jalr	-100(ra) # 80000e6e <memmove>
}
    80000eda:	60a2                	ld	ra,8(sp)
    80000edc:	6402                	ld	s0,0(sp)
    80000ede:	0141                	addi	sp,sp,16
    80000ee0:	8082                	ret

0000000080000ee2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000ee2:	1141                	addi	sp,sp,-16
    80000ee4:	e422                	sd	s0,8(sp)
    80000ee6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ee8:	ce11                	beqz	a2,80000f04 <strncmp+0x22>
    80000eea:	00054783          	lbu	a5,0(a0)
    80000eee:	cf89                	beqz	a5,80000f08 <strncmp+0x26>
    80000ef0:	0005c703          	lbu	a4,0(a1)
    80000ef4:	00f71a63          	bne	a4,a5,80000f08 <strncmp+0x26>
    n--, p++, q++;
    80000ef8:	367d                	addiw	a2,a2,-1
    80000efa:	0505                	addi	a0,a0,1
    80000efc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000efe:	f675                	bnez	a2,80000eea <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f00:	4501                	li	a0,0
    80000f02:	a809                	j	80000f14 <strncmp+0x32>
    80000f04:	4501                	li	a0,0
    80000f06:	a039                	j	80000f14 <strncmp+0x32>
  if(n == 0)
    80000f08:	ca09                	beqz	a2,80000f1a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000f0a:	00054503          	lbu	a0,0(a0)
    80000f0e:	0005c783          	lbu	a5,0(a1)
    80000f12:	9d1d                	subw	a0,a0,a5
}
    80000f14:	6422                	ld	s0,8(sp)
    80000f16:	0141                	addi	sp,sp,16
    80000f18:	8082                	ret
    return 0;
    80000f1a:	4501                	li	a0,0
    80000f1c:	bfe5                	j	80000f14 <strncmp+0x32>

0000000080000f1e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f1e:	1141                	addi	sp,sp,-16
    80000f20:	e422                	sd	s0,8(sp)
    80000f22:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f24:	872a                	mv	a4,a0
    80000f26:	8832                	mv	a6,a2
    80000f28:	367d                	addiw	a2,a2,-1
    80000f2a:	01005963          	blez	a6,80000f3c <strncpy+0x1e>
    80000f2e:	0705                	addi	a4,a4,1
    80000f30:	0005c783          	lbu	a5,0(a1)
    80000f34:	fef70fa3          	sb	a5,-1(a4)
    80000f38:	0585                	addi	a1,a1,1
    80000f3a:	f7f5                	bnez	a5,80000f26 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f3c:	86ba                	mv	a3,a4
    80000f3e:	00c05c63          	blez	a2,80000f56 <strncpy+0x38>
    *s++ = 0;
    80000f42:	0685                	addi	a3,a3,1
    80000f44:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000f48:	40d707bb          	subw	a5,a4,a3
    80000f4c:	37fd                	addiw	a5,a5,-1
    80000f4e:	010787bb          	addw	a5,a5,a6
    80000f52:	fef048e3          	bgtz	a5,80000f42 <strncpy+0x24>
  return os;
}
    80000f56:	6422                	ld	s0,8(sp)
    80000f58:	0141                	addi	sp,sp,16
    80000f5a:	8082                	ret

0000000080000f5c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f5c:	1141                	addi	sp,sp,-16
    80000f5e:	e422                	sd	s0,8(sp)
    80000f60:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f62:	02c05363          	blez	a2,80000f88 <safestrcpy+0x2c>
    80000f66:	fff6069b          	addiw	a3,a2,-1
    80000f6a:	1682                	slli	a3,a3,0x20
    80000f6c:	9281                	srli	a3,a3,0x20
    80000f6e:	96ae                	add	a3,a3,a1
    80000f70:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f72:	00d58963          	beq	a1,a3,80000f84 <safestrcpy+0x28>
    80000f76:	0585                	addi	a1,a1,1
    80000f78:	0785                	addi	a5,a5,1
    80000f7a:	fff5c703          	lbu	a4,-1(a1)
    80000f7e:	fee78fa3          	sb	a4,-1(a5)
    80000f82:	fb65                	bnez	a4,80000f72 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f84:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f88:	6422                	ld	s0,8(sp)
    80000f8a:	0141                	addi	sp,sp,16
    80000f8c:	8082                	ret

0000000080000f8e <strlen>:

int
strlen(const char *s)
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f94:	00054783          	lbu	a5,0(a0)
    80000f98:	cf91                	beqz	a5,80000fb4 <strlen+0x26>
    80000f9a:	0505                	addi	a0,a0,1
    80000f9c:	87aa                	mv	a5,a0
    80000f9e:	4685                	li	a3,1
    80000fa0:	9e89                	subw	a3,a3,a0
    80000fa2:	00f6853b          	addw	a0,a3,a5
    80000fa6:	0785                	addi	a5,a5,1
    80000fa8:	fff7c703          	lbu	a4,-1(a5)
    80000fac:	fb7d                	bnez	a4,80000fa2 <strlen+0x14>
    ;
  return n;
}
    80000fae:	6422                	ld	s0,8(sp)
    80000fb0:	0141                	addi	sp,sp,16
    80000fb2:	8082                	ret
  for(n = 0; s[n]; n++)
    80000fb4:	4501                	li	a0,0
    80000fb6:	bfe5                	j	80000fae <strlen+0x20>

0000000080000fb8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000fb8:	1141                	addi	sp,sp,-16
    80000fba:	e406                	sd	ra,8(sp)
    80000fbc:	e022                	sd	s0,0(sp)
    80000fbe:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000fc0:	00001097          	auipc	ra,0x1
    80000fc4:	b44080e7          	jalr	-1212(ra) # 80001b04 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000fc8:	00008717          	auipc	a4,0x8
    80000fcc:	c5070713          	addi	a4,a4,-944 # 80008c18 <started>
  if(cpuid() == 0){
    80000fd0:	c139                	beqz	a0,80001016 <main+0x5e>
    while(started == 0)
    80000fd2:	431c                	lw	a5,0(a4)
    80000fd4:	2781                	sext.w	a5,a5
    80000fd6:	dff5                	beqz	a5,80000fd2 <main+0x1a>
      ;
    __sync_synchronize();
    80000fd8:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000fdc:	00001097          	auipc	ra,0x1
    80000fe0:	b28080e7          	jalr	-1240(ra) # 80001b04 <cpuid>
    80000fe4:	85aa                	mv	a1,a0
    80000fe6:	00007517          	auipc	a0,0x7
    80000fea:	11250513          	addi	a0,a0,274 # 800080f8 <digits+0xb8>
    80000fee:	fffff097          	auipc	ra,0xfffff
    80000ff2:	59c080e7          	jalr	1436(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000ff6:	00000097          	auipc	ra,0x0
    80000ffa:	0d8080e7          	jalr	216(ra) # 800010ce <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ffe:	00002097          	auipc	ra,0x2
    80001002:	b9c080e7          	jalr	-1124(ra) # 80002b9a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001006:	00005097          	auipc	ra,0x5
    8000100a:	66a080e7          	jalr	1642(ra) # 80006670 <plicinithart>
  }

  scheduler();        
    8000100e:	00001097          	auipc	ra,0x1
    80001012:	144080e7          	jalr	324(ra) # 80002152 <scheduler>
    consoleinit();
    80001016:	fffff097          	auipc	ra,0xfffff
    8000101a:	43a080e7          	jalr	1082(ra) # 80000450 <consoleinit>
    printfinit();
    8000101e:	fffff097          	auipc	ra,0xfffff
    80001022:	74c080e7          	jalr	1868(ra) # 8000076a <printfinit>
    printf("\n");
    80001026:	00007517          	auipc	a0,0x7
    8000102a:	0e250513          	addi	a0,a0,226 # 80008108 <digits+0xc8>
    8000102e:	fffff097          	auipc	ra,0xfffff
    80001032:	55c080e7          	jalr	1372(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80001036:	00007517          	auipc	a0,0x7
    8000103a:	0aa50513          	addi	a0,a0,170 # 800080e0 <digits+0xa0>
    8000103e:	fffff097          	auipc	ra,0xfffff
    80001042:	54c080e7          	jalr	1356(ra) # 8000058a <printf>
    printf("\n");
    80001046:	00007517          	auipc	a0,0x7
    8000104a:	0c250513          	addi	a0,a0,194 # 80008108 <digits+0xc8>
    8000104e:	fffff097          	auipc	ra,0xfffff
    80001052:	53c080e7          	jalr	1340(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80001056:	00000097          	auipc	ra,0x0
    8000105a:	b56080e7          	jalr	-1194(ra) # 80000bac <kinit>
    kvminit();       // create kernel page table
    8000105e:	00000097          	auipc	ra,0x0
    80001062:	326080e7          	jalr	806(ra) # 80001384 <kvminit>
    kvminithart();   // turn on paging
    80001066:	00000097          	auipc	ra,0x0
    8000106a:	068080e7          	jalr	104(ra) # 800010ce <kvminithart>
    procinit();      // process table
    8000106e:	00001097          	auipc	ra,0x1
    80001072:	9d8080e7          	jalr	-1576(ra) # 80001a46 <procinit>
    trapinit();      // trap vectors
    80001076:	00002097          	auipc	ra,0x2
    8000107a:	afc080e7          	jalr	-1284(ra) # 80002b72 <trapinit>
    trapinithart();  // install kernel trap vector
    8000107e:	00002097          	auipc	ra,0x2
    80001082:	b1c080e7          	jalr	-1252(ra) # 80002b9a <trapinithart>
    plicinit();      // set up interrupt controller
    80001086:	00005097          	auipc	ra,0x5
    8000108a:	5d4080e7          	jalr	1492(ra) # 8000665a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000108e:	00005097          	auipc	ra,0x5
    80001092:	5e2080e7          	jalr	1506(ra) # 80006670 <plicinithart>
    binit();         // buffer cache
    80001096:	00002097          	auipc	ra,0x2
    8000109a:	760080e7          	jalr	1888(ra) # 800037f6 <binit>
    iinit();         // inode table
    8000109e:	00003097          	auipc	ra,0x3
    800010a2:	e00080e7          	jalr	-512(ra) # 80003e9e <iinit>
    fileinit();      // file table
    800010a6:	00004097          	auipc	ra,0x4
    800010aa:	da6080e7          	jalr	-602(ra) # 80004e4c <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010ae:	00005097          	auipc	ra,0x5
    800010b2:	6ca080e7          	jalr	1738(ra) # 80006778 <virtio_disk_init>
    userinit();      // first user process
    800010b6:	00001097          	auipc	ra,0x1
    800010ba:	e6e080e7          	jalr	-402(ra) # 80001f24 <userinit>
    __sync_synchronize();
    800010be:	0ff0000f          	fence
    started = 1;
    800010c2:	4785                	li	a5,1
    800010c4:	00008717          	auipc	a4,0x8
    800010c8:	b4f72a23          	sw	a5,-1196(a4) # 80008c18 <started>
    800010cc:	b789                	j	8000100e <main+0x56>

00000000800010ce <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800010ce:	1141                	addi	sp,sp,-16
    800010d0:	e422                	sd	s0,8(sp)
    800010d2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800010d4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800010d8:	00008797          	auipc	a5,0x8
    800010dc:	b487b783          	ld	a5,-1208(a5) # 80008c20 <kernel_pagetable>
    800010e0:	83b1                	srli	a5,a5,0xc
    800010e2:	577d                	li	a4,-1
    800010e4:	177e                	slli	a4,a4,0x3f
    800010e6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800010e8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800010ec:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800010f0:	6422                	ld	s0,8(sp)
    800010f2:	0141                	addi	sp,sp,16
    800010f4:	8082                	ret

00000000800010f6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010f6:	7139                	addi	sp,sp,-64
    800010f8:	fc06                	sd	ra,56(sp)
    800010fa:	f822                	sd	s0,48(sp)
    800010fc:	f426                	sd	s1,40(sp)
    800010fe:	f04a                	sd	s2,32(sp)
    80001100:	ec4e                	sd	s3,24(sp)
    80001102:	e852                	sd	s4,16(sp)
    80001104:	e456                	sd	s5,8(sp)
    80001106:	e05a                	sd	s6,0(sp)
    80001108:	0080                	addi	s0,sp,64
    8000110a:	84aa                	mv	s1,a0
    8000110c:	89ae                	mv	s3,a1
    8000110e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001110:	57fd                	li	a5,-1
    80001112:	83e9                	srli	a5,a5,0x1a
    80001114:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001116:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001118:	04b7f263          	bgeu	a5,a1,8000115c <walk+0x66>
    panic("walk");
    8000111c:	00007517          	auipc	a0,0x7
    80001120:	ff450513          	addi	a0,a0,-12 # 80008110 <digits+0xd0>
    80001124:	fffff097          	auipc	ra,0xfffff
    80001128:	41c080e7          	jalr	1052(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000112c:	060a8663          	beqz	s5,80001198 <walk+0xa2>
    80001130:	00000097          	auipc	ra,0x0
    80001134:	ab8080e7          	jalr	-1352(ra) # 80000be8 <kalloc>
    80001138:	84aa                	mv	s1,a0
    8000113a:	c529                	beqz	a0,80001184 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000113c:	6605                	lui	a2,0x1
    8000113e:	4581                	li	a1,0
    80001140:	00000097          	auipc	ra,0x0
    80001144:	cd2080e7          	jalr	-814(ra) # 80000e12 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001148:	00c4d793          	srli	a5,s1,0xc
    8000114c:	07aa                	slli	a5,a5,0xa
    8000114e:	0017e793          	ori	a5,a5,1
    80001152:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001156:	3a5d                	addiw	s4,s4,-9 # ff7 <_entry-0x7ffff009>
    80001158:	036a0063          	beq	s4,s6,80001178 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000115c:	0149d933          	srl	s2,s3,s4
    80001160:	1ff97913          	andi	s2,s2,511
    80001164:	090e                	slli	s2,s2,0x3
    80001166:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001168:	00093483          	ld	s1,0(s2)
    8000116c:	0014f793          	andi	a5,s1,1
    80001170:	dfd5                	beqz	a5,8000112c <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001172:	80a9                	srli	s1,s1,0xa
    80001174:	04b2                	slli	s1,s1,0xc
    80001176:	b7c5                	j	80001156 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001178:	00c9d513          	srli	a0,s3,0xc
    8000117c:	1ff57513          	andi	a0,a0,511
    80001180:	050e                	slli	a0,a0,0x3
    80001182:	9526                	add	a0,a0,s1
}
    80001184:	70e2                	ld	ra,56(sp)
    80001186:	7442                	ld	s0,48(sp)
    80001188:	74a2                	ld	s1,40(sp)
    8000118a:	7902                	ld	s2,32(sp)
    8000118c:	69e2                	ld	s3,24(sp)
    8000118e:	6a42                	ld	s4,16(sp)
    80001190:	6aa2                	ld	s5,8(sp)
    80001192:	6b02                	ld	s6,0(sp)
    80001194:	6121                	addi	sp,sp,64
    80001196:	8082                	ret
        return 0;
    80001198:	4501                	li	a0,0
    8000119a:	b7ed                	j	80001184 <walk+0x8e>

000000008000119c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000119c:	57fd                	li	a5,-1
    8000119e:	83e9                	srli	a5,a5,0x1a
    800011a0:	00b7f463          	bgeu	a5,a1,800011a8 <walkaddr+0xc>
    return 0;
    800011a4:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800011a6:	8082                	ret
{
    800011a8:	1141                	addi	sp,sp,-16
    800011aa:	e406                	sd	ra,8(sp)
    800011ac:	e022                	sd	s0,0(sp)
    800011ae:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800011b0:	4601                	li	a2,0
    800011b2:	00000097          	auipc	ra,0x0
    800011b6:	f44080e7          	jalr	-188(ra) # 800010f6 <walk>
  if(pte == 0)
    800011ba:	c105                	beqz	a0,800011da <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800011bc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011be:	0117f693          	andi	a3,a5,17
    800011c2:	4745                	li	a4,17
    return 0;
    800011c4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011c6:	00e68663          	beq	a3,a4,800011d2 <walkaddr+0x36>
}
    800011ca:	60a2                	ld	ra,8(sp)
    800011cc:	6402                	ld	s0,0(sp)
    800011ce:	0141                	addi	sp,sp,16
    800011d0:	8082                	ret
  pa = PTE2PA(*pte);
    800011d2:	83a9                	srli	a5,a5,0xa
    800011d4:	00c79513          	slli	a0,a5,0xc
  return pa;
    800011d8:	bfcd                	j	800011ca <walkaddr+0x2e>
    return 0;
    800011da:	4501                	li	a0,0
    800011dc:	b7fd                	j	800011ca <walkaddr+0x2e>

00000000800011de <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011de:	715d                	addi	sp,sp,-80
    800011e0:	e486                	sd	ra,72(sp)
    800011e2:	e0a2                	sd	s0,64(sp)
    800011e4:	fc26                	sd	s1,56(sp)
    800011e6:	f84a                	sd	s2,48(sp)
    800011e8:	f44e                	sd	s3,40(sp)
    800011ea:	f052                	sd	s4,32(sp)
    800011ec:	ec56                	sd	s5,24(sp)
    800011ee:	e85a                	sd	s6,16(sp)
    800011f0:	e45e                	sd	s7,8(sp)
    800011f2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800011f4:	c639                	beqz	a2,80001242 <mappages+0x64>
    800011f6:	8aaa                	mv	s5,a0
    800011f8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800011fa:	777d                	lui	a4,0xfffff
    800011fc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001200:	fff58993          	addi	s3,a1,-1
    80001204:	99b2                	add	s3,s3,a2
    80001206:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000120a:	893e                	mv	s2,a5
    8000120c:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001210:	6b85                	lui	s7,0x1
    80001212:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001216:	4605                	li	a2,1
    80001218:	85ca                	mv	a1,s2
    8000121a:	8556                	mv	a0,s5
    8000121c:	00000097          	auipc	ra,0x0
    80001220:	eda080e7          	jalr	-294(ra) # 800010f6 <walk>
    80001224:	cd1d                	beqz	a0,80001262 <mappages+0x84>
    if(*pte & PTE_V)
    80001226:	611c                	ld	a5,0(a0)
    80001228:	8b85                	andi	a5,a5,1
    8000122a:	e785                	bnez	a5,80001252 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000122c:	80b1                	srli	s1,s1,0xc
    8000122e:	04aa                	slli	s1,s1,0xa
    80001230:	0164e4b3          	or	s1,s1,s6
    80001234:	0014e493          	ori	s1,s1,1
    80001238:	e104                	sd	s1,0(a0)
    if(a == last)
    8000123a:	05390063          	beq	s2,s3,8000127a <mappages+0x9c>
    a += PGSIZE;
    8000123e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001240:	bfc9                	j	80001212 <mappages+0x34>
    panic("mappages: size");
    80001242:	00007517          	auipc	a0,0x7
    80001246:	ed650513          	addi	a0,a0,-298 # 80008118 <digits+0xd8>
    8000124a:	fffff097          	auipc	ra,0xfffff
    8000124e:	2f6080e7          	jalr	758(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001252:	00007517          	auipc	a0,0x7
    80001256:	ed650513          	addi	a0,a0,-298 # 80008128 <digits+0xe8>
    8000125a:	fffff097          	auipc	ra,0xfffff
    8000125e:	2e6080e7          	jalr	742(ra) # 80000540 <panic>
      return -1;
    80001262:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001264:	60a6                	ld	ra,72(sp)
    80001266:	6406                	ld	s0,64(sp)
    80001268:	74e2                	ld	s1,56(sp)
    8000126a:	7942                	ld	s2,48(sp)
    8000126c:	79a2                	ld	s3,40(sp)
    8000126e:	7a02                	ld	s4,32(sp)
    80001270:	6ae2                	ld	s5,24(sp)
    80001272:	6b42                	ld	s6,16(sp)
    80001274:	6ba2                	ld	s7,8(sp)
    80001276:	6161                	addi	sp,sp,80
    80001278:	8082                	ret
  return 0;
    8000127a:	4501                	li	a0,0
    8000127c:	b7e5                	j	80001264 <mappages+0x86>

000000008000127e <kvmmap>:
{
    8000127e:	1141                	addi	sp,sp,-16
    80001280:	e406                	sd	ra,8(sp)
    80001282:	e022                	sd	s0,0(sp)
    80001284:	0800                	addi	s0,sp,16
    80001286:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001288:	86b2                	mv	a3,a2
    8000128a:	863e                	mv	a2,a5
    8000128c:	00000097          	auipc	ra,0x0
    80001290:	f52080e7          	jalr	-174(ra) # 800011de <mappages>
    80001294:	e509                	bnez	a0,8000129e <kvmmap+0x20>
}
    80001296:	60a2                	ld	ra,8(sp)
    80001298:	6402                	ld	s0,0(sp)
    8000129a:	0141                	addi	sp,sp,16
    8000129c:	8082                	ret
    panic("kvmmap");
    8000129e:	00007517          	auipc	a0,0x7
    800012a2:	e9a50513          	addi	a0,a0,-358 # 80008138 <digits+0xf8>
    800012a6:	fffff097          	auipc	ra,0xfffff
    800012aa:	29a080e7          	jalr	666(ra) # 80000540 <panic>

00000000800012ae <kvmmake>:
{
    800012ae:	1101                	addi	sp,sp,-32
    800012b0:	ec06                	sd	ra,24(sp)
    800012b2:	e822                	sd	s0,16(sp)
    800012b4:	e426                	sd	s1,8(sp)
    800012b6:	e04a                	sd	s2,0(sp)
    800012b8:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800012ba:	00000097          	auipc	ra,0x0
    800012be:	92e080e7          	jalr	-1746(ra) # 80000be8 <kalloc>
    800012c2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012c4:	6605                	lui	a2,0x1
    800012c6:	4581                	li	a1,0
    800012c8:	00000097          	auipc	ra,0x0
    800012cc:	b4a080e7          	jalr	-1206(ra) # 80000e12 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012d0:	4719                	li	a4,6
    800012d2:	6685                	lui	a3,0x1
    800012d4:	10000637          	lui	a2,0x10000
    800012d8:	100005b7          	lui	a1,0x10000
    800012dc:	8526                	mv	a0,s1
    800012de:	00000097          	auipc	ra,0x0
    800012e2:	fa0080e7          	jalr	-96(ra) # 8000127e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012e6:	4719                	li	a4,6
    800012e8:	6685                	lui	a3,0x1
    800012ea:	10001637          	lui	a2,0x10001
    800012ee:	100015b7          	lui	a1,0x10001
    800012f2:	8526                	mv	a0,s1
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	f8a080e7          	jalr	-118(ra) # 8000127e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012fc:	4719                	li	a4,6
    800012fe:	004006b7          	lui	a3,0x400
    80001302:	0c000637          	lui	a2,0xc000
    80001306:	0c0005b7          	lui	a1,0xc000
    8000130a:	8526                	mv	a0,s1
    8000130c:	00000097          	auipc	ra,0x0
    80001310:	f72080e7          	jalr	-142(ra) # 8000127e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001314:	00007917          	auipc	s2,0x7
    80001318:	cec90913          	addi	s2,s2,-788 # 80008000 <etext>
    8000131c:	4729                	li	a4,10
    8000131e:	80007697          	auipc	a3,0x80007
    80001322:	ce268693          	addi	a3,a3,-798 # 8000 <_entry-0x7fff8000>
    80001326:	4605                	li	a2,1
    80001328:	067e                	slli	a2,a2,0x1f
    8000132a:	85b2                	mv	a1,a2
    8000132c:	8526                	mv	a0,s1
    8000132e:	00000097          	auipc	ra,0x0
    80001332:	f50080e7          	jalr	-176(ra) # 8000127e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001336:	4719                	li	a4,6
    80001338:	46c5                	li	a3,17
    8000133a:	06ee                	slli	a3,a3,0x1b
    8000133c:	412686b3          	sub	a3,a3,s2
    80001340:	864a                	mv	a2,s2
    80001342:	85ca                	mv	a1,s2
    80001344:	8526                	mv	a0,s1
    80001346:	00000097          	auipc	ra,0x0
    8000134a:	f38080e7          	jalr	-200(ra) # 8000127e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000134e:	4729                	li	a4,10
    80001350:	6685                	lui	a3,0x1
    80001352:	00006617          	auipc	a2,0x6
    80001356:	cae60613          	addi	a2,a2,-850 # 80007000 <_trampoline>
    8000135a:	040005b7          	lui	a1,0x4000
    8000135e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001360:	05b2                	slli	a1,a1,0xc
    80001362:	8526                	mv	a0,s1
    80001364:	00000097          	auipc	ra,0x0
    80001368:	f1a080e7          	jalr	-230(ra) # 8000127e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000136c:	8526                	mv	a0,s1
    8000136e:	00000097          	auipc	ra,0x0
    80001372:	642080e7          	jalr	1602(ra) # 800019b0 <proc_mapstacks>
}
    80001376:	8526                	mv	a0,s1
    80001378:	60e2                	ld	ra,24(sp)
    8000137a:	6442                	ld	s0,16(sp)
    8000137c:	64a2                	ld	s1,8(sp)
    8000137e:	6902                	ld	s2,0(sp)
    80001380:	6105                	addi	sp,sp,32
    80001382:	8082                	ret

0000000080001384 <kvminit>:
{
    80001384:	1141                	addi	sp,sp,-16
    80001386:	e406                	sd	ra,8(sp)
    80001388:	e022                	sd	s0,0(sp)
    8000138a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	f22080e7          	jalr	-222(ra) # 800012ae <kvmmake>
    80001394:	00008797          	auipc	a5,0x8
    80001398:	88a7b623          	sd	a0,-1908(a5) # 80008c20 <kernel_pagetable>
}
    8000139c:	60a2                	ld	ra,8(sp)
    8000139e:	6402                	ld	s0,0(sp)
    800013a0:	0141                	addi	sp,sp,16
    800013a2:	8082                	ret

00000000800013a4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800013a4:	715d                	addi	sp,sp,-80
    800013a6:	e486                	sd	ra,72(sp)
    800013a8:	e0a2                	sd	s0,64(sp)
    800013aa:	fc26                	sd	s1,56(sp)
    800013ac:	f84a                	sd	s2,48(sp)
    800013ae:	f44e                	sd	s3,40(sp)
    800013b0:	f052                	sd	s4,32(sp)
    800013b2:	ec56                	sd	s5,24(sp)
    800013b4:	e85a                	sd	s6,16(sp)
    800013b6:	e45e                	sd	s7,8(sp)
    800013b8:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013ba:	03459793          	slli	a5,a1,0x34
    800013be:	e795                	bnez	a5,800013ea <uvmunmap+0x46>
    800013c0:	8a2a                	mv	s4,a0
    800013c2:	892e                	mv	s2,a1
    800013c4:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013c6:	0632                	slli	a2,a2,0xc
    800013c8:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800013cc:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013ce:	6b05                	lui	s6,0x1
    800013d0:	0735e263          	bltu	a1,s3,80001434 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800013d4:	60a6                	ld	ra,72(sp)
    800013d6:	6406                	ld	s0,64(sp)
    800013d8:	74e2                	ld	s1,56(sp)
    800013da:	7942                	ld	s2,48(sp)
    800013dc:	79a2                	ld	s3,40(sp)
    800013de:	7a02                	ld	s4,32(sp)
    800013e0:	6ae2                	ld	s5,24(sp)
    800013e2:	6b42                	ld	s6,16(sp)
    800013e4:	6ba2                	ld	s7,8(sp)
    800013e6:	6161                	addi	sp,sp,80
    800013e8:	8082                	ret
    panic("uvmunmap: not aligned");
    800013ea:	00007517          	auipc	a0,0x7
    800013ee:	d5650513          	addi	a0,a0,-682 # 80008140 <digits+0x100>
    800013f2:	fffff097          	auipc	ra,0xfffff
    800013f6:	14e080e7          	jalr	334(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800013fa:	00007517          	auipc	a0,0x7
    800013fe:	d5e50513          	addi	a0,a0,-674 # 80008158 <digits+0x118>
    80001402:	fffff097          	auipc	ra,0xfffff
    80001406:	13e080e7          	jalr	318(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    8000140a:	00007517          	auipc	a0,0x7
    8000140e:	d5e50513          	addi	a0,a0,-674 # 80008168 <digits+0x128>
    80001412:	fffff097          	auipc	ra,0xfffff
    80001416:	12e080e7          	jalr	302(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    8000141a:	00007517          	auipc	a0,0x7
    8000141e:	d6650513          	addi	a0,a0,-666 # 80008180 <digits+0x140>
    80001422:	fffff097          	auipc	ra,0xfffff
    80001426:	11e080e7          	jalr	286(ra) # 80000540 <panic>
    *pte = 0;
    8000142a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000142e:	995a                	add	s2,s2,s6
    80001430:	fb3972e3          	bgeu	s2,s3,800013d4 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001434:	4601                	li	a2,0
    80001436:	85ca                	mv	a1,s2
    80001438:	8552                	mv	a0,s4
    8000143a:	00000097          	auipc	ra,0x0
    8000143e:	cbc080e7          	jalr	-836(ra) # 800010f6 <walk>
    80001442:	84aa                	mv	s1,a0
    80001444:	d95d                	beqz	a0,800013fa <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001446:	6108                	ld	a0,0(a0)
    80001448:	00157793          	andi	a5,a0,1
    8000144c:	dfdd                	beqz	a5,8000140a <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000144e:	3ff57793          	andi	a5,a0,1023
    80001452:	fd7784e3          	beq	a5,s7,8000141a <uvmunmap+0x76>
    if(do_free){
    80001456:	fc0a8ae3          	beqz	s5,8000142a <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000145a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000145c:	0532                	slli	a0,a0,0xc
    8000145e:	fffff097          	auipc	ra,0xfffff
    80001462:	606080e7          	jalr	1542(ra) # 80000a64 <kfree>
    80001466:	b7d1                	j	8000142a <uvmunmap+0x86>

0000000080001468 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001468:	1101                	addi	sp,sp,-32
    8000146a:	ec06                	sd	ra,24(sp)
    8000146c:	e822                	sd	s0,16(sp)
    8000146e:	e426                	sd	s1,8(sp)
    80001470:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001472:	fffff097          	auipc	ra,0xfffff
    80001476:	776080e7          	jalr	1910(ra) # 80000be8 <kalloc>
    8000147a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000147c:	c519                	beqz	a0,8000148a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000147e:	6605                	lui	a2,0x1
    80001480:	4581                	li	a1,0
    80001482:	00000097          	auipc	ra,0x0
    80001486:	990080e7          	jalr	-1648(ra) # 80000e12 <memset>
  return pagetable;
}
    8000148a:	8526                	mv	a0,s1
    8000148c:	60e2                	ld	ra,24(sp)
    8000148e:	6442                	ld	s0,16(sp)
    80001490:	64a2                	ld	s1,8(sp)
    80001492:	6105                	addi	sp,sp,32
    80001494:	8082                	ret

0000000080001496 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001496:	7179                	addi	sp,sp,-48
    80001498:	f406                	sd	ra,40(sp)
    8000149a:	f022                	sd	s0,32(sp)
    8000149c:	ec26                	sd	s1,24(sp)
    8000149e:	e84a                	sd	s2,16(sp)
    800014a0:	e44e                	sd	s3,8(sp)
    800014a2:	e052                	sd	s4,0(sp)
    800014a4:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800014a6:	6785                	lui	a5,0x1
    800014a8:	04f67863          	bgeu	a2,a5,800014f8 <uvmfirst+0x62>
    800014ac:	8a2a                	mv	s4,a0
    800014ae:	89ae                	mv	s3,a1
    800014b0:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800014b2:	fffff097          	auipc	ra,0xfffff
    800014b6:	736080e7          	jalr	1846(ra) # 80000be8 <kalloc>
    800014ba:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014bc:	6605                	lui	a2,0x1
    800014be:	4581                	li	a1,0
    800014c0:	00000097          	auipc	ra,0x0
    800014c4:	952080e7          	jalr	-1710(ra) # 80000e12 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014c8:	4779                	li	a4,30
    800014ca:	86ca                	mv	a3,s2
    800014cc:	6605                	lui	a2,0x1
    800014ce:	4581                	li	a1,0
    800014d0:	8552                	mv	a0,s4
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	d0c080e7          	jalr	-756(ra) # 800011de <mappages>
  memmove(mem, src, sz);
    800014da:	8626                	mv	a2,s1
    800014dc:	85ce                	mv	a1,s3
    800014de:	854a                	mv	a0,s2
    800014e0:	00000097          	auipc	ra,0x0
    800014e4:	98e080e7          	jalr	-1650(ra) # 80000e6e <memmove>
}
    800014e8:	70a2                	ld	ra,40(sp)
    800014ea:	7402                	ld	s0,32(sp)
    800014ec:	64e2                	ld	s1,24(sp)
    800014ee:	6942                	ld	s2,16(sp)
    800014f0:	69a2                	ld	s3,8(sp)
    800014f2:	6a02                	ld	s4,0(sp)
    800014f4:	6145                	addi	sp,sp,48
    800014f6:	8082                	ret
    panic("uvmfirst: more than a page");
    800014f8:	00007517          	auipc	a0,0x7
    800014fc:	ca050513          	addi	a0,a0,-864 # 80008198 <digits+0x158>
    80001500:	fffff097          	auipc	ra,0xfffff
    80001504:	040080e7          	jalr	64(ra) # 80000540 <panic>

0000000080001508 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001508:	1101                	addi	sp,sp,-32
    8000150a:	ec06                	sd	ra,24(sp)
    8000150c:	e822                	sd	s0,16(sp)
    8000150e:	e426                	sd	s1,8(sp)
    80001510:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001512:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001514:	00b67d63          	bgeu	a2,a1,8000152e <uvmdealloc+0x26>
    80001518:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000151a:	6785                	lui	a5,0x1
    8000151c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000151e:	00f60733          	add	a4,a2,a5
    80001522:	76fd                	lui	a3,0xfffff
    80001524:	8f75                	and	a4,a4,a3
    80001526:	97ae                	add	a5,a5,a1
    80001528:	8ff5                	and	a5,a5,a3
    8000152a:	00f76863          	bltu	a4,a5,8000153a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000152e:	8526                	mv	a0,s1
    80001530:	60e2                	ld	ra,24(sp)
    80001532:	6442                	ld	s0,16(sp)
    80001534:	64a2                	ld	s1,8(sp)
    80001536:	6105                	addi	sp,sp,32
    80001538:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000153a:	8f99                	sub	a5,a5,a4
    8000153c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000153e:	4685                	li	a3,1
    80001540:	0007861b          	sext.w	a2,a5
    80001544:	85ba                	mv	a1,a4
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	e5e080e7          	jalr	-418(ra) # 800013a4 <uvmunmap>
    8000154e:	b7c5                	j	8000152e <uvmdealloc+0x26>

0000000080001550 <uvmalloc>:
  if(newsz < oldsz)
    80001550:	0ab66563          	bltu	a2,a1,800015fa <uvmalloc+0xaa>
{
    80001554:	7139                	addi	sp,sp,-64
    80001556:	fc06                	sd	ra,56(sp)
    80001558:	f822                	sd	s0,48(sp)
    8000155a:	f426                	sd	s1,40(sp)
    8000155c:	f04a                	sd	s2,32(sp)
    8000155e:	ec4e                	sd	s3,24(sp)
    80001560:	e852                	sd	s4,16(sp)
    80001562:	e456                	sd	s5,8(sp)
    80001564:	e05a                	sd	s6,0(sp)
    80001566:	0080                	addi	s0,sp,64
    80001568:	8aaa                	mv	s5,a0
    8000156a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000156c:	6785                	lui	a5,0x1
    8000156e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001570:	95be                	add	a1,a1,a5
    80001572:	77fd                	lui	a5,0xfffff
    80001574:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001578:	08c9f363          	bgeu	s3,a2,800015fe <uvmalloc+0xae>
    8000157c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000157e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	666080e7          	jalr	1638(ra) # 80000be8 <kalloc>
    8000158a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000158c:	c51d                	beqz	a0,800015ba <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000158e:	6605                	lui	a2,0x1
    80001590:	4581                	li	a1,0
    80001592:	00000097          	auipc	ra,0x0
    80001596:	880080e7          	jalr	-1920(ra) # 80000e12 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000159a:	875a                	mv	a4,s6
    8000159c:	86a6                	mv	a3,s1
    8000159e:	6605                	lui	a2,0x1
    800015a0:	85ca                	mv	a1,s2
    800015a2:	8556                	mv	a0,s5
    800015a4:	00000097          	auipc	ra,0x0
    800015a8:	c3a080e7          	jalr	-966(ra) # 800011de <mappages>
    800015ac:	e90d                	bnez	a0,800015de <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015ae:	6785                	lui	a5,0x1
    800015b0:	993e                	add	s2,s2,a5
    800015b2:	fd4968e3          	bltu	s2,s4,80001582 <uvmalloc+0x32>
  return newsz;
    800015b6:	8552                	mv	a0,s4
    800015b8:	a809                	j	800015ca <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    800015ba:	864e                	mv	a2,s3
    800015bc:	85ca                	mv	a1,s2
    800015be:	8556                	mv	a0,s5
    800015c0:	00000097          	auipc	ra,0x0
    800015c4:	f48080e7          	jalr	-184(ra) # 80001508 <uvmdealloc>
      return 0;
    800015c8:	4501                	li	a0,0
}
    800015ca:	70e2                	ld	ra,56(sp)
    800015cc:	7442                	ld	s0,48(sp)
    800015ce:	74a2                	ld	s1,40(sp)
    800015d0:	7902                	ld	s2,32(sp)
    800015d2:	69e2                	ld	s3,24(sp)
    800015d4:	6a42                	ld	s4,16(sp)
    800015d6:	6aa2                	ld	s5,8(sp)
    800015d8:	6b02                	ld	s6,0(sp)
    800015da:	6121                	addi	sp,sp,64
    800015dc:	8082                	ret
      kfree(mem);
    800015de:	8526                	mv	a0,s1
    800015e0:	fffff097          	auipc	ra,0xfffff
    800015e4:	484080e7          	jalr	1156(ra) # 80000a64 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015e8:	864e                	mv	a2,s3
    800015ea:	85ca                	mv	a1,s2
    800015ec:	8556                	mv	a0,s5
    800015ee:	00000097          	auipc	ra,0x0
    800015f2:	f1a080e7          	jalr	-230(ra) # 80001508 <uvmdealloc>
      return 0;
    800015f6:	4501                	li	a0,0
    800015f8:	bfc9                	j	800015ca <uvmalloc+0x7a>
    return oldsz;
    800015fa:	852e                	mv	a0,a1
}
    800015fc:	8082                	ret
  return newsz;
    800015fe:	8532                	mv	a0,a2
    80001600:	b7e9                	j	800015ca <uvmalloc+0x7a>

0000000080001602 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001602:	7179                	addi	sp,sp,-48
    80001604:	f406                	sd	ra,40(sp)
    80001606:	f022                	sd	s0,32(sp)
    80001608:	ec26                	sd	s1,24(sp)
    8000160a:	e84a                	sd	s2,16(sp)
    8000160c:	e44e                	sd	s3,8(sp)
    8000160e:	e052                	sd	s4,0(sp)
    80001610:	1800                	addi	s0,sp,48
    80001612:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001614:	84aa                	mv	s1,a0
    80001616:	6905                	lui	s2,0x1
    80001618:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000161a:	4985                	li	s3,1
    8000161c:	a829                	j	80001636 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000161e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001620:	00c79513          	slli	a0,a5,0xc
    80001624:	00000097          	auipc	ra,0x0
    80001628:	fde080e7          	jalr	-34(ra) # 80001602 <freewalk>
      pagetable[i] = 0;
    8000162c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001630:	04a1                	addi	s1,s1,8
    80001632:	03248163          	beq	s1,s2,80001654 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001636:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001638:	00f7f713          	andi	a4,a5,15
    8000163c:	ff3701e3          	beq	a4,s3,8000161e <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001640:	8b85                	andi	a5,a5,1
    80001642:	d7fd                	beqz	a5,80001630 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001644:	00007517          	auipc	a0,0x7
    80001648:	b7450513          	addi	a0,a0,-1164 # 800081b8 <digits+0x178>
    8000164c:	fffff097          	auipc	ra,0xfffff
    80001650:	ef4080e7          	jalr	-268(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001654:	8552                	mv	a0,s4
    80001656:	fffff097          	auipc	ra,0xfffff
    8000165a:	40e080e7          	jalr	1038(ra) # 80000a64 <kfree>
}
    8000165e:	70a2                	ld	ra,40(sp)
    80001660:	7402                	ld	s0,32(sp)
    80001662:	64e2                	ld	s1,24(sp)
    80001664:	6942                	ld	s2,16(sp)
    80001666:	69a2                	ld	s3,8(sp)
    80001668:	6a02                	ld	s4,0(sp)
    8000166a:	6145                	addi	sp,sp,48
    8000166c:	8082                	ret

000000008000166e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000166e:	1101                	addi	sp,sp,-32
    80001670:	ec06                	sd	ra,24(sp)
    80001672:	e822                	sd	s0,16(sp)
    80001674:	e426                	sd	s1,8(sp)
    80001676:	1000                	addi	s0,sp,32
    80001678:	84aa                	mv	s1,a0
  if(sz > 0)
    8000167a:	e999                	bnez	a1,80001690 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000167c:	8526                	mv	a0,s1
    8000167e:	00000097          	auipc	ra,0x0
    80001682:	f84080e7          	jalr	-124(ra) # 80001602 <freewalk>
}
    80001686:	60e2                	ld	ra,24(sp)
    80001688:	6442                	ld	s0,16(sp)
    8000168a:	64a2                	ld	s1,8(sp)
    8000168c:	6105                	addi	sp,sp,32
    8000168e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001690:	6785                	lui	a5,0x1
    80001692:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001694:	95be                	add	a1,a1,a5
    80001696:	4685                	li	a3,1
    80001698:	00c5d613          	srli	a2,a1,0xc
    8000169c:	4581                	li	a1,0
    8000169e:	00000097          	auipc	ra,0x0
    800016a2:	d06080e7          	jalr	-762(ra) # 800013a4 <uvmunmap>
    800016a6:	bfd9                	j	8000167c <uvmfree+0xe>

00000000800016a8 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  // char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016a8:	ce4d                	beqz	a2,80001762 <uvmcopy+0xba>
{
    800016aa:	7139                	addi	sp,sp,-64
    800016ac:	fc06                	sd	ra,56(sp)
    800016ae:	f822                	sd	s0,48(sp)
    800016b0:	f426                	sd	s1,40(sp)
    800016b2:	f04a                	sd	s2,32(sp)
    800016b4:	ec4e                	sd	s3,24(sp)
    800016b6:	e852                	sd	s4,16(sp)
    800016b8:	e456                	sd	s5,8(sp)
    800016ba:	e05a                	sd	s6,0(sp)
    800016bc:	0080                	addi	s0,sp,64
    800016be:	8aaa                	mv	s5,a0
    800016c0:	8a2e                	mv	s4,a1
    800016c2:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016c4:	4481                	li	s1,0
    if((pte = walk(old, i, 0)) == 0)
    800016c6:	4601                	li	a2,0
    800016c8:	85a6                	mv	a1,s1
    800016ca:	8556                	mv	a0,s5
    800016cc:	00000097          	auipc	ra,0x0
    800016d0:	a2a080e7          	jalr	-1494(ra) # 800010f6 <walk>
    800016d4:	c139                	beqz	a0,8000171a <uvmcopy+0x72>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016d6:	611c                	ld	a5,0(a0)
    800016d8:	0017f713          	andi	a4,a5,1
    800016dc:	c739                	beqz	a4,8000172a <uvmcopy+0x82>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016de:	00a7d913          	srli	s2,a5,0xa
    800016e2:	0932                	slli	s2,s2,0xc

    // if((mem = kalloc()) == 0)
    //   goto err;
    // memmove(mem, (char*)pa, PGSIZE);

    flags &= ~PTE_W; // disabling writting for child
    800016e4:	3fb7fb13          	andi	s6,a5,1019
    flags = flags | PTE_C; // enabling COW flag

    *pte &= ~PTE_W; // disabling writting for parent
    800016e8:	9bed                	andi	a5,a5,-5
    *pte = *pte | PTE_C; // enabling COW flag
    800016ea:	0207e793          	ori	a5,a5,32
    800016ee:	e11c                	sd	a5,0(a0)

    incref(pa);
    800016f0:	854a                	mv	a0,s2
    800016f2:	fffff097          	auipc	ra,0xfffff
    800016f6:	2f6080e7          	jalr	758(ra) # 800009e8 <incref>
    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0){ // only map the page table and not memory
    800016fa:	020b6713          	ori	a4,s6,32
    800016fe:	86ca                	mv	a3,s2
    80001700:	6605                	lui	a2,0x1
    80001702:	85a6                	mv	a1,s1
    80001704:	8552                	mv	a0,s4
    80001706:	00000097          	auipc	ra,0x0
    8000170a:	ad8080e7          	jalr	-1320(ra) # 800011de <mappages>
    8000170e:	e515                	bnez	a0,8000173a <uvmcopy+0x92>
  for(i = 0; i < sz; i += PGSIZE){
    80001710:	6785                	lui	a5,0x1
    80001712:	94be                	add	s1,s1,a5
    80001714:	fb34e9e3          	bltu	s1,s3,800016c6 <uvmcopy+0x1e>
    80001718:	a81d                	j	8000174e <uvmcopy+0xa6>
      panic("uvmcopy: pte should exist");
    8000171a:	00007517          	auipc	a0,0x7
    8000171e:	aae50513          	addi	a0,a0,-1362 # 800081c8 <digits+0x188>
    80001722:	fffff097          	auipc	ra,0xfffff
    80001726:	e1e080e7          	jalr	-482(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    8000172a:	00007517          	auipc	a0,0x7
    8000172e:	abe50513          	addi	a0,a0,-1346 # 800081e8 <digits+0x1a8>
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	e0e080e7          	jalr	-498(ra) # 80000540 <panic>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000173a:	4685                	li	a3,1
    8000173c:	00c4d613          	srli	a2,s1,0xc
    80001740:	4581                	li	a1,0
    80001742:	8552                	mv	a0,s4
    80001744:	00000097          	auipc	ra,0x0
    80001748:	c60080e7          	jalr	-928(ra) # 800013a4 <uvmunmap>
  return -1;
    8000174c:	557d                	li	a0,-1
}
    8000174e:	70e2                	ld	ra,56(sp)
    80001750:	7442                	ld	s0,48(sp)
    80001752:	74a2                	ld	s1,40(sp)
    80001754:	7902                	ld	s2,32(sp)
    80001756:	69e2                	ld	s3,24(sp)
    80001758:	6a42                	ld	s4,16(sp)
    8000175a:	6aa2                	ld	s5,8(sp)
    8000175c:	6b02                	ld	s6,0(sp)
    8000175e:	6121                	addi	sp,sp,64
    80001760:	8082                	ret
  return 0;
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret

0000000080001766 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001766:	1141                	addi	sp,sp,-16
    80001768:	e406                	sd	ra,8(sp)
    8000176a:	e022                	sd	s0,0(sp)
    8000176c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000176e:	4601                	li	a2,0
    80001770:	00000097          	auipc	ra,0x0
    80001774:	986080e7          	jalr	-1658(ra) # 800010f6 <walk>
  if(pte == 0)
    80001778:	c901                	beqz	a0,80001788 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000177a:	611c                	ld	a5,0(a0)
    8000177c:	9bbd                	andi	a5,a5,-17
    8000177e:	e11c                	sd	a5,0(a0)
}
    80001780:	60a2                	ld	ra,8(sp)
    80001782:	6402                	ld	s0,0(sp)
    80001784:	0141                	addi	sp,sp,16
    80001786:	8082                	ret
    panic("uvmclear");
    80001788:	00007517          	auipc	a0,0x7
    8000178c:	a8050513          	addi	a0,a0,-1408 # 80008208 <digits+0x1c8>
    80001790:	fffff097          	auipc	ra,0xfffff
    80001794:	db0080e7          	jalr	-592(ra) # 80000540 <panic>

0000000080001798 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001798:	cac5                	beqz	a3,80001848 <copyout+0xb0>
{
    8000179a:	711d                	addi	sp,sp,-96
    8000179c:	ec86                	sd	ra,88(sp)
    8000179e:	e8a2                	sd	s0,80(sp)
    800017a0:	e4a6                	sd	s1,72(sp)
    800017a2:	e0ca                	sd	s2,64(sp)
    800017a4:	fc4e                	sd	s3,56(sp)
    800017a6:	f852                	sd	s4,48(sp)
    800017a8:	f456                	sd	s5,40(sp)
    800017aa:	f05a                	sd	s6,32(sp)
    800017ac:	ec5e                	sd	s7,24(sp)
    800017ae:	e862                	sd	s8,16(sp)
    800017b0:	e466                	sd	s9,8(sp)
    800017b2:	e06a                	sd	s10,0(sp)
    800017b4:	1080                	addi	s0,sp,96
    800017b6:	8baa                	mv	s7,a0
    800017b8:	89ae                	mv	s3,a1
    800017ba:	8b32                	mv	s6,a2
    800017bc:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    800017be:	7cfd                	lui	s9,0xfffff

    pa0=walkaddr(pagetable,va0);
    if(pa0==0)
      return -1;
    pte_t *pte=walk(pagetable,va0,0);
    if(pte==0 || (*pte & PTE_V)==0 || (*pte & PTE_U)==0)
    800017c0:	4d45                	li	s10,17
        return -1;
    }

    pa0=PTE2PA(*pte); // pull the pagetable entry out in case it is changed
  
    n = PGSIZE - (dstva - va0);
    800017c2:	6c05                	lui	s8,0x1
    800017c4:	a825                	j	800017fc <copyout+0x64>
    800017c6:	413904b3          	sub	s1,s2,s3
    800017ca:	94e2                	add	s1,s1,s8
    800017cc:	009af363          	bgeu	s5,s1,800017d2 <copyout+0x3a>
    800017d0:	84d6                	mv	s1,s5
    pa0=PTE2PA(*pte); // pull the pagetable entry out in case it is changed
    800017d2:	000a3783          	ld	a5,0(s4)
    800017d6:	83a9                	srli	a5,a5,0xa
    800017d8:	07b2                	slli	a5,a5,0xc
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017da:	41298533          	sub	a0,s3,s2
    800017de:	0004861b          	sext.w	a2,s1
    800017e2:	85da                	mv	a1,s6
    800017e4:	953e                	add	a0,a0,a5
    800017e6:	fffff097          	auipc	ra,0xfffff
    800017ea:	688080e7          	jalr	1672(ra) # 80000e6e <memmove>

    len -= n;
    800017ee:	409a8ab3          	sub	s5,s5,s1
    src += n;
    800017f2:	9b26                	add	s6,s6,s1
    dstva = va0 + PGSIZE;
    800017f4:	018909b3          	add	s3,s2,s8
  while(len > 0){
    800017f8:	040a8663          	beqz	s5,80001844 <copyout+0xac>
    va0 = PGROUNDDOWN(dstva);
    800017fc:	0199f933          	and	s2,s3,s9
    pa0=walkaddr(pagetable,va0);
    80001800:	85ca                	mv	a1,s2
    80001802:	855e                	mv	a0,s7
    80001804:	00000097          	auipc	ra,0x0
    80001808:	998080e7          	jalr	-1640(ra) # 8000119c <walkaddr>
    if(pa0==0)
    8000180c:	c121                	beqz	a0,8000184c <copyout+0xb4>
    pte_t *pte=walk(pagetable,va0,0);
    8000180e:	4601                	li	a2,0
    80001810:	85ca                	mv	a1,s2
    80001812:	855e                	mv	a0,s7
    80001814:	00000097          	auipc	ra,0x0
    80001818:	8e2080e7          	jalr	-1822(ra) # 800010f6 <walk>
    8000181c:	8a2a                	mv	s4,a0
    if(pte==0 || (*pte & PTE_V)==0 || (*pte & PTE_U)==0)
    8000181e:	c531                	beqz	a0,8000186a <copyout+0xd2>
    80001820:	611c                	ld	a5,0(a0)
    80001822:	0117f713          	andi	a4,a5,17
    80001826:	05a71463          	bne	a4,s10,8000186e <copyout+0xd6>
    if((*pte & PTE_C)==0){ // this is a cow page
    8000182a:	0207f793          	andi	a5,a5,32
    8000182e:	ffc1                	bnez	a5,800017c6 <copyout+0x2e>
      if(cow_handler(pagetable,va0)<0)
    80001830:	85ca                	mv	a1,s2
    80001832:	855e                	mv	a0,s7
    80001834:	00001097          	auipc	ra,0x1
    80001838:	37e080e7          	jalr	894(ra) # 80002bb2 <cow_handler>
    8000183c:	f80555e3          	bgez	a0,800017c6 <copyout+0x2e>
        return -1;
    80001840:	557d                	li	a0,-1
    80001842:	a031                	j	8000184e <copyout+0xb6>
  }
  return 0;
    80001844:	4501                	li	a0,0
    80001846:	a021                	j	8000184e <copyout+0xb6>
    80001848:	4501                	li	a0,0
}
    8000184a:	8082                	ret
      return -1;
    8000184c:	557d                	li	a0,-1
}
    8000184e:	60e6                	ld	ra,88(sp)
    80001850:	6446                	ld	s0,80(sp)
    80001852:	64a6                	ld	s1,72(sp)
    80001854:	6906                	ld	s2,64(sp)
    80001856:	79e2                	ld	s3,56(sp)
    80001858:	7a42                	ld	s4,48(sp)
    8000185a:	7aa2                	ld	s5,40(sp)
    8000185c:	7b02                	ld	s6,32(sp)
    8000185e:	6be2                	ld	s7,24(sp)
    80001860:	6c42                	ld	s8,16(sp)
    80001862:	6ca2                	ld	s9,8(sp)
    80001864:	6d02                	ld	s10,0(sp)
    80001866:	6125                	addi	sp,sp,96
    80001868:	8082                	ret
      return -1;
    8000186a:	557d                	li	a0,-1
    8000186c:	b7cd                	j	8000184e <copyout+0xb6>
    8000186e:	557d                	li	a0,-1
    80001870:	bff9                	j	8000184e <copyout+0xb6>

0000000080001872 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001872:	caa5                	beqz	a3,800018e2 <copyin+0x70>
{
    80001874:	715d                	addi	sp,sp,-80
    80001876:	e486                	sd	ra,72(sp)
    80001878:	e0a2                	sd	s0,64(sp)
    8000187a:	fc26                	sd	s1,56(sp)
    8000187c:	f84a                	sd	s2,48(sp)
    8000187e:	f44e                	sd	s3,40(sp)
    80001880:	f052                	sd	s4,32(sp)
    80001882:	ec56                	sd	s5,24(sp)
    80001884:	e85a                	sd	s6,16(sp)
    80001886:	e45e                	sd	s7,8(sp)
    80001888:	e062                	sd	s8,0(sp)
    8000188a:	0880                	addi	s0,sp,80
    8000188c:	8b2a                	mv	s6,a0
    8000188e:	8a2e                	mv	s4,a1
    80001890:	8c32                	mv	s8,a2
    80001892:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001894:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001896:	6a85                	lui	s5,0x1
    80001898:	a01d                	j	800018be <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000189a:	018505b3          	add	a1,a0,s8
    8000189e:	0004861b          	sext.w	a2,s1
    800018a2:	412585b3          	sub	a1,a1,s2
    800018a6:	8552                	mv	a0,s4
    800018a8:	fffff097          	auipc	ra,0xfffff
    800018ac:	5c6080e7          	jalr	1478(ra) # 80000e6e <memmove>

    len -= n;
    800018b0:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018b4:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018b6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018ba:	02098263          	beqz	s3,800018de <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800018be:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018c2:	85ca                	mv	a1,s2
    800018c4:	855a                	mv	a0,s6
    800018c6:	00000097          	auipc	ra,0x0
    800018ca:	8d6080e7          	jalr	-1834(ra) # 8000119c <walkaddr>
    if(pa0 == 0)
    800018ce:	cd01                	beqz	a0,800018e6 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800018d0:	418904b3          	sub	s1,s2,s8
    800018d4:	94d6                	add	s1,s1,s5
    800018d6:	fc99f2e3          	bgeu	s3,s1,8000189a <copyin+0x28>
    800018da:	84ce                	mv	s1,s3
    800018dc:	bf7d                	j	8000189a <copyin+0x28>
  }
  return 0;
    800018de:	4501                	li	a0,0
    800018e0:	a021                	j	800018e8 <copyin+0x76>
    800018e2:	4501                	li	a0,0
}
    800018e4:	8082                	ret
      return -1;
    800018e6:	557d                	li	a0,-1
}
    800018e8:	60a6                	ld	ra,72(sp)
    800018ea:	6406                	ld	s0,64(sp)
    800018ec:	74e2                	ld	s1,56(sp)
    800018ee:	7942                	ld	s2,48(sp)
    800018f0:	79a2                	ld	s3,40(sp)
    800018f2:	7a02                	ld	s4,32(sp)
    800018f4:	6ae2                	ld	s5,24(sp)
    800018f6:	6b42                	ld	s6,16(sp)
    800018f8:	6ba2                	ld	s7,8(sp)
    800018fa:	6c02                	ld	s8,0(sp)
    800018fc:	6161                	addi	sp,sp,80
    800018fe:	8082                	ret

0000000080001900 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001900:	c2dd                	beqz	a3,800019a6 <copyinstr+0xa6>
{
    80001902:	715d                	addi	sp,sp,-80
    80001904:	e486                	sd	ra,72(sp)
    80001906:	e0a2                	sd	s0,64(sp)
    80001908:	fc26                	sd	s1,56(sp)
    8000190a:	f84a                	sd	s2,48(sp)
    8000190c:	f44e                	sd	s3,40(sp)
    8000190e:	f052                	sd	s4,32(sp)
    80001910:	ec56                	sd	s5,24(sp)
    80001912:	e85a                	sd	s6,16(sp)
    80001914:	e45e                	sd	s7,8(sp)
    80001916:	0880                	addi	s0,sp,80
    80001918:	8a2a                	mv	s4,a0
    8000191a:	8b2e                	mv	s6,a1
    8000191c:	8bb2                	mv	s7,a2
    8000191e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001920:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001922:	6985                	lui	s3,0x1
    80001924:	a02d                	j	8000194e <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001926:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000192a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000192c:	37fd                	addiw	a5,a5,-1
    8000192e:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001932:	60a6                	ld	ra,72(sp)
    80001934:	6406                	ld	s0,64(sp)
    80001936:	74e2                	ld	s1,56(sp)
    80001938:	7942                	ld	s2,48(sp)
    8000193a:	79a2                	ld	s3,40(sp)
    8000193c:	7a02                	ld	s4,32(sp)
    8000193e:	6ae2                	ld	s5,24(sp)
    80001940:	6b42                	ld	s6,16(sp)
    80001942:	6ba2                	ld	s7,8(sp)
    80001944:	6161                	addi	sp,sp,80
    80001946:	8082                	ret
    srcva = va0 + PGSIZE;
    80001948:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000194c:	c8a9                	beqz	s1,8000199e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    8000194e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001952:	85ca                	mv	a1,s2
    80001954:	8552                	mv	a0,s4
    80001956:	00000097          	auipc	ra,0x0
    8000195a:	846080e7          	jalr	-1978(ra) # 8000119c <walkaddr>
    if(pa0 == 0)
    8000195e:	c131                	beqz	a0,800019a2 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001960:	417906b3          	sub	a3,s2,s7
    80001964:	96ce                	add	a3,a3,s3
    80001966:	00d4f363          	bgeu	s1,a3,8000196c <copyinstr+0x6c>
    8000196a:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000196c:	955e                	add	a0,a0,s7
    8000196e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001972:	daf9                	beqz	a3,80001948 <copyinstr+0x48>
    80001974:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001976:	41650633          	sub	a2,a0,s6
    8000197a:	fff48593          	addi	a1,s1,-1
    8000197e:	95da                	add	a1,a1,s6
    while(n > 0){
    80001980:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001982:	00f60733          	add	a4,a2,a5
    80001986:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fdbad00>
    8000198a:	df51                	beqz	a4,80001926 <copyinstr+0x26>
        *dst = *p;
    8000198c:	00e78023          	sb	a4,0(a5)
      --max;
    80001990:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001994:	0785                	addi	a5,a5,1
    while(n > 0){
    80001996:	fed796e3          	bne	a5,a3,80001982 <copyinstr+0x82>
      dst++;
    8000199a:	8b3e                	mv	s6,a5
    8000199c:	b775                	j	80001948 <copyinstr+0x48>
    8000199e:	4781                	li	a5,0
    800019a0:	b771                	j	8000192c <copyinstr+0x2c>
      return -1;
    800019a2:	557d                	li	a0,-1
    800019a4:	b779                	j	80001932 <copyinstr+0x32>
  int got_null = 0;
    800019a6:	4781                	li	a5,0
  if(got_null){
    800019a8:	37fd                	addiw	a5,a5,-1
    800019aa:	0007851b          	sext.w	a0,a5
}
    800019ae:	8082                	ret

00000000800019b0 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    800019b0:	7139                	addi	sp,sp,-64
    800019b2:	fc06                	sd	ra,56(sp)
    800019b4:	f822                	sd	s0,48(sp)
    800019b6:	f426                	sd	s1,40(sp)
    800019b8:	f04a                	sd	s2,32(sp)
    800019ba:	ec4e                	sd	s3,24(sp)
    800019bc:	e852                	sd	s4,16(sp)
    800019be:	e456                	sd	s5,8(sp)
    800019c0:	e05a                	sd	s6,0(sp)
    800019c2:	0080                	addi	s0,sp,64
    800019c4:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800019c6:	00230497          	auipc	s1,0x230
    800019ca:	d0a48493          	addi	s1,s1,-758 # 802316d0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800019ce:	8b26                	mv	s6,s1
    800019d0:	00006a97          	auipc	s5,0x6
    800019d4:	630a8a93          	addi	s5,s5,1584 # 80008000 <etext>
    800019d8:	04000937          	lui	s2,0x4000
    800019dc:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019de:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    800019e0:	00237a17          	auipc	s4,0x237
    800019e4:	4f0a0a13          	addi	s4,s4,1264 # 80238ed0 <queues>
    char *pa = kalloc();
    800019e8:	fffff097          	auipc	ra,0xfffff
    800019ec:	200080e7          	jalr	512(ra) # 80000be8 <kalloc>
    800019f0:	862a                	mv	a2,a0
    if (pa == 0)
    800019f2:	c131                	beqz	a0,80001a36 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    800019f4:	416485b3          	sub	a1,s1,s6
    800019f8:	8595                	srai	a1,a1,0x5
    800019fa:	000ab783          	ld	a5,0(s5)
    800019fe:	02f585b3          	mul	a1,a1,a5
    80001a02:	2585                	addiw	a1,a1,1
    80001a04:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a08:	4719                	li	a4,6
    80001a0a:	6685                	lui	a3,0x1
    80001a0c:	40b905b3          	sub	a1,s2,a1
    80001a10:	854e                	mv	a0,s3
    80001a12:	00000097          	auipc	ra,0x0
    80001a16:	86c080e7          	jalr	-1940(ra) # 8000127e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a1a:	1e048493          	addi	s1,s1,480
    80001a1e:	fd4495e3          	bne	s1,s4,800019e8 <proc_mapstacks+0x38>
  }
}
    80001a22:	70e2                	ld	ra,56(sp)
    80001a24:	7442                	ld	s0,48(sp)
    80001a26:	74a2                	ld	s1,40(sp)
    80001a28:	7902                	ld	s2,32(sp)
    80001a2a:	69e2                	ld	s3,24(sp)
    80001a2c:	6a42                	ld	s4,16(sp)
    80001a2e:	6aa2                	ld	s5,8(sp)
    80001a30:	6b02                	ld	s6,0(sp)
    80001a32:	6121                	addi	sp,sp,64
    80001a34:	8082                	ret
      panic("kalloc");
    80001a36:	00006517          	auipc	a0,0x6
    80001a3a:	7e250513          	addi	a0,a0,2018 # 80008218 <digits+0x1d8>
    80001a3e:	fffff097          	auipc	ra,0xfffff
    80001a42:	b02080e7          	jalr	-1278(ra) # 80000540 <panic>

0000000080001a46 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001a46:	715d                	addi	sp,sp,-80
    80001a48:	e486                	sd	ra,72(sp)
    80001a4a:	e0a2                	sd	s0,64(sp)
    80001a4c:	fc26                	sd	s1,56(sp)
    80001a4e:	f84a                	sd	s2,48(sp)
    80001a50:	f44e                	sd	s3,40(sp)
    80001a52:	f052                	sd	s4,32(sp)
    80001a54:	ec56                	sd	s5,24(sp)
    80001a56:	e85a                	sd	s6,16(sp)
    80001a58:	e45e                	sd	s7,8(sp)
    80001a5a:	0880                	addi	s0,sp,80

  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001a5c:	00006597          	auipc	a1,0x6
    80001a60:	7c458593          	addi	a1,a1,1988 # 80008220 <digits+0x1e0>
    80001a64:	0022f517          	auipc	a0,0x22f
    80001a68:	43c50513          	addi	a0,a0,1084 # 80230ea0 <pid_lock>
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	21a080e7          	jalr	538(ra) # 80000c86 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a74:	00006597          	auipc	a1,0x6
    80001a78:	7b458593          	addi	a1,a1,1972 # 80008228 <digits+0x1e8>
    80001a7c:	0022f517          	auipc	a0,0x22f
    80001a80:	43c50513          	addi	a0,a0,1084 # 80230eb8 <wait_lock>
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	202080e7          	jalr	514(ra) # 80000c86 <initlock>

  for (p = proc; p < &proc[NPROC]; p++)
    80001a8c:	00230497          	auipc	s1,0x230
    80001a90:	c4448493          	addi	s1,s1,-956 # 802316d0 <proc>
  {
    initlock(&p->lock, "proc");
    80001a94:	00006b97          	auipc	s7,0x6
    80001a98:	7a4b8b93          	addi	s7,s7,1956 # 80008238 <digits+0x1f8>
    p->state = UNUSED;
    p->mask = -1;
    80001a9c:	5b7d                	li	s6,-1
    p->kstack = KSTACK((int)(p - proc));
    80001a9e:	8aa6                	mv	s5,s1
    80001aa0:	00006a17          	auipc	s4,0x6
    80001aa4:	560a0a13          	addi	s4,s4,1376 # 80008000 <etext>
    80001aa8:	04000937          	lui	s2,0x4000
    80001aac:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001aae:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001ab0:	00237997          	auipc	s3,0x237
    80001ab4:	42098993          	addi	s3,s3,1056 # 80238ed0 <queues>
    initlock(&p->lock, "proc");
    80001ab8:	85de                	mv	a1,s7
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	1ca080e7          	jalr	458(ra) # 80000c86 <initlock>
    p->state = UNUSED;
    80001ac4:	0004ac23          	sw	zero,24(s1)
    p->mask = -1;
    80001ac8:	1764a423          	sw	s6,360(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001acc:	415487b3          	sub	a5,s1,s5
    80001ad0:	8795                	srai	a5,a5,0x5
    80001ad2:	000a3703          	ld	a4,0(s4)
    80001ad6:	02e787b3          	mul	a5,a5,a4
    80001ada:	2785                	addiw	a5,a5,1
    80001adc:	00d7979b          	slliw	a5,a5,0xd
    80001ae0:	40f907b3          	sub	a5,s2,a5
    80001ae4:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001ae6:	1e048493          	addi	s1,s1,480
    80001aea:	fd3497e3          	bne	s1,s3,80001ab8 <procinit+0x72>
  {
    queues[i].head = 0;
    queues[i].size = 0;
  }
#endif
}
    80001aee:	60a6                	ld	ra,72(sp)
    80001af0:	6406                	ld	s0,64(sp)
    80001af2:	74e2                	ld	s1,56(sp)
    80001af4:	7942                	ld	s2,48(sp)
    80001af6:	79a2                	ld	s3,40(sp)
    80001af8:	7a02                	ld	s4,32(sp)
    80001afa:	6ae2                	ld	s5,24(sp)
    80001afc:	6b42                	ld	s6,16(sp)
    80001afe:	6ba2                	ld	s7,8(sp)
    80001b00:	6161                	addi	sp,sp,80
    80001b02:	8082                	ret

0000000080001b04 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001b04:	1141                	addi	sp,sp,-16
    80001b06:	e422                	sd	s0,8(sp)
    80001b08:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b0a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b0c:	2501                	sext.w	a0,a0
    80001b0e:	6422                	ld	s0,8(sp)
    80001b10:	0141                	addi	sp,sp,16
    80001b12:	8082                	ret

0000000080001b14 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001b14:	1141                	addi	sp,sp,-16
    80001b16:	e422                	sd	s0,8(sp)
    80001b18:	0800                	addi	s0,sp,16
    80001b1a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b1c:	2781                	sext.w	a5,a5
    80001b1e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b20:	0022f517          	auipc	a0,0x22f
    80001b24:	3b050513          	addi	a0,a0,944 # 80230ed0 <cpus>
    80001b28:	953e                	add	a0,a0,a5
    80001b2a:	6422                	ld	s0,8(sp)
    80001b2c:	0141                	addi	sp,sp,16
    80001b2e:	8082                	ret

0000000080001b30 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001b30:	1101                	addi	sp,sp,-32
    80001b32:	ec06                	sd	ra,24(sp)
    80001b34:	e822                	sd	s0,16(sp)
    80001b36:	e426                	sd	s1,8(sp)
    80001b38:	1000                	addi	s0,sp,32
  push_off();
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	190080e7          	jalr	400(ra) # 80000cca <push_off>
    80001b42:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b44:	2781                	sext.w	a5,a5
    80001b46:	079e                	slli	a5,a5,0x7
    80001b48:	0022f717          	auipc	a4,0x22f
    80001b4c:	35870713          	addi	a4,a4,856 # 80230ea0 <pid_lock>
    80001b50:	97ba                	add	a5,a5,a4
    80001b52:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	216080e7          	jalr	534(ra) # 80000d6a <pop_off>
  return p;
}
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	60e2                	ld	ra,24(sp)
    80001b60:	6442                	ld	s0,16(sp)
    80001b62:	64a2                	ld	s1,8(sp)
    80001b64:	6105                	addi	sp,sp,32
    80001b66:	8082                	ret

0000000080001b68 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001b68:	1141                	addi	sp,sp,-16
    80001b6a:	e406                	sd	ra,8(sp)
    80001b6c:	e022                	sd	s0,0(sp)
    80001b6e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001b70:	00000097          	auipc	ra,0x0
    80001b74:	fc0080e7          	jalr	-64(ra) # 80001b30 <myproc>
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	252080e7          	jalr	594(ra) # 80000dca <release>

  if (first)
    80001b80:	00007797          	auipc	a5,0x7
    80001b84:	fa07a783          	lw	a5,-96(a5) # 80008b20 <first.1>
    80001b88:	eb89                	bnez	a5,80001b9a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b8a:	00001097          	auipc	ra,0x1
    80001b8e:	0bc080e7          	jalr	188(ra) # 80002c46 <usertrapret>
}
    80001b92:	60a2                	ld	ra,8(sp)
    80001b94:	6402                	ld	s0,0(sp)
    80001b96:	0141                	addi	sp,sp,16
    80001b98:	8082                	ret
    first = 0;
    80001b9a:	00007797          	auipc	a5,0x7
    80001b9e:	f807a323          	sw	zero,-122(a5) # 80008b20 <first.1>
    fsinit(ROOTDEV);
    80001ba2:	4505                	li	a0,1
    80001ba4:	00002097          	auipc	ra,0x2
    80001ba8:	27a080e7          	jalr	634(ra) # 80003e1e <fsinit>
    80001bac:	bff9                	j	80001b8a <forkret+0x22>

0000000080001bae <allocpid>:
{
    80001bae:	1101                	addi	sp,sp,-32
    80001bb0:	ec06                	sd	ra,24(sp)
    80001bb2:	e822                	sd	s0,16(sp)
    80001bb4:	e426                	sd	s1,8(sp)
    80001bb6:	e04a                	sd	s2,0(sp)
    80001bb8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bba:	0022f917          	auipc	s2,0x22f
    80001bbe:	2e690913          	addi	s2,s2,742 # 80230ea0 <pid_lock>
    80001bc2:	854a                	mv	a0,s2
    80001bc4:	fffff097          	auipc	ra,0xfffff
    80001bc8:	152080e7          	jalr	338(ra) # 80000d16 <acquire>
  pid = nextpid;
    80001bcc:	00007797          	auipc	a5,0x7
    80001bd0:	f5878793          	addi	a5,a5,-168 # 80008b24 <nextpid>
    80001bd4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bd6:	0014871b          	addiw	a4,s1,1
    80001bda:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bdc:	854a                	mv	a0,s2
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	1ec080e7          	jalr	492(ra) # 80000dca <release>
}
    80001be6:	8526                	mv	a0,s1
    80001be8:	60e2                	ld	ra,24(sp)
    80001bea:	6442                	ld	s0,16(sp)
    80001bec:	64a2                	ld	s1,8(sp)
    80001bee:	6902                	ld	s2,0(sp)
    80001bf0:	6105                	addi	sp,sp,32
    80001bf2:	8082                	ret

0000000080001bf4 <push>:
{
    80001bf4:	1141                	addi	sp,sp,-16
    80001bf6:	e422                	sd	s0,8(sp)
    80001bf8:	0800                	addi	s0,sp,16
  for (int i = 0; i < NPROC; i++)
    80001bfa:	0022f717          	auipc	a4,0x22f
    80001bfe:	6d670713          	addi	a4,a4,1750 # 802312d0 <nodes>
    80001c02:	4781                	li	a5,0
    80001c04:	04000613          	li	a2,64
    if (!(nodes[i].p))
    80001c08:	6314                	ld	a3,0(a4)
    80001c0a:	c699                	beqz	a3,80001c18 <push+0x24>
  for (int i = 0; i < NPROC; i++)
    80001c0c:	2785                	addiw	a5,a5,1
    80001c0e:	0741                	addi	a4,a4,16
    80001c10:	fec79ce3          	bne	a5,a2,80001c08 <push+0x14>
  struct node *newNode = 0;
    80001c14:	4681                	li	a3,0
    80001c16:	a039                	j	80001c24 <push+0x30>
      newNode = &(nodes[i]);
    80001c18:	0792                	slli	a5,a5,0x4
    80001c1a:	0022f697          	auipc	a3,0x22f
    80001c1e:	6b668693          	addi	a3,a3,1718 # 802312d0 <nodes>
    80001c22:	96be                	add	a3,a3,a5
  newNode->next = 0;
    80001c24:	0006b423          	sd	zero,8(a3)
  newNode->p = p;
    80001c28:	e28c                	sd	a1,0(a3)
  if (!(*head))
    80001c2a:	611c                	ld	a5,0(a0)
    80001c2c:	cb81                	beqz	a5,80001c3c <push+0x48>
    while (cur->next)
    80001c2e:	873e                	mv	a4,a5
    80001c30:	679c                	ld	a5,8(a5)
    80001c32:	fff5                	bnez	a5,80001c2e <push+0x3a>
    cur->next = newNode;
    80001c34:	e714                	sd	a3,8(a4)
}
    80001c36:	6422                	ld	s0,8(sp)
    80001c38:	0141                	addi	sp,sp,16
    80001c3a:	8082                	ret
    *head = newNode;
    80001c3c:	e114                	sd	a3,0(a0)
    80001c3e:	bfe5                	j	80001c36 <push+0x42>

0000000080001c40 <pop>:
{
    80001c40:	1141                	addi	sp,sp,-16
    80001c42:	e422                	sd	s0,8(sp)
    80001c44:	0800                	addi	s0,sp,16
  if (!(*head))
    80001c46:	611c                	ld	a5,0(a0)
    80001c48:	cb89                	beqz	a5,80001c5a <pop+0x1a>
  *head = (*head)->next;
    80001c4a:	6798                	ld	a4,8(a5)
    80001c4c:	e118                	sd	a4,0(a0)
  struct proc *ret = del->p;
    80001c4e:	6388                	ld	a0,0(a5)
  del->p = 0;
    80001c50:	0007b023          	sd	zero,0(a5)
}
    80001c54:	6422                	ld	s0,8(sp)
    80001c56:	0141                	addi	sp,sp,16
    80001c58:	8082                	ret
    return 0;
    80001c5a:	853e                	mv	a0,a5
    80001c5c:	bfe5                	j	80001c54 <pop+0x14>

0000000080001c5e <remove>:
{
    80001c5e:	1141                	addi	sp,sp,-16
    80001c60:	e422                	sd	s0,8(sp)
    80001c62:	0800                	addi	s0,sp,16
  if ((*head)->p->pid == pid)
    80001c64:	611c                	ld	a5,0(a0)
    80001c66:	6398                	ld	a4,0(a5)
    80001c68:	5b18                	lw	a4,48(a4)
    80001c6a:	02b70063          	beq	a4,a1,80001c8a <remove+0x2c>
    80001c6e:	86be                	mv	a3,a5
  while (cur && cur->next)
    80001c70:	679c                	ld	a5,8(a5)
    80001c72:	cb89                	beqz	a5,80001c84 <remove+0x26>
    if (cur->next->p->pid == pid)
    80001c74:	6398                	ld	a4,0(a5)
    80001c76:	5b18                	lw	a4,48(a4)
    80001c78:	feb71be3          	bne	a4,a1,80001c6e <remove+0x10>
      cur->next = del->next;
    80001c7c:	6798                	ld	a4,8(a5)
    80001c7e:	e698                	sd	a4,8(a3)
      del->p = 0;
    80001c80:	0007b023          	sd	zero,0(a5)
}
    80001c84:	6422                	ld	s0,8(sp)
    80001c86:	0141                	addi	sp,sp,16
    80001c88:	8082                	ret
    (*head)->p = 0;
    80001c8a:	0007b023          	sd	zero,0(a5)
    *head = (*head)->next;
    80001c8e:	611c                	ld	a5,0(a0)
    80001c90:	679c                	ld	a5,8(a5)
    80001c92:	e11c                	sd	a5,0(a0)
    return;
    80001c94:	bfc5                	j	80001c84 <remove+0x26>

0000000080001c96 <proc_pagetable>:
{
    80001c96:	1101                	addi	sp,sp,-32
    80001c98:	ec06                	sd	ra,24(sp)
    80001c9a:	e822                	sd	s0,16(sp)
    80001c9c:	e426                	sd	s1,8(sp)
    80001c9e:	e04a                	sd	s2,0(sp)
    80001ca0:	1000                	addi	s0,sp,32
    80001ca2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	7c4080e7          	jalr	1988(ra) # 80001468 <uvmcreate>
    80001cac:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001cae:	c121                	beqz	a0,80001cee <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001cb0:	4729                	li	a4,10
    80001cb2:	00005697          	auipc	a3,0x5
    80001cb6:	34e68693          	addi	a3,a3,846 # 80007000 <_trampoline>
    80001cba:	6605                	lui	a2,0x1
    80001cbc:	040005b7          	lui	a1,0x4000
    80001cc0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cc2:	05b2                	slli	a1,a1,0xc
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	51a080e7          	jalr	1306(ra) # 800011de <mappages>
    80001ccc:	02054863          	bltz	a0,80001cfc <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001cd0:	4719                	li	a4,6
    80001cd2:	05893683          	ld	a3,88(s2)
    80001cd6:	6605                	lui	a2,0x1
    80001cd8:	020005b7          	lui	a1,0x2000
    80001cdc:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cde:	05b6                	slli	a1,a1,0xd
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	4fc080e7          	jalr	1276(ra) # 800011de <mappages>
    80001cea:	02054163          	bltz	a0,80001d0c <proc_pagetable+0x76>
}
    80001cee:	8526                	mv	a0,s1
    80001cf0:	60e2                	ld	ra,24(sp)
    80001cf2:	6442                	ld	s0,16(sp)
    80001cf4:	64a2                	ld	s1,8(sp)
    80001cf6:	6902                	ld	s2,0(sp)
    80001cf8:	6105                	addi	sp,sp,32
    80001cfa:	8082                	ret
    uvmfree(pagetable, 0);
    80001cfc:	4581                	li	a1,0
    80001cfe:	8526                	mv	a0,s1
    80001d00:	00000097          	auipc	ra,0x0
    80001d04:	96e080e7          	jalr	-1682(ra) # 8000166e <uvmfree>
    return 0;
    80001d08:	4481                	li	s1,0
    80001d0a:	b7d5                	j	80001cee <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d0c:	4681                	li	a3,0
    80001d0e:	4605                	li	a2,1
    80001d10:	040005b7          	lui	a1,0x4000
    80001d14:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d16:	05b2                	slli	a1,a1,0xc
    80001d18:	8526                	mv	a0,s1
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	68a080e7          	jalr	1674(ra) # 800013a4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001d22:	4581                	li	a1,0
    80001d24:	8526                	mv	a0,s1
    80001d26:	00000097          	auipc	ra,0x0
    80001d2a:	948080e7          	jalr	-1720(ra) # 8000166e <uvmfree>
    return 0;
    80001d2e:	4481                	li	s1,0
    80001d30:	bf7d                	j	80001cee <proc_pagetable+0x58>

0000000080001d32 <proc_freepagetable>:
{
    80001d32:	1101                	addi	sp,sp,-32
    80001d34:	ec06                	sd	ra,24(sp)
    80001d36:	e822                	sd	s0,16(sp)
    80001d38:	e426                	sd	s1,8(sp)
    80001d3a:	e04a                	sd	s2,0(sp)
    80001d3c:	1000                	addi	s0,sp,32
    80001d3e:	84aa                	mv	s1,a0
    80001d40:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d42:	4681                	li	a3,0
    80001d44:	4605                	li	a2,1
    80001d46:	040005b7          	lui	a1,0x4000
    80001d4a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d4c:	05b2                	slli	a1,a1,0xc
    80001d4e:	fffff097          	auipc	ra,0xfffff
    80001d52:	656080e7          	jalr	1622(ra) # 800013a4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d56:	4681                	li	a3,0
    80001d58:	4605                	li	a2,1
    80001d5a:	020005b7          	lui	a1,0x2000
    80001d5e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d60:	05b6                	slli	a1,a1,0xd
    80001d62:	8526                	mv	a0,s1
    80001d64:	fffff097          	auipc	ra,0xfffff
    80001d68:	640080e7          	jalr	1600(ra) # 800013a4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d6c:	85ca                	mv	a1,s2
    80001d6e:	8526                	mv	a0,s1
    80001d70:	00000097          	auipc	ra,0x0
    80001d74:	8fe080e7          	jalr	-1794(ra) # 8000166e <uvmfree>
}
    80001d78:	60e2                	ld	ra,24(sp)
    80001d7a:	6442                	ld	s0,16(sp)
    80001d7c:	64a2                	ld	s1,8(sp)
    80001d7e:	6902                	ld	s2,0(sp)
    80001d80:	6105                	addi	sp,sp,32
    80001d82:	8082                	ret

0000000080001d84 <freeproc>:
{
    80001d84:	1101                	addi	sp,sp,-32
    80001d86:	ec06                	sd	ra,24(sp)
    80001d88:	e822                	sd	s0,16(sp)
    80001d8a:	e426                	sd	s1,8(sp)
    80001d8c:	1000                	addi	s0,sp,32
    80001d8e:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001d90:	6d28                	ld	a0,88(a0)
    80001d92:	c509                	beqz	a0,80001d9c <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	cd0080e7          	jalr	-816(ra) # 80000a64 <kfree>
  if (p->tf_copy)
    80001d9c:	1d04b503          	ld	a0,464(s1)
    80001da0:	c509                	beqz	a0,80001daa <freeproc+0x26>
    kfree((void *)p->tf_copy);
    80001da2:	fffff097          	auipc	ra,0xfffff
    80001da6:	cc2080e7          	jalr	-830(ra) # 80000a64 <kfree>
  p->trapframe = 0;
    80001daa:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001dae:	68a8                	ld	a0,80(s1)
    80001db0:	c511                	beqz	a0,80001dbc <freeproc+0x38>
    proc_freepagetable(p->pagetable, p->sz);
    80001db2:	64ac                	ld	a1,72(s1)
    80001db4:	00000097          	auipc	ra,0x0
    80001db8:	f7e080e7          	jalr	-130(ra) # 80001d32 <proc_freepagetable>
  p->pagetable = 0;
    80001dbc:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001dc0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001dc4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001dc8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001dcc:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001dd0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001dd4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001dd8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ddc:	0004ac23          	sw	zero,24(s1)
}
    80001de0:	60e2                	ld	ra,24(sp)
    80001de2:	6442                	ld	s0,16(sp)
    80001de4:	64a2                	ld	s1,8(sp)
    80001de6:	6105                	addi	sp,sp,32
    80001de8:	8082                	ret

0000000080001dea <allocproc>:
{
    80001dea:	1101                	addi	sp,sp,-32
    80001dec:	ec06                	sd	ra,24(sp)
    80001dee:	e822                	sd	s0,16(sp)
    80001df0:	e426                	sd	s1,8(sp)
    80001df2:	e04a                	sd	s2,0(sp)
    80001df4:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001df6:	00230497          	auipc	s1,0x230
    80001dfa:	8da48493          	addi	s1,s1,-1830 # 802316d0 <proc>
    80001dfe:	00237917          	auipc	s2,0x237
    80001e02:	0d290913          	addi	s2,s2,210 # 80238ed0 <queues>
    acquire(&p->lock);
    80001e06:	8526                	mv	a0,s1
    80001e08:	fffff097          	auipc	ra,0xfffff
    80001e0c:	f0e080e7          	jalr	-242(ra) # 80000d16 <acquire>
    if (p->state == UNUSED)
    80001e10:	4c9c                	lw	a5,24(s1)
    80001e12:	cf81                	beqz	a5,80001e2a <allocproc+0x40>
      release(&p->lock);
    80001e14:	8526                	mv	a0,s1
    80001e16:	fffff097          	auipc	ra,0xfffff
    80001e1a:	fb4080e7          	jalr	-76(ra) # 80000dca <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001e1e:	1e048493          	addi	s1,s1,480
    80001e22:	ff2492e3          	bne	s1,s2,80001e06 <allocproc+0x1c>
  return 0;
    80001e26:	4481                	li	s1,0
    80001e28:	a845                	j	80001ed8 <allocproc+0xee>
  p->pid = allocpid();
    80001e2a:	00000097          	auipc	ra,0x0
    80001e2e:	d84080e7          	jalr	-636(ra) # 80001bae <allocpid>
    80001e32:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001e34:	4785                	li	a5,1
    80001e36:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	db0080e7          	jalr	-592(ra) # 80000be8 <kalloc>
    80001e40:	892a                	mv	s2,a0
    80001e42:	eca8                	sd	a0,88(s1)
    80001e44:	c14d                	beqz	a0,80001ee6 <allocproc+0xfc>
  p->pagetable = proc_pagetable(p);
    80001e46:	8526                	mv	a0,s1
    80001e48:	00000097          	auipc	ra,0x0
    80001e4c:	e4e080e7          	jalr	-434(ra) # 80001c96 <proc_pagetable>
    80001e50:	892a                	mv	s2,a0
    80001e52:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001e54:	c54d                	beqz	a0,80001efe <allocproc+0x114>
  memset(&p->context, 0, sizeof(p->context));
    80001e56:	07000613          	li	a2,112
    80001e5a:	4581                	li	a1,0
    80001e5c:	06048513          	addi	a0,s1,96
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	fb2080e7          	jalr	-78(ra) # 80000e12 <memset>
  p->context.ra = (uint64)forkret;
    80001e68:	00000797          	auipc	a5,0x0
    80001e6c:	d0078793          	addi	a5,a5,-768 # 80001b68 <forkret>
    80001e70:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e72:	60bc                	ld	a5,64(s1)
    80001e74:	6705                	lui	a4,0x1
    80001e76:	97ba                	add	a5,a5,a4
    80001e78:	f4bc                	sd	a5,104(s1)
  if ((p->tf_copy = (struct trapframe *)kalloc()) == 0)
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	d6e080e7          	jalr	-658(ra) # 80000be8 <kalloc>
    80001e82:	892a                	mv	s2,a0
    80001e84:	1ca4b823          	sd	a0,464(s1)
    80001e88:	c559                	beqz	a0,80001f16 <allocproc+0x12c>
  p->readid = 0;
    80001e8a:	1c04ac23          	sw	zero,472(s1)
  p->starttime = ticks; // initialise starting time of process
    80001e8e:	00007797          	auipc	a5,0x7
    80001e92:	da27a783          	lw	a5,-606(a5) # 80008c30 <ticks>
    80001e96:	16f4a623          	sw	a5,364(s1)
  p->runtime = 0;
    80001e9a:	1604aa23          	sw	zero,372(s1)
  p->sleeptime = 0;
    80001e9e:	1604ac23          	sw	zero,376(s1)
  p->wTime = 0;
    80001ea2:	1804a023          	sw	zero,384(s1)
  p->is_sigalarm = 0;
    80001ea6:	1a04aa23          	sw	zero,436(s1)
  p->alarmhandler = 0; // function
    80001eaa:	1c04b023          	sd	zero,448(s1)
  p->alarmint = 0;     // alarm interval
    80001eae:	1a04ac23          	sw	zero,440(s1)
  p->tslalarm = 0;     // time since last alarm
    80001eb2:	1c04a423          	sw	zero,456(s1)
  p->tickets = 1; // by default each process has 1 ticket
    80001eb6:	4785                	li	a5,1
    80001eb8:	16f4a823          	sw	a5,368(s1)
  p->niceness = 5; // default
    80001ebc:	4795                	li	a5,5
    80001ebe:	16f4ae23          	sw	a5,380(s1)
  p->rbi = 25;
    80001ec2:	47e5                	li	a5,25
    80001ec4:	18f4a223          	sw	a5,388(s1)
  p->stpriority = 50; // static priority
    80001ec8:	03200793          	li	a5,50
    80001ecc:	18f4a423          	sw	a5,392(s1)
  p->numpicked = 0;   // number of times picked by scheduler
    80001ed0:	1804a623          	sw	zero,396(s1)
  p->etime = 0;
    80001ed4:	1c04ae23          	sw	zero,476(s1)
}
    80001ed8:	8526                	mv	a0,s1
    80001eda:	60e2                	ld	ra,24(sp)
    80001edc:	6442                	ld	s0,16(sp)
    80001ede:	64a2                	ld	s1,8(sp)
    80001ee0:	6902                	ld	s2,0(sp)
    80001ee2:	6105                	addi	sp,sp,32
    80001ee4:	8082                	ret
    freeproc(p);
    80001ee6:	8526                	mv	a0,s1
    80001ee8:	00000097          	auipc	ra,0x0
    80001eec:	e9c080e7          	jalr	-356(ra) # 80001d84 <freeproc>
    release(&p->lock);
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	fffff097          	auipc	ra,0xfffff
    80001ef6:	ed8080e7          	jalr	-296(ra) # 80000dca <release>
    return 0;
    80001efa:	84ca                	mv	s1,s2
    80001efc:	bff1                	j	80001ed8 <allocproc+0xee>
    freeproc(p);
    80001efe:	8526                	mv	a0,s1
    80001f00:	00000097          	auipc	ra,0x0
    80001f04:	e84080e7          	jalr	-380(ra) # 80001d84 <freeproc>
    release(&p->lock);
    80001f08:	8526                	mv	a0,s1
    80001f0a:	fffff097          	auipc	ra,0xfffff
    80001f0e:	ec0080e7          	jalr	-320(ra) # 80000dca <release>
    return 0;
    80001f12:	84ca                	mv	s1,s2
    80001f14:	b7d1                	j	80001ed8 <allocproc+0xee>
    release(&p->lock);
    80001f16:	8526                	mv	a0,s1
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	eb2080e7          	jalr	-334(ra) # 80000dca <release>
    return 0;
    80001f20:	84ca                	mv	s1,s2
    80001f22:	bf5d                	j	80001ed8 <allocproc+0xee>

0000000080001f24 <userinit>:
{
    80001f24:	1101                	addi	sp,sp,-32
    80001f26:	ec06                	sd	ra,24(sp)
    80001f28:	e822                	sd	s0,16(sp)
    80001f2a:	e426                	sd	s1,8(sp)
    80001f2c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f2e:	00000097          	auipc	ra,0x0
    80001f32:	ebc080e7          	jalr	-324(ra) # 80001dea <allocproc>
    80001f36:	84aa                	mv	s1,a0
  initproc = p;
    80001f38:	00007797          	auipc	a5,0x7
    80001f3c:	cea7b823          	sd	a0,-784(a5) # 80008c28 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f40:	03400613          	li	a2,52
    80001f44:	00007597          	auipc	a1,0x7
    80001f48:	bec58593          	addi	a1,a1,-1044 # 80008b30 <initcode>
    80001f4c:	6928                	ld	a0,80(a0)
    80001f4e:	fffff097          	auipc	ra,0xfffff
    80001f52:	548080e7          	jalr	1352(ra) # 80001496 <uvmfirst>
  p->sz = PGSIZE;
    80001f56:	6785                	lui	a5,0x1
    80001f58:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001f5a:	6cb8                	ld	a4,88(s1)
    80001f5c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001f60:	6cb8                	ld	a4,88(s1)
    80001f62:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f64:	4641                	li	a2,16
    80001f66:	00006597          	auipc	a1,0x6
    80001f6a:	2da58593          	addi	a1,a1,730 # 80008240 <digits+0x200>
    80001f6e:	15848513          	addi	a0,s1,344
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	fea080e7          	jalr	-22(ra) # 80000f5c <safestrcpy>
  p->cwd = namei("/");
    80001f7a:	00006517          	auipc	a0,0x6
    80001f7e:	2d650513          	addi	a0,a0,726 # 80008250 <digits+0x210>
    80001f82:	00003097          	auipc	ra,0x3
    80001f86:	8c6080e7          	jalr	-1850(ra) # 80004848 <namei>
    80001f8a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f8e:	478d                	li	a5,3
    80001f90:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001f92:	8526                	mv	a0,s1
    80001f94:	fffff097          	auipc	ra,0xfffff
    80001f98:	e36080e7          	jalr	-458(ra) # 80000dca <release>
}
    80001f9c:	60e2                	ld	ra,24(sp)
    80001f9e:	6442                	ld	s0,16(sp)
    80001fa0:	64a2                	ld	s1,8(sp)
    80001fa2:	6105                	addi	sp,sp,32
    80001fa4:	8082                	ret

0000000080001fa6 <growproc>:
{
    80001fa6:	1101                	addi	sp,sp,-32
    80001fa8:	ec06                	sd	ra,24(sp)
    80001faa:	e822                	sd	s0,16(sp)
    80001fac:	e426                	sd	s1,8(sp)
    80001fae:	e04a                	sd	s2,0(sp)
    80001fb0:	1000                	addi	s0,sp,32
    80001fb2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001fb4:	00000097          	auipc	ra,0x0
    80001fb8:	b7c080e7          	jalr	-1156(ra) # 80001b30 <myproc>
    80001fbc:	84aa                	mv	s1,a0
  sz = p->sz;
    80001fbe:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001fc0:	01204c63          	bgtz	s2,80001fd8 <growproc+0x32>
  else if (n < 0)
    80001fc4:	02094663          	bltz	s2,80001ff0 <growproc+0x4a>
  p->sz = sz;
    80001fc8:	e4ac                	sd	a1,72(s1)
  return 0;
    80001fca:	4501                	li	a0,0
}
    80001fcc:	60e2                	ld	ra,24(sp)
    80001fce:	6442                	ld	s0,16(sp)
    80001fd0:	64a2                	ld	s1,8(sp)
    80001fd2:	6902                	ld	s2,0(sp)
    80001fd4:	6105                	addi	sp,sp,32
    80001fd6:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001fd8:	4691                	li	a3,4
    80001fda:	00b90633          	add	a2,s2,a1
    80001fde:	6928                	ld	a0,80(a0)
    80001fe0:	fffff097          	auipc	ra,0xfffff
    80001fe4:	570080e7          	jalr	1392(ra) # 80001550 <uvmalloc>
    80001fe8:	85aa                	mv	a1,a0
    80001fea:	fd79                	bnez	a0,80001fc8 <growproc+0x22>
      return -1;
    80001fec:	557d                	li	a0,-1
    80001fee:	bff9                	j	80001fcc <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ff0:	00b90633          	add	a2,s2,a1
    80001ff4:	6928                	ld	a0,80(a0)
    80001ff6:	fffff097          	auipc	ra,0xfffff
    80001ffa:	512080e7          	jalr	1298(ra) # 80001508 <uvmdealloc>
    80001ffe:	85aa                	mv	a1,a0
    80002000:	b7e1                	j	80001fc8 <growproc+0x22>

0000000080002002 <fork>:
{
    80002002:	7139                	addi	sp,sp,-64
    80002004:	fc06                	sd	ra,56(sp)
    80002006:	f822                	sd	s0,48(sp)
    80002008:	f426                	sd	s1,40(sp)
    8000200a:	f04a                	sd	s2,32(sp)
    8000200c:	ec4e                	sd	s3,24(sp)
    8000200e:	e852                	sd	s4,16(sp)
    80002010:	e456                	sd	s5,8(sp)
    80002012:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002014:	00000097          	auipc	ra,0x0
    80002018:	b1c080e7          	jalr	-1252(ra) # 80001b30 <myproc>
    8000201c:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    8000201e:	00000097          	auipc	ra,0x0
    80002022:	dcc080e7          	jalr	-564(ra) # 80001dea <allocproc>
    80002026:	12050463          	beqz	a0,8000214e <fork+0x14c>
    8000202a:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    8000202c:	048ab603          	ld	a2,72(s5)
    80002030:	692c                	ld	a1,80(a0)
    80002032:	050ab503          	ld	a0,80(s5)
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	672080e7          	jalr	1650(ra) # 800016a8 <uvmcopy>
    8000203e:	06054063          	bltz	a0,8000209e <fork+0x9c>
  np->sz = p->sz;
    80002042:	048ab783          	ld	a5,72(s5)
    80002046:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    8000204a:	058ab683          	ld	a3,88(s5)
    8000204e:	87b6                	mv	a5,a3
    80002050:	0589b703          	ld	a4,88(s3)
    80002054:	12068693          	addi	a3,a3,288
    80002058:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000205c:	6788                	ld	a0,8(a5)
    8000205e:	6b8c                	ld	a1,16(a5)
    80002060:	6f90                	ld	a2,24(a5)
    80002062:	01073023          	sd	a6,0(a4)
    80002066:	e708                	sd	a0,8(a4)
    80002068:	eb0c                	sd	a1,16(a4)
    8000206a:	ef10                	sd	a2,24(a4)
    8000206c:	02078793          	addi	a5,a5,32
    80002070:	02070713          	addi	a4,a4,32
    80002074:	fed792e3          	bne	a5,a3,80002058 <fork+0x56>
  np->mask = p->mask;       // copy mask
    80002078:	168aa783          	lw	a5,360(s5)
    8000207c:	16f9a423          	sw	a5,360(s3)
  np->tickets = p->tickets; // child should have same number of tickets
    80002080:	170aa783          	lw	a5,368(s5)
    80002084:	16f9a823          	sw	a5,368(s3)
  np->trapframe->a0 = 0;
    80002088:	0589b783          	ld	a5,88(s3)
    8000208c:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002090:	0d0a8493          	addi	s1,s5,208
    80002094:	0d098913          	addi	s2,s3,208
    80002098:	150a8a13          	addi	s4,s5,336
    8000209c:	a00d                	j	800020be <fork+0xbc>
    freeproc(np);
    8000209e:	854e                	mv	a0,s3
    800020a0:	00000097          	auipc	ra,0x0
    800020a4:	ce4080e7          	jalr	-796(ra) # 80001d84 <freeproc>
    release(&np->lock);
    800020a8:	854e                	mv	a0,s3
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	d20080e7          	jalr	-736(ra) # 80000dca <release>
    return -1;
    800020b2:	597d                	li	s2,-1
    800020b4:	a059                	j	8000213a <fork+0x138>
  for (i = 0; i < NOFILE; i++)
    800020b6:	04a1                	addi	s1,s1,8
    800020b8:	0921                	addi	s2,s2,8
    800020ba:	01448b63          	beq	s1,s4,800020d0 <fork+0xce>
    if (p->ofile[i])
    800020be:	6088                	ld	a0,0(s1)
    800020c0:	d97d                	beqz	a0,800020b6 <fork+0xb4>
      np->ofile[i] = filedup(p->ofile[i]);
    800020c2:	00003097          	auipc	ra,0x3
    800020c6:	e1c080e7          	jalr	-484(ra) # 80004ede <filedup>
    800020ca:	00a93023          	sd	a0,0(s2)
    800020ce:	b7e5                	j	800020b6 <fork+0xb4>
  np->cwd = idup(p->cwd);
    800020d0:	150ab503          	ld	a0,336(s5)
    800020d4:	00002097          	auipc	ra,0x2
    800020d8:	f8a080e7          	jalr	-118(ra) # 8000405e <idup>
    800020dc:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020e0:	4641                	li	a2,16
    800020e2:	158a8593          	addi	a1,s5,344
    800020e6:	15898513          	addi	a0,s3,344
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	e72080e7          	jalr	-398(ra) # 80000f5c <safestrcpy>
  pid = np->pid;
    800020f2:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    800020f6:	854e                	mv	a0,s3
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	cd2080e7          	jalr	-814(ra) # 80000dca <release>
  acquire(&wait_lock);
    80002100:	0022f497          	auipc	s1,0x22f
    80002104:	db848493          	addi	s1,s1,-584 # 80230eb8 <wait_lock>
    80002108:	8526                	mv	a0,s1
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	c0c080e7          	jalr	-1012(ra) # 80000d16 <acquire>
  np->parent = p;
    80002112:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002116:	8526                	mv	a0,s1
    80002118:	fffff097          	auipc	ra,0xfffff
    8000211c:	cb2080e7          	jalr	-846(ra) # 80000dca <release>
  acquire(&np->lock);
    80002120:	854e                	mv	a0,s3
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	bf4080e7          	jalr	-1036(ra) # 80000d16 <acquire>
  np->state = RUNNABLE;
    8000212a:	478d                	li	a5,3
    8000212c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002130:	854e                	mv	a0,s3
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	c98080e7          	jalr	-872(ra) # 80000dca <release>
}
    8000213a:	854a                	mv	a0,s2
    8000213c:	70e2                	ld	ra,56(sp)
    8000213e:	7442                	ld	s0,48(sp)
    80002140:	74a2                	ld	s1,40(sp)
    80002142:	7902                	ld	s2,32(sp)
    80002144:	69e2                	ld	s3,24(sp)
    80002146:	6a42                	ld	s4,16(sp)
    80002148:	6aa2                	ld	s5,8(sp)
    8000214a:	6121                	addi	sp,sp,64
    8000214c:	8082                	ret
    return -1;
    8000214e:	597d                	li	s2,-1
    80002150:	b7ed                	j	8000213a <fork+0x138>

0000000080002152 <scheduler>:
{
    80002152:	711d                	addi	sp,sp,-96
    80002154:	ec86                	sd	ra,88(sp)
    80002156:	e8a2                	sd	s0,80(sp)
    80002158:	e4a6                	sd	s1,72(sp)
    8000215a:	e0ca                	sd	s2,64(sp)
    8000215c:	fc4e                	sd	s3,56(sp)
    8000215e:	f852                	sd	s4,48(sp)
    80002160:	f456                	sd	s5,40(sp)
    80002162:	f05a                	sd	s6,32(sp)
    80002164:	ec5e                	sd	s7,24(sp)
    80002166:	e862                	sd	s8,16(sp)
    80002168:	e466                	sd	s9,8(sp)
    8000216a:	1080                	addi	s0,sp,96
    8000216c:	8992                	mv	s3,tp
  int id = r_tp();
    8000216e:	2981                	sext.w	s3,s3
  c->proc = 0;
    80002170:	00799c13          	slli	s8,s3,0x7
    80002174:	0022f797          	auipc	a5,0x22f
    80002178:	d2c78793          	addi	a5,a5,-724 # 80230ea0 <pid_lock>
    8000217c:	97e2                	add	a5,a5,s8
    8000217e:	0207b823          	sd	zero,48(a5)
  printf("Scheduler : PBS\n");
    80002182:	00006517          	auipc	a0,0x6
    80002186:	0d650513          	addi	a0,a0,214 # 80008258 <digits+0x218>
    8000218a:	ffffe097          	auipc	ra,0xffffe
    8000218e:	400080e7          	jalr	1024(ra) # 8000058a <printf>
      swtch(&c->context, &chosenproc->context);
    80002192:	0022f797          	auipc	a5,0x22f
    80002196:	d4678793          	addi	a5,a5,-698 # 80230ed8 <cpus+0x8>
    8000219a:	9c3e                	add	s8,s8,a5
    int min_dp = __INT32_MAX__;
    8000219c:	80000b37          	lui	s6,0x80000
    800021a0:	fffb4b13          	not	s6,s6
    struct proc *chosenproc = proc;
    800021a4:	0022fa97          	auipc	s5,0x22f
    800021a8:	52ca8a93          	addi	s5,s5,1324 # 802316d0 <proc>
      if (p->state == RUNNABLE)
    800021ac:	448d                	li	s1,3
        int dp = min(p->stpriority + p->rbi, 100); 
    800021ae:	06400a13          	li	s4,100
    for (p = proc; p < &proc[NPROC]; p++)
    800021b2:	00237917          	auipc	s2,0x237
    800021b6:	d1e90913          	addi	s2,s2,-738 # 80238ed0 <queues>
      c->proc = chosenproc;
    800021ba:	099e                	slli	s3,s3,0x7
    800021bc:	0022fb97          	auipc	s7,0x22f
    800021c0:	ce4b8b93          	addi	s7,s7,-796 # 80230ea0 <pid_lock>
    800021c4:	9bce                	add	s7,s7,s3
    800021c6:	a8c1                	j	80002296 <scheduler+0x144>
          min_dp = dp;
    800021c8:	86ba                	mv	a3,a4
    800021ca:	89be                	mv	s3,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800021cc:	1e078793          	addi	a5,a5,480
    800021d0:	05278663          	beq	a5,s2,8000221c <scheduler+0xca>
      if (p->state == RUNNABLE)
    800021d4:	4f98                	lw	a4,24(a5)
    800021d6:	fe971be3          	bne	a4,s1,800021cc <scheduler+0x7a>
        int dp = min(p->stpriority + p->rbi, 100); 
    800021da:	1887a603          	lw	a2,392(a5)
    800021de:	1847a703          	lw	a4,388(a5)
    800021e2:	9f31                	addw	a4,a4,a2
    800021e4:	0007061b          	sext.w	a2,a4
    800021e8:	00c5d363          	bge	a1,a2,800021ee <scheduler+0x9c>
    800021ec:	8752                	mv	a4,s4
    800021ee:	2701                	sext.w	a4,a4
        if (dp < min_dp)
    800021f0:	fcd74ce3          	blt	a4,a3,800021c8 <scheduler+0x76>
        else if (dp == min_dp)
    800021f4:	fcd71ce3          	bne	a4,a3,800021cc <scheduler+0x7a>
          if (p->numpicked < chosenproc->numpicked)
    800021f8:	18c7a603          	lw	a2,396(a5)
    800021fc:	18c9a703          	lw	a4,396(s3)
    80002200:	00e64c63          	blt	a2,a4,80002218 <scheduler+0xc6>
          else if (p->numpicked == chosenproc->numpicked)
    80002204:	fce614e3          	bne	a2,a4,800021cc <scheduler+0x7a>
            if (p->starttime < chosenproc->starttime)
    80002208:	16c7a603          	lw	a2,364(a5)
    8000220c:	16c9a703          	lw	a4,364(s3)
    80002210:	fae65ee3          	bge	a2,a4,800021cc <scheduler+0x7a>
    80002214:	89be                	mv	s3,a5
    80002216:	bf5d                	j	800021cc <scheduler+0x7a>
    80002218:	89be                	mv	s3,a5
    8000221a:	bf4d                	j	800021cc <scheduler+0x7a>
    acquire(&chosenproc->lock);
    8000221c:	8cce                	mv	s9,s3
    8000221e:	854e                	mv	a0,s3
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	af6080e7          	jalr	-1290(ra) # 80000d16 <acquire>
    if (chosenproc->state == RUNNABLE)
    80002228:	0189a783          	lw	a5,24(s3)
    8000222c:	02979563          	bne	a5,s1,80002256 <scheduler+0x104>
      chosenproc->state = RUNNING;
    80002230:	4791                	li	a5,4
    80002232:	00f9ac23          	sw	a5,24(s3)
      chosenproc->numpicked++; // increment the number of times process is picked
    80002236:	18c9a783          	lw	a5,396(s3)
    8000223a:	2785                	addiw	a5,a5,1
    8000223c:	18f9a623          	sw	a5,396(s3)
      c->proc = chosenproc;
    80002240:	033bb823          	sd	s3,48(s7)
      swtch(&c->context, &chosenproc->context);
    80002244:	06098593          	addi	a1,s3,96
    80002248:	8562                	mv	a0,s8
    8000224a:	00001097          	auipc	ra,0x1
    8000224e:	8be080e7          	jalr	-1858(ra) # 80002b08 <swtch>
      c->proc = 0;
    80002252:	020bb823          	sd	zero,48(s7)
    release(&chosenproc->lock);
    80002256:	8566                	mv	a0,s9
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	b72080e7          	jalr	-1166(ra) # 80000dca <release>
    chosenproc->rbi = max(3 * chosenproc->runtime - chosenproc->sleeptime - chosenproc->wTime / chosenproc->runtime + chosenproc->wTime + chosenproc->sleeptime + 1 * 50, 0);
    80002260:	1749a703          	lw	a4,372(s3)
    80002264:	1789a683          	lw	a3,376(s3)
    80002268:	1809a603          	lw	a2,384(s3)
    8000226c:	0017179b          	slliw	a5,a4,0x1
    80002270:	9fb9                	addw	a5,a5,a4
    80002272:	9f95                	subw	a5,a5,a3
    80002274:	02e6473b          	divw	a4,a2,a4
    80002278:	9f99                	subw	a5,a5,a4
    8000227a:	9fb1                	addw	a5,a5,a2
    8000227c:	9fb5                	addw	a5,a5,a3
    8000227e:	0007869b          	sext.w	a3,a5
    80002282:	fce00713          	li	a4,-50
    80002286:	00e6d463          	bge	a3,a4,8000228e <scheduler+0x13c>
    8000228a:	fce00793          	li	a5,-50
    8000228e:	0327879b          	addiw	a5,a5,50
    80002292:	18f9a223          	sw	a5,388(s3)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002296:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000229a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000229e:	10079073          	csrw	sstatus,a5
    int min_dp = __INT32_MAX__;
    800022a2:	86da                	mv	a3,s6
    struct proc *chosenproc = proc;
    800022a4:	89d6                	mv	s3,s5
    for (p = proc; p < &proc[NPROC]; p++)
    800022a6:	87d6                	mv	a5,s5
        int dp = min(p->stpriority + p->rbi, 100); 
    800022a8:	06400593          	li	a1,100
    800022ac:	b725                	j	800021d4 <scheduler+0x82>

00000000800022ae <sched>:
{
    800022ae:	7179                	addi	sp,sp,-48
    800022b0:	f406                	sd	ra,40(sp)
    800022b2:	f022                	sd	s0,32(sp)
    800022b4:	ec26                	sd	s1,24(sp)
    800022b6:	e84a                	sd	s2,16(sp)
    800022b8:	e44e                	sd	s3,8(sp)
    800022ba:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800022bc:	00000097          	auipc	ra,0x0
    800022c0:	874080e7          	jalr	-1932(ra) # 80001b30 <myproc>
    800022c4:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	9d6080e7          	jalr	-1578(ra) # 80000c9c <holding>
    800022ce:	c93d                	beqz	a0,80002344 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022d0:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800022d2:	2781                	sext.w	a5,a5
    800022d4:	079e                	slli	a5,a5,0x7
    800022d6:	0022f717          	auipc	a4,0x22f
    800022da:	bca70713          	addi	a4,a4,-1078 # 80230ea0 <pid_lock>
    800022de:	97ba                	add	a5,a5,a4
    800022e0:	0a87a703          	lw	a4,168(a5)
    800022e4:	4785                	li	a5,1
    800022e6:	06f71763          	bne	a4,a5,80002354 <sched+0xa6>
  if (p->state == RUNNING)
    800022ea:	4c98                	lw	a4,24(s1)
    800022ec:	4791                	li	a5,4
    800022ee:	06f70b63          	beq	a4,a5,80002364 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022f2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022f6:	8b89                	andi	a5,a5,2
  if (intr_get())
    800022f8:	efb5                	bnez	a5,80002374 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022fa:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800022fc:	0022f917          	auipc	s2,0x22f
    80002300:	ba490913          	addi	s2,s2,-1116 # 80230ea0 <pid_lock>
    80002304:	2781                	sext.w	a5,a5
    80002306:	079e                	slli	a5,a5,0x7
    80002308:	97ca                	add	a5,a5,s2
    8000230a:	0ac7a983          	lw	s3,172(a5)
    8000230e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002310:	2781                	sext.w	a5,a5
    80002312:	079e                	slli	a5,a5,0x7
    80002314:	0022f597          	auipc	a1,0x22f
    80002318:	bc458593          	addi	a1,a1,-1084 # 80230ed8 <cpus+0x8>
    8000231c:	95be                	add	a1,a1,a5
    8000231e:	06048513          	addi	a0,s1,96
    80002322:	00000097          	auipc	ra,0x0
    80002326:	7e6080e7          	jalr	2022(ra) # 80002b08 <swtch>
    8000232a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000232c:	2781                	sext.w	a5,a5
    8000232e:	079e                	slli	a5,a5,0x7
    80002330:	993e                	add	s2,s2,a5
    80002332:	0b392623          	sw	s3,172(s2)
}
    80002336:	70a2                	ld	ra,40(sp)
    80002338:	7402                	ld	s0,32(sp)
    8000233a:	64e2                	ld	s1,24(sp)
    8000233c:	6942                	ld	s2,16(sp)
    8000233e:	69a2                	ld	s3,8(sp)
    80002340:	6145                	addi	sp,sp,48
    80002342:	8082                	ret
    panic("sched p->lock");
    80002344:	00006517          	auipc	a0,0x6
    80002348:	f2c50513          	addi	a0,a0,-212 # 80008270 <digits+0x230>
    8000234c:	ffffe097          	auipc	ra,0xffffe
    80002350:	1f4080e7          	jalr	500(ra) # 80000540 <panic>
    panic("sched locks");
    80002354:	00006517          	auipc	a0,0x6
    80002358:	f2c50513          	addi	a0,a0,-212 # 80008280 <digits+0x240>
    8000235c:	ffffe097          	auipc	ra,0xffffe
    80002360:	1e4080e7          	jalr	484(ra) # 80000540 <panic>
    panic("sched running");
    80002364:	00006517          	auipc	a0,0x6
    80002368:	f2c50513          	addi	a0,a0,-212 # 80008290 <digits+0x250>
    8000236c:	ffffe097          	auipc	ra,0xffffe
    80002370:	1d4080e7          	jalr	468(ra) # 80000540 <panic>
    panic("sched interruptible");
    80002374:	00006517          	auipc	a0,0x6
    80002378:	f2c50513          	addi	a0,a0,-212 # 800082a0 <digits+0x260>
    8000237c:	ffffe097          	auipc	ra,0xffffe
    80002380:	1c4080e7          	jalr	452(ra) # 80000540 <panic>

0000000080002384 <yield>:
{
    80002384:	1101                	addi	sp,sp,-32
    80002386:	ec06                	sd	ra,24(sp)
    80002388:	e822                	sd	s0,16(sp)
    8000238a:	e426                	sd	s1,8(sp)
    8000238c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	7a2080e7          	jalr	1954(ra) # 80001b30 <myproc>
    80002396:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	97e080e7          	jalr	-1666(ra) # 80000d16 <acquire>
  p->state = RUNNABLE;
    800023a0:	478d                	li	a5,3
    800023a2:	cc9c                	sw	a5,24(s1)
  sched();
    800023a4:	00000097          	auipc	ra,0x0
    800023a8:	f0a080e7          	jalr	-246(ra) # 800022ae <sched>
  release(&p->lock);
    800023ac:	8526                	mv	a0,s1
    800023ae:	fffff097          	auipc	ra,0xfffff
    800023b2:	a1c080e7          	jalr	-1508(ra) # 80000dca <release>
}
    800023b6:	60e2                	ld	ra,24(sp)
    800023b8:	6442                	ld	s0,16(sp)
    800023ba:	64a2                	ld	s1,8(sp)
    800023bc:	6105                	addi	sp,sp,32
    800023be:	8082                	ret

00000000800023c0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800023c0:	7179                	addi	sp,sp,-48
    800023c2:	f406                	sd	ra,40(sp)
    800023c4:	f022                	sd	s0,32(sp)
    800023c6:	ec26                	sd	s1,24(sp)
    800023c8:	e84a                	sd	s2,16(sp)
    800023ca:	e44e                	sd	s3,8(sp)
    800023cc:	1800                	addi	s0,sp,48
    800023ce:	89aa                	mv	s3,a0
    800023d0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	75e080e7          	jalr	1886(ra) # 80001b30 <myproc>
    800023da:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	93a080e7          	jalr	-1734(ra) # 80000d16 <acquire>
  release(lk);
    800023e4:	854a                	mv	a0,s2
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	9e4080e7          	jalr	-1564(ra) # 80000dca <release>

  // Go to sleep.
  p->chan = chan;
    800023ee:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800023f2:	4789                	li	a5,2
    800023f4:	cc9c                	sw	a5,24(s1)

  sched();
    800023f6:	00000097          	auipc	ra,0x0
    800023fa:	eb8080e7          	jalr	-328(ra) # 800022ae <sched>

  // Tidy up.
  p->chan = 0;
    800023fe:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002402:	8526                	mv	a0,s1
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	9c6080e7          	jalr	-1594(ra) # 80000dca <release>
  acquire(lk);
    8000240c:	854a                	mv	a0,s2
    8000240e:	fffff097          	auipc	ra,0xfffff
    80002412:	908080e7          	jalr	-1784(ra) # 80000d16 <acquire>
}
    80002416:	70a2                	ld	ra,40(sp)
    80002418:	7402                	ld	s0,32(sp)
    8000241a:	64e2                	ld	s1,24(sp)
    8000241c:	6942                	ld	s2,16(sp)
    8000241e:	69a2                	ld	s3,8(sp)
    80002420:	6145                	addi	sp,sp,48
    80002422:	8082                	ret

0000000080002424 <waitx>:
{
    80002424:	711d                	addi	sp,sp,-96
    80002426:	ec86                	sd	ra,88(sp)
    80002428:	e8a2                	sd	s0,80(sp)
    8000242a:	e4a6                	sd	s1,72(sp)
    8000242c:	e0ca                	sd	s2,64(sp)
    8000242e:	fc4e                	sd	s3,56(sp)
    80002430:	f852                	sd	s4,48(sp)
    80002432:	f456                	sd	s5,40(sp)
    80002434:	f05a                	sd	s6,32(sp)
    80002436:	ec5e                	sd	s7,24(sp)
    80002438:	e862                	sd	s8,16(sp)
    8000243a:	e466                	sd	s9,8(sp)
    8000243c:	e06a                	sd	s10,0(sp)
    8000243e:	1080                	addi	s0,sp,96
    80002440:	8b2a                	mv	s6,a0
    80002442:	8c2e                	mv	s8,a1
    80002444:	8bb2                	mv	s7,a2
  struct proc *p = myproc();
    80002446:	fffff097          	auipc	ra,0xfffff
    8000244a:	6ea080e7          	jalr	1770(ra) # 80001b30 <myproc>
    8000244e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002450:	0022f517          	auipc	a0,0x22f
    80002454:	a6850513          	addi	a0,a0,-1432 # 80230eb8 <wait_lock>
    80002458:	fffff097          	auipc	ra,0xfffff
    8000245c:	8be080e7          	jalr	-1858(ra) # 80000d16 <acquire>
    havekids = 0;
    80002460:	4c81                	li	s9,0
        if (np->state == ZOMBIE)
    80002462:	4a15                	li	s4,5
        havekids = 1;
    80002464:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002466:	00237997          	auipc	s3,0x237
    8000246a:	a6a98993          	addi	s3,s3,-1430 # 80238ed0 <queues>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000246e:	0022fd17          	auipc	s10,0x22f
    80002472:	a4ad0d13          	addi	s10,s10,-1462 # 80230eb8 <wait_lock>
    havekids = 0;
    80002476:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    80002478:	0022f497          	auipc	s1,0x22f
    8000247c:	25848493          	addi	s1,s1,600 # 802316d0 <proc>
    80002480:	a069                	j	8000250a <waitx+0xe6>
          pid = np->pid;
    80002482:	0304a983          	lw	s3,48(s1)
          *rtime = np->runtime;
    80002486:	1744a783          	lw	a5,372(s1)
    8000248a:	00fc2023          	sw	a5,0(s8) # 1000 <_entry-0x7ffff000>
          *wtime = np->etime - np->starttime - np->runtime;
    8000248e:	1dc4a783          	lw	a5,476(s1)
    80002492:	16c4a703          	lw	a4,364(s1)
    80002496:	9f99                	subw	a5,a5,a4
    80002498:	1744a703          	lw	a4,372(s1)
    8000249c:	9f99                	subw	a5,a5,a4
    8000249e:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800024a2:	000b0e63          	beqz	s6,800024be <waitx+0x9a>
    800024a6:	4691                	li	a3,4
    800024a8:	02c48613          	addi	a2,s1,44
    800024ac:	85da                	mv	a1,s6
    800024ae:	05093503          	ld	a0,80(s2)
    800024b2:	fffff097          	auipc	ra,0xfffff
    800024b6:	2e6080e7          	jalr	742(ra) # 80001798 <copyout>
    800024ba:	02054563          	bltz	a0,800024e4 <waitx+0xc0>
          freeproc(np);
    800024be:	8526                	mv	a0,s1
    800024c0:	00000097          	auipc	ra,0x0
    800024c4:	8c4080e7          	jalr	-1852(ra) # 80001d84 <freeproc>
          release(&np->lock);
    800024c8:	8526                	mv	a0,s1
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	900080e7          	jalr	-1792(ra) # 80000dca <release>
          release(&wait_lock);
    800024d2:	0022f517          	auipc	a0,0x22f
    800024d6:	9e650513          	addi	a0,a0,-1562 # 80230eb8 <wait_lock>
    800024da:	fffff097          	auipc	ra,0xfffff
    800024de:	8f0080e7          	jalr	-1808(ra) # 80000dca <release>
          return pid;
    800024e2:	a09d                	j	80002548 <waitx+0x124>
            release(&np->lock);
    800024e4:	8526                	mv	a0,s1
    800024e6:	fffff097          	auipc	ra,0xfffff
    800024ea:	8e4080e7          	jalr	-1820(ra) # 80000dca <release>
            release(&wait_lock);
    800024ee:	0022f517          	auipc	a0,0x22f
    800024f2:	9ca50513          	addi	a0,a0,-1590 # 80230eb8 <wait_lock>
    800024f6:	fffff097          	auipc	ra,0xfffff
    800024fa:	8d4080e7          	jalr	-1836(ra) # 80000dca <release>
            return -1;
    800024fe:	59fd                	li	s3,-1
    80002500:	a0a1                	j	80002548 <waitx+0x124>
    for (np = proc; np < &proc[NPROC]; np++)
    80002502:	1e048493          	addi	s1,s1,480
    80002506:	03348463          	beq	s1,s3,8000252e <waitx+0x10a>
      if (np->parent == p)
    8000250a:	7c9c                	ld	a5,56(s1)
    8000250c:	ff279be3          	bne	a5,s2,80002502 <waitx+0xde>
        acquire(&np->lock);
    80002510:	8526                	mv	a0,s1
    80002512:	fffff097          	auipc	ra,0xfffff
    80002516:	804080e7          	jalr	-2044(ra) # 80000d16 <acquire>
        if (np->state == ZOMBIE)
    8000251a:	4c9c                	lw	a5,24(s1)
    8000251c:	f74783e3          	beq	a5,s4,80002482 <waitx+0x5e>
        release(&np->lock);
    80002520:	8526                	mv	a0,s1
    80002522:	fffff097          	auipc	ra,0xfffff
    80002526:	8a8080e7          	jalr	-1880(ra) # 80000dca <release>
        havekids = 1;
    8000252a:	8756                	mv	a4,s5
    8000252c:	bfd9                	j	80002502 <waitx+0xde>
    if (!havekids || p->killed)
    8000252e:	c701                	beqz	a4,80002536 <waitx+0x112>
    80002530:	02892783          	lw	a5,40(s2)
    80002534:	cb8d                	beqz	a5,80002566 <waitx+0x142>
      release(&wait_lock);
    80002536:	0022f517          	auipc	a0,0x22f
    8000253a:	98250513          	addi	a0,a0,-1662 # 80230eb8 <wait_lock>
    8000253e:	fffff097          	auipc	ra,0xfffff
    80002542:	88c080e7          	jalr	-1908(ra) # 80000dca <release>
      return -1;
    80002546:	59fd                	li	s3,-1
}
    80002548:	854e                	mv	a0,s3
    8000254a:	60e6                	ld	ra,88(sp)
    8000254c:	6446                	ld	s0,80(sp)
    8000254e:	64a6                	ld	s1,72(sp)
    80002550:	6906                	ld	s2,64(sp)
    80002552:	79e2                	ld	s3,56(sp)
    80002554:	7a42                	ld	s4,48(sp)
    80002556:	7aa2                	ld	s5,40(sp)
    80002558:	7b02                	ld	s6,32(sp)
    8000255a:	6be2                	ld	s7,24(sp)
    8000255c:	6c42                	ld	s8,16(sp)
    8000255e:	6ca2                	ld	s9,8(sp)
    80002560:	6d02                	ld	s10,0(sp)
    80002562:	6125                	addi	sp,sp,96
    80002564:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002566:	85ea                	mv	a1,s10
    80002568:	854a                	mv	a0,s2
    8000256a:	00000097          	auipc	ra,0x0
    8000256e:	e56080e7          	jalr	-426(ra) # 800023c0 <sleep>
    havekids = 0;
    80002572:	b711                	j	80002476 <waitx+0x52>

0000000080002574 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002574:	7139                	addi	sp,sp,-64
    80002576:	fc06                	sd	ra,56(sp)
    80002578:	f822                	sd	s0,48(sp)
    8000257a:	f426                	sd	s1,40(sp)
    8000257c:	f04a                	sd	s2,32(sp)
    8000257e:	ec4e                	sd	s3,24(sp)
    80002580:	e852                	sd	s4,16(sp)
    80002582:	e456                	sd	s5,8(sp)
    80002584:	0080                	addi	s0,sp,64
    80002586:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002588:	0022f497          	auipc	s1,0x22f
    8000258c:	14848493          	addi	s1,s1,328 # 802316d0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002590:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002592:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002594:	00237917          	auipc	s2,0x237
    80002598:	93c90913          	addi	s2,s2,-1732 # 80238ed0 <queues>
    8000259c:	a811                	j	800025b0 <wakeup+0x3c>
      }
      release(&p->lock);
    8000259e:	8526                	mv	a0,s1
    800025a0:	fffff097          	auipc	ra,0xfffff
    800025a4:	82a080e7          	jalr	-2006(ra) # 80000dca <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800025a8:	1e048493          	addi	s1,s1,480
    800025ac:	03248663          	beq	s1,s2,800025d8 <wakeup+0x64>
    if (p != myproc())
    800025b0:	fffff097          	auipc	ra,0xfffff
    800025b4:	580080e7          	jalr	1408(ra) # 80001b30 <myproc>
    800025b8:	fea488e3          	beq	s1,a0,800025a8 <wakeup+0x34>
      acquire(&p->lock);
    800025bc:	8526                	mv	a0,s1
    800025be:	ffffe097          	auipc	ra,0xffffe
    800025c2:	758080e7          	jalr	1880(ra) # 80000d16 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800025c6:	4c9c                	lw	a5,24(s1)
    800025c8:	fd379be3          	bne	a5,s3,8000259e <wakeup+0x2a>
    800025cc:	709c                	ld	a5,32(s1)
    800025ce:	fd4798e3          	bne	a5,s4,8000259e <wakeup+0x2a>
        p->state = RUNNABLE;
    800025d2:	0154ac23          	sw	s5,24(s1)
    800025d6:	b7e1                	j	8000259e <wakeup+0x2a>
    }
  }
}
    800025d8:	70e2                	ld	ra,56(sp)
    800025da:	7442                	ld	s0,48(sp)
    800025dc:	74a2                	ld	s1,40(sp)
    800025de:	7902                	ld	s2,32(sp)
    800025e0:	69e2                	ld	s3,24(sp)
    800025e2:	6a42                	ld	s4,16(sp)
    800025e4:	6aa2                	ld	s5,8(sp)
    800025e6:	6121                	addi	sp,sp,64
    800025e8:	8082                	ret

00000000800025ea <reparent>:
{
    800025ea:	7179                	addi	sp,sp,-48
    800025ec:	f406                	sd	ra,40(sp)
    800025ee:	f022                	sd	s0,32(sp)
    800025f0:	ec26                	sd	s1,24(sp)
    800025f2:	e84a                	sd	s2,16(sp)
    800025f4:	e44e                	sd	s3,8(sp)
    800025f6:	e052                	sd	s4,0(sp)
    800025f8:	1800                	addi	s0,sp,48
    800025fa:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800025fc:	0022f497          	auipc	s1,0x22f
    80002600:	0d448493          	addi	s1,s1,212 # 802316d0 <proc>
      pp->parent = initproc;
    80002604:	00006a17          	auipc	s4,0x6
    80002608:	624a0a13          	addi	s4,s4,1572 # 80008c28 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000260c:	00237997          	auipc	s3,0x237
    80002610:	8c498993          	addi	s3,s3,-1852 # 80238ed0 <queues>
    80002614:	a029                	j	8000261e <reparent+0x34>
    80002616:	1e048493          	addi	s1,s1,480
    8000261a:	01348d63          	beq	s1,s3,80002634 <reparent+0x4a>
    if (pp->parent == p)
    8000261e:	7c9c                	ld	a5,56(s1)
    80002620:	ff279be3          	bne	a5,s2,80002616 <reparent+0x2c>
      pp->parent = initproc;
    80002624:	000a3503          	ld	a0,0(s4)
    80002628:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000262a:	00000097          	auipc	ra,0x0
    8000262e:	f4a080e7          	jalr	-182(ra) # 80002574 <wakeup>
    80002632:	b7d5                	j	80002616 <reparent+0x2c>
}
    80002634:	70a2                	ld	ra,40(sp)
    80002636:	7402                	ld	s0,32(sp)
    80002638:	64e2                	ld	s1,24(sp)
    8000263a:	6942                	ld	s2,16(sp)
    8000263c:	69a2                	ld	s3,8(sp)
    8000263e:	6a02                	ld	s4,0(sp)
    80002640:	6145                	addi	sp,sp,48
    80002642:	8082                	ret

0000000080002644 <exit>:
{
    80002644:	7179                	addi	sp,sp,-48
    80002646:	f406                	sd	ra,40(sp)
    80002648:	f022                	sd	s0,32(sp)
    8000264a:	ec26                	sd	s1,24(sp)
    8000264c:	e84a                	sd	s2,16(sp)
    8000264e:	e44e                	sd	s3,8(sp)
    80002650:	e052                	sd	s4,0(sp)
    80002652:	1800                	addi	s0,sp,48
    80002654:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002656:	fffff097          	auipc	ra,0xfffff
    8000265a:	4da080e7          	jalr	1242(ra) # 80001b30 <myproc>
    8000265e:	89aa                	mv	s3,a0
  if (p == initproc)
    80002660:	00006797          	auipc	a5,0x6
    80002664:	5c87b783          	ld	a5,1480(a5) # 80008c28 <initproc>
    80002668:	0d050493          	addi	s1,a0,208
    8000266c:	15050913          	addi	s2,a0,336
    80002670:	02a79363          	bne	a5,a0,80002696 <exit+0x52>
    panic("init exiting");
    80002674:	00006517          	auipc	a0,0x6
    80002678:	c4450513          	addi	a0,a0,-956 # 800082b8 <digits+0x278>
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	ec4080e7          	jalr	-316(ra) # 80000540 <panic>
      fileclose(f);
    80002684:	00003097          	auipc	ra,0x3
    80002688:	8ac080e7          	jalr	-1876(ra) # 80004f30 <fileclose>
      p->ofile[fd] = 0;
    8000268c:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002690:	04a1                	addi	s1,s1,8
    80002692:	01248563          	beq	s1,s2,8000269c <exit+0x58>
    if (p->ofile[fd])
    80002696:	6088                	ld	a0,0(s1)
    80002698:	f575                	bnez	a0,80002684 <exit+0x40>
    8000269a:	bfdd                	j	80002690 <exit+0x4c>
  begin_op();
    8000269c:	00002097          	auipc	ra,0x2
    800026a0:	3cc080e7          	jalr	972(ra) # 80004a68 <begin_op>
  iput(p->cwd);
    800026a4:	1509b503          	ld	a0,336(s3)
    800026a8:	00002097          	auipc	ra,0x2
    800026ac:	bae080e7          	jalr	-1106(ra) # 80004256 <iput>
  end_op();
    800026b0:	00002097          	auipc	ra,0x2
    800026b4:	436080e7          	jalr	1078(ra) # 80004ae6 <end_op>
  p->cwd = 0;
    800026b8:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800026bc:	0022e497          	auipc	s1,0x22e
    800026c0:	7fc48493          	addi	s1,s1,2044 # 80230eb8 <wait_lock>
    800026c4:	8526                	mv	a0,s1
    800026c6:	ffffe097          	auipc	ra,0xffffe
    800026ca:	650080e7          	jalr	1616(ra) # 80000d16 <acquire>
  reparent(p);
    800026ce:	854e                	mv	a0,s3
    800026d0:	00000097          	auipc	ra,0x0
    800026d4:	f1a080e7          	jalr	-230(ra) # 800025ea <reparent>
  wakeup(p->parent);
    800026d8:	0389b503          	ld	a0,56(s3)
    800026dc:	00000097          	auipc	ra,0x0
    800026e0:	e98080e7          	jalr	-360(ra) # 80002574 <wakeup>
  acquire(&p->lock);
    800026e4:	854e                	mv	a0,s3
    800026e6:	ffffe097          	auipc	ra,0xffffe
    800026ea:	630080e7          	jalr	1584(ra) # 80000d16 <acquire>
  p->xstate = status;
    800026ee:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800026f2:	4795                	li	a5,5
    800026f4:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800026f8:	00006797          	auipc	a5,0x6
    800026fc:	5387a783          	lw	a5,1336(a5) # 80008c30 <ticks>
    80002700:	1cf9ae23          	sw	a5,476(s3)
  release(&wait_lock);
    80002704:	8526                	mv	a0,s1
    80002706:	ffffe097          	auipc	ra,0xffffe
    8000270a:	6c4080e7          	jalr	1732(ra) # 80000dca <release>
  sched();
    8000270e:	00000097          	auipc	ra,0x0
    80002712:	ba0080e7          	jalr	-1120(ra) # 800022ae <sched>
  panic("zombie exit");
    80002716:	00006517          	auipc	a0,0x6
    8000271a:	bb250513          	addi	a0,a0,-1102 # 800082c8 <digits+0x288>
    8000271e:	ffffe097          	auipc	ra,0xffffe
    80002722:	e22080e7          	jalr	-478(ra) # 80000540 <panic>

0000000080002726 <update_times>:

// update times of all process
void update_times() // called in clockintr when incrementing ticks
{
    80002726:	7139                	addi	sp,sp,-64
    80002728:	fc06                	sd	ra,56(sp)
    8000272a:	f822                	sd	s0,48(sp)
    8000272c:	f426                	sd	s1,40(sp)
    8000272e:	f04a                	sd	s2,32(sp)
    80002730:	ec4e                	sd	s3,24(sp)
    80002732:	e852                	sd	s4,16(sp)
    80002734:	e456                	sd	s5,8(sp)
    80002736:	0080                	addi	s0,sp,64
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002738:	0022f497          	auipc	s1,0x22f
    8000273c:	f9848493          	addi	s1,s1,-104 # 802316d0 <proc>
  {
    acquire(&p->lock);

    if (p->state == SLEEPING)
    80002740:	4989                	li	s3,2
      p->sleeptime++;

    if (p->state == RUNNING)
    80002742:	4a11                	li	s4,4
#ifdef MLFQ
      p->qrtime[p->queueno]++;
      p->timeslice--;
#endif
    }
    if (p->state == RUNNABLE)
    80002744:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002746:	00236917          	auipc	s2,0x236
    8000274a:	78a90913          	addi	s2,s2,1930 # 80238ed0 <queues>
    8000274e:	a839                	j	8000276c <update_times+0x46>
      p->sleeptime++;
    80002750:	1784a783          	lw	a5,376(s1)
    80002754:	2785                	addiw	a5,a5,1
    80002756:	16f4ac23          	sw	a5,376(s1)
    {
      p->wTime++;
    }

    release(&p->lock);
    8000275a:	8526                	mv	a0,s1
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	66e080e7          	jalr	1646(ra) # 80000dca <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002764:	1e048493          	addi	s1,s1,480
    80002768:	03248a63          	beq	s1,s2,8000279c <update_times+0x76>
    acquire(&p->lock);
    8000276c:	8526                	mv	a0,s1
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	5a8080e7          	jalr	1448(ra) # 80000d16 <acquire>
    if (p->state == SLEEPING)
    80002776:	4c9c                	lw	a5,24(s1)
    80002778:	fd378ce3          	beq	a5,s3,80002750 <update_times+0x2a>
    if (p->state == RUNNING)
    8000277c:	01479863          	bne	a5,s4,8000278c <update_times+0x66>
      p->runtime++;
    80002780:	1744a783          	lw	a5,372(s1)
    80002784:	2785                	addiw	a5,a5,1
    80002786:	16f4aa23          	sw	a5,372(s1)
    if (p->state == RUNNABLE)
    8000278a:	bfc1                	j	8000275a <update_times+0x34>
    8000278c:	fd5797e3          	bne	a5,s5,8000275a <update_times+0x34>
      p->wTime++;
    80002790:	1804a783          	lw	a5,384(s1)
    80002794:	2785                	addiw	a5,a5,1
    80002796:	18f4a023          	sw	a5,384(s1)
    8000279a:	b7c1                	j	8000275a <update_times+0x34>
  }
}
    8000279c:	70e2                	ld	ra,56(sp)
    8000279e:	7442                	ld	s0,48(sp)
    800027a0:	74a2                	ld	s1,40(sp)
    800027a2:	7902                	ld	s2,32(sp)
    800027a4:	69e2                	ld	s3,24(sp)
    800027a6:	6a42                	ld	s4,16(sp)
    800027a8:	6aa2                	ld	s5,8(sp)
    800027aa:	6121                	addi	sp,sp,64
    800027ac:	8082                	ret

00000000800027ae <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800027ae:	7179                	addi	sp,sp,-48
    800027b0:	f406                	sd	ra,40(sp)
    800027b2:	f022                	sd	s0,32(sp)
    800027b4:	ec26                	sd	s1,24(sp)
    800027b6:	e84a                	sd	s2,16(sp)
    800027b8:	e44e                	sd	s3,8(sp)
    800027ba:	1800                	addi	s0,sp,48
    800027bc:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800027be:	0022f497          	auipc	s1,0x22f
    800027c2:	f1248493          	addi	s1,s1,-238 # 802316d0 <proc>
    800027c6:	00236997          	auipc	s3,0x236
    800027ca:	70a98993          	addi	s3,s3,1802 # 80238ed0 <queues>
  {
    acquire(&p->lock);
    800027ce:	8526                	mv	a0,s1
    800027d0:	ffffe097          	auipc	ra,0xffffe
    800027d4:	546080e7          	jalr	1350(ra) # 80000d16 <acquire>
    if (p->pid == pid)
    800027d8:	589c                	lw	a5,48(s1)
    800027da:	01278d63          	beq	a5,s2,800027f4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800027de:	8526                	mv	a0,s1
    800027e0:	ffffe097          	auipc	ra,0xffffe
    800027e4:	5ea080e7          	jalr	1514(ra) # 80000dca <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800027e8:	1e048493          	addi	s1,s1,480
    800027ec:	ff3491e3          	bne	s1,s3,800027ce <kill+0x20>
  }
  return -1;
    800027f0:	557d                	li	a0,-1
    800027f2:	a829                	j	8000280c <kill+0x5e>
      p->killed = 1;
    800027f4:	4785                	li	a5,1
    800027f6:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800027f8:	4c98                	lw	a4,24(s1)
    800027fa:	4789                	li	a5,2
    800027fc:	00f70f63          	beq	a4,a5,8000281a <kill+0x6c>
      release(&p->lock);
    80002800:	8526                	mv	a0,s1
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	5c8080e7          	jalr	1480(ra) # 80000dca <release>
      return 0;
    8000280a:	4501                	li	a0,0
}
    8000280c:	70a2                	ld	ra,40(sp)
    8000280e:	7402                	ld	s0,32(sp)
    80002810:	64e2                	ld	s1,24(sp)
    80002812:	6942                	ld	s2,16(sp)
    80002814:	69a2                	ld	s3,8(sp)
    80002816:	6145                	addi	sp,sp,48
    80002818:	8082                	ret
        p->state = RUNNABLE;
    8000281a:	478d                	li	a5,3
    8000281c:	cc9c                	sw	a5,24(s1)
    8000281e:	b7cd                	j	80002800 <kill+0x52>

0000000080002820 <setkilled>:

void setkilled(struct proc *p)
{
    80002820:	1101                	addi	sp,sp,-32
    80002822:	ec06                	sd	ra,24(sp)
    80002824:	e822                	sd	s0,16(sp)
    80002826:	e426                	sd	s1,8(sp)
    80002828:	1000                	addi	s0,sp,32
    8000282a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000282c:	ffffe097          	auipc	ra,0xffffe
    80002830:	4ea080e7          	jalr	1258(ra) # 80000d16 <acquire>
  p->killed = 1;
    80002834:	4785                	li	a5,1
    80002836:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002838:	8526                	mv	a0,s1
    8000283a:	ffffe097          	auipc	ra,0xffffe
    8000283e:	590080e7          	jalr	1424(ra) # 80000dca <release>
}
    80002842:	60e2                	ld	ra,24(sp)
    80002844:	6442                	ld	s0,16(sp)
    80002846:	64a2                	ld	s1,8(sp)
    80002848:	6105                	addi	sp,sp,32
    8000284a:	8082                	ret

000000008000284c <killed>:

int killed(struct proc *p)
{
    8000284c:	1101                	addi	sp,sp,-32
    8000284e:	ec06                	sd	ra,24(sp)
    80002850:	e822                	sd	s0,16(sp)
    80002852:	e426                	sd	s1,8(sp)
    80002854:	e04a                	sd	s2,0(sp)
    80002856:	1000                	addi	s0,sp,32
    80002858:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000285a:	ffffe097          	auipc	ra,0xffffe
    8000285e:	4bc080e7          	jalr	1212(ra) # 80000d16 <acquire>
  k = p->killed;
    80002862:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002866:	8526                	mv	a0,s1
    80002868:	ffffe097          	auipc	ra,0xffffe
    8000286c:	562080e7          	jalr	1378(ra) # 80000dca <release>
  return k;
}
    80002870:	854a                	mv	a0,s2
    80002872:	60e2                	ld	ra,24(sp)
    80002874:	6442                	ld	s0,16(sp)
    80002876:	64a2                	ld	s1,8(sp)
    80002878:	6902                	ld	s2,0(sp)
    8000287a:	6105                	addi	sp,sp,32
    8000287c:	8082                	ret

000000008000287e <wait>:
{
    8000287e:	715d                	addi	sp,sp,-80
    80002880:	e486                	sd	ra,72(sp)
    80002882:	e0a2                	sd	s0,64(sp)
    80002884:	fc26                	sd	s1,56(sp)
    80002886:	f84a                	sd	s2,48(sp)
    80002888:	f44e                	sd	s3,40(sp)
    8000288a:	f052                	sd	s4,32(sp)
    8000288c:	ec56                	sd	s5,24(sp)
    8000288e:	e85a                	sd	s6,16(sp)
    80002890:	e45e                	sd	s7,8(sp)
    80002892:	e062                	sd	s8,0(sp)
    80002894:	0880                	addi	s0,sp,80
    80002896:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002898:	fffff097          	auipc	ra,0xfffff
    8000289c:	298080e7          	jalr	664(ra) # 80001b30 <myproc>
    800028a0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800028a2:	0022e517          	auipc	a0,0x22e
    800028a6:	61650513          	addi	a0,a0,1558 # 80230eb8 <wait_lock>
    800028aa:	ffffe097          	auipc	ra,0xffffe
    800028ae:	46c080e7          	jalr	1132(ra) # 80000d16 <acquire>
    havekids = 0;
    800028b2:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800028b4:	4a15                	li	s4,5
        havekids = 1;
    800028b6:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800028b8:	00236997          	auipc	s3,0x236
    800028bc:	61898993          	addi	s3,s3,1560 # 80238ed0 <queues>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800028c0:	0022ec17          	auipc	s8,0x22e
    800028c4:	5f8c0c13          	addi	s8,s8,1528 # 80230eb8 <wait_lock>
    havekids = 0;
    800028c8:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800028ca:	0022f497          	auipc	s1,0x22f
    800028ce:	e0648493          	addi	s1,s1,-506 # 802316d0 <proc>
    800028d2:	a0bd                	j	80002940 <wait+0xc2>
          pid = pp->pid;
    800028d4:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800028d8:	000b0e63          	beqz	s6,800028f4 <wait+0x76>
    800028dc:	4691                	li	a3,4
    800028de:	02c48613          	addi	a2,s1,44
    800028e2:	85da                	mv	a1,s6
    800028e4:	05093503          	ld	a0,80(s2)
    800028e8:	fffff097          	auipc	ra,0xfffff
    800028ec:	eb0080e7          	jalr	-336(ra) # 80001798 <copyout>
    800028f0:	02054563          	bltz	a0,8000291a <wait+0x9c>
          freeproc(pp);
    800028f4:	8526                	mv	a0,s1
    800028f6:	fffff097          	auipc	ra,0xfffff
    800028fa:	48e080e7          	jalr	1166(ra) # 80001d84 <freeproc>
          release(&pp->lock);
    800028fe:	8526                	mv	a0,s1
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	4ca080e7          	jalr	1226(ra) # 80000dca <release>
          release(&wait_lock);
    80002908:	0022e517          	auipc	a0,0x22e
    8000290c:	5b050513          	addi	a0,a0,1456 # 80230eb8 <wait_lock>
    80002910:	ffffe097          	auipc	ra,0xffffe
    80002914:	4ba080e7          	jalr	1210(ra) # 80000dca <release>
          return pid;
    80002918:	a0b5                	j	80002984 <wait+0x106>
            release(&pp->lock);
    8000291a:	8526                	mv	a0,s1
    8000291c:	ffffe097          	auipc	ra,0xffffe
    80002920:	4ae080e7          	jalr	1198(ra) # 80000dca <release>
            release(&wait_lock);
    80002924:	0022e517          	auipc	a0,0x22e
    80002928:	59450513          	addi	a0,a0,1428 # 80230eb8 <wait_lock>
    8000292c:	ffffe097          	auipc	ra,0xffffe
    80002930:	49e080e7          	jalr	1182(ra) # 80000dca <release>
            return -1;
    80002934:	59fd                	li	s3,-1
    80002936:	a0b9                	j	80002984 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002938:	1e048493          	addi	s1,s1,480
    8000293c:	03348463          	beq	s1,s3,80002964 <wait+0xe6>
      if (pp->parent == p)
    80002940:	7c9c                	ld	a5,56(s1)
    80002942:	ff279be3          	bne	a5,s2,80002938 <wait+0xba>
        acquire(&pp->lock);
    80002946:	8526                	mv	a0,s1
    80002948:	ffffe097          	auipc	ra,0xffffe
    8000294c:	3ce080e7          	jalr	974(ra) # 80000d16 <acquire>
        if (pp->state == ZOMBIE)
    80002950:	4c9c                	lw	a5,24(s1)
    80002952:	f94781e3          	beq	a5,s4,800028d4 <wait+0x56>
        release(&pp->lock);
    80002956:	8526                	mv	a0,s1
    80002958:	ffffe097          	auipc	ra,0xffffe
    8000295c:	472080e7          	jalr	1138(ra) # 80000dca <release>
        havekids = 1;
    80002960:	8756                	mv	a4,s5
    80002962:	bfd9                	j	80002938 <wait+0xba>
    if (!havekids || killed(p))
    80002964:	c719                	beqz	a4,80002972 <wait+0xf4>
    80002966:	854a                	mv	a0,s2
    80002968:	00000097          	auipc	ra,0x0
    8000296c:	ee4080e7          	jalr	-284(ra) # 8000284c <killed>
    80002970:	c51d                	beqz	a0,8000299e <wait+0x120>
      release(&wait_lock);
    80002972:	0022e517          	auipc	a0,0x22e
    80002976:	54650513          	addi	a0,a0,1350 # 80230eb8 <wait_lock>
    8000297a:	ffffe097          	auipc	ra,0xffffe
    8000297e:	450080e7          	jalr	1104(ra) # 80000dca <release>
      return -1;
    80002982:	59fd                	li	s3,-1
}
    80002984:	854e                	mv	a0,s3
    80002986:	60a6                	ld	ra,72(sp)
    80002988:	6406                	ld	s0,64(sp)
    8000298a:	74e2                	ld	s1,56(sp)
    8000298c:	7942                	ld	s2,48(sp)
    8000298e:	79a2                	ld	s3,40(sp)
    80002990:	7a02                	ld	s4,32(sp)
    80002992:	6ae2                	ld	s5,24(sp)
    80002994:	6b42                	ld	s6,16(sp)
    80002996:	6ba2                	ld	s7,8(sp)
    80002998:	6c02                	ld	s8,0(sp)
    8000299a:	6161                	addi	sp,sp,80
    8000299c:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000299e:	85e2                	mv	a1,s8
    800029a0:	854a                	mv	a0,s2
    800029a2:	00000097          	auipc	ra,0x0
    800029a6:	a1e080e7          	jalr	-1506(ra) # 800023c0 <sleep>
    havekids = 0;
    800029aa:	bf39                	j	800028c8 <wait+0x4a>

00000000800029ac <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800029ac:	7179                	addi	sp,sp,-48
    800029ae:	f406                	sd	ra,40(sp)
    800029b0:	f022                	sd	s0,32(sp)
    800029b2:	ec26                	sd	s1,24(sp)
    800029b4:	e84a                	sd	s2,16(sp)
    800029b6:	e44e                	sd	s3,8(sp)
    800029b8:	e052                	sd	s4,0(sp)
    800029ba:	1800                	addi	s0,sp,48
    800029bc:	84aa                	mv	s1,a0
    800029be:	892e                	mv	s2,a1
    800029c0:	89b2                	mv	s3,a2
    800029c2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800029c4:	fffff097          	auipc	ra,0xfffff
    800029c8:	16c080e7          	jalr	364(ra) # 80001b30 <myproc>
  if (user_dst)
    800029cc:	c08d                	beqz	s1,800029ee <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800029ce:	86d2                	mv	a3,s4
    800029d0:	864e                	mv	a2,s3
    800029d2:	85ca                	mv	a1,s2
    800029d4:	6928                	ld	a0,80(a0)
    800029d6:	fffff097          	auipc	ra,0xfffff
    800029da:	dc2080e7          	jalr	-574(ra) # 80001798 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800029de:	70a2                	ld	ra,40(sp)
    800029e0:	7402                	ld	s0,32(sp)
    800029e2:	64e2                	ld	s1,24(sp)
    800029e4:	6942                	ld	s2,16(sp)
    800029e6:	69a2                	ld	s3,8(sp)
    800029e8:	6a02                	ld	s4,0(sp)
    800029ea:	6145                	addi	sp,sp,48
    800029ec:	8082                	ret
    memmove((char *)dst, src, len);
    800029ee:	000a061b          	sext.w	a2,s4
    800029f2:	85ce                	mv	a1,s3
    800029f4:	854a                	mv	a0,s2
    800029f6:	ffffe097          	auipc	ra,0xffffe
    800029fa:	478080e7          	jalr	1144(ra) # 80000e6e <memmove>
    return 0;
    800029fe:	8526                	mv	a0,s1
    80002a00:	bff9                	j	800029de <either_copyout+0x32>

0000000080002a02 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002a02:	7179                	addi	sp,sp,-48
    80002a04:	f406                	sd	ra,40(sp)
    80002a06:	f022                	sd	s0,32(sp)
    80002a08:	ec26                	sd	s1,24(sp)
    80002a0a:	e84a                	sd	s2,16(sp)
    80002a0c:	e44e                	sd	s3,8(sp)
    80002a0e:	e052                	sd	s4,0(sp)
    80002a10:	1800                	addi	s0,sp,48
    80002a12:	892a                	mv	s2,a0
    80002a14:	84ae                	mv	s1,a1
    80002a16:	89b2                	mv	s3,a2
    80002a18:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a1a:	fffff097          	auipc	ra,0xfffff
    80002a1e:	116080e7          	jalr	278(ra) # 80001b30 <myproc>
  if (user_src)
    80002a22:	c08d                	beqz	s1,80002a44 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002a24:	86d2                	mv	a3,s4
    80002a26:	864e                	mv	a2,s3
    80002a28:	85ca                	mv	a1,s2
    80002a2a:	6928                	ld	a0,80(a0)
    80002a2c:	fffff097          	auipc	ra,0xfffff
    80002a30:	e46080e7          	jalr	-442(ra) # 80001872 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002a34:	70a2                	ld	ra,40(sp)
    80002a36:	7402                	ld	s0,32(sp)
    80002a38:	64e2                	ld	s1,24(sp)
    80002a3a:	6942                	ld	s2,16(sp)
    80002a3c:	69a2                	ld	s3,8(sp)
    80002a3e:	6a02                	ld	s4,0(sp)
    80002a40:	6145                	addi	sp,sp,48
    80002a42:	8082                	ret
    memmove(dst, (char *)src, len);
    80002a44:	000a061b          	sext.w	a2,s4
    80002a48:	85ce                	mv	a1,s3
    80002a4a:	854a                	mv	a0,s2
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	422080e7          	jalr	1058(ra) # 80000e6e <memmove>
    return 0;
    80002a54:	8526                	mv	a0,s1
    80002a56:	bff9                	j	80002a34 <either_copyin+0x32>

0000000080002a58 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002a58:	715d                	addi	sp,sp,-80
    80002a5a:	e486                	sd	ra,72(sp)
    80002a5c:	e0a2                	sd	s0,64(sp)
    80002a5e:	fc26                	sd	s1,56(sp)
    80002a60:	f84a                	sd	s2,48(sp)
    80002a62:	f44e                	sd	s3,40(sp)
    80002a64:	f052                	sd	s4,32(sp)
    80002a66:	ec56                	sd	s5,24(sp)
    80002a68:	e85a                	sd	s6,16(sp)
    80002a6a:	e45e                	sd	s7,8(sp)
    80002a6c:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002a6e:	00005517          	auipc	a0,0x5
    80002a72:	69a50513          	addi	a0,a0,1690 # 80008108 <digits+0xc8>
    80002a76:	ffffe097          	auipc	ra,0xffffe
    80002a7a:	b14080e7          	jalr	-1260(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a7e:	0022f497          	auipc	s1,0x22f
    80002a82:	daa48493          	addi	s1,s1,-598 # 80231828 <proc+0x158>
    80002a86:	00236917          	auipc	s2,0x236
    80002a8a:	5a290913          	addi	s2,s2,1442 # 80239028 <bcache+0xf0>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a8e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002a90:	00006997          	auipc	s3,0x6
    80002a94:	84898993          	addi	s3,s3,-1976 # 800082d8 <digits+0x298>
    printf("%d %s %s", p->pid, state, p->name);
    80002a98:	00006a97          	auipc	s5,0x6
    80002a9c:	848a8a93          	addi	s5,s5,-1976 # 800082e0 <digits+0x2a0>
    printf("\n");
    80002aa0:	00005a17          	auipc	s4,0x5
    80002aa4:	668a0a13          	addi	s4,s4,1640 # 80008108 <digits+0xc8>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002aa8:	00006b97          	auipc	s7,0x6
    80002aac:	878b8b93          	addi	s7,s7,-1928 # 80008320 <states.0>
    80002ab0:	a00d                	j	80002ad2 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002ab2:	ed86a583          	lw	a1,-296(a3)
    80002ab6:	8556                	mv	a0,s5
    80002ab8:	ffffe097          	auipc	ra,0xffffe
    80002abc:	ad2080e7          	jalr	-1326(ra) # 8000058a <printf>
    printf("\n");
    80002ac0:	8552                	mv	a0,s4
    80002ac2:	ffffe097          	auipc	ra,0xffffe
    80002ac6:	ac8080e7          	jalr	-1336(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002aca:	1e048493          	addi	s1,s1,480
    80002ace:	03248263          	beq	s1,s2,80002af2 <procdump+0x9a>
    if (p->state == UNUSED)
    80002ad2:	86a6                	mv	a3,s1
    80002ad4:	ec04a783          	lw	a5,-320(s1)
    80002ad8:	dbed                	beqz	a5,80002aca <procdump+0x72>
      state = "???";
    80002ada:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002adc:	fcfb6be3          	bltu	s6,a5,80002ab2 <procdump+0x5a>
    80002ae0:	02079713          	slli	a4,a5,0x20
    80002ae4:	01d75793          	srli	a5,a4,0x1d
    80002ae8:	97de                	add	a5,a5,s7
    80002aea:	6390                	ld	a2,0(a5)
    80002aec:	f279                	bnez	a2,80002ab2 <procdump+0x5a>
      state = "???";
    80002aee:	864e                	mv	a2,s3
    80002af0:	b7c9                	j	80002ab2 <procdump+0x5a>
  }
}
    80002af2:	60a6                	ld	ra,72(sp)
    80002af4:	6406                	ld	s0,64(sp)
    80002af6:	74e2                	ld	s1,56(sp)
    80002af8:	7942                	ld	s2,48(sp)
    80002afa:	79a2                	ld	s3,40(sp)
    80002afc:	7a02                	ld	s4,32(sp)
    80002afe:	6ae2                	ld	s5,24(sp)
    80002b00:	6b42                	ld	s6,16(sp)
    80002b02:	6ba2                	ld	s7,8(sp)
    80002b04:	6161                	addi	sp,sp,80
    80002b06:	8082                	ret

0000000080002b08 <swtch>:
    80002b08:	00153023          	sd	ra,0(a0)
    80002b0c:	00253423          	sd	sp,8(a0)
    80002b10:	e900                	sd	s0,16(a0)
    80002b12:	ed04                	sd	s1,24(a0)
    80002b14:	03253023          	sd	s2,32(a0)
    80002b18:	03353423          	sd	s3,40(a0)
    80002b1c:	03453823          	sd	s4,48(a0)
    80002b20:	03553c23          	sd	s5,56(a0)
    80002b24:	05653023          	sd	s6,64(a0)
    80002b28:	05753423          	sd	s7,72(a0)
    80002b2c:	05853823          	sd	s8,80(a0)
    80002b30:	05953c23          	sd	s9,88(a0)
    80002b34:	07a53023          	sd	s10,96(a0)
    80002b38:	07b53423          	sd	s11,104(a0)
    80002b3c:	0005b083          	ld	ra,0(a1)
    80002b40:	0085b103          	ld	sp,8(a1)
    80002b44:	6980                	ld	s0,16(a1)
    80002b46:	6d84                	ld	s1,24(a1)
    80002b48:	0205b903          	ld	s2,32(a1)
    80002b4c:	0285b983          	ld	s3,40(a1)
    80002b50:	0305ba03          	ld	s4,48(a1)
    80002b54:	0385ba83          	ld	s5,56(a1)
    80002b58:	0405bb03          	ld	s6,64(a1)
    80002b5c:	0485bb83          	ld	s7,72(a1)
    80002b60:	0505bc03          	ld	s8,80(a1)
    80002b64:	0585bc83          	ld	s9,88(a1)
    80002b68:	0605bd03          	ld	s10,96(a1)
    80002b6c:	0685bd83          	ld	s11,104(a1)
    80002b70:	8082                	ret

0000000080002b72 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002b72:	1141                	addi	sp,sp,-16
    80002b74:	e406                	sd	ra,8(sp)
    80002b76:	e022                	sd	s0,0(sp)
    80002b78:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b7a:	00005597          	auipc	a1,0x5
    80002b7e:	7d658593          	addi	a1,a1,2006 # 80008350 <states.0+0x30>
    80002b82:	00236517          	auipc	a0,0x236
    80002b86:	39e50513          	addi	a0,a0,926 # 80238f20 <tickslock>
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	0fc080e7          	jalr	252(ra) # 80000c86 <initlock>
}
    80002b92:	60a2                	ld	ra,8(sp)
    80002b94:	6402                	ld	s0,0(sp)
    80002b96:	0141                	addi	sp,sp,16
    80002b98:	8082                	ret

0000000080002b9a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002b9a:	1141                	addi	sp,sp,-16
    80002b9c:	e422                	sd	s0,8(sp)
    80002b9e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ba0:	00004797          	auipc	a5,0x4
    80002ba4:	a0078793          	addi	a5,a5,-1536 # 800065a0 <kernelvec>
    80002ba8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002bac:	6422                	ld	s0,8(sp)
    80002bae:	0141                	addi	sp,sp,16
    80002bb0:	8082                	ret

0000000080002bb2 <cow_handler>:

// in case of page fault
int cow_handler(pagetable_t pagetable, uint64 va)
{
  if (va >= MAXVA) // so that walk doesn't panic
    80002bb2:	57fd                	li	a5,-1
    80002bb4:	83e9                	srli	a5,a5,0x1a
    80002bb6:	08b7e263          	bltu	a5,a1,80002c3a <cow_handler+0x88>
{
    80002bba:	7179                	addi	sp,sp,-48
    80002bbc:	f406                	sd	ra,40(sp)
    80002bbe:	f022                	sd	s0,32(sp)
    80002bc0:	ec26                	sd	s1,24(sp)
    80002bc2:	e84a                	sd	s2,16(sp)
    80002bc4:	e44e                	sd	s3,8(sp)
    80002bc6:	1800                	addi	s0,sp,48
    return -1;

  pte_t *pte = walk(pagetable, va, 0);
    80002bc8:	4601                	li	a2,0
    80002bca:	ffffe097          	auipc	ra,0xffffe
    80002bce:	52c080e7          	jalr	1324(ra) # 800010f6 <walk>
    80002bd2:	89aa                	mv	s3,a0
  if (pte == 0)
    80002bd4:	c52d                	beqz	a0,80002c3e <cow_handler+0x8c>
    return -1; // if pagetable not found

  if ((*pte & PTE_U) == 0 || (*pte & PTE_V) == 0)
    80002bd6:	610c                	ld	a1,0(a0)
    80002bd8:	0115f713          	andi	a4,a1,17
    80002bdc:	47c5                	li	a5,17
    80002bde:	06f71263          	bne	a4,a5,80002c42 <cow_handler+0x90>
    return -1; // crazy addresses

  uint64 pa1 = PTE2PA(*pte);
    80002be2:	81a9                	srli	a1,a1,0xa
    80002be4:	00c59913          	slli	s2,a1,0xc

  uint64 pa2 = (uint64)kalloc();
    80002be8:	ffffe097          	auipc	ra,0xffffe
    80002bec:	000080e7          	jalr	ra # 80000be8 <kalloc>
    80002bf0:	84aa                	mv	s1,a0
  if (pa2 == 0)
    80002bf2:	c915                	beqz	a0,80002c26 <cow_handler+0x74>
  {
    printf("Cow KAlloc failed\n");
    return -1;
  }

  memmove((void *)pa2, (void *)pa1, 4096);
    80002bf4:	6605                	lui	a2,0x1
    80002bf6:	85ca                	mv	a1,s2
    80002bf8:	ffffe097          	auipc	ra,0xffffe
    80002bfc:	276080e7          	jalr	630(ra) # 80000e6e <memmove>

  kfree((void *)pa1); // it now means decrementing the pageref
    80002c00:	854a                	mv	a0,s2
    80002c02:	ffffe097          	auipc	ra,0xffffe
    80002c06:	e62080e7          	jalr	-414(ra) # 80000a64 <kfree>

  *pte = PA2PTE(pa2) | PTE_V | PTE_U | PTE_R | PTE_W | PTE_X; // other process creates a copy and goes on
    80002c0a:	80b1                	srli	s1,s1,0xc
    80002c0c:	04aa                	slli	s1,s1,0xa
    80002c0e:	01f4e493          	ori	s1,s1,31
    80002c12:	0099b023          	sd	s1,0(s3)
  *pte &= ~PTE_C;
  return 0;
    80002c16:	4501                	li	a0,0
}
    80002c18:	70a2                	ld	ra,40(sp)
    80002c1a:	7402                	ld	s0,32(sp)
    80002c1c:	64e2                	ld	s1,24(sp)
    80002c1e:	6942                	ld	s2,16(sp)
    80002c20:	69a2                	ld	s3,8(sp)
    80002c22:	6145                	addi	sp,sp,48
    80002c24:	8082                	ret
    printf("Cow KAlloc failed\n");
    80002c26:	00005517          	auipc	a0,0x5
    80002c2a:	73250513          	addi	a0,a0,1842 # 80008358 <states.0+0x38>
    80002c2e:	ffffe097          	auipc	ra,0xffffe
    80002c32:	95c080e7          	jalr	-1700(ra) # 8000058a <printf>
    return -1;
    80002c36:	557d                	li	a0,-1
    80002c38:	b7c5                	j	80002c18 <cow_handler+0x66>
    return -1;
    80002c3a:	557d                	li	a0,-1
}
    80002c3c:	8082                	ret
    return -1; // if pagetable not found
    80002c3e:	557d                	li	a0,-1
    80002c40:	bfe1                	j	80002c18 <cow_handler+0x66>
    return -1; // crazy addresses
    80002c42:	557d                	li	a0,-1
    80002c44:	bfd1                	j	80002c18 <cow_handler+0x66>

0000000080002c46 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002c46:	1141                	addi	sp,sp,-16
    80002c48:	e406                	sd	ra,8(sp)
    80002c4a:	e022                	sd	s0,0(sp)
    80002c4c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002c4e:	fffff097          	auipc	ra,0xfffff
    80002c52:	ee2080e7          	jalr	-286(ra) # 80001b30 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002c5a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c5c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002c60:	00004697          	auipc	a3,0x4
    80002c64:	3a068693          	addi	a3,a3,928 # 80007000 <_trampoline>
    80002c68:	00004717          	auipc	a4,0x4
    80002c6c:	39870713          	addi	a4,a4,920 # 80007000 <_trampoline>
    80002c70:	8f15                	sub	a4,a4,a3
    80002c72:	040007b7          	lui	a5,0x4000
    80002c76:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002c78:	07b2                	slli	a5,a5,0xc
    80002c7a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c7c:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002c80:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002c82:	18002673          	csrr	a2,satp
    80002c86:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002c88:	6d30                	ld	a2,88(a0)
    80002c8a:	6138                	ld	a4,64(a0)
    80002c8c:	6585                	lui	a1,0x1
    80002c8e:	972e                	add	a4,a4,a1
    80002c90:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002c92:	6d38                	ld	a4,88(a0)
    80002c94:	00000617          	auipc	a2,0x0
    80002c98:	13e60613          	addi	a2,a2,318 # 80002dd2 <usertrap>
    80002c9c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002c9e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ca0:	8612                	mv	a2,tp
    80002ca2:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ca4:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002ca8:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002cac:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cb0:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002cb4:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cb6:	6f18                	ld	a4,24(a4)
    80002cb8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002cbc:	6928                	ld	a0,80(a0)
    80002cbe:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002cc0:	00004717          	auipc	a4,0x4
    80002cc4:	3dc70713          	addi	a4,a4,988 # 8000709c <userret>
    80002cc8:	8f15                	sub	a4,a4,a3
    80002cca:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002ccc:	577d                	li	a4,-1
    80002cce:	177e                	slli	a4,a4,0x3f
    80002cd0:	8d59                	or	a0,a0,a4
    80002cd2:	9782                	jalr	a5
}
    80002cd4:	60a2                	ld	ra,8(sp)
    80002cd6:	6402                	ld	s0,0(sp)
    80002cd8:	0141                	addi	sp,sp,16
    80002cda:	8082                	ret

0000000080002cdc <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002cdc:	1101                	addi	sp,sp,-32
    80002cde:	ec06                	sd	ra,24(sp)
    80002ce0:	e822                	sd	s0,16(sp)
    80002ce2:	e426                	sd	s1,8(sp)
    80002ce4:	e04a                	sd	s2,0(sp)
    80002ce6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ce8:	00236917          	auipc	s2,0x236
    80002cec:	23890913          	addi	s2,s2,568 # 80238f20 <tickslock>
    80002cf0:	854a                	mv	a0,s2
    80002cf2:	ffffe097          	auipc	ra,0xffffe
    80002cf6:	024080e7          	jalr	36(ra) # 80000d16 <acquire>
  ticks++;
    80002cfa:	00006497          	auipc	s1,0x6
    80002cfe:	f3648493          	addi	s1,s1,-202 # 80008c30 <ticks>
    80002d02:	409c                	lw	a5,0(s1)
    80002d04:	2785                	addiw	a5,a5,1
    80002d06:	c09c                	sw	a5,0(s1)

  update_times(); // update certain time units of processes
    80002d08:	00000097          	auipc	ra,0x0
    80002d0c:	a1e080e7          	jalr	-1506(ra) # 80002726 <update_times>

  wakeup(&ticks);
    80002d10:	8526                	mv	a0,s1
    80002d12:	00000097          	auipc	ra,0x0
    80002d16:	862080e7          	jalr	-1950(ra) # 80002574 <wakeup>
  release(&tickslock);
    80002d1a:	854a                	mv	a0,s2
    80002d1c:	ffffe097          	auipc	ra,0xffffe
    80002d20:	0ae080e7          	jalr	174(ra) # 80000dca <release>
}
    80002d24:	60e2                	ld	ra,24(sp)
    80002d26:	6442                	ld	s0,16(sp)
    80002d28:	64a2                	ld	s1,8(sp)
    80002d2a:	6902                	ld	s2,0(sp)
    80002d2c:	6105                	addi	sp,sp,32
    80002d2e:	8082                	ret

0000000080002d30 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr() // CAN BE CALLED FROM BOTH USER SPACE AND KERNEL SPACE
{
    80002d30:	1101                	addi	sp,sp,-32
    80002d32:	ec06                	sd	ra,24(sp)
    80002d34:	e822                	sd	s0,16(sp)
    80002d36:	e426                	sd	s1,8(sp)
    80002d38:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d3a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002d3e:	00074d63          	bltz	a4,80002d58 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002d42:	57fd                	li	a5,-1
    80002d44:	17fe                	slli	a5,a5,0x3f
    80002d46:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002d48:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002d4a:	06f70363          	beq	a4,a5,80002db0 <devintr+0x80>
  }
}
    80002d4e:	60e2                	ld	ra,24(sp)
    80002d50:	6442                	ld	s0,16(sp)
    80002d52:	64a2                	ld	s1,8(sp)
    80002d54:	6105                	addi	sp,sp,32
    80002d56:	8082                	ret
      (scause & 0xff) == 9)
    80002d58:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    80002d5c:	46a5                	li	a3,9
    80002d5e:	fed792e3          	bne	a5,a3,80002d42 <devintr+0x12>
    int irq = plic_claim();
    80002d62:	00004097          	auipc	ra,0x4
    80002d66:	946080e7          	jalr	-1722(ra) # 800066a8 <plic_claim>
    80002d6a:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002d6c:	47a9                	li	a5,10
    80002d6e:	02f50763          	beq	a0,a5,80002d9c <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002d72:	4785                	li	a5,1
    80002d74:	02f50963          	beq	a0,a5,80002da6 <devintr+0x76>
    return 1;
    80002d78:	4505                	li	a0,1
    else if (irq)
    80002d7a:	d8f1                	beqz	s1,80002d4e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002d7c:	85a6                	mv	a1,s1
    80002d7e:	00005517          	auipc	a0,0x5
    80002d82:	5f250513          	addi	a0,a0,1522 # 80008370 <states.0+0x50>
    80002d86:	ffffe097          	auipc	ra,0xffffe
    80002d8a:	804080e7          	jalr	-2044(ra) # 8000058a <printf>
      plic_complete(irq);
    80002d8e:	8526                	mv	a0,s1
    80002d90:	00004097          	auipc	ra,0x4
    80002d94:	93c080e7          	jalr	-1732(ra) # 800066cc <plic_complete>
    return 1;
    80002d98:	4505                	li	a0,1
    80002d9a:	bf55                	j	80002d4e <devintr+0x1e>
      uartintr();
    80002d9c:	ffffe097          	auipc	ra,0xffffe
    80002da0:	bfc080e7          	jalr	-1028(ra) # 80000998 <uartintr>
    80002da4:	b7ed                	j	80002d8e <devintr+0x5e>
      virtio_disk_intr();
    80002da6:	00004097          	auipc	ra,0x4
    80002daa:	dee080e7          	jalr	-530(ra) # 80006b94 <virtio_disk_intr>
    80002dae:	b7c5                	j	80002d8e <devintr+0x5e>
    if (cpuid() == 0)
    80002db0:	fffff097          	auipc	ra,0xfffff
    80002db4:	d54080e7          	jalr	-684(ra) # 80001b04 <cpuid>
    80002db8:	c901                	beqz	a0,80002dc8 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002dba:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002dbe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002dc0:	14479073          	csrw	sip,a5
    return 2;
    80002dc4:	4509                	li	a0,2
    80002dc6:	b761                	j	80002d4e <devintr+0x1e>
      clockintr();
    80002dc8:	00000097          	auipc	ra,0x0
    80002dcc:	f14080e7          	jalr	-236(ra) # 80002cdc <clockintr>
    80002dd0:	b7ed                	j	80002dba <devintr+0x8a>

0000000080002dd2 <usertrap>:
{
    80002dd2:	1101                	addi	sp,sp,-32
    80002dd4:	ec06                	sd	ra,24(sp)
    80002dd6:	e822                	sd	s0,16(sp)
    80002dd8:	e426                	sd	s1,8(sp)
    80002dda:	e04a                	sd	s2,0(sp)
    80002ddc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dde:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002de2:	1007f793          	andi	a5,a5,256
    80002de6:	e7b9                	bnez	a5,80002e34 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002de8:	00003797          	auipc	a5,0x3
    80002dec:	7b878793          	addi	a5,a5,1976 # 800065a0 <kernelvec>
    80002df0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002df4:	fffff097          	auipc	ra,0xfffff
    80002df8:	d3c080e7          	jalr	-708(ra) # 80001b30 <myproc>
    80002dfc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002dfe:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e00:	14102773          	csrr	a4,sepc
    80002e04:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e06:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002e0a:	47a1                	li	a5,8
    80002e0c:	02f70c63          	beq	a4,a5,80002e44 <usertrap+0x72>
    80002e10:	14202773          	csrr	a4,scause
  else if (r_scause() == 0xf)
    80002e14:	47bd                	li	a5,15
    80002e16:	08f70063          	beq	a4,a5,80002e96 <usertrap+0xc4>
  else if ((which_dev = devintr()) != 0)
    80002e1a:	00000097          	auipc	ra,0x0
    80002e1e:	f16080e7          	jalr	-234(ra) # 80002d30 <devintr>
    80002e22:	892a                	mv	s2,a0
    80002e24:	c549                	beqz	a0,80002eae <usertrap+0xdc>
  if (killed(p))
    80002e26:	8526                	mv	a0,s1
    80002e28:	00000097          	auipc	ra,0x0
    80002e2c:	a24080e7          	jalr	-1500(ra) # 8000284c <killed>
    80002e30:	c171                	beqz	a0,80002ef4 <usertrap+0x122>
    80002e32:	a865                	j	80002eea <usertrap+0x118>
    panic("usertrap: not from user mode");
    80002e34:	00005517          	auipc	a0,0x5
    80002e38:	55c50513          	addi	a0,a0,1372 # 80008390 <states.0+0x70>
    80002e3c:	ffffd097          	auipc	ra,0xffffd
    80002e40:	704080e7          	jalr	1796(ra) # 80000540 <panic>
    if (killed(p))
    80002e44:	00000097          	auipc	ra,0x0
    80002e48:	a08080e7          	jalr	-1528(ra) # 8000284c <killed>
    80002e4c:	ed1d                	bnez	a0,80002e8a <usertrap+0xb8>
    p->trapframe->epc += 4;
    80002e4e:	6cb8                	ld	a4,88(s1)
    80002e50:	6f1c                	ld	a5,24(a4)
    80002e52:	0791                	addi	a5,a5,4
    80002e54:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002e5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e5e:	10079073          	csrw	sstatus,a5
    syscall();
    80002e62:	00000097          	auipc	ra,0x0
    80002e66:	340080e7          	jalr	832(ra) # 800031a2 <syscall>
  if (killed(p))
    80002e6a:	8526                	mv	a0,s1
    80002e6c:	00000097          	auipc	ra,0x0
    80002e70:	9e0080e7          	jalr	-1568(ra) # 8000284c <killed>
    80002e74:	e935                	bnez	a0,80002ee8 <usertrap+0x116>
  usertrapret();
    80002e76:	00000097          	auipc	ra,0x0
    80002e7a:	dd0080e7          	jalr	-560(ra) # 80002c46 <usertrapret>
}
    80002e7e:	60e2                	ld	ra,24(sp)
    80002e80:	6442                	ld	s0,16(sp)
    80002e82:	64a2                	ld	s1,8(sp)
    80002e84:	6902                	ld	s2,0(sp)
    80002e86:	6105                	addi	sp,sp,32
    80002e88:	8082                	ret
      exit(-1);
    80002e8a:	557d                	li	a0,-1
    80002e8c:	fffff097          	auipc	ra,0xfffff
    80002e90:	7b8080e7          	jalr	1976(ra) # 80002644 <exit>
    80002e94:	bf6d                	j	80002e4e <usertrap+0x7c>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e96:	143025f3          	csrr	a1,stval
    if (cow_handler(p->pagetable, r_stval()) < 0)
    80002e9a:	6928                	ld	a0,80(a0)
    80002e9c:	00000097          	auipc	ra,0x0
    80002ea0:	d16080e7          	jalr	-746(ra) # 80002bb2 <cow_handler>
    80002ea4:	fc0553e3          	bgez	a0,80002e6a <usertrap+0x98>
      p->killed = 1;
    80002ea8:	4785                	li	a5,1
    80002eaa:	d49c                	sw	a5,40(s1)
    80002eac:	bf7d                	j	80002e6a <usertrap+0x98>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002eae:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002eb2:	5890                	lw	a2,48(s1)
    80002eb4:	00005517          	auipc	a0,0x5
    80002eb8:	4fc50513          	addi	a0,a0,1276 # 800083b0 <states.0+0x90>
    80002ebc:	ffffd097          	auipc	ra,0xffffd
    80002ec0:	6ce080e7          	jalr	1742(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ec4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ec8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ecc:	00005517          	auipc	a0,0x5
    80002ed0:	51450513          	addi	a0,a0,1300 # 800083e0 <states.0+0xc0>
    80002ed4:	ffffd097          	auipc	ra,0xffffd
    80002ed8:	6b6080e7          	jalr	1718(ra) # 8000058a <printf>
    setkilled(p);
    80002edc:	8526                	mv	a0,s1
    80002ede:	00000097          	auipc	ra,0x0
    80002ee2:	942080e7          	jalr	-1726(ra) # 80002820 <setkilled>
    80002ee6:	b751                	j	80002e6a <usertrap+0x98>
  if (killed(p))
    80002ee8:	4901                	li	s2,0
    exit(-1);
    80002eea:	557d                	li	a0,-1
    80002eec:	fffff097          	auipc	ra,0xfffff
    80002ef0:	758080e7          	jalr	1880(ra) # 80002644 <exit>
  if ((which_dev == 2) && (p != 0) && (p->state == RUNNING) && (p->alarmint != 0)) // TIMER INTERRUPT FROM USER SPACE WHEN PROCESS IS RUNNING
    80002ef4:	4789                	li	a5,2
    80002ef6:	f8f910e3          	bne	s2,a5,80002e76 <usertrap+0xa4>
    80002efa:	4c98                	lw	a4,24(s1)
    80002efc:	4791                	li	a5,4
    80002efe:	f6f71ce3          	bne	a4,a5,80002e76 <usertrap+0xa4>
    80002f02:	1b84a783          	lw	a5,440(s1)
    80002f06:	dba5                	beqz	a5,80002e76 <usertrap+0xa4>
    p->tslalarm += 1;                                      // incrementing time since last alarm
    80002f08:	1c84a703          	lw	a4,456(s1)
    80002f0c:	2705                	addiw	a4,a4,1
    80002f0e:	0007069b          	sext.w	a3,a4
    80002f12:	1ce4a423          	sw	a4,456(s1)
    if ((p->tslalarm >= p->alarmint) && (!p->is_sigalarm)) // Ohh !! we have to call the handler now
    80002f16:	04f6c463          	blt	a3,a5,80002f5e <usertrap+0x18c>
    80002f1a:	1b44a783          	lw	a5,436(s1)
    80002f1e:	e3a1                	bnez	a5,80002f5e <usertrap+0x18c>
      p->tslalarm = 0;                     // resetting value of tslalarm
    80002f20:	1c04a423          	sw	zero,456(s1)
      p->is_sigalarm = 1;                  // enabling alarm
    80002f24:	4785                	li	a5,1
    80002f26:	1af4aa23          	sw	a5,436(s1)
      *(p->tf_copy) = *(p->trapframe);     // storing the current state in copy
    80002f2a:	6cb4                	ld	a3,88(s1)
    80002f2c:	87b6                	mv	a5,a3
    80002f2e:	1d04b703          	ld	a4,464(s1)
    80002f32:	12068693          	addi	a3,a3,288
    80002f36:	0007b803          	ld	a6,0(a5)
    80002f3a:	6788                	ld	a0,8(a5)
    80002f3c:	6b8c                	ld	a1,16(a5)
    80002f3e:	6f90                	ld	a2,24(a5)
    80002f40:	01073023          	sd	a6,0(a4)
    80002f44:	e708                	sd	a0,8(a4)
    80002f46:	eb0c                	sd	a1,16(a4)
    80002f48:	ef10                	sd	a2,24(a4)
    80002f4a:	02078793          	addi	a5,a5,32
    80002f4e:	02070713          	addi	a4,a4,32
    80002f52:	fed792e3          	bne	a5,a3,80002f36 <usertrap+0x164>
      p->trapframe->epc = p->alarmhandler; // calling handler function
    80002f56:	6cbc                	ld	a5,88(s1)
    80002f58:	1c04b703          	ld	a4,448(s1)
    80002f5c:	ef98                	sd	a4,24(a5)
    yield();
    80002f5e:	fffff097          	auipc	ra,0xfffff
    80002f62:	426080e7          	jalr	1062(ra) # 80002384 <yield>
    80002f66:	bf01                	j	80002e76 <usertrap+0xa4>

0000000080002f68 <kerneltrap>:
{
    80002f68:	7179                	addi	sp,sp,-48
    80002f6a:	f406                	sd	ra,40(sp)
    80002f6c:	f022                	sd	s0,32(sp)
    80002f6e:	ec26                	sd	s1,24(sp)
    80002f70:	e84a                	sd	s2,16(sp)
    80002f72:	e44e                	sd	s3,8(sp)
    80002f74:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f76:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f7a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f7e:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002f82:	1004f793          	andi	a5,s1,256
    80002f86:	cb85                	beqz	a5,80002fb6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f88:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002f8c:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002f8e:	ef85                	bnez	a5,80002fc6 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002f90:	00000097          	auipc	ra,0x0
    80002f94:	da0080e7          	jalr	-608(ra) # 80002d30 <devintr>
    80002f98:	cd1d                	beqz	a0,80002fd6 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f9a:	4789                	li	a5,2
    80002f9c:	06f50a63          	beq	a0,a5,80003010 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002fa0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fa4:	10049073          	csrw	sstatus,s1
}
    80002fa8:	70a2                	ld	ra,40(sp)
    80002faa:	7402                	ld	s0,32(sp)
    80002fac:	64e2                	ld	s1,24(sp)
    80002fae:	6942                	ld	s2,16(sp)
    80002fb0:	69a2                	ld	s3,8(sp)
    80002fb2:	6145                	addi	sp,sp,48
    80002fb4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002fb6:	00005517          	auipc	a0,0x5
    80002fba:	44a50513          	addi	a0,a0,1098 # 80008400 <states.0+0xe0>
    80002fbe:	ffffd097          	auipc	ra,0xffffd
    80002fc2:	582080e7          	jalr	1410(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002fc6:	00005517          	auipc	a0,0x5
    80002fca:	46250513          	addi	a0,a0,1122 # 80008428 <states.0+0x108>
    80002fce:	ffffd097          	auipc	ra,0xffffd
    80002fd2:	572080e7          	jalr	1394(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002fd6:	85ce                	mv	a1,s3
    80002fd8:	00005517          	auipc	a0,0x5
    80002fdc:	47050513          	addi	a0,a0,1136 # 80008448 <states.0+0x128>
    80002fe0:	ffffd097          	auipc	ra,0xffffd
    80002fe4:	5aa080e7          	jalr	1450(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fe8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fec:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ff0:	00005517          	auipc	a0,0x5
    80002ff4:	46850513          	addi	a0,a0,1128 # 80008458 <states.0+0x138>
    80002ff8:	ffffd097          	auipc	ra,0xffffd
    80002ffc:	592080e7          	jalr	1426(ra) # 8000058a <printf>
    panic("kerneltrap");
    80003000:	00005517          	auipc	a0,0x5
    80003004:	47050513          	addi	a0,a0,1136 # 80008470 <states.0+0x150>
    80003008:	ffffd097          	auipc	ra,0xffffd
    8000300c:	538080e7          	jalr	1336(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003010:	fffff097          	auipc	ra,0xfffff
    80003014:	b20080e7          	jalr	-1248(ra) # 80001b30 <myproc>
    80003018:	d541                	beqz	a0,80002fa0 <kerneltrap+0x38>
    8000301a:	fffff097          	auipc	ra,0xfffff
    8000301e:	b16080e7          	jalr	-1258(ra) # 80001b30 <myproc>
    80003022:	bfbd                	j	80002fa0 <kerneltrap+0x38>

0000000080003024 <argraw>:
//   return 0;
// }

static uint64
argraw(int n)
{
    80003024:	1101                	addi	sp,sp,-32
    80003026:	ec06                	sd	ra,24(sp)
    80003028:	e822                	sd	s0,16(sp)
    8000302a:	e426                	sd	s1,8(sp)
    8000302c:	1000                	addi	s0,sp,32
    8000302e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003030:	fffff097          	auipc	ra,0xfffff
    80003034:	b00080e7          	jalr	-1280(ra) # 80001b30 <myproc>
  switch (n)
    80003038:	4795                	li	a5,5
    8000303a:	0497e163          	bltu	a5,s1,8000307c <argraw+0x58>
    8000303e:	048a                	slli	s1,s1,0x2
    80003040:	00005717          	auipc	a4,0x5
    80003044:	59870713          	addi	a4,a4,1432 # 800085d8 <states.0+0x2b8>
    80003048:	94ba                	add	s1,s1,a4
    8000304a:	409c                	lw	a5,0(s1)
    8000304c:	97ba                	add	a5,a5,a4
    8000304e:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80003050:	6d3c                	ld	a5,88(a0)
    80003052:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003054:	60e2                	ld	ra,24(sp)
    80003056:	6442                	ld	s0,16(sp)
    80003058:	64a2                	ld	s1,8(sp)
    8000305a:	6105                	addi	sp,sp,32
    8000305c:	8082                	ret
    return p->trapframe->a1;
    8000305e:	6d3c                	ld	a5,88(a0)
    80003060:	7fa8                	ld	a0,120(a5)
    80003062:	bfcd                	j	80003054 <argraw+0x30>
    return p->trapframe->a2;
    80003064:	6d3c                	ld	a5,88(a0)
    80003066:	63c8                	ld	a0,128(a5)
    80003068:	b7f5                	j	80003054 <argraw+0x30>
    return p->trapframe->a3;
    8000306a:	6d3c                	ld	a5,88(a0)
    8000306c:	67c8                	ld	a0,136(a5)
    8000306e:	b7dd                	j	80003054 <argraw+0x30>
    return p->trapframe->a4;
    80003070:	6d3c                	ld	a5,88(a0)
    80003072:	6bc8                	ld	a0,144(a5)
    80003074:	b7c5                	j	80003054 <argraw+0x30>
    return p->trapframe->a5;
    80003076:	6d3c                	ld	a5,88(a0)
    80003078:	6fc8                	ld	a0,152(a5)
    8000307a:	bfe9                	j	80003054 <argraw+0x30>
  panic("argraw");
    8000307c:	00005517          	auipc	a0,0x5
    80003080:	40450513          	addi	a0,a0,1028 # 80008480 <states.0+0x160>
    80003084:	ffffd097          	auipc	ra,0xffffd
    80003088:	4bc080e7          	jalr	1212(ra) # 80000540 <panic>

000000008000308c <fetchaddr>:
{
    8000308c:	1101                	addi	sp,sp,-32
    8000308e:	ec06                	sd	ra,24(sp)
    80003090:	e822                	sd	s0,16(sp)
    80003092:	e426                	sd	s1,8(sp)
    80003094:	e04a                	sd	s2,0(sp)
    80003096:	1000                	addi	s0,sp,32
    80003098:	84aa                	mv	s1,a0
    8000309a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000309c:	fffff097          	auipc	ra,0xfffff
    800030a0:	a94080e7          	jalr	-1388(ra) # 80001b30 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800030a4:	653c                	ld	a5,72(a0)
    800030a6:	02f4f863          	bgeu	s1,a5,800030d6 <fetchaddr+0x4a>
    800030aa:	00848713          	addi	a4,s1,8
    800030ae:	02e7e663          	bltu	a5,a4,800030da <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800030b2:	46a1                	li	a3,8
    800030b4:	8626                	mv	a2,s1
    800030b6:	85ca                	mv	a1,s2
    800030b8:	6928                	ld	a0,80(a0)
    800030ba:	ffffe097          	auipc	ra,0xffffe
    800030be:	7b8080e7          	jalr	1976(ra) # 80001872 <copyin>
    800030c2:	00a03533          	snez	a0,a0
    800030c6:	40a00533          	neg	a0,a0
}
    800030ca:	60e2                	ld	ra,24(sp)
    800030cc:	6442                	ld	s0,16(sp)
    800030ce:	64a2                	ld	s1,8(sp)
    800030d0:	6902                	ld	s2,0(sp)
    800030d2:	6105                	addi	sp,sp,32
    800030d4:	8082                	ret
    return -1;
    800030d6:	557d                	li	a0,-1
    800030d8:	bfcd                	j	800030ca <fetchaddr+0x3e>
    800030da:	557d                	li	a0,-1
    800030dc:	b7fd                	j	800030ca <fetchaddr+0x3e>

00000000800030de <fetchstr>:
{
    800030de:	7179                	addi	sp,sp,-48
    800030e0:	f406                	sd	ra,40(sp)
    800030e2:	f022                	sd	s0,32(sp)
    800030e4:	ec26                	sd	s1,24(sp)
    800030e6:	e84a                	sd	s2,16(sp)
    800030e8:	e44e                	sd	s3,8(sp)
    800030ea:	1800                	addi	s0,sp,48
    800030ec:	892a                	mv	s2,a0
    800030ee:	84ae                	mv	s1,a1
    800030f0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800030f2:	fffff097          	auipc	ra,0xfffff
    800030f6:	a3e080e7          	jalr	-1474(ra) # 80001b30 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    800030fa:	86ce                	mv	a3,s3
    800030fc:	864a                	mv	a2,s2
    800030fe:	85a6                	mv	a1,s1
    80003100:	6928                	ld	a0,80(a0)
    80003102:	ffffe097          	auipc	ra,0xffffe
    80003106:	7fe080e7          	jalr	2046(ra) # 80001900 <copyinstr>
    8000310a:	00054e63          	bltz	a0,80003126 <fetchstr+0x48>
  return strlen(buf);
    8000310e:	8526                	mv	a0,s1
    80003110:	ffffe097          	auipc	ra,0xffffe
    80003114:	e7e080e7          	jalr	-386(ra) # 80000f8e <strlen>
}
    80003118:	70a2                	ld	ra,40(sp)
    8000311a:	7402                	ld	s0,32(sp)
    8000311c:	64e2                	ld	s1,24(sp)
    8000311e:	6942                	ld	s2,16(sp)
    80003120:	69a2                	ld	s3,8(sp)
    80003122:	6145                	addi	sp,sp,48
    80003124:	8082                	ret
    return -1;
    80003126:	557d                	li	a0,-1
    80003128:	bfc5                	j	80003118 <fetchstr+0x3a>

000000008000312a <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    8000312a:	1101                	addi	sp,sp,-32
    8000312c:	ec06                	sd	ra,24(sp)
    8000312e:	e822                	sd	s0,16(sp)
    80003130:	e426                	sd	s1,8(sp)
    80003132:	1000                	addi	s0,sp,32
    80003134:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003136:	00000097          	auipc	ra,0x0
    8000313a:	eee080e7          	jalr	-274(ra) # 80003024 <argraw>
    8000313e:	c088                	sw	a0,0(s1)
}
    80003140:	60e2                	ld	ra,24(sp)
    80003142:	6442                	ld	s0,16(sp)
    80003144:	64a2                	ld	s1,8(sp)
    80003146:	6105                	addi	sp,sp,32
    80003148:	8082                	ret

000000008000314a <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip) // copies
{
    8000314a:	1101                	addi	sp,sp,-32
    8000314c:	ec06                	sd	ra,24(sp)
    8000314e:	e822                	sd	s0,16(sp)
    80003150:	e426                	sd	s1,8(sp)
    80003152:	1000                	addi	s0,sp,32
    80003154:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003156:	00000097          	auipc	ra,0x0
    8000315a:	ece080e7          	jalr	-306(ra) # 80003024 <argraw>
    8000315e:	e088                	sd	a0,0(s1)
}
    80003160:	60e2                	ld	ra,24(sp)
    80003162:	6442                	ld	s0,16(sp)
    80003164:	64a2                	ld	s1,8(sp)
    80003166:	6105                	addi	sp,sp,32
    80003168:	8082                	ret

000000008000316a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.

int argstr(int n, char *buf, int max)
{
    8000316a:	7179                	addi	sp,sp,-48
    8000316c:	f406                	sd	ra,40(sp)
    8000316e:	f022                	sd	s0,32(sp)
    80003170:	ec26                	sd	s1,24(sp)
    80003172:	e84a                	sd	s2,16(sp)
    80003174:	1800                	addi	s0,sp,48
    80003176:	84ae                	mv	s1,a1
    80003178:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000317a:	fd840593          	addi	a1,s0,-40
    8000317e:	00000097          	auipc	ra,0x0
    80003182:	fcc080e7          	jalr	-52(ra) # 8000314a <argaddr>
  return fetchstr(addr, buf, max);
    80003186:	864a                	mv	a2,s2
    80003188:	85a6                	mv	a1,s1
    8000318a:	fd843503          	ld	a0,-40(s0)
    8000318e:	00000097          	auipc	ra,0x0
    80003192:	f50080e7          	jalr	-176(ra) # 800030de <fetchstr>
}
    80003196:	70a2                	ld	ra,40(sp)
    80003198:	7402                	ld	s0,32(sp)
    8000319a:	64e2                	ld	s1,24(sp)
    8000319c:	6942                	ld	s2,16(sp)
    8000319e:	6145                	addi	sp,sp,48
    800031a0:	8082                	ret

00000000800031a2 <syscall>:

// sys_ps
// sys_set_priority
// sys_waitx
void syscall(void) // IS CALLED WHEN A SYSTEM CALL IS DONE
{
    800031a2:	7139                	addi	sp,sp,-64
    800031a4:	fc06                	sd	ra,56(sp)
    800031a6:	f822                	sd	s0,48(sp)
    800031a8:	f426                	sd	s1,40(sp)
    800031aa:	f04a                	sd	s2,32(sp)
    800031ac:	ec4e                	sd	s3,24(sp)
    800031ae:	e852                	sd	s4,16(sp)
    800031b0:	e456                	sd	s5,8(sp)
    800031b2:	e05a                	sd	s6,0(sp)
    800031b4:	0080                	addi	s0,sp,64
  int num, mask;
  struct proc *p = myproc(); // PROCESS
    800031b6:	fffff097          	auipc	ra,0xfffff
    800031ba:	97a080e7          	jalr	-1670(ra) # 80001b30 <myproc>
    800031be:	84aa                	mv	s1,a0

  num = p->trapframe->a7; // syscall number
    800031c0:	05853983          	ld	s3,88(a0)
    800031c4:	0a89b783          	ld	a5,168(s3)
    800031c8:	00078a1b          	sext.w	s4,a5
  mask = p->mask;         // getting maskgetrea
    800031cc:	16852903          	lw	s2,360(a0)
  if (num == SYS_read)
    800031d0:	4715                	li	a4,5
    800031d2:	0aea0a63          	beq	s4,a4,80003286 <syscall+0xe4>
  {
    // p->readid = p->readid + 1; // my change
    readcount++; // my change
  }
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800031d6:	37fd                	addiw	a5,a5,-1
    800031d8:	476d                	li	a4,27
    800031da:	0cf76563          	bltu	a4,a5,800032a4 <syscall+0x102>
    800031de:	003a1713          	slli	a4,s4,0x3
    800031e2:	00005797          	auipc	a5,0x5
    800031e6:	40e78793          	addi	a5,a5,1038 # 800085f0 <syscalls>
    800031ea:	97ba                	add	a5,a5,a4
    800031ec:	6398                	ld	a4,0(a5)
    800031ee:	cb5d                	beqz	a4,800032a4 <syscall+0x102>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    int argc = syscall_argc[num];
    800031f0:	002a1693          	slli	a3,s4,0x2
    800031f4:	00006797          	auipc	a5,0x6
    800031f8:	97478793          	addi	a5,a5,-1676 # 80008b68 <syscall_argc>
    800031fc:	97b6                	add	a5,a5,a3
    800031fe:	0007aa83          	lw	s5,0(a5)
    int arg_0 = p->trapframe->a0;
    80003202:	0709bb03          	ld	s6,112(s3)
    p->trapframe->a0 = syscalls[num](); // return value of syscall
    80003206:	9702                	jalr	a4
    80003208:	06a9b823          	sd	a0,112(s3)

    // ADD CODE HERE TO CHECK FOR MASK AND IF SYSCALL NUMBER IS SET OR NOT

    if ((mask != -1) && (mask & (1 << num)))
    8000320c:	57fd                	li	a5,-1
    8000320e:	0af90a63          	beq	s2,a5,800032c2 <syscall+0x120>
    80003212:	4149593b          	sraw	s2,s2,s4
    80003216:	00197913          	andi	s2,s2,1
    8000321a:	0a090463          	beqz	s2,800032c2 <syscall+0x120>
    {
      // PRINT THE LINE
      printf("%d: ", p->pid);                    // pid
    8000321e:	588c                	lw	a1,48(s1)
    80003220:	00005517          	auipc	a0,0x5
    80003224:	26850513          	addi	a0,a0,616 # 80008488 <states.0+0x168>
    80003228:	ffffd097          	auipc	ra,0xffffd
    8000322c:	362080e7          	jalr	866(ra) # 8000058a <printf>
      printf("syscall %s (", syscallnames[num]); // syscall name
    80003230:	0a0e                	slli	s4,s4,0x3
    80003232:	00005797          	auipc	a5,0x5
    80003236:	3be78793          	addi	a5,a5,958 # 800085f0 <syscalls>
    8000323a:	97d2                	add	a5,a5,s4
    8000323c:	77ec                	ld	a1,232(a5)
    8000323e:	00005517          	auipc	a0,0x5
    80003242:	25250513          	addi	a0,a0,594 # 80008490 <states.0+0x170>
    80003246:	ffffd097          	auipc	ra,0xffffd
    8000324a:	344080e7          	jalr	836(ra) # 8000058a <printf>
      if (argc >= 1)
    8000324e:	09504463          	bgtz	s5,800032d6 <syscall+0x134>
        printf("%d", arg_0);
      if (argc >= 2)
    80003252:	4785                	li	a5,1
    80003254:	0957cc63          	blt	a5,s5,800032ec <syscall+0x14a>
        printf(" %d", p->trapframe->a1);
      if (argc >= 3)
    80003258:	4789                	li	a5,2
    8000325a:	0b57c463          	blt	a5,s5,80003302 <syscall+0x160>
        printf(" %d", p->trapframe->a2);
      if (argc >= 4)
    8000325e:	478d                	li	a5,3
    80003260:	0b57cc63          	blt	a5,s5,80003318 <syscall+0x176>
        printf(" %d", p->trapframe->a3);
      if (argc >= 5)
    80003264:	4791                	li	a5,4
    80003266:	0d57c463          	blt	a5,s5,8000332e <syscall+0x18c>
        printf(" %d", p->trapframe->a4);
      if (argc >= 6)
    8000326a:	4795                	li	a5,5
    8000326c:	0d57cc63          	blt	a5,s5,80003344 <syscall+0x1a2>
        printf(" %d", p->trapframe->a5);
      printf(") -> %d\n", p->trapframe->a0); // return value
    80003270:	6cbc                	ld	a5,88(s1)
    80003272:	7bac                	ld	a1,112(a5)
    80003274:	00005517          	auipc	a0,0x5
    80003278:	23c50513          	addi	a0,a0,572 # 800084b0 <states.0+0x190>
    8000327c:	ffffd097          	auipc	ra,0xffffd
    80003280:	30e080e7          	jalr	782(ra) # 8000058a <printf>
    80003284:	a83d                	j	800032c2 <syscall+0x120>
    readcount++; // my change
    80003286:	00006697          	auipc	a3,0x6
    8000328a:	9ae68693          	addi	a3,a3,-1618 # 80008c34 <readcount>
    8000328e:	4298                	lw	a4,0(a3)
    80003290:	2705                	addiw	a4,a4,1
    80003292:	c298                	sw	a4,0(a3)
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80003294:	37fd                	addiw	a5,a5,-1
    80003296:	46ed                	li	a3,27
    80003298:	00003717          	auipc	a4,0x3
    8000329c:	94e70713          	addi	a4,a4,-1714 # 80005be6 <sys_read>
    800032a0:	f4f6f8e3          	bgeu	a3,a5,800031f0 <syscall+0x4e>
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    800032a4:	86d2                	mv	a3,s4
    800032a6:	15848613          	addi	a2,s1,344
    800032aa:	588c                	lw	a1,48(s1)
    800032ac:	00005517          	auipc	a0,0x5
    800032b0:	21450513          	addi	a0,a0,532 # 800084c0 <states.0+0x1a0>
    800032b4:	ffffd097          	auipc	ra,0xffffd
    800032b8:	2d6080e7          	jalr	726(ra) # 8000058a <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800032bc:	6cbc                	ld	a5,88(s1)
    800032be:	577d                	li	a4,-1
    800032c0:	fbb8                	sd	a4,112(a5)
  }
}
    800032c2:	70e2                	ld	ra,56(sp)
    800032c4:	7442                	ld	s0,48(sp)
    800032c6:	74a2                	ld	s1,40(sp)
    800032c8:	7902                	ld	s2,32(sp)
    800032ca:	69e2                	ld	s3,24(sp)
    800032cc:	6a42                	ld	s4,16(sp)
    800032ce:	6aa2                	ld	s5,8(sp)
    800032d0:	6b02                	ld	s6,0(sp)
    800032d2:	6121                	addi	sp,sp,64
    800032d4:	8082                	ret
        printf("%d", arg_0);
    800032d6:	000b059b          	sext.w	a1,s6
    800032da:	00005517          	auipc	a0,0x5
    800032de:	1c650513          	addi	a0,a0,454 # 800084a0 <states.0+0x180>
    800032e2:	ffffd097          	auipc	ra,0xffffd
    800032e6:	2a8080e7          	jalr	680(ra) # 8000058a <printf>
    800032ea:	b7a5                	j	80003252 <syscall+0xb0>
        printf(" %d", p->trapframe->a1);
    800032ec:	6cbc                	ld	a5,88(s1)
    800032ee:	7fac                	ld	a1,120(a5)
    800032f0:	00005517          	auipc	a0,0x5
    800032f4:	1b850513          	addi	a0,a0,440 # 800084a8 <states.0+0x188>
    800032f8:	ffffd097          	auipc	ra,0xffffd
    800032fc:	292080e7          	jalr	658(ra) # 8000058a <printf>
    80003300:	bfa1                	j	80003258 <syscall+0xb6>
        printf(" %d", p->trapframe->a2);
    80003302:	6cbc                	ld	a5,88(s1)
    80003304:	63cc                	ld	a1,128(a5)
    80003306:	00005517          	auipc	a0,0x5
    8000330a:	1a250513          	addi	a0,a0,418 # 800084a8 <states.0+0x188>
    8000330e:	ffffd097          	auipc	ra,0xffffd
    80003312:	27c080e7          	jalr	636(ra) # 8000058a <printf>
    80003316:	b7a1                	j	8000325e <syscall+0xbc>
        printf(" %d", p->trapframe->a3);
    80003318:	6cbc                	ld	a5,88(s1)
    8000331a:	67cc                	ld	a1,136(a5)
    8000331c:	00005517          	auipc	a0,0x5
    80003320:	18c50513          	addi	a0,a0,396 # 800084a8 <states.0+0x188>
    80003324:	ffffd097          	auipc	ra,0xffffd
    80003328:	266080e7          	jalr	614(ra) # 8000058a <printf>
    8000332c:	bf25                	j	80003264 <syscall+0xc2>
        printf(" %d", p->trapframe->a4);
    8000332e:	6cbc                	ld	a5,88(s1)
    80003330:	6bcc                	ld	a1,144(a5)
    80003332:	00005517          	auipc	a0,0x5
    80003336:	17650513          	addi	a0,a0,374 # 800084a8 <states.0+0x188>
    8000333a:	ffffd097          	auipc	ra,0xffffd
    8000333e:	250080e7          	jalr	592(ra) # 8000058a <printf>
    80003342:	b725                	j	8000326a <syscall+0xc8>
        printf(" %d", p->trapframe->a5);
    80003344:	6cbc                	ld	a5,88(s1)
    80003346:	6fcc                	ld	a1,152(a5)
    80003348:	00005517          	auipc	a0,0x5
    8000334c:	16050513          	addi	a0,a0,352 # 800084a8 <states.0+0x188>
    80003350:	ffffd097          	auipc	ra,0xffffd
    80003354:	23a080e7          	jalr	570(ra) # 8000058a <printf>
    80003358:	bf21                	j	80003270 <syscall+0xce>

000000008000335a <sys_exit>:
#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

uint64
sys_exit(void)
{
    8000335a:	1101                	addi	sp,sp,-32
    8000335c:	ec06                	sd	ra,24(sp)
    8000335e:	e822                	sd	s0,16(sp)
    80003360:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003362:	fec40593          	addi	a1,s0,-20
    80003366:	4501                	li	a0,0
    80003368:	00000097          	auipc	ra,0x0
    8000336c:	dc2080e7          	jalr	-574(ra) # 8000312a <argint>
  exit(n);
    80003370:	fec42503          	lw	a0,-20(s0)
    80003374:	fffff097          	auipc	ra,0xfffff
    80003378:	2d0080e7          	jalr	720(ra) # 80002644 <exit>
  return 0;  // not reached
}
    8000337c:	4501                	li	a0,0
    8000337e:	60e2                	ld	ra,24(sp)
    80003380:	6442                	ld	s0,16(sp)
    80003382:	6105                	addi	sp,sp,32
    80003384:	8082                	ret

0000000080003386 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003386:	1141                	addi	sp,sp,-16
    80003388:	e406                	sd	ra,8(sp)
    8000338a:	e022                	sd	s0,0(sp)
    8000338c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000338e:	ffffe097          	auipc	ra,0xffffe
    80003392:	7a2080e7          	jalr	1954(ra) # 80001b30 <myproc>
}
    80003396:	5908                	lw	a0,48(a0)
    80003398:	60a2                	ld	ra,8(sp)
    8000339a:	6402                	ld	s0,0(sp)
    8000339c:	0141                	addi	sp,sp,16
    8000339e:	8082                	ret

00000000800033a0 <sys_fork>:

uint64
sys_fork(void)
{
    800033a0:	1141                	addi	sp,sp,-16
    800033a2:	e406                	sd	ra,8(sp)
    800033a4:	e022                	sd	s0,0(sp)
    800033a6:	0800                	addi	s0,sp,16
  return fork();
    800033a8:	fffff097          	auipc	ra,0xfffff
    800033ac:	c5a080e7          	jalr	-934(ra) # 80002002 <fork>
}
    800033b0:	60a2                	ld	ra,8(sp)
    800033b2:	6402                	ld	s0,0(sp)
    800033b4:	0141                	addi	sp,sp,16
    800033b6:	8082                	ret

00000000800033b8 <sys_wait>:

uint64
sys_wait(void)
{
    800033b8:	1101                	addi	sp,sp,-32
    800033ba:	ec06                	sd	ra,24(sp)
    800033bc:	e822                	sd	s0,16(sp)
    800033be:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800033c0:	fe840593          	addi	a1,s0,-24
    800033c4:	4501                	li	a0,0
    800033c6:	00000097          	auipc	ra,0x0
    800033ca:	d84080e7          	jalr	-636(ra) # 8000314a <argaddr>
  return wait(p);
    800033ce:	fe843503          	ld	a0,-24(s0)
    800033d2:	fffff097          	auipc	ra,0xfffff
    800033d6:	4ac080e7          	jalr	1196(ra) # 8000287e <wait>
}
    800033da:	60e2                	ld	ra,24(sp)
    800033dc:	6442                	ld	s0,16(sp)
    800033de:	6105                	addi	sp,sp,32
    800033e0:	8082                	ret

00000000800033e2 <sys_waitx>:

uint64
sys_waitx(void)
{
    800033e2:	7139                	addi	sp,sp,-64
    800033e4:	fc06                	sd	ra,56(sp)
    800033e6:	f822                	sd	s0,48(sp)
    800033e8:	f426                	sd	s1,40(sp)
    800033ea:	f04a                	sd	s2,32(sp)
    800033ec:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  
  argaddr(0, &addr);
    800033ee:	fd840593          	addi	a1,s0,-40
    800033f2:	4501                	li	a0,0
    800033f4:	00000097          	auipc	ra,0x0
    800033f8:	d56080e7          	jalr	-682(ra) # 8000314a <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800033fc:	fd040593          	addi	a1,s0,-48
    80003400:	4505                	li	a0,1
    80003402:	00000097          	auipc	ra,0x0
    80003406:	d48080e7          	jalr	-696(ra) # 8000314a <argaddr>
  argaddr(2, &addr2);
    8000340a:	fc840593          	addi	a1,s0,-56
    8000340e:	4509                	li	a0,2
    80003410:	00000097          	auipc	ra,0x0
    80003414:	d3a080e7          	jalr	-710(ra) # 8000314a <argaddr>

  int ret = waitx(addr, &wtime, &rtime);
    80003418:	fc040613          	addi	a2,s0,-64
    8000341c:	fc440593          	addi	a1,s0,-60
    80003420:	fd843503          	ld	a0,-40(s0)
    80003424:	fffff097          	auipc	ra,0xfffff
    80003428:	000080e7          	jalr	ra # 80002424 <waitx>
    8000342c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000342e:	ffffe097          	auipc	ra,0xffffe
    80003432:	702080e7          	jalr	1794(ra) # 80001b30 <myproc>
    80003436:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003438:	4691                	li	a3,4
    8000343a:	fc440613          	addi	a2,s0,-60
    8000343e:	fd043583          	ld	a1,-48(s0)
    80003442:	6928                	ld	a0,80(a0)
    80003444:	ffffe097          	auipc	ra,0xffffe
    80003448:	354080e7          	jalr	852(ra) # 80001798 <copyout>
    return -1;
    8000344c:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000344e:	00054f63          	bltz	a0,8000346c <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003452:	4691                	li	a3,4
    80003454:	fc040613          	addi	a2,s0,-64
    80003458:	fc843583          	ld	a1,-56(s0)
    8000345c:	68a8                	ld	a0,80(s1)
    8000345e:	ffffe097          	auipc	ra,0xffffe
    80003462:	33a080e7          	jalr	826(ra) # 80001798 <copyout>
    80003466:	00054a63          	bltz	a0,8000347a <sys_waitx+0x98>
    return -1;
  return ret;
    8000346a:	87ca                	mv	a5,s2
}
    8000346c:	853e                	mv	a0,a5
    8000346e:	70e2                	ld	ra,56(sp)
    80003470:	7442                	ld	s0,48(sp)
    80003472:	74a2                	ld	s1,40(sp)
    80003474:	7902                	ld	s2,32(sp)
    80003476:	6121                	addi	sp,sp,64
    80003478:	8082                	ret
    return -1;
    8000347a:	57fd                	li	a5,-1
    8000347c:	bfc5                	j	8000346c <sys_waitx+0x8a>

000000008000347e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000347e:	7179                	addi	sp,sp,-48
    80003480:	f406                	sd	ra,40(sp)
    80003482:	f022                	sd	s0,32(sp)
    80003484:	ec26                	sd	s1,24(sp)
    80003486:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003488:	fdc40593          	addi	a1,s0,-36
    8000348c:	4501                	li	a0,0
    8000348e:	00000097          	auipc	ra,0x0
    80003492:	c9c080e7          	jalr	-868(ra) # 8000312a <argint>
  addr = myproc()->sz;
    80003496:	ffffe097          	auipc	ra,0xffffe
    8000349a:	69a080e7          	jalr	1690(ra) # 80001b30 <myproc>
    8000349e:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800034a0:	fdc42503          	lw	a0,-36(s0)
    800034a4:	fffff097          	auipc	ra,0xfffff
    800034a8:	b02080e7          	jalr	-1278(ra) # 80001fa6 <growproc>
    800034ac:	00054863          	bltz	a0,800034bc <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800034b0:	8526                	mv	a0,s1
    800034b2:	70a2                	ld	ra,40(sp)
    800034b4:	7402                	ld	s0,32(sp)
    800034b6:	64e2                	ld	s1,24(sp)
    800034b8:	6145                	addi	sp,sp,48
    800034ba:	8082                	ret
    return -1;
    800034bc:	54fd                	li	s1,-1
    800034be:	bfcd                	j	800034b0 <sys_sbrk+0x32>

00000000800034c0 <sys_trace>:

uint64
sys_trace(void) // JUST FOR CALLING SOME SYSTEM CALL IN PROC.C 
{
    800034c0:	1101                	addi	sp,sp,-32
    800034c2:	ec06                	sd	ra,24(sp)
    800034c4:	e822                	sd	s0,16(sp)
    800034c6:	1000                	addi	s0,sp,32
  // The functions in sysproc.c can access the process structure of a given process by calling myproc()
  int mask;
  argint(0, &mask);
    800034c8:	fec40593          	addi	a1,s0,-20
    800034cc:	4501                	li	a0,0
    800034ce:	00000097          	auipc	ra,0x0
    800034d2:	c5c080e7          	jalr	-932(ra) # 8000312a <argint>
  myproc()->mask=mask;
    800034d6:	ffffe097          	auipc	ra,0xffffe
    800034da:	65a080e7          	jalr	1626(ra) # 80001b30 <myproc>
    800034de:	fec42783          	lw	a5,-20(s0)
    800034e2:	16f52423          	sw	a5,360(a0)
  return 1; // during process initialisation only , we updated value of mask
}
    800034e6:	4505                	li	a0,1
    800034e8:	60e2                	ld	ra,24(sp)
    800034ea:	6442                	ld	s0,16(sp)
    800034ec:	6105                	addi	sp,sp,32
    800034ee:	8082                	ret

00000000800034f0 <sys_sigalarm>:

uint64
sys_sigalarm(void) // JUST FOR CALLING SOME SYSTEM CALL IN PROC.C 
{
    800034f0:	1101                	addi	sp,sp,-32
    800034f2:	ec06                	sd	ra,24(sp)
    800034f4:	e822                	sd	s0,16(sp)
    800034f6:	1000                	addi	s0,sp,32
  // The functions in sysproc.c can access the process structure of a given process by calling myproc()
  int n;
  uint64 handler;

  argint(0,&n);
    800034f8:	fec40593          	addi	a1,s0,-20
    800034fc:	4501                	li	a0,0
    800034fe:	00000097          	auipc	ra,0x0
    80003502:	c2c080e7          	jalr	-980(ra) # 8000312a <argint>
  argaddr(1,&handler);
    80003506:	fe040593          	addi	a1,s0,-32
    8000350a:	4505                	li	a0,1
    8000350c:	00000097          	auipc	ra,0x0
    80003510:	c3e080e7          	jalr	-962(ra) # 8000314a <argaddr>

  myproc()->is_sigalarm=0;
    80003514:	ffffe097          	auipc	ra,0xffffe
    80003518:	61c080e7          	jalr	1564(ra) # 80001b30 <myproc>
    8000351c:	1a052a23          	sw	zero,436(a0)
  myproc()->tslalarm=0;
    80003520:	ffffe097          	auipc	ra,0xffffe
    80003524:	610080e7          	jalr	1552(ra) # 80001b30 <myproc>
    80003528:	1c052423          	sw	zero,456(a0)
  myproc()->alarmint=n;
    8000352c:	ffffe097          	auipc	ra,0xffffe
    80003530:	604080e7          	jalr	1540(ra) # 80001b30 <myproc>
    80003534:	fec42783          	lw	a5,-20(s0)
    80003538:	1af52c23          	sw	a5,440(a0)
  myproc()->alarmhandler=handler;
    8000353c:	ffffe097          	auipc	ra,0xffffe
    80003540:	5f4080e7          	jalr	1524(ra) # 80001b30 <myproc>
    80003544:	fe043783          	ld	a5,-32(s0)
    80003548:	1cf53023          	sd	a5,448(a0)

  // just alert the user every n ticks 
  return 1; // during process initialisation only , we updated value of mask
}
    8000354c:	4505                	li	a0,1
    8000354e:	60e2                	ld	ra,24(sp)
    80003550:	6442                	ld	s0,16(sp)
    80003552:	6105                	addi	sp,sp,32
    80003554:	8082                	ret

0000000080003556 <sys_settickets>:

uint64
sys_settickets(void) // JUST FOR CALLING SOME SYSTEM CALL IN PROC.C 
{
    80003556:	1101                	addi	sp,sp,-32
    80003558:	ec06                	sd	ra,24(sp)
    8000355a:	e822                	sd	s0,16(sp)
    8000355c:	1000                	addi	s0,sp,32
  // The functions in sysproc.c can access the process structure of a given process by calling myproc()
  int tickets;
  argint(0,&tickets);
    8000355e:	fec40593          	addi	a1,s0,-20
    80003562:	4501                	li	a0,0
    80003564:	00000097          	auipc	ra,0x0
    80003568:	bc6080e7          	jalr	-1082(ra) # 8000312a <argint>

  myproc()->tickets=tickets;
    8000356c:	ffffe097          	auipc	ra,0xffffe
    80003570:	5c4080e7          	jalr	1476(ra) # 80001b30 <myproc>
    80003574:	fec42783          	lw	a5,-20(s0)
    80003578:	16f52823          	sw	a5,368(a0)

  return 1; 
}
    8000357c:	4505                	li	a0,1
    8000357e:	60e2                	ld	ra,24(sp)
    80003580:	6442                	ld	s0,16(sp)
    80003582:	6105                	addi	sp,sp,32
    80003584:	8082                	ret

0000000080003586 <sys_set_priority>:

uint64
sys_set_priority(void)
{
    80003586:	715d                	addi	sp,sp,-80
    80003588:	e486                	sd	ra,72(sp)
    8000358a:	e0a2                	sd	s0,64(sp)
    8000358c:	fc26                	sd	s1,56(sp)
    8000358e:	f84a                	sd	s2,48(sp)
    80003590:	f44e                	sd	s3,40(sp)
    80003592:	f052                	sd	s4,32(sp)
    80003594:	ec56                	sd	s5,24(sp)
    80003596:	e85a                	sd	s6,16(sp)
    80003598:	0880                	addi	s0,sp,80
  int np, pid, ret = 0;
  struct proc *p;
  extern struct proc proc[];

  argint(0, &np);
    8000359a:	fbc40593          	addi	a1,s0,-68
    8000359e:	4501                	li	a0,0
    800035a0:	00000097          	auipc	ra,0x0
    800035a4:	b8a080e7          	jalr	-1142(ra) # 8000312a <argint>
  argint(1, &pid);
    800035a8:	fb840593          	addi	a1,s0,-72
    800035ac:	4505                	li	a0,1
    800035ae:	00000097          	auipc	ra,0x0
    800035b2:	b7c080e7          	jalr	-1156(ra) # 8000312a <argint>
printf(" arg1 -->%d  arg2 ---->%d", np,pid);
    800035b6:	fb842603          	lw	a2,-72(s0)
    800035ba:	fbc42583          	lw	a1,-68(s0)
    800035be:	00005517          	auipc	a0,0x5
    800035c2:	20250513          	addi	a0,a0,514 # 800087c0 <syscallnames+0xe8>
    800035c6:	ffffd097          	auipc	ra,0xffffd
    800035ca:	fc4080e7          	jalr	-60(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800035ce:	0022e497          	auipc	s1,0x22e
    800035d2:	10248493          	addi	s1,s1,258 # 802316d0 <proc>
  int np, pid, ret = 0;
    800035d6:	4501                	li	a0,0
  {
    if (p->pid == pid)
    {
      printf("found");
    800035d8:	00005a97          	auipc	s5,0x5
    800035dc:	208a8a93          	addi	s5,s5,520 # 800087e0 <syscallnames+0x108>
      int olddp= min(p->stpriority+p->rbi,100); // old priority
    800035e0:	06400993          	li	s3,100

      ret = p->stpriority; // storing old static priority

      // p->niceness = 5; // updating niceness
      p->rbi = 25;
    800035e4:	4a65                	li	s4,25
      p->stpriority = np; // updating static priority

      int newdp= min(p->stpriority+p->rbi,100);  // new priority
    800035e6:	06400b13          	li	s6,100
  for (p = proc; p < &proc[NPROC]; p++)
    800035ea:	00236917          	auipc	s2,0x236
    800035ee:	8e690913          	addi	s2,s2,-1818 # 80238ed0 <queues>
    800035f2:	a029                	j	800035fc <sys_set_priority+0x76>
    800035f4:	1e048493          	addi	s1,s1,480
    800035f8:	05248a63          	beq	s1,s2,8000364c <sys_set_priority+0xc6>
    if (p->pid == pid)
    800035fc:	5898                	lw	a4,48(s1)
    800035fe:	fb842783          	lw	a5,-72(s0)
    80003602:	fef719e3          	bne	a4,a5,800035f4 <sys_set_priority+0x6e>
      printf("found");
    80003606:	8556                	mv	a0,s5
    80003608:	ffffd097          	auipc	ra,0xffffd
    8000360c:	f82080e7          	jalr	-126(ra) # 8000058a <printf>
      int olddp= min(p->stpriority+p->rbi,100); // old priority
    80003610:	1884a503          	lw	a0,392(s1)
    80003614:	1844a783          	lw	a5,388(s1)
    80003618:	9fa9                	addw	a5,a5,a0
    8000361a:	0007871b          	sext.w	a4,a5
    8000361e:	00e9d363          	bge	s3,a4,80003624 <sys_set_priority+0x9e>
    80003622:	87da                	mv	a5,s6
    80003624:	0007871b          	sext.w	a4,a5
      p->rbi = 25;
    80003628:	1944a223          	sw	s4,388(s1)
      p->stpriority = np; // updating static priority
    8000362c:	fbc42783          	lw	a5,-68(s0)
    80003630:	18f4a423          	sw	a5,392(s1)
      int newdp= min(p->stpriority+p->rbi,100);  // new priority
    80003634:	27e5                	addiw	a5,a5,25
    80003636:	0007869b          	sext.w	a3,a5
    8000363a:	00d9d363          	bge	s3,a3,80003640 <sys_set_priority+0xba>
    8000363e:	87da                	mv	a5,s6

      if(newdp<olddp) // if priority increases i.e dp value decreases , then reschedule
    80003640:	2781                	sext.w	a5,a5
    80003642:	fae7d9e3          	bge	a5,a4,800035f4 <sys_set_priority+0x6e>
        p->numpicked = 0;
    80003646:	1804a623          	sw	zero,396(s1)
    8000364a:	b76d                	j	800035f4 <sys_set_priority+0x6e>
    }
  }

  return ret;
}
    8000364c:	60a6                	ld	ra,72(sp)
    8000364e:	6406                	ld	s0,64(sp)
    80003650:	74e2                	ld	s1,56(sp)
    80003652:	7942                	ld	s2,48(sp)
    80003654:	79a2                	ld	s3,40(sp)
    80003656:	7a02                	ld	s4,32(sp)
    80003658:	6ae2                	ld	s5,24(sp)
    8000365a:	6b42                	ld	s6,16(sp)
    8000365c:	6161                	addi	sp,sp,80
    8000365e:	8082                	ret

0000000080003660 <sys_sigreturn>:

uint64 sys_sigreturn(void){
    80003660:	1141                	addi	sp,sp,-16
    80003662:	e406                	sd	ra,8(sp)
    80003664:	e022                	sd	s0,0(sp)
    80003666:	0800                	addi	s0,sp,16
  struct proc* p=myproc();
    80003668:	ffffe097          	auipc	ra,0xffffe
    8000366c:	4c8080e7          	jalr	1224(ra) # 80001b30 <myproc>

  // Restoring kernel stack for trapframe
  p->tf_copy->kernel_satp=p->trapframe->kernel_satp;
    80003670:	1d053783          	ld	a5,464(a0)
    80003674:	6d38                	ld	a4,88(a0)
    80003676:	6318                	ld	a4,0(a4)
    80003678:	e398                	sd	a4,0(a5)
  p->tf_copy->kernel_sp=p->trapframe->kernel_sp;
    8000367a:	1d053783          	ld	a5,464(a0)
    8000367e:	6d38                	ld	a4,88(a0)
    80003680:	6718                	ld	a4,8(a4)
    80003682:	e798                	sd	a4,8(a5)
  p->tf_copy->kernel_trap=p->trapframe->kernel_trap;
    80003684:	1d053783          	ld	a5,464(a0)
    80003688:	6d38                	ld	a4,88(a0)
    8000368a:	6b18                	ld	a4,16(a4)
    8000368c:	eb98                	sd	a4,16(a5)
  p->tf_copy->kernel_hartid=p->trapframe->kernel_hartid;
    8000368e:	1d053783          	ld	a5,464(a0)
    80003692:	6d38                	ld	a4,88(a0)
    80003694:	7318                	ld	a4,32(a4)
    80003696:	f398                	sd	a4,32(a5)

  // restoring previous things of trapframe
  *(p->trapframe)=*(p->tf_copy); 
    80003698:	1d053683          	ld	a3,464(a0)
    8000369c:	87b6                	mv	a5,a3
    8000369e:	6d38                	ld	a4,88(a0)
    800036a0:	12068693          	addi	a3,a3,288
    800036a4:	0007b883          	ld	a7,0(a5)
    800036a8:	0087b803          	ld	a6,8(a5)
    800036ac:	6b8c                	ld	a1,16(a5)
    800036ae:	6f90                	ld	a2,24(a5)
    800036b0:	01173023          	sd	a7,0(a4)
    800036b4:	01073423          	sd	a6,8(a4)
    800036b8:	eb0c                	sd	a1,16(a4)
    800036ba:	ef10                	sd	a2,24(a4)
    800036bc:	02078793          	addi	a5,a5,32
    800036c0:	02070713          	addi	a4,a4,32
    800036c4:	fed790e3          	bne	a5,a3,800036a4 <sys_sigreturn+0x44>
  p->is_sigalarm=0; // disabling alarm
    800036c8:	1a052a23          	sw	zero,436(a0)
  return myproc()->trapframe->a0;
    800036cc:	ffffe097          	auipc	ra,0xffffe
    800036d0:	464080e7          	jalr	1124(ra) # 80001b30 <myproc>
    800036d4:	6d3c                	ld	a5,88(a0)
}
    800036d6:	7ba8                	ld	a0,112(a5)
    800036d8:	60a2                	ld	ra,8(sp)
    800036da:	6402                	ld	s0,0(sp)
    800036dc:	0141                	addi	sp,sp,16
    800036de:	8082                	ret

00000000800036e0 <sys_sleep>:

uint64
sys_sleep(void)
{
    800036e0:	7139                	addi	sp,sp,-64
    800036e2:	fc06                	sd	ra,56(sp)
    800036e4:	f822                	sd	s0,48(sp)
    800036e6:	f426                	sd	s1,40(sp)
    800036e8:	f04a                	sd	s2,32(sp)
    800036ea:	ec4e                	sd	s3,24(sp)
    800036ec:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800036ee:	fcc40593          	addi	a1,s0,-52
    800036f2:	4501                	li	a0,0
    800036f4:	00000097          	auipc	ra,0x0
    800036f8:	a36080e7          	jalr	-1482(ra) # 8000312a <argint>
  acquire(&tickslock);
    800036fc:	00236517          	auipc	a0,0x236
    80003700:	82450513          	addi	a0,a0,-2012 # 80238f20 <tickslock>
    80003704:	ffffd097          	auipc	ra,0xffffd
    80003708:	612080e7          	jalr	1554(ra) # 80000d16 <acquire>
  ticks0 = ticks;
    8000370c:	00005917          	auipc	s2,0x5
    80003710:	52492903          	lw	s2,1316(s2) # 80008c30 <ticks>
  while(ticks - ticks0 < n){
    80003714:	fcc42783          	lw	a5,-52(s0)
    80003718:	cf9d                	beqz	a5,80003756 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000371a:	00236997          	auipc	s3,0x236
    8000371e:	80698993          	addi	s3,s3,-2042 # 80238f20 <tickslock>
    80003722:	00005497          	auipc	s1,0x5
    80003726:	50e48493          	addi	s1,s1,1294 # 80008c30 <ticks>
    if(killed(myproc())){
    8000372a:	ffffe097          	auipc	ra,0xffffe
    8000372e:	406080e7          	jalr	1030(ra) # 80001b30 <myproc>
    80003732:	fffff097          	auipc	ra,0xfffff
    80003736:	11a080e7          	jalr	282(ra) # 8000284c <killed>
    8000373a:	ed15                	bnez	a0,80003776 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000373c:	85ce                	mv	a1,s3
    8000373e:	8526                	mv	a0,s1
    80003740:	fffff097          	auipc	ra,0xfffff
    80003744:	c80080e7          	jalr	-896(ra) # 800023c0 <sleep>
  while(ticks - ticks0 < n){
    80003748:	409c                	lw	a5,0(s1)
    8000374a:	412787bb          	subw	a5,a5,s2
    8000374e:	fcc42703          	lw	a4,-52(s0)
    80003752:	fce7ece3          	bltu	a5,a4,8000372a <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003756:	00235517          	auipc	a0,0x235
    8000375a:	7ca50513          	addi	a0,a0,1994 # 80238f20 <tickslock>
    8000375e:	ffffd097          	auipc	ra,0xffffd
    80003762:	66c080e7          	jalr	1644(ra) # 80000dca <release>
  return 0;
    80003766:	4501                	li	a0,0
}
    80003768:	70e2                	ld	ra,56(sp)
    8000376a:	7442                	ld	s0,48(sp)
    8000376c:	74a2                	ld	s1,40(sp)
    8000376e:	7902                	ld	s2,32(sp)
    80003770:	69e2                	ld	s3,24(sp)
    80003772:	6121                	addi	sp,sp,64
    80003774:	8082                	ret
      release(&tickslock);
    80003776:	00235517          	auipc	a0,0x235
    8000377a:	7aa50513          	addi	a0,a0,1962 # 80238f20 <tickslock>
    8000377e:	ffffd097          	auipc	ra,0xffffd
    80003782:	64c080e7          	jalr	1612(ra) # 80000dca <release>
      return -1;
    80003786:	557d                	li	a0,-1
    80003788:	b7c5                	j	80003768 <sys_sleep+0x88>

000000008000378a <sys_kill>:

uint64
sys_kill(void)
{
    8000378a:	1101                	addi	sp,sp,-32
    8000378c:	ec06                	sd	ra,24(sp)
    8000378e:	e822                	sd	s0,16(sp)
    80003790:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003792:	fec40593          	addi	a1,s0,-20
    80003796:	4501                	li	a0,0
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	992080e7          	jalr	-1646(ra) # 8000312a <argint>
  return kill(pid);
    800037a0:	fec42503          	lw	a0,-20(s0)
    800037a4:	fffff097          	auipc	ra,0xfffff
    800037a8:	00a080e7          	jalr	10(ra) # 800027ae <kill>
}
    800037ac:	60e2                	ld	ra,24(sp)
    800037ae:	6442                	ld	s0,16(sp)
    800037b0:	6105                	addi	sp,sp,32
    800037b2:	8082                	ret

00000000800037b4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800037b4:	1101                	addi	sp,sp,-32
    800037b6:	ec06                	sd	ra,24(sp)
    800037b8:	e822                	sd	s0,16(sp)
    800037ba:	e426                	sd	s1,8(sp)
    800037bc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800037be:	00235517          	auipc	a0,0x235
    800037c2:	76250513          	addi	a0,a0,1890 # 80238f20 <tickslock>
    800037c6:	ffffd097          	auipc	ra,0xffffd
    800037ca:	550080e7          	jalr	1360(ra) # 80000d16 <acquire>
  xticks = ticks;
    800037ce:	00005497          	auipc	s1,0x5
    800037d2:	4624a483          	lw	s1,1122(s1) # 80008c30 <ticks>
  release(&tickslock);
    800037d6:	00235517          	auipc	a0,0x235
    800037da:	74a50513          	addi	a0,a0,1866 # 80238f20 <tickslock>
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	5ec080e7          	jalr	1516(ra) # 80000dca <release>
  return xticks;
}
    800037e6:	02049513          	slli	a0,s1,0x20
    800037ea:	9101                	srli	a0,a0,0x20
    800037ec:	60e2                	ld	ra,24(sp)
    800037ee:	6442                	ld	s0,16(sp)
    800037f0:	64a2                	ld	s1,8(sp)
    800037f2:	6105                	addi	sp,sp,32
    800037f4:	8082                	ret

00000000800037f6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800037f6:	7179                	addi	sp,sp,-48
    800037f8:	f406                	sd	ra,40(sp)
    800037fa:	f022                	sd	s0,32(sp)
    800037fc:	ec26                	sd	s1,24(sp)
    800037fe:	e84a                	sd	s2,16(sp)
    80003800:	e44e                	sd	s3,8(sp)
    80003802:	e052                	sd	s4,0(sp)
    80003804:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003806:	00005597          	auipc	a1,0x5
    8000380a:	fe258593          	addi	a1,a1,-30 # 800087e8 <syscallnames+0x110>
    8000380e:	00235517          	auipc	a0,0x235
    80003812:	72a50513          	addi	a0,a0,1834 # 80238f38 <bcache>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	470080e7          	jalr	1136(ra) # 80000c86 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000381e:	0023d797          	auipc	a5,0x23d
    80003822:	71a78793          	addi	a5,a5,1818 # 80240f38 <bcache+0x8000>
    80003826:	0023e717          	auipc	a4,0x23e
    8000382a:	97a70713          	addi	a4,a4,-1670 # 802411a0 <bcache+0x8268>
    8000382e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003832:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003836:	00235497          	auipc	s1,0x235
    8000383a:	71a48493          	addi	s1,s1,1818 # 80238f50 <bcache+0x18>
    b->next = bcache.head.next;
    8000383e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003840:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003842:	00005a17          	auipc	s4,0x5
    80003846:	faea0a13          	addi	s4,s4,-82 # 800087f0 <syscallnames+0x118>
    b->next = bcache.head.next;
    8000384a:	2b893783          	ld	a5,696(s2)
    8000384e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003850:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003854:	85d2                	mv	a1,s4
    80003856:	01048513          	addi	a0,s1,16
    8000385a:	00001097          	auipc	ra,0x1
    8000385e:	4c8080e7          	jalr	1224(ra) # 80004d22 <initsleeplock>
    bcache.head.next->prev = b;
    80003862:	2b893783          	ld	a5,696(s2)
    80003866:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003868:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000386c:	45848493          	addi	s1,s1,1112
    80003870:	fd349de3          	bne	s1,s3,8000384a <binit+0x54>
  }
}
    80003874:	70a2                	ld	ra,40(sp)
    80003876:	7402                	ld	s0,32(sp)
    80003878:	64e2                	ld	s1,24(sp)
    8000387a:	6942                	ld	s2,16(sp)
    8000387c:	69a2                	ld	s3,8(sp)
    8000387e:	6a02                	ld	s4,0(sp)
    80003880:	6145                	addi	sp,sp,48
    80003882:	8082                	ret

0000000080003884 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003884:	7179                	addi	sp,sp,-48
    80003886:	f406                	sd	ra,40(sp)
    80003888:	f022                	sd	s0,32(sp)
    8000388a:	ec26                	sd	s1,24(sp)
    8000388c:	e84a                	sd	s2,16(sp)
    8000388e:	e44e                	sd	s3,8(sp)
    80003890:	1800                	addi	s0,sp,48
    80003892:	892a                	mv	s2,a0
    80003894:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003896:	00235517          	auipc	a0,0x235
    8000389a:	6a250513          	addi	a0,a0,1698 # 80238f38 <bcache>
    8000389e:	ffffd097          	auipc	ra,0xffffd
    800038a2:	478080e7          	jalr	1144(ra) # 80000d16 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800038a6:	0023e497          	auipc	s1,0x23e
    800038aa:	94a4b483          	ld	s1,-1718(s1) # 802411f0 <bcache+0x82b8>
    800038ae:	0023e797          	auipc	a5,0x23e
    800038b2:	8f278793          	addi	a5,a5,-1806 # 802411a0 <bcache+0x8268>
    800038b6:	02f48f63          	beq	s1,a5,800038f4 <bread+0x70>
    800038ba:	873e                	mv	a4,a5
    800038bc:	a021                	j	800038c4 <bread+0x40>
    800038be:	68a4                	ld	s1,80(s1)
    800038c0:	02e48a63          	beq	s1,a4,800038f4 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800038c4:	449c                	lw	a5,8(s1)
    800038c6:	ff279ce3          	bne	a5,s2,800038be <bread+0x3a>
    800038ca:	44dc                	lw	a5,12(s1)
    800038cc:	ff3799e3          	bne	a5,s3,800038be <bread+0x3a>
      b->refcnt++;
    800038d0:	40bc                	lw	a5,64(s1)
    800038d2:	2785                	addiw	a5,a5,1
    800038d4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800038d6:	00235517          	auipc	a0,0x235
    800038da:	66250513          	addi	a0,a0,1634 # 80238f38 <bcache>
    800038de:	ffffd097          	auipc	ra,0xffffd
    800038e2:	4ec080e7          	jalr	1260(ra) # 80000dca <release>
      acquiresleep(&b->lock);
    800038e6:	01048513          	addi	a0,s1,16
    800038ea:	00001097          	auipc	ra,0x1
    800038ee:	472080e7          	jalr	1138(ra) # 80004d5c <acquiresleep>
      return b;
    800038f2:	a8b9                	j	80003950 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800038f4:	0023e497          	auipc	s1,0x23e
    800038f8:	8f44b483          	ld	s1,-1804(s1) # 802411e8 <bcache+0x82b0>
    800038fc:	0023e797          	auipc	a5,0x23e
    80003900:	8a478793          	addi	a5,a5,-1884 # 802411a0 <bcache+0x8268>
    80003904:	00f48863          	beq	s1,a5,80003914 <bread+0x90>
    80003908:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000390a:	40bc                	lw	a5,64(s1)
    8000390c:	cf81                	beqz	a5,80003924 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000390e:	64a4                	ld	s1,72(s1)
    80003910:	fee49de3          	bne	s1,a4,8000390a <bread+0x86>
  panic("bget: no buffers");
    80003914:	00005517          	auipc	a0,0x5
    80003918:	ee450513          	addi	a0,a0,-284 # 800087f8 <syscallnames+0x120>
    8000391c:	ffffd097          	auipc	ra,0xffffd
    80003920:	c24080e7          	jalr	-988(ra) # 80000540 <panic>
      b->dev = dev;
    80003924:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003928:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000392c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003930:	4785                	li	a5,1
    80003932:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003934:	00235517          	auipc	a0,0x235
    80003938:	60450513          	addi	a0,a0,1540 # 80238f38 <bcache>
    8000393c:	ffffd097          	auipc	ra,0xffffd
    80003940:	48e080e7          	jalr	1166(ra) # 80000dca <release>
      acquiresleep(&b->lock);
    80003944:	01048513          	addi	a0,s1,16
    80003948:	00001097          	auipc	ra,0x1
    8000394c:	414080e7          	jalr	1044(ra) # 80004d5c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003950:	409c                	lw	a5,0(s1)
    80003952:	cb89                	beqz	a5,80003964 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003954:	8526                	mv	a0,s1
    80003956:	70a2                	ld	ra,40(sp)
    80003958:	7402                	ld	s0,32(sp)
    8000395a:	64e2                	ld	s1,24(sp)
    8000395c:	6942                	ld	s2,16(sp)
    8000395e:	69a2                	ld	s3,8(sp)
    80003960:	6145                	addi	sp,sp,48
    80003962:	8082                	ret
    virtio_disk_rw(b, 0);
    80003964:	4581                	li	a1,0
    80003966:	8526                	mv	a0,s1
    80003968:	00003097          	auipc	ra,0x3
    8000396c:	ffa080e7          	jalr	-6(ra) # 80006962 <virtio_disk_rw>
    b->valid = 1;
    80003970:	4785                	li	a5,1
    80003972:	c09c                	sw	a5,0(s1)
  return b;
    80003974:	b7c5                	j	80003954 <bread+0xd0>

0000000080003976 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003976:	1101                	addi	sp,sp,-32
    80003978:	ec06                	sd	ra,24(sp)
    8000397a:	e822                	sd	s0,16(sp)
    8000397c:	e426                	sd	s1,8(sp)
    8000397e:	1000                	addi	s0,sp,32
    80003980:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003982:	0541                	addi	a0,a0,16
    80003984:	00001097          	auipc	ra,0x1
    80003988:	472080e7          	jalr	1138(ra) # 80004df6 <holdingsleep>
    8000398c:	cd01                	beqz	a0,800039a4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000398e:	4585                	li	a1,1
    80003990:	8526                	mv	a0,s1
    80003992:	00003097          	auipc	ra,0x3
    80003996:	fd0080e7          	jalr	-48(ra) # 80006962 <virtio_disk_rw>
}
    8000399a:	60e2                	ld	ra,24(sp)
    8000399c:	6442                	ld	s0,16(sp)
    8000399e:	64a2                	ld	s1,8(sp)
    800039a0:	6105                	addi	sp,sp,32
    800039a2:	8082                	ret
    panic("bwrite");
    800039a4:	00005517          	auipc	a0,0x5
    800039a8:	e6c50513          	addi	a0,a0,-404 # 80008810 <syscallnames+0x138>
    800039ac:	ffffd097          	auipc	ra,0xffffd
    800039b0:	b94080e7          	jalr	-1132(ra) # 80000540 <panic>

00000000800039b4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800039b4:	1101                	addi	sp,sp,-32
    800039b6:	ec06                	sd	ra,24(sp)
    800039b8:	e822                	sd	s0,16(sp)
    800039ba:	e426                	sd	s1,8(sp)
    800039bc:	e04a                	sd	s2,0(sp)
    800039be:	1000                	addi	s0,sp,32
    800039c0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800039c2:	01050913          	addi	s2,a0,16
    800039c6:	854a                	mv	a0,s2
    800039c8:	00001097          	auipc	ra,0x1
    800039cc:	42e080e7          	jalr	1070(ra) # 80004df6 <holdingsleep>
    800039d0:	c92d                	beqz	a0,80003a42 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800039d2:	854a                	mv	a0,s2
    800039d4:	00001097          	auipc	ra,0x1
    800039d8:	3de080e7          	jalr	990(ra) # 80004db2 <releasesleep>

  acquire(&bcache.lock);
    800039dc:	00235517          	auipc	a0,0x235
    800039e0:	55c50513          	addi	a0,a0,1372 # 80238f38 <bcache>
    800039e4:	ffffd097          	auipc	ra,0xffffd
    800039e8:	332080e7          	jalr	818(ra) # 80000d16 <acquire>
  b->refcnt--;
    800039ec:	40bc                	lw	a5,64(s1)
    800039ee:	37fd                	addiw	a5,a5,-1
    800039f0:	0007871b          	sext.w	a4,a5
    800039f4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800039f6:	eb05                	bnez	a4,80003a26 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800039f8:	68bc                	ld	a5,80(s1)
    800039fa:	64b8                	ld	a4,72(s1)
    800039fc:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800039fe:	64bc                	ld	a5,72(s1)
    80003a00:	68b8                	ld	a4,80(s1)
    80003a02:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003a04:	0023d797          	auipc	a5,0x23d
    80003a08:	53478793          	addi	a5,a5,1332 # 80240f38 <bcache+0x8000>
    80003a0c:	2b87b703          	ld	a4,696(a5)
    80003a10:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003a12:	0023d717          	auipc	a4,0x23d
    80003a16:	78e70713          	addi	a4,a4,1934 # 802411a0 <bcache+0x8268>
    80003a1a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003a1c:	2b87b703          	ld	a4,696(a5)
    80003a20:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003a22:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003a26:	00235517          	auipc	a0,0x235
    80003a2a:	51250513          	addi	a0,a0,1298 # 80238f38 <bcache>
    80003a2e:	ffffd097          	auipc	ra,0xffffd
    80003a32:	39c080e7          	jalr	924(ra) # 80000dca <release>
}
    80003a36:	60e2                	ld	ra,24(sp)
    80003a38:	6442                	ld	s0,16(sp)
    80003a3a:	64a2                	ld	s1,8(sp)
    80003a3c:	6902                	ld	s2,0(sp)
    80003a3e:	6105                	addi	sp,sp,32
    80003a40:	8082                	ret
    panic("brelse");
    80003a42:	00005517          	auipc	a0,0x5
    80003a46:	dd650513          	addi	a0,a0,-554 # 80008818 <syscallnames+0x140>
    80003a4a:	ffffd097          	auipc	ra,0xffffd
    80003a4e:	af6080e7          	jalr	-1290(ra) # 80000540 <panic>

0000000080003a52 <bpin>:

void
bpin(struct buf *b) {
    80003a52:	1101                	addi	sp,sp,-32
    80003a54:	ec06                	sd	ra,24(sp)
    80003a56:	e822                	sd	s0,16(sp)
    80003a58:	e426                	sd	s1,8(sp)
    80003a5a:	1000                	addi	s0,sp,32
    80003a5c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003a5e:	00235517          	auipc	a0,0x235
    80003a62:	4da50513          	addi	a0,a0,1242 # 80238f38 <bcache>
    80003a66:	ffffd097          	auipc	ra,0xffffd
    80003a6a:	2b0080e7          	jalr	688(ra) # 80000d16 <acquire>
  b->refcnt++;
    80003a6e:	40bc                	lw	a5,64(s1)
    80003a70:	2785                	addiw	a5,a5,1
    80003a72:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a74:	00235517          	auipc	a0,0x235
    80003a78:	4c450513          	addi	a0,a0,1220 # 80238f38 <bcache>
    80003a7c:	ffffd097          	auipc	ra,0xffffd
    80003a80:	34e080e7          	jalr	846(ra) # 80000dca <release>
}
    80003a84:	60e2                	ld	ra,24(sp)
    80003a86:	6442                	ld	s0,16(sp)
    80003a88:	64a2                	ld	s1,8(sp)
    80003a8a:	6105                	addi	sp,sp,32
    80003a8c:	8082                	ret

0000000080003a8e <bunpin>:

void
bunpin(struct buf *b) {
    80003a8e:	1101                	addi	sp,sp,-32
    80003a90:	ec06                	sd	ra,24(sp)
    80003a92:	e822                	sd	s0,16(sp)
    80003a94:	e426                	sd	s1,8(sp)
    80003a96:	1000                	addi	s0,sp,32
    80003a98:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003a9a:	00235517          	auipc	a0,0x235
    80003a9e:	49e50513          	addi	a0,a0,1182 # 80238f38 <bcache>
    80003aa2:	ffffd097          	auipc	ra,0xffffd
    80003aa6:	274080e7          	jalr	628(ra) # 80000d16 <acquire>
  b->refcnt--;
    80003aaa:	40bc                	lw	a5,64(s1)
    80003aac:	37fd                	addiw	a5,a5,-1
    80003aae:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003ab0:	00235517          	auipc	a0,0x235
    80003ab4:	48850513          	addi	a0,a0,1160 # 80238f38 <bcache>
    80003ab8:	ffffd097          	auipc	ra,0xffffd
    80003abc:	312080e7          	jalr	786(ra) # 80000dca <release>
}
    80003ac0:	60e2                	ld	ra,24(sp)
    80003ac2:	6442                	ld	s0,16(sp)
    80003ac4:	64a2                	ld	s1,8(sp)
    80003ac6:	6105                	addi	sp,sp,32
    80003ac8:	8082                	ret

0000000080003aca <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003aca:	1101                	addi	sp,sp,-32
    80003acc:	ec06                	sd	ra,24(sp)
    80003ace:	e822                	sd	s0,16(sp)
    80003ad0:	e426                	sd	s1,8(sp)
    80003ad2:	e04a                	sd	s2,0(sp)
    80003ad4:	1000                	addi	s0,sp,32
    80003ad6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003ad8:	00d5d59b          	srliw	a1,a1,0xd
    80003adc:	0023e797          	auipc	a5,0x23e
    80003ae0:	b387a783          	lw	a5,-1224(a5) # 80241614 <sb+0x1c>
    80003ae4:	9dbd                	addw	a1,a1,a5
    80003ae6:	00000097          	auipc	ra,0x0
    80003aea:	d9e080e7          	jalr	-610(ra) # 80003884 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003aee:	0074f713          	andi	a4,s1,7
    80003af2:	4785                	li	a5,1
    80003af4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003af8:	14ce                	slli	s1,s1,0x33
    80003afa:	90d9                	srli	s1,s1,0x36
    80003afc:	00950733          	add	a4,a0,s1
    80003b00:	05874703          	lbu	a4,88(a4)
    80003b04:	00e7f6b3          	and	a3,a5,a4
    80003b08:	c69d                	beqz	a3,80003b36 <bfree+0x6c>
    80003b0a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003b0c:	94aa                	add	s1,s1,a0
    80003b0e:	fff7c793          	not	a5,a5
    80003b12:	8f7d                	and	a4,a4,a5
    80003b14:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003b18:	00001097          	auipc	ra,0x1
    80003b1c:	126080e7          	jalr	294(ra) # 80004c3e <log_write>
  brelse(bp);
    80003b20:	854a                	mv	a0,s2
    80003b22:	00000097          	auipc	ra,0x0
    80003b26:	e92080e7          	jalr	-366(ra) # 800039b4 <brelse>
}
    80003b2a:	60e2                	ld	ra,24(sp)
    80003b2c:	6442                	ld	s0,16(sp)
    80003b2e:	64a2                	ld	s1,8(sp)
    80003b30:	6902                	ld	s2,0(sp)
    80003b32:	6105                	addi	sp,sp,32
    80003b34:	8082                	ret
    panic("freeing free block");
    80003b36:	00005517          	auipc	a0,0x5
    80003b3a:	cea50513          	addi	a0,a0,-790 # 80008820 <syscallnames+0x148>
    80003b3e:	ffffd097          	auipc	ra,0xffffd
    80003b42:	a02080e7          	jalr	-1534(ra) # 80000540 <panic>

0000000080003b46 <balloc>:
{
    80003b46:	711d                	addi	sp,sp,-96
    80003b48:	ec86                	sd	ra,88(sp)
    80003b4a:	e8a2                	sd	s0,80(sp)
    80003b4c:	e4a6                	sd	s1,72(sp)
    80003b4e:	e0ca                	sd	s2,64(sp)
    80003b50:	fc4e                	sd	s3,56(sp)
    80003b52:	f852                	sd	s4,48(sp)
    80003b54:	f456                	sd	s5,40(sp)
    80003b56:	f05a                	sd	s6,32(sp)
    80003b58:	ec5e                	sd	s7,24(sp)
    80003b5a:	e862                	sd	s8,16(sp)
    80003b5c:	e466                	sd	s9,8(sp)
    80003b5e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003b60:	0023e797          	auipc	a5,0x23e
    80003b64:	a9c7a783          	lw	a5,-1380(a5) # 802415fc <sb+0x4>
    80003b68:	cff5                	beqz	a5,80003c64 <balloc+0x11e>
    80003b6a:	8baa                	mv	s7,a0
    80003b6c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003b6e:	0023eb17          	auipc	s6,0x23e
    80003b72:	a8ab0b13          	addi	s6,s6,-1398 # 802415f8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b76:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003b78:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b7a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003b7c:	6c89                	lui	s9,0x2
    80003b7e:	a061                	j	80003c06 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003b80:	97ca                	add	a5,a5,s2
    80003b82:	8e55                	or	a2,a2,a3
    80003b84:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003b88:	854a                	mv	a0,s2
    80003b8a:	00001097          	auipc	ra,0x1
    80003b8e:	0b4080e7          	jalr	180(ra) # 80004c3e <log_write>
        brelse(bp);
    80003b92:	854a                	mv	a0,s2
    80003b94:	00000097          	auipc	ra,0x0
    80003b98:	e20080e7          	jalr	-480(ra) # 800039b4 <brelse>
  bp = bread(dev, bno);
    80003b9c:	85a6                	mv	a1,s1
    80003b9e:	855e                	mv	a0,s7
    80003ba0:	00000097          	auipc	ra,0x0
    80003ba4:	ce4080e7          	jalr	-796(ra) # 80003884 <bread>
    80003ba8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003baa:	40000613          	li	a2,1024
    80003bae:	4581                	li	a1,0
    80003bb0:	05850513          	addi	a0,a0,88
    80003bb4:	ffffd097          	auipc	ra,0xffffd
    80003bb8:	25e080e7          	jalr	606(ra) # 80000e12 <memset>
  log_write(bp);
    80003bbc:	854a                	mv	a0,s2
    80003bbe:	00001097          	auipc	ra,0x1
    80003bc2:	080080e7          	jalr	128(ra) # 80004c3e <log_write>
  brelse(bp);
    80003bc6:	854a                	mv	a0,s2
    80003bc8:	00000097          	auipc	ra,0x0
    80003bcc:	dec080e7          	jalr	-532(ra) # 800039b4 <brelse>
}
    80003bd0:	8526                	mv	a0,s1
    80003bd2:	60e6                	ld	ra,88(sp)
    80003bd4:	6446                	ld	s0,80(sp)
    80003bd6:	64a6                	ld	s1,72(sp)
    80003bd8:	6906                	ld	s2,64(sp)
    80003bda:	79e2                	ld	s3,56(sp)
    80003bdc:	7a42                	ld	s4,48(sp)
    80003bde:	7aa2                	ld	s5,40(sp)
    80003be0:	7b02                	ld	s6,32(sp)
    80003be2:	6be2                	ld	s7,24(sp)
    80003be4:	6c42                	ld	s8,16(sp)
    80003be6:	6ca2                	ld	s9,8(sp)
    80003be8:	6125                	addi	sp,sp,96
    80003bea:	8082                	ret
    brelse(bp);
    80003bec:	854a                	mv	a0,s2
    80003bee:	00000097          	auipc	ra,0x0
    80003bf2:	dc6080e7          	jalr	-570(ra) # 800039b4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003bf6:	015c87bb          	addw	a5,s9,s5
    80003bfa:	00078a9b          	sext.w	s5,a5
    80003bfe:	004b2703          	lw	a4,4(s6)
    80003c02:	06eaf163          	bgeu	s5,a4,80003c64 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003c06:	41fad79b          	sraiw	a5,s5,0x1f
    80003c0a:	0137d79b          	srliw	a5,a5,0x13
    80003c0e:	015787bb          	addw	a5,a5,s5
    80003c12:	40d7d79b          	sraiw	a5,a5,0xd
    80003c16:	01cb2583          	lw	a1,28(s6)
    80003c1a:	9dbd                	addw	a1,a1,a5
    80003c1c:	855e                	mv	a0,s7
    80003c1e:	00000097          	auipc	ra,0x0
    80003c22:	c66080e7          	jalr	-922(ra) # 80003884 <bread>
    80003c26:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c28:	004b2503          	lw	a0,4(s6)
    80003c2c:	000a849b          	sext.w	s1,s5
    80003c30:	8762                	mv	a4,s8
    80003c32:	faa4fde3          	bgeu	s1,a0,80003bec <balloc+0xa6>
      m = 1 << (bi % 8);
    80003c36:	00777693          	andi	a3,a4,7
    80003c3a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003c3e:	41f7579b          	sraiw	a5,a4,0x1f
    80003c42:	01d7d79b          	srliw	a5,a5,0x1d
    80003c46:	9fb9                	addw	a5,a5,a4
    80003c48:	4037d79b          	sraiw	a5,a5,0x3
    80003c4c:	00f90633          	add	a2,s2,a5
    80003c50:	05864603          	lbu	a2,88(a2)
    80003c54:	00c6f5b3          	and	a1,a3,a2
    80003c58:	d585                	beqz	a1,80003b80 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c5a:	2705                	addiw	a4,a4,1
    80003c5c:	2485                	addiw	s1,s1,1
    80003c5e:	fd471ae3          	bne	a4,s4,80003c32 <balloc+0xec>
    80003c62:	b769                	j	80003bec <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003c64:	00005517          	auipc	a0,0x5
    80003c68:	bd450513          	addi	a0,a0,-1068 # 80008838 <syscallnames+0x160>
    80003c6c:	ffffd097          	auipc	ra,0xffffd
    80003c70:	91e080e7          	jalr	-1762(ra) # 8000058a <printf>
  return 0;
    80003c74:	4481                	li	s1,0
    80003c76:	bfa9                	j	80003bd0 <balloc+0x8a>

0000000080003c78 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003c78:	7179                	addi	sp,sp,-48
    80003c7a:	f406                	sd	ra,40(sp)
    80003c7c:	f022                	sd	s0,32(sp)
    80003c7e:	ec26                	sd	s1,24(sp)
    80003c80:	e84a                	sd	s2,16(sp)
    80003c82:	e44e                	sd	s3,8(sp)
    80003c84:	e052                	sd	s4,0(sp)
    80003c86:	1800                	addi	s0,sp,48
    80003c88:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003c8a:	47ad                	li	a5,11
    80003c8c:	02b7e863          	bltu	a5,a1,80003cbc <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003c90:	02059793          	slli	a5,a1,0x20
    80003c94:	01e7d593          	srli	a1,a5,0x1e
    80003c98:	00b504b3          	add	s1,a0,a1
    80003c9c:	0504a903          	lw	s2,80(s1)
    80003ca0:	06091e63          	bnez	s2,80003d1c <bmap+0xa4>
      addr = balloc(ip->dev);
    80003ca4:	4108                	lw	a0,0(a0)
    80003ca6:	00000097          	auipc	ra,0x0
    80003caa:	ea0080e7          	jalr	-352(ra) # 80003b46 <balloc>
    80003cae:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003cb2:	06090563          	beqz	s2,80003d1c <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003cb6:	0524a823          	sw	s2,80(s1)
    80003cba:	a08d                	j	80003d1c <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003cbc:	ff45849b          	addiw	s1,a1,-12
    80003cc0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003cc4:	0ff00793          	li	a5,255
    80003cc8:	08e7e563          	bltu	a5,a4,80003d52 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003ccc:	08052903          	lw	s2,128(a0)
    80003cd0:	00091d63          	bnez	s2,80003cea <bmap+0x72>
      addr = balloc(ip->dev);
    80003cd4:	4108                	lw	a0,0(a0)
    80003cd6:	00000097          	auipc	ra,0x0
    80003cda:	e70080e7          	jalr	-400(ra) # 80003b46 <balloc>
    80003cde:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ce2:	02090d63          	beqz	s2,80003d1c <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003ce6:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003cea:	85ca                	mv	a1,s2
    80003cec:	0009a503          	lw	a0,0(s3)
    80003cf0:	00000097          	auipc	ra,0x0
    80003cf4:	b94080e7          	jalr	-1132(ra) # 80003884 <bread>
    80003cf8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003cfa:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003cfe:	02049713          	slli	a4,s1,0x20
    80003d02:	01e75593          	srli	a1,a4,0x1e
    80003d06:	00b784b3          	add	s1,a5,a1
    80003d0a:	0004a903          	lw	s2,0(s1)
    80003d0e:	02090063          	beqz	s2,80003d2e <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003d12:	8552                	mv	a0,s4
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	ca0080e7          	jalr	-864(ra) # 800039b4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003d1c:	854a                	mv	a0,s2
    80003d1e:	70a2                	ld	ra,40(sp)
    80003d20:	7402                	ld	s0,32(sp)
    80003d22:	64e2                	ld	s1,24(sp)
    80003d24:	6942                	ld	s2,16(sp)
    80003d26:	69a2                	ld	s3,8(sp)
    80003d28:	6a02                	ld	s4,0(sp)
    80003d2a:	6145                	addi	sp,sp,48
    80003d2c:	8082                	ret
      addr = balloc(ip->dev);
    80003d2e:	0009a503          	lw	a0,0(s3)
    80003d32:	00000097          	auipc	ra,0x0
    80003d36:	e14080e7          	jalr	-492(ra) # 80003b46 <balloc>
    80003d3a:	0005091b          	sext.w	s2,a0
      if(addr){
    80003d3e:	fc090ae3          	beqz	s2,80003d12 <bmap+0x9a>
        a[bn] = addr;
    80003d42:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003d46:	8552                	mv	a0,s4
    80003d48:	00001097          	auipc	ra,0x1
    80003d4c:	ef6080e7          	jalr	-266(ra) # 80004c3e <log_write>
    80003d50:	b7c9                	j	80003d12 <bmap+0x9a>
  panic("bmap: out of range");
    80003d52:	00005517          	auipc	a0,0x5
    80003d56:	afe50513          	addi	a0,a0,-1282 # 80008850 <syscallnames+0x178>
    80003d5a:	ffffc097          	auipc	ra,0xffffc
    80003d5e:	7e6080e7          	jalr	2022(ra) # 80000540 <panic>

0000000080003d62 <iget>:
{
    80003d62:	7179                	addi	sp,sp,-48
    80003d64:	f406                	sd	ra,40(sp)
    80003d66:	f022                	sd	s0,32(sp)
    80003d68:	ec26                	sd	s1,24(sp)
    80003d6a:	e84a                	sd	s2,16(sp)
    80003d6c:	e44e                	sd	s3,8(sp)
    80003d6e:	e052                	sd	s4,0(sp)
    80003d70:	1800                	addi	s0,sp,48
    80003d72:	89aa                	mv	s3,a0
    80003d74:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003d76:	0023e517          	auipc	a0,0x23e
    80003d7a:	8a250513          	addi	a0,a0,-1886 # 80241618 <itable>
    80003d7e:	ffffd097          	auipc	ra,0xffffd
    80003d82:	f98080e7          	jalr	-104(ra) # 80000d16 <acquire>
  empty = 0;
    80003d86:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d88:	0023e497          	auipc	s1,0x23e
    80003d8c:	8a848493          	addi	s1,s1,-1880 # 80241630 <itable+0x18>
    80003d90:	0023f697          	auipc	a3,0x23f
    80003d94:	33068693          	addi	a3,a3,816 # 802430c0 <log>
    80003d98:	a039                	j	80003da6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d9a:	02090b63          	beqz	s2,80003dd0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d9e:	08848493          	addi	s1,s1,136
    80003da2:	02d48a63          	beq	s1,a3,80003dd6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003da6:	449c                	lw	a5,8(s1)
    80003da8:	fef059e3          	blez	a5,80003d9a <iget+0x38>
    80003dac:	4098                	lw	a4,0(s1)
    80003dae:	ff3716e3          	bne	a4,s3,80003d9a <iget+0x38>
    80003db2:	40d8                	lw	a4,4(s1)
    80003db4:	ff4713e3          	bne	a4,s4,80003d9a <iget+0x38>
      ip->ref++;
    80003db8:	2785                	addiw	a5,a5,1
    80003dba:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003dbc:	0023e517          	auipc	a0,0x23e
    80003dc0:	85c50513          	addi	a0,a0,-1956 # 80241618 <itable>
    80003dc4:	ffffd097          	auipc	ra,0xffffd
    80003dc8:	006080e7          	jalr	6(ra) # 80000dca <release>
      return ip;
    80003dcc:	8926                	mv	s2,s1
    80003dce:	a03d                	j	80003dfc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003dd0:	f7f9                	bnez	a5,80003d9e <iget+0x3c>
    80003dd2:	8926                	mv	s2,s1
    80003dd4:	b7e9                	j	80003d9e <iget+0x3c>
  if(empty == 0)
    80003dd6:	02090c63          	beqz	s2,80003e0e <iget+0xac>
  ip->dev = dev;
    80003dda:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003dde:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003de2:	4785                	li	a5,1
    80003de4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003de8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003dec:	0023e517          	auipc	a0,0x23e
    80003df0:	82c50513          	addi	a0,a0,-2004 # 80241618 <itable>
    80003df4:	ffffd097          	auipc	ra,0xffffd
    80003df8:	fd6080e7          	jalr	-42(ra) # 80000dca <release>
}
    80003dfc:	854a                	mv	a0,s2
    80003dfe:	70a2                	ld	ra,40(sp)
    80003e00:	7402                	ld	s0,32(sp)
    80003e02:	64e2                	ld	s1,24(sp)
    80003e04:	6942                	ld	s2,16(sp)
    80003e06:	69a2                	ld	s3,8(sp)
    80003e08:	6a02                	ld	s4,0(sp)
    80003e0a:	6145                	addi	sp,sp,48
    80003e0c:	8082                	ret
    panic("iget: no inodes");
    80003e0e:	00005517          	auipc	a0,0x5
    80003e12:	a5a50513          	addi	a0,a0,-1446 # 80008868 <syscallnames+0x190>
    80003e16:	ffffc097          	auipc	ra,0xffffc
    80003e1a:	72a080e7          	jalr	1834(ra) # 80000540 <panic>

0000000080003e1e <fsinit>:
fsinit(int dev) {
    80003e1e:	7179                	addi	sp,sp,-48
    80003e20:	f406                	sd	ra,40(sp)
    80003e22:	f022                	sd	s0,32(sp)
    80003e24:	ec26                	sd	s1,24(sp)
    80003e26:	e84a                	sd	s2,16(sp)
    80003e28:	e44e                	sd	s3,8(sp)
    80003e2a:	1800                	addi	s0,sp,48
    80003e2c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003e2e:	4585                	li	a1,1
    80003e30:	00000097          	auipc	ra,0x0
    80003e34:	a54080e7          	jalr	-1452(ra) # 80003884 <bread>
    80003e38:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003e3a:	0023d997          	auipc	s3,0x23d
    80003e3e:	7be98993          	addi	s3,s3,1982 # 802415f8 <sb>
    80003e42:	02000613          	li	a2,32
    80003e46:	05850593          	addi	a1,a0,88
    80003e4a:	854e                	mv	a0,s3
    80003e4c:	ffffd097          	auipc	ra,0xffffd
    80003e50:	022080e7          	jalr	34(ra) # 80000e6e <memmove>
  brelse(bp);
    80003e54:	8526                	mv	a0,s1
    80003e56:	00000097          	auipc	ra,0x0
    80003e5a:	b5e080e7          	jalr	-1186(ra) # 800039b4 <brelse>
  if(sb.magic != FSMAGIC)
    80003e5e:	0009a703          	lw	a4,0(s3)
    80003e62:	102037b7          	lui	a5,0x10203
    80003e66:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003e6a:	02f71263          	bne	a4,a5,80003e8e <fsinit+0x70>
  initlog(dev, &sb);
    80003e6e:	0023d597          	auipc	a1,0x23d
    80003e72:	78a58593          	addi	a1,a1,1930 # 802415f8 <sb>
    80003e76:	854a                	mv	a0,s2
    80003e78:	00001097          	auipc	ra,0x1
    80003e7c:	b4a080e7          	jalr	-1206(ra) # 800049c2 <initlog>
}
    80003e80:	70a2                	ld	ra,40(sp)
    80003e82:	7402                	ld	s0,32(sp)
    80003e84:	64e2                	ld	s1,24(sp)
    80003e86:	6942                	ld	s2,16(sp)
    80003e88:	69a2                	ld	s3,8(sp)
    80003e8a:	6145                	addi	sp,sp,48
    80003e8c:	8082                	ret
    panic("invalid file system");
    80003e8e:	00005517          	auipc	a0,0x5
    80003e92:	9ea50513          	addi	a0,a0,-1558 # 80008878 <syscallnames+0x1a0>
    80003e96:	ffffc097          	auipc	ra,0xffffc
    80003e9a:	6aa080e7          	jalr	1706(ra) # 80000540 <panic>

0000000080003e9e <iinit>:
{
    80003e9e:	7179                	addi	sp,sp,-48
    80003ea0:	f406                	sd	ra,40(sp)
    80003ea2:	f022                	sd	s0,32(sp)
    80003ea4:	ec26                	sd	s1,24(sp)
    80003ea6:	e84a                	sd	s2,16(sp)
    80003ea8:	e44e                	sd	s3,8(sp)
    80003eaa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003eac:	00005597          	auipc	a1,0x5
    80003eb0:	9e458593          	addi	a1,a1,-1564 # 80008890 <syscallnames+0x1b8>
    80003eb4:	0023d517          	auipc	a0,0x23d
    80003eb8:	76450513          	addi	a0,a0,1892 # 80241618 <itable>
    80003ebc:	ffffd097          	auipc	ra,0xffffd
    80003ec0:	dca080e7          	jalr	-566(ra) # 80000c86 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003ec4:	0023d497          	auipc	s1,0x23d
    80003ec8:	77c48493          	addi	s1,s1,1916 # 80241640 <itable+0x28>
    80003ecc:	0023f997          	auipc	s3,0x23f
    80003ed0:	20498993          	addi	s3,s3,516 # 802430d0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003ed4:	00005917          	auipc	s2,0x5
    80003ed8:	9c490913          	addi	s2,s2,-1596 # 80008898 <syscallnames+0x1c0>
    80003edc:	85ca                	mv	a1,s2
    80003ede:	8526                	mv	a0,s1
    80003ee0:	00001097          	auipc	ra,0x1
    80003ee4:	e42080e7          	jalr	-446(ra) # 80004d22 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003ee8:	08848493          	addi	s1,s1,136
    80003eec:	ff3498e3          	bne	s1,s3,80003edc <iinit+0x3e>
}
    80003ef0:	70a2                	ld	ra,40(sp)
    80003ef2:	7402                	ld	s0,32(sp)
    80003ef4:	64e2                	ld	s1,24(sp)
    80003ef6:	6942                	ld	s2,16(sp)
    80003ef8:	69a2                	ld	s3,8(sp)
    80003efa:	6145                	addi	sp,sp,48
    80003efc:	8082                	ret

0000000080003efe <ialloc>:
{
    80003efe:	715d                	addi	sp,sp,-80
    80003f00:	e486                	sd	ra,72(sp)
    80003f02:	e0a2                	sd	s0,64(sp)
    80003f04:	fc26                	sd	s1,56(sp)
    80003f06:	f84a                	sd	s2,48(sp)
    80003f08:	f44e                	sd	s3,40(sp)
    80003f0a:	f052                	sd	s4,32(sp)
    80003f0c:	ec56                	sd	s5,24(sp)
    80003f0e:	e85a                	sd	s6,16(sp)
    80003f10:	e45e                	sd	s7,8(sp)
    80003f12:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f14:	0023d717          	auipc	a4,0x23d
    80003f18:	6f072703          	lw	a4,1776(a4) # 80241604 <sb+0xc>
    80003f1c:	4785                	li	a5,1
    80003f1e:	04e7fa63          	bgeu	a5,a4,80003f72 <ialloc+0x74>
    80003f22:	8aaa                	mv	s5,a0
    80003f24:	8bae                	mv	s7,a1
    80003f26:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003f28:	0023da17          	auipc	s4,0x23d
    80003f2c:	6d0a0a13          	addi	s4,s4,1744 # 802415f8 <sb>
    80003f30:	00048b1b          	sext.w	s6,s1
    80003f34:	0044d593          	srli	a1,s1,0x4
    80003f38:	018a2783          	lw	a5,24(s4)
    80003f3c:	9dbd                	addw	a1,a1,a5
    80003f3e:	8556                	mv	a0,s5
    80003f40:	00000097          	auipc	ra,0x0
    80003f44:	944080e7          	jalr	-1724(ra) # 80003884 <bread>
    80003f48:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003f4a:	05850993          	addi	s3,a0,88
    80003f4e:	00f4f793          	andi	a5,s1,15
    80003f52:	079a                	slli	a5,a5,0x6
    80003f54:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003f56:	00099783          	lh	a5,0(s3)
    80003f5a:	c3a1                	beqz	a5,80003f9a <ialloc+0x9c>
    brelse(bp);
    80003f5c:	00000097          	auipc	ra,0x0
    80003f60:	a58080e7          	jalr	-1448(ra) # 800039b4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f64:	0485                	addi	s1,s1,1
    80003f66:	00ca2703          	lw	a4,12(s4)
    80003f6a:	0004879b          	sext.w	a5,s1
    80003f6e:	fce7e1e3          	bltu	a5,a4,80003f30 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003f72:	00005517          	auipc	a0,0x5
    80003f76:	92e50513          	addi	a0,a0,-1746 # 800088a0 <syscallnames+0x1c8>
    80003f7a:	ffffc097          	auipc	ra,0xffffc
    80003f7e:	610080e7          	jalr	1552(ra) # 8000058a <printf>
  return 0;
    80003f82:	4501                	li	a0,0
}
    80003f84:	60a6                	ld	ra,72(sp)
    80003f86:	6406                	ld	s0,64(sp)
    80003f88:	74e2                	ld	s1,56(sp)
    80003f8a:	7942                	ld	s2,48(sp)
    80003f8c:	79a2                	ld	s3,40(sp)
    80003f8e:	7a02                	ld	s4,32(sp)
    80003f90:	6ae2                	ld	s5,24(sp)
    80003f92:	6b42                	ld	s6,16(sp)
    80003f94:	6ba2                	ld	s7,8(sp)
    80003f96:	6161                	addi	sp,sp,80
    80003f98:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003f9a:	04000613          	li	a2,64
    80003f9e:	4581                	li	a1,0
    80003fa0:	854e                	mv	a0,s3
    80003fa2:	ffffd097          	auipc	ra,0xffffd
    80003fa6:	e70080e7          	jalr	-400(ra) # 80000e12 <memset>
      dip->type = type;
    80003faa:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003fae:	854a                	mv	a0,s2
    80003fb0:	00001097          	auipc	ra,0x1
    80003fb4:	c8e080e7          	jalr	-882(ra) # 80004c3e <log_write>
      brelse(bp);
    80003fb8:	854a                	mv	a0,s2
    80003fba:	00000097          	auipc	ra,0x0
    80003fbe:	9fa080e7          	jalr	-1542(ra) # 800039b4 <brelse>
      return iget(dev, inum);
    80003fc2:	85da                	mv	a1,s6
    80003fc4:	8556                	mv	a0,s5
    80003fc6:	00000097          	auipc	ra,0x0
    80003fca:	d9c080e7          	jalr	-612(ra) # 80003d62 <iget>
    80003fce:	bf5d                	j	80003f84 <ialloc+0x86>

0000000080003fd0 <iupdate>:
{
    80003fd0:	1101                	addi	sp,sp,-32
    80003fd2:	ec06                	sd	ra,24(sp)
    80003fd4:	e822                	sd	s0,16(sp)
    80003fd6:	e426                	sd	s1,8(sp)
    80003fd8:	e04a                	sd	s2,0(sp)
    80003fda:	1000                	addi	s0,sp,32
    80003fdc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003fde:	415c                	lw	a5,4(a0)
    80003fe0:	0047d79b          	srliw	a5,a5,0x4
    80003fe4:	0023d597          	auipc	a1,0x23d
    80003fe8:	62c5a583          	lw	a1,1580(a1) # 80241610 <sb+0x18>
    80003fec:	9dbd                	addw	a1,a1,a5
    80003fee:	4108                	lw	a0,0(a0)
    80003ff0:	00000097          	auipc	ra,0x0
    80003ff4:	894080e7          	jalr	-1900(ra) # 80003884 <bread>
    80003ff8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ffa:	05850793          	addi	a5,a0,88
    80003ffe:	40d8                	lw	a4,4(s1)
    80004000:	8b3d                	andi	a4,a4,15
    80004002:	071a                	slli	a4,a4,0x6
    80004004:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80004006:	04449703          	lh	a4,68(s1)
    8000400a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000400e:	04649703          	lh	a4,70(s1)
    80004012:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80004016:	04849703          	lh	a4,72(s1)
    8000401a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000401e:	04a49703          	lh	a4,74(s1)
    80004022:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80004026:	44f8                	lw	a4,76(s1)
    80004028:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000402a:	03400613          	li	a2,52
    8000402e:	05048593          	addi	a1,s1,80
    80004032:	00c78513          	addi	a0,a5,12
    80004036:	ffffd097          	auipc	ra,0xffffd
    8000403a:	e38080e7          	jalr	-456(ra) # 80000e6e <memmove>
  log_write(bp);
    8000403e:	854a                	mv	a0,s2
    80004040:	00001097          	auipc	ra,0x1
    80004044:	bfe080e7          	jalr	-1026(ra) # 80004c3e <log_write>
  brelse(bp);
    80004048:	854a                	mv	a0,s2
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	96a080e7          	jalr	-1686(ra) # 800039b4 <brelse>
}
    80004052:	60e2                	ld	ra,24(sp)
    80004054:	6442                	ld	s0,16(sp)
    80004056:	64a2                	ld	s1,8(sp)
    80004058:	6902                	ld	s2,0(sp)
    8000405a:	6105                	addi	sp,sp,32
    8000405c:	8082                	ret

000000008000405e <idup>:
{
    8000405e:	1101                	addi	sp,sp,-32
    80004060:	ec06                	sd	ra,24(sp)
    80004062:	e822                	sd	s0,16(sp)
    80004064:	e426                	sd	s1,8(sp)
    80004066:	1000                	addi	s0,sp,32
    80004068:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000406a:	0023d517          	auipc	a0,0x23d
    8000406e:	5ae50513          	addi	a0,a0,1454 # 80241618 <itable>
    80004072:	ffffd097          	auipc	ra,0xffffd
    80004076:	ca4080e7          	jalr	-860(ra) # 80000d16 <acquire>
  ip->ref++;
    8000407a:	449c                	lw	a5,8(s1)
    8000407c:	2785                	addiw	a5,a5,1
    8000407e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004080:	0023d517          	auipc	a0,0x23d
    80004084:	59850513          	addi	a0,a0,1432 # 80241618 <itable>
    80004088:	ffffd097          	auipc	ra,0xffffd
    8000408c:	d42080e7          	jalr	-702(ra) # 80000dca <release>
}
    80004090:	8526                	mv	a0,s1
    80004092:	60e2                	ld	ra,24(sp)
    80004094:	6442                	ld	s0,16(sp)
    80004096:	64a2                	ld	s1,8(sp)
    80004098:	6105                	addi	sp,sp,32
    8000409a:	8082                	ret

000000008000409c <ilock>:
{
    8000409c:	1101                	addi	sp,sp,-32
    8000409e:	ec06                	sd	ra,24(sp)
    800040a0:	e822                	sd	s0,16(sp)
    800040a2:	e426                	sd	s1,8(sp)
    800040a4:	e04a                	sd	s2,0(sp)
    800040a6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800040a8:	c115                	beqz	a0,800040cc <ilock+0x30>
    800040aa:	84aa                	mv	s1,a0
    800040ac:	451c                	lw	a5,8(a0)
    800040ae:	00f05f63          	blez	a5,800040cc <ilock+0x30>
  acquiresleep(&ip->lock);
    800040b2:	0541                	addi	a0,a0,16
    800040b4:	00001097          	auipc	ra,0x1
    800040b8:	ca8080e7          	jalr	-856(ra) # 80004d5c <acquiresleep>
  if(ip->valid == 0){
    800040bc:	40bc                	lw	a5,64(s1)
    800040be:	cf99                	beqz	a5,800040dc <ilock+0x40>
}
    800040c0:	60e2                	ld	ra,24(sp)
    800040c2:	6442                	ld	s0,16(sp)
    800040c4:	64a2                	ld	s1,8(sp)
    800040c6:	6902                	ld	s2,0(sp)
    800040c8:	6105                	addi	sp,sp,32
    800040ca:	8082                	ret
    panic("ilock");
    800040cc:	00004517          	auipc	a0,0x4
    800040d0:	7ec50513          	addi	a0,a0,2028 # 800088b8 <syscallnames+0x1e0>
    800040d4:	ffffc097          	auipc	ra,0xffffc
    800040d8:	46c080e7          	jalr	1132(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800040dc:	40dc                	lw	a5,4(s1)
    800040de:	0047d79b          	srliw	a5,a5,0x4
    800040e2:	0023d597          	auipc	a1,0x23d
    800040e6:	52e5a583          	lw	a1,1326(a1) # 80241610 <sb+0x18>
    800040ea:	9dbd                	addw	a1,a1,a5
    800040ec:	4088                	lw	a0,0(s1)
    800040ee:	fffff097          	auipc	ra,0xfffff
    800040f2:	796080e7          	jalr	1942(ra) # 80003884 <bread>
    800040f6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800040f8:	05850593          	addi	a1,a0,88
    800040fc:	40dc                	lw	a5,4(s1)
    800040fe:	8bbd                	andi	a5,a5,15
    80004100:	079a                	slli	a5,a5,0x6
    80004102:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004104:	00059783          	lh	a5,0(a1)
    80004108:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000410c:	00259783          	lh	a5,2(a1)
    80004110:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004114:	00459783          	lh	a5,4(a1)
    80004118:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000411c:	00659783          	lh	a5,6(a1)
    80004120:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004124:	459c                	lw	a5,8(a1)
    80004126:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004128:	03400613          	li	a2,52
    8000412c:	05b1                	addi	a1,a1,12
    8000412e:	05048513          	addi	a0,s1,80
    80004132:	ffffd097          	auipc	ra,0xffffd
    80004136:	d3c080e7          	jalr	-708(ra) # 80000e6e <memmove>
    brelse(bp);
    8000413a:	854a                	mv	a0,s2
    8000413c:	00000097          	auipc	ra,0x0
    80004140:	878080e7          	jalr	-1928(ra) # 800039b4 <brelse>
    ip->valid = 1;
    80004144:	4785                	li	a5,1
    80004146:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004148:	04449783          	lh	a5,68(s1)
    8000414c:	fbb5                	bnez	a5,800040c0 <ilock+0x24>
      panic("ilock: no type");
    8000414e:	00004517          	auipc	a0,0x4
    80004152:	77250513          	addi	a0,a0,1906 # 800088c0 <syscallnames+0x1e8>
    80004156:	ffffc097          	auipc	ra,0xffffc
    8000415a:	3ea080e7          	jalr	1002(ra) # 80000540 <panic>

000000008000415e <iunlock>:
{
    8000415e:	1101                	addi	sp,sp,-32
    80004160:	ec06                	sd	ra,24(sp)
    80004162:	e822                	sd	s0,16(sp)
    80004164:	e426                	sd	s1,8(sp)
    80004166:	e04a                	sd	s2,0(sp)
    80004168:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000416a:	c905                	beqz	a0,8000419a <iunlock+0x3c>
    8000416c:	84aa                	mv	s1,a0
    8000416e:	01050913          	addi	s2,a0,16
    80004172:	854a                	mv	a0,s2
    80004174:	00001097          	auipc	ra,0x1
    80004178:	c82080e7          	jalr	-894(ra) # 80004df6 <holdingsleep>
    8000417c:	cd19                	beqz	a0,8000419a <iunlock+0x3c>
    8000417e:	449c                	lw	a5,8(s1)
    80004180:	00f05d63          	blez	a5,8000419a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004184:	854a                	mv	a0,s2
    80004186:	00001097          	auipc	ra,0x1
    8000418a:	c2c080e7          	jalr	-980(ra) # 80004db2 <releasesleep>
}
    8000418e:	60e2                	ld	ra,24(sp)
    80004190:	6442                	ld	s0,16(sp)
    80004192:	64a2                	ld	s1,8(sp)
    80004194:	6902                	ld	s2,0(sp)
    80004196:	6105                	addi	sp,sp,32
    80004198:	8082                	ret
    panic("iunlock");
    8000419a:	00004517          	auipc	a0,0x4
    8000419e:	73650513          	addi	a0,a0,1846 # 800088d0 <syscallnames+0x1f8>
    800041a2:	ffffc097          	auipc	ra,0xffffc
    800041a6:	39e080e7          	jalr	926(ra) # 80000540 <panic>

00000000800041aa <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800041aa:	7179                	addi	sp,sp,-48
    800041ac:	f406                	sd	ra,40(sp)
    800041ae:	f022                	sd	s0,32(sp)
    800041b0:	ec26                	sd	s1,24(sp)
    800041b2:	e84a                	sd	s2,16(sp)
    800041b4:	e44e                	sd	s3,8(sp)
    800041b6:	e052                	sd	s4,0(sp)
    800041b8:	1800                	addi	s0,sp,48
    800041ba:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800041bc:	05050493          	addi	s1,a0,80
    800041c0:	08050913          	addi	s2,a0,128
    800041c4:	a021                	j	800041cc <itrunc+0x22>
    800041c6:	0491                	addi	s1,s1,4
    800041c8:	01248d63          	beq	s1,s2,800041e2 <itrunc+0x38>
    if(ip->addrs[i]){
    800041cc:	408c                	lw	a1,0(s1)
    800041ce:	dde5                	beqz	a1,800041c6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800041d0:	0009a503          	lw	a0,0(s3)
    800041d4:	00000097          	auipc	ra,0x0
    800041d8:	8f6080e7          	jalr	-1802(ra) # 80003aca <bfree>
      ip->addrs[i] = 0;
    800041dc:	0004a023          	sw	zero,0(s1)
    800041e0:	b7dd                	j	800041c6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800041e2:	0809a583          	lw	a1,128(s3)
    800041e6:	e185                	bnez	a1,80004206 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800041e8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800041ec:	854e                	mv	a0,s3
    800041ee:	00000097          	auipc	ra,0x0
    800041f2:	de2080e7          	jalr	-542(ra) # 80003fd0 <iupdate>
}
    800041f6:	70a2                	ld	ra,40(sp)
    800041f8:	7402                	ld	s0,32(sp)
    800041fa:	64e2                	ld	s1,24(sp)
    800041fc:	6942                	ld	s2,16(sp)
    800041fe:	69a2                	ld	s3,8(sp)
    80004200:	6a02                	ld	s4,0(sp)
    80004202:	6145                	addi	sp,sp,48
    80004204:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004206:	0009a503          	lw	a0,0(s3)
    8000420a:	fffff097          	auipc	ra,0xfffff
    8000420e:	67a080e7          	jalr	1658(ra) # 80003884 <bread>
    80004212:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004214:	05850493          	addi	s1,a0,88
    80004218:	45850913          	addi	s2,a0,1112
    8000421c:	a021                	j	80004224 <itrunc+0x7a>
    8000421e:	0491                	addi	s1,s1,4
    80004220:	01248b63          	beq	s1,s2,80004236 <itrunc+0x8c>
      if(a[j])
    80004224:	408c                	lw	a1,0(s1)
    80004226:	dde5                	beqz	a1,8000421e <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004228:	0009a503          	lw	a0,0(s3)
    8000422c:	00000097          	auipc	ra,0x0
    80004230:	89e080e7          	jalr	-1890(ra) # 80003aca <bfree>
    80004234:	b7ed                	j	8000421e <itrunc+0x74>
    brelse(bp);
    80004236:	8552                	mv	a0,s4
    80004238:	fffff097          	auipc	ra,0xfffff
    8000423c:	77c080e7          	jalr	1916(ra) # 800039b4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004240:	0809a583          	lw	a1,128(s3)
    80004244:	0009a503          	lw	a0,0(s3)
    80004248:	00000097          	auipc	ra,0x0
    8000424c:	882080e7          	jalr	-1918(ra) # 80003aca <bfree>
    ip->addrs[NDIRECT] = 0;
    80004250:	0809a023          	sw	zero,128(s3)
    80004254:	bf51                	j	800041e8 <itrunc+0x3e>

0000000080004256 <iput>:
{
    80004256:	1101                	addi	sp,sp,-32
    80004258:	ec06                	sd	ra,24(sp)
    8000425a:	e822                	sd	s0,16(sp)
    8000425c:	e426                	sd	s1,8(sp)
    8000425e:	e04a                	sd	s2,0(sp)
    80004260:	1000                	addi	s0,sp,32
    80004262:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004264:	0023d517          	auipc	a0,0x23d
    80004268:	3b450513          	addi	a0,a0,948 # 80241618 <itable>
    8000426c:	ffffd097          	auipc	ra,0xffffd
    80004270:	aaa080e7          	jalr	-1366(ra) # 80000d16 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004274:	4498                	lw	a4,8(s1)
    80004276:	4785                	li	a5,1
    80004278:	02f70363          	beq	a4,a5,8000429e <iput+0x48>
  ip->ref--;
    8000427c:	449c                	lw	a5,8(s1)
    8000427e:	37fd                	addiw	a5,a5,-1
    80004280:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004282:	0023d517          	auipc	a0,0x23d
    80004286:	39650513          	addi	a0,a0,918 # 80241618 <itable>
    8000428a:	ffffd097          	auipc	ra,0xffffd
    8000428e:	b40080e7          	jalr	-1216(ra) # 80000dca <release>
}
    80004292:	60e2                	ld	ra,24(sp)
    80004294:	6442                	ld	s0,16(sp)
    80004296:	64a2                	ld	s1,8(sp)
    80004298:	6902                	ld	s2,0(sp)
    8000429a:	6105                	addi	sp,sp,32
    8000429c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000429e:	40bc                	lw	a5,64(s1)
    800042a0:	dff1                	beqz	a5,8000427c <iput+0x26>
    800042a2:	04a49783          	lh	a5,74(s1)
    800042a6:	fbf9                	bnez	a5,8000427c <iput+0x26>
    acquiresleep(&ip->lock);
    800042a8:	01048913          	addi	s2,s1,16
    800042ac:	854a                	mv	a0,s2
    800042ae:	00001097          	auipc	ra,0x1
    800042b2:	aae080e7          	jalr	-1362(ra) # 80004d5c <acquiresleep>
    release(&itable.lock);
    800042b6:	0023d517          	auipc	a0,0x23d
    800042ba:	36250513          	addi	a0,a0,866 # 80241618 <itable>
    800042be:	ffffd097          	auipc	ra,0xffffd
    800042c2:	b0c080e7          	jalr	-1268(ra) # 80000dca <release>
    itrunc(ip);
    800042c6:	8526                	mv	a0,s1
    800042c8:	00000097          	auipc	ra,0x0
    800042cc:	ee2080e7          	jalr	-286(ra) # 800041aa <itrunc>
    ip->type = 0;
    800042d0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800042d4:	8526                	mv	a0,s1
    800042d6:	00000097          	auipc	ra,0x0
    800042da:	cfa080e7          	jalr	-774(ra) # 80003fd0 <iupdate>
    ip->valid = 0;
    800042de:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800042e2:	854a                	mv	a0,s2
    800042e4:	00001097          	auipc	ra,0x1
    800042e8:	ace080e7          	jalr	-1330(ra) # 80004db2 <releasesleep>
    acquire(&itable.lock);
    800042ec:	0023d517          	auipc	a0,0x23d
    800042f0:	32c50513          	addi	a0,a0,812 # 80241618 <itable>
    800042f4:	ffffd097          	auipc	ra,0xffffd
    800042f8:	a22080e7          	jalr	-1502(ra) # 80000d16 <acquire>
    800042fc:	b741                	j	8000427c <iput+0x26>

00000000800042fe <iunlockput>:
{
    800042fe:	1101                	addi	sp,sp,-32
    80004300:	ec06                	sd	ra,24(sp)
    80004302:	e822                	sd	s0,16(sp)
    80004304:	e426                	sd	s1,8(sp)
    80004306:	1000                	addi	s0,sp,32
    80004308:	84aa                	mv	s1,a0
  iunlock(ip);
    8000430a:	00000097          	auipc	ra,0x0
    8000430e:	e54080e7          	jalr	-428(ra) # 8000415e <iunlock>
  iput(ip);
    80004312:	8526                	mv	a0,s1
    80004314:	00000097          	auipc	ra,0x0
    80004318:	f42080e7          	jalr	-190(ra) # 80004256 <iput>
}
    8000431c:	60e2                	ld	ra,24(sp)
    8000431e:	6442                	ld	s0,16(sp)
    80004320:	64a2                	ld	s1,8(sp)
    80004322:	6105                	addi	sp,sp,32
    80004324:	8082                	ret

0000000080004326 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004326:	1141                	addi	sp,sp,-16
    80004328:	e422                	sd	s0,8(sp)
    8000432a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000432c:	411c                	lw	a5,0(a0)
    8000432e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004330:	415c                	lw	a5,4(a0)
    80004332:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004334:	04451783          	lh	a5,68(a0)
    80004338:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000433c:	04a51783          	lh	a5,74(a0)
    80004340:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004344:	04c56783          	lwu	a5,76(a0)
    80004348:	e99c                	sd	a5,16(a1)
}
    8000434a:	6422                	ld	s0,8(sp)
    8000434c:	0141                	addi	sp,sp,16
    8000434e:	8082                	ret

0000000080004350 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004350:	457c                	lw	a5,76(a0)
    80004352:	0ed7e963          	bltu	a5,a3,80004444 <readi+0xf4>
{
    80004356:	7159                	addi	sp,sp,-112
    80004358:	f486                	sd	ra,104(sp)
    8000435a:	f0a2                	sd	s0,96(sp)
    8000435c:	eca6                	sd	s1,88(sp)
    8000435e:	e8ca                	sd	s2,80(sp)
    80004360:	e4ce                	sd	s3,72(sp)
    80004362:	e0d2                	sd	s4,64(sp)
    80004364:	fc56                	sd	s5,56(sp)
    80004366:	f85a                	sd	s6,48(sp)
    80004368:	f45e                	sd	s7,40(sp)
    8000436a:	f062                	sd	s8,32(sp)
    8000436c:	ec66                	sd	s9,24(sp)
    8000436e:	e86a                	sd	s10,16(sp)
    80004370:	e46e                	sd	s11,8(sp)
    80004372:	1880                	addi	s0,sp,112
    80004374:	8b2a                	mv	s6,a0
    80004376:	8bae                	mv	s7,a1
    80004378:	8a32                	mv	s4,a2
    8000437a:	84b6                	mv	s1,a3
    8000437c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000437e:	9f35                	addw	a4,a4,a3
    return 0;
    80004380:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004382:	0ad76063          	bltu	a4,a3,80004422 <readi+0xd2>
  if(off + n > ip->size)
    80004386:	00e7f463          	bgeu	a5,a4,8000438e <readi+0x3e>
    n = ip->size - off;
    8000438a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000438e:	0a0a8963          	beqz	s5,80004440 <readi+0xf0>
    80004392:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004394:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004398:	5c7d                	li	s8,-1
    8000439a:	a82d                	j	800043d4 <readi+0x84>
    8000439c:	020d1d93          	slli	s11,s10,0x20
    800043a0:	020ddd93          	srli	s11,s11,0x20
    800043a4:	05890613          	addi	a2,s2,88
    800043a8:	86ee                	mv	a3,s11
    800043aa:	963a                	add	a2,a2,a4
    800043ac:	85d2                	mv	a1,s4
    800043ae:	855e                	mv	a0,s7
    800043b0:	ffffe097          	auipc	ra,0xffffe
    800043b4:	5fc080e7          	jalr	1532(ra) # 800029ac <either_copyout>
    800043b8:	05850d63          	beq	a0,s8,80004412 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800043bc:	854a                	mv	a0,s2
    800043be:	fffff097          	auipc	ra,0xfffff
    800043c2:	5f6080e7          	jalr	1526(ra) # 800039b4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800043c6:	013d09bb          	addw	s3,s10,s3
    800043ca:	009d04bb          	addw	s1,s10,s1
    800043ce:	9a6e                	add	s4,s4,s11
    800043d0:	0559f763          	bgeu	s3,s5,8000441e <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800043d4:	00a4d59b          	srliw	a1,s1,0xa
    800043d8:	855a                	mv	a0,s6
    800043da:	00000097          	auipc	ra,0x0
    800043de:	89e080e7          	jalr	-1890(ra) # 80003c78 <bmap>
    800043e2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800043e6:	cd85                	beqz	a1,8000441e <readi+0xce>
    bp = bread(ip->dev, addr);
    800043e8:	000b2503          	lw	a0,0(s6)
    800043ec:	fffff097          	auipc	ra,0xfffff
    800043f0:	498080e7          	jalr	1176(ra) # 80003884 <bread>
    800043f4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043f6:	3ff4f713          	andi	a4,s1,1023
    800043fa:	40ec87bb          	subw	a5,s9,a4
    800043fe:	413a86bb          	subw	a3,s5,s3
    80004402:	8d3e                	mv	s10,a5
    80004404:	2781                	sext.w	a5,a5
    80004406:	0006861b          	sext.w	a2,a3
    8000440a:	f8f679e3          	bgeu	a2,a5,8000439c <readi+0x4c>
    8000440e:	8d36                	mv	s10,a3
    80004410:	b771                	j	8000439c <readi+0x4c>
      brelse(bp);
    80004412:	854a                	mv	a0,s2
    80004414:	fffff097          	auipc	ra,0xfffff
    80004418:	5a0080e7          	jalr	1440(ra) # 800039b4 <brelse>
      tot = -1;
    8000441c:	59fd                	li	s3,-1
  }
  return tot;
    8000441e:	0009851b          	sext.w	a0,s3
}
    80004422:	70a6                	ld	ra,104(sp)
    80004424:	7406                	ld	s0,96(sp)
    80004426:	64e6                	ld	s1,88(sp)
    80004428:	6946                	ld	s2,80(sp)
    8000442a:	69a6                	ld	s3,72(sp)
    8000442c:	6a06                	ld	s4,64(sp)
    8000442e:	7ae2                	ld	s5,56(sp)
    80004430:	7b42                	ld	s6,48(sp)
    80004432:	7ba2                	ld	s7,40(sp)
    80004434:	7c02                	ld	s8,32(sp)
    80004436:	6ce2                	ld	s9,24(sp)
    80004438:	6d42                	ld	s10,16(sp)
    8000443a:	6da2                	ld	s11,8(sp)
    8000443c:	6165                	addi	sp,sp,112
    8000443e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004440:	89d6                	mv	s3,s5
    80004442:	bff1                	j	8000441e <readi+0xce>
    return 0;
    80004444:	4501                	li	a0,0
}
    80004446:	8082                	ret

0000000080004448 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004448:	457c                	lw	a5,76(a0)
    8000444a:	10d7e863          	bltu	a5,a3,8000455a <writei+0x112>
{
    8000444e:	7159                	addi	sp,sp,-112
    80004450:	f486                	sd	ra,104(sp)
    80004452:	f0a2                	sd	s0,96(sp)
    80004454:	eca6                	sd	s1,88(sp)
    80004456:	e8ca                	sd	s2,80(sp)
    80004458:	e4ce                	sd	s3,72(sp)
    8000445a:	e0d2                	sd	s4,64(sp)
    8000445c:	fc56                	sd	s5,56(sp)
    8000445e:	f85a                	sd	s6,48(sp)
    80004460:	f45e                	sd	s7,40(sp)
    80004462:	f062                	sd	s8,32(sp)
    80004464:	ec66                	sd	s9,24(sp)
    80004466:	e86a                	sd	s10,16(sp)
    80004468:	e46e                	sd	s11,8(sp)
    8000446a:	1880                	addi	s0,sp,112
    8000446c:	8aaa                	mv	s5,a0
    8000446e:	8bae                	mv	s7,a1
    80004470:	8a32                	mv	s4,a2
    80004472:	8936                	mv	s2,a3
    80004474:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004476:	00e687bb          	addw	a5,a3,a4
    8000447a:	0ed7e263          	bltu	a5,a3,8000455e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000447e:	00043737          	lui	a4,0x43
    80004482:	0ef76063          	bltu	a4,a5,80004562 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004486:	0c0b0863          	beqz	s6,80004556 <writei+0x10e>
    8000448a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000448c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004490:	5c7d                	li	s8,-1
    80004492:	a091                	j	800044d6 <writei+0x8e>
    80004494:	020d1d93          	slli	s11,s10,0x20
    80004498:	020ddd93          	srli	s11,s11,0x20
    8000449c:	05848513          	addi	a0,s1,88
    800044a0:	86ee                	mv	a3,s11
    800044a2:	8652                	mv	a2,s4
    800044a4:	85de                	mv	a1,s7
    800044a6:	953a                	add	a0,a0,a4
    800044a8:	ffffe097          	auipc	ra,0xffffe
    800044ac:	55a080e7          	jalr	1370(ra) # 80002a02 <either_copyin>
    800044b0:	07850263          	beq	a0,s8,80004514 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800044b4:	8526                	mv	a0,s1
    800044b6:	00000097          	auipc	ra,0x0
    800044ba:	788080e7          	jalr	1928(ra) # 80004c3e <log_write>
    brelse(bp);
    800044be:	8526                	mv	a0,s1
    800044c0:	fffff097          	auipc	ra,0xfffff
    800044c4:	4f4080e7          	jalr	1268(ra) # 800039b4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800044c8:	013d09bb          	addw	s3,s10,s3
    800044cc:	012d093b          	addw	s2,s10,s2
    800044d0:	9a6e                	add	s4,s4,s11
    800044d2:	0569f663          	bgeu	s3,s6,8000451e <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800044d6:	00a9559b          	srliw	a1,s2,0xa
    800044da:	8556                	mv	a0,s5
    800044dc:	fffff097          	auipc	ra,0xfffff
    800044e0:	79c080e7          	jalr	1948(ra) # 80003c78 <bmap>
    800044e4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800044e8:	c99d                	beqz	a1,8000451e <writei+0xd6>
    bp = bread(ip->dev, addr);
    800044ea:	000aa503          	lw	a0,0(s5)
    800044ee:	fffff097          	auipc	ra,0xfffff
    800044f2:	396080e7          	jalr	918(ra) # 80003884 <bread>
    800044f6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800044f8:	3ff97713          	andi	a4,s2,1023
    800044fc:	40ec87bb          	subw	a5,s9,a4
    80004500:	413b06bb          	subw	a3,s6,s3
    80004504:	8d3e                	mv	s10,a5
    80004506:	2781                	sext.w	a5,a5
    80004508:	0006861b          	sext.w	a2,a3
    8000450c:	f8f674e3          	bgeu	a2,a5,80004494 <writei+0x4c>
    80004510:	8d36                	mv	s10,a3
    80004512:	b749                	j	80004494 <writei+0x4c>
      brelse(bp);
    80004514:	8526                	mv	a0,s1
    80004516:	fffff097          	auipc	ra,0xfffff
    8000451a:	49e080e7          	jalr	1182(ra) # 800039b4 <brelse>
  }

  if(off > ip->size)
    8000451e:	04caa783          	lw	a5,76(s5)
    80004522:	0127f463          	bgeu	a5,s2,8000452a <writei+0xe2>
    ip->size = off;
    80004526:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000452a:	8556                	mv	a0,s5
    8000452c:	00000097          	auipc	ra,0x0
    80004530:	aa4080e7          	jalr	-1372(ra) # 80003fd0 <iupdate>

  return tot;
    80004534:	0009851b          	sext.w	a0,s3
}
    80004538:	70a6                	ld	ra,104(sp)
    8000453a:	7406                	ld	s0,96(sp)
    8000453c:	64e6                	ld	s1,88(sp)
    8000453e:	6946                	ld	s2,80(sp)
    80004540:	69a6                	ld	s3,72(sp)
    80004542:	6a06                	ld	s4,64(sp)
    80004544:	7ae2                	ld	s5,56(sp)
    80004546:	7b42                	ld	s6,48(sp)
    80004548:	7ba2                	ld	s7,40(sp)
    8000454a:	7c02                	ld	s8,32(sp)
    8000454c:	6ce2                	ld	s9,24(sp)
    8000454e:	6d42                	ld	s10,16(sp)
    80004550:	6da2                	ld	s11,8(sp)
    80004552:	6165                	addi	sp,sp,112
    80004554:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004556:	89da                	mv	s3,s6
    80004558:	bfc9                	j	8000452a <writei+0xe2>
    return -1;
    8000455a:	557d                	li	a0,-1
}
    8000455c:	8082                	ret
    return -1;
    8000455e:	557d                	li	a0,-1
    80004560:	bfe1                	j	80004538 <writei+0xf0>
    return -1;
    80004562:	557d                	li	a0,-1
    80004564:	bfd1                	j	80004538 <writei+0xf0>

0000000080004566 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004566:	1141                	addi	sp,sp,-16
    80004568:	e406                	sd	ra,8(sp)
    8000456a:	e022                	sd	s0,0(sp)
    8000456c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000456e:	4639                	li	a2,14
    80004570:	ffffd097          	auipc	ra,0xffffd
    80004574:	972080e7          	jalr	-1678(ra) # 80000ee2 <strncmp>
}
    80004578:	60a2                	ld	ra,8(sp)
    8000457a:	6402                	ld	s0,0(sp)
    8000457c:	0141                	addi	sp,sp,16
    8000457e:	8082                	ret

0000000080004580 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004580:	7139                	addi	sp,sp,-64
    80004582:	fc06                	sd	ra,56(sp)
    80004584:	f822                	sd	s0,48(sp)
    80004586:	f426                	sd	s1,40(sp)
    80004588:	f04a                	sd	s2,32(sp)
    8000458a:	ec4e                	sd	s3,24(sp)
    8000458c:	e852                	sd	s4,16(sp)
    8000458e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004590:	04451703          	lh	a4,68(a0)
    80004594:	4785                	li	a5,1
    80004596:	00f71a63          	bne	a4,a5,800045aa <dirlookup+0x2a>
    8000459a:	892a                	mv	s2,a0
    8000459c:	89ae                	mv	s3,a1
    8000459e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800045a0:	457c                	lw	a5,76(a0)
    800045a2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800045a4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045a6:	e79d                	bnez	a5,800045d4 <dirlookup+0x54>
    800045a8:	a8a5                	j	80004620 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800045aa:	00004517          	auipc	a0,0x4
    800045ae:	32e50513          	addi	a0,a0,814 # 800088d8 <syscallnames+0x200>
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	f8e080e7          	jalr	-114(ra) # 80000540 <panic>
      panic("dirlookup read");
    800045ba:	00004517          	auipc	a0,0x4
    800045be:	33650513          	addi	a0,a0,822 # 800088f0 <syscallnames+0x218>
    800045c2:	ffffc097          	auipc	ra,0xffffc
    800045c6:	f7e080e7          	jalr	-130(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045ca:	24c1                	addiw	s1,s1,16
    800045cc:	04c92783          	lw	a5,76(s2)
    800045d0:	04f4f763          	bgeu	s1,a5,8000461e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045d4:	4741                	li	a4,16
    800045d6:	86a6                	mv	a3,s1
    800045d8:	fc040613          	addi	a2,s0,-64
    800045dc:	4581                	li	a1,0
    800045de:	854a                	mv	a0,s2
    800045e0:	00000097          	auipc	ra,0x0
    800045e4:	d70080e7          	jalr	-656(ra) # 80004350 <readi>
    800045e8:	47c1                	li	a5,16
    800045ea:	fcf518e3          	bne	a0,a5,800045ba <dirlookup+0x3a>
    if(de.inum == 0)
    800045ee:	fc045783          	lhu	a5,-64(s0)
    800045f2:	dfe1                	beqz	a5,800045ca <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800045f4:	fc240593          	addi	a1,s0,-62
    800045f8:	854e                	mv	a0,s3
    800045fa:	00000097          	auipc	ra,0x0
    800045fe:	f6c080e7          	jalr	-148(ra) # 80004566 <namecmp>
    80004602:	f561                	bnez	a0,800045ca <dirlookup+0x4a>
      if(poff)
    80004604:	000a0463          	beqz	s4,8000460c <dirlookup+0x8c>
        *poff = off;
    80004608:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000460c:	fc045583          	lhu	a1,-64(s0)
    80004610:	00092503          	lw	a0,0(s2)
    80004614:	fffff097          	auipc	ra,0xfffff
    80004618:	74e080e7          	jalr	1870(ra) # 80003d62 <iget>
    8000461c:	a011                	j	80004620 <dirlookup+0xa0>
  return 0;
    8000461e:	4501                	li	a0,0
}
    80004620:	70e2                	ld	ra,56(sp)
    80004622:	7442                	ld	s0,48(sp)
    80004624:	74a2                	ld	s1,40(sp)
    80004626:	7902                	ld	s2,32(sp)
    80004628:	69e2                	ld	s3,24(sp)
    8000462a:	6a42                	ld	s4,16(sp)
    8000462c:	6121                	addi	sp,sp,64
    8000462e:	8082                	ret

0000000080004630 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004630:	711d                	addi	sp,sp,-96
    80004632:	ec86                	sd	ra,88(sp)
    80004634:	e8a2                	sd	s0,80(sp)
    80004636:	e4a6                	sd	s1,72(sp)
    80004638:	e0ca                	sd	s2,64(sp)
    8000463a:	fc4e                	sd	s3,56(sp)
    8000463c:	f852                	sd	s4,48(sp)
    8000463e:	f456                	sd	s5,40(sp)
    80004640:	f05a                	sd	s6,32(sp)
    80004642:	ec5e                	sd	s7,24(sp)
    80004644:	e862                	sd	s8,16(sp)
    80004646:	e466                	sd	s9,8(sp)
    80004648:	e06a                	sd	s10,0(sp)
    8000464a:	1080                	addi	s0,sp,96
    8000464c:	84aa                	mv	s1,a0
    8000464e:	8b2e                	mv	s6,a1
    80004650:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004652:	00054703          	lbu	a4,0(a0)
    80004656:	02f00793          	li	a5,47
    8000465a:	02f70363          	beq	a4,a5,80004680 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000465e:	ffffd097          	auipc	ra,0xffffd
    80004662:	4d2080e7          	jalr	1234(ra) # 80001b30 <myproc>
    80004666:	15053503          	ld	a0,336(a0)
    8000466a:	00000097          	auipc	ra,0x0
    8000466e:	9f4080e7          	jalr	-1548(ra) # 8000405e <idup>
    80004672:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004674:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004678:	4cb5                	li	s9,13
  len = path - s;
    8000467a:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000467c:	4c05                	li	s8,1
    8000467e:	a87d                	j	8000473c <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004680:	4585                	li	a1,1
    80004682:	4505                	li	a0,1
    80004684:	fffff097          	auipc	ra,0xfffff
    80004688:	6de080e7          	jalr	1758(ra) # 80003d62 <iget>
    8000468c:	8a2a                	mv	s4,a0
    8000468e:	b7dd                	j	80004674 <namex+0x44>
      iunlockput(ip);
    80004690:	8552                	mv	a0,s4
    80004692:	00000097          	auipc	ra,0x0
    80004696:	c6c080e7          	jalr	-916(ra) # 800042fe <iunlockput>
      return 0;
    8000469a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000469c:	8552                	mv	a0,s4
    8000469e:	60e6                	ld	ra,88(sp)
    800046a0:	6446                	ld	s0,80(sp)
    800046a2:	64a6                	ld	s1,72(sp)
    800046a4:	6906                	ld	s2,64(sp)
    800046a6:	79e2                	ld	s3,56(sp)
    800046a8:	7a42                	ld	s4,48(sp)
    800046aa:	7aa2                	ld	s5,40(sp)
    800046ac:	7b02                	ld	s6,32(sp)
    800046ae:	6be2                	ld	s7,24(sp)
    800046b0:	6c42                	ld	s8,16(sp)
    800046b2:	6ca2                	ld	s9,8(sp)
    800046b4:	6d02                	ld	s10,0(sp)
    800046b6:	6125                	addi	sp,sp,96
    800046b8:	8082                	ret
      iunlock(ip);
    800046ba:	8552                	mv	a0,s4
    800046bc:	00000097          	auipc	ra,0x0
    800046c0:	aa2080e7          	jalr	-1374(ra) # 8000415e <iunlock>
      return ip;
    800046c4:	bfe1                	j	8000469c <namex+0x6c>
      iunlockput(ip);
    800046c6:	8552                	mv	a0,s4
    800046c8:	00000097          	auipc	ra,0x0
    800046cc:	c36080e7          	jalr	-970(ra) # 800042fe <iunlockput>
      return 0;
    800046d0:	8a4e                	mv	s4,s3
    800046d2:	b7e9                	j	8000469c <namex+0x6c>
  len = path - s;
    800046d4:	40998633          	sub	a2,s3,s1
    800046d8:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800046dc:	09acd863          	bge	s9,s10,8000476c <namex+0x13c>
    memmove(name, s, DIRSIZ);
    800046e0:	4639                	li	a2,14
    800046e2:	85a6                	mv	a1,s1
    800046e4:	8556                	mv	a0,s5
    800046e6:	ffffc097          	auipc	ra,0xffffc
    800046ea:	788080e7          	jalr	1928(ra) # 80000e6e <memmove>
    800046ee:	84ce                	mv	s1,s3
  while(*path == '/')
    800046f0:	0004c783          	lbu	a5,0(s1)
    800046f4:	01279763          	bne	a5,s2,80004702 <namex+0xd2>
    path++;
    800046f8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800046fa:	0004c783          	lbu	a5,0(s1)
    800046fe:	ff278de3          	beq	a5,s2,800046f8 <namex+0xc8>
    ilock(ip);
    80004702:	8552                	mv	a0,s4
    80004704:	00000097          	auipc	ra,0x0
    80004708:	998080e7          	jalr	-1640(ra) # 8000409c <ilock>
    if(ip->type != T_DIR){
    8000470c:	044a1783          	lh	a5,68(s4)
    80004710:	f98790e3          	bne	a5,s8,80004690 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004714:	000b0563          	beqz	s6,8000471e <namex+0xee>
    80004718:	0004c783          	lbu	a5,0(s1)
    8000471c:	dfd9                	beqz	a5,800046ba <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000471e:	865e                	mv	a2,s7
    80004720:	85d6                	mv	a1,s5
    80004722:	8552                	mv	a0,s4
    80004724:	00000097          	auipc	ra,0x0
    80004728:	e5c080e7          	jalr	-420(ra) # 80004580 <dirlookup>
    8000472c:	89aa                	mv	s3,a0
    8000472e:	dd41                	beqz	a0,800046c6 <namex+0x96>
    iunlockput(ip);
    80004730:	8552                	mv	a0,s4
    80004732:	00000097          	auipc	ra,0x0
    80004736:	bcc080e7          	jalr	-1076(ra) # 800042fe <iunlockput>
    ip = next;
    8000473a:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000473c:	0004c783          	lbu	a5,0(s1)
    80004740:	01279763          	bne	a5,s2,8000474e <namex+0x11e>
    path++;
    80004744:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004746:	0004c783          	lbu	a5,0(s1)
    8000474a:	ff278de3          	beq	a5,s2,80004744 <namex+0x114>
  if(*path == 0)
    8000474e:	cb9d                	beqz	a5,80004784 <namex+0x154>
  while(*path != '/' && *path != 0)
    80004750:	0004c783          	lbu	a5,0(s1)
    80004754:	89a6                	mv	s3,s1
  len = path - s;
    80004756:	8d5e                	mv	s10,s7
    80004758:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000475a:	01278963          	beq	a5,s2,8000476c <namex+0x13c>
    8000475e:	dbbd                	beqz	a5,800046d4 <namex+0xa4>
    path++;
    80004760:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004762:	0009c783          	lbu	a5,0(s3)
    80004766:	ff279ce3          	bne	a5,s2,8000475e <namex+0x12e>
    8000476a:	b7ad                	j	800046d4 <namex+0xa4>
    memmove(name, s, len);
    8000476c:	2601                	sext.w	a2,a2
    8000476e:	85a6                	mv	a1,s1
    80004770:	8556                	mv	a0,s5
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	6fc080e7          	jalr	1788(ra) # 80000e6e <memmove>
    name[len] = 0;
    8000477a:	9d56                	add	s10,s10,s5
    8000477c:	000d0023          	sb	zero,0(s10)
    80004780:	84ce                	mv	s1,s3
    80004782:	b7bd                	j	800046f0 <namex+0xc0>
  if(nameiparent){
    80004784:	f00b0ce3          	beqz	s6,8000469c <namex+0x6c>
    iput(ip);
    80004788:	8552                	mv	a0,s4
    8000478a:	00000097          	auipc	ra,0x0
    8000478e:	acc080e7          	jalr	-1332(ra) # 80004256 <iput>
    return 0;
    80004792:	4a01                	li	s4,0
    80004794:	b721                	j	8000469c <namex+0x6c>

0000000080004796 <dirlink>:
{
    80004796:	7139                	addi	sp,sp,-64
    80004798:	fc06                	sd	ra,56(sp)
    8000479a:	f822                	sd	s0,48(sp)
    8000479c:	f426                	sd	s1,40(sp)
    8000479e:	f04a                	sd	s2,32(sp)
    800047a0:	ec4e                	sd	s3,24(sp)
    800047a2:	e852                	sd	s4,16(sp)
    800047a4:	0080                	addi	s0,sp,64
    800047a6:	892a                	mv	s2,a0
    800047a8:	8a2e                	mv	s4,a1
    800047aa:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800047ac:	4601                	li	a2,0
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	dd2080e7          	jalr	-558(ra) # 80004580 <dirlookup>
    800047b6:	e93d                	bnez	a0,8000482c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800047b8:	04c92483          	lw	s1,76(s2)
    800047bc:	c49d                	beqz	s1,800047ea <dirlink+0x54>
    800047be:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800047c0:	4741                	li	a4,16
    800047c2:	86a6                	mv	a3,s1
    800047c4:	fc040613          	addi	a2,s0,-64
    800047c8:	4581                	li	a1,0
    800047ca:	854a                	mv	a0,s2
    800047cc:	00000097          	auipc	ra,0x0
    800047d0:	b84080e7          	jalr	-1148(ra) # 80004350 <readi>
    800047d4:	47c1                	li	a5,16
    800047d6:	06f51163          	bne	a0,a5,80004838 <dirlink+0xa2>
    if(de.inum == 0)
    800047da:	fc045783          	lhu	a5,-64(s0)
    800047de:	c791                	beqz	a5,800047ea <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800047e0:	24c1                	addiw	s1,s1,16
    800047e2:	04c92783          	lw	a5,76(s2)
    800047e6:	fcf4ede3          	bltu	s1,a5,800047c0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800047ea:	4639                	li	a2,14
    800047ec:	85d2                	mv	a1,s4
    800047ee:	fc240513          	addi	a0,s0,-62
    800047f2:	ffffc097          	auipc	ra,0xffffc
    800047f6:	72c080e7          	jalr	1836(ra) # 80000f1e <strncpy>
  de.inum = inum;
    800047fa:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800047fe:	4741                	li	a4,16
    80004800:	86a6                	mv	a3,s1
    80004802:	fc040613          	addi	a2,s0,-64
    80004806:	4581                	li	a1,0
    80004808:	854a                	mv	a0,s2
    8000480a:	00000097          	auipc	ra,0x0
    8000480e:	c3e080e7          	jalr	-962(ra) # 80004448 <writei>
    80004812:	1541                	addi	a0,a0,-16
    80004814:	00a03533          	snez	a0,a0
    80004818:	40a00533          	neg	a0,a0
}
    8000481c:	70e2                	ld	ra,56(sp)
    8000481e:	7442                	ld	s0,48(sp)
    80004820:	74a2                	ld	s1,40(sp)
    80004822:	7902                	ld	s2,32(sp)
    80004824:	69e2                	ld	s3,24(sp)
    80004826:	6a42                	ld	s4,16(sp)
    80004828:	6121                	addi	sp,sp,64
    8000482a:	8082                	ret
    iput(ip);
    8000482c:	00000097          	auipc	ra,0x0
    80004830:	a2a080e7          	jalr	-1494(ra) # 80004256 <iput>
    return -1;
    80004834:	557d                	li	a0,-1
    80004836:	b7dd                	j	8000481c <dirlink+0x86>
      panic("dirlink read");
    80004838:	00004517          	auipc	a0,0x4
    8000483c:	0c850513          	addi	a0,a0,200 # 80008900 <syscallnames+0x228>
    80004840:	ffffc097          	auipc	ra,0xffffc
    80004844:	d00080e7          	jalr	-768(ra) # 80000540 <panic>

0000000080004848 <namei>:

struct inode*
namei(char *path)
{
    80004848:	1101                	addi	sp,sp,-32
    8000484a:	ec06                	sd	ra,24(sp)
    8000484c:	e822                	sd	s0,16(sp)
    8000484e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004850:	fe040613          	addi	a2,s0,-32
    80004854:	4581                	li	a1,0
    80004856:	00000097          	auipc	ra,0x0
    8000485a:	dda080e7          	jalr	-550(ra) # 80004630 <namex>
}
    8000485e:	60e2                	ld	ra,24(sp)
    80004860:	6442                	ld	s0,16(sp)
    80004862:	6105                	addi	sp,sp,32
    80004864:	8082                	ret

0000000080004866 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004866:	1141                	addi	sp,sp,-16
    80004868:	e406                	sd	ra,8(sp)
    8000486a:	e022                	sd	s0,0(sp)
    8000486c:	0800                	addi	s0,sp,16
    8000486e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004870:	4585                	li	a1,1
    80004872:	00000097          	auipc	ra,0x0
    80004876:	dbe080e7          	jalr	-578(ra) # 80004630 <namex>
}
    8000487a:	60a2                	ld	ra,8(sp)
    8000487c:	6402                	ld	s0,0(sp)
    8000487e:	0141                	addi	sp,sp,16
    80004880:	8082                	ret

0000000080004882 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004882:	1101                	addi	sp,sp,-32
    80004884:	ec06                	sd	ra,24(sp)
    80004886:	e822                	sd	s0,16(sp)
    80004888:	e426                	sd	s1,8(sp)
    8000488a:	e04a                	sd	s2,0(sp)
    8000488c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000488e:	0023f917          	auipc	s2,0x23f
    80004892:	83290913          	addi	s2,s2,-1998 # 802430c0 <log>
    80004896:	01892583          	lw	a1,24(s2)
    8000489a:	02892503          	lw	a0,40(s2)
    8000489e:	fffff097          	auipc	ra,0xfffff
    800048a2:	fe6080e7          	jalr	-26(ra) # 80003884 <bread>
    800048a6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800048a8:	02c92683          	lw	a3,44(s2)
    800048ac:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800048ae:	02d05863          	blez	a3,800048de <write_head+0x5c>
    800048b2:	0023f797          	auipc	a5,0x23f
    800048b6:	83e78793          	addi	a5,a5,-1986 # 802430f0 <log+0x30>
    800048ba:	05c50713          	addi	a4,a0,92
    800048be:	36fd                	addiw	a3,a3,-1
    800048c0:	02069613          	slli	a2,a3,0x20
    800048c4:	01e65693          	srli	a3,a2,0x1e
    800048c8:	0023f617          	auipc	a2,0x23f
    800048cc:	82c60613          	addi	a2,a2,-2004 # 802430f4 <log+0x34>
    800048d0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800048d2:	4390                	lw	a2,0(a5)
    800048d4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800048d6:	0791                	addi	a5,a5,4
    800048d8:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800048da:	fed79ce3          	bne	a5,a3,800048d2 <write_head+0x50>
  }
  bwrite(buf);
    800048de:	8526                	mv	a0,s1
    800048e0:	fffff097          	auipc	ra,0xfffff
    800048e4:	096080e7          	jalr	150(ra) # 80003976 <bwrite>
  brelse(buf);
    800048e8:	8526                	mv	a0,s1
    800048ea:	fffff097          	auipc	ra,0xfffff
    800048ee:	0ca080e7          	jalr	202(ra) # 800039b4 <brelse>
}
    800048f2:	60e2                	ld	ra,24(sp)
    800048f4:	6442                	ld	s0,16(sp)
    800048f6:	64a2                	ld	s1,8(sp)
    800048f8:	6902                	ld	s2,0(sp)
    800048fa:	6105                	addi	sp,sp,32
    800048fc:	8082                	ret

00000000800048fe <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800048fe:	0023e797          	auipc	a5,0x23e
    80004902:	7ee7a783          	lw	a5,2030(a5) # 802430ec <log+0x2c>
    80004906:	0af05d63          	blez	a5,800049c0 <install_trans+0xc2>
{
    8000490a:	7139                	addi	sp,sp,-64
    8000490c:	fc06                	sd	ra,56(sp)
    8000490e:	f822                	sd	s0,48(sp)
    80004910:	f426                	sd	s1,40(sp)
    80004912:	f04a                	sd	s2,32(sp)
    80004914:	ec4e                	sd	s3,24(sp)
    80004916:	e852                	sd	s4,16(sp)
    80004918:	e456                	sd	s5,8(sp)
    8000491a:	e05a                	sd	s6,0(sp)
    8000491c:	0080                	addi	s0,sp,64
    8000491e:	8b2a                	mv	s6,a0
    80004920:	0023ea97          	auipc	s5,0x23e
    80004924:	7d0a8a93          	addi	s5,s5,2000 # 802430f0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004928:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000492a:	0023e997          	auipc	s3,0x23e
    8000492e:	79698993          	addi	s3,s3,1942 # 802430c0 <log>
    80004932:	a00d                	j	80004954 <install_trans+0x56>
    brelse(lbuf);
    80004934:	854a                	mv	a0,s2
    80004936:	fffff097          	auipc	ra,0xfffff
    8000493a:	07e080e7          	jalr	126(ra) # 800039b4 <brelse>
    brelse(dbuf);
    8000493e:	8526                	mv	a0,s1
    80004940:	fffff097          	auipc	ra,0xfffff
    80004944:	074080e7          	jalr	116(ra) # 800039b4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004948:	2a05                	addiw	s4,s4,1
    8000494a:	0a91                	addi	s5,s5,4
    8000494c:	02c9a783          	lw	a5,44(s3)
    80004950:	04fa5e63          	bge	s4,a5,800049ac <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004954:	0189a583          	lw	a1,24(s3)
    80004958:	014585bb          	addw	a1,a1,s4
    8000495c:	2585                	addiw	a1,a1,1
    8000495e:	0289a503          	lw	a0,40(s3)
    80004962:	fffff097          	auipc	ra,0xfffff
    80004966:	f22080e7          	jalr	-222(ra) # 80003884 <bread>
    8000496a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000496c:	000aa583          	lw	a1,0(s5)
    80004970:	0289a503          	lw	a0,40(s3)
    80004974:	fffff097          	auipc	ra,0xfffff
    80004978:	f10080e7          	jalr	-240(ra) # 80003884 <bread>
    8000497c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000497e:	40000613          	li	a2,1024
    80004982:	05890593          	addi	a1,s2,88
    80004986:	05850513          	addi	a0,a0,88
    8000498a:	ffffc097          	auipc	ra,0xffffc
    8000498e:	4e4080e7          	jalr	1252(ra) # 80000e6e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004992:	8526                	mv	a0,s1
    80004994:	fffff097          	auipc	ra,0xfffff
    80004998:	fe2080e7          	jalr	-30(ra) # 80003976 <bwrite>
    if(recovering == 0)
    8000499c:	f80b1ce3          	bnez	s6,80004934 <install_trans+0x36>
      bunpin(dbuf);
    800049a0:	8526                	mv	a0,s1
    800049a2:	fffff097          	auipc	ra,0xfffff
    800049a6:	0ec080e7          	jalr	236(ra) # 80003a8e <bunpin>
    800049aa:	b769                	j	80004934 <install_trans+0x36>
}
    800049ac:	70e2                	ld	ra,56(sp)
    800049ae:	7442                	ld	s0,48(sp)
    800049b0:	74a2                	ld	s1,40(sp)
    800049b2:	7902                	ld	s2,32(sp)
    800049b4:	69e2                	ld	s3,24(sp)
    800049b6:	6a42                	ld	s4,16(sp)
    800049b8:	6aa2                	ld	s5,8(sp)
    800049ba:	6b02                	ld	s6,0(sp)
    800049bc:	6121                	addi	sp,sp,64
    800049be:	8082                	ret
    800049c0:	8082                	ret

00000000800049c2 <initlog>:
{
    800049c2:	7179                	addi	sp,sp,-48
    800049c4:	f406                	sd	ra,40(sp)
    800049c6:	f022                	sd	s0,32(sp)
    800049c8:	ec26                	sd	s1,24(sp)
    800049ca:	e84a                	sd	s2,16(sp)
    800049cc:	e44e                	sd	s3,8(sp)
    800049ce:	1800                	addi	s0,sp,48
    800049d0:	892a                	mv	s2,a0
    800049d2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800049d4:	0023e497          	auipc	s1,0x23e
    800049d8:	6ec48493          	addi	s1,s1,1772 # 802430c0 <log>
    800049dc:	00004597          	auipc	a1,0x4
    800049e0:	f3458593          	addi	a1,a1,-204 # 80008910 <syscallnames+0x238>
    800049e4:	8526                	mv	a0,s1
    800049e6:	ffffc097          	auipc	ra,0xffffc
    800049ea:	2a0080e7          	jalr	672(ra) # 80000c86 <initlock>
  log.start = sb->logstart;
    800049ee:	0149a583          	lw	a1,20(s3)
    800049f2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800049f4:	0109a783          	lw	a5,16(s3)
    800049f8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800049fa:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800049fe:	854a                	mv	a0,s2
    80004a00:	fffff097          	auipc	ra,0xfffff
    80004a04:	e84080e7          	jalr	-380(ra) # 80003884 <bread>
  log.lh.n = lh->n;
    80004a08:	4d34                	lw	a3,88(a0)
    80004a0a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004a0c:	02d05663          	blez	a3,80004a38 <initlog+0x76>
    80004a10:	05c50793          	addi	a5,a0,92
    80004a14:	0023e717          	auipc	a4,0x23e
    80004a18:	6dc70713          	addi	a4,a4,1756 # 802430f0 <log+0x30>
    80004a1c:	36fd                	addiw	a3,a3,-1
    80004a1e:	02069613          	slli	a2,a3,0x20
    80004a22:	01e65693          	srli	a3,a2,0x1e
    80004a26:	06050613          	addi	a2,a0,96
    80004a2a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004a2c:	4390                	lw	a2,0(a5)
    80004a2e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004a30:	0791                	addi	a5,a5,4
    80004a32:	0711                	addi	a4,a4,4
    80004a34:	fed79ce3          	bne	a5,a3,80004a2c <initlog+0x6a>
  brelse(buf);
    80004a38:	fffff097          	auipc	ra,0xfffff
    80004a3c:	f7c080e7          	jalr	-132(ra) # 800039b4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004a40:	4505                	li	a0,1
    80004a42:	00000097          	auipc	ra,0x0
    80004a46:	ebc080e7          	jalr	-324(ra) # 800048fe <install_trans>
  log.lh.n = 0;
    80004a4a:	0023e797          	auipc	a5,0x23e
    80004a4e:	6a07a123          	sw	zero,1698(a5) # 802430ec <log+0x2c>
  write_head(); // clear the log
    80004a52:	00000097          	auipc	ra,0x0
    80004a56:	e30080e7          	jalr	-464(ra) # 80004882 <write_head>
}
    80004a5a:	70a2                	ld	ra,40(sp)
    80004a5c:	7402                	ld	s0,32(sp)
    80004a5e:	64e2                	ld	s1,24(sp)
    80004a60:	6942                	ld	s2,16(sp)
    80004a62:	69a2                	ld	s3,8(sp)
    80004a64:	6145                	addi	sp,sp,48
    80004a66:	8082                	ret

0000000080004a68 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004a68:	1101                	addi	sp,sp,-32
    80004a6a:	ec06                	sd	ra,24(sp)
    80004a6c:	e822                	sd	s0,16(sp)
    80004a6e:	e426                	sd	s1,8(sp)
    80004a70:	e04a                	sd	s2,0(sp)
    80004a72:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004a74:	0023e517          	auipc	a0,0x23e
    80004a78:	64c50513          	addi	a0,a0,1612 # 802430c0 <log>
    80004a7c:	ffffc097          	auipc	ra,0xffffc
    80004a80:	29a080e7          	jalr	666(ra) # 80000d16 <acquire>
  while(1){
    if(log.committing){
    80004a84:	0023e497          	auipc	s1,0x23e
    80004a88:	63c48493          	addi	s1,s1,1596 # 802430c0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004a8c:	4979                	li	s2,30
    80004a8e:	a039                	j	80004a9c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004a90:	85a6                	mv	a1,s1
    80004a92:	8526                	mv	a0,s1
    80004a94:	ffffe097          	auipc	ra,0xffffe
    80004a98:	92c080e7          	jalr	-1748(ra) # 800023c0 <sleep>
    if(log.committing){
    80004a9c:	50dc                	lw	a5,36(s1)
    80004a9e:	fbed                	bnez	a5,80004a90 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004aa0:	5098                	lw	a4,32(s1)
    80004aa2:	2705                	addiw	a4,a4,1
    80004aa4:	0007069b          	sext.w	a3,a4
    80004aa8:	0027179b          	slliw	a5,a4,0x2
    80004aac:	9fb9                	addw	a5,a5,a4
    80004aae:	0017979b          	slliw	a5,a5,0x1
    80004ab2:	54d8                	lw	a4,44(s1)
    80004ab4:	9fb9                	addw	a5,a5,a4
    80004ab6:	00f95963          	bge	s2,a5,80004ac8 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004aba:	85a6                	mv	a1,s1
    80004abc:	8526                	mv	a0,s1
    80004abe:	ffffe097          	auipc	ra,0xffffe
    80004ac2:	902080e7          	jalr	-1790(ra) # 800023c0 <sleep>
    80004ac6:	bfd9                	j	80004a9c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004ac8:	0023e517          	auipc	a0,0x23e
    80004acc:	5f850513          	addi	a0,a0,1528 # 802430c0 <log>
    80004ad0:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004ad2:	ffffc097          	auipc	ra,0xffffc
    80004ad6:	2f8080e7          	jalr	760(ra) # 80000dca <release>
      break;
    }
  }
}
    80004ada:	60e2                	ld	ra,24(sp)
    80004adc:	6442                	ld	s0,16(sp)
    80004ade:	64a2                	ld	s1,8(sp)
    80004ae0:	6902                	ld	s2,0(sp)
    80004ae2:	6105                	addi	sp,sp,32
    80004ae4:	8082                	ret

0000000080004ae6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004ae6:	7139                	addi	sp,sp,-64
    80004ae8:	fc06                	sd	ra,56(sp)
    80004aea:	f822                	sd	s0,48(sp)
    80004aec:	f426                	sd	s1,40(sp)
    80004aee:	f04a                	sd	s2,32(sp)
    80004af0:	ec4e                	sd	s3,24(sp)
    80004af2:	e852                	sd	s4,16(sp)
    80004af4:	e456                	sd	s5,8(sp)
    80004af6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004af8:	0023e497          	auipc	s1,0x23e
    80004afc:	5c848493          	addi	s1,s1,1480 # 802430c0 <log>
    80004b00:	8526                	mv	a0,s1
    80004b02:	ffffc097          	auipc	ra,0xffffc
    80004b06:	214080e7          	jalr	532(ra) # 80000d16 <acquire>
  log.outstanding -= 1;
    80004b0a:	509c                	lw	a5,32(s1)
    80004b0c:	37fd                	addiw	a5,a5,-1
    80004b0e:	0007891b          	sext.w	s2,a5
    80004b12:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004b14:	50dc                	lw	a5,36(s1)
    80004b16:	e7b9                	bnez	a5,80004b64 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004b18:	04091e63          	bnez	s2,80004b74 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004b1c:	0023e497          	auipc	s1,0x23e
    80004b20:	5a448493          	addi	s1,s1,1444 # 802430c0 <log>
    80004b24:	4785                	li	a5,1
    80004b26:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004b28:	8526                	mv	a0,s1
    80004b2a:	ffffc097          	auipc	ra,0xffffc
    80004b2e:	2a0080e7          	jalr	672(ra) # 80000dca <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004b32:	54dc                	lw	a5,44(s1)
    80004b34:	06f04763          	bgtz	a5,80004ba2 <end_op+0xbc>
    acquire(&log.lock);
    80004b38:	0023e497          	auipc	s1,0x23e
    80004b3c:	58848493          	addi	s1,s1,1416 # 802430c0 <log>
    80004b40:	8526                	mv	a0,s1
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	1d4080e7          	jalr	468(ra) # 80000d16 <acquire>
    log.committing = 0;
    80004b4a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004b4e:	8526                	mv	a0,s1
    80004b50:	ffffe097          	auipc	ra,0xffffe
    80004b54:	a24080e7          	jalr	-1500(ra) # 80002574 <wakeup>
    release(&log.lock);
    80004b58:	8526                	mv	a0,s1
    80004b5a:	ffffc097          	auipc	ra,0xffffc
    80004b5e:	270080e7          	jalr	624(ra) # 80000dca <release>
}
    80004b62:	a03d                	j	80004b90 <end_op+0xaa>
    panic("log.committing");
    80004b64:	00004517          	auipc	a0,0x4
    80004b68:	db450513          	addi	a0,a0,-588 # 80008918 <syscallnames+0x240>
    80004b6c:	ffffc097          	auipc	ra,0xffffc
    80004b70:	9d4080e7          	jalr	-1580(ra) # 80000540 <panic>
    wakeup(&log);
    80004b74:	0023e497          	auipc	s1,0x23e
    80004b78:	54c48493          	addi	s1,s1,1356 # 802430c0 <log>
    80004b7c:	8526                	mv	a0,s1
    80004b7e:	ffffe097          	auipc	ra,0xffffe
    80004b82:	9f6080e7          	jalr	-1546(ra) # 80002574 <wakeup>
  release(&log.lock);
    80004b86:	8526                	mv	a0,s1
    80004b88:	ffffc097          	auipc	ra,0xffffc
    80004b8c:	242080e7          	jalr	578(ra) # 80000dca <release>
}
    80004b90:	70e2                	ld	ra,56(sp)
    80004b92:	7442                	ld	s0,48(sp)
    80004b94:	74a2                	ld	s1,40(sp)
    80004b96:	7902                	ld	s2,32(sp)
    80004b98:	69e2                	ld	s3,24(sp)
    80004b9a:	6a42                	ld	s4,16(sp)
    80004b9c:	6aa2                	ld	s5,8(sp)
    80004b9e:	6121                	addi	sp,sp,64
    80004ba0:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ba2:	0023ea97          	auipc	s5,0x23e
    80004ba6:	54ea8a93          	addi	s5,s5,1358 # 802430f0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004baa:	0023ea17          	auipc	s4,0x23e
    80004bae:	516a0a13          	addi	s4,s4,1302 # 802430c0 <log>
    80004bb2:	018a2583          	lw	a1,24(s4)
    80004bb6:	012585bb          	addw	a1,a1,s2
    80004bba:	2585                	addiw	a1,a1,1
    80004bbc:	028a2503          	lw	a0,40(s4)
    80004bc0:	fffff097          	auipc	ra,0xfffff
    80004bc4:	cc4080e7          	jalr	-828(ra) # 80003884 <bread>
    80004bc8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004bca:	000aa583          	lw	a1,0(s5)
    80004bce:	028a2503          	lw	a0,40(s4)
    80004bd2:	fffff097          	auipc	ra,0xfffff
    80004bd6:	cb2080e7          	jalr	-846(ra) # 80003884 <bread>
    80004bda:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004bdc:	40000613          	li	a2,1024
    80004be0:	05850593          	addi	a1,a0,88
    80004be4:	05848513          	addi	a0,s1,88
    80004be8:	ffffc097          	auipc	ra,0xffffc
    80004bec:	286080e7          	jalr	646(ra) # 80000e6e <memmove>
    bwrite(to);  // write the log
    80004bf0:	8526                	mv	a0,s1
    80004bf2:	fffff097          	auipc	ra,0xfffff
    80004bf6:	d84080e7          	jalr	-636(ra) # 80003976 <bwrite>
    brelse(from);
    80004bfa:	854e                	mv	a0,s3
    80004bfc:	fffff097          	auipc	ra,0xfffff
    80004c00:	db8080e7          	jalr	-584(ra) # 800039b4 <brelse>
    brelse(to);
    80004c04:	8526                	mv	a0,s1
    80004c06:	fffff097          	auipc	ra,0xfffff
    80004c0a:	dae080e7          	jalr	-594(ra) # 800039b4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c0e:	2905                	addiw	s2,s2,1
    80004c10:	0a91                	addi	s5,s5,4
    80004c12:	02ca2783          	lw	a5,44(s4)
    80004c16:	f8f94ee3          	blt	s2,a5,80004bb2 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004c1a:	00000097          	auipc	ra,0x0
    80004c1e:	c68080e7          	jalr	-920(ra) # 80004882 <write_head>
    install_trans(0); // Now install writes to home locations
    80004c22:	4501                	li	a0,0
    80004c24:	00000097          	auipc	ra,0x0
    80004c28:	cda080e7          	jalr	-806(ra) # 800048fe <install_trans>
    log.lh.n = 0;
    80004c2c:	0023e797          	auipc	a5,0x23e
    80004c30:	4c07a023          	sw	zero,1216(a5) # 802430ec <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004c34:	00000097          	auipc	ra,0x0
    80004c38:	c4e080e7          	jalr	-946(ra) # 80004882 <write_head>
    80004c3c:	bdf5                	j	80004b38 <end_op+0x52>

0000000080004c3e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004c3e:	1101                	addi	sp,sp,-32
    80004c40:	ec06                	sd	ra,24(sp)
    80004c42:	e822                	sd	s0,16(sp)
    80004c44:	e426                	sd	s1,8(sp)
    80004c46:	e04a                	sd	s2,0(sp)
    80004c48:	1000                	addi	s0,sp,32
    80004c4a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004c4c:	0023e917          	auipc	s2,0x23e
    80004c50:	47490913          	addi	s2,s2,1140 # 802430c0 <log>
    80004c54:	854a                	mv	a0,s2
    80004c56:	ffffc097          	auipc	ra,0xffffc
    80004c5a:	0c0080e7          	jalr	192(ra) # 80000d16 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004c5e:	02c92603          	lw	a2,44(s2)
    80004c62:	47f5                	li	a5,29
    80004c64:	06c7c563          	blt	a5,a2,80004cce <log_write+0x90>
    80004c68:	0023e797          	auipc	a5,0x23e
    80004c6c:	4747a783          	lw	a5,1140(a5) # 802430dc <log+0x1c>
    80004c70:	37fd                	addiw	a5,a5,-1
    80004c72:	04f65e63          	bge	a2,a5,80004cce <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004c76:	0023e797          	auipc	a5,0x23e
    80004c7a:	46a7a783          	lw	a5,1130(a5) # 802430e0 <log+0x20>
    80004c7e:	06f05063          	blez	a5,80004cde <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004c82:	4781                	li	a5,0
    80004c84:	06c05563          	blez	a2,80004cee <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004c88:	44cc                	lw	a1,12(s1)
    80004c8a:	0023e717          	auipc	a4,0x23e
    80004c8e:	46670713          	addi	a4,a4,1126 # 802430f0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004c92:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004c94:	4314                	lw	a3,0(a4)
    80004c96:	04b68c63          	beq	a3,a1,80004cee <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004c9a:	2785                	addiw	a5,a5,1
    80004c9c:	0711                	addi	a4,a4,4
    80004c9e:	fef61be3          	bne	a2,a5,80004c94 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004ca2:	0621                	addi	a2,a2,8
    80004ca4:	060a                	slli	a2,a2,0x2
    80004ca6:	0023e797          	auipc	a5,0x23e
    80004caa:	41a78793          	addi	a5,a5,1050 # 802430c0 <log>
    80004cae:	97b2                	add	a5,a5,a2
    80004cb0:	44d8                	lw	a4,12(s1)
    80004cb2:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004cb4:	8526                	mv	a0,s1
    80004cb6:	fffff097          	auipc	ra,0xfffff
    80004cba:	d9c080e7          	jalr	-612(ra) # 80003a52 <bpin>
    log.lh.n++;
    80004cbe:	0023e717          	auipc	a4,0x23e
    80004cc2:	40270713          	addi	a4,a4,1026 # 802430c0 <log>
    80004cc6:	575c                	lw	a5,44(a4)
    80004cc8:	2785                	addiw	a5,a5,1
    80004cca:	d75c                	sw	a5,44(a4)
    80004ccc:	a82d                	j	80004d06 <log_write+0xc8>
    panic("too big a transaction");
    80004cce:	00004517          	auipc	a0,0x4
    80004cd2:	c5a50513          	addi	a0,a0,-934 # 80008928 <syscallnames+0x250>
    80004cd6:	ffffc097          	auipc	ra,0xffffc
    80004cda:	86a080e7          	jalr	-1942(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004cde:	00004517          	auipc	a0,0x4
    80004ce2:	c6250513          	addi	a0,a0,-926 # 80008940 <syscallnames+0x268>
    80004ce6:	ffffc097          	auipc	ra,0xffffc
    80004cea:	85a080e7          	jalr	-1958(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004cee:	00878693          	addi	a3,a5,8
    80004cf2:	068a                	slli	a3,a3,0x2
    80004cf4:	0023e717          	auipc	a4,0x23e
    80004cf8:	3cc70713          	addi	a4,a4,972 # 802430c0 <log>
    80004cfc:	9736                	add	a4,a4,a3
    80004cfe:	44d4                	lw	a3,12(s1)
    80004d00:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004d02:	faf609e3          	beq	a2,a5,80004cb4 <log_write+0x76>
  }
  release(&log.lock);
    80004d06:	0023e517          	auipc	a0,0x23e
    80004d0a:	3ba50513          	addi	a0,a0,954 # 802430c0 <log>
    80004d0e:	ffffc097          	auipc	ra,0xffffc
    80004d12:	0bc080e7          	jalr	188(ra) # 80000dca <release>
}
    80004d16:	60e2                	ld	ra,24(sp)
    80004d18:	6442                	ld	s0,16(sp)
    80004d1a:	64a2                	ld	s1,8(sp)
    80004d1c:	6902                	ld	s2,0(sp)
    80004d1e:	6105                	addi	sp,sp,32
    80004d20:	8082                	ret

0000000080004d22 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004d22:	1101                	addi	sp,sp,-32
    80004d24:	ec06                	sd	ra,24(sp)
    80004d26:	e822                	sd	s0,16(sp)
    80004d28:	e426                	sd	s1,8(sp)
    80004d2a:	e04a                	sd	s2,0(sp)
    80004d2c:	1000                	addi	s0,sp,32
    80004d2e:	84aa                	mv	s1,a0
    80004d30:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004d32:	00004597          	auipc	a1,0x4
    80004d36:	c2e58593          	addi	a1,a1,-978 # 80008960 <syscallnames+0x288>
    80004d3a:	0521                	addi	a0,a0,8
    80004d3c:	ffffc097          	auipc	ra,0xffffc
    80004d40:	f4a080e7          	jalr	-182(ra) # 80000c86 <initlock>
  lk->name = name;
    80004d44:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004d48:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004d4c:	0204a423          	sw	zero,40(s1)
}
    80004d50:	60e2                	ld	ra,24(sp)
    80004d52:	6442                	ld	s0,16(sp)
    80004d54:	64a2                	ld	s1,8(sp)
    80004d56:	6902                	ld	s2,0(sp)
    80004d58:	6105                	addi	sp,sp,32
    80004d5a:	8082                	ret

0000000080004d5c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004d5c:	1101                	addi	sp,sp,-32
    80004d5e:	ec06                	sd	ra,24(sp)
    80004d60:	e822                	sd	s0,16(sp)
    80004d62:	e426                	sd	s1,8(sp)
    80004d64:	e04a                	sd	s2,0(sp)
    80004d66:	1000                	addi	s0,sp,32
    80004d68:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004d6a:	00850913          	addi	s2,a0,8
    80004d6e:	854a                	mv	a0,s2
    80004d70:	ffffc097          	auipc	ra,0xffffc
    80004d74:	fa6080e7          	jalr	-90(ra) # 80000d16 <acquire>
  while (lk->locked) {
    80004d78:	409c                	lw	a5,0(s1)
    80004d7a:	cb89                	beqz	a5,80004d8c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004d7c:	85ca                	mv	a1,s2
    80004d7e:	8526                	mv	a0,s1
    80004d80:	ffffd097          	auipc	ra,0xffffd
    80004d84:	640080e7          	jalr	1600(ra) # 800023c0 <sleep>
  while (lk->locked) {
    80004d88:	409c                	lw	a5,0(s1)
    80004d8a:	fbed                	bnez	a5,80004d7c <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004d8c:	4785                	li	a5,1
    80004d8e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004d90:	ffffd097          	auipc	ra,0xffffd
    80004d94:	da0080e7          	jalr	-608(ra) # 80001b30 <myproc>
    80004d98:	591c                	lw	a5,48(a0)
    80004d9a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004d9c:	854a                	mv	a0,s2
    80004d9e:	ffffc097          	auipc	ra,0xffffc
    80004da2:	02c080e7          	jalr	44(ra) # 80000dca <release>
}
    80004da6:	60e2                	ld	ra,24(sp)
    80004da8:	6442                	ld	s0,16(sp)
    80004daa:	64a2                	ld	s1,8(sp)
    80004dac:	6902                	ld	s2,0(sp)
    80004dae:	6105                	addi	sp,sp,32
    80004db0:	8082                	ret

0000000080004db2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004db2:	1101                	addi	sp,sp,-32
    80004db4:	ec06                	sd	ra,24(sp)
    80004db6:	e822                	sd	s0,16(sp)
    80004db8:	e426                	sd	s1,8(sp)
    80004dba:	e04a                	sd	s2,0(sp)
    80004dbc:	1000                	addi	s0,sp,32
    80004dbe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004dc0:	00850913          	addi	s2,a0,8
    80004dc4:	854a                	mv	a0,s2
    80004dc6:	ffffc097          	auipc	ra,0xffffc
    80004dca:	f50080e7          	jalr	-176(ra) # 80000d16 <acquire>
  lk->locked = 0;
    80004dce:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004dd2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004dd6:	8526                	mv	a0,s1
    80004dd8:	ffffd097          	auipc	ra,0xffffd
    80004ddc:	79c080e7          	jalr	1948(ra) # 80002574 <wakeup>
  release(&lk->lk);
    80004de0:	854a                	mv	a0,s2
    80004de2:	ffffc097          	auipc	ra,0xffffc
    80004de6:	fe8080e7          	jalr	-24(ra) # 80000dca <release>
}
    80004dea:	60e2                	ld	ra,24(sp)
    80004dec:	6442                	ld	s0,16(sp)
    80004dee:	64a2                	ld	s1,8(sp)
    80004df0:	6902                	ld	s2,0(sp)
    80004df2:	6105                	addi	sp,sp,32
    80004df4:	8082                	ret

0000000080004df6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004df6:	7179                	addi	sp,sp,-48
    80004df8:	f406                	sd	ra,40(sp)
    80004dfa:	f022                	sd	s0,32(sp)
    80004dfc:	ec26                	sd	s1,24(sp)
    80004dfe:	e84a                	sd	s2,16(sp)
    80004e00:	e44e                	sd	s3,8(sp)
    80004e02:	1800                	addi	s0,sp,48
    80004e04:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004e06:	00850913          	addi	s2,a0,8
    80004e0a:	854a                	mv	a0,s2
    80004e0c:	ffffc097          	auipc	ra,0xffffc
    80004e10:	f0a080e7          	jalr	-246(ra) # 80000d16 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004e14:	409c                	lw	a5,0(s1)
    80004e16:	ef99                	bnez	a5,80004e34 <holdingsleep+0x3e>
    80004e18:	4481                	li	s1,0
  release(&lk->lk);
    80004e1a:	854a                	mv	a0,s2
    80004e1c:	ffffc097          	auipc	ra,0xffffc
    80004e20:	fae080e7          	jalr	-82(ra) # 80000dca <release>
  return r;
}
    80004e24:	8526                	mv	a0,s1
    80004e26:	70a2                	ld	ra,40(sp)
    80004e28:	7402                	ld	s0,32(sp)
    80004e2a:	64e2                	ld	s1,24(sp)
    80004e2c:	6942                	ld	s2,16(sp)
    80004e2e:	69a2                	ld	s3,8(sp)
    80004e30:	6145                	addi	sp,sp,48
    80004e32:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004e34:	0284a983          	lw	s3,40(s1)
    80004e38:	ffffd097          	auipc	ra,0xffffd
    80004e3c:	cf8080e7          	jalr	-776(ra) # 80001b30 <myproc>
    80004e40:	5904                	lw	s1,48(a0)
    80004e42:	413484b3          	sub	s1,s1,s3
    80004e46:	0014b493          	seqz	s1,s1
    80004e4a:	bfc1                	j	80004e1a <holdingsleep+0x24>

0000000080004e4c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004e4c:	1141                	addi	sp,sp,-16
    80004e4e:	e406                	sd	ra,8(sp)
    80004e50:	e022                	sd	s0,0(sp)
    80004e52:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004e54:	00004597          	auipc	a1,0x4
    80004e58:	b1c58593          	addi	a1,a1,-1252 # 80008970 <syscallnames+0x298>
    80004e5c:	0023e517          	auipc	a0,0x23e
    80004e60:	3ac50513          	addi	a0,a0,940 # 80243208 <ftable>
    80004e64:	ffffc097          	auipc	ra,0xffffc
    80004e68:	e22080e7          	jalr	-478(ra) # 80000c86 <initlock>
}
    80004e6c:	60a2                	ld	ra,8(sp)
    80004e6e:	6402                	ld	s0,0(sp)
    80004e70:	0141                	addi	sp,sp,16
    80004e72:	8082                	ret

0000000080004e74 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004e74:	1101                	addi	sp,sp,-32
    80004e76:	ec06                	sd	ra,24(sp)
    80004e78:	e822                	sd	s0,16(sp)
    80004e7a:	e426                	sd	s1,8(sp)
    80004e7c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004e7e:	0023e517          	auipc	a0,0x23e
    80004e82:	38a50513          	addi	a0,a0,906 # 80243208 <ftable>
    80004e86:	ffffc097          	auipc	ra,0xffffc
    80004e8a:	e90080e7          	jalr	-368(ra) # 80000d16 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e8e:	0023e497          	auipc	s1,0x23e
    80004e92:	39248493          	addi	s1,s1,914 # 80243220 <ftable+0x18>
    80004e96:	0023f717          	auipc	a4,0x23f
    80004e9a:	32a70713          	addi	a4,a4,810 # 802441c0 <disk>
    if(f->ref == 0){
    80004e9e:	40dc                	lw	a5,4(s1)
    80004ea0:	cf99                	beqz	a5,80004ebe <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ea2:	02848493          	addi	s1,s1,40
    80004ea6:	fee49ce3          	bne	s1,a4,80004e9e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004eaa:	0023e517          	auipc	a0,0x23e
    80004eae:	35e50513          	addi	a0,a0,862 # 80243208 <ftable>
    80004eb2:	ffffc097          	auipc	ra,0xffffc
    80004eb6:	f18080e7          	jalr	-232(ra) # 80000dca <release>
  return 0;
    80004eba:	4481                	li	s1,0
    80004ebc:	a819                	j	80004ed2 <filealloc+0x5e>
      f->ref = 1;
    80004ebe:	4785                	li	a5,1
    80004ec0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004ec2:	0023e517          	auipc	a0,0x23e
    80004ec6:	34650513          	addi	a0,a0,838 # 80243208 <ftable>
    80004eca:	ffffc097          	auipc	ra,0xffffc
    80004ece:	f00080e7          	jalr	-256(ra) # 80000dca <release>
}
    80004ed2:	8526                	mv	a0,s1
    80004ed4:	60e2                	ld	ra,24(sp)
    80004ed6:	6442                	ld	s0,16(sp)
    80004ed8:	64a2                	ld	s1,8(sp)
    80004eda:	6105                	addi	sp,sp,32
    80004edc:	8082                	ret

0000000080004ede <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ede:	1101                	addi	sp,sp,-32
    80004ee0:	ec06                	sd	ra,24(sp)
    80004ee2:	e822                	sd	s0,16(sp)
    80004ee4:	e426                	sd	s1,8(sp)
    80004ee6:	1000                	addi	s0,sp,32
    80004ee8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004eea:	0023e517          	auipc	a0,0x23e
    80004eee:	31e50513          	addi	a0,a0,798 # 80243208 <ftable>
    80004ef2:	ffffc097          	auipc	ra,0xffffc
    80004ef6:	e24080e7          	jalr	-476(ra) # 80000d16 <acquire>
  if(f->ref < 1)
    80004efa:	40dc                	lw	a5,4(s1)
    80004efc:	02f05263          	blez	a5,80004f20 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004f00:	2785                	addiw	a5,a5,1
    80004f02:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004f04:	0023e517          	auipc	a0,0x23e
    80004f08:	30450513          	addi	a0,a0,772 # 80243208 <ftable>
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	ebe080e7          	jalr	-322(ra) # 80000dca <release>
  return f;
}
    80004f14:	8526                	mv	a0,s1
    80004f16:	60e2                	ld	ra,24(sp)
    80004f18:	6442                	ld	s0,16(sp)
    80004f1a:	64a2                	ld	s1,8(sp)
    80004f1c:	6105                	addi	sp,sp,32
    80004f1e:	8082                	ret
    panic("filedup");
    80004f20:	00004517          	auipc	a0,0x4
    80004f24:	a5850513          	addi	a0,a0,-1448 # 80008978 <syscallnames+0x2a0>
    80004f28:	ffffb097          	auipc	ra,0xffffb
    80004f2c:	618080e7          	jalr	1560(ra) # 80000540 <panic>

0000000080004f30 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004f30:	7139                	addi	sp,sp,-64
    80004f32:	fc06                	sd	ra,56(sp)
    80004f34:	f822                	sd	s0,48(sp)
    80004f36:	f426                	sd	s1,40(sp)
    80004f38:	f04a                	sd	s2,32(sp)
    80004f3a:	ec4e                	sd	s3,24(sp)
    80004f3c:	e852                	sd	s4,16(sp)
    80004f3e:	e456                	sd	s5,8(sp)
    80004f40:	0080                	addi	s0,sp,64
    80004f42:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004f44:	0023e517          	auipc	a0,0x23e
    80004f48:	2c450513          	addi	a0,a0,708 # 80243208 <ftable>
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	dca080e7          	jalr	-566(ra) # 80000d16 <acquire>
  if(f->ref < 1)
    80004f54:	40dc                	lw	a5,4(s1)
    80004f56:	06f05163          	blez	a5,80004fb8 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004f5a:	37fd                	addiw	a5,a5,-1
    80004f5c:	0007871b          	sext.w	a4,a5
    80004f60:	c0dc                	sw	a5,4(s1)
    80004f62:	06e04363          	bgtz	a4,80004fc8 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004f66:	0004a903          	lw	s2,0(s1)
    80004f6a:	0094ca83          	lbu	s5,9(s1)
    80004f6e:	0104ba03          	ld	s4,16(s1)
    80004f72:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004f76:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004f7a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004f7e:	0023e517          	auipc	a0,0x23e
    80004f82:	28a50513          	addi	a0,a0,650 # 80243208 <ftable>
    80004f86:	ffffc097          	auipc	ra,0xffffc
    80004f8a:	e44080e7          	jalr	-444(ra) # 80000dca <release>

  if(ff.type == FD_PIPE){
    80004f8e:	4785                	li	a5,1
    80004f90:	04f90d63          	beq	s2,a5,80004fea <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004f94:	3979                	addiw	s2,s2,-2
    80004f96:	4785                	li	a5,1
    80004f98:	0527e063          	bltu	a5,s2,80004fd8 <fileclose+0xa8>
    begin_op();
    80004f9c:	00000097          	auipc	ra,0x0
    80004fa0:	acc080e7          	jalr	-1332(ra) # 80004a68 <begin_op>
    iput(ff.ip);
    80004fa4:	854e                	mv	a0,s3
    80004fa6:	fffff097          	auipc	ra,0xfffff
    80004faa:	2b0080e7          	jalr	688(ra) # 80004256 <iput>
    end_op();
    80004fae:	00000097          	auipc	ra,0x0
    80004fb2:	b38080e7          	jalr	-1224(ra) # 80004ae6 <end_op>
    80004fb6:	a00d                	j	80004fd8 <fileclose+0xa8>
    panic("fileclose");
    80004fb8:	00004517          	auipc	a0,0x4
    80004fbc:	9c850513          	addi	a0,a0,-1592 # 80008980 <syscallnames+0x2a8>
    80004fc0:	ffffb097          	auipc	ra,0xffffb
    80004fc4:	580080e7          	jalr	1408(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004fc8:	0023e517          	auipc	a0,0x23e
    80004fcc:	24050513          	addi	a0,a0,576 # 80243208 <ftable>
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	dfa080e7          	jalr	-518(ra) # 80000dca <release>
  }
}
    80004fd8:	70e2                	ld	ra,56(sp)
    80004fda:	7442                	ld	s0,48(sp)
    80004fdc:	74a2                	ld	s1,40(sp)
    80004fde:	7902                	ld	s2,32(sp)
    80004fe0:	69e2                	ld	s3,24(sp)
    80004fe2:	6a42                	ld	s4,16(sp)
    80004fe4:	6aa2                	ld	s5,8(sp)
    80004fe6:	6121                	addi	sp,sp,64
    80004fe8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004fea:	85d6                	mv	a1,s5
    80004fec:	8552                	mv	a0,s4
    80004fee:	00000097          	auipc	ra,0x0
    80004ff2:	34c080e7          	jalr	844(ra) # 8000533a <pipeclose>
    80004ff6:	b7cd                	j	80004fd8 <fileclose+0xa8>

0000000080004ff8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ff8:	715d                	addi	sp,sp,-80
    80004ffa:	e486                	sd	ra,72(sp)
    80004ffc:	e0a2                	sd	s0,64(sp)
    80004ffe:	fc26                	sd	s1,56(sp)
    80005000:	f84a                	sd	s2,48(sp)
    80005002:	f44e                	sd	s3,40(sp)
    80005004:	0880                	addi	s0,sp,80
    80005006:	84aa                	mv	s1,a0
    80005008:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000500a:	ffffd097          	auipc	ra,0xffffd
    8000500e:	b26080e7          	jalr	-1242(ra) # 80001b30 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005012:	409c                	lw	a5,0(s1)
    80005014:	37f9                	addiw	a5,a5,-2
    80005016:	4705                	li	a4,1
    80005018:	04f76763          	bltu	a4,a5,80005066 <filestat+0x6e>
    8000501c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000501e:	6c88                	ld	a0,24(s1)
    80005020:	fffff097          	auipc	ra,0xfffff
    80005024:	07c080e7          	jalr	124(ra) # 8000409c <ilock>
    stati(f->ip, &st);
    80005028:	fb840593          	addi	a1,s0,-72
    8000502c:	6c88                	ld	a0,24(s1)
    8000502e:	fffff097          	auipc	ra,0xfffff
    80005032:	2f8080e7          	jalr	760(ra) # 80004326 <stati>
    iunlock(f->ip);
    80005036:	6c88                	ld	a0,24(s1)
    80005038:	fffff097          	auipc	ra,0xfffff
    8000503c:	126080e7          	jalr	294(ra) # 8000415e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005040:	46e1                	li	a3,24
    80005042:	fb840613          	addi	a2,s0,-72
    80005046:	85ce                	mv	a1,s3
    80005048:	05093503          	ld	a0,80(s2)
    8000504c:	ffffc097          	auipc	ra,0xffffc
    80005050:	74c080e7          	jalr	1868(ra) # 80001798 <copyout>
    80005054:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005058:	60a6                	ld	ra,72(sp)
    8000505a:	6406                	ld	s0,64(sp)
    8000505c:	74e2                	ld	s1,56(sp)
    8000505e:	7942                	ld	s2,48(sp)
    80005060:	79a2                	ld	s3,40(sp)
    80005062:	6161                	addi	sp,sp,80
    80005064:	8082                	ret
  return -1;
    80005066:	557d                	li	a0,-1
    80005068:	bfc5                	j	80005058 <filestat+0x60>

000000008000506a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000506a:	7179                	addi	sp,sp,-48
    8000506c:	f406                	sd	ra,40(sp)
    8000506e:	f022                	sd	s0,32(sp)
    80005070:	ec26                	sd	s1,24(sp)
    80005072:	e84a                	sd	s2,16(sp)
    80005074:	e44e                	sd	s3,8(sp)
    80005076:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005078:	00854783          	lbu	a5,8(a0)
    8000507c:	c3d5                	beqz	a5,80005120 <fileread+0xb6>
    8000507e:	84aa                	mv	s1,a0
    80005080:	89ae                	mv	s3,a1
    80005082:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005084:	411c                	lw	a5,0(a0)
    80005086:	4705                	li	a4,1
    80005088:	04e78963          	beq	a5,a4,800050da <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000508c:	470d                	li	a4,3
    8000508e:	04e78d63          	beq	a5,a4,800050e8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005092:	4709                	li	a4,2
    80005094:	06e79e63          	bne	a5,a4,80005110 <fileread+0xa6>
    ilock(f->ip);
    80005098:	6d08                	ld	a0,24(a0)
    8000509a:	fffff097          	auipc	ra,0xfffff
    8000509e:	002080e7          	jalr	2(ra) # 8000409c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800050a2:	874a                	mv	a4,s2
    800050a4:	5094                	lw	a3,32(s1)
    800050a6:	864e                	mv	a2,s3
    800050a8:	4585                	li	a1,1
    800050aa:	6c88                	ld	a0,24(s1)
    800050ac:	fffff097          	auipc	ra,0xfffff
    800050b0:	2a4080e7          	jalr	676(ra) # 80004350 <readi>
    800050b4:	892a                	mv	s2,a0
    800050b6:	00a05563          	blez	a0,800050c0 <fileread+0x56>
      f->off += r;
    800050ba:	509c                	lw	a5,32(s1)
    800050bc:	9fa9                	addw	a5,a5,a0
    800050be:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800050c0:	6c88                	ld	a0,24(s1)
    800050c2:	fffff097          	auipc	ra,0xfffff
    800050c6:	09c080e7          	jalr	156(ra) # 8000415e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800050ca:	854a                	mv	a0,s2
    800050cc:	70a2                	ld	ra,40(sp)
    800050ce:	7402                	ld	s0,32(sp)
    800050d0:	64e2                	ld	s1,24(sp)
    800050d2:	6942                	ld	s2,16(sp)
    800050d4:	69a2                	ld	s3,8(sp)
    800050d6:	6145                	addi	sp,sp,48
    800050d8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800050da:	6908                	ld	a0,16(a0)
    800050dc:	00000097          	auipc	ra,0x0
    800050e0:	3c6080e7          	jalr	966(ra) # 800054a2 <piperead>
    800050e4:	892a                	mv	s2,a0
    800050e6:	b7d5                	j	800050ca <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800050e8:	02451783          	lh	a5,36(a0)
    800050ec:	03079693          	slli	a3,a5,0x30
    800050f0:	92c1                	srli	a3,a3,0x30
    800050f2:	4725                	li	a4,9
    800050f4:	02d76863          	bltu	a4,a3,80005124 <fileread+0xba>
    800050f8:	0792                	slli	a5,a5,0x4
    800050fa:	0023e717          	auipc	a4,0x23e
    800050fe:	06e70713          	addi	a4,a4,110 # 80243168 <devsw>
    80005102:	97ba                	add	a5,a5,a4
    80005104:	639c                	ld	a5,0(a5)
    80005106:	c38d                	beqz	a5,80005128 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005108:	4505                	li	a0,1
    8000510a:	9782                	jalr	a5
    8000510c:	892a                	mv	s2,a0
    8000510e:	bf75                	j	800050ca <fileread+0x60>
    panic("fileread");
    80005110:	00004517          	auipc	a0,0x4
    80005114:	88050513          	addi	a0,a0,-1920 # 80008990 <syscallnames+0x2b8>
    80005118:	ffffb097          	auipc	ra,0xffffb
    8000511c:	428080e7          	jalr	1064(ra) # 80000540 <panic>
    return -1;
    80005120:	597d                	li	s2,-1
    80005122:	b765                	j	800050ca <fileread+0x60>
      return -1;
    80005124:	597d                	li	s2,-1
    80005126:	b755                	j	800050ca <fileread+0x60>
    80005128:	597d                	li	s2,-1
    8000512a:	b745                	j	800050ca <fileread+0x60>

000000008000512c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000512c:	715d                	addi	sp,sp,-80
    8000512e:	e486                	sd	ra,72(sp)
    80005130:	e0a2                	sd	s0,64(sp)
    80005132:	fc26                	sd	s1,56(sp)
    80005134:	f84a                	sd	s2,48(sp)
    80005136:	f44e                	sd	s3,40(sp)
    80005138:	f052                	sd	s4,32(sp)
    8000513a:	ec56                	sd	s5,24(sp)
    8000513c:	e85a                	sd	s6,16(sp)
    8000513e:	e45e                	sd	s7,8(sp)
    80005140:	e062                	sd	s8,0(sp)
    80005142:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005144:	00954783          	lbu	a5,9(a0)
    80005148:	10078663          	beqz	a5,80005254 <filewrite+0x128>
    8000514c:	892a                	mv	s2,a0
    8000514e:	8b2e                	mv	s6,a1
    80005150:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005152:	411c                	lw	a5,0(a0)
    80005154:	4705                	li	a4,1
    80005156:	02e78263          	beq	a5,a4,8000517a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000515a:	470d                	li	a4,3
    8000515c:	02e78663          	beq	a5,a4,80005188 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005160:	4709                	li	a4,2
    80005162:	0ee79163          	bne	a5,a4,80005244 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005166:	0ac05d63          	blez	a2,80005220 <filewrite+0xf4>
    int i = 0;
    8000516a:	4981                	li	s3,0
    8000516c:	6b85                	lui	s7,0x1
    8000516e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005172:	6c05                	lui	s8,0x1
    80005174:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80005178:	a861                	j	80005210 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000517a:	6908                	ld	a0,16(a0)
    8000517c:	00000097          	auipc	ra,0x0
    80005180:	22e080e7          	jalr	558(ra) # 800053aa <pipewrite>
    80005184:	8a2a                	mv	s4,a0
    80005186:	a045                	j	80005226 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005188:	02451783          	lh	a5,36(a0)
    8000518c:	03079693          	slli	a3,a5,0x30
    80005190:	92c1                	srli	a3,a3,0x30
    80005192:	4725                	li	a4,9
    80005194:	0cd76263          	bltu	a4,a3,80005258 <filewrite+0x12c>
    80005198:	0792                	slli	a5,a5,0x4
    8000519a:	0023e717          	auipc	a4,0x23e
    8000519e:	fce70713          	addi	a4,a4,-50 # 80243168 <devsw>
    800051a2:	97ba                	add	a5,a5,a4
    800051a4:	679c                	ld	a5,8(a5)
    800051a6:	cbdd                	beqz	a5,8000525c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800051a8:	4505                	li	a0,1
    800051aa:	9782                	jalr	a5
    800051ac:	8a2a                	mv	s4,a0
    800051ae:	a8a5                	j	80005226 <filewrite+0xfa>
    800051b0:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800051b4:	00000097          	auipc	ra,0x0
    800051b8:	8b4080e7          	jalr	-1868(ra) # 80004a68 <begin_op>
      ilock(f->ip);
    800051bc:	01893503          	ld	a0,24(s2)
    800051c0:	fffff097          	auipc	ra,0xfffff
    800051c4:	edc080e7          	jalr	-292(ra) # 8000409c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800051c8:	8756                	mv	a4,s5
    800051ca:	02092683          	lw	a3,32(s2)
    800051ce:	01698633          	add	a2,s3,s6
    800051d2:	4585                	li	a1,1
    800051d4:	01893503          	ld	a0,24(s2)
    800051d8:	fffff097          	auipc	ra,0xfffff
    800051dc:	270080e7          	jalr	624(ra) # 80004448 <writei>
    800051e0:	84aa                	mv	s1,a0
    800051e2:	00a05763          	blez	a0,800051f0 <filewrite+0xc4>
        f->off += r;
    800051e6:	02092783          	lw	a5,32(s2)
    800051ea:	9fa9                	addw	a5,a5,a0
    800051ec:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800051f0:	01893503          	ld	a0,24(s2)
    800051f4:	fffff097          	auipc	ra,0xfffff
    800051f8:	f6a080e7          	jalr	-150(ra) # 8000415e <iunlock>
      end_op();
    800051fc:	00000097          	auipc	ra,0x0
    80005200:	8ea080e7          	jalr	-1814(ra) # 80004ae6 <end_op>

      if(r != n1){
    80005204:	009a9f63          	bne	s5,s1,80005222 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005208:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000520c:	0149db63          	bge	s3,s4,80005222 <filewrite+0xf6>
      int n1 = n - i;
    80005210:	413a04bb          	subw	s1,s4,s3
    80005214:	0004879b          	sext.w	a5,s1
    80005218:	f8fbdce3          	bge	s7,a5,800051b0 <filewrite+0x84>
    8000521c:	84e2                	mv	s1,s8
    8000521e:	bf49                	j	800051b0 <filewrite+0x84>
    int i = 0;
    80005220:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005222:	013a1f63          	bne	s4,s3,80005240 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005226:	8552                	mv	a0,s4
    80005228:	60a6                	ld	ra,72(sp)
    8000522a:	6406                	ld	s0,64(sp)
    8000522c:	74e2                	ld	s1,56(sp)
    8000522e:	7942                	ld	s2,48(sp)
    80005230:	79a2                	ld	s3,40(sp)
    80005232:	7a02                	ld	s4,32(sp)
    80005234:	6ae2                	ld	s5,24(sp)
    80005236:	6b42                	ld	s6,16(sp)
    80005238:	6ba2                	ld	s7,8(sp)
    8000523a:	6c02                	ld	s8,0(sp)
    8000523c:	6161                	addi	sp,sp,80
    8000523e:	8082                	ret
    ret = (i == n ? n : -1);
    80005240:	5a7d                	li	s4,-1
    80005242:	b7d5                	j	80005226 <filewrite+0xfa>
    panic("filewrite");
    80005244:	00003517          	auipc	a0,0x3
    80005248:	75c50513          	addi	a0,a0,1884 # 800089a0 <syscallnames+0x2c8>
    8000524c:	ffffb097          	auipc	ra,0xffffb
    80005250:	2f4080e7          	jalr	756(ra) # 80000540 <panic>
    return -1;
    80005254:	5a7d                	li	s4,-1
    80005256:	bfc1                	j	80005226 <filewrite+0xfa>
      return -1;
    80005258:	5a7d                	li	s4,-1
    8000525a:	b7f1                	j	80005226 <filewrite+0xfa>
    8000525c:	5a7d                	li	s4,-1
    8000525e:	b7e1                	j	80005226 <filewrite+0xfa>

0000000080005260 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005260:	7179                	addi	sp,sp,-48
    80005262:	f406                	sd	ra,40(sp)
    80005264:	f022                	sd	s0,32(sp)
    80005266:	ec26                	sd	s1,24(sp)
    80005268:	e84a                	sd	s2,16(sp)
    8000526a:	e44e                	sd	s3,8(sp)
    8000526c:	e052                	sd	s4,0(sp)
    8000526e:	1800                	addi	s0,sp,48
    80005270:	84aa                	mv	s1,a0
    80005272:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005274:	0005b023          	sd	zero,0(a1)
    80005278:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000527c:	00000097          	auipc	ra,0x0
    80005280:	bf8080e7          	jalr	-1032(ra) # 80004e74 <filealloc>
    80005284:	e088                	sd	a0,0(s1)
    80005286:	c551                	beqz	a0,80005312 <pipealloc+0xb2>
    80005288:	00000097          	auipc	ra,0x0
    8000528c:	bec080e7          	jalr	-1044(ra) # 80004e74 <filealloc>
    80005290:	00aa3023          	sd	a0,0(s4)
    80005294:	c92d                	beqz	a0,80005306 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005296:	ffffc097          	auipc	ra,0xffffc
    8000529a:	952080e7          	jalr	-1710(ra) # 80000be8 <kalloc>
    8000529e:	892a                	mv	s2,a0
    800052a0:	c125                	beqz	a0,80005300 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800052a2:	4985                	li	s3,1
    800052a4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800052a8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800052ac:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800052b0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800052b4:	00003597          	auipc	a1,0x3
    800052b8:	24458593          	addi	a1,a1,580 # 800084f8 <states.0+0x1d8>
    800052bc:	ffffc097          	auipc	ra,0xffffc
    800052c0:	9ca080e7          	jalr	-1590(ra) # 80000c86 <initlock>
  (*f0)->type = FD_PIPE;
    800052c4:	609c                	ld	a5,0(s1)
    800052c6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800052ca:	609c                	ld	a5,0(s1)
    800052cc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800052d0:	609c                	ld	a5,0(s1)
    800052d2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800052d6:	609c                	ld	a5,0(s1)
    800052d8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800052dc:	000a3783          	ld	a5,0(s4)
    800052e0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800052e4:	000a3783          	ld	a5,0(s4)
    800052e8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800052ec:	000a3783          	ld	a5,0(s4)
    800052f0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800052f4:	000a3783          	ld	a5,0(s4)
    800052f8:	0127b823          	sd	s2,16(a5)
  return 0;
    800052fc:	4501                	li	a0,0
    800052fe:	a025                	j	80005326 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005300:	6088                	ld	a0,0(s1)
    80005302:	e501                	bnez	a0,8000530a <pipealloc+0xaa>
    80005304:	a039                	j	80005312 <pipealloc+0xb2>
    80005306:	6088                	ld	a0,0(s1)
    80005308:	c51d                	beqz	a0,80005336 <pipealloc+0xd6>
    fileclose(*f0);
    8000530a:	00000097          	auipc	ra,0x0
    8000530e:	c26080e7          	jalr	-986(ra) # 80004f30 <fileclose>
  if(*f1)
    80005312:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005316:	557d                	li	a0,-1
  if(*f1)
    80005318:	c799                	beqz	a5,80005326 <pipealloc+0xc6>
    fileclose(*f1);
    8000531a:	853e                	mv	a0,a5
    8000531c:	00000097          	auipc	ra,0x0
    80005320:	c14080e7          	jalr	-1004(ra) # 80004f30 <fileclose>
  return -1;
    80005324:	557d                	li	a0,-1
}
    80005326:	70a2                	ld	ra,40(sp)
    80005328:	7402                	ld	s0,32(sp)
    8000532a:	64e2                	ld	s1,24(sp)
    8000532c:	6942                	ld	s2,16(sp)
    8000532e:	69a2                	ld	s3,8(sp)
    80005330:	6a02                	ld	s4,0(sp)
    80005332:	6145                	addi	sp,sp,48
    80005334:	8082                	ret
  return -1;
    80005336:	557d                	li	a0,-1
    80005338:	b7fd                	j	80005326 <pipealloc+0xc6>

000000008000533a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000533a:	1101                	addi	sp,sp,-32
    8000533c:	ec06                	sd	ra,24(sp)
    8000533e:	e822                	sd	s0,16(sp)
    80005340:	e426                	sd	s1,8(sp)
    80005342:	e04a                	sd	s2,0(sp)
    80005344:	1000                	addi	s0,sp,32
    80005346:	84aa                	mv	s1,a0
    80005348:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000534a:	ffffc097          	auipc	ra,0xffffc
    8000534e:	9cc080e7          	jalr	-1588(ra) # 80000d16 <acquire>
  if(writable){
    80005352:	02090d63          	beqz	s2,8000538c <pipeclose+0x52>
    pi->writeopen = 0;
    80005356:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000535a:	21848513          	addi	a0,s1,536
    8000535e:	ffffd097          	auipc	ra,0xffffd
    80005362:	216080e7          	jalr	534(ra) # 80002574 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005366:	2204b783          	ld	a5,544(s1)
    8000536a:	eb95                	bnez	a5,8000539e <pipeclose+0x64>
    release(&pi->lock);
    8000536c:	8526                	mv	a0,s1
    8000536e:	ffffc097          	auipc	ra,0xffffc
    80005372:	a5c080e7          	jalr	-1444(ra) # 80000dca <release>
    kfree((char*)pi);
    80005376:	8526                	mv	a0,s1
    80005378:	ffffb097          	auipc	ra,0xffffb
    8000537c:	6ec080e7          	jalr	1772(ra) # 80000a64 <kfree>
  } else
    release(&pi->lock);
}
    80005380:	60e2                	ld	ra,24(sp)
    80005382:	6442                	ld	s0,16(sp)
    80005384:	64a2                	ld	s1,8(sp)
    80005386:	6902                	ld	s2,0(sp)
    80005388:	6105                	addi	sp,sp,32
    8000538a:	8082                	ret
    pi->readopen = 0;
    8000538c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005390:	21c48513          	addi	a0,s1,540
    80005394:	ffffd097          	auipc	ra,0xffffd
    80005398:	1e0080e7          	jalr	480(ra) # 80002574 <wakeup>
    8000539c:	b7e9                	j	80005366 <pipeclose+0x2c>
    release(&pi->lock);
    8000539e:	8526                	mv	a0,s1
    800053a0:	ffffc097          	auipc	ra,0xffffc
    800053a4:	a2a080e7          	jalr	-1494(ra) # 80000dca <release>
}
    800053a8:	bfe1                	j	80005380 <pipeclose+0x46>

00000000800053aa <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800053aa:	711d                	addi	sp,sp,-96
    800053ac:	ec86                	sd	ra,88(sp)
    800053ae:	e8a2                	sd	s0,80(sp)
    800053b0:	e4a6                	sd	s1,72(sp)
    800053b2:	e0ca                	sd	s2,64(sp)
    800053b4:	fc4e                	sd	s3,56(sp)
    800053b6:	f852                	sd	s4,48(sp)
    800053b8:	f456                	sd	s5,40(sp)
    800053ba:	f05a                	sd	s6,32(sp)
    800053bc:	ec5e                	sd	s7,24(sp)
    800053be:	e862                	sd	s8,16(sp)
    800053c0:	1080                	addi	s0,sp,96
    800053c2:	84aa                	mv	s1,a0
    800053c4:	8aae                	mv	s5,a1
    800053c6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800053c8:	ffffc097          	auipc	ra,0xffffc
    800053cc:	768080e7          	jalr	1896(ra) # 80001b30 <myproc>
    800053d0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800053d2:	8526                	mv	a0,s1
    800053d4:	ffffc097          	auipc	ra,0xffffc
    800053d8:	942080e7          	jalr	-1726(ra) # 80000d16 <acquire>
  while(i < n){
    800053dc:	0b405663          	blez	s4,80005488 <pipewrite+0xde>
  int i = 0;
    800053e0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800053e2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800053e4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800053e8:	21c48b93          	addi	s7,s1,540
    800053ec:	a089                	j	8000542e <pipewrite+0x84>
      release(&pi->lock);
    800053ee:	8526                	mv	a0,s1
    800053f0:	ffffc097          	auipc	ra,0xffffc
    800053f4:	9da080e7          	jalr	-1574(ra) # 80000dca <release>
      return -1;
    800053f8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800053fa:	854a                	mv	a0,s2
    800053fc:	60e6                	ld	ra,88(sp)
    800053fe:	6446                	ld	s0,80(sp)
    80005400:	64a6                	ld	s1,72(sp)
    80005402:	6906                	ld	s2,64(sp)
    80005404:	79e2                	ld	s3,56(sp)
    80005406:	7a42                	ld	s4,48(sp)
    80005408:	7aa2                	ld	s5,40(sp)
    8000540a:	7b02                	ld	s6,32(sp)
    8000540c:	6be2                	ld	s7,24(sp)
    8000540e:	6c42                	ld	s8,16(sp)
    80005410:	6125                	addi	sp,sp,96
    80005412:	8082                	ret
      wakeup(&pi->nread);
    80005414:	8562                	mv	a0,s8
    80005416:	ffffd097          	auipc	ra,0xffffd
    8000541a:	15e080e7          	jalr	350(ra) # 80002574 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000541e:	85a6                	mv	a1,s1
    80005420:	855e                	mv	a0,s7
    80005422:	ffffd097          	auipc	ra,0xffffd
    80005426:	f9e080e7          	jalr	-98(ra) # 800023c0 <sleep>
  while(i < n){
    8000542a:	07495063          	bge	s2,s4,8000548a <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    8000542e:	2204a783          	lw	a5,544(s1)
    80005432:	dfd5                	beqz	a5,800053ee <pipewrite+0x44>
    80005434:	854e                	mv	a0,s3
    80005436:	ffffd097          	auipc	ra,0xffffd
    8000543a:	416080e7          	jalr	1046(ra) # 8000284c <killed>
    8000543e:	f945                	bnez	a0,800053ee <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005440:	2184a783          	lw	a5,536(s1)
    80005444:	21c4a703          	lw	a4,540(s1)
    80005448:	2007879b          	addiw	a5,a5,512
    8000544c:	fcf704e3          	beq	a4,a5,80005414 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005450:	4685                	li	a3,1
    80005452:	01590633          	add	a2,s2,s5
    80005456:	faf40593          	addi	a1,s0,-81
    8000545a:	0509b503          	ld	a0,80(s3)
    8000545e:	ffffc097          	auipc	ra,0xffffc
    80005462:	414080e7          	jalr	1044(ra) # 80001872 <copyin>
    80005466:	03650263          	beq	a0,s6,8000548a <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000546a:	21c4a783          	lw	a5,540(s1)
    8000546e:	0017871b          	addiw	a4,a5,1
    80005472:	20e4ae23          	sw	a4,540(s1)
    80005476:	1ff7f793          	andi	a5,a5,511
    8000547a:	97a6                	add	a5,a5,s1
    8000547c:	faf44703          	lbu	a4,-81(s0)
    80005480:	00e78c23          	sb	a4,24(a5)
      i++;
    80005484:	2905                	addiw	s2,s2,1
    80005486:	b755                	j	8000542a <pipewrite+0x80>
  int i = 0;
    80005488:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000548a:	21848513          	addi	a0,s1,536
    8000548e:	ffffd097          	auipc	ra,0xffffd
    80005492:	0e6080e7          	jalr	230(ra) # 80002574 <wakeup>
  release(&pi->lock);
    80005496:	8526                	mv	a0,s1
    80005498:	ffffc097          	auipc	ra,0xffffc
    8000549c:	932080e7          	jalr	-1742(ra) # 80000dca <release>
  return i;
    800054a0:	bfa9                	j	800053fa <pipewrite+0x50>

00000000800054a2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800054a2:	715d                	addi	sp,sp,-80
    800054a4:	e486                	sd	ra,72(sp)
    800054a6:	e0a2                	sd	s0,64(sp)
    800054a8:	fc26                	sd	s1,56(sp)
    800054aa:	f84a                	sd	s2,48(sp)
    800054ac:	f44e                	sd	s3,40(sp)
    800054ae:	f052                	sd	s4,32(sp)
    800054b0:	ec56                	sd	s5,24(sp)
    800054b2:	e85a                	sd	s6,16(sp)
    800054b4:	0880                	addi	s0,sp,80
    800054b6:	84aa                	mv	s1,a0
    800054b8:	892e                	mv	s2,a1
    800054ba:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800054bc:	ffffc097          	auipc	ra,0xffffc
    800054c0:	674080e7          	jalr	1652(ra) # 80001b30 <myproc>
    800054c4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800054c6:	8526                	mv	a0,s1
    800054c8:	ffffc097          	auipc	ra,0xffffc
    800054cc:	84e080e7          	jalr	-1970(ra) # 80000d16 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054d0:	2184a703          	lw	a4,536(s1)
    800054d4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800054d8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054dc:	02f71763          	bne	a4,a5,8000550a <piperead+0x68>
    800054e0:	2244a783          	lw	a5,548(s1)
    800054e4:	c39d                	beqz	a5,8000550a <piperead+0x68>
    if(killed(pr)){
    800054e6:	8552                	mv	a0,s4
    800054e8:	ffffd097          	auipc	ra,0xffffd
    800054ec:	364080e7          	jalr	868(ra) # 8000284c <killed>
    800054f0:	e949                	bnez	a0,80005582 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800054f2:	85a6                	mv	a1,s1
    800054f4:	854e                	mv	a0,s3
    800054f6:	ffffd097          	auipc	ra,0xffffd
    800054fa:	eca080e7          	jalr	-310(ra) # 800023c0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054fe:	2184a703          	lw	a4,536(s1)
    80005502:	21c4a783          	lw	a5,540(s1)
    80005506:	fcf70de3          	beq	a4,a5,800054e0 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000550a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000550c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000550e:	05505463          	blez	s5,80005556 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005512:	2184a783          	lw	a5,536(s1)
    80005516:	21c4a703          	lw	a4,540(s1)
    8000551a:	02f70e63          	beq	a4,a5,80005556 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000551e:	0017871b          	addiw	a4,a5,1
    80005522:	20e4ac23          	sw	a4,536(s1)
    80005526:	1ff7f793          	andi	a5,a5,511
    8000552a:	97a6                	add	a5,a5,s1
    8000552c:	0187c783          	lbu	a5,24(a5)
    80005530:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005534:	4685                	li	a3,1
    80005536:	fbf40613          	addi	a2,s0,-65
    8000553a:	85ca                	mv	a1,s2
    8000553c:	050a3503          	ld	a0,80(s4)
    80005540:	ffffc097          	auipc	ra,0xffffc
    80005544:	258080e7          	jalr	600(ra) # 80001798 <copyout>
    80005548:	01650763          	beq	a0,s6,80005556 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000554c:	2985                	addiw	s3,s3,1
    8000554e:	0905                	addi	s2,s2,1
    80005550:	fd3a91e3          	bne	s5,s3,80005512 <piperead+0x70>
    80005554:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005556:	21c48513          	addi	a0,s1,540
    8000555a:	ffffd097          	auipc	ra,0xffffd
    8000555e:	01a080e7          	jalr	26(ra) # 80002574 <wakeup>
  release(&pi->lock);
    80005562:	8526                	mv	a0,s1
    80005564:	ffffc097          	auipc	ra,0xffffc
    80005568:	866080e7          	jalr	-1946(ra) # 80000dca <release>
  return i;
}
    8000556c:	854e                	mv	a0,s3
    8000556e:	60a6                	ld	ra,72(sp)
    80005570:	6406                	ld	s0,64(sp)
    80005572:	74e2                	ld	s1,56(sp)
    80005574:	7942                	ld	s2,48(sp)
    80005576:	79a2                	ld	s3,40(sp)
    80005578:	7a02                	ld	s4,32(sp)
    8000557a:	6ae2                	ld	s5,24(sp)
    8000557c:	6b42                	ld	s6,16(sp)
    8000557e:	6161                	addi	sp,sp,80
    80005580:	8082                	ret
      release(&pi->lock);
    80005582:	8526                	mv	a0,s1
    80005584:	ffffc097          	auipc	ra,0xffffc
    80005588:	846080e7          	jalr	-1978(ra) # 80000dca <release>
      return -1;
    8000558c:	59fd                	li	s3,-1
    8000558e:	bff9                	j	8000556c <piperead+0xca>

0000000080005590 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005590:	1141                	addi	sp,sp,-16
    80005592:	e422                	sd	s0,8(sp)
    80005594:	0800                	addi	s0,sp,16
    80005596:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005598:	8905                	andi	a0,a0,1
    8000559a:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000559c:	8b89                	andi	a5,a5,2
    8000559e:	c399                	beqz	a5,800055a4 <flags2perm+0x14>
      perm |= PTE_W;
    800055a0:	00456513          	ori	a0,a0,4
    return perm;
}
    800055a4:	6422                	ld	s0,8(sp)
    800055a6:	0141                	addi	sp,sp,16
    800055a8:	8082                	ret

00000000800055aa <exec>:

int
exec(char *path, char **argv)
{
    800055aa:	de010113          	addi	sp,sp,-544
    800055ae:	20113c23          	sd	ra,536(sp)
    800055b2:	20813823          	sd	s0,528(sp)
    800055b6:	20913423          	sd	s1,520(sp)
    800055ba:	21213023          	sd	s2,512(sp)
    800055be:	ffce                	sd	s3,504(sp)
    800055c0:	fbd2                	sd	s4,496(sp)
    800055c2:	f7d6                	sd	s5,488(sp)
    800055c4:	f3da                	sd	s6,480(sp)
    800055c6:	efde                	sd	s7,472(sp)
    800055c8:	ebe2                	sd	s8,464(sp)
    800055ca:	e7e6                	sd	s9,456(sp)
    800055cc:	e3ea                	sd	s10,448(sp)
    800055ce:	ff6e                	sd	s11,440(sp)
    800055d0:	1400                	addi	s0,sp,544
    800055d2:	892a                	mv	s2,a0
    800055d4:	dea43423          	sd	a0,-536(s0)
    800055d8:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800055dc:	ffffc097          	auipc	ra,0xffffc
    800055e0:	554080e7          	jalr	1364(ra) # 80001b30 <myproc>
    800055e4:	84aa                	mv	s1,a0

  begin_op();
    800055e6:	fffff097          	auipc	ra,0xfffff
    800055ea:	482080e7          	jalr	1154(ra) # 80004a68 <begin_op>

  if((ip = namei(path)) == 0){
    800055ee:	854a                	mv	a0,s2
    800055f0:	fffff097          	auipc	ra,0xfffff
    800055f4:	258080e7          	jalr	600(ra) # 80004848 <namei>
    800055f8:	c93d                	beqz	a0,8000566e <exec+0xc4>
    800055fa:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800055fc:	fffff097          	auipc	ra,0xfffff
    80005600:	aa0080e7          	jalr	-1376(ra) # 8000409c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005604:	04000713          	li	a4,64
    80005608:	4681                	li	a3,0
    8000560a:	e5040613          	addi	a2,s0,-432
    8000560e:	4581                	li	a1,0
    80005610:	8556                	mv	a0,s5
    80005612:	fffff097          	auipc	ra,0xfffff
    80005616:	d3e080e7          	jalr	-706(ra) # 80004350 <readi>
    8000561a:	04000793          	li	a5,64
    8000561e:	00f51a63          	bne	a0,a5,80005632 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005622:	e5042703          	lw	a4,-432(s0)
    80005626:	464c47b7          	lui	a5,0x464c4
    8000562a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000562e:	04f70663          	beq	a4,a5,8000567a <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005632:	8556                	mv	a0,s5
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	cca080e7          	jalr	-822(ra) # 800042fe <iunlockput>
    end_op();
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	4aa080e7          	jalr	1194(ra) # 80004ae6 <end_op>
  }
  return -1;
    80005644:	557d                	li	a0,-1
}
    80005646:	21813083          	ld	ra,536(sp)
    8000564a:	21013403          	ld	s0,528(sp)
    8000564e:	20813483          	ld	s1,520(sp)
    80005652:	20013903          	ld	s2,512(sp)
    80005656:	79fe                	ld	s3,504(sp)
    80005658:	7a5e                	ld	s4,496(sp)
    8000565a:	7abe                	ld	s5,488(sp)
    8000565c:	7b1e                	ld	s6,480(sp)
    8000565e:	6bfe                	ld	s7,472(sp)
    80005660:	6c5e                	ld	s8,464(sp)
    80005662:	6cbe                	ld	s9,456(sp)
    80005664:	6d1e                	ld	s10,448(sp)
    80005666:	7dfa                	ld	s11,440(sp)
    80005668:	22010113          	addi	sp,sp,544
    8000566c:	8082                	ret
    end_op();
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	478080e7          	jalr	1144(ra) # 80004ae6 <end_op>
    return -1;
    80005676:	557d                	li	a0,-1
    80005678:	b7f9                	j	80005646 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000567a:	8526                	mv	a0,s1
    8000567c:	ffffc097          	auipc	ra,0xffffc
    80005680:	61a080e7          	jalr	1562(ra) # 80001c96 <proc_pagetable>
    80005684:	8b2a                	mv	s6,a0
    80005686:	d555                	beqz	a0,80005632 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005688:	e7042783          	lw	a5,-400(s0)
    8000568c:	e8845703          	lhu	a4,-376(s0)
    80005690:	c735                	beqz	a4,800056fc <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005692:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005694:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005698:	6a05                	lui	s4,0x1
    8000569a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000569e:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800056a2:	6d85                	lui	s11,0x1
    800056a4:	7d7d                	lui	s10,0xfffff
    800056a6:	ac3d                	j	800058e4 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800056a8:	00003517          	auipc	a0,0x3
    800056ac:	30850513          	addi	a0,a0,776 # 800089b0 <syscallnames+0x2d8>
    800056b0:	ffffb097          	auipc	ra,0xffffb
    800056b4:	e90080e7          	jalr	-368(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800056b8:	874a                	mv	a4,s2
    800056ba:	009c86bb          	addw	a3,s9,s1
    800056be:	4581                	li	a1,0
    800056c0:	8556                	mv	a0,s5
    800056c2:	fffff097          	auipc	ra,0xfffff
    800056c6:	c8e080e7          	jalr	-882(ra) # 80004350 <readi>
    800056ca:	2501                	sext.w	a0,a0
    800056cc:	1aa91963          	bne	s2,a0,8000587e <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    800056d0:	009d84bb          	addw	s1,s11,s1
    800056d4:	013d09bb          	addw	s3,s10,s3
    800056d8:	1f74f663          	bgeu	s1,s7,800058c4 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    800056dc:	02049593          	slli	a1,s1,0x20
    800056e0:	9181                	srli	a1,a1,0x20
    800056e2:	95e2                	add	a1,a1,s8
    800056e4:	855a                	mv	a0,s6
    800056e6:	ffffc097          	auipc	ra,0xffffc
    800056ea:	ab6080e7          	jalr	-1354(ra) # 8000119c <walkaddr>
    800056ee:	862a                	mv	a2,a0
    if(pa == 0)
    800056f0:	dd45                	beqz	a0,800056a8 <exec+0xfe>
      n = PGSIZE;
    800056f2:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800056f4:	fd49f2e3          	bgeu	s3,s4,800056b8 <exec+0x10e>
      n = sz - i;
    800056f8:	894e                	mv	s2,s3
    800056fa:	bf7d                	j	800056b8 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800056fc:	4901                	li	s2,0
  iunlockput(ip);
    800056fe:	8556                	mv	a0,s5
    80005700:	fffff097          	auipc	ra,0xfffff
    80005704:	bfe080e7          	jalr	-1026(ra) # 800042fe <iunlockput>
  end_op();
    80005708:	fffff097          	auipc	ra,0xfffff
    8000570c:	3de080e7          	jalr	990(ra) # 80004ae6 <end_op>
  p = myproc();
    80005710:	ffffc097          	auipc	ra,0xffffc
    80005714:	420080e7          	jalr	1056(ra) # 80001b30 <myproc>
    80005718:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000571a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000571e:	6785                	lui	a5,0x1
    80005720:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005722:	97ca                	add	a5,a5,s2
    80005724:	777d                	lui	a4,0xfffff
    80005726:	8ff9                	and	a5,a5,a4
    80005728:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000572c:	4691                	li	a3,4
    8000572e:	6609                	lui	a2,0x2
    80005730:	963e                	add	a2,a2,a5
    80005732:	85be                	mv	a1,a5
    80005734:	855a                	mv	a0,s6
    80005736:	ffffc097          	auipc	ra,0xffffc
    8000573a:	e1a080e7          	jalr	-486(ra) # 80001550 <uvmalloc>
    8000573e:	8c2a                	mv	s8,a0
  ip = 0;
    80005740:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005742:	12050e63          	beqz	a0,8000587e <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005746:	75f9                	lui	a1,0xffffe
    80005748:	95aa                	add	a1,a1,a0
    8000574a:	855a                	mv	a0,s6
    8000574c:	ffffc097          	auipc	ra,0xffffc
    80005750:	01a080e7          	jalr	26(ra) # 80001766 <uvmclear>
  stackbase = sp - PGSIZE;
    80005754:	7afd                	lui	s5,0xfffff
    80005756:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005758:	df043783          	ld	a5,-528(s0)
    8000575c:	6388                	ld	a0,0(a5)
    8000575e:	c925                	beqz	a0,800057ce <exec+0x224>
    80005760:	e9040993          	addi	s3,s0,-368
    80005764:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005768:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000576a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000576c:	ffffc097          	auipc	ra,0xffffc
    80005770:	822080e7          	jalr	-2014(ra) # 80000f8e <strlen>
    80005774:	0015079b          	addiw	a5,a0,1
    80005778:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000577c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005780:	13596663          	bltu	s2,s5,800058ac <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005784:	df043d83          	ld	s11,-528(s0)
    80005788:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000578c:	8552                	mv	a0,s4
    8000578e:	ffffc097          	auipc	ra,0xffffc
    80005792:	800080e7          	jalr	-2048(ra) # 80000f8e <strlen>
    80005796:	0015069b          	addiw	a3,a0,1
    8000579a:	8652                	mv	a2,s4
    8000579c:	85ca                	mv	a1,s2
    8000579e:	855a                	mv	a0,s6
    800057a0:	ffffc097          	auipc	ra,0xffffc
    800057a4:	ff8080e7          	jalr	-8(ra) # 80001798 <copyout>
    800057a8:	10054663          	bltz	a0,800058b4 <exec+0x30a>
    ustack[argc] = sp;
    800057ac:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800057b0:	0485                	addi	s1,s1,1
    800057b2:	008d8793          	addi	a5,s11,8
    800057b6:	def43823          	sd	a5,-528(s0)
    800057ba:	008db503          	ld	a0,8(s11)
    800057be:	c911                	beqz	a0,800057d2 <exec+0x228>
    if(argc >= MAXARG)
    800057c0:	09a1                	addi	s3,s3,8
    800057c2:	fb3c95e3          	bne	s9,s3,8000576c <exec+0x1c2>
  sz = sz1;
    800057c6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800057ca:	4a81                	li	s5,0
    800057cc:	a84d                	j	8000587e <exec+0x2d4>
  sp = sz;
    800057ce:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800057d0:	4481                	li	s1,0
  ustack[argc] = 0;
    800057d2:	00349793          	slli	a5,s1,0x3
    800057d6:	f9078793          	addi	a5,a5,-112
    800057da:	97a2                	add	a5,a5,s0
    800057dc:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800057e0:	00148693          	addi	a3,s1,1
    800057e4:	068e                	slli	a3,a3,0x3
    800057e6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800057ea:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800057ee:	01597663          	bgeu	s2,s5,800057fa <exec+0x250>
  sz = sz1;
    800057f2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800057f6:	4a81                	li	s5,0
    800057f8:	a059                	j	8000587e <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800057fa:	e9040613          	addi	a2,s0,-368
    800057fe:	85ca                	mv	a1,s2
    80005800:	855a                	mv	a0,s6
    80005802:	ffffc097          	auipc	ra,0xffffc
    80005806:	f96080e7          	jalr	-106(ra) # 80001798 <copyout>
    8000580a:	0a054963          	bltz	a0,800058bc <exec+0x312>
  p->trapframe->a1 = sp;
    8000580e:	058bb783          	ld	a5,88(s7)
    80005812:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005816:	de843783          	ld	a5,-536(s0)
    8000581a:	0007c703          	lbu	a4,0(a5)
    8000581e:	cf11                	beqz	a4,8000583a <exec+0x290>
    80005820:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005822:	02f00693          	li	a3,47
    80005826:	a039                	j	80005834 <exec+0x28a>
      last = s+1;
    80005828:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000582c:	0785                	addi	a5,a5,1
    8000582e:	fff7c703          	lbu	a4,-1(a5)
    80005832:	c701                	beqz	a4,8000583a <exec+0x290>
    if(*s == '/')
    80005834:	fed71ce3          	bne	a4,a3,8000582c <exec+0x282>
    80005838:	bfc5                	j	80005828 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    8000583a:	4641                	li	a2,16
    8000583c:	de843583          	ld	a1,-536(s0)
    80005840:	158b8513          	addi	a0,s7,344
    80005844:	ffffb097          	auipc	ra,0xffffb
    80005848:	718080e7          	jalr	1816(ra) # 80000f5c <safestrcpy>
  oldpagetable = p->pagetable;
    8000584c:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005850:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005854:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005858:	058bb783          	ld	a5,88(s7)
    8000585c:	e6843703          	ld	a4,-408(s0)
    80005860:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005862:	058bb783          	ld	a5,88(s7)
    80005866:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000586a:	85ea                	mv	a1,s10
    8000586c:	ffffc097          	auipc	ra,0xffffc
    80005870:	4c6080e7          	jalr	1222(ra) # 80001d32 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005874:	0004851b          	sext.w	a0,s1
    80005878:	b3f9                	j	80005646 <exec+0x9c>
    8000587a:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000587e:	df843583          	ld	a1,-520(s0)
    80005882:	855a                	mv	a0,s6
    80005884:	ffffc097          	auipc	ra,0xffffc
    80005888:	4ae080e7          	jalr	1198(ra) # 80001d32 <proc_freepagetable>
  if(ip){
    8000588c:	da0a93e3          	bnez	s5,80005632 <exec+0x88>
  return -1;
    80005890:	557d                	li	a0,-1
    80005892:	bb55                	j	80005646 <exec+0x9c>
    80005894:	df243c23          	sd	s2,-520(s0)
    80005898:	b7dd                	j	8000587e <exec+0x2d4>
    8000589a:	df243c23          	sd	s2,-520(s0)
    8000589e:	b7c5                	j	8000587e <exec+0x2d4>
    800058a0:	df243c23          	sd	s2,-520(s0)
    800058a4:	bfe9                	j	8000587e <exec+0x2d4>
    800058a6:	df243c23          	sd	s2,-520(s0)
    800058aa:	bfd1                	j	8000587e <exec+0x2d4>
  sz = sz1;
    800058ac:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800058b0:	4a81                	li	s5,0
    800058b2:	b7f1                	j	8000587e <exec+0x2d4>
  sz = sz1;
    800058b4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800058b8:	4a81                	li	s5,0
    800058ba:	b7d1                	j	8000587e <exec+0x2d4>
  sz = sz1;
    800058bc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800058c0:	4a81                	li	s5,0
    800058c2:	bf75                	j	8000587e <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800058c4:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800058c8:	e0843783          	ld	a5,-504(s0)
    800058cc:	0017869b          	addiw	a3,a5,1
    800058d0:	e0d43423          	sd	a3,-504(s0)
    800058d4:	e0043783          	ld	a5,-512(s0)
    800058d8:	0387879b          	addiw	a5,a5,56
    800058dc:	e8845703          	lhu	a4,-376(s0)
    800058e0:	e0e6dfe3          	bge	a3,a4,800056fe <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800058e4:	2781                	sext.w	a5,a5
    800058e6:	e0f43023          	sd	a5,-512(s0)
    800058ea:	03800713          	li	a4,56
    800058ee:	86be                	mv	a3,a5
    800058f0:	e1840613          	addi	a2,s0,-488
    800058f4:	4581                	li	a1,0
    800058f6:	8556                	mv	a0,s5
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	a58080e7          	jalr	-1448(ra) # 80004350 <readi>
    80005900:	03800793          	li	a5,56
    80005904:	f6f51be3          	bne	a0,a5,8000587a <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80005908:	e1842783          	lw	a5,-488(s0)
    8000590c:	4705                	li	a4,1
    8000590e:	fae79de3          	bne	a5,a4,800058c8 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005912:	e4043483          	ld	s1,-448(s0)
    80005916:	e3843783          	ld	a5,-456(s0)
    8000591a:	f6f4ede3          	bltu	s1,a5,80005894 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000591e:	e2843783          	ld	a5,-472(s0)
    80005922:	94be                	add	s1,s1,a5
    80005924:	f6f4ebe3          	bltu	s1,a5,8000589a <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80005928:	de043703          	ld	a4,-544(s0)
    8000592c:	8ff9                	and	a5,a5,a4
    8000592e:	fbad                	bnez	a5,800058a0 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005930:	e1c42503          	lw	a0,-484(s0)
    80005934:	00000097          	auipc	ra,0x0
    80005938:	c5c080e7          	jalr	-932(ra) # 80005590 <flags2perm>
    8000593c:	86aa                	mv	a3,a0
    8000593e:	8626                	mv	a2,s1
    80005940:	85ca                	mv	a1,s2
    80005942:	855a                	mv	a0,s6
    80005944:	ffffc097          	auipc	ra,0xffffc
    80005948:	c0c080e7          	jalr	-1012(ra) # 80001550 <uvmalloc>
    8000594c:	dea43c23          	sd	a0,-520(s0)
    80005950:	d939                	beqz	a0,800058a6 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005952:	e2843c03          	ld	s8,-472(s0)
    80005956:	e2042c83          	lw	s9,-480(s0)
    8000595a:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000595e:	f60b83e3          	beqz	s7,800058c4 <exec+0x31a>
    80005962:	89de                	mv	s3,s7
    80005964:	4481                	li	s1,0
    80005966:	bb9d                	j	800056dc <exec+0x132>

0000000080005968 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005968:	7179                	addi	sp,sp,-48
    8000596a:	f406                	sd	ra,40(sp)
    8000596c:	f022                	sd	s0,32(sp)
    8000596e:	ec26                	sd	s1,24(sp)
    80005970:	e84a                	sd	s2,16(sp)
    80005972:	1800                	addi	s0,sp,48
    80005974:	892e                	mv	s2,a1
    80005976:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005978:	fdc40593          	addi	a1,s0,-36
    8000597c:	ffffd097          	auipc	ra,0xffffd
    80005980:	7ae080e7          	jalr	1966(ra) # 8000312a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005984:	fdc42703          	lw	a4,-36(s0)
    80005988:	47bd                	li	a5,15
    8000598a:	02e7eb63          	bltu	a5,a4,800059c0 <argfd+0x58>
    8000598e:	ffffc097          	auipc	ra,0xffffc
    80005992:	1a2080e7          	jalr	418(ra) # 80001b30 <myproc>
    80005996:	fdc42703          	lw	a4,-36(s0)
    8000599a:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7fdbad1a>
    8000599e:	078e                	slli	a5,a5,0x3
    800059a0:	953e                	add	a0,a0,a5
    800059a2:	611c                	ld	a5,0(a0)
    800059a4:	c385                	beqz	a5,800059c4 <argfd+0x5c>
    return -1;
  if(pfd)
    800059a6:	00090463          	beqz	s2,800059ae <argfd+0x46>
    *pfd = fd;
    800059aa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800059ae:	4501                	li	a0,0
  if(pf)
    800059b0:	c091                	beqz	s1,800059b4 <argfd+0x4c>
    *pf = f;
    800059b2:	e09c                	sd	a5,0(s1)
}
    800059b4:	70a2                	ld	ra,40(sp)
    800059b6:	7402                	ld	s0,32(sp)
    800059b8:	64e2                	ld	s1,24(sp)
    800059ba:	6942                	ld	s2,16(sp)
    800059bc:	6145                	addi	sp,sp,48
    800059be:	8082                	ret
    return -1;
    800059c0:	557d                	li	a0,-1
    800059c2:	bfcd                	j	800059b4 <argfd+0x4c>
    800059c4:	557d                	li	a0,-1
    800059c6:	b7fd                	j	800059b4 <argfd+0x4c>

00000000800059c8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800059c8:	1101                	addi	sp,sp,-32
    800059ca:	ec06                	sd	ra,24(sp)
    800059cc:	e822                	sd	s0,16(sp)
    800059ce:	e426                	sd	s1,8(sp)
    800059d0:	1000                	addi	s0,sp,32
    800059d2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800059d4:	ffffc097          	auipc	ra,0xffffc
    800059d8:	15c080e7          	jalr	348(ra) # 80001b30 <myproc>
    800059dc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800059de:	0d050793          	addi	a5,a0,208
    800059e2:	4501                	li	a0,0
    800059e4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800059e6:	6398                	ld	a4,0(a5)
    800059e8:	cb19                	beqz	a4,800059fe <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800059ea:	2505                	addiw	a0,a0,1
    800059ec:	07a1                	addi	a5,a5,8
    800059ee:	fed51ce3          	bne	a0,a3,800059e6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800059f2:	557d                	li	a0,-1
}
    800059f4:	60e2                	ld	ra,24(sp)
    800059f6:	6442                	ld	s0,16(sp)
    800059f8:	64a2                	ld	s1,8(sp)
    800059fa:	6105                	addi	sp,sp,32
    800059fc:	8082                	ret
      p->ofile[fd] = f;
    800059fe:	01a50793          	addi	a5,a0,26
    80005a02:	078e                	slli	a5,a5,0x3
    80005a04:	963e                	add	a2,a2,a5
    80005a06:	e204                	sd	s1,0(a2)
      return fd;
    80005a08:	b7f5                	j	800059f4 <fdalloc+0x2c>

0000000080005a0a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005a0a:	715d                	addi	sp,sp,-80
    80005a0c:	e486                	sd	ra,72(sp)
    80005a0e:	e0a2                	sd	s0,64(sp)
    80005a10:	fc26                	sd	s1,56(sp)
    80005a12:	f84a                	sd	s2,48(sp)
    80005a14:	f44e                	sd	s3,40(sp)
    80005a16:	f052                	sd	s4,32(sp)
    80005a18:	ec56                	sd	s5,24(sp)
    80005a1a:	e85a                	sd	s6,16(sp)
    80005a1c:	0880                	addi	s0,sp,80
    80005a1e:	8b2e                	mv	s6,a1
    80005a20:	89b2                	mv	s3,a2
    80005a22:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005a24:	fb040593          	addi	a1,s0,-80
    80005a28:	fffff097          	auipc	ra,0xfffff
    80005a2c:	e3e080e7          	jalr	-450(ra) # 80004866 <nameiparent>
    80005a30:	84aa                	mv	s1,a0
    80005a32:	14050f63          	beqz	a0,80005b90 <create+0x186>
    return 0;

  ilock(dp);
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	666080e7          	jalr	1638(ra) # 8000409c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005a3e:	4601                	li	a2,0
    80005a40:	fb040593          	addi	a1,s0,-80
    80005a44:	8526                	mv	a0,s1
    80005a46:	fffff097          	auipc	ra,0xfffff
    80005a4a:	b3a080e7          	jalr	-1222(ra) # 80004580 <dirlookup>
    80005a4e:	8aaa                	mv	s5,a0
    80005a50:	c931                	beqz	a0,80005aa4 <create+0x9a>
    iunlockput(dp);
    80005a52:	8526                	mv	a0,s1
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	8aa080e7          	jalr	-1878(ra) # 800042fe <iunlockput>
    ilock(ip);
    80005a5c:	8556                	mv	a0,s5
    80005a5e:	ffffe097          	auipc	ra,0xffffe
    80005a62:	63e080e7          	jalr	1598(ra) # 8000409c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005a66:	000b059b          	sext.w	a1,s6
    80005a6a:	4789                	li	a5,2
    80005a6c:	02f59563          	bne	a1,a5,80005a96 <create+0x8c>
    80005a70:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7fdbad44>
    80005a74:	37f9                	addiw	a5,a5,-2
    80005a76:	17c2                	slli	a5,a5,0x30
    80005a78:	93c1                	srli	a5,a5,0x30
    80005a7a:	4705                	li	a4,1
    80005a7c:	00f76d63          	bltu	a4,a5,80005a96 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005a80:	8556                	mv	a0,s5
    80005a82:	60a6                	ld	ra,72(sp)
    80005a84:	6406                	ld	s0,64(sp)
    80005a86:	74e2                	ld	s1,56(sp)
    80005a88:	7942                	ld	s2,48(sp)
    80005a8a:	79a2                	ld	s3,40(sp)
    80005a8c:	7a02                	ld	s4,32(sp)
    80005a8e:	6ae2                	ld	s5,24(sp)
    80005a90:	6b42                	ld	s6,16(sp)
    80005a92:	6161                	addi	sp,sp,80
    80005a94:	8082                	ret
    iunlockput(ip);
    80005a96:	8556                	mv	a0,s5
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	866080e7          	jalr	-1946(ra) # 800042fe <iunlockput>
    return 0;
    80005aa0:	4a81                	li	s5,0
    80005aa2:	bff9                	j	80005a80 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005aa4:	85da                	mv	a1,s6
    80005aa6:	4088                	lw	a0,0(s1)
    80005aa8:	ffffe097          	auipc	ra,0xffffe
    80005aac:	456080e7          	jalr	1110(ra) # 80003efe <ialloc>
    80005ab0:	8a2a                	mv	s4,a0
    80005ab2:	c539                	beqz	a0,80005b00 <create+0xf6>
  ilock(ip);
    80005ab4:	ffffe097          	auipc	ra,0xffffe
    80005ab8:	5e8080e7          	jalr	1512(ra) # 8000409c <ilock>
  ip->major = major;
    80005abc:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005ac0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005ac4:	4905                	li	s2,1
    80005ac6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005aca:	8552                	mv	a0,s4
    80005acc:	ffffe097          	auipc	ra,0xffffe
    80005ad0:	504080e7          	jalr	1284(ra) # 80003fd0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005ad4:	000b059b          	sext.w	a1,s6
    80005ad8:	03258b63          	beq	a1,s2,80005b0e <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005adc:	004a2603          	lw	a2,4(s4)
    80005ae0:	fb040593          	addi	a1,s0,-80
    80005ae4:	8526                	mv	a0,s1
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	cb0080e7          	jalr	-848(ra) # 80004796 <dirlink>
    80005aee:	06054f63          	bltz	a0,80005b6c <create+0x162>
  iunlockput(dp);
    80005af2:	8526                	mv	a0,s1
    80005af4:	fffff097          	auipc	ra,0xfffff
    80005af8:	80a080e7          	jalr	-2038(ra) # 800042fe <iunlockput>
  return ip;
    80005afc:	8ad2                	mv	s5,s4
    80005afe:	b749                	j	80005a80 <create+0x76>
    iunlockput(dp);
    80005b00:	8526                	mv	a0,s1
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	7fc080e7          	jalr	2044(ra) # 800042fe <iunlockput>
    return 0;
    80005b0a:	8ad2                	mv	s5,s4
    80005b0c:	bf95                	j	80005a80 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005b0e:	004a2603          	lw	a2,4(s4)
    80005b12:	00003597          	auipc	a1,0x3
    80005b16:	ebe58593          	addi	a1,a1,-322 # 800089d0 <syscallnames+0x2f8>
    80005b1a:	8552                	mv	a0,s4
    80005b1c:	fffff097          	auipc	ra,0xfffff
    80005b20:	c7a080e7          	jalr	-902(ra) # 80004796 <dirlink>
    80005b24:	04054463          	bltz	a0,80005b6c <create+0x162>
    80005b28:	40d0                	lw	a2,4(s1)
    80005b2a:	00003597          	auipc	a1,0x3
    80005b2e:	eae58593          	addi	a1,a1,-338 # 800089d8 <syscallnames+0x300>
    80005b32:	8552                	mv	a0,s4
    80005b34:	fffff097          	auipc	ra,0xfffff
    80005b38:	c62080e7          	jalr	-926(ra) # 80004796 <dirlink>
    80005b3c:	02054863          	bltz	a0,80005b6c <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005b40:	004a2603          	lw	a2,4(s4)
    80005b44:	fb040593          	addi	a1,s0,-80
    80005b48:	8526                	mv	a0,s1
    80005b4a:	fffff097          	auipc	ra,0xfffff
    80005b4e:	c4c080e7          	jalr	-948(ra) # 80004796 <dirlink>
    80005b52:	00054d63          	bltz	a0,80005b6c <create+0x162>
    dp->nlink++;  // for ".."
    80005b56:	04a4d783          	lhu	a5,74(s1)
    80005b5a:	2785                	addiw	a5,a5,1
    80005b5c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b60:	8526                	mv	a0,s1
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	46e080e7          	jalr	1134(ra) # 80003fd0 <iupdate>
    80005b6a:	b761                	j	80005af2 <create+0xe8>
  ip->nlink = 0;
    80005b6c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005b70:	8552                	mv	a0,s4
    80005b72:	ffffe097          	auipc	ra,0xffffe
    80005b76:	45e080e7          	jalr	1118(ra) # 80003fd0 <iupdate>
  iunlockput(ip);
    80005b7a:	8552                	mv	a0,s4
    80005b7c:	ffffe097          	auipc	ra,0xffffe
    80005b80:	782080e7          	jalr	1922(ra) # 800042fe <iunlockput>
  iunlockput(dp);
    80005b84:	8526                	mv	a0,s1
    80005b86:	ffffe097          	auipc	ra,0xffffe
    80005b8a:	778080e7          	jalr	1912(ra) # 800042fe <iunlockput>
  return 0;
    80005b8e:	bdcd                	j	80005a80 <create+0x76>
    return 0;
    80005b90:	8aaa                	mv	s5,a0
    80005b92:	b5fd                	j	80005a80 <create+0x76>

0000000080005b94 <sys_dup>:
{
    80005b94:	7179                	addi	sp,sp,-48
    80005b96:	f406                	sd	ra,40(sp)
    80005b98:	f022                	sd	s0,32(sp)
    80005b9a:	ec26                	sd	s1,24(sp)
    80005b9c:	e84a                	sd	s2,16(sp)
    80005b9e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005ba0:	fd840613          	addi	a2,s0,-40
    80005ba4:	4581                	li	a1,0
    80005ba6:	4501                	li	a0,0
    80005ba8:	00000097          	auipc	ra,0x0
    80005bac:	dc0080e7          	jalr	-576(ra) # 80005968 <argfd>
    return -1;
    80005bb0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005bb2:	02054363          	bltz	a0,80005bd8 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005bb6:	fd843903          	ld	s2,-40(s0)
    80005bba:	854a                	mv	a0,s2
    80005bbc:	00000097          	auipc	ra,0x0
    80005bc0:	e0c080e7          	jalr	-500(ra) # 800059c8 <fdalloc>
    80005bc4:	84aa                	mv	s1,a0
    return -1;
    80005bc6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005bc8:	00054863          	bltz	a0,80005bd8 <sys_dup+0x44>
  filedup(f);
    80005bcc:	854a                	mv	a0,s2
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	310080e7          	jalr	784(ra) # 80004ede <filedup>
  return fd;
    80005bd6:	87a6                	mv	a5,s1
}
    80005bd8:	853e                	mv	a0,a5
    80005bda:	70a2                	ld	ra,40(sp)
    80005bdc:	7402                	ld	s0,32(sp)
    80005bde:	64e2                	ld	s1,24(sp)
    80005be0:	6942                	ld	s2,16(sp)
    80005be2:	6145                	addi	sp,sp,48
    80005be4:	8082                	ret

0000000080005be6 <sys_read>:
{
    80005be6:	7179                	addi	sp,sp,-48
    80005be8:	f406                	sd	ra,40(sp)
    80005bea:	f022                	sd	s0,32(sp)
    80005bec:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005bee:	fd840593          	addi	a1,s0,-40
    80005bf2:	4505                	li	a0,1
    80005bf4:	ffffd097          	auipc	ra,0xffffd
    80005bf8:	556080e7          	jalr	1366(ra) # 8000314a <argaddr>
  argint(2, &n);
    80005bfc:	fe440593          	addi	a1,s0,-28
    80005c00:	4509                	li	a0,2
    80005c02:	ffffd097          	auipc	ra,0xffffd
    80005c06:	528080e7          	jalr	1320(ra) # 8000312a <argint>
  count++;
    80005c0a:	00003717          	auipc	a4,0x3
    80005c0e:	02e70713          	addi	a4,a4,46 # 80008c38 <count>
    80005c12:	431c                	lw	a5,0(a4)
    80005c14:	2785                	addiw	a5,a5,1
    80005c16:	c31c                	sw	a5,0(a4)
  if(argfd(0, 0, &f) < 0)
    80005c18:	fe840613          	addi	a2,s0,-24
    80005c1c:	4581                	li	a1,0
    80005c1e:	4501                	li	a0,0
    80005c20:	00000097          	auipc	ra,0x0
    80005c24:	d48080e7          	jalr	-696(ra) # 80005968 <argfd>
    80005c28:	87aa                	mv	a5,a0
    return -1;
    80005c2a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c2c:	0007cc63          	bltz	a5,80005c44 <sys_read+0x5e>
  return fileread(f, p, n);
    80005c30:	fe442603          	lw	a2,-28(s0)
    80005c34:	fd843583          	ld	a1,-40(s0)
    80005c38:	fe843503          	ld	a0,-24(s0)
    80005c3c:	fffff097          	auipc	ra,0xfffff
    80005c40:	42e080e7          	jalr	1070(ra) # 8000506a <fileread>
}
    80005c44:	70a2                	ld	ra,40(sp)
    80005c46:	7402                	ld	s0,32(sp)
    80005c48:	6145                	addi	sp,sp,48
    80005c4a:	8082                	ret

0000000080005c4c <sys_write>:
{
    80005c4c:	7179                	addi	sp,sp,-48
    80005c4e:	f406                	sd	ra,40(sp)
    80005c50:	f022                	sd	s0,32(sp)
    80005c52:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005c54:	fd840593          	addi	a1,s0,-40
    80005c58:	4505                	li	a0,1
    80005c5a:	ffffd097          	auipc	ra,0xffffd
    80005c5e:	4f0080e7          	jalr	1264(ra) # 8000314a <argaddr>
  argint(2, &n);
    80005c62:	fe440593          	addi	a1,s0,-28
    80005c66:	4509                	li	a0,2
    80005c68:	ffffd097          	auipc	ra,0xffffd
    80005c6c:	4c2080e7          	jalr	1218(ra) # 8000312a <argint>
  if(argfd(0, 0, &f) < 0)
    80005c70:	fe840613          	addi	a2,s0,-24
    80005c74:	4581                	li	a1,0
    80005c76:	4501                	li	a0,0
    80005c78:	00000097          	auipc	ra,0x0
    80005c7c:	cf0080e7          	jalr	-784(ra) # 80005968 <argfd>
    80005c80:	87aa                	mv	a5,a0
    return -1;
    80005c82:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c84:	0007cc63          	bltz	a5,80005c9c <sys_write+0x50>
  return filewrite(f, p, n);
    80005c88:	fe442603          	lw	a2,-28(s0)
    80005c8c:	fd843583          	ld	a1,-40(s0)
    80005c90:	fe843503          	ld	a0,-24(s0)
    80005c94:	fffff097          	auipc	ra,0xfffff
    80005c98:	498080e7          	jalr	1176(ra) # 8000512c <filewrite>
}
    80005c9c:	70a2                	ld	ra,40(sp)
    80005c9e:	7402                	ld	s0,32(sp)
    80005ca0:	6145                	addi	sp,sp,48
    80005ca2:	8082                	ret

0000000080005ca4 <sys_close>:
{
    80005ca4:	1101                	addi	sp,sp,-32
    80005ca6:	ec06                	sd	ra,24(sp)
    80005ca8:	e822                	sd	s0,16(sp)
    80005caa:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005cac:	fe040613          	addi	a2,s0,-32
    80005cb0:	fec40593          	addi	a1,s0,-20
    80005cb4:	4501                	li	a0,0
    80005cb6:	00000097          	auipc	ra,0x0
    80005cba:	cb2080e7          	jalr	-846(ra) # 80005968 <argfd>
    return -1;
    80005cbe:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005cc0:	02054463          	bltz	a0,80005ce8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005cc4:	ffffc097          	auipc	ra,0xffffc
    80005cc8:	e6c080e7          	jalr	-404(ra) # 80001b30 <myproc>
    80005ccc:	fec42783          	lw	a5,-20(s0)
    80005cd0:	07e9                	addi	a5,a5,26
    80005cd2:	078e                	slli	a5,a5,0x3
    80005cd4:	953e                	add	a0,a0,a5
    80005cd6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005cda:	fe043503          	ld	a0,-32(s0)
    80005cde:	fffff097          	auipc	ra,0xfffff
    80005ce2:	252080e7          	jalr	594(ra) # 80004f30 <fileclose>
  return 0;
    80005ce6:	4781                	li	a5,0
}
    80005ce8:	853e                	mv	a0,a5
    80005cea:	60e2                	ld	ra,24(sp)
    80005cec:	6442                	ld	s0,16(sp)
    80005cee:	6105                	addi	sp,sp,32
    80005cf0:	8082                	ret

0000000080005cf2 <sys_fstat>:
{
    80005cf2:	1101                	addi	sp,sp,-32
    80005cf4:	ec06                	sd	ra,24(sp)
    80005cf6:	e822                	sd	s0,16(sp)
    80005cf8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005cfa:	fe040593          	addi	a1,s0,-32
    80005cfe:	4505                	li	a0,1
    80005d00:	ffffd097          	auipc	ra,0xffffd
    80005d04:	44a080e7          	jalr	1098(ra) # 8000314a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005d08:	fe840613          	addi	a2,s0,-24
    80005d0c:	4581                	li	a1,0
    80005d0e:	4501                	li	a0,0
    80005d10:	00000097          	auipc	ra,0x0
    80005d14:	c58080e7          	jalr	-936(ra) # 80005968 <argfd>
    80005d18:	87aa                	mv	a5,a0
    return -1;
    80005d1a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d1c:	0007ca63          	bltz	a5,80005d30 <sys_fstat+0x3e>
  return filestat(f, st);
    80005d20:	fe043583          	ld	a1,-32(s0)
    80005d24:	fe843503          	ld	a0,-24(s0)
    80005d28:	fffff097          	auipc	ra,0xfffff
    80005d2c:	2d0080e7          	jalr	720(ra) # 80004ff8 <filestat>
}
    80005d30:	60e2                	ld	ra,24(sp)
    80005d32:	6442                	ld	s0,16(sp)
    80005d34:	6105                	addi	sp,sp,32
    80005d36:	8082                	ret

0000000080005d38 <sys_link>:
{
    80005d38:	7169                	addi	sp,sp,-304
    80005d3a:	f606                	sd	ra,296(sp)
    80005d3c:	f222                	sd	s0,288(sp)
    80005d3e:	ee26                	sd	s1,280(sp)
    80005d40:	ea4a                	sd	s2,272(sp)
    80005d42:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d44:	08000613          	li	a2,128
    80005d48:	ed040593          	addi	a1,s0,-304
    80005d4c:	4501                	li	a0,0
    80005d4e:	ffffd097          	auipc	ra,0xffffd
    80005d52:	41c080e7          	jalr	1052(ra) # 8000316a <argstr>
    return -1;
    80005d56:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d58:	10054e63          	bltz	a0,80005e74 <sys_link+0x13c>
    80005d5c:	08000613          	li	a2,128
    80005d60:	f5040593          	addi	a1,s0,-176
    80005d64:	4505                	li	a0,1
    80005d66:	ffffd097          	auipc	ra,0xffffd
    80005d6a:	404080e7          	jalr	1028(ra) # 8000316a <argstr>
    return -1;
    80005d6e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d70:	10054263          	bltz	a0,80005e74 <sys_link+0x13c>
  begin_op();
    80005d74:	fffff097          	auipc	ra,0xfffff
    80005d78:	cf4080e7          	jalr	-780(ra) # 80004a68 <begin_op>
  if((ip = namei(old)) == 0){
    80005d7c:	ed040513          	addi	a0,s0,-304
    80005d80:	fffff097          	auipc	ra,0xfffff
    80005d84:	ac8080e7          	jalr	-1336(ra) # 80004848 <namei>
    80005d88:	84aa                	mv	s1,a0
    80005d8a:	c551                	beqz	a0,80005e16 <sys_link+0xde>
  ilock(ip);
    80005d8c:	ffffe097          	auipc	ra,0xffffe
    80005d90:	310080e7          	jalr	784(ra) # 8000409c <ilock>
  if(ip->type == T_DIR){
    80005d94:	04449703          	lh	a4,68(s1)
    80005d98:	4785                	li	a5,1
    80005d9a:	08f70463          	beq	a4,a5,80005e22 <sys_link+0xea>
  ip->nlink++;
    80005d9e:	04a4d783          	lhu	a5,74(s1)
    80005da2:	2785                	addiw	a5,a5,1
    80005da4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005da8:	8526                	mv	a0,s1
    80005daa:	ffffe097          	auipc	ra,0xffffe
    80005dae:	226080e7          	jalr	550(ra) # 80003fd0 <iupdate>
  iunlock(ip);
    80005db2:	8526                	mv	a0,s1
    80005db4:	ffffe097          	auipc	ra,0xffffe
    80005db8:	3aa080e7          	jalr	938(ra) # 8000415e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005dbc:	fd040593          	addi	a1,s0,-48
    80005dc0:	f5040513          	addi	a0,s0,-176
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	aa2080e7          	jalr	-1374(ra) # 80004866 <nameiparent>
    80005dcc:	892a                	mv	s2,a0
    80005dce:	c935                	beqz	a0,80005e42 <sys_link+0x10a>
  ilock(dp);
    80005dd0:	ffffe097          	auipc	ra,0xffffe
    80005dd4:	2cc080e7          	jalr	716(ra) # 8000409c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005dd8:	00092703          	lw	a4,0(s2)
    80005ddc:	409c                	lw	a5,0(s1)
    80005dde:	04f71d63          	bne	a4,a5,80005e38 <sys_link+0x100>
    80005de2:	40d0                	lw	a2,4(s1)
    80005de4:	fd040593          	addi	a1,s0,-48
    80005de8:	854a                	mv	a0,s2
    80005dea:	fffff097          	auipc	ra,0xfffff
    80005dee:	9ac080e7          	jalr	-1620(ra) # 80004796 <dirlink>
    80005df2:	04054363          	bltz	a0,80005e38 <sys_link+0x100>
  iunlockput(dp);
    80005df6:	854a                	mv	a0,s2
    80005df8:	ffffe097          	auipc	ra,0xffffe
    80005dfc:	506080e7          	jalr	1286(ra) # 800042fe <iunlockput>
  iput(ip);
    80005e00:	8526                	mv	a0,s1
    80005e02:	ffffe097          	auipc	ra,0xffffe
    80005e06:	454080e7          	jalr	1108(ra) # 80004256 <iput>
  end_op();
    80005e0a:	fffff097          	auipc	ra,0xfffff
    80005e0e:	cdc080e7          	jalr	-804(ra) # 80004ae6 <end_op>
  return 0;
    80005e12:	4781                	li	a5,0
    80005e14:	a085                	j	80005e74 <sys_link+0x13c>
    end_op();
    80005e16:	fffff097          	auipc	ra,0xfffff
    80005e1a:	cd0080e7          	jalr	-816(ra) # 80004ae6 <end_op>
    return -1;
    80005e1e:	57fd                	li	a5,-1
    80005e20:	a891                	j	80005e74 <sys_link+0x13c>
    iunlockput(ip);
    80005e22:	8526                	mv	a0,s1
    80005e24:	ffffe097          	auipc	ra,0xffffe
    80005e28:	4da080e7          	jalr	1242(ra) # 800042fe <iunlockput>
    end_op();
    80005e2c:	fffff097          	auipc	ra,0xfffff
    80005e30:	cba080e7          	jalr	-838(ra) # 80004ae6 <end_op>
    return -1;
    80005e34:	57fd                	li	a5,-1
    80005e36:	a83d                	j	80005e74 <sys_link+0x13c>
    iunlockput(dp);
    80005e38:	854a                	mv	a0,s2
    80005e3a:	ffffe097          	auipc	ra,0xffffe
    80005e3e:	4c4080e7          	jalr	1220(ra) # 800042fe <iunlockput>
  ilock(ip);
    80005e42:	8526                	mv	a0,s1
    80005e44:	ffffe097          	auipc	ra,0xffffe
    80005e48:	258080e7          	jalr	600(ra) # 8000409c <ilock>
  ip->nlink--;
    80005e4c:	04a4d783          	lhu	a5,74(s1)
    80005e50:	37fd                	addiw	a5,a5,-1
    80005e52:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005e56:	8526                	mv	a0,s1
    80005e58:	ffffe097          	auipc	ra,0xffffe
    80005e5c:	178080e7          	jalr	376(ra) # 80003fd0 <iupdate>
  iunlockput(ip);
    80005e60:	8526                	mv	a0,s1
    80005e62:	ffffe097          	auipc	ra,0xffffe
    80005e66:	49c080e7          	jalr	1180(ra) # 800042fe <iunlockput>
  end_op();
    80005e6a:	fffff097          	auipc	ra,0xfffff
    80005e6e:	c7c080e7          	jalr	-900(ra) # 80004ae6 <end_op>
  return -1;
    80005e72:	57fd                	li	a5,-1
}
    80005e74:	853e                	mv	a0,a5
    80005e76:	70b2                	ld	ra,296(sp)
    80005e78:	7412                	ld	s0,288(sp)
    80005e7a:	64f2                	ld	s1,280(sp)
    80005e7c:	6952                	ld	s2,272(sp)
    80005e7e:	6155                	addi	sp,sp,304
    80005e80:	8082                	ret

0000000080005e82 <sys_unlink>:
{
    80005e82:	7151                	addi	sp,sp,-240
    80005e84:	f586                	sd	ra,232(sp)
    80005e86:	f1a2                	sd	s0,224(sp)
    80005e88:	eda6                	sd	s1,216(sp)
    80005e8a:	e9ca                	sd	s2,208(sp)
    80005e8c:	e5ce                	sd	s3,200(sp)
    80005e8e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005e90:	08000613          	li	a2,128
    80005e94:	f3040593          	addi	a1,s0,-208
    80005e98:	4501                	li	a0,0
    80005e9a:	ffffd097          	auipc	ra,0xffffd
    80005e9e:	2d0080e7          	jalr	720(ra) # 8000316a <argstr>
    80005ea2:	18054163          	bltz	a0,80006024 <sys_unlink+0x1a2>
  begin_op();
    80005ea6:	fffff097          	auipc	ra,0xfffff
    80005eaa:	bc2080e7          	jalr	-1086(ra) # 80004a68 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005eae:	fb040593          	addi	a1,s0,-80
    80005eb2:	f3040513          	addi	a0,s0,-208
    80005eb6:	fffff097          	auipc	ra,0xfffff
    80005eba:	9b0080e7          	jalr	-1616(ra) # 80004866 <nameiparent>
    80005ebe:	84aa                	mv	s1,a0
    80005ec0:	c979                	beqz	a0,80005f96 <sys_unlink+0x114>
  ilock(dp);
    80005ec2:	ffffe097          	auipc	ra,0xffffe
    80005ec6:	1da080e7          	jalr	474(ra) # 8000409c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005eca:	00003597          	auipc	a1,0x3
    80005ece:	b0658593          	addi	a1,a1,-1274 # 800089d0 <syscallnames+0x2f8>
    80005ed2:	fb040513          	addi	a0,s0,-80
    80005ed6:	ffffe097          	auipc	ra,0xffffe
    80005eda:	690080e7          	jalr	1680(ra) # 80004566 <namecmp>
    80005ede:	14050a63          	beqz	a0,80006032 <sys_unlink+0x1b0>
    80005ee2:	00003597          	auipc	a1,0x3
    80005ee6:	af658593          	addi	a1,a1,-1290 # 800089d8 <syscallnames+0x300>
    80005eea:	fb040513          	addi	a0,s0,-80
    80005eee:	ffffe097          	auipc	ra,0xffffe
    80005ef2:	678080e7          	jalr	1656(ra) # 80004566 <namecmp>
    80005ef6:	12050e63          	beqz	a0,80006032 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005efa:	f2c40613          	addi	a2,s0,-212
    80005efe:	fb040593          	addi	a1,s0,-80
    80005f02:	8526                	mv	a0,s1
    80005f04:	ffffe097          	auipc	ra,0xffffe
    80005f08:	67c080e7          	jalr	1660(ra) # 80004580 <dirlookup>
    80005f0c:	892a                	mv	s2,a0
    80005f0e:	12050263          	beqz	a0,80006032 <sys_unlink+0x1b0>
  ilock(ip);
    80005f12:	ffffe097          	auipc	ra,0xffffe
    80005f16:	18a080e7          	jalr	394(ra) # 8000409c <ilock>
  if(ip->nlink < 1)
    80005f1a:	04a91783          	lh	a5,74(s2)
    80005f1e:	08f05263          	blez	a5,80005fa2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005f22:	04491703          	lh	a4,68(s2)
    80005f26:	4785                	li	a5,1
    80005f28:	08f70563          	beq	a4,a5,80005fb2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005f2c:	4641                	li	a2,16
    80005f2e:	4581                	li	a1,0
    80005f30:	fc040513          	addi	a0,s0,-64
    80005f34:	ffffb097          	auipc	ra,0xffffb
    80005f38:	ede080e7          	jalr	-290(ra) # 80000e12 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f3c:	4741                	li	a4,16
    80005f3e:	f2c42683          	lw	a3,-212(s0)
    80005f42:	fc040613          	addi	a2,s0,-64
    80005f46:	4581                	li	a1,0
    80005f48:	8526                	mv	a0,s1
    80005f4a:	ffffe097          	auipc	ra,0xffffe
    80005f4e:	4fe080e7          	jalr	1278(ra) # 80004448 <writei>
    80005f52:	47c1                	li	a5,16
    80005f54:	0af51563          	bne	a0,a5,80005ffe <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005f58:	04491703          	lh	a4,68(s2)
    80005f5c:	4785                	li	a5,1
    80005f5e:	0af70863          	beq	a4,a5,8000600e <sys_unlink+0x18c>
  iunlockput(dp);
    80005f62:	8526                	mv	a0,s1
    80005f64:	ffffe097          	auipc	ra,0xffffe
    80005f68:	39a080e7          	jalr	922(ra) # 800042fe <iunlockput>
  ip->nlink--;
    80005f6c:	04a95783          	lhu	a5,74(s2)
    80005f70:	37fd                	addiw	a5,a5,-1
    80005f72:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005f76:	854a                	mv	a0,s2
    80005f78:	ffffe097          	auipc	ra,0xffffe
    80005f7c:	058080e7          	jalr	88(ra) # 80003fd0 <iupdate>
  iunlockput(ip);
    80005f80:	854a                	mv	a0,s2
    80005f82:	ffffe097          	auipc	ra,0xffffe
    80005f86:	37c080e7          	jalr	892(ra) # 800042fe <iunlockput>
  end_op();
    80005f8a:	fffff097          	auipc	ra,0xfffff
    80005f8e:	b5c080e7          	jalr	-1188(ra) # 80004ae6 <end_op>
  return 0;
    80005f92:	4501                	li	a0,0
    80005f94:	a84d                	j	80006046 <sys_unlink+0x1c4>
    end_op();
    80005f96:	fffff097          	auipc	ra,0xfffff
    80005f9a:	b50080e7          	jalr	-1200(ra) # 80004ae6 <end_op>
    return -1;
    80005f9e:	557d                	li	a0,-1
    80005fa0:	a05d                	j	80006046 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005fa2:	00003517          	auipc	a0,0x3
    80005fa6:	a3e50513          	addi	a0,a0,-1474 # 800089e0 <syscallnames+0x308>
    80005faa:	ffffa097          	auipc	ra,0xffffa
    80005fae:	596080e7          	jalr	1430(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005fb2:	04c92703          	lw	a4,76(s2)
    80005fb6:	02000793          	li	a5,32
    80005fba:	f6e7f9e3          	bgeu	a5,a4,80005f2c <sys_unlink+0xaa>
    80005fbe:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005fc2:	4741                	li	a4,16
    80005fc4:	86ce                	mv	a3,s3
    80005fc6:	f1840613          	addi	a2,s0,-232
    80005fca:	4581                	li	a1,0
    80005fcc:	854a                	mv	a0,s2
    80005fce:	ffffe097          	auipc	ra,0xffffe
    80005fd2:	382080e7          	jalr	898(ra) # 80004350 <readi>
    80005fd6:	47c1                	li	a5,16
    80005fd8:	00f51b63          	bne	a0,a5,80005fee <sys_unlink+0x16c>
    if(de.inum != 0)
    80005fdc:	f1845783          	lhu	a5,-232(s0)
    80005fe0:	e7a1                	bnez	a5,80006028 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005fe2:	29c1                	addiw	s3,s3,16
    80005fe4:	04c92783          	lw	a5,76(s2)
    80005fe8:	fcf9ede3          	bltu	s3,a5,80005fc2 <sys_unlink+0x140>
    80005fec:	b781                	j	80005f2c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005fee:	00003517          	auipc	a0,0x3
    80005ff2:	a0a50513          	addi	a0,a0,-1526 # 800089f8 <syscallnames+0x320>
    80005ff6:	ffffa097          	auipc	ra,0xffffa
    80005ffa:	54a080e7          	jalr	1354(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005ffe:	00003517          	auipc	a0,0x3
    80006002:	a1250513          	addi	a0,a0,-1518 # 80008a10 <syscallnames+0x338>
    80006006:	ffffa097          	auipc	ra,0xffffa
    8000600a:	53a080e7          	jalr	1338(ra) # 80000540 <panic>
    dp->nlink--;
    8000600e:	04a4d783          	lhu	a5,74(s1)
    80006012:	37fd                	addiw	a5,a5,-1
    80006014:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006018:	8526                	mv	a0,s1
    8000601a:	ffffe097          	auipc	ra,0xffffe
    8000601e:	fb6080e7          	jalr	-74(ra) # 80003fd0 <iupdate>
    80006022:	b781                	j	80005f62 <sys_unlink+0xe0>
    return -1;
    80006024:	557d                	li	a0,-1
    80006026:	a005                	j	80006046 <sys_unlink+0x1c4>
    iunlockput(ip);
    80006028:	854a                	mv	a0,s2
    8000602a:	ffffe097          	auipc	ra,0xffffe
    8000602e:	2d4080e7          	jalr	724(ra) # 800042fe <iunlockput>
  iunlockput(dp);
    80006032:	8526                	mv	a0,s1
    80006034:	ffffe097          	auipc	ra,0xffffe
    80006038:	2ca080e7          	jalr	714(ra) # 800042fe <iunlockput>
  end_op();
    8000603c:	fffff097          	auipc	ra,0xfffff
    80006040:	aaa080e7          	jalr	-1366(ra) # 80004ae6 <end_op>
  return -1;
    80006044:	557d                	li	a0,-1
}
    80006046:	70ae                	ld	ra,232(sp)
    80006048:	740e                	ld	s0,224(sp)
    8000604a:	64ee                	ld	s1,216(sp)
    8000604c:	694e                	ld	s2,208(sp)
    8000604e:	69ae                	ld	s3,200(sp)
    80006050:	616d                	addi	sp,sp,240
    80006052:	8082                	ret

0000000080006054 <sys_open>:

uint64
sys_open(void)
{
    80006054:	7131                	addi	sp,sp,-192
    80006056:	fd06                	sd	ra,184(sp)
    80006058:	f922                	sd	s0,176(sp)
    8000605a:	f526                	sd	s1,168(sp)
    8000605c:	f14a                	sd	s2,160(sp)
    8000605e:	ed4e                	sd	s3,152(sp)
    80006060:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80006062:	f4c40593          	addi	a1,s0,-180
    80006066:	4505                	li	a0,1
    80006068:	ffffd097          	auipc	ra,0xffffd
    8000606c:	0c2080e7          	jalr	194(ra) # 8000312a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006070:	08000613          	li	a2,128
    80006074:	f5040593          	addi	a1,s0,-176
    80006078:	4501                	li	a0,0
    8000607a:	ffffd097          	auipc	ra,0xffffd
    8000607e:	0f0080e7          	jalr	240(ra) # 8000316a <argstr>
    80006082:	87aa                	mv	a5,a0
    return -1;
    80006084:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006086:	0a07c963          	bltz	a5,80006138 <sys_open+0xe4>

  begin_op();
    8000608a:	fffff097          	auipc	ra,0xfffff
    8000608e:	9de080e7          	jalr	-1570(ra) # 80004a68 <begin_op>

  if(omode & O_CREATE){
    80006092:	f4c42783          	lw	a5,-180(s0)
    80006096:	2007f793          	andi	a5,a5,512
    8000609a:	cfc5                	beqz	a5,80006152 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000609c:	4681                	li	a3,0
    8000609e:	4601                	li	a2,0
    800060a0:	4589                	li	a1,2
    800060a2:	f5040513          	addi	a0,s0,-176
    800060a6:	00000097          	auipc	ra,0x0
    800060aa:	964080e7          	jalr	-1692(ra) # 80005a0a <create>
    800060ae:	84aa                	mv	s1,a0
    if(ip == 0){
    800060b0:	c959                	beqz	a0,80006146 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800060b2:	04449703          	lh	a4,68(s1)
    800060b6:	478d                	li	a5,3
    800060b8:	00f71763          	bne	a4,a5,800060c6 <sys_open+0x72>
    800060bc:	0464d703          	lhu	a4,70(s1)
    800060c0:	47a5                	li	a5,9
    800060c2:	0ce7ed63          	bltu	a5,a4,8000619c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800060c6:	fffff097          	auipc	ra,0xfffff
    800060ca:	dae080e7          	jalr	-594(ra) # 80004e74 <filealloc>
    800060ce:	89aa                	mv	s3,a0
    800060d0:	10050363          	beqz	a0,800061d6 <sys_open+0x182>
    800060d4:	00000097          	auipc	ra,0x0
    800060d8:	8f4080e7          	jalr	-1804(ra) # 800059c8 <fdalloc>
    800060dc:	892a                	mv	s2,a0
    800060de:	0e054763          	bltz	a0,800061cc <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800060e2:	04449703          	lh	a4,68(s1)
    800060e6:	478d                	li	a5,3
    800060e8:	0cf70563          	beq	a4,a5,800061b2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800060ec:	4789                	li	a5,2
    800060ee:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800060f2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800060f6:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800060fa:	f4c42783          	lw	a5,-180(s0)
    800060fe:	0017c713          	xori	a4,a5,1
    80006102:	8b05                	andi	a4,a4,1
    80006104:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006108:	0037f713          	andi	a4,a5,3
    8000610c:	00e03733          	snez	a4,a4
    80006110:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006114:	4007f793          	andi	a5,a5,1024
    80006118:	c791                	beqz	a5,80006124 <sys_open+0xd0>
    8000611a:	04449703          	lh	a4,68(s1)
    8000611e:	4789                	li	a5,2
    80006120:	0af70063          	beq	a4,a5,800061c0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006124:	8526                	mv	a0,s1
    80006126:	ffffe097          	auipc	ra,0xffffe
    8000612a:	038080e7          	jalr	56(ra) # 8000415e <iunlock>
  end_op();
    8000612e:	fffff097          	auipc	ra,0xfffff
    80006132:	9b8080e7          	jalr	-1608(ra) # 80004ae6 <end_op>

  return fd;
    80006136:	854a                	mv	a0,s2
}
    80006138:	70ea                	ld	ra,184(sp)
    8000613a:	744a                	ld	s0,176(sp)
    8000613c:	74aa                	ld	s1,168(sp)
    8000613e:	790a                	ld	s2,160(sp)
    80006140:	69ea                	ld	s3,152(sp)
    80006142:	6129                	addi	sp,sp,192
    80006144:	8082                	ret
      end_op();
    80006146:	fffff097          	auipc	ra,0xfffff
    8000614a:	9a0080e7          	jalr	-1632(ra) # 80004ae6 <end_op>
      return -1;
    8000614e:	557d                	li	a0,-1
    80006150:	b7e5                	j	80006138 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006152:	f5040513          	addi	a0,s0,-176
    80006156:	ffffe097          	auipc	ra,0xffffe
    8000615a:	6f2080e7          	jalr	1778(ra) # 80004848 <namei>
    8000615e:	84aa                	mv	s1,a0
    80006160:	c905                	beqz	a0,80006190 <sys_open+0x13c>
    ilock(ip);
    80006162:	ffffe097          	auipc	ra,0xffffe
    80006166:	f3a080e7          	jalr	-198(ra) # 8000409c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000616a:	04449703          	lh	a4,68(s1)
    8000616e:	4785                	li	a5,1
    80006170:	f4f711e3          	bne	a4,a5,800060b2 <sys_open+0x5e>
    80006174:	f4c42783          	lw	a5,-180(s0)
    80006178:	d7b9                	beqz	a5,800060c6 <sys_open+0x72>
      iunlockput(ip);
    8000617a:	8526                	mv	a0,s1
    8000617c:	ffffe097          	auipc	ra,0xffffe
    80006180:	182080e7          	jalr	386(ra) # 800042fe <iunlockput>
      end_op();
    80006184:	fffff097          	auipc	ra,0xfffff
    80006188:	962080e7          	jalr	-1694(ra) # 80004ae6 <end_op>
      return -1;
    8000618c:	557d                	li	a0,-1
    8000618e:	b76d                	j	80006138 <sys_open+0xe4>
      end_op();
    80006190:	fffff097          	auipc	ra,0xfffff
    80006194:	956080e7          	jalr	-1706(ra) # 80004ae6 <end_op>
      return -1;
    80006198:	557d                	li	a0,-1
    8000619a:	bf79                	j	80006138 <sys_open+0xe4>
    iunlockput(ip);
    8000619c:	8526                	mv	a0,s1
    8000619e:	ffffe097          	auipc	ra,0xffffe
    800061a2:	160080e7          	jalr	352(ra) # 800042fe <iunlockput>
    end_op();
    800061a6:	fffff097          	auipc	ra,0xfffff
    800061aa:	940080e7          	jalr	-1728(ra) # 80004ae6 <end_op>
    return -1;
    800061ae:	557d                	li	a0,-1
    800061b0:	b761                	j	80006138 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800061b2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800061b6:	04649783          	lh	a5,70(s1)
    800061ba:	02f99223          	sh	a5,36(s3)
    800061be:	bf25                	j	800060f6 <sys_open+0xa2>
    itrunc(ip);
    800061c0:	8526                	mv	a0,s1
    800061c2:	ffffe097          	auipc	ra,0xffffe
    800061c6:	fe8080e7          	jalr	-24(ra) # 800041aa <itrunc>
    800061ca:	bfa9                	j	80006124 <sys_open+0xd0>
      fileclose(f);
    800061cc:	854e                	mv	a0,s3
    800061ce:	fffff097          	auipc	ra,0xfffff
    800061d2:	d62080e7          	jalr	-670(ra) # 80004f30 <fileclose>
    iunlockput(ip);
    800061d6:	8526                	mv	a0,s1
    800061d8:	ffffe097          	auipc	ra,0xffffe
    800061dc:	126080e7          	jalr	294(ra) # 800042fe <iunlockput>
    end_op();
    800061e0:	fffff097          	auipc	ra,0xfffff
    800061e4:	906080e7          	jalr	-1786(ra) # 80004ae6 <end_op>
    return -1;
    800061e8:	557d                	li	a0,-1
    800061ea:	b7b9                	j	80006138 <sys_open+0xe4>

00000000800061ec <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800061ec:	7175                	addi	sp,sp,-144
    800061ee:	e506                	sd	ra,136(sp)
    800061f0:	e122                	sd	s0,128(sp)
    800061f2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800061f4:	fffff097          	auipc	ra,0xfffff
    800061f8:	874080e7          	jalr	-1932(ra) # 80004a68 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800061fc:	08000613          	li	a2,128
    80006200:	f7040593          	addi	a1,s0,-144
    80006204:	4501                	li	a0,0
    80006206:	ffffd097          	auipc	ra,0xffffd
    8000620a:	f64080e7          	jalr	-156(ra) # 8000316a <argstr>
    8000620e:	02054963          	bltz	a0,80006240 <sys_mkdir+0x54>
    80006212:	4681                	li	a3,0
    80006214:	4601                	li	a2,0
    80006216:	4585                	li	a1,1
    80006218:	f7040513          	addi	a0,s0,-144
    8000621c:	fffff097          	auipc	ra,0xfffff
    80006220:	7ee080e7          	jalr	2030(ra) # 80005a0a <create>
    80006224:	cd11                	beqz	a0,80006240 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006226:	ffffe097          	auipc	ra,0xffffe
    8000622a:	0d8080e7          	jalr	216(ra) # 800042fe <iunlockput>
  end_op();
    8000622e:	fffff097          	auipc	ra,0xfffff
    80006232:	8b8080e7          	jalr	-1864(ra) # 80004ae6 <end_op>
  return 0;
    80006236:	4501                	li	a0,0
}
    80006238:	60aa                	ld	ra,136(sp)
    8000623a:	640a                	ld	s0,128(sp)
    8000623c:	6149                	addi	sp,sp,144
    8000623e:	8082                	ret
    end_op();
    80006240:	fffff097          	auipc	ra,0xfffff
    80006244:	8a6080e7          	jalr	-1882(ra) # 80004ae6 <end_op>
    return -1;
    80006248:	557d                	li	a0,-1
    8000624a:	b7fd                	j	80006238 <sys_mkdir+0x4c>

000000008000624c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000624c:	7135                	addi	sp,sp,-160
    8000624e:	ed06                	sd	ra,152(sp)
    80006250:	e922                	sd	s0,144(sp)
    80006252:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006254:	fffff097          	auipc	ra,0xfffff
    80006258:	814080e7          	jalr	-2028(ra) # 80004a68 <begin_op>
  argint(1, &major);
    8000625c:	f6c40593          	addi	a1,s0,-148
    80006260:	4505                	li	a0,1
    80006262:	ffffd097          	auipc	ra,0xffffd
    80006266:	ec8080e7          	jalr	-312(ra) # 8000312a <argint>
  argint(2, &minor);
    8000626a:	f6840593          	addi	a1,s0,-152
    8000626e:	4509                	li	a0,2
    80006270:	ffffd097          	auipc	ra,0xffffd
    80006274:	eba080e7          	jalr	-326(ra) # 8000312a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006278:	08000613          	li	a2,128
    8000627c:	f7040593          	addi	a1,s0,-144
    80006280:	4501                	li	a0,0
    80006282:	ffffd097          	auipc	ra,0xffffd
    80006286:	ee8080e7          	jalr	-280(ra) # 8000316a <argstr>
    8000628a:	02054b63          	bltz	a0,800062c0 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000628e:	f6841683          	lh	a3,-152(s0)
    80006292:	f6c41603          	lh	a2,-148(s0)
    80006296:	458d                	li	a1,3
    80006298:	f7040513          	addi	a0,s0,-144
    8000629c:	fffff097          	auipc	ra,0xfffff
    800062a0:	76e080e7          	jalr	1902(ra) # 80005a0a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800062a4:	cd11                	beqz	a0,800062c0 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800062a6:	ffffe097          	auipc	ra,0xffffe
    800062aa:	058080e7          	jalr	88(ra) # 800042fe <iunlockput>
  end_op();
    800062ae:	fffff097          	auipc	ra,0xfffff
    800062b2:	838080e7          	jalr	-1992(ra) # 80004ae6 <end_op>
  return 0;
    800062b6:	4501                	li	a0,0
}
    800062b8:	60ea                	ld	ra,152(sp)
    800062ba:	644a                	ld	s0,144(sp)
    800062bc:	610d                	addi	sp,sp,160
    800062be:	8082                	ret
    end_op();
    800062c0:	fffff097          	auipc	ra,0xfffff
    800062c4:	826080e7          	jalr	-2010(ra) # 80004ae6 <end_op>
    return -1;
    800062c8:	557d                	li	a0,-1
    800062ca:	b7fd                	j	800062b8 <sys_mknod+0x6c>

00000000800062cc <sys_chdir>:

uint64
sys_chdir(void)
{
    800062cc:	7135                	addi	sp,sp,-160
    800062ce:	ed06                	sd	ra,152(sp)
    800062d0:	e922                	sd	s0,144(sp)
    800062d2:	e526                	sd	s1,136(sp)
    800062d4:	e14a                	sd	s2,128(sp)
    800062d6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800062d8:	ffffc097          	auipc	ra,0xffffc
    800062dc:	858080e7          	jalr	-1960(ra) # 80001b30 <myproc>
    800062e0:	892a                	mv	s2,a0
  
  begin_op();
    800062e2:	ffffe097          	auipc	ra,0xffffe
    800062e6:	786080e7          	jalr	1926(ra) # 80004a68 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800062ea:	08000613          	li	a2,128
    800062ee:	f6040593          	addi	a1,s0,-160
    800062f2:	4501                	li	a0,0
    800062f4:	ffffd097          	auipc	ra,0xffffd
    800062f8:	e76080e7          	jalr	-394(ra) # 8000316a <argstr>
    800062fc:	04054b63          	bltz	a0,80006352 <sys_chdir+0x86>
    80006300:	f6040513          	addi	a0,s0,-160
    80006304:	ffffe097          	auipc	ra,0xffffe
    80006308:	544080e7          	jalr	1348(ra) # 80004848 <namei>
    8000630c:	84aa                	mv	s1,a0
    8000630e:	c131                	beqz	a0,80006352 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006310:	ffffe097          	auipc	ra,0xffffe
    80006314:	d8c080e7          	jalr	-628(ra) # 8000409c <ilock>
  if(ip->type != T_DIR){
    80006318:	04449703          	lh	a4,68(s1)
    8000631c:	4785                	li	a5,1
    8000631e:	04f71063          	bne	a4,a5,8000635e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006322:	8526                	mv	a0,s1
    80006324:	ffffe097          	auipc	ra,0xffffe
    80006328:	e3a080e7          	jalr	-454(ra) # 8000415e <iunlock>
  iput(p->cwd);
    8000632c:	15093503          	ld	a0,336(s2)
    80006330:	ffffe097          	auipc	ra,0xffffe
    80006334:	f26080e7          	jalr	-218(ra) # 80004256 <iput>
  end_op();
    80006338:	ffffe097          	auipc	ra,0xffffe
    8000633c:	7ae080e7          	jalr	1966(ra) # 80004ae6 <end_op>
  p->cwd = ip;
    80006340:	14993823          	sd	s1,336(s2)
  return 0;
    80006344:	4501                	li	a0,0
}
    80006346:	60ea                	ld	ra,152(sp)
    80006348:	644a                	ld	s0,144(sp)
    8000634a:	64aa                	ld	s1,136(sp)
    8000634c:	690a                	ld	s2,128(sp)
    8000634e:	610d                	addi	sp,sp,160
    80006350:	8082                	ret
    end_op();
    80006352:	ffffe097          	auipc	ra,0xffffe
    80006356:	794080e7          	jalr	1940(ra) # 80004ae6 <end_op>
    return -1;
    8000635a:	557d                	li	a0,-1
    8000635c:	b7ed                	j	80006346 <sys_chdir+0x7a>
    iunlockput(ip);
    8000635e:	8526                	mv	a0,s1
    80006360:	ffffe097          	auipc	ra,0xffffe
    80006364:	f9e080e7          	jalr	-98(ra) # 800042fe <iunlockput>
    end_op();
    80006368:	ffffe097          	auipc	ra,0xffffe
    8000636c:	77e080e7          	jalr	1918(ra) # 80004ae6 <end_op>
    return -1;
    80006370:	557d                	li	a0,-1
    80006372:	bfd1                	j	80006346 <sys_chdir+0x7a>

0000000080006374 <sys_exec>:

uint64
sys_exec(void)
{
    80006374:	7145                	addi	sp,sp,-464
    80006376:	e786                	sd	ra,456(sp)
    80006378:	e3a2                	sd	s0,448(sp)
    8000637a:	ff26                	sd	s1,440(sp)
    8000637c:	fb4a                	sd	s2,432(sp)
    8000637e:	f74e                	sd	s3,424(sp)
    80006380:	f352                	sd	s4,416(sp)
    80006382:	ef56                	sd	s5,408(sp)
    80006384:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006386:	e3840593          	addi	a1,s0,-456
    8000638a:	4505                	li	a0,1
    8000638c:	ffffd097          	auipc	ra,0xffffd
    80006390:	dbe080e7          	jalr	-578(ra) # 8000314a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006394:	08000613          	li	a2,128
    80006398:	f4040593          	addi	a1,s0,-192
    8000639c:	4501                	li	a0,0
    8000639e:	ffffd097          	auipc	ra,0xffffd
    800063a2:	dcc080e7          	jalr	-564(ra) # 8000316a <argstr>
    800063a6:	87aa                	mv	a5,a0
    return -1;
    800063a8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800063aa:	0c07c363          	bltz	a5,80006470 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800063ae:	10000613          	li	a2,256
    800063b2:	4581                	li	a1,0
    800063b4:	e4040513          	addi	a0,s0,-448
    800063b8:	ffffb097          	auipc	ra,0xffffb
    800063bc:	a5a080e7          	jalr	-1446(ra) # 80000e12 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800063c0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800063c4:	89a6                	mv	s3,s1
    800063c6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800063c8:	02000a13          	li	s4,32
    800063cc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800063d0:	00391513          	slli	a0,s2,0x3
    800063d4:	e3040593          	addi	a1,s0,-464
    800063d8:	e3843783          	ld	a5,-456(s0)
    800063dc:	953e                	add	a0,a0,a5
    800063de:	ffffd097          	auipc	ra,0xffffd
    800063e2:	cae080e7          	jalr	-850(ra) # 8000308c <fetchaddr>
    800063e6:	02054a63          	bltz	a0,8000641a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800063ea:	e3043783          	ld	a5,-464(s0)
    800063ee:	c3b9                	beqz	a5,80006434 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800063f0:	ffffa097          	auipc	ra,0xffffa
    800063f4:	7f8080e7          	jalr	2040(ra) # 80000be8 <kalloc>
    800063f8:	85aa                	mv	a1,a0
    800063fa:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800063fe:	cd11                	beqz	a0,8000641a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006400:	6605                	lui	a2,0x1
    80006402:	e3043503          	ld	a0,-464(s0)
    80006406:	ffffd097          	auipc	ra,0xffffd
    8000640a:	cd8080e7          	jalr	-808(ra) # 800030de <fetchstr>
    8000640e:	00054663          	bltz	a0,8000641a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006412:	0905                	addi	s2,s2,1
    80006414:	09a1                	addi	s3,s3,8
    80006416:	fb491be3          	bne	s2,s4,800063cc <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000641a:	f4040913          	addi	s2,s0,-192
    8000641e:	6088                	ld	a0,0(s1)
    80006420:	c539                	beqz	a0,8000646e <sys_exec+0xfa>
    kfree(argv[i]);
    80006422:	ffffa097          	auipc	ra,0xffffa
    80006426:	642080e7          	jalr	1602(ra) # 80000a64 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000642a:	04a1                	addi	s1,s1,8
    8000642c:	ff2499e3          	bne	s1,s2,8000641e <sys_exec+0xaa>
  return -1;
    80006430:	557d                	li	a0,-1
    80006432:	a83d                	j	80006470 <sys_exec+0xfc>
      argv[i] = 0;
    80006434:	0a8e                	slli	s5,s5,0x3
    80006436:	fc0a8793          	addi	a5,s5,-64
    8000643a:	00878ab3          	add	s5,a5,s0
    8000643e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006442:	e4040593          	addi	a1,s0,-448
    80006446:	f4040513          	addi	a0,s0,-192
    8000644a:	fffff097          	auipc	ra,0xfffff
    8000644e:	160080e7          	jalr	352(ra) # 800055aa <exec>
    80006452:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006454:	f4040993          	addi	s3,s0,-192
    80006458:	6088                	ld	a0,0(s1)
    8000645a:	c901                	beqz	a0,8000646a <sys_exec+0xf6>
    kfree(argv[i]);
    8000645c:	ffffa097          	auipc	ra,0xffffa
    80006460:	608080e7          	jalr	1544(ra) # 80000a64 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006464:	04a1                	addi	s1,s1,8
    80006466:	ff3499e3          	bne	s1,s3,80006458 <sys_exec+0xe4>
  return ret;
    8000646a:	854a                	mv	a0,s2
    8000646c:	a011                	j	80006470 <sys_exec+0xfc>
  return -1;
    8000646e:	557d                	li	a0,-1
}
    80006470:	60be                	ld	ra,456(sp)
    80006472:	641e                	ld	s0,448(sp)
    80006474:	74fa                	ld	s1,440(sp)
    80006476:	795a                	ld	s2,432(sp)
    80006478:	79ba                	ld	s3,424(sp)
    8000647a:	7a1a                	ld	s4,416(sp)
    8000647c:	6afa                	ld	s5,408(sp)
    8000647e:	6179                	addi	sp,sp,464
    80006480:	8082                	ret

0000000080006482 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006482:	7139                	addi	sp,sp,-64
    80006484:	fc06                	sd	ra,56(sp)
    80006486:	f822                	sd	s0,48(sp)
    80006488:	f426                	sd	s1,40(sp)
    8000648a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000648c:	ffffb097          	auipc	ra,0xffffb
    80006490:	6a4080e7          	jalr	1700(ra) # 80001b30 <myproc>
    80006494:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006496:	fd840593          	addi	a1,s0,-40
    8000649a:	4501                	li	a0,0
    8000649c:	ffffd097          	auipc	ra,0xffffd
    800064a0:	cae080e7          	jalr	-850(ra) # 8000314a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800064a4:	fc840593          	addi	a1,s0,-56
    800064a8:	fd040513          	addi	a0,s0,-48
    800064ac:	fffff097          	auipc	ra,0xfffff
    800064b0:	db4080e7          	jalr	-588(ra) # 80005260 <pipealloc>
    return -1;
    800064b4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800064b6:	0c054463          	bltz	a0,8000657e <sys_pipe+0xfc>
  fd0 = -1;
    800064ba:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800064be:	fd043503          	ld	a0,-48(s0)
    800064c2:	fffff097          	auipc	ra,0xfffff
    800064c6:	506080e7          	jalr	1286(ra) # 800059c8 <fdalloc>
    800064ca:	fca42223          	sw	a0,-60(s0)
    800064ce:	08054b63          	bltz	a0,80006564 <sys_pipe+0xe2>
    800064d2:	fc843503          	ld	a0,-56(s0)
    800064d6:	fffff097          	auipc	ra,0xfffff
    800064da:	4f2080e7          	jalr	1266(ra) # 800059c8 <fdalloc>
    800064de:	fca42023          	sw	a0,-64(s0)
    800064e2:	06054863          	bltz	a0,80006552 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800064e6:	4691                	li	a3,4
    800064e8:	fc440613          	addi	a2,s0,-60
    800064ec:	fd843583          	ld	a1,-40(s0)
    800064f0:	68a8                	ld	a0,80(s1)
    800064f2:	ffffb097          	auipc	ra,0xffffb
    800064f6:	2a6080e7          	jalr	678(ra) # 80001798 <copyout>
    800064fa:	02054063          	bltz	a0,8000651a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800064fe:	4691                	li	a3,4
    80006500:	fc040613          	addi	a2,s0,-64
    80006504:	fd843583          	ld	a1,-40(s0)
    80006508:	0591                	addi	a1,a1,4
    8000650a:	68a8                	ld	a0,80(s1)
    8000650c:	ffffb097          	auipc	ra,0xffffb
    80006510:	28c080e7          	jalr	652(ra) # 80001798 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006514:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006516:	06055463          	bgez	a0,8000657e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000651a:	fc442783          	lw	a5,-60(s0)
    8000651e:	07e9                	addi	a5,a5,26
    80006520:	078e                	slli	a5,a5,0x3
    80006522:	97a6                	add	a5,a5,s1
    80006524:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006528:	fc042783          	lw	a5,-64(s0)
    8000652c:	07e9                	addi	a5,a5,26
    8000652e:	078e                	slli	a5,a5,0x3
    80006530:	94be                	add	s1,s1,a5
    80006532:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006536:	fd043503          	ld	a0,-48(s0)
    8000653a:	fffff097          	auipc	ra,0xfffff
    8000653e:	9f6080e7          	jalr	-1546(ra) # 80004f30 <fileclose>
    fileclose(wf);
    80006542:	fc843503          	ld	a0,-56(s0)
    80006546:	fffff097          	auipc	ra,0xfffff
    8000654a:	9ea080e7          	jalr	-1558(ra) # 80004f30 <fileclose>
    return -1;
    8000654e:	57fd                	li	a5,-1
    80006550:	a03d                	j	8000657e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006552:	fc442783          	lw	a5,-60(s0)
    80006556:	0007c763          	bltz	a5,80006564 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000655a:	07e9                	addi	a5,a5,26
    8000655c:	078e                	slli	a5,a5,0x3
    8000655e:	97a6                	add	a5,a5,s1
    80006560:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006564:	fd043503          	ld	a0,-48(s0)
    80006568:	fffff097          	auipc	ra,0xfffff
    8000656c:	9c8080e7          	jalr	-1592(ra) # 80004f30 <fileclose>
    fileclose(wf);
    80006570:	fc843503          	ld	a0,-56(s0)
    80006574:	fffff097          	auipc	ra,0xfffff
    80006578:	9bc080e7          	jalr	-1604(ra) # 80004f30 <fileclose>
    return -1;
    8000657c:	57fd                	li	a5,-1
}
    8000657e:	853e                	mv	a0,a5
    80006580:	70e2                	ld	ra,56(sp)
    80006582:	7442                	ld	s0,48(sp)
    80006584:	74a2                	ld	s1,40(sp)
    80006586:	6121                	addi	sp,sp,64
    80006588:	8082                	ret

000000008000658a <sys_getreadcount>:


uint64
sys_getreadcount(void)
{
    8000658a:	1141                	addi	sp,sp,-16
    8000658c:	e422                	sd	s0,8(sp)
    8000658e:	0800                	addi	s0,sp,16
  // return myproc()->readid;
  return count;
    80006590:	00002517          	auipc	a0,0x2
    80006594:	6a852503          	lw	a0,1704(a0) # 80008c38 <count>
    80006598:	6422                	ld	s0,8(sp)
    8000659a:	0141                	addi	sp,sp,16
    8000659c:	8082                	ret
	...

00000000800065a0 <kernelvec>:
    800065a0:	7111                	addi	sp,sp,-256
    800065a2:	e006                	sd	ra,0(sp)
    800065a4:	e40a                	sd	sp,8(sp)
    800065a6:	e80e                	sd	gp,16(sp)
    800065a8:	ec12                	sd	tp,24(sp)
    800065aa:	f016                	sd	t0,32(sp)
    800065ac:	f41a                	sd	t1,40(sp)
    800065ae:	f81e                	sd	t2,48(sp)
    800065b0:	fc22                	sd	s0,56(sp)
    800065b2:	e0a6                	sd	s1,64(sp)
    800065b4:	e4aa                	sd	a0,72(sp)
    800065b6:	e8ae                	sd	a1,80(sp)
    800065b8:	ecb2                	sd	a2,88(sp)
    800065ba:	f0b6                	sd	a3,96(sp)
    800065bc:	f4ba                	sd	a4,104(sp)
    800065be:	f8be                	sd	a5,112(sp)
    800065c0:	fcc2                	sd	a6,120(sp)
    800065c2:	e146                	sd	a7,128(sp)
    800065c4:	e54a                	sd	s2,136(sp)
    800065c6:	e94e                	sd	s3,144(sp)
    800065c8:	ed52                	sd	s4,152(sp)
    800065ca:	f156                	sd	s5,160(sp)
    800065cc:	f55a                	sd	s6,168(sp)
    800065ce:	f95e                	sd	s7,176(sp)
    800065d0:	fd62                	sd	s8,184(sp)
    800065d2:	e1e6                	sd	s9,192(sp)
    800065d4:	e5ea                	sd	s10,200(sp)
    800065d6:	e9ee                	sd	s11,208(sp)
    800065d8:	edf2                	sd	t3,216(sp)
    800065da:	f1f6                	sd	t4,224(sp)
    800065dc:	f5fa                	sd	t5,232(sp)
    800065de:	f9fe                	sd	t6,240(sp)
    800065e0:	989fc0ef          	jal	ra,80002f68 <kerneltrap>
    800065e4:	6082                	ld	ra,0(sp)
    800065e6:	6122                	ld	sp,8(sp)
    800065e8:	61c2                	ld	gp,16(sp)
    800065ea:	7282                	ld	t0,32(sp)
    800065ec:	7322                	ld	t1,40(sp)
    800065ee:	73c2                	ld	t2,48(sp)
    800065f0:	7462                	ld	s0,56(sp)
    800065f2:	6486                	ld	s1,64(sp)
    800065f4:	6526                	ld	a0,72(sp)
    800065f6:	65c6                	ld	a1,80(sp)
    800065f8:	6666                	ld	a2,88(sp)
    800065fa:	7686                	ld	a3,96(sp)
    800065fc:	7726                	ld	a4,104(sp)
    800065fe:	77c6                	ld	a5,112(sp)
    80006600:	7866                	ld	a6,120(sp)
    80006602:	688a                	ld	a7,128(sp)
    80006604:	692a                	ld	s2,136(sp)
    80006606:	69ca                	ld	s3,144(sp)
    80006608:	6a6a                	ld	s4,152(sp)
    8000660a:	7a8a                	ld	s5,160(sp)
    8000660c:	7b2a                	ld	s6,168(sp)
    8000660e:	7bca                	ld	s7,176(sp)
    80006610:	7c6a                	ld	s8,184(sp)
    80006612:	6c8e                	ld	s9,192(sp)
    80006614:	6d2e                	ld	s10,200(sp)
    80006616:	6dce                	ld	s11,208(sp)
    80006618:	6e6e                	ld	t3,216(sp)
    8000661a:	7e8e                	ld	t4,224(sp)
    8000661c:	7f2e                	ld	t5,232(sp)
    8000661e:	7fce                	ld	t6,240(sp)
    80006620:	6111                	addi	sp,sp,256
    80006622:	10200073          	sret
    80006626:	00000013          	nop
    8000662a:	00000013          	nop
    8000662e:	0001                	nop

0000000080006630 <timervec>:
    80006630:	34051573          	csrrw	a0,mscratch,a0
    80006634:	e10c                	sd	a1,0(a0)
    80006636:	e510                	sd	a2,8(a0)
    80006638:	e914                	sd	a3,16(a0)
    8000663a:	6d0c                	ld	a1,24(a0)
    8000663c:	7110                	ld	a2,32(a0)
    8000663e:	6194                	ld	a3,0(a1)
    80006640:	96b2                	add	a3,a3,a2
    80006642:	e194                	sd	a3,0(a1)
    80006644:	4589                	li	a1,2
    80006646:	14459073          	csrw	sip,a1
    8000664a:	6914                	ld	a3,16(a0)
    8000664c:	6510                	ld	a2,8(a0)
    8000664e:	610c                	ld	a1,0(a0)
    80006650:	34051573          	csrrw	a0,mscratch,a0
    80006654:	30200073          	mret
	...

000000008000665a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000665a:	1141                	addi	sp,sp,-16
    8000665c:	e422                	sd	s0,8(sp)
    8000665e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006660:	0c0007b7          	lui	a5,0xc000
    80006664:	4705                	li	a4,1
    80006666:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006668:	c3d8                	sw	a4,4(a5)
}
    8000666a:	6422                	ld	s0,8(sp)
    8000666c:	0141                	addi	sp,sp,16
    8000666e:	8082                	ret

0000000080006670 <plicinithart>:

void
plicinithart(void)
{
    80006670:	1141                	addi	sp,sp,-16
    80006672:	e406                	sd	ra,8(sp)
    80006674:	e022                	sd	s0,0(sp)
    80006676:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006678:	ffffb097          	auipc	ra,0xffffb
    8000667c:	48c080e7          	jalr	1164(ra) # 80001b04 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006680:	0085171b          	slliw	a4,a0,0x8
    80006684:	0c0027b7          	lui	a5,0xc002
    80006688:	97ba                	add	a5,a5,a4
    8000668a:	40200713          	li	a4,1026
    8000668e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006692:	00d5151b          	slliw	a0,a0,0xd
    80006696:	0c2017b7          	lui	a5,0xc201
    8000669a:	97aa                	add	a5,a5,a0
    8000669c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800066a0:	60a2                	ld	ra,8(sp)
    800066a2:	6402                	ld	s0,0(sp)
    800066a4:	0141                	addi	sp,sp,16
    800066a6:	8082                	ret

00000000800066a8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800066a8:	1141                	addi	sp,sp,-16
    800066aa:	e406                	sd	ra,8(sp)
    800066ac:	e022                	sd	s0,0(sp)
    800066ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800066b0:	ffffb097          	auipc	ra,0xffffb
    800066b4:	454080e7          	jalr	1108(ra) # 80001b04 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800066b8:	00d5151b          	slliw	a0,a0,0xd
    800066bc:	0c2017b7          	lui	a5,0xc201
    800066c0:	97aa                	add	a5,a5,a0
  return irq;
}
    800066c2:	43c8                	lw	a0,4(a5)
    800066c4:	60a2                	ld	ra,8(sp)
    800066c6:	6402                	ld	s0,0(sp)
    800066c8:	0141                	addi	sp,sp,16
    800066ca:	8082                	ret

00000000800066cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800066cc:	1101                	addi	sp,sp,-32
    800066ce:	ec06                	sd	ra,24(sp)
    800066d0:	e822                	sd	s0,16(sp)
    800066d2:	e426                	sd	s1,8(sp)
    800066d4:	1000                	addi	s0,sp,32
    800066d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800066d8:	ffffb097          	auipc	ra,0xffffb
    800066dc:	42c080e7          	jalr	1068(ra) # 80001b04 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800066e0:	00d5151b          	slliw	a0,a0,0xd
    800066e4:	0c2017b7          	lui	a5,0xc201
    800066e8:	97aa                	add	a5,a5,a0
    800066ea:	c3c4                	sw	s1,4(a5)
}
    800066ec:	60e2                	ld	ra,24(sp)
    800066ee:	6442                	ld	s0,16(sp)
    800066f0:	64a2                	ld	s1,8(sp)
    800066f2:	6105                	addi	sp,sp,32
    800066f4:	8082                	ret

00000000800066f6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800066f6:	1141                	addi	sp,sp,-16
    800066f8:	e406                	sd	ra,8(sp)
    800066fa:	e022                	sd	s0,0(sp)
    800066fc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800066fe:	479d                	li	a5,7
    80006700:	04a7cc63          	blt	a5,a0,80006758 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006704:	0023e797          	auipc	a5,0x23e
    80006708:	abc78793          	addi	a5,a5,-1348 # 802441c0 <disk>
    8000670c:	97aa                	add	a5,a5,a0
    8000670e:	0187c783          	lbu	a5,24(a5)
    80006712:	ebb9                	bnez	a5,80006768 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006714:	00451693          	slli	a3,a0,0x4
    80006718:	0023e797          	auipc	a5,0x23e
    8000671c:	aa878793          	addi	a5,a5,-1368 # 802441c0 <disk>
    80006720:	6398                	ld	a4,0(a5)
    80006722:	9736                	add	a4,a4,a3
    80006724:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006728:	6398                	ld	a4,0(a5)
    8000672a:	9736                	add	a4,a4,a3
    8000672c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006730:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006734:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006738:	97aa                	add	a5,a5,a0
    8000673a:	4705                	li	a4,1
    8000673c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006740:	0023e517          	auipc	a0,0x23e
    80006744:	a9850513          	addi	a0,a0,-1384 # 802441d8 <disk+0x18>
    80006748:	ffffc097          	auipc	ra,0xffffc
    8000674c:	e2c080e7          	jalr	-468(ra) # 80002574 <wakeup>
}
    80006750:	60a2                	ld	ra,8(sp)
    80006752:	6402                	ld	s0,0(sp)
    80006754:	0141                	addi	sp,sp,16
    80006756:	8082                	ret
    panic("free_desc 1");
    80006758:	00002517          	auipc	a0,0x2
    8000675c:	2c850513          	addi	a0,a0,712 # 80008a20 <syscallnames+0x348>
    80006760:	ffffa097          	auipc	ra,0xffffa
    80006764:	de0080e7          	jalr	-544(ra) # 80000540 <panic>
    panic("free_desc 2");
    80006768:	00002517          	auipc	a0,0x2
    8000676c:	2c850513          	addi	a0,a0,712 # 80008a30 <syscallnames+0x358>
    80006770:	ffffa097          	auipc	ra,0xffffa
    80006774:	dd0080e7          	jalr	-560(ra) # 80000540 <panic>

0000000080006778 <virtio_disk_init>:
{
    80006778:	1101                	addi	sp,sp,-32
    8000677a:	ec06                	sd	ra,24(sp)
    8000677c:	e822                	sd	s0,16(sp)
    8000677e:	e426                	sd	s1,8(sp)
    80006780:	e04a                	sd	s2,0(sp)
    80006782:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006784:	00002597          	auipc	a1,0x2
    80006788:	2bc58593          	addi	a1,a1,700 # 80008a40 <syscallnames+0x368>
    8000678c:	0023e517          	auipc	a0,0x23e
    80006790:	b5c50513          	addi	a0,a0,-1188 # 802442e8 <disk+0x128>
    80006794:	ffffa097          	auipc	ra,0xffffa
    80006798:	4f2080e7          	jalr	1266(ra) # 80000c86 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000679c:	100017b7          	lui	a5,0x10001
    800067a0:	4398                	lw	a4,0(a5)
    800067a2:	2701                	sext.w	a4,a4
    800067a4:	747277b7          	lui	a5,0x74727
    800067a8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800067ac:	14f71b63          	bne	a4,a5,80006902 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800067b0:	100017b7          	lui	a5,0x10001
    800067b4:	43dc                	lw	a5,4(a5)
    800067b6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800067b8:	4709                	li	a4,2
    800067ba:	14e79463          	bne	a5,a4,80006902 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800067be:	100017b7          	lui	a5,0x10001
    800067c2:	479c                	lw	a5,8(a5)
    800067c4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800067c6:	12e79e63          	bne	a5,a4,80006902 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800067ca:	100017b7          	lui	a5,0x10001
    800067ce:	47d8                	lw	a4,12(a5)
    800067d0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800067d2:	554d47b7          	lui	a5,0x554d4
    800067d6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800067da:	12f71463          	bne	a4,a5,80006902 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800067de:	100017b7          	lui	a5,0x10001
    800067e2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800067e6:	4705                	li	a4,1
    800067e8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800067ea:	470d                	li	a4,3
    800067ec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800067ee:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800067f0:	c7ffe6b7          	lui	a3,0xc7ffe
    800067f4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47dba45f>
    800067f8:	8f75                	and	a4,a4,a3
    800067fa:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800067fc:	472d                	li	a4,11
    800067fe:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006800:	5bbc                	lw	a5,112(a5)
    80006802:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006806:	8ba1                	andi	a5,a5,8
    80006808:	10078563          	beqz	a5,80006912 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000680c:	100017b7          	lui	a5,0x10001
    80006810:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006814:	43fc                	lw	a5,68(a5)
    80006816:	2781                	sext.w	a5,a5
    80006818:	10079563          	bnez	a5,80006922 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000681c:	100017b7          	lui	a5,0x10001
    80006820:	5bdc                	lw	a5,52(a5)
    80006822:	2781                	sext.w	a5,a5
  if(max == 0)
    80006824:	10078763          	beqz	a5,80006932 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006828:	471d                	li	a4,7
    8000682a:	10f77c63          	bgeu	a4,a5,80006942 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000682e:	ffffa097          	auipc	ra,0xffffa
    80006832:	3ba080e7          	jalr	954(ra) # 80000be8 <kalloc>
    80006836:	0023e497          	auipc	s1,0x23e
    8000683a:	98a48493          	addi	s1,s1,-1654 # 802441c0 <disk>
    8000683e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006840:	ffffa097          	auipc	ra,0xffffa
    80006844:	3a8080e7          	jalr	936(ra) # 80000be8 <kalloc>
    80006848:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000684a:	ffffa097          	auipc	ra,0xffffa
    8000684e:	39e080e7          	jalr	926(ra) # 80000be8 <kalloc>
    80006852:	87aa                	mv	a5,a0
    80006854:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006856:	6088                	ld	a0,0(s1)
    80006858:	cd6d                	beqz	a0,80006952 <virtio_disk_init+0x1da>
    8000685a:	0023e717          	auipc	a4,0x23e
    8000685e:	96e73703          	ld	a4,-1682(a4) # 802441c8 <disk+0x8>
    80006862:	cb65                	beqz	a4,80006952 <virtio_disk_init+0x1da>
    80006864:	c7fd                	beqz	a5,80006952 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006866:	6605                	lui	a2,0x1
    80006868:	4581                	li	a1,0
    8000686a:	ffffa097          	auipc	ra,0xffffa
    8000686e:	5a8080e7          	jalr	1448(ra) # 80000e12 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006872:	0023e497          	auipc	s1,0x23e
    80006876:	94e48493          	addi	s1,s1,-1714 # 802441c0 <disk>
    8000687a:	6605                	lui	a2,0x1
    8000687c:	4581                	li	a1,0
    8000687e:	6488                	ld	a0,8(s1)
    80006880:	ffffa097          	auipc	ra,0xffffa
    80006884:	592080e7          	jalr	1426(ra) # 80000e12 <memset>
  memset(disk.used, 0, PGSIZE);
    80006888:	6605                	lui	a2,0x1
    8000688a:	4581                	li	a1,0
    8000688c:	6888                	ld	a0,16(s1)
    8000688e:	ffffa097          	auipc	ra,0xffffa
    80006892:	584080e7          	jalr	1412(ra) # 80000e12 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006896:	100017b7          	lui	a5,0x10001
    8000689a:	4721                	li	a4,8
    8000689c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000689e:	4098                	lw	a4,0(s1)
    800068a0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800068a4:	40d8                	lw	a4,4(s1)
    800068a6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800068aa:	6498                	ld	a4,8(s1)
    800068ac:	0007069b          	sext.w	a3,a4
    800068b0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800068b4:	9701                	srai	a4,a4,0x20
    800068b6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800068ba:	6898                	ld	a4,16(s1)
    800068bc:	0007069b          	sext.w	a3,a4
    800068c0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800068c4:	9701                	srai	a4,a4,0x20
    800068c6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800068ca:	4705                	li	a4,1
    800068cc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800068ce:	00e48c23          	sb	a4,24(s1)
    800068d2:	00e48ca3          	sb	a4,25(s1)
    800068d6:	00e48d23          	sb	a4,26(s1)
    800068da:	00e48da3          	sb	a4,27(s1)
    800068de:	00e48e23          	sb	a4,28(s1)
    800068e2:	00e48ea3          	sb	a4,29(s1)
    800068e6:	00e48f23          	sb	a4,30(s1)
    800068ea:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800068ee:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800068f2:	0727a823          	sw	s2,112(a5)
}
    800068f6:	60e2                	ld	ra,24(sp)
    800068f8:	6442                	ld	s0,16(sp)
    800068fa:	64a2                	ld	s1,8(sp)
    800068fc:	6902                	ld	s2,0(sp)
    800068fe:	6105                	addi	sp,sp,32
    80006900:	8082                	ret
    panic("could not find virtio disk");
    80006902:	00002517          	auipc	a0,0x2
    80006906:	14e50513          	addi	a0,a0,334 # 80008a50 <syscallnames+0x378>
    8000690a:	ffffa097          	auipc	ra,0xffffa
    8000690e:	c36080e7          	jalr	-970(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006912:	00002517          	auipc	a0,0x2
    80006916:	15e50513          	addi	a0,a0,350 # 80008a70 <syscallnames+0x398>
    8000691a:	ffffa097          	auipc	ra,0xffffa
    8000691e:	c26080e7          	jalr	-986(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006922:	00002517          	auipc	a0,0x2
    80006926:	16e50513          	addi	a0,a0,366 # 80008a90 <syscallnames+0x3b8>
    8000692a:	ffffa097          	auipc	ra,0xffffa
    8000692e:	c16080e7          	jalr	-1002(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006932:	00002517          	auipc	a0,0x2
    80006936:	17e50513          	addi	a0,a0,382 # 80008ab0 <syscallnames+0x3d8>
    8000693a:	ffffa097          	auipc	ra,0xffffa
    8000693e:	c06080e7          	jalr	-1018(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006942:	00002517          	auipc	a0,0x2
    80006946:	18e50513          	addi	a0,a0,398 # 80008ad0 <syscallnames+0x3f8>
    8000694a:	ffffa097          	auipc	ra,0xffffa
    8000694e:	bf6080e7          	jalr	-1034(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006952:	00002517          	auipc	a0,0x2
    80006956:	19e50513          	addi	a0,a0,414 # 80008af0 <syscallnames+0x418>
    8000695a:	ffffa097          	auipc	ra,0xffffa
    8000695e:	be6080e7          	jalr	-1050(ra) # 80000540 <panic>

0000000080006962 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006962:	7119                	addi	sp,sp,-128
    80006964:	fc86                	sd	ra,120(sp)
    80006966:	f8a2                	sd	s0,112(sp)
    80006968:	f4a6                	sd	s1,104(sp)
    8000696a:	f0ca                	sd	s2,96(sp)
    8000696c:	ecce                	sd	s3,88(sp)
    8000696e:	e8d2                	sd	s4,80(sp)
    80006970:	e4d6                	sd	s5,72(sp)
    80006972:	e0da                	sd	s6,64(sp)
    80006974:	fc5e                	sd	s7,56(sp)
    80006976:	f862                	sd	s8,48(sp)
    80006978:	f466                	sd	s9,40(sp)
    8000697a:	f06a                	sd	s10,32(sp)
    8000697c:	ec6e                	sd	s11,24(sp)
    8000697e:	0100                	addi	s0,sp,128
    80006980:	8aaa                	mv	s5,a0
    80006982:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006984:	00c52d03          	lw	s10,12(a0)
    80006988:	001d1d1b          	slliw	s10,s10,0x1
    8000698c:	1d02                	slli	s10,s10,0x20
    8000698e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006992:	0023e517          	auipc	a0,0x23e
    80006996:	95650513          	addi	a0,a0,-1706 # 802442e8 <disk+0x128>
    8000699a:	ffffa097          	auipc	ra,0xffffa
    8000699e:	37c080e7          	jalr	892(ra) # 80000d16 <acquire>
  for(int i = 0; i < 3; i++){
    800069a2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800069a4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800069a6:	0023eb97          	auipc	s7,0x23e
    800069aa:	81ab8b93          	addi	s7,s7,-2022 # 802441c0 <disk>
  for(int i = 0; i < 3; i++){
    800069ae:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800069b0:	0023ec97          	auipc	s9,0x23e
    800069b4:	938c8c93          	addi	s9,s9,-1736 # 802442e8 <disk+0x128>
    800069b8:	a08d                	j	80006a1a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800069ba:	00fb8733          	add	a4,s7,a5
    800069be:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800069c2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800069c4:	0207c563          	bltz	a5,800069ee <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800069c8:	2905                	addiw	s2,s2,1
    800069ca:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800069cc:	05690c63          	beq	s2,s6,80006a24 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800069d0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800069d2:	0023d717          	auipc	a4,0x23d
    800069d6:	7ee70713          	addi	a4,a4,2030 # 802441c0 <disk>
    800069da:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800069dc:	01874683          	lbu	a3,24(a4)
    800069e0:	fee9                	bnez	a3,800069ba <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800069e2:	2785                	addiw	a5,a5,1
    800069e4:	0705                	addi	a4,a4,1
    800069e6:	fe979be3          	bne	a5,s1,800069dc <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800069ea:	57fd                	li	a5,-1
    800069ec:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800069ee:	01205d63          	blez	s2,80006a08 <virtio_disk_rw+0xa6>
    800069f2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800069f4:	000a2503          	lw	a0,0(s4)
    800069f8:	00000097          	auipc	ra,0x0
    800069fc:	cfe080e7          	jalr	-770(ra) # 800066f6 <free_desc>
      for(int j = 0; j < i; j++)
    80006a00:	2d85                	addiw	s11,s11,1
    80006a02:	0a11                	addi	s4,s4,4
    80006a04:	ff2d98e3          	bne	s11,s2,800069f4 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006a08:	85e6                	mv	a1,s9
    80006a0a:	0023d517          	auipc	a0,0x23d
    80006a0e:	7ce50513          	addi	a0,a0,1998 # 802441d8 <disk+0x18>
    80006a12:	ffffc097          	auipc	ra,0xffffc
    80006a16:	9ae080e7          	jalr	-1618(ra) # 800023c0 <sleep>
  for(int i = 0; i < 3; i++){
    80006a1a:	f8040a13          	addi	s4,s0,-128
{
    80006a1e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006a20:	894e                	mv	s2,s3
    80006a22:	b77d                	j	800069d0 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a24:	f8042503          	lw	a0,-128(s0)
    80006a28:	00a50713          	addi	a4,a0,10
    80006a2c:	0712                	slli	a4,a4,0x4

  if(write)
    80006a2e:	0023d797          	auipc	a5,0x23d
    80006a32:	79278793          	addi	a5,a5,1938 # 802441c0 <disk>
    80006a36:	00e786b3          	add	a3,a5,a4
    80006a3a:	01803633          	snez	a2,s8
    80006a3e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006a40:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006a44:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006a48:	f6070613          	addi	a2,a4,-160
    80006a4c:	6394                	ld	a3,0(a5)
    80006a4e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a50:	00870593          	addi	a1,a4,8
    80006a54:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006a56:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006a58:	0007b803          	ld	a6,0(a5)
    80006a5c:	9642                	add	a2,a2,a6
    80006a5e:	46c1                	li	a3,16
    80006a60:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006a62:	4585                	li	a1,1
    80006a64:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006a68:	f8442683          	lw	a3,-124(s0)
    80006a6c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006a70:	0692                	slli	a3,a3,0x4
    80006a72:	9836                	add	a6,a6,a3
    80006a74:	058a8613          	addi	a2,s5,88
    80006a78:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80006a7c:	0007b803          	ld	a6,0(a5)
    80006a80:	96c2                	add	a3,a3,a6
    80006a82:	40000613          	li	a2,1024
    80006a86:	c690                	sw	a2,8(a3)
  if(write)
    80006a88:	001c3613          	seqz	a2,s8
    80006a8c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006a90:	00166613          	ori	a2,a2,1
    80006a94:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006a98:	f8842603          	lw	a2,-120(s0)
    80006a9c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006aa0:	00250693          	addi	a3,a0,2
    80006aa4:	0692                	slli	a3,a3,0x4
    80006aa6:	96be                	add	a3,a3,a5
    80006aa8:	58fd                	li	a7,-1
    80006aaa:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006aae:	0612                	slli	a2,a2,0x4
    80006ab0:	9832                	add	a6,a6,a2
    80006ab2:	f9070713          	addi	a4,a4,-112
    80006ab6:	973e                	add	a4,a4,a5
    80006ab8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006abc:	6398                	ld	a4,0(a5)
    80006abe:	9732                	add	a4,a4,a2
    80006ac0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006ac2:	4609                	li	a2,2
    80006ac4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006ac8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006acc:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006ad0:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006ad4:	6794                	ld	a3,8(a5)
    80006ad6:	0026d703          	lhu	a4,2(a3)
    80006ada:	8b1d                	andi	a4,a4,7
    80006adc:	0706                	slli	a4,a4,0x1
    80006ade:	96ba                	add	a3,a3,a4
    80006ae0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006ae4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006ae8:	6798                	ld	a4,8(a5)
    80006aea:	00275783          	lhu	a5,2(a4)
    80006aee:	2785                	addiw	a5,a5,1
    80006af0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006af4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006af8:	100017b7          	lui	a5,0x10001
    80006afc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006b00:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006b04:	0023d917          	auipc	s2,0x23d
    80006b08:	7e490913          	addi	s2,s2,2020 # 802442e8 <disk+0x128>
  while(b->disk == 1) {
    80006b0c:	4485                	li	s1,1
    80006b0e:	00b79c63          	bne	a5,a1,80006b26 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006b12:	85ca                	mv	a1,s2
    80006b14:	8556                	mv	a0,s5
    80006b16:	ffffc097          	auipc	ra,0xffffc
    80006b1a:	8aa080e7          	jalr	-1878(ra) # 800023c0 <sleep>
  while(b->disk == 1) {
    80006b1e:	004aa783          	lw	a5,4(s5)
    80006b22:	fe9788e3          	beq	a5,s1,80006b12 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006b26:	f8042903          	lw	s2,-128(s0)
    80006b2a:	00290713          	addi	a4,s2,2
    80006b2e:	0712                	slli	a4,a4,0x4
    80006b30:	0023d797          	auipc	a5,0x23d
    80006b34:	69078793          	addi	a5,a5,1680 # 802441c0 <disk>
    80006b38:	97ba                	add	a5,a5,a4
    80006b3a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006b3e:	0023d997          	auipc	s3,0x23d
    80006b42:	68298993          	addi	s3,s3,1666 # 802441c0 <disk>
    80006b46:	00491713          	slli	a4,s2,0x4
    80006b4a:	0009b783          	ld	a5,0(s3)
    80006b4e:	97ba                	add	a5,a5,a4
    80006b50:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006b54:	854a                	mv	a0,s2
    80006b56:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006b5a:	00000097          	auipc	ra,0x0
    80006b5e:	b9c080e7          	jalr	-1124(ra) # 800066f6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006b62:	8885                	andi	s1,s1,1
    80006b64:	f0ed                	bnez	s1,80006b46 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006b66:	0023d517          	auipc	a0,0x23d
    80006b6a:	78250513          	addi	a0,a0,1922 # 802442e8 <disk+0x128>
    80006b6e:	ffffa097          	auipc	ra,0xffffa
    80006b72:	25c080e7          	jalr	604(ra) # 80000dca <release>
}
    80006b76:	70e6                	ld	ra,120(sp)
    80006b78:	7446                	ld	s0,112(sp)
    80006b7a:	74a6                	ld	s1,104(sp)
    80006b7c:	7906                	ld	s2,96(sp)
    80006b7e:	69e6                	ld	s3,88(sp)
    80006b80:	6a46                	ld	s4,80(sp)
    80006b82:	6aa6                	ld	s5,72(sp)
    80006b84:	6b06                	ld	s6,64(sp)
    80006b86:	7be2                	ld	s7,56(sp)
    80006b88:	7c42                	ld	s8,48(sp)
    80006b8a:	7ca2                	ld	s9,40(sp)
    80006b8c:	7d02                	ld	s10,32(sp)
    80006b8e:	6de2                	ld	s11,24(sp)
    80006b90:	6109                	addi	sp,sp,128
    80006b92:	8082                	ret

0000000080006b94 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006b94:	1101                	addi	sp,sp,-32
    80006b96:	ec06                	sd	ra,24(sp)
    80006b98:	e822                	sd	s0,16(sp)
    80006b9a:	e426                	sd	s1,8(sp)
    80006b9c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006b9e:	0023d497          	auipc	s1,0x23d
    80006ba2:	62248493          	addi	s1,s1,1570 # 802441c0 <disk>
    80006ba6:	0023d517          	auipc	a0,0x23d
    80006baa:	74250513          	addi	a0,a0,1858 # 802442e8 <disk+0x128>
    80006bae:	ffffa097          	auipc	ra,0xffffa
    80006bb2:	168080e7          	jalr	360(ra) # 80000d16 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006bb6:	10001737          	lui	a4,0x10001
    80006bba:	533c                	lw	a5,96(a4)
    80006bbc:	8b8d                	andi	a5,a5,3
    80006bbe:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006bc0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006bc4:	689c                	ld	a5,16(s1)
    80006bc6:	0204d703          	lhu	a4,32(s1)
    80006bca:	0027d783          	lhu	a5,2(a5)
    80006bce:	04f70863          	beq	a4,a5,80006c1e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006bd2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006bd6:	6898                	ld	a4,16(s1)
    80006bd8:	0204d783          	lhu	a5,32(s1)
    80006bdc:	8b9d                	andi	a5,a5,7
    80006bde:	078e                	slli	a5,a5,0x3
    80006be0:	97ba                	add	a5,a5,a4
    80006be2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006be4:	00278713          	addi	a4,a5,2
    80006be8:	0712                	slli	a4,a4,0x4
    80006bea:	9726                	add	a4,a4,s1
    80006bec:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006bf0:	e721                	bnez	a4,80006c38 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006bf2:	0789                	addi	a5,a5,2
    80006bf4:	0792                	slli	a5,a5,0x4
    80006bf6:	97a6                	add	a5,a5,s1
    80006bf8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006bfa:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006bfe:	ffffc097          	auipc	ra,0xffffc
    80006c02:	976080e7          	jalr	-1674(ra) # 80002574 <wakeup>

    disk.used_idx += 1;
    80006c06:	0204d783          	lhu	a5,32(s1)
    80006c0a:	2785                	addiw	a5,a5,1
    80006c0c:	17c2                	slli	a5,a5,0x30
    80006c0e:	93c1                	srli	a5,a5,0x30
    80006c10:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006c14:	6898                	ld	a4,16(s1)
    80006c16:	00275703          	lhu	a4,2(a4)
    80006c1a:	faf71ce3          	bne	a4,a5,80006bd2 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006c1e:	0023d517          	auipc	a0,0x23d
    80006c22:	6ca50513          	addi	a0,a0,1738 # 802442e8 <disk+0x128>
    80006c26:	ffffa097          	auipc	ra,0xffffa
    80006c2a:	1a4080e7          	jalr	420(ra) # 80000dca <release>
}
    80006c2e:	60e2                	ld	ra,24(sp)
    80006c30:	6442                	ld	s0,16(sp)
    80006c32:	64a2                	ld	s1,8(sp)
    80006c34:	6105                	addi	sp,sp,32
    80006c36:	8082                	ret
      panic("virtio_disk_intr status");
    80006c38:	00002517          	auipc	a0,0x2
    80006c3c:	ed050513          	addi	a0,a0,-304 # 80008b08 <syscallnames+0x430>
    80006c40:	ffffa097          	auipc	ra,0xffffa
    80006c44:	900080e7          	jalr	-1792(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
