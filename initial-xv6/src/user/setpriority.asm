
user/_setpriority:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
    if (argc != 3)
   c:	478d                	li	a5,3
   e:	02f50063          	beq	a0,a5,2e <main+0x2e>
    {
        fprintf(2, "Usage: setpriority priority pid\n");
  12:	00001597          	auipc	a1,0x1
  16:	86e58593          	addi	a1,a1,-1938 # 880 <malloc+0xf2>
  1a:	4509                	li	a0,2
  1c:	00000097          	auipc	ra,0x0
  20:	68c080e7          	jalr	1676(ra) # 6a8 <fprintf>
        exit(1);
  24:	4505                	li	a0,1
  26:	00000097          	auipc	ra,0x0
  2a:	2fe080e7          	jalr	766(ra) # 324 <exit>
  2e:	84ae                	mv	s1,a1
    }
   int a =  set_priority(atoi(argv[2]), getpid());
  30:	6988                	ld	a0,16(a1)
  32:	00000097          	auipc	ra,0x0
  36:	1f8080e7          	jalr	504(ra) # 22a <atoi>
  3a:	892a                	mv	s2,a0
  3c:	00000097          	auipc	ra,0x0
  40:	368080e7          	jalr	872(ra) # 3a4 <getpid>
  44:	85aa                	mv	a1,a0
  46:	854a                	mv	a0,s2
  48:	00000097          	auipc	ra,0x0
  4c:	3a4080e7          	jalr	932(ra) # 3ec <set_priority>
  50:	85aa                	mv	a1,a0
   printf("\n%d\n", a);
  52:	00001517          	auipc	a0,0x1
  56:	85650513          	addi	a0,a0,-1962 # 8a8 <malloc+0x11a>
  5a:	00000097          	auipc	ra,0x0
  5e:	67c080e7          	jalr	1660(ra) # 6d6 <printf>
    a =  set_priority(atoi(argv[2]), getpid());
  62:	6888                	ld	a0,16(s1)
  64:	00000097          	auipc	ra,0x0
  68:	1c6080e7          	jalr	454(ra) # 22a <atoi>
  6c:	84aa                	mv	s1,a0
  6e:	00000097          	auipc	ra,0x0
  72:	336080e7          	jalr	822(ra) # 3a4 <getpid>
  76:	85aa                	mv	a1,a0
  78:	8526                	mv	a0,s1
  7a:	00000097          	auipc	ra,0x0
  7e:	372080e7          	jalr	882(ra) # 3ec <set_priority>
  82:	85aa                	mv	a1,a0
        printf("\n%d\n", a);
  84:	00001517          	auipc	a0,0x1
  88:	82450513          	addi	a0,a0,-2012 # 8a8 <malloc+0x11a>
  8c:	00000097          	auipc	ra,0x0
  90:	64a080e7          	jalr	1610(ra) # 6d6 <printf>
    exit(0);
  94:	4501                	li	a0,0
  96:	00000097          	auipc	ra,0x0
  9a:	28e080e7          	jalr	654(ra) # 324 <exit>

000000000000009e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e406                	sd	ra,8(sp)
  a2:	e022                	sd	s0,0(sp)
  a4:	0800                	addi	s0,sp,16
  extern int main();
  main();
  a6:	00000097          	auipc	ra,0x0
  aa:	f5a080e7          	jalr	-166(ra) # 0 <main>
  exit(0);
  ae:	4501                	li	a0,0
  b0:	00000097          	auipc	ra,0x0
  b4:	274080e7          	jalr	628(ra) # 324 <exit>

00000000000000b8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e422                	sd	s0,8(sp)
  bc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  be:	87aa                	mv	a5,a0
  c0:	0585                	addi	a1,a1,1
  c2:	0785                	addi	a5,a5,1
  c4:	fff5c703          	lbu	a4,-1(a1)
  c8:	fee78fa3          	sb	a4,-1(a5)
  cc:	fb75                	bnez	a4,c0 <strcpy+0x8>
    ;
  return os;
}
  ce:	6422                	ld	s0,8(sp)
  d0:	0141                	addi	sp,sp,16
  d2:	8082                	ret

00000000000000d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  da:	00054783          	lbu	a5,0(a0)
  de:	cb91                	beqz	a5,f2 <strcmp+0x1e>
  e0:	0005c703          	lbu	a4,0(a1)
  e4:	00f71763          	bne	a4,a5,f2 <strcmp+0x1e>
    p++, q++;
  e8:	0505                	addi	a0,a0,1
  ea:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ec:	00054783          	lbu	a5,0(a0)
  f0:	fbe5                	bnez	a5,e0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f2:	0005c503          	lbu	a0,0(a1)
}
  f6:	40a7853b          	subw	a0,a5,a0
  fa:	6422                	ld	s0,8(sp)
  fc:	0141                	addi	sp,sp,16
  fe:	8082                	ret

0000000000000100 <strlen>:

uint
strlen(const char *s)
{
 100:	1141                	addi	sp,sp,-16
 102:	e422                	sd	s0,8(sp)
 104:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 106:	00054783          	lbu	a5,0(a0)
 10a:	cf91                	beqz	a5,126 <strlen+0x26>
 10c:	0505                	addi	a0,a0,1
 10e:	87aa                	mv	a5,a0
 110:	4685                	li	a3,1
 112:	9e89                	subw	a3,a3,a0
 114:	00f6853b          	addw	a0,a3,a5
 118:	0785                	addi	a5,a5,1
 11a:	fff7c703          	lbu	a4,-1(a5)
 11e:	fb7d                	bnez	a4,114 <strlen+0x14>
    ;
  return n;
}
 120:	6422                	ld	s0,8(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret
  for(n = 0; s[n]; n++)
 126:	4501                	li	a0,0
 128:	bfe5                	j	120 <strlen+0x20>

000000000000012a <memset>:

void*
memset(void *dst, int c, uint n)
{
 12a:	1141                	addi	sp,sp,-16
 12c:	e422                	sd	s0,8(sp)
 12e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 130:	ca19                	beqz	a2,146 <memset+0x1c>
 132:	87aa                	mv	a5,a0
 134:	1602                	slli	a2,a2,0x20
 136:	9201                	srli	a2,a2,0x20
 138:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 13c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 140:	0785                	addi	a5,a5,1
 142:	fee79de3          	bne	a5,a4,13c <memset+0x12>
  }
  return dst;
}
 146:	6422                	ld	s0,8(sp)
 148:	0141                	addi	sp,sp,16
 14a:	8082                	ret

000000000000014c <strchr>:

char*
strchr(const char *s, char c)
{
 14c:	1141                	addi	sp,sp,-16
 14e:	e422                	sd	s0,8(sp)
 150:	0800                	addi	s0,sp,16
  for(; *s; s++)
 152:	00054783          	lbu	a5,0(a0)
 156:	cb99                	beqz	a5,16c <strchr+0x20>
    if(*s == c)
 158:	00f58763          	beq	a1,a5,166 <strchr+0x1a>
  for(; *s; s++)
 15c:	0505                	addi	a0,a0,1
 15e:	00054783          	lbu	a5,0(a0)
 162:	fbfd                	bnez	a5,158 <strchr+0xc>
      return (char*)s;
  return 0;
 164:	4501                	li	a0,0
}
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret
  return 0;
 16c:	4501                	li	a0,0
 16e:	bfe5                	j	166 <strchr+0x1a>

0000000000000170 <gets>:

char*
gets(char *buf, int max)
{
 170:	711d                	addi	sp,sp,-96
 172:	ec86                	sd	ra,88(sp)
 174:	e8a2                	sd	s0,80(sp)
 176:	e4a6                	sd	s1,72(sp)
 178:	e0ca                	sd	s2,64(sp)
 17a:	fc4e                	sd	s3,56(sp)
 17c:	f852                	sd	s4,48(sp)
 17e:	f456                	sd	s5,40(sp)
 180:	f05a                	sd	s6,32(sp)
 182:	ec5e                	sd	s7,24(sp)
 184:	1080                	addi	s0,sp,96
 186:	8baa                	mv	s7,a0
 188:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18a:	892a                	mv	s2,a0
 18c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 18e:	4aa9                	li	s5,10
 190:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 192:	89a6                	mv	s3,s1
 194:	2485                	addiw	s1,s1,1
 196:	0344d863          	bge	s1,s4,1c6 <gets+0x56>
    cc = read(0, &c, 1);
 19a:	4605                	li	a2,1
 19c:	faf40593          	addi	a1,s0,-81
 1a0:	4501                	li	a0,0
 1a2:	00000097          	auipc	ra,0x0
 1a6:	19a080e7          	jalr	410(ra) # 33c <read>
    if(cc < 1)
 1aa:	00a05e63          	blez	a0,1c6 <gets+0x56>
    buf[i++] = c;
 1ae:	faf44783          	lbu	a5,-81(s0)
 1b2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b6:	01578763          	beq	a5,s5,1c4 <gets+0x54>
 1ba:	0905                	addi	s2,s2,1
 1bc:	fd679be3          	bne	a5,s6,192 <gets+0x22>
  for(i=0; i+1 < max; ){
 1c0:	89a6                	mv	s3,s1
 1c2:	a011                	j	1c6 <gets+0x56>
 1c4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c6:	99de                	add	s3,s3,s7
 1c8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1cc:	855e                	mv	a0,s7
 1ce:	60e6                	ld	ra,88(sp)
 1d0:	6446                	ld	s0,80(sp)
 1d2:	64a6                	ld	s1,72(sp)
 1d4:	6906                	ld	s2,64(sp)
 1d6:	79e2                	ld	s3,56(sp)
 1d8:	7a42                	ld	s4,48(sp)
 1da:	7aa2                	ld	s5,40(sp)
 1dc:	7b02                	ld	s6,32(sp)
 1de:	6be2                	ld	s7,24(sp)
 1e0:	6125                	addi	sp,sp,96
 1e2:	8082                	ret

00000000000001e4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e4:	1101                	addi	sp,sp,-32
 1e6:	ec06                	sd	ra,24(sp)
 1e8:	e822                	sd	s0,16(sp)
 1ea:	e426                	sd	s1,8(sp)
 1ec:	e04a                	sd	s2,0(sp)
 1ee:	1000                	addi	s0,sp,32
 1f0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f2:	4581                	li	a1,0
 1f4:	00000097          	auipc	ra,0x0
 1f8:	170080e7          	jalr	368(ra) # 364 <open>
  if(fd < 0)
 1fc:	02054563          	bltz	a0,226 <stat+0x42>
 200:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 202:	85ca                	mv	a1,s2
 204:	00000097          	auipc	ra,0x0
 208:	178080e7          	jalr	376(ra) # 37c <fstat>
 20c:	892a                	mv	s2,a0
  close(fd);
 20e:	8526                	mv	a0,s1
 210:	00000097          	auipc	ra,0x0
 214:	13c080e7          	jalr	316(ra) # 34c <close>
  return r;
}
 218:	854a                	mv	a0,s2
 21a:	60e2                	ld	ra,24(sp)
 21c:	6442                	ld	s0,16(sp)
 21e:	64a2                	ld	s1,8(sp)
 220:	6902                	ld	s2,0(sp)
 222:	6105                	addi	sp,sp,32
 224:	8082                	ret
    return -1;
 226:	597d                	li	s2,-1
 228:	bfc5                	j	218 <stat+0x34>

000000000000022a <atoi>:

int
atoi(const char *s)
{
 22a:	1141                	addi	sp,sp,-16
 22c:	e422                	sd	s0,8(sp)
 22e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 230:	00054683          	lbu	a3,0(a0)
 234:	fd06879b          	addiw	a5,a3,-48
 238:	0ff7f793          	zext.b	a5,a5
 23c:	4625                	li	a2,9
 23e:	02f66863          	bltu	a2,a5,26e <atoi+0x44>
 242:	872a                	mv	a4,a0
  n = 0;
 244:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 246:	0705                	addi	a4,a4,1
 248:	0025179b          	slliw	a5,a0,0x2
 24c:	9fa9                	addw	a5,a5,a0
 24e:	0017979b          	slliw	a5,a5,0x1
 252:	9fb5                	addw	a5,a5,a3
 254:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 258:	00074683          	lbu	a3,0(a4)
 25c:	fd06879b          	addiw	a5,a3,-48
 260:	0ff7f793          	zext.b	a5,a5
 264:	fef671e3          	bgeu	a2,a5,246 <atoi+0x1c>
  return n;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret
  n = 0;
 26e:	4501                	li	a0,0
 270:	bfe5                	j	268 <atoi+0x3e>

0000000000000272 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 272:	1141                	addi	sp,sp,-16
 274:	e422                	sd	s0,8(sp)
 276:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 278:	02b57463          	bgeu	a0,a1,2a0 <memmove+0x2e>
    while(n-- > 0)
 27c:	00c05f63          	blez	a2,29a <memmove+0x28>
 280:	1602                	slli	a2,a2,0x20
 282:	9201                	srli	a2,a2,0x20
 284:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 288:	872a                	mv	a4,a0
      *dst++ = *src++;
 28a:	0585                	addi	a1,a1,1
 28c:	0705                	addi	a4,a4,1
 28e:	fff5c683          	lbu	a3,-1(a1)
 292:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 296:	fee79ae3          	bne	a5,a4,28a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret
    dst += n;
 2a0:	00c50733          	add	a4,a0,a2
    src += n;
 2a4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2a6:	fec05ae3          	blez	a2,29a <memmove+0x28>
 2aa:	fff6079b          	addiw	a5,a2,-1
 2ae:	1782                	slli	a5,a5,0x20
 2b0:	9381                	srli	a5,a5,0x20
 2b2:	fff7c793          	not	a5,a5
 2b6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b8:	15fd                	addi	a1,a1,-1
 2ba:	177d                	addi	a4,a4,-1
 2bc:	0005c683          	lbu	a3,0(a1)
 2c0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c4:	fee79ae3          	bne	a5,a4,2b8 <memmove+0x46>
 2c8:	bfc9                	j	29a <memmove+0x28>

00000000000002ca <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e422                	sd	s0,8(sp)
 2ce:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d0:	ca05                	beqz	a2,300 <memcmp+0x36>
 2d2:	fff6069b          	addiw	a3,a2,-1
 2d6:	1682                	slli	a3,a3,0x20
 2d8:	9281                	srli	a3,a3,0x20
 2da:	0685                	addi	a3,a3,1
 2dc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2de:	00054783          	lbu	a5,0(a0)
 2e2:	0005c703          	lbu	a4,0(a1)
 2e6:	00e79863          	bne	a5,a4,2f6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ea:	0505                	addi	a0,a0,1
    p2++;
 2ec:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ee:	fed518e3          	bne	a0,a3,2de <memcmp+0x14>
  }
  return 0;
 2f2:	4501                	li	a0,0
 2f4:	a019                	j	2fa <memcmp+0x30>
      return *p1 - *p2;
 2f6:	40e7853b          	subw	a0,a5,a4
}
 2fa:	6422                	ld	s0,8(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret
  return 0;
 300:	4501                	li	a0,0
 302:	bfe5                	j	2fa <memcmp+0x30>

0000000000000304 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 304:	1141                	addi	sp,sp,-16
 306:	e406                	sd	ra,8(sp)
 308:	e022                	sd	s0,0(sp)
 30a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 30c:	00000097          	auipc	ra,0x0
 310:	f66080e7          	jalr	-154(ra) # 272 <memmove>
}
 314:	60a2                	ld	ra,8(sp)
 316:	6402                	ld	s0,0(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 31c:	4885                	li	a7,1
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <exit>:
.global exit
exit:
 li a7, SYS_exit
 324:	4889                	li	a7,2
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <wait>:
.global wait
wait:
 li a7, SYS_wait
 32c:	488d                	li	a7,3
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 334:	4891                	li	a7,4
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <read>:
.global read
read:
 li a7, SYS_read
 33c:	4895                	li	a7,5
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <write>:
.global write
write:
 li a7, SYS_write
 344:	48c1                	li	a7,16
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <close>:
.global close
close:
 li a7, SYS_close
 34c:	48d5                	li	a7,21
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <kill>:
.global kill
kill:
 li a7, SYS_kill
 354:	4899                	li	a7,6
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <exec>:
.global exec
exec:
 li a7, SYS_exec
 35c:	489d                	li	a7,7
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <open>:
.global open
open:
 li a7, SYS_open
 364:	48bd                	li	a7,15
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 36c:	48c5                	li	a7,17
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 374:	48c9                	li	a7,18
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 37c:	48a1                	li	a7,8
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <link>:
.global link
link:
 li a7, SYS_link
 384:	48cd                	li	a7,19
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 38c:	48d1                	li	a7,20
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 394:	48a5                	li	a7,9
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <dup>:
.global dup
dup:
 li a7, SYS_dup
 39c:	48a9                	li	a7,10
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a4:	48ad                	li	a7,11
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3ac:	48b1                	li	a7,12
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b4:	48b5                	li	a7,13
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3bc:	48b9                	li	a7,14
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3c4:	48d9                	li	a7,22
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 3cc:	48dd                	li	a7,23
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 3d4:	48e1                	li	a7,24
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 3dc:	48e5                	li	a7,25
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3e4:	48e9                	li	a7,26
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 3ec:	48ed                	li	a7,27
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3f4:	48f1                	li	a7,28
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3fc:	1101                	addi	sp,sp,-32
 3fe:	ec06                	sd	ra,24(sp)
 400:	e822                	sd	s0,16(sp)
 402:	1000                	addi	s0,sp,32
 404:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 408:	4605                	li	a2,1
 40a:	fef40593          	addi	a1,s0,-17
 40e:	00000097          	auipc	ra,0x0
 412:	f36080e7          	jalr	-202(ra) # 344 <write>
}
 416:	60e2                	ld	ra,24(sp)
 418:	6442                	ld	s0,16(sp)
 41a:	6105                	addi	sp,sp,32
 41c:	8082                	ret

000000000000041e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 41e:	7139                	addi	sp,sp,-64
 420:	fc06                	sd	ra,56(sp)
 422:	f822                	sd	s0,48(sp)
 424:	f426                	sd	s1,40(sp)
 426:	f04a                	sd	s2,32(sp)
 428:	ec4e                	sd	s3,24(sp)
 42a:	0080                	addi	s0,sp,64
 42c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 42e:	c299                	beqz	a3,434 <printint+0x16>
 430:	0805c963          	bltz	a1,4c2 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 434:	2581                	sext.w	a1,a1
  neg = 0;
 436:	4881                	li	a7,0
 438:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 43c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 43e:	2601                	sext.w	a2,a2
 440:	00000517          	auipc	a0,0x0
 444:	4d050513          	addi	a0,a0,1232 # 910 <digits>
 448:	883a                	mv	a6,a4
 44a:	2705                	addiw	a4,a4,1
 44c:	02c5f7bb          	remuw	a5,a1,a2
 450:	1782                	slli	a5,a5,0x20
 452:	9381                	srli	a5,a5,0x20
 454:	97aa                	add	a5,a5,a0
 456:	0007c783          	lbu	a5,0(a5)
 45a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 45e:	0005879b          	sext.w	a5,a1
 462:	02c5d5bb          	divuw	a1,a1,a2
 466:	0685                	addi	a3,a3,1
 468:	fec7f0e3          	bgeu	a5,a2,448 <printint+0x2a>
  if(neg)
 46c:	00088c63          	beqz	a7,484 <printint+0x66>
    buf[i++] = '-';
 470:	fd070793          	addi	a5,a4,-48
 474:	00878733          	add	a4,a5,s0
 478:	02d00793          	li	a5,45
 47c:	fef70823          	sb	a5,-16(a4)
 480:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 484:	02e05863          	blez	a4,4b4 <printint+0x96>
 488:	fc040793          	addi	a5,s0,-64
 48c:	00e78933          	add	s2,a5,a4
 490:	fff78993          	addi	s3,a5,-1
 494:	99ba                	add	s3,s3,a4
 496:	377d                	addiw	a4,a4,-1
 498:	1702                	slli	a4,a4,0x20
 49a:	9301                	srli	a4,a4,0x20
 49c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4a0:	fff94583          	lbu	a1,-1(s2)
 4a4:	8526                	mv	a0,s1
 4a6:	00000097          	auipc	ra,0x0
 4aa:	f56080e7          	jalr	-170(ra) # 3fc <putc>
  while(--i >= 0)
 4ae:	197d                	addi	s2,s2,-1
 4b0:	ff3918e3          	bne	s2,s3,4a0 <printint+0x82>
}
 4b4:	70e2                	ld	ra,56(sp)
 4b6:	7442                	ld	s0,48(sp)
 4b8:	74a2                	ld	s1,40(sp)
 4ba:	7902                	ld	s2,32(sp)
 4bc:	69e2                	ld	s3,24(sp)
 4be:	6121                	addi	sp,sp,64
 4c0:	8082                	ret
    x = -xx;
 4c2:	40b005bb          	negw	a1,a1
    neg = 1;
 4c6:	4885                	li	a7,1
    x = -xx;
 4c8:	bf85                	j	438 <printint+0x1a>

00000000000004ca <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ca:	7119                	addi	sp,sp,-128
 4cc:	fc86                	sd	ra,120(sp)
 4ce:	f8a2                	sd	s0,112(sp)
 4d0:	f4a6                	sd	s1,104(sp)
 4d2:	f0ca                	sd	s2,96(sp)
 4d4:	ecce                	sd	s3,88(sp)
 4d6:	e8d2                	sd	s4,80(sp)
 4d8:	e4d6                	sd	s5,72(sp)
 4da:	e0da                	sd	s6,64(sp)
 4dc:	fc5e                	sd	s7,56(sp)
 4de:	f862                	sd	s8,48(sp)
 4e0:	f466                	sd	s9,40(sp)
 4e2:	f06a                	sd	s10,32(sp)
 4e4:	ec6e                	sd	s11,24(sp)
 4e6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e8:	0005c903          	lbu	s2,0(a1)
 4ec:	18090f63          	beqz	s2,68a <vprintf+0x1c0>
 4f0:	8aaa                	mv	s5,a0
 4f2:	8b32                	mv	s6,a2
 4f4:	00158493          	addi	s1,a1,1
  state = 0;
 4f8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4fa:	02500a13          	li	s4,37
 4fe:	4c55                	li	s8,21
 500:	00000c97          	auipc	s9,0x0
 504:	3b8c8c93          	addi	s9,s9,952 # 8b8 <malloc+0x12a>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 508:	02800d93          	li	s11,40
  putc(fd, 'x');
 50c:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 50e:	00000b97          	auipc	s7,0x0
 512:	402b8b93          	addi	s7,s7,1026 # 910 <digits>
 516:	a839                	j	534 <vprintf+0x6a>
        putc(fd, c);
 518:	85ca                	mv	a1,s2
 51a:	8556                	mv	a0,s5
 51c:	00000097          	auipc	ra,0x0
 520:	ee0080e7          	jalr	-288(ra) # 3fc <putc>
 524:	a019                	j	52a <vprintf+0x60>
    } else if(state == '%'){
 526:	01498d63          	beq	s3,s4,540 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 52a:	0485                	addi	s1,s1,1
 52c:	fff4c903          	lbu	s2,-1(s1)
 530:	14090d63          	beqz	s2,68a <vprintf+0x1c0>
    if(state == 0){
 534:	fe0999e3          	bnez	s3,526 <vprintf+0x5c>
      if(c == '%'){
 538:	ff4910e3          	bne	s2,s4,518 <vprintf+0x4e>
        state = '%';
 53c:	89d2                	mv	s3,s4
 53e:	b7f5                	j	52a <vprintf+0x60>
      if(c == 'd'){
 540:	11490c63          	beq	s2,s4,658 <vprintf+0x18e>
 544:	f9d9079b          	addiw	a5,s2,-99
 548:	0ff7f793          	zext.b	a5,a5
 54c:	10fc6e63          	bltu	s8,a5,668 <vprintf+0x19e>
 550:	f9d9079b          	addiw	a5,s2,-99
 554:	0ff7f713          	zext.b	a4,a5
 558:	10ec6863          	bltu	s8,a4,668 <vprintf+0x19e>
 55c:	00271793          	slli	a5,a4,0x2
 560:	97e6                	add	a5,a5,s9
 562:	439c                	lw	a5,0(a5)
 564:	97e6                	add	a5,a5,s9
 566:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 568:	008b0913          	addi	s2,s6,8
 56c:	4685                	li	a3,1
 56e:	4629                	li	a2,10
 570:	000b2583          	lw	a1,0(s6)
 574:	8556                	mv	a0,s5
 576:	00000097          	auipc	ra,0x0
 57a:	ea8080e7          	jalr	-344(ra) # 41e <printint>
 57e:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 580:	4981                	li	s3,0
 582:	b765                	j	52a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 584:	008b0913          	addi	s2,s6,8
 588:	4681                	li	a3,0
 58a:	4629                	li	a2,10
 58c:	000b2583          	lw	a1,0(s6)
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	e8c080e7          	jalr	-372(ra) # 41e <printint>
 59a:	8b4a                	mv	s6,s2
      state = 0;
 59c:	4981                	li	s3,0
 59e:	b771                	j	52a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5a0:	008b0913          	addi	s2,s6,8
 5a4:	4681                	li	a3,0
 5a6:	866a                	mv	a2,s10
 5a8:	000b2583          	lw	a1,0(s6)
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	e70080e7          	jalr	-400(ra) # 41e <printint>
 5b6:	8b4a                	mv	s6,s2
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	bf85                	j	52a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5bc:	008b0793          	addi	a5,s6,8
 5c0:	f8f43423          	sd	a5,-120(s0)
 5c4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5c8:	03000593          	li	a1,48
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	e2e080e7          	jalr	-466(ra) # 3fc <putc>
  putc(fd, 'x');
 5d6:	07800593          	li	a1,120
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	e20080e7          	jalr	-480(ra) # 3fc <putc>
 5e4:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e6:	03c9d793          	srli	a5,s3,0x3c
 5ea:	97de                	add	a5,a5,s7
 5ec:	0007c583          	lbu	a1,0(a5)
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	e0a080e7          	jalr	-502(ra) # 3fc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5fa:	0992                	slli	s3,s3,0x4
 5fc:	397d                	addiw	s2,s2,-1
 5fe:	fe0914e3          	bnez	s2,5e6 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 602:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 606:	4981                	li	s3,0
 608:	b70d                	j	52a <vprintf+0x60>
        s = va_arg(ap, char*);
 60a:	008b0913          	addi	s2,s6,8
 60e:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 612:	02098163          	beqz	s3,634 <vprintf+0x16a>
        while(*s != 0){
 616:	0009c583          	lbu	a1,0(s3)
 61a:	c5ad                	beqz	a1,684 <vprintf+0x1ba>
          putc(fd, *s);
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	dde080e7          	jalr	-546(ra) # 3fc <putc>
          s++;
 626:	0985                	addi	s3,s3,1
        while(*s != 0){
 628:	0009c583          	lbu	a1,0(s3)
 62c:	f9e5                	bnez	a1,61c <vprintf+0x152>
        s = va_arg(ap, char*);
 62e:	8b4a                	mv	s6,s2
      state = 0;
 630:	4981                	li	s3,0
 632:	bde5                	j	52a <vprintf+0x60>
          s = "(null)";
 634:	00000997          	auipc	s3,0x0
 638:	27c98993          	addi	s3,s3,636 # 8b0 <malloc+0x122>
        while(*s != 0){
 63c:	85ee                	mv	a1,s11
 63e:	bff9                	j	61c <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 640:	008b0913          	addi	s2,s6,8
 644:	000b4583          	lbu	a1,0(s6)
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	db2080e7          	jalr	-590(ra) # 3fc <putc>
 652:	8b4a                	mv	s6,s2
      state = 0;
 654:	4981                	li	s3,0
 656:	bdd1                	j	52a <vprintf+0x60>
        putc(fd, c);
 658:	85d2                	mv	a1,s4
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	da0080e7          	jalr	-608(ra) # 3fc <putc>
      state = 0;
 664:	4981                	li	s3,0
 666:	b5d1                	j	52a <vprintf+0x60>
        putc(fd, '%');
 668:	85d2                	mv	a1,s4
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	d90080e7          	jalr	-624(ra) # 3fc <putc>
        putc(fd, c);
 674:	85ca                	mv	a1,s2
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	d84080e7          	jalr	-636(ra) # 3fc <putc>
      state = 0;
 680:	4981                	li	s3,0
 682:	b565                	j	52a <vprintf+0x60>
        s = va_arg(ap, char*);
 684:	8b4a                	mv	s6,s2
      state = 0;
 686:	4981                	li	s3,0
 688:	b54d                	j	52a <vprintf+0x60>
    }
  }
}
 68a:	70e6                	ld	ra,120(sp)
 68c:	7446                	ld	s0,112(sp)
 68e:	74a6                	ld	s1,104(sp)
 690:	7906                	ld	s2,96(sp)
 692:	69e6                	ld	s3,88(sp)
 694:	6a46                	ld	s4,80(sp)
 696:	6aa6                	ld	s5,72(sp)
 698:	6b06                	ld	s6,64(sp)
 69a:	7be2                	ld	s7,56(sp)
 69c:	7c42                	ld	s8,48(sp)
 69e:	7ca2                	ld	s9,40(sp)
 6a0:	7d02                	ld	s10,32(sp)
 6a2:	6de2                	ld	s11,24(sp)
 6a4:	6109                	addi	sp,sp,128
 6a6:	8082                	ret

00000000000006a8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6a8:	715d                	addi	sp,sp,-80
 6aa:	ec06                	sd	ra,24(sp)
 6ac:	e822                	sd	s0,16(sp)
 6ae:	1000                	addi	s0,sp,32
 6b0:	e010                	sd	a2,0(s0)
 6b2:	e414                	sd	a3,8(s0)
 6b4:	e818                	sd	a4,16(s0)
 6b6:	ec1c                	sd	a5,24(s0)
 6b8:	03043023          	sd	a6,32(s0)
 6bc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6c0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6c4:	8622                	mv	a2,s0
 6c6:	00000097          	auipc	ra,0x0
 6ca:	e04080e7          	jalr	-508(ra) # 4ca <vprintf>
}
 6ce:	60e2                	ld	ra,24(sp)
 6d0:	6442                	ld	s0,16(sp)
 6d2:	6161                	addi	sp,sp,80
 6d4:	8082                	ret

00000000000006d6 <printf>:

void
printf(const char *fmt, ...)
{
 6d6:	711d                	addi	sp,sp,-96
 6d8:	ec06                	sd	ra,24(sp)
 6da:	e822                	sd	s0,16(sp)
 6dc:	1000                	addi	s0,sp,32
 6de:	e40c                	sd	a1,8(s0)
 6e0:	e810                	sd	a2,16(s0)
 6e2:	ec14                	sd	a3,24(s0)
 6e4:	f018                	sd	a4,32(s0)
 6e6:	f41c                	sd	a5,40(s0)
 6e8:	03043823          	sd	a6,48(s0)
 6ec:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6f0:	00840613          	addi	a2,s0,8
 6f4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f8:	85aa                	mv	a1,a0
 6fa:	4505                	li	a0,1
 6fc:	00000097          	auipc	ra,0x0
 700:	dce080e7          	jalr	-562(ra) # 4ca <vprintf>
}
 704:	60e2                	ld	ra,24(sp)
 706:	6442                	ld	s0,16(sp)
 708:	6125                	addi	sp,sp,96
 70a:	8082                	ret

000000000000070c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 70c:	1141                	addi	sp,sp,-16
 70e:	e422                	sd	s0,8(sp)
 710:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 712:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 716:	00001797          	auipc	a5,0x1
 71a:	8ea7b783          	ld	a5,-1814(a5) # 1000 <freep>
 71e:	a02d                	j	748 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 720:	4618                	lw	a4,8(a2)
 722:	9f2d                	addw	a4,a4,a1
 724:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 728:	6398                	ld	a4,0(a5)
 72a:	6310                	ld	a2,0(a4)
 72c:	a83d                	j	76a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 72e:	ff852703          	lw	a4,-8(a0)
 732:	9f31                	addw	a4,a4,a2
 734:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 736:	ff053683          	ld	a3,-16(a0)
 73a:	a091                	j	77e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73c:	6398                	ld	a4,0(a5)
 73e:	00e7e463          	bltu	a5,a4,746 <free+0x3a>
 742:	00e6ea63          	bltu	a3,a4,756 <free+0x4a>
{
 746:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 748:	fed7fae3          	bgeu	a5,a3,73c <free+0x30>
 74c:	6398                	ld	a4,0(a5)
 74e:	00e6e463          	bltu	a3,a4,756 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 752:	fee7eae3          	bltu	a5,a4,746 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 756:	ff852583          	lw	a1,-8(a0)
 75a:	6390                	ld	a2,0(a5)
 75c:	02059813          	slli	a6,a1,0x20
 760:	01c85713          	srli	a4,a6,0x1c
 764:	9736                	add	a4,a4,a3
 766:	fae60de3          	beq	a2,a4,720 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 76a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 76e:	4790                	lw	a2,8(a5)
 770:	02061593          	slli	a1,a2,0x20
 774:	01c5d713          	srli	a4,a1,0x1c
 778:	973e                	add	a4,a4,a5
 77a:	fae68ae3          	beq	a3,a4,72e <free+0x22>
    p->s.ptr = bp->s.ptr;
 77e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 780:	00001717          	auipc	a4,0x1
 784:	88f73023          	sd	a5,-1920(a4) # 1000 <freep>
}
 788:	6422                	ld	s0,8(sp)
 78a:	0141                	addi	sp,sp,16
 78c:	8082                	ret

000000000000078e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 78e:	7139                	addi	sp,sp,-64
 790:	fc06                	sd	ra,56(sp)
 792:	f822                	sd	s0,48(sp)
 794:	f426                	sd	s1,40(sp)
 796:	f04a                	sd	s2,32(sp)
 798:	ec4e                	sd	s3,24(sp)
 79a:	e852                	sd	s4,16(sp)
 79c:	e456                	sd	s5,8(sp)
 79e:	e05a                	sd	s6,0(sp)
 7a0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7a2:	02051493          	slli	s1,a0,0x20
 7a6:	9081                	srli	s1,s1,0x20
 7a8:	04bd                	addi	s1,s1,15
 7aa:	8091                	srli	s1,s1,0x4
 7ac:	0014899b          	addiw	s3,s1,1
 7b0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7b2:	00001517          	auipc	a0,0x1
 7b6:	84e53503          	ld	a0,-1970(a0) # 1000 <freep>
 7ba:	c515                	beqz	a0,7e6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7be:	4798                	lw	a4,8(a5)
 7c0:	02977f63          	bgeu	a4,s1,7fe <malloc+0x70>
 7c4:	8a4e                	mv	s4,s3
 7c6:	0009871b          	sext.w	a4,s3
 7ca:	6685                	lui	a3,0x1
 7cc:	00d77363          	bgeu	a4,a3,7d2 <malloc+0x44>
 7d0:	6a05                	lui	s4,0x1
 7d2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7da:	00001917          	auipc	s2,0x1
 7de:	82690913          	addi	s2,s2,-2010 # 1000 <freep>
  if(p == (char*)-1)
 7e2:	5afd                	li	s5,-1
 7e4:	a895                	j	858 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7e6:	00001797          	auipc	a5,0x1
 7ea:	82a78793          	addi	a5,a5,-2006 # 1010 <base>
 7ee:	00001717          	auipc	a4,0x1
 7f2:	80f73923          	sd	a5,-2030(a4) # 1000 <freep>
 7f6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7f8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7fc:	b7e1                	j	7c4 <malloc+0x36>
      if(p->s.size == nunits)
 7fe:	02e48c63          	beq	s1,a4,836 <malloc+0xa8>
        p->s.size -= nunits;
 802:	4137073b          	subw	a4,a4,s3
 806:	c798                	sw	a4,8(a5)
        p += p->s.size;
 808:	02071693          	slli	a3,a4,0x20
 80c:	01c6d713          	srli	a4,a3,0x1c
 810:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 812:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 816:	00000717          	auipc	a4,0x0
 81a:	7ea73523          	sd	a0,2026(a4) # 1000 <freep>
      return (void*)(p + 1);
 81e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 822:	70e2                	ld	ra,56(sp)
 824:	7442                	ld	s0,48(sp)
 826:	74a2                	ld	s1,40(sp)
 828:	7902                	ld	s2,32(sp)
 82a:	69e2                	ld	s3,24(sp)
 82c:	6a42                	ld	s4,16(sp)
 82e:	6aa2                	ld	s5,8(sp)
 830:	6b02                	ld	s6,0(sp)
 832:	6121                	addi	sp,sp,64
 834:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 836:	6398                	ld	a4,0(a5)
 838:	e118                	sd	a4,0(a0)
 83a:	bff1                	j	816 <malloc+0x88>
  hp->s.size = nu;
 83c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 840:	0541                	addi	a0,a0,16
 842:	00000097          	auipc	ra,0x0
 846:	eca080e7          	jalr	-310(ra) # 70c <free>
  return freep;
 84a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 84e:	d971                	beqz	a0,822 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 850:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 852:	4798                	lw	a4,8(a5)
 854:	fa9775e3          	bgeu	a4,s1,7fe <malloc+0x70>
    if(p == freep)
 858:	00093703          	ld	a4,0(s2)
 85c:	853e                	mv	a0,a5
 85e:	fef719e3          	bne	a4,a5,850 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 862:	8552                	mv	a0,s4
 864:	00000097          	auipc	ra,0x0
 868:	b48080e7          	jalr	-1208(ra) # 3ac <sbrk>
  if(p == (char*)-1)
 86c:	fd5518e3          	bne	a0,s5,83c <malloc+0xae>
        return 0;
 870:	4501                	li	a0,0
 872:	bf45                	j	822 <malloc+0x94>
