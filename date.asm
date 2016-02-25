
_date:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "date.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 50             	sub    $0x50,%esp
    struct rtcdate r;

int pid = getpid();
   c:	e8 b9 03 00 00       	call   3ca <getpid>
  11:	89 44 24 4c          	mov    %eax,0x4c(%esp)
int gid = getgid();
  15:	e8 e8 03 00 00       	call   402 <getgid>
  1a:	89 44 24 48          	mov    %eax,0x48(%esp)
int uid = getuid();
  1e:	e8 d7 03 00 00       	call   3fa <getuid>
  23:	89 44 24 44          	mov    %eax,0x44(%esp)
int ppid = getppid();
  27:	e8 de 03 00 00       	call   40a <getppid>
  2c:	89 44 24 40          	mov    %eax,0x40(%esp)

	printf(2, "PID:%d  GID:%d  UID:%d PPID:%d ", pid,gid,uid,ppid);
  30:	8b 44 24 40          	mov    0x40(%esp),%eax
  34:	89 44 24 14          	mov    %eax,0x14(%esp)
  38:	8b 44 24 44          	mov    0x44(%esp),%eax
  3c:	89 44 24 10          	mov    %eax,0x10(%esp)
  40:	8b 44 24 48          	mov    0x48(%esp),%eax
  44:	89 44 24 0c          	mov    %eax,0xc(%esp)
  48:	8b 44 24 4c          	mov    0x4c(%esp),%eax
  4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  50:	c7 44 24 04 d8 08 00 	movl   $0x8d8,0x4(%esp)
  57:	00 
  58:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  5f:	e8 a6 04 00 00       	call   50a <printf>


    if (date(&r)) {
  64:	8d 44 24 28          	lea    0x28(%esp),%eax
  68:	89 04 24             	mov    %eax,(%esp)
  6b:	e8 7a 03 00 00       	call   3ea <date>
  70:	85 c0                	test   %eax,%eax
  72:	74 19                	je     8d <main+0x8d>
	printf(2, "date failed\n");
  74:	c7 44 24 04 f8 08 00 	movl   $0x8f8,0x4(%esp)
  7b:	00 
  7c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  83:	e8 82 04 00 00       	call   50a <printf>
	exit ();
  88:	e8 bd 02 00 00       	call   34a <exit>
    }


    // your code to print the time in any format your like
   date(&r);
  8d:	8d 44 24 28          	lea    0x28(%esp),%eax
  91:	89 04 24             	mov    %eax,(%esp)
  94:	e8 51 03 00 00       	call   3ea <date>
    printf(1,"UTC Time (h:m:s): %d:%d:%d : UTC Date (m/d/y): %d/%d/%d",r.hour, r.minute, r.second,r.month, r.day, r.year);
  99:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  9d:	8b 74 24 34          	mov    0x34(%esp),%esi
  a1:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  a5:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  a9:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  ad:	8b 44 24 30          	mov    0x30(%esp),%eax
  b1:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
  b5:	89 74 24 18          	mov    %esi,0x18(%esp)
  b9:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  bd:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  c9:	c7 44 24 04 08 09 00 	movl   $0x908,0x4(%esp)
  d0:	00 
  d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d8:	e8 2d 04 00 00       	call   50a <printf>





    exit();
  dd:	e8 68 02 00 00       	call   34a <exit>

000000e2 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  e2:	55                   	push   %ebp
  e3:	89 e5                	mov    %esp,%ebp
  e5:	57                   	push   %edi
  e6:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ea:	8b 55 10             	mov    0x10(%ebp),%edx
  ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  f0:	89 cb                	mov    %ecx,%ebx
  f2:	89 df                	mov    %ebx,%edi
  f4:	89 d1                	mov    %edx,%ecx
  f6:	fc                   	cld    
  f7:	f3 aa                	rep stos %al,%es:(%edi)
  f9:	89 ca                	mov    %ecx,%edx
  fb:	89 fb                	mov    %edi,%ebx
  fd:	89 5d 08             	mov    %ebx,0x8(%ebp)
 100:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 103:	5b                   	pop    %ebx
 104:	5f                   	pop    %edi
 105:	5d                   	pop    %ebp
 106:	c3                   	ret    

00000107 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 10d:	8b 45 08             	mov    0x8(%ebp),%eax
 110:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 113:	90                   	nop
 114:	8b 45 08             	mov    0x8(%ebp),%eax
 117:	8d 50 01             	lea    0x1(%eax),%edx
 11a:	89 55 08             	mov    %edx,0x8(%ebp)
 11d:	8b 55 0c             	mov    0xc(%ebp),%edx
 120:	8d 4a 01             	lea    0x1(%edx),%ecx
 123:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 126:	0f b6 12             	movzbl (%edx),%edx
 129:	88 10                	mov    %dl,(%eax)
 12b:	0f b6 00             	movzbl (%eax),%eax
 12e:	84 c0                	test   %al,%al
 130:	75 e2                	jne    114 <strcpy+0xd>
    ;
  return os;
 132:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 135:	c9                   	leave  
 136:	c3                   	ret    

00000137 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 137:	55                   	push   %ebp
 138:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 13a:	eb 08                	jmp    144 <strcmp+0xd>
    p++, q++;
 13c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 140:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 144:	8b 45 08             	mov    0x8(%ebp),%eax
 147:	0f b6 00             	movzbl (%eax),%eax
 14a:	84 c0                	test   %al,%al
 14c:	74 10                	je     15e <strcmp+0x27>
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
 151:	0f b6 10             	movzbl (%eax),%edx
 154:	8b 45 0c             	mov    0xc(%ebp),%eax
 157:	0f b6 00             	movzbl (%eax),%eax
 15a:	38 c2                	cmp    %al,%dl
 15c:	74 de                	je     13c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 15e:	8b 45 08             	mov    0x8(%ebp),%eax
 161:	0f b6 00             	movzbl (%eax),%eax
 164:	0f b6 d0             	movzbl %al,%edx
 167:	8b 45 0c             	mov    0xc(%ebp),%eax
 16a:	0f b6 00             	movzbl (%eax),%eax
 16d:	0f b6 c0             	movzbl %al,%eax
 170:	29 c2                	sub    %eax,%edx
 172:	89 d0                	mov    %edx,%eax
}
 174:	5d                   	pop    %ebp
 175:	c3                   	ret    

00000176 <strlen>:

uint
strlen(char *s)
{
 176:	55                   	push   %ebp
 177:	89 e5                	mov    %esp,%ebp
 179:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 17c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 183:	eb 04                	jmp    189 <strlen+0x13>
 185:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 189:	8b 55 fc             	mov    -0x4(%ebp),%edx
 18c:	8b 45 08             	mov    0x8(%ebp),%eax
 18f:	01 d0                	add    %edx,%eax
 191:	0f b6 00             	movzbl (%eax),%eax
 194:	84 c0                	test   %al,%al
 196:	75 ed                	jne    185 <strlen+0xf>
    ;
  return n;
 198:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 19b:	c9                   	leave  
 19c:	c3                   	ret    

0000019d <memset>:

void*
memset(void *dst, int c, uint n)
{
 19d:	55                   	push   %ebp
 19e:	89 e5                	mov    %esp,%ebp
 1a0:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1a3:	8b 45 10             	mov    0x10(%ebp),%eax
 1a6:	89 44 24 08          	mov    %eax,0x8(%esp)
 1aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ad:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b1:	8b 45 08             	mov    0x8(%ebp),%eax
 1b4:	89 04 24             	mov    %eax,(%esp)
 1b7:	e8 26 ff ff ff       	call   e2 <stosb>
  return dst;
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1bf:	c9                   	leave  
 1c0:	c3                   	ret    

000001c1 <strchr>:

char*
strchr(const char *s, char c)
{
 1c1:	55                   	push   %ebp
 1c2:	89 e5                	mov    %esp,%ebp
 1c4:	83 ec 04             	sub    $0x4,%esp
 1c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ca:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1cd:	eb 14                	jmp    1e3 <strchr+0x22>
    if(*s == c)
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	0f b6 00             	movzbl (%eax),%eax
 1d5:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1d8:	75 05                	jne    1df <strchr+0x1e>
      return (char*)s;
 1da:	8b 45 08             	mov    0x8(%ebp),%eax
 1dd:	eb 13                	jmp    1f2 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1df:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1e3:	8b 45 08             	mov    0x8(%ebp),%eax
 1e6:	0f b6 00             	movzbl (%eax),%eax
 1e9:	84 c0                	test   %al,%al
 1eb:	75 e2                	jne    1cf <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1f2:	c9                   	leave  
 1f3:	c3                   	ret    

000001f4 <gets>:

char*
gets(char *buf, int max)
{
 1f4:	55                   	push   %ebp
 1f5:	89 e5                	mov    %esp,%ebp
 1f7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 201:	eb 4c                	jmp    24f <gets+0x5b>
    cc = read(0, &c, 1);
 203:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 20a:	00 
 20b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 20e:	89 44 24 04          	mov    %eax,0x4(%esp)
 212:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 219:	e8 44 01 00 00       	call   362 <read>
 21e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 221:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 225:	7f 02                	jg     229 <gets+0x35>
      break;
 227:	eb 31                	jmp    25a <gets+0x66>
    buf[i++] = c;
 229:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22c:	8d 50 01             	lea    0x1(%eax),%edx
 22f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 232:	89 c2                	mov    %eax,%edx
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	01 c2                	add    %eax,%edx
 239:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 23d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 23f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 243:	3c 0a                	cmp    $0xa,%al
 245:	74 13                	je     25a <gets+0x66>
 247:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 24b:	3c 0d                	cmp    $0xd,%al
 24d:	74 0b                	je     25a <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 24f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 252:	83 c0 01             	add    $0x1,%eax
 255:	3b 45 0c             	cmp    0xc(%ebp),%eax
 258:	7c a9                	jl     203 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 25a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 25d:	8b 45 08             	mov    0x8(%ebp),%eax
 260:	01 d0                	add    %edx,%eax
 262:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 265:	8b 45 08             	mov    0x8(%ebp),%eax
}
 268:	c9                   	leave  
 269:	c3                   	ret    

0000026a <stat>:

int
stat(char *n, struct stat *st)
{
 26a:	55                   	push   %ebp
 26b:	89 e5                	mov    %esp,%ebp
 26d:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 270:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 277:	00 
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	89 04 24             	mov    %eax,(%esp)
 27e:	e8 07 01 00 00       	call   38a <open>
 283:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 286:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 28a:	79 07                	jns    293 <stat+0x29>
    return -1;
 28c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 291:	eb 23                	jmp    2b6 <stat+0x4c>
  r = fstat(fd, st);
 293:	8b 45 0c             	mov    0xc(%ebp),%eax
 296:	89 44 24 04          	mov    %eax,0x4(%esp)
 29a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29d:	89 04 24             	mov    %eax,(%esp)
 2a0:	e8 fd 00 00 00       	call   3a2 <fstat>
 2a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ab:	89 04 24             	mov    %eax,(%esp)
 2ae:	e8 bf 00 00 00       	call   372 <close>
  return r;
 2b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2b6:	c9                   	leave  
 2b7:	c3                   	ret    

000002b8 <atoi>:

int
atoi(const char *s)
{
 2b8:	55                   	push   %ebp
 2b9:	89 e5                	mov    %esp,%ebp
 2bb:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2c5:	eb 25                	jmp    2ec <atoi+0x34>
    n = n*10 + *s++ - '0';
 2c7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2ca:	89 d0                	mov    %edx,%eax
 2cc:	c1 e0 02             	shl    $0x2,%eax
 2cf:	01 d0                	add    %edx,%eax
 2d1:	01 c0                	add    %eax,%eax
 2d3:	89 c1                	mov    %eax,%ecx
 2d5:	8b 45 08             	mov    0x8(%ebp),%eax
 2d8:	8d 50 01             	lea    0x1(%eax),%edx
 2db:	89 55 08             	mov    %edx,0x8(%ebp)
 2de:	0f b6 00             	movzbl (%eax),%eax
 2e1:	0f be c0             	movsbl %al,%eax
 2e4:	01 c8                	add    %ecx,%eax
 2e6:	83 e8 30             	sub    $0x30,%eax
 2e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ec:	8b 45 08             	mov    0x8(%ebp),%eax
 2ef:	0f b6 00             	movzbl (%eax),%eax
 2f2:	3c 2f                	cmp    $0x2f,%al
 2f4:	7e 0a                	jle    300 <atoi+0x48>
 2f6:	8b 45 08             	mov    0x8(%ebp),%eax
 2f9:	0f b6 00             	movzbl (%eax),%eax
 2fc:	3c 39                	cmp    $0x39,%al
 2fe:	7e c7                	jle    2c7 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 300:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 303:	c9                   	leave  
 304:	c3                   	ret    

00000305 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 305:	55                   	push   %ebp
 306:	89 e5                	mov    %esp,%ebp
 308:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 30b:	8b 45 08             	mov    0x8(%ebp),%eax
 30e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 311:	8b 45 0c             	mov    0xc(%ebp),%eax
 314:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 317:	eb 17                	jmp    330 <memmove+0x2b>
    *dst++ = *src++;
 319:	8b 45 fc             	mov    -0x4(%ebp),%eax
 31c:	8d 50 01             	lea    0x1(%eax),%edx
 31f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 322:	8b 55 f8             	mov    -0x8(%ebp),%edx
 325:	8d 4a 01             	lea    0x1(%edx),%ecx
 328:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 32b:	0f b6 12             	movzbl (%edx),%edx
 32e:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 330:	8b 45 10             	mov    0x10(%ebp),%eax
 333:	8d 50 ff             	lea    -0x1(%eax),%edx
 336:	89 55 10             	mov    %edx,0x10(%ebp)
 339:	85 c0                	test   %eax,%eax
 33b:	7f dc                	jg     319 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 33d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 340:	c9                   	leave  
 341:	c3                   	ret    

00000342 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 342:	b8 01 00 00 00       	mov    $0x1,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <exit>:
SYSCALL(exit)
 34a:	b8 02 00 00 00       	mov    $0x2,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <wait>:
SYSCALL(wait)
 352:	b8 03 00 00 00       	mov    $0x3,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <pipe>:
SYSCALL(pipe)
 35a:	b8 04 00 00 00       	mov    $0x4,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <read>:
SYSCALL(read)
 362:	b8 05 00 00 00       	mov    $0x5,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <write>:
SYSCALL(write)
 36a:	b8 10 00 00 00       	mov    $0x10,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <close>:
SYSCALL(close)
 372:	b8 15 00 00 00       	mov    $0x15,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <kill>:
SYSCALL(kill)
 37a:	b8 06 00 00 00       	mov    $0x6,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <exec>:
SYSCALL(exec)
 382:	b8 07 00 00 00       	mov    $0x7,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <open>:
SYSCALL(open)
 38a:	b8 0f 00 00 00       	mov    $0xf,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <mknod>:
SYSCALL(mknod)
 392:	b8 11 00 00 00       	mov    $0x11,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <unlink>:
SYSCALL(unlink)
 39a:	b8 12 00 00 00       	mov    $0x12,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <fstat>:
SYSCALL(fstat)
 3a2:	b8 08 00 00 00       	mov    $0x8,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <link>:
SYSCALL(link)
 3aa:	b8 13 00 00 00       	mov    $0x13,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <mkdir>:
SYSCALL(mkdir)
 3b2:	b8 14 00 00 00       	mov    $0x14,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <chdir>:
SYSCALL(chdir)
 3ba:	b8 09 00 00 00       	mov    $0x9,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <dup>:
SYSCALL(dup)
 3c2:	b8 0a 00 00 00       	mov    $0xa,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <getpid>:
SYSCALL(getpid)
 3ca:	b8 0b 00 00 00       	mov    $0xb,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <sbrk>:
SYSCALL(sbrk)
 3d2:	b8 0c 00 00 00       	mov    $0xc,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <sleep>:
SYSCALL(sleep)
 3da:	b8 0d 00 00 00       	mov    $0xd,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <uptime>:
SYSCALL(uptime)
 3e2:	b8 0e 00 00 00       	mov    $0xe,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <date>:
SYSCALL(date)
 3ea:	b8 16 00 00 00       	mov    $0x16,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <timem>:
SYSCALL(timem)
 3f2:	b8 17 00 00 00       	mov    $0x17,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <getuid>:
SYSCALL(getuid)
 3fa:	b8 18 00 00 00       	mov    $0x18,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <getgid>:
SYSCALL(getgid)
 402:	b8 19 00 00 00       	mov    $0x19,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <getppid>:
SYSCALL(getppid)
 40a:	b8 1a 00 00 00       	mov    $0x1a,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <setuid>:
SYSCALL(setuid)
 412:	b8 1b 00 00 00       	mov    $0x1b,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <setgid>:
SYSCALL(setgid)
 41a:	b8 1c 00 00 00       	mov    $0x1c,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <getprocs>:
SYSCALL(getprocs)
 422:	b8 1d 00 00 00       	mov    $0x1d,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 42a:	55                   	push   %ebp
 42b:	89 e5                	mov    %esp,%ebp
 42d:	83 ec 18             	sub    $0x18,%esp
 430:	8b 45 0c             	mov    0xc(%ebp),%eax
 433:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 436:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 43d:	00 
 43e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 441:	89 44 24 04          	mov    %eax,0x4(%esp)
 445:	8b 45 08             	mov    0x8(%ebp),%eax
 448:	89 04 24             	mov    %eax,(%esp)
 44b:	e8 1a ff ff ff       	call   36a <write>
}
 450:	c9                   	leave  
 451:	c3                   	ret    

00000452 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 452:	55                   	push   %ebp
 453:	89 e5                	mov    %esp,%ebp
 455:	56                   	push   %esi
 456:	53                   	push   %ebx
 457:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 45a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 461:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 465:	74 17                	je     47e <printint+0x2c>
 467:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 46b:	79 11                	jns    47e <printint+0x2c>
    neg = 1;
 46d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 474:	8b 45 0c             	mov    0xc(%ebp),%eax
 477:	f7 d8                	neg    %eax
 479:	89 45 ec             	mov    %eax,-0x14(%ebp)
 47c:	eb 06                	jmp    484 <printint+0x32>
  } else {
    x = xx;
 47e:	8b 45 0c             	mov    0xc(%ebp),%eax
 481:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 484:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 48b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 48e:	8d 41 01             	lea    0x1(%ecx),%eax
 491:	89 45 f4             	mov    %eax,-0xc(%ebp)
 494:	8b 5d 10             	mov    0x10(%ebp),%ebx
 497:	8b 45 ec             	mov    -0x14(%ebp),%eax
 49a:	ba 00 00 00 00       	mov    $0x0,%edx
 49f:	f7 f3                	div    %ebx
 4a1:	89 d0                	mov    %edx,%eax
 4a3:	0f b6 80 90 0b 00 00 	movzbl 0xb90(%eax),%eax
 4aa:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4ae:	8b 75 10             	mov    0x10(%ebp),%esi
 4b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b4:	ba 00 00 00 00       	mov    $0x0,%edx
 4b9:	f7 f6                	div    %esi
 4bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4be:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c2:	75 c7                	jne    48b <printint+0x39>
  if(neg)
 4c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4c8:	74 10                	je     4da <printint+0x88>
    buf[i++] = '-';
 4ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4cd:	8d 50 01             	lea    0x1(%eax),%edx
 4d0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4d3:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4d8:	eb 1f                	jmp    4f9 <printint+0xa7>
 4da:	eb 1d                	jmp    4f9 <printint+0xa7>
    putc(fd, buf[i]);
 4dc:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e2:	01 d0                	add    %edx,%eax
 4e4:	0f b6 00             	movzbl (%eax),%eax
 4e7:	0f be c0             	movsbl %al,%eax
 4ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ee:	8b 45 08             	mov    0x8(%ebp),%eax
 4f1:	89 04 24             	mov    %eax,(%esp)
 4f4:	e8 31 ff ff ff       	call   42a <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4f9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 501:	79 d9                	jns    4dc <printint+0x8a>
    putc(fd, buf[i]);
}
 503:	83 c4 30             	add    $0x30,%esp
 506:	5b                   	pop    %ebx
 507:	5e                   	pop    %esi
 508:	5d                   	pop    %ebp
 509:	c3                   	ret    

0000050a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 50a:	55                   	push   %ebp
 50b:	89 e5                	mov    %esp,%ebp
 50d:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 510:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 517:	8d 45 0c             	lea    0xc(%ebp),%eax
 51a:	83 c0 04             	add    $0x4,%eax
 51d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 520:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 527:	e9 7c 01 00 00       	jmp    6a8 <printf+0x19e>
    c = fmt[i] & 0xff;
 52c:	8b 55 0c             	mov    0xc(%ebp),%edx
 52f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 532:	01 d0                	add    %edx,%eax
 534:	0f b6 00             	movzbl (%eax),%eax
 537:	0f be c0             	movsbl %al,%eax
 53a:	25 ff 00 00 00       	and    $0xff,%eax
 53f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 542:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 546:	75 2c                	jne    574 <printf+0x6a>
      if(c == '%'){
 548:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 54c:	75 0c                	jne    55a <printf+0x50>
        state = '%';
 54e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 555:	e9 4a 01 00 00       	jmp    6a4 <printf+0x19a>
      } else {
        putc(fd, c);
 55a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 55d:	0f be c0             	movsbl %al,%eax
 560:	89 44 24 04          	mov    %eax,0x4(%esp)
 564:	8b 45 08             	mov    0x8(%ebp),%eax
 567:	89 04 24             	mov    %eax,(%esp)
 56a:	e8 bb fe ff ff       	call   42a <putc>
 56f:	e9 30 01 00 00       	jmp    6a4 <printf+0x19a>
      }
    } else if(state == '%'){
 574:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 578:	0f 85 26 01 00 00    	jne    6a4 <printf+0x19a>
      if(c == 'd'){
 57e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 582:	75 2d                	jne    5b1 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 584:	8b 45 e8             	mov    -0x18(%ebp),%eax
 587:	8b 00                	mov    (%eax),%eax
 589:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 590:	00 
 591:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 598:	00 
 599:	89 44 24 04          	mov    %eax,0x4(%esp)
 59d:	8b 45 08             	mov    0x8(%ebp),%eax
 5a0:	89 04 24             	mov    %eax,(%esp)
 5a3:	e8 aa fe ff ff       	call   452 <printint>
        ap++;
 5a8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ac:	e9 ec 00 00 00       	jmp    69d <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5b1:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5b5:	74 06                	je     5bd <printf+0xb3>
 5b7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5bb:	75 2d                	jne    5ea <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c0:	8b 00                	mov    (%eax),%eax
 5c2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5c9:	00 
 5ca:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5d1:	00 
 5d2:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d6:	8b 45 08             	mov    0x8(%ebp),%eax
 5d9:	89 04 24             	mov    %eax,(%esp)
 5dc:	e8 71 fe ff ff       	call   452 <printint>
        ap++;
 5e1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e5:	e9 b3 00 00 00       	jmp    69d <printf+0x193>
      } else if(c == 's'){
 5ea:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5ee:	75 45                	jne    635 <printf+0x12b>
        s = (char*)*ap;
 5f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f3:	8b 00                	mov    (%eax),%eax
 5f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5f8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 600:	75 09                	jne    60b <printf+0x101>
          s = "(null)";
 602:	c7 45 f4 40 09 00 00 	movl   $0x940,-0xc(%ebp)
        while(*s != 0){
 609:	eb 1e                	jmp    629 <printf+0x11f>
 60b:	eb 1c                	jmp    629 <printf+0x11f>
          putc(fd, *s);
 60d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 610:	0f b6 00             	movzbl (%eax),%eax
 613:	0f be c0             	movsbl %al,%eax
 616:	89 44 24 04          	mov    %eax,0x4(%esp)
 61a:	8b 45 08             	mov    0x8(%ebp),%eax
 61d:	89 04 24             	mov    %eax,(%esp)
 620:	e8 05 fe ff ff       	call   42a <putc>
          s++;
 625:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 629:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62c:	0f b6 00             	movzbl (%eax),%eax
 62f:	84 c0                	test   %al,%al
 631:	75 da                	jne    60d <printf+0x103>
 633:	eb 68                	jmp    69d <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 635:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 639:	75 1d                	jne    658 <printf+0x14e>
        putc(fd, *ap);
 63b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 63e:	8b 00                	mov    (%eax),%eax
 640:	0f be c0             	movsbl %al,%eax
 643:	89 44 24 04          	mov    %eax,0x4(%esp)
 647:	8b 45 08             	mov    0x8(%ebp),%eax
 64a:	89 04 24             	mov    %eax,(%esp)
 64d:	e8 d8 fd ff ff       	call   42a <putc>
        ap++;
 652:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 656:	eb 45                	jmp    69d <printf+0x193>
      } else if(c == '%'){
 658:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 65c:	75 17                	jne    675 <printf+0x16b>
        putc(fd, c);
 65e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 661:	0f be c0             	movsbl %al,%eax
 664:	89 44 24 04          	mov    %eax,0x4(%esp)
 668:	8b 45 08             	mov    0x8(%ebp),%eax
 66b:	89 04 24             	mov    %eax,(%esp)
 66e:	e8 b7 fd ff ff       	call   42a <putc>
 673:	eb 28                	jmp    69d <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 675:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 67c:	00 
 67d:	8b 45 08             	mov    0x8(%ebp),%eax
 680:	89 04 24             	mov    %eax,(%esp)
 683:	e8 a2 fd ff ff       	call   42a <putc>
        putc(fd, c);
 688:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68b:	0f be c0             	movsbl %al,%eax
 68e:	89 44 24 04          	mov    %eax,0x4(%esp)
 692:	8b 45 08             	mov    0x8(%ebp),%eax
 695:	89 04 24             	mov    %eax,(%esp)
 698:	e8 8d fd ff ff       	call   42a <putc>
      }
      state = 0;
 69d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6a4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6a8:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ae:	01 d0                	add    %edx,%eax
 6b0:	0f b6 00             	movzbl (%eax),%eax
 6b3:	84 c0                	test   %al,%al
 6b5:	0f 85 71 fe ff ff    	jne    52c <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6bb:	c9                   	leave  
 6bc:	c3                   	ret    

000006bd <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6bd:	55                   	push   %ebp
 6be:	89 e5                	mov    %esp,%ebp
 6c0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c3:	8b 45 08             	mov    0x8(%ebp),%eax
 6c6:	83 e8 08             	sub    $0x8,%eax
 6c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6cc:	a1 ac 0b 00 00       	mov    0xbac,%eax
 6d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6d4:	eb 24                	jmp    6fa <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d9:	8b 00                	mov    (%eax),%eax
 6db:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6de:	77 12                	ja     6f2 <free+0x35>
 6e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e6:	77 24                	ja     70c <free+0x4f>
 6e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6eb:	8b 00                	mov    (%eax),%eax
 6ed:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f0:	77 1a                	ja     70c <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f5:	8b 00                	mov    (%eax),%eax
 6f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 700:	76 d4                	jbe    6d6 <free+0x19>
 702:	8b 45 fc             	mov    -0x4(%ebp),%eax
 705:	8b 00                	mov    (%eax),%eax
 707:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 70a:	76 ca                	jbe    6d6 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 70c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70f:	8b 40 04             	mov    0x4(%eax),%eax
 712:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 719:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71c:	01 c2                	add    %eax,%edx
 71e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 721:	8b 00                	mov    (%eax),%eax
 723:	39 c2                	cmp    %eax,%edx
 725:	75 24                	jne    74b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 727:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72a:	8b 50 04             	mov    0x4(%eax),%edx
 72d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 730:	8b 00                	mov    (%eax),%eax
 732:	8b 40 04             	mov    0x4(%eax),%eax
 735:	01 c2                	add    %eax,%edx
 737:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 73d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 740:	8b 00                	mov    (%eax),%eax
 742:	8b 10                	mov    (%eax),%edx
 744:	8b 45 f8             	mov    -0x8(%ebp),%eax
 747:	89 10                	mov    %edx,(%eax)
 749:	eb 0a                	jmp    755 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 74b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74e:	8b 10                	mov    (%eax),%edx
 750:	8b 45 f8             	mov    -0x8(%ebp),%eax
 753:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 755:	8b 45 fc             	mov    -0x4(%ebp),%eax
 758:	8b 40 04             	mov    0x4(%eax),%eax
 75b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 762:	8b 45 fc             	mov    -0x4(%ebp),%eax
 765:	01 d0                	add    %edx,%eax
 767:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 76a:	75 20                	jne    78c <free+0xcf>
    p->s.size += bp->s.size;
 76c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76f:	8b 50 04             	mov    0x4(%eax),%edx
 772:	8b 45 f8             	mov    -0x8(%ebp),%eax
 775:	8b 40 04             	mov    0x4(%eax),%eax
 778:	01 c2                	add    %eax,%edx
 77a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 780:	8b 45 f8             	mov    -0x8(%ebp),%eax
 783:	8b 10                	mov    (%eax),%edx
 785:	8b 45 fc             	mov    -0x4(%ebp),%eax
 788:	89 10                	mov    %edx,(%eax)
 78a:	eb 08                	jmp    794 <free+0xd7>
  } else
    p->s.ptr = bp;
 78c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 792:	89 10                	mov    %edx,(%eax)
  freep = p;
 794:	8b 45 fc             	mov    -0x4(%ebp),%eax
 797:	a3 ac 0b 00 00       	mov    %eax,0xbac
}
 79c:	c9                   	leave  
 79d:	c3                   	ret    

0000079e <morecore>:

static Header*
morecore(uint nu)
{
 79e:	55                   	push   %ebp
 79f:	89 e5                	mov    %esp,%ebp
 7a1:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7a4:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7ab:	77 07                	ja     7b4 <morecore+0x16>
    nu = 4096;
 7ad:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7b4:	8b 45 08             	mov    0x8(%ebp),%eax
 7b7:	c1 e0 03             	shl    $0x3,%eax
 7ba:	89 04 24             	mov    %eax,(%esp)
 7bd:	e8 10 fc ff ff       	call   3d2 <sbrk>
 7c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7c5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7c9:	75 07                	jne    7d2 <morecore+0x34>
    return 0;
 7cb:	b8 00 00 00 00       	mov    $0x0,%eax
 7d0:	eb 22                	jmp    7f4 <morecore+0x56>
  hp = (Header*)p;
 7d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7db:	8b 55 08             	mov    0x8(%ebp),%edx
 7de:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e4:	83 c0 08             	add    $0x8,%eax
 7e7:	89 04 24             	mov    %eax,(%esp)
 7ea:	e8 ce fe ff ff       	call   6bd <free>
  return freep;
 7ef:	a1 ac 0b 00 00       	mov    0xbac,%eax
}
 7f4:	c9                   	leave  
 7f5:	c3                   	ret    

000007f6 <malloc>:

void*
malloc(uint nbytes)
{
 7f6:	55                   	push   %ebp
 7f7:	89 e5                	mov    %esp,%ebp
 7f9:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fc:	8b 45 08             	mov    0x8(%ebp),%eax
 7ff:	83 c0 07             	add    $0x7,%eax
 802:	c1 e8 03             	shr    $0x3,%eax
 805:	83 c0 01             	add    $0x1,%eax
 808:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 80b:	a1 ac 0b 00 00       	mov    0xbac,%eax
 810:	89 45 f0             	mov    %eax,-0x10(%ebp)
 813:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 817:	75 23                	jne    83c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 819:	c7 45 f0 a4 0b 00 00 	movl   $0xba4,-0x10(%ebp)
 820:	8b 45 f0             	mov    -0x10(%ebp),%eax
 823:	a3 ac 0b 00 00       	mov    %eax,0xbac
 828:	a1 ac 0b 00 00       	mov    0xbac,%eax
 82d:	a3 a4 0b 00 00       	mov    %eax,0xba4
    base.s.size = 0;
 832:	c7 05 a8 0b 00 00 00 	movl   $0x0,0xba8
 839:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83f:	8b 00                	mov    (%eax),%eax
 841:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 844:	8b 45 f4             	mov    -0xc(%ebp),%eax
 847:	8b 40 04             	mov    0x4(%eax),%eax
 84a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 84d:	72 4d                	jb     89c <malloc+0xa6>
      if(p->s.size == nunits)
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	8b 40 04             	mov    0x4(%eax),%eax
 855:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 858:	75 0c                	jne    866 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 85a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85d:	8b 10                	mov    (%eax),%edx
 85f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 862:	89 10                	mov    %edx,(%eax)
 864:	eb 26                	jmp    88c <malloc+0x96>
      else {
        p->s.size -= nunits;
 866:	8b 45 f4             	mov    -0xc(%ebp),%eax
 869:	8b 40 04             	mov    0x4(%eax),%eax
 86c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 86f:	89 c2                	mov    %eax,%edx
 871:	8b 45 f4             	mov    -0xc(%ebp),%eax
 874:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 877:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87a:	8b 40 04             	mov    0x4(%eax),%eax
 87d:	c1 e0 03             	shl    $0x3,%eax
 880:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 883:	8b 45 f4             	mov    -0xc(%ebp),%eax
 886:	8b 55 ec             	mov    -0x14(%ebp),%edx
 889:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 88c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88f:	a3 ac 0b 00 00       	mov    %eax,0xbac
      return (void*)(p + 1);
 894:	8b 45 f4             	mov    -0xc(%ebp),%eax
 897:	83 c0 08             	add    $0x8,%eax
 89a:	eb 38                	jmp    8d4 <malloc+0xde>
    }
    if(p == freep)
 89c:	a1 ac 0b 00 00       	mov    0xbac,%eax
 8a1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8a4:	75 1b                	jne    8c1 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a9:	89 04 24             	mov    %eax,(%esp)
 8ac:	e8 ed fe ff ff       	call   79e <morecore>
 8b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8b8:	75 07                	jne    8c1 <malloc+0xcb>
        return 0;
 8ba:	b8 00 00 00 00       	mov    $0x0,%eax
 8bf:	eb 13                	jmp    8d4 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ca:	8b 00                	mov    (%eax),%eax
 8cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8cf:	e9 70 ff ff ff       	jmp    844 <malloc+0x4e>
}
 8d4:	c9                   	leave  
 8d5:	c3                   	ret    
