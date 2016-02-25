
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <printTableEntry>:

#define MAX 10

void
printTableEntry(struct uproc* t)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 ec 3c             	sub    $0x3c,%esp
  printf(2, "pid: %d, name: %s\n      uid: %d  gid: %d   ppid: %d  state: %s  size: %d\n",
   9:	8b 45 08             	mov    0x8(%ebp),%eax
   c:	8b 70 20             	mov    0x20(%eax),%esi
        t->pid, t->name, t->uid, t->gid, t->ppid,
        t->state, t->size);
   f:	8b 45 08             	mov    0x8(%ebp),%eax
  12:	83 c0 10             	add    $0x10,%eax
  15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#define MAX 10

void
printTableEntry(struct uproc* t)
{
  printf(2, "pid: %d, name: %s\n      uid: %d  gid: %d   ppid: %d  state: %s  size: %d\n",
  18:	8b 45 08             	mov    0x8(%ebp),%eax
  1b:	8b 58 0c             	mov    0xc(%eax),%ebx
  1e:	8b 45 08             	mov    0x8(%ebp),%eax
  21:	8b 48 08             	mov    0x8(%eax),%ecx
  24:	8b 45 08             	mov    0x8(%ebp),%eax
  27:	8b 50 04             	mov    0x4(%eax),%edx
        t->pid, t->name, t->uid, t->gid, t->ppid,
  2a:	8b 45 08             	mov    0x8(%ebp),%eax
  2d:	8d 78 24             	lea    0x24(%eax),%edi
#define MAX 10

void
printTableEntry(struct uproc* t)
{
  printf(2, "pid: %d, name: %s\n      uid: %d  gid: %d   ppid: %d  state: %s  size: %d\n",
  30:	8b 45 08             	mov    0x8(%ebp),%eax
  33:	8b 00                	mov    (%eax),%eax
  35:	89 74 24 20          	mov    %esi,0x20(%esp)
  39:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  3c:	89 74 24 1c          	mov    %esi,0x1c(%esp)
  40:	89 5c 24 18          	mov    %ebx,0x18(%esp)
  44:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  48:	89 54 24 10          	mov    %edx,0x10(%esp)
  4c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  50:	89 44 24 08          	mov    %eax,0x8(%esp)
  54:	c7 44 24 04 04 09 00 	movl   $0x904,0x4(%esp)
  5b:	00 
  5c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  63:	e8 cd 04 00 00       	call   535 <printf>
        t->pid, t->name, t->uid, t->gid, t->ppid,
        t->state, t->size);
  return;
  68:	90                   	nop
}
  69:	83 c4 3c             	add    $0x3c,%esp
  6c:	5b                   	pop    %ebx
  6d:	5e                   	pop    %esi
  6e:	5f                   	pop    %edi
  6f:	5d                   	pop    %ebp
  70:	c3                   	ret    

00000071 <main>:

int
main(int argc, char* argv[]) {
  71:	55                   	push   %ebp
  72:	89 e5                	mov    %esp,%ebp
  74:	83 e4 f0             	and    $0xfffffff0,%esp
  77:	81 ec 20 02 00 00    	sub    $0x220,%esp
  int i, rc;
  struct uproc table[MAX];

  rc = getprocs(MAX, table);
  7d:	8d 44 24 10          	lea    0x10(%esp),%eax
  81:	89 44 24 04          	mov    %eax,0x4(%esp)
  85:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8c:	e8 bc 03 00 00       	call   44d <getprocs>
  91:	89 84 24 18 02 00 00 	mov    %eax,0x218(%esp)

  if (rc < 0) {
  98:	83 bc 24 18 02 00 00 	cmpl   $0x0,0x218(%esp)
  9f:	00 
  a0:	79 29                	jns    cb <main+0x5a>
    printf(2, "Error: getprocs call failed. %s at line %d\n", __FILE__, __LINE__);
  a2:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  a9:	00 
  aa:	c7 44 24 08 4e 09 00 	movl   $0x94e,0x8(%esp)
  b1:	00 
  b2:	c7 44 24 04 54 09 00 	movl   $0x954,0x4(%esp)
  b9:	00 
  ba:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  c1:	e8 6f 04 00 00       	call   535 <printf>
    exit();
  c6:	e8 aa 02 00 00       	call   375 <exit>
  }

  for (i=0; i<rc; i++) {
  cb:	c7 84 24 1c 02 00 00 	movl   $0x0,0x21c(%esp)
  d2:	00 00 00 00 
  d6:	eb 20                	jmp    f8 <main+0x87>
    printTableEntry(&table[i]);
  d8:	8d 54 24 10          	lea    0x10(%esp),%edx
  dc:	8b 84 24 1c 02 00 00 	mov    0x21c(%esp),%eax
  e3:	6b c0 34             	imul   $0x34,%eax,%eax
  e6:	01 d0                	add    %edx,%eax
  e8:	89 04 24             	mov    %eax,(%esp)
  eb:	e8 10 ff ff ff       	call   0 <printTableEntry>
  if (rc < 0) {
    printf(2, "Error: getprocs call failed. %s at line %d\n", __FILE__, __LINE__);
    exit();
  }

  for (i=0; i<rc; i++) {
  f0:	83 84 24 1c 02 00 00 	addl   $0x1,0x21c(%esp)
  f7:	01 
  f8:	8b 84 24 1c 02 00 00 	mov    0x21c(%esp),%eax
  ff:	3b 84 24 18 02 00 00 	cmp    0x218(%esp),%eax
 106:	7c d0                	jl     d8 <main+0x67>





  exit();
 108:	e8 68 02 00 00       	call   375 <exit>

0000010d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 10d:	55                   	push   %ebp
 10e:	89 e5                	mov    %esp,%ebp
 110:	57                   	push   %edi
 111:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 112:	8b 4d 08             	mov    0x8(%ebp),%ecx
 115:	8b 55 10             	mov    0x10(%ebp),%edx
 118:	8b 45 0c             	mov    0xc(%ebp),%eax
 11b:	89 cb                	mov    %ecx,%ebx
 11d:	89 df                	mov    %ebx,%edi
 11f:	89 d1                	mov    %edx,%ecx
 121:	fc                   	cld    
 122:	f3 aa                	rep stos %al,%es:(%edi)
 124:	89 ca                	mov    %ecx,%edx
 126:	89 fb                	mov    %edi,%ebx
 128:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 12e:	5b                   	pop    %ebx
 12f:	5f                   	pop    %edi
 130:	5d                   	pop    %ebp
 131:	c3                   	ret    

00000132 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 132:	55                   	push   %ebp
 133:	89 e5                	mov    %esp,%ebp
 135:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 138:	8b 45 08             	mov    0x8(%ebp),%eax
 13b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 13e:	90                   	nop
 13f:	8b 45 08             	mov    0x8(%ebp),%eax
 142:	8d 50 01             	lea    0x1(%eax),%edx
 145:	89 55 08             	mov    %edx,0x8(%ebp)
 148:	8b 55 0c             	mov    0xc(%ebp),%edx
 14b:	8d 4a 01             	lea    0x1(%edx),%ecx
 14e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 151:	0f b6 12             	movzbl (%edx),%edx
 154:	88 10                	mov    %dl,(%eax)
 156:	0f b6 00             	movzbl (%eax),%eax
 159:	84 c0                	test   %al,%al
 15b:	75 e2                	jne    13f <strcpy+0xd>
    ;
  return os;
 15d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 160:	c9                   	leave  
 161:	c3                   	ret    

00000162 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 162:	55                   	push   %ebp
 163:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 165:	eb 08                	jmp    16f <strcmp+0xd>
    p++, q++;
 167:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 16f:	8b 45 08             	mov    0x8(%ebp),%eax
 172:	0f b6 00             	movzbl (%eax),%eax
 175:	84 c0                	test   %al,%al
 177:	74 10                	je     189 <strcmp+0x27>
 179:	8b 45 08             	mov    0x8(%ebp),%eax
 17c:	0f b6 10             	movzbl (%eax),%edx
 17f:	8b 45 0c             	mov    0xc(%ebp),%eax
 182:	0f b6 00             	movzbl (%eax),%eax
 185:	38 c2                	cmp    %al,%dl
 187:	74 de                	je     167 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	0f b6 00             	movzbl (%eax),%eax
 18f:	0f b6 d0             	movzbl %al,%edx
 192:	8b 45 0c             	mov    0xc(%ebp),%eax
 195:	0f b6 00             	movzbl (%eax),%eax
 198:	0f b6 c0             	movzbl %al,%eax
 19b:	29 c2                	sub    %eax,%edx
 19d:	89 d0                	mov    %edx,%eax
}
 19f:	5d                   	pop    %ebp
 1a0:	c3                   	ret    

000001a1 <strlen>:

uint
strlen(char *s)
{
 1a1:	55                   	push   %ebp
 1a2:	89 e5                	mov    %esp,%ebp
 1a4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1a7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1ae:	eb 04                	jmp    1b4 <strlen+0x13>
 1b0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ba:	01 d0                	add    %edx,%eax
 1bc:	0f b6 00             	movzbl (%eax),%eax
 1bf:	84 c0                	test   %al,%al
 1c1:	75 ed                	jne    1b0 <strlen+0xf>
    ;
  return n;
 1c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c6:	c9                   	leave  
 1c7:	c3                   	ret    

000001c8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c8:	55                   	push   %ebp
 1c9:	89 e5                	mov    %esp,%ebp
 1cb:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1ce:	8b 45 10             	mov    0x10(%ebp),%eax
 1d1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
 1df:	89 04 24             	mov    %eax,(%esp)
 1e2:	e8 26 ff ff ff       	call   10d <stosb>
  return dst;
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ea:	c9                   	leave  
 1eb:	c3                   	ret    

000001ec <strchr>:

char*
strchr(const char *s, char c)
{
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	83 ec 04             	sub    $0x4,%esp
 1f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f5:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f8:	eb 14                	jmp    20e <strchr+0x22>
    if(*s == c)
 1fa:	8b 45 08             	mov    0x8(%ebp),%eax
 1fd:	0f b6 00             	movzbl (%eax),%eax
 200:	3a 45 fc             	cmp    -0x4(%ebp),%al
 203:	75 05                	jne    20a <strchr+0x1e>
      return (char*)s;
 205:	8b 45 08             	mov    0x8(%ebp),%eax
 208:	eb 13                	jmp    21d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 20a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 20e:	8b 45 08             	mov    0x8(%ebp),%eax
 211:	0f b6 00             	movzbl (%eax),%eax
 214:	84 c0                	test   %al,%al
 216:	75 e2                	jne    1fa <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 218:	b8 00 00 00 00       	mov    $0x0,%eax
}
 21d:	c9                   	leave  
 21e:	c3                   	ret    

0000021f <gets>:

char*
gets(char *buf, int max)
{
 21f:	55                   	push   %ebp
 220:	89 e5                	mov    %esp,%ebp
 222:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 225:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 22c:	eb 4c                	jmp    27a <gets+0x5b>
    cc = read(0, &c, 1);
 22e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 235:	00 
 236:	8d 45 ef             	lea    -0x11(%ebp),%eax
 239:	89 44 24 04          	mov    %eax,0x4(%esp)
 23d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 244:	e8 44 01 00 00       	call   38d <read>
 249:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 24c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 250:	7f 02                	jg     254 <gets+0x35>
      break;
 252:	eb 31                	jmp    285 <gets+0x66>
    buf[i++] = c;
 254:	8b 45 f4             	mov    -0xc(%ebp),%eax
 257:	8d 50 01             	lea    0x1(%eax),%edx
 25a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 25d:	89 c2                	mov    %eax,%edx
 25f:	8b 45 08             	mov    0x8(%ebp),%eax
 262:	01 c2                	add    %eax,%edx
 264:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 268:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 26a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26e:	3c 0a                	cmp    $0xa,%al
 270:	74 13                	je     285 <gets+0x66>
 272:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 276:	3c 0d                	cmp    $0xd,%al
 278:	74 0b                	je     285 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27d:	83 c0 01             	add    $0x1,%eax
 280:	3b 45 0c             	cmp    0xc(%ebp),%eax
 283:	7c a9                	jl     22e <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 285:	8b 55 f4             	mov    -0xc(%ebp),%edx
 288:	8b 45 08             	mov    0x8(%ebp),%eax
 28b:	01 d0                	add    %edx,%eax
 28d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 290:	8b 45 08             	mov    0x8(%ebp),%eax
}
 293:	c9                   	leave  
 294:	c3                   	ret    

00000295 <stat>:

int
stat(char *n, struct stat *st)
{
 295:	55                   	push   %ebp
 296:	89 e5                	mov    %esp,%ebp
 298:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2a2:	00 
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
 2a6:	89 04 24             	mov    %eax,(%esp)
 2a9:	e8 07 01 00 00       	call   3b5 <open>
 2ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b5:	79 07                	jns    2be <stat+0x29>
    return -1;
 2b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2bc:	eb 23                	jmp    2e1 <stat+0x4c>
  r = fstat(fd, st);
 2be:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c8:	89 04 24             	mov    %eax,(%esp)
 2cb:	e8 fd 00 00 00       	call   3cd <fstat>
 2d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d6:	89 04 24             	mov    %eax,(%esp)
 2d9:	e8 bf 00 00 00       	call   39d <close>
  return r;
 2de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e1:	c9                   	leave  
 2e2:	c3                   	ret    

000002e3 <atoi>:

int
atoi(const char *s)
{
 2e3:	55                   	push   %ebp
 2e4:	89 e5                	mov    %esp,%ebp
 2e6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f0:	eb 25                	jmp    317 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f5:	89 d0                	mov    %edx,%eax
 2f7:	c1 e0 02             	shl    $0x2,%eax
 2fa:	01 d0                	add    %edx,%eax
 2fc:	01 c0                	add    %eax,%eax
 2fe:	89 c1                	mov    %eax,%ecx
 300:	8b 45 08             	mov    0x8(%ebp),%eax
 303:	8d 50 01             	lea    0x1(%eax),%edx
 306:	89 55 08             	mov    %edx,0x8(%ebp)
 309:	0f b6 00             	movzbl (%eax),%eax
 30c:	0f be c0             	movsbl %al,%eax
 30f:	01 c8                	add    %ecx,%eax
 311:	83 e8 30             	sub    $0x30,%eax
 314:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 317:	8b 45 08             	mov    0x8(%ebp),%eax
 31a:	0f b6 00             	movzbl (%eax),%eax
 31d:	3c 2f                	cmp    $0x2f,%al
 31f:	7e 0a                	jle    32b <atoi+0x48>
 321:	8b 45 08             	mov    0x8(%ebp),%eax
 324:	0f b6 00             	movzbl (%eax),%eax
 327:	3c 39                	cmp    $0x39,%al
 329:	7e c7                	jle    2f2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 32b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 32e:	c9                   	leave  
 32f:	c3                   	ret    

00000330 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 330:	55                   	push   %ebp
 331:	89 e5                	mov    %esp,%ebp
 333:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 336:	8b 45 08             	mov    0x8(%ebp),%eax
 339:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33c:	8b 45 0c             	mov    0xc(%ebp),%eax
 33f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 342:	eb 17                	jmp    35b <memmove+0x2b>
    *dst++ = *src++;
 344:	8b 45 fc             	mov    -0x4(%ebp),%eax
 347:	8d 50 01             	lea    0x1(%eax),%edx
 34a:	89 55 fc             	mov    %edx,-0x4(%ebp)
 34d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 350:	8d 4a 01             	lea    0x1(%edx),%ecx
 353:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 356:	0f b6 12             	movzbl (%edx),%edx
 359:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35b:	8b 45 10             	mov    0x10(%ebp),%eax
 35e:	8d 50 ff             	lea    -0x1(%eax),%edx
 361:	89 55 10             	mov    %edx,0x10(%ebp)
 364:	85 c0                	test   %eax,%eax
 366:	7f dc                	jg     344 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 368:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36b:	c9                   	leave  
 36c:	c3                   	ret    

0000036d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 36d:	b8 01 00 00 00       	mov    $0x1,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <exit>:
SYSCALL(exit)
 375:	b8 02 00 00 00       	mov    $0x2,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <wait>:
SYSCALL(wait)
 37d:	b8 03 00 00 00       	mov    $0x3,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <pipe>:
SYSCALL(pipe)
 385:	b8 04 00 00 00       	mov    $0x4,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <read>:
SYSCALL(read)
 38d:	b8 05 00 00 00       	mov    $0x5,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <write>:
SYSCALL(write)
 395:	b8 10 00 00 00       	mov    $0x10,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <close>:
SYSCALL(close)
 39d:	b8 15 00 00 00       	mov    $0x15,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <kill>:
SYSCALL(kill)
 3a5:	b8 06 00 00 00       	mov    $0x6,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <exec>:
SYSCALL(exec)
 3ad:	b8 07 00 00 00       	mov    $0x7,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <open>:
SYSCALL(open)
 3b5:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <mknod>:
SYSCALL(mknod)
 3bd:	b8 11 00 00 00       	mov    $0x11,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <unlink>:
SYSCALL(unlink)
 3c5:	b8 12 00 00 00       	mov    $0x12,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <fstat>:
SYSCALL(fstat)
 3cd:	b8 08 00 00 00       	mov    $0x8,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <link>:
SYSCALL(link)
 3d5:	b8 13 00 00 00       	mov    $0x13,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <mkdir>:
SYSCALL(mkdir)
 3dd:	b8 14 00 00 00       	mov    $0x14,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <chdir>:
SYSCALL(chdir)
 3e5:	b8 09 00 00 00       	mov    $0x9,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <dup>:
SYSCALL(dup)
 3ed:	b8 0a 00 00 00       	mov    $0xa,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <getpid>:
SYSCALL(getpid)
 3f5:	b8 0b 00 00 00       	mov    $0xb,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <sbrk>:
SYSCALL(sbrk)
 3fd:	b8 0c 00 00 00       	mov    $0xc,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <sleep>:
SYSCALL(sleep)
 405:	b8 0d 00 00 00       	mov    $0xd,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <uptime>:
SYSCALL(uptime)
 40d:	b8 0e 00 00 00       	mov    $0xe,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <date>:
SYSCALL(date)
 415:	b8 16 00 00 00       	mov    $0x16,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <timem>:
SYSCALL(timem)
 41d:	b8 17 00 00 00       	mov    $0x17,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <getuid>:
SYSCALL(getuid)
 425:	b8 18 00 00 00       	mov    $0x18,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <getgid>:
SYSCALL(getgid)
 42d:	b8 19 00 00 00       	mov    $0x19,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <getppid>:
SYSCALL(getppid)
 435:	b8 1a 00 00 00       	mov    $0x1a,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <setuid>:
SYSCALL(setuid)
 43d:	b8 1b 00 00 00       	mov    $0x1b,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <setgid>:
SYSCALL(setgid)
 445:	b8 1c 00 00 00       	mov    $0x1c,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <getprocs>:
SYSCALL(getprocs)
 44d:	b8 1d 00 00 00       	mov    $0x1d,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 455:	55                   	push   %ebp
 456:	89 e5                	mov    %esp,%ebp
 458:	83 ec 18             	sub    $0x18,%esp
 45b:	8b 45 0c             	mov    0xc(%ebp),%eax
 45e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 461:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 468:	00 
 469:	8d 45 f4             	lea    -0xc(%ebp),%eax
 46c:	89 44 24 04          	mov    %eax,0x4(%esp)
 470:	8b 45 08             	mov    0x8(%ebp),%eax
 473:	89 04 24             	mov    %eax,(%esp)
 476:	e8 1a ff ff ff       	call   395 <write>
}
 47b:	c9                   	leave  
 47c:	c3                   	ret    

0000047d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47d:	55                   	push   %ebp
 47e:	89 e5                	mov    %esp,%ebp
 480:	56                   	push   %esi
 481:	53                   	push   %ebx
 482:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 485:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 48c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 490:	74 17                	je     4a9 <printint+0x2c>
 492:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 496:	79 11                	jns    4a9 <printint+0x2c>
    neg = 1;
 498:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 49f:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a2:	f7 d8                	neg    %eax
 4a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a7:	eb 06                	jmp    4af <printint+0x32>
  } else {
    x = xx;
 4a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4b9:	8d 41 01             	lea    0x1(%ecx),%eax
 4bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c5:	ba 00 00 00 00       	mov    $0x0,%edx
 4ca:	f7 f3                	div    %ebx
 4cc:	89 d0                	mov    %edx,%eax
 4ce:	0f b6 80 f8 0b 00 00 	movzbl 0xbf8(%eax),%eax
 4d5:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4d9:	8b 75 10             	mov    0x10(%ebp),%esi
 4dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4df:	ba 00 00 00 00       	mov    $0x0,%edx
 4e4:	f7 f6                	div    %esi
 4e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ed:	75 c7                	jne    4b6 <printint+0x39>
  if(neg)
 4ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f3:	74 10                	je     505 <printint+0x88>
    buf[i++] = '-';
 4f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f8:	8d 50 01             	lea    0x1(%eax),%edx
 4fb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4fe:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 503:	eb 1f                	jmp    524 <printint+0xa7>
 505:	eb 1d                	jmp    524 <printint+0xa7>
    putc(fd, buf[i]);
 507:	8d 55 dc             	lea    -0x24(%ebp),%edx
 50a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50d:	01 d0                	add    %edx,%eax
 50f:	0f b6 00             	movzbl (%eax),%eax
 512:	0f be c0             	movsbl %al,%eax
 515:	89 44 24 04          	mov    %eax,0x4(%esp)
 519:	8b 45 08             	mov    0x8(%ebp),%eax
 51c:	89 04 24             	mov    %eax,(%esp)
 51f:	e8 31 ff ff ff       	call   455 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 524:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 528:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 52c:	79 d9                	jns    507 <printint+0x8a>
    putc(fd, buf[i]);
}
 52e:	83 c4 30             	add    $0x30,%esp
 531:	5b                   	pop    %ebx
 532:	5e                   	pop    %esi
 533:	5d                   	pop    %ebp
 534:	c3                   	ret    

00000535 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 535:	55                   	push   %ebp
 536:	89 e5                	mov    %esp,%ebp
 538:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 53b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 542:	8d 45 0c             	lea    0xc(%ebp),%eax
 545:	83 c0 04             	add    $0x4,%eax
 548:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 54b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 552:	e9 7c 01 00 00       	jmp    6d3 <printf+0x19e>
    c = fmt[i] & 0xff;
 557:	8b 55 0c             	mov    0xc(%ebp),%edx
 55a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 55d:	01 d0                	add    %edx,%eax
 55f:	0f b6 00             	movzbl (%eax),%eax
 562:	0f be c0             	movsbl %al,%eax
 565:	25 ff 00 00 00       	and    $0xff,%eax
 56a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 56d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 571:	75 2c                	jne    59f <printf+0x6a>
      if(c == '%'){
 573:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 577:	75 0c                	jne    585 <printf+0x50>
        state = '%';
 579:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 580:	e9 4a 01 00 00       	jmp    6cf <printf+0x19a>
      } else {
        putc(fd, c);
 585:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 588:	0f be c0             	movsbl %al,%eax
 58b:	89 44 24 04          	mov    %eax,0x4(%esp)
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
 592:	89 04 24             	mov    %eax,(%esp)
 595:	e8 bb fe ff ff       	call   455 <putc>
 59a:	e9 30 01 00 00       	jmp    6cf <printf+0x19a>
      }
    } else if(state == '%'){
 59f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5a3:	0f 85 26 01 00 00    	jne    6cf <printf+0x19a>
      if(c == 'd'){
 5a9:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5ad:	75 2d                	jne    5dc <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5af:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b2:	8b 00                	mov    (%eax),%eax
 5b4:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5bb:	00 
 5bc:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5c3:	00 
 5c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c8:	8b 45 08             	mov    0x8(%ebp),%eax
 5cb:	89 04 24             	mov    %eax,(%esp)
 5ce:	e8 aa fe ff ff       	call   47d <printint>
        ap++;
 5d3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d7:	e9 ec 00 00 00       	jmp    6c8 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5dc:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5e0:	74 06                	je     5e8 <printf+0xb3>
 5e2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5e6:	75 2d                	jne    615 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5eb:	8b 00                	mov    (%eax),%eax
 5ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5f4:	00 
 5f5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5fc:	00 
 5fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 601:	8b 45 08             	mov    0x8(%ebp),%eax
 604:	89 04 24             	mov    %eax,(%esp)
 607:	e8 71 fe ff ff       	call   47d <printint>
        ap++;
 60c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 610:	e9 b3 00 00 00       	jmp    6c8 <printf+0x193>
      } else if(c == 's'){
 615:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 619:	75 45                	jne    660 <printf+0x12b>
        s = (char*)*ap;
 61b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 61e:	8b 00                	mov    (%eax),%eax
 620:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 623:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 627:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 62b:	75 09                	jne    636 <printf+0x101>
          s = "(null)";
 62d:	c7 45 f4 80 09 00 00 	movl   $0x980,-0xc(%ebp)
        while(*s != 0){
 634:	eb 1e                	jmp    654 <printf+0x11f>
 636:	eb 1c                	jmp    654 <printf+0x11f>
          putc(fd, *s);
 638:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63b:	0f b6 00             	movzbl (%eax),%eax
 63e:	0f be c0             	movsbl %al,%eax
 641:	89 44 24 04          	mov    %eax,0x4(%esp)
 645:	8b 45 08             	mov    0x8(%ebp),%eax
 648:	89 04 24             	mov    %eax,(%esp)
 64b:	e8 05 fe ff ff       	call   455 <putc>
          s++;
 650:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 654:	8b 45 f4             	mov    -0xc(%ebp),%eax
 657:	0f b6 00             	movzbl (%eax),%eax
 65a:	84 c0                	test   %al,%al
 65c:	75 da                	jne    638 <printf+0x103>
 65e:	eb 68                	jmp    6c8 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 660:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 664:	75 1d                	jne    683 <printf+0x14e>
        putc(fd, *ap);
 666:	8b 45 e8             	mov    -0x18(%ebp),%eax
 669:	8b 00                	mov    (%eax),%eax
 66b:	0f be c0             	movsbl %al,%eax
 66e:	89 44 24 04          	mov    %eax,0x4(%esp)
 672:	8b 45 08             	mov    0x8(%ebp),%eax
 675:	89 04 24             	mov    %eax,(%esp)
 678:	e8 d8 fd ff ff       	call   455 <putc>
        ap++;
 67d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 681:	eb 45                	jmp    6c8 <printf+0x193>
      } else if(c == '%'){
 683:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 687:	75 17                	jne    6a0 <printf+0x16b>
        putc(fd, c);
 689:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68c:	0f be c0             	movsbl %al,%eax
 68f:	89 44 24 04          	mov    %eax,0x4(%esp)
 693:	8b 45 08             	mov    0x8(%ebp),%eax
 696:	89 04 24             	mov    %eax,(%esp)
 699:	e8 b7 fd ff ff       	call   455 <putc>
 69e:	eb 28                	jmp    6c8 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6a0:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6a7:	00 
 6a8:	8b 45 08             	mov    0x8(%ebp),%eax
 6ab:	89 04 24             	mov    %eax,(%esp)
 6ae:	e8 a2 fd ff ff       	call   455 <putc>
        putc(fd, c);
 6b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b6:	0f be c0             	movsbl %al,%eax
 6b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6bd:	8b 45 08             	mov    0x8(%ebp),%eax
 6c0:	89 04 24             	mov    %eax,(%esp)
 6c3:	e8 8d fd ff ff       	call   455 <putc>
      }
      state = 0;
 6c8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6cf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6d3:	8b 55 0c             	mov    0xc(%ebp),%edx
 6d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d9:	01 d0                	add    %edx,%eax
 6db:	0f b6 00             	movzbl (%eax),%eax
 6de:	84 c0                	test   %al,%al
 6e0:	0f 85 71 fe ff ff    	jne    557 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6e6:	c9                   	leave  
 6e7:	c3                   	ret    

000006e8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6e8:	55                   	push   %ebp
 6e9:	89 e5                	mov    %esp,%ebp
 6eb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ee:	8b 45 08             	mov    0x8(%ebp),%eax
 6f1:	83 e8 08             	sub    $0x8,%eax
 6f4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f7:	a1 14 0c 00 00       	mov    0xc14,%eax
 6fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6ff:	eb 24                	jmp    725 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	8b 00                	mov    (%eax),%eax
 706:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 709:	77 12                	ja     71d <free+0x35>
 70b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 711:	77 24                	ja     737 <free+0x4f>
 713:	8b 45 fc             	mov    -0x4(%ebp),%eax
 716:	8b 00                	mov    (%eax),%eax
 718:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 71b:	77 1a                	ja     737 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 720:	8b 00                	mov    (%eax),%eax
 722:	89 45 fc             	mov    %eax,-0x4(%ebp)
 725:	8b 45 f8             	mov    -0x8(%ebp),%eax
 728:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 72b:	76 d4                	jbe    701 <free+0x19>
 72d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 730:	8b 00                	mov    (%eax),%eax
 732:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 735:	76 ca                	jbe    701 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 737:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73a:	8b 40 04             	mov    0x4(%eax),%eax
 73d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 744:	8b 45 f8             	mov    -0x8(%ebp),%eax
 747:	01 c2                	add    %eax,%edx
 749:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74c:	8b 00                	mov    (%eax),%eax
 74e:	39 c2                	cmp    %eax,%edx
 750:	75 24                	jne    776 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 752:	8b 45 f8             	mov    -0x8(%ebp),%eax
 755:	8b 50 04             	mov    0x4(%eax),%edx
 758:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75b:	8b 00                	mov    (%eax),%eax
 75d:	8b 40 04             	mov    0x4(%eax),%eax
 760:	01 c2                	add    %eax,%edx
 762:	8b 45 f8             	mov    -0x8(%ebp),%eax
 765:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 768:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76b:	8b 00                	mov    (%eax),%eax
 76d:	8b 10                	mov    (%eax),%edx
 76f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 772:	89 10                	mov    %edx,(%eax)
 774:	eb 0a                	jmp    780 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 776:	8b 45 fc             	mov    -0x4(%ebp),%eax
 779:	8b 10                	mov    (%eax),%edx
 77b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 780:	8b 45 fc             	mov    -0x4(%ebp),%eax
 783:	8b 40 04             	mov    0x4(%eax),%eax
 786:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 78d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 790:	01 d0                	add    %edx,%eax
 792:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 795:	75 20                	jne    7b7 <free+0xcf>
    p->s.size += bp->s.size;
 797:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79a:	8b 50 04             	mov    0x4(%eax),%edx
 79d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a0:	8b 40 04             	mov    0x4(%eax),%eax
 7a3:	01 c2                	add    %eax,%edx
 7a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ae:	8b 10                	mov    (%eax),%edx
 7b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b3:	89 10                	mov    %edx,(%eax)
 7b5:	eb 08                	jmp    7bf <free+0xd7>
  } else
    p->s.ptr = bp;
 7b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ba:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7bd:	89 10                	mov    %edx,(%eax)
  freep = p;
 7bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c2:	a3 14 0c 00 00       	mov    %eax,0xc14
}
 7c7:	c9                   	leave  
 7c8:	c3                   	ret    

000007c9 <morecore>:

static Header*
morecore(uint nu)
{
 7c9:	55                   	push   %ebp
 7ca:	89 e5                	mov    %esp,%ebp
 7cc:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7cf:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7d6:	77 07                	ja     7df <morecore+0x16>
    nu = 4096;
 7d8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7df:	8b 45 08             	mov    0x8(%ebp),%eax
 7e2:	c1 e0 03             	shl    $0x3,%eax
 7e5:	89 04 24             	mov    %eax,(%esp)
 7e8:	e8 10 fc ff ff       	call   3fd <sbrk>
 7ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7f0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7f4:	75 07                	jne    7fd <morecore+0x34>
    return 0;
 7f6:	b8 00 00 00 00       	mov    $0x0,%eax
 7fb:	eb 22                	jmp    81f <morecore+0x56>
  hp = (Header*)p;
 7fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 800:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 803:	8b 45 f0             	mov    -0x10(%ebp),%eax
 806:	8b 55 08             	mov    0x8(%ebp),%edx
 809:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 80c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80f:	83 c0 08             	add    $0x8,%eax
 812:	89 04 24             	mov    %eax,(%esp)
 815:	e8 ce fe ff ff       	call   6e8 <free>
  return freep;
 81a:	a1 14 0c 00 00       	mov    0xc14,%eax
}
 81f:	c9                   	leave  
 820:	c3                   	ret    

00000821 <malloc>:

void*
malloc(uint nbytes)
{
 821:	55                   	push   %ebp
 822:	89 e5                	mov    %esp,%ebp
 824:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 827:	8b 45 08             	mov    0x8(%ebp),%eax
 82a:	83 c0 07             	add    $0x7,%eax
 82d:	c1 e8 03             	shr    $0x3,%eax
 830:	83 c0 01             	add    $0x1,%eax
 833:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 836:	a1 14 0c 00 00       	mov    0xc14,%eax
 83b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 83e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 842:	75 23                	jne    867 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 844:	c7 45 f0 0c 0c 00 00 	movl   $0xc0c,-0x10(%ebp)
 84b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84e:	a3 14 0c 00 00       	mov    %eax,0xc14
 853:	a1 14 0c 00 00       	mov    0xc14,%eax
 858:	a3 0c 0c 00 00       	mov    %eax,0xc0c
    base.s.size = 0;
 85d:	c7 05 10 0c 00 00 00 	movl   $0x0,0xc10
 864:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 867:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86a:	8b 00                	mov    (%eax),%eax
 86c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 86f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 872:	8b 40 04             	mov    0x4(%eax),%eax
 875:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 878:	72 4d                	jb     8c7 <malloc+0xa6>
      if(p->s.size == nunits)
 87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87d:	8b 40 04             	mov    0x4(%eax),%eax
 880:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 883:	75 0c                	jne    891 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 885:	8b 45 f4             	mov    -0xc(%ebp),%eax
 888:	8b 10                	mov    (%eax),%edx
 88a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88d:	89 10                	mov    %edx,(%eax)
 88f:	eb 26                	jmp    8b7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 891:	8b 45 f4             	mov    -0xc(%ebp),%eax
 894:	8b 40 04             	mov    0x4(%eax),%eax
 897:	2b 45 ec             	sub    -0x14(%ebp),%eax
 89a:	89 c2                	mov    %eax,%edx
 89c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a5:	8b 40 04             	mov    0x4(%eax),%eax
 8a8:	c1 e0 03             	shl    $0x3,%eax
 8ab:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8b4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ba:	a3 14 0c 00 00       	mov    %eax,0xc14
      return (void*)(p + 1);
 8bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c2:	83 c0 08             	add    $0x8,%eax
 8c5:	eb 38                	jmp    8ff <malloc+0xde>
    }
    if(p == freep)
 8c7:	a1 14 0c 00 00       	mov    0xc14,%eax
 8cc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8cf:	75 1b                	jne    8ec <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8d4:	89 04 24             	mov    %eax,(%esp)
 8d7:	e8 ed fe ff ff       	call   7c9 <morecore>
 8dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8e3:	75 07                	jne    8ec <malloc+0xcb>
        return 0;
 8e5:	b8 00 00 00 00       	mov    $0x0,%eax
 8ea:	eb 13                	jmp    8ff <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f5:	8b 00                	mov    (%eax),%eax
 8f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8fa:	e9 70 ff ff ff       	jmp    86f <malloc+0x4e>
}
 8ff:	c9                   	leave  
 900:	c3                   	ret    
