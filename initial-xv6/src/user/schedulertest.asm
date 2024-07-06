
user/_schedulertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#define NFORK 10
#define IO 0

int main()
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	0080                	addi	s0,sp,64
    int n, pid;
    int wtime, rtime;
    int twtime = 0, trtime = 0;
    for (n = 0; n < NFORK; n++)
  10:	4481                	li	s1,0
            printf("Process %d finished\n", n);
            exit(0);
        }
        else
        {
            printf("Process %d PID %d started\n",n,pid);
  12:	00001a17          	auipc	s4,0x1
  16:	8e6a0a13          	addi	s4,s4,-1818 # 8f8 <malloc+0x102>
    for (n = 0; n < NFORK; n++)
  1a:	49a9                	li	s3,10
        pid = fork();
  1c:	00000097          	auipc	ra,0x0
  20:	368080e7          	jalr	872(ra) # 384 <fork>
  24:	892a                	mv	s2,a0
        if (pid < 0)
  26:	02054763          	bltz	a0,54 <main+0x54>
        if (pid == 0)
  2a:	c939                	beqz	a0,80 <main+0x80>
            printf("Process %d PID %d started\n",n,pid);
  2c:	862a                	mv	a2,a0
  2e:	85a6                	mv	a1,s1
  30:	8552                	mv	a0,s4
  32:	00000097          	auipc	ra,0x0
  36:	70c080e7          	jalr	1804(ra) # 73e <printf>
#ifdef PBS
            set_priority(80, pid); // Will only matter for PBS, set lower priority for IO bound processes
  3a:	85ca                	mv	a1,s2
  3c:	05000513          	li	a0,80
  40:	00000097          	auipc	ra,0x0
  44:	414080e7          	jalr	1044(ra) # 454 <set_priority>
    for (n = 0; n < NFORK; n++)
  48:	2485                	addiw	s1,s1,1
  4a:	fd3499e3          	bne	s1,s3,1c <main+0x1c>
  4e:	4901                	li	s2,0
  50:	4981                	li	s3,0
  52:	a071                	j	de <main+0xde>
#endif
        }
    }
    for (; n > 0; n--)
  54:	fe904de3          	bgtz	s1,4e <main+0x4e>
  58:	4901                	li	s2,0
  5a:	4981                	li	s3,0
        {
            trtime += rtime;
            twtime += wtime;
        }
    }
    printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  5c:	45a9                	li	a1,10
  5e:	02b9c63b          	divw	a2,s3,a1
  62:	02b945bb          	divw	a1,s2,a1
  66:	00001517          	auipc	a0,0x1
  6a:	8b250513          	addi	a0,a0,-1870 # 918 <malloc+0x122>
  6e:	00000097          	auipc	ra,0x0
  72:	6d0080e7          	jalr	1744(ra) # 73e <printf>
    exit(0);
  76:	4501                	li	a0,0
  78:	00000097          	auipc	ra,0x0
  7c:	314080e7          	jalr	788(ra) # 38c <exit>
            if (n < IO)
  80:	0404c663          	bltz	s1,cc <main+0xcc>
                for (volatile int i = 0; i < 1000000000; i++)
  84:	fc042223          	sw	zero,-60(s0)
  88:	fc442703          	lw	a4,-60(s0)
  8c:	2701                	sext.w	a4,a4
  8e:	3b9ad7b7          	lui	a5,0x3b9ad
  92:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <base+0x3b9ab9ef>
  96:	00e7cd63          	blt	a5,a4,b0 <main+0xb0>
  9a:	873e                	mv	a4,a5
  9c:	fc442783          	lw	a5,-60(s0)
  a0:	2785                	addiw	a5,a5,1
  a2:	fcf42223          	sw	a5,-60(s0)
  a6:	fc442783          	lw	a5,-60(s0)
  aa:	2781                	sext.w	a5,a5
  ac:	fef758e3          	bge	a4,a5,9c <main+0x9c>
            printf("Process %d finished\n", n);
  b0:	85a6                	mv	a1,s1
  b2:	00001517          	auipc	a0,0x1
  b6:	82e50513          	addi	a0,a0,-2002 # 8e0 <malloc+0xea>
  ba:	00000097          	auipc	ra,0x0
  be:	684080e7          	jalr	1668(ra) # 73e <printf>
            exit(0);
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	2c8080e7          	jalr	712(ra) # 38c <exit>
                sleep(200); // IO bound processes
  cc:	0c800513          	li	a0,200
  d0:	00000097          	auipc	ra,0x0
  d4:	34c080e7          	jalr	844(ra) # 41c <sleep>
  d8:	bfe1                	j	b0 <main+0xb0>
    for (; n > 0; n--)
  da:	34fd                	addiw	s1,s1,-1
  dc:	d0c1                	beqz	s1,5c <main+0x5c>
        if (waitx(0, &wtime, &rtime) >= 0)
  de:	fc840613          	addi	a2,s0,-56
  e2:	fcc40593          	addi	a1,s0,-52
  e6:	4501                	li	a0,0
  e8:	00000097          	auipc	ra,0x0
  ec:	374080e7          	jalr	884(ra) # 45c <waitx>
  f0:	fe0545e3          	bltz	a0,da <main+0xda>
            trtime += rtime;
  f4:	fc842783          	lw	a5,-56(s0)
  f8:	0127893b          	addw	s2,a5,s2
            twtime += wtime;
  fc:	fcc42783          	lw	a5,-52(s0)
 100:	013789bb          	addw	s3,a5,s3
 104:	bfd9                	j	da <main+0xda>

0000000000000106 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 106:	1141                	addi	sp,sp,-16
 108:	e406                	sd	ra,8(sp)
 10a:	e022                	sd	s0,0(sp)
 10c:	0800                	addi	s0,sp,16
  extern int main();
  main();
 10e:	00000097          	auipc	ra,0x0
 112:	ef2080e7          	jalr	-270(ra) # 0 <main>
  exit(0);
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	274080e7          	jalr	628(ra) # 38c <exit>

0000000000000120 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 120:	1141                	addi	sp,sp,-16
 122:	e422                	sd	s0,8(sp)
 124:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 126:	87aa                	mv	a5,a0
 128:	0585                	addi	a1,a1,1
 12a:	0785                	addi	a5,a5,1
 12c:	fff5c703          	lbu	a4,-1(a1)
 130:	fee78fa3          	sb	a4,-1(a5)
 134:	fb75                	bnez	a4,128 <strcpy+0x8>
    ;
  return os;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 142:	00054783          	lbu	a5,0(a0)
 146:	cb91                	beqz	a5,15a <strcmp+0x1e>
 148:	0005c703          	lbu	a4,0(a1)
 14c:	00f71763          	bne	a4,a5,15a <strcmp+0x1e>
    p++, q++;
 150:	0505                	addi	a0,a0,1
 152:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 154:	00054783          	lbu	a5,0(a0)
 158:	fbe5                	bnez	a5,148 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 15a:	0005c503          	lbu	a0,0(a1)
}
 15e:	40a7853b          	subw	a0,a5,a0
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strlen>:

uint
strlen(const char *s)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cf91                	beqz	a5,18e <strlen+0x26>
 174:	0505                	addi	a0,a0,1
 176:	87aa                	mv	a5,a0
 178:	4685                	li	a3,1
 17a:	9e89                	subw	a3,a3,a0
 17c:	00f6853b          	addw	a0,a3,a5
 180:	0785                	addi	a5,a5,1
 182:	fff7c703          	lbu	a4,-1(a5)
 186:	fb7d                	bnez	a4,17c <strlen+0x14>
    ;
  return n;
}
 188:	6422                	ld	s0,8(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret
  for(n = 0; s[n]; n++)
 18e:	4501                	li	a0,0
 190:	bfe5                	j	188 <strlen+0x20>

0000000000000192 <memset>:

void*
memset(void *dst, int c, uint n)
{
 192:	1141                	addi	sp,sp,-16
 194:	e422                	sd	s0,8(sp)
 196:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 198:	ca19                	beqz	a2,1ae <memset+0x1c>
 19a:	87aa                	mv	a5,a0
 19c:	1602                	slli	a2,a2,0x20
 19e:	9201                	srli	a2,a2,0x20
 1a0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1a4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a8:	0785                	addi	a5,a5,1
 1aa:	fee79de3          	bne	a5,a4,1a4 <memset+0x12>
  }
  return dst;
}
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strchr>:

char*
strchr(const char *s, char c)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cb99                	beqz	a5,1d4 <strchr+0x20>
    if(*s == c)
 1c0:	00f58763          	beq	a1,a5,1ce <strchr+0x1a>
  for(; *s; s++)
 1c4:	0505                	addi	a0,a0,1
 1c6:	00054783          	lbu	a5,0(a0)
 1ca:	fbfd                	bnez	a5,1c0 <strchr+0xc>
      return (char*)s;
  return 0;
 1cc:	4501                	li	a0,0
}
 1ce:	6422                	ld	s0,8(sp)
 1d0:	0141                	addi	sp,sp,16
 1d2:	8082                	ret
  return 0;
 1d4:	4501                	li	a0,0
 1d6:	bfe5                	j	1ce <strchr+0x1a>

00000000000001d8 <gets>:

char*
gets(char *buf, int max)
{
 1d8:	711d                	addi	sp,sp,-96
 1da:	ec86                	sd	ra,88(sp)
 1dc:	e8a2                	sd	s0,80(sp)
 1de:	e4a6                	sd	s1,72(sp)
 1e0:	e0ca                	sd	s2,64(sp)
 1e2:	fc4e                	sd	s3,56(sp)
 1e4:	f852                	sd	s4,48(sp)
 1e6:	f456                	sd	s5,40(sp)
 1e8:	f05a                	sd	s6,32(sp)
 1ea:	ec5e                	sd	s7,24(sp)
 1ec:	1080                	addi	s0,sp,96
 1ee:	8baa                	mv	s7,a0
 1f0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f2:	892a                	mv	s2,a0
 1f4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1f6:	4aa9                	li	s5,10
 1f8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1fa:	89a6                	mv	s3,s1
 1fc:	2485                	addiw	s1,s1,1
 1fe:	0344d863          	bge	s1,s4,22e <gets+0x56>
    cc = read(0, &c, 1);
 202:	4605                	li	a2,1
 204:	faf40593          	addi	a1,s0,-81
 208:	4501                	li	a0,0
 20a:	00000097          	auipc	ra,0x0
 20e:	19a080e7          	jalr	410(ra) # 3a4 <read>
    if(cc < 1)
 212:	00a05e63          	blez	a0,22e <gets+0x56>
    buf[i++] = c;
 216:	faf44783          	lbu	a5,-81(s0)
 21a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 21e:	01578763          	beq	a5,s5,22c <gets+0x54>
 222:	0905                	addi	s2,s2,1
 224:	fd679be3          	bne	a5,s6,1fa <gets+0x22>
  for(i=0; i+1 < max; ){
 228:	89a6                	mv	s3,s1
 22a:	a011                	j	22e <gets+0x56>
 22c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 22e:	99de                	add	s3,s3,s7
 230:	00098023          	sb	zero,0(s3)
  return buf;
}
 234:	855e                	mv	a0,s7
 236:	60e6                	ld	ra,88(sp)
 238:	6446                	ld	s0,80(sp)
 23a:	64a6                	ld	s1,72(sp)
 23c:	6906                	ld	s2,64(sp)
 23e:	79e2                	ld	s3,56(sp)
 240:	7a42                	ld	s4,48(sp)
 242:	7aa2                	ld	s5,40(sp)
 244:	7b02                	ld	s6,32(sp)
 246:	6be2                	ld	s7,24(sp)
 248:	6125                	addi	sp,sp,96
 24a:	8082                	ret

000000000000024c <stat>:

int
stat(const char *n, struct stat *st)
{
 24c:	1101                	addi	sp,sp,-32
 24e:	ec06                	sd	ra,24(sp)
 250:	e822                	sd	s0,16(sp)
 252:	e426                	sd	s1,8(sp)
 254:	e04a                	sd	s2,0(sp)
 256:	1000                	addi	s0,sp,32
 258:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25a:	4581                	li	a1,0
 25c:	00000097          	auipc	ra,0x0
 260:	170080e7          	jalr	368(ra) # 3cc <open>
  if(fd < 0)
 264:	02054563          	bltz	a0,28e <stat+0x42>
 268:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 26a:	85ca                	mv	a1,s2
 26c:	00000097          	auipc	ra,0x0
 270:	178080e7          	jalr	376(ra) # 3e4 <fstat>
 274:	892a                	mv	s2,a0
  close(fd);
 276:	8526                	mv	a0,s1
 278:	00000097          	auipc	ra,0x0
 27c:	13c080e7          	jalr	316(ra) # 3b4 <close>
  return r;
}
 280:	854a                	mv	a0,s2
 282:	60e2                	ld	ra,24(sp)
 284:	6442                	ld	s0,16(sp)
 286:	64a2                	ld	s1,8(sp)
 288:	6902                	ld	s2,0(sp)
 28a:	6105                	addi	sp,sp,32
 28c:	8082                	ret
    return -1;
 28e:	597d                	li	s2,-1
 290:	bfc5                	j	280 <stat+0x34>

0000000000000292 <atoi>:

int
atoi(const char *s)
{
 292:	1141                	addi	sp,sp,-16
 294:	e422                	sd	s0,8(sp)
 296:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 298:	00054683          	lbu	a3,0(a0)
 29c:	fd06879b          	addiw	a5,a3,-48
 2a0:	0ff7f793          	zext.b	a5,a5
 2a4:	4625                	li	a2,9
 2a6:	02f66863          	bltu	a2,a5,2d6 <atoi+0x44>
 2aa:	872a                	mv	a4,a0
  n = 0;
 2ac:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ae:	0705                	addi	a4,a4,1
 2b0:	0025179b          	slliw	a5,a0,0x2
 2b4:	9fa9                	addw	a5,a5,a0
 2b6:	0017979b          	slliw	a5,a5,0x1
 2ba:	9fb5                	addw	a5,a5,a3
 2bc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c0:	00074683          	lbu	a3,0(a4)
 2c4:	fd06879b          	addiw	a5,a3,-48
 2c8:	0ff7f793          	zext.b	a5,a5
 2cc:	fef671e3          	bgeu	a2,a5,2ae <atoi+0x1c>
  return n;
}
 2d0:	6422                	ld	s0,8(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret
  n = 0;
 2d6:	4501                	li	a0,0
 2d8:	bfe5                	j	2d0 <atoi+0x3e>

00000000000002da <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e422                	sd	s0,8(sp)
 2de:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e0:	02b57463          	bgeu	a0,a1,308 <memmove+0x2e>
    while(n-- > 0)
 2e4:	00c05f63          	blez	a2,302 <memmove+0x28>
 2e8:	1602                	slli	a2,a2,0x20
 2ea:	9201                	srli	a2,a2,0x20
 2ec:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f2:	0585                	addi	a1,a1,1
 2f4:	0705                	addi	a4,a4,1
 2f6:	fff5c683          	lbu	a3,-1(a1)
 2fa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2fe:	fee79ae3          	bne	a5,a4,2f2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 302:	6422                	ld	s0,8(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret
    dst += n;
 308:	00c50733          	add	a4,a0,a2
    src += n;
 30c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 30e:	fec05ae3          	blez	a2,302 <memmove+0x28>
 312:	fff6079b          	addiw	a5,a2,-1
 316:	1782                	slli	a5,a5,0x20
 318:	9381                	srli	a5,a5,0x20
 31a:	fff7c793          	not	a5,a5
 31e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 320:	15fd                	addi	a1,a1,-1
 322:	177d                	addi	a4,a4,-1
 324:	0005c683          	lbu	a3,0(a1)
 328:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 32c:	fee79ae3          	bne	a5,a4,320 <memmove+0x46>
 330:	bfc9                	j	302 <memmove+0x28>

0000000000000332 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 332:	1141                	addi	sp,sp,-16
 334:	e422                	sd	s0,8(sp)
 336:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 338:	ca05                	beqz	a2,368 <memcmp+0x36>
 33a:	fff6069b          	addiw	a3,a2,-1
 33e:	1682                	slli	a3,a3,0x20
 340:	9281                	srli	a3,a3,0x20
 342:	0685                	addi	a3,a3,1
 344:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 346:	00054783          	lbu	a5,0(a0)
 34a:	0005c703          	lbu	a4,0(a1)
 34e:	00e79863          	bne	a5,a4,35e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 352:	0505                	addi	a0,a0,1
    p2++;
 354:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 356:	fed518e3          	bne	a0,a3,346 <memcmp+0x14>
  }
  return 0;
 35a:	4501                	li	a0,0
 35c:	a019                	j	362 <memcmp+0x30>
      return *p1 - *p2;
 35e:	40e7853b          	subw	a0,a5,a4
}
 362:	6422                	ld	s0,8(sp)
 364:	0141                	addi	sp,sp,16
 366:	8082                	ret
  return 0;
 368:	4501                	li	a0,0
 36a:	bfe5                	j	362 <memcmp+0x30>

000000000000036c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e406                	sd	ra,8(sp)
 370:	e022                	sd	s0,0(sp)
 372:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 374:	00000097          	auipc	ra,0x0
 378:	f66080e7          	jalr	-154(ra) # 2da <memmove>
}
 37c:	60a2                	ld	ra,8(sp)
 37e:	6402                	ld	s0,0(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret

0000000000000384 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 384:	4885                	li	a7,1
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <exit>:
.global exit
exit:
 li a7, SYS_exit
 38c:	4889                	li	a7,2
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <wait>:
.global wait
wait:
 li a7, SYS_wait
 394:	488d                	li	a7,3
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 39c:	4891                	li	a7,4
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <read>:
.global read
read:
 li a7, SYS_read
 3a4:	4895                	li	a7,5
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <write>:
.global write
write:
 li a7, SYS_write
 3ac:	48c1                	li	a7,16
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <close>:
.global close
close:
 li a7, SYS_close
 3b4:	48d5                	li	a7,21
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3bc:	4899                	li	a7,6
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c4:	489d                	li	a7,7
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <open>:
.global open
open:
 li a7, SYS_open
 3cc:	48bd                	li	a7,15
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d4:	48c5                	li	a7,17
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3dc:	48c9                	li	a7,18
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e4:	48a1                	li	a7,8
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <link>:
.global link
link:
 li a7, SYS_link
 3ec:	48cd                	li	a7,19
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f4:	48d1                	li	a7,20
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3fc:	48a5                	li	a7,9
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <dup>:
.global dup
dup:
 li a7, SYS_dup
 404:	48a9                	li	a7,10
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 40c:	48ad                	li	a7,11
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 414:	48b1                	li	a7,12
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 41c:	48b5                	li	a7,13
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 424:	48b9                	li	a7,14
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <trace>:
.global trace
trace:
 li a7, SYS_trace
 42c:	48d9                	li	a7,22
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 434:	48dd                	li	a7,23
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 43c:	48e1                	li	a7,24
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 444:	48e5                	li	a7,25
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 44c:	48e9                	li	a7,26
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 454:	48ed                	li	a7,27
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 45c:	48f1                	li	a7,28
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 464:	1101                	addi	sp,sp,-32
 466:	ec06                	sd	ra,24(sp)
 468:	e822                	sd	s0,16(sp)
 46a:	1000                	addi	s0,sp,32
 46c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 470:	4605                	li	a2,1
 472:	fef40593          	addi	a1,s0,-17
 476:	00000097          	auipc	ra,0x0
 47a:	f36080e7          	jalr	-202(ra) # 3ac <write>
}
 47e:	60e2                	ld	ra,24(sp)
 480:	6442                	ld	s0,16(sp)
 482:	6105                	addi	sp,sp,32
 484:	8082                	ret

0000000000000486 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 486:	7139                	addi	sp,sp,-64
 488:	fc06                	sd	ra,56(sp)
 48a:	f822                	sd	s0,48(sp)
 48c:	f426                	sd	s1,40(sp)
 48e:	f04a                	sd	s2,32(sp)
 490:	ec4e                	sd	s3,24(sp)
 492:	0080                	addi	s0,sp,64
 494:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 496:	c299                	beqz	a3,49c <printint+0x16>
 498:	0805c963          	bltz	a1,52a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 49c:	2581                	sext.w	a1,a1
  neg = 0;
 49e:	4881                	li	a7,0
 4a0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4a4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4a6:	2601                	sext.w	a2,a2
 4a8:	00000517          	auipc	a0,0x0
 4ac:	4f050513          	addi	a0,a0,1264 # 998 <digits>
 4b0:	883a                	mv	a6,a4
 4b2:	2705                	addiw	a4,a4,1
 4b4:	02c5f7bb          	remuw	a5,a1,a2
 4b8:	1782                	slli	a5,a5,0x20
 4ba:	9381                	srli	a5,a5,0x20
 4bc:	97aa                	add	a5,a5,a0
 4be:	0007c783          	lbu	a5,0(a5)
 4c2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4c6:	0005879b          	sext.w	a5,a1
 4ca:	02c5d5bb          	divuw	a1,a1,a2
 4ce:	0685                	addi	a3,a3,1
 4d0:	fec7f0e3          	bgeu	a5,a2,4b0 <printint+0x2a>
  if(neg)
 4d4:	00088c63          	beqz	a7,4ec <printint+0x66>
    buf[i++] = '-';
 4d8:	fd070793          	addi	a5,a4,-48
 4dc:	00878733          	add	a4,a5,s0
 4e0:	02d00793          	li	a5,45
 4e4:	fef70823          	sb	a5,-16(a4)
 4e8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ec:	02e05863          	blez	a4,51c <printint+0x96>
 4f0:	fc040793          	addi	a5,s0,-64
 4f4:	00e78933          	add	s2,a5,a4
 4f8:	fff78993          	addi	s3,a5,-1
 4fc:	99ba                	add	s3,s3,a4
 4fe:	377d                	addiw	a4,a4,-1
 500:	1702                	slli	a4,a4,0x20
 502:	9301                	srli	a4,a4,0x20
 504:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 508:	fff94583          	lbu	a1,-1(s2)
 50c:	8526                	mv	a0,s1
 50e:	00000097          	auipc	ra,0x0
 512:	f56080e7          	jalr	-170(ra) # 464 <putc>
  while(--i >= 0)
 516:	197d                	addi	s2,s2,-1
 518:	ff3918e3          	bne	s2,s3,508 <printint+0x82>
}
 51c:	70e2                	ld	ra,56(sp)
 51e:	7442                	ld	s0,48(sp)
 520:	74a2                	ld	s1,40(sp)
 522:	7902                	ld	s2,32(sp)
 524:	69e2                	ld	s3,24(sp)
 526:	6121                	addi	sp,sp,64
 528:	8082                	ret
    x = -xx;
 52a:	40b005bb          	negw	a1,a1
    neg = 1;
 52e:	4885                	li	a7,1
    x = -xx;
 530:	bf85                	j	4a0 <printint+0x1a>

0000000000000532 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 532:	7119                	addi	sp,sp,-128
 534:	fc86                	sd	ra,120(sp)
 536:	f8a2                	sd	s0,112(sp)
 538:	f4a6                	sd	s1,104(sp)
 53a:	f0ca                	sd	s2,96(sp)
 53c:	ecce                	sd	s3,88(sp)
 53e:	e8d2                	sd	s4,80(sp)
 540:	e4d6                	sd	s5,72(sp)
 542:	e0da                	sd	s6,64(sp)
 544:	fc5e                	sd	s7,56(sp)
 546:	f862                	sd	s8,48(sp)
 548:	f466                	sd	s9,40(sp)
 54a:	f06a                	sd	s10,32(sp)
 54c:	ec6e                	sd	s11,24(sp)
 54e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 550:	0005c903          	lbu	s2,0(a1)
 554:	18090f63          	beqz	s2,6f2 <vprintf+0x1c0>
 558:	8aaa                	mv	s5,a0
 55a:	8b32                	mv	s6,a2
 55c:	00158493          	addi	s1,a1,1
  state = 0;
 560:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 562:	02500a13          	li	s4,37
 566:	4c55                	li	s8,21
 568:	00000c97          	auipc	s9,0x0
 56c:	3d8c8c93          	addi	s9,s9,984 # 940 <malloc+0x14a>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 570:	02800d93          	li	s11,40
  putc(fd, 'x');
 574:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 576:	00000b97          	auipc	s7,0x0
 57a:	422b8b93          	addi	s7,s7,1058 # 998 <digits>
 57e:	a839                	j	59c <vprintf+0x6a>
        putc(fd, c);
 580:	85ca                	mv	a1,s2
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	ee0080e7          	jalr	-288(ra) # 464 <putc>
 58c:	a019                	j	592 <vprintf+0x60>
    } else if(state == '%'){
 58e:	01498d63          	beq	s3,s4,5a8 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 592:	0485                	addi	s1,s1,1
 594:	fff4c903          	lbu	s2,-1(s1)
 598:	14090d63          	beqz	s2,6f2 <vprintf+0x1c0>
    if(state == 0){
 59c:	fe0999e3          	bnez	s3,58e <vprintf+0x5c>
      if(c == '%'){
 5a0:	ff4910e3          	bne	s2,s4,580 <vprintf+0x4e>
        state = '%';
 5a4:	89d2                	mv	s3,s4
 5a6:	b7f5                	j	592 <vprintf+0x60>
      if(c == 'd'){
 5a8:	11490c63          	beq	s2,s4,6c0 <vprintf+0x18e>
 5ac:	f9d9079b          	addiw	a5,s2,-99
 5b0:	0ff7f793          	zext.b	a5,a5
 5b4:	10fc6e63          	bltu	s8,a5,6d0 <vprintf+0x19e>
 5b8:	f9d9079b          	addiw	a5,s2,-99
 5bc:	0ff7f713          	zext.b	a4,a5
 5c0:	10ec6863          	bltu	s8,a4,6d0 <vprintf+0x19e>
 5c4:	00271793          	slli	a5,a4,0x2
 5c8:	97e6                	add	a5,a5,s9
 5ca:	439c                	lw	a5,0(a5)
 5cc:	97e6                	add	a5,a5,s9
 5ce:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5d0:	008b0913          	addi	s2,s6,8
 5d4:	4685                	li	a3,1
 5d6:	4629                	li	a2,10
 5d8:	000b2583          	lw	a1,0(s6)
 5dc:	8556                	mv	a0,s5
 5de:	00000097          	auipc	ra,0x0
 5e2:	ea8080e7          	jalr	-344(ra) # 486 <printint>
 5e6:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	b765                	j	592 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ec:	008b0913          	addi	s2,s6,8
 5f0:	4681                	li	a3,0
 5f2:	4629                	li	a2,10
 5f4:	000b2583          	lw	a1,0(s6)
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e8c080e7          	jalr	-372(ra) # 486 <printint>
 602:	8b4a                	mv	s6,s2
      state = 0;
 604:	4981                	li	s3,0
 606:	b771                	j	592 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 608:	008b0913          	addi	s2,s6,8
 60c:	4681                	li	a3,0
 60e:	866a                	mv	a2,s10
 610:	000b2583          	lw	a1,0(s6)
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	e70080e7          	jalr	-400(ra) # 486 <printint>
 61e:	8b4a                	mv	s6,s2
      state = 0;
 620:	4981                	li	s3,0
 622:	bf85                	j	592 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 624:	008b0793          	addi	a5,s6,8
 628:	f8f43423          	sd	a5,-120(s0)
 62c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 630:	03000593          	li	a1,48
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	e2e080e7          	jalr	-466(ra) # 464 <putc>
  putc(fd, 'x');
 63e:	07800593          	li	a1,120
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e20080e7          	jalr	-480(ra) # 464 <putc>
 64c:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 64e:	03c9d793          	srli	a5,s3,0x3c
 652:	97de                	add	a5,a5,s7
 654:	0007c583          	lbu	a1,0(a5)
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	e0a080e7          	jalr	-502(ra) # 464 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 662:	0992                	slli	s3,s3,0x4
 664:	397d                	addiw	s2,s2,-1
 666:	fe0914e3          	bnez	s2,64e <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 66a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 66e:	4981                	li	s3,0
 670:	b70d                	j	592 <vprintf+0x60>
        s = va_arg(ap, char*);
 672:	008b0913          	addi	s2,s6,8
 676:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 67a:	02098163          	beqz	s3,69c <vprintf+0x16a>
        while(*s != 0){
 67e:	0009c583          	lbu	a1,0(s3)
 682:	c5ad                	beqz	a1,6ec <vprintf+0x1ba>
          putc(fd, *s);
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	dde080e7          	jalr	-546(ra) # 464 <putc>
          s++;
 68e:	0985                	addi	s3,s3,1
        while(*s != 0){
 690:	0009c583          	lbu	a1,0(s3)
 694:	f9e5                	bnez	a1,684 <vprintf+0x152>
        s = va_arg(ap, char*);
 696:	8b4a                	mv	s6,s2
      state = 0;
 698:	4981                	li	s3,0
 69a:	bde5                	j	592 <vprintf+0x60>
          s = "(null)";
 69c:	00000997          	auipc	s3,0x0
 6a0:	29c98993          	addi	s3,s3,668 # 938 <malloc+0x142>
        while(*s != 0){
 6a4:	85ee                	mv	a1,s11
 6a6:	bff9                	j	684 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 6a8:	008b0913          	addi	s2,s6,8
 6ac:	000b4583          	lbu	a1,0(s6)
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	db2080e7          	jalr	-590(ra) # 464 <putc>
 6ba:	8b4a                	mv	s6,s2
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bdd1                	j	592 <vprintf+0x60>
        putc(fd, c);
 6c0:	85d2                	mv	a1,s4
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	da0080e7          	jalr	-608(ra) # 464 <putc>
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b5d1                	j	592 <vprintf+0x60>
        putc(fd, '%');
 6d0:	85d2                	mv	a1,s4
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	d90080e7          	jalr	-624(ra) # 464 <putc>
        putc(fd, c);
 6dc:	85ca                	mv	a1,s2
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	d84080e7          	jalr	-636(ra) # 464 <putc>
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	b565                	j	592 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ec:	8b4a                	mv	s6,s2
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b54d                	j	592 <vprintf+0x60>
    }
  }
}
 6f2:	70e6                	ld	ra,120(sp)
 6f4:	7446                	ld	s0,112(sp)
 6f6:	74a6                	ld	s1,104(sp)
 6f8:	7906                	ld	s2,96(sp)
 6fa:	69e6                	ld	s3,88(sp)
 6fc:	6a46                	ld	s4,80(sp)
 6fe:	6aa6                	ld	s5,72(sp)
 700:	6b06                	ld	s6,64(sp)
 702:	7be2                	ld	s7,56(sp)
 704:	7c42                	ld	s8,48(sp)
 706:	7ca2                	ld	s9,40(sp)
 708:	7d02                	ld	s10,32(sp)
 70a:	6de2                	ld	s11,24(sp)
 70c:	6109                	addi	sp,sp,128
 70e:	8082                	ret

0000000000000710 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 710:	715d                	addi	sp,sp,-80
 712:	ec06                	sd	ra,24(sp)
 714:	e822                	sd	s0,16(sp)
 716:	1000                	addi	s0,sp,32
 718:	e010                	sd	a2,0(s0)
 71a:	e414                	sd	a3,8(s0)
 71c:	e818                	sd	a4,16(s0)
 71e:	ec1c                	sd	a5,24(s0)
 720:	03043023          	sd	a6,32(s0)
 724:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 728:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72c:	8622                	mv	a2,s0
 72e:	00000097          	auipc	ra,0x0
 732:	e04080e7          	jalr	-508(ra) # 532 <vprintf>
}
 736:	60e2                	ld	ra,24(sp)
 738:	6442                	ld	s0,16(sp)
 73a:	6161                	addi	sp,sp,80
 73c:	8082                	ret

000000000000073e <printf>:

void
printf(const char *fmt, ...)
{
 73e:	711d                	addi	sp,sp,-96
 740:	ec06                	sd	ra,24(sp)
 742:	e822                	sd	s0,16(sp)
 744:	1000                	addi	s0,sp,32
 746:	e40c                	sd	a1,8(s0)
 748:	e810                	sd	a2,16(s0)
 74a:	ec14                	sd	a3,24(s0)
 74c:	f018                	sd	a4,32(s0)
 74e:	f41c                	sd	a5,40(s0)
 750:	03043823          	sd	a6,48(s0)
 754:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 758:	00840613          	addi	a2,s0,8
 75c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 760:	85aa                	mv	a1,a0
 762:	4505                	li	a0,1
 764:	00000097          	auipc	ra,0x0
 768:	dce080e7          	jalr	-562(ra) # 532 <vprintf>
}
 76c:	60e2                	ld	ra,24(sp)
 76e:	6442                	ld	s0,16(sp)
 770:	6125                	addi	sp,sp,96
 772:	8082                	ret

0000000000000774 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 774:	1141                	addi	sp,sp,-16
 776:	e422                	sd	s0,8(sp)
 778:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 77a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77e:	00001797          	auipc	a5,0x1
 782:	8827b783          	ld	a5,-1918(a5) # 1000 <freep>
 786:	a02d                	j	7b0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 788:	4618                	lw	a4,8(a2)
 78a:	9f2d                	addw	a4,a4,a1
 78c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 790:	6398                	ld	a4,0(a5)
 792:	6310                	ld	a2,0(a4)
 794:	a83d                	j	7d2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 796:	ff852703          	lw	a4,-8(a0)
 79a:	9f31                	addw	a4,a4,a2
 79c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 79e:	ff053683          	ld	a3,-16(a0)
 7a2:	a091                	j	7e6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a4:	6398                	ld	a4,0(a5)
 7a6:	00e7e463          	bltu	a5,a4,7ae <free+0x3a>
 7aa:	00e6ea63          	bltu	a3,a4,7be <free+0x4a>
{
 7ae:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b0:	fed7fae3          	bgeu	a5,a3,7a4 <free+0x30>
 7b4:	6398                	ld	a4,0(a5)
 7b6:	00e6e463          	bltu	a3,a4,7be <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ba:	fee7eae3          	bltu	a5,a4,7ae <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7be:	ff852583          	lw	a1,-8(a0)
 7c2:	6390                	ld	a2,0(a5)
 7c4:	02059813          	slli	a6,a1,0x20
 7c8:	01c85713          	srli	a4,a6,0x1c
 7cc:	9736                	add	a4,a4,a3
 7ce:	fae60de3          	beq	a2,a4,788 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7d2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d6:	4790                	lw	a2,8(a5)
 7d8:	02061593          	slli	a1,a2,0x20
 7dc:	01c5d713          	srli	a4,a1,0x1c
 7e0:	973e                	add	a4,a4,a5
 7e2:	fae68ae3          	beq	a3,a4,796 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7e6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7e8:	00001717          	auipc	a4,0x1
 7ec:	80f73c23          	sd	a5,-2024(a4) # 1000 <freep>
}
 7f0:	6422                	ld	s0,8(sp)
 7f2:	0141                	addi	sp,sp,16
 7f4:	8082                	ret

00000000000007f6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f6:	7139                	addi	sp,sp,-64
 7f8:	fc06                	sd	ra,56(sp)
 7fa:	f822                	sd	s0,48(sp)
 7fc:	f426                	sd	s1,40(sp)
 7fe:	f04a                	sd	s2,32(sp)
 800:	ec4e                	sd	s3,24(sp)
 802:	e852                	sd	s4,16(sp)
 804:	e456                	sd	s5,8(sp)
 806:	e05a                	sd	s6,0(sp)
 808:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 80a:	02051493          	slli	s1,a0,0x20
 80e:	9081                	srli	s1,s1,0x20
 810:	04bd                	addi	s1,s1,15
 812:	8091                	srli	s1,s1,0x4
 814:	0014899b          	addiw	s3,s1,1
 818:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 81a:	00000517          	auipc	a0,0x0
 81e:	7e653503          	ld	a0,2022(a0) # 1000 <freep>
 822:	c515                	beqz	a0,84e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 824:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 826:	4798                	lw	a4,8(a5)
 828:	02977f63          	bgeu	a4,s1,866 <malloc+0x70>
 82c:	8a4e                	mv	s4,s3
 82e:	0009871b          	sext.w	a4,s3
 832:	6685                	lui	a3,0x1
 834:	00d77363          	bgeu	a4,a3,83a <malloc+0x44>
 838:	6a05                	lui	s4,0x1
 83a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 83e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 842:	00000917          	auipc	s2,0x0
 846:	7be90913          	addi	s2,s2,1982 # 1000 <freep>
  if(p == (char*)-1)
 84a:	5afd                	li	s5,-1
 84c:	a895                	j	8c0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 84e:	00000797          	auipc	a5,0x0
 852:	7c278793          	addi	a5,a5,1986 # 1010 <base>
 856:	00000717          	auipc	a4,0x0
 85a:	7af73523          	sd	a5,1962(a4) # 1000 <freep>
 85e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 860:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 864:	b7e1                	j	82c <malloc+0x36>
      if(p->s.size == nunits)
 866:	02e48c63          	beq	s1,a4,89e <malloc+0xa8>
        p->s.size -= nunits;
 86a:	4137073b          	subw	a4,a4,s3
 86e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 870:	02071693          	slli	a3,a4,0x20
 874:	01c6d713          	srli	a4,a3,0x1c
 878:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 87a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 87e:	00000717          	auipc	a4,0x0
 882:	78a73123          	sd	a0,1922(a4) # 1000 <freep>
      return (void*)(p + 1);
 886:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 88a:	70e2                	ld	ra,56(sp)
 88c:	7442                	ld	s0,48(sp)
 88e:	74a2                	ld	s1,40(sp)
 890:	7902                	ld	s2,32(sp)
 892:	69e2                	ld	s3,24(sp)
 894:	6a42                	ld	s4,16(sp)
 896:	6aa2                	ld	s5,8(sp)
 898:	6b02                	ld	s6,0(sp)
 89a:	6121                	addi	sp,sp,64
 89c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 89e:	6398                	ld	a4,0(a5)
 8a0:	e118                	sd	a4,0(a0)
 8a2:	bff1                	j	87e <malloc+0x88>
  hp->s.size = nu;
 8a4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8a8:	0541                	addi	a0,a0,16
 8aa:	00000097          	auipc	ra,0x0
 8ae:	eca080e7          	jalr	-310(ra) # 774 <free>
  return freep;
 8b2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8b6:	d971                	beqz	a0,88a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ba:	4798                	lw	a4,8(a5)
 8bc:	fa9775e3          	bgeu	a4,s1,866 <malloc+0x70>
    if(p == freep)
 8c0:	00093703          	ld	a4,0(s2)
 8c4:	853e                	mv	a0,a5
 8c6:	fef719e3          	bne	a4,a5,8b8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8ca:	8552                	mv	a0,s4
 8cc:	00000097          	auipc	ra,0x0
 8d0:	b48080e7          	jalr	-1208(ra) # 414 <sbrk>
  if(p == (char*)-1)
 8d4:	fd5518e3          	bne	a0,s5,8a4 <malloc+0xae>
        return 0;
 8d8:	4501                	li	a0,0
 8da:	bf45                	j	88a <malloc+0x94>
