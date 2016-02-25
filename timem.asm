
_timem:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#define NULL_PTR ((char*)0)


int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec a0 00 00 00    	sub    $0xa0,%esp
char *p[MAX_ARGS];

static int status = 1;

//start time
date(&r1);
   c:	8d 44 24 78          	lea    0x78(%esp),%eax
  10:	89 04 24             	mov    %eax,(%esp)
  13:	e8 c2 04 00 00       	call   4da <date>

// check for args
if (argc < 2)
  18:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  1c:	7f 19                	jg     37 <main+0x37>
{
	printf(2, "minimum one command after 'timem'");
  1e:	c7 44 24 04 c8 09 00 	movl   $0x9c8,0x4(%esp)
  25:	00 
  26:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  2d:	e8 c8 05 00 00       	call   5fa <printf>
  32:	e9 96 01 00 00       	jmp    1cd <main+0x1cd>
}
else if (argc > MAX_ARGS+1)
  37:	83 7d 08 15          	cmpl   $0x15,0x8(%ebp)
  3b:	7e 19                	jle    56 <main+0x56>
{
	printf(2, "Hit maximum commands.\n");
  3d:	c7 44 24 04 ea 09 00 	movl   $0x9ea,0x4(%esp)
  44:	00 
  45:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  4c:	e8 a9 05 00 00       	call   5fa <printf>
  51:	e9 77 01 00 00       	jmp    1cd <main+0x1cd>
}
else
{
	int i;

	int pid = fork();
  56:	e8 d7 03 00 00       	call   432 <fork>
  5b:	89 84 24 98 00 00 00 	mov    %eax,0x98(%esp)
    
	// negative (fork failed)
	if (pid < 0)                       
  62:	83 bc 24 98 00 00 00 	cmpl   $0x0,0x98(%esp)
  69:	00 
  6a:	79 22                	jns    8e <main+0x8e>
		printf(2, "'%s' has failed.\n", argv[0]);
  6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  6f:	8b 00                	mov    (%eax),%eax
  71:	89 44 24 08          	mov    %eax,0x8(%esp)
  75:	c7 44 24 04 01 0a 00 	movl   $0xa01,0x4(%esp)
  7c:	00 
  7d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  84:	e8 71 05 00 00       	call   5fa <printf>
  89:	e9 c0 00 00 00       	jmp    14e <main+0x14e>
	else if (pid > 0)                           
  8e:	83 bc 24 98 00 00 00 	cmpl   $0x0,0x98(%esp)
  95:	00 
  96:	7e 1d                	jle    b5 <main+0xb5>
	{
		//parent
      		pid = wait();
  98:	e8 a5 03 00 00       	call   442 <wait>
  9d:	89 84 24 98 00 00 00 	mov    %eax,0x98(%esp)

	//end time
	date(&r2);
  a4:	8d 44 24 60          	lea    0x60(%esp),%eax
  a8:	89 04 24             	mov    %eax,(%esp)
  ab:	e8 2a 04 00 00       	call   4da <date>
  b0:	e9 99 00 00 00       	jmp    14e <main+0x14e>
	}
	else             
	{
		for (i = 0; i < argc-1; i++)
  b5:	c7 84 24 9c 00 00 00 	movl   $0x0,0x9c(%esp)
  bc:	00 00 00 00 
  c0:	eb 2b                	jmp    ed <main+0xed>
		p[i] = argv[i+1];
  c2:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
  c9:	83 c0 01             	add    $0x1,%eax
  cc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  d6:	01 d0                	add    %edx,%eax
  d8:	8b 10                	mov    (%eax),%edx
  da:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
  e1:	89 54 84 10          	mov    %edx,0x10(%esp,%eax,4)
	//end time
	date(&r2);
	}
	else             
	{
		for (i = 0; i < argc-1; i++)
  e5:	83 84 24 9c 00 00 00 	addl   $0x1,0x9c(%esp)
  ec:	01 
  ed:	8b 45 08             	mov    0x8(%ebp),%eax
  f0:	83 e8 01             	sub    $0x1,%eax
  f3:	3b 84 24 9c 00 00 00 	cmp    0x9c(%esp),%eax
  fa:	7f c6                	jg     c2 <main+0xc2>
		p[i] = argv[i+1];
		p[i] = NULL_PTR;
  fc:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
 103:	c7 44 84 10 00 00 00 	movl   $0x0,0x10(%esp,%eax,4)
 10a:	00 

		//execute command
		status = exec(p[0], p);
 10b:	8b 44 24 10          	mov    0x10(%esp),%eax
 10f:	8d 54 24 10          	lea    0x10(%esp),%edx
 113:	89 54 24 04          	mov    %edx,0x4(%esp)
 117:	89 04 24             	mov    %eax,(%esp)
 11a:	e8 53 03 00 00       	call   472 <exec>
 11f:	a3 84 0c 00 00       	mov    %eax,0xc84
		if (status)
 124:	a1 84 0c 00 00       	mov    0xc84,%eax
 129:	85 c0                	test   %eax,%eax
 12b:	74 1c                	je     149 <main+0x149>
			printf(2, "exec '%s' failed", p[0]);
 12d:	8b 44 24 10          	mov    0x10(%esp),%eax
 131:	89 44 24 08          	mov    %eax,0x8(%esp)
 135:	c7 44 24 04 13 0a 00 	movl   $0xa13,0x4(%esp)
 13c:	00 
 13d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 144:	e8 b1 04 00 00       	call   5fa <printf>

		exit();
 149:	e8 ec 02 00 00       	call   43a <exit>
	}

	int s1 = r1.hour * 3600 + r1.minute * 60 + r1.second;
 14e:	8b 84 24 80 00 00 00 	mov    0x80(%esp),%eax
 155:	69 d0 10 0e 00 00    	imul   $0xe10,%eax,%edx
 15b:	8b 44 24 7c          	mov    0x7c(%esp),%eax
 15f:	c1 e0 02             	shl    $0x2,%eax
 162:	89 c1                	mov    %eax,%ecx
 164:	c1 e1 04             	shl    $0x4,%ecx
 167:	29 c1                	sub    %eax,%ecx
 169:	89 c8                	mov    %ecx,%eax
 16b:	01 c2                	add    %eax,%edx
 16d:	8b 44 24 78          	mov    0x78(%esp),%eax
 171:	01 d0                	add    %edx,%eax
 173:	89 84 24 94 00 00 00 	mov    %eax,0x94(%esp)
	int s2 = r2.hour * 3600 + r2.minute * 60 + r2.second;
 17a:	8b 44 24 68          	mov    0x68(%esp),%eax
 17e:	69 d0 10 0e 00 00    	imul   $0xe10,%eax,%edx
 184:	8b 44 24 64          	mov    0x64(%esp),%eax
 188:	c1 e0 02             	shl    $0x2,%eax
 18b:	89 c1                	mov    %eax,%ecx
 18d:	c1 e1 04             	shl    $0x4,%ecx
 190:	29 c1                	sub    %eax,%ecx
 192:	89 c8                	mov    %ecx,%eax
 194:	01 c2                	add    %eax,%edx
 196:	8b 44 24 60          	mov    0x60(%esp),%eax
 19a:	01 d0                	add    %edx,%eax
 19c:	89 84 24 90 00 00 00 	mov    %eax,0x90(%esp)
	printf(2, "\nTime: %d seconds\n", s2-s1);
 1a3:	8b 84 24 94 00 00 00 	mov    0x94(%esp),%eax
 1aa:	8b 94 24 90 00 00 00 	mov    0x90(%esp),%edx
 1b1:	29 c2                	sub    %eax,%edx
 1b3:	89 d0                	mov    %edx,%eax
 1b5:	89 44 24 08          	mov    %eax,0x8(%esp)
 1b9:	c7 44 24 04 24 0a 00 	movl   $0xa24,0x4(%esp)
 1c0:	00 
 1c1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1c8:	e8 2d 04 00 00       	call   5fa <printf>
}
exit();
 1cd:	e8 68 02 00 00       	call   43a <exit>

000001d2 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1d2:	55                   	push   %ebp
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	57                   	push   %edi
 1d6:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1da:	8b 55 10             	mov    0x10(%ebp),%edx
 1dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e0:	89 cb                	mov    %ecx,%ebx
 1e2:	89 df                	mov    %ebx,%edi
 1e4:	89 d1                	mov    %edx,%ecx
 1e6:	fc                   	cld    
 1e7:	f3 aa                	rep stos %al,%es:(%edi)
 1e9:	89 ca                	mov    %ecx,%edx
 1eb:	89 fb                	mov    %edi,%ebx
 1ed:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1f0:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1f3:	5b                   	pop    %ebx
 1f4:	5f                   	pop    %edi
 1f5:	5d                   	pop    %ebp
 1f6:	c3                   	ret    

000001f7 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 203:	90                   	nop
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	8d 50 01             	lea    0x1(%eax),%edx
 20a:	89 55 08             	mov    %edx,0x8(%ebp)
 20d:	8b 55 0c             	mov    0xc(%ebp),%edx
 210:	8d 4a 01             	lea    0x1(%edx),%ecx
 213:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 216:	0f b6 12             	movzbl (%edx),%edx
 219:	88 10                	mov    %dl,(%eax)
 21b:	0f b6 00             	movzbl (%eax),%eax
 21e:	84 c0                	test   %al,%al
 220:	75 e2                	jne    204 <strcpy+0xd>
    ;
  return os;
 222:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 225:	c9                   	leave  
 226:	c3                   	ret    

00000227 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 227:	55                   	push   %ebp
 228:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 22a:	eb 08                	jmp    234 <strcmp+0xd>
    p++, q++;
 22c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 230:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	0f b6 00             	movzbl (%eax),%eax
 23a:	84 c0                	test   %al,%al
 23c:	74 10                	je     24e <strcmp+0x27>
 23e:	8b 45 08             	mov    0x8(%ebp),%eax
 241:	0f b6 10             	movzbl (%eax),%edx
 244:	8b 45 0c             	mov    0xc(%ebp),%eax
 247:	0f b6 00             	movzbl (%eax),%eax
 24a:	38 c2                	cmp    %al,%dl
 24c:	74 de                	je     22c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
 251:	0f b6 00             	movzbl (%eax),%eax
 254:	0f b6 d0             	movzbl %al,%edx
 257:	8b 45 0c             	mov    0xc(%ebp),%eax
 25a:	0f b6 00             	movzbl (%eax),%eax
 25d:	0f b6 c0             	movzbl %al,%eax
 260:	29 c2                	sub    %eax,%edx
 262:	89 d0                	mov    %edx,%eax
}
 264:	5d                   	pop    %ebp
 265:	c3                   	ret    

00000266 <strlen>:

uint
strlen(char *s)
{
 266:	55                   	push   %ebp
 267:	89 e5                	mov    %esp,%ebp
 269:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 26c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 273:	eb 04                	jmp    279 <strlen+0x13>
 275:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 279:	8b 55 fc             	mov    -0x4(%ebp),%edx
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	01 d0                	add    %edx,%eax
 281:	0f b6 00             	movzbl (%eax),%eax
 284:	84 c0                	test   %al,%al
 286:	75 ed                	jne    275 <strlen+0xf>
    ;
  return n;
 288:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 28b:	c9                   	leave  
 28c:	c3                   	ret    

0000028d <memset>:

void*
memset(void *dst, int c, uint n)
{
 28d:	55                   	push   %ebp
 28e:	89 e5                	mov    %esp,%ebp
 290:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 293:	8b 45 10             	mov    0x10(%ebp),%eax
 296:	89 44 24 08          	mov    %eax,0x8(%esp)
 29a:	8b 45 0c             	mov    0xc(%ebp),%eax
 29d:	89 44 24 04          	mov    %eax,0x4(%esp)
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	89 04 24             	mov    %eax,(%esp)
 2a7:	e8 26 ff ff ff       	call   1d2 <stosb>
  return dst;
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2af:	c9                   	leave  
 2b0:	c3                   	ret    

000002b1 <strchr>:

char*
strchr(const char *s, char c)
{
 2b1:	55                   	push   %ebp
 2b2:	89 e5                	mov    %esp,%ebp
 2b4:	83 ec 04             	sub    $0x4,%esp
 2b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ba:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2bd:	eb 14                	jmp    2d3 <strchr+0x22>
    if(*s == c)
 2bf:	8b 45 08             	mov    0x8(%ebp),%eax
 2c2:	0f b6 00             	movzbl (%eax),%eax
 2c5:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2c8:	75 05                	jne    2cf <strchr+0x1e>
      return (char*)s;
 2ca:	8b 45 08             	mov    0x8(%ebp),%eax
 2cd:	eb 13                	jmp    2e2 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2d3:	8b 45 08             	mov    0x8(%ebp),%eax
 2d6:	0f b6 00             	movzbl (%eax),%eax
 2d9:	84 c0                	test   %al,%al
 2db:	75 e2                	jne    2bf <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2e2:	c9                   	leave  
 2e3:	c3                   	ret    

000002e4 <gets>:

char*
gets(char *buf, int max)
{
 2e4:	55                   	push   %ebp
 2e5:	89 e5                	mov    %esp,%ebp
 2e7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2f1:	eb 4c                	jmp    33f <gets+0x5b>
    cc = read(0, &c, 1);
 2f3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2fa:	00 
 2fb:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 302:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 309:	e8 44 01 00 00       	call   452 <read>
 30e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 311:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 315:	7f 02                	jg     319 <gets+0x35>
      break;
 317:	eb 31                	jmp    34a <gets+0x66>
    buf[i++] = c;
 319:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31c:	8d 50 01             	lea    0x1(%eax),%edx
 31f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 322:	89 c2                	mov    %eax,%edx
 324:	8b 45 08             	mov    0x8(%ebp),%eax
 327:	01 c2                	add    %eax,%edx
 329:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 32d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 32f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 333:	3c 0a                	cmp    $0xa,%al
 335:	74 13                	je     34a <gets+0x66>
 337:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 33b:	3c 0d                	cmp    $0xd,%al
 33d:	74 0b                	je     34a <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 33f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 342:	83 c0 01             	add    $0x1,%eax
 345:	3b 45 0c             	cmp    0xc(%ebp),%eax
 348:	7c a9                	jl     2f3 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 34a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 34d:	8b 45 08             	mov    0x8(%ebp),%eax
 350:	01 d0                	add    %edx,%eax
 352:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 355:	8b 45 08             	mov    0x8(%ebp),%eax
}
 358:	c9                   	leave  
 359:	c3                   	ret    

0000035a <stat>:

int
stat(char *n, struct stat *st)
{
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
 35d:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 360:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 367:	00 
 368:	8b 45 08             	mov    0x8(%ebp),%eax
 36b:	89 04 24             	mov    %eax,(%esp)
 36e:	e8 07 01 00 00       	call   47a <open>
 373:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 376:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 37a:	79 07                	jns    383 <stat+0x29>
    return -1;
 37c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 381:	eb 23                	jmp    3a6 <stat+0x4c>
  r = fstat(fd, st);
 383:	8b 45 0c             	mov    0xc(%ebp),%eax
 386:	89 44 24 04          	mov    %eax,0x4(%esp)
 38a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38d:	89 04 24             	mov    %eax,(%esp)
 390:	e8 fd 00 00 00       	call   492 <fstat>
 395:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 398:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39b:	89 04 24             	mov    %eax,(%esp)
 39e:	e8 bf 00 00 00       	call   462 <close>
  return r;
 3a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3a6:	c9                   	leave  
 3a7:	c3                   	ret    

000003a8 <atoi>:

int
atoi(const char *s)
{
 3a8:	55                   	push   %ebp
 3a9:	89 e5                	mov    %esp,%ebp
 3ab:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3b5:	eb 25                	jmp    3dc <atoi+0x34>
    n = n*10 + *s++ - '0';
 3b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3ba:	89 d0                	mov    %edx,%eax
 3bc:	c1 e0 02             	shl    $0x2,%eax
 3bf:	01 d0                	add    %edx,%eax
 3c1:	01 c0                	add    %eax,%eax
 3c3:	89 c1                	mov    %eax,%ecx
 3c5:	8b 45 08             	mov    0x8(%ebp),%eax
 3c8:	8d 50 01             	lea    0x1(%eax),%edx
 3cb:	89 55 08             	mov    %edx,0x8(%ebp)
 3ce:	0f b6 00             	movzbl (%eax),%eax
 3d1:	0f be c0             	movsbl %al,%eax
 3d4:	01 c8                	add    %ecx,%eax
 3d6:	83 e8 30             	sub    $0x30,%eax
 3d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3dc:	8b 45 08             	mov    0x8(%ebp),%eax
 3df:	0f b6 00             	movzbl (%eax),%eax
 3e2:	3c 2f                	cmp    $0x2f,%al
 3e4:	7e 0a                	jle    3f0 <atoi+0x48>
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	0f b6 00             	movzbl (%eax),%eax
 3ec:	3c 39                	cmp    $0x39,%al
 3ee:	7e c7                	jle    3b7 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3f3:	c9                   	leave  
 3f4:	c3                   	ret    

000003f5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3f5:	55                   	push   %ebp
 3f6:	89 e5                	mov    %esp,%ebp
 3f8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3fb:	8b 45 08             	mov    0x8(%ebp),%eax
 3fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 401:	8b 45 0c             	mov    0xc(%ebp),%eax
 404:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 407:	eb 17                	jmp    420 <memmove+0x2b>
    *dst++ = *src++;
 409:	8b 45 fc             	mov    -0x4(%ebp),%eax
 40c:	8d 50 01             	lea    0x1(%eax),%edx
 40f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 412:	8b 55 f8             	mov    -0x8(%ebp),%edx
 415:	8d 4a 01             	lea    0x1(%edx),%ecx
 418:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 41b:	0f b6 12             	movzbl (%edx),%edx
 41e:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 420:	8b 45 10             	mov    0x10(%ebp),%eax
 423:	8d 50 ff             	lea    -0x1(%eax),%edx
 426:	89 55 10             	mov    %edx,0x10(%ebp)
 429:	85 c0                	test   %eax,%eax
 42b:	7f dc                	jg     409 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 42d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 430:	c9                   	leave  
 431:	c3                   	ret    

00000432 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 432:	b8 01 00 00 00       	mov    $0x1,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <exit>:
SYSCALL(exit)
 43a:	b8 02 00 00 00       	mov    $0x2,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <wait>:
SYSCALL(wait)
 442:	b8 03 00 00 00       	mov    $0x3,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <pipe>:
SYSCALL(pipe)
 44a:	b8 04 00 00 00       	mov    $0x4,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <read>:
SYSCALL(read)
 452:	b8 05 00 00 00       	mov    $0x5,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    

0000045a <write>:
SYSCALL(write)
 45a:	b8 10 00 00 00       	mov    $0x10,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <close>:
SYSCALL(close)
 462:	b8 15 00 00 00       	mov    $0x15,%eax
 467:	cd 40                	int    $0x40
 469:	c3                   	ret    

0000046a <kill>:
SYSCALL(kill)
 46a:	b8 06 00 00 00       	mov    $0x6,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <exec>:
SYSCALL(exec)
 472:	b8 07 00 00 00       	mov    $0x7,%eax
 477:	cd 40                	int    $0x40
 479:	c3                   	ret    

0000047a <open>:
SYSCALL(open)
 47a:	b8 0f 00 00 00       	mov    $0xf,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret    

00000482 <mknod>:
SYSCALL(mknod)
 482:	b8 11 00 00 00       	mov    $0x11,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret    

0000048a <unlink>:
SYSCALL(unlink)
 48a:	b8 12 00 00 00       	mov    $0x12,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret    

00000492 <fstat>:
SYSCALL(fstat)
 492:	b8 08 00 00 00       	mov    $0x8,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret    

0000049a <link>:
SYSCALL(link)
 49a:	b8 13 00 00 00       	mov    $0x13,%eax
 49f:	cd 40                	int    $0x40
 4a1:	c3                   	ret    

000004a2 <mkdir>:
SYSCALL(mkdir)
 4a2:	b8 14 00 00 00       	mov    $0x14,%eax
 4a7:	cd 40                	int    $0x40
 4a9:	c3                   	ret    

000004aa <chdir>:
SYSCALL(chdir)
 4aa:	b8 09 00 00 00       	mov    $0x9,%eax
 4af:	cd 40                	int    $0x40
 4b1:	c3                   	ret    

000004b2 <dup>:
SYSCALL(dup)
 4b2:	b8 0a 00 00 00       	mov    $0xa,%eax
 4b7:	cd 40                	int    $0x40
 4b9:	c3                   	ret    

000004ba <getpid>:
SYSCALL(getpid)
 4ba:	b8 0b 00 00 00       	mov    $0xb,%eax
 4bf:	cd 40                	int    $0x40
 4c1:	c3                   	ret    

000004c2 <sbrk>:
SYSCALL(sbrk)
 4c2:	b8 0c 00 00 00       	mov    $0xc,%eax
 4c7:	cd 40                	int    $0x40
 4c9:	c3                   	ret    

000004ca <sleep>:
SYSCALL(sleep)
 4ca:	b8 0d 00 00 00       	mov    $0xd,%eax
 4cf:	cd 40                	int    $0x40
 4d1:	c3                   	ret    

000004d2 <uptime>:
SYSCALL(uptime)
 4d2:	b8 0e 00 00 00       	mov    $0xe,%eax
 4d7:	cd 40                	int    $0x40
 4d9:	c3                   	ret    

000004da <date>:
SYSCALL(date)
 4da:	b8 16 00 00 00       	mov    $0x16,%eax
 4df:	cd 40                	int    $0x40
 4e1:	c3                   	ret    

000004e2 <timem>:
SYSCALL(timem)
 4e2:	b8 17 00 00 00       	mov    $0x17,%eax
 4e7:	cd 40                	int    $0x40
 4e9:	c3                   	ret    

000004ea <getuid>:
SYSCALL(getuid)
 4ea:	b8 18 00 00 00       	mov    $0x18,%eax
 4ef:	cd 40                	int    $0x40
 4f1:	c3                   	ret    

000004f2 <getgid>:
SYSCALL(getgid)
 4f2:	b8 19 00 00 00       	mov    $0x19,%eax
 4f7:	cd 40                	int    $0x40
 4f9:	c3                   	ret    

000004fa <getppid>:
SYSCALL(getppid)
 4fa:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4ff:	cd 40                	int    $0x40
 501:	c3                   	ret    

00000502 <setuid>:
SYSCALL(setuid)
 502:	b8 1b 00 00 00       	mov    $0x1b,%eax
 507:	cd 40                	int    $0x40
 509:	c3                   	ret    

0000050a <setgid>:
SYSCALL(setgid)
 50a:	b8 1c 00 00 00       	mov    $0x1c,%eax
 50f:	cd 40                	int    $0x40
 511:	c3                   	ret    

00000512 <getprocs>:
SYSCALL(getprocs)
 512:	b8 1d 00 00 00       	mov    $0x1d,%eax
 517:	cd 40                	int    $0x40
 519:	c3                   	ret    

0000051a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 51a:	55                   	push   %ebp
 51b:	89 e5                	mov    %esp,%ebp
 51d:	83 ec 18             	sub    $0x18,%esp
 520:	8b 45 0c             	mov    0xc(%ebp),%eax
 523:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 526:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 52d:	00 
 52e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 531:	89 44 24 04          	mov    %eax,0x4(%esp)
 535:	8b 45 08             	mov    0x8(%ebp),%eax
 538:	89 04 24             	mov    %eax,(%esp)
 53b:	e8 1a ff ff ff       	call   45a <write>
}
 540:	c9                   	leave  
 541:	c3                   	ret    

00000542 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 542:	55                   	push   %ebp
 543:	89 e5                	mov    %esp,%ebp
 545:	56                   	push   %esi
 546:	53                   	push   %ebx
 547:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 54a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 551:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 555:	74 17                	je     56e <printint+0x2c>
 557:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 55b:	79 11                	jns    56e <printint+0x2c>
    neg = 1;
 55d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 564:	8b 45 0c             	mov    0xc(%ebp),%eax
 567:	f7 d8                	neg    %eax
 569:	89 45 ec             	mov    %eax,-0x14(%ebp)
 56c:	eb 06                	jmp    574 <printint+0x32>
  } else {
    x = xx;
 56e:	8b 45 0c             	mov    0xc(%ebp),%eax
 571:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 574:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 57b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 57e:	8d 41 01             	lea    0x1(%ecx),%eax
 581:	89 45 f4             	mov    %eax,-0xc(%ebp)
 584:	8b 5d 10             	mov    0x10(%ebp),%ebx
 587:	8b 45 ec             	mov    -0x14(%ebp),%eax
 58a:	ba 00 00 00 00       	mov    $0x0,%edx
 58f:	f7 f3                	div    %ebx
 591:	89 d0                	mov    %edx,%eax
 593:	0f b6 80 88 0c 00 00 	movzbl 0xc88(%eax),%eax
 59a:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 59e:	8b 75 10             	mov    0x10(%ebp),%esi
 5a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5a4:	ba 00 00 00 00       	mov    $0x0,%edx
 5a9:	f7 f6                	div    %esi
 5ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5ae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5b2:	75 c7                	jne    57b <printint+0x39>
  if(neg)
 5b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5b8:	74 10                	je     5ca <printint+0x88>
    buf[i++] = '-';
 5ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5bd:	8d 50 01             	lea    0x1(%eax),%edx
 5c0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5c3:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5c8:	eb 1f                	jmp    5e9 <printint+0xa7>
 5ca:	eb 1d                	jmp    5e9 <printint+0xa7>
    putc(fd, buf[i]);
 5cc:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d2:	01 d0                	add    %edx,%eax
 5d4:	0f b6 00             	movzbl (%eax),%eax
 5d7:	0f be c0             	movsbl %al,%eax
 5da:	89 44 24 04          	mov    %eax,0x4(%esp)
 5de:	8b 45 08             	mov    0x8(%ebp),%eax
 5e1:	89 04 24             	mov    %eax,(%esp)
 5e4:	e8 31 ff ff ff       	call   51a <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5e9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5f1:	79 d9                	jns    5cc <printint+0x8a>
    putc(fd, buf[i]);
}
 5f3:	83 c4 30             	add    $0x30,%esp
 5f6:	5b                   	pop    %ebx
 5f7:	5e                   	pop    %esi
 5f8:	5d                   	pop    %ebp
 5f9:	c3                   	ret    

000005fa <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5fa:	55                   	push   %ebp
 5fb:	89 e5                	mov    %esp,%ebp
 5fd:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 600:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 607:	8d 45 0c             	lea    0xc(%ebp),%eax
 60a:	83 c0 04             	add    $0x4,%eax
 60d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 610:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 617:	e9 7c 01 00 00       	jmp    798 <printf+0x19e>
    c = fmt[i] & 0xff;
 61c:	8b 55 0c             	mov    0xc(%ebp),%edx
 61f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 622:	01 d0                	add    %edx,%eax
 624:	0f b6 00             	movzbl (%eax),%eax
 627:	0f be c0             	movsbl %al,%eax
 62a:	25 ff 00 00 00       	and    $0xff,%eax
 62f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 632:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 636:	75 2c                	jne    664 <printf+0x6a>
      if(c == '%'){
 638:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 63c:	75 0c                	jne    64a <printf+0x50>
        state = '%';
 63e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 645:	e9 4a 01 00 00       	jmp    794 <printf+0x19a>
      } else {
        putc(fd, c);
 64a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64d:	0f be c0             	movsbl %al,%eax
 650:	89 44 24 04          	mov    %eax,0x4(%esp)
 654:	8b 45 08             	mov    0x8(%ebp),%eax
 657:	89 04 24             	mov    %eax,(%esp)
 65a:	e8 bb fe ff ff       	call   51a <putc>
 65f:	e9 30 01 00 00       	jmp    794 <printf+0x19a>
      }
    } else if(state == '%'){
 664:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 668:	0f 85 26 01 00 00    	jne    794 <printf+0x19a>
      if(c == 'd'){
 66e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 672:	75 2d                	jne    6a1 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 674:	8b 45 e8             	mov    -0x18(%ebp),%eax
 677:	8b 00                	mov    (%eax),%eax
 679:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 680:	00 
 681:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 688:	00 
 689:	89 44 24 04          	mov    %eax,0x4(%esp)
 68d:	8b 45 08             	mov    0x8(%ebp),%eax
 690:	89 04 24             	mov    %eax,(%esp)
 693:	e8 aa fe ff ff       	call   542 <printint>
        ap++;
 698:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 69c:	e9 ec 00 00 00       	jmp    78d <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 6a1:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6a5:	74 06                	je     6ad <printf+0xb3>
 6a7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6ab:	75 2d                	jne    6da <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b0:	8b 00                	mov    (%eax),%eax
 6b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6b9:	00 
 6ba:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6c1:	00 
 6c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c6:	8b 45 08             	mov    0x8(%ebp),%eax
 6c9:	89 04 24             	mov    %eax,(%esp)
 6cc:	e8 71 fe ff ff       	call   542 <printint>
        ap++;
 6d1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d5:	e9 b3 00 00 00       	jmp    78d <printf+0x193>
      } else if(c == 's'){
 6da:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6de:	75 45                	jne    725 <printf+0x12b>
        s = (char*)*ap;
 6e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e3:	8b 00                	mov    (%eax),%eax
 6e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6e8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f0:	75 09                	jne    6fb <printf+0x101>
          s = "(null)";
 6f2:	c7 45 f4 37 0a 00 00 	movl   $0xa37,-0xc(%ebp)
        while(*s != 0){
 6f9:	eb 1e                	jmp    719 <printf+0x11f>
 6fb:	eb 1c                	jmp    719 <printf+0x11f>
          putc(fd, *s);
 6fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 700:	0f b6 00             	movzbl (%eax),%eax
 703:	0f be c0             	movsbl %al,%eax
 706:	89 44 24 04          	mov    %eax,0x4(%esp)
 70a:	8b 45 08             	mov    0x8(%ebp),%eax
 70d:	89 04 24             	mov    %eax,(%esp)
 710:	e8 05 fe ff ff       	call   51a <putc>
          s++;
 715:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 719:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71c:	0f b6 00             	movzbl (%eax),%eax
 71f:	84 c0                	test   %al,%al
 721:	75 da                	jne    6fd <printf+0x103>
 723:	eb 68                	jmp    78d <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 725:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 729:	75 1d                	jne    748 <printf+0x14e>
        putc(fd, *ap);
 72b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 72e:	8b 00                	mov    (%eax),%eax
 730:	0f be c0             	movsbl %al,%eax
 733:	89 44 24 04          	mov    %eax,0x4(%esp)
 737:	8b 45 08             	mov    0x8(%ebp),%eax
 73a:	89 04 24             	mov    %eax,(%esp)
 73d:	e8 d8 fd ff ff       	call   51a <putc>
        ap++;
 742:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 746:	eb 45                	jmp    78d <printf+0x193>
      } else if(c == '%'){
 748:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 74c:	75 17                	jne    765 <printf+0x16b>
        putc(fd, c);
 74e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 751:	0f be c0             	movsbl %al,%eax
 754:	89 44 24 04          	mov    %eax,0x4(%esp)
 758:	8b 45 08             	mov    0x8(%ebp),%eax
 75b:	89 04 24             	mov    %eax,(%esp)
 75e:	e8 b7 fd ff ff       	call   51a <putc>
 763:	eb 28                	jmp    78d <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 765:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 76c:	00 
 76d:	8b 45 08             	mov    0x8(%ebp),%eax
 770:	89 04 24             	mov    %eax,(%esp)
 773:	e8 a2 fd ff ff       	call   51a <putc>
        putc(fd, c);
 778:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 77b:	0f be c0             	movsbl %al,%eax
 77e:	89 44 24 04          	mov    %eax,0x4(%esp)
 782:	8b 45 08             	mov    0x8(%ebp),%eax
 785:	89 04 24             	mov    %eax,(%esp)
 788:	e8 8d fd ff ff       	call   51a <putc>
      }
      state = 0;
 78d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 794:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 798:	8b 55 0c             	mov    0xc(%ebp),%edx
 79b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79e:	01 d0                	add    %edx,%eax
 7a0:	0f b6 00             	movzbl (%eax),%eax
 7a3:	84 c0                	test   %al,%al
 7a5:	0f 85 71 fe ff ff    	jne    61c <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7ab:	c9                   	leave  
 7ac:	c3                   	ret    

000007ad <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ad:	55                   	push   %ebp
 7ae:	89 e5                	mov    %esp,%ebp
 7b0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b3:	8b 45 08             	mov    0x8(%ebp),%eax
 7b6:	83 e8 08             	sub    $0x8,%eax
 7b9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bc:	a1 a4 0c 00 00       	mov    0xca4,%eax
 7c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c4:	eb 24                	jmp    7ea <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c9:	8b 00                	mov    (%eax),%eax
 7cb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ce:	77 12                	ja     7e2 <free+0x35>
 7d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d6:	77 24                	ja     7fc <free+0x4f>
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e0:	77 1a                	ja     7fc <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e5:	8b 00                	mov    (%eax),%eax
 7e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ed:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f0:	76 d4                	jbe    7c6 <free+0x19>
 7f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f5:	8b 00                	mov    (%eax),%eax
 7f7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7fa:	76 ca                	jbe    7c6 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ff:	8b 40 04             	mov    0x4(%eax),%eax
 802:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 809:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80c:	01 c2                	add    %eax,%edx
 80e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 811:	8b 00                	mov    (%eax),%eax
 813:	39 c2                	cmp    %eax,%edx
 815:	75 24                	jne    83b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 817:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81a:	8b 50 04             	mov    0x4(%eax),%edx
 81d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 820:	8b 00                	mov    (%eax),%eax
 822:	8b 40 04             	mov    0x4(%eax),%eax
 825:	01 c2                	add    %eax,%edx
 827:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 82d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 830:	8b 00                	mov    (%eax),%eax
 832:	8b 10                	mov    (%eax),%edx
 834:	8b 45 f8             	mov    -0x8(%ebp),%eax
 837:	89 10                	mov    %edx,(%eax)
 839:	eb 0a                	jmp    845 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 83b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83e:	8b 10                	mov    (%eax),%edx
 840:	8b 45 f8             	mov    -0x8(%ebp),%eax
 843:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
 848:	8b 40 04             	mov    0x4(%eax),%eax
 84b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 852:	8b 45 fc             	mov    -0x4(%ebp),%eax
 855:	01 d0                	add    %edx,%eax
 857:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 85a:	75 20                	jne    87c <free+0xcf>
    p->s.size += bp->s.size;
 85c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85f:	8b 50 04             	mov    0x4(%eax),%edx
 862:	8b 45 f8             	mov    -0x8(%ebp),%eax
 865:	8b 40 04             	mov    0x4(%eax),%eax
 868:	01 c2                	add    %eax,%edx
 86a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 870:	8b 45 f8             	mov    -0x8(%ebp),%eax
 873:	8b 10                	mov    (%eax),%edx
 875:	8b 45 fc             	mov    -0x4(%ebp),%eax
 878:	89 10                	mov    %edx,(%eax)
 87a:	eb 08                	jmp    884 <free+0xd7>
  } else
    p->s.ptr = bp;
 87c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 882:	89 10                	mov    %edx,(%eax)
  freep = p;
 884:	8b 45 fc             	mov    -0x4(%ebp),%eax
 887:	a3 a4 0c 00 00       	mov    %eax,0xca4
}
 88c:	c9                   	leave  
 88d:	c3                   	ret    

0000088e <morecore>:

static Header*
morecore(uint nu)
{
 88e:	55                   	push   %ebp
 88f:	89 e5                	mov    %esp,%ebp
 891:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 894:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 89b:	77 07                	ja     8a4 <morecore+0x16>
    nu = 4096;
 89d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8a4:	8b 45 08             	mov    0x8(%ebp),%eax
 8a7:	c1 e0 03             	shl    $0x3,%eax
 8aa:	89 04 24             	mov    %eax,(%esp)
 8ad:	e8 10 fc ff ff       	call   4c2 <sbrk>
 8b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8b5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8b9:	75 07                	jne    8c2 <morecore+0x34>
    return 0;
 8bb:	b8 00 00 00 00       	mov    $0x0,%eax
 8c0:	eb 22                	jmp    8e4 <morecore+0x56>
  hp = (Header*)p;
 8c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cb:	8b 55 08             	mov    0x8(%ebp),%edx
 8ce:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d4:	83 c0 08             	add    $0x8,%eax
 8d7:	89 04 24             	mov    %eax,(%esp)
 8da:	e8 ce fe ff ff       	call   7ad <free>
  return freep;
 8df:	a1 a4 0c 00 00       	mov    0xca4,%eax
}
 8e4:	c9                   	leave  
 8e5:	c3                   	ret    

000008e6 <malloc>:

void*
malloc(uint nbytes)
{
 8e6:	55                   	push   %ebp
 8e7:	89 e5                	mov    %esp,%ebp
 8e9:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ec:	8b 45 08             	mov    0x8(%ebp),%eax
 8ef:	83 c0 07             	add    $0x7,%eax
 8f2:	c1 e8 03             	shr    $0x3,%eax
 8f5:	83 c0 01             	add    $0x1,%eax
 8f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8fb:	a1 a4 0c 00 00       	mov    0xca4,%eax
 900:	89 45 f0             	mov    %eax,-0x10(%ebp)
 903:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 907:	75 23                	jne    92c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 909:	c7 45 f0 9c 0c 00 00 	movl   $0xc9c,-0x10(%ebp)
 910:	8b 45 f0             	mov    -0x10(%ebp),%eax
 913:	a3 a4 0c 00 00       	mov    %eax,0xca4
 918:	a1 a4 0c 00 00       	mov    0xca4,%eax
 91d:	a3 9c 0c 00 00       	mov    %eax,0xc9c
    base.s.size = 0;
 922:	c7 05 a0 0c 00 00 00 	movl   $0x0,0xca0
 929:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92f:	8b 00                	mov    (%eax),%eax
 931:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 934:	8b 45 f4             	mov    -0xc(%ebp),%eax
 937:	8b 40 04             	mov    0x4(%eax),%eax
 93a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 93d:	72 4d                	jb     98c <malloc+0xa6>
      if(p->s.size == nunits)
 93f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 942:	8b 40 04             	mov    0x4(%eax),%eax
 945:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 948:	75 0c                	jne    956 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 94a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94d:	8b 10                	mov    (%eax),%edx
 94f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 952:	89 10                	mov    %edx,(%eax)
 954:	eb 26                	jmp    97c <malloc+0x96>
      else {
        p->s.size -= nunits;
 956:	8b 45 f4             	mov    -0xc(%ebp),%eax
 959:	8b 40 04             	mov    0x4(%eax),%eax
 95c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 95f:	89 c2                	mov    %eax,%edx
 961:	8b 45 f4             	mov    -0xc(%ebp),%eax
 964:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 967:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96a:	8b 40 04             	mov    0x4(%eax),%eax
 96d:	c1 e0 03             	shl    $0x3,%eax
 970:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 973:	8b 45 f4             	mov    -0xc(%ebp),%eax
 976:	8b 55 ec             	mov    -0x14(%ebp),%edx
 979:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 97c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97f:	a3 a4 0c 00 00       	mov    %eax,0xca4
      return (void*)(p + 1);
 984:	8b 45 f4             	mov    -0xc(%ebp),%eax
 987:	83 c0 08             	add    $0x8,%eax
 98a:	eb 38                	jmp    9c4 <malloc+0xde>
    }
    if(p == freep)
 98c:	a1 a4 0c 00 00       	mov    0xca4,%eax
 991:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 994:	75 1b                	jne    9b1 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 996:	8b 45 ec             	mov    -0x14(%ebp),%eax
 999:	89 04 24             	mov    %eax,(%esp)
 99c:	e8 ed fe ff ff       	call   88e <morecore>
 9a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9a8:	75 07                	jne    9b1 <malloc+0xcb>
        return 0;
 9aa:	b8 00 00 00 00       	mov    $0x0,%eax
 9af:	eb 13                	jmp    9c4 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ba:	8b 00                	mov    (%eax),%eax
 9bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9bf:	e9 70 ff ff ff       	jmp    934 <malloc+0x4e>
}
 9c4:	c9                   	leave  
 9c5:	c3                   	ret    
