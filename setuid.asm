
_setuid:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"
int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
    exit();
   6:	e8 68 02 00 00       	call   273 <exit>

0000000b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
   b:	55                   	push   %ebp
   c:	89 e5                	mov    %esp,%ebp
   e:	57                   	push   %edi
   f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  13:	8b 55 10             	mov    0x10(%ebp),%edx
  16:	8b 45 0c             	mov    0xc(%ebp),%eax
  19:	89 cb                	mov    %ecx,%ebx
  1b:	89 df                	mov    %ebx,%edi
  1d:	89 d1                	mov    %edx,%ecx
  1f:	fc                   	cld    
  20:	f3 aa                	rep stos %al,%es:(%edi)
  22:	89 ca                	mov    %ecx,%edx
  24:	89 fb                	mov    %edi,%ebx
  26:	89 5d 08             	mov    %ebx,0x8(%ebp)
  29:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  2c:	5b                   	pop    %ebx
  2d:	5f                   	pop    %edi
  2e:	5d                   	pop    %ebp
  2f:	c3                   	ret    

00000030 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  30:	55                   	push   %ebp
  31:	89 e5                	mov    %esp,%ebp
  33:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  36:	8b 45 08             	mov    0x8(%ebp),%eax
  39:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  3c:	90                   	nop
  3d:	8b 45 08             	mov    0x8(%ebp),%eax
  40:	8d 50 01             	lea    0x1(%eax),%edx
  43:	89 55 08             	mov    %edx,0x8(%ebp)
  46:	8b 55 0c             	mov    0xc(%ebp),%edx
  49:	8d 4a 01             	lea    0x1(%edx),%ecx
  4c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  4f:	0f b6 12             	movzbl (%edx),%edx
  52:	88 10                	mov    %dl,(%eax)
  54:	0f b6 00             	movzbl (%eax),%eax
  57:	84 c0                	test   %al,%al
  59:	75 e2                	jne    3d <strcpy+0xd>
    ;
  return os;
  5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  5e:	c9                   	leave  
  5f:	c3                   	ret    

00000060 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  60:	55                   	push   %ebp
  61:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  63:	eb 08                	jmp    6d <strcmp+0xd>
    p++, q++;
  65:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  69:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  6d:	8b 45 08             	mov    0x8(%ebp),%eax
  70:	0f b6 00             	movzbl (%eax),%eax
  73:	84 c0                	test   %al,%al
  75:	74 10                	je     87 <strcmp+0x27>
  77:	8b 45 08             	mov    0x8(%ebp),%eax
  7a:	0f b6 10             	movzbl (%eax),%edx
  7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  80:	0f b6 00             	movzbl (%eax),%eax
  83:	38 c2                	cmp    %al,%dl
  85:	74 de                	je     65 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  87:	8b 45 08             	mov    0x8(%ebp),%eax
  8a:	0f b6 00             	movzbl (%eax),%eax
  8d:	0f b6 d0             	movzbl %al,%edx
  90:	8b 45 0c             	mov    0xc(%ebp),%eax
  93:	0f b6 00             	movzbl (%eax),%eax
  96:	0f b6 c0             	movzbl %al,%eax
  99:	29 c2                	sub    %eax,%edx
  9b:	89 d0                	mov    %edx,%eax
}
  9d:	5d                   	pop    %ebp
  9e:	c3                   	ret    

0000009f <strlen>:

uint
strlen(char *s)
{
  9f:	55                   	push   %ebp
  a0:	89 e5                	mov    %esp,%ebp
  a2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  a5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  ac:	eb 04                	jmp    b2 <strlen+0x13>
  ae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  b5:	8b 45 08             	mov    0x8(%ebp),%eax
  b8:	01 d0                	add    %edx,%eax
  ba:	0f b6 00             	movzbl (%eax),%eax
  bd:	84 c0                	test   %al,%al
  bf:	75 ed                	jne    ae <strlen+0xf>
    ;
  return n;
  c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c4:	c9                   	leave  
  c5:	c3                   	ret    

000000c6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c6:	55                   	push   %ebp
  c7:	89 e5                	mov    %esp,%ebp
  c9:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  cc:	8b 45 10             	mov    0x10(%ebp),%eax
  cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  da:	8b 45 08             	mov    0x8(%ebp),%eax
  dd:	89 04 24             	mov    %eax,(%esp)
  e0:	e8 26 ff ff ff       	call   b <stosb>
  return dst;
  e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  e8:	c9                   	leave  
  e9:	c3                   	ret    

000000ea <strchr>:

char*
strchr(const char *s, char c)
{
  ea:	55                   	push   %ebp
  eb:	89 e5                	mov    %esp,%ebp
  ed:	83 ec 04             	sub    $0x4,%esp
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
  f6:	eb 14                	jmp    10c <strchr+0x22>
    if(*s == c)
  f8:	8b 45 08             	mov    0x8(%ebp),%eax
  fb:	0f b6 00             	movzbl (%eax),%eax
  fe:	3a 45 fc             	cmp    -0x4(%ebp),%al
 101:	75 05                	jne    108 <strchr+0x1e>
      return (char*)s;
 103:	8b 45 08             	mov    0x8(%ebp),%eax
 106:	eb 13                	jmp    11b <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 108:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 10c:	8b 45 08             	mov    0x8(%ebp),%eax
 10f:	0f b6 00             	movzbl (%eax),%eax
 112:	84 c0                	test   %al,%al
 114:	75 e2                	jne    f8 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 116:	b8 00 00 00 00       	mov    $0x0,%eax
}
 11b:	c9                   	leave  
 11c:	c3                   	ret    

0000011d <gets>:

char*
gets(char *buf, int max)
{
 11d:	55                   	push   %ebp
 11e:	89 e5                	mov    %esp,%ebp
 120:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 123:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 12a:	eb 4c                	jmp    178 <gets+0x5b>
    cc = read(0, &c, 1);
 12c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 133:	00 
 134:	8d 45 ef             	lea    -0x11(%ebp),%eax
 137:	89 44 24 04          	mov    %eax,0x4(%esp)
 13b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 142:	e8 44 01 00 00       	call   28b <read>
 147:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 14a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 14e:	7f 02                	jg     152 <gets+0x35>
      break;
 150:	eb 31                	jmp    183 <gets+0x66>
    buf[i++] = c;
 152:	8b 45 f4             	mov    -0xc(%ebp),%eax
 155:	8d 50 01             	lea    0x1(%eax),%edx
 158:	89 55 f4             	mov    %edx,-0xc(%ebp)
 15b:	89 c2                	mov    %eax,%edx
 15d:	8b 45 08             	mov    0x8(%ebp),%eax
 160:	01 c2                	add    %eax,%edx
 162:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 166:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 168:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 16c:	3c 0a                	cmp    $0xa,%al
 16e:	74 13                	je     183 <gets+0x66>
 170:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 174:	3c 0d                	cmp    $0xd,%al
 176:	74 0b                	je     183 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 178:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17b:	83 c0 01             	add    $0x1,%eax
 17e:	3b 45 0c             	cmp    0xc(%ebp),%eax
 181:	7c a9                	jl     12c <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 183:	8b 55 f4             	mov    -0xc(%ebp),%edx
 186:	8b 45 08             	mov    0x8(%ebp),%eax
 189:	01 d0                	add    %edx,%eax
 18b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 18e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 191:	c9                   	leave  
 192:	c3                   	ret    

00000193 <stat>:

int
stat(char *n, struct stat *st)
{
 193:	55                   	push   %ebp
 194:	89 e5                	mov    %esp,%ebp
 196:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 199:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1a0:	00 
 1a1:	8b 45 08             	mov    0x8(%ebp),%eax
 1a4:	89 04 24             	mov    %eax,(%esp)
 1a7:	e8 07 01 00 00       	call   2b3 <open>
 1ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1b3:	79 07                	jns    1bc <stat+0x29>
    return -1;
 1b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1ba:	eb 23                	jmp    1df <stat+0x4c>
  r = fstat(fd, st);
 1bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c6:	89 04 24             	mov    %eax,(%esp)
 1c9:	e8 fd 00 00 00       	call   2cb <fstat>
 1ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d4:	89 04 24             	mov    %eax,(%esp)
 1d7:	e8 bf 00 00 00       	call   29b <close>
  return r;
 1dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1df:	c9                   	leave  
 1e0:	c3                   	ret    

000001e1 <atoi>:

int
atoi(const char *s)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1e7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1ee:	eb 25                	jmp    215 <atoi+0x34>
    n = n*10 + *s++ - '0';
 1f0:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1f3:	89 d0                	mov    %edx,%eax
 1f5:	c1 e0 02             	shl    $0x2,%eax
 1f8:	01 d0                	add    %edx,%eax
 1fa:	01 c0                	add    %eax,%eax
 1fc:	89 c1                	mov    %eax,%ecx
 1fe:	8b 45 08             	mov    0x8(%ebp),%eax
 201:	8d 50 01             	lea    0x1(%eax),%edx
 204:	89 55 08             	mov    %edx,0x8(%ebp)
 207:	0f b6 00             	movzbl (%eax),%eax
 20a:	0f be c0             	movsbl %al,%eax
 20d:	01 c8                	add    %ecx,%eax
 20f:	83 e8 30             	sub    $0x30,%eax
 212:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	0f b6 00             	movzbl (%eax),%eax
 21b:	3c 2f                	cmp    $0x2f,%al
 21d:	7e 0a                	jle    229 <atoi+0x48>
 21f:	8b 45 08             	mov    0x8(%ebp),%eax
 222:	0f b6 00             	movzbl (%eax),%eax
 225:	3c 39                	cmp    $0x39,%al
 227:	7e c7                	jle    1f0 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 229:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 22c:	c9                   	leave  
 22d:	c3                   	ret    

0000022e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 22e:	55                   	push   %ebp
 22f:	89 e5                	mov    %esp,%ebp
 231:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 23a:	8b 45 0c             	mov    0xc(%ebp),%eax
 23d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 240:	eb 17                	jmp    259 <memmove+0x2b>
    *dst++ = *src++;
 242:	8b 45 fc             	mov    -0x4(%ebp),%eax
 245:	8d 50 01             	lea    0x1(%eax),%edx
 248:	89 55 fc             	mov    %edx,-0x4(%ebp)
 24b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 24e:	8d 4a 01             	lea    0x1(%edx),%ecx
 251:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 254:	0f b6 12             	movzbl (%edx),%edx
 257:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 259:	8b 45 10             	mov    0x10(%ebp),%eax
 25c:	8d 50 ff             	lea    -0x1(%eax),%edx
 25f:	89 55 10             	mov    %edx,0x10(%ebp)
 262:	85 c0                	test   %eax,%eax
 264:	7f dc                	jg     242 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 266:	8b 45 08             	mov    0x8(%ebp),%eax
}
 269:	c9                   	leave  
 26a:	c3                   	ret    

0000026b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 26b:	b8 01 00 00 00       	mov    $0x1,%eax
 270:	cd 40                	int    $0x40
 272:	c3                   	ret    

00000273 <exit>:
SYSCALL(exit)
 273:	b8 02 00 00 00       	mov    $0x2,%eax
 278:	cd 40                	int    $0x40
 27a:	c3                   	ret    

0000027b <wait>:
SYSCALL(wait)
 27b:	b8 03 00 00 00       	mov    $0x3,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <pipe>:
SYSCALL(pipe)
 283:	b8 04 00 00 00       	mov    $0x4,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <read>:
SYSCALL(read)
 28b:	b8 05 00 00 00       	mov    $0x5,%eax
 290:	cd 40                	int    $0x40
 292:	c3                   	ret    

00000293 <write>:
SYSCALL(write)
 293:	b8 10 00 00 00       	mov    $0x10,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <close>:
SYSCALL(close)
 29b:	b8 15 00 00 00       	mov    $0x15,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <kill>:
SYSCALL(kill)
 2a3:	b8 06 00 00 00       	mov    $0x6,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    

000002ab <exec>:
SYSCALL(exec)
 2ab:	b8 07 00 00 00       	mov    $0x7,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret    

000002b3 <open>:
SYSCALL(open)
 2b3:	b8 0f 00 00 00       	mov    $0xf,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret    

000002bb <mknod>:
SYSCALL(mknod)
 2bb:	b8 11 00 00 00       	mov    $0x11,%eax
 2c0:	cd 40                	int    $0x40
 2c2:	c3                   	ret    

000002c3 <unlink>:
SYSCALL(unlink)
 2c3:	b8 12 00 00 00       	mov    $0x12,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <fstat>:
SYSCALL(fstat)
 2cb:	b8 08 00 00 00       	mov    $0x8,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <link>:
SYSCALL(link)
 2d3:	b8 13 00 00 00       	mov    $0x13,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <mkdir>:
SYSCALL(mkdir)
 2db:	b8 14 00 00 00       	mov    $0x14,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <chdir>:
SYSCALL(chdir)
 2e3:	b8 09 00 00 00       	mov    $0x9,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <dup>:
SYSCALL(dup)
 2eb:	b8 0a 00 00 00       	mov    $0xa,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <getpid>:
SYSCALL(getpid)
 2f3:	b8 0b 00 00 00       	mov    $0xb,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <sbrk>:
SYSCALL(sbrk)
 2fb:	b8 0c 00 00 00       	mov    $0xc,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <sleep>:
SYSCALL(sleep)
 303:	b8 0d 00 00 00       	mov    $0xd,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <uptime>:
SYSCALL(uptime)
 30b:	b8 0e 00 00 00       	mov    $0xe,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <date>:
SYSCALL(date)
 313:	b8 16 00 00 00       	mov    $0x16,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <timem>:
SYSCALL(timem)
 31b:	b8 17 00 00 00       	mov    $0x17,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <getuid>:
SYSCALL(getuid)
 323:	b8 18 00 00 00       	mov    $0x18,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <getgid>:
SYSCALL(getgid)
 32b:	b8 19 00 00 00       	mov    $0x19,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <getppid>:
SYSCALL(getppid)
 333:	b8 1a 00 00 00       	mov    $0x1a,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <setuid>:
SYSCALL(setuid)
 33b:	b8 1b 00 00 00       	mov    $0x1b,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <setgid>:
SYSCALL(setgid)
 343:	b8 1c 00 00 00       	mov    $0x1c,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <getprocs>:
SYSCALL(getprocs)
 34b:	b8 1d 00 00 00       	mov    $0x1d,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 353:	55                   	push   %ebp
 354:	89 e5                	mov    %esp,%ebp
 356:	83 ec 18             	sub    $0x18,%esp
 359:	8b 45 0c             	mov    0xc(%ebp),%eax
 35c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 35f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 366:	00 
 367:	8d 45 f4             	lea    -0xc(%ebp),%eax
 36a:	89 44 24 04          	mov    %eax,0x4(%esp)
 36e:	8b 45 08             	mov    0x8(%ebp),%eax
 371:	89 04 24             	mov    %eax,(%esp)
 374:	e8 1a ff ff ff       	call   293 <write>
}
 379:	c9                   	leave  
 37a:	c3                   	ret    

0000037b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 37b:	55                   	push   %ebp
 37c:	89 e5                	mov    %esp,%ebp
 37e:	56                   	push   %esi
 37f:	53                   	push   %ebx
 380:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 383:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 38a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 38e:	74 17                	je     3a7 <printint+0x2c>
 390:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 394:	79 11                	jns    3a7 <printint+0x2c>
    neg = 1;
 396:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 39d:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a0:	f7 d8                	neg    %eax
 3a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3a5:	eb 06                	jmp    3ad <printint+0x32>
  } else {
    x = xx;
 3a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3b4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3b7:	8d 41 01             	lea    0x1(%ecx),%eax
 3ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3c3:	ba 00 00 00 00       	mov    $0x0,%edx
 3c8:	f7 f3                	div    %ebx
 3ca:	89 d0                	mov    %edx,%eax
 3cc:	0f b6 80 4c 0a 00 00 	movzbl 0xa4c(%eax),%eax
 3d3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3d7:	8b 75 10             	mov    0x10(%ebp),%esi
 3da:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3dd:	ba 00 00 00 00       	mov    $0x0,%edx
 3e2:	f7 f6                	div    %esi
 3e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3eb:	75 c7                	jne    3b4 <printint+0x39>
  if(neg)
 3ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3f1:	74 10                	je     403 <printint+0x88>
    buf[i++] = '-';
 3f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f6:	8d 50 01             	lea    0x1(%eax),%edx
 3f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3fc:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 401:	eb 1f                	jmp    422 <printint+0xa7>
 403:	eb 1d                	jmp    422 <printint+0xa7>
    putc(fd, buf[i]);
 405:	8d 55 dc             	lea    -0x24(%ebp),%edx
 408:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40b:	01 d0                	add    %edx,%eax
 40d:	0f b6 00             	movzbl (%eax),%eax
 410:	0f be c0             	movsbl %al,%eax
 413:	89 44 24 04          	mov    %eax,0x4(%esp)
 417:	8b 45 08             	mov    0x8(%ebp),%eax
 41a:	89 04 24             	mov    %eax,(%esp)
 41d:	e8 31 ff ff ff       	call   353 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 422:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 426:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 42a:	79 d9                	jns    405 <printint+0x8a>
    putc(fd, buf[i]);
}
 42c:	83 c4 30             	add    $0x30,%esp
 42f:	5b                   	pop    %ebx
 430:	5e                   	pop    %esi
 431:	5d                   	pop    %ebp
 432:	c3                   	ret    

00000433 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 433:	55                   	push   %ebp
 434:	89 e5                	mov    %esp,%ebp
 436:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 439:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 440:	8d 45 0c             	lea    0xc(%ebp),%eax
 443:	83 c0 04             	add    $0x4,%eax
 446:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 449:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 450:	e9 7c 01 00 00       	jmp    5d1 <printf+0x19e>
    c = fmt[i] & 0xff;
 455:	8b 55 0c             	mov    0xc(%ebp),%edx
 458:	8b 45 f0             	mov    -0x10(%ebp),%eax
 45b:	01 d0                	add    %edx,%eax
 45d:	0f b6 00             	movzbl (%eax),%eax
 460:	0f be c0             	movsbl %al,%eax
 463:	25 ff 00 00 00       	and    $0xff,%eax
 468:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 46b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 46f:	75 2c                	jne    49d <printf+0x6a>
      if(c == '%'){
 471:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 475:	75 0c                	jne    483 <printf+0x50>
        state = '%';
 477:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 47e:	e9 4a 01 00 00       	jmp    5cd <printf+0x19a>
      } else {
        putc(fd, c);
 483:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 486:	0f be c0             	movsbl %al,%eax
 489:	89 44 24 04          	mov    %eax,0x4(%esp)
 48d:	8b 45 08             	mov    0x8(%ebp),%eax
 490:	89 04 24             	mov    %eax,(%esp)
 493:	e8 bb fe ff ff       	call   353 <putc>
 498:	e9 30 01 00 00       	jmp    5cd <printf+0x19a>
      }
    } else if(state == '%'){
 49d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4a1:	0f 85 26 01 00 00    	jne    5cd <printf+0x19a>
      if(c == 'd'){
 4a7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4ab:	75 2d                	jne    4da <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4b0:	8b 00                	mov    (%eax),%eax
 4b2:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4b9:	00 
 4ba:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4c1:	00 
 4c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c6:	8b 45 08             	mov    0x8(%ebp),%eax
 4c9:	89 04 24             	mov    %eax,(%esp)
 4cc:	e8 aa fe ff ff       	call   37b <printint>
        ap++;
 4d1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4d5:	e9 ec 00 00 00       	jmp    5c6 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 4da:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4de:	74 06                	je     4e6 <printf+0xb3>
 4e0:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4e4:	75 2d                	jne    513 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e9:	8b 00                	mov    (%eax),%eax
 4eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4f2:	00 
 4f3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4fa:	00 
 4fb:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ff:	8b 45 08             	mov    0x8(%ebp),%eax
 502:	89 04 24             	mov    %eax,(%esp)
 505:	e8 71 fe ff ff       	call   37b <printint>
        ap++;
 50a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 50e:	e9 b3 00 00 00       	jmp    5c6 <printf+0x193>
      } else if(c == 's'){
 513:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 517:	75 45                	jne    55e <printf+0x12b>
        s = (char*)*ap;
 519:	8b 45 e8             	mov    -0x18(%ebp),%eax
 51c:	8b 00                	mov    (%eax),%eax
 51e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 521:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 525:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 529:	75 09                	jne    534 <printf+0x101>
          s = "(null)";
 52b:	c7 45 f4 ff 07 00 00 	movl   $0x7ff,-0xc(%ebp)
        while(*s != 0){
 532:	eb 1e                	jmp    552 <printf+0x11f>
 534:	eb 1c                	jmp    552 <printf+0x11f>
          putc(fd, *s);
 536:	8b 45 f4             	mov    -0xc(%ebp),%eax
 539:	0f b6 00             	movzbl (%eax),%eax
 53c:	0f be c0             	movsbl %al,%eax
 53f:	89 44 24 04          	mov    %eax,0x4(%esp)
 543:	8b 45 08             	mov    0x8(%ebp),%eax
 546:	89 04 24             	mov    %eax,(%esp)
 549:	e8 05 fe ff ff       	call   353 <putc>
          s++;
 54e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 552:	8b 45 f4             	mov    -0xc(%ebp),%eax
 555:	0f b6 00             	movzbl (%eax),%eax
 558:	84 c0                	test   %al,%al
 55a:	75 da                	jne    536 <printf+0x103>
 55c:	eb 68                	jmp    5c6 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 55e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 562:	75 1d                	jne    581 <printf+0x14e>
        putc(fd, *ap);
 564:	8b 45 e8             	mov    -0x18(%ebp),%eax
 567:	8b 00                	mov    (%eax),%eax
 569:	0f be c0             	movsbl %al,%eax
 56c:	89 44 24 04          	mov    %eax,0x4(%esp)
 570:	8b 45 08             	mov    0x8(%ebp),%eax
 573:	89 04 24             	mov    %eax,(%esp)
 576:	e8 d8 fd ff ff       	call   353 <putc>
        ap++;
 57b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 57f:	eb 45                	jmp    5c6 <printf+0x193>
      } else if(c == '%'){
 581:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 585:	75 17                	jne    59e <printf+0x16b>
        putc(fd, c);
 587:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 58a:	0f be c0             	movsbl %al,%eax
 58d:	89 44 24 04          	mov    %eax,0x4(%esp)
 591:	8b 45 08             	mov    0x8(%ebp),%eax
 594:	89 04 24             	mov    %eax,(%esp)
 597:	e8 b7 fd ff ff       	call   353 <putc>
 59c:	eb 28                	jmp    5c6 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 59e:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5a5:	00 
 5a6:	8b 45 08             	mov    0x8(%ebp),%eax
 5a9:	89 04 24             	mov    %eax,(%esp)
 5ac:	e8 a2 fd ff ff       	call   353 <putc>
        putc(fd, c);
 5b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5b4:	0f be c0             	movsbl %al,%eax
 5b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5bb:	8b 45 08             	mov    0x8(%ebp),%eax
 5be:	89 04 24             	mov    %eax,(%esp)
 5c1:	e8 8d fd ff ff       	call   353 <putc>
      }
      state = 0;
 5c6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5cd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5d1:	8b 55 0c             	mov    0xc(%ebp),%edx
 5d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5d7:	01 d0                	add    %edx,%eax
 5d9:	0f b6 00             	movzbl (%eax),%eax
 5dc:	84 c0                	test   %al,%al
 5de:	0f 85 71 fe ff ff    	jne    455 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5e4:	c9                   	leave  
 5e5:	c3                   	ret    

000005e6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5e6:	55                   	push   %ebp
 5e7:	89 e5                	mov    %esp,%ebp
 5e9:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5ec:	8b 45 08             	mov    0x8(%ebp),%eax
 5ef:	83 e8 08             	sub    $0x8,%eax
 5f2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5f5:	a1 68 0a 00 00       	mov    0xa68,%eax
 5fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5fd:	eb 24                	jmp    623 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 602:	8b 00                	mov    (%eax),%eax
 604:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 607:	77 12                	ja     61b <free+0x35>
 609:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 60f:	77 24                	ja     635 <free+0x4f>
 611:	8b 45 fc             	mov    -0x4(%ebp),%eax
 614:	8b 00                	mov    (%eax),%eax
 616:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 619:	77 1a                	ja     635 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 61b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61e:	8b 00                	mov    (%eax),%eax
 620:	89 45 fc             	mov    %eax,-0x4(%ebp)
 623:	8b 45 f8             	mov    -0x8(%ebp),%eax
 626:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 629:	76 d4                	jbe    5ff <free+0x19>
 62b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62e:	8b 00                	mov    (%eax),%eax
 630:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 633:	76 ca                	jbe    5ff <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 635:	8b 45 f8             	mov    -0x8(%ebp),%eax
 638:	8b 40 04             	mov    0x4(%eax),%eax
 63b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 642:	8b 45 f8             	mov    -0x8(%ebp),%eax
 645:	01 c2                	add    %eax,%edx
 647:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64a:	8b 00                	mov    (%eax),%eax
 64c:	39 c2                	cmp    %eax,%edx
 64e:	75 24                	jne    674 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 650:	8b 45 f8             	mov    -0x8(%ebp),%eax
 653:	8b 50 04             	mov    0x4(%eax),%edx
 656:	8b 45 fc             	mov    -0x4(%ebp),%eax
 659:	8b 00                	mov    (%eax),%eax
 65b:	8b 40 04             	mov    0x4(%eax),%eax
 65e:	01 c2                	add    %eax,%edx
 660:	8b 45 f8             	mov    -0x8(%ebp),%eax
 663:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 666:	8b 45 fc             	mov    -0x4(%ebp),%eax
 669:	8b 00                	mov    (%eax),%eax
 66b:	8b 10                	mov    (%eax),%edx
 66d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 670:	89 10                	mov    %edx,(%eax)
 672:	eb 0a                	jmp    67e <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 674:	8b 45 fc             	mov    -0x4(%ebp),%eax
 677:	8b 10                	mov    (%eax),%edx
 679:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67c:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 67e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 681:	8b 40 04             	mov    0x4(%eax),%eax
 684:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 68b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68e:	01 d0                	add    %edx,%eax
 690:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 693:	75 20                	jne    6b5 <free+0xcf>
    p->s.size += bp->s.size;
 695:	8b 45 fc             	mov    -0x4(%ebp),%eax
 698:	8b 50 04             	mov    0x4(%eax),%edx
 69b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69e:	8b 40 04             	mov    0x4(%eax),%eax
 6a1:	01 c2                	add    %eax,%edx
 6a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ac:	8b 10                	mov    (%eax),%edx
 6ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b1:	89 10                	mov    %edx,(%eax)
 6b3:	eb 08                	jmp    6bd <free+0xd7>
  } else
    p->s.ptr = bp;
 6b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6bb:	89 10                	mov    %edx,(%eax)
  freep = p;
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	a3 68 0a 00 00       	mov    %eax,0xa68
}
 6c5:	c9                   	leave  
 6c6:	c3                   	ret    

000006c7 <morecore>:

static Header*
morecore(uint nu)
{
 6c7:	55                   	push   %ebp
 6c8:	89 e5                	mov    %esp,%ebp
 6ca:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6cd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6d4:	77 07                	ja     6dd <morecore+0x16>
    nu = 4096;
 6d6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6dd:	8b 45 08             	mov    0x8(%ebp),%eax
 6e0:	c1 e0 03             	shl    $0x3,%eax
 6e3:	89 04 24             	mov    %eax,(%esp)
 6e6:	e8 10 fc ff ff       	call   2fb <sbrk>
 6eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6ee:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6f2:	75 07                	jne    6fb <morecore+0x34>
    return 0;
 6f4:	b8 00 00 00 00       	mov    $0x0,%eax
 6f9:	eb 22                	jmp    71d <morecore+0x56>
  hp = (Header*)p;
 6fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 701:	8b 45 f0             	mov    -0x10(%ebp),%eax
 704:	8b 55 08             	mov    0x8(%ebp),%edx
 707:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 70a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 70d:	83 c0 08             	add    $0x8,%eax
 710:	89 04 24             	mov    %eax,(%esp)
 713:	e8 ce fe ff ff       	call   5e6 <free>
  return freep;
 718:	a1 68 0a 00 00       	mov    0xa68,%eax
}
 71d:	c9                   	leave  
 71e:	c3                   	ret    

0000071f <malloc>:

void*
malloc(uint nbytes)
{
 71f:	55                   	push   %ebp
 720:	89 e5                	mov    %esp,%ebp
 722:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 725:	8b 45 08             	mov    0x8(%ebp),%eax
 728:	83 c0 07             	add    $0x7,%eax
 72b:	c1 e8 03             	shr    $0x3,%eax
 72e:	83 c0 01             	add    $0x1,%eax
 731:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 734:	a1 68 0a 00 00       	mov    0xa68,%eax
 739:	89 45 f0             	mov    %eax,-0x10(%ebp)
 73c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 740:	75 23                	jne    765 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 742:	c7 45 f0 60 0a 00 00 	movl   $0xa60,-0x10(%ebp)
 749:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74c:	a3 68 0a 00 00       	mov    %eax,0xa68
 751:	a1 68 0a 00 00       	mov    0xa68,%eax
 756:	a3 60 0a 00 00       	mov    %eax,0xa60
    base.s.size = 0;
 75b:	c7 05 64 0a 00 00 00 	movl   $0x0,0xa64
 762:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 765:	8b 45 f0             	mov    -0x10(%ebp),%eax
 768:	8b 00                	mov    (%eax),%eax
 76a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 76d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 770:	8b 40 04             	mov    0x4(%eax),%eax
 773:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 776:	72 4d                	jb     7c5 <malloc+0xa6>
      if(p->s.size == nunits)
 778:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77b:	8b 40 04             	mov    0x4(%eax),%eax
 77e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 781:	75 0c                	jne    78f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 783:	8b 45 f4             	mov    -0xc(%ebp),%eax
 786:	8b 10                	mov    (%eax),%edx
 788:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78b:	89 10                	mov    %edx,(%eax)
 78d:	eb 26                	jmp    7b5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 78f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 792:	8b 40 04             	mov    0x4(%eax),%eax
 795:	2b 45 ec             	sub    -0x14(%ebp),%eax
 798:	89 c2                	mov    %eax,%edx
 79a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a3:	8b 40 04             	mov    0x4(%eax),%eax
 7a6:	c1 e0 03             	shl    $0x3,%eax
 7a9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7af:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7b2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b8:	a3 68 0a 00 00       	mov    %eax,0xa68
      return (void*)(p + 1);
 7bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c0:	83 c0 08             	add    $0x8,%eax
 7c3:	eb 38                	jmp    7fd <malloc+0xde>
    }
    if(p == freep)
 7c5:	a1 68 0a 00 00       	mov    0xa68,%eax
 7ca:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7cd:	75 1b                	jne    7ea <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7d2:	89 04 24             	mov    %eax,(%esp)
 7d5:	e8 ed fe ff ff       	call   6c7 <morecore>
 7da:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e1:	75 07                	jne    7ea <malloc+0xcb>
        return 0;
 7e3:	b8 00 00 00 00       	mov    $0x0,%eax
 7e8:	eb 13                	jmp    7fd <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f3:	8b 00                	mov    (%eax),%eax
 7f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7f8:	e9 70 ff ff ff       	jmp    76d <malloc+0x4e>
}
 7fd:	c9                   	leave  
 7fe:	c3                   	ret    
