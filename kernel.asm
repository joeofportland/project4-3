
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 c6 10 80       	mov    $0x8010c670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 c3 37 10 80       	mov    $0x801037c3,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 d8 87 10 	movl   $0x801087d8,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100049:	e8 6e 50 00 00       	call   801050bc <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 05 11 80 84 	movl   $0x80110584,0x80110590
80100055:	05 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 05 11 80 84 	movl   $0x80110584,0x80110594
8010005f:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 c6 10 80 	movl   $0x8010c6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 05 11 80    	mov    0x80110594,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 05 11 80 	movl   $0x80110584,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 05 11 80       	mov    0x80110594,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 05 11 80       	mov    %eax,0x80110594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801000bd:	e8 1b 50 00 00       	call   801050dd <acquire>

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 05 11 80       	mov    0x80110594,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->blockno == blockno){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100104:	e8 36 50 00 00       	call   8010513f <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 c6 10 	movl   $0x8010c680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 ee 4a 00 00       	call   80104c12 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 05 11 80       	mov    0x80110590,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010017c:	e8 be 4f 00 00       	call   8010513f <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 df 87 10 80 	movl   $0x801087df,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 7f 26 00 00       	call   80102857 <iderw>
  }
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 f0 87 10 80 	movl   $0x801087f0,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 42 26 00 00       	call   80102857 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 f7 87 10 80 	movl   $0x801087f7,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010023c:	e8 9c 4e 00 00       	call   801050dd <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 05 11 80    	mov    0x80110594,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 05 11 80 	movl   $0x80110584,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 05 11 80       	mov    0x80110594,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 05 11 80       	mov    %eax,0x80110594

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 4c 4a 00 00       	call   80104cee <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801002a9:	e8 91 4e 00 00       	call   8010513f <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 dc 03 00 00       	call   8010076b <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801003bb:	e8 1d 4d 00 00       	call   801050dd <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 fe 87 10 80 	movl   $0x801087fe,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 75 03 00 00       	call   8010076b <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec 07 88 10 80 	movl   $0x80108807,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 9f 02 00 00       	call   8010076b <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 83 02 00 00       	call   8010076b <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 75 02 00 00       	call   8010076b <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 6a 02 00 00       	call   8010076b <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100533:	e8 07 4c 00 00       	call   8010513f <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 0e 88 10 80 	movl   $0x8010880e,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 1d 88 10 80 	movl   $0x8010881d,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 fa 4b 00 00       	call   8010518e <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 1f 88 10 80 	movl   $0x8010881f,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
8010068a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068e:	78 09                	js     80100699 <cgaputc+0xcf>
80100690:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100697:	7e 0c                	jle    801006a5 <cgaputc+0xdb>
    panic("pos under/overflow");
80100699:	c7 04 24 23 88 10 80 	movl   $0x80108823,(%esp)
801006a0:	e8 95 fe ff ff       	call   8010053a <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006a5:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006ac:	7e 53                	jle    80100701 <cgaputc+0x137>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006ae:	a1 00 90 10 80       	mov    0x80109000,%eax
801006b3:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b9:	a1 00 90 10 80       	mov    0x80109000,%eax
801006be:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c5:	00 
801006c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801006ca:	89 04 24             	mov    %eax,(%esp)
801006cd:	e8 2e 4d 00 00       	call   80105400 <memmove>
    pos -= 80;
801006d2:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d6:	b8 80 07 00 00       	mov    $0x780,%eax
801006db:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006de:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006e1:	a1 00 90 10 80       	mov    0x80109000,%eax
801006e6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006e9:	01 c9                	add    %ecx,%ecx
801006eb:	01 c8                	add    %ecx,%eax
801006ed:	89 54 24 08          	mov    %edx,0x8(%esp)
801006f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f8:	00 
801006f9:	89 04 24             	mov    %eax,(%esp)
801006fc:	e8 30 4c 00 00       	call   80105331 <memset>
  }
  
  outb(CRTPORT, 14);
80100701:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100708:	00 
80100709:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100710:	e8 b8 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
80100715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100718:	c1 f8 08             	sar    $0x8,%eax
8010071b:	0f b6 c0             	movzbl %al,%eax
8010071e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100722:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100729:	e8 9f fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
8010072e:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100735:	00 
80100736:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010073d:	e8 8b fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100745:	0f b6 c0             	movzbl %al,%eax
80100748:	89 44 24 04          	mov    %eax,0x4(%esp)
8010074c:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100753:	e8 75 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
80100758:	a1 00 90 10 80       	mov    0x80109000,%eax
8010075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100760:	01 d2                	add    %edx,%edx
80100762:	01 d0                	add    %edx,%eax
80100764:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100769:	c9                   	leave  
8010076a:	c3                   	ret    

8010076b <consputc>:

void
consputc(int c)
{
8010076b:	55                   	push   %ebp
8010076c:	89 e5                	mov    %esp,%ebp
8010076e:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100771:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80100776:	85 c0                	test   %eax,%eax
80100778:	74 07                	je     80100781 <consputc+0x16>
    cli();
8010077a:	e8 6c fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
8010077f:	eb fe                	jmp    8010077f <consputc+0x14>
  }

  if(c == BACKSPACE){
80100781:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100788:	75 26                	jne    801007b0 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100791:	e8 83 66 00 00       	call   80106e19 <uartputc>
80100796:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079d:	e8 77 66 00 00       	call   80106e19 <uartputc>
801007a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a9:	e8 6b 66 00 00       	call   80106e19 <uartputc>
801007ae:	eb 0b                	jmp    801007bb <consputc+0x50>
  } else
    uartputc(c);
801007b0:	8b 45 08             	mov    0x8(%ebp),%eax
801007b3:	89 04 24             	mov    %eax,(%esp)
801007b6:	e8 5e 66 00 00       	call   80106e19 <uartputc>
  cgaputc(c);
801007bb:	8b 45 08             	mov    0x8(%ebp),%eax
801007be:	89 04 24             	mov    %eax,(%esp)
801007c1:	e8 04 fe ff ff       	call   801005ca <cgaputc>
}
801007c6:	c9                   	leave  
801007c7:	c3                   	ret    

801007c8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007c8:	55                   	push   %ebp
801007c9:	89 e5                	mov    %esp,%ebp
801007cb:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007d5:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801007dc:	e8 fc 48 00 00       	call   801050dd <acquire>
  while((c = getc()) >= 0){
801007e1:	e9 39 01 00 00       	jmp    8010091f <consoleintr+0x157>
    switch(c){
801007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801007e9:	83 f8 10             	cmp    $0x10,%eax
801007ec:	74 1e                	je     8010080c <consoleintr+0x44>
801007ee:	83 f8 10             	cmp    $0x10,%eax
801007f1:	7f 0a                	jg     801007fd <consoleintr+0x35>
801007f3:	83 f8 08             	cmp    $0x8,%eax
801007f6:	74 66                	je     8010085e <consoleintr+0x96>
801007f8:	e9 93 00 00 00       	jmp    80100890 <consoleintr+0xc8>
801007fd:	83 f8 15             	cmp    $0x15,%eax
80100800:	74 31                	je     80100833 <consoleintr+0x6b>
80100802:	83 f8 7f             	cmp    $0x7f,%eax
80100805:	74 57                	je     8010085e <consoleintr+0x96>
80100807:	e9 84 00 00 00       	jmp    80100890 <consoleintr+0xc8>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010080c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100813:	e9 07 01 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100818:	a1 28 08 11 80       	mov    0x80110828,%eax
8010081d:	83 e8 01             	sub    $0x1,%eax
80100820:	a3 28 08 11 80       	mov    %eax,0x80110828
        consputc(BACKSPACE);
80100825:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010082c:	e8 3a ff ff ff       	call   8010076b <consputc>
80100831:	eb 01                	jmp    80100834 <consoleintr+0x6c>
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100833:	90                   	nop
80100834:	8b 15 28 08 11 80    	mov    0x80110828,%edx
8010083a:	a1 24 08 11 80       	mov    0x80110824,%eax
8010083f:	39 c2                	cmp    %eax,%edx
80100841:	74 16                	je     80100859 <consoleintr+0x91>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100843:	a1 28 08 11 80       	mov    0x80110828,%eax
80100848:	83 e8 01             	sub    $0x1,%eax
8010084b:	83 e0 7f             	and    $0x7f,%eax
8010084e:	0f b6 80 a0 07 11 80 	movzbl -0x7feef860(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100855:	3c 0a                	cmp    $0xa,%al
80100857:	75 bf                	jne    80100818 <consoleintr+0x50>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100859:	e9 c1 00 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010085e:	8b 15 28 08 11 80    	mov    0x80110828,%edx
80100864:	a1 24 08 11 80       	mov    0x80110824,%eax
80100869:	39 c2                	cmp    %eax,%edx
8010086b:	74 1e                	je     8010088b <consoleintr+0xc3>
        input.e--;
8010086d:	a1 28 08 11 80       	mov    0x80110828,%eax
80100872:	83 e8 01             	sub    $0x1,%eax
80100875:	a3 28 08 11 80       	mov    %eax,0x80110828
        consputc(BACKSPACE);
8010087a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100881:	e8 e5 fe ff ff       	call   8010076b <consputc>
      }
      break;
80100886:	e9 94 00 00 00       	jmp    8010091f <consoleintr+0x157>
8010088b:	e9 8f 00 00 00       	jmp    8010091f <consoleintr+0x157>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100890:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100894:	0f 84 84 00 00 00    	je     8010091e <consoleintr+0x156>
8010089a:	8b 15 28 08 11 80    	mov    0x80110828,%edx
801008a0:	a1 20 08 11 80       	mov    0x80110820,%eax
801008a5:	29 c2                	sub    %eax,%edx
801008a7:	89 d0                	mov    %edx,%eax
801008a9:	83 f8 7f             	cmp    $0x7f,%eax
801008ac:	77 70                	ja     8010091e <consoleintr+0x156>
        c = (c == '\r') ? '\n' : c;
801008ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008b2:	74 05                	je     801008b9 <consoleintr+0xf1>
801008b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008b7:	eb 05                	jmp    801008be <consoleintr+0xf6>
801008b9:	b8 0a 00 00 00       	mov    $0xa,%eax
801008be:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008c1:	a1 28 08 11 80       	mov    0x80110828,%eax
801008c6:	8d 50 01             	lea    0x1(%eax),%edx
801008c9:	89 15 28 08 11 80    	mov    %edx,0x80110828
801008cf:	83 e0 7f             	and    $0x7f,%eax
801008d2:	89 c2                	mov    %eax,%edx
801008d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d7:	88 82 a0 07 11 80    	mov    %al,-0x7feef860(%edx)
        consputc(c);
801008dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008e0:	89 04 24             	mov    %eax,(%esp)
801008e3:	e8 83 fe ff ff       	call   8010076b <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008e8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801008ec:	74 18                	je     80100906 <consoleintr+0x13e>
801008ee:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801008f2:	74 12                	je     80100906 <consoleintr+0x13e>
801008f4:	a1 28 08 11 80       	mov    0x80110828,%eax
801008f9:	8b 15 20 08 11 80    	mov    0x80110820,%edx
801008ff:	83 ea 80             	sub    $0xffffff80,%edx
80100902:	39 d0                	cmp    %edx,%eax
80100904:	75 18                	jne    8010091e <consoleintr+0x156>
          input.w = input.e;
80100906:	a1 28 08 11 80       	mov    0x80110828,%eax
8010090b:	a3 24 08 11 80       	mov    %eax,0x80110824
          wakeup(&input.r);
80100910:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80100917:	e8 d2 43 00 00       	call   80104cee <wakeup>
        }
      }
      break;
8010091c:	eb 00                	jmp    8010091e <consoleintr+0x156>
8010091e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010091f:	8b 45 08             	mov    0x8(%ebp),%eax
80100922:	ff d0                	call   *%eax
80100924:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100927:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010092b:	0f 89 b5 fe ff ff    	jns    801007e6 <consoleintr+0x1e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100931:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100938:	e8 02 48 00 00       	call   8010513f <release>
  if(doprocdump) {
8010093d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100941:	74 05                	je     80100948 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
80100943:	e8 4c 44 00 00       	call   80104d94 <procdump>
  }
}
80100948:	c9                   	leave  
80100949:	c3                   	ret    

8010094a <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010094a:	55                   	push   %ebp
8010094b:	89 e5                	mov    %esp,%ebp
8010094d:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100950:	8b 45 08             	mov    0x8(%ebp),%eax
80100953:	89 04 24             	mov    %eax,(%esp)
80100956:	e8 cd 10 00 00       	call   80101a28 <iunlock>
  target = n;
8010095b:	8b 45 10             	mov    0x10(%ebp),%eax
8010095e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100961:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100968:	e8 70 47 00 00       	call   801050dd <acquire>
  while(n > 0){
8010096d:	e9 aa 00 00 00       	jmp    80100a1c <consoleread+0xd2>
    while(input.r == input.w){
80100972:	eb 42                	jmp    801009b6 <consoleread+0x6c>
      if(proc->killed){
80100974:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010097a:	8b 40 2c             	mov    0x2c(%eax),%eax
8010097d:	85 c0                	test   %eax,%eax
8010097f:	74 21                	je     801009a2 <consoleread+0x58>
        release(&cons.lock);
80100981:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100988:	e8 b2 47 00 00       	call   8010513f <release>
        ilock(ip);
8010098d:	8b 45 08             	mov    0x8(%ebp),%eax
80100990:	89 04 24             	mov    %eax,(%esp)
80100993:	e8 3c 0f 00 00       	call   801018d4 <ilock>
        return -1;
80100998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010099d:	e9 a5 00 00 00       	jmp    80100a47 <consoleread+0xfd>
      }
      sleep(&input.r, &cons.lock);
801009a2:	c7 44 24 04 e0 b5 10 	movl   $0x8010b5e0,0x4(%esp)
801009a9:	80 
801009aa:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
801009b1:	e8 5c 42 00 00       	call   80104c12 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801009b6:	8b 15 20 08 11 80    	mov    0x80110820,%edx
801009bc:	a1 24 08 11 80       	mov    0x80110824,%eax
801009c1:	39 c2                	cmp    %eax,%edx
801009c3:	74 af                	je     80100974 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009c5:	a1 20 08 11 80       	mov    0x80110820,%eax
801009ca:	8d 50 01             	lea    0x1(%eax),%edx
801009cd:	89 15 20 08 11 80    	mov    %edx,0x80110820
801009d3:	83 e0 7f             	and    $0x7f,%eax
801009d6:	0f b6 80 a0 07 11 80 	movzbl -0x7feef860(%eax),%eax
801009dd:	0f be c0             	movsbl %al,%eax
801009e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009e3:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009e7:	75 19                	jne    80100a02 <consoleread+0xb8>
      if(n < target){
801009e9:	8b 45 10             	mov    0x10(%ebp),%eax
801009ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009ef:	73 0f                	jae    80100a00 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009f1:	a1 20 08 11 80       	mov    0x80110820,%eax
801009f6:	83 e8 01             	sub    $0x1,%eax
801009f9:	a3 20 08 11 80       	mov    %eax,0x80110820
      }
      break;
801009fe:	eb 26                	jmp    80100a26 <consoleread+0xdc>
80100a00:	eb 24                	jmp    80100a26 <consoleread+0xdc>
    }
    *dst++ = c;
80100a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a05:	8d 50 01             	lea    0x1(%eax),%edx
80100a08:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a0e:	88 10                	mov    %dl,(%eax)
    --n;
80100a10:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a14:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a18:	75 02                	jne    80100a1c <consoleread+0xd2>
      break;
80100a1a:	eb 0a                	jmp    80100a26 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a20:	0f 8f 4c ff ff ff    	jg     80100972 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100a26:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a2d:	e8 0d 47 00 00       	call   8010513f <release>
  ilock(ip);
80100a32:	8b 45 08             	mov    0x8(%ebp),%eax
80100a35:	89 04 24             	mov    %eax,(%esp)
80100a38:	e8 97 0e 00 00       	call   801018d4 <ilock>

  return target - n;
80100a3d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	29 c2                	sub    %eax,%edx
80100a45:	89 d0                	mov    %edx,%eax
}
80100a47:	c9                   	leave  
80100a48:	c3                   	ret    

80100a49 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a49:	55                   	push   %ebp
80100a4a:	89 e5                	mov    %esp,%ebp
80100a4c:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80100a52:	89 04 24             	mov    %eax,(%esp)
80100a55:	e8 ce 0f 00 00       	call   80101a28 <iunlock>
  acquire(&cons.lock);
80100a5a:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a61:	e8 77 46 00 00       	call   801050dd <acquire>
  for(i = 0; i < n; i++)
80100a66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a6d:	eb 1d                	jmp    80100a8c <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a75:	01 d0                	add    %edx,%eax
80100a77:	0f b6 00             	movzbl (%eax),%eax
80100a7a:	0f be c0             	movsbl %al,%eax
80100a7d:	0f b6 c0             	movzbl %al,%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 e3 fc ff ff       	call   8010076b <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a8f:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a92:	7c db                	jl     80100a6f <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a94:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a9b:	e8 9f 46 00 00       	call   8010513f <release>
  ilock(ip);
80100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80100aa3:	89 04 24             	mov    %eax,(%esp)
80100aa6:	e8 29 0e 00 00       	call   801018d4 <ilock>

  return n;
80100aab:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100aae:	c9                   	leave  
80100aaf:	c3                   	ret    

80100ab0 <consoleinit>:

void
consoleinit(void)
{
80100ab0:	55                   	push   %ebp
80100ab1:	89 e5                	mov    %esp,%ebp
80100ab3:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100ab6:	c7 44 24 04 36 88 10 	movl   $0x80108836,0x4(%esp)
80100abd:	80 
80100abe:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100ac5:	e8 f2 45 00 00       	call   801050bc <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aca:	c7 05 ec 11 11 80 49 	movl   $0x80100a49,0x801111ec
80100ad1:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ad4:	c7 05 e8 11 11 80 4a 	movl   $0x8010094a,0x801111e8
80100adb:	09 10 80 
  cons.locking = 1;
80100ade:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100ae5:	00 00 00 

  picenable(IRQ_KBD);
80100ae8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100aef:	e8 67 33 00 00       	call   80103e5b <picenable>
  ioapicenable(IRQ_KBD, 0);
80100af4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100afb:	00 
80100afc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b03:	e8 0b 1f 00 00       	call   80102a13 <ioapicenable>
}
80100b08:	c9                   	leave  
80100b09:	c3                   	ret    

80100b0a <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b0a:	55                   	push   %ebp
80100b0b:	89 e5                	mov    %esp,%ebp
80100b0d:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b13:	e8 a4 29 00 00       	call   801034bc <begin_op>
  if((ip = namei(path)) == 0){
80100b18:	8b 45 08             	mov    0x8(%ebp),%eax
80100b1b:	89 04 24             	mov    %eax,(%esp)
80100b1e:	e8 62 19 00 00       	call   80102485 <namei>
80100b23:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b26:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b2a:	75 0f                	jne    80100b3b <exec+0x31>
    end_op();
80100b2c:	e8 0f 2a 00 00       	call   80103540 <end_op>
    return -1;
80100b31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b36:	e9 e8 03 00 00       	jmp    80100f23 <exec+0x419>
  }
  ilock(ip);
80100b3b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b3e:	89 04 24             	mov    %eax,(%esp)
80100b41:	e8 8e 0d 00 00       	call   801018d4 <ilock>
  pgdir = 0;
80100b46:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b4d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b54:	00 
80100b55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b5c:	00 
80100b5d:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b63:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b67:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b6a:	89 04 24             	mov    %eax,(%esp)
80100b6d:	e8 75 12 00 00       	call   80101de7 <readi>
80100b72:	83 f8 33             	cmp    $0x33,%eax
80100b75:	77 05                	ja     80100b7c <exec+0x72>
    goto bad;
80100b77:	e9 7b 03 00 00       	jmp    80100ef7 <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
80100b7c:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b82:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b87:	74 05                	je     80100b8e <exec+0x84>
    goto bad;
80100b89:	e9 69 03 00 00       	jmp    80100ef7 <exec+0x3ed>

  if((pgdir = setupkvm()) == 0)
80100b8e:	e8 d7 73 00 00       	call   80107f6a <setupkvm>
80100b93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b96:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b9a:	75 05                	jne    80100ba1 <exec+0x97>
    goto bad;
80100b9c:	e9 56 03 00 00       	jmp    80100ef7 <exec+0x3ed>

  // Load program into memory.
  sz = 0;
80100ba1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ba8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100baf:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bb5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bb8:	e9 cb 00 00 00       	jmp    80100c88 <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bc0:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bc7:	00 
80100bc8:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bcc:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bd6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bd9:	89 04 24             	mov    %eax,(%esp)
80100bdc:	e8 06 12 00 00       	call   80101de7 <readi>
80100be1:	83 f8 20             	cmp    $0x20,%eax
80100be4:	74 05                	je     80100beb <exec+0xe1>
      goto bad;
80100be6:	e9 0c 03 00 00       	jmp    80100ef7 <exec+0x3ed>
    if(ph.type != ELF_PROG_LOAD)
80100beb:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bf1:	83 f8 01             	cmp    $0x1,%eax
80100bf4:	74 05                	je     80100bfb <exec+0xf1>
      continue;
80100bf6:	e9 80 00 00 00       	jmp    80100c7b <exec+0x171>
    if(ph.memsz < ph.filesz)
80100bfb:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c01:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c07:	39 c2                	cmp    %eax,%edx
80100c09:	73 05                	jae    80100c10 <exec+0x106>
      goto bad;
80100c0b:	e9 e7 02 00 00       	jmp    80100ef7 <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c10:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c16:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c1c:	01 d0                	add    %edx,%eax
80100c1e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c25:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c2c:	89 04 24             	mov    %eax,(%esp)
80100c2f:	e8 04 77 00 00       	call   80108338 <allocuvm>
80100c34:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c37:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c3b:	75 05                	jne    80100c42 <exec+0x138>
      goto bad;
80100c3d:	e9 b5 02 00 00       	jmp    80100ef7 <exec+0x3ed>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c42:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c48:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c4e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c54:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c58:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c5c:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c5f:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c63:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c67:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c6a:	89 04 24             	mov    %eax,(%esp)
80100c6d:	e8 db 75 00 00       	call   8010824d <loaduvm>
80100c72:	85 c0                	test   %eax,%eax
80100c74:	79 05                	jns    80100c7b <exec+0x171>
      goto bad;
80100c76:	e9 7c 02 00 00       	jmp    80100ef7 <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c7b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c82:	83 c0 20             	add    $0x20,%eax
80100c85:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c88:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c8f:	0f b7 c0             	movzwl %ax,%eax
80100c92:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c95:	0f 8f 22 ff ff ff    	jg     80100bbd <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c9e:	89 04 24             	mov    %eax,(%esp)
80100ca1:	e8 b8 0e 00 00       	call   80101b5e <iunlockput>
  end_op();
80100ca6:	e8 95 28 00 00       	call   80103540 <end_op>
  ip = 0;
80100cab:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb5:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc5:	05 00 20 00 00       	add    $0x2000,%eax
80100cca:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cce:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cd8:	89 04 24             	mov    %eax,(%esp)
80100cdb:	e8 58 76 00 00       	call   80108338 <allocuvm>
80100ce0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ce3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ce7:	75 05                	jne    80100cee <exec+0x1e4>
    goto bad;
80100ce9:	e9 09 02 00 00       	jmp    80100ef7 <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf1:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cfa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cfd:	89 04 24             	mov    %eax,(%esp)
80100d00:	e8 63 78 00 00       	call   80108568 <clearpteu>
  sp = sz;
80100d05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d08:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d0b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d12:	e9 9a 00 00 00       	jmp    80100db1 <exec+0x2a7>
    if(argc >= MAXARG)
80100d17:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d1b:	76 05                	jbe    80100d22 <exec+0x218>
      goto bad;
80100d1d:	e9 d5 01 00 00       	jmp    80100ef7 <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d2f:	01 d0                	add    %edx,%eax
80100d31:	8b 00                	mov    (%eax),%eax
80100d33:	89 04 24             	mov    %eax,(%esp)
80100d36:	e8 60 48 00 00       	call   8010559b <strlen>
80100d3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d3e:	29 c2                	sub    %eax,%edx
80100d40:	89 d0                	mov    %edx,%eax
80100d42:	83 e8 01             	sub    $0x1,%eax
80100d45:	83 e0 fc             	and    $0xfffffffc,%eax
80100d48:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d55:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d58:	01 d0                	add    %edx,%eax
80100d5a:	8b 00                	mov    (%eax),%eax
80100d5c:	89 04 24             	mov    %eax,(%esp)
80100d5f:	e8 37 48 00 00       	call   8010559b <strlen>
80100d64:	83 c0 01             	add    $0x1,%eax
80100d67:	89 c2                	mov    %eax,%edx
80100d69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d73:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d76:	01 c8                	add    %ecx,%eax
80100d78:	8b 00                	mov    (%eax),%eax
80100d7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d82:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d85:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d89:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d8c:	89 04 24             	mov    %eax,(%esp)
80100d8f:	e8 99 79 00 00       	call   8010872d <copyout>
80100d94:	85 c0                	test   %eax,%eax
80100d96:	79 05                	jns    80100d9d <exec+0x293>
      goto bad;
80100d98:	e9 5a 01 00 00       	jmp    80100ef7 <exec+0x3ed>
    ustack[3+argc] = sp;
80100d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da0:	8d 50 03             	lea    0x3(%eax),%edx
80100da3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da6:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dad:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100db1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dbe:	01 d0                	add    %edx,%eax
80100dc0:	8b 00                	mov    (%eax),%eax
80100dc2:	85 c0                	test   %eax,%eax
80100dc4:	0f 85 4d ff ff ff    	jne    80100d17 <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcd:	83 c0 03             	add    $0x3,%eax
80100dd0:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dd7:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ddb:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100de2:	ff ff ff 
  ustack[1] = argc;
80100de5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de8:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df1:	83 c0 01             	add    $0x1,%eax
80100df4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dfb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dfe:	29 d0                	sub    %edx,%eax
80100e00:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e09:	83 c0 04             	add    $0x4,%eax
80100e0c:	c1 e0 02             	shl    $0x2,%eax
80100e0f:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e15:	83 c0 04             	add    $0x4,%eax
80100e18:	c1 e0 02             	shl    $0x2,%eax
80100e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e1f:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e25:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e29:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e33:	89 04 24             	mov    %eax,(%esp)
80100e36:	e8 f2 78 00 00       	call   8010872d <copyout>
80100e3b:	85 c0                	test   %eax,%eax
80100e3d:	79 05                	jns    80100e44 <exec+0x33a>
    goto bad;
80100e3f:	e9 b3 00 00 00       	jmp    80100ef7 <exec+0x3ed>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e44:	8b 45 08             	mov    0x8(%ebp),%eax
80100e47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e50:	eb 17                	jmp    80100e69 <exec+0x35f>
    if(*s == '/')
80100e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e55:	0f b6 00             	movzbl (%eax),%eax
80100e58:	3c 2f                	cmp    $0x2f,%al
80100e5a:	75 09                	jne    80100e65 <exec+0x35b>
      last = s+1;
80100e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5f:	83 c0 01             	add    $0x1,%eax
80100e62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6c:	0f b6 00             	movzbl (%eax),%eax
80100e6f:	84 c0                	test   %al,%al
80100e71:	75 df                	jne    80100e52 <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e79:	8d 50 74             	lea    0x74(%eax),%edx
80100e7c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e83:	00 
80100e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e87:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e8b:	89 14 24             	mov    %edx,(%esp)
80100e8e:	e8 be 46 00 00       	call   80105551 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e99:	8b 40 04             	mov    0x4(%eax),%eax
80100e9c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ea8:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eb4:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebc:	8b 40 20             	mov    0x20(%eax),%eax
80100ebf:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ec5:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ec8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ece:	8b 40 20             	mov    0x20(%eax),%eax
80100ed1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ed4:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ed7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100edd:	89 04 24             	mov    %eax,(%esp)
80100ee0:	e8 76 71 00 00       	call   8010805b <switchuvm>
  freevm(oldpgdir);
80100ee5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ee8:	89 04 24             	mov    %eax,(%esp)
80100eeb:	e8 de 75 00 00       	call   801084ce <freevm>
  return 0;
80100ef0:	b8 00 00 00 00       	mov    $0x0,%eax
80100ef5:	eb 2c                	jmp    80100f23 <exec+0x419>

 bad:
  if(pgdir)
80100ef7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100efb:	74 0b                	je     80100f08 <exec+0x3fe>
    freevm(pgdir);
80100efd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f00:	89 04 24             	mov    %eax,(%esp)
80100f03:	e8 c6 75 00 00       	call   801084ce <freevm>
  if(ip){
80100f08:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f0c:	74 10                	je     80100f1e <exec+0x414>
    iunlockput(ip);
80100f0e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f11:	89 04 24             	mov    %eax,(%esp)
80100f14:	e8 45 0c 00 00       	call   80101b5e <iunlockput>
    end_op();
80100f19:	e8 22 26 00 00       	call   80103540 <end_op>
  }
  return -1;
80100f1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f23:	c9                   	leave  
80100f24:	c3                   	ret    

80100f25 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f25:	55                   	push   %ebp
80100f26:	89 e5                	mov    %esp,%ebp
80100f28:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f2b:	c7 44 24 04 3e 88 10 	movl   $0x8010883e,0x4(%esp)
80100f32:	80 
80100f33:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f3a:	e8 7d 41 00 00       	call   801050bc <initlock>
}
80100f3f:	c9                   	leave  
80100f40:	c3                   	ret    

80100f41 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f41:	55                   	push   %ebp
80100f42:	89 e5                	mov    %esp,%ebp
80100f44:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f47:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f4e:	e8 8a 41 00 00       	call   801050dd <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f53:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80100f5a:	eb 29                	jmp    80100f85 <filealloc+0x44>
    if(f->ref == 0){
80100f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5f:	8b 40 04             	mov    0x4(%eax),%eax
80100f62:	85 c0                	test   %eax,%eax
80100f64:	75 1b                	jne    80100f81 <filealloc+0x40>
      f->ref = 1;
80100f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f69:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f70:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f77:	e8 c3 41 00 00       	call   8010513f <release>
      return f;
80100f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7f:	eb 1e                	jmp    80100f9f <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f81:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f85:	81 7d f4 d4 11 11 80 	cmpl   $0x801111d4,-0xc(%ebp)
80100f8c:	72 ce                	jb     80100f5c <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f8e:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f95:	e8 a5 41 00 00       	call   8010513f <release>
  return 0;
80100f9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f9f:	c9                   	leave  
80100fa0:	c3                   	ret    

80100fa1 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fa1:	55                   	push   %ebp
80100fa2:	89 e5                	mov    %esp,%ebp
80100fa4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fa7:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fae:	e8 2a 41 00 00       	call   801050dd <acquire>
  if(f->ref < 1)
80100fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb6:	8b 40 04             	mov    0x4(%eax),%eax
80100fb9:	85 c0                	test   %eax,%eax
80100fbb:	7f 0c                	jg     80100fc9 <filedup+0x28>
    panic("filedup");
80100fbd:	c7 04 24 45 88 10 80 	movl   $0x80108845,(%esp)
80100fc4:	e8 71 f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fcc:	8b 40 04             	mov    0x4(%eax),%eax
80100fcf:	8d 50 01             	lea    0x1(%eax),%edx
80100fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd5:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fd8:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fdf:	e8 5b 41 00 00       	call   8010513f <release>
  return f;
80100fe4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fe7:	c9                   	leave  
80100fe8:	c3                   	ret    

80100fe9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fe9:	55                   	push   %ebp
80100fea:	89 e5                	mov    %esp,%ebp
80100fec:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fef:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100ff6:	e8 e2 40 00 00       	call   801050dd <acquire>
  if(f->ref < 1)
80100ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffe:	8b 40 04             	mov    0x4(%eax),%eax
80101001:	85 c0                	test   %eax,%eax
80101003:	7f 0c                	jg     80101011 <fileclose+0x28>
    panic("fileclose");
80101005:	c7 04 24 4d 88 10 80 	movl   $0x8010884d,(%esp)
8010100c:	e8 29 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80101011:	8b 45 08             	mov    0x8(%ebp),%eax
80101014:	8b 40 04             	mov    0x4(%eax),%eax
80101017:	8d 50 ff             	lea    -0x1(%eax),%edx
8010101a:	8b 45 08             	mov    0x8(%ebp),%eax
8010101d:	89 50 04             	mov    %edx,0x4(%eax)
80101020:	8b 45 08             	mov    0x8(%ebp),%eax
80101023:	8b 40 04             	mov    0x4(%eax),%eax
80101026:	85 c0                	test   %eax,%eax
80101028:	7e 11                	jle    8010103b <fileclose+0x52>
    release(&ftable.lock);
8010102a:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101031:	e8 09 41 00 00       	call   8010513f <release>
80101036:	e9 82 00 00 00       	jmp    801010bd <fileclose+0xd4>
    return;
  }
  ff = *f;
8010103b:	8b 45 08             	mov    0x8(%ebp),%eax
8010103e:	8b 10                	mov    (%eax),%edx
80101040:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101043:	8b 50 04             	mov    0x4(%eax),%edx
80101046:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101049:	8b 50 08             	mov    0x8(%eax),%edx
8010104c:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010104f:	8b 50 0c             	mov    0xc(%eax),%edx
80101052:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101055:	8b 50 10             	mov    0x10(%eax),%edx
80101058:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010105b:	8b 40 14             	mov    0x14(%eax),%eax
8010105e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101061:	8b 45 08             	mov    0x8(%ebp),%eax
80101064:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010106b:	8b 45 08             	mov    0x8(%ebp),%eax
8010106e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101074:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
8010107b:	e8 bf 40 00 00       	call   8010513f <release>
  
  if(ff.type == FD_PIPE)
80101080:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101083:	83 f8 01             	cmp    $0x1,%eax
80101086:	75 18                	jne    801010a0 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101088:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010108c:	0f be d0             	movsbl %al,%edx
8010108f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101092:	89 54 24 04          	mov    %edx,0x4(%esp)
80101096:	89 04 24             	mov    %eax,(%esp)
80101099:	e8 6d 30 00 00       	call   8010410b <pipeclose>
8010109e:	eb 1d                	jmp    801010bd <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801010a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010a3:	83 f8 02             	cmp    $0x2,%eax
801010a6:	75 15                	jne    801010bd <fileclose+0xd4>
    begin_op();
801010a8:	e8 0f 24 00 00       	call   801034bc <begin_op>
    iput(ff.ip);
801010ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010b0:	89 04 24             	mov    %eax,(%esp)
801010b3:	e8 d5 09 00 00       	call   80101a8d <iput>
    end_op();
801010b8:	e8 83 24 00 00       	call   80103540 <end_op>
  }
}
801010bd:	c9                   	leave  
801010be:	c3                   	ret    

801010bf <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010bf:	55                   	push   %ebp
801010c0:	89 e5                	mov    %esp,%ebp
801010c2:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 00                	mov    (%eax),%eax
801010ca:	83 f8 02             	cmp    $0x2,%eax
801010cd:	75 38                	jne    80101107 <filestat+0x48>
    ilock(f->ip);
801010cf:	8b 45 08             	mov    0x8(%ebp),%eax
801010d2:	8b 40 10             	mov    0x10(%eax),%eax
801010d5:	89 04 24             	mov    %eax,(%esp)
801010d8:	e8 f7 07 00 00       	call   801018d4 <ilock>
    stati(f->ip, st);
801010dd:	8b 45 08             	mov    0x8(%ebp),%eax
801010e0:	8b 40 10             	mov    0x10(%eax),%eax
801010e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801010e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801010ea:	89 04 24             	mov    %eax,(%esp)
801010ed:	e8 b0 0c 00 00       	call   80101da2 <stati>
    iunlock(f->ip);
801010f2:	8b 45 08             	mov    0x8(%ebp),%eax
801010f5:	8b 40 10             	mov    0x10(%eax),%eax
801010f8:	89 04 24             	mov    %eax,(%esp)
801010fb:	e8 28 09 00 00       	call   80101a28 <iunlock>
    return 0;
80101100:	b8 00 00 00 00       	mov    $0x0,%eax
80101105:	eb 05                	jmp    8010110c <filestat+0x4d>
  }
  return -1;
80101107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010110c:	c9                   	leave  
8010110d:	c3                   	ret    

8010110e <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010110e:	55                   	push   %ebp
8010110f:	89 e5                	mov    %esp,%ebp
80101111:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101114:	8b 45 08             	mov    0x8(%ebp),%eax
80101117:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010111b:	84 c0                	test   %al,%al
8010111d:	75 0a                	jne    80101129 <fileread+0x1b>
    return -1;
8010111f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101124:	e9 9f 00 00 00       	jmp    801011c8 <fileread+0xba>
  if(f->type == FD_PIPE)
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	8b 00                	mov    (%eax),%eax
8010112e:	83 f8 01             	cmp    $0x1,%eax
80101131:	75 1e                	jne    80101151 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101133:	8b 45 08             	mov    0x8(%ebp),%eax
80101136:	8b 40 0c             	mov    0xc(%eax),%eax
80101139:	8b 55 10             	mov    0x10(%ebp),%edx
8010113c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101140:	8b 55 0c             	mov    0xc(%ebp),%edx
80101143:	89 54 24 04          	mov    %edx,0x4(%esp)
80101147:	89 04 24             	mov    %eax,(%esp)
8010114a:	e8 3d 31 00 00       	call   8010428c <piperead>
8010114f:	eb 77                	jmp    801011c8 <fileread+0xba>
  if(f->type == FD_INODE){
80101151:	8b 45 08             	mov    0x8(%ebp),%eax
80101154:	8b 00                	mov    (%eax),%eax
80101156:	83 f8 02             	cmp    $0x2,%eax
80101159:	75 61                	jne    801011bc <fileread+0xae>
    ilock(f->ip);
8010115b:	8b 45 08             	mov    0x8(%ebp),%eax
8010115e:	8b 40 10             	mov    0x10(%eax),%eax
80101161:	89 04 24             	mov    %eax,(%esp)
80101164:	e8 6b 07 00 00       	call   801018d4 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101169:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010116c:	8b 45 08             	mov    0x8(%ebp),%eax
8010116f:	8b 50 14             	mov    0x14(%eax),%edx
80101172:	8b 45 08             	mov    0x8(%ebp),%eax
80101175:	8b 40 10             	mov    0x10(%eax),%eax
80101178:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010117c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101180:	8b 55 0c             	mov    0xc(%ebp),%edx
80101183:	89 54 24 04          	mov    %edx,0x4(%esp)
80101187:	89 04 24             	mov    %eax,(%esp)
8010118a:	e8 58 0c 00 00       	call   80101de7 <readi>
8010118f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101192:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101196:	7e 11                	jle    801011a9 <fileread+0x9b>
      f->off += r;
80101198:	8b 45 08             	mov    0x8(%ebp),%eax
8010119b:	8b 50 14             	mov    0x14(%eax),%edx
8010119e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011a1:	01 c2                	add    %eax,%edx
801011a3:	8b 45 08             	mov    0x8(%ebp),%eax
801011a6:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011a9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ac:	8b 40 10             	mov    0x10(%eax),%eax
801011af:	89 04 24             	mov    %eax,(%esp)
801011b2:	e8 71 08 00 00       	call   80101a28 <iunlock>
    return r;
801011b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011ba:	eb 0c                	jmp    801011c8 <fileread+0xba>
  }
  panic("fileread");
801011bc:	c7 04 24 57 88 10 80 	movl   $0x80108857,(%esp)
801011c3:	e8 72 f3 ff ff       	call   8010053a <panic>
}
801011c8:	c9                   	leave  
801011c9:	c3                   	ret    

801011ca <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011ca:	55                   	push   %ebp
801011cb:	89 e5                	mov    %esp,%ebp
801011cd:	53                   	push   %ebx
801011ce:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011d1:	8b 45 08             	mov    0x8(%ebp),%eax
801011d4:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011d8:	84 c0                	test   %al,%al
801011da:	75 0a                	jne    801011e6 <filewrite+0x1c>
    return -1;
801011dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011e1:	e9 20 01 00 00       	jmp    80101306 <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	8b 00                	mov    (%eax),%eax
801011eb:	83 f8 01             	cmp    $0x1,%eax
801011ee:	75 21                	jne    80101211 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 40 0c             	mov    0xc(%eax),%eax
801011f6:	8b 55 10             	mov    0x10(%ebp),%edx
801011f9:	89 54 24 08          	mov    %edx,0x8(%esp)
801011fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101200:	89 54 24 04          	mov    %edx,0x4(%esp)
80101204:	89 04 24             	mov    %eax,(%esp)
80101207:	e8 91 2f 00 00       	call   8010419d <pipewrite>
8010120c:	e9 f5 00 00 00       	jmp    80101306 <filewrite+0x13c>
  if(f->type == FD_INODE){
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	8b 00                	mov    (%eax),%eax
80101216:	83 f8 02             	cmp    $0x2,%eax
80101219:	0f 85 db 00 00 00    	jne    801012fa <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010121f:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101226:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010122d:	e9 a8 00 00 00       	jmp    801012da <filewrite+0x110>
      int n1 = n - i;
80101232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101235:	8b 55 10             	mov    0x10(%ebp),%edx
80101238:	29 c2                	sub    %eax,%edx
8010123a:	89 d0                	mov    %edx,%eax
8010123c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010123f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101242:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101245:	7e 06                	jle    8010124d <filewrite+0x83>
        n1 = max;
80101247:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010124a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010124d:	e8 6a 22 00 00       	call   801034bc <begin_op>
      ilock(f->ip);
80101252:	8b 45 08             	mov    0x8(%ebp),%eax
80101255:	8b 40 10             	mov    0x10(%eax),%eax
80101258:	89 04 24             	mov    %eax,(%esp)
8010125b:	e8 74 06 00 00       	call   801018d4 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101260:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101263:	8b 45 08             	mov    0x8(%ebp),%eax
80101266:	8b 50 14             	mov    0x14(%eax),%edx
80101269:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010126c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010126f:	01 c3                	add    %eax,%ebx
80101271:	8b 45 08             	mov    0x8(%ebp),%eax
80101274:	8b 40 10             	mov    0x10(%eax),%eax
80101277:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010127b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010127f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101283:	89 04 24             	mov    %eax,(%esp)
80101286:	e8 c0 0c 00 00       	call   80101f4b <writei>
8010128b:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010128e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101292:	7e 11                	jle    801012a5 <filewrite+0xdb>
        f->off += r;
80101294:	8b 45 08             	mov    0x8(%ebp),%eax
80101297:	8b 50 14             	mov    0x14(%eax),%edx
8010129a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010129d:	01 c2                	add    %eax,%edx
8010129f:	8b 45 08             	mov    0x8(%ebp),%eax
801012a2:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012a5:	8b 45 08             	mov    0x8(%ebp),%eax
801012a8:	8b 40 10             	mov    0x10(%eax),%eax
801012ab:	89 04 24             	mov    %eax,(%esp)
801012ae:	e8 75 07 00 00       	call   80101a28 <iunlock>
      end_op();
801012b3:	e8 88 22 00 00       	call   80103540 <end_op>

      if(r < 0)
801012b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012bc:	79 02                	jns    801012c0 <filewrite+0xf6>
        break;
801012be:	eb 26                	jmp    801012e6 <filewrite+0x11c>
      if(r != n1)
801012c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012c6:	74 0c                	je     801012d4 <filewrite+0x10a>
        panic("short filewrite");
801012c8:	c7 04 24 60 88 10 80 	movl   $0x80108860,(%esp)
801012cf:	e8 66 f2 ff ff       	call   8010053a <panic>
      i += r;
801012d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012d7:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012dd:	3b 45 10             	cmp    0x10(%ebp),%eax
801012e0:	0f 8c 4c ff ff ff    	jl     80101232 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e9:	3b 45 10             	cmp    0x10(%ebp),%eax
801012ec:	75 05                	jne    801012f3 <filewrite+0x129>
801012ee:	8b 45 10             	mov    0x10(%ebp),%eax
801012f1:	eb 05                	jmp    801012f8 <filewrite+0x12e>
801012f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f8:	eb 0c                	jmp    80101306 <filewrite+0x13c>
  }
  panic("filewrite");
801012fa:	c7 04 24 70 88 10 80 	movl   $0x80108870,(%esp)
80101301:	e8 34 f2 ff ff       	call   8010053a <panic>
}
80101306:	83 c4 24             	add    $0x24,%esp
80101309:	5b                   	pop    %ebx
8010130a:	5d                   	pop    %ebp
8010130b:	c3                   	ret    

8010130c <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010130c:	55                   	push   %ebp
8010130d:	89 e5                	mov    %esp,%ebp
8010130f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010131c:	00 
8010131d:	89 04 24             	mov    %eax,(%esp)
80101320:	e8 81 ee ff ff       	call   801001a6 <bread>
80101325:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132b:	83 c0 18             	add    $0x18,%eax
8010132e:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101335:	00 
80101336:	89 44 24 04          	mov    %eax,0x4(%esp)
8010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010133d:	89 04 24             	mov    %eax,(%esp)
80101340:	e8 bb 40 00 00       	call   80105400 <memmove>
  brelse(bp);
80101345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101348:	89 04 24             	mov    %eax,(%esp)
8010134b:	e8 c7 ee ff ff       	call   80100217 <brelse>
}
80101350:	c9                   	leave  
80101351:	c3                   	ret    

80101352 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101352:	55                   	push   %ebp
80101353:	89 e5                	mov    %esp,%ebp
80101355:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101358:	8b 55 0c             	mov    0xc(%ebp),%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101362:	89 04 24             	mov    %eax,(%esp)
80101365:	e8 3c ee ff ff       	call   801001a6 <bread>
8010136a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010136d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101370:	83 c0 18             	add    $0x18,%eax
80101373:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010137a:	00 
8010137b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101382:	00 
80101383:	89 04 24             	mov    %eax,(%esp)
80101386:	e8 a6 3f 00 00       	call   80105331 <memset>
  log_write(bp);
8010138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138e:	89 04 24             	mov    %eax,(%esp)
80101391:	e8 31 23 00 00       	call   801036c7 <log_write>
  brelse(bp);
80101396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101399:	89 04 24             	mov    %eax,(%esp)
8010139c:	e8 76 ee ff ff       	call   80100217 <brelse>
}
801013a1:	c9                   	leave  
801013a2:	c3                   	ret    

801013a3 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013a3:	55                   	push   %ebp
801013a4:	89 e5                	mov    %esp,%ebp
801013a6:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801013a9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801013b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013b7:	e9 07 01 00 00       	jmp    801014c3 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
801013bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013bf:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013c5:	85 c0                	test   %eax,%eax
801013c7:	0f 48 c2             	cmovs  %edx,%eax
801013ca:	c1 f8 0c             	sar    $0xc,%eax
801013cd:	89 c2                	mov    %eax,%edx
801013cf:	a1 58 12 11 80       	mov    0x80111258,%eax
801013d4:	01 d0                	add    %edx,%eax
801013d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801013da:	8b 45 08             	mov    0x8(%ebp),%eax
801013dd:	89 04 24             	mov    %eax,(%esp)
801013e0:	e8 c1 ed ff ff       	call   801001a6 <bread>
801013e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013ef:	e9 9d 00 00 00       	jmp    80101491 <balloc+0xee>
      m = 1 << (bi % 8);
801013f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f7:	99                   	cltd   
801013f8:	c1 ea 1d             	shr    $0x1d,%edx
801013fb:	01 d0                	add    %edx,%eax
801013fd:	83 e0 07             	and    $0x7,%eax
80101400:	29 d0                	sub    %edx,%eax
80101402:	ba 01 00 00 00       	mov    $0x1,%edx
80101407:	89 c1                	mov    %eax,%ecx
80101409:	d3 e2                	shl    %cl,%edx
8010140b:	89 d0                	mov    %edx,%eax
8010140d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101413:	8d 50 07             	lea    0x7(%eax),%edx
80101416:	85 c0                	test   %eax,%eax
80101418:	0f 48 c2             	cmovs  %edx,%eax
8010141b:	c1 f8 03             	sar    $0x3,%eax
8010141e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101421:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101426:	0f b6 c0             	movzbl %al,%eax
80101429:	23 45 e8             	and    -0x18(%ebp),%eax
8010142c:	85 c0                	test   %eax,%eax
8010142e:	75 5d                	jne    8010148d <balloc+0xea>
        bp->data[bi/8] |= m;  // Mark block in use.
80101430:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101433:	8d 50 07             	lea    0x7(%eax),%edx
80101436:	85 c0                	test   %eax,%eax
80101438:	0f 48 c2             	cmovs  %edx,%eax
8010143b:	c1 f8 03             	sar    $0x3,%eax
8010143e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101441:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101446:	89 d1                	mov    %edx,%ecx
80101448:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010144b:	09 ca                	or     %ecx,%edx
8010144d:	89 d1                	mov    %edx,%ecx
8010144f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101452:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101456:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101459:	89 04 24             	mov    %eax,(%esp)
8010145c:	e8 66 22 00 00       	call   801036c7 <log_write>
        brelse(bp);
80101461:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101464:	89 04 24             	mov    %eax,(%esp)
80101467:	e8 ab ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
8010146c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101472:	01 c2                	add    %eax,%edx
80101474:	8b 45 08             	mov    0x8(%ebp),%eax
80101477:	89 54 24 04          	mov    %edx,0x4(%esp)
8010147b:	89 04 24             	mov    %eax,(%esp)
8010147e:	e8 cf fe ff ff       	call   80101352 <bzero>
        return b + bi;
80101483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101486:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101489:	01 d0                	add    %edx,%eax
8010148b:	eb 52                	jmp    801014df <balloc+0x13c>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010148d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101491:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101498:	7f 17                	jg     801014b1 <balloc+0x10e>
8010149a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a0:	01 d0                	add    %edx,%eax
801014a2:	89 c2                	mov    %eax,%edx
801014a4:	a1 40 12 11 80       	mov    0x80111240,%eax
801014a9:	39 c2                	cmp    %eax,%edx
801014ab:	0f 82 43 ff ff ff    	jb     801013f4 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014b4:	89 04 24             	mov    %eax,(%esp)
801014b7:	e8 5b ed ff ff       	call   80100217 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801014bc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014c6:	a1 40 12 11 80       	mov    0x80111240,%eax
801014cb:	39 c2                	cmp    %eax,%edx
801014cd:	0f 82 e9 fe ff ff    	jb     801013bc <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014d3:	c7 04 24 7c 88 10 80 	movl   $0x8010887c,(%esp)
801014da:	e8 5b f0 ff ff       	call   8010053a <panic>
}
801014df:	c9                   	leave  
801014e0:	c3                   	ret    

801014e1 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014e1:	55                   	push   %ebp
801014e2:	89 e5                	mov    %esp,%ebp
801014e4:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801014e7:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
801014ee:	80 
801014ef:	8b 45 08             	mov    0x8(%ebp),%eax
801014f2:	89 04 24             	mov    %eax,(%esp)
801014f5:	e8 12 fe ff ff       	call   8010130c <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801014fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801014fd:	c1 e8 0c             	shr    $0xc,%eax
80101500:	89 c2                	mov    %eax,%edx
80101502:	a1 58 12 11 80       	mov    0x80111258,%eax
80101507:	01 c2                	add    %eax,%edx
80101509:	8b 45 08             	mov    0x8(%ebp),%eax
8010150c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101510:	89 04 24             	mov    %eax,(%esp)
80101513:	e8 8e ec ff ff       	call   801001a6 <bread>
80101518:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010151b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010151e:	25 ff 0f 00 00       	and    $0xfff,%eax
80101523:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101526:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101529:	99                   	cltd   
8010152a:	c1 ea 1d             	shr    $0x1d,%edx
8010152d:	01 d0                	add    %edx,%eax
8010152f:	83 e0 07             	and    $0x7,%eax
80101532:	29 d0                	sub    %edx,%eax
80101534:	ba 01 00 00 00       	mov    $0x1,%edx
80101539:	89 c1                	mov    %eax,%ecx
8010153b:	d3 e2                	shl    %cl,%edx
8010153d:	89 d0                	mov    %edx,%eax
8010153f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101542:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101545:	8d 50 07             	lea    0x7(%eax),%edx
80101548:	85 c0                	test   %eax,%eax
8010154a:	0f 48 c2             	cmovs  %edx,%eax
8010154d:	c1 f8 03             	sar    $0x3,%eax
80101550:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101553:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101558:	0f b6 c0             	movzbl %al,%eax
8010155b:	23 45 ec             	and    -0x14(%ebp),%eax
8010155e:	85 c0                	test   %eax,%eax
80101560:	75 0c                	jne    8010156e <bfree+0x8d>
    panic("freeing free block");
80101562:	c7 04 24 92 88 10 80 	movl   $0x80108892,(%esp)
80101569:	e8 cc ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
8010156e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101571:	8d 50 07             	lea    0x7(%eax),%edx
80101574:	85 c0                	test   %eax,%eax
80101576:	0f 48 c2             	cmovs  %edx,%eax
80101579:	c1 f8 03             	sar    $0x3,%eax
8010157c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010157f:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101584:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101587:	f7 d1                	not    %ecx
80101589:	21 ca                	and    %ecx,%edx
8010158b:	89 d1                	mov    %edx,%ecx
8010158d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101590:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101597:	89 04 24             	mov    %eax,(%esp)
8010159a:	e8 28 21 00 00       	call   801036c7 <log_write>
  brelse(bp);
8010159f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a2:	89 04 24             	mov    %eax,(%esp)
801015a5:	e8 6d ec ff ff       	call   80100217 <brelse>
}
801015aa:	c9                   	leave  
801015ab:	c3                   	ret    

801015ac <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801015ac:	55                   	push   %ebp
801015ad:	89 e5                	mov    %esp,%ebp
801015af:	57                   	push   %edi
801015b0:	56                   	push   %esi
801015b1:	53                   	push   %ebx
801015b2:	83 ec 3c             	sub    $0x3c,%esp
  initlock(&icache.lock, "icache");
801015b5:	c7 44 24 04 a5 88 10 	movl   $0x801088a5,0x4(%esp)
801015bc:	80 
801015bd:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801015c4:	e8 f3 3a 00 00       	call   801050bc <initlock>
  readsb(dev, &sb);
801015c9:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
801015d0:	80 
801015d1:	8b 45 08             	mov    0x8(%ebp),%eax
801015d4:	89 04 24             	mov    %eax,(%esp)
801015d7:	e8 30 fd ff ff       	call   8010130c <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
801015dc:	a1 58 12 11 80       	mov    0x80111258,%eax
801015e1:	8b 3d 54 12 11 80    	mov    0x80111254,%edi
801015e7:	8b 35 50 12 11 80    	mov    0x80111250,%esi
801015ed:	8b 1d 4c 12 11 80    	mov    0x8011124c,%ebx
801015f3:	8b 0d 48 12 11 80    	mov    0x80111248,%ecx
801015f9:	8b 15 44 12 11 80    	mov    0x80111244,%edx
801015ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101602:	8b 15 40 12 11 80    	mov    0x80111240,%edx
80101608:	89 44 24 1c          	mov    %eax,0x1c(%esp)
8010160c:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101610:	89 74 24 14          	mov    %esi,0x14(%esp)
80101614:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101618:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010161c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010161f:	89 44 24 08          	mov    %eax,0x8(%esp)
80101623:	89 d0                	mov    %edx,%eax
80101625:	89 44 24 04          	mov    %eax,0x4(%esp)
80101629:	c7 04 24 ac 88 10 80 	movl   $0x801088ac,(%esp)
80101630:	e8 6b ed ff ff       	call   801003a0 <cprintf>
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101635:	83 c4 3c             	add    $0x3c,%esp
80101638:	5b                   	pop    %ebx
80101639:	5e                   	pop    %esi
8010163a:	5f                   	pop    %edi
8010163b:	5d                   	pop    %ebp
8010163c:	c3                   	ret    

8010163d <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010163d:	55                   	push   %ebp
8010163e:	89 e5                	mov    %esp,%ebp
80101640:	83 ec 28             	sub    $0x28,%esp
80101643:	8b 45 0c             	mov    0xc(%ebp),%eax
80101646:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010164a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101651:	e9 9e 00 00 00       	jmp    801016f4 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101659:	c1 e8 03             	shr    $0x3,%eax
8010165c:	89 c2                	mov    %eax,%edx
8010165e:	a1 54 12 11 80       	mov    0x80111254,%eax
80101663:	01 d0                	add    %edx,%eax
80101665:	89 44 24 04          	mov    %eax,0x4(%esp)
80101669:	8b 45 08             	mov    0x8(%ebp),%eax
8010166c:	89 04 24             	mov    %eax,(%esp)
8010166f:	e8 32 eb ff ff       	call   801001a6 <bread>
80101674:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101677:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167a:	8d 50 18             	lea    0x18(%eax),%edx
8010167d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101680:	83 e0 07             	and    $0x7,%eax
80101683:	c1 e0 06             	shl    $0x6,%eax
80101686:	01 d0                	add    %edx,%eax
80101688:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010168b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010168e:	0f b7 00             	movzwl (%eax),%eax
80101691:	66 85 c0             	test   %ax,%ax
80101694:	75 4f                	jne    801016e5 <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
80101696:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010169d:	00 
8010169e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016a5:	00 
801016a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016a9:	89 04 24             	mov    %eax,(%esp)
801016ac:	e8 80 3c 00 00       	call   80105331 <memset>
      dip->type = type;
801016b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016b4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801016b8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016be:	89 04 24             	mov    %eax,(%esp)
801016c1:	e8 01 20 00 00       	call   801036c7 <log_write>
      brelse(bp);
801016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c9:	89 04 24             	mov    %eax,(%esp)
801016cc:	e8 46 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801016d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801016d8:	8b 45 08             	mov    0x8(%ebp),%eax
801016db:	89 04 24             	mov    %eax,(%esp)
801016de:	e8 ed 00 00 00       	call   801017d0 <iget>
801016e3:	eb 2b                	jmp    80101710 <ialloc+0xd3>
    }
    brelse(bp);
801016e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e8:	89 04 24             	mov    %eax,(%esp)
801016eb:	e8 27 eb ff ff       	call   80100217 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016f7:	a1 48 12 11 80       	mov    0x80111248,%eax
801016fc:	39 c2                	cmp    %eax,%edx
801016fe:	0f 82 52 ff ff ff    	jb     80101656 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101704:	c7 04 24 ff 88 10 80 	movl   $0x801088ff,(%esp)
8010170b:	e8 2a ee ff ff       	call   8010053a <panic>
}
80101710:	c9                   	leave  
80101711:	c3                   	ret    

80101712 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101712:	55                   	push   %ebp
80101713:	89 e5                	mov    %esp,%ebp
80101715:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101718:	8b 45 08             	mov    0x8(%ebp),%eax
8010171b:	8b 40 04             	mov    0x4(%eax),%eax
8010171e:	c1 e8 03             	shr    $0x3,%eax
80101721:	89 c2                	mov    %eax,%edx
80101723:	a1 54 12 11 80       	mov    0x80111254,%eax
80101728:	01 c2                	add    %eax,%edx
8010172a:	8b 45 08             	mov    0x8(%ebp),%eax
8010172d:	8b 00                	mov    (%eax),%eax
8010172f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101733:	89 04 24             	mov    %eax,(%esp)
80101736:	e8 6b ea ff ff       	call   801001a6 <bread>
8010173b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010173e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101741:	8d 50 18             	lea    0x18(%eax),%edx
80101744:	8b 45 08             	mov    0x8(%ebp),%eax
80101747:	8b 40 04             	mov    0x4(%eax),%eax
8010174a:	83 e0 07             	and    $0x7,%eax
8010174d:	c1 e0 06             	shl    $0x6,%eax
80101750:	01 d0                	add    %edx,%eax
80101752:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101755:	8b 45 08             	mov    0x8(%ebp),%eax
80101758:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010175c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175f:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101762:	8b 45 08             	mov    0x8(%ebp),%eax
80101765:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101769:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010176c:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101770:	8b 45 08             	mov    0x8(%ebp),%eax
80101773:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177a:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010177e:	8b 45 08             	mov    0x8(%ebp),%eax
80101781:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101785:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101788:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010178c:	8b 45 08             	mov    0x8(%ebp),%eax
8010178f:	8b 50 18             	mov    0x18(%eax),%edx
80101792:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101795:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101798:	8b 45 08             	mov    0x8(%ebp),%eax
8010179b:	8d 50 1c             	lea    0x1c(%eax),%edx
8010179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a1:	83 c0 0c             	add    $0xc,%eax
801017a4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801017ab:	00 
801017ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801017b0:	89 04 24             	mov    %eax,(%esp)
801017b3:	e8 48 3c 00 00       	call   80105400 <memmove>
  log_write(bp);
801017b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017bb:	89 04 24             	mov    %eax,(%esp)
801017be:	e8 04 1f 00 00       	call   801036c7 <log_write>
  brelse(bp);
801017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c6:	89 04 24             	mov    %eax,(%esp)
801017c9:	e8 49 ea ff ff       	call   80100217 <brelse>
}
801017ce:	c9                   	leave  
801017cf:	c3                   	ret    

801017d0 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017d0:	55                   	push   %ebp
801017d1:	89 e5                	mov    %esp,%ebp
801017d3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017d6:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801017dd:	e8 fb 38 00 00       	call   801050dd <acquire>

  // Is the inode already cached?
  empty = 0;
801017e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017e9:	c7 45 f4 94 12 11 80 	movl   $0x80111294,-0xc(%ebp)
801017f0:	eb 59                	jmp    8010184b <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f5:	8b 40 08             	mov    0x8(%eax),%eax
801017f8:	85 c0                	test   %eax,%eax
801017fa:	7e 35                	jle    80101831 <iget+0x61>
801017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ff:	8b 00                	mov    (%eax),%eax
80101801:	3b 45 08             	cmp    0x8(%ebp),%eax
80101804:	75 2b                	jne    80101831 <iget+0x61>
80101806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101809:	8b 40 04             	mov    0x4(%eax),%eax
8010180c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010180f:	75 20                	jne    80101831 <iget+0x61>
      ip->ref++;
80101811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101814:	8b 40 08             	mov    0x8(%eax),%eax
80101817:	8d 50 01             	lea    0x1(%eax),%edx
8010181a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101820:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101827:	e8 13 39 00 00       	call   8010513f <release>
      return ip;
8010182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182f:	eb 6f                	jmp    801018a0 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101831:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101835:	75 10                	jne    80101847 <iget+0x77>
80101837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183a:	8b 40 08             	mov    0x8(%eax),%eax
8010183d:	85 c0                	test   %eax,%eax
8010183f:	75 06                	jne    80101847 <iget+0x77>
      empty = ip;
80101841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101844:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101847:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
8010184b:	81 7d f4 34 22 11 80 	cmpl   $0x80112234,-0xc(%ebp)
80101852:	72 9e                	jb     801017f2 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101854:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101858:	75 0c                	jne    80101866 <iget+0x96>
    panic("iget: no inodes");
8010185a:	c7 04 24 11 89 10 80 	movl   $0x80108911,(%esp)
80101861:	e8 d4 ec ff ff       	call   8010053a <panic>

  ip = empty;
80101866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101869:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010186c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186f:	8b 55 08             	mov    0x8(%ebp),%edx
80101872:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101877:	8b 55 0c             	mov    0xc(%ebp),%edx
8010187a:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010187d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101880:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101891:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101898:	e8 a2 38 00 00       	call   8010513f <release>

  return ip;
8010189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018a0:	c9                   	leave  
801018a1:	c3                   	ret    

801018a2 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018a2:	55                   	push   %ebp
801018a3:	89 e5                	mov    %esp,%ebp
801018a5:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801018a8:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801018af:	e8 29 38 00 00       	call   801050dd <acquire>
  ip->ref++;
801018b4:	8b 45 08             	mov    0x8(%ebp),%eax
801018b7:	8b 40 08             	mov    0x8(%eax),%eax
801018ba:	8d 50 01             	lea    0x1(%eax),%edx
801018bd:	8b 45 08             	mov    0x8(%ebp),%eax
801018c0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018c3:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801018ca:	e8 70 38 00 00       	call   8010513f <release>
  return ip;
801018cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801018d2:	c9                   	leave  
801018d3:	c3                   	ret    

801018d4 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801018d4:	55                   	push   %ebp
801018d5:	89 e5                	mov    %esp,%ebp
801018d7:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801018da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801018de:	74 0a                	je     801018ea <ilock+0x16>
801018e0:	8b 45 08             	mov    0x8(%ebp),%eax
801018e3:	8b 40 08             	mov    0x8(%eax),%eax
801018e6:	85 c0                	test   %eax,%eax
801018e8:	7f 0c                	jg     801018f6 <ilock+0x22>
    panic("ilock");
801018ea:	c7 04 24 21 89 10 80 	movl   $0x80108921,(%esp)
801018f1:	e8 44 ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801018f6:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801018fd:	e8 db 37 00 00       	call   801050dd <acquire>
  while(ip->flags & I_BUSY)
80101902:	eb 13                	jmp    80101917 <ilock+0x43>
    sleep(ip, &icache.lock);
80101904:	c7 44 24 04 60 12 11 	movl   $0x80111260,0x4(%esp)
8010190b:	80 
8010190c:	8b 45 08             	mov    0x8(%ebp),%eax
8010190f:	89 04 24             	mov    %eax,(%esp)
80101912:	e8 fb 32 00 00       	call   80104c12 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101917:	8b 45 08             	mov    0x8(%ebp),%eax
8010191a:	8b 40 0c             	mov    0xc(%eax),%eax
8010191d:	83 e0 01             	and    $0x1,%eax
80101920:	85 c0                	test   %eax,%eax
80101922:	75 e0                	jne    80101904 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101924:	8b 45 08             	mov    0x8(%ebp),%eax
80101927:	8b 40 0c             	mov    0xc(%eax),%eax
8010192a:	83 c8 01             	or     $0x1,%eax
8010192d:	89 c2                	mov    %eax,%edx
8010192f:	8b 45 08             	mov    0x8(%ebp),%eax
80101932:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101935:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
8010193c:	e8 fe 37 00 00       	call   8010513f <release>

  if(!(ip->flags & I_VALID)){
80101941:	8b 45 08             	mov    0x8(%ebp),%eax
80101944:	8b 40 0c             	mov    0xc(%eax),%eax
80101947:	83 e0 02             	and    $0x2,%eax
8010194a:	85 c0                	test   %eax,%eax
8010194c:	0f 85 d4 00 00 00    	jne    80101a26 <ilock+0x152>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101952:	8b 45 08             	mov    0x8(%ebp),%eax
80101955:	8b 40 04             	mov    0x4(%eax),%eax
80101958:	c1 e8 03             	shr    $0x3,%eax
8010195b:	89 c2                	mov    %eax,%edx
8010195d:	a1 54 12 11 80       	mov    0x80111254,%eax
80101962:	01 c2                	add    %eax,%edx
80101964:	8b 45 08             	mov    0x8(%ebp),%eax
80101967:	8b 00                	mov    (%eax),%eax
80101969:	89 54 24 04          	mov    %edx,0x4(%esp)
8010196d:	89 04 24             	mov    %eax,(%esp)
80101970:	e8 31 e8 ff ff       	call   801001a6 <bread>
80101975:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197b:	8d 50 18             	lea    0x18(%eax),%edx
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	8b 40 04             	mov    0x4(%eax),%eax
80101984:	83 e0 07             	and    $0x7,%eax
80101987:	c1 e0 06             	shl    $0x6,%eax
8010198a:	01 d0                	add    %edx,%eax
8010198c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010198f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101992:	0f b7 10             	movzwl (%eax),%edx
80101995:	8b 45 08             	mov    0x8(%ebp),%eax
80101998:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010199c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019a3:	8b 45 08             	mov    0x8(%ebp),%eax
801019a6:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ad:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019b1:	8b 45 08             	mov    0x8(%ebp),%eax
801019b4:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bb:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019bf:	8b 45 08             	mov    0x8(%ebp),%eax
801019c2:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801019c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c9:	8b 50 08             	mov    0x8(%eax),%edx
801019cc:	8b 45 08             	mov    0x8(%ebp),%eax
801019cf:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d5:	8d 50 0c             	lea    0xc(%eax),%edx
801019d8:	8b 45 08             	mov    0x8(%ebp),%eax
801019db:	83 c0 1c             	add    $0x1c,%eax
801019de:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019e5:	00 
801019e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801019ea:	89 04 24             	mov    %eax,(%esp)
801019ed:	e8 0e 3a 00 00       	call   80105400 <memmove>
    brelse(bp);
801019f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f5:	89 04 24             	mov    %eax,(%esp)
801019f8:	e8 1a e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
801019fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101a00:	8b 40 0c             	mov    0xc(%eax),%eax
80101a03:	83 c8 02             	or     $0x2,%eax
80101a06:	89 c2                	mov    %eax,%edx
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a15:	66 85 c0             	test   %ax,%ax
80101a18:	75 0c                	jne    80101a26 <ilock+0x152>
      panic("ilock: no type");
80101a1a:	c7 04 24 27 89 10 80 	movl   $0x80108927,(%esp)
80101a21:	e8 14 eb ff ff       	call   8010053a <panic>
  }
}
80101a26:	c9                   	leave  
80101a27:	c3                   	ret    

80101a28 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a28:	55                   	push   %ebp
80101a29:	89 e5                	mov    %esp,%ebp
80101a2b:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a2e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a32:	74 17                	je     80101a4b <iunlock+0x23>
80101a34:	8b 45 08             	mov    0x8(%ebp),%eax
80101a37:	8b 40 0c             	mov    0xc(%eax),%eax
80101a3a:	83 e0 01             	and    $0x1,%eax
80101a3d:	85 c0                	test   %eax,%eax
80101a3f:	74 0a                	je     80101a4b <iunlock+0x23>
80101a41:	8b 45 08             	mov    0x8(%ebp),%eax
80101a44:	8b 40 08             	mov    0x8(%eax),%eax
80101a47:	85 c0                	test   %eax,%eax
80101a49:	7f 0c                	jg     80101a57 <iunlock+0x2f>
    panic("iunlock");
80101a4b:	c7 04 24 36 89 10 80 	movl   $0x80108936,(%esp)
80101a52:	e8 e3 ea ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
80101a57:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101a5e:	e8 7a 36 00 00       	call   801050dd <acquire>
  ip->flags &= ~I_BUSY;
80101a63:	8b 45 08             	mov    0x8(%ebp),%eax
80101a66:	8b 40 0c             	mov    0xc(%eax),%eax
80101a69:	83 e0 fe             	and    $0xfffffffe,%eax
80101a6c:	89 c2                	mov    %eax,%edx
80101a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a71:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a74:	8b 45 08             	mov    0x8(%ebp),%eax
80101a77:	89 04 24             	mov    %eax,(%esp)
80101a7a:	e8 6f 32 00 00       	call   80104cee <wakeup>
  release(&icache.lock);
80101a7f:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101a86:	e8 b4 36 00 00       	call   8010513f <release>
}
80101a8b:	c9                   	leave  
80101a8c:	c3                   	ret    

80101a8d <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a8d:	55                   	push   %ebp
80101a8e:	89 e5                	mov    %esp,%ebp
80101a90:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a93:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101a9a:	e8 3e 36 00 00       	call   801050dd <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa2:	8b 40 08             	mov    0x8(%eax),%eax
80101aa5:	83 f8 01             	cmp    $0x1,%eax
80101aa8:	0f 85 93 00 00 00    	jne    80101b41 <iput+0xb4>
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	8b 40 0c             	mov    0xc(%eax),%eax
80101ab4:	83 e0 02             	and    $0x2,%eax
80101ab7:	85 c0                	test   %eax,%eax
80101ab9:	0f 84 82 00 00 00    	je     80101b41 <iput+0xb4>
80101abf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101ac6:	66 85 c0             	test   %ax,%ax
80101ac9:	75 76                	jne    80101b41 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	8b 40 0c             	mov    0xc(%eax),%eax
80101ad1:	83 e0 01             	and    $0x1,%eax
80101ad4:	85 c0                	test   %eax,%eax
80101ad6:	74 0c                	je     80101ae4 <iput+0x57>
      panic("iput busy");
80101ad8:	c7 04 24 3e 89 10 80 	movl   $0x8010893e,(%esp)
80101adf:	e8 56 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	8b 40 0c             	mov    0xc(%eax),%eax
80101aea:	83 c8 01             	or     $0x1,%eax
80101aed:	89 c2                	mov    %eax,%edx
80101aef:	8b 45 08             	mov    0x8(%ebp),%eax
80101af2:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101af5:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101afc:	e8 3e 36 00 00       	call   8010513f <release>
    itrunc(ip);
80101b01:	8b 45 08             	mov    0x8(%ebp),%eax
80101b04:	89 04 24             	mov    %eax,(%esp)
80101b07:	e8 7d 01 00 00       	call   80101c89 <itrunc>
    ip->type = 0;
80101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0f:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
80101b18:	89 04 24             	mov    %eax,(%esp)
80101b1b:	e8 f2 fb ff ff       	call   80101712 <iupdate>
    acquire(&icache.lock);
80101b20:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101b27:	e8 b1 35 00 00       	call   801050dd <acquire>
    ip->flags = 0;
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	89 04 24             	mov    %eax,(%esp)
80101b3c:	e8 ad 31 00 00       	call   80104cee <wakeup>
  }
  ip->ref--;
80101b41:	8b 45 08             	mov    0x8(%ebp),%eax
80101b44:	8b 40 08             	mov    0x8(%eax),%eax
80101b47:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b50:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101b57:	e8 e3 35 00 00       	call   8010513f <release>
}
80101b5c:	c9                   	leave  
80101b5d:	c3                   	ret    

80101b5e <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b5e:	55                   	push   %ebp
80101b5f:	89 e5                	mov    %esp,%ebp
80101b61:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	89 04 24             	mov    %eax,(%esp)
80101b6a:	e8 b9 fe ff ff       	call   80101a28 <iunlock>
  iput(ip);
80101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b72:	89 04 24             	mov    %eax,(%esp)
80101b75:	e8 13 ff ff ff       	call   80101a8d <iput>
}
80101b7a:	c9                   	leave  
80101b7b:	c3                   	ret    

80101b7c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b7c:	55                   	push   %ebp
80101b7d:	89 e5                	mov    %esp,%ebp
80101b7f:	53                   	push   %ebx
80101b80:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b83:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b87:	77 3e                	ja     80101bc7 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b8f:	83 c2 04             	add    $0x4,%edx
80101b92:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b9d:	75 20                	jne    80101bbf <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba2:	8b 00                	mov    (%eax),%eax
80101ba4:	89 04 24             	mov    %eax,(%esp)
80101ba7:	e8 f7 f7 ff ff       	call   801013a3 <balloc>
80101bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101baf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bb5:	8d 4a 04             	lea    0x4(%edx),%ecx
80101bb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bbb:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc2:	e9 bc 00 00 00       	jmp    80101c83 <bmap+0x107>
  }
  bn -= NDIRECT;
80101bc7:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101bcb:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101bcf:	0f 87 a2 00 00 00    	ja     80101c77 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101be2:	75 19                	jne    80101bfd <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101be4:	8b 45 08             	mov    0x8(%ebp),%eax
80101be7:	8b 00                	mov    (%eax),%eax
80101be9:	89 04 24             	mov    %eax,(%esp)
80101bec:	e8 b2 f7 ff ff       	call   801013a3 <balloc>
80101bf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bfa:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101c00:	8b 00                	mov    (%eax),%eax
80101c02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c05:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c09:	89 04 24             	mov    %eax,(%esp)
80101c0c:	e8 95 e5 ff ff       	call   801001a6 <bread>
80101c11:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c17:	83 c0 18             	add    $0x18,%eax
80101c1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c2a:	01 d0                	add    %edx,%eax
80101c2c:	8b 00                	mov    (%eax),%eax
80101c2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c35:	75 30                	jne    80101c67 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101c37:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c44:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101c47:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4a:	8b 00                	mov    (%eax),%eax
80101c4c:	89 04 24             	mov    %eax,(%esp)
80101c4f:	e8 4f f7 ff ff       	call   801013a3 <balloc>
80101c54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5a:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c5f:	89 04 24             	mov    %eax,(%esp)
80101c62:	e8 60 1a 00 00       	call   801036c7 <log_write>
    }
    brelse(bp);
80101c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c6a:	89 04 24             	mov    %eax,(%esp)
80101c6d:	e8 a5 e5 ff ff       	call   80100217 <brelse>
    return addr;
80101c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c75:	eb 0c                	jmp    80101c83 <bmap+0x107>
  }

  panic("bmap: out of range");
80101c77:	c7 04 24 48 89 10 80 	movl   $0x80108948,(%esp)
80101c7e:	e8 b7 e8 ff ff       	call   8010053a <panic>
}
80101c83:	83 c4 24             	add    $0x24,%esp
80101c86:	5b                   	pop    %ebx
80101c87:	5d                   	pop    %ebp
80101c88:	c3                   	ret    

80101c89 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c89:	55                   	push   %ebp
80101c8a:	89 e5                	mov    %esp,%ebp
80101c8c:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c96:	eb 44                	jmp    80101cdc <itrunc+0x53>
    if(ip->addrs[i]){
80101c98:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c9e:	83 c2 04             	add    $0x4,%edx
80101ca1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ca5:	85 c0                	test   %eax,%eax
80101ca7:	74 2f                	je     80101cd8 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cac:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101caf:	83 c2 04             	add    $0x4,%edx
80101cb2:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cbf:	89 04 24             	mov    %eax,(%esp)
80101cc2:	e8 1a f8 ff ff       	call   801014e1 <bfree>
      ip->addrs[i] = 0;
80101cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ccd:	83 c2 04             	add    $0x4,%edx
80101cd0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101cd7:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101cd8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101cdc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ce0:	7e b6                	jle    80101c98 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ce8:	85 c0                	test   %eax,%eax
80101cea:	0f 84 9b 00 00 00    	je     80101d8b <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	8b 00                	mov    (%eax),%eax
80101cfb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cff:	89 04 24             	mov    %eax,(%esp)
80101d02:	e8 9f e4 ff ff       	call   801001a6 <bread>
80101d07:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d0d:	83 c0 18             	add    $0x18,%eax
80101d10:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d1a:	eb 3b                	jmp    80101d57 <itrunc+0xce>
      if(a[j])
80101d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d29:	01 d0                	add    %edx,%eax
80101d2b:	8b 00                	mov    (%eax),%eax
80101d2d:	85 c0                	test   %eax,%eax
80101d2f:	74 22                	je     80101d53 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d3e:	01 d0                	add    %edx,%eax
80101d40:	8b 10                	mov    (%eax),%edx
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 00                	mov    (%eax),%eax
80101d47:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d4b:	89 04 24             	mov    %eax,(%esp)
80101d4e:	e8 8e f7 ff ff       	call   801014e1 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101d53:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d5a:	83 f8 7f             	cmp    $0x7f,%eax
80101d5d:	76 bd                	jbe    80101d1c <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101d5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d62:	89 04 24             	mov    %eax,(%esp)
80101d65:	e8 ad e4 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d70:	8b 45 08             	mov    0x8(%ebp),%eax
80101d73:	8b 00                	mov    (%eax),%eax
80101d75:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d79:	89 04 24             	mov    %eax,(%esp)
80101d7c:	e8 60 f7 ff ff       	call   801014e1 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d95:	8b 45 08             	mov    0x8(%ebp),%eax
80101d98:	89 04 24             	mov    %eax,(%esp)
80101d9b:	e8 72 f9 ff ff       	call   80101712 <iupdate>
}
80101da0:	c9                   	leave  
80101da1:	c3                   	ret    

80101da2 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101da2:	55                   	push   %ebp
80101da3:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101da5:	8b 45 08             	mov    0x8(%ebp),%eax
80101da8:	8b 00                	mov    (%eax),%eax
80101daa:	89 c2                	mov    %eax,%edx
80101dac:	8b 45 0c             	mov    0xc(%ebp),%eax
80101daf:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101db2:	8b 45 08             	mov    0x8(%ebp),%eax
80101db5:	8b 50 04             	mov    0x4(%eax),%edx
80101db8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dbb:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc1:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc8:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dd5:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddc:	8b 50 18             	mov    0x18(%eax),%edx
80101ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101de2:	89 50 10             	mov    %edx,0x10(%eax)
}
80101de5:	5d                   	pop    %ebp
80101de6:	c3                   	ret    

80101de7 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101de7:	55                   	push   %ebp
80101de8:	89 e5                	mov    %esp,%ebp
80101dea:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ded:	8b 45 08             	mov    0x8(%ebp),%eax
80101df0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101df4:	66 83 f8 03          	cmp    $0x3,%ax
80101df8:	75 60                	jne    80101e5a <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfd:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e01:	66 85 c0             	test   %ax,%ax
80101e04:	78 20                	js     80101e26 <readi+0x3f>
80101e06:	8b 45 08             	mov    0x8(%ebp),%eax
80101e09:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e0d:	66 83 f8 09          	cmp    $0x9,%ax
80101e11:	7f 13                	jg     80101e26 <readi+0x3f>
80101e13:	8b 45 08             	mov    0x8(%ebp),%eax
80101e16:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e1a:	98                   	cwtl   
80101e1b:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101e22:	85 c0                	test   %eax,%eax
80101e24:	75 0a                	jne    80101e30 <readi+0x49>
      return -1;
80101e26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e2b:	e9 19 01 00 00       	jmp    80101f49 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101e30:	8b 45 08             	mov    0x8(%ebp),%eax
80101e33:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e37:	98                   	cwtl   
80101e38:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101e3f:	8b 55 14             	mov    0x14(%ebp),%edx
80101e42:	89 54 24 08          	mov    %edx,0x8(%esp)
80101e46:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e49:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e4d:	8b 55 08             	mov    0x8(%ebp),%edx
80101e50:	89 14 24             	mov    %edx,(%esp)
80101e53:	ff d0                	call   *%eax
80101e55:	e9 ef 00 00 00       	jmp    80101f49 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5d:	8b 40 18             	mov    0x18(%eax),%eax
80101e60:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e63:	72 0d                	jb     80101e72 <readi+0x8b>
80101e65:	8b 45 14             	mov    0x14(%ebp),%eax
80101e68:	8b 55 10             	mov    0x10(%ebp),%edx
80101e6b:	01 d0                	add    %edx,%eax
80101e6d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e70:	73 0a                	jae    80101e7c <readi+0x95>
    return -1;
80101e72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e77:	e9 cd 00 00 00       	jmp    80101f49 <readi+0x162>
  if(off + n > ip->size)
80101e7c:	8b 45 14             	mov    0x14(%ebp),%eax
80101e7f:	8b 55 10             	mov    0x10(%ebp),%edx
80101e82:	01 c2                	add    %eax,%edx
80101e84:	8b 45 08             	mov    0x8(%ebp),%eax
80101e87:	8b 40 18             	mov    0x18(%eax),%eax
80101e8a:	39 c2                	cmp    %eax,%edx
80101e8c:	76 0c                	jbe    80101e9a <readi+0xb3>
    n = ip->size - off;
80101e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e91:	8b 40 18             	mov    0x18(%eax),%eax
80101e94:	2b 45 10             	sub    0x10(%ebp),%eax
80101e97:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ea1:	e9 94 00 00 00       	jmp    80101f3a <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ea6:	8b 45 10             	mov    0x10(%ebp),%eax
80101ea9:	c1 e8 09             	shr    $0x9,%eax
80101eac:	89 44 24 04          	mov    %eax,0x4(%esp)
80101eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb3:	89 04 24             	mov    %eax,(%esp)
80101eb6:	e8 c1 fc ff ff       	call   80101b7c <bmap>
80101ebb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ebe:	8b 12                	mov    (%edx),%edx
80101ec0:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ec4:	89 14 24             	mov    %edx,(%esp)
80101ec7:	e8 da e2 ff ff       	call   801001a6 <bread>
80101ecc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101ecf:	8b 45 10             	mov    0x10(%ebp),%eax
80101ed2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ed7:	89 c2                	mov    %eax,%edx
80101ed9:	b8 00 02 00 00       	mov    $0x200,%eax
80101ede:	29 d0                	sub    %edx,%eax
80101ee0:	89 c2                	mov    %eax,%edx
80101ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ee5:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101ee8:	29 c1                	sub    %eax,%ecx
80101eea:	89 c8                	mov    %ecx,%eax
80101eec:	39 c2                	cmp    %eax,%edx
80101eee:	0f 46 c2             	cmovbe %edx,%eax
80101ef1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ef4:	8b 45 10             	mov    0x10(%ebp),%eax
80101ef7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101efc:	8d 50 10             	lea    0x10(%eax),%edx
80101eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f02:	01 d0                	add    %edx,%eax
80101f04:	8d 50 08             	lea    0x8(%eax),%edx
80101f07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f0a:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f0e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f12:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f15:	89 04 24             	mov    %eax,(%esp)
80101f18:	e8 e3 34 00 00       	call   80105400 <memmove>
    brelse(bp);
80101f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f20:	89 04 24             	mov    %eax,(%esp)
80101f23:	e8 ef e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f2b:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f31:	01 45 10             	add    %eax,0x10(%ebp)
80101f34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f37:	01 45 0c             	add    %eax,0xc(%ebp)
80101f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f3d:	3b 45 14             	cmp    0x14(%ebp),%eax
80101f40:	0f 82 60 ff ff ff    	jb     80101ea6 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f46:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f49:	c9                   	leave  
80101f4a:	c3                   	ret    

80101f4b <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f4b:	55                   	push   %ebp
80101f4c:	89 e5                	mov    %esp,%ebp
80101f4e:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f51:	8b 45 08             	mov    0x8(%ebp),%eax
80101f54:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f58:	66 83 f8 03          	cmp    $0x3,%ax
80101f5c:	75 60                	jne    80101fbe <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f61:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f65:	66 85 c0             	test   %ax,%ax
80101f68:	78 20                	js     80101f8a <writei+0x3f>
80101f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f71:	66 83 f8 09          	cmp    $0x9,%ax
80101f75:	7f 13                	jg     80101f8a <writei+0x3f>
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f7e:	98                   	cwtl   
80101f7f:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f86:	85 c0                	test   %eax,%eax
80101f88:	75 0a                	jne    80101f94 <writei+0x49>
      return -1;
80101f8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f8f:	e9 44 01 00 00       	jmp    801020d8 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f94:	8b 45 08             	mov    0x8(%ebp),%eax
80101f97:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f9b:	98                   	cwtl   
80101f9c:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101fa3:	8b 55 14             	mov    0x14(%ebp),%edx
80101fa6:	89 54 24 08          	mov    %edx,0x8(%esp)
80101faa:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fad:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fb1:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb4:	89 14 24             	mov    %edx,(%esp)
80101fb7:	ff d0                	call   *%eax
80101fb9:	e9 1a 01 00 00       	jmp    801020d8 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc1:	8b 40 18             	mov    0x18(%eax),%eax
80101fc4:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fc7:	72 0d                	jb     80101fd6 <writei+0x8b>
80101fc9:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcc:	8b 55 10             	mov    0x10(%ebp),%edx
80101fcf:	01 d0                	add    %edx,%eax
80101fd1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fd4:	73 0a                	jae    80101fe0 <writei+0x95>
    return -1;
80101fd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fdb:	e9 f8 00 00 00       	jmp    801020d8 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101fe0:	8b 45 14             	mov    0x14(%ebp),%eax
80101fe3:	8b 55 10             	mov    0x10(%ebp),%edx
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101fed:	76 0a                	jbe    80101ff9 <writei+0xae>
    return -1;
80101fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ff4:	e9 df 00 00 00       	jmp    801020d8 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101ff9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102000:	e9 9f 00 00 00       	jmp    801020a4 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102005:	8b 45 10             	mov    0x10(%ebp),%eax
80102008:	c1 e8 09             	shr    $0x9,%eax
8010200b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010200f:	8b 45 08             	mov    0x8(%ebp),%eax
80102012:	89 04 24             	mov    %eax,(%esp)
80102015:	e8 62 fb ff ff       	call   80101b7c <bmap>
8010201a:	8b 55 08             	mov    0x8(%ebp),%edx
8010201d:	8b 12                	mov    (%edx),%edx
8010201f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102023:	89 14 24             	mov    %edx,(%esp)
80102026:	e8 7b e1 ff ff       	call   801001a6 <bread>
8010202b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010202e:	8b 45 10             	mov    0x10(%ebp),%eax
80102031:	25 ff 01 00 00       	and    $0x1ff,%eax
80102036:	89 c2                	mov    %eax,%edx
80102038:	b8 00 02 00 00       	mov    $0x200,%eax
8010203d:	29 d0                	sub    %edx,%eax
8010203f:	89 c2                	mov    %eax,%edx
80102041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102044:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102047:	29 c1                	sub    %eax,%ecx
80102049:	89 c8                	mov    %ecx,%eax
8010204b:	39 c2                	cmp    %eax,%edx
8010204d:	0f 46 c2             	cmovbe %edx,%eax
80102050:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102053:	8b 45 10             	mov    0x10(%ebp),%eax
80102056:	25 ff 01 00 00       	and    $0x1ff,%eax
8010205b:	8d 50 10             	lea    0x10(%eax),%edx
8010205e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102061:	01 d0                	add    %edx,%eax
80102063:	8d 50 08             	lea    0x8(%eax),%edx
80102066:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102069:	89 44 24 08          	mov    %eax,0x8(%esp)
8010206d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102070:	89 44 24 04          	mov    %eax,0x4(%esp)
80102074:	89 14 24             	mov    %edx,(%esp)
80102077:	e8 84 33 00 00       	call   80105400 <memmove>
    log_write(bp);
8010207c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010207f:	89 04 24             	mov    %eax,(%esp)
80102082:	e8 40 16 00 00       	call   801036c7 <log_write>
    brelse(bp);
80102087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010208a:	89 04 24             	mov    %eax,(%esp)
8010208d:	e8 85 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102092:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102095:	01 45 f4             	add    %eax,-0xc(%ebp)
80102098:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010209b:	01 45 10             	add    %eax,0x10(%ebp)
8010209e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a1:	01 45 0c             	add    %eax,0xc(%ebp)
801020a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020a7:	3b 45 14             	cmp    0x14(%ebp),%eax
801020aa:	0f 82 55 ff ff ff    	jb     80102005 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801020b0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801020b4:	74 1f                	je     801020d5 <writei+0x18a>
801020b6:	8b 45 08             	mov    0x8(%ebp),%eax
801020b9:	8b 40 18             	mov    0x18(%eax),%eax
801020bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801020bf:	73 14                	jae    801020d5 <writei+0x18a>
    ip->size = off;
801020c1:	8b 45 08             	mov    0x8(%ebp),%eax
801020c4:	8b 55 10             	mov    0x10(%ebp),%edx
801020c7:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801020ca:	8b 45 08             	mov    0x8(%ebp),%eax
801020cd:	89 04 24             	mov    %eax,(%esp)
801020d0:	e8 3d f6 ff ff       	call   80101712 <iupdate>
  }
  return n;
801020d5:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020d8:	c9                   	leave  
801020d9:	c3                   	ret    

801020da <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801020da:	55                   	push   %ebp
801020db:	89 e5                	mov    %esp,%ebp
801020dd:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801020e0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020e7:	00 
801020e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801020eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ef:	8b 45 08             	mov    0x8(%ebp),%eax
801020f2:	89 04 24             	mov    %eax,(%esp)
801020f5:	e8 a9 33 00 00       	call   801054a3 <strncmp>
}
801020fa:	c9                   	leave  
801020fb:	c3                   	ret    

801020fc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020fc:	55                   	push   %ebp
801020fd:	89 e5                	mov    %esp,%ebp
801020ff:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102102:	8b 45 08             	mov    0x8(%ebp),%eax
80102105:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102109:	66 83 f8 01          	cmp    $0x1,%ax
8010210d:	74 0c                	je     8010211b <dirlookup+0x1f>
    panic("dirlookup not DIR");
8010210f:	c7 04 24 5b 89 10 80 	movl   $0x8010895b,(%esp)
80102116:	e8 1f e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010211b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102122:	e9 88 00 00 00       	jmp    801021af <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102127:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010212e:	00 
8010212f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102132:	89 44 24 08          	mov    %eax,0x8(%esp)
80102136:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102139:	89 44 24 04          	mov    %eax,0x4(%esp)
8010213d:	8b 45 08             	mov    0x8(%ebp),%eax
80102140:	89 04 24             	mov    %eax,(%esp)
80102143:	e8 9f fc ff ff       	call   80101de7 <readi>
80102148:	83 f8 10             	cmp    $0x10,%eax
8010214b:	74 0c                	je     80102159 <dirlookup+0x5d>
      panic("dirlink read");
8010214d:	c7 04 24 6d 89 10 80 	movl   $0x8010896d,(%esp)
80102154:	e8 e1 e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
80102159:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010215d:	66 85 c0             	test   %ax,%ax
80102160:	75 02                	jne    80102164 <dirlookup+0x68>
      continue;
80102162:	eb 47                	jmp    801021ab <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
80102164:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102167:	83 c0 02             	add    $0x2,%eax
8010216a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010216e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102171:	89 04 24             	mov    %eax,(%esp)
80102174:	e8 61 ff ff ff       	call   801020da <namecmp>
80102179:	85 c0                	test   %eax,%eax
8010217b:	75 2e                	jne    801021ab <dirlookup+0xaf>
      // entry matches path element
      if(poff)
8010217d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102181:	74 08                	je     8010218b <dirlookup+0x8f>
        *poff = off;
80102183:	8b 45 10             	mov    0x10(%ebp),%eax
80102186:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102189:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010218b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010218f:	0f b7 c0             	movzwl %ax,%eax
80102192:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 00                	mov    (%eax),%eax
8010219a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010219d:	89 54 24 04          	mov    %edx,0x4(%esp)
801021a1:	89 04 24             	mov    %eax,(%esp)
801021a4:	e8 27 f6 ff ff       	call   801017d0 <iget>
801021a9:	eb 18                	jmp    801021c3 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ab:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801021af:	8b 45 08             	mov    0x8(%ebp),%eax
801021b2:	8b 40 18             	mov    0x18(%eax),%eax
801021b5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801021b8:	0f 87 69 ff ff ff    	ja     80102127 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801021be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801021c3:	c9                   	leave  
801021c4:	c3                   	ret    

801021c5 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801021c5:	55                   	push   %ebp
801021c6:	89 e5                	mov    %esp,%ebp
801021c8:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801021cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801021d2:	00 
801021d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801021d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	89 04 24             	mov    %eax,(%esp)
801021e0:	e8 17 ff ff ff       	call   801020fc <dirlookup>
801021e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021ec:	74 15                	je     80102203 <dirlink+0x3e>
    iput(ip);
801021ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f1:	89 04 24             	mov    %eax,(%esp)
801021f4:	e8 94 f8 ff ff       	call   80101a8d <iput>
    return -1;
801021f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021fe:	e9 b7 00 00 00       	jmp    801022ba <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102203:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010220a:	eb 46                	jmp    80102252 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010220c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102216:	00 
80102217:	89 44 24 08          	mov    %eax,0x8(%esp)
8010221b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010221e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102222:	8b 45 08             	mov    0x8(%ebp),%eax
80102225:	89 04 24             	mov    %eax,(%esp)
80102228:	e8 ba fb ff ff       	call   80101de7 <readi>
8010222d:	83 f8 10             	cmp    $0x10,%eax
80102230:	74 0c                	je     8010223e <dirlink+0x79>
      panic("dirlink read");
80102232:	c7 04 24 6d 89 10 80 	movl   $0x8010896d,(%esp)
80102239:	e8 fc e2 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
8010223e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102242:	66 85 c0             	test   %ax,%ax
80102245:	75 02                	jne    80102249 <dirlink+0x84>
      break;
80102247:	eb 16                	jmp    8010225f <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010224c:	83 c0 10             	add    $0x10,%eax
8010224f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102252:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 40 18             	mov    0x18(%eax),%eax
8010225b:	39 c2                	cmp    %eax,%edx
8010225d:	72 ad                	jb     8010220c <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
8010225f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102266:	00 
80102267:	8b 45 0c             	mov    0xc(%ebp),%eax
8010226a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010226e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102271:	83 c0 02             	add    $0x2,%eax
80102274:	89 04 24             	mov    %eax,(%esp)
80102277:	e8 7d 32 00 00       	call   801054f9 <strncpy>
  de.inum = inum;
8010227c:	8b 45 10             	mov    0x10(%ebp),%eax
8010227f:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102286:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010228d:	00 
8010228e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102292:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102295:	89 44 24 04          	mov    %eax,0x4(%esp)
80102299:	8b 45 08             	mov    0x8(%ebp),%eax
8010229c:	89 04 24             	mov    %eax,(%esp)
8010229f:	e8 a7 fc ff ff       	call   80101f4b <writei>
801022a4:	83 f8 10             	cmp    $0x10,%eax
801022a7:	74 0c                	je     801022b5 <dirlink+0xf0>
    panic("dirlink");
801022a9:	c7 04 24 7a 89 10 80 	movl   $0x8010897a,(%esp)
801022b0:	e8 85 e2 ff ff       	call   8010053a <panic>
  
  return 0;
801022b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022ba:	c9                   	leave  
801022bb:	c3                   	ret    

801022bc <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022bc:	55                   	push   %ebp
801022bd:	89 e5                	mov    %esp,%ebp
801022bf:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801022c2:	eb 04                	jmp    801022c8 <skipelem+0xc>
    path++;
801022c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801022c8:	8b 45 08             	mov    0x8(%ebp),%eax
801022cb:	0f b6 00             	movzbl (%eax),%eax
801022ce:	3c 2f                	cmp    $0x2f,%al
801022d0:	74 f2                	je     801022c4 <skipelem+0x8>
    path++;
  if(*path == 0)
801022d2:	8b 45 08             	mov    0x8(%ebp),%eax
801022d5:	0f b6 00             	movzbl (%eax),%eax
801022d8:	84 c0                	test   %al,%al
801022da:	75 0a                	jne    801022e6 <skipelem+0x2a>
    return 0;
801022dc:	b8 00 00 00 00       	mov    $0x0,%eax
801022e1:	e9 86 00 00 00       	jmp    8010236c <skipelem+0xb0>
  s = path;
801022e6:	8b 45 08             	mov    0x8(%ebp),%eax
801022e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022ec:	eb 04                	jmp    801022f2 <skipelem+0x36>
    path++;
801022ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801022f2:	8b 45 08             	mov    0x8(%ebp),%eax
801022f5:	0f b6 00             	movzbl (%eax),%eax
801022f8:	3c 2f                	cmp    $0x2f,%al
801022fa:	74 0a                	je     80102306 <skipelem+0x4a>
801022fc:	8b 45 08             	mov    0x8(%ebp),%eax
801022ff:	0f b6 00             	movzbl (%eax),%eax
80102302:	84 c0                	test   %al,%al
80102304:	75 e8                	jne    801022ee <skipelem+0x32>
    path++;
  len = path - s;
80102306:	8b 55 08             	mov    0x8(%ebp),%edx
80102309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230c:	29 c2                	sub    %eax,%edx
8010230e:	89 d0                	mov    %edx,%eax
80102310:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102313:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102317:	7e 1c                	jle    80102335 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
80102319:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102320:	00 
80102321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102324:	89 44 24 04          	mov    %eax,0x4(%esp)
80102328:	8b 45 0c             	mov    0xc(%ebp),%eax
8010232b:	89 04 24             	mov    %eax,(%esp)
8010232e:	e8 cd 30 00 00       	call   80105400 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102333:	eb 2a                	jmp    8010235f <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102335:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102338:	89 44 24 08          	mov    %eax,0x8(%esp)
8010233c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102343:	8b 45 0c             	mov    0xc(%ebp),%eax
80102346:	89 04 24             	mov    %eax,(%esp)
80102349:	e8 b2 30 00 00       	call   80105400 <memmove>
    name[len] = 0;
8010234e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102351:	8b 45 0c             	mov    0xc(%ebp),%eax
80102354:	01 d0                	add    %edx,%eax
80102356:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102359:	eb 04                	jmp    8010235f <skipelem+0xa3>
    path++;
8010235b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010235f:	8b 45 08             	mov    0x8(%ebp),%eax
80102362:	0f b6 00             	movzbl (%eax),%eax
80102365:	3c 2f                	cmp    $0x2f,%al
80102367:	74 f2                	je     8010235b <skipelem+0x9f>
    path++;
  return path;
80102369:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010236c:	c9                   	leave  
8010236d:	c3                   	ret    

8010236e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010236e:	55                   	push   %ebp
8010236f:	89 e5                	mov    %esp,%ebp
80102371:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	3c 2f                	cmp    $0x2f,%al
8010237c:	75 1c                	jne    8010239a <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010237e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102385:	00 
80102386:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010238d:	e8 3e f4 ff ff       	call   801017d0 <iget>
80102392:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102395:	e9 af 00 00 00       	jmp    80102449 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010239a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023a0:	8b 40 70             	mov    0x70(%eax),%eax
801023a3:	89 04 24             	mov    %eax,(%esp)
801023a6:	e8 f7 f4 ff ff       	call   801018a2 <idup>
801023ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023ae:	e9 96 00 00 00       	jmp    80102449 <namex+0xdb>
    ilock(ip);
801023b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b6:	89 04 24             	mov    %eax,(%esp)
801023b9:	e8 16 f5 ff ff       	call   801018d4 <ilock>
    if(ip->type != T_DIR){
801023be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023c5:	66 83 f8 01          	cmp    $0x1,%ax
801023c9:	74 15                	je     801023e0 <namex+0x72>
      iunlockput(ip);
801023cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ce:	89 04 24             	mov    %eax,(%esp)
801023d1:	e8 88 f7 ff ff       	call   80101b5e <iunlockput>
      return 0;
801023d6:	b8 00 00 00 00       	mov    $0x0,%eax
801023db:	e9 a3 00 00 00       	jmp    80102483 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801023e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023e4:	74 1d                	je     80102403 <namex+0x95>
801023e6:	8b 45 08             	mov    0x8(%ebp),%eax
801023e9:	0f b6 00             	movzbl (%eax),%eax
801023ec:	84 c0                	test   %al,%al
801023ee:	75 13                	jne    80102403 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801023f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f3:	89 04 24             	mov    %eax,(%esp)
801023f6:	e8 2d f6 ff ff       	call   80101a28 <iunlock>
      return ip;
801023fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023fe:	e9 80 00 00 00       	jmp    80102483 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102403:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010240a:	00 
8010240b:	8b 45 10             	mov    0x10(%ebp),%eax
8010240e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102415:	89 04 24             	mov    %eax,(%esp)
80102418:	e8 df fc ff ff       	call   801020fc <dirlookup>
8010241d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102420:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102424:	75 12                	jne    80102438 <namex+0xca>
      iunlockput(ip);
80102426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102429:	89 04 24             	mov    %eax,(%esp)
8010242c:	e8 2d f7 ff ff       	call   80101b5e <iunlockput>
      return 0;
80102431:	b8 00 00 00 00       	mov    $0x0,%eax
80102436:	eb 4b                	jmp    80102483 <namex+0x115>
    }
    iunlockput(ip);
80102438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243b:	89 04 24             	mov    %eax,(%esp)
8010243e:	e8 1b f7 ff ff       	call   80101b5e <iunlockput>
    ip = next;
80102443:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102446:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102449:	8b 45 10             	mov    0x10(%ebp),%eax
8010244c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102450:	8b 45 08             	mov    0x8(%ebp),%eax
80102453:	89 04 24             	mov    %eax,(%esp)
80102456:	e8 61 fe ff ff       	call   801022bc <skipelem>
8010245b:	89 45 08             	mov    %eax,0x8(%ebp)
8010245e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102462:	0f 85 4b ff ff ff    	jne    801023b3 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102468:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010246c:	74 12                	je     80102480 <namex+0x112>
    iput(ip);
8010246e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102471:	89 04 24             	mov    %eax,(%esp)
80102474:	e8 14 f6 ff ff       	call   80101a8d <iput>
    return 0;
80102479:	b8 00 00 00 00       	mov    $0x0,%eax
8010247e:	eb 03                	jmp    80102483 <namex+0x115>
  }
  return ip;
80102480:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102483:	c9                   	leave  
80102484:	c3                   	ret    

80102485 <namei>:

struct inode*
namei(char *path)
{
80102485:	55                   	push   %ebp
80102486:	89 e5                	mov    %esp,%ebp
80102488:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010248b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010248e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102492:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102499:	00 
8010249a:	8b 45 08             	mov    0x8(%ebp),%eax
8010249d:	89 04 24             	mov    %eax,(%esp)
801024a0:	e8 c9 fe ff ff       	call   8010236e <namex>
}
801024a5:	c9                   	leave  
801024a6:	c3                   	ret    

801024a7 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024a7:	55                   	push   %ebp
801024a8:	89 e5                	mov    %esp,%ebp
801024aa:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801024ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b0:	89 44 24 08          	mov    %eax,0x8(%esp)
801024b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024bb:	00 
801024bc:	8b 45 08             	mov    0x8(%ebp),%eax
801024bf:	89 04 24             	mov    %eax,(%esp)
801024c2:	e8 a7 fe ff ff       	call   8010236e <namex>
}
801024c7:	c9                   	leave  
801024c8:	c3                   	ret    

801024c9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801024c9:	55                   	push   %ebp
801024ca:	89 e5                	mov    %esp,%ebp
801024cc:	83 ec 14             	sub    $0x14,%esp
801024cf:	8b 45 08             	mov    0x8(%ebp),%eax
801024d2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024d6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801024da:	89 c2                	mov    %eax,%edx
801024dc:	ec                   	in     (%dx),%al
801024dd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801024e0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801024e4:	c9                   	leave  
801024e5:	c3                   	ret    

801024e6 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801024e6:	55                   	push   %ebp
801024e7:	89 e5                	mov    %esp,%ebp
801024e9:	57                   	push   %edi
801024ea:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024eb:	8b 55 08             	mov    0x8(%ebp),%edx
801024ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024f1:	8b 45 10             	mov    0x10(%ebp),%eax
801024f4:	89 cb                	mov    %ecx,%ebx
801024f6:	89 df                	mov    %ebx,%edi
801024f8:	89 c1                	mov    %eax,%ecx
801024fa:	fc                   	cld    
801024fb:	f3 6d                	rep insl (%dx),%es:(%edi)
801024fd:	89 c8                	mov    %ecx,%eax
801024ff:	89 fb                	mov    %edi,%ebx
80102501:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102504:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102507:	5b                   	pop    %ebx
80102508:	5f                   	pop    %edi
80102509:	5d                   	pop    %ebp
8010250a:	c3                   	ret    

8010250b <outb>:

static inline void
outb(ushort port, uchar data)
{
8010250b:	55                   	push   %ebp
8010250c:	89 e5                	mov    %esp,%ebp
8010250e:	83 ec 08             	sub    $0x8,%esp
80102511:	8b 55 08             	mov    0x8(%ebp),%edx
80102514:	8b 45 0c             	mov    0xc(%ebp),%eax
80102517:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010251b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010251e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102522:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102526:	ee                   	out    %al,(%dx)
}
80102527:	c9                   	leave  
80102528:	c3                   	ret    

80102529 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102529:	55                   	push   %ebp
8010252a:	89 e5                	mov    %esp,%ebp
8010252c:	56                   	push   %esi
8010252d:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010252e:	8b 55 08             	mov    0x8(%ebp),%edx
80102531:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102534:	8b 45 10             	mov    0x10(%ebp),%eax
80102537:	89 cb                	mov    %ecx,%ebx
80102539:	89 de                	mov    %ebx,%esi
8010253b:	89 c1                	mov    %eax,%ecx
8010253d:	fc                   	cld    
8010253e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102540:	89 c8                	mov    %ecx,%eax
80102542:	89 f3                	mov    %esi,%ebx
80102544:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102547:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010254a:	5b                   	pop    %ebx
8010254b:	5e                   	pop    %esi
8010254c:	5d                   	pop    %ebp
8010254d:	c3                   	ret    

8010254e <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010254e:	55                   	push   %ebp
8010254f:	89 e5                	mov    %esp,%ebp
80102551:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102554:	90                   	nop
80102555:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010255c:	e8 68 ff ff ff       	call   801024c9 <inb>
80102561:	0f b6 c0             	movzbl %al,%eax
80102564:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102567:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010256a:	25 c0 00 00 00       	and    $0xc0,%eax
8010256f:	83 f8 40             	cmp    $0x40,%eax
80102572:	75 e1                	jne    80102555 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102574:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102578:	74 11                	je     8010258b <idewait+0x3d>
8010257a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010257d:	83 e0 21             	and    $0x21,%eax
80102580:	85 c0                	test   %eax,%eax
80102582:	74 07                	je     8010258b <idewait+0x3d>
    return -1;
80102584:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102589:	eb 05                	jmp    80102590 <idewait+0x42>
  return 0;
8010258b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102590:	c9                   	leave  
80102591:	c3                   	ret    

80102592 <ideinit>:

void
ideinit(void)
{
80102592:	55                   	push   %ebp
80102593:	89 e5                	mov    %esp,%ebp
80102595:	83 ec 28             	sub    $0x28,%esp
  int i;
  
  initlock(&idelock, "ide");
80102598:	c7 44 24 04 82 89 10 	movl   $0x80108982,0x4(%esp)
8010259f:	80 
801025a0:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801025a7:	e8 10 2b 00 00       	call   801050bc <initlock>
  picenable(IRQ_IDE);
801025ac:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025b3:	e8 a3 18 00 00       	call   80103e5b <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801025b8:	a1 60 29 11 80       	mov    0x80112960,%eax
801025bd:	83 e8 01             	sub    $0x1,%eax
801025c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801025c4:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025cb:	e8 43 04 00 00       	call   80102a13 <ioapicenable>
  idewait(0);
801025d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025d7:	e8 72 ff ff ff       	call   8010254e <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025dc:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801025e3:	00 
801025e4:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025eb:	e8 1b ff ff ff       	call   8010250b <outb>
  for(i=0; i<1000; i++){
801025f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025f7:	eb 20                	jmp    80102619 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801025f9:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102600:	e8 c4 fe ff ff       	call   801024c9 <inb>
80102605:	84 c0                	test   %al,%al
80102607:	74 0c                	je     80102615 <ideinit+0x83>
      havedisk1 = 1;
80102609:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
80102610:	00 00 00 
      break;
80102613:	eb 0d                	jmp    80102622 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102615:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102619:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102620:	7e d7                	jle    801025f9 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102622:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102629:	00 
8010262a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102631:	e8 d5 fe ff ff       	call   8010250b <outb>
}
80102636:	c9                   	leave  
80102637:	c3                   	ret    

80102638 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102638:	55                   	push   %ebp
80102639:	89 e5                	mov    %esp,%ebp
8010263b:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
8010263e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102642:	75 0c                	jne    80102650 <idestart+0x18>
    panic("idestart");
80102644:	c7 04 24 86 89 10 80 	movl   $0x80108986,(%esp)
8010264b:	e8 ea de ff ff       	call   8010053a <panic>
  if(b->blockno >= FSSIZE)
80102650:	8b 45 08             	mov    0x8(%ebp),%eax
80102653:	8b 40 08             	mov    0x8(%eax),%eax
80102656:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010265b:	76 0c                	jbe    80102669 <idestart+0x31>
    panic("incorrect blockno");
8010265d:	c7 04 24 8f 89 10 80 	movl   $0x8010898f,(%esp)
80102664:	e8 d1 de ff ff       	call   8010053a <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102669:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102670:	8b 45 08             	mov    0x8(%ebp),%eax
80102673:	8b 50 08             	mov    0x8(%eax),%edx
80102676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102679:	0f af c2             	imul   %edx,%eax
8010267c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010267f:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102683:	7e 0c                	jle    80102691 <idestart+0x59>
80102685:	c7 04 24 86 89 10 80 	movl   $0x80108986,(%esp)
8010268c:	e8 a9 de ff ff       	call   8010053a <panic>
  
  idewait(0);
80102691:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102698:	e8 b1 fe ff ff       	call   8010254e <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010269d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801026a4:	00 
801026a5:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801026ac:	e8 5a fe ff ff       	call   8010250b <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
801026b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026b4:	0f b6 c0             	movzbl %al,%eax
801026b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801026bb:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801026c2:	e8 44 fe ff ff       	call   8010250b <outb>
  outb(0x1f3, sector & 0xff);
801026c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026ca:	0f b6 c0             	movzbl %al,%eax
801026cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d1:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801026d8:	e8 2e fe ff ff       	call   8010250b <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801026dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026e0:	c1 f8 08             	sar    $0x8,%eax
801026e3:	0f b6 c0             	movzbl %al,%eax
801026e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ea:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801026f1:	e8 15 fe ff ff       	call   8010250b <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801026f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026f9:	c1 f8 10             	sar    $0x10,%eax
801026fc:	0f b6 c0             	movzbl %al,%eax
801026ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80102703:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010270a:	e8 fc fd ff ff       	call   8010250b <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010270f:	8b 45 08             	mov    0x8(%ebp),%eax
80102712:	8b 40 04             	mov    0x4(%eax),%eax
80102715:	83 e0 01             	and    $0x1,%eax
80102718:	c1 e0 04             	shl    $0x4,%eax
8010271b:	89 c2                	mov    %eax,%edx
8010271d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102720:	c1 f8 18             	sar    $0x18,%eax
80102723:	83 e0 0f             	and    $0xf,%eax
80102726:	09 d0                	or     %edx,%eax
80102728:	83 c8 e0             	or     $0xffffffe0,%eax
8010272b:	0f b6 c0             	movzbl %al,%eax
8010272e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102732:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102739:	e8 cd fd ff ff       	call   8010250b <outb>
  if(b->flags & B_DIRTY){
8010273e:	8b 45 08             	mov    0x8(%ebp),%eax
80102741:	8b 00                	mov    (%eax),%eax
80102743:	83 e0 04             	and    $0x4,%eax
80102746:	85 c0                	test   %eax,%eax
80102748:	74 34                	je     8010277e <idestart+0x146>
    outb(0x1f7, IDE_CMD_WRITE);
8010274a:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102751:	00 
80102752:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102759:	e8 ad fd ff ff       	call   8010250b <outb>
    outsl(0x1f0, b->data, BSIZE/4);
8010275e:	8b 45 08             	mov    0x8(%ebp),%eax
80102761:	83 c0 18             	add    $0x18,%eax
80102764:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010276b:	00 
8010276c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102770:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102777:	e8 ad fd ff ff       	call   80102529 <outsl>
8010277c:	eb 14                	jmp    80102792 <idestart+0x15a>
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010277e:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102785:	00 
80102786:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010278d:	e8 79 fd ff ff       	call   8010250b <outb>
  }
}
80102792:	c9                   	leave  
80102793:	c3                   	ret    

80102794 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102794:	55                   	push   %ebp
80102795:	89 e5                	mov    %esp,%ebp
80102797:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010279a:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801027a1:	e8 37 29 00 00       	call   801050dd <acquire>
  if((b = idequeue) == 0){
801027a6:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801027ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027b2:	75 11                	jne    801027c5 <ideintr+0x31>
    release(&idelock);
801027b4:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801027bb:	e8 7f 29 00 00       	call   8010513f <release>
    // cprintf("spurious IDE interrupt\n");
    return;
801027c0:	e9 90 00 00 00       	jmp    80102855 <ideintr+0xc1>
  }
  idequeue = b->qnext;
801027c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c8:	8b 40 14             	mov    0x14(%eax),%eax
801027cb:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d3:	8b 00                	mov    (%eax),%eax
801027d5:	83 e0 04             	and    $0x4,%eax
801027d8:	85 c0                	test   %eax,%eax
801027da:	75 2e                	jne    8010280a <ideintr+0x76>
801027dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801027e3:	e8 66 fd ff ff       	call   8010254e <idewait>
801027e8:	85 c0                	test   %eax,%eax
801027ea:	78 1e                	js     8010280a <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
801027ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ef:	83 c0 18             	add    $0x18,%eax
801027f2:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801027f9:	00 
801027fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801027fe:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102805:	e8 dc fc ff ff       	call   801024e6 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010280a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010280d:	8b 00                	mov    (%eax),%eax
8010280f:	83 c8 02             	or     $0x2,%eax
80102812:	89 c2                	mov    %eax,%edx
80102814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102817:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281c:	8b 00                	mov    (%eax),%eax
8010281e:	83 e0 fb             	and    $0xfffffffb,%eax
80102821:	89 c2                	mov    %eax,%edx
80102823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102826:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282b:	89 04 24             	mov    %eax,(%esp)
8010282e:	e8 bb 24 00 00       	call   80104cee <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102833:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102838:	85 c0                	test   %eax,%eax
8010283a:	74 0d                	je     80102849 <ideintr+0xb5>
    idestart(idequeue);
8010283c:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102841:	89 04 24             	mov    %eax,(%esp)
80102844:	e8 ef fd ff ff       	call   80102638 <idestart>

  release(&idelock);
80102849:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102850:	e8 ea 28 00 00       	call   8010513f <release>
}
80102855:	c9                   	leave  
80102856:	c3                   	ret    

80102857 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102857:	55                   	push   %ebp
80102858:	89 e5                	mov    %esp,%ebp
8010285a:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010285d:	8b 45 08             	mov    0x8(%ebp),%eax
80102860:	8b 00                	mov    (%eax),%eax
80102862:	83 e0 01             	and    $0x1,%eax
80102865:	85 c0                	test   %eax,%eax
80102867:	75 0c                	jne    80102875 <iderw+0x1e>
    panic("iderw: buf not busy");
80102869:	c7 04 24 a1 89 10 80 	movl   $0x801089a1,(%esp)
80102870:	e8 c5 dc ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102875:	8b 45 08             	mov    0x8(%ebp),%eax
80102878:	8b 00                	mov    (%eax),%eax
8010287a:	83 e0 06             	and    $0x6,%eax
8010287d:	83 f8 02             	cmp    $0x2,%eax
80102880:	75 0c                	jne    8010288e <iderw+0x37>
    panic("iderw: nothing to do");
80102882:	c7 04 24 b5 89 10 80 	movl   $0x801089b5,(%esp)
80102889:	e8 ac dc ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
8010288e:	8b 45 08             	mov    0x8(%ebp),%eax
80102891:	8b 40 04             	mov    0x4(%eax),%eax
80102894:	85 c0                	test   %eax,%eax
80102896:	74 15                	je     801028ad <iderw+0x56>
80102898:	a1 58 b6 10 80       	mov    0x8010b658,%eax
8010289d:	85 c0                	test   %eax,%eax
8010289f:	75 0c                	jne    801028ad <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801028a1:	c7 04 24 ca 89 10 80 	movl   $0x801089ca,(%esp)
801028a8:	e8 8d dc ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028ad:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801028b4:	e8 24 28 00 00       	call   801050dd <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801028b9:	8b 45 08             	mov    0x8(%ebp),%eax
801028bc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028c3:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
801028ca:	eb 0b                	jmp    801028d7 <iderw+0x80>
801028cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028cf:	8b 00                	mov    (%eax),%eax
801028d1:	83 c0 14             	add    $0x14,%eax
801028d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028da:	8b 00                	mov    (%eax),%eax
801028dc:	85 c0                	test   %eax,%eax
801028de:	75 ec                	jne    801028cc <iderw+0x75>
    ;
  *pp = b;
801028e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e3:	8b 55 08             	mov    0x8(%ebp),%edx
801028e6:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801028e8:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801028ed:	3b 45 08             	cmp    0x8(%ebp),%eax
801028f0:	75 0d                	jne    801028ff <iderw+0xa8>
    idestart(b);
801028f2:	8b 45 08             	mov    0x8(%ebp),%eax
801028f5:	89 04 24             	mov    %eax,(%esp)
801028f8:	e8 3b fd ff ff       	call   80102638 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028fd:	eb 15                	jmp    80102914 <iderw+0xbd>
801028ff:	eb 13                	jmp    80102914 <iderw+0xbd>
    sleep(b, &idelock);
80102901:	c7 44 24 04 20 b6 10 	movl   $0x8010b620,0x4(%esp)
80102908:	80 
80102909:	8b 45 08             	mov    0x8(%ebp),%eax
8010290c:	89 04 24             	mov    %eax,(%esp)
8010290f:	e8 fe 22 00 00       	call   80104c12 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102914:	8b 45 08             	mov    0x8(%ebp),%eax
80102917:	8b 00                	mov    (%eax),%eax
80102919:	83 e0 06             	and    $0x6,%eax
8010291c:	83 f8 02             	cmp    $0x2,%eax
8010291f:	75 e0                	jne    80102901 <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
80102921:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102928:	e8 12 28 00 00       	call   8010513f <release>
}
8010292d:	c9                   	leave  
8010292e:	c3                   	ret    

8010292f <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010292f:	55                   	push   %ebp
80102930:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102932:	a1 34 22 11 80       	mov    0x80112234,%eax
80102937:	8b 55 08             	mov    0x8(%ebp),%edx
8010293a:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010293c:	a1 34 22 11 80       	mov    0x80112234,%eax
80102941:	8b 40 10             	mov    0x10(%eax),%eax
}
80102944:	5d                   	pop    %ebp
80102945:	c3                   	ret    

80102946 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102946:	55                   	push   %ebp
80102947:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102949:	a1 34 22 11 80       	mov    0x80112234,%eax
8010294e:	8b 55 08             	mov    0x8(%ebp),%edx
80102951:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102953:	a1 34 22 11 80       	mov    0x80112234,%eax
80102958:	8b 55 0c             	mov    0xc(%ebp),%edx
8010295b:	89 50 10             	mov    %edx,0x10(%eax)
}
8010295e:	5d                   	pop    %ebp
8010295f:	c3                   	ret    

80102960 <ioapicinit>:

void
ioapicinit(void)
{
80102960:	55                   	push   %ebp
80102961:	89 e5                	mov    %esp,%ebp
80102963:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102966:	a1 64 23 11 80       	mov    0x80112364,%eax
8010296b:	85 c0                	test   %eax,%eax
8010296d:	75 05                	jne    80102974 <ioapicinit+0x14>
    return;
8010296f:	e9 9d 00 00 00       	jmp    80102a11 <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102974:	c7 05 34 22 11 80 00 	movl   $0xfec00000,0x80112234
8010297b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010297e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102985:	e8 a5 ff ff ff       	call   8010292f <ioapicread>
8010298a:	c1 e8 10             	shr    $0x10,%eax
8010298d:	25 ff 00 00 00       	and    $0xff,%eax
80102992:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102995:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010299c:	e8 8e ff ff ff       	call   8010292f <ioapicread>
801029a1:	c1 e8 18             	shr    $0x18,%eax
801029a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029a7:	0f b6 05 60 23 11 80 	movzbl 0x80112360,%eax
801029ae:	0f b6 c0             	movzbl %al,%eax
801029b1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029b4:	74 0c                	je     801029c2 <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029b6:	c7 04 24 e8 89 10 80 	movl   $0x801089e8,(%esp)
801029bd:	e8 de d9 ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029c9:	eb 3e                	jmp    80102a09 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ce:	83 c0 20             	add    $0x20,%eax
801029d1:	0d 00 00 01 00       	or     $0x10000,%eax
801029d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801029d9:	83 c2 08             	add    $0x8,%edx
801029dc:	01 d2                	add    %edx,%edx
801029de:	89 44 24 04          	mov    %eax,0x4(%esp)
801029e2:	89 14 24             	mov    %edx,(%esp)
801029e5:	e8 5c ff ff ff       	call   80102946 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
801029ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ed:	83 c0 08             	add    $0x8,%eax
801029f0:	01 c0                	add    %eax,%eax
801029f2:	83 c0 01             	add    $0x1,%eax
801029f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801029fc:	00 
801029fd:	89 04 24             	mov    %eax,(%esp)
80102a00:	e8 41 ff ff ff       	call   80102946 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a05:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a0f:	7e ba                	jle    801029cb <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a11:	c9                   	leave  
80102a12:	c3                   	ret    

80102a13 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a13:	55                   	push   %ebp
80102a14:	89 e5                	mov    %esp,%ebp
80102a16:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102a19:	a1 64 23 11 80       	mov    0x80112364,%eax
80102a1e:	85 c0                	test   %eax,%eax
80102a20:	75 02                	jne    80102a24 <ioapicenable+0x11>
    return;
80102a22:	eb 37                	jmp    80102a5b <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a24:	8b 45 08             	mov    0x8(%ebp),%eax
80102a27:	83 c0 20             	add    $0x20,%eax
80102a2a:	8b 55 08             	mov    0x8(%ebp),%edx
80102a2d:	83 c2 08             	add    $0x8,%edx
80102a30:	01 d2                	add    %edx,%edx
80102a32:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a36:	89 14 24             	mov    %edx,(%esp)
80102a39:	e8 08 ff ff ff       	call   80102946 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a41:	c1 e0 18             	shl    $0x18,%eax
80102a44:	8b 55 08             	mov    0x8(%ebp),%edx
80102a47:	83 c2 08             	add    $0x8,%edx
80102a4a:	01 d2                	add    %edx,%edx
80102a4c:	83 c2 01             	add    $0x1,%edx
80102a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a53:	89 14 24             	mov    %edx,(%esp)
80102a56:	e8 eb fe ff ff       	call   80102946 <ioapicwrite>
}
80102a5b:	c9                   	leave  
80102a5c:	c3                   	ret    

80102a5d <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a5d:	55                   	push   %ebp
80102a5e:	89 e5                	mov    %esp,%ebp
80102a60:	8b 45 08             	mov    0x8(%ebp),%eax
80102a63:	05 00 00 00 80       	add    $0x80000000,%eax
80102a68:	5d                   	pop    %ebp
80102a69:	c3                   	ret    

80102a6a <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a70:	c7 44 24 04 1a 8a 10 	movl   $0x80108a1a,0x4(%esp)
80102a77:	80 
80102a78:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102a7f:	e8 38 26 00 00       	call   801050bc <initlock>
  kmem.use_lock = 0;
80102a84:	c7 05 74 22 11 80 00 	movl   $0x0,0x80112274
80102a8b:	00 00 00 
  freerange(vstart, vend);
80102a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a91:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a95:	8b 45 08             	mov    0x8(%ebp),%eax
80102a98:	89 04 24             	mov    %eax,(%esp)
80102a9b:	e8 26 00 00 00       	call   80102ac6 <freerange>
}
80102aa0:	c9                   	leave  
80102aa1:	c3                   	ret    

80102aa2 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102aa2:	55                   	push   %ebp
80102aa3:	89 e5                	mov    %esp,%ebp
80102aa5:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102aab:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab2:	89 04 24             	mov    %eax,(%esp)
80102ab5:	e8 0c 00 00 00       	call   80102ac6 <freerange>
  kmem.use_lock = 1;
80102aba:	c7 05 74 22 11 80 01 	movl   $0x1,0x80112274
80102ac1:	00 00 00 
}
80102ac4:	c9                   	leave  
80102ac5:	c3                   	ret    

80102ac6 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102ac6:	55                   	push   %ebp
80102ac7:	89 e5                	mov    %esp,%ebp
80102ac9:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102acc:	8b 45 08             	mov    0x8(%ebp),%eax
80102acf:	05 ff 0f 00 00       	add    $0xfff,%eax
80102ad4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102adc:	eb 12                	jmp    80102af0 <freerange+0x2a>
    kfree(p);
80102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae1:	89 04 24             	mov    %eax,(%esp)
80102ae4:	e8 16 00 00 00       	call   80102aff <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ae9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af3:	05 00 10 00 00       	add    $0x1000,%eax
80102af8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102afb:	76 e1                	jbe    80102ade <freerange+0x18>
    kfree(p);
}
80102afd:	c9                   	leave  
80102afe:	c3                   	ret    

80102aff <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102aff:	55                   	push   %ebp
80102b00:	89 e5                	mov    %esp,%ebp
80102b02:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b05:	8b 45 08             	mov    0x8(%ebp),%eax
80102b08:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b0d:	85 c0                	test   %eax,%eax
80102b0f:	75 1b                	jne    80102b2c <kfree+0x2d>
80102b11:	81 7d 08 5c 53 11 80 	cmpl   $0x8011535c,0x8(%ebp)
80102b18:	72 12                	jb     80102b2c <kfree+0x2d>
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	89 04 24             	mov    %eax,(%esp)
80102b20:	e8 38 ff ff ff       	call   80102a5d <v2p>
80102b25:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b2a:	76 0c                	jbe    80102b38 <kfree+0x39>
    panic("kfree");
80102b2c:	c7 04 24 1f 8a 10 80 	movl   $0x80108a1f,(%esp)
80102b33:	e8 02 da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b38:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102b3f:	00 
80102b40:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b47:	00 
80102b48:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4b:	89 04 24             	mov    %eax,(%esp)
80102b4e:	e8 de 27 00 00       	call   80105331 <memset>

  if(kmem.use_lock)
80102b53:	a1 74 22 11 80       	mov    0x80112274,%eax
80102b58:	85 c0                	test   %eax,%eax
80102b5a:	74 0c                	je     80102b68 <kfree+0x69>
    acquire(&kmem.lock);
80102b5c:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102b63:	e8 75 25 00 00       	call   801050dd <acquire>
  r = (struct run*)v;
80102b68:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b6e:	8b 15 78 22 11 80    	mov    0x80112278,%edx
80102b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b77:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b7c:	a3 78 22 11 80       	mov    %eax,0x80112278
  if(kmem.use_lock)
80102b81:	a1 74 22 11 80       	mov    0x80112274,%eax
80102b86:	85 c0                	test   %eax,%eax
80102b88:	74 0c                	je     80102b96 <kfree+0x97>
    release(&kmem.lock);
80102b8a:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102b91:	e8 a9 25 00 00       	call   8010513f <release>
}
80102b96:	c9                   	leave  
80102b97:	c3                   	ret    

80102b98 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b98:	55                   	push   %ebp
80102b99:	89 e5                	mov    %esp,%ebp
80102b9b:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b9e:	a1 74 22 11 80       	mov    0x80112274,%eax
80102ba3:	85 c0                	test   %eax,%eax
80102ba5:	74 0c                	je     80102bb3 <kalloc+0x1b>
    acquire(&kmem.lock);
80102ba7:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102bae:	e8 2a 25 00 00       	call   801050dd <acquire>
  r = kmem.freelist;
80102bb3:	a1 78 22 11 80       	mov    0x80112278,%eax
80102bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bbf:	74 0a                	je     80102bcb <kalloc+0x33>
    kmem.freelist = r->next;
80102bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc4:	8b 00                	mov    (%eax),%eax
80102bc6:	a3 78 22 11 80       	mov    %eax,0x80112278
  if(kmem.use_lock)
80102bcb:	a1 74 22 11 80       	mov    0x80112274,%eax
80102bd0:	85 c0                	test   %eax,%eax
80102bd2:	74 0c                	je     80102be0 <kalloc+0x48>
    release(&kmem.lock);
80102bd4:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102bdb:	e8 5f 25 00 00       	call   8010513f <release>
  return (char*)r;
80102be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102be3:	c9                   	leave  
80102be4:	c3                   	ret    

80102be5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102be5:	55                   	push   %ebp
80102be6:	89 e5                	mov    %esp,%ebp
80102be8:	83 ec 14             	sub    $0x14,%esp
80102beb:	8b 45 08             	mov    0x8(%ebp),%eax
80102bee:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bf2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102bf6:	89 c2                	mov    %eax,%edx
80102bf8:	ec                   	in     (%dx),%al
80102bf9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102bfc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c00:	c9                   	leave  
80102c01:	c3                   	ret    

80102c02 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c02:	55                   	push   %ebp
80102c03:	89 e5                	mov    %esp,%ebp
80102c05:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c08:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102c0f:	e8 d1 ff ff ff       	call   80102be5 <inb>
80102c14:	0f b6 c0             	movzbl %al,%eax
80102c17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c1d:	83 e0 01             	and    $0x1,%eax
80102c20:	85 c0                	test   %eax,%eax
80102c22:	75 0a                	jne    80102c2e <kbdgetc+0x2c>
    return -1;
80102c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c29:	e9 25 01 00 00       	jmp    80102d53 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102c2e:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102c35:	e8 ab ff ff ff       	call   80102be5 <inb>
80102c3a:	0f b6 c0             	movzbl %al,%eax
80102c3d:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c40:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c47:	75 17                	jne    80102c60 <kbdgetc+0x5e>
    shift |= E0ESC;
80102c49:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c4e:	83 c8 40             	or     $0x40,%eax
80102c51:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102c56:	b8 00 00 00 00       	mov    $0x0,%eax
80102c5b:	e9 f3 00 00 00       	jmp    80102d53 <kbdgetc+0x151>
  } else if(data & 0x80){
80102c60:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c63:	25 80 00 00 00       	and    $0x80,%eax
80102c68:	85 c0                	test   %eax,%eax
80102c6a:	74 45                	je     80102cb1 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c6c:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c71:	83 e0 40             	and    $0x40,%eax
80102c74:	85 c0                	test   %eax,%eax
80102c76:	75 08                	jne    80102c80 <kbdgetc+0x7e>
80102c78:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c7b:	83 e0 7f             	and    $0x7f,%eax
80102c7e:	eb 03                	jmp    80102c83 <kbdgetc+0x81>
80102c80:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c83:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c86:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c89:	05 20 90 10 80       	add    $0x80109020,%eax
80102c8e:	0f b6 00             	movzbl (%eax),%eax
80102c91:	83 c8 40             	or     $0x40,%eax
80102c94:	0f b6 c0             	movzbl %al,%eax
80102c97:	f7 d0                	not    %eax
80102c99:	89 c2                	mov    %eax,%edx
80102c9b:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ca0:	21 d0                	and    %edx,%eax
80102ca2:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102ca7:	b8 00 00 00 00       	mov    $0x0,%eax
80102cac:	e9 a2 00 00 00       	jmp    80102d53 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102cb1:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cb6:	83 e0 40             	and    $0x40,%eax
80102cb9:	85 c0                	test   %eax,%eax
80102cbb:	74 14                	je     80102cd1 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cbd:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102cc4:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cc9:	83 e0 bf             	and    $0xffffffbf,%eax
80102ccc:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102cd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cd4:	05 20 90 10 80       	add    $0x80109020,%eax
80102cd9:	0f b6 00             	movzbl (%eax),%eax
80102cdc:	0f b6 d0             	movzbl %al,%edx
80102cdf:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ce4:	09 d0                	or     %edx,%eax
80102ce6:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102ceb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cee:	05 20 91 10 80       	add    $0x80109120,%eax
80102cf3:	0f b6 00             	movzbl (%eax),%eax
80102cf6:	0f b6 d0             	movzbl %al,%edx
80102cf9:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cfe:	31 d0                	xor    %edx,%eax
80102d00:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d05:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d0a:	83 e0 03             	and    $0x3,%eax
80102d0d:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102d14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d17:	01 d0                	add    %edx,%eax
80102d19:	0f b6 00             	movzbl (%eax),%eax
80102d1c:	0f b6 c0             	movzbl %al,%eax
80102d1f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d22:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d27:	83 e0 08             	and    $0x8,%eax
80102d2a:	85 c0                	test   %eax,%eax
80102d2c:	74 22                	je     80102d50 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102d2e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d32:	76 0c                	jbe    80102d40 <kbdgetc+0x13e>
80102d34:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d38:	77 06                	ja     80102d40 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102d3a:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d3e:	eb 10                	jmp    80102d50 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102d40:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d44:	76 0a                	jbe    80102d50 <kbdgetc+0x14e>
80102d46:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d4a:	77 04                	ja     80102d50 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102d4c:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d50:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d53:	c9                   	leave  
80102d54:	c3                   	ret    

80102d55 <kbdintr>:

void
kbdintr(void)
{
80102d55:	55                   	push   %ebp
80102d56:	89 e5                	mov    %esp,%ebp
80102d58:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d5b:	c7 04 24 02 2c 10 80 	movl   $0x80102c02,(%esp)
80102d62:	e8 61 da ff ff       	call   801007c8 <consoleintr>
}
80102d67:	c9                   	leave  
80102d68:	c3                   	ret    

80102d69 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d69:	55                   	push   %ebp
80102d6a:	89 e5                	mov    %esp,%ebp
80102d6c:	83 ec 14             	sub    $0x14,%esp
80102d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d72:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d76:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d7a:	89 c2                	mov    %eax,%edx
80102d7c:	ec                   	in     (%dx),%al
80102d7d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d80:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d84:	c9                   	leave  
80102d85:	c3                   	ret    

80102d86 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d86:	55                   	push   %ebp
80102d87:	89 e5                	mov    %esp,%ebp
80102d89:	83 ec 08             	sub    $0x8,%esp
80102d8c:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d92:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d96:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d99:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d9d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102da1:	ee                   	out    %al,(%dx)
}
80102da2:	c9                   	leave  
80102da3:	c3                   	ret    

80102da4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102da4:	55                   	push   %ebp
80102da5:	89 e5                	mov    %esp,%ebp
80102da7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102daa:	9c                   	pushf  
80102dab:	58                   	pop    %eax
80102dac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102daf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102db2:	c9                   	leave  
80102db3:	c3                   	ret    

80102db4 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102db4:	55                   	push   %ebp
80102db5:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102db7:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102dbc:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbf:	c1 e2 02             	shl    $0x2,%edx
80102dc2:	01 c2                	add    %eax,%edx
80102dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dc7:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102dc9:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102dce:	83 c0 20             	add    $0x20,%eax
80102dd1:	8b 00                	mov    (%eax),%eax
}
80102dd3:	5d                   	pop    %ebp
80102dd4:	c3                   	ret    

80102dd5 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102dd5:	55                   	push   %ebp
80102dd6:	89 e5                	mov    %esp,%ebp
80102dd8:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102ddb:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102de0:	85 c0                	test   %eax,%eax
80102de2:	75 05                	jne    80102de9 <lapicinit+0x14>
    return;
80102de4:	e9 43 01 00 00       	jmp    80102f2c <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102de9:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102df0:	00 
80102df1:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102df8:	e8 b7 ff ff ff       	call   80102db4 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102dfd:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102e04:	00 
80102e05:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102e0c:	e8 a3 ff ff ff       	call   80102db4 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e11:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102e18:	00 
80102e19:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102e20:	e8 8f ff ff ff       	call   80102db4 <lapicw>
  lapicw(TICR, 10000000); 
80102e25:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102e2c:	00 
80102e2d:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102e34:	e8 7b ff ff ff       	call   80102db4 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e39:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e40:	00 
80102e41:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e48:	e8 67 ff ff ff       	call   80102db4 <lapicw>
  lapicw(LINT1, MASKED);
80102e4d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e54:	00 
80102e55:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e5c:	e8 53 ff ff ff       	call   80102db4 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e61:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102e66:	83 c0 30             	add    $0x30,%eax
80102e69:	8b 00                	mov    (%eax),%eax
80102e6b:	c1 e8 10             	shr    $0x10,%eax
80102e6e:	0f b6 c0             	movzbl %al,%eax
80102e71:	83 f8 03             	cmp    $0x3,%eax
80102e74:	76 14                	jbe    80102e8a <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102e76:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e7d:	00 
80102e7e:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e85:	e8 2a ff ff ff       	call   80102db4 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e8a:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e91:	00 
80102e92:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e99:	e8 16 ff ff ff       	call   80102db4 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ea5:	00 
80102ea6:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102ead:	e8 02 ff ff ff       	call   80102db4 <lapicw>
  lapicw(ESR, 0);
80102eb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eb9:	00 
80102eba:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102ec1:	e8 ee fe ff ff       	call   80102db4 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ec6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ecd:	00 
80102ece:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102ed5:	e8 da fe ff ff       	call   80102db4 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102eda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee1:	00 
80102ee2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102ee9:	e8 c6 fe ff ff       	call   80102db4 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102eee:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102ef5:	00 
80102ef6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102efd:	e8 b2 fe ff ff       	call   80102db4 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102f02:	90                   	nop
80102f03:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f08:	05 00 03 00 00       	add    $0x300,%eax
80102f0d:	8b 00                	mov    (%eax),%eax
80102f0f:	25 00 10 00 00       	and    $0x1000,%eax
80102f14:	85 c0                	test   %eax,%eax
80102f16:	75 eb                	jne    80102f03 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f1f:	00 
80102f20:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102f27:	e8 88 fe ff ff       	call   80102db4 <lapicw>
}
80102f2c:	c9                   	leave  
80102f2d:	c3                   	ret    

80102f2e <cpunum>:

int
cpunum(void)
{
80102f2e:	55                   	push   %ebp
80102f2f:	89 e5                	mov    %esp,%ebp
80102f31:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f34:	e8 6b fe ff ff       	call   80102da4 <readeflags>
80102f39:	25 00 02 00 00       	and    $0x200,%eax
80102f3e:	85 c0                	test   %eax,%eax
80102f40:	74 25                	je     80102f67 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102f42:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80102f47:	8d 50 01             	lea    0x1(%eax),%edx
80102f4a:	89 15 60 b6 10 80    	mov    %edx,0x8010b660
80102f50:	85 c0                	test   %eax,%eax
80102f52:	75 13                	jne    80102f67 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f54:	8b 45 04             	mov    0x4(%ebp),%eax
80102f57:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f5b:	c7 04 24 28 8a 10 80 	movl   $0x80108a28,(%esp)
80102f62:	e8 39 d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102f67:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f6c:	85 c0                	test   %eax,%eax
80102f6e:	74 0f                	je     80102f7f <cpunum+0x51>
    return lapic[ID]>>24;
80102f70:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f75:	83 c0 20             	add    $0x20,%eax
80102f78:	8b 00                	mov    (%eax),%eax
80102f7a:	c1 e8 18             	shr    $0x18,%eax
80102f7d:	eb 05                	jmp    80102f84 <cpunum+0x56>
  return 0;
80102f7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f84:	c9                   	leave  
80102f85:	c3                   	ret    

80102f86 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f86:	55                   	push   %ebp
80102f87:	89 e5                	mov    %esp,%ebp
80102f89:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f8c:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f91:	85 c0                	test   %eax,%eax
80102f93:	74 14                	je     80102fa9 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f9c:	00 
80102f9d:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102fa4:	e8 0b fe ff ff       	call   80102db4 <lapicw>
}
80102fa9:	c9                   	leave  
80102faa:	c3                   	ret    

80102fab <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fab:	55                   	push   %ebp
80102fac:	89 e5                	mov    %esp,%ebp
}
80102fae:	5d                   	pop    %ebp
80102faf:	c3                   	ret    

80102fb0 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fb0:	55                   	push   %ebp
80102fb1:	89 e5                	mov    %esp,%ebp
80102fb3:	83 ec 1c             	sub    $0x1c,%esp
80102fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80102fb9:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fbc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102fc3:	00 
80102fc4:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102fcb:	e8 b6 fd ff ff       	call   80102d86 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102fd0:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102fd7:	00 
80102fd8:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102fdf:	e8 a2 fd ff ff       	call   80102d86 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102fe4:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102feb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fee:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102ff3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ff6:	8d 50 02             	lea    0x2(%eax),%edx
80102ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ffc:	c1 e8 04             	shr    $0x4,%eax
80102fff:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103002:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103006:	c1 e0 18             	shl    $0x18,%eax
80103009:	89 44 24 04          	mov    %eax,0x4(%esp)
8010300d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103014:	e8 9b fd ff ff       	call   80102db4 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103019:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103020:	00 
80103021:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103028:	e8 87 fd ff ff       	call   80102db4 <lapicw>
  microdelay(200);
8010302d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103034:	e8 72 ff ff ff       	call   80102fab <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103039:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103040:	00 
80103041:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103048:	e8 67 fd ff ff       	call   80102db4 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010304d:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103054:	e8 52 ff ff ff       	call   80102fab <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103059:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103060:	eb 40                	jmp    801030a2 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103062:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103066:	c1 e0 18             	shl    $0x18,%eax
80103069:	89 44 24 04          	mov    %eax,0x4(%esp)
8010306d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103074:	e8 3b fd ff ff       	call   80102db4 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103079:	8b 45 0c             	mov    0xc(%ebp),%eax
8010307c:	c1 e8 0c             	shr    $0xc,%eax
8010307f:	80 cc 06             	or     $0x6,%ah
80103082:	89 44 24 04          	mov    %eax,0x4(%esp)
80103086:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010308d:	e8 22 fd ff ff       	call   80102db4 <lapicw>
    microdelay(200);
80103092:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103099:	e8 0d ff ff ff       	call   80102fab <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010309e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030a2:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030a6:	7e ba                	jle    80103062 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801030a8:	c9                   	leave  
801030a9:	c3                   	ret    

801030aa <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030aa:	55                   	push   %ebp
801030ab:	89 e5                	mov    %esp,%ebp
801030ad:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801030b0:	8b 45 08             	mov    0x8(%ebp),%eax
801030b3:	0f b6 c0             	movzbl %al,%eax
801030b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801030ba:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801030c1:	e8 c0 fc ff ff       	call   80102d86 <outb>
  microdelay(200);
801030c6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030cd:	e8 d9 fe ff ff       	call   80102fab <microdelay>

  return inb(CMOS_RETURN);
801030d2:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801030d9:	e8 8b fc ff ff       	call   80102d69 <inb>
801030de:	0f b6 c0             	movzbl %al,%eax
}
801030e1:	c9                   	leave  
801030e2:	c3                   	ret    

801030e3 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030e3:	55                   	push   %ebp
801030e4:	89 e5                	mov    %esp,%ebp
801030e6:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801030e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801030f0:	e8 b5 ff ff ff       	call   801030aa <cmos_read>
801030f5:	8b 55 08             	mov    0x8(%ebp),%edx
801030f8:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801030fa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103101:	e8 a4 ff ff ff       	call   801030aa <cmos_read>
80103106:	8b 55 08             	mov    0x8(%ebp),%edx
80103109:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010310c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103113:	e8 92 ff ff ff       	call   801030aa <cmos_read>
80103118:	8b 55 08             	mov    0x8(%ebp),%edx
8010311b:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010311e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103125:	e8 80 ff ff ff       	call   801030aa <cmos_read>
8010312a:	8b 55 08             	mov    0x8(%ebp),%edx
8010312d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103130:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103137:	e8 6e ff ff ff       	call   801030aa <cmos_read>
8010313c:	8b 55 08             	mov    0x8(%ebp),%edx
8010313f:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103142:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103149:	e8 5c ff ff ff       	call   801030aa <cmos_read>
8010314e:	8b 55 08             	mov    0x8(%ebp),%edx
80103151:	89 42 14             	mov    %eax,0x14(%edx)
}
80103154:	c9                   	leave  
80103155:	c3                   	ret    

80103156 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103156:	55                   	push   %ebp
80103157:	89 e5                	mov    %esp,%ebp
80103159:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010315c:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103163:	e8 42 ff ff ff       	call   801030aa <cmos_read>
80103168:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010316b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010316e:	83 e0 04             	and    $0x4,%eax
80103171:	85 c0                	test   %eax,%eax
80103173:	0f 94 c0             	sete   %al
80103176:	0f b6 c0             	movzbl %al,%eax
80103179:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010317c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010317f:	89 04 24             	mov    %eax,(%esp)
80103182:	e8 5c ff ff ff       	call   801030e3 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103187:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010318e:	e8 17 ff ff ff       	call   801030aa <cmos_read>
80103193:	25 80 00 00 00       	and    $0x80,%eax
80103198:	85 c0                	test   %eax,%eax
8010319a:	74 02                	je     8010319e <cmostime+0x48>
        continue;
8010319c:	eb 36                	jmp    801031d4 <cmostime+0x7e>
    fill_rtcdate(&t2);
8010319e:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031a1:	89 04 24             	mov    %eax,(%esp)
801031a4:	e8 3a ff ff ff       	call   801030e3 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801031a9:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801031b0:	00 
801031b1:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801031b8:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031bb:	89 04 24             	mov    %eax,(%esp)
801031be:	e8 e5 21 00 00       	call   801053a8 <memcmp>
801031c3:	85 c0                	test   %eax,%eax
801031c5:	75 0d                	jne    801031d4 <cmostime+0x7e>
      break;
801031c7:	90                   	nop
  }

  // convert
  if (bcd) {
801031c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801031cc:	0f 84 ac 00 00 00    	je     8010327e <cmostime+0x128>
801031d2:	eb 02                	jmp    801031d6 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031d4:	eb a6                	jmp    8010317c <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031d9:	c1 e8 04             	shr    $0x4,%eax
801031dc:	89 c2                	mov    %eax,%edx
801031de:	89 d0                	mov    %edx,%eax
801031e0:	c1 e0 02             	shl    $0x2,%eax
801031e3:	01 d0                	add    %edx,%eax
801031e5:	01 c0                	add    %eax,%eax
801031e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031ea:	83 e2 0f             	and    $0xf,%edx
801031ed:	01 d0                	add    %edx,%eax
801031ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031f5:	c1 e8 04             	shr    $0x4,%eax
801031f8:	89 c2                	mov    %eax,%edx
801031fa:	89 d0                	mov    %edx,%eax
801031fc:	c1 e0 02             	shl    $0x2,%eax
801031ff:	01 d0                	add    %edx,%eax
80103201:	01 c0                	add    %eax,%eax
80103203:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103206:	83 e2 0f             	and    $0xf,%edx
80103209:	01 d0                	add    %edx,%eax
8010320b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010320e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103211:	c1 e8 04             	shr    $0x4,%eax
80103214:	89 c2                	mov    %eax,%edx
80103216:	89 d0                	mov    %edx,%eax
80103218:	c1 e0 02             	shl    $0x2,%eax
8010321b:	01 d0                	add    %edx,%eax
8010321d:	01 c0                	add    %eax,%eax
8010321f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103222:	83 e2 0f             	and    $0xf,%edx
80103225:	01 d0                	add    %edx,%eax
80103227:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010322a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010322d:	c1 e8 04             	shr    $0x4,%eax
80103230:	89 c2                	mov    %eax,%edx
80103232:	89 d0                	mov    %edx,%eax
80103234:	c1 e0 02             	shl    $0x2,%eax
80103237:	01 d0                	add    %edx,%eax
80103239:	01 c0                	add    %eax,%eax
8010323b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010323e:	83 e2 0f             	and    $0xf,%edx
80103241:	01 d0                	add    %edx,%eax
80103243:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103246:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103249:	c1 e8 04             	shr    $0x4,%eax
8010324c:	89 c2                	mov    %eax,%edx
8010324e:	89 d0                	mov    %edx,%eax
80103250:	c1 e0 02             	shl    $0x2,%eax
80103253:	01 d0                	add    %edx,%eax
80103255:	01 c0                	add    %eax,%eax
80103257:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010325a:	83 e2 0f             	and    $0xf,%edx
8010325d:	01 d0                	add    %edx,%eax
8010325f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103262:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103265:	c1 e8 04             	shr    $0x4,%eax
80103268:	89 c2                	mov    %eax,%edx
8010326a:	89 d0                	mov    %edx,%eax
8010326c:	c1 e0 02             	shl    $0x2,%eax
8010326f:	01 d0                	add    %edx,%eax
80103271:	01 c0                	add    %eax,%eax
80103273:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103276:	83 e2 0f             	and    $0xf,%edx
80103279:	01 d0                	add    %edx,%eax
8010327b:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010327e:	8b 45 08             	mov    0x8(%ebp),%eax
80103281:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103284:	89 10                	mov    %edx,(%eax)
80103286:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103289:	89 50 04             	mov    %edx,0x4(%eax)
8010328c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010328f:	89 50 08             	mov    %edx,0x8(%eax)
80103292:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103295:	89 50 0c             	mov    %edx,0xc(%eax)
80103298:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010329b:	89 50 10             	mov    %edx,0x10(%eax)
8010329e:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032a1:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032a4:	8b 45 08             	mov    0x8(%ebp),%eax
801032a7:	8b 40 14             	mov    0x14(%eax),%eax
801032aa:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032b0:	8b 45 08             	mov    0x8(%ebp),%eax
801032b3:	89 50 14             	mov    %edx,0x14(%eax)
}
801032b6:	c9                   	leave  
801032b7:	c3                   	ret    

801032b8 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801032b8:	55                   	push   %ebp
801032b9:	89 e5                	mov    %esp,%ebp
801032bb:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032be:	c7 44 24 04 54 8a 10 	movl   $0x80108a54,0x4(%esp)
801032c5:	80 
801032c6:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801032cd:	e8 ea 1d 00 00       	call   801050bc <initlock>
  readsb(dev, &sb);
801032d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
801032d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801032d9:	8b 45 08             	mov    0x8(%ebp),%eax
801032dc:	89 04 24             	mov    %eax,(%esp)
801032df:	e8 28 e0 ff ff       	call   8010130c <readsb>
  log.start = sb.logstart;
801032e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e7:	a3 b4 22 11 80       	mov    %eax,0x801122b4
  log.size = sb.nlog;
801032ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032ef:	a3 b8 22 11 80       	mov    %eax,0x801122b8
  log.dev = dev;
801032f4:	8b 45 08             	mov    0x8(%ebp),%eax
801032f7:	a3 c4 22 11 80       	mov    %eax,0x801122c4
  recover_from_log();
801032fc:	e8 9a 01 00 00       	call   8010349b <recover_from_log>
}
80103301:	c9                   	leave  
80103302:	c3                   	ret    

80103303 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103303:	55                   	push   %ebp
80103304:	89 e5                	mov    %esp,%ebp
80103306:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103309:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103310:	e9 8c 00 00 00       	jmp    801033a1 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103315:	8b 15 b4 22 11 80    	mov    0x801122b4,%edx
8010331b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331e:	01 d0                	add    %edx,%eax
80103320:	83 c0 01             	add    $0x1,%eax
80103323:	89 c2                	mov    %eax,%edx
80103325:	a1 c4 22 11 80       	mov    0x801122c4,%eax
8010332a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010332e:	89 04 24             	mov    %eax,(%esp)
80103331:	e8 70 ce ff ff       	call   801001a6 <bread>
80103336:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010333c:	83 c0 10             	add    $0x10,%eax
8010333f:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
80103346:	89 c2                	mov    %eax,%edx
80103348:	a1 c4 22 11 80       	mov    0x801122c4,%eax
8010334d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103351:	89 04 24             	mov    %eax,(%esp)
80103354:	e8 4d ce ff ff       	call   801001a6 <bread>
80103359:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010335c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010335f:	8d 50 18             	lea    0x18(%eax),%edx
80103362:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103365:	83 c0 18             	add    $0x18,%eax
80103368:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010336f:	00 
80103370:	89 54 24 04          	mov    %edx,0x4(%esp)
80103374:	89 04 24             	mov    %eax,(%esp)
80103377:	e8 84 20 00 00       	call   80105400 <memmove>
    bwrite(dbuf);  // write dst to disk
8010337c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010337f:	89 04 24             	mov    %eax,(%esp)
80103382:	e8 56 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103387:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010338a:	89 04 24             	mov    %eax,(%esp)
8010338d:	e8 85 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103392:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103395:	89 04 24             	mov    %eax,(%esp)
80103398:	e8 7a ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010339d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033a1:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801033a6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033a9:	0f 8f 66 ff ff ff    	jg     80103315 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033af:	c9                   	leave  
801033b0:	c3                   	ret    

801033b1 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033b1:	55                   	push   %ebp
801033b2:	89 e5                	mov    %esp,%ebp
801033b4:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033b7:	a1 b4 22 11 80       	mov    0x801122b4,%eax
801033bc:	89 c2                	mov    %eax,%edx
801033be:	a1 c4 22 11 80       	mov    0x801122c4,%eax
801033c3:	89 54 24 04          	mov    %edx,0x4(%esp)
801033c7:	89 04 24             	mov    %eax,(%esp)
801033ca:	e8 d7 cd ff ff       	call   801001a6 <bread>
801033cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033d5:	83 c0 18             	add    $0x18,%eax
801033d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033de:	8b 00                	mov    (%eax),%eax
801033e0:	a3 c8 22 11 80       	mov    %eax,0x801122c8
  for (i = 0; i < log.lh.n; i++) {
801033e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033ec:	eb 1b                	jmp    80103409 <read_head+0x58>
    log.lh.block[i] = lh->block[i];
801033ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033f4:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033fb:	83 c2 10             	add    $0x10,%edx
801033fe:	89 04 95 8c 22 11 80 	mov    %eax,-0x7feedd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103405:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103409:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010340e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103411:	7f db                	jg     801033ee <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103413:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103416:	89 04 24             	mov    %eax,(%esp)
80103419:	e8 f9 cd ff ff       	call   80100217 <brelse>
}
8010341e:	c9                   	leave  
8010341f:	c3                   	ret    

80103420 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103420:	55                   	push   %ebp
80103421:	89 e5                	mov    %esp,%ebp
80103423:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103426:	a1 b4 22 11 80       	mov    0x801122b4,%eax
8010342b:	89 c2                	mov    %eax,%edx
8010342d:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103432:	89 54 24 04          	mov    %edx,0x4(%esp)
80103436:	89 04 24             	mov    %eax,(%esp)
80103439:	e8 68 cd ff ff       	call   801001a6 <bread>
8010343e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103444:	83 c0 18             	add    $0x18,%eax
80103447:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010344a:	8b 15 c8 22 11 80    	mov    0x801122c8,%edx
80103450:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103453:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103455:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010345c:	eb 1b                	jmp    80103479 <write_head+0x59>
    hb->block[i] = log.lh.block[i];
8010345e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103461:	83 c0 10             	add    $0x10,%eax
80103464:	8b 0c 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%ecx
8010346b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103471:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103475:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103479:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010347e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103481:	7f db                	jg     8010345e <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103486:	89 04 24             	mov    %eax,(%esp)
80103489:	e8 4f cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
8010348e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103491:	89 04 24             	mov    %eax,(%esp)
80103494:	e8 7e cd ff ff       	call   80100217 <brelse>
}
80103499:	c9                   	leave  
8010349a:	c3                   	ret    

8010349b <recover_from_log>:

static void
recover_from_log(void)
{
8010349b:	55                   	push   %ebp
8010349c:	89 e5                	mov    %esp,%ebp
8010349e:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034a1:	e8 0b ff ff ff       	call   801033b1 <read_head>
  install_trans(); // if committed, copy from log to disk
801034a6:	e8 58 fe ff ff       	call   80103303 <install_trans>
  log.lh.n = 0;
801034ab:	c7 05 c8 22 11 80 00 	movl   $0x0,0x801122c8
801034b2:	00 00 00 
  write_head(); // clear the log
801034b5:	e8 66 ff ff ff       	call   80103420 <write_head>
}
801034ba:	c9                   	leave  
801034bb:	c3                   	ret    

801034bc <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034bc:	55                   	push   %ebp
801034bd:	89 e5                	mov    %esp,%ebp
801034bf:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801034c2:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801034c9:	e8 0f 1c 00 00       	call   801050dd <acquire>
  while(1){
    if(log.committing){
801034ce:	a1 c0 22 11 80       	mov    0x801122c0,%eax
801034d3:	85 c0                	test   %eax,%eax
801034d5:	74 16                	je     801034ed <begin_op+0x31>
      sleep(&log, &log.lock);
801034d7:	c7 44 24 04 80 22 11 	movl   $0x80112280,0x4(%esp)
801034de:	80 
801034df:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801034e6:	e8 27 17 00 00       	call   80104c12 <sleep>
801034eb:	eb 4f                	jmp    8010353c <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034ed:	8b 0d c8 22 11 80    	mov    0x801122c8,%ecx
801034f3:	a1 bc 22 11 80       	mov    0x801122bc,%eax
801034f8:	8d 50 01             	lea    0x1(%eax),%edx
801034fb:	89 d0                	mov    %edx,%eax
801034fd:	c1 e0 02             	shl    $0x2,%eax
80103500:	01 d0                	add    %edx,%eax
80103502:	01 c0                	add    %eax,%eax
80103504:	01 c8                	add    %ecx,%eax
80103506:	83 f8 1e             	cmp    $0x1e,%eax
80103509:	7e 16                	jle    80103521 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010350b:	c7 44 24 04 80 22 11 	movl   $0x80112280,0x4(%esp)
80103512:	80 
80103513:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
8010351a:	e8 f3 16 00 00       	call   80104c12 <sleep>
8010351f:	eb 1b                	jmp    8010353c <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103521:	a1 bc 22 11 80       	mov    0x801122bc,%eax
80103526:	83 c0 01             	add    $0x1,%eax
80103529:	a3 bc 22 11 80       	mov    %eax,0x801122bc
      release(&log.lock);
8010352e:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103535:	e8 05 1c 00 00       	call   8010513f <release>
      break;
8010353a:	eb 02                	jmp    8010353e <begin_op+0x82>
    }
  }
8010353c:	eb 90                	jmp    801034ce <begin_op+0x12>
}
8010353e:	c9                   	leave  
8010353f:	c3                   	ret    

80103540 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103540:	55                   	push   %ebp
80103541:	89 e5                	mov    %esp,%ebp
80103543:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103546:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010354d:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103554:	e8 84 1b 00 00       	call   801050dd <acquire>
  log.outstanding -= 1;
80103559:	a1 bc 22 11 80       	mov    0x801122bc,%eax
8010355e:	83 e8 01             	sub    $0x1,%eax
80103561:	a3 bc 22 11 80       	mov    %eax,0x801122bc
  if(log.committing)
80103566:	a1 c0 22 11 80       	mov    0x801122c0,%eax
8010356b:	85 c0                	test   %eax,%eax
8010356d:	74 0c                	je     8010357b <end_op+0x3b>
    panic("log.committing");
8010356f:	c7 04 24 58 8a 10 80 	movl   $0x80108a58,(%esp)
80103576:	e8 bf cf ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
8010357b:	a1 bc 22 11 80       	mov    0x801122bc,%eax
80103580:	85 c0                	test   %eax,%eax
80103582:	75 13                	jne    80103597 <end_op+0x57>
    do_commit = 1;
80103584:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010358b:	c7 05 c0 22 11 80 01 	movl   $0x1,0x801122c0
80103592:	00 00 00 
80103595:	eb 0c                	jmp    801035a3 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103597:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
8010359e:	e8 4b 17 00 00       	call   80104cee <wakeup>
  }
  release(&log.lock);
801035a3:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035aa:	e8 90 1b 00 00       	call   8010513f <release>

  if(do_commit){
801035af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035b3:	74 33                	je     801035e8 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035b5:	e8 de 00 00 00       	call   80103698 <commit>
    acquire(&log.lock);
801035ba:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035c1:	e8 17 1b 00 00       	call   801050dd <acquire>
    log.committing = 0;
801035c6:	c7 05 c0 22 11 80 00 	movl   $0x0,0x801122c0
801035cd:	00 00 00 
    wakeup(&log);
801035d0:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035d7:	e8 12 17 00 00       	call   80104cee <wakeup>
    release(&log.lock);
801035dc:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035e3:	e8 57 1b 00 00       	call   8010513f <release>
  }
}
801035e8:	c9                   	leave  
801035e9:	c3                   	ret    

801035ea <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801035ea:	55                   	push   %ebp
801035eb:	89 e5                	mov    %esp,%ebp
801035ed:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035f7:	e9 8c 00 00 00       	jmp    80103688 <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035fc:	8b 15 b4 22 11 80    	mov    0x801122b4,%edx
80103602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103605:	01 d0                	add    %edx,%eax
80103607:	83 c0 01             	add    $0x1,%eax
8010360a:	89 c2                	mov    %eax,%edx
8010360c:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103611:	89 54 24 04          	mov    %edx,0x4(%esp)
80103615:	89 04 24             	mov    %eax,(%esp)
80103618:	e8 89 cb ff ff       	call   801001a6 <bread>
8010361d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103623:	83 c0 10             	add    $0x10,%eax
80103626:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
8010362d:	89 c2                	mov    %eax,%edx
8010362f:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103634:	89 54 24 04          	mov    %edx,0x4(%esp)
80103638:	89 04 24             	mov    %eax,(%esp)
8010363b:	e8 66 cb ff ff       	call   801001a6 <bread>
80103640:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103643:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103646:	8d 50 18             	lea    0x18(%eax),%edx
80103649:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010364c:	83 c0 18             	add    $0x18,%eax
8010364f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103656:	00 
80103657:	89 54 24 04          	mov    %edx,0x4(%esp)
8010365b:	89 04 24             	mov    %eax,(%esp)
8010365e:	e8 9d 1d 00 00       	call   80105400 <memmove>
    bwrite(to);  // write the log
80103663:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103666:	89 04 24             	mov    %eax,(%esp)
80103669:	e8 6f cb ff ff       	call   801001dd <bwrite>
    brelse(from); 
8010366e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103671:	89 04 24             	mov    %eax,(%esp)
80103674:	e8 9e cb ff ff       	call   80100217 <brelse>
    brelse(to);
80103679:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010367c:	89 04 24             	mov    %eax,(%esp)
8010367f:	e8 93 cb ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103684:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103688:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010368d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103690:	0f 8f 66 ff ff ff    	jg     801035fc <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103696:	c9                   	leave  
80103697:	c3                   	ret    

80103698 <commit>:

static void
commit()
{
80103698:	55                   	push   %ebp
80103699:	89 e5                	mov    %esp,%ebp
8010369b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010369e:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	7e 1e                	jle    801036c5 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801036a7:	e8 3e ff ff ff       	call   801035ea <write_log>
    write_head();    // Write header to disk -- the real commit
801036ac:	e8 6f fd ff ff       	call   80103420 <write_head>
    install_trans(); // Now install writes to home locations
801036b1:	e8 4d fc ff ff       	call   80103303 <install_trans>
    log.lh.n = 0; 
801036b6:	c7 05 c8 22 11 80 00 	movl   $0x0,0x801122c8
801036bd:	00 00 00 
    write_head();    // Erase the transaction from the log
801036c0:	e8 5b fd ff ff       	call   80103420 <write_head>
  }
}
801036c5:	c9                   	leave  
801036c6:	c3                   	ret    

801036c7 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036c7:	55                   	push   %ebp
801036c8:	89 e5                	mov    %esp,%ebp
801036ca:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036cd:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801036d2:	83 f8 1d             	cmp    $0x1d,%eax
801036d5:	7f 12                	jg     801036e9 <log_write+0x22>
801036d7:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801036dc:	8b 15 b8 22 11 80    	mov    0x801122b8,%edx
801036e2:	83 ea 01             	sub    $0x1,%edx
801036e5:	39 d0                	cmp    %edx,%eax
801036e7:	7c 0c                	jl     801036f5 <log_write+0x2e>
    panic("too big a transaction");
801036e9:	c7 04 24 67 8a 10 80 	movl   $0x80108a67,(%esp)
801036f0:	e8 45 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
801036f5:	a1 bc 22 11 80       	mov    0x801122bc,%eax
801036fa:	85 c0                	test   %eax,%eax
801036fc:	7f 0c                	jg     8010370a <log_write+0x43>
    panic("log_write outside of trans");
801036fe:	c7 04 24 7d 8a 10 80 	movl   $0x80108a7d,(%esp)
80103705:	e8 30 ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010370a:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103711:	e8 c7 19 00 00       	call   801050dd <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010371d:	eb 1f                	jmp    8010373e <log_write+0x77>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010371f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103722:	83 c0 10             	add    $0x10,%eax
80103725:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
8010372c:	89 c2                	mov    %eax,%edx
8010372e:	8b 45 08             	mov    0x8(%ebp),%eax
80103731:	8b 40 08             	mov    0x8(%eax),%eax
80103734:	39 c2                	cmp    %eax,%edx
80103736:	75 02                	jne    8010373a <log_write+0x73>
      break;
80103738:	eb 0e                	jmp    80103748 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010373a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010373e:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103743:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103746:	7f d7                	jg     8010371f <log_write+0x58>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103748:	8b 45 08             	mov    0x8(%ebp),%eax
8010374b:	8b 40 08             	mov    0x8(%eax),%eax
8010374e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103751:	83 c2 10             	add    $0x10,%edx
80103754:	89 04 95 8c 22 11 80 	mov    %eax,-0x7feedd74(,%edx,4)
  if (i == log.lh.n)
8010375b:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103760:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103763:	75 0d                	jne    80103772 <log_write+0xab>
    log.lh.n++;
80103765:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010376a:	83 c0 01             	add    $0x1,%eax
8010376d:	a3 c8 22 11 80       	mov    %eax,0x801122c8
  b->flags |= B_DIRTY; // prevent eviction
80103772:	8b 45 08             	mov    0x8(%ebp),%eax
80103775:	8b 00                	mov    (%eax),%eax
80103777:	83 c8 04             	or     $0x4,%eax
8010377a:	89 c2                	mov    %eax,%edx
8010377c:	8b 45 08             	mov    0x8(%ebp),%eax
8010377f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103781:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103788:	e8 b2 19 00 00       	call   8010513f <release>
}
8010378d:	c9                   	leave  
8010378e:	c3                   	ret    

8010378f <v2p>:
8010378f:	55                   	push   %ebp
80103790:	89 e5                	mov    %esp,%ebp
80103792:	8b 45 08             	mov    0x8(%ebp),%eax
80103795:	05 00 00 00 80       	add    $0x80000000,%eax
8010379a:	5d                   	pop    %ebp
8010379b:	c3                   	ret    

8010379c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010379c:	55                   	push   %ebp
8010379d:	89 e5                	mov    %esp,%ebp
8010379f:	8b 45 08             	mov    0x8(%ebp),%eax
801037a2:	05 00 00 00 80       	add    $0x80000000,%eax
801037a7:	5d                   	pop    %ebp
801037a8:	c3                   	ret    

801037a9 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801037a9:	55                   	push   %ebp
801037aa:	89 e5                	mov    %esp,%ebp
801037ac:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801037af:	8b 55 08             	mov    0x8(%ebp),%edx
801037b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801037b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801037b8:	f0 87 02             	lock xchg %eax,(%edx)
801037bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801037c1:	c9                   	leave  
801037c2:	c3                   	ret    

801037c3 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801037c3:	55                   	push   %ebp
801037c4:	89 e5                	mov    %esp,%ebp
801037c6:	83 e4 f0             	and    $0xfffffff0,%esp
801037c9:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801037cc:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801037d3:	80 
801037d4:	c7 04 24 5c 53 11 80 	movl   $0x8011535c,(%esp)
801037db:	e8 8a f2 ff ff       	call   80102a6a <kinit1>
  kvmalloc();      // kernel page table
801037e0:	e8 42 48 00 00       	call   80108027 <kvmalloc>
  mpinit();        // collect info about this machine
801037e5:	e8 41 04 00 00       	call   80103c2b <mpinit>
  lapicinit();
801037ea:	e8 e6 f5 ff ff       	call   80102dd5 <lapicinit>
  seginit();       // set up segments
801037ef:	e8 c6 41 00 00       	call   801079ba <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037f4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037fa:	0f b6 00             	movzbl (%eax),%eax
801037fd:	0f b6 c0             	movzbl %al,%eax
80103800:	89 44 24 04          	mov    %eax,0x4(%esp)
80103804:	c7 04 24 98 8a 10 80 	movl   $0x80108a98,(%esp)
8010380b:	e8 90 cb ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103810:	e8 74 06 00 00       	call   80103e89 <picinit>
  ioapicinit();    // another interrupt controller
80103815:	e8 46 f1 ff ff       	call   80102960 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010381a:	e8 91 d2 ff ff       	call   80100ab0 <consoleinit>
  uartinit();      // serial port
8010381f:	e8 e5 34 00 00       	call   80106d09 <uartinit>
  pinit();         // process table
80103824:	e8 6a 0b 00 00       	call   80104393 <pinit>
  tvinit();        // trap vectors
80103829:	e8 8d 30 00 00       	call   801068bb <tvinit>
  binit();         // buffer cache
8010382e:	e8 01 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103833:	e8 ed d6 ff ff       	call   80100f25 <fileinit>
  ideinit();       // disk
80103838:	e8 55 ed ff ff       	call   80102592 <ideinit>
  if(!ismp)
8010383d:	a1 64 23 11 80       	mov    0x80112364,%eax
80103842:	85 c0                	test   %eax,%eax
80103844:	75 05                	jne    8010384b <main+0x88>
    timerinit();   // uniprocessor timer
80103846:	e8 bb 2f 00 00       	call   80106806 <timerinit>
  startothers();   // start other processors
8010384b:	e8 7f 00 00 00       	call   801038cf <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103850:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103857:	8e 
80103858:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010385f:	e8 3e f2 ff ff       	call   80102aa2 <kinit2>
  userinit();      // first user process
80103864:	e8 48 0c 00 00       	call   801044b1 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103869:	e8 1a 00 00 00       	call   80103888 <mpmain>

8010386e <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010386e:	55                   	push   %ebp
8010386f:	89 e5                	mov    %esp,%ebp
80103871:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103874:	e8 c5 47 00 00       	call   8010803e <switchkvm>
  seginit();
80103879:	e8 3c 41 00 00       	call   801079ba <seginit>
  lapicinit();
8010387e:	e8 52 f5 ff ff       	call   80102dd5 <lapicinit>
  mpmain();
80103883:	e8 00 00 00 00       	call   80103888 <mpmain>

80103888 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103888:	55                   	push   %ebp
80103889:	89 e5                	mov    %esp,%ebp
8010388b:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010388e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103894:	0f b6 00             	movzbl (%eax),%eax
80103897:	0f b6 c0             	movzbl %al,%eax
8010389a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010389e:	c7 04 24 af 8a 10 80 	movl   $0x80108aaf,(%esp)
801038a5:	e8 f6 ca ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
801038aa:	e8 80 31 00 00       	call   80106a2f <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801038af:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038b5:	05 a8 00 00 00       	add    $0xa8,%eax
801038ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801038c1:	00 
801038c2:	89 04 24             	mov    %eax,(%esp)
801038c5:	e8 df fe ff ff       	call   801037a9 <xchg>
  scheduler();     // start running processes
801038ca:	e8 85 11 00 00       	call   80104a54 <scheduler>

801038cf <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801038cf:	55                   	push   %ebp
801038d0:	89 e5                	mov    %esp,%ebp
801038d2:	53                   	push   %ebx
801038d3:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801038d6:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801038dd:	e8 ba fe ff ff       	call   8010379c <p2v>
801038e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038e5:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038ea:	89 44 24 08          	mov    %eax,0x8(%esp)
801038ee:	c7 44 24 04 2c b5 10 	movl   $0x8010b52c,0x4(%esp)
801038f5:	80 
801038f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038f9:	89 04 24             	mov    %eax,(%esp)
801038fc:	e8 ff 1a 00 00       	call   80105400 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103901:	c7 45 f4 80 23 11 80 	movl   $0x80112380,-0xc(%ebp)
80103908:	e9 85 00 00 00       	jmp    80103992 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
8010390d:	e8 1c f6 ff ff       	call   80102f2e <cpunum>
80103912:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103918:	05 80 23 11 80       	add    $0x80112380,%eax
8010391d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103920:	75 02                	jne    80103924 <startothers+0x55>
      continue;
80103922:	eb 67                	jmp    8010398b <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103924:	e8 6f f2 ff ff       	call   80102b98 <kalloc>
80103929:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010392c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010392f:	83 e8 04             	sub    $0x4,%eax
80103932:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103935:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010393b:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010393d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103940:	83 e8 08             	sub    $0x8,%eax
80103943:	c7 00 6e 38 10 80    	movl   $0x8010386e,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010394c:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010394f:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103956:	e8 34 fe ff ff       	call   8010378f <v2p>
8010395b:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010395d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103960:	89 04 24             	mov    %eax,(%esp)
80103963:	e8 27 fe ff ff       	call   8010378f <v2p>
80103968:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010396b:	0f b6 12             	movzbl (%edx),%edx
8010396e:	0f b6 d2             	movzbl %dl,%edx
80103971:	89 44 24 04          	mov    %eax,0x4(%esp)
80103975:	89 14 24             	mov    %edx,(%esp)
80103978:	e8 33 f6 ff ff       	call   80102fb0 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010397d:	90                   	nop
8010397e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103981:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103987:	85 c0                	test   %eax,%eax
80103989:	74 f3                	je     8010397e <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010398b:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103992:	a1 60 29 11 80       	mov    0x80112960,%eax
80103997:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010399d:	05 80 23 11 80       	add    $0x80112380,%eax
801039a2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039a5:	0f 87 62 ff ff ff    	ja     8010390d <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039ab:	83 c4 24             	add    $0x24,%esp
801039ae:	5b                   	pop    %ebx
801039af:	5d                   	pop    %ebp
801039b0:	c3                   	ret    

801039b1 <p2v>:
801039b1:	55                   	push   %ebp
801039b2:	89 e5                	mov    %esp,%ebp
801039b4:	8b 45 08             	mov    0x8(%ebp),%eax
801039b7:	05 00 00 00 80       	add    $0x80000000,%eax
801039bc:	5d                   	pop    %ebp
801039bd:	c3                   	ret    

801039be <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801039be:	55                   	push   %ebp
801039bf:	89 e5                	mov    %esp,%ebp
801039c1:	83 ec 14             	sub    $0x14,%esp
801039c4:	8b 45 08             	mov    0x8(%ebp),%eax
801039c7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039cb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801039cf:	89 c2                	mov    %eax,%edx
801039d1:	ec                   	in     (%dx),%al
801039d2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801039d5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801039d9:	c9                   	leave  
801039da:	c3                   	ret    

801039db <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039db:	55                   	push   %ebp
801039dc:	89 e5                	mov    %esp,%ebp
801039de:	83 ec 08             	sub    $0x8,%esp
801039e1:	8b 55 08             	mov    0x8(%ebp),%edx
801039e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801039e7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039eb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039ee:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039f2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039f6:	ee                   	out    %al,(%dx)
}
801039f7:	c9                   	leave  
801039f8:	c3                   	ret    

801039f9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039f9:	55                   	push   %ebp
801039fa:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039fc:	a1 64 b6 10 80       	mov    0x8010b664,%eax
80103a01:	89 c2                	mov    %eax,%edx
80103a03:	b8 80 23 11 80       	mov    $0x80112380,%eax
80103a08:	29 c2                	sub    %eax,%edx
80103a0a:	89 d0                	mov    %edx,%eax
80103a0c:	c1 f8 02             	sar    $0x2,%eax
80103a0f:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103a15:	5d                   	pop    %ebp
80103a16:	c3                   	ret    

80103a17 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103a17:	55                   	push   %ebp
80103a18:	89 e5                	mov    %esp,%ebp
80103a1a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103a1d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a24:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a2b:	eb 15                	jmp    80103a42 <sum+0x2b>
    sum += addr[i];
80103a2d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a30:	8b 45 08             	mov    0x8(%ebp),%eax
80103a33:	01 d0                	add    %edx,%eax
80103a35:	0f b6 00             	movzbl (%eax),%eax
80103a38:	0f b6 c0             	movzbl %al,%eax
80103a3b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a3e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a45:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a48:	7c e3                	jl     80103a2d <sum+0x16>
    sum += addr[i];
  return sum;
80103a4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a4d:	c9                   	leave  
80103a4e:	c3                   	ret    

80103a4f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a4f:	55                   	push   %ebp
80103a50:	89 e5                	mov    %esp,%ebp
80103a52:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a55:	8b 45 08             	mov    0x8(%ebp),%eax
80103a58:	89 04 24             	mov    %eax,(%esp)
80103a5b:	e8 51 ff ff ff       	call   801039b1 <p2v>
80103a60:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a63:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a69:	01 d0                	add    %edx,%eax
80103a6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a74:	eb 3f                	jmp    80103ab5 <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a76:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a7d:	00 
80103a7e:	c7 44 24 04 c0 8a 10 	movl   $0x80108ac0,0x4(%esp)
80103a85:	80 
80103a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a89:	89 04 24             	mov    %eax,(%esp)
80103a8c:	e8 17 19 00 00       	call   801053a8 <memcmp>
80103a91:	85 c0                	test   %eax,%eax
80103a93:	75 1c                	jne    80103ab1 <mpsearch1+0x62>
80103a95:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a9c:	00 
80103a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa0:	89 04 24             	mov    %eax,(%esp)
80103aa3:	e8 6f ff ff ff       	call   80103a17 <sum>
80103aa8:	84 c0                	test   %al,%al
80103aaa:	75 05                	jne    80103ab1 <mpsearch1+0x62>
      return (struct mp*)p;
80103aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aaf:	eb 11                	jmp    80103ac2 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103ab1:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103abb:	72 b9                	jb     80103a76 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ac2:	c9                   	leave  
80103ac3:	c3                   	ret    

80103ac4 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ac4:	55                   	push   %ebp
80103ac5:	89 e5                	mov    %esp,%ebp
80103ac7:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103aca:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad4:	83 c0 0f             	add    $0xf,%eax
80103ad7:	0f b6 00             	movzbl (%eax),%eax
80103ada:	0f b6 c0             	movzbl %al,%eax
80103add:	c1 e0 08             	shl    $0x8,%eax
80103ae0:	89 c2                	mov    %eax,%edx
80103ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae5:	83 c0 0e             	add    $0xe,%eax
80103ae8:	0f b6 00             	movzbl (%eax),%eax
80103aeb:	0f b6 c0             	movzbl %al,%eax
80103aee:	09 d0                	or     %edx,%eax
80103af0:	c1 e0 04             	shl    $0x4,%eax
80103af3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103af6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103afa:	74 21                	je     80103b1d <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103afc:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b03:	00 
80103b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b07:	89 04 24             	mov    %eax,(%esp)
80103b0a:	e8 40 ff ff ff       	call   80103a4f <mpsearch1>
80103b0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b12:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b16:	74 50                	je     80103b68 <mpsearch+0xa4>
      return mp;
80103b18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b1b:	eb 5f                	jmp    80103b7c <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b20:	83 c0 14             	add    $0x14,%eax
80103b23:	0f b6 00             	movzbl (%eax),%eax
80103b26:	0f b6 c0             	movzbl %al,%eax
80103b29:	c1 e0 08             	shl    $0x8,%eax
80103b2c:	89 c2                	mov    %eax,%edx
80103b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b31:	83 c0 13             	add    $0x13,%eax
80103b34:	0f b6 00             	movzbl (%eax),%eax
80103b37:	0f b6 c0             	movzbl %al,%eax
80103b3a:	09 d0                	or     %edx,%eax
80103b3c:	c1 e0 0a             	shl    $0xa,%eax
80103b3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b45:	2d 00 04 00 00       	sub    $0x400,%eax
80103b4a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b51:	00 
80103b52:	89 04 24             	mov    %eax,(%esp)
80103b55:	e8 f5 fe ff ff       	call   80103a4f <mpsearch1>
80103b5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b5d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b61:	74 05                	je     80103b68 <mpsearch+0xa4>
      return mp;
80103b63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b66:	eb 14                	jmp    80103b7c <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b68:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b6f:	00 
80103b70:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b77:	e8 d3 fe ff ff       	call   80103a4f <mpsearch1>
}
80103b7c:	c9                   	leave  
80103b7d:	c3                   	ret    

80103b7e <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b7e:	55                   	push   %ebp
80103b7f:	89 e5                	mov    %esp,%ebp
80103b81:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b84:	e8 3b ff ff ff       	call   80103ac4 <mpsearch>
80103b89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b90:	74 0a                	je     80103b9c <mpconfig+0x1e>
80103b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b95:	8b 40 04             	mov    0x4(%eax),%eax
80103b98:	85 c0                	test   %eax,%eax
80103b9a:	75 0a                	jne    80103ba6 <mpconfig+0x28>
    return 0;
80103b9c:	b8 00 00 00 00       	mov    $0x0,%eax
80103ba1:	e9 83 00 00 00       	jmp    80103c29 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba9:	8b 40 04             	mov    0x4(%eax),%eax
80103bac:	89 04 24             	mov    %eax,(%esp)
80103baf:	e8 fd fd ff ff       	call   801039b1 <p2v>
80103bb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103bb7:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103bbe:	00 
80103bbf:	c7 44 24 04 c5 8a 10 	movl   $0x80108ac5,0x4(%esp)
80103bc6:	80 
80103bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bca:	89 04 24             	mov    %eax,(%esp)
80103bcd:	e8 d6 17 00 00       	call   801053a8 <memcmp>
80103bd2:	85 c0                	test   %eax,%eax
80103bd4:	74 07                	je     80103bdd <mpconfig+0x5f>
    return 0;
80103bd6:	b8 00 00 00 00       	mov    $0x0,%eax
80103bdb:	eb 4c                	jmp    80103c29 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be0:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103be4:	3c 01                	cmp    $0x1,%al
80103be6:	74 12                	je     80103bfa <mpconfig+0x7c>
80103be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103beb:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bef:	3c 04                	cmp    $0x4,%al
80103bf1:	74 07                	je     80103bfa <mpconfig+0x7c>
    return 0;
80103bf3:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf8:	eb 2f                	jmp    80103c29 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfd:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c01:	0f b7 c0             	movzwl %ax,%eax
80103c04:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c0b:	89 04 24             	mov    %eax,(%esp)
80103c0e:	e8 04 fe ff ff       	call   80103a17 <sum>
80103c13:	84 c0                	test   %al,%al
80103c15:	74 07                	je     80103c1e <mpconfig+0xa0>
    return 0;
80103c17:	b8 00 00 00 00       	mov    $0x0,%eax
80103c1c:	eb 0b                	jmp    80103c29 <mpconfig+0xab>
  *pmp = mp;
80103c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c24:	89 10                	mov    %edx,(%eax)
  return conf;
80103c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c29:	c9                   	leave  
80103c2a:	c3                   	ret    

80103c2b <mpinit>:

void
mpinit(void)
{
80103c2b:	55                   	push   %ebp
80103c2c:	89 e5                	mov    %esp,%ebp
80103c2e:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c31:	c7 05 64 b6 10 80 80 	movl   $0x80112380,0x8010b664
80103c38:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c3b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c3e:	89 04 24             	mov    %eax,(%esp)
80103c41:	e8 38 ff ff ff       	call   80103b7e <mpconfig>
80103c46:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c4d:	75 05                	jne    80103c54 <mpinit+0x29>
    return;
80103c4f:	e9 9c 01 00 00       	jmp    80103df0 <mpinit+0x1c5>
  ismp = 1;
80103c54:	c7 05 64 23 11 80 01 	movl   $0x1,0x80112364
80103c5b:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c61:	8b 40 24             	mov    0x24(%eax),%eax
80103c64:	a3 7c 22 11 80       	mov    %eax,0x8011227c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c6c:	83 c0 2c             	add    $0x2c,%eax
80103c6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c75:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c79:	0f b7 d0             	movzwl %ax,%edx
80103c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c7f:	01 d0                	add    %edx,%eax
80103c81:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c84:	e9 f4 00 00 00       	jmp    80103d7d <mpinit+0x152>
    switch(*p){
80103c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8c:	0f b6 00             	movzbl (%eax),%eax
80103c8f:	0f b6 c0             	movzbl %al,%eax
80103c92:	83 f8 04             	cmp    $0x4,%eax
80103c95:	0f 87 bf 00 00 00    	ja     80103d5a <mpinit+0x12f>
80103c9b:	8b 04 85 08 8b 10 80 	mov    -0x7fef74f8(,%eax,4),%eax
80103ca2:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca7:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103caa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cad:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cb1:	0f b6 d0             	movzbl %al,%edx
80103cb4:	a1 60 29 11 80       	mov    0x80112960,%eax
80103cb9:	39 c2                	cmp    %eax,%edx
80103cbb:	74 2d                	je     80103cea <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103cbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cc0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cc4:	0f b6 d0             	movzbl %al,%edx
80103cc7:	a1 60 29 11 80       	mov    0x80112960,%eax
80103ccc:	89 54 24 08          	mov    %edx,0x8(%esp)
80103cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cd4:	c7 04 24 ca 8a 10 80 	movl   $0x80108aca,(%esp)
80103cdb:	e8 c0 c6 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103ce0:	c7 05 64 23 11 80 00 	movl   $0x0,0x80112364
80103ce7:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103cea:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ced:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103cf1:	0f b6 c0             	movzbl %al,%eax
80103cf4:	83 e0 02             	and    $0x2,%eax
80103cf7:	85 c0                	test   %eax,%eax
80103cf9:	74 15                	je     80103d10 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103cfb:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d00:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d06:	05 80 23 11 80       	add    $0x80112380,%eax
80103d0b:	a3 64 b6 10 80       	mov    %eax,0x8010b664
      cpus[ncpu].id = ncpu;
80103d10:	8b 15 60 29 11 80    	mov    0x80112960,%edx
80103d16:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d1b:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103d21:	81 c2 80 23 11 80    	add    $0x80112380,%edx
80103d27:	88 02                	mov    %al,(%edx)
      ncpu++;
80103d29:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d2e:	83 c0 01             	add    $0x1,%eax
80103d31:	a3 60 29 11 80       	mov    %eax,0x80112960
      p += sizeof(struct mpproc);
80103d36:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d3a:	eb 41                	jmp    80103d7d <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d45:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d49:	a2 60 23 11 80       	mov    %al,0x80112360
      p += sizeof(struct mpioapic);
80103d4e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d52:	eb 29                	jmp    80103d7d <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d54:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d58:	eb 23                	jmp    80103d7d <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5d:	0f b6 00             	movzbl (%eax),%eax
80103d60:	0f b6 c0             	movzbl %al,%eax
80103d63:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d67:	c7 04 24 e8 8a 10 80 	movl   $0x80108ae8,(%esp)
80103d6e:	e8 2d c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103d73:	c7 05 64 23 11 80 00 	movl   $0x0,0x80112364
80103d7a:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d80:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d83:	0f 82 00 ff ff ff    	jb     80103c89 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d89:	a1 64 23 11 80       	mov    0x80112364,%eax
80103d8e:	85 c0                	test   %eax,%eax
80103d90:	75 1d                	jne    80103daf <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d92:	c7 05 60 29 11 80 01 	movl   $0x1,0x80112960
80103d99:	00 00 00 
    lapic = 0;
80103d9c:	c7 05 7c 22 11 80 00 	movl   $0x0,0x8011227c
80103da3:	00 00 00 
    ioapicid = 0;
80103da6:	c6 05 60 23 11 80 00 	movb   $0x0,0x80112360
    return;
80103dad:	eb 41                	jmp    80103df0 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103daf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db2:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103db6:	84 c0                	test   %al,%al
80103db8:	74 36                	je     80103df0 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103dba:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103dc1:	00 
80103dc2:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103dc9:	e8 0d fc ff ff       	call   801039db <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103dce:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103dd5:	e8 e4 fb ff ff       	call   801039be <inb>
80103dda:	83 c8 01             	or     $0x1,%eax
80103ddd:	0f b6 c0             	movzbl %al,%eax
80103de0:	89 44 24 04          	mov    %eax,0x4(%esp)
80103de4:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103deb:	e8 eb fb ff ff       	call   801039db <outb>
  }
}
80103df0:	c9                   	leave  
80103df1:	c3                   	ret    

80103df2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103df2:	55                   	push   %ebp
80103df3:	89 e5                	mov    %esp,%ebp
80103df5:	83 ec 08             	sub    $0x8,%esp
80103df8:	8b 55 08             	mov    0x8(%ebp),%edx
80103dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dfe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e02:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e05:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e09:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e0d:	ee                   	out    %al,(%dx)
}
80103e0e:	c9                   	leave  
80103e0f:	c3                   	ret    

80103e10 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103e10:	55                   	push   %ebp
80103e11:	89 e5                	mov    %esp,%ebp
80103e13:	83 ec 0c             	sub    $0xc,%esp
80103e16:	8b 45 08             	mov    0x8(%ebp),%eax
80103e19:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103e1d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e21:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103e27:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e2b:	0f b6 c0             	movzbl %al,%eax
80103e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e32:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e39:	e8 b4 ff ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103e3e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e42:	66 c1 e8 08          	shr    $0x8,%ax
80103e46:	0f b6 c0             	movzbl %al,%eax
80103e49:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e4d:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e54:	e8 99 ff ff ff       	call   80103df2 <outb>
}
80103e59:	c9                   	leave  
80103e5a:	c3                   	ret    

80103e5b <picenable>:

void
picenable(int irq)
{
80103e5b:	55                   	push   %ebp
80103e5c:	89 e5                	mov    %esp,%ebp
80103e5e:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e61:	8b 45 08             	mov    0x8(%ebp),%eax
80103e64:	ba 01 00 00 00       	mov    $0x1,%edx
80103e69:	89 c1                	mov    %eax,%ecx
80103e6b:	d3 e2                	shl    %cl,%edx
80103e6d:	89 d0                	mov    %edx,%eax
80103e6f:	f7 d0                	not    %eax
80103e71:	89 c2                	mov    %eax,%edx
80103e73:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e7a:	21 d0                	and    %edx,%eax
80103e7c:	0f b7 c0             	movzwl %ax,%eax
80103e7f:	89 04 24             	mov    %eax,(%esp)
80103e82:	e8 89 ff ff ff       	call   80103e10 <picsetmask>
}
80103e87:	c9                   	leave  
80103e88:	c3                   	ret    

80103e89 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e89:	55                   	push   %ebp
80103e8a:	89 e5                	mov    %esp,%ebp
80103e8c:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e8f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e96:	00 
80103e97:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e9e:	e8 4f ff ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, 0xFF);
80103ea3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103eaa:	00 
80103eab:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eb2:	e8 3b ff ff ff       	call   80103df2 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103eb7:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ebe:	00 
80103ebf:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ec6:	e8 27 ff ff ff       	call   80103df2 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103ecb:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103ed2:	00 
80103ed3:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eda:	e8 13 ff ff ff       	call   80103df2 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103edf:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ee6:	00 
80103ee7:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eee:	e8 ff fe ff ff       	call   80103df2 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ef3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103efa:	00 
80103efb:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f02:	e8 eb fe ff ff       	call   80103df2 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f07:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103f0e:	00 
80103f0f:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f16:	e8 d7 fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103f1b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103f22:	00 
80103f23:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f2a:	e8 c3 fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f2f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103f36:	00 
80103f37:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f3e:	e8 af fe ff ff       	call   80103df2 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f43:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f4a:	00 
80103f4b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f52:	e8 9b fe ff ff       	call   80103df2 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f57:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f5e:	00 
80103f5f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f66:	e8 87 fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f6b:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f72:	00 
80103f73:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f7a:	e8 73 fe ff ff       	call   80103df2 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f7f:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f86:	00 
80103f87:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f8e:	e8 5f fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f93:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f9a:	00 
80103f9b:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103fa2:	e8 4b fe ff ff       	call   80103df2 <outb>

  if(irqmask != 0xFFFF)
80103fa7:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103fae:	66 83 f8 ff          	cmp    $0xffff,%ax
80103fb2:	74 12                	je     80103fc6 <picinit+0x13d>
    picsetmask(irqmask);
80103fb4:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103fbb:	0f b7 c0             	movzwl %ax,%eax
80103fbe:	89 04 24             	mov    %eax,(%esp)
80103fc1:	e8 4a fe ff ff       	call   80103e10 <picsetmask>
}
80103fc6:	c9                   	leave  
80103fc7:	c3                   	ret    

80103fc8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103fce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fde:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe1:	8b 10                	mov    (%eax),%edx
80103fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe6:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fe8:	e8 54 cf ff ff       	call   80100f41 <filealloc>
80103fed:	8b 55 08             	mov    0x8(%ebp),%edx
80103ff0:	89 02                	mov    %eax,(%edx)
80103ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff5:	8b 00                	mov    (%eax),%eax
80103ff7:	85 c0                	test   %eax,%eax
80103ff9:	0f 84 c8 00 00 00    	je     801040c7 <pipealloc+0xff>
80103fff:	e8 3d cf ff ff       	call   80100f41 <filealloc>
80104004:	8b 55 0c             	mov    0xc(%ebp),%edx
80104007:	89 02                	mov    %eax,(%edx)
80104009:	8b 45 0c             	mov    0xc(%ebp),%eax
8010400c:	8b 00                	mov    (%eax),%eax
8010400e:	85 c0                	test   %eax,%eax
80104010:	0f 84 b1 00 00 00    	je     801040c7 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104016:	e8 7d eb ff ff       	call   80102b98 <kalloc>
8010401b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010401e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104022:	75 05                	jne    80104029 <pipealloc+0x61>
    goto bad;
80104024:	e9 9e 00 00 00       	jmp    801040c7 <pipealloc+0xff>
  p->readopen = 1;
80104029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104033:	00 00 00 
  p->writeopen = 1;
80104036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104039:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104040:	00 00 00 
  p->nwrite = 0;
80104043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104046:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010404d:	00 00 00 
  p->nread = 0;
80104050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104053:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010405a:	00 00 00 
  initlock(&p->lock, "pipe");
8010405d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104060:	c7 44 24 04 1c 8b 10 	movl   $0x80108b1c,0x4(%esp)
80104067:	80 
80104068:	89 04 24             	mov    %eax,(%esp)
8010406b:	e8 4c 10 00 00       	call   801050bc <initlock>
  (*f0)->type = FD_PIPE;
80104070:	8b 45 08             	mov    0x8(%ebp),%eax
80104073:	8b 00                	mov    (%eax),%eax
80104075:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010407b:	8b 45 08             	mov    0x8(%ebp),%eax
8010407e:	8b 00                	mov    (%eax),%eax
80104080:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104084:	8b 45 08             	mov    0x8(%ebp),%eax
80104087:	8b 00                	mov    (%eax),%eax
80104089:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010408d:	8b 45 08             	mov    0x8(%ebp),%eax
80104090:	8b 00                	mov    (%eax),%eax
80104092:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104095:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104098:	8b 45 0c             	mov    0xc(%ebp),%eax
8010409b:	8b 00                	mov    (%eax),%eax
8010409d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a6:	8b 00                	mov    (%eax),%eax
801040a8:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801040af:	8b 00                	mov    (%eax),%eax
801040b1:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b8:	8b 00                	mov    (%eax),%eax
801040ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040bd:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040c0:	b8 00 00 00 00       	mov    $0x0,%eax
801040c5:	eb 42                	jmp    80104109 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
801040c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040cb:	74 0b                	je     801040d8 <pipealloc+0x110>
    kfree((char*)p);
801040cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d0:	89 04 24             	mov    %eax,(%esp)
801040d3:	e8 27 ea ff ff       	call   80102aff <kfree>
  if(*f0)
801040d8:	8b 45 08             	mov    0x8(%ebp),%eax
801040db:	8b 00                	mov    (%eax),%eax
801040dd:	85 c0                	test   %eax,%eax
801040df:	74 0d                	je     801040ee <pipealloc+0x126>
    fileclose(*f0);
801040e1:	8b 45 08             	mov    0x8(%ebp),%eax
801040e4:	8b 00                	mov    (%eax),%eax
801040e6:	89 04 24             	mov    %eax,(%esp)
801040e9:	e8 fb ce ff ff       	call   80100fe9 <fileclose>
  if(*f1)
801040ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f1:	8b 00                	mov    (%eax),%eax
801040f3:	85 c0                	test   %eax,%eax
801040f5:	74 0d                	je     80104104 <pipealloc+0x13c>
    fileclose(*f1);
801040f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801040fa:	8b 00                	mov    (%eax),%eax
801040fc:	89 04 24             	mov    %eax,(%esp)
801040ff:	e8 e5 ce ff ff       	call   80100fe9 <fileclose>
  return -1;
80104104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104109:	c9                   	leave  
8010410a:	c3                   	ret    

8010410b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010410b:	55                   	push   %ebp
8010410c:	89 e5                	mov    %esp,%ebp
8010410e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104111:	8b 45 08             	mov    0x8(%ebp),%eax
80104114:	89 04 24             	mov    %eax,(%esp)
80104117:	e8 c1 0f 00 00       	call   801050dd <acquire>
  if(writable){
8010411c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104120:	74 1f                	je     80104141 <pipeclose+0x36>
    p->writeopen = 0;
80104122:	8b 45 08             	mov    0x8(%ebp),%eax
80104125:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010412c:	00 00 00 
    wakeup(&p->nread);
8010412f:	8b 45 08             	mov    0x8(%ebp),%eax
80104132:	05 34 02 00 00       	add    $0x234,%eax
80104137:	89 04 24             	mov    %eax,(%esp)
8010413a:	e8 af 0b 00 00       	call   80104cee <wakeup>
8010413f:	eb 1d                	jmp    8010415e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104141:	8b 45 08             	mov    0x8(%ebp),%eax
80104144:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010414b:	00 00 00 
    wakeup(&p->nwrite);
8010414e:	8b 45 08             	mov    0x8(%ebp),%eax
80104151:	05 38 02 00 00       	add    $0x238,%eax
80104156:	89 04 24             	mov    %eax,(%esp)
80104159:	e8 90 0b 00 00       	call   80104cee <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010415e:	8b 45 08             	mov    0x8(%ebp),%eax
80104161:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104167:	85 c0                	test   %eax,%eax
80104169:	75 25                	jne    80104190 <pipeclose+0x85>
8010416b:	8b 45 08             	mov    0x8(%ebp),%eax
8010416e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104174:	85 c0                	test   %eax,%eax
80104176:	75 18                	jne    80104190 <pipeclose+0x85>
    release(&p->lock);
80104178:	8b 45 08             	mov    0x8(%ebp),%eax
8010417b:	89 04 24             	mov    %eax,(%esp)
8010417e:	e8 bc 0f 00 00       	call   8010513f <release>
    kfree((char*)p);
80104183:	8b 45 08             	mov    0x8(%ebp),%eax
80104186:	89 04 24             	mov    %eax,(%esp)
80104189:	e8 71 e9 ff ff       	call   80102aff <kfree>
8010418e:	eb 0b                	jmp    8010419b <pipeclose+0x90>
  } else
    release(&p->lock);
80104190:	8b 45 08             	mov    0x8(%ebp),%eax
80104193:	89 04 24             	mov    %eax,(%esp)
80104196:	e8 a4 0f 00 00       	call   8010513f <release>
}
8010419b:	c9                   	leave  
8010419c:	c3                   	ret    

8010419d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010419d:	55                   	push   %ebp
8010419e:	89 e5                	mov    %esp,%ebp
801041a0:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801041a3:	8b 45 08             	mov    0x8(%ebp),%eax
801041a6:	89 04 24             	mov    %eax,(%esp)
801041a9:	e8 2f 0f 00 00       	call   801050dd <acquire>
  for(i = 0; i < n; i++){
801041ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041b5:	e9 a6 00 00 00       	jmp    80104260 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041ba:	eb 57                	jmp    80104213 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
801041bc:	8b 45 08             	mov    0x8(%ebp),%eax
801041bf:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041c5:	85 c0                	test   %eax,%eax
801041c7:	74 0d                	je     801041d6 <pipewrite+0x39>
801041c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041cf:	8b 40 2c             	mov    0x2c(%eax),%eax
801041d2:	85 c0                	test   %eax,%eax
801041d4:	74 15                	je     801041eb <pipewrite+0x4e>
        release(&p->lock);
801041d6:	8b 45 08             	mov    0x8(%ebp),%eax
801041d9:	89 04 24             	mov    %eax,(%esp)
801041dc:	e8 5e 0f 00 00       	call   8010513f <release>
        return -1;
801041e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041e6:	e9 9f 00 00 00       	jmp    8010428a <pipewrite+0xed>
      }
      wakeup(&p->nread);
801041eb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ee:	05 34 02 00 00       	add    $0x234,%eax
801041f3:	89 04 24             	mov    %eax,(%esp)
801041f6:	e8 f3 0a 00 00       	call   80104cee <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041fb:	8b 45 08             	mov    0x8(%ebp),%eax
801041fe:	8b 55 08             	mov    0x8(%ebp),%edx
80104201:	81 c2 38 02 00 00    	add    $0x238,%edx
80104207:	89 44 24 04          	mov    %eax,0x4(%esp)
8010420b:	89 14 24             	mov    %edx,(%esp)
8010420e:	e8 ff 09 00 00       	call   80104c12 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104213:	8b 45 08             	mov    0x8(%ebp),%eax
80104216:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010421c:	8b 45 08             	mov    0x8(%ebp),%eax
8010421f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104225:	05 00 02 00 00       	add    $0x200,%eax
8010422a:	39 c2                	cmp    %eax,%edx
8010422c:	74 8e                	je     801041bc <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010422e:	8b 45 08             	mov    0x8(%ebp),%eax
80104231:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104237:	8d 48 01             	lea    0x1(%eax),%ecx
8010423a:	8b 55 08             	mov    0x8(%ebp),%edx
8010423d:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104243:	25 ff 01 00 00       	and    $0x1ff,%eax
80104248:	89 c1                	mov    %eax,%ecx
8010424a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010424d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104250:	01 d0                	add    %edx,%eax
80104252:	0f b6 10             	movzbl (%eax),%edx
80104255:	8b 45 08             	mov    0x8(%ebp),%eax
80104258:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010425c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104263:	3b 45 10             	cmp    0x10(%ebp),%eax
80104266:	0f 8c 4e ff ff ff    	jl     801041ba <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010426c:	8b 45 08             	mov    0x8(%ebp),%eax
8010426f:	05 34 02 00 00       	add    $0x234,%eax
80104274:	89 04 24             	mov    %eax,(%esp)
80104277:	e8 72 0a 00 00       	call   80104cee <wakeup>
  release(&p->lock);
8010427c:	8b 45 08             	mov    0x8(%ebp),%eax
8010427f:	89 04 24             	mov    %eax,(%esp)
80104282:	e8 b8 0e 00 00       	call   8010513f <release>
  return n;
80104287:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010428a:	c9                   	leave  
8010428b:	c3                   	ret    

8010428c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010428c:	55                   	push   %ebp
8010428d:	89 e5                	mov    %esp,%ebp
8010428f:	53                   	push   %ebx
80104290:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104293:	8b 45 08             	mov    0x8(%ebp),%eax
80104296:	89 04 24             	mov    %eax,(%esp)
80104299:	e8 3f 0e 00 00       	call   801050dd <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010429e:	eb 3a                	jmp    801042da <piperead+0x4e>
    if(proc->killed){
801042a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042a6:	8b 40 2c             	mov    0x2c(%eax),%eax
801042a9:	85 c0                	test   %eax,%eax
801042ab:	74 15                	je     801042c2 <piperead+0x36>
      release(&p->lock);
801042ad:	8b 45 08             	mov    0x8(%ebp),%eax
801042b0:	89 04 24             	mov    %eax,(%esp)
801042b3:	e8 87 0e 00 00       	call   8010513f <release>
      return -1;
801042b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042bd:	e9 b5 00 00 00       	jmp    80104377 <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042c2:	8b 45 08             	mov    0x8(%ebp),%eax
801042c5:	8b 55 08             	mov    0x8(%ebp),%edx
801042c8:	81 c2 34 02 00 00    	add    $0x234,%edx
801042ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801042d2:	89 14 24             	mov    %edx,(%esp)
801042d5:	e8 38 09 00 00       	call   80104c12 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042da:	8b 45 08             	mov    0x8(%ebp),%eax
801042dd:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042e3:	8b 45 08             	mov    0x8(%ebp),%eax
801042e6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042ec:	39 c2                	cmp    %eax,%edx
801042ee:	75 0d                	jne    801042fd <piperead+0x71>
801042f0:	8b 45 08             	mov    0x8(%ebp),%eax
801042f3:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042f9:	85 c0                	test   %eax,%eax
801042fb:	75 a3                	jne    801042a0 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104304:	eb 4b                	jmp    80104351 <piperead+0xc5>
    if(p->nread == p->nwrite)
80104306:	8b 45 08             	mov    0x8(%ebp),%eax
80104309:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010430f:	8b 45 08             	mov    0x8(%ebp),%eax
80104312:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104318:	39 c2                	cmp    %eax,%edx
8010431a:	75 02                	jne    8010431e <piperead+0x92>
      break;
8010431c:	eb 3b                	jmp    80104359 <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010431e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104321:	8b 45 0c             	mov    0xc(%ebp),%eax
80104324:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104327:	8b 45 08             	mov    0x8(%ebp),%eax
8010432a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104330:	8d 48 01             	lea    0x1(%eax),%ecx
80104333:	8b 55 08             	mov    0x8(%ebp),%edx
80104336:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010433c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104341:	89 c2                	mov    %eax,%edx
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
80104346:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010434b:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010434d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104354:	3b 45 10             	cmp    0x10(%ebp),%eax
80104357:	7c ad                	jl     80104306 <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104359:	8b 45 08             	mov    0x8(%ebp),%eax
8010435c:	05 38 02 00 00       	add    $0x238,%eax
80104361:	89 04 24             	mov    %eax,(%esp)
80104364:	e8 85 09 00 00       	call   80104cee <wakeup>
  release(&p->lock);
80104369:	8b 45 08             	mov    0x8(%ebp),%eax
8010436c:	89 04 24             	mov    %eax,(%esp)
8010436f:	e8 cb 0d 00 00       	call   8010513f <release>
  return i;
80104374:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104377:	83 c4 24             	add    $0x24,%esp
8010437a:	5b                   	pop    %ebx
8010437b:	5d                   	pop    %ebp
8010437c:	c3                   	ret    

8010437d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010437d:	55                   	push   %ebp
8010437e:	89 e5                	mov    %esp,%ebp
80104380:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104383:	9c                   	pushf  
80104384:	58                   	pop    %eax
80104385:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104388:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010438b:	c9                   	leave  
8010438c:	c3                   	ret    

8010438d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010438d:	55                   	push   %ebp
8010438e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104390:	fb                   	sti    
}
80104391:	5d                   	pop    %ebp
80104392:	c3                   	ret    

80104393 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104393:	55                   	push   %ebp
80104394:	89 e5                	mov    %esp,%ebp
80104396:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104399:	c7 44 24 04 21 8b 10 	movl   $0x80108b21,0x4(%esp)
801043a0:	80 
801043a1:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
801043a8:	e8 0f 0d 00 00       	call   801050bc <initlock>
}
801043ad:	c9                   	leave  
801043ae:	c3                   	ret    

801043af <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801043af:	55                   	push   %ebp
801043b0:	89 e5                	mov    %esp,%ebp
801043b2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801043b5:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
801043bc:	e8 1c 0d 00 00       	call   801050dd <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043c1:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
801043c8:	eb 53                	jmp    8010441d <allocproc+0x6e>
    if(p->state == UNUSED)
801043ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cd:	8b 40 0c             	mov    0xc(%eax),%eax
801043d0:	85 c0                	test   %eax,%eax
801043d2:	75 42                	jne    80104416 <allocproc+0x67>
      goto found;
801043d4:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d8:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043df:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043e4:	8d 50 01             	lea    0x1(%eax),%edx
801043e7:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801043ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f0:	89 42 10             	mov    %eax,0x10(%edx)
  //p->gid = nextpid; 
  //p->uid = nextpid;

  release(&ptable.lock);
801043f3:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
801043fa:	e8 40 0d 00 00       	call   8010513f <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043ff:	e8 94 e7 ff ff       	call   80102b98 <kalloc>
80104404:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104407:	89 42 08             	mov    %eax,0x8(%edx)
8010440a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440d:	8b 40 08             	mov    0x8(%eax),%eax
80104410:	85 c0                	test   %eax,%eax
80104412:	75 36                	jne    8010444a <allocproc+0x9b>
80104414:	eb 23                	jmp    80104439 <allocproc+0x8a>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104416:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010441d:	81 7d f4 b4 4a 11 80 	cmpl   $0x80114ab4,-0xc(%ebp)
80104424:	72 a4                	jb     801043ca <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104426:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
8010442d:	e8 0d 0d 00 00       	call   8010513f <release>
  return 0;
80104432:	b8 00 00 00 00       	mov    $0x0,%eax
80104437:	eb 76                	jmp    801044af <allocproc+0x100>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104443:	b8 00 00 00 00       	mov    $0x0,%eax
80104448:	eb 65                	jmp    801044af <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
8010444a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444d:	8b 40 08             	mov    0x8(%eax),%eax
80104450:	05 00 10 00 00       	add    $0x1000,%eax
80104455:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104458:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010445c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104462:	89 50 20             	mov    %edx,0x20(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104465:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104469:	ba 76 68 10 80       	mov    $0x80106876,%edx
8010446e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104471:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104473:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010447d:	89 50 24             	mov    %edx,0x24(%eax)
  memset(p->context, 0, sizeof *p->context);
80104480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104483:	8b 40 24             	mov    0x24(%eax),%eax
80104486:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010448d:	00 
8010448e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104495:	00 
80104496:	89 04 24             	mov    %eax,(%esp)
80104499:	e8 93 0e 00 00       	call   80105331 <memset>
  p->context->eip = (uint)forkret;
8010449e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a1:	8b 40 24             	mov    0x24(%eax),%eax
801044a4:	ba d3 4b 10 80       	mov    $0x80104bd3,%edx
801044a9:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801044ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044af:	c9                   	leave  
801044b0:	c3                   	ret    

801044b1 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801044b1:	55                   	push   %ebp
801044b2:	89 e5                	mov    %esp,%ebp
801044b4:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801044b7:	e8 f3 fe ff ff       	call   801043af <allocproc>
801044bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p->uid=0;
801044bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  p->gid=1;
801044c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cc:	c7 40 18 01 00 00 00 	movl   $0x1,0x18(%eax)

  initproc = p;
801044d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d6:	a3 68 b6 10 80       	mov    %eax,0x8010b668
  if((p->pgdir = setupkvm()) == 0)
801044db:	e8 8a 3a 00 00       	call   80107f6a <setupkvm>
801044e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e3:	89 42 04             	mov    %eax,0x4(%edx)
801044e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e9:	8b 40 04             	mov    0x4(%eax),%eax
801044ec:	85 c0                	test   %eax,%eax
801044ee:	75 0c                	jne    801044fc <userinit+0x4b>
    panic("userinit: out of memory?");
801044f0:	c7 04 24 28 8b 10 80 	movl   $0x80108b28,(%esp)
801044f7:	e8 3e c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044fc:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104504:	8b 40 04             	mov    0x4(%eax),%eax
80104507:	89 54 24 08          	mov    %edx,0x8(%esp)
8010450b:	c7 44 24 04 00 b5 10 	movl   $0x8010b500,0x4(%esp)
80104512:	80 
80104513:	89 04 24             	mov    %eax,(%esp)
80104516:	e8 a7 3c 00 00       	call   801081c2 <inituvm>
  p->sz = PGSIZE;
8010451b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	8b 40 20             	mov    0x20(%eax),%eax
8010452a:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104531:	00 
80104532:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104539:	00 
8010453a:	89 04 24             	mov    %eax,(%esp)
8010453d:	e8 ef 0d 00 00       	call   80105331 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104545:	8b 40 20             	mov    0x20(%eax),%eax
80104548:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010454e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104551:	8b 40 20             	mov    0x20(%eax),%eax
80104554:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010455a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455d:	8b 40 20             	mov    0x20(%eax),%eax
80104560:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104563:	8b 52 20             	mov    0x20(%edx),%edx
80104566:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010456a:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010456e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104571:	8b 40 20             	mov    0x20(%eax),%eax
80104574:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104577:	8b 52 20             	mov    0x20(%edx),%edx
8010457a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010457e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104585:	8b 40 20             	mov    0x20(%eax),%eax
80104588:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010458f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104592:	8b 40 20             	mov    0x20(%eax),%eax
80104595:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010459c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459f:	8b 40 20             	mov    0x20(%eax),%eax
801045a2:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801045a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ac:	83 c0 74             	add    $0x74,%eax
801045af:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801045b6:	00 
801045b7:	c7 44 24 04 41 8b 10 	movl   $0x80108b41,0x4(%esp)
801045be:	80 
801045bf:	89 04 24             	mov    %eax,(%esp)
801045c2:	e8 8a 0f 00 00       	call   80105551 <safestrcpy>
  p->cwd = namei("/");
801045c7:	c7 04 24 4a 8b 10 80 	movl   $0x80108b4a,(%esp)
801045ce:	e8 b2 de ff ff       	call   80102485 <namei>
801045d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d6:	89 42 70             	mov    %eax,0x70(%edx)

  p->state = RUNNABLE;
801045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045e3:	c9                   	leave  
801045e4:	c3                   	ret    

801045e5 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045e5:	55                   	push   %ebp
801045e6:	89 e5                	mov    %esp,%ebp
801045e8:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045f1:	8b 00                	mov    (%eax),%eax
801045f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045f6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045fa:	7e 34                	jle    80104630 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045fc:	8b 55 08             	mov    0x8(%ebp),%edx
801045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104602:	01 c2                	add    %eax,%edx
80104604:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010460a:	8b 40 04             	mov    0x4(%eax),%eax
8010460d:	89 54 24 08          	mov    %edx,0x8(%esp)
80104611:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104614:	89 54 24 04          	mov    %edx,0x4(%esp)
80104618:	89 04 24             	mov    %eax,(%esp)
8010461b:	e8 18 3d 00 00       	call   80108338 <allocuvm>
80104620:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104623:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104627:	75 41                	jne    8010466a <growproc+0x85>
      return -1;
80104629:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010462e:	eb 58                	jmp    80104688 <growproc+0xa3>
  } else if(n < 0){
80104630:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104634:	79 34                	jns    8010466a <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104636:	8b 55 08             	mov    0x8(%ebp),%edx
80104639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463c:	01 c2                	add    %eax,%edx
8010463e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104644:	8b 40 04             	mov    0x4(%eax),%eax
80104647:	89 54 24 08          	mov    %edx,0x8(%esp)
8010464b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104652:	89 04 24             	mov    %eax,(%esp)
80104655:	e8 b8 3d 00 00       	call   80108412 <deallocuvm>
8010465a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010465d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104661:	75 07                	jne    8010466a <growproc+0x85>
      return -1;
80104663:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104668:	eb 1e                	jmp    80104688 <growproc+0xa3>
  }
  proc->sz = sz;
8010466a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104670:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104673:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104675:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010467b:	89 04 24             	mov    %eax,(%esp)
8010467e:	e8 d8 39 00 00       	call   8010805b <switchuvm>
  return 0;
80104683:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104688:	c9                   	leave  
80104689:	c3                   	ret    

8010468a <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010468a:	55                   	push   %ebp
8010468b:	89 e5                	mov    %esp,%ebp
8010468d:	57                   	push   %edi
8010468e:	56                   	push   %esi
8010468f:	53                   	push   %ebx
80104690:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104693:	e8 17 fd ff ff       	call   801043af <allocproc>
80104698:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010469b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010469f:	75 0a                	jne    801046ab <fork+0x21>
    return -1;
801046a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046a6:	e9 6d 01 00 00       	jmp    80104818 <fork+0x18e>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801046ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b1:	8b 10                	mov    (%eax),%edx
801046b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b9:	8b 40 04             	mov    0x4(%eax),%eax
801046bc:	89 54 24 04          	mov    %edx,0x4(%esp)
801046c0:	89 04 24             	mov    %eax,(%esp)
801046c3:	e8 e6 3e 00 00       	call   801085ae <copyuvm>
801046c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046cb:	89 42 04             	mov    %eax,0x4(%edx)
801046ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d1:	8b 40 04             	mov    0x4(%eax),%eax
801046d4:	85 c0                	test   %eax,%eax
801046d6:	75 2c                	jne    80104704 <fork+0x7a>
    kfree(np->kstack);
801046d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046db:	8b 40 08             	mov    0x8(%eax),%eax
801046de:	89 04 24             	mov    %eax,(%esp)
801046e1:	e8 19 e4 ff ff       	call   80102aff <kfree>
    np->kstack = 0;
801046e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ff:	e9 14 01 00 00       	jmp    80104818 <fork+0x18e>
  }
  np->sz = proc->sz;
80104704:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010470a:	8b 10                	mov    (%eax),%edx
8010470c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010470f:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104711:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104718:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010471b:	89 50 1c             	mov    %edx,0x1c(%eax)
  *np->tf = *proc->tf;
8010471e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104721:	8b 50 20             	mov    0x20(%eax),%edx
80104724:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472a:	8b 40 20             	mov    0x20(%eax),%eax
8010472d:	89 c3                	mov    %eax,%ebx
8010472f:	b8 13 00 00 00       	mov    $0x13,%eax
80104734:	89 d7                	mov    %edx,%edi
80104736:	89 de                	mov    %ebx,%esi
80104738:	89 c1                	mov    %eax,%ecx
8010473a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

///allocating uid and gid
  np->uid = proc->uid;
8010473c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104742:	8b 50 14             	mov    0x14(%eax),%edx
80104745:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104748:	89 50 14             	mov    %edx,0x14(%eax)
  np->gid = proc->gid;
8010474b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104751:	8b 50 18             	mov    0x18(%eax),%edx
80104754:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104757:	89 50 18             	mov    %edx,0x18(%eax)


  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010475a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475d:	8b 40 20             	mov    0x20(%eax),%eax
80104760:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104767:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010476e:	eb 3a                	jmp    801047aa <fork+0x120>
    if(proc->ofile[i])
80104770:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104776:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104779:	83 c2 0c             	add    $0xc,%edx
8010477c:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010477f:	85 c0                	test   %eax,%eax
80104781:	74 23                	je     801047a6 <fork+0x11c>
      np->ofile[i] = filedup(proc->ofile[i]);
80104783:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104789:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010478c:	83 c2 0c             	add    $0xc,%edx
8010478f:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104792:	89 04 24             	mov    %eax,(%esp)
80104795:	e8 07 c8 ff ff       	call   80100fa1 <filedup>
8010479a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010479d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801047a0:	83 c1 0c             	add    $0xc,%ecx
801047a3:	89 04 8a             	mov    %eax,(%edx,%ecx,4)


  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801047a6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801047aa:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801047ae:	7e c0                	jle    80104770 <fork+0xe6>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801047b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b6:	8b 40 70             	mov    0x70(%eax),%eax
801047b9:	89 04 24             	mov    %eax,(%esp)
801047bc:	e8 e1 d0 ff ff       	call   801018a2 <idup>
801047c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047c4:	89 42 70             	mov    %eax,0x70(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801047c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047cd:	8d 50 74             	lea    0x74(%eax),%edx
801047d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d3:	83 c0 74             	add    $0x74,%eax
801047d6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047dd:	00 
801047de:	89 54 24 04          	mov    %edx,0x4(%esp)
801047e2:	89 04 24             	mov    %eax,(%esp)
801047e5:	e8 67 0d 00 00       	call   80105551 <safestrcpy>
 
  pid = np->pid;
801047ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ed:	8b 40 10             	mov    0x10(%eax),%eax
801047f0:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801047f3:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
801047fa:	e8 de 08 00 00       	call   801050dd <acquire>
  np->state = RUNNABLE;
801047ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104802:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104809:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104810:	e8 2a 09 00 00       	call   8010513f <release>
  
  return pid;
80104815:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104818:	83 c4 2c             	add    $0x2c,%esp
8010481b:	5b                   	pop    %ebx
8010481c:	5e                   	pop    %esi
8010481d:	5f                   	pop    %edi
8010481e:	5d                   	pop    %ebp
8010481f:	c3                   	ret    

80104820 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104820:	55                   	push   %ebp
80104821:	89 e5                	mov    %esp,%ebp
80104823:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104826:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010482d:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80104832:	39 c2                	cmp    %eax,%edx
80104834:	75 0c                	jne    80104842 <exit+0x22>
    panic("init exiting");
80104836:	c7 04 24 4c 8b 10 80 	movl   $0x80108b4c,(%esp)
8010483d:	e8 f8 bc ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104842:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104849:	eb 41                	jmp    8010488c <exit+0x6c>
    if(proc->ofile[fd]){
8010484b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104851:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104854:	83 c2 0c             	add    $0xc,%edx
80104857:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010485a:	85 c0                	test   %eax,%eax
8010485c:	74 2a                	je     80104888 <exit+0x68>
      fileclose(proc->ofile[fd]);
8010485e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104864:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104867:	83 c2 0c             	add    $0xc,%edx
8010486a:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010486d:	89 04 24             	mov    %eax,(%esp)
80104870:	e8 74 c7 ff ff       	call   80100fe9 <fileclose>
      proc->ofile[fd] = 0;
80104875:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010487b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010487e:	83 c2 0c             	add    $0xc,%edx
80104881:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104888:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010488c:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104890:	7e b9                	jle    8010484b <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104892:	e8 25 ec ff ff       	call   801034bc <begin_op>
  iput(proc->cwd);
80104897:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489d:	8b 40 70             	mov    0x70(%eax),%eax
801048a0:	89 04 24             	mov    %eax,(%esp)
801048a3:	e8 e5 d1 ff ff       	call   80101a8d <iput>
  end_op();
801048a8:	e8 93 ec ff ff       	call   80103540 <end_op>
  proc->cwd = 0;
801048ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b3:	c7 40 70 00 00 00 00 	movl   $0x0,0x70(%eax)

  acquire(&ptable.lock);
801048ba:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
801048c1:	e8 17 08 00 00       	call   801050dd <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801048c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048cc:	8b 40 1c             	mov    0x1c(%eax),%eax
801048cf:	89 04 24             	mov    %eax,(%esp)
801048d2:	e8 d6 03 00 00       	call   80104cad <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048d7:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
801048de:	eb 3b                	jmp    8010491b <exit+0xfb>
    if(p->parent == proc){
801048e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e3:	8b 50 1c             	mov    0x1c(%eax),%edx
801048e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ec:	39 c2                	cmp    %eax,%edx
801048ee:	75 24                	jne    80104914 <exit+0xf4>
      p->parent = initproc;
801048f0:	8b 15 68 b6 10 80    	mov    0x8010b668,%edx
801048f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f9:	89 50 1c             	mov    %edx,0x1c(%eax)
      if(p->state == ZOMBIE)
801048fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ff:	8b 40 0c             	mov    0xc(%eax),%eax
80104902:	83 f8 05             	cmp    $0x5,%eax
80104905:	75 0d                	jne    80104914 <exit+0xf4>
        wakeup1(initproc);
80104907:	a1 68 b6 10 80       	mov    0x8010b668,%eax
8010490c:	89 04 24             	mov    %eax,(%esp)
8010490f:	e8 99 03 00 00       	call   80104cad <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104914:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010491b:	81 7d f4 b4 4a 11 80 	cmpl   $0x80114ab4,-0xc(%ebp)
80104922:	72 bc                	jb     801048e0 <exit+0xc0>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104924:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010492a:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104931:	e8 b9 01 00 00       	call   80104aef <sched>
  panic("zombie exit");
80104936:	c7 04 24 59 8b 10 80 	movl   $0x80108b59,(%esp)
8010493d:	e8 f8 bb ff ff       	call   8010053a <panic>

80104942 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104942:	55                   	push   %ebp
80104943:	89 e5                	mov    %esp,%ebp
80104945:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104948:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
8010494f:	e8 89 07 00 00       	call   801050dd <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104954:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010495b:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104962:	e9 9d 00 00 00       	jmp    80104a04 <wait+0xc2>
      if(p->parent != proc)
80104967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496a:	8b 50 1c             	mov    0x1c(%eax),%edx
8010496d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104973:	39 c2                	cmp    %eax,%edx
80104975:	74 05                	je     8010497c <wait+0x3a>
        continue;
80104977:	e9 81 00 00 00       	jmp    801049fd <wait+0xbb>
      havekids = 1;
8010497c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104986:	8b 40 0c             	mov    0xc(%eax),%eax
80104989:	83 f8 05             	cmp    $0x5,%eax
8010498c:	75 6f                	jne    801049fd <wait+0xbb>
        // Found one.
        pid = p->pid;
8010498e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104991:	8b 40 10             	mov    0x10(%eax),%eax
80104994:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499a:	8b 40 08             	mov    0x8(%eax),%eax
8010499d:	89 04 24             	mov    %eax,(%esp)
801049a0:	e8 5a e1 ff ff       	call   80102aff <kfree>
        p->kstack = 0;
801049a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801049af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b2:	8b 40 04             	mov    0x4(%eax),%eax
801049b5:	89 04 24             	mov    %eax,(%esp)
801049b8:	e8 11 3b 00 00       	call   801084ce <freevm>
        p->state = UNUSED;
801049bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801049c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ca:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        p->name[0] = 0;
801049db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049de:	c6 40 74 00          	movb   $0x0,0x74(%eax)
        p->killed = 0;
801049e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e5:	c7 40 2c 00 00 00 00 	movl   $0x0,0x2c(%eax)
        release(&ptable.lock);
801049ec:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
801049f3:	e8 47 07 00 00       	call   8010513f <release>
        return pid;
801049f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049fb:	eb 55                	jmp    80104a52 <wait+0x110>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049fd:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a04:	81 7d f4 b4 4a 11 80 	cmpl   $0x80114ab4,-0xc(%ebp)
80104a0b:	0f 82 56 ff ff ff    	jb     80104967 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104a11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a15:	74 0d                	je     80104a24 <wait+0xe2>
80104a17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a1d:	8b 40 2c             	mov    0x2c(%eax),%eax
80104a20:	85 c0                	test   %eax,%eax
80104a22:	74 13                	je     80104a37 <wait+0xf5>
      release(&ptable.lock);
80104a24:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104a2b:	e8 0f 07 00 00       	call   8010513f <release>
      return -1;
80104a30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a35:	eb 1b                	jmp    80104a52 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a3d:	c7 44 24 04 80 29 11 	movl   $0x80112980,0x4(%esp)
80104a44:	80 
80104a45:	89 04 24             	mov    %eax,(%esp)
80104a48:	e8 c5 01 00 00       	call   80104c12 <sleep>
  }
80104a4d:	e9 02 ff ff ff       	jmp    80104954 <wait+0x12>
}
80104a52:	c9                   	leave  
80104a53:	c3                   	ret    

80104a54 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a54:	55                   	push   %ebp
80104a55:	89 e5                	mov    %esp,%ebp
80104a57:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a5a:	e8 2e f9 ff ff       	call   8010438d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a5f:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104a66:	e8 72 06 00 00       	call   801050dd <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a6b:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104a72:	eb 61                	jmp    80104ad5 <scheduler+0x81>
      if(p->state != RUNNABLE)
80104a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a77:	8b 40 0c             	mov    0xc(%eax),%eax
80104a7a:	83 f8 03             	cmp    $0x3,%eax
80104a7d:	74 02                	je     80104a81 <scheduler+0x2d>
        continue;
80104a7f:	eb 4d                	jmp    80104ace <scheduler+0x7a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a84:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8d:	89 04 24             	mov    %eax,(%esp)
80104a90:	e8 c6 35 00 00       	call   8010805b <switchuvm>
      p->state = RUNNING;
80104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a98:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104a9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aa5:	8b 40 24             	mov    0x24(%eax),%eax
80104aa8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104aaf:	83 c2 04             	add    $0x4,%edx
80104ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ab6:	89 14 24             	mov    %edx,(%esp)
80104ab9:	e8 04 0b 00 00       	call   801055c2 <swtch>
      switchkvm();
80104abe:	e8 7b 35 00 00       	call   8010803e <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104ac3:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104aca:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ace:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104ad5:	81 7d f4 b4 4a 11 80 	cmpl   $0x80114ab4,-0xc(%ebp)
80104adc:	72 96                	jb     80104a74 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104ade:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104ae5:	e8 55 06 00 00       	call   8010513f <release>

  }
80104aea:	e9 6b ff ff ff       	jmp    80104a5a <scheduler+0x6>

80104aef <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104aef:	55                   	push   %ebp
80104af0:	89 e5                	mov    %esp,%ebp
80104af2:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104af5:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104afc:	e8 06 07 00 00       	call   80105207 <holding>
80104b01:	85 c0                	test   %eax,%eax
80104b03:	75 0c                	jne    80104b11 <sched+0x22>
    panic("sched ptable.lock");
80104b05:	c7 04 24 65 8b 10 80 	movl   $0x80108b65,(%esp)
80104b0c:	e8 29 ba ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104b11:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b17:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104b1d:	83 f8 01             	cmp    $0x1,%eax
80104b20:	74 0c                	je     80104b2e <sched+0x3f>
    panic("sched locks");
80104b22:	c7 04 24 77 8b 10 80 	movl   $0x80108b77,(%esp)
80104b29:	e8 0c ba ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104b2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b34:	8b 40 0c             	mov    0xc(%eax),%eax
80104b37:	83 f8 04             	cmp    $0x4,%eax
80104b3a:	75 0c                	jne    80104b48 <sched+0x59>
    panic("sched running");
80104b3c:	c7 04 24 83 8b 10 80 	movl   $0x80108b83,(%esp)
80104b43:	e8 f2 b9 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104b48:	e8 30 f8 ff ff       	call   8010437d <readeflags>
80104b4d:	25 00 02 00 00       	and    $0x200,%eax
80104b52:	85 c0                	test   %eax,%eax
80104b54:	74 0c                	je     80104b62 <sched+0x73>
    panic("sched interruptible");
80104b56:	c7 04 24 91 8b 10 80 	movl   $0x80108b91,(%esp)
80104b5d:	e8 d8 b9 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104b62:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b68:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104b6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104b71:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b77:	8b 40 04             	mov    0x4(%eax),%eax
80104b7a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b81:	83 c2 24             	add    $0x24,%edx
80104b84:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b88:	89 14 24             	mov    %edx,(%esp)
80104b8b:	e8 32 0a 00 00       	call   801055c2 <swtch>
  cpu->intena = intena;
80104b90:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b99:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104b9f:	c9                   	leave  
80104ba0:	c3                   	ret    

80104ba1 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ba1:	55                   	push   %ebp
80104ba2:	89 e5                	mov    %esp,%ebp
80104ba4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104ba7:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104bae:	e8 2a 05 00 00       	call   801050dd <acquire>
  proc->state = RUNNABLE;
80104bb3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bb9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104bc0:	e8 2a ff ff ff       	call   80104aef <sched>
  release(&ptable.lock);
80104bc5:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104bcc:	e8 6e 05 00 00       	call   8010513f <release>
}
80104bd1:	c9                   	leave  
80104bd2:	c3                   	ret    

80104bd3 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bd3:	55                   	push   %ebp
80104bd4:	89 e5                	mov    %esp,%ebp
80104bd6:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104bd9:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104be0:	e8 5a 05 00 00       	call   8010513f <release>

  if (first) {
80104be5:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104bea:	85 c0                	test   %eax,%eax
80104bec:	74 22                	je     80104c10 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104bee:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104bf5:	00 00 00 
    iinit(ROOTDEV);
80104bf8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104bff:	e8 a8 c9 ff ff       	call   801015ac <iinit>
    initlog(ROOTDEV);
80104c04:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104c0b:	e8 a8 e6 ff ff       	call   801032b8 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104c10:	c9                   	leave  
80104c11:	c3                   	ret    

80104c12 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c12:	55                   	push   %ebp
80104c13:	89 e5                	mov    %esp,%ebp
80104c15:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104c18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c1e:	85 c0                	test   %eax,%eax
80104c20:	75 0c                	jne    80104c2e <sleep+0x1c>
    panic("sleep");
80104c22:	c7 04 24 a5 8b 10 80 	movl   $0x80108ba5,(%esp)
80104c29:	e8 0c b9 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104c2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c32:	75 0c                	jne    80104c40 <sleep+0x2e>
    panic("sleep without lk");
80104c34:	c7 04 24 ab 8b 10 80 	movl   $0x80108bab,(%esp)
80104c3b:	e8 fa b8 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c40:	81 7d 0c 80 29 11 80 	cmpl   $0x80112980,0xc(%ebp)
80104c47:	74 17                	je     80104c60 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c49:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104c50:	e8 88 04 00 00       	call   801050dd <acquire>
    release(lk);
80104c55:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c58:	89 04 24             	mov    %eax,(%esp)
80104c5b:	e8 df 04 00 00       	call   8010513f <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104c60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c66:	8b 55 08             	mov    0x8(%ebp),%edx
80104c69:	89 50 28             	mov    %edx,0x28(%eax)
  proc->state = SLEEPING;
80104c6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c72:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104c79:	e8 71 fe ff ff       	call   80104aef <sched>

  // Tidy up.
  proc->chan = 0;
80104c7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c84:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c8b:	81 7d 0c 80 29 11 80 	cmpl   $0x80112980,0xc(%ebp)
80104c92:	74 17                	je     80104cab <sleep+0x99>
    release(&ptable.lock);
80104c94:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104c9b:	e8 9f 04 00 00       	call   8010513f <release>
    acquire(lk);
80104ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ca3:	89 04 24             	mov    %eax,(%esp)
80104ca6:	e8 32 04 00 00       	call   801050dd <acquire>
  }
}
80104cab:	c9                   	leave  
80104cac:	c3                   	ret    

80104cad <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104cad:	55                   	push   %ebp
80104cae:	89 e5                	mov    %esp,%ebp
80104cb0:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cb3:	c7 45 fc b4 29 11 80 	movl   $0x801129b4,-0x4(%ebp)
80104cba:	eb 27                	jmp    80104ce3 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104cbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cbf:	8b 40 0c             	mov    0xc(%eax),%eax
80104cc2:	83 f8 02             	cmp    $0x2,%eax
80104cc5:	75 15                	jne    80104cdc <wakeup1+0x2f>
80104cc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cca:	8b 40 28             	mov    0x28(%eax),%eax
80104ccd:	3b 45 08             	cmp    0x8(%ebp),%eax
80104cd0:	75 0a                	jne    80104cdc <wakeup1+0x2f>
      p->state = RUNNABLE;
80104cd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cd5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cdc:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104ce3:	81 7d fc b4 4a 11 80 	cmpl   $0x80114ab4,-0x4(%ebp)
80104cea:	72 d0                	jb     80104cbc <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104cec:	c9                   	leave  
80104ced:	c3                   	ret    

80104cee <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104cee:	55                   	push   %ebp
80104cef:	89 e5                	mov    %esp,%ebp
80104cf1:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104cf4:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104cfb:	e8 dd 03 00 00       	call   801050dd <acquire>
  wakeup1(chan);
80104d00:	8b 45 08             	mov    0x8(%ebp),%eax
80104d03:	89 04 24             	mov    %eax,(%esp)
80104d06:	e8 a2 ff ff ff       	call   80104cad <wakeup1>
  release(&ptable.lock);
80104d0b:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104d12:	e8 28 04 00 00       	call   8010513f <release>
}
80104d17:	c9                   	leave  
80104d18:	c3                   	ret    

80104d19 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d19:	55                   	push   %ebp
80104d1a:	89 e5                	mov    %esp,%ebp
80104d1c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d1f:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104d26:	e8 b2 03 00 00       	call   801050dd <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d2b:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104d32:	eb 44                	jmp    80104d78 <kill+0x5f>
    if(p->pid == pid){
80104d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d37:	8b 40 10             	mov    0x10(%eax),%eax
80104d3a:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d3d:	75 32                	jne    80104d71 <kill+0x58>
      p->killed = 1;
80104d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d42:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4c:	8b 40 0c             	mov    0xc(%eax),%eax
80104d4f:	83 f8 02             	cmp    $0x2,%eax
80104d52:	75 0a                	jne    80104d5e <kill+0x45>
        p->state = RUNNABLE;
80104d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d57:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d5e:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104d65:	e8 d5 03 00 00       	call   8010513f <release>
      return 0;
80104d6a:	b8 00 00 00 00       	mov    $0x0,%eax
80104d6f:	eb 21                	jmp    80104d92 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d71:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104d78:	81 7d f4 b4 4a 11 80 	cmpl   $0x80114ab4,-0xc(%ebp)
80104d7f:	72 b3                	jb     80104d34 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d81:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104d88:	e8 b2 03 00 00       	call   8010513f <release>
  return -1;
80104d8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d92:	c9                   	leave  
80104d93:	c3                   	ret    

80104d94 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d94:	55                   	push   %ebp
80104d95:	89 e5                	mov    %esp,%ebp
80104d97:	53                   	push   %ebx
80104d98:	83 ec 64             	sub    $0x64,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d9b:	c7 45 f0 b4 29 11 80 	movl   $0x801129b4,-0x10(%ebp)
80104da2:	e9 ed 00 00 00       	jmp    80104e94 <procdump+0x100>
    if(p->state == UNUSED)
80104da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104daa:	8b 40 0c             	mov    0xc(%eax),%eax
80104dad:	85 c0                	test   %eax,%eax
80104daf:	75 05                	jne    80104db6 <procdump+0x22>
      continue;
80104db1:	e9 d7 00 00 00       	jmp    80104e8d <procdump+0xf9>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104db6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db9:	8b 40 0c             	mov    0xc(%eax),%eax
80104dbc:	83 f8 05             	cmp    $0x5,%eax
80104dbf:	77 23                	ja     80104de4 <procdump+0x50>
80104dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dc4:	8b 40 0c             	mov    0xc(%eax),%eax
80104dc7:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104dce:	85 c0                	test   %eax,%eax
80104dd0:	74 12                	je     80104de4 <procdump+0x50>
      state = states[p->state];
80104dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dd5:	8b 40 0c             	mov    0xc(%eax),%eax
80104dd8:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104ddf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104de2:	eb 07                	jmp    80104deb <procdump+0x57>
    else
      state = "???";
80104de4:	c7 45 ec bc 8b 10 80 	movl   $0x80108bbc,-0x14(%ebp)
    cprintf("%d %d %d %s %s", p->pid, p->uid, p->gid, state, p->name);
80104deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dee:	8d 58 74             	lea    0x74(%eax),%ebx
80104df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104df4:	8b 48 18             	mov    0x18(%eax),%ecx
80104df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dfa:	8b 50 14             	mov    0x14(%eax),%edx
80104dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e00:	8b 40 10             	mov    0x10(%eax),%eax
80104e03:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80104e07:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80104e0a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80104e0e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80104e12:	89 54 24 08          	mov    %edx,0x8(%esp)
80104e16:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e1a:	c7 04 24 c0 8b 10 80 	movl   $0x80108bc0,(%esp)
80104e21:	e8 7a b5 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e29:	8b 40 0c             	mov    0xc(%eax),%eax
80104e2c:	83 f8 02             	cmp    $0x2,%eax
80104e2f:	75 50                	jne    80104e81 <procdump+0xed>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e34:	8b 40 24             	mov    0x24(%eax),%eax
80104e37:	8b 40 0c             	mov    0xc(%eax),%eax
80104e3a:	83 c0 08             	add    $0x8,%eax
80104e3d:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104e40:	89 54 24 04          	mov    %edx,0x4(%esp)
80104e44:	89 04 24             	mov    %eax,(%esp)
80104e47:	e8 42 03 00 00       	call   8010518e <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104e4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e53:	eb 1b                	jmp    80104e70 <procdump+0xdc>
        cprintf(" %p", pc[i]);
80104e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e58:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e60:	c7 04 24 cf 8b 10 80 	movl   $0x80108bcf,(%esp)
80104e67:	e8 34 b5 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %d %d %s %s", p->pid, p->uid, p->gid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e70:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e74:	7f 0b                	jg     80104e81 <procdump+0xed>
80104e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e79:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e7d:	85 c0                	test   %eax,%eax
80104e7f:	75 d4                	jne    80104e55 <procdump+0xc1>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e81:	c7 04 24 d3 8b 10 80 	movl   $0x80108bd3,(%esp)
80104e88:	e8 13 b5 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e8d:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104e94:	81 7d f0 b4 4a 11 80 	cmpl   $0x80114ab4,-0x10(%ebp)
80104e9b:	0f 82 06 ff ff ff    	jb     80104da7 <procdump+0x13>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104ea1:	83 c4 64             	add    $0x64,%esp
80104ea4:	5b                   	pop    %ebx
80104ea5:	5d                   	pop    %ebp
80104ea6:	c3                   	ret    

80104ea7 <getProcInfo>:


int
getProcInfo(int max,struct uproc *table)
{
80104ea7:	55                   	push   %ebp
80104ea8:	89 e5                	mov    %esp,%ebp
80104eaa:	83 ec 40             	sub    $0x40,%esp
struct proc *p;

int numproc=0;
80104ead:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104eb4:	c7 45 fc b4 29 11 80 	movl   $0x801129b4,-0x4(%ebp)
80104ebb:	eb 17                	jmp    80104ed4 <getProcInfo+0x2d>
    if(p->state == UNUSED)
80104ebd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ec0:	8b 40 0c             	mov    0xc(%eax),%eax
80104ec3:	85 c0                	test   %eax,%eax
80104ec5:	75 02                	jne    80104ec9 <getProcInfo+0x22>
      continue;
80104ec7:	eb 04                	jmp    80104ecd <getProcInfo+0x26>
numproc++;
80104ec9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
getProcInfo(int max,struct uproc *table)
{
struct proc *p;

int numproc=0;
for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ecd:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104ed4:	81 7d fc b4 4a 11 80 	cmpl   $0x80114ab4,-0x4(%ebp)
80104edb:	72 e0                	jb     80104ebd <getProcInfo+0x16>
numproc++;
}



int i=numproc;
80104edd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ee0:	89 45 e8             	mov    %eax,-0x18(%ebp)
int l=0;
80104ee3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
while(l < i)
80104eea:	e9 86 01 00 00       	jmp    80105075 <getProcInfo+0x1ce>
{

int z=0;
80104eef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
int sn=sizeof(ptable.proc[l].name);
80104ef6:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%ebp)
while(z < sn)
80104efd:	eb 36                	jmp    80104f35 <getProcInfo+0x8e>
{
table[l].name[z]=ptable.proc[l].name[z];
80104eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f02:	6b d0 34             	imul   $0x34,%eax,%edx
80104f05:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f08:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80104f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0e:	c1 e0 02             	shl    $0x2,%eax
80104f11:	89 c2                	mov    %eax,%edx
80104f13:	c1 e2 05             	shl    $0x5,%edx
80104f16:	01 d0                	add    %edx,%eax
80104f18:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f1b:	01 d0                	add    %edx,%eax
80104f1d:	05 20 2a 11 80       	add    $0x80112a20,%eax
80104f22:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80104f26:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f29:	01 ca                	add    %ecx,%edx
80104f2b:	83 c2 20             	add    $0x20,%edx
80104f2e:	88 42 04             	mov    %al,0x4(%edx)
//table[l].state[z]=ptable.proc[l].name[z];
z++;
80104f31:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
while(l < i)
{

int z=0;
int sn=sizeof(ptable.proc[l].name);
while(z < sn)
80104f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f38:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80104f3b:	7c c2                	jl     80104eff <getProcInfo+0x58>
{
table[l].name[z]=ptable.proc[l].name[z];
//table[l].state[z]=ptable.proc[l].name[z];
z++;
}
char *statelist[] = {"UNUSED  ","EMBRYO  ","SLEEPING","RUNNABLE","RUNNING ","ZOMBIE  "};
80104f3d:	c7 45 c4 d5 8b 10 80 	movl   $0x80108bd5,-0x3c(%ebp)
80104f44:	c7 45 c8 de 8b 10 80 	movl   $0x80108bde,-0x38(%ebp)
80104f4b:	c7 45 cc e7 8b 10 80 	movl   $0x80108be7,-0x34(%ebp)
80104f52:	c7 45 d0 f0 8b 10 80 	movl   $0x80108bf0,-0x30(%ebp)
80104f59:	c7 45 d4 f9 8b 10 80 	movl   $0x80108bf9,-0x2c(%ebp)
80104f60:	c7 45 d8 02 8c 10 80 	movl   $0x80108c02,-0x28(%ebp)

int s=(int) ptable.proc[l].state;
80104f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6a:	c1 e0 02             	shl    $0x2,%eax
80104f6d:	89 c2                	mov    %eax,%edx
80104f6f:	c1 e2 05             	shl    $0x5,%edx
80104f72:	01 d0                	add    %edx,%eax
80104f74:	05 b0 29 11 80       	add    $0x801129b0,%eax
80104f79:	8b 40 10             	mov    0x10(%eax),%eax
80104f7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
//int ssize=sizeof(*statelist[s]);
int ssize=8;
80104f7f:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
int ss=0;
80104f86:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
while(ss < ssize)
80104f8d:	eb 29                	jmp    80104fb8 <getProcInfo+0x111>
{
table[l].state[ss]=statelist[s][ss];
80104f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f92:	6b d0 34             	imul   $0x34,%eax,%edx
80104f95:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f98:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80104f9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f9e:	8b 54 85 c4          	mov    -0x3c(%ebp,%eax,4),%edx
80104fa2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104fa5:	01 d0                	add    %edx,%eax
80104fa7:	0f b6 00             	movzbl (%eax),%eax
80104faa:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fad:	01 ca                	add    %ecx,%edx
80104faf:	83 c2 10             	add    $0x10,%edx
80104fb2:	88 02                	mov    %al,(%edx)
ss++;
80104fb4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)

int s=(int) ptable.proc[l].state;
//int ssize=sizeof(*statelist[s]);
int ssize=8;
int ss=0;
while(ss < ssize)
80104fb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104fbb:	3b 45 dc             	cmp    -0x24(%ebp),%eax
80104fbe:	7c cf                	jl     80104f8f <getProcInfo+0xe8>
table[l].state[ss]=statelist[s][ss];
ss++;
}


table[l].pid = ptable.proc[l].pid;
80104fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc3:	6b d0 34             	imul   $0x34,%eax,%edx
80104fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fc9:	01 c2                	add    %eax,%edx
80104fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fce:	c1 e0 02             	shl    $0x2,%eax
80104fd1:	89 c1                	mov    %eax,%ecx
80104fd3:	c1 e1 05             	shl    $0x5,%ecx
80104fd6:	01 c8                	add    %ecx,%eax
80104fd8:	05 c0 29 11 80       	add    $0x801129c0,%eax
80104fdd:	8b 40 04             	mov    0x4(%eax),%eax
80104fe0:	89 02                	mov    %eax,(%edx)
table[l].uid = ptable.proc[l].uid;
80104fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe5:	6b d0 34             	imul   $0x34,%eax,%edx
80104fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104feb:	01 c2                	add    %eax,%edx
80104fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff0:	c1 e0 02             	shl    $0x2,%eax
80104ff3:	89 c1                	mov    %eax,%ecx
80104ff5:	c1 e1 05             	shl    $0x5,%ecx
80104ff8:	01 c8                	add    %ecx,%eax
80104ffa:	05 c0 29 11 80       	add    $0x801129c0,%eax
80104fff:	8b 40 08             	mov    0x8(%eax),%eax
80105002:	89 42 04             	mov    %eax,0x4(%edx)
table[l].gid = ptable.proc[l].gid;
80105005:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105008:	6b d0 34             	imul   $0x34,%eax,%edx
8010500b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010500e:	01 c2                	add    %eax,%edx
80105010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105013:	c1 e0 02             	shl    $0x2,%eax
80105016:	89 c1                	mov    %eax,%ecx
80105018:	c1 e1 05             	shl    $0x5,%ecx
8010501b:	01 c8                	add    %ecx,%eax
8010501d:	05 c0 29 11 80       	add    $0x801129c0,%eax
80105022:	8b 40 0c             	mov    0xc(%eax),%eax
80105025:	89 42 08             	mov    %eax,0x8(%edx)
table[l].ppid = ptable.proc[l].parent->pid;
80105028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010502b:	6b d0 34             	imul   $0x34,%eax,%edx
8010502e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105031:	01 c2                	add    %eax,%edx
80105033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105036:	c1 e0 02             	shl    $0x2,%eax
80105039:	89 c1                	mov    %eax,%ecx
8010503b:	c1 e1 05             	shl    $0x5,%ecx
8010503e:	01 c8                	add    %ecx,%eax
80105040:	05 c0 29 11 80       	add    $0x801129c0,%eax
80105045:	8b 40 10             	mov    0x10(%eax),%eax
80105048:	8b 40 10             	mov    0x10(%eax),%eax
8010504b:	89 42 0c             	mov    %eax,0xc(%edx)
table[l].size = ptable.proc[l].sz;
8010504e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105051:	6b d0 34             	imul   $0x34,%eax,%edx
80105054:	8b 45 0c             	mov    0xc(%ebp),%eax
80105057:	01 c2                	add    %eax,%edx
80105059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505c:	c1 e0 02             	shl    $0x2,%eax
8010505f:	89 c1                	mov    %eax,%ecx
80105061:	c1 e1 05             	shl    $0x5,%ecx
80105064:	01 c8                	add    %ecx,%eax
80105066:	05 b0 29 11 80       	add    $0x801129b0,%eax
8010506b:	8b 40 04             	mov    0x4(%eax),%eax
8010506e:	89 42 20             	mov    %eax,0x20(%edx)


l++;
80105071:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)



int i=numproc;
int l=0;
while(l < i)
80105075:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105078:	3b 45 e8             	cmp    -0x18(%ebp),%eax
8010507b:	0f 8c 6e fe ff ff    	jl     80104eef <getProcInfo+0x48>


l++;
}

return i;
80105081:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105084:	c9                   	leave  
80105085:	c3                   	ret    

80105086 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105086:	55                   	push   %ebp
80105087:	89 e5                	mov    %esp,%ebp
80105089:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010508c:	9c                   	pushf  
8010508d:	58                   	pop    %eax
8010508e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105091:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105094:	c9                   	leave  
80105095:	c3                   	ret    

80105096 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105096:	55                   	push   %ebp
80105097:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105099:	fa                   	cli    
}
8010509a:	5d                   	pop    %ebp
8010509b:	c3                   	ret    

8010509c <sti>:

static inline void
sti(void)
{
8010509c:	55                   	push   %ebp
8010509d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010509f:	fb                   	sti    
}
801050a0:	5d                   	pop    %ebp
801050a1:	c3                   	ret    

801050a2 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801050a2:	55                   	push   %ebp
801050a3:	89 e5                	mov    %esp,%ebp
801050a5:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801050a8:	8b 55 08             	mov    0x8(%ebp),%edx
801050ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050b1:	f0 87 02             	lock xchg %eax,(%edx)
801050b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801050b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050ba:	c9                   	leave  
801050bb:	c3                   	ret    

801050bc <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801050bc:	55                   	push   %ebp
801050bd:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801050bf:	8b 45 08             	mov    0x8(%ebp),%eax
801050c2:	8b 55 0c             	mov    0xc(%ebp),%edx
801050c5:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801050c8:	8b 45 08             	mov    0x8(%ebp),%eax
801050cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801050d1:	8b 45 08             	mov    0x8(%ebp),%eax
801050d4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801050db:	5d                   	pop    %ebp
801050dc:	c3                   	ret    

801050dd <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801050dd:	55                   	push   %ebp
801050de:	89 e5                	mov    %esp,%ebp
801050e0:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801050e3:	e8 49 01 00 00       	call   80105231 <pushcli>
  if(holding(lk))
801050e8:	8b 45 08             	mov    0x8(%ebp),%eax
801050eb:	89 04 24             	mov    %eax,(%esp)
801050ee:	e8 14 01 00 00       	call   80105207 <holding>
801050f3:	85 c0                	test   %eax,%eax
801050f5:	74 0c                	je     80105103 <acquire+0x26>
    panic("acquire");
801050f7:	c7 04 24 35 8c 10 80 	movl   $0x80108c35,(%esp)
801050fe:	e8 37 b4 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105103:	90                   	nop
80105104:	8b 45 08             	mov    0x8(%ebp),%eax
80105107:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010510e:	00 
8010510f:	89 04 24             	mov    %eax,(%esp)
80105112:	e8 8b ff ff ff       	call   801050a2 <xchg>
80105117:	85 c0                	test   %eax,%eax
80105119:	75 e9                	jne    80105104 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010511b:	8b 45 08             	mov    0x8(%ebp),%eax
8010511e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105125:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105128:	8b 45 08             	mov    0x8(%ebp),%eax
8010512b:	83 c0 0c             	add    $0xc,%eax
8010512e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105132:	8d 45 08             	lea    0x8(%ebp),%eax
80105135:	89 04 24             	mov    %eax,(%esp)
80105138:	e8 51 00 00 00       	call   8010518e <getcallerpcs>
}
8010513d:	c9                   	leave  
8010513e:	c3                   	ret    

8010513f <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010513f:	55                   	push   %ebp
80105140:	89 e5                	mov    %esp,%ebp
80105142:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105145:	8b 45 08             	mov    0x8(%ebp),%eax
80105148:	89 04 24             	mov    %eax,(%esp)
8010514b:	e8 b7 00 00 00       	call   80105207 <holding>
80105150:	85 c0                	test   %eax,%eax
80105152:	75 0c                	jne    80105160 <release+0x21>
    panic("release");
80105154:	c7 04 24 3d 8c 10 80 	movl   $0x80108c3d,(%esp)
8010515b:	e8 da b3 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80105160:	8b 45 08             	mov    0x8(%ebp),%eax
80105163:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010516a:	8b 45 08             	mov    0x8(%ebp),%eax
8010516d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105174:	8b 45 08             	mov    0x8(%ebp),%eax
80105177:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010517e:	00 
8010517f:	89 04 24             	mov    %eax,(%esp)
80105182:	e8 1b ff ff ff       	call   801050a2 <xchg>

  popcli();
80105187:	e8 e9 00 00 00       	call   80105275 <popcli>
}
8010518c:	c9                   	leave  
8010518d:	c3                   	ret    

8010518e <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010518e:	55                   	push   %ebp
8010518f:	89 e5                	mov    %esp,%ebp
80105191:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105194:	8b 45 08             	mov    0x8(%ebp),%eax
80105197:	83 e8 08             	sub    $0x8,%eax
8010519a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010519d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801051a4:	eb 38                	jmp    801051de <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801051a6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801051aa:	74 38                	je     801051e4 <getcallerpcs+0x56>
801051ac:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801051b3:	76 2f                	jbe    801051e4 <getcallerpcs+0x56>
801051b5:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801051b9:	74 29                	je     801051e4 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
801051bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051be:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801051c8:	01 c2                	add    %eax,%edx
801051ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051cd:	8b 40 04             	mov    0x4(%eax),%eax
801051d0:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801051d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051d5:	8b 00                	mov    (%eax),%eax
801051d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801051da:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051de:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051e2:	7e c2                	jle    801051a6 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051e4:	eb 19                	jmp    801051ff <getcallerpcs+0x71>
    pcs[i] = 0;
801051e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051e9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801051f3:	01 d0                	add    %edx,%eax
801051f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051fb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051ff:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105203:	7e e1                	jle    801051e6 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105205:	c9                   	leave  
80105206:	c3                   	ret    

80105207 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105207:	55                   	push   %ebp
80105208:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010520a:	8b 45 08             	mov    0x8(%ebp),%eax
8010520d:	8b 00                	mov    (%eax),%eax
8010520f:	85 c0                	test   %eax,%eax
80105211:	74 17                	je     8010522a <holding+0x23>
80105213:	8b 45 08             	mov    0x8(%ebp),%eax
80105216:	8b 50 08             	mov    0x8(%eax),%edx
80105219:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010521f:	39 c2                	cmp    %eax,%edx
80105221:	75 07                	jne    8010522a <holding+0x23>
80105223:	b8 01 00 00 00       	mov    $0x1,%eax
80105228:	eb 05                	jmp    8010522f <holding+0x28>
8010522a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010522f:	5d                   	pop    %ebp
80105230:	c3                   	ret    

80105231 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105231:	55                   	push   %ebp
80105232:	89 e5                	mov    %esp,%ebp
80105234:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105237:	e8 4a fe ff ff       	call   80105086 <readeflags>
8010523c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010523f:	e8 52 fe ff ff       	call   80105096 <cli>
  if(cpu->ncli++ == 0)
80105244:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010524b:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105251:	8d 48 01             	lea    0x1(%eax),%ecx
80105254:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010525a:	85 c0                	test   %eax,%eax
8010525c:	75 15                	jne    80105273 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010525e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105264:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105267:	81 e2 00 02 00 00    	and    $0x200,%edx
8010526d:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105273:	c9                   	leave  
80105274:	c3                   	ret    

80105275 <popcli>:

void
popcli(void)
{
80105275:	55                   	push   %ebp
80105276:	89 e5                	mov    %esp,%ebp
80105278:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010527b:	e8 06 fe ff ff       	call   80105086 <readeflags>
80105280:	25 00 02 00 00       	and    $0x200,%eax
80105285:	85 c0                	test   %eax,%eax
80105287:	74 0c                	je     80105295 <popcli+0x20>
    panic("popcli - interruptible");
80105289:	c7 04 24 45 8c 10 80 	movl   $0x80108c45,(%esp)
80105290:	e8 a5 b2 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105295:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010529b:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801052a1:	83 ea 01             	sub    $0x1,%edx
801052a4:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801052aa:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801052b0:	85 c0                	test   %eax,%eax
801052b2:	79 0c                	jns    801052c0 <popcli+0x4b>
    panic("popcli");
801052b4:	c7 04 24 5c 8c 10 80 	movl   $0x80108c5c,(%esp)
801052bb:	e8 7a b2 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
801052c0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052c6:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801052cc:	85 c0                	test   %eax,%eax
801052ce:	75 15                	jne    801052e5 <popcli+0x70>
801052d0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052d6:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052dc:	85 c0                	test   %eax,%eax
801052de:	74 05                	je     801052e5 <popcli+0x70>
    sti();
801052e0:	e8 b7 fd ff ff       	call   8010509c <sti>
}
801052e5:	c9                   	leave  
801052e6:	c3                   	ret    

801052e7 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801052e7:	55                   	push   %ebp
801052e8:	89 e5                	mov    %esp,%ebp
801052ea:	57                   	push   %edi
801052eb:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052ef:	8b 55 10             	mov    0x10(%ebp),%edx
801052f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f5:	89 cb                	mov    %ecx,%ebx
801052f7:	89 df                	mov    %ebx,%edi
801052f9:	89 d1                	mov    %edx,%ecx
801052fb:	fc                   	cld    
801052fc:	f3 aa                	rep stos %al,%es:(%edi)
801052fe:	89 ca                	mov    %ecx,%edx
80105300:	89 fb                	mov    %edi,%ebx
80105302:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105305:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105308:	5b                   	pop    %ebx
80105309:	5f                   	pop    %edi
8010530a:	5d                   	pop    %ebp
8010530b:	c3                   	ret    

8010530c <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010530c:	55                   	push   %ebp
8010530d:	89 e5                	mov    %esp,%ebp
8010530f:	57                   	push   %edi
80105310:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105311:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105314:	8b 55 10             	mov    0x10(%ebp),%edx
80105317:	8b 45 0c             	mov    0xc(%ebp),%eax
8010531a:	89 cb                	mov    %ecx,%ebx
8010531c:	89 df                	mov    %ebx,%edi
8010531e:	89 d1                	mov    %edx,%ecx
80105320:	fc                   	cld    
80105321:	f3 ab                	rep stos %eax,%es:(%edi)
80105323:	89 ca                	mov    %ecx,%edx
80105325:	89 fb                	mov    %edi,%ebx
80105327:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010532a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010532d:	5b                   	pop    %ebx
8010532e:	5f                   	pop    %edi
8010532f:	5d                   	pop    %ebp
80105330:	c3                   	ret    

80105331 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105331:	55                   	push   %ebp
80105332:	89 e5                	mov    %esp,%ebp
80105334:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105337:	8b 45 08             	mov    0x8(%ebp),%eax
8010533a:	83 e0 03             	and    $0x3,%eax
8010533d:	85 c0                	test   %eax,%eax
8010533f:	75 49                	jne    8010538a <memset+0x59>
80105341:	8b 45 10             	mov    0x10(%ebp),%eax
80105344:	83 e0 03             	and    $0x3,%eax
80105347:	85 c0                	test   %eax,%eax
80105349:	75 3f                	jne    8010538a <memset+0x59>
    c &= 0xFF;
8010534b:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105352:	8b 45 10             	mov    0x10(%ebp),%eax
80105355:	c1 e8 02             	shr    $0x2,%eax
80105358:	89 c2                	mov    %eax,%edx
8010535a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010535d:	c1 e0 18             	shl    $0x18,%eax
80105360:	89 c1                	mov    %eax,%ecx
80105362:	8b 45 0c             	mov    0xc(%ebp),%eax
80105365:	c1 e0 10             	shl    $0x10,%eax
80105368:	09 c1                	or     %eax,%ecx
8010536a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010536d:	c1 e0 08             	shl    $0x8,%eax
80105370:	09 c8                	or     %ecx,%eax
80105372:	0b 45 0c             	or     0xc(%ebp),%eax
80105375:	89 54 24 08          	mov    %edx,0x8(%esp)
80105379:	89 44 24 04          	mov    %eax,0x4(%esp)
8010537d:	8b 45 08             	mov    0x8(%ebp),%eax
80105380:	89 04 24             	mov    %eax,(%esp)
80105383:	e8 84 ff ff ff       	call   8010530c <stosl>
80105388:	eb 19                	jmp    801053a3 <memset+0x72>
  } else
    stosb(dst, c, n);
8010538a:	8b 45 10             	mov    0x10(%ebp),%eax
8010538d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105391:	8b 45 0c             	mov    0xc(%ebp),%eax
80105394:	89 44 24 04          	mov    %eax,0x4(%esp)
80105398:	8b 45 08             	mov    0x8(%ebp),%eax
8010539b:	89 04 24             	mov    %eax,(%esp)
8010539e:	e8 44 ff ff ff       	call   801052e7 <stosb>
  return dst;
801053a3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053a6:	c9                   	leave  
801053a7:	c3                   	ret    

801053a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801053a8:	55                   	push   %ebp
801053a9:	89 e5                	mov    %esp,%ebp
801053ab:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801053ae:	8b 45 08             	mov    0x8(%ebp),%eax
801053b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801053b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801053ba:	eb 30                	jmp    801053ec <memcmp+0x44>
    if(*s1 != *s2)
801053bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053bf:	0f b6 10             	movzbl (%eax),%edx
801053c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053c5:	0f b6 00             	movzbl (%eax),%eax
801053c8:	38 c2                	cmp    %al,%dl
801053ca:	74 18                	je     801053e4 <memcmp+0x3c>
      return *s1 - *s2;
801053cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053cf:	0f b6 00             	movzbl (%eax),%eax
801053d2:	0f b6 d0             	movzbl %al,%edx
801053d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053d8:	0f b6 00             	movzbl (%eax),%eax
801053db:	0f b6 c0             	movzbl %al,%eax
801053de:	29 c2                	sub    %eax,%edx
801053e0:	89 d0                	mov    %edx,%eax
801053e2:	eb 1a                	jmp    801053fe <memcmp+0x56>
    s1++, s2++;
801053e4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053e8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801053ec:	8b 45 10             	mov    0x10(%ebp),%eax
801053ef:	8d 50 ff             	lea    -0x1(%eax),%edx
801053f2:	89 55 10             	mov    %edx,0x10(%ebp)
801053f5:	85 c0                	test   %eax,%eax
801053f7:	75 c3                	jne    801053bc <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801053f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053fe:	c9                   	leave  
801053ff:	c3                   	ret    

80105400 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105400:	55                   	push   %ebp
80105401:	89 e5                	mov    %esp,%ebp
80105403:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105406:	8b 45 0c             	mov    0xc(%ebp),%eax
80105409:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010540c:	8b 45 08             	mov    0x8(%ebp),%eax
8010540f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105412:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105415:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105418:	73 3d                	jae    80105457 <memmove+0x57>
8010541a:	8b 45 10             	mov    0x10(%ebp),%eax
8010541d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105420:	01 d0                	add    %edx,%eax
80105422:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105425:	76 30                	jbe    80105457 <memmove+0x57>
    s += n;
80105427:	8b 45 10             	mov    0x10(%ebp),%eax
8010542a:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010542d:	8b 45 10             	mov    0x10(%ebp),%eax
80105430:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105433:	eb 13                	jmp    80105448 <memmove+0x48>
      *--d = *--s;
80105435:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105439:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010543d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105440:	0f b6 10             	movzbl (%eax),%edx
80105443:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105446:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105448:	8b 45 10             	mov    0x10(%ebp),%eax
8010544b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010544e:	89 55 10             	mov    %edx,0x10(%ebp)
80105451:	85 c0                	test   %eax,%eax
80105453:	75 e0                	jne    80105435 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105455:	eb 26                	jmp    8010547d <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105457:	eb 17                	jmp    80105470 <memmove+0x70>
      *d++ = *s++;
80105459:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010545c:	8d 50 01             	lea    0x1(%eax),%edx
8010545f:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105462:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105465:	8d 4a 01             	lea    0x1(%edx),%ecx
80105468:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010546b:	0f b6 12             	movzbl (%edx),%edx
8010546e:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105470:	8b 45 10             	mov    0x10(%ebp),%eax
80105473:	8d 50 ff             	lea    -0x1(%eax),%edx
80105476:	89 55 10             	mov    %edx,0x10(%ebp)
80105479:	85 c0                	test   %eax,%eax
8010547b:	75 dc                	jne    80105459 <memmove+0x59>
      *d++ = *s++;

  return dst;
8010547d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105480:	c9                   	leave  
80105481:	c3                   	ret    

80105482 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105482:	55                   	push   %ebp
80105483:	89 e5                	mov    %esp,%ebp
80105485:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105488:	8b 45 10             	mov    0x10(%ebp),%eax
8010548b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010548f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105492:	89 44 24 04          	mov    %eax,0x4(%esp)
80105496:	8b 45 08             	mov    0x8(%ebp),%eax
80105499:	89 04 24             	mov    %eax,(%esp)
8010549c:	e8 5f ff ff ff       	call   80105400 <memmove>
}
801054a1:	c9                   	leave  
801054a2:	c3                   	ret    

801054a3 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801054a3:	55                   	push   %ebp
801054a4:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801054a6:	eb 0c                	jmp    801054b4 <strncmp+0x11>
    n--, p++, q++;
801054a8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801054b0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801054b4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054b8:	74 1a                	je     801054d4 <strncmp+0x31>
801054ba:	8b 45 08             	mov    0x8(%ebp),%eax
801054bd:	0f b6 00             	movzbl (%eax),%eax
801054c0:	84 c0                	test   %al,%al
801054c2:	74 10                	je     801054d4 <strncmp+0x31>
801054c4:	8b 45 08             	mov    0x8(%ebp),%eax
801054c7:	0f b6 10             	movzbl (%eax),%edx
801054ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801054cd:	0f b6 00             	movzbl (%eax),%eax
801054d0:	38 c2                	cmp    %al,%dl
801054d2:	74 d4                	je     801054a8 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801054d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054d8:	75 07                	jne    801054e1 <strncmp+0x3e>
    return 0;
801054da:	b8 00 00 00 00       	mov    $0x0,%eax
801054df:	eb 16                	jmp    801054f7 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801054e1:	8b 45 08             	mov    0x8(%ebp),%eax
801054e4:	0f b6 00             	movzbl (%eax),%eax
801054e7:	0f b6 d0             	movzbl %al,%edx
801054ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ed:	0f b6 00             	movzbl (%eax),%eax
801054f0:	0f b6 c0             	movzbl %al,%eax
801054f3:	29 c2                	sub    %eax,%edx
801054f5:	89 d0                	mov    %edx,%eax
}
801054f7:	5d                   	pop    %ebp
801054f8:	c3                   	ret    

801054f9 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054f9:	55                   	push   %ebp
801054fa:	89 e5                	mov    %esp,%ebp
801054fc:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105502:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105505:	90                   	nop
80105506:	8b 45 10             	mov    0x10(%ebp),%eax
80105509:	8d 50 ff             	lea    -0x1(%eax),%edx
8010550c:	89 55 10             	mov    %edx,0x10(%ebp)
8010550f:	85 c0                	test   %eax,%eax
80105511:	7e 1e                	jle    80105531 <strncpy+0x38>
80105513:	8b 45 08             	mov    0x8(%ebp),%eax
80105516:	8d 50 01             	lea    0x1(%eax),%edx
80105519:	89 55 08             	mov    %edx,0x8(%ebp)
8010551c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010551f:	8d 4a 01             	lea    0x1(%edx),%ecx
80105522:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105525:	0f b6 12             	movzbl (%edx),%edx
80105528:	88 10                	mov    %dl,(%eax)
8010552a:	0f b6 00             	movzbl (%eax),%eax
8010552d:	84 c0                	test   %al,%al
8010552f:	75 d5                	jne    80105506 <strncpy+0xd>
    ;
  while(n-- > 0)
80105531:	eb 0c                	jmp    8010553f <strncpy+0x46>
    *s++ = 0;
80105533:	8b 45 08             	mov    0x8(%ebp),%eax
80105536:	8d 50 01             	lea    0x1(%eax),%edx
80105539:	89 55 08             	mov    %edx,0x8(%ebp)
8010553c:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010553f:	8b 45 10             	mov    0x10(%ebp),%eax
80105542:	8d 50 ff             	lea    -0x1(%eax),%edx
80105545:	89 55 10             	mov    %edx,0x10(%ebp)
80105548:	85 c0                	test   %eax,%eax
8010554a:	7f e7                	jg     80105533 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010554c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010554f:	c9                   	leave  
80105550:	c3                   	ret    

80105551 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105551:	55                   	push   %ebp
80105552:	89 e5                	mov    %esp,%ebp
80105554:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105557:	8b 45 08             	mov    0x8(%ebp),%eax
8010555a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010555d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105561:	7f 05                	jg     80105568 <safestrcpy+0x17>
    return os;
80105563:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105566:	eb 31                	jmp    80105599 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105568:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010556c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105570:	7e 1e                	jle    80105590 <safestrcpy+0x3f>
80105572:	8b 45 08             	mov    0x8(%ebp),%eax
80105575:	8d 50 01             	lea    0x1(%eax),%edx
80105578:	89 55 08             	mov    %edx,0x8(%ebp)
8010557b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010557e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105581:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105584:	0f b6 12             	movzbl (%edx),%edx
80105587:	88 10                	mov    %dl,(%eax)
80105589:	0f b6 00             	movzbl (%eax),%eax
8010558c:	84 c0                	test   %al,%al
8010558e:	75 d8                	jne    80105568 <safestrcpy+0x17>
    ;
  *s = 0;
80105590:	8b 45 08             	mov    0x8(%ebp),%eax
80105593:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105596:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105599:	c9                   	leave  
8010559a:	c3                   	ret    

8010559b <strlen>:

int
strlen(const char *s)
{
8010559b:	55                   	push   %ebp
8010559c:	89 e5                	mov    %esp,%ebp
8010559e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801055a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801055a8:	eb 04                	jmp    801055ae <strlen+0x13>
801055aa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055ae:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055b1:	8b 45 08             	mov    0x8(%ebp),%eax
801055b4:	01 d0                	add    %edx,%eax
801055b6:	0f b6 00             	movzbl (%eax),%eax
801055b9:	84 c0                	test   %al,%al
801055bb:	75 ed                	jne    801055aa <strlen+0xf>
    ;
  return n;
801055bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055c0:	c9                   	leave  
801055c1:	c3                   	ret    

801055c2 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801055c2:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801055c6:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801055ca:	55                   	push   %ebp
  pushl %ebx
801055cb:	53                   	push   %ebx
  pushl %esi
801055cc:	56                   	push   %esi
  pushl %edi
801055cd:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801055ce:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055d0:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055d2:	5f                   	pop    %edi
  popl %esi
801055d3:	5e                   	pop    %esi
  popl %ebx
801055d4:	5b                   	pop    %ebx
  popl %ebp
801055d5:	5d                   	pop    %ebp
  ret
801055d6:	c3                   	ret    

801055d7 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801055d7:	55                   	push   %ebp
801055d8:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801055da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055e0:	8b 00                	mov    (%eax),%eax
801055e2:	3b 45 08             	cmp    0x8(%ebp),%eax
801055e5:	76 12                	jbe    801055f9 <fetchint+0x22>
801055e7:	8b 45 08             	mov    0x8(%ebp),%eax
801055ea:	8d 50 04             	lea    0x4(%eax),%edx
801055ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055f3:	8b 00                	mov    (%eax),%eax
801055f5:	39 c2                	cmp    %eax,%edx
801055f7:	76 07                	jbe    80105600 <fetchint+0x29>
    return -1;
801055f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055fe:	eb 0f                	jmp    8010560f <fetchint+0x38>
  *ip = *(int*)(addr);
80105600:	8b 45 08             	mov    0x8(%ebp),%eax
80105603:	8b 10                	mov    (%eax),%edx
80105605:	8b 45 0c             	mov    0xc(%ebp),%eax
80105608:	89 10                	mov    %edx,(%eax)
  return 0;
8010560a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010560f:	5d                   	pop    %ebp
80105610:	c3                   	ret    

80105611 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105611:	55                   	push   %ebp
80105612:	89 e5                	mov    %esp,%ebp
80105614:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105617:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010561d:	8b 00                	mov    (%eax),%eax
8010561f:	3b 45 08             	cmp    0x8(%ebp),%eax
80105622:	77 07                	ja     8010562b <fetchstr+0x1a>
    return -1;
80105624:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105629:	eb 46                	jmp    80105671 <fetchstr+0x60>
  *pp = (char*)addr;
8010562b:	8b 55 08             	mov    0x8(%ebp),%edx
8010562e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105631:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105633:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105639:	8b 00                	mov    (%eax),%eax
8010563b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010563e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105641:	8b 00                	mov    (%eax),%eax
80105643:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105646:	eb 1c                	jmp    80105664 <fetchstr+0x53>
    if(*s == 0)
80105648:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010564b:	0f b6 00             	movzbl (%eax),%eax
8010564e:	84 c0                	test   %al,%al
80105650:	75 0e                	jne    80105660 <fetchstr+0x4f>
      return s - *pp;
80105652:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105655:	8b 45 0c             	mov    0xc(%ebp),%eax
80105658:	8b 00                	mov    (%eax),%eax
8010565a:	29 c2                	sub    %eax,%edx
8010565c:	89 d0                	mov    %edx,%eax
8010565e:	eb 11                	jmp    80105671 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105660:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105664:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105667:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010566a:	72 dc                	jb     80105648 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010566c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105671:	c9                   	leave  
80105672:	c3                   	ret    

80105673 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105673:	55                   	push   %ebp
80105674:	89 e5                	mov    %esp,%ebp
80105676:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105679:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010567f:	8b 40 20             	mov    0x20(%eax),%eax
80105682:	8b 50 44             	mov    0x44(%eax),%edx
80105685:	8b 45 08             	mov    0x8(%ebp),%eax
80105688:	c1 e0 02             	shl    $0x2,%eax
8010568b:	01 d0                	add    %edx,%eax
8010568d:	8d 50 04             	lea    0x4(%eax),%edx
80105690:	8b 45 0c             	mov    0xc(%ebp),%eax
80105693:	89 44 24 04          	mov    %eax,0x4(%esp)
80105697:	89 14 24             	mov    %edx,(%esp)
8010569a:	e8 38 ff ff ff       	call   801055d7 <fetchint>
}
8010569f:	c9                   	leave  
801056a0:	c3                   	ret    

801056a1 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801056a1:	55                   	push   %ebp
801056a2:	89 e5                	mov    %esp,%ebp
801056a4:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801056a7:	8d 45 fc             	lea    -0x4(%ebp),%eax
801056aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801056ae:	8b 45 08             	mov    0x8(%ebp),%eax
801056b1:	89 04 24             	mov    %eax,(%esp)
801056b4:	e8 ba ff ff ff       	call   80105673 <argint>
801056b9:	85 c0                	test   %eax,%eax
801056bb:	79 07                	jns    801056c4 <argptr+0x23>
    return -1;
801056bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c2:	eb 3d                	jmp    80105701 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801056c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056c7:	89 c2                	mov    %eax,%edx
801056c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056cf:	8b 00                	mov    (%eax),%eax
801056d1:	39 c2                	cmp    %eax,%edx
801056d3:	73 16                	jae    801056eb <argptr+0x4a>
801056d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056d8:	89 c2                	mov    %eax,%edx
801056da:	8b 45 10             	mov    0x10(%ebp),%eax
801056dd:	01 c2                	add    %eax,%edx
801056df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e5:	8b 00                	mov    (%eax),%eax
801056e7:	39 c2                	cmp    %eax,%edx
801056e9:	76 07                	jbe    801056f2 <argptr+0x51>
    return -1;
801056eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f0:	eb 0f                	jmp    80105701 <argptr+0x60>
  *pp = (char*)i;
801056f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056f5:	89 c2                	mov    %eax,%edx
801056f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801056fa:	89 10                	mov    %edx,(%eax)
  return 0;
801056fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105701:	c9                   	leave  
80105702:	c3                   	ret    

80105703 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105703:	55                   	push   %ebp
80105704:	89 e5                	mov    %esp,%ebp
80105706:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105709:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010570c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105710:	8b 45 08             	mov    0x8(%ebp),%eax
80105713:	89 04 24             	mov    %eax,(%esp)
80105716:	e8 58 ff ff ff       	call   80105673 <argint>
8010571b:	85 c0                	test   %eax,%eax
8010571d:	79 07                	jns    80105726 <argstr+0x23>
    return -1;
8010571f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105724:	eb 12                	jmp    80105738 <argstr+0x35>
  return fetchstr(addr, pp);
80105726:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105729:	8b 55 0c             	mov    0xc(%ebp),%edx
8010572c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105730:	89 04 24             	mov    %eax,(%esp)
80105733:	e8 d9 fe ff ff       	call   80105611 <fetchstr>
}
80105738:	c9                   	leave  
80105739:	c3                   	ret    

8010573a <syscall>:
#endif


void
syscall(void)
{
8010573a:	55                   	push   %ebp
8010573b:	89 e5                	mov    %esp,%ebp
8010573d:	53                   	push   %ebx
8010573e:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105741:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105747:	8b 40 20             	mov    0x20(%eax),%eax
8010574a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010574d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105750:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105754:	7e 30                	jle    80105786 <syscall+0x4c>
80105756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105759:	83 f8 1d             	cmp    $0x1d,%eax
8010575c:	77 28                	ja     80105786 <syscall+0x4c>
8010575e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105761:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105768:	85 c0                	test   %eax,%eax
8010576a:	74 1a                	je     80105786 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
8010576c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105772:	8b 58 20             	mov    0x20(%eax),%ebx
80105775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105778:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010577f:	ff d0                	call   *%eax
80105781:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105784:	eb 3d                	jmp    801057c3 <syscall+0x89>
#ifdef PRINT_SYSCALLS
    //cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105786:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010578c:	8d 48 74             	lea    0x74(%eax),%ecx
8010578f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
//cprintf("%d %s: -> %d\n",proc->pid, proc->name, num);
#ifdef PRINT_SYSCALLS
    //cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105795:	8b 40 10             	mov    0x10(%eax),%eax
80105798:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010579b:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010579f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801057a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801057a7:	c7 04 24 63 8c 10 80 	movl   $0x80108c63,(%esp)
801057ae:	e8 ed ab ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801057b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b9:	8b 40 20             	mov    0x20(%eax),%eax
801057bc:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801057c3:	83 c4 24             	add    $0x24,%esp
801057c6:	5b                   	pop    %ebx
801057c7:	5d                   	pop    %ebp
801057c8:	c3                   	ret    

801057c9 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801057c9:	55                   	push   %ebp
801057ca:	89 e5                	mov    %esp,%ebp
801057cc:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801057cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801057d6:	8b 45 08             	mov    0x8(%ebp),%eax
801057d9:	89 04 24             	mov    %eax,(%esp)
801057dc:	e8 92 fe ff ff       	call   80105673 <argint>
801057e1:	85 c0                	test   %eax,%eax
801057e3:	79 07                	jns    801057ec <argfd+0x23>
    return -1;
801057e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ea:	eb 4f                	jmp    8010583b <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801057ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ef:	85 c0                	test   %eax,%eax
801057f1:	78 20                	js     80105813 <argfd+0x4a>
801057f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f6:	83 f8 0f             	cmp    $0xf,%eax
801057f9:	7f 18                	jg     80105813 <argfd+0x4a>
801057fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105801:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105804:	83 c2 0c             	add    $0xc,%edx
80105807:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010580a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010580d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105811:	75 07                	jne    8010581a <argfd+0x51>
    return -1;
80105813:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105818:	eb 21                	jmp    8010583b <argfd+0x72>
  if(pfd)
8010581a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010581e:	74 08                	je     80105828 <argfd+0x5f>
    *pfd = fd;
80105820:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105823:	8b 45 0c             	mov    0xc(%ebp),%eax
80105826:	89 10                	mov    %edx,(%eax)
  if(pf)
80105828:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010582c:	74 08                	je     80105836 <argfd+0x6d>
    *pf = f;
8010582e:	8b 45 10             	mov    0x10(%ebp),%eax
80105831:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105834:	89 10                	mov    %edx,(%eax)
  return 0;
80105836:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010583b:	c9                   	leave  
8010583c:	c3                   	ret    

8010583d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010583d:	55                   	push   %ebp
8010583e:	89 e5                	mov    %esp,%ebp
80105840:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105843:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010584a:	eb 2e                	jmp    8010587a <fdalloc+0x3d>
    if(proc->ofile[fd] == 0){
8010584c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105852:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105855:	83 c2 0c             	add    $0xc,%edx
80105858:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010585b:	85 c0                	test   %eax,%eax
8010585d:	75 17                	jne    80105876 <fdalloc+0x39>
      proc->ofile[fd] = f;
8010585f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105865:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105868:	8d 4a 0c             	lea    0xc(%edx),%ecx
8010586b:	8b 55 08             	mov    0x8(%ebp),%edx
8010586e:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      return fd;
80105871:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105874:	eb 0f                	jmp    80105885 <fdalloc+0x48>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105876:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010587a:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010587e:	7e cc                	jle    8010584c <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105885:	c9                   	leave  
80105886:	c3                   	ret    

80105887 <sys_dup>:

int
sys_dup(void)
{
80105887:	55                   	push   %ebp
80105888:	89 e5                	mov    %esp,%ebp
8010588a:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010588d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105890:	89 44 24 08          	mov    %eax,0x8(%esp)
80105894:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010589b:	00 
8010589c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058a3:	e8 21 ff ff ff       	call   801057c9 <argfd>
801058a8:	85 c0                	test   %eax,%eax
801058aa:	79 07                	jns    801058b3 <sys_dup+0x2c>
    return -1;
801058ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b1:	eb 29                	jmp    801058dc <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801058b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b6:	89 04 24             	mov    %eax,(%esp)
801058b9:	e8 7f ff ff ff       	call   8010583d <fdalloc>
801058be:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058c5:	79 07                	jns    801058ce <sys_dup+0x47>
    return -1;
801058c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058cc:	eb 0e                	jmp    801058dc <sys_dup+0x55>
  filedup(f);
801058ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d1:	89 04 24             	mov    %eax,(%esp)
801058d4:	e8 c8 b6 ff ff       	call   80100fa1 <filedup>
  return fd;
801058d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801058dc:	c9                   	leave  
801058dd:	c3                   	ret    

801058de <sys_read>:

int
sys_read(void)
{
801058de:	55                   	push   %ebp
801058df:	89 e5                	mov    %esp,%ebp
801058e1:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058e7:	89 44 24 08          	mov    %eax,0x8(%esp)
801058eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058f2:	00 
801058f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058fa:	e8 ca fe ff ff       	call   801057c9 <argfd>
801058ff:	85 c0                	test   %eax,%eax
80105901:	78 35                	js     80105938 <sys_read+0x5a>
80105903:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105906:	89 44 24 04          	mov    %eax,0x4(%esp)
8010590a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105911:	e8 5d fd ff ff       	call   80105673 <argint>
80105916:	85 c0                	test   %eax,%eax
80105918:	78 1e                	js     80105938 <sys_read+0x5a>
8010591a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010591d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105921:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105924:	89 44 24 04          	mov    %eax,0x4(%esp)
80105928:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010592f:	e8 6d fd ff ff       	call   801056a1 <argptr>
80105934:	85 c0                	test   %eax,%eax
80105936:	79 07                	jns    8010593f <sys_read+0x61>
    return -1;
80105938:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010593d:	eb 19                	jmp    80105958 <sys_read+0x7a>
  return fileread(f, p, n);
8010593f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105942:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105948:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010594c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105950:	89 04 24             	mov    %eax,(%esp)
80105953:	e8 b6 b7 ff ff       	call   8010110e <fileread>
}
80105958:	c9                   	leave  
80105959:	c3                   	ret    

8010595a <sys_write>:

int
sys_write(void)
{
8010595a:	55                   	push   %ebp
8010595b:	89 e5                	mov    %esp,%ebp
8010595d:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105960:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105963:	89 44 24 08          	mov    %eax,0x8(%esp)
80105967:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010596e:	00 
8010596f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105976:	e8 4e fe ff ff       	call   801057c9 <argfd>
8010597b:	85 c0                	test   %eax,%eax
8010597d:	78 35                	js     801059b4 <sys_write+0x5a>
8010597f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105982:	89 44 24 04          	mov    %eax,0x4(%esp)
80105986:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010598d:	e8 e1 fc ff ff       	call   80105673 <argint>
80105992:	85 c0                	test   %eax,%eax
80105994:	78 1e                	js     801059b4 <sys_write+0x5a>
80105996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105999:	89 44 24 08          	mov    %eax,0x8(%esp)
8010599d:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801059a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059ab:	e8 f1 fc ff ff       	call   801056a1 <argptr>
801059b0:	85 c0                	test   %eax,%eax
801059b2:	79 07                	jns    801059bb <sys_write+0x61>
    return -1;
801059b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b9:	eb 19                	jmp    801059d4 <sys_write+0x7a>
  return filewrite(f, p, n);
801059bb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059be:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801059cc:	89 04 24             	mov    %eax,(%esp)
801059cf:	e8 f6 b7 ff ff       	call   801011ca <filewrite>
}
801059d4:	c9                   	leave  
801059d5:	c3                   	ret    

801059d6 <sys_close>:

int
sys_close(void)
{
801059d6:	55                   	push   %ebp
801059d7:	89 e5                	mov    %esp,%ebp
801059d9:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801059dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059df:	89 44 24 08          	mov    %eax,0x8(%esp)
801059e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059f1:	e8 d3 fd ff ff       	call   801057c9 <argfd>
801059f6:	85 c0                	test   %eax,%eax
801059f8:	79 07                	jns    80105a01 <sys_close+0x2b>
    return -1;
801059fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ff:	eb 23                	jmp    80105a24 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105a01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a0a:	83 c2 0c             	add    $0xc,%edx
80105a0d:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
  fileclose(f);
80105a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a17:	89 04 24             	mov    %eax,(%esp)
80105a1a:	e8 ca b5 ff ff       	call   80100fe9 <fileclose>
  return 0;
80105a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a24:	c9                   	leave  
80105a25:	c3                   	ret    

80105a26 <sys_fstat>:

int
sys_fstat(void)
{
80105a26:	55                   	push   %ebp
80105a27:	89 e5                	mov    %esp,%ebp
80105a29:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a2f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a33:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a3a:	00 
80105a3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a42:	e8 82 fd ff ff       	call   801057c9 <argfd>
80105a47:	85 c0                	test   %eax,%eax
80105a49:	78 1f                	js     80105a6a <sys_fstat+0x44>
80105a4b:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105a52:	00 
80105a53:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a56:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a61:	e8 3b fc ff ff       	call   801056a1 <argptr>
80105a66:	85 c0                	test   %eax,%eax
80105a68:	79 07                	jns    80105a71 <sys_fstat+0x4b>
    return -1;
80105a6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a6f:	eb 12                	jmp    80105a83 <sys_fstat+0x5d>
  return filestat(f, st);
80105a71:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a77:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a7b:	89 04 24             	mov    %eax,(%esp)
80105a7e:	e8 3c b6 ff ff       	call   801010bf <filestat>
}
80105a83:	c9                   	leave  
80105a84:	c3                   	ret    

80105a85 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105a85:	55                   	push   %ebp
80105a86:	89 e5                	mov    %esp,%ebp
80105a88:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105a8b:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a99:	e8 65 fc ff ff       	call   80105703 <argstr>
80105a9e:	85 c0                	test   %eax,%eax
80105aa0:	78 17                	js     80105ab9 <sys_link+0x34>
80105aa2:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105aa9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ab0:	e8 4e fc ff ff       	call   80105703 <argstr>
80105ab5:	85 c0                	test   %eax,%eax
80105ab7:	79 0a                	jns    80105ac3 <sys_link+0x3e>
    return -1;
80105ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105abe:	e9 42 01 00 00       	jmp    80105c05 <sys_link+0x180>

  begin_op();
80105ac3:	e8 f4 d9 ff ff       	call   801034bc <begin_op>
  if((ip = namei(old)) == 0){
80105ac8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105acb:	89 04 24             	mov    %eax,(%esp)
80105ace:	e8 b2 c9 ff ff       	call   80102485 <namei>
80105ad3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ad6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ada:	75 0f                	jne    80105aeb <sys_link+0x66>
    end_op();
80105adc:	e8 5f da ff ff       	call   80103540 <end_op>
    return -1;
80105ae1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ae6:	e9 1a 01 00 00       	jmp    80105c05 <sys_link+0x180>
  }

  ilock(ip);
80105aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aee:	89 04 24             	mov    %eax,(%esp)
80105af1:	e8 de bd ff ff       	call   801018d4 <ilock>
  if(ip->type == T_DIR){
80105af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105afd:	66 83 f8 01          	cmp    $0x1,%ax
80105b01:	75 1a                	jne    80105b1d <sys_link+0x98>
    iunlockput(ip);
80105b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b06:	89 04 24             	mov    %eax,(%esp)
80105b09:	e8 50 c0 ff ff       	call   80101b5e <iunlockput>
    end_op();
80105b0e:	e8 2d da ff ff       	call   80103540 <end_op>
    return -1;
80105b13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b18:	e9 e8 00 00 00       	jmp    80105c05 <sys_link+0x180>
  }

  ip->nlink++;
80105b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b20:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b24:	8d 50 01             	lea    0x1(%eax),%edx
80105b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2a:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b31:	89 04 24             	mov    %eax,(%esp)
80105b34:	e8 d9 bb ff ff       	call   80101712 <iupdate>
  iunlock(ip);
80105b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3c:	89 04 24             	mov    %eax,(%esp)
80105b3f:	e8 e4 be ff ff       	call   80101a28 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105b44:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b47:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b4a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b4e:	89 04 24             	mov    %eax,(%esp)
80105b51:	e8 51 c9 ff ff       	call   801024a7 <nameiparent>
80105b56:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b5d:	75 02                	jne    80105b61 <sys_link+0xdc>
    goto bad;
80105b5f:	eb 68                	jmp    80105bc9 <sys_link+0x144>
  ilock(dp);
80105b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b64:	89 04 24             	mov    %eax,(%esp)
80105b67:	e8 68 bd ff ff       	call   801018d4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6f:	8b 10                	mov    (%eax),%edx
80105b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b74:	8b 00                	mov    (%eax),%eax
80105b76:	39 c2                	cmp    %eax,%edx
80105b78:	75 20                	jne    80105b9a <sys_link+0x115>
80105b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b7d:	8b 40 04             	mov    0x4(%eax),%eax
80105b80:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b84:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105b87:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8e:	89 04 24             	mov    %eax,(%esp)
80105b91:	e8 2f c6 ff ff       	call   801021c5 <dirlink>
80105b96:	85 c0                	test   %eax,%eax
80105b98:	79 0d                	jns    80105ba7 <sys_link+0x122>
    iunlockput(dp);
80105b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9d:	89 04 24             	mov    %eax,(%esp)
80105ba0:	e8 b9 bf ff ff       	call   80101b5e <iunlockput>
    goto bad;
80105ba5:	eb 22                	jmp    80105bc9 <sys_link+0x144>
  }
  iunlockput(dp);
80105ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105baa:	89 04 24             	mov    %eax,(%esp)
80105bad:	e8 ac bf ff ff       	call   80101b5e <iunlockput>
  iput(ip);
80105bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb5:	89 04 24             	mov    %eax,(%esp)
80105bb8:	e8 d0 be ff ff       	call   80101a8d <iput>

  end_op();
80105bbd:	e8 7e d9 ff ff       	call   80103540 <end_op>

  return 0;
80105bc2:	b8 00 00 00 00       	mov    $0x0,%eax
80105bc7:	eb 3c                	jmp    80105c05 <sys_link+0x180>

bad:
  ilock(ip);
80105bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcc:	89 04 24             	mov    %eax,(%esp)
80105bcf:	e8 00 bd ff ff       	call   801018d4 <ilock>
  ip->nlink--;
80105bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bdb:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be1:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be8:	89 04 24             	mov    %eax,(%esp)
80105beb:	e8 22 bb ff ff       	call   80101712 <iupdate>
  iunlockput(ip);
80105bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf3:	89 04 24             	mov    %eax,(%esp)
80105bf6:	e8 63 bf ff ff       	call   80101b5e <iunlockput>
  end_op();
80105bfb:	e8 40 d9 ff ff       	call   80103540 <end_op>
  return -1;
80105c00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c05:	c9                   	leave  
80105c06:	c3                   	ret    

80105c07 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c07:	55                   	push   %ebp
80105c08:	89 e5                	mov    %esp,%ebp
80105c0a:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c0d:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c14:	eb 4b                	jmp    80105c61 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c19:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105c20:	00 
80105c21:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c28:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c2f:	89 04 24             	mov    %eax,(%esp)
80105c32:	e8 b0 c1 ff ff       	call   80101de7 <readi>
80105c37:	83 f8 10             	cmp    $0x10,%eax
80105c3a:	74 0c                	je     80105c48 <isdirempty+0x41>
      panic("isdirempty: readi");
80105c3c:	c7 04 24 7f 8c 10 80 	movl   $0x80108c7f,(%esp)
80105c43:	e8 f2 a8 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105c48:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c4c:	66 85 c0             	test   %ax,%ax
80105c4f:	74 07                	je     80105c58 <isdirempty+0x51>
      return 0;
80105c51:	b8 00 00 00 00       	mov    $0x0,%eax
80105c56:	eb 1b                	jmp    80105c73 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5b:	83 c0 10             	add    $0x10,%eax
80105c5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c64:	8b 45 08             	mov    0x8(%ebp),%eax
80105c67:	8b 40 18             	mov    0x18(%eax),%eax
80105c6a:	39 c2                	cmp    %eax,%edx
80105c6c:	72 a8                	jb     80105c16 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105c6e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c73:	c9                   	leave  
80105c74:	c3                   	ret    

80105c75 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105c75:	55                   	push   %ebp
80105c76:	89 e5                	mov    %esp,%ebp
80105c78:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105c7b:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c89:	e8 75 fa ff ff       	call   80105703 <argstr>
80105c8e:	85 c0                	test   %eax,%eax
80105c90:	79 0a                	jns    80105c9c <sys_unlink+0x27>
    return -1;
80105c92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c97:	e9 af 01 00 00       	jmp    80105e4b <sys_unlink+0x1d6>

  begin_op();
80105c9c:	e8 1b d8 ff ff       	call   801034bc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ca1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105ca4:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105ca7:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cab:	89 04 24             	mov    %eax,(%esp)
80105cae:	e8 f4 c7 ff ff       	call   801024a7 <nameiparent>
80105cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cb6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cba:	75 0f                	jne    80105ccb <sys_unlink+0x56>
    end_op();
80105cbc:	e8 7f d8 ff ff       	call   80103540 <end_op>
    return -1;
80105cc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc6:	e9 80 01 00 00       	jmp    80105e4b <sys_unlink+0x1d6>
  }

  ilock(dp);
80105ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cce:	89 04 24             	mov    %eax,(%esp)
80105cd1:	e8 fe bb ff ff       	call   801018d4 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105cd6:	c7 44 24 04 91 8c 10 	movl   $0x80108c91,0x4(%esp)
80105cdd:	80 
80105cde:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ce1:	89 04 24             	mov    %eax,(%esp)
80105ce4:	e8 f1 c3 ff ff       	call   801020da <namecmp>
80105ce9:	85 c0                	test   %eax,%eax
80105ceb:	0f 84 45 01 00 00    	je     80105e36 <sys_unlink+0x1c1>
80105cf1:	c7 44 24 04 93 8c 10 	movl   $0x80108c93,0x4(%esp)
80105cf8:	80 
80105cf9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cfc:	89 04 24             	mov    %eax,(%esp)
80105cff:	e8 d6 c3 ff ff       	call   801020da <namecmp>
80105d04:	85 c0                	test   %eax,%eax
80105d06:	0f 84 2a 01 00 00    	je     80105e36 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d0c:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d0f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d13:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d16:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1d:	89 04 24             	mov    %eax,(%esp)
80105d20:	e8 d7 c3 ff ff       	call   801020fc <dirlookup>
80105d25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d2c:	75 05                	jne    80105d33 <sys_unlink+0xbe>
    goto bad;
80105d2e:	e9 03 01 00 00       	jmp    80105e36 <sys_unlink+0x1c1>
  ilock(ip);
80105d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d36:	89 04 24             	mov    %eax,(%esp)
80105d39:	e8 96 bb ff ff       	call   801018d4 <ilock>

  if(ip->nlink < 1)
80105d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d41:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d45:	66 85 c0             	test   %ax,%ax
80105d48:	7f 0c                	jg     80105d56 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105d4a:	c7 04 24 96 8c 10 80 	movl   $0x80108c96,(%esp)
80105d51:	e8 e4 a7 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d59:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d5d:	66 83 f8 01          	cmp    $0x1,%ax
80105d61:	75 1f                	jne    80105d82 <sys_unlink+0x10d>
80105d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d66:	89 04 24             	mov    %eax,(%esp)
80105d69:	e8 99 fe ff ff       	call   80105c07 <isdirempty>
80105d6e:	85 c0                	test   %eax,%eax
80105d70:	75 10                	jne    80105d82 <sys_unlink+0x10d>
    iunlockput(ip);
80105d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d75:	89 04 24             	mov    %eax,(%esp)
80105d78:	e8 e1 bd ff ff       	call   80101b5e <iunlockput>
    goto bad;
80105d7d:	e9 b4 00 00 00       	jmp    80105e36 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105d82:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105d89:	00 
80105d8a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d91:	00 
80105d92:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d95:	89 04 24             	mov    %eax,(%esp)
80105d98:	e8 94 f5 ff ff       	call   80105331 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d9d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105da0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105da7:	00 
80105da8:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dac:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105daf:	89 44 24 04          	mov    %eax,0x4(%esp)
80105db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db6:	89 04 24             	mov    %eax,(%esp)
80105db9:	e8 8d c1 ff ff       	call   80101f4b <writei>
80105dbe:	83 f8 10             	cmp    $0x10,%eax
80105dc1:	74 0c                	je     80105dcf <sys_unlink+0x15a>
    panic("unlink: writei");
80105dc3:	c7 04 24 a8 8c 10 80 	movl   $0x80108ca8,(%esp)
80105dca:	e8 6b a7 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105dd6:	66 83 f8 01          	cmp    $0x1,%ax
80105dda:	75 1c                	jne    80105df8 <sys_unlink+0x183>
    dp->nlink--;
80105ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105de3:	8d 50 ff             	lea    -0x1(%eax),%edx
80105de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de9:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df0:	89 04 24             	mov    %eax,(%esp)
80105df3:	e8 1a b9 ff ff       	call   80101712 <iupdate>
  }
  iunlockput(dp);
80105df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfb:	89 04 24             	mov    %eax,(%esp)
80105dfe:	e8 5b bd ff ff       	call   80101b5e <iunlockput>

  ip->nlink--;
80105e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e06:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e0a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e10:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e17:	89 04 24             	mov    %eax,(%esp)
80105e1a:	e8 f3 b8 ff ff       	call   80101712 <iupdate>
  iunlockput(ip);
80105e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e22:	89 04 24             	mov    %eax,(%esp)
80105e25:	e8 34 bd ff ff       	call   80101b5e <iunlockput>

  end_op();
80105e2a:	e8 11 d7 ff ff       	call   80103540 <end_op>

  return 0;
80105e2f:	b8 00 00 00 00       	mov    $0x0,%eax
80105e34:	eb 15                	jmp    80105e4b <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e39:	89 04 24             	mov    %eax,(%esp)
80105e3c:	e8 1d bd ff ff       	call   80101b5e <iunlockput>
  end_op();
80105e41:	e8 fa d6 ff ff       	call   80103540 <end_op>
  return -1;
80105e46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e4b:	c9                   	leave  
80105e4c:	c3                   	ret    

80105e4d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e4d:	55                   	push   %ebp
80105e4e:	89 e5                	mov    %esp,%ebp
80105e50:	83 ec 48             	sub    $0x48,%esp
80105e53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e56:	8b 55 10             	mov    0x10(%ebp),%edx
80105e59:	8b 45 14             	mov    0x14(%ebp),%eax
80105e5c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e60:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e64:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e68:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e6b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80105e72:	89 04 24             	mov    %eax,(%esp)
80105e75:	e8 2d c6 ff ff       	call   801024a7 <nameiparent>
80105e7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e81:	75 0a                	jne    80105e8d <create+0x40>
    return 0;
80105e83:	b8 00 00 00 00       	mov    $0x0,%eax
80105e88:	e9 7e 01 00 00       	jmp    8010600b <create+0x1be>
  ilock(dp);
80105e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e90:	89 04 24             	mov    %eax,(%esp)
80105e93:	e8 3c ba ff ff       	call   801018d4 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e98:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e9b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e9f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ea2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea9:	89 04 24             	mov    %eax,(%esp)
80105eac:	e8 4b c2 ff ff       	call   801020fc <dirlookup>
80105eb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105eb4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105eb8:	74 47                	je     80105f01 <create+0xb4>
    iunlockput(dp);
80105eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebd:	89 04 24             	mov    %eax,(%esp)
80105ec0:	e8 99 bc ff ff       	call   80101b5e <iunlockput>
    ilock(ip);
80105ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec8:	89 04 24             	mov    %eax,(%esp)
80105ecb:	e8 04 ba ff ff       	call   801018d4 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105ed0:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105ed5:	75 15                	jne    80105eec <create+0x9f>
80105ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eda:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ede:	66 83 f8 02          	cmp    $0x2,%ax
80105ee2:	75 08                	jne    80105eec <create+0x9f>
      return ip;
80105ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee7:	e9 1f 01 00 00       	jmp    8010600b <create+0x1be>
    iunlockput(ip);
80105eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eef:	89 04 24             	mov    %eax,(%esp)
80105ef2:	e8 67 bc ff ff       	call   80101b5e <iunlockput>
    return 0;
80105ef7:	b8 00 00 00 00       	mov    $0x0,%eax
80105efc:	e9 0a 01 00 00       	jmp    8010600b <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f01:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f08:	8b 00                	mov    (%eax),%eax
80105f0a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f0e:	89 04 24             	mov    %eax,(%esp)
80105f11:	e8 27 b7 ff ff       	call   8010163d <ialloc>
80105f16:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f1d:	75 0c                	jne    80105f2b <create+0xde>
    panic("create: ialloc");
80105f1f:	c7 04 24 b7 8c 10 80 	movl   $0x80108cb7,(%esp)
80105f26:	e8 0f a6 ff ff       	call   8010053a <panic>

  ilock(ip);
80105f2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2e:	89 04 24             	mov    %eax,(%esp)
80105f31:	e8 9e b9 ff ff       	call   801018d4 <ilock>
  ip->major = major;
80105f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f39:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f3d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f44:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f48:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f4f:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f58:	89 04 24             	mov    %eax,(%esp)
80105f5b:	e8 b2 b7 ff ff       	call   80101712 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105f60:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f65:	75 6a                	jne    80105fd1 <create+0x184>
    dp->nlink++;  // for ".."
80105f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f6a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f6e:	8d 50 01             	lea    0x1(%eax),%edx
80105f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f74:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f7b:	89 04 24             	mov    %eax,(%esp)
80105f7e:	e8 8f b7 ff ff       	call   80101712 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f86:	8b 40 04             	mov    0x4(%eax),%eax
80105f89:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f8d:	c7 44 24 04 91 8c 10 	movl   $0x80108c91,0x4(%esp)
80105f94:	80 
80105f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f98:	89 04 24             	mov    %eax,(%esp)
80105f9b:	e8 25 c2 ff ff       	call   801021c5 <dirlink>
80105fa0:	85 c0                	test   %eax,%eax
80105fa2:	78 21                	js     80105fc5 <create+0x178>
80105fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa7:	8b 40 04             	mov    0x4(%eax),%eax
80105faa:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fae:	c7 44 24 04 93 8c 10 	movl   $0x80108c93,0x4(%esp)
80105fb5:	80 
80105fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb9:	89 04 24             	mov    %eax,(%esp)
80105fbc:	e8 04 c2 ff ff       	call   801021c5 <dirlink>
80105fc1:	85 c0                	test   %eax,%eax
80105fc3:	79 0c                	jns    80105fd1 <create+0x184>
      panic("create dots");
80105fc5:	c7 04 24 c6 8c 10 80 	movl   $0x80108cc6,(%esp)
80105fcc:	e8 69 a5 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd4:	8b 40 04             	mov    0x4(%eax),%eax
80105fd7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fdb:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fde:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe5:	89 04 24             	mov    %eax,(%esp)
80105fe8:	e8 d8 c1 ff ff       	call   801021c5 <dirlink>
80105fed:	85 c0                	test   %eax,%eax
80105fef:	79 0c                	jns    80105ffd <create+0x1b0>
    panic("create: dirlink");
80105ff1:	c7 04 24 d2 8c 10 80 	movl   $0x80108cd2,(%esp)
80105ff8:	e8 3d a5 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80105ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106000:	89 04 24             	mov    %eax,(%esp)
80106003:	e8 56 bb ff ff       	call   80101b5e <iunlockput>

  return ip;
80106008:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010600b:	c9                   	leave  
8010600c:	c3                   	ret    

8010600d <sys_open>:

int
sys_open(void)
{
8010600d:	55                   	push   %ebp
8010600e:	89 e5                	mov    %esp,%ebp
80106010:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106013:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106016:	89 44 24 04          	mov    %eax,0x4(%esp)
8010601a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106021:	e8 dd f6 ff ff       	call   80105703 <argstr>
80106026:	85 c0                	test   %eax,%eax
80106028:	78 17                	js     80106041 <sys_open+0x34>
8010602a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010602d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106031:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106038:	e8 36 f6 ff ff       	call   80105673 <argint>
8010603d:	85 c0                	test   %eax,%eax
8010603f:	79 0a                	jns    8010604b <sys_open+0x3e>
    return -1;
80106041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106046:	e9 5c 01 00 00       	jmp    801061a7 <sys_open+0x19a>

  begin_op();
8010604b:	e8 6c d4 ff ff       	call   801034bc <begin_op>

  if(omode & O_CREATE){
80106050:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106053:	25 00 02 00 00       	and    $0x200,%eax
80106058:	85 c0                	test   %eax,%eax
8010605a:	74 3b                	je     80106097 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010605c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010605f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106066:	00 
80106067:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010606e:	00 
8010606f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106076:	00 
80106077:	89 04 24             	mov    %eax,(%esp)
8010607a:	e8 ce fd ff ff       	call   80105e4d <create>
8010607f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106082:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106086:	75 6b                	jne    801060f3 <sys_open+0xe6>
      end_op();
80106088:	e8 b3 d4 ff ff       	call   80103540 <end_op>
      return -1;
8010608d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106092:	e9 10 01 00 00       	jmp    801061a7 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80106097:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010609a:	89 04 24             	mov    %eax,(%esp)
8010609d:	e8 e3 c3 ff ff       	call   80102485 <namei>
801060a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060a9:	75 0f                	jne    801060ba <sys_open+0xad>
      end_op();
801060ab:	e8 90 d4 ff ff       	call   80103540 <end_op>
      return -1;
801060b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b5:	e9 ed 00 00 00       	jmp    801061a7 <sys_open+0x19a>
    }
    ilock(ip);
801060ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bd:	89 04 24             	mov    %eax,(%esp)
801060c0:	e8 0f b8 ff ff       	call   801018d4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801060c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060cc:	66 83 f8 01          	cmp    $0x1,%ax
801060d0:	75 21                	jne    801060f3 <sys_open+0xe6>
801060d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060d5:	85 c0                	test   %eax,%eax
801060d7:	74 1a                	je     801060f3 <sys_open+0xe6>
      iunlockput(ip);
801060d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060dc:	89 04 24             	mov    %eax,(%esp)
801060df:	e8 7a ba ff ff       	call   80101b5e <iunlockput>
      end_op();
801060e4:	e8 57 d4 ff ff       	call   80103540 <end_op>
      return -1;
801060e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ee:	e9 b4 00 00 00       	jmp    801061a7 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801060f3:	e8 49 ae ff ff       	call   80100f41 <filealloc>
801060f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060ff:	74 14                	je     80106115 <sys_open+0x108>
80106101:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106104:	89 04 24             	mov    %eax,(%esp)
80106107:	e8 31 f7 ff ff       	call   8010583d <fdalloc>
8010610c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010610f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106113:	79 28                	jns    8010613d <sys_open+0x130>
    if(f)
80106115:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106119:	74 0b                	je     80106126 <sys_open+0x119>
      fileclose(f);
8010611b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611e:	89 04 24             	mov    %eax,(%esp)
80106121:	e8 c3 ae ff ff       	call   80100fe9 <fileclose>
    iunlockput(ip);
80106126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106129:	89 04 24             	mov    %eax,(%esp)
8010612c:	e8 2d ba ff ff       	call   80101b5e <iunlockput>
    end_op();
80106131:	e8 0a d4 ff ff       	call   80103540 <end_op>
    return -1;
80106136:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010613b:	eb 6a                	jmp    801061a7 <sys_open+0x19a>
  }
  iunlock(ip);
8010613d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106140:	89 04 24             	mov    %eax,(%esp)
80106143:	e8 e0 b8 ff ff       	call   80101a28 <iunlock>
  end_op();
80106148:	e8 f3 d3 ff ff       	call   80103540 <end_op>

  f->type = FD_INODE;
8010614d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106150:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106156:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106159:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010615c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010615f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106162:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106169:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010616c:	83 e0 01             	and    $0x1,%eax
8010616f:	85 c0                	test   %eax,%eax
80106171:	0f 94 c0             	sete   %al
80106174:	89 c2                	mov    %eax,%edx
80106176:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106179:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010617c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010617f:	83 e0 01             	and    $0x1,%eax
80106182:	85 c0                	test   %eax,%eax
80106184:	75 0a                	jne    80106190 <sys_open+0x183>
80106186:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106189:	83 e0 02             	and    $0x2,%eax
8010618c:	85 c0                	test   %eax,%eax
8010618e:	74 07                	je     80106197 <sys_open+0x18a>
80106190:	b8 01 00 00 00       	mov    $0x1,%eax
80106195:	eb 05                	jmp    8010619c <sys_open+0x18f>
80106197:	b8 00 00 00 00       	mov    $0x0,%eax
8010619c:	89 c2                	mov    %eax,%edx
8010619e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a1:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801061a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801061a7:	c9                   	leave  
801061a8:	c3                   	ret    

801061a9 <sys_mkdir>:

int
sys_mkdir(void)
{
801061a9:	55                   	push   %ebp
801061aa:	89 e5                	mov    %esp,%ebp
801061ac:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801061af:	e8 08 d3 ff ff       	call   801034bc <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801061b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801061bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061c2:	e8 3c f5 ff ff       	call   80105703 <argstr>
801061c7:	85 c0                	test   %eax,%eax
801061c9:	78 2c                	js     801061f7 <sys_mkdir+0x4e>
801061cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ce:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801061d5:	00 
801061d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801061dd:	00 
801061de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801061e5:	00 
801061e6:	89 04 24             	mov    %eax,(%esp)
801061e9:	e8 5f fc ff ff       	call   80105e4d <create>
801061ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061f5:	75 0c                	jne    80106203 <sys_mkdir+0x5a>
    end_op();
801061f7:	e8 44 d3 ff ff       	call   80103540 <end_op>
    return -1;
801061fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106201:	eb 15                	jmp    80106218 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106206:	89 04 24             	mov    %eax,(%esp)
80106209:	e8 50 b9 ff ff       	call   80101b5e <iunlockput>
  end_op();
8010620e:	e8 2d d3 ff ff       	call   80103540 <end_op>
  return 0;
80106213:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106218:	c9                   	leave  
80106219:	c3                   	ret    

8010621a <sys_mknod>:

int
sys_mknod(void)
{
8010621a:	55                   	push   %ebp
8010621b:	89 e5                	mov    %esp,%ebp
8010621d:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106220:	e8 97 d2 ff ff       	call   801034bc <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106225:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106228:	89 44 24 04          	mov    %eax,0x4(%esp)
8010622c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106233:	e8 cb f4 ff ff       	call   80105703 <argstr>
80106238:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010623b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010623f:	78 5e                	js     8010629f <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106241:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106244:	89 44 24 04          	mov    %eax,0x4(%esp)
80106248:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010624f:	e8 1f f4 ff ff       	call   80105673 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106254:	85 c0                	test   %eax,%eax
80106256:	78 47                	js     8010629f <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106258:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010625b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010625f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106266:	e8 08 f4 ff ff       	call   80105673 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010626b:	85 c0                	test   %eax,%eax
8010626d:	78 30                	js     8010629f <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010626f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106272:	0f bf c8             	movswl %ax,%ecx
80106275:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106278:	0f bf d0             	movswl %ax,%edx
8010627b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010627e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106282:	89 54 24 08          	mov    %edx,0x8(%esp)
80106286:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010628d:	00 
8010628e:	89 04 24             	mov    %eax,(%esp)
80106291:	e8 b7 fb ff ff       	call   80105e4d <create>
80106296:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106299:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010629d:	75 0c                	jne    801062ab <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010629f:	e8 9c d2 ff ff       	call   80103540 <end_op>
    return -1;
801062a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a9:	eb 15                	jmp    801062c0 <sys_mknod+0xa6>
  }
  iunlockput(ip);
801062ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ae:	89 04 24             	mov    %eax,(%esp)
801062b1:	e8 a8 b8 ff ff       	call   80101b5e <iunlockput>
  end_op();
801062b6:	e8 85 d2 ff ff       	call   80103540 <end_op>
  return 0;
801062bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062c0:	c9                   	leave  
801062c1:	c3                   	ret    

801062c2 <sys_chdir>:

int
sys_chdir(void)
{
801062c2:	55                   	push   %ebp
801062c3:	89 e5                	mov    %esp,%ebp
801062c5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801062c8:	e8 ef d1 ff ff       	call   801034bc <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801062cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801062d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062db:	e8 23 f4 ff ff       	call   80105703 <argstr>
801062e0:	85 c0                	test   %eax,%eax
801062e2:	78 14                	js     801062f8 <sys_chdir+0x36>
801062e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e7:	89 04 24             	mov    %eax,(%esp)
801062ea:	e8 96 c1 ff ff       	call   80102485 <namei>
801062ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062f6:	75 0c                	jne    80106304 <sys_chdir+0x42>
    end_op();
801062f8:	e8 43 d2 ff ff       	call   80103540 <end_op>
    return -1;
801062fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106302:	eb 61                	jmp    80106365 <sys_chdir+0xa3>
  }
  ilock(ip);
80106304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106307:	89 04 24             	mov    %eax,(%esp)
8010630a:	e8 c5 b5 ff ff       	call   801018d4 <ilock>
  if(ip->type != T_DIR){
8010630f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106312:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106316:	66 83 f8 01          	cmp    $0x1,%ax
8010631a:	74 17                	je     80106333 <sys_chdir+0x71>
    iunlockput(ip);
8010631c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631f:	89 04 24             	mov    %eax,(%esp)
80106322:	e8 37 b8 ff ff       	call   80101b5e <iunlockput>
    end_op();
80106327:	e8 14 d2 ff ff       	call   80103540 <end_op>
    return -1;
8010632c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106331:	eb 32                	jmp    80106365 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106336:	89 04 24             	mov    %eax,(%esp)
80106339:	e8 ea b6 ff ff       	call   80101a28 <iunlock>
  iput(proc->cwd);
8010633e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106344:	8b 40 70             	mov    0x70(%eax),%eax
80106347:	89 04 24             	mov    %eax,(%esp)
8010634a:	e8 3e b7 ff ff       	call   80101a8d <iput>
  end_op();
8010634f:	e8 ec d1 ff ff       	call   80103540 <end_op>
  proc->cwd = ip;
80106354:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010635a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010635d:	89 50 70             	mov    %edx,0x70(%eax)
  return 0;
80106360:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106365:	c9                   	leave  
80106366:	c3                   	ret    

80106367 <sys_exec>:

int
sys_exec(void)
{
80106367:	55                   	push   %ebp
80106368:	89 e5                	mov    %esp,%ebp
8010636a:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106370:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106373:	89 44 24 04          	mov    %eax,0x4(%esp)
80106377:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010637e:	e8 80 f3 ff ff       	call   80105703 <argstr>
80106383:	85 c0                	test   %eax,%eax
80106385:	78 1a                	js     801063a1 <sys_exec+0x3a>
80106387:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010638d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106391:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106398:	e8 d6 f2 ff ff       	call   80105673 <argint>
8010639d:	85 c0                	test   %eax,%eax
8010639f:	79 0a                	jns    801063ab <sys_exec+0x44>
    return -1;
801063a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a6:	e9 c8 00 00 00       	jmp    80106473 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
801063ab:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801063b2:	00 
801063b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801063ba:	00 
801063bb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063c1:	89 04 24             	mov    %eax,(%esp)
801063c4:	e8 68 ef ff ff       	call   80105331 <memset>
  for(i=0;; i++){
801063c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d3:	83 f8 1f             	cmp    $0x1f,%eax
801063d6:	76 0a                	jbe    801063e2 <sys_exec+0x7b>
      return -1;
801063d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063dd:	e9 91 00 00 00       	jmp    80106473 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801063e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e5:	c1 e0 02             	shl    $0x2,%eax
801063e8:	89 c2                	mov    %eax,%edx
801063ea:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801063f0:	01 c2                	add    %eax,%edx
801063f2:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801063f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801063fc:	89 14 24             	mov    %edx,(%esp)
801063ff:	e8 d3 f1 ff ff       	call   801055d7 <fetchint>
80106404:	85 c0                	test   %eax,%eax
80106406:	79 07                	jns    8010640f <sys_exec+0xa8>
      return -1;
80106408:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640d:	eb 64                	jmp    80106473 <sys_exec+0x10c>
    if(uarg == 0){
8010640f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106415:	85 c0                	test   %eax,%eax
80106417:	75 26                	jne    8010643f <sys_exec+0xd8>
      argv[i] = 0;
80106419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010641c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106423:	00 00 00 00 
      break;
80106427:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106431:	89 54 24 04          	mov    %edx,0x4(%esp)
80106435:	89 04 24             	mov    %eax,(%esp)
80106438:	e8 cd a6 ff ff       	call   80100b0a <exec>
8010643d:	eb 34                	jmp    80106473 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010643f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106445:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106448:	c1 e2 02             	shl    $0x2,%edx
8010644b:	01 c2                	add    %eax,%edx
8010644d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106453:	89 54 24 04          	mov    %edx,0x4(%esp)
80106457:	89 04 24             	mov    %eax,(%esp)
8010645a:	e8 b2 f1 ff ff       	call   80105611 <fetchstr>
8010645f:	85 c0                	test   %eax,%eax
80106461:	79 07                	jns    8010646a <sys_exec+0x103>
      return -1;
80106463:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106468:	eb 09                	jmp    80106473 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010646a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010646e:	e9 5d ff ff ff       	jmp    801063d0 <sys_exec+0x69>
  return exec(path, argv);
}
80106473:	c9                   	leave  
80106474:	c3                   	ret    

80106475 <sys_pipe>:

int
sys_pipe(void)
{
80106475:	55                   	push   %ebp
80106476:	89 e5                	mov    %esp,%ebp
80106478:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010647b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106482:	00 
80106483:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106486:	89 44 24 04          	mov    %eax,0x4(%esp)
8010648a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106491:	e8 0b f2 ff ff       	call   801056a1 <argptr>
80106496:	85 c0                	test   %eax,%eax
80106498:	79 0a                	jns    801064a4 <sys_pipe+0x2f>
    return -1;
8010649a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649f:	e9 9a 00 00 00       	jmp    8010653e <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
801064a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801064a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ab:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064ae:	89 04 24             	mov    %eax,(%esp)
801064b1:	e8 12 db ff ff       	call   80103fc8 <pipealloc>
801064b6:	85 c0                	test   %eax,%eax
801064b8:	79 07                	jns    801064c1 <sys_pipe+0x4c>
    return -1;
801064ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064bf:	eb 7d                	jmp    8010653e <sys_pipe+0xc9>
  fd0 = -1;
801064c1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801064c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064cb:	89 04 24             	mov    %eax,(%esp)
801064ce:	e8 6a f3 ff ff       	call   8010583d <fdalloc>
801064d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064da:	78 14                	js     801064f0 <sys_pipe+0x7b>
801064dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064df:	89 04 24             	mov    %eax,(%esp)
801064e2:	e8 56 f3 ff ff       	call   8010583d <fdalloc>
801064e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064ee:	79 36                	jns    80106526 <sys_pipe+0xb1>
    if(fd0 >= 0)
801064f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064f4:	78 13                	js     80106509 <sys_pipe+0x94>
      proc->ofile[fd0] = 0;
801064f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064ff:	83 c2 0c             	add    $0xc,%edx
80106502:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
    fileclose(rf);
80106509:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010650c:	89 04 24             	mov    %eax,(%esp)
8010650f:	e8 d5 aa ff ff       	call   80100fe9 <fileclose>
    fileclose(wf);
80106514:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106517:	89 04 24             	mov    %eax,(%esp)
8010651a:	e8 ca aa ff ff       	call   80100fe9 <fileclose>
    return -1;
8010651f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106524:	eb 18                	jmp    8010653e <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106526:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106529:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010652c:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010652e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106531:	8d 50 04             	lea    0x4(%eax),%edx
80106534:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106537:	89 02                	mov    %eax,(%edx)
  return 0;
80106539:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010653e:	c9                   	leave  
8010653f:	c3                   	ret    

80106540 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106540:	55                   	push   %ebp
80106541:	89 e5                	mov    %esp,%ebp
80106543:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106546:	e8 3f e1 ff ff       	call   8010468a <fork>
}
8010654b:	c9                   	leave  
8010654c:	c3                   	ret    

8010654d <sys_exit>:

int
sys_exit(void)
{
8010654d:	55                   	push   %ebp
8010654e:	89 e5                	mov    %esp,%ebp
80106550:	83 ec 08             	sub    $0x8,%esp
  exit();
80106553:	e8 c8 e2 ff ff       	call   80104820 <exit>
  return 0;  // not reached
80106558:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010655d:	c9                   	leave  
8010655e:	c3                   	ret    

8010655f <sys_wait>:

int
sys_wait(void)
{
8010655f:	55                   	push   %ebp
80106560:	89 e5                	mov    %esp,%ebp
80106562:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106565:	e8 d8 e3 ff ff       	call   80104942 <wait>
}
8010656a:	c9                   	leave  
8010656b:	c3                   	ret    

8010656c <sys_kill>:

int
sys_kill(void)
{
8010656c:	55                   	push   %ebp
8010656d:	89 e5                	mov    %esp,%ebp
8010656f:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106572:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106575:	89 44 24 04          	mov    %eax,0x4(%esp)
80106579:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106580:	e8 ee f0 ff ff       	call   80105673 <argint>
80106585:	85 c0                	test   %eax,%eax
80106587:	79 07                	jns    80106590 <sys_kill+0x24>
    return -1;
80106589:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658e:	eb 0b                	jmp    8010659b <sys_kill+0x2f>
  return kill(pid);
80106590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106593:	89 04 24             	mov    %eax,(%esp)
80106596:	e8 7e e7 ff ff       	call   80104d19 <kill>
}
8010659b:	c9                   	leave  
8010659c:	c3                   	ret    

8010659d <sys_getpid>:

int
sys_getpid(void)
{
8010659d:	55                   	push   %ebp
8010659e:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801065a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065a6:	8b 40 10             	mov    0x10(%eax),%eax
}
801065a9:	5d                   	pop    %ebp
801065aa:	c3                   	ret    

801065ab <sys_sbrk>:

int
sys_sbrk(void)
{
801065ab:	55                   	push   %ebp
801065ac:	89 e5                	mov    %esp,%ebp
801065ae:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801065b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801065b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065bf:	e8 af f0 ff ff       	call   80105673 <argint>
801065c4:	85 c0                	test   %eax,%eax
801065c6:	79 07                	jns    801065cf <sys_sbrk+0x24>
    return -1;
801065c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065cd:	eb 24                	jmp    801065f3 <sys_sbrk+0x48>
  addr = proc->sz;
801065cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065d5:	8b 00                	mov    (%eax),%eax
801065d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801065da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065dd:	89 04 24             	mov    %eax,(%esp)
801065e0:	e8 00 e0 ff ff       	call   801045e5 <growproc>
801065e5:	85 c0                	test   %eax,%eax
801065e7:	79 07                	jns    801065f0 <sys_sbrk+0x45>
    return -1;
801065e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ee:	eb 03                	jmp    801065f3 <sys_sbrk+0x48>
  return addr;
801065f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065f3:	c9                   	leave  
801065f4:	c3                   	ret    

801065f5 <sys_sleep>:

int
sys_sleep(void)
{
801065f5:	55                   	push   %ebp
801065f6:	89 e5                	mov    %esp,%ebp
801065f8:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801065fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106602:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106609:	e8 65 f0 ff ff       	call   80105673 <argint>
8010660e:	85 c0                	test   %eax,%eax
80106610:	79 07                	jns    80106619 <sys_sleep+0x24>
    return -1;
80106612:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106617:	eb 6c                	jmp    80106685 <sys_sleep+0x90>
  acquire(&tickslock);
80106619:	c7 04 24 c0 4a 11 80 	movl   $0x80114ac0,(%esp)
80106620:	e8 b8 ea ff ff       	call   801050dd <acquire>
  ticks0 = ticks;
80106625:	a1 00 53 11 80       	mov    0x80115300,%eax
8010662a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010662d:	eb 34                	jmp    80106663 <sys_sleep+0x6e>
    if(proc->killed){
8010662f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106635:	8b 40 2c             	mov    0x2c(%eax),%eax
80106638:	85 c0                	test   %eax,%eax
8010663a:	74 13                	je     8010664f <sys_sleep+0x5a>
      release(&tickslock);
8010663c:	c7 04 24 c0 4a 11 80 	movl   $0x80114ac0,(%esp)
80106643:	e8 f7 ea ff ff       	call   8010513f <release>
      return -1;
80106648:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010664d:	eb 36                	jmp    80106685 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010664f:	c7 44 24 04 c0 4a 11 	movl   $0x80114ac0,0x4(%esp)
80106656:	80 
80106657:	c7 04 24 00 53 11 80 	movl   $0x80115300,(%esp)
8010665e:	e8 af e5 ff ff       	call   80104c12 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106663:	a1 00 53 11 80       	mov    0x80115300,%eax
80106668:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010666b:	89 c2                	mov    %eax,%edx
8010666d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106670:	39 c2                	cmp    %eax,%edx
80106672:	72 bb                	jb     8010662f <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106674:	c7 04 24 c0 4a 11 80 	movl   $0x80114ac0,(%esp)
8010667b:	e8 bf ea ff ff       	call   8010513f <release>
  return 0;
80106680:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106685:	c9                   	leave  
80106686:	c3                   	ret    

80106687 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106687:	55                   	push   %ebp
80106688:	89 e5                	mov    %esp,%ebp
8010668a:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010668d:	c7 04 24 c0 4a 11 80 	movl   $0x80114ac0,(%esp)
80106694:	e8 44 ea ff ff       	call   801050dd <acquire>
  xticks = ticks;
80106699:	a1 00 53 11 80       	mov    0x80115300,%eax
8010669e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801066a1:	c7 04 24 c0 4a 11 80 	movl   $0x80114ac0,(%esp)
801066a8:	e8 92 ea ff ff       	call   8010513f <release>
  return xticks;
801066ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066b0:	c9                   	leave  
801066b1:	c3                   	ret    

801066b2 <sys_date>:
int
sys_date(rtcdate)
{
801066b2:	55                   	push   %ebp
801066b3:	89 e5                	mov    %esp,%ebp
801066b5:	83 ec 28             	sub    $0x28,%esp

 struct rtcdate *d;
 argptr(0, (void*)&d, sizeof(*d));
801066b8:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801066bf:	00 
801066c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801066c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066ce:	e8 ce ef ff ff       	call   801056a1 <argptr>
cmostime(d);
801066d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d6:	89 04 24             	mov    %eax,(%esp)
801066d9:	e8 78 ca ff ff       	call   80103156 <cmostime>

return 0;
801066de:	b8 00 00 00 00       	mov    $0x0,%eax

}
801066e3:	c9                   	leave  
801066e4:	c3                   	ret    

801066e5 <sys_timem>:
int
sys_timem(void)
{
801066e5:	55                   	push   %ebp
801066e6:	89 e5                	mov    %esp,%ebp
return 0;
801066e8:	b8 00 00 00 00       	mov    $0x0,%eax

}
801066ed:	5d                   	pop    %ebp
801066ee:	c3                   	ret    

801066ef <sys_getuid>:


int
sys_getuid(void)
{
801066ef:	55                   	push   %ebp
801066f0:	89 e5                	mov    %esp,%ebp
	//int newid=5;
//proc->uid=newid;
  return proc->uid;
801066f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066f8:	8b 40 14             	mov    0x14(%eax),%eax

}
801066fb:	5d                   	pop    %ebp
801066fc:	c3                   	ret    

801066fd <sys_getgid>:
int
sys_getgid(void)
{
801066fd:	55                   	push   %ebp
801066fe:	89 e5                	mov    %esp,%ebp
  return proc->gid;
80106700:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106706:	8b 40 18             	mov    0x18(%eax),%eax

}
80106709:	5d                   	pop    %ebp
8010670a:	c3                   	ret    

8010670b <sys_getppid>:

int
sys_getppid(void)
{
8010670b:	55                   	push   %ebp
8010670c:	89 e5                	mov    %esp,%ebp
  return proc->parent->pid;
8010670e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106714:	8b 40 1c             	mov    0x1c(%eax),%eax
80106717:	8b 40 10             	mov    0x10(%eax),%eax

}
8010671a:	5d                   	pop    %ebp
8010671b:	c3                   	ret    

8010671c <sys_setuid>:

int
sys_setuid(void)
{
8010671c:	55                   	push   %ebp
8010671d:	89 e5                	mov    %esp,%ebp
8010671f:	83 ec 28             	sub    $0x28,%esp
  int fuid;

  if(argint(0, &fuid) < 0)
80106722:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106725:	89 44 24 04          	mov    %eax,0x4(%esp)
80106729:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106730:	e8 3e ef ff ff       	call   80105673 <argint>
80106735:	85 c0                	test   %eax,%eax
80106737:	79 07                	jns    80106740 <sys_setuid+0x24>
    return -1;
80106739:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010673e:	eb 11                	jmp    80106751 <sys_setuid+0x35>
proc->uid=fuid;
80106740:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106746:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106749:	89 50 14             	mov    %edx,0x14(%eax)
return 0;
8010674c:	b8 00 00 00 00       	mov    $0x0,%eax

}
80106751:	c9                   	leave  
80106752:	c3                   	ret    

80106753 <sys_setgid>:
int
sys_setgid(void)
{
80106753:	55                   	push   %ebp
80106754:	89 e5                	mov    %esp,%ebp
80106756:	83 ec 28             	sub    $0x28,%esp
  int fgid;

  if(argint(0, &fgid) < 0)
80106759:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010675c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106760:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106767:	e8 07 ef ff ff       	call   80105673 <argint>
8010676c:	85 c0                	test   %eax,%eax
8010676e:	79 07                	jns    80106777 <sys_setgid+0x24>
    return -1;
80106770:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106775:	eb 11                	jmp    80106788 <sys_setgid+0x35>
proc->gid=fgid;
80106777:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010677d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106780:	89 50 18             	mov    %edx,0x18(%eax)
return 0;
80106783:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106788:	c9                   	leave  
80106789:	c3                   	ret    

8010678a <sys_getprocs>:

int
sys_getprocs(void)
{
8010678a:	55                   	push   %ebp
8010678b:	89 e5                	mov    %esp,%ebp
8010678d:	83 ec 28             	sub    $0x28,%esp
int max;
struct uproc *table;

if (argint(0, (void*)&max) < 0) {
80106790:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106793:	89 44 24 04          	mov    %eax,0x4(%esp)
80106797:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010679e:	e8 d0 ee ff ff       	call   80105673 <argint>
801067a3:	85 c0                	test   %eax,%eax
801067a5:	79 07                	jns    801067ae <sys_getprocs+0x24>
return -1;
801067a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ac:	eb 38                	jmp    801067e6 <sys_getprocs+0x5c>
}

if (argptr(1, (void*)&table, sizeof(*table)) < 0) {
801067ae:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801067b5:	00 
801067b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801067bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801067c4:	e8 d8 ee ff ff       	call   801056a1 <argptr>
801067c9:	85 c0                	test   %eax,%eax
801067cb:	79 07                	jns    801067d4 <sys_getprocs+0x4a>
return -1;
801067cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d2:	eb 12                	jmp    801067e6 <sys_getprocs+0x5c>
}
//return 0;
return getProcInfo(max, table);
801067d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801067d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067da:	89 54 24 04          	mov    %edx,0x4(%esp)
801067de:	89 04 24             	mov    %eax,(%esp)
801067e1:	e8 c1 e6 ff ff       	call   80104ea7 <getProcInfo>
801067e6:	c9                   	leave  
801067e7:	c3                   	ret    

801067e8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801067e8:	55                   	push   %ebp
801067e9:	89 e5                	mov    %esp,%ebp
801067eb:	83 ec 08             	sub    $0x8,%esp
801067ee:	8b 55 08             	mov    0x8(%ebp),%edx
801067f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801067f4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801067f8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801067fb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801067ff:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106803:	ee                   	out    %al,(%dx)
}
80106804:	c9                   	leave  
80106805:	c3                   	ret    

80106806 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106806:	55                   	push   %ebp
80106807:	89 e5                	mov    %esp,%ebp
80106809:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010680c:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106813:	00 
80106814:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
8010681b:	e8 c8 ff ff ff       	call   801067e8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106820:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106827:	00 
80106828:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010682f:	e8 b4 ff ff ff       	call   801067e8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106834:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010683b:	00 
8010683c:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106843:	e8 a0 ff ff ff       	call   801067e8 <outb>
  picenable(IRQ_TIMER);
80106848:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010684f:	e8 07 d6 ff ff       	call   80103e5b <picenable>
}
80106854:	c9                   	leave  
80106855:	c3                   	ret    

80106856 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106856:	1e                   	push   %ds
  pushl %es
80106857:	06                   	push   %es
  pushl %fs
80106858:	0f a0                	push   %fs
  pushl %gs
8010685a:	0f a8                	push   %gs
  pushal
8010685c:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010685d:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106861:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106863:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106865:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106869:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010686b:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010686d:	54                   	push   %esp
  call trap
8010686e:	e8 d8 01 00 00       	call   80106a4b <trap>
  addl $4, %esp
80106873:	83 c4 04             	add    $0x4,%esp

80106876 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106876:	61                   	popa   
  popl %gs
80106877:	0f a9                	pop    %gs
  popl %fs
80106879:	0f a1                	pop    %fs
  popl %es
8010687b:	07                   	pop    %es
  popl %ds
8010687c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010687d:	83 c4 08             	add    $0x8,%esp
  iret
80106880:	cf                   	iret   

80106881 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106881:	55                   	push   %ebp
80106882:	89 e5                	mov    %esp,%ebp
80106884:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106887:	8b 45 0c             	mov    0xc(%ebp),%eax
8010688a:	83 e8 01             	sub    $0x1,%eax
8010688d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106891:	8b 45 08             	mov    0x8(%ebp),%eax
80106894:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106898:	8b 45 08             	mov    0x8(%ebp),%eax
8010689b:	c1 e8 10             	shr    $0x10,%eax
8010689e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801068a2:	8d 45 fa             	lea    -0x6(%ebp),%eax
801068a5:	0f 01 18             	lidtl  (%eax)
}
801068a8:	c9                   	leave  
801068a9:	c3                   	ret    

801068aa <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801068aa:	55                   	push   %ebp
801068ab:	89 e5                	mov    %esp,%ebp
801068ad:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801068b0:	0f 20 d0             	mov    %cr2,%eax
801068b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801068b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801068b9:	c9                   	leave  
801068ba:	c3                   	ret    

801068bb <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801068bb:	55                   	push   %ebp
801068bc:	89 e5                	mov    %esp,%ebp
801068be:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801068c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801068c8:	e9 c3 00 00 00       	jmp    80106990 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801068cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d0:	8b 04 85 b8 b0 10 80 	mov    -0x7fef4f48(,%eax,4),%eax
801068d7:	89 c2                	mov    %eax,%edx
801068d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068dc:	66 89 14 c5 00 4b 11 	mov    %dx,-0x7feeb500(,%eax,8)
801068e3:	80 
801068e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e7:	66 c7 04 c5 02 4b 11 	movw   $0x8,-0x7feeb4fe(,%eax,8)
801068ee:	80 08 00 
801068f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f4:	0f b6 14 c5 04 4b 11 	movzbl -0x7feeb4fc(,%eax,8),%edx
801068fb:	80 
801068fc:	83 e2 e0             	and    $0xffffffe0,%edx
801068ff:	88 14 c5 04 4b 11 80 	mov    %dl,-0x7feeb4fc(,%eax,8)
80106906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106909:	0f b6 14 c5 04 4b 11 	movzbl -0x7feeb4fc(,%eax,8),%edx
80106910:	80 
80106911:	83 e2 1f             	and    $0x1f,%edx
80106914:	88 14 c5 04 4b 11 80 	mov    %dl,-0x7feeb4fc(,%eax,8)
8010691b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010691e:	0f b6 14 c5 05 4b 11 	movzbl -0x7feeb4fb(,%eax,8),%edx
80106925:	80 
80106926:	83 e2 f0             	and    $0xfffffff0,%edx
80106929:	83 ca 0e             	or     $0xe,%edx
8010692c:	88 14 c5 05 4b 11 80 	mov    %dl,-0x7feeb4fb(,%eax,8)
80106933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106936:	0f b6 14 c5 05 4b 11 	movzbl -0x7feeb4fb(,%eax,8),%edx
8010693d:	80 
8010693e:	83 e2 ef             	and    $0xffffffef,%edx
80106941:	88 14 c5 05 4b 11 80 	mov    %dl,-0x7feeb4fb(,%eax,8)
80106948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010694b:	0f b6 14 c5 05 4b 11 	movzbl -0x7feeb4fb(,%eax,8),%edx
80106952:	80 
80106953:	83 e2 9f             	and    $0xffffff9f,%edx
80106956:	88 14 c5 05 4b 11 80 	mov    %dl,-0x7feeb4fb(,%eax,8)
8010695d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106960:	0f b6 14 c5 05 4b 11 	movzbl -0x7feeb4fb(,%eax,8),%edx
80106967:	80 
80106968:	83 ca 80             	or     $0xffffff80,%edx
8010696b:	88 14 c5 05 4b 11 80 	mov    %dl,-0x7feeb4fb(,%eax,8)
80106972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106975:	8b 04 85 b8 b0 10 80 	mov    -0x7fef4f48(,%eax,4),%eax
8010697c:	c1 e8 10             	shr    $0x10,%eax
8010697f:	89 c2                	mov    %eax,%edx
80106981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106984:	66 89 14 c5 06 4b 11 	mov    %dx,-0x7feeb4fa(,%eax,8)
8010698b:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010698c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106990:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106997:	0f 8e 30 ff ff ff    	jle    801068cd <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010699d:	a1 b8 b1 10 80       	mov    0x8010b1b8,%eax
801069a2:	66 a3 00 4d 11 80    	mov    %ax,0x80114d00
801069a8:	66 c7 05 02 4d 11 80 	movw   $0x8,0x80114d02
801069af:	08 00 
801069b1:	0f b6 05 04 4d 11 80 	movzbl 0x80114d04,%eax
801069b8:	83 e0 e0             	and    $0xffffffe0,%eax
801069bb:	a2 04 4d 11 80       	mov    %al,0x80114d04
801069c0:	0f b6 05 04 4d 11 80 	movzbl 0x80114d04,%eax
801069c7:	83 e0 1f             	and    $0x1f,%eax
801069ca:	a2 04 4d 11 80       	mov    %al,0x80114d04
801069cf:	0f b6 05 05 4d 11 80 	movzbl 0x80114d05,%eax
801069d6:	83 c8 0f             	or     $0xf,%eax
801069d9:	a2 05 4d 11 80       	mov    %al,0x80114d05
801069de:	0f b6 05 05 4d 11 80 	movzbl 0x80114d05,%eax
801069e5:	83 e0 ef             	and    $0xffffffef,%eax
801069e8:	a2 05 4d 11 80       	mov    %al,0x80114d05
801069ed:	0f b6 05 05 4d 11 80 	movzbl 0x80114d05,%eax
801069f4:	83 c8 60             	or     $0x60,%eax
801069f7:	a2 05 4d 11 80       	mov    %al,0x80114d05
801069fc:	0f b6 05 05 4d 11 80 	movzbl 0x80114d05,%eax
80106a03:	83 c8 80             	or     $0xffffff80,%eax
80106a06:	a2 05 4d 11 80       	mov    %al,0x80114d05
80106a0b:	a1 b8 b1 10 80       	mov    0x8010b1b8,%eax
80106a10:	c1 e8 10             	shr    $0x10,%eax
80106a13:	66 a3 06 4d 11 80    	mov    %ax,0x80114d06
  
  initlock(&tickslock, "time");
80106a19:	c7 44 24 04 e4 8c 10 	movl   $0x80108ce4,0x4(%esp)
80106a20:	80 
80106a21:	c7 04 24 c0 4a 11 80 	movl   $0x80114ac0,(%esp)
80106a28:	e8 8f e6 ff ff       	call   801050bc <initlock>
}
80106a2d:	c9                   	leave  
80106a2e:	c3                   	ret    

80106a2f <idtinit>:

void
idtinit(void)
{
80106a2f:	55                   	push   %ebp
80106a30:	89 e5                	mov    %esp,%ebp
80106a32:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106a35:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106a3c:	00 
80106a3d:	c7 04 24 00 4b 11 80 	movl   $0x80114b00,(%esp)
80106a44:	e8 38 fe ff ff       	call   80106881 <lidt>
}
80106a49:	c9                   	leave  
80106a4a:	c3                   	ret    

80106a4b <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106a4b:	55                   	push   %ebp
80106a4c:	89 e5                	mov    %esp,%ebp
80106a4e:	57                   	push   %edi
80106a4f:	56                   	push   %esi
80106a50:	53                   	push   %ebx
80106a51:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106a54:	8b 45 08             	mov    0x8(%ebp),%eax
80106a57:	8b 40 30             	mov    0x30(%eax),%eax
80106a5a:	83 f8 40             	cmp    $0x40,%eax
80106a5d:	75 3f                	jne    80106a9e <trap+0x53>
    if(proc->killed)
80106a5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a65:	8b 40 2c             	mov    0x2c(%eax),%eax
80106a68:	85 c0                	test   %eax,%eax
80106a6a:	74 05                	je     80106a71 <trap+0x26>
      exit();
80106a6c:	e8 af dd ff ff       	call   80104820 <exit>
    proc->tf = tf;
80106a71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a77:	8b 55 08             	mov    0x8(%ebp),%edx
80106a7a:	89 50 20             	mov    %edx,0x20(%eax)
    syscall();
80106a7d:	e8 b8 ec ff ff       	call   8010573a <syscall>
    if(proc->killed)
80106a82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a88:	8b 40 2c             	mov    0x2c(%eax),%eax
80106a8b:	85 c0                	test   %eax,%eax
80106a8d:	74 0a                	je     80106a99 <trap+0x4e>
      exit();
80106a8f:	e8 8c dd ff ff       	call   80104820 <exit>
    return;
80106a94:	e9 2d 02 00 00       	jmp    80106cc6 <trap+0x27b>
80106a99:	e9 28 02 00 00       	jmp    80106cc6 <trap+0x27b>
  }

  switch(tf->trapno){
80106a9e:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa1:	8b 40 30             	mov    0x30(%eax),%eax
80106aa4:	83 e8 20             	sub    $0x20,%eax
80106aa7:	83 f8 1f             	cmp    $0x1f,%eax
80106aaa:	0f 87 bc 00 00 00    	ja     80106b6c <trap+0x121>
80106ab0:	8b 04 85 8c 8d 10 80 	mov    -0x7fef7274(,%eax,4),%eax
80106ab7:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106ab9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106abf:	0f b6 00             	movzbl (%eax),%eax
80106ac2:	84 c0                	test   %al,%al
80106ac4:	75 31                	jne    80106af7 <trap+0xac>
      acquire(&tickslock);
80106ac6:	c7 04 24 c0 4a 11 80 	movl   $0x80114ac0,(%esp)
80106acd:	e8 0b e6 ff ff       	call   801050dd <acquire>
      ticks++;
80106ad2:	a1 00 53 11 80       	mov    0x80115300,%eax
80106ad7:	83 c0 01             	add    $0x1,%eax
80106ada:	a3 00 53 11 80       	mov    %eax,0x80115300
      wakeup(&ticks);
80106adf:	c7 04 24 00 53 11 80 	movl   $0x80115300,(%esp)
80106ae6:	e8 03 e2 ff ff       	call   80104cee <wakeup>
      release(&tickslock);
80106aeb:	c7 04 24 c0 4a 11 80 	movl   $0x80114ac0,(%esp)
80106af2:	e8 48 e6 ff ff       	call   8010513f <release>
    }
    lapiceoi();
80106af7:	e8 8a c4 ff ff       	call   80102f86 <lapiceoi>
    break;
80106afc:	e9 41 01 00 00       	jmp    80106c42 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b01:	e8 8e bc ff ff       	call   80102794 <ideintr>
    lapiceoi();
80106b06:	e8 7b c4 ff ff       	call   80102f86 <lapiceoi>
    break;
80106b0b:	e9 32 01 00 00       	jmp    80106c42 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106b10:	e8 40 c2 ff ff       	call   80102d55 <kbdintr>
    lapiceoi();
80106b15:	e8 6c c4 ff ff       	call   80102f86 <lapiceoi>
    break;
80106b1a:	e9 23 01 00 00       	jmp    80106c42 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106b1f:	e8 97 03 00 00       	call   80106ebb <uartintr>
    lapiceoi();
80106b24:	e8 5d c4 ff ff       	call   80102f86 <lapiceoi>
    break;
80106b29:	e9 14 01 00 00       	jmp    80106c42 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106b31:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106b34:	8b 45 08             	mov    0x8(%ebp),%eax
80106b37:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b3b:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106b3e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b44:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b47:	0f b6 c0             	movzbl %al,%eax
80106b4a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b4e:	89 54 24 08          	mov    %edx,0x8(%esp)
80106b52:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b56:	c7 04 24 ec 8c 10 80 	movl   $0x80108cec,(%esp)
80106b5d:	e8 3e 98 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106b62:	e8 1f c4 ff ff       	call   80102f86 <lapiceoi>
    break;
80106b67:	e9 d6 00 00 00       	jmp    80106c42 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106b6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b72:	85 c0                	test   %eax,%eax
80106b74:	74 11                	je     80106b87 <trap+0x13c>
80106b76:	8b 45 08             	mov    0x8(%ebp),%eax
80106b79:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b7d:	0f b7 c0             	movzwl %ax,%eax
80106b80:	83 e0 03             	and    $0x3,%eax
80106b83:	85 c0                	test   %eax,%eax
80106b85:	75 46                	jne    80106bcd <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b87:	e8 1e fd ff ff       	call   801068aa <rcr2>
80106b8c:	8b 55 08             	mov    0x8(%ebp),%edx
80106b8f:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106b92:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106b99:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b9c:	0f b6 ca             	movzbl %dl,%ecx
80106b9f:	8b 55 08             	mov    0x8(%ebp),%edx
80106ba2:	8b 52 30             	mov    0x30(%edx),%edx
80106ba5:	89 44 24 10          	mov    %eax,0x10(%esp)
80106ba9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106bad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106bb1:	89 54 24 04          	mov    %edx,0x4(%esp)
80106bb5:	c7 04 24 10 8d 10 80 	movl   $0x80108d10,(%esp)
80106bbc:	e8 df 97 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106bc1:	c7 04 24 42 8d 10 80 	movl   $0x80108d42,(%esp)
80106bc8:	e8 6d 99 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106bcd:	e8 d8 fc ff ff       	call   801068aa <rcr2>
80106bd2:	89 c2                	mov    %eax,%edx
80106bd4:	8b 45 08             	mov    0x8(%ebp),%eax
80106bd7:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106bda:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106be0:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106be3:	0f b6 f0             	movzbl %al,%esi
80106be6:	8b 45 08             	mov    0x8(%ebp),%eax
80106be9:	8b 58 34             	mov    0x34(%eax),%ebx
80106bec:	8b 45 08             	mov    0x8(%ebp),%eax
80106bef:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106bf2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bf8:	83 c0 74             	add    $0x74,%eax
80106bfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106bfe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c04:	8b 40 10             	mov    0x10(%eax),%eax
80106c07:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106c0b:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106c0f:	89 74 24 14          	mov    %esi,0x14(%esp)
80106c13:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106c17:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c1b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106c1e:	89 74 24 08          	mov    %esi,0x8(%esp)
80106c22:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c26:	c7 04 24 48 8d 10 80 	movl   $0x80108d48,(%esp)
80106c2d:	e8 6e 97 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106c32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c38:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
80106c3f:	eb 01                	jmp    80106c42 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106c41:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106c42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c48:	85 c0                	test   %eax,%eax
80106c4a:	74 24                	je     80106c70 <trap+0x225>
80106c4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c52:	8b 40 2c             	mov    0x2c(%eax),%eax
80106c55:	85 c0                	test   %eax,%eax
80106c57:	74 17                	je     80106c70 <trap+0x225>
80106c59:	8b 45 08             	mov    0x8(%ebp),%eax
80106c5c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c60:	0f b7 c0             	movzwl %ax,%eax
80106c63:	83 e0 03             	and    $0x3,%eax
80106c66:	83 f8 03             	cmp    $0x3,%eax
80106c69:	75 05                	jne    80106c70 <trap+0x225>
    exit();
80106c6b:	e8 b0 db ff ff       	call   80104820 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106c70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c76:	85 c0                	test   %eax,%eax
80106c78:	74 1e                	je     80106c98 <trap+0x24d>
80106c7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c80:	8b 40 0c             	mov    0xc(%eax),%eax
80106c83:	83 f8 04             	cmp    $0x4,%eax
80106c86:	75 10                	jne    80106c98 <trap+0x24d>
80106c88:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8b:	8b 40 30             	mov    0x30(%eax),%eax
80106c8e:	83 f8 20             	cmp    $0x20,%eax
80106c91:	75 05                	jne    80106c98 <trap+0x24d>
    yield();
80106c93:	e8 09 df ff ff       	call   80104ba1 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106c98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c9e:	85 c0                	test   %eax,%eax
80106ca0:	74 24                	je     80106cc6 <trap+0x27b>
80106ca2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ca8:	8b 40 2c             	mov    0x2c(%eax),%eax
80106cab:	85 c0                	test   %eax,%eax
80106cad:	74 17                	je     80106cc6 <trap+0x27b>
80106caf:	8b 45 08             	mov    0x8(%ebp),%eax
80106cb2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cb6:	0f b7 c0             	movzwl %ax,%eax
80106cb9:	83 e0 03             	and    $0x3,%eax
80106cbc:	83 f8 03             	cmp    $0x3,%eax
80106cbf:	75 05                	jne    80106cc6 <trap+0x27b>
    exit();
80106cc1:	e8 5a db ff ff       	call   80104820 <exit>
}
80106cc6:	83 c4 3c             	add    $0x3c,%esp
80106cc9:	5b                   	pop    %ebx
80106cca:	5e                   	pop    %esi
80106ccb:	5f                   	pop    %edi
80106ccc:	5d                   	pop    %ebp
80106ccd:	c3                   	ret    

80106cce <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106cce:	55                   	push   %ebp
80106ccf:	89 e5                	mov    %esp,%ebp
80106cd1:	83 ec 14             	sub    $0x14,%esp
80106cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106cdb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106cdf:	89 c2                	mov    %eax,%edx
80106ce1:	ec                   	in     (%dx),%al
80106ce2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106ce5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106ce9:	c9                   	leave  
80106cea:	c3                   	ret    

80106ceb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106ceb:	55                   	push   %ebp
80106cec:	89 e5                	mov    %esp,%ebp
80106cee:	83 ec 08             	sub    $0x8,%esp
80106cf1:	8b 55 08             	mov    0x8(%ebp),%edx
80106cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
80106cf7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106cfb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106cfe:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106d02:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106d06:	ee                   	out    %al,(%dx)
}
80106d07:	c9                   	leave  
80106d08:	c3                   	ret    

80106d09 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106d09:	55                   	push   %ebp
80106d0a:	89 e5                	mov    %esp,%ebp
80106d0c:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106d0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d16:	00 
80106d17:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106d1e:	e8 c8 ff ff ff       	call   80106ceb <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106d23:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106d2a:	00 
80106d2b:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106d32:	e8 b4 ff ff ff       	call   80106ceb <outb>
  outb(COM1+0, 115200/9600);
80106d37:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106d3e:	00 
80106d3f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d46:	e8 a0 ff ff ff       	call   80106ceb <outb>
  outb(COM1+1, 0);
80106d4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d52:	00 
80106d53:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106d5a:	e8 8c ff ff ff       	call   80106ceb <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106d5f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106d66:	00 
80106d67:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106d6e:	e8 78 ff ff ff       	call   80106ceb <outb>
  outb(COM1+4, 0);
80106d73:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d7a:	00 
80106d7b:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106d82:	e8 64 ff ff ff       	call   80106ceb <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106d87:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106d8e:	00 
80106d8f:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106d96:	e8 50 ff ff ff       	call   80106ceb <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106d9b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106da2:	e8 27 ff ff ff       	call   80106cce <inb>
80106da7:	3c ff                	cmp    $0xff,%al
80106da9:	75 02                	jne    80106dad <uartinit+0xa4>
    return;
80106dab:	eb 6a                	jmp    80106e17 <uartinit+0x10e>
  uart = 1;
80106dad:	c7 05 6c b6 10 80 01 	movl   $0x1,0x8010b66c
80106db4:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106db7:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106dbe:	e8 0b ff ff ff       	call   80106cce <inb>
  inb(COM1+0);
80106dc3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106dca:	e8 ff fe ff ff       	call   80106cce <inb>
  picenable(IRQ_COM1);
80106dcf:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106dd6:	e8 80 d0 ff ff       	call   80103e5b <picenable>
  ioapicenable(IRQ_COM1, 0);
80106ddb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106de2:	00 
80106de3:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106dea:	e8 24 bc ff ff       	call   80102a13 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106def:	c7 45 f4 0c 8e 10 80 	movl   $0x80108e0c,-0xc(%ebp)
80106df6:	eb 15                	jmp    80106e0d <uartinit+0x104>
    uartputc(*p);
80106df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dfb:	0f b6 00             	movzbl (%eax),%eax
80106dfe:	0f be c0             	movsbl %al,%eax
80106e01:	89 04 24             	mov    %eax,(%esp)
80106e04:	e8 10 00 00 00       	call   80106e19 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e09:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e10:	0f b6 00             	movzbl (%eax),%eax
80106e13:	84 c0                	test   %al,%al
80106e15:	75 e1                	jne    80106df8 <uartinit+0xef>
    uartputc(*p);
}
80106e17:	c9                   	leave  
80106e18:	c3                   	ret    

80106e19 <uartputc>:

void
uartputc(int c)
{
80106e19:	55                   	push   %ebp
80106e1a:	89 e5                	mov    %esp,%ebp
80106e1c:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106e1f:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106e24:	85 c0                	test   %eax,%eax
80106e26:	75 02                	jne    80106e2a <uartputc+0x11>
    return;
80106e28:	eb 4b                	jmp    80106e75 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106e31:	eb 10                	jmp    80106e43 <uartputc+0x2a>
    microdelay(10);
80106e33:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106e3a:	e8 6c c1 ff ff       	call   80102fab <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e3f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e43:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106e47:	7f 16                	jg     80106e5f <uartputc+0x46>
80106e49:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e50:	e8 79 fe ff ff       	call   80106cce <inb>
80106e55:	0f b6 c0             	movzbl %al,%eax
80106e58:	83 e0 20             	and    $0x20,%eax
80106e5b:	85 c0                	test   %eax,%eax
80106e5d:	74 d4                	je     80106e33 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106e5f:	8b 45 08             	mov    0x8(%ebp),%eax
80106e62:	0f b6 c0             	movzbl %al,%eax
80106e65:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e69:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e70:	e8 76 fe ff ff       	call   80106ceb <outb>
}
80106e75:	c9                   	leave  
80106e76:	c3                   	ret    

80106e77 <uartgetc>:

static int
uartgetc(void)
{
80106e77:	55                   	push   %ebp
80106e78:	89 e5                	mov    %esp,%ebp
80106e7a:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106e7d:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106e82:	85 c0                	test   %eax,%eax
80106e84:	75 07                	jne    80106e8d <uartgetc+0x16>
    return -1;
80106e86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e8b:	eb 2c                	jmp    80106eb9 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106e8d:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e94:	e8 35 fe ff ff       	call   80106cce <inb>
80106e99:	0f b6 c0             	movzbl %al,%eax
80106e9c:	83 e0 01             	and    $0x1,%eax
80106e9f:	85 c0                	test   %eax,%eax
80106ea1:	75 07                	jne    80106eaa <uartgetc+0x33>
    return -1;
80106ea3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ea8:	eb 0f                	jmp    80106eb9 <uartgetc+0x42>
  return inb(COM1+0);
80106eaa:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106eb1:	e8 18 fe ff ff       	call   80106cce <inb>
80106eb6:	0f b6 c0             	movzbl %al,%eax
}
80106eb9:	c9                   	leave  
80106eba:	c3                   	ret    

80106ebb <uartintr>:

void
uartintr(void)
{
80106ebb:	55                   	push   %ebp
80106ebc:	89 e5                	mov    %esp,%ebp
80106ebe:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106ec1:	c7 04 24 77 6e 10 80 	movl   $0x80106e77,(%esp)
80106ec8:	e8 fb 98 ff ff       	call   801007c8 <consoleintr>
}
80106ecd:	c9                   	leave  
80106ece:	c3                   	ret    

80106ecf <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $0
80106ed1:	6a 00                	push   $0x0
  jmp alltraps
80106ed3:	e9 7e f9 ff ff       	jmp    80106856 <alltraps>

80106ed8 <vector1>:
.globl vector1
vector1:
  pushl $0
80106ed8:	6a 00                	push   $0x0
  pushl $1
80106eda:	6a 01                	push   $0x1
  jmp alltraps
80106edc:	e9 75 f9 ff ff       	jmp    80106856 <alltraps>

80106ee1 <vector2>:
.globl vector2
vector2:
  pushl $0
80106ee1:	6a 00                	push   $0x0
  pushl $2
80106ee3:	6a 02                	push   $0x2
  jmp alltraps
80106ee5:	e9 6c f9 ff ff       	jmp    80106856 <alltraps>

80106eea <vector3>:
.globl vector3
vector3:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $3
80106eec:	6a 03                	push   $0x3
  jmp alltraps
80106eee:	e9 63 f9 ff ff       	jmp    80106856 <alltraps>

80106ef3 <vector4>:
.globl vector4
vector4:
  pushl $0
80106ef3:	6a 00                	push   $0x0
  pushl $4
80106ef5:	6a 04                	push   $0x4
  jmp alltraps
80106ef7:	e9 5a f9 ff ff       	jmp    80106856 <alltraps>

80106efc <vector5>:
.globl vector5
vector5:
  pushl $0
80106efc:	6a 00                	push   $0x0
  pushl $5
80106efe:	6a 05                	push   $0x5
  jmp alltraps
80106f00:	e9 51 f9 ff ff       	jmp    80106856 <alltraps>

80106f05 <vector6>:
.globl vector6
vector6:
  pushl $0
80106f05:	6a 00                	push   $0x0
  pushl $6
80106f07:	6a 06                	push   $0x6
  jmp alltraps
80106f09:	e9 48 f9 ff ff       	jmp    80106856 <alltraps>

80106f0e <vector7>:
.globl vector7
vector7:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $7
80106f10:	6a 07                	push   $0x7
  jmp alltraps
80106f12:	e9 3f f9 ff ff       	jmp    80106856 <alltraps>

80106f17 <vector8>:
.globl vector8
vector8:
  pushl $8
80106f17:	6a 08                	push   $0x8
  jmp alltraps
80106f19:	e9 38 f9 ff ff       	jmp    80106856 <alltraps>

80106f1e <vector9>:
.globl vector9
vector9:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $9
80106f20:	6a 09                	push   $0x9
  jmp alltraps
80106f22:	e9 2f f9 ff ff       	jmp    80106856 <alltraps>

80106f27 <vector10>:
.globl vector10
vector10:
  pushl $10
80106f27:	6a 0a                	push   $0xa
  jmp alltraps
80106f29:	e9 28 f9 ff ff       	jmp    80106856 <alltraps>

80106f2e <vector11>:
.globl vector11
vector11:
  pushl $11
80106f2e:	6a 0b                	push   $0xb
  jmp alltraps
80106f30:	e9 21 f9 ff ff       	jmp    80106856 <alltraps>

80106f35 <vector12>:
.globl vector12
vector12:
  pushl $12
80106f35:	6a 0c                	push   $0xc
  jmp alltraps
80106f37:	e9 1a f9 ff ff       	jmp    80106856 <alltraps>

80106f3c <vector13>:
.globl vector13
vector13:
  pushl $13
80106f3c:	6a 0d                	push   $0xd
  jmp alltraps
80106f3e:	e9 13 f9 ff ff       	jmp    80106856 <alltraps>

80106f43 <vector14>:
.globl vector14
vector14:
  pushl $14
80106f43:	6a 0e                	push   $0xe
  jmp alltraps
80106f45:	e9 0c f9 ff ff       	jmp    80106856 <alltraps>

80106f4a <vector15>:
.globl vector15
vector15:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $15
80106f4c:	6a 0f                	push   $0xf
  jmp alltraps
80106f4e:	e9 03 f9 ff ff       	jmp    80106856 <alltraps>

80106f53 <vector16>:
.globl vector16
vector16:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $16
80106f55:	6a 10                	push   $0x10
  jmp alltraps
80106f57:	e9 fa f8 ff ff       	jmp    80106856 <alltraps>

80106f5c <vector17>:
.globl vector17
vector17:
  pushl $17
80106f5c:	6a 11                	push   $0x11
  jmp alltraps
80106f5e:	e9 f3 f8 ff ff       	jmp    80106856 <alltraps>

80106f63 <vector18>:
.globl vector18
vector18:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $18
80106f65:	6a 12                	push   $0x12
  jmp alltraps
80106f67:	e9 ea f8 ff ff       	jmp    80106856 <alltraps>

80106f6c <vector19>:
.globl vector19
vector19:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $19
80106f6e:	6a 13                	push   $0x13
  jmp alltraps
80106f70:	e9 e1 f8 ff ff       	jmp    80106856 <alltraps>

80106f75 <vector20>:
.globl vector20
vector20:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $20
80106f77:	6a 14                	push   $0x14
  jmp alltraps
80106f79:	e9 d8 f8 ff ff       	jmp    80106856 <alltraps>

80106f7e <vector21>:
.globl vector21
vector21:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $21
80106f80:	6a 15                	push   $0x15
  jmp alltraps
80106f82:	e9 cf f8 ff ff       	jmp    80106856 <alltraps>

80106f87 <vector22>:
.globl vector22
vector22:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $22
80106f89:	6a 16                	push   $0x16
  jmp alltraps
80106f8b:	e9 c6 f8 ff ff       	jmp    80106856 <alltraps>

80106f90 <vector23>:
.globl vector23
vector23:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $23
80106f92:	6a 17                	push   $0x17
  jmp alltraps
80106f94:	e9 bd f8 ff ff       	jmp    80106856 <alltraps>

80106f99 <vector24>:
.globl vector24
vector24:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $24
80106f9b:	6a 18                	push   $0x18
  jmp alltraps
80106f9d:	e9 b4 f8 ff ff       	jmp    80106856 <alltraps>

80106fa2 <vector25>:
.globl vector25
vector25:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $25
80106fa4:	6a 19                	push   $0x19
  jmp alltraps
80106fa6:	e9 ab f8 ff ff       	jmp    80106856 <alltraps>

80106fab <vector26>:
.globl vector26
vector26:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $26
80106fad:	6a 1a                	push   $0x1a
  jmp alltraps
80106faf:	e9 a2 f8 ff ff       	jmp    80106856 <alltraps>

80106fb4 <vector27>:
.globl vector27
vector27:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $27
80106fb6:	6a 1b                	push   $0x1b
  jmp alltraps
80106fb8:	e9 99 f8 ff ff       	jmp    80106856 <alltraps>

80106fbd <vector28>:
.globl vector28
vector28:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $28
80106fbf:	6a 1c                	push   $0x1c
  jmp alltraps
80106fc1:	e9 90 f8 ff ff       	jmp    80106856 <alltraps>

80106fc6 <vector29>:
.globl vector29
vector29:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $29
80106fc8:	6a 1d                	push   $0x1d
  jmp alltraps
80106fca:	e9 87 f8 ff ff       	jmp    80106856 <alltraps>

80106fcf <vector30>:
.globl vector30
vector30:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $30
80106fd1:	6a 1e                	push   $0x1e
  jmp alltraps
80106fd3:	e9 7e f8 ff ff       	jmp    80106856 <alltraps>

80106fd8 <vector31>:
.globl vector31
vector31:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $31
80106fda:	6a 1f                	push   $0x1f
  jmp alltraps
80106fdc:	e9 75 f8 ff ff       	jmp    80106856 <alltraps>

80106fe1 <vector32>:
.globl vector32
vector32:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $32
80106fe3:	6a 20                	push   $0x20
  jmp alltraps
80106fe5:	e9 6c f8 ff ff       	jmp    80106856 <alltraps>

80106fea <vector33>:
.globl vector33
vector33:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $33
80106fec:	6a 21                	push   $0x21
  jmp alltraps
80106fee:	e9 63 f8 ff ff       	jmp    80106856 <alltraps>

80106ff3 <vector34>:
.globl vector34
vector34:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $34
80106ff5:	6a 22                	push   $0x22
  jmp alltraps
80106ff7:	e9 5a f8 ff ff       	jmp    80106856 <alltraps>

80106ffc <vector35>:
.globl vector35
vector35:
  pushl $0
80106ffc:	6a 00                	push   $0x0
  pushl $35
80106ffe:	6a 23                	push   $0x23
  jmp alltraps
80107000:	e9 51 f8 ff ff       	jmp    80106856 <alltraps>

80107005 <vector36>:
.globl vector36
vector36:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $36
80107007:	6a 24                	push   $0x24
  jmp alltraps
80107009:	e9 48 f8 ff ff       	jmp    80106856 <alltraps>

8010700e <vector37>:
.globl vector37
vector37:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $37
80107010:	6a 25                	push   $0x25
  jmp alltraps
80107012:	e9 3f f8 ff ff       	jmp    80106856 <alltraps>

80107017 <vector38>:
.globl vector38
vector38:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $38
80107019:	6a 26                	push   $0x26
  jmp alltraps
8010701b:	e9 36 f8 ff ff       	jmp    80106856 <alltraps>

80107020 <vector39>:
.globl vector39
vector39:
  pushl $0
80107020:	6a 00                	push   $0x0
  pushl $39
80107022:	6a 27                	push   $0x27
  jmp alltraps
80107024:	e9 2d f8 ff ff       	jmp    80106856 <alltraps>

80107029 <vector40>:
.globl vector40
vector40:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $40
8010702b:	6a 28                	push   $0x28
  jmp alltraps
8010702d:	e9 24 f8 ff ff       	jmp    80106856 <alltraps>

80107032 <vector41>:
.globl vector41
vector41:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $41
80107034:	6a 29                	push   $0x29
  jmp alltraps
80107036:	e9 1b f8 ff ff       	jmp    80106856 <alltraps>

8010703b <vector42>:
.globl vector42
vector42:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $42
8010703d:	6a 2a                	push   $0x2a
  jmp alltraps
8010703f:	e9 12 f8 ff ff       	jmp    80106856 <alltraps>

80107044 <vector43>:
.globl vector43
vector43:
  pushl $0
80107044:	6a 00                	push   $0x0
  pushl $43
80107046:	6a 2b                	push   $0x2b
  jmp alltraps
80107048:	e9 09 f8 ff ff       	jmp    80106856 <alltraps>

8010704d <vector44>:
.globl vector44
vector44:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $44
8010704f:	6a 2c                	push   $0x2c
  jmp alltraps
80107051:	e9 00 f8 ff ff       	jmp    80106856 <alltraps>

80107056 <vector45>:
.globl vector45
vector45:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $45
80107058:	6a 2d                	push   $0x2d
  jmp alltraps
8010705a:	e9 f7 f7 ff ff       	jmp    80106856 <alltraps>

8010705f <vector46>:
.globl vector46
vector46:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $46
80107061:	6a 2e                	push   $0x2e
  jmp alltraps
80107063:	e9 ee f7 ff ff       	jmp    80106856 <alltraps>

80107068 <vector47>:
.globl vector47
vector47:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $47
8010706a:	6a 2f                	push   $0x2f
  jmp alltraps
8010706c:	e9 e5 f7 ff ff       	jmp    80106856 <alltraps>

80107071 <vector48>:
.globl vector48
vector48:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $48
80107073:	6a 30                	push   $0x30
  jmp alltraps
80107075:	e9 dc f7 ff ff       	jmp    80106856 <alltraps>

8010707a <vector49>:
.globl vector49
vector49:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $49
8010707c:	6a 31                	push   $0x31
  jmp alltraps
8010707e:	e9 d3 f7 ff ff       	jmp    80106856 <alltraps>

80107083 <vector50>:
.globl vector50
vector50:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $50
80107085:	6a 32                	push   $0x32
  jmp alltraps
80107087:	e9 ca f7 ff ff       	jmp    80106856 <alltraps>

8010708c <vector51>:
.globl vector51
vector51:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $51
8010708e:	6a 33                	push   $0x33
  jmp alltraps
80107090:	e9 c1 f7 ff ff       	jmp    80106856 <alltraps>

80107095 <vector52>:
.globl vector52
vector52:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $52
80107097:	6a 34                	push   $0x34
  jmp alltraps
80107099:	e9 b8 f7 ff ff       	jmp    80106856 <alltraps>

8010709e <vector53>:
.globl vector53
vector53:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $53
801070a0:	6a 35                	push   $0x35
  jmp alltraps
801070a2:	e9 af f7 ff ff       	jmp    80106856 <alltraps>

801070a7 <vector54>:
.globl vector54
vector54:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $54
801070a9:	6a 36                	push   $0x36
  jmp alltraps
801070ab:	e9 a6 f7 ff ff       	jmp    80106856 <alltraps>

801070b0 <vector55>:
.globl vector55
vector55:
  pushl $0
801070b0:	6a 00                	push   $0x0
  pushl $55
801070b2:	6a 37                	push   $0x37
  jmp alltraps
801070b4:	e9 9d f7 ff ff       	jmp    80106856 <alltraps>

801070b9 <vector56>:
.globl vector56
vector56:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $56
801070bb:	6a 38                	push   $0x38
  jmp alltraps
801070bd:	e9 94 f7 ff ff       	jmp    80106856 <alltraps>

801070c2 <vector57>:
.globl vector57
vector57:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $57
801070c4:	6a 39                	push   $0x39
  jmp alltraps
801070c6:	e9 8b f7 ff ff       	jmp    80106856 <alltraps>

801070cb <vector58>:
.globl vector58
vector58:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $58
801070cd:	6a 3a                	push   $0x3a
  jmp alltraps
801070cf:	e9 82 f7 ff ff       	jmp    80106856 <alltraps>

801070d4 <vector59>:
.globl vector59
vector59:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $59
801070d6:	6a 3b                	push   $0x3b
  jmp alltraps
801070d8:	e9 79 f7 ff ff       	jmp    80106856 <alltraps>

801070dd <vector60>:
.globl vector60
vector60:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $60
801070df:	6a 3c                	push   $0x3c
  jmp alltraps
801070e1:	e9 70 f7 ff ff       	jmp    80106856 <alltraps>

801070e6 <vector61>:
.globl vector61
vector61:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $61
801070e8:	6a 3d                	push   $0x3d
  jmp alltraps
801070ea:	e9 67 f7 ff ff       	jmp    80106856 <alltraps>

801070ef <vector62>:
.globl vector62
vector62:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $62
801070f1:	6a 3e                	push   $0x3e
  jmp alltraps
801070f3:	e9 5e f7 ff ff       	jmp    80106856 <alltraps>

801070f8 <vector63>:
.globl vector63
vector63:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $63
801070fa:	6a 3f                	push   $0x3f
  jmp alltraps
801070fc:	e9 55 f7 ff ff       	jmp    80106856 <alltraps>

80107101 <vector64>:
.globl vector64
vector64:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $64
80107103:	6a 40                	push   $0x40
  jmp alltraps
80107105:	e9 4c f7 ff ff       	jmp    80106856 <alltraps>

8010710a <vector65>:
.globl vector65
vector65:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $65
8010710c:	6a 41                	push   $0x41
  jmp alltraps
8010710e:	e9 43 f7 ff ff       	jmp    80106856 <alltraps>

80107113 <vector66>:
.globl vector66
vector66:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $66
80107115:	6a 42                	push   $0x42
  jmp alltraps
80107117:	e9 3a f7 ff ff       	jmp    80106856 <alltraps>

8010711c <vector67>:
.globl vector67
vector67:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $67
8010711e:	6a 43                	push   $0x43
  jmp alltraps
80107120:	e9 31 f7 ff ff       	jmp    80106856 <alltraps>

80107125 <vector68>:
.globl vector68
vector68:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $68
80107127:	6a 44                	push   $0x44
  jmp alltraps
80107129:	e9 28 f7 ff ff       	jmp    80106856 <alltraps>

8010712e <vector69>:
.globl vector69
vector69:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $69
80107130:	6a 45                	push   $0x45
  jmp alltraps
80107132:	e9 1f f7 ff ff       	jmp    80106856 <alltraps>

80107137 <vector70>:
.globl vector70
vector70:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $70
80107139:	6a 46                	push   $0x46
  jmp alltraps
8010713b:	e9 16 f7 ff ff       	jmp    80106856 <alltraps>

80107140 <vector71>:
.globl vector71
vector71:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $71
80107142:	6a 47                	push   $0x47
  jmp alltraps
80107144:	e9 0d f7 ff ff       	jmp    80106856 <alltraps>

80107149 <vector72>:
.globl vector72
vector72:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $72
8010714b:	6a 48                	push   $0x48
  jmp alltraps
8010714d:	e9 04 f7 ff ff       	jmp    80106856 <alltraps>

80107152 <vector73>:
.globl vector73
vector73:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $73
80107154:	6a 49                	push   $0x49
  jmp alltraps
80107156:	e9 fb f6 ff ff       	jmp    80106856 <alltraps>

8010715b <vector74>:
.globl vector74
vector74:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $74
8010715d:	6a 4a                	push   $0x4a
  jmp alltraps
8010715f:	e9 f2 f6 ff ff       	jmp    80106856 <alltraps>

80107164 <vector75>:
.globl vector75
vector75:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $75
80107166:	6a 4b                	push   $0x4b
  jmp alltraps
80107168:	e9 e9 f6 ff ff       	jmp    80106856 <alltraps>

8010716d <vector76>:
.globl vector76
vector76:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $76
8010716f:	6a 4c                	push   $0x4c
  jmp alltraps
80107171:	e9 e0 f6 ff ff       	jmp    80106856 <alltraps>

80107176 <vector77>:
.globl vector77
vector77:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $77
80107178:	6a 4d                	push   $0x4d
  jmp alltraps
8010717a:	e9 d7 f6 ff ff       	jmp    80106856 <alltraps>

8010717f <vector78>:
.globl vector78
vector78:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $78
80107181:	6a 4e                	push   $0x4e
  jmp alltraps
80107183:	e9 ce f6 ff ff       	jmp    80106856 <alltraps>

80107188 <vector79>:
.globl vector79
vector79:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $79
8010718a:	6a 4f                	push   $0x4f
  jmp alltraps
8010718c:	e9 c5 f6 ff ff       	jmp    80106856 <alltraps>

80107191 <vector80>:
.globl vector80
vector80:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $80
80107193:	6a 50                	push   $0x50
  jmp alltraps
80107195:	e9 bc f6 ff ff       	jmp    80106856 <alltraps>

8010719a <vector81>:
.globl vector81
vector81:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $81
8010719c:	6a 51                	push   $0x51
  jmp alltraps
8010719e:	e9 b3 f6 ff ff       	jmp    80106856 <alltraps>

801071a3 <vector82>:
.globl vector82
vector82:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $82
801071a5:	6a 52                	push   $0x52
  jmp alltraps
801071a7:	e9 aa f6 ff ff       	jmp    80106856 <alltraps>

801071ac <vector83>:
.globl vector83
vector83:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $83
801071ae:	6a 53                	push   $0x53
  jmp alltraps
801071b0:	e9 a1 f6 ff ff       	jmp    80106856 <alltraps>

801071b5 <vector84>:
.globl vector84
vector84:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $84
801071b7:	6a 54                	push   $0x54
  jmp alltraps
801071b9:	e9 98 f6 ff ff       	jmp    80106856 <alltraps>

801071be <vector85>:
.globl vector85
vector85:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $85
801071c0:	6a 55                	push   $0x55
  jmp alltraps
801071c2:	e9 8f f6 ff ff       	jmp    80106856 <alltraps>

801071c7 <vector86>:
.globl vector86
vector86:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $86
801071c9:	6a 56                	push   $0x56
  jmp alltraps
801071cb:	e9 86 f6 ff ff       	jmp    80106856 <alltraps>

801071d0 <vector87>:
.globl vector87
vector87:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $87
801071d2:	6a 57                	push   $0x57
  jmp alltraps
801071d4:	e9 7d f6 ff ff       	jmp    80106856 <alltraps>

801071d9 <vector88>:
.globl vector88
vector88:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $88
801071db:	6a 58                	push   $0x58
  jmp alltraps
801071dd:	e9 74 f6 ff ff       	jmp    80106856 <alltraps>

801071e2 <vector89>:
.globl vector89
vector89:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $89
801071e4:	6a 59                	push   $0x59
  jmp alltraps
801071e6:	e9 6b f6 ff ff       	jmp    80106856 <alltraps>

801071eb <vector90>:
.globl vector90
vector90:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $90
801071ed:	6a 5a                	push   $0x5a
  jmp alltraps
801071ef:	e9 62 f6 ff ff       	jmp    80106856 <alltraps>

801071f4 <vector91>:
.globl vector91
vector91:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $91
801071f6:	6a 5b                	push   $0x5b
  jmp alltraps
801071f8:	e9 59 f6 ff ff       	jmp    80106856 <alltraps>

801071fd <vector92>:
.globl vector92
vector92:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $92
801071ff:	6a 5c                	push   $0x5c
  jmp alltraps
80107201:	e9 50 f6 ff ff       	jmp    80106856 <alltraps>

80107206 <vector93>:
.globl vector93
vector93:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $93
80107208:	6a 5d                	push   $0x5d
  jmp alltraps
8010720a:	e9 47 f6 ff ff       	jmp    80106856 <alltraps>

8010720f <vector94>:
.globl vector94
vector94:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $94
80107211:	6a 5e                	push   $0x5e
  jmp alltraps
80107213:	e9 3e f6 ff ff       	jmp    80106856 <alltraps>

80107218 <vector95>:
.globl vector95
vector95:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $95
8010721a:	6a 5f                	push   $0x5f
  jmp alltraps
8010721c:	e9 35 f6 ff ff       	jmp    80106856 <alltraps>

80107221 <vector96>:
.globl vector96
vector96:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $96
80107223:	6a 60                	push   $0x60
  jmp alltraps
80107225:	e9 2c f6 ff ff       	jmp    80106856 <alltraps>

8010722a <vector97>:
.globl vector97
vector97:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $97
8010722c:	6a 61                	push   $0x61
  jmp alltraps
8010722e:	e9 23 f6 ff ff       	jmp    80106856 <alltraps>

80107233 <vector98>:
.globl vector98
vector98:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $98
80107235:	6a 62                	push   $0x62
  jmp alltraps
80107237:	e9 1a f6 ff ff       	jmp    80106856 <alltraps>

8010723c <vector99>:
.globl vector99
vector99:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $99
8010723e:	6a 63                	push   $0x63
  jmp alltraps
80107240:	e9 11 f6 ff ff       	jmp    80106856 <alltraps>

80107245 <vector100>:
.globl vector100
vector100:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $100
80107247:	6a 64                	push   $0x64
  jmp alltraps
80107249:	e9 08 f6 ff ff       	jmp    80106856 <alltraps>

8010724e <vector101>:
.globl vector101
vector101:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $101
80107250:	6a 65                	push   $0x65
  jmp alltraps
80107252:	e9 ff f5 ff ff       	jmp    80106856 <alltraps>

80107257 <vector102>:
.globl vector102
vector102:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $102
80107259:	6a 66                	push   $0x66
  jmp alltraps
8010725b:	e9 f6 f5 ff ff       	jmp    80106856 <alltraps>

80107260 <vector103>:
.globl vector103
vector103:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $103
80107262:	6a 67                	push   $0x67
  jmp alltraps
80107264:	e9 ed f5 ff ff       	jmp    80106856 <alltraps>

80107269 <vector104>:
.globl vector104
vector104:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $104
8010726b:	6a 68                	push   $0x68
  jmp alltraps
8010726d:	e9 e4 f5 ff ff       	jmp    80106856 <alltraps>

80107272 <vector105>:
.globl vector105
vector105:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $105
80107274:	6a 69                	push   $0x69
  jmp alltraps
80107276:	e9 db f5 ff ff       	jmp    80106856 <alltraps>

8010727b <vector106>:
.globl vector106
vector106:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $106
8010727d:	6a 6a                	push   $0x6a
  jmp alltraps
8010727f:	e9 d2 f5 ff ff       	jmp    80106856 <alltraps>

80107284 <vector107>:
.globl vector107
vector107:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $107
80107286:	6a 6b                	push   $0x6b
  jmp alltraps
80107288:	e9 c9 f5 ff ff       	jmp    80106856 <alltraps>

8010728d <vector108>:
.globl vector108
vector108:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $108
8010728f:	6a 6c                	push   $0x6c
  jmp alltraps
80107291:	e9 c0 f5 ff ff       	jmp    80106856 <alltraps>

80107296 <vector109>:
.globl vector109
vector109:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $109
80107298:	6a 6d                	push   $0x6d
  jmp alltraps
8010729a:	e9 b7 f5 ff ff       	jmp    80106856 <alltraps>

8010729f <vector110>:
.globl vector110
vector110:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $110
801072a1:	6a 6e                	push   $0x6e
  jmp alltraps
801072a3:	e9 ae f5 ff ff       	jmp    80106856 <alltraps>

801072a8 <vector111>:
.globl vector111
vector111:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $111
801072aa:	6a 6f                	push   $0x6f
  jmp alltraps
801072ac:	e9 a5 f5 ff ff       	jmp    80106856 <alltraps>

801072b1 <vector112>:
.globl vector112
vector112:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $112
801072b3:	6a 70                	push   $0x70
  jmp alltraps
801072b5:	e9 9c f5 ff ff       	jmp    80106856 <alltraps>

801072ba <vector113>:
.globl vector113
vector113:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $113
801072bc:	6a 71                	push   $0x71
  jmp alltraps
801072be:	e9 93 f5 ff ff       	jmp    80106856 <alltraps>

801072c3 <vector114>:
.globl vector114
vector114:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $114
801072c5:	6a 72                	push   $0x72
  jmp alltraps
801072c7:	e9 8a f5 ff ff       	jmp    80106856 <alltraps>

801072cc <vector115>:
.globl vector115
vector115:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $115
801072ce:	6a 73                	push   $0x73
  jmp alltraps
801072d0:	e9 81 f5 ff ff       	jmp    80106856 <alltraps>

801072d5 <vector116>:
.globl vector116
vector116:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $116
801072d7:	6a 74                	push   $0x74
  jmp alltraps
801072d9:	e9 78 f5 ff ff       	jmp    80106856 <alltraps>

801072de <vector117>:
.globl vector117
vector117:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $117
801072e0:	6a 75                	push   $0x75
  jmp alltraps
801072e2:	e9 6f f5 ff ff       	jmp    80106856 <alltraps>

801072e7 <vector118>:
.globl vector118
vector118:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $118
801072e9:	6a 76                	push   $0x76
  jmp alltraps
801072eb:	e9 66 f5 ff ff       	jmp    80106856 <alltraps>

801072f0 <vector119>:
.globl vector119
vector119:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $119
801072f2:	6a 77                	push   $0x77
  jmp alltraps
801072f4:	e9 5d f5 ff ff       	jmp    80106856 <alltraps>

801072f9 <vector120>:
.globl vector120
vector120:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $120
801072fb:	6a 78                	push   $0x78
  jmp alltraps
801072fd:	e9 54 f5 ff ff       	jmp    80106856 <alltraps>

80107302 <vector121>:
.globl vector121
vector121:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $121
80107304:	6a 79                	push   $0x79
  jmp alltraps
80107306:	e9 4b f5 ff ff       	jmp    80106856 <alltraps>

8010730b <vector122>:
.globl vector122
vector122:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $122
8010730d:	6a 7a                	push   $0x7a
  jmp alltraps
8010730f:	e9 42 f5 ff ff       	jmp    80106856 <alltraps>

80107314 <vector123>:
.globl vector123
vector123:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $123
80107316:	6a 7b                	push   $0x7b
  jmp alltraps
80107318:	e9 39 f5 ff ff       	jmp    80106856 <alltraps>

8010731d <vector124>:
.globl vector124
vector124:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $124
8010731f:	6a 7c                	push   $0x7c
  jmp alltraps
80107321:	e9 30 f5 ff ff       	jmp    80106856 <alltraps>

80107326 <vector125>:
.globl vector125
vector125:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $125
80107328:	6a 7d                	push   $0x7d
  jmp alltraps
8010732a:	e9 27 f5 ff ff       	jmp    80106856 <alltraps>

8010732f <vector126>:
.globl vector126
vector126:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $126
80107331:	6a 7e                	push   $0x7e
  jmp alltraps
80107333:	e9 1e f5 ff ff       	jmp    80106856 <alltraps>

80107338 <vector127>:
.globl vector127
vector127:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $127
8010733a:	6a 7f                	push   $0x7f
  jmp alltraps
8010733c:	e9 15 f5 ff ff       	jmp    80106856 <alltraps>

80107341 <vector128>:
.globl vector128
vector128:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $128
80107343:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107348:	e9 09 f5 ff ff       	jmp    80106856 <alltraps>

8010734d <vector129>:
.globl vector129
vector129:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $129
8010734f:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107354:	e9 fd f4 ff ff       	jmp    80106856 <alltraps>

80107359 <vector130>:
.globl vector130
vector130:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $130
8010735b:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107360:	e9 f1 f4 ff ff       	jmp    80106856 <alltraps>

80107365 <vector131>:
.globl vector131
vector131:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $131
80107367:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010736c:	e9 e5 f4 ff ff       	jmp    80106856 <alltraps>

80107371 <vector132>:
.globl vector132
vector132:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $132
80107373:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107378:	e9 d9 f4 ff ff       	jmp    80106856 <alltraps>

8010737d <vector133>:
.globl vector133
vector133:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $133
8010737f:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107384:	e9 cd f4 ff ff       	jmp    80106856 <alltraps>

80107389 <vector134>:
.globl vector134
vector134:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $134
8010738b:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107390:	e9 c1 f4 ff ff       	jmp    80106856 <alltraps>

80107395 <vector135>:
.globl vector135
vector135:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $135
80107397:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010739c:	e9 b5 f4 ff ff       	jmp    80106856 <alltraps>

801073a1 <vector136>:
.globl vector136
vector136:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $136
801073a3:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801073a8:	e9 a9 f4 ff ff       	jmp    80106856 <alltraps>

801073ad <vector137>:
.globl vector137
vector137:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $137
801073af:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801073b4:	e9 9d f4 ff ff       	jmp    80106856 <alltraps>

801073b9 <vector138>:
.globl vector138
vector138:
  pushl $0
801073b9:	6a 00                	push   $0x0
  pushl $138
801073bb:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801073c0:	e9 91 f4 ff ff       	jmp    80106856 <alltraps>

801073c5 <vector139>:
.globl vector139
vector139:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $139
801073c7:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801073cc:	e9 85 f4 ff ff       	jmp    80106856 <alltraps>

801073d1 <vector140>:
.globl vector140
vector140:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $140
801073d3:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801073d8:	e9 79 f4 ff ff       	jmp    80106856 <alltraps>

801073dd <vector141>:
.globl vector141
vector141:
  pushl $0
801073dd:	6a 00                	push   $0x0
  pushl $141
801073df:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801073e4:	e9 6d f4 ff ff       	jmp    80106856 <alltraps>

801073e9 <vector142>:
.globl vector142
vector142:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $142
801073eb:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801073f0:	e9 61 f4 ff ff       	jmp    80106856 <alltraps>

801073f5 <vector143>:
.globl vector143
vector143:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $143
801073f7:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801073fc:	e9 55 f4 ff ff       	jmp    80106856 <alltraps>

80107401 <vector144>:
.globl vector144
vector144:
  pushl $0
80107401:	6a 00                	push   $0x0
  pushl $144
80107403:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107408:	e9 49 f4 ff ff       	jmp    80106856 <alltraps>

8010740d <vector145>:
.globl vector145
vector145:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $145
8010740f:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107414:	e9 3d f4 ff ff       	jmp    80106856 <alltraps>

80107419 <vector146>:
.globl vector146
vector146:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $146
8010741b:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107420:	e9 31 f4 ff ff       	jmp    80106856 <alltraps>

80107425 <vector147>:
.globl vector147
vector147:
  pushl $0
80107425:	6a 00                	push   $0x0
  pushl $147
80107427:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010742c:	e9 25 f4 ff ff       	jmp    80106856 <alltraps>

80107431 <vector148>:
.globl vector148
vector148:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $148
80107433:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107438:	e9 19 f4 ff ff       	jmp    80106856 <alltraps>

8010743d <vector149>:
.globl vector149
vector149:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $149
8010743f:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107444:	e9 0d f4 ff ff       	jmp    80106856 <alltraps>

80107449 <vector150>:
.globl vector150
vector150:
  pushl $0
80107449:	6a 00                	push   $0x0
  pushl $150
8010744b:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107450:	e9 01 f4 ff ff       	jmp    80106856 <alltraps>

80107455 <vector151>:
.globl vector151
vector151:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $151
80107457:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010745c:	e9 f5 f3 ff ff       	jmp    80106856 <alltraps>

80107461 <vector152>:
.globl vector152
vector152:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $152
80107463:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107468:	e9 e9 f3 ff ff       	jmp    80106856 <alltraps>

8010746d <vector153>:
.globl vector153
vector153:
  pushl $0
8010746d:	6a 00                	push   $0x0
  pushl $153
8010746f:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107474:	e9 dd f3 ff ff       	jmp    80106856 <alltraps>

80107479 <vector154>:
.globl vector154
vector154:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $154
8010747b:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107480:	e9 d1 f3 ff ff       	jmp    80106856 <alltraps>

80107485 <vector155>:
.globl vector155
vector155:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $155
80107487:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010748c:	e9 c5 f3 ff ff       	jmp    80106856 <alltraps>

80107491 <vector156>:
.globl vector156
vector156:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $156
80107493:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107498:	e9 b9 f3 ff ff       	jmp    80106856 <alltraps>

8010749d <vector157>:
.globl vector157
vector157:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $157
8010749f:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801074a4:	e9 ad f3 ff ff       	jmp    80106856 <alltraps>

801074a9 <vector158>:
.globl vector158
vector158:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $158
801074ab:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801074b0:	e9 a1 f3 ff ff       	jmp    80106856 <alltraps>

801074b5 <vector159>:
.globl vector159
vector159:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $159
801074b7:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801074bc:	e9 95 f3 ff ff       	jmp    80106856 <alltraps>

801074c1 <vector160>:
.globl vector160
vector160:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $160
801074c3:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801074c8:	e9 89 f3 ff ff       	jmp    80106856 <alltraps>

801074cd <vector161>:
.globl vector161
vector161:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $161
801074cf:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801074d4:	e9 7d f3 ff ff       	jmp    80106856 <alltraps>

801074d9 <vector162>:
.globl vector162
vector162:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $162
801074db:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801074e0:	e9 71 f3 ff ff       	jmp    80106856 <alltraps>

801074e5 <vector163>:
.globl vector163
vector163:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $163
801074e7:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801074ec:	e9 65 f3 ff ff       	jmp    80106856 <alltraps>

801074f1 <vector164>:
.globl vector164
vector164:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $164
801074f3:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801074f8:	e9 59 f3 ff ff       	jmp    80106856 <alltraps>

801074fd <vector165>:
.globl vector165
vector165:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $165
801074ff:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107504:	e9 4d f3 ff ff       	jmp    80106856 <alltraps>

80107509 <vector166>:
.globl vector166
vector166:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $166
8010750b:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107510:	e9 41 f3 ff ff       	jmp    80106856 <alltraps>

80107515 <vector167>:
.globl vector167
vector167:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $167
80107517:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010751c:	e9 35 f3 ff ff       	jmp    80106856 <alltraps>

80107521 <vector168>:
.globl vector168
vector168:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $168
80107523:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107528:	e9 29 f3 ff ff       	jmp    80106856 <alltraps>

8010752d <vector169>:
.globl vector169
vector169:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $169
8010752f:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107534:	e9 1d f3 ff ff       	jmp    80106856 <alltraps>

80107539 <vector170>:
.globl vector170
vector170:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $170
8010753b:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107540:	e9 11 f3 ff ff       	jmp    80106856 <alltraps>

80107545 <vector171>:
.globl vector171
vector171:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $171
80107547:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010754c:	e9 05 f3 ff ff       	jmp    80106856 <alltraps>

80107551 <vector172>:
.globl vector172
vector172:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $172
80107553:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107558:	e9 f9 f2 ff ff       	jmp    80106856 <alltraps>

8010755d <vector173>:
.globl vector173
vector173:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $173
8010755f:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107564:	e9 ed f2 ff ff       	jmp    80106856 <alltraps>

80107569 <vector174>:
.globl vector174
vector174:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $174
8010756b:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107570:	e9 e1 f2 ff ff       	jmp    80106856 <alltraps>

80107575 <vector175>:
.globl vector175
vector175:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $175
80107577:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010757c:	e9 d5 f2 ff ff       	jmp    80106856 <alltraps>

80107581 <vector176>:
.globl vector176
vector176:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $176
80107583:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107588:	e9 c9 f2 ff ff       	jmp    80106856 <alltraps>

8010758d <vector177>:
.globl vector177
vector177:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $177
8010758f:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107594:	e9 bd f2 ff ff       	jmp    80106856 <alltraps>

80107599 <vector178>:
.globl vector178
vector178:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $178
8010759b:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801075a0:	e9 b1 f2 ff ff       	jmp    80106856 <alltraps>

801075a5 <vector179>:
.globl vector179
vector179:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $179
801075a7:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801075ac:	e9 a5 f2 ff ff       	jmp    80106856 <alltraps>

801075b1 <vector180>:
.globl vector180
vector180:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $180
801075b3:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801075b8:	e9 99 f2 ff ff       	jmp    80106856 <alltraps>

801075bd <vector181>:
.globl vector181
vector181:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $181
801075bf:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801075c4:	e9 8d f2 ff ff       	jmp    80106856 <alltraps>

801075c9 <vector182>:
.globl vector182
vector182:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $182
801075cb:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801075d0:	e9 81 f2 ff ff       	jmp    80106856 <alltraps>

801075d5 <vector183>:
.globl vector183
vector183:
  pushl $0
801075d5:	6a 00                	push   $0x0
  pushl $183
801075d7:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801075dc:	e9 75 f2 ff ff       	jmp    80106856 <alltraps>

801075e1 <vector184>:
.globl vector184
vector184:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $184
801075e3:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801075e8:	e9 69 f2 ff ff       	jmp    80106856 <alltraps>

801075ed <vector185>:
.globl vector185
vector185:
  pushl $0
801075ed:	6a 00                	push   $0x0
  pushl $185
801075ef:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801075f4:	e9 5d f2 ff ff       	jmp    80106856 <alltraps>

801075f9 <vector186>:
.globl vector186
vector186:
  pushl $0
801075f9:	6a 00                	push   $0x0
  pushl $186
801075fb:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107600:	e9 51 f2 ff ff       	jmp    80106856 <alltraps>

80107605 <vector187>:
.globl vector187
vector187:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $187
80107607:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010760c:	e9 45 f2 ff ff       	jmp    80106856 <alltraps>

80107611 <vector188>:
.globl vector188
vector188:
  pushl $0
80107611:	6a 00                	push   $0x0
  pushl $188
80107613:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107618:	e9 39 f2 ff ff       	jmp    80106856 <alltraps>

8010761d <vector189>:
.globl vector189
vector189:
  pushl $0
8010761d:	6a 00                	push   $0x0
  pushl $189
8010761f:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107624:	e9 2d f2 ff ff       	jmp    80106856 <alltraps>

80107629 <vector190>:
.globl vector190
vector190:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $190
8010762b:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107630:	e9 21 f2 ff ff       	jmp    80106856 <alltraps>

80107635 <vector191>:
.globl vector191
vector191:
  pushl $0
80107635:	6a 00                	push   $0x0
  pushl $191
80107637:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010763c:	e9 15 f2 ff ff       	jmp    80106856 <alltraps>

80107641 <vector192>:
.globl vector192
vector192:
  pushl $0
80107641:	6a 00                	push   $0x0
  pushl $192
80107643:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107648:	e9 09 f2 ff ff       	jmp    80106856 <alltraps>

8010764d <vector193>:
.globl vector193
vector193:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $193
8010764f:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107654:	e9 fd f1 ff ff       	jmp    80106856 <alltraps>

80107659 <vector194>:
.globl vector194
vector194:
  pushl $0
80107659:	6a 00                	push   $0x0
  pushl $194
8010765b:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107660:	e9 f1 f1 ff ff       	jmp    80106856 <alltraps>

80107665 <vector195>:
.globl vector195
vector195:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $195
80107667:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010766c:	e9 e5 f1 ff ff       	jmp    80106856 <alltraps>

80107671 <vector196>:
.globl vector196
vector196:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $196
80107673:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107678:	e9 d9 f1 ff ff       	jmp    80106856 <alltraps>

8010767d <vector197>:
.globl vector197
vector197:
  pushl $0
8010767d:	6a 00                	push   $0x0
  pushl $197
8010767f:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107684:	e9 cd f1 ff ff       	jmp    80106856 <alltraps>

80107689 <vector198>:
.globl vector198
vector198:
  pushl $0
80107689:	6a 00                	push   $0x0
  pushl $198
8010768b:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107690:	e9 c1 f1 ff ff       	jmp    80106856 <alltraps>

80107695 <vector199>:
.globl vector199
vector199:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $199
80107697:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010769c:	e9 b5 f1 ff ff       	jmp    80106856 <alltraps>

801076a1 <vector200>:
.globl vector200
vector200:
  pushl $0
801076a1:	6a 00                	push   $0x0
  pushl $200
801076a3:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801076a8:	e9 a9 f1 ff ff       	jmp    80106856 <alltraps>

801076ad <vector201>:
.globl vector201
vector201:
  pushl $0
801076ad:	6a 00                	push   $0x0
  pushl $201
801076af:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801076b4:	e9 9d f1 ff ff       	jmp    80106856 <alltraps>

801076b9 <vector202>:
.globl vector202
vector202:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $202
801076bb:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801076c0:	e9 91 f1 ff ff       	jmp    80106856 <alltraps>

801076c5 <vector203>:
.globl vector203
vector203:
  pushl $0
801076c5:	6a 00                	push   $0x0
  pushl $203
801076c7:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801076cc:	e9 85 f1 ff ff       	jmp    80106856 <alltraps>

801076d1 <vector204>:
.globl vector204
vector204:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $204
801076d3:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801076d8:	e9 79 f1 ff ff       	jmp    80106856 <alltraps>

801076dd <vector205>:
.globl vector205
vector205:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $205
801076df:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801076e4:	e9 6d f1 ff ff       	jmp    80106856 <alltraps>

801076e9 <vector206>:
.globl vector206
vector206:
  pushl $0
801076e9:	6a 00                	push   $0x0
  pushl $206
801076eb:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801076f0:	e9 61 f1 ff ff       	jmp    80106856 <alltraps>

801076f5 <vector207>:
.globl vector207
vector207:
  pushl $0
801076f5:	6a 00                	push   $0x0
  pushl $207
801076f7:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801076fc:	e9 55 f1 ff ff       	jmp    80106856 <alltraps>

80107701 <vector208>:
.globl vector208
vector208:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $208
80107703:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107708:	e9 49 f1 ff ff       	jmp    80106856 <alltraps>

8010770d <vector209>:
.globl vector209
vector209:
  pushl $0
8010770d:	6a 00                	push   $0x0
  pushl $209
8010770f:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107714:	e9 3d f1 ff ff       	jmp    80106856 <alltraps>

80107719 <vector210>:
.globl vector210
vector210:
  pushl $0
80107719:	6a 00                	push   $0x0
  pushl $210
8010771b:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107720:	e9 31 f1 ff ff       	jmp    80106856 <alltraps>

80107725 <vector211>:
.globl vector211
vector211:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $211
80107727:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010772c:	e9 25 f1 ff ff       	jmp    80106856 <alltraps>

80107731 <vector212>:
.globl vector212
vector212:
  pushl $0
80107731:	6a 00                	push   $0x0
  pushl $212
80107733:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107738:	e9 19 f1 ff ff       	jmp    80106856 <alltraps>

8010773d <vector213>:
.globl vector213
vector213:
  pushl $0
8010773d:	6a 00                	push   $0x0
  pushl $213
8010773f:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107744:	e9 0d f1 ff ff       	jmp    80106856 <alltraps>

80107749 <vector214>:
.globl vector214
vector214:
  pushl $0
80107749:	6a 00                	push   $0x0
  pushl $214
8010774b:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107750:	e9 01 f1 ff ff       	jmp    80106856 <alltraps>

80107755 <vector215>:
.globl vector215
vector215:
  pushl $0
80107755:	6a 00                	push   $0x0
  pushl $215
80107757:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010775c:	e9 f5 f0 ff ff       	jmp    80106856 <alltraps>

80107761 <vector216>:
.globl vector216
vector216:
  pushl $0
80107761:	6a 00                	push   $0x0
  pushl $216
80107763:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107768:	e9 e9 f0 ff ff       	jmp    80106856 <alltraps>

8010776d <vector217>:
.globl vector217
vector217:
  pushl $0
8010776d:	6a 00                	push   $0x0
  pushl $217
8010776f:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107774:	e9 dd f0 ff ff       	jmp    80106856 <alltraps>

80107779 <vector218>:
.globl vector218
vector218:
  pushl $0
80107779:	6a 00                	push   $0x0
  pushl $218
8010777b:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107780:	e9 d1 f0 ff ff       	jmp    80106856 <alltraps>

80107785 <vector219>:
.globl vector219
vector219:
  pushl $0
80107785:	6a 00                	push   $0x0
  pushl $219
80107787:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010778c:	e9 c5 f0 ff ff       	jmp    80106856 <alltraps>

80107791 <vector220>:
.globl vector220
vector220:
  pushl $0
80107791:	6a 00                	push   $0x0
  pushl $220
80107793:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107798:	e9 b9 f0 ff ff       	jmp    80106856 <alltraps>

8010779d <vector221>:
.globl vector221
vector221:
  pushl $0
8010779d:	6a 00                	push   $0x0
  pushl $221
8010779f:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801077a4:	e9 ad f0 ff ff       	jmp    80106856 <alltraps>

801077a9 <vector222>:
.globl vector222
vector222:
  pushl $0
801077a9:	6a 00                	push   $0x0
  pushl $222
801077ab:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801077b0:	e9 a1 f0 ff ff       	jmp    80106856 <alltraps>

801077b5 <vector223>:
.globl vector223
vector223:
  pushl $0
801077b5:	6a 00                	push   $0x0
  pushl $223
801077b7:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801077bc:	e9 95 f0 ff ff       	jmp    80106856 <alltraps>

801077c1 <vector224>:
.globl vector224
vector224:
  pushl $0
801077c1:	6a 00                	push   $0x0
  pushl $224
801077c3:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801077c8:	e9 89 f0 ff ff       	jmp    80106856 <alltraps>

801077cd <vector225>:
.globl vector225
vector225:
  pushl $0
801077cd:	6a 00                	push   $0x0
  pushl $225
801077cf:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801077d4:	e9 7d f0 ff ff       	jmp    80106856 <alltraps>

801077d9 <vector226>:
.globl vector226
vector226:
  pushl $0
801077d9:	6a 00                	push   $0x0
  pushl $226
801077db:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801077e0:	e9 71 f0 ff ff       	jmp    80106856 <alltraps>

801077e5 <vector227>:
.globl vector227
vector227:
  pushl $0
801077e5:	6a 00                	push   $0x0
  pushl $227
801077e7:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801077ec:	e9 65 f0 ff ff       	jmp    80106856 <alltraps>

801077f1 <vector228>:
.globl vector228
vector228:
  pushl $0
801077f1:	6a 00                	push   $0x0
  pushl $228
801077f3:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801077f8:	e9 59 f0 ff ff       	jmp    80106856 <alltraps>

801077fd <vector229>:
.globl vector229
vector229:
  pushl $0
801077fd:	6a 00                	push   $0x0
  pushl $229
801077ff:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107804:	e9 4d f0 ff ff       	jmp    80106856 <alltraps>

80107809 <vector230>:
.globl vector230
vector230:
  pushl $0
80107809:	6a 00                	push   $0x0
  pushl $230
8010780b:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107810:	e9 41 f0 ff ff       	jmp    80106856 <alltraps>

80107815 <vector231>:
.globl vector231
vector231:
  pushl $0
80107815:	6a 00                	push   $0x0
  pushl $231
80107817:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010781c:	e9 35 f0 ff ff       	jmp    80106856 <alltraps>

80107821 <vector232>:
.globl vector232
vector232:
  pushl $0
80107821:	6a 00                	push   $0x0
  pushl $232
80107823:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107828:	e9 29 f0 ff ff       	jmp    80106856 <alltraps>

8010782d <vector233>:
.globl vector233
vector233:
  pushl $0
8010782d:	6a 00                	push   $0x0
  pushl $233
8010782f:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107834:	e9 1d f0 ff ff       	jmp    80106856 <alltraps>

80107839 <vector234>:
.globl vector234
vector234:
  pushl $0
80107839:	6a 00                	push   $0x0
  pushl $234
8010783b:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107840:	e9 11 f0 ff ff       	jmp    80106856 <alltraps>

80107845 <vector235>:
.globl vector235
vector235:
  pushl $0
80107845:	6a 00                	push   $0x0
  pushl $235
80107847:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010784c:	e9 05 f0 ff ff       	jmp    80106856 <alltraps>

80107851 <vector236>:
.globl vector236
vector236:
  pushl $0
80107851:	6a 00                	push   $0x0
  pushl $236
80107853:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107858:	e9 f9 ef ff ff       	jmp    80106856 <alltraps>

8010785d <vector237>:
.globl vector237
vector237:
  pushl $0
8010785d:	6a 00                	push   $0x0
  pushl $237
8010785f:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107864:	e9 ed ef ff ff       	jmp    80106856 <alltraps>

80107869 <vector238>:
.globl vector238
vector238:
  pushl $0
80107869:	6a 00                	push   $0x0
  pushl $238
8010786b:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107870:	e9 e1 ef ff ff       	jmp    80106856 <alltraps>

80107875 <vector239>:
.globl vector239
vector239:
  pushl $0
80107875:	6a 00                	push   $0x0
  pushl $239
80107877:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010787c:	e9 d5 ef ff ff       	jmp    80106856 <alltraps>

80107881 <vector240>:
.globl vector240
vector240:
  pushl $0
80107881:	6a 00                	push   $0x0
  pushl $240
80107883:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107888:	e9 c9 ef ff ff       	jmp    80106856 <alltraps>

8010788d <vector241>:
.globl vector241
vector241:
  pushl $0
8010788d:	6a 00                	push   $0x0
  pushl $241
8010788f:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107894:	e9 bd ef ff ff       	jmp    80106856 <alltraps>

80107899 <vector242>:
.globl vector242
vector242:
  pushl $0
80107899:	6a 00                	push   $0x0
  pushl $242
8010789b:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801078a0:	e9 b1 ef ff ff       	jmp    80106856 <alltraps>

801078a5 <vector243>:
.globl vector243
vector243:
  pushl $0
801078a5:	6a 00                	push   $0x0
  pushl $243
801078a7:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801078ac:	e9 a5 ef ff ff       	jmp    80106856 <alltraps>

801078b1 <vector244>:
.globl vector244
vector244:
  pushl $0
801078b1:	6a 00                	push   $0x0
  pushl $244
801078b3:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801078b8:	e9 99 ef ff ff       	jmp    80106856 <alltraps>

801078bd <vector245>:
.globl vector245
vector245:
  pushl $0
801078bd:	6a 00                	push   $0x0
  pushl $245
801078bf:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801078c4:	e9 8d ef ff ff       	jmp    80106856 <alltraps>

801078c9 <vector246>:
.globl vector246
vector246:
  pushl $0
801078c9:	6a 00                	push   $0x0
  pushl $246
801078cb:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801078d0:	e9 81 ef ff ff       	jmp    80106856 <alltraps>

801078d5 <vector247>:
.globl vector247
vector247:
  pushl $0
801078d5:	6a 00                	push   $0x0
  pushl $247
801078d7:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801078dc:	e9 75 ef ff ff       	jmp    80106856 <alltraps>

801078e1 <vector248>:
.globl vector248
vector248:
  pushl $0
801078e1:	6a 00                	push   $0x0
  pushl $248
801078e3:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801078e8:	e9 69 ef ff ff       	jmp    80106856 <alltraps>

801078ed <vector249>:
.globl vector249
vector249:
  pushl $0
801078ed:	6a 00                	push   $0x0
  pushl $249
801078ef:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801078f4:	e9 5d ef ff ff       	jmp    80106856 <alltraps>

801078f9 <vector250>:
.globl vector250
vector250:
  pushl $0
801078f9:	6a 00                	push   $0x0
  pushl $250
801078fb:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107900:	e9 51 ef ff ff       	jmp    80106856 <alltraps>

80107905 <vector251>:
.globl vector251
vector251:
  pushl $0
80107905:	6a 00                	push   $0x0
  pushl $251
80107907:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010790c:	e9 45 ef ff ff       	jmp    80106856 <alltraps>

80107911 <vector252>:
.globl vector252
vector252:
  pushl $0
80107911:	6a 00                	push   $0x0
  pushl $252
80107913:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107918:	e9 39 ef ff ff       	jmp    80106856 <alltraps>

8010791d <vector253>:
.globl vector253
vector253:
  pushl $0
8010791d:	6a 00                	push   $0x0
  pushl $253
8010791f:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107924:	e9 2d ef ff ff       	jmp    80106856 <alltraps>

80107929 <vector254>:
.globl vector254
vector254:
  pushl $0
80107929:	6a 00                	push   $0x0
  pushl $254
8010792b:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107930:	e9 21 ef ff ff       	jmp    80106856 <alltraps>

80107935 <vector255>:
.globl vector255
vector255:
  pushl $0
80107935:	6a 00                	push   $0x0
  pushl $255
80107937:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010793c:	e9 15 ef ff ff       	jmp    80106856 <alltraps>

80107941 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107941:	55                   	push   %ebp
80107942:	89 e5                	mov    %esp,%ebp
80107944:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107947:	8b 45 0c             	mov    0xc(%ebp),%eax
8010794a:	83 e8 01             	sub    $0x1,%eax
8010794d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107951:	8b 45 08             	mov    0x8(%ebp),%eax
80107954:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107958:	8b 45 08             	mov    0x8(%ebp),%eax
8010795b:	c1 e8 10             	shr    $0x10,%eax
8010795e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107962:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107965:	0f 01 10             	lgdtl  (%eax)
}
80107968:	c9                   	leave  
80107969:	c3                   	ret    

8010796a <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010796a:	55                   	push   %ebp
8010796b:	89 e5                	mov    %esp,%ebp
8010796d:	83 ec 04             	sub    $0x4,%esp
80107970:	8b 45 08             	mov    0x8(%ebp),%eax
80107973:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107977:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010797b:	0f 00 d8             	ltr    %ax
}
8010797e:	c9                   	leave  
8010797f:	c3                   	ret    

80107980 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107980:	55                   	push   %ebp
80107981:	89 e5                	mov    %esp,%ebp
80107983:	83 ec 04             	sub    $0x4,%esp
80107986:	8b 45 08             	mov    0x8(%ebp),%eax
80107989:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010798d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107991:	8e e8                	mov    %eax,%gs
}
80107993:	c9                   	leave  
80107994:	c3                   	ret    

80107995 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107995:	55                   	push   %ebp
80107996:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107998:	8b 45 08             	mov    0x8(%ebp),%eax
8010799b:	0f 22 d8             	mov    %eax,%cr3
}
8010799e:	5d                   	pop    %ebp
8010799f:	c3                   	ret    

801079a0 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801079a0:	55                   	push   %ebp
801079a1:	89 e5                	mov    %esp,%ebp
801079a3:	8b 45 08             	mov    0x8(%ebp),%eax
801079a6:	05 00 00 00 80       	add    $0x80000000,%eax
801079ab:	5d                   	pop    %ebp
801079ac:	c3                   	ret    

801079ad <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801079ad:	55                   	push   %ebp
801079ae:	89 e5                	mov    %esp,%ebp
801079b0:	8b 45 08             	mov    0x8(%ebp),%eax
801079b3:	05 00 00 00 80       	add    $0x80000000,%eax
801079b8:	5d                   	pop    %ebp
801079b9:	c3                   	ret    

801079ba <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801079ba:	55                   	push   %ebp
801079bb:	89 e5                	mov    %esp,%ebp
801079bd:	53                   	push   %ebx
801079be:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801079c1:	e8 68 b5 ff ff       	call   80102f2e <cpunum>
801079c6:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801079cc:	05 80 23 11 80       	add    $0x80112380,%eax
801079d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801079d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d7:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801079dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e0:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801079e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e9:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801079ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079f4:	83 e2 f0             	and    $0xfffffff0,%edx
801079f7:	83 ca 0a             	or     $0xa,%edx
801079fa:	88 50 7d             	mov    %dl,0x7d(%eax)
801079fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a00:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a04:	83 ca 10             	or     $0x10,%edx
80107a07:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a11:	83 e2 9f             	and    $0xffffff9f,%edx
80107a14:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a1e:	83 ca 80             	or     $0xffffff80,%edx
80107a21:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a27:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a2b:	83 ca 0f             	or     $0xf,%edx
80107a2e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a34:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a38:	83 e2 ef             	and    $0xffffffef,%edx
80107a3b:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a41:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a45:	83 e2 df             	and    $0xffffffdf,%edx
80107a48:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a52:	83 ca 40             	or     $0x40,%edx
80107a55:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a5f:	83 ca 80             	or     $0xffffff80,%edx
80107a62:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a68:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6f:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107a76:	ff ff 
80107a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7b:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107a82:	00 00 
80107a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a87:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a91:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a98:	83 e2 f0             	and    $0xfffffff0,%edx
80107a9b:	83 ca 02             	or     $0x2,%edx
80107a9e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa7:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107aae:	83 ca 10             	or     $0x10,%edx
80107ab1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aba:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ac1:	83 e2 9f             	and    $0xffffff9f,%edx
80107ac4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acd:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ad4:	83 ca 80             	or     $0xffffff80,%edx
80107ad7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ae7:	83 ca 0f             	or     $0xf,%edx
80107aea:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107afa:	83 e2 ef             	and    $0xffffffef,%edx
80107afd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b06:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b0d:	83 e2 df             	and    $0xffffffdf,%edx
80107b10:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b19:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b20:	83 ca 40             	or     $0x40,%edx
80107b23:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b33:	83 ca 80             	or     $0xffffff80,%edx
80107b36:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3f:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b49:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107b50:	ff ff 
80107b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b55:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107b5c:	00 00 
80107b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b61:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b72:	83 e2 f0             	and    $0xfffffff0,%edx
80107b75:	83 ca 0a             	or     $0xa,%edx
80107b78:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b81:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b88:	83 ca 10             	or     $0x10,%edx
80107b8b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b94:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b9b:	83 ca 60             	or     $0x60,%edx
80107b9e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107bae:	83 ca 80             	or     $0xffffff80,%edx
80107bb1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bba:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bc1:	83 ca 0f             	or     $0xf,%edx
80107bc4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcd:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bd4:	83 e2 ef             	and    $0xffffffef,%edx
80107bd7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107be7:	83 e2 df             	and    $0xffffffdf,%edx
80107bea:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bfa:	83 ca 40             	or     $0x40,%edx
80107bfd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c06:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c0d:	83 ca 80             	or     $0xffffff80,%edx
80107c10:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c19:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c23:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107c2a:	ff ff 
80107c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2f:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107c36:	00 00 
80107c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3b:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c45:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c4c:	83 e2 f0             	and    $0xfffffff0,%edx
80107c4f:	83 ca 02             	or     $0x2,%edx
80107c52:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c62:	83 ca 10             	or     $0x10,%edx
80107c65:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c75:	83 ca 60             	or     $0x60,%edx
80107c78:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c81:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c88:	83 ca 80             	or     $0xffffff80,%edx
80107c8b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c94:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c9b:	83 ca 0f             	or     $0xf,%edx
80107c9e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107cae:	83 e2 ef             	and    $0xffffffef,%edx
80107cb1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cba:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107cc1:	83 e2 df             	and    $0xffffffdf,%edx
80107cc4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccd:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107cd4:	83 ca 40             	or     $0x40,%edx
80107cd7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ce7:	83 ca 80             	or     $0xffffff80,%edx
80107cea:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf3:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfd:	05 b4 00 00 00       	add    $0xb4,%eax
80107d02:	89 c3                	mov    %eax,%ebx
80107d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d07:	05 b4 00 00 00       	add    $0xb4,%eax
80107d0c:	c1 e8 10             	shr    $0x10,%eax
80107d0f:	89 c1                	mov    %eax,%ecx
80107d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d14:	05 b4 00 00 00       	add    $0xb4,%eax
80107d19:	c1 e8 18             	shr    $0x18,%eax
80107d1c:	89 c2                	mov    %eax,%edx
80107d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d21:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107d28:	00 00 
80107d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2d:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d37:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d40:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107d47:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d4a:	83 c9 02             	or     $0x2,%ecx
80107d4d:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d56:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107d5d:	83 c9 10             	or     $0x10,%ecx
80107d60:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d69:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107d70:	83 e1 9f             	and    $0xffffff9f,%ecx
80107d73:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7c:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107d83:	83 c9 80             	or     $0xffffff80,%ecx
80107d86:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8f:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d96:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d99:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da2:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107da9:	83 e1 ef             	and    $0xffffffef,%ecx
80107dac:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db5:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107dbc:	83 e1 df             	and    $0xffffffdf,%ecx
80107dbf:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc8:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107dcf:	83 c9 40             	or     $0x40,%ecx
80107dd2:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddb:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107de2:	83 c9 80             	or     $0xffffff80,%ecx
80107de5:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dee:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df7:	83 c0 70             	add    $0x70,%eax
80107dfa:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107e01:	00 
80107e02:	89 04 24             	mov    %eax,(%esp)
80107e05:	e8 37 fb ff ff       	call   80107941 <lgdt>
  loadgs(SEG_KCPU << 3);
80107e0a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107e11:	e8 6a fb ff ff       	call   80107980 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e19:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107e1f:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107e26:	00 00 00 00 
}
80107e2a:	83 c4 24             	add    $0x24,%esp
80107e2d:	5b                   	pop    %ebx
80107e2e:	5d                   	pop    %ebp
80107e2f:	c3                   	ret    

80107e30 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107e30:	55                   	push   %ebp
80107e31:	89 e5                	mov    %esp,%ebp
80107e33:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107e36:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e39:	c1 e8 16             	shr    $0x16,%eax
80107e3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e43:	8b 45 08             	mov    0x8(%ebp),%eax
80107e46:	01 d0                	add    %edx,%eax
80107e48:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107e4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e4e:	8b 00                	mov    (%eax),%eax
80107e50:	83 e0 01             	and    $0x1,%eax
80107e53:	85 c0                	test   %eax,%eax
80107e55:	74 17                	je     80107e6e <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e5a:	8b 00                	mov    (%eax),%eax
80107e5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e61:	89 04 24             	mov    %eax,(%esp)
80107e64:	e8 44 fb ff ff       	call   801079ad <p2v>
80107e69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e6c:	eb 4b                	jmp    80107eb9 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107e6e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107e72:	74 0e                	je     80107e82 <walkpgdir+0x52>
80107e74:	e8 1f ad ff ff       	call   80102b98 <kalloc>
80107e79:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e7c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e80:	75 07                	jne    80107e89 <walkpgdir+0x59>
      return 0;
80107e82:	b8 00 00 00 00       	mov    $0x0,%eax
80107e87:	eb 47                	jmp    80107ed0 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107e89:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e90:	00 
80107e91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e98:	00 
80107e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9c:	89 04 24             	mov    %eax,(%esp)
80107e9f:	e8 8d d4 ff ff       	call   80105331 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea7:	89 04 24             	mov    %eax,(%esp)
80107eaa:	e8 f1 fa ff ff       	call   801079a0 <v2p>
80107eaf:	83 c8 07             	or     $0x7,%eax
80107eb2:	89 c2                	mov    %eax,%edx
80107eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eb7:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ebc:	c1 e8 0c             	shr    $0xc,%eax
80107ebf:	25 ff 03 00 00       	and    $0x3ff,%eax
80107ec4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ece:	01 d0                	add    %edx,%eax
}
80107ed0:	c9                   	leave  
80107ed1:	c3                   	ret    

80107ed2 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107ed2:	55                   	push   %ebp
80107ed3:	89 e5                	mov    %esp,%ebp
80107ed5:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107edb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ee0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107ee3:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ee6:	8b 45 10             	mov    0x10(%ebp),%eax
80107ee9:	01 d0                	add    %edx,%eax
80107eeb:	83 e8 01             	sub    $0x1,%eax
80107eee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ef3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ef6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107efd:	00 
80107efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f01:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f05:	8b 45 08             	mov    0x8(%ebp),%eax
80107f08:	89 04 24             	mov    %eax,(%esp)
80107f0b:	e8 20 ff ff ff       	call   80107e30 <walkpgdir>
80107f10:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f13:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f17:	75 07                	jne    80107f20 <mappages+0x4e>
      return -1;
80107f19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f1e:	eb 48                	jmp    80107f68 <mappages+0x96>
    if(*pte & PTE_P)
80107f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f23:	8b 00                	mov    (%eax),%eax
80107f25:	83 e0 01             	and    $0x1,%eax
80107f28:	85 c0                	test   %eax,%eax
80107f2a:	74 0c                	je     80107f38 <mappages+0x66>
      panic("remap");
80107f2c:	c7 04 24 14 8e 10 80 	movl   $0x80108e14,(%esp)
80107f33:	e8 02 86 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107f38:	8b 45 18             	mov    0x18(%ebp),%eax
80107f3b:	0b 45 14             	or     0x14(%ebp),%eax
80107f3e:	83 c8 01             	or     $0x1,%eax
80107f41:	89 c2                	mov    %eax,%edx
80107f43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f46:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f4e:	75 08                	jne    80107f58 <mappages+0x86>
      break;
80107f50:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107f51:	b8 00 00 00 00       	mov    $0x0,%eax
80107f56:	eb 10                	jmp    80107f68 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107f58:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107f5f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107f66:	eb 8e                	jmp    80107ef6 <mappages+0x24>
  return 0;
}
80107f68:	c9                   	leave  
80107f69:	c3                   	ret    

80107f6a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107f6a:	55                   	push   %ebp
80107f6b:	89 e5                	mov    %esp,%ebp
80107f6d:	53                   	push   %ebx
80107f6e:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107f71:	e8 22 ac ff ff       	call   80102b98 <kalloc>
80107f76:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f79:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f7d:	75 0a                	jne    80107f89 <setupkvm+0x1f>
    return 0;
80107f7f:	b8 00 00 00 00       	mov    $0x0,%eax
80107f84:	e9 98 00 00 00       	jmp    80108021 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107f89:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f90:	00 
80107f91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f98:	00 
80107f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f9c:	89 04 24             	mov    %eax,(%esp)
80107f9f:	e8 8d d3 ff ff       	call   80105331 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107fa4:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107fab:	e8 fd f9 ff ff       	call   801079ad <p2v>
80107fb0:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107fb5:	76 0c                	jbe    80107fc3 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107fb7:	c7 04 24 1a 8e 10 80 	movl   $0x80108e1a,(%esp)
80107fbe:	e8 77 85 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107fc3:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80107fca:	eb 49                	jmp    80108015 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcf:	8b 48 0c             	mov    0xc(%eax),%ecx
80107fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd5:	8b 50 04             	mov    0x4(%eax),%edx
80107fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fdb:	8b 58 08             	mov    0x8(%eax),%ebx
80107fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe1:	8b 40 04             	mov    0x4(%eax),%eax
80107fe4:	29 c3                	sub    %eax,%ebx
80107fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe9:	8b 00                	mov    (%eax),%eax
80107feb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107fef:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107ff3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ffb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ffe:	89 04 24             	mov    %eax,(%esp)
80108001:	e8 cc fe ff ff       	call   80107ed2 <mappages>
80108006:	85 c0                	test   %eax,%eax
80108008:	79 07                	jns    80108011 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
8010800a:	b8 00 00 00 00       	mov    $0x0,%eax
8010800f:	eb 10                	jmp    80108021 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108011:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108015:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
8010801c:	72 ae                	jb     80107fcc <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
8010801e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108021:	83 c4 34             	add    $0x34,%esp
80108024:	5b                   	pop    %ebx
80108025:	5d                   	pop    %ebp
80108026:	c3                   	ret    

80108027 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108027:	55                   	push   %ebp
80108028:	89 e5                	mov    %esp,%ebp
8010802a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010802d:	e8 38 ff ff ff       	call   80107f6a <setupkvm>
80108032:	a3 58 53 11 80       	mov    %eax,0x80115358
  switchkvm();
80108037:	e8 02 00 00 00       	call   8010803e <switchkvm>
}
8010803c:	c9                   	leave  
8010803d:	c3                   	ret    

8010803e <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010803e:	55                   	push   %ebp
8010803f:	89 e5                	mov    %esp,%ebp
80108041:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108044:	a1 58 53 11 80       	mov    0x80115358,%eax
80108049:	89 04 24             	mov    %eax,(%esp)
8010804c:	e8 4f f9 ff ff       	call   801079a0 <v2p>
80108051:	89 04 24             	mov    %eax,(%esp)
80108054:	e8 3c f9 ff ff       	call   80107995 <lcr3>
}
80108059:	c9                   	leave  
8010805a:	c3                   	ret    

8010805b <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010805b:	55                   	push   %ebp
8010805c:	89 e5                	mov    %esp,%ebp
8010805e:	53                   	push   %ebx
8010805f:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108062:	e8 ca d1 ff ff       	call   80105231 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108067:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010806d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108074:	83 c2 08             	add    $0x8,%edx
80108077:	89 d3                	mov    %edx,%ebx
80108079:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108080:	83 c2 08             	add    $0x8,%edx
80108083:	c1 ea 10             	shr    $0x10,%edx
80108086:	89 d1                	mov    %edx,%ecx
80108088:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010808f:	83 c2 08             	add    $0x8,%edx
80108092:	c1 ea 18             	shr    $0x18,%edx
80108095:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010809c:	67 00 
8010809e:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
801080a5:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
801080ab:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801080b2:	83 e1 f0             	and    $0xfffffff0,%ecx
801080b5:	83 c9 09             	or     $0x9,%ecx
801080b8:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801080be:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801080c5:	83 c9 10             	or     $0x10,%ecx
801080c8:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801080ce:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801080d5:	83 e1 9f             	and    $0xffffff9f,%ecx
801080d8:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801080de:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801080e5:	83 c9 80             	or     $0xffffff80,%ecx
801080e8:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801080ee:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801080f5:	83 e1 f0             	and    $0xfffffff0,%ecx
801080f8:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801080fe:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108105:	83 e1 ef             	and    $0xffffffef,%ecx
80108108:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010810e:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108115:	83 e1 df             	and    $0xffffffdf,%ecx
80108118:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010811e:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108125:	83 c9 40             	or     $0x40,%ecx
80108128:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010812e:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108135:	83 e1 7f             	and    $0x7f,%ecx
80108138:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010813e:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108144:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010814a:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108151:	83 e2 ef             	and    $0xffffffef,%edx
80108154:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
8010815a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108160:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108166:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010816c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108173:	8b 52 08             	mov    0x8(%edx),%edx
80108176:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010817c:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010817f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108186:	e8 df f7 ff ff       	call   8010796a <ltr>
  if(p->pgdir == 0)
8010818b:	8b 45 08             	mov    0x8(%ebp),%eax
8010818e:	8b 40 04             	mov    0x4(%eax),%eax
80108191:	85 c0                	test   %eax,%eax
80108193:	75 0c                	jne    801081a1 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108195:	c7 04 24 2b 8e 10 80 	movl   $0x80108e2b,(%esp)
8010819c:	e8 99 83 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801081a1:	8b 45 08             	mov    0x8(%ebp),%eax
801081a4:	8b 40 04             	mov    0x4(%eax),%eax
801081a7:	89 04 24             	mov    %eax,(%esp)
801081aa:	e8 f1 f7 ff ff       	call   801079a0 <v2p>
801081af:	89 04 24             	mov    %eax,(%esp)
801081b2:	e8 de f7 ff ff       	call   80107995 <lcr3>
  popcli();
801081b7:	e8 b9 d0 ff ff       	call   80105275 <popcli>
}
801081bc:	83 c4 14             	add    $0x14,%esp
801081bf:	5b                   	pop    %ebx
801081c0:	5d                   	pop    %ebp
801081c1:	c3                   	ret    

801081c2 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801081c2:	55                   	push   %ebp
801081c3:	89 e5                	mov    %esp,%ebp
801081c5:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801081c8:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801081cf:	76 0c                	jbe    801081dd <inituvm+0x1b>
    panic("inituvm: more than a page");
801081d1:	c7 04 24 3f 8e 10 80 	movl   $0x80108e3f,(%esp)
801081d8:	e8 5d 83 ff ff       	call   8010053a <panic>
  mem = kalloc();
801081dd:	e8 b6 a9 ff ff       	call   80102b98 <kalloc>
801081e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801081e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081ec:	00 
801081ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801081f4:	00 
801081f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f8:	89 04 24             	mov    %eax,(%esp)
801081fb:	e8 31 d1 ff ff       	call   80105331 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108203:	89 04 24             	mov    %eax,(%esp)
80108206:	e8 95 f7 ff ff       	call   801079a0 <v2p>
8010820b:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108212:	00 
80108213:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108217:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010821e:	00 
8010821f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108226:	00 
80108227:	8b 45 08             	mov    0x8(%ebp),%eax
8010822a:	89 04 24             	mov    %eax,(%esp)
8010822d:	e8 a0 fc ff ff       	call   80107ed2 <mappages>
  memmove(mem, init, sz);
80108232:	8b 45 10             	mov    0x10(%ebp),%eax
80108235:	89 44 24 08          	mov    %eax,0x8(%esp)
80108239:	8b 45 0c             	mov    0xc(%ebp),%eax
8010823c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108243:	89 04 24             	mov    %eax,(%esp)
80108246:	e8 b5 d1 ff ff       	call   80105400 <memmove>
}
8010824b:	c9                   	leave  
8010824c:	c3                   	ret    

8010824d <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010824d:	55                   	push   %ebp
8010824e:	89 e5                	mov    %esp,%ebp
80108250:	53                   	push   %ebx
80108251:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108254:	8b 45 0c             	mov    0xc(%ebp),%eax
80108257:	25 ff 0f 00 00       	and    $0xfff,%eax
8010825c:	85 c0                	test   %eax,%eax
8010825e:	74 0c                	je     8010826c <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108260:	c7 04 24 5c 8e 10 80 	movl   $0x80108e5c,(%esp)
80108267:	e8 ce 82 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010826c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108273:	e9 a9 00 00 00       	jmp    80108321 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010827e:	01 d0                	add    %edx,%eax
80108280:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108287:	00 
80108288:	89 44 24 04          	mov    %eax,0x4(%esp)
8010828c:	8b 45 08             	mov    0x8(%ebp),%eax
8010828f:	89 04 24             	mov    %eax,(%esp)
80108292:	e8 99 fb ff ff       	call   80107e30 <walkpgdir>
80108297:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010829a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010829e:	75 0c                	jne    801082ac <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801082a0:	c7 04 24 7f 8e 10 80 	movl   $0x80108e7f,(%esp)
801082a7:	e8 8e 82 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801082ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082af:	8b 00                	mov    (%eax),%eax
801082b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801082b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082bc:	8b 55 18             	mov    0x18(%ebp),%edx
801082bf:	29 c2                	sub    %eax,%edx
801082c1:	89 d0                	mov    %edx,%eax
801082c3:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801082c8:	77 0f                	ja     801082d9 <loaduvm+0x8c>
      n = sz - i;
801082ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082cd:	8b 55 18             	mov    0x18(%ebp),%edx
801082d0:	29 c2                	sub    %eax,%edx
801082d2:	89 d0                	mov    %edx,%eax
801082d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801082d7:	eb 07                	jmp    801082e0 <loaduvm+0x93>
    else
      n = PGSIZE;
801082d9:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801082e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e3:	8b 55 14             	mov    0x14(%ebp),%edx
801082e6:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801082e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082ec:	89 04 24             	mov    %eax,(%esp)
801082ef:	e8 b9 f6 ff ff       	call   801079ad <p2v>
801082f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801082f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
801082fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801082ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80108303:	8b 45 10             	mov    0x10(%ebp),%eax
80108306:	89 04 24             	mov    %eax,(%esp)
80108309:	e8 d9 9a ff ff       	call   80101de7 <readi>
8010830e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108311:	74 07                	je     8010831a <loaduvm+0xcd>
      return -1;
80108313:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108318:	eb 18                	jmp    80108332 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010831a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108324:	3b 45 18             	cmp    0x18(%ebp),%eax
80108327:	0f 82 4b ff ff ff    	jb     80108278 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010832d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108332:	83 c4 24             	add    $0x24,%esp
80108335:	5b                   	pop    %ebx
80108336:	5d                   	pop    %ebp
80108337:	c3                   	ret    

80108338 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108338:	55                   	push   %ebp
80108339:	89 e5                	mov    %esp,%ebp
8010833b:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010833e:	8b 45 10             	mov    0x10(%ebp),%eax
80108341:	85 c0                	test   %eax,%eax
80108343:	79 0a                	jns    8010834f <allocuvm+0x17>
    return 0;
80108345:	b8 00 00 00 00       	mov    $0x0,%eax
8010834a:	e9 c1 00 00 00       	jmp    80108410 <allocuvm+0xd8>
  if(newsz < oldsz)
8010834f:	8b 45 10             	mov    0x10(%ebp),%eax
80108352:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108355:	73 08                	jae    8010835f <allocuvm+0x27>
    return oldsz;
80108357:	8b 45 0c             	mov    0xc(%ebp),%eax
8010835a:	e9 b1 00 00 00       	jmp    80108410 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010835f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108362:	05 ff 0f 00 00       	add    $0xfff,%eax
80108367:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010836c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010836f:	e9 8d 00 00 00       	jmp    80108401 <allocuvm+0xc9>
    mem = kalloc();
80108374:	e8 1f a8 ff ff       	call   80102b98 <kalloc>
80108379:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010837c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108380:	75 2c                	jne    801083ae <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108382:	c7 04 24 9d 8e 10 80 	movl   $0x80108e9d,(%esp)
80108389:	e8 12 80 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010838e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108391:	89 44 24 08          	mov    %eax,0x8(%esp)
80108395:	8b 45 10             	mov    0x10(%ebp),%eax
80108398:	89 44 24 04          	mov    %eax,0x4(%esp)
8010839c:	8b 45 08             	mov    0x8(%ebp),%eax
8010839f:	89 04 24             	mov    %eax,(%esp)
801083a2:	e8 6b 00 00 00       	call   80108412 <deallocuvm>
      return 0;
801083a7:	b8 00 00 00 00       	mov    $0x0,%eax
801083ac:	eb 62                	jmp    80108410 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801083ae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083b5:	00 
801083b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801083bd:	00 
801083be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083c1:	89 04 24             	mov    %eax,(%esp)
801083c4:	e8 68 cf ff ff       	call   80105331 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801083c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083cc:	89 04 24             	mov    %eax,(%esp)
801083cf:	e8 cc f5 ff ff       	call   801079a0 <v2p>
801083d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083d7:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801083de:	00 
801083df:	89 44 24 0c          	mov    %eax,0xc(%esp)
801083e3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083ea:	00 
801083eb:	89 54 24 04          	mov    %edx,0x4(%esp)
801083ef:	8b 45 08             	mov    0x8(%ebp),%eax
801083f2:	89 04 24             	mov    %eax,(%esp)
801083f5:	e8 d8 fa ff ff       	call   80107ed2 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801083fa:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108404:	3b 45 10             	cmp    0x10(%ebp),%eax
80108407:	0f 82 67 ff ff ff    	jb     80108374 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010840d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108410:	c9                   	leave  
80108411:	c3                   	ret    

80108412 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108412:	55                   	push   %ebp
80108413:	89 e5                	mov    %esp,%ebp
80108415:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108418:	8b 45 10             	mov    0x10(%ebp),%eax
8010841b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010841e:	72 08                	jb     80108428 <deallocuvm+0x16>
    return oldsz;
80108420:	8b 45 0c             	mov    0xc(%ebp),%eax
80108423:	e9 a4 00 00 00       	jmp    801084cc <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108428:	8b 45 10             	mov    0x10(%ebp),%eax
8010842b:	05 ff 0f 00 00       	add    $0xfff,%eax
80108430:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108435:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108438:	e9 80 00 00 00       	jmp    801084bd <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010843d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108440:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108447:	00 
80108448:	89 44 24 04          	mov    %eax,0x4(%esp)
8010844c:	8b 45 08             	mov    0x8(%ebp),%eax
8010844f:	89 04 24             	mov    %eax,(%esp)
80108452:	e8 d9 f9 ff ff       	call   80107e30 <walkpgdir>
80108457:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010845a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010845e:	75 09                	jne    80108469 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108460:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108467:	eb 4d                	jmp    801084b6 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108469:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010846c:	8b 00                	mov    (%eax),%eax
8010846e:	83 e0 01             	and    $0x1,%eax
80108471:	85 c0                	test   %eax,%eax
80108473:	74 41                	je     801084b6 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108478:	8b 00                	mov    (%eax),%eax
8010847a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010847f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108482:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108486:	75 0c                	jne    80108494 <deallocuvm+0x82>
        panic("kfree");
80108488:	c7 04 24 b5 8e 10 80 	movl   $0x80108eb5,(%esp)
8010848f:	e8 a6 80 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108494:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108497:	89 04 24             	mov    %eax,(%esp)
8010849a:	e8 0e f5 ff ff       	call   801079ad <p2v>
8010849f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801084a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084a5:	89 04 24             	mov    %eax,(%esp)
801084a8:	e8 52 a6 ff ff       	call   80102aff <kfree>
      *pte = 0;
801084ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801084b6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084c3:	0f 82 74 ff ff ff    	jb     8010843d <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801084c9:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084cc:	c9                   	leave  
801084cd:	c3                   	ret    

801084ce <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801084ce:	55                   	push   %ebp
801084cf:	89 e5                	mov    %esp,%ebp
801084d1:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801084d4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801084d8:	75 0c                	jne    801084e6 <freevm+0x18>
    panic("freevm: no pgdir");
801084da:	c7 04 24 bb 8e 10 80 	movl   $0x80108ebb,(%esp)
801084e1:	e8 54 80 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801084e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084ed:	00 
801084ee:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801084f5:	80 
801084f6:	8b 45 08             	mov    0x8(%ebp),%eax
801084f9:	89 04 24             	mov    %eax,(%esp)
801084fc:	e8 11 ff ff ff       	call   80108412 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108501:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108508:	eb 48                	jmp    80108552 <freevm+0x84>
    if(pgdir[i] & PTE_P){
8010850a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108514:	8b 45 08             	mov    0x8(%ebp),%eax
80108517:	01 d0                	add    %edx,%eax
80108519:	8b 00                	mov    (%eax),%eax
8010851b:	83 e0 01             	and    $0x1,%eax
8010851e:	85 c0                	test   %eax,%eax
80108520:	74 2c                	je     8010854e <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108525:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010852c:	8b 45 08             	mov    0x8(%ebp),%eax
8010852f:	01 d0                	add    %edx,%eax
80108531:	8b 00                	mov    (%eax),%eax
80108533:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108538:	89 04 24             	mov    %eax,(%esp)
8010853b:	e8 6d f4 ff ff       	call   801079ad <p2v>
80108540:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108543:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108546:	89 04 24             	mov    %eax,(%esp)
80108549:	e8 b1 a5 ff ff       	call   80102aff <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010854e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108552:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108559:	76 af                	jbe    8010850a <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010855b:	8b 45 08             	mov    0x8(%ebp),%eax
8010855e:	89 04 24             	mov    %eax,(%esp)
80108561:	e8 99 a5 ff ff       	call   80102aff <kfree>
}
80108566:	c9                   	leave  
80108567:	c3                   	ret    

80108568 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108568:	55                   	push   %ebp
80108569:	89 e5                	mov    %esp,%ebp
8010856b:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010856e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108575:	00 
80108576:	8b 45 0c             	mov    0xc(%ebp),%eax
80108579:	89 44 24 04          	mov    %eax,0x4(%esp)
8010857d:	8b 45 08             	mov    0x8(%ebp),%eax
80108580:	89 04 24             	mov    %eax,(%esp)
80108583:	e8 a8 f8 ff ff       	call   80107e30 <walkpgdir>
80108588:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010858b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010858f:	75 0c                	jne    8010859d <clearpteu+0x35>
    panic("clearpteu");
80108591:	c7 04 24 cc 8e 10 80 	movl   $0x80108ecc,(%esp)
80108598:	e8 9d 7f ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
8010859d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a0:	8b 00                	mov    (%eax),%eax
801085a2:	83 e0 fb             	and    $0xfffffffb,%eax
801085a5:	89 c2                	mov    %eax,%edx
801085a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085aa:	89 10                	mov    %edx,(%eax)
}
801085ac:	c9                   	leave  
801085ad:	c3                   	ret    

801085ae <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801085ae:	55                   	push   %ebp
801085af:	89 e5                	mov    %esp,%ebp
801085b1:	53                   	push   %ebx
801085b2:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801085b5:	e8 b0 f9 ff ff       	call   80107f6a <setupkvm>
801085ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801085bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085c1:	75 0a                	jne    801085cd <copyuvm+0x1f>
    return 0;
801085c3:	b8 00 00 00 00       	mov    $0x0,%eax
801085c8:	e9 fd 00 00 00       	jmp    801086ca <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801085cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085d4:	e9 d0 00 00 00       	jmp    801086a9 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801085d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085e3:	00 
801085e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801085e8:	8b 45 08             	mov    0x8(%ebp),%eax
801085eb:	89 04 24             	mov    %eax,(%esp)
801085ee:	e8 3d f8 ff ff       	call   80107e30 <walkpgdir>
801085f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801085f6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085fa:	75 0c                	jne    80108608 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
801085fc:	c7 04 24 d6 8e 10 80 	movl   $0x80108ed6,(%esp)
80108603:	e8 32 7f ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
80108608:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010860b:	8b 00                	mov    (%eax),%eax
8010860d:	83 e0 01             	and    $0x1,%eax
80108610:	85 c0                	test   %eax,%eax
80108612:	75 0c                	jne    80108620 <copyuvm+0x72>
      panic("copyuvm: page not present");
80108614:	c7 04 24 f0 8e 10 80 	movl   $0x80108ef0,(%esp)
8010861b:	e8 1a 7f ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108620:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108623:	8b 00                	mov    (%eax),%eax
80108625:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010862a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010862d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108630:	8b 00                	mov    (%eax),%eax
80108632:	25 ff 0f 00 00       	and    $0xfff,%eax
80108637:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010863a:	e8 59 a5 ff ff       	call   80102b98 <kalloc>
8010863f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108642:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108646:	75 02                	jne    8010864a <copyuvm+0x9c>
      goto bad;
80108648:	eb 70                	jmp    801086ba <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010864a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010864d:	89 04 24             	mov    %eax,(%esp)
80108650:	e8 58 f3 ff ff       	call   801079ad <p2v>
80108655:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010865c:	00 
8010865d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108661:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108664:	89 04 24             	mov    %eax,(%esp)
80108667:	e8 94 cd ff ff       	call   80105400 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010866c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010866f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108672:	89 04 24             	mov    %eax,(%esp)
80108675:	e8 26 f3 ff ff       	call   801079a0 <v2p>
8010867a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010867d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108681:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108685:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010868c:	00 
8010868d:	89 54 24 04          	mov    %edx,0x4(%esp)
80108691:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108694:	89 04 24             	mov    %eax,(%esp)
80108697:	e8 36 f8 ff ff       	call   80107ed2 <mappages>
8010869c:	85 c0                	test   %eax,%eax
8010869e:	79 02                	jns    801086a2 <copyuvm+0xf4>
      goto bad;
801086a0:	eb 18                	jmp    801086ba <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801086a2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ac:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086af:	0f 82 24 ff ff ff    	jb     801085d9 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801086b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086b8:	eb 10                	jmp    801086ca <copyuvm+0x11c>

bad:
  freevm(d);
801086ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086bd:	89 04 24             	mov    %eax,(%esp)
801086c0:	e8 09 fe ff ff       	call   801084ce <freevm>
  return 0;
801086c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086ca:	83 c4 44             	add    $0x44,%esp
801086cd:	5b                   	pop    %ebx
801086ce:	5d                   	pop    %ebp
801086cf:	c3                   	ret    

801086d0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801086d0:	55                   	push   %ebp
801086d1:	89 e5                	mov    %esp,%ebp
801086d3:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801086d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086dd:	00 
801086de:	8b 45 0c             	mov    0xc(%ebp),%eax
801086e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801086e5:	8b 45 08             	mov    0x8(%ebp),%eax
801086e8:	89 04 24             	mov    %eax,(%esp)
801086eb:	e8 40 f7 ff ff       	call   80107e30 <walkpgdir>
801086f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801086f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f6:	8b 00                	mov    (%eax),%eax
801086f8:	83 e0 01             	and    $0x1,%eax
801086fb:	85 c0                	test   %eax,%eax
801086fd:	75 07                	jne    80108706 <uva2ka+0x36>
    return 0;
801086ff:	b8 00 00 00 00       	mov    $0x0,%eax
80108704:	eb 25                	jmp    8010872b <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108709:	8b 00                	mov    (%eax),%eax
8010870b:	83 e0 04             	and    $0x4,%eax
8010870e:	85 c0                	test   %eax,%eax
80108710:	75 07                	jne    80108719 <uva2ka+0x49>
    return 0;
80108712:	b8 00 00 00 00       	mov    $0x0,%eax
80108717:	eb 12                	jmp    8010872b <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871c:	8b 00                	mov    (%eax),%eax
8010871e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108723:	89 04 24             	mov    %eax,(%esp)
80108726:	e8 82 f2 ff ff       	call   801079ad <p2v>
}
8010872b:	c9                   	leave  
8010872c:	c3                   	ret    

8010872d <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010872d:	55                   	push   %ebp
8010872e:	89 e5                	mov    %esp,%ebp
80108730:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108733:	8b 45 10             	mov    0x10(%ebp),%eax
80108736:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108739:	e9 87 00 00 00       	jmp    801087c5 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
8010873e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108741:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108746:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108749:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010874c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108750:	8b 45 08             	mov    0x8(%ebp),%eax
80108753:	89 04 24             	mov    %eax,(%esp)
80108756:	e8 75 ff ff ff       	call   801086d0 <uva2ka>
8010875b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010875e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108762:	75 07                	jne    8010876b <copyout+0x3e>
      return -1;
80108764:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108769:	eb 69                	jmp    801087d4 <copyout+0xa7>
    n = PGSIZE - (va - va0);
8010876b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010876e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108771:	29 c2                	sub    %eax,%edx
80108773:	89 d0                	mov    %edx,%eax
80108775:	05 00 10 00 00       	add    $0x1000,%eax
8010877a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010877d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108780:	3b 45 14             	cmp    0x14(%ebp),%eax
80108783:	76 06                	jbe    8010878b <copyout+0x5e>
      n = len;
80108785:	8b 45 14             	mov    0x14(%ebp),%eax
80108788:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010878b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010878e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108791:	29 c2                	sub    %eax,%edx
80108793:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108796:	01 c2                	add    %eax,%edx
80108798:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010879b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010879f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801087a6:	89 14 24             	mov    %edx,(%esp)
801087a9:	e8 52 cc ff ff       	call   80105400 <memmove>
    len -= n;
801087ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b1:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801087b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b7:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801087ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087bd:	05 00 10 00 00       	add    $0x1000,%eax
801087c2:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801087c5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801087c9:	0f 85 6f ff ff ff    	jne    8010873e <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801087cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801087d4:	c9                   	leave  
801087d5:	c3                   	ret    
