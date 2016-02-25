
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10:	00 
  11:	c7 04 24 06 09 00 00 	movl   $0x906,(%esp)
  18:	e8 9a 03 00 00       	call   3b7 <open>
  1d:	85 c0                	test   %eax,%eax
  1f:	79 30                	jns    51 <main+0x51>
    mknod("console", 1, 1);
  21:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  28:	00 
  29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  30:	00 
  31:	c7 04 24 06 09 00 00 	movl   $0x906,(%esp)
  38:	e8 82 03 00 00       	call   3bf <mknod>
    open("console", O_RDWR);
  3d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  44:	00 
  45:	c7 04 24 06 09 00 00 	movl   $0x906,(%esp)
  4c:	e8 66 03 00 00       	call   3b7 <open>
  }
  dup(0);  // stdout
  51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  58:	e8 92 03 00 00       	call   3ef <dup>
  dup(0);  // stderr
  5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  64:	e8 86 03 00 00       	call   3ef <dup>

  for(;;){
    printf(1, "init: starting sh\n");
  69:	c7 44 24 04 0e 09 00 	movl   $0x90e,0x4(%esp)
  70:	00 
  71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  78:	e8 ba 04 00 00       	call   537 <printf>
    pid = fork();
  7d:	e8 ed 02 00 00       	call   36f <fork>
  82:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
  86:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8b:	79 19                	jns    a6 <main+0xa6>
      printf(1, "init: fork failed\n");
  8d:	c7 44 24 04 21 09 00 	movl   $0x921,0x4(%esp)
  94:	00 
  95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9c:	e8 96 04 00 00       	call   537 <printf>
      exit();
  a1:	e8 d1 02 00 00       	call   377 <exit>
    }
    if(pid == 0){
  a6:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  ab:	75 2d                	jne    da <main+0xda>
      exec("sh", argv);
  ad:	c7 44 24 04 a0 0b 00 	movl   $0xba0,0x4(%esp)
  b4:	00 
  b5:	c7 04 24 03 09 00 00 	movl   $0x903,(%esp)
  bc:	e8 ee 02 00 00       	call   3af <exec>
      printf(1, "init: exec sh failed\n");
  c1:	c7 44 24 04 34 09 00 	movl   $0x934,0x4(%esp)
  c8:	00 
  c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d0:	e8 62 04 00 00       	call   537 <printf>
      exit();
  d5:	e8 9d 02 00 00       	call   377 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  da:	eb 14                	jmp    f0 <main+0xf0>
      printf(1, "zombie!\n");
  dc:	c7 44 24 04 4a 09 00 	movl   $0x94a,0x4(%esp)
  e3:	00 
  e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  eb:	e8 47 04 00 00       	call   537 <printf>
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  f0:	e8 8a 02 00 00       	call   37f <wait>
  f5:	89 44 24 18          	mov    %eax,0x18(%esp)
  f9:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  fe:	78 0a                	js     10a <main+0x10a>
 100:	8b 44 24 18          	mov    0x18(%esp),%eax
 104:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 108:	75 d2                	jne    dc <main+0xdc>
      printf(1, "zombie!\n");
  }
 10a:	e9 5a ff ff ff       	jmp    69 <main+0x69>

0000010f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	57                   	push   %edi
 113:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 114:	8b 4d 08             	mov    0x8(%ebp),%ecx
 117:	8b 55 10             	mov    0x10(%ebp),%edx
 11a:	8b 45 0c             	mov    0xc(%ebp),%eax
 11d:	89 cb                	mov    %ecx,%ebx
 11f:	89 df                	mov    %ebx,%edi
 121:	89 d1                	mov    %edx,%ecx
 123:	fc                   	cld    
 124:	f3 aa                	rep stos %al,%es:(%edi)
 126:	89 ca                	mov    %ecx,%edx
 128:	89 fb                	mov    %edi,%ebx
 12a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 130:	5b                   	pop    %ebx
 131:	5f                   	pop    %edi
 132:	5d                   	pop    %ebp
 133:	c3                   	ret    

00000134 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13a:	8b 45 08             	mov    0x8(%ebp),%eax
 13d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 140:	90                   	nop
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	8d 50 01             	lea    0x1(%eax),%edx
 147:	89 55 08             	mov    %edx,0x8(%ebp)
 14a:	8b 55 0c             	mov    0xc(%ebp),%edx
 14d:	8d 4a 01             	lea    0x1(%edx),%ecx
 150:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 153:	0f b6 12             	movzbl (%edx),%edx
 156:	88 10                	mov    %dl,(%eax)
 158:	0f b6 00             	movzbl (%eax),%eax
 15b:	84 c0                	test   %al,%al
 15d:	75 e2                	jne    141 <strcpy+0xd>
    ;
  return os;
 15f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 162:	c9                   	leave  
 163:	c3                   	ret    

00000164 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 167:	eb 08                	jmp    171 <strcmp+0xd>
    p++, q++;
 169:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 171:	8b 45 08             	mov    0x8(%ebp),%eax
 174:	0f b6 00             	movzbl (%eax),%eax
 177:	84 c0                	test   %al,%al
 179:	74 10                	je     18b <strcmp+0x27>
 17b:	8b 45 08             	mov    0x8(%ebp),%eax
 17e:	0f b6 10             	movzbl (%eax),%edx
 181:	8b 45 0c             	mov    0xc(%ebp),%eax
 184:	0f b6 00             	movzbl (%eax),%eax
 187:	38 c2                	cmp    %al,%dl
 189:	74 de                	je     169 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 18b:	8b 45 08             	mov    0x8(%ebp),%eax
 18e:	0f b6 00             	movzbl (%eax),%eax
 191:	0f b6 d0             	movzbl %al,%edx
 194:	8b 45 0c             	mov    0xc(%ebp),%eax
 197:	0f b6 00             	movzbl (%eax),%eax
 19a:	0f b6 c0             	movzbl %al,%eax
 19d:	29 c2                	sub    %eax,%edx
 19f:	89 d0                	mov    %edx,%eax
}
 1a1:	5d                   	pop    %ebp
 1a2:	c3                   	ret    

000001a3 <strlen>:

uint
strlen(char *s)
{
 1a3:	55                   	push   %ebp
 1a4:	89 e5                	mov    %esp,%ebp
 1a6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b0:	eb 04                	jmp    1b6 <strlen+0x13>
 1b2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1b9:	8b 45 08             	mov    0x8(%ebp),%eax
 1bc:	01 d0                	add    %edx,%eax
 1be:	0f b6 00             	movzbl (%eax),%eax
 1c1:	84 c0                	test   %al,%al
 1c3:	75 ed                	jne    1b2 <strlen+0xf>
    ;
  return n;
 1c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c8:	c9                   	leave  
 1c9:	c3                   	ret    

000001ca <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ca:	55                   	push   %ebp
 1cb:	89 e5                	mov    %esp,%ebp
 1cd:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1d0:	8b 45 10             	mov    0x10(%ebp),%eax
 1d3:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1da:	89 44 24 04          	mov    %eax,0x4(%esp)
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	89 04 24             	mov    %eax,(%esp)
 1e4:	e8 26 ff ff ff       	call   10f <stosb>
  return dst;
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ec:	c9                   	leave  
 1ed:	c3                   	ret    

000001ee <strchr>:

char*
strchr(const char *s, char c)
{
 1ee:	55                   	push   %ebp
 1ef:	89 e5                	mov    %esp,%ebp
 1f1:	83 ec 04             	sub    $0x4,%esp
 1f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f7:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1fa:	eb 14                	jmp    210 <strchr+0x22>
    if(*s == c)
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	0f b6 00             	movzbl (%eax),%eax
 202:	3a 45 fc             	cmp    -0x4(%ebp),%al
 205:	75 05                	jne    20c <strchr+0x1e>
      return (char*)s;
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	eb 13                	jmp    21f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 20c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	0f b6 00             	movzbl (%eax),%eax
 216:	84 c0                	test   %al,%al
 218:	75 e2                	jne    1fc <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 21a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 21f:	c9                   	leave  
 220:	c3                   	ret    

00000221 <gets>:

char*
gets(char *buf, int max)
{
 221:	55                   	push   %ebp
 222:	89 e5                	mov    %esp,%ebp
 224:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 227:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 22e:	eb 4c                	jmp    27c <gets+0x5b>
    cc = read(0, &c, 1);
 230:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 237:	00 
 238:	8d 45 ef             	lea    -0x11(%ebp),%eax
 23b:	89 44 24 04          	mov    %eax,0x4(%esp)
 23f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 246:	e8 44 01 00 00       	call   38f <read>
 24b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 24e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 252:	7f 02                	jg     256 <gets+0x35>
      break;
 254:	eb 31                	jmp    287 <gets+0x66>
    buf[i++] = c;
 256:	8b 45 f4             	mov    -0xc(%ebp),%eax
 259:	8d 50 01             	lea    0x1(%eax),%edx
 25c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 25f:	89 c2                	mov    %eax,%edx
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	01 c2                	add    %eax,%edx
 266:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 26c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 270:	3c 0a                	cmp    $0xa,%al
 272:	74 13                	je     287 <gets+0x66>
 274:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 278:	3c 0d                	cmp    $0xd,%al
 27a:	74 0b                	je     287 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27f:	83 c0 01             	add    $0x1,%eax
 282:	3b 45 0c             	cmp    0xc(%ebp),%eax
 285:	7c a9                	jl     230 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 287:	8b 55 f4             	mov    -0xc(%ebp),%edx
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	01 d0                	add    %edx,%eax
 28f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 292:	8b 45 08             	mov    0x8(%ebp),%eax
}
 295:	c9                   	leave  
 296:	c3                   	ret    

00000297 <stat>:

int
stat(char *n, struct stat *st)
{
 297:	55                   	push   %ebp
 298:	89 e5                	mov    %esp,%ebp
 29a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2a4:	00 
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	89 04 24             	mov    %eax,(%esp)
 2ab:	e8 07 01 00 00       	call   3b7 <open>
 2b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b7:	79 07                	jns    2c0 <stat+0x29>
    return -1;
 2b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2be:	eb 23                	jmp    2e3 <stat+0x4c>
  r = fstat(fd, st);
 2c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ca:	89 04 24             	mov    %eax,(%esp)
 2cd:	e8 fd 00 00 00       	call   3cf <fstat>
 2d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d8:	89 04 24             	mov    %eax,(%esp)
 2db:	e8 bf 00 00 00       	call   39f <close>
  return r;
 2e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e3:	c9                   	leave  
 2e4:	c3                   	ret    

000002e5 <atoi>:

int
atoi(const char *s)
{
 2e5:	55                   	push   %ebp
 2e6:	89 e5                	mov    %esp,%ebp
 2e8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2eb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f2:	eb 25                	jmp    319 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2f4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f7:	89 d0                	mov    %edx,%eax
 2f9:	c1 e0 02             	shl    $0x2,%eax
 2fc:	01 d0                	add    %edx,%eax
 2fe:	01 c0                	add    %eax,%eax
 300:	89 c1                	mov    %eax,%ecx
 302:	8b 45 08             	mov    0x8(%ebp),%eax
 305:	8d 50 01             	lea    0x1(%eax),%edx
 308:	89 55 08             	mov    %edx,0x8(%ebp)
 30b:	0f b6 00             	movzbl (%eax),%eax
 30e:	0f be c0             	movsbl %al,%eax
 311:	01 c8                	add    %ecx,%eax
 313:	83 e8 30             	sub    $0x30,%eax
 316:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	0f b6 00             	movzbl (%eax),%eax
 31f:	3c 2f                	cmp    $0x2f,%al
 321:	7e 0a                	jle    32d <atoi+0x48>
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	0f b6 00             	movzbl (%eax),%eax
 329:	3c 39                	cmp    $0x39,%al
 32b:	7e c7                	jle    2f4 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 32d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 330:	c9                   	leave  
 331:	c3                   	ret    

00000332 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33e:	8b 45 0c             	mov    0xc(%ebp),%eax
 341:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 344:	eb 17                	jmp    35d <memmove+0x2b>
    *dst++ = *src++;
 346:	8b 45 fc             	mov    -0x4(%ebp),%eax
 349:	8d 50 01             	lea    0x1(%eax),%edx
 34c:	89 55 fc             	mov    %edx,-0x4(%ebp)
 34f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 352:	8d 4a 01             	lea    0x1(%edx),%ecx
 355:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 358:	0f b6 12             	movzbl (%edx),%edx
 35b:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35d:	8b 45 10             	mov    0x10(%ebp),%eax
 360:	8d 50 ff             	lea    -0x1(%eax),%edx
 363:	89 55 10             	mov    %edx,0x10(%ebp)
 366:	85 c0                	test   %eax,%eax
 368:	7f dc                	jg     346 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36d:	c9                   	leave  
 36e:	c3                   	ret    

0000036f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 36f:	b8 01 00 00 00       	mov    $0x1,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <exit>:
SYSCALL(exit)
 377:	b8 02 00 00 00       	mov    $0x2,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <wait>:
SYSCALL(wait)
 37f:	b8 03 00 00 00       	mov    $0x3,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <pipe>:
SYSCALL(pipe)
 387:	b8 04 00 00 00       	mov    $0x4,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <read>:
SYSCALL(read)
 38f:	b8 05 00 00 00       	mov    $0x5,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	ret    

00000397 <write>:
SYSCALL(write)
 397:	b8 10 00 00 00       	mov    $0x10,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	ret    

0000039f <close>:
SYSCALL(close)
 39f:	b8 15 00 00 00       	mov    $0x15,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	ret    

000003a7 <kill>:
SYSCALL(kill)
 3a7:	b8 06 00 00 00       	mov    $0x6,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	ret    

000003af <exec>:
SYSCALL(exec)
 3af:	b8 07 00 00 00       	mov    $0x7,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	ret    

000003b7 <open>:
SYSCALL(open)
 3b7:	b8 0f 00 00 00       	mov    $0xf,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	ret    

000003bf <mknod>:
SYSCALL(mknod)
 3bf:	b8 11 00 00 00       	mov    $0x11,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <unlink>:
SYSCALL(unlink)
 3c7:	b8 12 00 00 00       	mov    $0x12,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <fstat>:
SYSCALL(fstat)
 3cf:	b8 08 00 00 00       	mov    $0x8,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	ret    

000003d7 <link>:
SYSCALL(link)
 3d7:	b8 13 00 00 00       	mov    $0x13,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	ret    

000003df <mkdir>:
SYSCALL(mkdir)
 3df:	b8 14 00 00 00       	mov    $0x14,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	ret    

000003e7 <chdir>:
SYSCALL(chdir)
 3e7:	b8 09 00 00 00       	mov    $0x9,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <dup>:
SYSCALL(dup)
 3ef:	b8 0a 00 00 00       	mov    $0xa,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	ret    

000003f7 <getpid>:
SYSCALL(getpid)
 3f7:	b8 0b 00 00 00       	mov    $0xb,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	ret    

000003ff <sbrk>:
SYSCALL(sbrk)
 3ff:	b8 0c 00 00 00       	mov    $0xc,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	ret    

00000407 <sleep>:
SYSCALL(sleep)
 407:	b8 0d 00 00 00       	mov    $0xd,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <uptime>:
SYSCALL(uptime)
 40f:	b8 0e 00 00 00       	mov    $0xe,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <date>:
SYSCALL(date)
 417:	b8 16 00 00 00       	mov    $0x16,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	ret    

0000041f <timem>:
SYSCALL(timem)
 41f:	b8 17 00 00 00       	mov    $0x17,%eax
 424:	cd 40                	int    $0x40
 426:	c3                   	ret    

00000427 <getuid>:
SYSCALL(getuid)
 427:	b8 18 00 00 00       	mov    $0x18,%eax
 42c:	cd 40                	int    $0x40
 42e:	c3                   	ret    

0000042f <getgid>:
SYSCALL(getgid)
 42f:	b8 19 00 00 00       	mov    $0x19,%eax
 434:	cd 40                	int    $0x40
 436:	c3                   	ret    

00000437 <getppid>:
SYSCALL(getppid)
 437:	b8 1a 00 00 00       	mov    $0x1a,%eax
 43c:	cd 40                	int    $0x40
 43e:	c3                   	ret    

0000043f <setuid>:
SYSCALL(setuid)
 43f:	b8 1b 00 00 00       	mov    $0x1b,%eax
 444:	cd 40                	int    $0x40
 446:	c3                   	ret    

00000447 <setgid>:
SYSCALL(setgid)
 447:	b8 1c 00 00 00       	mov    $0x1c,%eax
 44c:	cd 40                	int    $0x40
 44e:	c3                   	ret    

0000044f <getprocs>:
SYSCALL(getprocs)
 44f:	b8 1d 00 00 00       	mov    $0x1d,%eax
 454:	cd 40                	int    $0x40
 456:	c3                   	ret    

00000457 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 457:	55                   	push   %ebp
 458:	89 e5                	mov    %esp,%ebp
 45a:	83 ec 18             	sub    $0x18,%esp
 45d:	8b 45 0c             	mov    0xc(%ebp),%eax
 460:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 463:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 46a:	00 
 46b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 46e:	89 44 24 04          	mov    %eax,0x4(%esp)
 472:	8b 45 08             	mov    0x8(%ebp),%eax
 475:	89 04 24             	mov    %eax,(%esp)
 478:	e8 1a ff ff ff       	call   397 <write>
}
 47d:	c9                   	leave  
 47e:	c3                   	ret    

0000047f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47f:	55                   	push   %ebp
 480:	89 e5                	mov    %esp,%ebp
 482:	56                   	push   %esi
 483:	53                   	push   %ebx
 484:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 487:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 48e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 492:	74 17                	je     4ab <printint+0x2c>
 494:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 498:	79 11                	jns    4ab <printint+0x2c>
    neg = 1;
 49a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a4:	f7 d8                	neg    %eax
 4a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a9:	eb 06                	jmp    4b1 <printint+0x32>
  } else {
    x = xx;
 4ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4bb:	8d 41 01             	lea    0x1(%ecx),%eax
 4be:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c7:	ba 00 00 00 00       	mov    $0x0,%edx
 4cc:	f7 f3                	div    %ebx
 4ce:	89 d0                	mov    %edx,%eax
 4d0:	0f b6 80 a8 0b 00 00 	movzbl 0xba8(%eax),%eax
 4d7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4db:	8b 75 10             	mov    0x10(%ebp),%esi
 4de:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4e1:	ba 00 00 00 00       	mov    $0x0,%edx
 4e6:	f7 f6                	div    %esi
 4e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4eb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ef:	75 c7                	jne    4b8 <printint+0x39>
  if(neg)
 4f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f5:	74 10                	je     507 <printint+0x88>
    buf[i++] = '-';
 4f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fa:	8d 50 01             	lea    0x1(%eax),%edx
 4fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 500:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 505:	eb 1f                	jmp    526 <printint+0xa7>
 507:	eb 1d                	jmp    526 <printint+0xa7>
    putc(fd, buf[i]);
 509:	8d 55 dc             	lea    -0x24(%ebp),%edx
 50c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50f:	01 d0                	add    %edx,%eax
 511:	0f b6 00             	movzbl (%eax),%eax
 514:	0f be c0             	movsbl %al,%eax
 517:	89 44 24 04          	mov    %eax,0x4(%esp)
 51b:	8b 45 08             	mov    0x8(%ebp),%eax
 51e:	89 04 24             	mov    %eax,(%esp)
 521:	e8 31 ff ff ff       	call   457 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 526:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 52a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 52e:	79 d9                	jns    509 <printint+0x8a>
    putc(fd, buf[i]);
}
 530:	83 c4 30             	add    $0x30,%esp
 533:	5b                   	pop    %ebx
 534:	5e                   	pop    %esi
 535:	5d                   	pop    %ebp
 536:	c3                   	ret    

00000537 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 537:	55                   	push   %ebp
 538:	89 e5                	mov    %esp,%ebp
 53a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 53d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 544:	8d 45 0c             	lea    0xc(%ebp),%eax
 547:	83 c0 04             	add    $0x4,%eax
 54a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 54d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 554:	e9 7c 01 00 00       	jmp    6d5 <printf+0x19e>
    c = fmt[i] & 0xff;
 559:	8b 55 0c             	mov    0xc(%ebp),%edx
 55c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 55f:	01 d0                	add    %edx,%eax
 561:	0f b6 00             	movzbl (%eax),%eax
 564:	0f be c0             	movsbl %al,%eax
 567:	25 ff 00 00 00       	and    $0xff,%eax
 56c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 56f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 573:	75 2c                	jne    5a1 <printf+0x6a>
      if(c == '%'){
 575:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 579:	75 0c                	jne    587 <printf+0x50>
        state = '%';
 57b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 582:	e9 4a 01 00 00       	jmp    6d1 <printf+0x19a>
      } else {
        putc(fd, c);
 587:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 58a:	0f be c0             	movsbl %al,%eax
 58d:	89 44 24 04          	mov    %eax,0x4(%esp)
 591:	8b 45 08             	mov    0x8(%ebp),%eax
 594:	89 04 24             	mov    %eax,(%esp)
 597:	e8 bb fe ff ff       	call   457 <putc>
 59c:	e9 30 01 00 00       	jmp    6d1 <printf+0x19a>
      }
    } else if(state == '%'){
 5a1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5a5:	0f 85 26 01 00 00    	jne    6d1 <printf+0x19a>
      if(c == 'd'){
 5ab:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5af:	75 2d                	jne    5de <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b4:	8b 00                	mov    (%eax),%eax
 5b6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5bd:	00 
 5be:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5c5:	00 
 5c6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ca:	8b 45 08             	mov    0x8(%ebp),%eax
 5cd:	89 04 24             	mov    %eax,(%esp)
 5d0:	e8 aa fe ff ff       	call   47f <printint>
        ap++;
 5d5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d9:	e9 ec 00 00 00       	jmp    6ca <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5de:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5e2:	74 06                	je     5ea <printf+0xb3>
 5e4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5e8:	75 2d                	jne    617 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ed:	8b 00                	mov    (%eax),%eax
 5ef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5f6:	00 
 5f7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5fe:	00 
 5ff:	89 44 24 04          	mov    %eax,0x4(%esp)
 603:	8b 45 08             	mov    0x8(%ebp),%eax
 606:	89 04 24             	mov    %eax,(%esp)
 609:	e8 71 fe ff ff       	call   47f <printint>
        ap++;
 60e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 612:	e9 b3 00 00 00       	jmp    6ca <printf+0x193>
      } else if(c == 's'){
 617:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 61b:	75 45                	jne    662 <printf+0x12b>
        s = (char*)*ap;
 61d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 620:	8b 00                	mov    (%eax),%eax
 622:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 625:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 629:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 62d:	75 09                	jne    638 <printf+0x101>
          s = "(null)";
 62f:	c7 45 f4 53 09 00 00 	movl   $0x953,-0xc(%ebp)
        while(*s != 0){
 636:	eb 1e                	jmp    656 <printf+0x11f>
 638:	eb 1c                	jmp    656 <printf+0x11f>
          putc(fd, *s);
 63a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63d:	0f b6 00             	movzbl (%eax),%eax
 640:	0f be c0             	movsbl %al,%eax
 643:	89 44 24 04          	mov    %eax,0x4(%esp)
 647:	8b 45 08             	mov    0x8(%ebp),%eax
 64a:	89 04 24             	mov    %eax,(%esp)
 64d:	e8 05 fe ff ff       	call   457 <putc>
          s++;
 652:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 656:	8b 45 f4             	mov    -0xc(%ebp),%eax
 659:	0f b6 00             	movzbl (%eax),%eax
 65c:	84 c0                	test   %al,%al
 65e:	75 da                	jne    63a <printf+0x103>
 660:	eb 68                	jmp    6ca <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 662:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 666:	75 1d                	jne    685 <printf+0x14e>
        putc(fd, *ap);
 668:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66b:	8b 00                	mov    (%eax),%eax
 66d:	0f be c0             	movsbl %al,%eax
 670:	89 44 24 04          	mov    %eax,0x4(%esp)
 674:	8b 45 08             	mov    0x8(%ebp),%eax
 677:	89 04 24             	mov    %eax,(%esp)
 67a:	e8 d8 fd ff ff       	call   457 <putc>
        ap++;
 67f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 683:	eb 45                	jmp    6ca <printf+0x193>
      } else if(c == '%'){
 685:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 689:	75 17                	jne    6a2 <printf+0x16b>
        putc(fd, c);
 68b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68e:	0f be c0             	movsbl %al,%eax
 691:	89 44 24 04          	mov    %eax,0x4(%esp)
 695:	8b 45 08             	mov    0x8(%ebp),%eax
 698:	89 04 24             	mov    %eax,(%esp)
 69b:	e8 b7 fd ff ff       	call   457 <putc>
 6a0:	eb 28                	jmp    6ca <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6a2:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6a9:	00 
 6aa:	8b 45 08             	mov    0x8(%ebp),%eax
 6ad:	89 04 24             	mov    %eax,(%esp)
 6b0:	e8 a2 fd ff ff       	call   457 <putc>
        putc(fd, c);
 6b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b8:	0f be c0             	movsbl %al,%eax
 6bb:	89 44 24 04          	mov    %eax,0x4(%esp)
 6bf:	8b 45 08             	mov    0x8(%ebp),%eax
 6c2:	89 04 24             	mov    %eax,(%esp)
 6c5:	e8 8d fd ff ff       	call   457 <putc>
      }
      state = 0;
 6ca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6d1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6d5:	8b 55 0c             	mov    0xc(%ebp),%edx
 6d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6db:	01 d0                	add    %edx,%eax
 6dd:	0f b6 00             	movzbl (%eax),%eax
 6e0:	84 c0                	test   %al,%al
 6e2:	0f 85 71 fe ff ff    	jne    559 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6e8:	c9                   	leave  
 6e9:	c3                   	ret    

000006ea <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ea:	55                   	push   %ebp
 6eb:	89 e5                	mov    %esp,%ebp
 6ed:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f0:	8b 45 08             	mov    0x8(%ebp),%eax
 6f3:	83 e8 08             	sub    $0x8,%eax
 6f6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f9:	a1 c4 0b 00 00       	mov    0xbc4,%eax
 6fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
 701:	eb 24                	jmp    727 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 703:	8b 45 fc             	mov    -0x4(%ebp),%eax
 706:	8b 00                	mov    (%eax),%eax
 708:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 70b:	77 12                	ja     71f <free+0x35>
 70d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 710:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 713:	77 24                	ja     739 <free+0x4f>
 715:	8b 45 fc             	mov    -0x4(%ebp),%eax
 718:	8b 00                	mov    (%eax),%eax
 71a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 71d:	77 1a                	ja     739 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 722:	8b 00                	mov    (%eax),%eax
 724:	89 45 fc             	mov    %eax,-0x4(%ebp)
 727:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 72d:	76 d4                	jbe    703 <free+0x19>
 72f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 732:	8b 00                	mov    (%eax),%eax
 734:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 737:	76 ca                	jbe    703 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 739:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73c:	8b 40 04             	mov    0x4(%eax),%eax
 73f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 746:	8b 45 f8             	mov    -0x8(%ebp),%eax
 749:	01 c2                	add    %eax,%edx
 74b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74e:	8b 00                	mov    (%eax),%eax
 750:	39 c2                	cmp    %eax,%edx
 752:	75 24                	jne    778 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 754:	8b 45 f8             	mov    -0x8(%ebp),%eax
 757:	8b 50 04             	mov    0x4(%eax),%edx
 75a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75d:	8b 00                	mov    (%eax),%eax
 75f:	8b 40 04             	mov    0x4(%eax),%eax
 762:	01 c2                	add    %eax,%edx
 764:	8b 45 f8             	mov    -0x8(%ebp),%eax
 767:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 76a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76d:	8b 00                	mov    (%eax),%eax
 76f:	8b 10                	mov    (%eax),%edx
 771:	8b 45 f8             	mov    -0x8(%ebp),%eax
 774:	89 10                	mov    %edx,(%eax)
 776:	eb 0a                	jmp    782 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 778:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77b:	8b 10                	mov    (%eax),%edx
 77d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 780:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 782:	8b 45 fc             	mov    -0x4(%ebp),%eax
 785:	8b 40 04             	mov    0x4(%eax),%eax
 788:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 78f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 792:	01 d0                	add    %edx,%eax
 794:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 797:	75 20                	jne    7b9 <free+0xcf>
    p->s.size += bp->s.size;
 799:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79c:	8b 50 04             	mov    0x4(%eax),%edx
 79f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a2:	8b 40 04             	mov    0x4(%eax),%eax
 7a5:	01 c2                	add    %eax,%edx
 7a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7aa:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b0:	8b 10                	mov    (%eax),%edx
 7b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b5:	89 10                	mov    %edx,(%eax)
 7b7:	eb 08                	jmp    7c1 <free+0xd7>
  } else
    p->s.ptr = bp;
 7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7bf:	89 10                	mov    %edx,(%eax)
  freep = p;
 7c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c4:	a3 c4 0b 00 00       	mov    %eax,0xbc4
}
 7c9:	c9                   	leave  
 7ca:	c3                   	ret    

000007cb <morecore>:

static Header*
morecore(uint nu)
{
 7cb:	55                   	push   %ebp
 7cc:	89 e5                	mov    %esp,%ebp
 7ce:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7d1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7d8:	77 07                	ja     7e1 <morecore+0x16>
    nu = 4096;
 7da:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7e1:	8b 45 08             	mov    0x8(%ebp),%eax
 7e4:	c1 e0 03             	shl    $0x3,%eax
 7e7:	89 04 24             	mov    %eax,(%esp)
 7ea:	e8 10 fc ff ff       	call   3ff <sbrk>
 7ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7f2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7f6:	75 07                	jne    7ff <morecore+0x34>
    return 0;
 7f8:	b8 00 00 00 00       	mov    $0x0,%eax
 7fd:	eb 22                	jmp    821 <morecore+0x56>
  hp = (Header*)p;
 7ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 802:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 805:	8b 45 f0             	mov    -0x10(%ebp),%eax
 808:	8b 55 08             	mov    0x8(%ebp),%edx
 80b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 80e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 811:	83 c0 08             	add    $0x8,%eax
 814:	89 04 24             	mov    %eax,(%esp)
 817:	e8 ce fe ff ff       	call   6ea <free>
  return freep;
 81c:	a1 c4 0b 00 00       	mov    0xbc4,%eax
}
 821:	c9                   	leave  
 822:	c3                   	ret    

00000823 <malloc>:

void*
malloc(uint nbytes)
{
 823:	55                   	push   %ebp
 824:	89 e5                	mov    %esp,%ebp
 826:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 829:	8b 45 08             	mov    0x8(%ebp),%eax
 82c:	83 c0 07             	add    $0x7,%eax
 82f:	c1 e8 03             	shr    $0x3,%eax
 832:	83 c0 01             	add    $0x1,%eax
 835:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 838:	a1 c4 0b 00 00       	mov    0xbc4,%eax
 83d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 840:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 844:	75 23                	jne    869 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 846:	c7 45 f0 bc 0b 00 00 	movl   $0xbbc,-0x10(%ebp)
 84d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 850:	a3 c4 0b 00 00       	mov    %eax,0xbc4
 855:	a1 c4 0b 00 00       	mov    0xbc4,%eax
 85a:	a3 bc 0b 00 00       	mov    %eax,0xbbc
    base.s.size = 0;
 85f:	c7 05 c0 0b 00 00 00 	movl   $0x0,0xbc0
 866:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 869:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86c:	8b 00                	mov    (%eax),%eax
 86e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 871:	8b 45 f4             	mov    -0xc(%ebp),%eax
 874:	8b 40 04             	mov    0x4(%eax),%eax
 877:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 87a:	72 4d                	jb     8c9 <malloc+0xa6>
      if(p->s.size == nunits)
 87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87f:	8b 40 04             	mov    0x4(%eax),%eax
 882:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 885:	75 0c                	jne    893 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 887:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88a:	8b 10                	mov    (%eax),%edx
 88c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88f:	89 10                	mov    %edx,(%eax)
 891:	eb 26                	jmp    8b9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 893:	8b 45 f4             	mov    -0xc(%ebp),%eax
 896:	8b 40 04             	mov    0x4(%eax),%eax
 899:	2b 45 ec             	sub    -0x14(%ebp),%eax
 89c:	89 c2                	mov    %eax,%edx
 89e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a7:	8b 40 04             	mov    0x4(%eax),%eax
 8aa:	c1 e0 03             	shl    $0x3,%eax
 8ad:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8b6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bc:	a3 c4 0b 00 00       	mov    %eax,0xbc4
      return (void*)(p + 1);
 8c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c4:	83 c0 08             	add    $0x8,%eax
 8c7:	eb 38                	jmp    901 <malloc+0xde>
    }
    if(p == freep)
 8c9:	a1 c4 0b 00 00       	mov    0xbc4,%eax
 8ce:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8d1:	75 1b                	jne    8ee <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8d6:	89 04 24             	mov    %eax,(%esp)
 8d9:	e8 ed fe ff ff       	call   7cb <morecore>
 8de:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8e5:	75 07                	jne    8ee <malloc+0xcb>
        return 0;
 8e7:	b8 00 00 00 00       	mov    $0x0,%eax
 8ec:	eb 13                	jmp    901 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f7:	8b 00                	mov    (%eax),%eax
 8f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8fc:	e9 70 ff ff ff       	jmp    871 <malloc+0x4e>
}
 901:	c9                   	leave  
 902:	c3                   	ret    
