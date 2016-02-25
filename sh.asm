
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 05                	jne    11 <runcmd+0x11>
    exit();
       c:	e8 7d 12 00 00       	call   128e <exit>
  
  switch(cmd->type){
      11:	8b 45 08             	mov    0x8(%ebp),%eax
      14:	8b 00                	mov    (%eax),%eax
      16:	83 f8 05             	cmp    $0x5,%eax
      19:	77 09                	ja     24 <runcmd+0x24>
      1b:	8b 04 85 48 18 00 00 	mov    0x1848(,%eax,4),%eax
      22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      24:	c7 04 24 1c 18 00 00 	movl   $0x181c,(%esp)
      2b:	e8 54 06 00 00       	call   684 <panic>

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      30:	8b 45 08             	mov    0x8(%ebp),%eax
      33:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      36:	8b 45 f4             	mov    -0xc(%ebp),%eax
      39:	8b 40 04             	mov    0x4(%eax),%eax
      3c:	85 c0                	test   %eax,%eax
      3e:	75 05                	jne    45 <runcmd+0x45>
      exit();
      40:	e8 49 12 00 00       	call   128e <exit>
    exec(ecmd->argv[0], ecmd->argv);
      45:	8b 45 f4             	mov    -0xc(%ebp),%eax
      48:	8d 50 04             	lea    0x4(%eax),%edx
      4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4e:	8b 40 04             	mov    0x4(%eax),%eax
      51:	89 54 24 04          	mov    %edx,0x4(%esp)
      55:	89 04 24             	mov    %eax,(%esp)
      58:	e8 69 12 00 00       	call   12c6 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
      60:	8b 40 04             	mov    0x4(%eax),%eax
      63:	89 44 24 08          	mov    %eax,0x8(%esp)
      67:	c7 44 24 04 23 18 00 	movl   $0x1823,0x4(%esp)
      6e:	00 
      6f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      76:	e8 d3 13 00 00       	call   144e <printf>
    break;
      7b:	e9 86 01 00 00       	jmp    206 <runcmd+0x206>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      80:	8b 45 08             	mov    0x8(%ebp),%eax
      83:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      86:	8b 45 f0             	mov    -0x10(%ebp),%eax
      89:	8b 40 14             	mov    0x14(%eax),%eax
      8c:	89 04 24             	mov    %eax,(%esp)
      8f:	e8 22 12 00 00       	call   12b6 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      94:	8b 45 f0             	mov    -0x10(%ebp),%eax
      97:	8b 50 10             	mov    0x10(%eax),%edx
      9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
      9d:	8b 40 08             	mov    0x8(%eax),%eax
      a0:	89 54 24 04          	mov    %edx,0x4(%esp)
      a4:	89 04 24             	mov    %eax,(%esp)
      a7:	e8 22 12 00 00       	call   12ce <open>
      ac:	85 c0                	test   %eax,%eax
      ae:	79 23                	jns    d3 <runcmd+0xd3>
      printf(2, "open %s failed\n", rcmd->file);
      b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
      b3:	8b 40 08             	mov    0x8(%eax),%eax
      b6:	89 44 24 08          	mov    %eax,0x8(%esp)
      ba:	c7 44 24 04 33 18 00 	movl   $0x1833,0x4(%esp)
      c1:	00 
      c2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      c9:	e8 80 13 00 00       	call   144e <printf>
      exit();
      ce:	e8 bb 11 00 00       	call   128e <exit>
    }
    runcmd(rcmd->cmd);
      d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
      d6:	8b 40 04             	mov    0x4(%eax),%eax
      d9:	89 04 24             	mov    %eax,(%esp)
      dc:	e8 1f ff ff ff       	call   0 <runcmd>
    break;
      e1:	e9 20 01 00 00       	jmp    206 <runcmd+0x206>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      e6:	8b 45 08             	mov    0x8(%ebp),%eax
      e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
      ec:	e8 b9 05 00 00       	call   6aa <fork1>
      f1:	85 c0                	test   %eax,%eax
      f3:	75 0e                	jne    103 <runcmd+0x103>
      runcmd(lcmd->left);
      f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
      f8:	8b 40 04             	mov    0x4(%eax),%eax
      fb:	89 04 24             	mov    %eax,(%esp)
      fe:	e8 fd fe ff ff       	call   0 <runcmd>
    wait();
     103:	e8 8e 11 00 00       	call   1296 <wait>
    runcmd(lcmd->right);
     108:	8b 45 ec             	mov    -0x14(%ebp),%eax
     10b:	8b 40 08             	mov    0x8(%eax),%eax
     10e:	89 04 24             	mov    %eax,(%esp)
     111:	e8 ea fe ff ff       	call   0 <runcmd>
    break;
     116:	e9 eb 00 00 00       	jmp    206 <runcmd+0x206>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     11b:	8b 45 08             	mov    0x8(%ebp),%eax
     11e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     121:	8d 45 dc             	lea    -0x24(%ebp),%eax
     124:	89 04 24             	mov    %eax,(%esp)
     127:	e8 72 11 00 00       	call   129e <pipe>
     12c:	85 c0                	test   %eax,%eax
     12e:	79 0c                	jns    13c <runcmd+0x13c>
      panic("pipe");
     130:	c7 04 24 43 18 00 00 	movl   $0x1843,(%esp)
     137:	e8 48 05 00 00       	call   684 <panic>
    if(fork1() == 0){
     13c:	e8 69 05 00 00       	call   6aa <fork1>
     141:	85 c0                	test   %eax,%eax
     143:	75 3b                	jne    180 <runcmd+0x180>
      close(1);
     145:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     14c:	e8 65 11 00 00       	call   12b6 <close>
      dup(p[1]);
     151:	8b 45 e0             	mov    -0x20(%ebp),%eax
     154:	89 04 24             	mov    %eax,(%esp)
     157:	e8 aa 11 00 00       	call   1306 <dup>
      close(p[0]);
     15c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     15f:	89 04 24             	mov    %eax,(%esp)
     162:	e8 4f 11 00 00       	call   12b6 <close>
      close(p[1]);
     167:	8b 45 e0             	mov    -0x20(%ebp),%eax
     16a:	89 04 24             	mov    %eax,(%esp)
     16d:	e8 44 11 00 00       	call   12b6 <close>
      runcmd(pcmd->left);
     172:	8b 45 e8             	mov    -0x18(%ebp),%eax
     175:	8b 40 04             	mov    0x4(%eax),%eax
     178:	89 04 24             	mov    %eax,(%esp)
     17b:	e8 80 fe ff ff       	call   0 <runcmd>
    }
    if(fork1() == 0){
     180:	e8 25 05 00 00       	call   6aa <fork1>
     185:	85 c0                	test   %eax,%eax
     187:	75 3b                	jne    1c4 <runcmd+0x1c4>
      close(0);
     189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     190:	e8 21 11 00 00       	call   12b6 <close>
      dup(p[0]);
     195:	8b 45 dc             	mov    -0x24(%ebp),%eax
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 66 11 00 00       	call   1306 <dup>
      close(p[0]);
     1a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1a3:	89 04 24             	mov    %eax,(%esp)
     1a6:	e8 0b 11 00 00       	call   12b6 <close>
      close(p[1]);
     1ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1ae:	89 04 24             	mov    %eax,(%esp)
     1b1:	e8 00 11 00 00       	call   12b6 <close>
      runcmd(pcmd->right);
     1b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1b9:	8b 40 08             	mov    0x8(%eax),%eax
     1bc:	89 04 24             	mov    %eax,(%esp)
     1bf:	e8 3c fe ff ff       	call   0 <runcmd>
    }
    close(p[0]);
     1c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1c7:	89 04 24             	mov    %eax,(%esp)
     1ca:	e8 e7 10 00 00       	call   12b6 <close>
    close(p[1]);
     1cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1d2:	89 04 24             	mov    %eax,(%esp)
     1d5:	e8 dc 10 00 00       	call   12b6 <close>
    wait();
     1da:	e8 b7 10 00 00       	call   1296 <wait>
    wait();
     1df:	e8 b2 10 00 00       	call   1296 <wait>
    break;
     1e4:	eb 20                	jmp    206 <runcmd+0x206>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     1e6:	8b 45 08             	mov    0x8(%ebp),%eax
     1e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     1ec:	e8 b9 04 00 00       	call   6aa <fork1>
     1f1:	85 c0                	test   %eax,%eax
     1f3:	75 10                	jne    205 <runcmd+0x205>
      runcmd(bcmd->cmd);
     1f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     1f8:	8b 40 04             	mov    0x4(%eax),%eax
     1fb:	89 04 24             	mov    %eax,(%esp)
     1fe:	e8 fd fd ff ff       	call   0 <runcmd>
    break;
     203:	eb 00                	jmp    205 <runcmd+0x205>
     205:	90                   	nop
  }
  exit();
     206:	e8 83 10 00 00       	call   128e <exit>

0000020b <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     20b:	55                   	push   %ebp
     20c:	89 e5                	mov    %esp,%ebp
     20e:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     211:	c7 44 24 04 60 18 00 	movl   $0x1860,0x4(%esp)
     218:	00 
     219:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     220:	e8 29 12 00 00       	call   144e <printf>
  memset(buf, 0, nbuf);
     225:	8b 45 0c             	mov    0xc(%ebp),%eax
     228:	89 44 24 08          	mov    %eax,0x8(%esp)
     22c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     233:	00 
     234:	8b 45 08             	mov    0x8(%ebp),%eax
     237:	89 04 24             	mov    %eax,(%esp)
     23a:	e8 a2 0e 00 00       	call   10e1 <memset>
  gets(buf, nbuf);
     23f:	8b 45 0c             	mov    0xc(%ebp),%eax
     242:	89 44 24 04          	mov    %eax,0x4(%esp)
     246:	8b 45 08             	mov    0x8(%ebp),%eax
     249:	89 04 24             	mov    %eax,(%esp)
     24c:	e8 e7 0e 00 00       	call   1138 <gets>
  if(buf[0] == 0) // EOF
     251:	8b 45 08             	mov    0x8(%ebp),%eax
     254:	0f b6 00             	movzbl (%eax),%eax
     257:	84 c0                	test   %al,%al
     259:	75 07                	jne    262 <getcmd+0x57>
    return -1;
     25b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     260:	eb 05                	jmp    267 <getcmd+0x5c>
  return 0;
     262:	b8 00 00 00 00       	mov    $0x0,%eax
}
     267:	c9                   	leave  
     268:	c3                   	ret    

00000269 <strncmp>:

// ***** processing for shell builtins begins here *****

int
strncmp(const char *p, const char *q, uint n)
{
     269:	55                   	push   %ebp
     26a:	89 e5                	mov    %esp,%ebp
    while(n > 0 && *p && *p == *q)
     26c:	eb 0c                	jmp    27a <strncmp+0x11>
      n--, p++, q++;
     26e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
     272:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     276:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
// ***** processing for shell builtins begins here *****

int
strncmp(const char *p, const char *q, uint n)
{
    while(n > 0 && *p && *p == *q)
     27a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     27e:	74 1a                	je     29a <strncmp+0x31>
     280:	8b 45 08             	mov    0x8(%ebp),%eax
     283:	0f b6 00             	movzbl (%eax),%eax
     286:	84 c0                	test   %al,%al
     288:	74 10                	je     29a <strncmp+0x31>
     28a:	8b 45 08             	mov    0x8(%ebp),%eax
     28d:	0f b6 10             	movzbl (%eax),%edx
     290:	8b 45 0c             	mov    0xc(%ebp),%eax
     293:	0f b6 00             	movzbl (%eax),%eax
     296:	38 c2                	cmp    %al,%dl
     298:	74 d4                	je     26e <strncmp+0x5>
      n--, p++, q++;
    if(n == 0)
     29a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     29e:	75 07                	jne    2a7 <strncmp+0x3e>
      return 0;
     2a0:	b8 00 00 00 00       	mov    $0x0,%eax
     2a5:	eb 16                	jmp    2bd <strncmp+0x54>
    return (uchar)*p - (uchar)*q;
     2a7:	8b 45 08             	mov    0x8(%ebp),%eax
     2aa:	0f b6 00             	movzbl (%eax),%eax
     2ad:	0f b6 d0             	movzbl %al,%edx
     2b0:	8b 45 0c             	mov    0xc(%ebp),%eax
     2b3:	0f b6 00             	movzbl (%eax),%eax
     2b6:	0f b6 c0             	movzbl %al,%eax
     2b9:	29 c2                	sub    %eax,%edx
     2bb:	89 d0                	mov    %edx,%eax
}
     2bd:	5d                   	pop    %ebp
     2be:	c3                   	ret    

000002bf <makeint>:

int
makeint(char *p)
{
     2bf:	55                   	push   %ebp
     2c0:	89 e5                	mov    %esp,%ebp
     2c2:	83 ec 10             	sub    $0x10,%esp
  int val = 0;
     2c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

  while ((*p >= '0') && (*p <= '9')) {
     2cc:	eb 23                	jmp    2f1 <makeint+0x32>
    val = 10*val + (*p-'0');
     2ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
     2d1:	89 d0                	mov    %edx,%eax
     2d3:	c1 e0 02             	shl    $0x2,%eax
     2d6:	01 d0                	add    %edx,%eax
     2d8:	01 c0                	add    %eax,%eax
     2da:	89 c2                	mov    %eax,%edx
     2dc:	8b 45 08             	mov    0x8(%ebp),%eax
     2df:	0f b6 00             	movzbl (%eax),%eax
     2e2:	0f be c0             	movsbl %al,%eax
     2e5:	83 e8 30             	sub    $0x30,%eax
     2e8:	01 d0                	add    %edx,%eax
     2ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
    ++p;
     2ed:	83 45 08 01          	addl   $0x1,0x8(%ebp)
int
makeint(char *p)
{
  int val = 0;

  while ((*p >= '0') && (*p <= '9')) {
     2f1:	8b 45 08             	mov    0x8(%ebp),%eax
     2f4:	0f b6 00             	movzbl (%eax),%eax
     2f7:	3c 2f                	cmp    $0x2f,%al
     2f9:	7e 0a                	jle    305 <makeint+0x46>
     2fb:	8b 45 08             	mov    0x8(%ebp),%eax
     2fe:	0f b6 00             	movzbl (%eax),%eax
     301:	3c 39                	cmp    $0x39,%al
     303:	7e c9                	jle    2ce <makeint+0xf>
    val = 10*val + (*p-'0');
    ++p;
  }
  return val;
     305:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     308:	c9                   	leave  
     309:	c3                   	ret    

0000030a <setbuiltin>:

int
setbuiltin(char *p)
{
     30a:	55                   	push   %ebp
     30b:	89 e5                	mov    %esp,%ebp
     30d:	83 ec 28             	sub    $0x28,%esp
  int i;

  p += strlen("_set");
     310:	c7 04 24 63 18 00 00 	movl   $0x1863,(%esp)
     317:	e8 9e 0d 00 00       	call   10ba <strlen>
     31c:	01 45 08             	add    %eax,0x8(%ebp)
  while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
     31f:	eb 04                	jmp    325 <setbuiltin+0x1b>
     321:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     325:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     32c:	00 
     32d:	c7 44 24 04 68 18 00 	movl   $0x1868,0x4(%esp)
     334:	00 
     335:	8b 45 08             	mov    0x8(%ebp),%eax
     338:	89 04 24             	mov    %eax,(%esp)
     33b:	e8 29 ff ff ff       	call   269 <strncmp>
     340:	85 c0                	test   %eax,%eax
     342:	74 dd                	je     321 <setbuiltin+0x17>
  if (strncmp("uid", p, 3) == 0) {
     344:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
     34b:	00 
     34c:	8b 45 08             	mov    0x8(%ebp),%eax
     34f:	89 44 24 04          	mov    %eax,0x4(%esp)
     353:	c7 04 24 6a 18 00 00 	movl   $0x186a,(%esp)
     35a:	e8 0a ff ff ff       	call   269 <strncmp>
     35f:	85 c0                	test   %eax,%eax
     361:	75 52                	jne    3b5 <setbuiltin+0xab>
    p += strlen("uid");
     363:	c7 04 24 6a 18 00 00 	movl   $0x186a,(%esp)
     36a:	e8 4b 0d 00 00       	call   10ba <strlen>
     36f:	01 45 08             	add    %eax,0x8(%ebp)
    while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
     372:	eb 04                	jmp    378 <setbuiltin+0x6e>
     374:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     378:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     37f:	00 
     380:	c7 44 24 04 68 18 00 	movl   $0x1868,0x4(%esp)
     387:	00 
     388:	8b 45 08             	mov    0x8(%ebp),%eax
     38b:	89 04 24             	mov    %eax,(%esp)
     38e:	e8 d6 fe ff ff       	call   269 <strncmp>
     393:	85 c0                	test   %eax,%eax
     395:	74 dd                	je     374 <setbuiltin+0x6a>
    i = makeint(p); // ugly
     397:	8b 45 08             	mov    0x8(%ebp),%eax
     39a:	89 04 24             	mov    %eax,(%esp)
     39d:	e8 1d ff ff ff       	call   2bf <makeint>
     3a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return (setuid(i));
     3a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3a8:	89 04 24             	mov    %eax,(%esp)
     3ab:	e8 a6 0f 00 00       	call   1356 <setuid>
     3b0:	e9 87 00 00 00       	jmp    43c <setbuiltin+0x132>
  } else 
  if (strncmp("gid", p, 3) == 0) {
     3b5:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
     3bc:	00 
     3bd:	8b 45 08             	mov    0x8(%ebp),%eax
     3c0:	89 44 24 04          	mov    %eax,0x4(%esp)
     3c4:	c7 04 24 6e 18 00 00 	movl   $0x186e,(%esp)
     3cb:	e8 99 fe ff ff       	call   269 <strncmp>
     3d0:	85 c0                	test   %eax,%eax
     3d2:	75 4f                	jne    423 <setbuiltin+0x119>
    p += strlen("gid");
     3d4:	c7 04 24 6e 18 00 00 	movl   $0x186e,(%esp)
     3db:	e8 da 0c 00 00       	call   10ba <strlen>
     3e0:	01 45 08             	add    %eax,0x8(%ebp)
    while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
     3e3:	eb 04                	jmp    3e9 <setbuiltin+0xdf>
     3e5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     3e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     3f0:	00 
     3f1:	c7 44 24 04 68 18 00 	movl   $0x1868,0x4(%esp)
     3f8:	00 
     3f9:	8b 45 08             	mov    0x8(%ebp),%eax
     3fc:	89 04 24             	mov    %eax,(%esp)
     3ff:	e8 65 fe ff ff       	call   269 <strncmp>
     404:	85 c0                	test   %eax,%eax
     406:	74 dd                	je     3e5 <setbuiltin+0xdb>
    i = makeint(p); // ugly
     408:	8b 45 08             	mov    0x8(%ebp),%eax
     40b:	89 04 24             	mov    %eax,(%esp)
     40e:	e8 ac fe ff ff       	call   2bf <makeint>
     413:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return (setgid(i));
     416:	8b 45 f4             	mov    -0xc(%ebp),%eax
     419:	89 04 24             	mov    %eax,(%esp)
     41c:	e8 3d 0f 00 00       	call   135e <setgid>
     421:	eb 19                	jmp    43c <setbuiltin+0x132>
  }
  printf(2, "Invalid _set parameter\n");
     423:	c7 44 24 04 72 18 00 	movl   $0x1872,0x4(%esp)
     42a:	00 
     42b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     432:	e8 17 10 00 00       	call   144e <printf>
  return -1;
     437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
     43c:	c9                   	leave  
     43d:	c3                   	ret    

0000043e <getbuiltin>:

int
getbuiltin(char *p)
{
     43e:	55                   	push   %ebp
     43f:	89 e5                	mov    %esp,%ebp
     441:	83 ec 18             	sub    $0x18,%esp
  p += strlen("_get");
     444:	c7 04 24 8a 18 00 00 	movl   $0x188a,(%esp)
     44b:	e8 6a 0c 00 00       	call   10ba <strlen>
     450:	01 45 08             	add    %eax,0x8(%ebp)
  while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
     453:	eb 04                	jmp    459 <getbuiltin+0x1b>
     455:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     459:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     460:	00 
     461:	c7 44 24 04 68 18 00 	movl   $0x1868,0x4(%esp)
     468:	00 
     469:	8b 45 08             	mov    0x8(%ebp),%eax
     46c:	89 04 24             	mov    %eax,(%esp)
     46f:	e8 f5 fd ff ff       	call   269 <strncmp>
     474:	85 c0                	test   %eax,%eax
     476:	74 dd                	je     455 <getbuiltin+0x17>
  if (strncmp("uid", p, 3) == 0) {
     478:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
     47f:	00 
     480:	8b 45 08             	mov    0x8(%ebp),%eax
     483:	89 44 24 04          	mov    %eax,0x4(%esp)
     487:	c7 04 24 6a 18 00 00 	movl   $0x186a,(%esp)
     48e:	e8 d6 fd ff ff       	call   269 <strncmp>
     493:	85 c0                	test   %eax,%eax
     495:	75 24                	jne    4bb <getbuiltin+0x7d>
    printf(2, "%d\n", getuid());
     497:	e8 a2 0e 00 00       	call   133e <getuid>
     49c:	89 44 24 08          	mov    %eax,0x8(%esp)
     4a0:	c7 44 24 04 8f 18 00 	movl   $0x188f,0x4(%esp)
     4a7:	00 
     4a8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     4af:	e8 9a 0f 00 00       	call   144e <printf>
    return 0;
     4b4:	b8 00 00 00 00       	mov    $0x0,%eax
     4b9:	eb 5c                	jmp    517 <getbuiltin+0xd9>
  }
  if (strncmp("gid", p, 3) == 0) {
     4bb:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
     4c2:	00 
     4c3:	8b 45 08             	mov    0x8(%ebp),%eax
     4c6:	89 44 24 04          	mov    %eax,0x4(%esp)
     4ca:	c7 04 24 6e 18 00 00 	movl   $0x186e,(%esp)
     4d1:	e8 93 fd ff ff       	call   269 <strncmp>
     4d6:	85 c0                	test   %eax,%eax
     4d8:	75 24                	jne    4fe <getbuiltin+0xc0>
    printf(2, "%d\n", getgid());
     4da:	e8 67 0e 00 00       	call   1346 <getgid>
     4df:	89 44 24 08          	mov    %eax,0x8(%esp)
     4e3:	c7 44 24 04 8f 18 00 	movl   $0x188f,0x4(%esp)
     4ea:	00 
     4eb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     4f2:	e8 57 0f 00 00       	call   144e <printf>
    return 0;
     4f7:	b8 00 00 00 00       	mov    $0x0,%eax
     4fc:	eb 19                	jmp    517 <getbuiltin+0xd9>
  }
  printf(2, "Invalid _get parameter\n");
     4fe:	c7 44 24 04 93 18 00 	movl   $0x1893,0x4(%esp)
     505:	00 
     506:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     50d:	e8 3c 0f 00 00       	call   144e <printf>
  return -1;
     512:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
     517:	c9                   	leave  
     518:	c3                   	ret    

00000519 <dobuiltin>:
  {"_get", getbuiltin}
};
int FDTcount = sizeof(fdt) / sizeof(fdt[0]); // # entris in FDT

void
dobuiltin(char *cmd) {
     519:	55                   	push   %ebp
     51a:	89 e5                	mov    %esp,%ebp
     51c:	83 ec 28             	sub    $0x28,%esp
  int i;

  for (i=0; i<FDTcount; i++) 
     51f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     526:	eb 49                	jmp    571 <dobuiltin+0x58>
    if (strncmp(cmd, fdt[i].cmd, strlen(fdt[i].cmd)) == 0) 
     528:	8b 45 f4             	mov    -0xc(%ebp),%eax
     52b:	8b 04 c5 7c 1e 00 00 	mov    0x1e7c(,%eax,8),%eax
     532:	89 04 24             	mov    %eax,(%esp)
     535:	e8 80 0b 00 00       	call   10ba <strlen>
     53a:	8b 55 f4             	mov    -0xc(%ebp),%edx
     53d:	8b 14 d5 7c 1e 00 00 	mov    0x1e7c(,%edx,8),%edx
     544:	89 44 24 08          	mov    %eax,0x8(%esp)
     548:	89 54 24 04          	mov    %edx,0x4(%esp)
     54c:	8b 45 08             	mov    0x8(%ebp),%eax
     54f:	89 04 24             	mov    %eax,(%esp)
     552:	e8 12 fd ff ff       	call   269 <strncmp>
     557:	85 c0                	test   %eax,%eax
     559:	75 12                	jne    56d <dobuiltin+0x54>
     (*fdt[i].name)(cmd);
     55b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     55e:	8b 04 c5 80 1e 00 00 	mov    0x1e80(,%eax,8),%eax
     565:	8b 55 08             	mov    0x8(%ebp),%edx
     568:	89 14 24             	mov    %edx,(%esp)
     56b:	ff d0                	call   *%eax

void
dobuiltin(char *cmd) {
  int i;

  for (i=0; i<FDTcount; i++) 
     56d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     571:	a1 8c 1e 00 00       	mov    0x1e8c,%eax
     576:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     579:	7c ad                	jl     528 <dobuiltin+0xf>
    if (strncmp(cmd, fdt[i].cmd, strlen(fdt[i].cmd)) == 0) 
     (*fdt[i].name)(cmd);
}
     57b:	c9                   	leave  
     57c:	c3                   	ret    

0000057d <main>:

// ***** processing for shell builtins ends here *****

int
main(void)
{
     57d:	55                   	push   %ebp
     57e:	89 e5                	mov    %esp,%ebp
     580:	83 e4 f0             	and    $0xfffffff0,%esp
     583:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     586:	eb 15                	jmp    59d <main+0x20>
    if(fd >= 3){
     588:	83 7c 24 1c 02       	cmpl   $0x2,0x1c(%esp)
     58d:	7e 0e                	jle    59d <main+0x20>
      close(fd);
     58f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     593:	89 04 24             	mov    %eax,(%esp)
     596:	e8 1b 0d 00 00       	call   12b6 <close>
      break;
     59b:	eb 1f                	jmp    5bc <main+0x3f>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     59d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     5a4:	00 
     5a5:	c7 04 24 ab 18 00 00 	movl   $0x18ab,(%esp)
     5ac:	e8 1d 0d 00 00       	call   12ce <open>
     5b1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     5b5:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     5ba:	79 cc                	jns    588 <main+0xb>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     5bc:	e9 a2 00 00 00       	jmp    663 <main+0xe6>
// add support for built-ins here. cd is a built-in
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     5c1:	0f b6 05 c0 1e 00 00 	movzbl 0x1ec0,%eax
     5c8:	3c 63                	cmp    $0x63,%al
     5ca:	75 5c                	jne    628 <main+0xab>
     5cc:	0f b6 05 c1 1e 00 00 	movzbl 0x1ec1,%eax
     5d3:	3c 64                	cmp    $0x64,%al
     5d5:	75 51                	jne    628 <main+0xab>
     5d7:	0f b6 05 c2 1e 00 00 	movzbl 0x1ec2,%eax
     5de:	3c 20                	cmp    $0x20,%al
     5e0:	75 46                	jne    628 <main+0xab>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     5e2:	c7 04 24 c0 1e 00 00 	movl   $0x1ec0,(%esp)
     5e9:	e8 cc 0a 00 00       	call   10ba <strlen>
     5ee:	83 e8 01             	sub    $0x1,%eax
     5f1:	c6 80 c0 1e 00 00 00 	movb   $0x0,0x1ec0(%eax)
      if(chdir(buf+3) < 0)
     5f8:	c7 04 24 c3 1e 00 00 	movl   $0x1ec3,(%esp)
     5ff:	e8 fa 0c 00 00       	call   12fe <chdir>
     604:	85 c0                	test   %eax,%eax
     606:	79 1e                	jns    626 <main+0xa9>
        printf(2, "cannot cd %s\n", buf+3);
     608:	c7 44 24 08 c3 1e 00 	movl   $0x1ec3,0x8(%esp)
     60f:	00 
     610:	c7 44 24 04 b3 18 00 	movl   $0x18b3,0x4(%esp)
     617:	00 
     618:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     61f:	e8 2a 0e 00 00       	call   144e <printf>
      continue;
     624:	eb 3d                	jmp    663 <main+0xe6>
     626:	eb 3b                	jmp    663 <main+0xe6>
    }
    if (buf[0]=='_') {     // assume it is a builtin command
     628:	0f b6 05 c0 1e 00 00 	movzbl 0x1ec0,%eax
     62f:	3c 5f                	cmp    $0x5f,%al
     631:	75 0e                	jne    641 <main+0xc4>
      dobuiltin(buf);
     633:	c7 04 24 c0 1e 00 00 	movl   $0x1ec0,(%esp)
     63a:	e8 da fe ff ff       	call   519 <dobuiltin>
      continue;
     63f:	eb 22                	jmp    663 <main+0xe6>
    }
    if(fork1() == 0)
     641:	e8 64 00 00 00       	call   6aa <fork1>
     646:	85 c0                	test   %eax,%eax
     648:	75 14                	jne    65e <main+0xe1>
      runcmd(parsecmd(buf));
     64a:	c7 04 24 c0 1e 00 00 	movl   $0x1ec0,(%esp)
     651:	e8 c9 03 00 00       	call   a1f <parsecmd>
     656:	89 04 24             	mov    %eax,(%esp)
     659:	e8 a2 f9 ff ff       	call   0 <runcmd>
    wait();
     65e:	e8 33 0c 00 00       	call   1296 <wait>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     663:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     66a:	00 
     66b:	c7 04 24 c0 1e 00 00 	movl   $0x1ec0,(%esp)
     672:	e8 94 fb ff ff       	call   20b <getcmd>
     677:	85 c0                	test   %eax,%eax
     679:	0f 89 42 ff ff ff    	jns    5c1 <main+0x44>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
     67f:	e8 0a 0c 00 00       	call   128e <exit>

00000684 <panic>:
}

void
panic(char *s)
{
     684:	55                   	push   %ebp
     685:	89 e5                	mov    %esp,%ebp
     687:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     68a:	8b 45 08             	mov    0x8(%ebp),%eax
     68d:	89 44 24 08          	mov    %eax,0x8(%esp)
     691:	c7 44 24 04 c1 18 00 	movl   $0x18c1,0x4(%esp)
     698:	00 
     699:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     6a0:	e8 a9 0d 00 00       	call   144e <printf>
  exit();
     6a5:	e8 e4 0b 00 00       	call   128e <exit>

000006aa <fork1>:
}

int
fork1(void)
{
     6aa:	55                   	push   %ebp
     6ab:	89 e5                	mov    %esp,%ebp
     6ad:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     6b0:	e8 d1 0b 00 00       	call   1286 <fork>
     6b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     6b8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     6bc:	75 0c                	jne    6ca <fork1+0x20>
    panic("fork");
     6be:	c7 04 24 c5 18 00 00 	movl   $0x18c5,(%esp)
     6c5:	e8 ba ff ff ff       	call   684 <panic>
  return pid;
     6ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     6cd:	c9                   	leave  
     6ce:	c3                   	ret    

000006cf <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     6cf:	55                   	push   %ebp
     6d0:	89 e5                	mov    %esp,%ebp
     6d2:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     6d5:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     6dc:	e8 59 10 00 00       	call   173a <malloc>
     6e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     6e4:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     6eb:	00 
     6ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     6f3:	00 
     6f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6f7:	89 04 24             	mov    %eax,(%esp)
     6fa:	e8 e2 09 00 00       	call   10e1 <memset>
  cmd->type = EXEC;
     6ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
     702:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     708:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     70b:	c9                   	leave  
     70c:	c3                   	ret    

0000070d <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     70d:	55                   	push   %ebp
     70e:	89 e5                	mov    %esp,%ebp
     710:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     713:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     71a:	e8 1b 10 00 00       	call   173a <malloc>
     71f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     722:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     729:	00 
     72a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     731:	00 
     732:	8b 45 f4             	mov    -0xc(%ebp),%eax
     735:	89 04 24             	mov    %eax,(%esp)
     738:	e8 a4 09 00 00       	call   10e1 <memset>
  cmd->type = REDIR;
     73d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     740:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     746:	8b 45 f4             	mov    -0xc(%ebp),%eax
     749:	8b 55 08             	mov    0x8(%ebp),%edx
     74c:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     74f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     752:	8b 55 0c             	mov    0xc(%ebp),%edx
     755:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     758:	8b 45 f4             	mov    -0xc(%ebp),%eax
     75b:	8b 55 10             	mov    0x10(%ebp),%edx
     75e:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     761:	8b 45 f4             	mov    -0xc(%ebp),%eax
     764:	8b 55 14             	mov    0x14(%ebp),%edx
     767:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     76a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     76d:	8b 55 18             	mov    0x18(%ebp),%edx
     770:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     773:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     776:	c9                   	leave  
     777:	c3                   	ret    

00000778 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     778:	55                   	push   %ebp
     779:	89 e5                	mov    %esp,%ebp
     77b:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     77e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     785:	e8 b0 0f 00 00       	call   173a <malloc>
     78a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     78d:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     794:	00 
     795:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     79c:	00 
     79d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7a0:	89 04 24             	mov    %eax,(%esp)
     7a3:	e8 39 09 00 00       	call   10e1 <memset>
  cmd->type = PIPE;
     7a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7ab:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7b4:	8b 55 08             	mov    0x8(%ebp),%edx
     7b7:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     7ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7bd:	8b 55 0c             	mov    0xc(%ebp),%edx
     7c0:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     7c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     7c6:	c9                   	leave  
     7c7:	c3                   	ret    

000007c8 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     7c8:	55                   	push   %ebp
     7c9:	89 e5                	mov    %esp,%ebp
     7cb:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     7ce:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     7d5:	e8 60 0f 00 00       	call   173a <malloc>
     7da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     7dd:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     7e4:	00 
     7e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     7ec:	00 
     7ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7f0:	89 04 24             	mov    %eax,(%esp)
     7f3:	e8 e9 08 00 00       	call   10e1 <memset>
  cmd->type = LIST;
     7f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7fb:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     801:	8b 45 f4             	mov    -0xc(%ebp),%eax
     804:	8b 55 08             	mov    0x8(%ebp),%edx
     807:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     80a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     80d:	8b 55 0c             	mov    0xc(%ebp),%edx
     810:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     813:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     816:	c9                   	leave  
     817:	c3                   	ret    

00000818 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     818:	55                   	push   %ebp
     819:	89 e5                	mov    %esp,%ebp
     81b:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     81e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     825:	e8 10 0f 00 00       	call   173a <malloc>
     82a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     82d:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     834:	00 
     835:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     83c:	00 
     83d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     840:	89 04 24             	mov    %eax,(%esp)
     843:	e8 99 08 00 00       	call   10e1 <memset>
  cmd->type = BACK;
     848:	8b 45 f4             	mov    -0xc(%ebp),%eax
     84b:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     851:	8b 45 f4             	mov    -0xc(%ebp),%eax
     854:	8b 55 08             	mov    0x8(%ebp),%edx
     857:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     85a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     85d:	c9                   	leave  
     85e:	c3                   	ret    

0000085f <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     85f:	55                   	push   %ebp
     860:	89 e5                	mov    %esp,%ebp
     862:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     865:	8b 45 08             	mov    0x8(%ebp),%eax
     868:	8b 00                	mov    (%eax),%eax
     86a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     86d:	eb 04                	jmp    873 <gettoken+0x14>
    s++;
     86f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     873:	8b 45 f4             	mov    -0xc(%ebp),%eax
     876:	3b 45 0c             	cmp    0xc(%ebp),%eax
     879:	73 1d                	jae    898 <gettoken+0x39>
     87b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     87e:	0f b6 00             	movzbl (%eax),%eax
     881:	0f be c0             	movsbl %al,%eax
     884:	89 44 24 04          	mov    %eax,0x4(%esp)
     888:	c7 04 24 90 1e 00 00 	movl   $0x1e90,(%esp)
     88f:	e8 71 08 00 00       	call   1105 <strchr>
     894:	85 c0                	test   %eax,%eax
     896:	75 d7                	jne    86f <gettoken+0x10>
    s++;
  if(q)
     898:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     89c:	74 08                	je     8a6 <gettoken+0x47>
    *q = s;
     89e:	8b 45 10             	mov    0x10(%ebp),%eax
     8a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
     8a4:	89 10                	mov    %edx,(%eax)
  ret = *s;
     8a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8a9:	0f b6 00             	movzbl (%eax),%eax
     8ac:	0f be c0             	movsbl %al,%eax
     8af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     8b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8b5:	0f b6 00             	movzbl (%eax),%eax
     8b8:	0f be c0             	movsbl %al,%eax
     8bb:	83 f8 29             	cmp    $0x29,%eax
     8be:	7f 14                	jg     8d4 <gettoken+0x75>
     8c0:	83 f8 28             	cmp    $0x28,%eax
     8c3:	7d 28                	jge    8ed <gettoken+0x8e>
     8c5:	85 c0                	test   %eax,%eax
     8c7:	0f 84 94 00 00 00    	je     961 <gettoken+0x102>
     8cd:	83 f8 26             	cmp    $0x26,%eax
     8d0:	74 1b                	je     8ed <gettoken+0x8e>
     8d2:	eb 3c                	jmp    910 <gettoken+0xb1>
     8d4:	83 f8 3e             	cmp    $0x3e,%eax
     8d7:	74 1a                	je     8f3 <gettoken+0x94>
     8d9:	83 f8 3e             	cmp    $0x3e,%eax
     8dc:	7f 0a                	jg     8e8 <gettoken+0x89>
     8de:	83 e8 3b             	sub    $0x3b,%eax
     8e1:	83 f8 01             	cmp    $0x1,%eax
     8e4:	77 2a                	ja     910 <gettoken+0xb1>
     8e6:	eb 05                	jmp    8ed <gettoken+0x8e>
     8e8:	83 f8 7c             	cmp    $0x7c,%eax
     8eb:	75 23                	jne    910 <gettoken+0xb1>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     8ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     8f1:	eb 6f                	jmp    962 <gettoken+0x103>
  case '>':
    s++;
     8f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     8f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8fa:	0f b6 00             	movzbl (%eax),%eax
     8fd:	3c 3e                	cmp    $0x3e,%al
     8ff:	75 0d                	jne    90e <gettoken+0xaf>
      ret = '+';
     901:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     908:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     90c:	eb 54                	jmp    962 <gettoken+0x103>
     90e:	eb 52                	jmp    962 <gettoken+0x103>
  default:
    ret = 'a';
     910:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     917:	eb 04                	jmp    91d <gettoken+0xbe>
      s++;
     919:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     91d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     920:	3b 45 0c             	cmp    0xc(%ebp),%eax
     923:	73 3a                	jae    95f <gettoken+0x100>
     925:	8b 45 f4             	mov    -0xc(%ebp),%eax
     928:	0f b6 00             	movzbl (%eax),%eax
     92b:	0f be c0             	movsbl %al,%eax
     92e:	89 44 24 04          	mov    %eax,0x4(%esp)
     932:	c7 04 24 90 1e 00 00 	movl   $0x1e90,(%esp)
     939:	e8 c7 07 00 00       	call   1105 <strchr>
     93e:	85 c0                	test   %eax,%eax
     940:	75 1d                	jne    95f <gettoken+0x100>
     942:	8b 45 f4             	mov    -0xc(%ebp),%eax
     945:	0f b6 00             	movzbl (%eax),%eax
     948:	0f be c0             	movsbl %al,%eax
     94b:	89 44 24 04          	mov    %eax,0x4(%esp)
     94f:	c7 04 24 96 1e 00 00 	movl   $0x1e96,(%esp)
     956:	e8 aa 07 00 00       	call   1105 <strchr>
     95b:	85 c0                	test   %eax,%eax
     95d:	74 ba                	je     919 <gettoken+0xba>
      s++;
    break;
     95f:	eb 01                	jmp    962 <gettoken+0x103>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     961:	90                   	nop
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     962:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     966:	74 0a                	je     972 <gettoken+0x113>
    *eq = s;
     968:	8b 45 14             	mov    0x14(%ebp),%eax
     96b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     96e:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     970:	eb 06                	jmp    978 <gettoken+0x119>
     972:	eb 04                	jmp    978 <gettoken+0x119>
    s++;
     974:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     978:	8b 45 f4             	mov    -0xc(%ebp),%eax
     97b:	3b 45 0c             	cmp    0xc(%ebp),%eax
     97e:	73 1d                	jae    99d <gettoken+0x13e>
     980:	8b 45 f4             	mov    -0xc(%ebp),%eax
     983:	0f b6 00             	movzbl (%eax),%eax
     986:	0f be c0             	movsbl %al,%eax
     989:	89 44 24 04          	mov    %eax,0x4(%esp)
     98d:	c7 04 24 90 1e 00 00 	movl   $0x1e90,(%esp)
     994:	e8 6c 07 00 00       	call   1105 <strchr>
     999:	85 c0                	test   %eax,%eax
     99b:	75 d7                	jne    974 <gettoken+0x115>
    s++;
  *ps = s;
     99d:	8b 45 08             	mov    0x8(%ebp),%eax
     9a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
     9a3:	89 10                	mov    %edx,(%eax)
  return ret;
     9a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     9a8:	c9                   	leave  
     9a9:	c3                   	ret    

000009aa <peek>:

int
peek(char **ps, char *es, char *toks)
{
     9aa:	55                   	push   %ebp
     9ab:	89 e5                	mov    %esp,%ebp
     9ad:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     9b0:	8b 45 08             	mov    0x8(%ebp),%eax
     9b3:	8b 00                	mov    (%eax),%eax
     9b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     9b8:	eb 04                	jmp    9be <peek+0x14>
    s++;
     9ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     9be:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9c1:	3b 45 0c             	cmp    0xc(%ebp),%eax
     9c4:	73 1d                	jae    9e3 <peek+0x39>
     9c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9c9:	0f b6 00             	movzbl (%eax),%eax
     9cc:	0f be c0             	movsbl %al,%eax
     9cf:	89 44 24 04          	mov    %eax,0x4(%esp)
     9d3:	c7 04 24 90 1e 00 00 	movl   $0x1e90,(%esp)
     9da:	e8 26 07 00 00       	call   1105 <strchr>
     9df:	85 c0                	test   %eax,%eax
     9e1:	75 d7                	jne    9ba <peek+0x10>
    s++;
  *ps = s;
     9e3:	8b 45 08             	mov    0x8(%ebp),%eax
     9e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
     9e9:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     9eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9ee:	0f b6 00             	movzbl (%eax),%eax
     9f1:	84 c0                	test   %al,%al
     9f3:	74 23                	je     a18 <peek+0x6e>
     9f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9f8:	0f b6 00             	movzbl (%eax),%eax
     9fb:	0f be c0             	movsbl %al,%eax
     9fe:	89 44 24 04          	mov    %eax,0x4(%esp)
     a02:	8b 45 10             	mov    0x10(%ebp),%eax
     a05:	89 04 24             	mov    %eax,(%esp)
     a08:	e8 f8 06 00 00       	call   1105 <strchr>
     a0d:	85 c0                	test   %eax,%eax
     a0f:	74 07                	je     a18 <peek+0x6e>
     a11:	b8 01 00 00 00       	mov    $0x1,%eax
     a16:	eb 05                	jmp    a1d <peek+0x73>
     a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
     a1d:	c9                   	leave  
     a1e:	c3                   	ret    

00000a1f <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     a1f:	55                   	push   %ebp
     a20:	89 e5                	mov    %esp,%ebp
     a22:	53                   	push   %ebx
     a23:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     a26:	8b 5d 08             	mov    0x8(%ebp),%ebx
     a29:	8b 45 08             	mov    0x8(%ebp),%eax
     a2c:	89 04 24             	mov    %eax,(%esp)
     a2f:	e8 86 06 00 00       	call   10ba <strlen>
     a34:	01 d8                	add    %ebx,%eax
     a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
     a40:	8d 45 08             	lea    0x8(%ebp),%eax
     a43:	89 04 24             	mov    %eax,(%esp)
     a46:	e8 60 00 00 00       	call   aab <parseline>
     a4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     a4e:	c7 44 24 08 ca 18 00 	movl   $0x18ca,0x8(%esp)
     a55:	00 
     a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a59:	89 44 24 04          	mov    %eax,0x4(%esp)
     a5d:	8d 45 08             	lea    0x8(%ebp),%eax
     a60:	89 04 24             	mov    %eax,(%esp)
     a63:	e8 42 ff ff ff       	call   9aa <peek>
  if(s != es){
     a68:	8b 45 08             	mov    0x8(%ebp),%eax
     a6b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     a6e:	74 27                	je     a97 <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     a70:	8b 45 08             	mov    0x8(%ebp),%eax
     a73:	89 44 24 08          	mov    %eax,0x8(%esp)
     a77:	c7 44 24 04 cb 18 00 	movl   $0x18cb,0x4(%esp)
     a7e:	00 
     a7f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     a86:	e8 c3 09 00 00       	call   144e <printf>
    panic("syntax");
     a8b:	c7 04 24 da 18 00 00 	movl   $0x18da,(%esp)
     a92:	e8 ed fb ff ff       	call   684 <panic>
  }
  nulterminate(cmd);
     a97:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a9a:	89 04 24             	mov    %eax,(%esp)
     a9d:	e8 a3 04 00 00       	call   f45 <nulterminate>
  return cmd;
     aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     aa5:	83 c4 24             	add    $0x24,%esp
     aa8:	5b                   	pop    %ebx
     aa9:	5d                   	pop    %ebp
     aaa:	c3                   	ret    

00000aab <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     aab:	55                   	push   %ebp
     aac:	89 e5                	mov    %esp,%ebp
     aae:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
     ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
     ab8:	8b 45 08             	mov    0x8(%ebp),%eax
     abb:	89 04 24             	mov    %eax,(%esp)
     abe:	e8 bc 00 00 00       	call   b7f <parsepipe>
     ac3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     ac6:	eb 30                	jmp    af8 <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     ac8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     acf:	00 
     ad0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     ad7:	00 
     ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
     adb:	89 44 24 04          	mov    %eax,0x4(%esp)
     adf:	8b 45 08             	mov    0x8(%ebp),%eax
     ae2:	89 04 24             	mov    %eax,(%esp)
     ae5:	e8 75 fd ff ff       	call   85f <gettoken>
    cmd = backcmd(cmd);
     aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
     aed:	89 04 24             	mov    %eax,(%esp)
     af0:	e8 23 fd ff ff       	call   818 <backcmd>
     af5:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     af8:	c7 44 24 08 e1 18 00 	movl   $0x18e1,0x8(%esp)
     aff:	00 
     b00:	8b 45 0c             	mov    0xc(%ebp),%eax
     b03:	89 44 24 04          	mov    %eax,0x4(%esp)
     b07:	8b 45 08             	mov    0x8(%ebp),%eax
     b0a:	89 04 24             	mov    %eax,(%esp)
     b0d:	e8 98 fe ff ff       	call   9aa <peek>
     b12:	85 c0                	test   %eax,%eax
     b14:	75 b2                	jne    ac8 <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     b16:	c7 44 24 08 e3 18 00 	movl   $0x18e3,0x8(%esp)
     b1d:	00 
     b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
     b21:	89 44 24 04          	mov    %eax,0x4(%esp)
     b25:	8b 45 08             	mov    0x8(%ebp),%eax
     b28:	89 04 24             	mov    %eax,(%esp)
     b2b:	e8 7a fe ff ff       	call   9aa <peek>
     b30:	85 c0                	test   %eax,%eax
     b32:	74 46                	je     b7a <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     b34:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     b3b:	00 
     b3c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     b43:	00 
     b44:	8b 45 0c             	mov    0xc(%ebp),%eax
     b47:	89 44 24 04          	mov    %eax,0x4(%esp)
     b4b:	8b 45 08             	mov    0x8(%ebp),%eax
     b4e:	89 04 24             	mov    %eax,(%esp)
     b51:	e8 09 fd ff ff       	call   85f <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     b56:	8b 45 0c             	mov    0xc(%ebp),%eax
     b59:	89 44 24 04          	mov    %eax,0x4(%esp)
     b5d:	8b 45 08             	mov    0x8(%ebp),%eax
     b60:	89 04 24             	mov    %eax,(%esp)
     b63:	e8 43 ff ff ff       	call   aab <parseline>
     b68:	89 44 24 04          	mov    %eax,0x4(%esp)
     b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b6f:	89 04 24             	mov    %eax,(%esp)
     b72:	e8 51 fc ff ff       	call   7c8 <listcmd>
     b77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     b7d:	c9                   	leave  
     b7e:	c3                   	ret    

00000b7f <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     b7f:	55                   	push   %ebp
     b80:	89 e5                	mov    %esp,%ebp
     b82:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     b85:	8b 45 0c             	mov    0xc(%ebp),%eax
     b88:	89 44 24 04          	mov    %eax,0x4(%esp)
     b8c:	8b 45 08             	mov    0x8(%ebp),%eax
     b8f:	89 04 24             	mov    %eax,(%esp)
     b92:	e8 68 02 00 00       	call   dff <parseexec>
     b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     b9a:	c7 44 24 08 e5 18 00 	movl   $0x18e5,0x8(%esp)
     ba1:	00 
     ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
     ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
     ba9:	8b 45 08             	mov    0x8(%ebp),%eax
     bac:	89 04 24             	mov    %eax,(%esp)
     baf:	e8 f6 fd ff ff       	call   9aa <peek>
     bb4:	85 c0                	test   %eax,%eax
     bb6:	74 46                	je     bfe <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     bb8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     bbf:	00 
     bc0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     bc7:	00 
     bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
     bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
     bcf:	8b 45 08             	mov    0x8(%ebp),%eax
     bd2:	89 04 24             	mov    %eax,(%esp)
     bd5:	e8 85 fc ff ff       	call   85f <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     bda:	8b 45 0c             	mov    0xc(%ebp),%eax
     bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
     be1:	8b 45 08             	mov    0x8(%ebp),%eax
     be4:	89 04 24             	mov    %eax,(%esp)
     be7:	e8 93 ff ff ff       	call   b7f <parsepipe>
     bec:	89 44 24 04          	mov    %eax,0x4(%esp)
     bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     bf3:	89 04 24             	mov    %eax,(%esp)
     bf6:	e8 7d fb ff ff       	call   778 <pipecmd>
     bfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     c01:	c9                   	leave  
     c02:	c3                   	ret    

00000c03 <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     c03:	55                   	push   %ebp
     c04:	89 e5                	mov    %esp,%ebp
     c06:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     c09:	e9 f6 00 00 00       	jmp    d04 <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     c0e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     c15:	00 
     c16:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     c1d:	00 
     c1e:	8b 45 10             	mov    0x10(%ebp),%eax
     c21:	89 44 24 04          	mov    %eax,0x4(%esp)
     c25:	8b 45 0c             	mov    0xc(%ebp),%eax
     c28:	89 04 24             	mov    %eax,(%esp)
     c2b:	e8 2f fc ff ff       	call   85f <gettoken>
     c30:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     c33:	8d 45 ec             	lea    -0x14(%ebp),%eax
     c36:	89 44 24 0c          	mov    %eax,0xc(%esp)
     c3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
     c3d:	89 44 24 08          	mov    %eax,0x8(%esp)
     c41:	8b 45 10             	mov    0x10(%ebp),%eax
     c44:	89 44 24 04          	mov    %eax,0x4(%esp)
     c48:	8b 45 0c             	mov    0xc(%ebp),%eax
     c4b:	89 04 24             	mov    %eax,(%esp)
     c4e:	e8 0c fc ff ff       	call   85f <gettoken>
     c53:	83 f8 61             	cmp    $0x61,%eax
     c56:	74 0c                	je     c64 <parseredirs+0x61>
      panic("missing file for redirection");
     c58:	c7 04 24 e7 18 00 00 	movl   $0x18e7,(%esp)
     c5f:	e8 20 fa ff ff       	call   684 <panic>
    switch(tok){
     c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c67:	83 f8 3c             	cmp    $0x3c,%eax
     c6a:	74 0f                	je     c7b <parseredirs+0x78>
     c6c:	83 f8 3e             	cmp    $0x3e,%eax
     c6f:	74 38                	je     ca9 <parseredirs+0xa6>
     c71:	83 f8 2b             	cmp    $0x2b,%eax
     c74:	74 61                	je     cd7 <parseredirs+0xd4>
     c76:	e9 89 00 00 00       	jmp    d04 <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     c7b:	8b 55 ec             	mov    -0x14(%ebp),%edx
     c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c81:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     c88:	00 
     c89:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     c90:	00 
     c91:	89 54 24 08          	mov    %edx,0x8(%esp)
     c95:	89 44 24 04          	mov    %eax,0x4(%esp)
     c99:	8b 45 08             	mov    0x8(%ebp),%eax
     c9c:	89 04 24             	mov    %eax,(%esp)
     c9f:	e8 69 fa ff ff       	call   70d <redircmd>
     ca4:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     ca7:	eb 5b                	jmp    d04 <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     ca9:	8b 55 ec             	mov    -0x14(%ebp),%edx
     cac:	8b 45 f0             	mov    -0x10(%ebp),%eax
     caf:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     cb6:	00 
     cb7:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     cbe:	00 
     cbf:	89 54 24 08          	mov    %edx,0x8(%esp)
     cc3:	89 44 24 04          	mov    %eax,0x4(%esp)
     cc7:	8b 45 08             	mov    0x8(%ebp),%eax
     cca:	89 04 24             	mov    %eax,(%esp)
     ccd:	e8 3b fa ff ff       	call   70d <redircmd>
     cd2:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     cd5:	eb 2d                	jmp    d04 <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     cd7:	8b 55 ec             	mov    -0x14(%ebp),%edx
     cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
     cdd:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     ce4:	00 
     ce5:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     cec:	00 
     ced:	89 54 24 08          	mov    %edx,0x8(%esp)
     cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
     cf5:	8b 45 08             	mov    0x8(%ebp),%eax
     cf8:	89 04 24             	mov    %eax,(%esp)
     cfb:	e8 0d fa ff ff       	call   70d <redircmd>
     d00:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     d03:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     d04:	c7 44 24 08 04 19 00 	movl   $0x1904,0x8(%esp)
     d0b:	00 
     d0c:	8b 45 10             	mov    0x10(%ebp),%eax
     d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
     d13:	8b 45 0c             	mov    0xc(%ebp),%eax
     d16:	89 04 24             	mov    %eax,(%esp)
     d19:	e8 8c fc ff ff       	call   9aa <peek>
     d1e:	85 c0                	test   %eax,%eax
     d20:	0f 85 e8 fe ff ff    	jne    c0e <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     d26:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d29:	c9                   	leave  
     d2a:	c3                   	ret    

00000d2b <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     d2b:	55                   	push   %ebp
     d2c:	89 e5                	mov    %esp,%ebp
     d2e:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     d31:	c7 44 24 08 07 19 00 	movl   $0x1907,0x8(%esp)
     d38:	00 
     d39:	8b 45 0c             	mov    0xc(%ebp),%eax
     d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
     d40:	8b 45 08             	mov    0x8(%ebp),%eax
     d43:	89 04 24             	mov    %eax,(%esp)
     d46:	e8 5f fc ff ff       	call   9aa <peek>
     d4b:	85 c0                	test   %eax,%eax
     d4d:	75 0c                	jne    d5b <parseblock+0x30>
    panic("parseblock");
     d4f:	c7 04 24 09 19 00 00 	movl   $0x1909,(%esp)
     d56:	e8 29 f9 ff ff       	call   684 <panic>
  gettoken(ps, es, 0, 0);
     d5b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     d62:	00 
     d63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     d6a:	00 
     d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
     d6e:	89 44 24 04          	mov    %eax,0x4(%esp)
     d72:	8b 45 08             	mov    0x8(%ebp),%eax
     d75:	89 04 24             	mov    %eax,(%esp)
     d78:	e8 e2 fa ff ff       	call   85f <gettoken>
  cmd = parseline(ps, es);
     d7d:	8b 45 0c             	mov    0xc(%ebp),%eax
     d80:	89 44 24 04          	mov    %eax,0x4(%esp)
     d84:	8b 45 08             	mov    0x8(%ebp),%eax
     d87:	89 04 24             	mov    %eax,(%esp)
     d8a:	e8 1c fd ff ff       	call   aab <parseline>
     d8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     d92:	c7 44 24 08 14 19 00 	movl   $0x1914,0x8(%esp)
     d99:	00 
     d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
     d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
     da1:	8b 45 08             	mov    0x8(%ebp),%eax
     da4:	89 04 24             	mov    %eax,(%esp)
     da7:	e8 fe fb ff ff       	call   9aa <peek>
     dac:	85 c0                	test   %eax,%eax
     dae:	75 0c                	jne    dbc <parseblock+0x91>
    panic("syntax - missing )");
     db0:	c7 04 24 16 19 00 00 	movl   $0x1916,(%esp)
     db7:	e8 c8 f8 ff ff       	call   684 <panic>
  gettoken(ps, es, 0, 0);
     dbc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     dc3:	00 
     dc4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     dcb:	00 
     dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
     dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
     dd3:	8b 45 08             	mov    0x8(%ebp),%eax
     dd6:	89 04 24             	mov    %eax,(%esp)
     dd9:	e8 81 fa ff ff       	call   85f <gettoken>
  cmd = parseredirs(cmd, ps, es);
     dde:	8b 45 0c             	mov    0xc(%ebp),%eax
     de1:	89 44 24 08          	mov    %eax,0x8(%esp)
     de5:	8b 45 08             	mov    0x8(%ebp),%eax
     de8:	89 44 24 04          	mov    %eax,0x4(%esp)
     dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
     def:	89 04 24             	mov    %eax,(%esp)
     df2:	e8 0c fe ff ff       	call   c03 <parseredirs>
     df7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     dfd:	c9                   	leave  
     dfe:	c3                   	ret    

00000dff <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     dff:	55                   	push   %ebp
     e00:	89 e5                	mov    %esp,%ebp
     e02:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     e05:	c7 44 24 08 07 19 00 	movl   $0x1907,0x8(%esp)
     e0c:	00 
     e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
     e10:	89 44 24 04          	mov    %eax,0x4(%esp)
     e14:	8b 45 08             	mov    0x8(%ebp),%eax
     e17:	89 04 24             	mov    %eax,(%esp)
     e1a:	e8 8b fb ff ff       	call   9aa <peek>
     e1f:	85 c0                	test   %eax,%eax
     e21:	74 17                	je     e3a <parseexec+0x3b>
    return parseblock(ps, es);
     e23:	8b 45 0c             	mov    0xc(%ebp),%eax
     e26:	89 44 24 04          	mov    %eax,0x4(%esp)
     e2a:	8b 45 08             	mov    0x8(%ebp),%eax
     e2d:	89 04 24             	mov    %eax,(%esp)
     e30:	e8 f6 fe ff ff       	call   d2b <parseblock>
     e35:	e9 09 01 00 00       	jmp    f43 <parseexec+0x144>

  ret = execcmd();
     e3a:	e8 90 f8 ff ff       	call   6cf <execcmd>
     e3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     e42:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e45:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     e48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
     e52:	89 44 24 08          	mov    %eax,0x8(%esp)
     e56:	8b 45 08             	mov    0x8(%ebp),%eax
     e59:	89 44 24 04          	mov    %eax,0x4(%esp)
     e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e60:	89 04 24             	mov    %eax,(%esp)
     e63:	e8 9b fd ff ff       	call   c03 <parseredirs>
     e68:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     e6b:	e9 8f 00 00 00       	jmp    eff <parseexec+0x100>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     e70:	8d 45 e0             	lea    -0x20(%ebp),%eax
     e73:	89 44 24 0c          	mov    %eax,0xc(%esp)
     e77:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     e7a:	89 44 24 08          	mov    %eax,0x8(%esp)
     e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
     e81:	89 44 24 04          	mov    %eax,0x4(%esp)
     e85:	8b 45 08             	mov    0x8(%ebp),%eax
     e88:	89 04 24             	mov    %eax,(%esp)
     e8b:	e8 cf f9 ff ff       	call   85f <gettoken>
     e90:	89 45 e8             	mov    %eax,-0x18(%ebp)
     e93:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     e97:	75 05                	jne    e9e <parseexec+0x9f>
      break;
     e99:	e9 83 00 00 00       	jmp    f21 <parseexec+0x122>
    if(tok != 'a')
     e9e:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     ea2:	74 0c                	je     eb0 <parseexec+0xb1>
      panic("syntax");
     ea4:	c7 04 24 da 18 00 00 	movl   $0x18da,(%esp)
     eab:	e8 d4 f7 ff ff       	call   684 <panic>
    cmd->argv[argc] = q;
     eb0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     eb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
     eb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
     eb9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     ebd:	8b 55 e0             	mov    -0x20(%ebp),%edx
     ec0:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ec3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     ec6:	83 c1 08             	add    $0x8,%ecx
     ec9:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     ecd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     ed1:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     ed5:	7e 0c                	jle    ee3 <parseexec+0xe4>
      panic("too many args");
     ed7:	c7 04 24 29 19 00 00 	movl   $0x1929,(%esp)
     ede:	e8 a1 f7 ff ff       	call   684 <panic>
    ret = parseredirs(ret, ps, es);
     ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
     ee6:	89 44 24 08          	mov    %eax,0x8(%esp)
     eea:	8b 45 08             	mov    0x8(%ebp),%eax
     eed:	89 44 24 04          	mov    %eax,0x4(%esp)
     ef1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ef4:	89 04 24             	mov    %eax,(%esp)
     ef7:	e8 07 fd ff ff       	call   c03 <parseredirs>
     efc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     eff:	c7 44 24 08 37 19 00 	movl   $0x1937,0x8(%esp)
     f06:	00 
     f07:	8b 45 0c             	mov    0xc(%ebp),%eax
     f0a:	89 44 24 04          	mov    %eax,0x4(%esp)
     f0e:	8b 45 08             	mov    0x8(%ebp),%eax
     f11:	89 04 24             	mov    %eax,(%esp)
     f14:	e8 91 fa ff ff       	call   9aa <peek>
     f19:	85 c0                	test   %eax,%eax
     f1b:	0f 84 4f ff ff ff    	je     e70 <parseexec+0x71>
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     f21:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f24:	8b 55 f4             	mov    -0xc(%ebp),%edx
     f27:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     f2e:	00 
  cmd->eargv[argc] = 0;
     f2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f32:	8b 55 f4             	mov    -0xc(%ebp),%edx
     f35:	83 c2 08             	add    $0x8,%edx
     f38:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     f3f:	00 
  return ret;
     f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     f43:	c9                   	leave  
     f44:	c3                   	ret    

00000f45 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     f45:	55                   	push   %ebp
     f46:	89 e5                	mov    %esp,%ebp
     f48:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     f4b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     f4f:	75 0a                	jne    f5b <nulterminate+0x16>
    return 0;
     f51:	b8 00 00 00 00       	mov    $0x0,%eax
     f56:	e9 c9 00 00 00       	jmp    1024 <nulterminate+0xdf>
  
  switch(cmd->type){
     f5b:	8b 45 08             	mov    0x8(%ebp),%eax
     f5e:	8b 00                	mov    (%eax),%eax
     f60:	83 f8 05             	cmp    $0x5,%eax
     f63:	0f 87 b8 00 00 00    	ja     1021 <nulterminate+0xdc>
     f69:	8b 04 85 3c 19 00 00 	mov    0x193c(,%eax,4),%eax
     f70:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     f72:	8b 45 08             	mov    0x8(%ebp),%eax
     f75:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     f78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     f7f:	eb 14                	jmp    f95 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f84:	8b 55 f4             	mov    -0xc(%ebp),%edx
     f87:	83 c2 08             	add    $0x8,%edx
     f8a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     f8e:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     f91:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f98:	8b 55 f4             	mov    -0xc(%ebp),%edx
     f9b:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     f9f:	85 c0                	test   %eax,%eax
     fa1:	75 de                	jne    f81 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     fa3:	eb 7c                	jmp    1021 <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     fa5:	8b 45 08             	mov    0x8(%ebp),%eax
     fa8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     fab:	8b 45 ec             	mov    -0x14(%ebp),%eax
     fae:	8b 40 04             	mov    0x4(%eax),%eax
     fb1:	89 04 24             	mov    %eax,(%esp)
     fb4:	e8 8c ff ff ff       	call   f45 <nulterminate>
    *rcmd->efile = 0;
     fb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
     fbc:	8b 40 0c             	mov    0xc(%eax),%eax
     fbf:	c6 00 00             	movb   $0x0,(%eax)
    break;
     fc2:	eb 5d                	jmp    1021 <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     fc4:	8b 45 08             	mov    0x8(%ebp),%eax
     fc7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     fca:	8b 45 e8             	mov    -0x18(%ebp),%eax
     fcd:	8b 40 04             	mov    0x4(%eax),%eax
     fd0:	89 04 24             	mov    %eax,(%esp)
     fd3:	e8 6d ff ff ff       	call   f45 <nulterminate>
    nulterminate(pcmd->right);
     fd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
     fdb:	8b 40 08             	mov    0x8(%eax),%eax
     fde:	89 04 24             	mov    %eax,(%esp)
     fe1:	e8 5f ff ff ff       	call   f45 <nulterminate>
    break;
     fe6:	eb 39                	jmp    1021 <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     fe8:	8b 45 08             	mov    0x8(%ebp),%eax
     feb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     fee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     ff1:	8b 40 04             	mov    0x4(%eax),%eax
     ff4:	89 04 24             	mov    %eax,(%esp)
     ff7:	e8 49 ff ff ff       	call   f45 <nulterminate>
    nulterminate(lcmd->right);
     ffc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     fff:	8b 40 08             	mov    0x8(%eax),%eax
    1002:	89 04 24             	mov    %eax,(%esp)
    1005:	e8 3b ff ff ff       	call   f45 <nulterminate>
    break;
    100a:	eb 15                	jmp    1021 <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
    100c:	8b 45 08             	mov    0x8(%ebp),%eax
    100f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
    1012:	8b 45 e0             	mov    -0x20(%ebp),%eax
    1015:	8b 40 04             	mov    0x4(%eax),%eax
    1018:	89 04 24             	mov    %eax,(%esp)
    101b:	e8 25 ff ff ff       	call   f45 <nulterminate>
    break;
    1020:	90                   	nop
  }
  return cmd;
    1021:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1024:	c9                   	leave  
    1025:	c3                   	ret    

00001026 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1026:	55                   	push   %ebp
    1027:	89 e5                	mov    %esp,%ebp
    1029:	57                   	push   %edi
    102a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    102b:	8b 4d 08             	mov    0x8(%ebp),%ecx
    102e:	8b 55 10             	mov    0x10(%ebp),%edx
    1031:	8b 45 0c             	mov    0xc(%ebp),%eax
    1034:	89 cb                	mov    %ecx,%ebx
    1036:	89 df                	mov    %ebx,%edi
    1038:	89 d1                	mov    %edx,%ecx
    103a:	fc                   	cld    
    103b:	f3 aa                	rep stos %al,%es:(%edi)
    103d:	89 ca                	mov    %ecx,%edx
    103f:	89 fb                	mov    %edi,%ebx
    1041:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1044:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1047:	5b                   	pop    %ebx
    1048:	5f                   	pop    %edi
    1049:	5d                   	pop    %ebp
    104a:	c3                   	ret    

0000104b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    104b:	55                   	push   %ebp
    104c:	89 e5                	mov    %esp,%ebp
    104e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1051:	8b 45 08             	mov    0x8(%ebp),%eax
    1054:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1057:	90                   	nop
    1058:	8b 45 08             	mov    0x8(%ebp),%eax
    105b:	8d 50 01             	lea    0x1(%eax),%edx
    105e:	89 55 08             	mov    %edx,0x8(%ebp)
    1061:	8b 55 0c             	mov    0xc(%ebp),%edx
    1064:	8d 4a 01             	lea    0x1(%edx),%ecx
    1067:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    106a:	0f b6 12             	movzbl (%edx),%edx
    106d:	88 10                	mov    %dl,(%eax)
    106f:	0f b6 00             	movzbl (%eax),%eax
    1072:	84 c0                	test   %al,%al
    1074:	75 e2                	jne    1058 <strcpy+0xd>
    ;
  return os;
    1076:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1079:	c9                   	leave  
    107a:	c3                   	ret    

0000107b <strcmp>:

int
strcmp(const char *p, const char *q)
{
    107b:	55                   	push   %ebp
    107c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    107e:	eb 08                	jmp    1088 <strcmp+0xd>
    p++, q++;
    1080:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1084:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    1088:	8b 45 08             	mov    0x8(%ebp),%eax
    108b:	0f b6 00             	movzbl (%eax),%eax
    108e:	84 c0                	test   %al,%al
    1090:	74 10                	je     10a2 <strcmp+0x27>
    1092:	8b 45 08             	mov    0x8(%ebp),%eax
    1095:	0f b6 10             	movzbl (%eax),%edx
    1098:	8b 45 0c             	mov    0xc(%ebp),%eax
    109b:	0f b6 00             	movzbl (%eax),%eax
    109e:	38 c2                	cmp    %al,%dl
    10a0:	74 de                	je     1080 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10a2:	8b 45 08             	mov    0x8(%ebp),%eax
    10a5:	0f b6 00             	movzbl (%eax),%eax
    10a8:	0f b6 d0             	movzbl %al,%edx
    10ab:	8b 45 0c             	mov    0xc(%ebp),%eax
    10ae:	0f b6 00             	movzbl (%eax),%eax
    10b1:	0f b6 c0             	movzbl %al,%eax
    10b4:	29 c2                	sub    %eax,%edx
    10b6:	89 d0                	mov    %edx,%eax
}
    10b8:	5d                   	pop    %ebp
    10b9:	c3                   	ret    

000010ba <strlen>:

uint
strlen(char *s)
{
    10ba:	55                   	push   %ebp
    10bb:	89 e5                	mov    %esp,%ebp
    10bd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    10c0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    10c7:	eb 04                	jmp    10cd <strlen+0x13>
    10c9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    10cd:	8b 55 fc             	mov    -0x4(%ebp),%edx
    10d0:	8b 45 08             	mov    0x8(%ebp),%eax
    10d3:	01 d0                	add    %edx,%eax
    10d5:	0f b6 00             	movzbl (%eax),%eax
    10d8:	84 c0                	test   %al,%al
    10da:	75 ed                	jne    10c9 <strlen+0xf>
    ;
  return n;
    10dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10df:	c9                   	leave  
    10e0:	c3                   	ret    

000010e1 <memset>:

void*
memset(void *dst, int c, uint n)
{
    10e1:	55                   	push   %ebp
    10e2:	89 e5                	mov    %esp,%ebp
    10e4:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    10e7:	8b 45 10             	mov    0x10(%ebp),%eax
    10ea:	89 44 24 08          	mov    %eax,0x8(%esp)
    10ee:	8b 45 0c             	mov    0xc(%ebp),%eax
    10f1:	89 44 24 04          	mov    %eax,0x4(%esp)
    10f5:	8b 45 08             	mov    0x8(%ebp),%eax
    10f8:	89 04 24             	mov    %eax,(%esp)
    10fb:	e8 26 ff ff ff       	call   1026 <stosb>
  return dst;
    1100:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1103:	c9                   	leave  
    1104:	c3                   	ret    

00001105 <strchr>:

char*
strchr(const char *s, char c)
{
    1105:	55                   	push   %ebp
    1106:	89 e5                	mov    %esp,%ebp
    1108:	83 ec 04             	sub    $0x4,%esp
    110b:	8b 45 0c             	mov    0xc(%ebp),%eax
    110e:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1111:	eb 14                	jmp    1127 <strchr+0x22>
    if(*s == c)
    1113:	8b 45 08             	mov    0x8(%ebp),%eax
    1116:	0f b6 00             	movzbl (%eax),%eax
    1119:	3a 45 fc             	cmp    -0x4(%ebp),%al
    111c:	75 05                	jne    1123 <strchr+0x1e>
      return (char*)s;
    111e:	8b 45 08             	mov    0x8(%ebp),%eax
    1121:	eb 13                	jmp    1136 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1123:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1127:	8b 45 08             	mov    0x8(%ebp),%eax
    112a:	0f b6 00             	movzbl (%eax),%eax
    112d:	84 c0                	test   %al,%al
    112f:	75 e2                	jne    1113 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1131:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1136:	c9                   	leave  
    1137:	c3                   	ret    

00001138 <gets>:

char*
gets(char *buf, int max)
{
    1138:	55                   	push   %ebp
    1139:	89 e5                	mov    %esp,%ebp
    113b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    113e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1145:	eb 4c                	jmp    1193 <gets+0x5b>
    cc = read(0, &c, 1);
    1147:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    114e:	00 
    114f:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1152:	89 44 24 04          	mov    %eax,0x4(%esp)
    1156:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    115d:	e8 44 01 00 00       	call   12a6 <read>
    1162:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1165:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1169:	7f 02                	jg     116d <gets+0x35>
      break;
    116b:	eb 31                	jmp    119e <gets+0x66>
    buf[i++] = c;
    116d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1170:	8d 50 01             	lea    0x1(%eax),%edx
    1173:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1176:	89 c2                	mov    %eax,%edx
    1178:	8b 45 08             	mov    0x8(%ebp),%eax
    117b:	01 c2                	add    %eax,%edx
    117d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1181:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1183:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1187:	3c 0a                	cmp    $0xa,%al
    1189:	74 13                	je     119e <gets+0x66>
    118b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    118f:	3c 0d                	cmp    $0xd,%al
    1191:	74 0b                	je     119e <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1193:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1196:	83 c0 01             	add    $0x1,%eax
    1199:	3b 45 0c             	cmp    0xc(%ebp),%eax
    119c:	7c a9                	jl     1147 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    119e:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11a1:	8b 45 08             	mov    0x8(%ebp),%eax
    11a4:	01 d0                	add    %edx,%eax
    11a6:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11a9:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11ac:	c9                   	leave  
    11ad:	c3                   	ret    

000011ae <stat>:

int
stat(char *n, struct stat *st)
{
    11ae:	55                   	push   %ebp
    11af:	89 e5                	mov    %esp,%ebp
    11b1:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    11bb:	00 
    11bc:	8b 45 08             	mov    0x8(%ebp),%eax
    11bf:	89 04 24             	mov    %eax,(%esp)
    11c2:	e8 07 01 00 00       	call   12ce <open>
    11c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    11ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11ce:	79 07                	jns    11d7 <stat+0x29>
    return -1;
    11d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    11d5:	eb 23                	jmp    11fa <stat+0x4c>
  r = fstat(fd, st);
    11d7:	8b 45 0c             	mov    0xc(%ebp),%eax
    11da:	89 44 24 04          	mov    %eax,0x4(%esp)
    11de:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11e1:	89 04 24             	mov    %eax,(%esp)
    11e4:	e8 fd 00 00 00       	call   12e6 <fstat>
    11e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    11ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11ef:	89 04 24             	mov    %eax,(%esp)
    11f2:	e8 bf 00 00 00       	call   12b6 <close>
  return r;
    11f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    11fa:	c9                   	leave  
    11fb:	c3                   	ret    

000011fc <atoi>:

int
atoi(const char *s)
{
    11fc:	55                   	push   %ebp
    11fd:	89 e5                	mov    %esp,%ebp
    11ff:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1202:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1209:	eb 25                	jmp    1230 <atoi+0x34>
    n = n*10 + *s++ - '0';
    120b:	8b 55 fc             	mov    -0x4(%ebp),%edx
    120e:	89 d0                	mov    %edx,%eax
    1210:	c1 e0 02             	shl    $0x2,%eax
    1213:	01 d0                	add    %edx,%eax
    1215:	01 c0                	add    %eax,%eax
    1217:	89 c1                	mov    %eax,%ecx
    1219:	8b 45 08             	mov    0x8(%ebp),%eax
    121c:	8d 50 01             	lea    0x1(%eax),%edx
    121f:	89 55 08             	mov    %edx,0x8(%ebp)
    1222:	0f b6 00             	movzbl (%eax),%eax
    1225:	0f be c0             	movsbl %al,%eax
    1228:	01 c8                	add    %ecx,%eax
    122a:	83 e8 30             	sub    $0x30,%eax
    122d:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1230:	8b 45 08             	mov    0x8(%ebp),%eax
    1233:	0f b6 00             	movzbl (%eax),%eax
    1236:	3c 2f                	cmp    $0x2f,%al
    1238:	7e 0a                	jle    1244 <atoi+0x48>
    123a:	8b 45 08             	mov    0x8(%ebp),%eax
    123d:	0f b6 00             	movzbl (%eax),%eax
    1240:	3c 39                	cmp    $0x39,%al
    1242:	7e c7                	jle    120b <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1244:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1247:	c9                   	leave  
    1248:	c3                   	ret    

00001249 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1249:	55                   	push   %ebp
    124a:	89 e5                	mov    %esp,%ebp
    124c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    124f:	8b 45 08             	mov    0x8(%ebp),%eax
    1252:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1255:	8b 45 0c             	mov    0xc(%ebp),%eax
    1258:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    125b:	eb 17                	jmp    1274 <memmove+0x2b>
    *dst++ = *src++;
    125d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1260:	8d 50 01             	lea    0x1(%eax),%edx
    1263:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1266:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1269:	8d 4a 01             	lea    0x1(%edx),%ecx
    126c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    126f:	0f b6 12             	movzbl (%edx),%edx
    1272:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1274:	8b 45 10             	mov    0x10(%ebp),%eax
    1277:	8d 50 ff             	lea    -0x1(%eax),%edx
    127a:	89 55 10             	mov    %edx,0x10(%ebp)
    127d:	85 c0                	test   %eax,%eax
    127f:	7f dc                	jg     125d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1281:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1284:	c9                   	leave  
    1285:	c3                   	ret    

00001286 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1286:	b8 01 00 00 00       	mov    $0x1,%eax
    128b:	cd 40                	int    $0x40
    128d:	c3                   	ret    

0000128e <exit>:
SYSCALL(exit)
    128e:	b8 02 00 00 00       	mov    $0x2,%eax
    1293:	cd 40                	int    $0x40
    1295:	c3                   	ret    

00001296 <wait>:
SYSCALL(wait)
    1296:	b8 03 00 00 00       	mov    $0x3,%eax
    129b:	cd 40                	int    $0x40
    129d:	c3                   	ret    

0000129e <pipe>:
SYSCALL(pipe)
    129e:	b8 04 00 00 00       	mov    $0x4,%eax
    12a3:	cd 40                	int    $0x40
    12a5:	c3                   	ret    

000012a6 <read>:
SYSCALL(read)
    12a6:	b8 05 00 00 00       	mov    $0x5,%eax
    12ab:	cd 40                	int    $0x40
    12ad:	c3                   	ret    

000012ae <write>:
SYSCALL(write)
    12ae:	b8 10 00 00 00       	mov    $0x10,%eax
    12b3:	cd 40                	int    $0x40
    12b5:	c3                   	ret    

000012b6 <close>:
SYSCALL(close)
    12b6:	b8 15 00 00 00       	mov    $0x15,%eax
    12bb:	cd 40                	int    $0x40
    12bd:	c3                   	ret    

000012be <kill>:
SYSCALL(kill)
    12be:	b8 06 00 00 00       	mov    $0x6,%eax
    12c3:	cd 40                	int    $0x40
    12c5:	c3                   	ret    

000012c6 <exec>:
SYSCALL(exec)
    12c6:	b8 07 00 00 00       	mov    $0x7,%eax
    12cb:	cd 40                	int    $0x40
    12cd:	c3                   	ret    

000012ce <open>:
SYSCALL(open)
    12ce:	b8 0f 00 00 00       	mov    $0xf,%eax
    12d3:	cd 40                	int    $0x40
    12d5:	c3                   	ret    

000012d6 <mknod>:
SYSCALL(mknod)
    12d6:	b8 11 00 00 00       	mov    $0x11,%eax
    12db:	cd 40                	int    $0x40
    12dd:	c3                   	ret    

000012de <unlink>:
SYSCALL(unlink)
    12de:	b8 12 00 00 00       	mov    $0x12,%eax
    12e3:	cd 40                	int    $0x40
    12e5:	c3                   	ret    

000012e6 <fstat>:
SYSCALL(fstat)
    12e6:	b8 08 00 00 00       	mov    $0x8,%eax
    12eb:	cd 40                	int    $0x40
    12ed:	c3                   	ret    

000012ee <link>:
SYSCALL(link)
    12ee:	b8 13 00 00 00       	mov    $0x13,%eax
    12f3:	cd 40                	int    $0x40
    12f5:	c3                   	ret    

000012f6 <mkdir>:
SYSCALL(mkdir)
    12f6:	b8 14 00 00 00       	mov    $0x14,%eax
    12fb:	cd 40                	int    $0x40
    12fd:	c3                   	ret    

000012fe <chdir>:
SYSCALL(chdir)
    12fe:	b8 09 00 00 00       	mov    $0x9,%eax
    1303:	cd 40                	int    $0x40
    1305:	c3                   	ret    

00001306 <dup>:
SYSCALL(dup)
    1306:	b8 0a 00 00 00       	mov    $0xa,%eax
    130b:	cd 40                	int    $0x40
    130d:	c3                   	ret    

0000130e <getpid>:
SYSCALL(getpid)
    130e:	b8 0b 00 00 00       	mov    $0xb,%eax
    1313:	cd 40                	int    $0x40
    1315:	c3                   	ret    

00001316 <sbrk>:
SYSCALL(sbrk)
    1316:	b8 0c 00 00 00       	mov    $0xc,%eax
    131b:	cd 40                	int    $0x40
    131d:	c3                   	ret    

0000131e <sleep>:
SYSCALL(sleep)
    131e:	b8 0d 00 00 00       	mov    $0xd,%eax
    1323:	cd 40                	int    $0x40
    1325:	c3                   	ret    

00001326 <uptime>:
SYSCALL(uptime)
    1326:	b8 0e 00 00 00       	mov    $0xe,%eax
    132b:	cd 40                	int    $0x40
    132d:	c3                   	ret    

0000132e <date>:
SYSCALL(date)
    132e:	b8 16 00 00 00       	mov    $0x16,%eax
    1333:	cd 40                	int    $0x40
    1335:	c3                   	ret    

00001336 <timem>:
SYSCALL(timem)
    1336:	b8 17 00 00 00       	mov    $0x17,%eax
    133b:	cd 40                	int    $0x40
    133d:	c3                   	ret    

0000133e <getuid>:
SYSCALL(getuid)
    133e:	b8 18 00 00 00       	mov    $0x18,%eax
    1343:	cd 40                	int    $0x40
    1345:	c3                   	ret    

00001346 <getgid>:
SYSCALL(getgid)
    1346:	b8 19 00 00 00       	mov    $0x19,%eax
    134b:	cd 40                	int    $0x40
    134d:	c3                   	ret    

0000134e <getppid>:
SYSCALL(getppid)
    134e:	b8 1a 00 00 00       	mov    $0x1a,%eax
    1353:	cd 40                	int    $0x40
    1355:	c3                   	ret    

00001356 <setuid>:
SYSCALL(setuid)
    1356:	b8 1b 00 00 00       	mov    $0x1b,%eax
    135b:	cd 40                	int    $0x40
    135d:	c3                   	ret    

0000135e <setgid>:
SYSCALL(setgid)
    135e:	b8 1c 00 00 00       	mov    $0x1c,%eax
    1363:	cd 40                	int    $0x40
    1365:	c3                   	ret    

00001366 <getprocs>:
SYSCALL(getprocs)
    1366:	b8 1d 00 00 00       	mov    $0x1d,%eax
    136b:	cd 40                	int    $0x40
    136d:	c3                   	ret    

0000136e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    136e:	55                   	push   %ebp
    136f:	89 e5                	mov    %esp,%ebp
    1371:	83 ec 18             	sub    $0x18,%esp
    1374:	8b 45 0c             	mov    0xc(%ebp),%eax
    1377:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    137a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1381:	00 
    1382:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1385:	89 44 24 04          	mov    %eax,0x4(%esp)
    1389:	8b 45 08             	mov    0x8(%ebp),%eax
    138c:	89 04 24             	mov    %eax,(%esp)
    138f:	e8 1a ff ff ff       	call   12ae <write>
}
    1394:	c9                   	leave  
    1395:	c3                   	ret    

00001396 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1396:	55                   	push   %ebp
    1397:	89 e5                	mov    %esp,%ebp
    1399:	56                   	push   %esi
    139a:	53                   	push   %ebx
    139b:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    139e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13a5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13a9:	74 17                	je     13c2 <printint+0x2c>
    13ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13af:	79 11                	jns    13c2 <printint+0x2c>
    neg = 1;
    13b1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13b8:	8b 45 0c             	mov    0xc(%ebp),%eax
    13bb:	f7 d8                	neg    %eax
    13bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13c0:	eb 06                	jmp    13c8 <printint+0x32>
  } else {
    x = xx;
    13c2:	8b 45 0c             	mov    0xc(%ebp),%eax
    13c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13cf:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13d2:	8d 41 01             	lea    0x1(%ecx),%eax
    13d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13db:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13de:	ba 00 00 00 00       	mov    $0x0,%edx
    13e3:	f7 f3                	div    %ebx
    13e5:	89 d0                	mov    %edx,%eax
    13e7:	0f b6 80 9e 1e 00 00 	movzbl 0x1e9e(%eax),%eax
    13ee:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13f2:	8b 75 10             	mov    0x10(%ebp),%esi
    13f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13f8:	ba 00 00 00 00       	mov    $0x0,%edx
    13fd:	f7 f6                	div    %esi
    13ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1402:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1406:	75 c7                	jne    13cf <printint+0x39>
  if(neg)
    1408:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    140c:	74 10                	je     141e <printint+0x88>
    buf[i++] = '-';
    140e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1411:	8d 50 01             	lea    0x1(%eax),%edx
    1414:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1417:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    141c:	eb 1f                	jmp    143d <printint+0xa7>
    141e:	eb 1d                	jmp    143d <printint+0xa7>
    putc(fd, buf[i]);
    1420:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1423:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1426:	01 d0                	add    %edx,%eax
    1428:	0f b6 00             	movzbl (%eax),%eax
    142b:	0f be c0             	movsbl %al,%eax
    142e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1432:	8b 45 08             	mov    0x8(%ebp),%eax
    1435:	89 04 24             	mov    %eax,(%esp)
    1438:	e8 31 ff ff ff       	call   136e <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    143d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1441:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1445:	79 d9                	jns    1420 <printint+0x8a>
    putc(fd, buf[i]);
}
    1447:	83 c4 30             	add    $0x30,%esp
    144a:	5b                   	pop    %ebx
    144b:	5e                   	pop    %esi
    144c:	5d                   	pop    %ebp
    144d:	c3                   	ret    

0000144e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    144e:	55                   	push   %ebp
    144f:	89 e5                	mov    %esp,%ebp
    1451:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1454:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    145b:	8d 45 0c             	lea    0xc(%ebp),%eax
    145e:	83 c0 04             	add    $0x4,%eax
    1461:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1464:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    146b:	e9 7c 01 00 00       	jmp    15ec <printf+0x19e>
    c = fmt[i] & 0xff;
    1470:	8b 55 0c             	mov    0xc(%ebp),%edx
    1473:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1476:	01 d0                	add    %edx,%eax
    1478:	0f b6 00             	movzbl (%eax),%eax
    147b:	0f be c0             	movsbl %al,%eax
    147e:	25 ff 00 00 00       	and    $0xff,%eax
    1483:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1486:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    148a:	75 2c                	jne    14b8 <printf+0x6a>
      if(c == '%'){
    148c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1490:	75 0c                	jne    149e <printf+0x50>
        state = '%';
    1492:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1499:	e9 4a 01 00 00       	jmp    15e8 <printf+0x19a>
      } else {
        putc(fd, c);
    149e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14a1:	0f be c0             	movsbl %al,%eax
    14a4:	89 44 24 04          	mov    %eax,0x4(%esp)
    14a8:	8b 45 08             	mov    0x8(%ebp),%eax
    14ab:	89 04 24             	mov    %eax,(%esp)
    14ae:	e8 bb fe ff ff       	call   136e <putc>
    14b3:	e9 30 01 00 00       	jmp    15e8 <printf+0x19a>
      }
    } else if(state == '%'){
    14b8:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14bc:	0f 85 26 01 00 00    	jne    15e8 <printf+0x19a>
      if(c == 'd'){
    14c2:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14c6:	75 2d                	jne    14f5 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    14c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14cb:	8b 00                	mov    (%eax),%eax
    14cd:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    14d4:	00 
    14d5:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    14dc:	00 
    14dd:	89 44 24 04          	mov    %eax,0x4(%esp)
    14e1:	8b 45 08             	mov    0x8(%ebp),%eax
    14e4:	89 04 24             	mov    %eax,(%esp)
    14e7:	e8 aa fe ff ff       	call   1396 <printint>
        ap++;
    14ec:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14f0:	e9 ec 00 00 00       	jmp    15e1 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    14f5:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14f9:	74 06                	je     1501 <printf+0xb3>
    14fb:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14ff:	75 2d                	jne    152e <printf+0xe0>
        printint(fd, *ap, 16, 0);
    1501:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1504:	8b 00                	mov    (%eax),%eax
    1506:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    150d:	00 
    150e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1515:	00 
    1516:	89 44 24 04          	mov    %eax,0x4(%esp)
    151a:	8b 45 08             	mov    0x8(%ebp),%eax
    151d:	89 04 24             	mov    %eax,(%esp)
    1520:	e8 71 fe ff ff       	call   1396 <printint>
        ap++;
    1525:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1529:	e9 b3 00 00 00       	jmp    15e1 <printf+0x193>
      } else if(c == 's'){
    152e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1532:	75 45                	jne    1579 <printf+0x12b>
        s = (char*)*ap;
    1534:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1537:	8b 00                	mov    (%eax),%eax
    1539:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    153c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1540:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1544:	75 09                	jne    154f <printf+0x101>
          s = "(null)";
    1546:	c7 45 f4 54 19 00 00 	movl   $0x1954,-0xc(%ebp)
        while(*s != 0){
    154d:	eb 1e                	jmp    156d <printf+0x11f>
    154f:	eb 1c                	jmp    156d <printf+0x11f>
          putc(fd, *s);
    1551:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1554:	0f b6 00             	movzbl (%eax),%eax
    1557:	0f be c0             	movsbl %al,%eax
    155a:	89 44 24 04          	mov    %eax,0x4(%esp)
    155e:	8b 45 08             	mov    0x8(%ebp),%eax
    1561:	89 04 24             	mov    %eax,(%esp)
    1564:	e8 05 fe ff ff       	call   136e <putc>
          s++;
    1569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    156d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1570:	0f b6 00             	movzbl (%eax),%eax
    1573:	84 c0                	test   %al,%al
    1575:	75 da                	jne    1551 <printf+0x103>
    1577:	eb 68                	jmp    15e1 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1579:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    157d:	75 1d                	jne    159c <printf+0x14e>
        putc(fd, *ap);
    157f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1582:	8b 00                	mov    (%eax),%eax
    1584:	0f be c0             	movsbl %al,%eax
    1587:	89 44 24 04          	mov    %eax,0x4(%esp)
    158b:	8b 45 08             	mov    0x8(%ebp),%eax
    158e:	89 04 24             	mov    %eax,(%esp)
    1591:	e8 d8 fd ff ff       	call   136e <putc>
        ap++;
    1596:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    159a:	eb 45                	jmp    15e1 <printf+0x193>
      } else if(c == '%'){
    159c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    15a0:	75 17                	jne    15b9 <printf+0x16b>
        putc(fd, c);
    15a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15a5:	0f be c0             	movsbl %al,%eax
    15a8:	89 44 24 04          	mov    %eax,0x4(%esp)
    15ac:	8b 45 08             	mov    0x8(%ebp),%eax
    15af:	89 04 24             	mov    %eax,(%esp)
    15b2:	e8 b7 fd ff ff       	call   136e <putc>
    15b7:	eb 28                	jmp    15e1 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    15b9:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    15c0:	00 
    15c1:	8b 45 08             	mov    0x8(%ebp),%eax
    15c4:	89 04 24             	mov    %eax,(%esp)
    15c7:	e8 a2 fd ff ff       	call   136e <putc>
        putc(fd, c);
    15cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15cf:	0f be c0             	movsbl %al,%eax
    15d2:	89 44 24 04          	mov    %eax,0x4(%esp)
    15d6:	8b 45 08             	mov    0x8(%ebp),%eax
    15d9:	89 04 24             	mov    %eax,(%esp)
    15dc:	e8 8d fd ff ff       	call   136e <putc>
      }
      state = 0;
    15e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15e8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15ec:	8b 55 0c             	mov    0xc(%ebp),%edx
    15ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15f2:	01 d0                	add    %edx,%eax
    15f4:	0f b6 00             	movzbl (%eax),%eax
    15f7:	84 c0                	test   %al,%al
    15f9:	0f 85 71 fe ff ff    	jne    1470 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15ff:	c9                   	leave  
    1600:	c3                   	ret    

00001601 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1601:	55                   	push   %ebp
    1602:	89 e5                	mov    %esp,%ebp
    1604:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1607:	8b 45 08             	mov    0x8(%ebp),%eax
    160a:	83 e8 08             	sub    $0x8,%eax
    160d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1610:	a1 2c 1f 00 00       	mov    0x1f2c,%eax
    1615:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1618:	eb 24                	jmp    163e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    161a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    161d:	8b 00                	mov    (%eax),%eax
    161f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1622:	77 12                	ja     1636 <free+0x35>
    1624:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1627:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    162a:	77 24                	ja     1650 <free+0x4f>
    162c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    162f:	8b 00                	mov    (%eax),%eax
    1631:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1634:	77 1a                	ja     1650 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1636:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1639:	8b 00                	mov    (%eax),%eax
    163b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    163e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1641:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1644:	76 d4                	jbe    161a <free+0x19>
    1646:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1649:	8b 00                	mov    (%eax),%eax
    164b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    164e:	76 ca                	jbe    161a <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1650:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1653:	8b 40 04             	mov    0x4(%eax),%eax
    1656:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    165d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1660:	01 c2                	add    %eax,%edx
    1662:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1665:	8b 00                	mov    (%eax),%eax
    1667:	39 c2                	cmp    %eax,%edx
    1669:	75 24                	jne    168f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    166b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    166e:	8b 50 04             	mov    0x4(%eax),%edx
    1671:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1674:	8b 00                	mov    (%eax),%eax
    1676:	8b 40 04             	mov    0x4(%eax),%eax
    1679:	01 c2                	add    %eax,%edx
    167b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    167e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1681:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1684:	8b 00                	mov    (%eax),%eax
    1686:	8b 10                	mov    (%eax),%edx
    1688:	8b 45 f8             	mov    -0x8(%ebp),%eax
    168b:	89 10                	mov    %edx,(%eax)
    168d:	eb 0a                	jmp    1699 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    168f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1692:	8b 10                	mov    (%eax),%edx
    1694:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1697:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1699:	8b 45 fc             	mov    -0x4(%ebp),%eax
    169c:	8b 40 04             	mov    0x4(%eax),%eax
    169f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a9:	01 d0                	add    %edx,%eax
    16ab:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16ae:	75 20                	jne    16d0 <free+0xcf>
    p->s.size += bp->s.size;
    16b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b3:	8b 50 04             	mov    0x4(%eax),%edx
    16b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16b9:	8b 40 04             	mov    0x4(%eax),%eax
    16bc:	01 c2                	add    %eax,%edx
    16be:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    16c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16c7:	8b 10                	mov    (%eax),%edx
    16c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16cc:	89 10                	mov    %edx,(%eax)
    16ce:	eb 08                	jmp    16d8 <free+0xd7>
  } else
    p->s.ptr = bp;
    16d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d3:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16d6:	89 10                	mov    %edx,(%eax)
  freep = p;
    16d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16db:	a3 2c 1f 00 00       	mov    %eax,0x1f2c
}
    16e0:	c9                   	leave  
    16e1:	c3                   	ret    

000016e2 <morecore>:

static Header*
morecore(uint nu)
{
    16e2:	55                   	push   %ebp
    16e3:	89 e5                	mov    %esp,%ebp
    16e5:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16e8:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16ef:	77 07                	ja     16f8 <morecore+0x16>
    nu = 4096;
    16f1:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16f8:	8b 45 08             	mov    0x8(%ebp),%eax
    16fb:	c1 e0 03             	shl    $0x3,%eax
    16fe:	89 04 24             	mov    %eax,(%esp)
    1701:	e8 10 fc ff ff       	call   1316 <sbrk>
    1706:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1709:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    170d:	75 07                	jne    1716 <morecore+0x34>
    return 0;
    170f:	b8 00 00 00 00       	mov    $0x0,%eax
    1714:	eb 22                	jmp    1738 <morecore+0x56>
  hp = (Header*)p;
    1716:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1719:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    171c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    171f:	8b 55 08             	mov    0x8(%ebp),%edx
    1722:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1725:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1728:	83 c0 08             	add    $0x8,%eax
    172b:	89 04 24             	mov    %eax,(%esp)
    172e:	e8 ce fe ff ff       	call   1601 <free>
  return freep;
    1733:	a1 2c 1f 00 00       	mov    0x1f2c,%eax
}
    1738:	c9                   	leave  
    1739:	c3                   	ret    

0000173a <malloc>:

void*
malloc(uint nbytes)
{
    173a:	55                   	push   %ebp
    173b:	89 e5                	mov    %esp,%ebp
    173d:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1740:	8b 45 08             	mov    0x8(%ebp),%eax
    1743:	83 c0 07             	add    $0x7,%eax
    1746:	c1 e8 03             	shr    $0x3,%eax
    1749:	83 c0 01             	add    $0x1,%eax
    174c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    174f:	a1 2c 1f 00 00       	mov    0x1f2c,%eax
    1754:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1757:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    175b:	75 23                	jne    1780 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    175d:	c7 45 f0 24 1f 00 00 	movl   $0x1f24,-0x10(%ebp)
    1764:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1767:	a3 2c 1f 00 00       	mov    %eax,0x1f2c
    176c:	a1 2c 1f 00 00       	mov    0x1f2c,%eax
    1771:	a3 24 1f 00 00       	mov    %eax,0x1f24
    base.s.size = 0;
    1776:	c7 05 28 1f 00 00 00 	movl   $0x0,0x1f28
    177d:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1780:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1783:	8b 00                	mov    (%eax),%eax
    1785:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1788:	8b 45 f4             	mov    -0xc(%ebp),%eax
    178b:	8b 40 04             	mov    0x4(%eax),%eax
    178e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1791:	72 4d                	jb     17e0 <malloc+0xa6>
      if(p->s.size == nunits)
    1793:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1796:	8b 40 04             	mov    0x4(%eax),%eax
    1799:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    179c:	75 0c                	jne    17aa <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    179e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a1:	8b 10                	mov    (%eax),%edx
    17a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17a6:	89 10                	mov    %edx,(%eax)
    17a8:	eb 26                	jmp    17d0 <malloc+0x96>
      else {
        p->s.size -= nunits;
    17aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ad:	8b 40 04             	mov    0x4(%eax),%eax
    17b0:	2b 45 ec             	sub    -0x14(%ebp),%eax
    17b3:	89 c2                	mov    %eax,%edx
    17b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b8:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    17bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17be:	8b 40 04             	mov    0x4(%eax),%eax
    17c1:	c1 e0 03             	shl    $0x3,%eax
    17c4:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ca:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17cd:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17d3:	a3 2c 1f 00 00       	mov    %eax,0x1f2c
      return (void*)(p + 1);
    17d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17db:	83 c0 08             	add    $0x8,%eax
    17de:	eb 38                	jmp    1818 <malloc+0xde>
    }
    if(p == freep)
    17e0:	a1 2c 1f 00 00       	mov    0x1f2c,%eax
    17e5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17e8:	75 1b                	jne    1805 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    17ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
    17ed:	89 04 24             	mov    %eax,(%esp)
    17f0:	e8 ed fe ff ff       	call   16e2 <morecore>
    17f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17fc:	75 07                	jne    1805 <malloc+0xcb>
        return 0;
    17fe:	b8 00 00 00 00       	mov    $0x0,%eax
    1803:	eb 13                	jmp    1818 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1805:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1808:	89 45 f0             	mov    %eax,-0x10(%ebp)
    180b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    180e:	8b 00                	mov    (%eax),%eax
    1810:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1813:	e9 70 ff ff ff       	jmp    1788 <malloc+0x4e>
}
    1818:	c9                   	leave  
    1819:	c3                   	ret    
