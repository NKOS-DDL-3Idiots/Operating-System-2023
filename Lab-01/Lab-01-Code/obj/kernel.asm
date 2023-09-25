
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	249000ef          	jal	ra,80200a6c <memset>

    cons_init();  // init the console
    80200028:	15e000ef          	jal	ra,80200186 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a5458593          	addi	a1,a1,-1452 # 80200a80 <etext+0x2>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a6c50513          	addi	a0,a0,-1428 # 80200aa0 <etext+0x22>
    8020003c:	042000ef          	jal	ra,8020007e <cprintf>

    print_kerninfo();
    80200040:	072000ef          	jal	ra,802000b2 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	152000ef          	jal	ra,80200196 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0fa000ef          	jal	ra,80200142 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	144000ef          	jal	ra,80200190 <intr_enable>

    // 增加异常指令

    // 非法指令
    __asm__ __volatile__ ("mret");
    80200050:	30200073          	mret

    // 断点
    __asm__ __volatile__("ebreak");
    80200054:	9002                	ebreak

    // 打印信息
    cprintf("Hello World!\n");
    80200056:	00001517          	auipc	a0,0x1
    8020005a:	a5250513          	addi	a0,a0,-1454 # 80200aa8 <etext+0x2a>
    8020005e:	020000ef          	jal	ra,8020007e <cprintf>
    
    while (1)
        ;
    80200062:	a001                	j	80200062 <kern_init+0x56>

0000000080200064 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200064:	1141                	addi	sp,sp,-16
    80200066:	e022                	sd	s0,0(sp)
    80200068:	e406                	sd	ra,8(sp)
    8020006a:	842e                	mv	s0,a1
    cons_putc(c);
    8020006c:	11c000ef          	jal	ra,80200188 <cons_putc>
    (*cnt)++;
    80200070:	401c                	lw	a5,0(s0)
}
    80200072:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200074:	2785                	addiw	a5,a5,1
    80200076:	c01c                	sw	a5,0(s0)
}
    80200078:	6402                	ld	s0,0(sp)
    8020007a:	0141                	addi	sp,sp,16
    8020007c:	8082                	ret

000000008020007e <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020007e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200080:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200084:	f42e                	sd	a1,40(sp)
    80200086:	f832                	sd	a2,48(sp)
    80200088:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020008a:	862a                	mv	a2,a0
    8020008c:	004c                	addi	a1,sp,4
    8020008e:	00000517          	auipc	a0,0x0
    80200092:	fd650513          	addi	a0,a0,-42 # 80200064 <cputch>
    80200096:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200098:	ec06                	sd	ra,24(sp)
    8020009a:	e0ba                	sd	a4,64(sp)
    8020009c:	e4be                	sd	a5,72(sp)
    8020009e:	e8c2                	sd	a6,80(sp)
    802000a0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    802000a2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    802000a4:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    802000a6:	5c0000ef          	jal	ra,80200666 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    802000aa:	60e2                	ld	ra,24(sp)
    802000ac:	4512                	lw	a0,4(sp)
    802000ae:	6125                	addi	sp,sp,96
    802000b0:	8082                	ret

00000000802000b2 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000b2:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000b4:	00001517          	auipc	a0,0x1
    802000b8:	a0450513          	addi	a0,a0,-1532 # 80200ab8 <etext+0x3a>
void print_kerninfo(void) {
    802000bc:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000be:	fc1ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000c2:	00000597          	auipc	a1,0x0
    802000c6:	f4a58593          	addi	a1,a1,-182 # 8020000c <kern_init>
    802000ca:	00001517          	auipc	a0,0x1
    802000ce:	a0e50513          	addi	a0,a0,-1522 # 80200ad8 <etext+0x5a>
    802000d2:	fadff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000d6:	00001597          	auipc	a1,0x1
    802000da:	9a858593          	addi	a1,a1,-1624 # 80200a7e <etext>
    802000de:	00001517          	auipc	a0,0x1
    802000e2:	a1a50513          	addi	a0,a0,-1510 # 80200af8 <etext+0x7a>
    802000e6:	f99ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000ea:	00004597          	auipc	a1,0x4
    802000ee:	f2658593          	addi	a1,a1,-218 # 80204010 <edata>
    802000f2:	00001517          	auipc	a0,0x1
    802000f6:	a2650513          	addi	a0,a0,-1498 # 80200b18 <etext+0x9a>
    802000fa:	f85ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000fe:	00004597          	auipc	a1,0x4
    80200102:	f2a58593          	addi	a1,a1,-214 # 80204028 <end>
    80200106:	00001517          	auipc	a0,0x1
    8020010a:	a3250513          	addi	a0,a0,-1486 # 80200b38 <etext+0xba>
    8020010e:	f71ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200112:	00004597          	auipc	a1,0x4
    80200116:	31558593          	addi	a1,a1,789 # 80204427 <end+0x3ff>
    8020011a:	00000797          	auipc	a5,0x0
    8020011e:	ef278793          	addi	a5,a5,-270 # 8020000c <kern_init>
    80200122:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200126:	43f7d593          	srai	a1,a5,0x3f
}
    8020012a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	3ff5f593          	andi	a1,a1,1023
    80200130:	95be                	add	a1,a1,a5
    80200132:	85a9                	srai	a1,a1,0xa
    80200134:	00001517          	auipc	a0,0x1
    80200138:	a2450513          	addi	a0,a0,-1500 # 80200b58 <etext+0xda>
}
    8020013c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020013e:	f41ff06f          	j	8020007e <cprintf>

0000000080200142 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200142:	1141                	addi	sp,sp,-16
    80200144:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200146:	02000793          	li	a5,32
    8020014a:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020014e:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200152:	67e1                	lui	a5,0x18
    80200154:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200158:	953e                	add	a0,a0,a5
    8020015a:	0b5000ef          	jal	ra,80200a0e <sbi_set_timer>
}
    8020015e:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200160:	00004797          	auipc	a5,0x4
    80200164:	ec07b023          	sd	zero,-320(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200168:	00001517          	auipc	a0,0x1
    8020016c:	a2050513          	addi	a0,a0,-1504 # 80200b88 <etext+0x10a>
}
    80200170:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200172:	f0dff06f          	j	8020007e <cprintf>

0000000080200176 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200176:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020017a:	67e1                	lui	a5,0x18
    8020017c:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200180:	953e                	add	a0,a0,a5
    80200182:	08d0006f          	j	80200a0e <sbi_set_timer>

0000000080200186 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200186:	8082                	ret

0000000080200188 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200188:	0ff57513          	andi	a0,a0,255
    8020018c:	0670006f          	j	802009f2 <sbi_console_putchar>

0000000080200190 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200190:	100167f3          	csrrsi	a5,sstatus,2
    80200194:	8082                	ret

0000000080200196 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200196:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020019a:	00000797          	auipc	a5,0x0
    8020019e:	3aa78793          	addi	a5,a5,938 # 80200544 <__alltraps>
    802001a2:	10579073          	csrw	stvec,a5
}
    802001a6:	8082                	ret

00000000802001a8 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a8:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    802001aa:	1141                	addi	sp,sp,-16
    802001ac:	e022                	sd	s0,0(sp)
    802001ae:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001b0:	00001517          	auipc	a0,0x1
    802001b4:	b6850513          	addi	a0,a0,-1176 # 80200d18 <etext+0x29a>
void print_regs(struct pushregs *gpr) {
    802001b8:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001ba:	ec5ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001be:	640c                	ld	a1,8(s0)
    802001c0:	00001517          	auipc	a0,0x1
    802001c4:	b7050513          	addi	a0,a0,-1168 # 80200d30 <etext+0x2b2>
    802001c8:	eb7ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001cc:	680c                	ld	a1,16(s0)
    802001ce:	00001517          	auipc	a0,0x1
    802001d2:	b7a50513          	addi	a0,a0,-1158 # 80200d48 <etext+0x2ca>
    802001d6:	ea9ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001da:	6c0c                	ld	a1,24(s0)
    802001dc:	00001517          	auipc	a0,0x1
    802001e0:	b8450513          	addi	a0,a0,-1148 # 80200d60 <etext+0x2e2>
    802001e4:	e9bff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001e8:	700c                	ld	a1,32(s0)
    802001ea:	00001517          	auipc	a0,0x1
    802001ee:	b8e50513          	addi	a0,a0,-1138 # 80200d78 <etext+0x2fa>
    802001f2:	e8dff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001f6:	740c                	ld	a1,40(s0)
    802001f8:	00001517          	auipc	a0,0x1
    802001fc:	b9850513          	addi	a0,a0,-1128 # 80200d90 <etext+0x312>
    80200200:	e7fff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    80200204:	780c                	ld	a1,48(s0)
    80200206:	00001517          	auipc	a0,0x1
    8020020a:	ba250513          	addi	a0,a0,-1118 # 80200da8 <etext+0x32a>
    8020020e:	e71ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200212:	7c0c                	ld	a1,56(s0)
    80200214:	00001517          	auipc	a0,0x1
    80200218:	bac50513          	addi	a0,a0,-1108 # 80200dc0 <etext+0x342>
    8020021c:	e63ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200220:	602c                	ld	a1,64(s0)
    80200222:	00001517          	auipc	a0,0x1
    80200226:	bb650513          	addi	a0,a0,-1098 # 80200dd8 <etext+0x35a>
    8020022a:	e55ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020022e:	642c                	ld	a1,72(s0)
    80200230:	00001517          	auipc	a0,0x1
    80200234:	bc050513          	addi	a0,a0,-1088 # 80200df0 <etext+0x372>
    80200238:	e47ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020023c:	682c                	ld	a1,80(s0)
    8020023e:	00001517          	auipc	a0,0x1
    80200242:	bca50513          	addi	a0,a0,-1078 # 80200e08 <etext+0x38a>
    80200246:	e39ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020024a:	6c2c                	ld	a1,88(s0)
    8020024c:	00001517          	auipc	a0,0x1
    80200250:	bd450513          	addi	a0,a0,-1068 # 80200e20 <etext+0x3a2>
    80200254:	e2bff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200258:	702c                	ld	a1,96(s0)
    8020025a:	00001517          	auipc	a0,0x1
    8020025e:	bde50513          	addi	a0,a0,-1058 # 80200e38 <etext+0x3ba>
    80200262:	e1dff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200266:	742c                	ld	a1,104(s0)
    80200268:	00001517          	auipc	a0,0x1
    8020026c:	be850513          	addi	a0,a0,-1048 # 80200e50 <etext+0x3d2>
    80200270:	e0fff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200274:	782c                	ld	a1,112(s0)
    80200276:	00001517          	auipc	a0,0x1
    8020027a:	bf250513          	addi	a0,a0,-1038 # 80200e68 <etext+0x3ea>
    8020027e:	e01ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200282:	7c2c                	ld	a1,120(s0)
    80200284:	00001517          	auipc	a0,0x1
    80200288:	bfc50513          	addi	a0,a0,-1028 # 80200e80 <etext+0x402>
    8020028c:	df3ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200290:	604c                	ld	a1,128(s0)
    80200292:	00001517          	auipc	a0,0x1
    80200296:	c0650513          	addi	a0,a0,-1018 # 80200e98 <etext+0x41a>
    8020029a:	de5ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020029e:	644c                	ld	a1,136(s0)
    802002a0:	00001517          	auipc	a0,0x1
    802002a4:	c1050513          	addi	a0,a0,-1008 # 80200eb0 <etext+0x432>
    802002a8:	dd7ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    802002ac:	684c                	ld	a1,144(s0)
    802002ae:	00001517          	auipc	a0,0x1
    802002b2:	c1a50513          	addi	a0,a0,-998 # 80200ec8 <etext+0x44a>
    802002b6:	dc9ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002ba:	6c4c                	ld	a1,152(s0)
    802002bc:	00001517          	auipc	a0,0x1
    802002c0:	c2450513          	addi	a0,a0,-988 # 80200ee0 <etext+0x462>
    802002c4:	dbbff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002c8:	704c                	ld	a1,160(s0)
    802002ca:	00001517          	auipc	a0,0x1
    802002ce:	c2e50513          	addi	a0,a0,-978 # 80200ef8 <etext+0x47a>
    802002d2:	dadff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002d6:	744c                	ld	a1,168(s0)
    802002d8:	00001517          	auipc	a0,0x1
    802002dc:	c3850513          	addi	a0,a0,-968 # 80200f10 <etext+0x492>
    802002e0:	d9fff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002e4:	784c                	ld	a1,176(s0)
    802002e6:	00001517          	auipc	a0,0x1
    802002ea:	c4250513          	addi	a0,a0,-958 # 80200f28 <etext+0x4aa>
    802002ee:	d91ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002f2:	7c4c                	ld	a1,184(s0)
    802002f4:	00001517          	auipc	a0,0x1
    802002f8:	c4c50513          	addi	a0,a0,-948 # 80200f40 <etext+0x4c2>
    802002fc:	d83ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    80200300:	606c                	ld	a1,192(s0)
    80200302:	00001517          	auipc	a0,0x1
    80200306:	c5650513          	addi	a0,a0,-938 # 80200f58 <etext+0x4da>
    8020030a:	d75ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    8020030e:	646c                	ld	a1,200(s0)
    80200310:	00001517          	auipc	a0,0x1
    80200314:	c6050513          	addi	a0,a0,-928 # 80200f70 <etext+0x4f2>
    80200318:	d67ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020031c:	686c                	ld	a1,208(s0)
    8020031e:	00001517          	auipc	a0,0x1
    80200322:	c6a50513          	addi	a0,a0,-918 # 80200f88 <etext+0x50a>
    80200326:	d59ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020032a:	6c6c                	ld	a1,216(s0)
    8020032c:	00001517          	auipc	a0,0x1
    80200330:	c7450513          	addi	a0,a0,-908 # 80200fa0 <etext+0x522>
    80200334:	d4bff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200338:	706c                	ld	a1,224(s0)
    8020033a:	00001517          	auipc	a0,0x1
    8020033e:	c7e50513          	addi	a0,a0,-898 # 80200fb8 <etext+0x53a>
    80200342:	d3dff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200346:	746c                	ld	a1,232(s0)
    80200348:	00001517          	auipc	a0,0x1
    8020034c:	c8850513          	addi	a0,a0,-888 # 80200fd0 <etext+0x552>
    80200350:	d2fff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200354:	786c                	ld	a1,240(s0)
    80200356:	00001517          	auipc	a0,0x1
    8020035a:	c9250513          	addi	a0,a0,-878 # 80200fe8 <etext+0x56a>
    8020035e:	d21ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200362:	7c6c                	ld	a1,248(s0)
}
    80200364:	6402                	ld	s0,0(sp)
    80200366:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200368:	00001517          	auipc	a0,0x1
    8020036c:	c9850513          	addi	a0,a0,-872 # 80201000 <etext+0x582>
}
    80200370:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200372:	d0dff06f          	j	8020007e <cprintf>

0000000080200376 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200376:	1141                	addi	sp,sp,-16
    80200378:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020037a:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020037c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020037e:	00001517          	auipc	a0,0x1
    80200382:	c9a50513          	addi	a0,a0,-870 # 80201018 <etext+0x59a>
void print_trapframe(struct trapframe *tf) {
    80200386:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200388:	cf7ff0ef          	jal	ra,8020007e <cprintf>
    print_regs(&tf->gpr);
    8020038c:	8522                	mv	a0,s0
    8020038e:	e1bff0ef          	jal	ra,802001a8 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200392:	10043583          	ld	a1,256(s0)
    80200396:	00001517          	auipc	a0,0x1
    8020039a:	c9a50513          	addi	a0,a0,-870 # 80201030 <etext+0x5b2>
    8020039e:	ce1ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    802003a2:	10843583          	ld	a1,264(s0)
    802003a6:	00001517          	auipc	a0,0x1
    802003aa:	ca250513          	addi	a0,a0,-862 # 80201048 <etext+0x5ca>
    802003ae:	cd1ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003b2:	11043583          	ld	a1,272(s0)
    802003b6:	00001517          	auipc	a0,0x1
    802003ba:	caa50513          	addi	a0,a0,-854 # 80201060 <etext+0x5e2>
    802003be:	cc1ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	11843583          	ld	a1,280(s0)
}
    802003c6:	6402                	ld	s0,0(sp)
    802003c8:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ca:	00001517          	auipc	a0,0x1
    802003ce:	cae50513          	addi	a0,a0,-850 # 80201078 <etext+0x5fa>
}
    802003d2:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003d4:	cabff06f          	j	8020007e <cprintf>

00000000802003d8 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003d8:	11853783          	ld	a5,280(a0)
    802003dc:	577d                	li	a4,-1
    802003de:	8305                	srli	a4,a4,0x1
    802003e0:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003e2:	472d                	li	a4,11
    802003e4:	08f76063          	bltu	a4,a5,80200464 <interrupt_handler+0x8c>
    802003e8:	00000717          	auipc	a4,0x0
    802003ec:	7bc70713          	addi	a4,a4,1980 # 80200ba4 <etext+0x126>
    802003f0:	078a                	slli	a5,a5,0x2
    802003f2:	97ba                	add	a5,a5,a4
    802003f4:	439c                	lw	a5,0(a5)
    802003f6:	97ba                	add	a5,a5,a4
    802003f8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003fa:	00001517          	auipc	a0,0x1
    802003fe:	8ce50513          	addi	a0,a0,-1842 # 80200cc8 <etext+0x24a>
    80200402:	c7dff06f          	j	8020007e <cprintf>
            cprintf("Hypervisor software interrupt\n");
    80200406:	00001517          	auipc	a0,0x1
    8020040a:	8a250513          	addi	a0,a0,-1886 # 80200ca8 <etext+0x22a>
    8020040e:	c71ff06f          	j	8020007e <cprintf>
            cprintf("User software interrupt\n");
    80200412:	00001517          	auipc	a0,0x1
    80200416:	85650513          	addi	a0,a0,-1962 # 80200c68 <etext+0x1ea>
    8020041a:	c65ff06f          	j	8020007e <cprintf>
            cprintf("Supervisor software interrupt\n");
    8020041e:	00001517          	auipc	a0,0x1
    80200422:	86a50513          	addi	a0,a0,-1942 # 80200c88 <etext+0x20a>
    80200426:	c59ff06f          	j	8020007e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020042a:	00001517          	auipc	a0,0x1
    8020042e:	8ce50513          	addi	a0,a0,-1842 # 80200cf8 <etext+0x27a>
    80200432:	c4dff06f          	j	8020007e <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200436:	1141                	addi	sp,sp,-16
    80200438:	e406                	sd	ra,8(sp)
            clock_set_next_event(); // 设置下次时钟中断
    8020043a:	d3dff0ef          	jal	ra,80200176 <clock_set_next_event>
            ticks++; // 计数器加一
    8020043e:	00004717          	auipc	a4,0x4
    80200442:	be270713          	addi	a4,a4,-1054 # 80204020 <ticks>
    80200446:	631c                	ld	a5,0(a4)
    80200448:	0785                	addi	a5,a5,1
    8020044a:	00004697          	auipc	a3,0x4
    8020044e:	bcf6bb23          	sd	a5,-1066(a3) # 80204020 <ticks>
            if (ticks % TICK_NUM == 0) { // 每当计数器加到100的时候
    80200452:	631c                	ld	a5,0(a4)
    80200454:	06400713          	li	a4,100
    80200458:	02e7f7b3          	remu	a5,a5,a4
    8020045c:	c791                	beqz	a5,80200468 <interrupt_handler+0x90>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020045e:	60a2                	ld	ra,8(sp)
    80200460:	0141                	addi	sp,sp,16
    80200462:	8082                	ret
            print_trapframe(tf);
    80200464:	f13ff06f          	j	80200376 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200468:	06400593          	li	a1,100
    8020046c:	00001517          	auipc	a0,0x1
    80200470:	87c50513          	addi	a0,a0,-1924 # 80200ce8 <etext+0x26a>
    80200474:	c0bff0ef          	jal	ra,8020007e <cprintf>
                num++; // 同时打印次数（num）加一
    80200478:	00004717          	auipc	a4,0x4
    8020047c:	b9870713          	addi	a4,a4,-1128 # 80204010 <edata>
    80200480:	631c                	ld	a5,0(a4)
                if (num == 10) { // 判断打印次数，当打印次数为10时
    80200482:	46a9                	li	a3,10
                num++; // 同时打印次数（num）加一
    80200484:	0785                	addi	a5,a5,1
    80200486:	00004617          	auipc	a2,0x4
    8020048a:	b8f63523          	sd	a5,-1142(a2) # 80204010 <edata>
                if (num == 10) { // 判断打印次数，当打印次数为10时
    8020048e:	631c                	ld	a5,0(a4)
    80200490:	fcd797e3          	bne	a5,a3,8020045e <interrupt_handler+0x86>
}
    80200494:	60a2                	ld	ra,8(sp)
    80200496:	0141                	addi	sp,sp,16
                    sbi_shutdown(); // 调用<sbi.h>中的关机函数sbi_shutdown()关机
    80200498:	5920006f          	j	80200a2a <sbi_shutdown>

000000008020049c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020049c:	11853783          	ld	a5,280(a0)
    802004a0:	472d                	li	a4,11
    802004a2:	02f76863          	bltu	a4,a5,802004d2 <exception_handler+0x36>
    802004a6:	4705                	li	a4,1
    802004a8:	00f71733          	sll	a4,a4,a5
    802004ac:	6785                	lui	a5,0x1
    802004ae:	17cd                	addi	a5,a5,-13
    802004b0:	8ff9                	and	a5,a5,a4
    802004b2:	ef99                	bnez	a5,802004d0 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004b4:	1141                	addi	sp,sp,-16
    802004b6:	e022                	sd	s0,0(sp)
    802004b8:	e406                	sd	ra,8(sp)
    802004ba:	00877793          	andi	a5,a4,8
    802004be:	842a                	mv	s0,a0
    802004c0:	e3b1                	bnez	a5,80200504 <exception_handler+0x68>
    802004c2:	8b11                	andi	a4,a4,4
    802004c4:	eb09                	bnez	a4,802004d6 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004c6:	6402                	ld	s0,0(sp)
    802004c8:	60a2                	ld	ra,8(sp)
    802004ca:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004cc:	eabff06f          	j	80200376 <print_trapframe>
    802004d0:	8082                	ret
    802004d2:	ea5ff06f          	j	80200376 <print_trapframe>
            cprintf("Exception type: Illegal instruction\n");
    802004d6:	00000517          	auipc	a0,0x0
    802004da:	70250513          	addi	a0,a0,1794 # 80200bd8 <etext+0x15a>
    802004de:	ba1ff0ef          	jal	ra,8020007e <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    802004e2:	10843583          	ld	a1,264(s0)
    802004e6:	00000517          	auipc	a0,0x0
    802004ea:	71a50513          	addi	a0,a0,1818 # 80200c00 <etext+0x182>
    802004ee:	b91ff0ef          	jal	ra,8020007e <cprintf>
            tf->epc += 4; // 指令长度 4 字节
    802004f2:	10843783          	ld	a5,264(s0)
}
    802004f6:	60a2                	ld	ra,8(sp)
            tf->epc += 4; // 指令长度 4 字节
    802004f8:	0791                	addi	a5,a5,4
    802004fa:	10f43423          	sd	a5,264(s0)
}
    802004fe:	6402                	ld	s0,0(sp)
    80200500:	0141                	addi	sp,sp,16
    80200502:	8082                	ret
            cprintf("Exception type: breakpoint\n");
    80200504:	00000517          	auipc	a0,0x0
    80200508:	72450513          	addi	a0,a0,1828 # 80200c28 <etext+0x1aa>
    8020050c:	b73ff0ef          	jal	ra,8020007e <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
    80200510:	10843583          	ld	a1,264(s0)
    80200514:	00000517          	auipc	a0,0x0
    80200518:	73450513          	addi	a0,a0,1844 # 80200c48 <etext+0x1ca>
    8020051c:	b63ff0ef          	jal	ra,8020007e <cprintf>
            tf->epc += 2; // 指令长度 2 字节
    80200520:	10843783          	ld	a5,264(s0)
}
    80200524:	60a2                	ld	ra,8(sp)
            tf->epc += 2; // 指令长度 2 字节
    80200526:	0789                	addi	a5,a5,2
    80200528:	10f43423          	sd	a5,264(s0)
}
    8020052c:	6402                	ld	s0,0(sp)
    8020052e:	0141                	addi	sp,sp,16
    80200530:	8082                	ret

0000000080200532 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200532:	11853783          	ld	a5,280(a0)
    80200536:	0007c463          	bltz	a5,8020053e <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    8020053a:	f63ff06f          	j	8020049c <exception_handler>
        interrupt_handler(tf);
    8020053e:	e9bff06f          	j	802003d8 <interrupt_handler>
	...

0000000080200544 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200544:	14011073          	csrw	sscratch,sp
    80200548:	712d                	addi	sp,sp,-288
    8020054a:	e002                	sd	zero,0(sp)
    8020054c:	e406                	sd	ra,8(sp)
    8020054e:	ec0e                	sd	gp,24(sp)
    80200550:	f012                	sd	tp,32(sp)
    80200552:	f416                	sd	t0,40(sp)
    80200554:	f81a                	sd	t1,48(sp)
    80200556:	fc1e                	sd	t2,56(sp)
    80200558:	e0a2                	sd	s0,64(sp)
    8020055a:	e4a6                	sd	s1,72(sp)
    8020055c:	e8aa                	sd	a0,80(sp)
    8020055e:	ecae                	sd	a1,88(sp)
    80200560:	f0b2                	sd	a2,96(sp)
    80200562:	f4b6                	sd	a3,104(sp)
    80200564:	f8ba                	sd	a4,112(sp)
    80200566:	fcbe                	sd	a5,120(sp)
    80200568:	e142                	sd	a6,128(sp)
    8020056a:	e546                	sd	a7,136(sp)
    8020056c:	e94a                	sd	s2,144(sp)
    8020056e:	ed4e                	sd	s3,152(sp)
    80200570:	f152                	sd	s4,160(sp)
    80200572:	f556                	sd	s5,168(sp)
    80200574:	f95a                	sd	s6,176(sp)
    80200576:	fd5e                	sd	s7,184(sp)
    80200578:	e1e2                	sd	s8,192(sp)
    8020057a:	e5e6                	sd	s9,200(sp)
    8020057c:	e9ea                	sd	s10,208(sp)
    8020057e:	edee                	sd	s11,216(sp)
    80200580:	f1f2                	sd	t3,224(sp)
    80200582:	f5f6                	sd	t4,232(sp)
    80200584:	f9fa                	sd	t5,240(sp)
    80200586:	fdfe                	sd	t6,248(sp)
    80200588:	14001473          	csrrw	s0,sscratch,zero
    8020058c:	100024f3          	csrr	s1,sstatus
    80200590:	14102973          	csrr	s2,sepc
    80200594:	143029f3          	csrr	s3,stval
    80200598:	14202a73          	csrr	s4,scause
    8020059c:	e822                	sd	s0,16(sp)
    8020059e:	e226                	sd	s1,256(sp)
    802005a0:	e64a                	sd	s2,264(sp)
    802005a2:	ea4e                	sd	s3,272(sp)
    802005a4:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802005a6:	850a                	mv	a0,sp
    jal trap
    802005a8:	f8bff0ef          	jal	ra,80200532 <trap>

00000000802005ac <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802005ac:	6492                	ld	s1,256(sp)
    802005ae:	6932                	ld	s2,264(sp)
    802005b0:	10049073          	csrw	sstatus,s1
    802005b4:	14191073          	csrw	sepc,s2
    802005b8:	60a2                	ld	ra,8(sp)
    802005ba:	61e2                	ld	gp,24(sp)
    802005bc:	7202                	ld	tp,32(sp)
    802005be:	72a2                	ld	t0,40(sp)
    802005c0:	7342                	ld	t1,48(sp)
    802005c2:	73e2                	ld	t2,56(sp)
    802005c4:	6406                	ld	s0,64(sp)
    802005c6:	64a6                	ld	s1,72(sp)
    802005c8:	6546                	ld	a0,80(sp)
    802005ca:	65e6                	ld	a1,88(sp)
    802005cc:	7606                	ld	a2,96(sp)
    802005ce:	76a6                	ld	a3,104(sp)
    802005d0:	7746                	ld	a4,112(sp)
    802005d2:	77e6                	ld	a5,120(sp)
    802005d4:	680a                	ld	a6,128(sp)
    802005d6:	68aa                	ld	a7,136(sp)
    802005d8:	694a                	ld	s2,144(sp)
    802005da:	69ea                	ld	s3,152(sp)
    802005dc:	7a0a                	ld	s4,160(sp)
    802005de:	7aaa                	ld	s5,168(sp)
    802005e0:	7b4a                	ld	s6,176(sp)
    802005e2:	7bea                	ld	s7,184(sp)
    802005e4:	6c0e                	ld	s8,192(sp)
    802005e6:	6cae                	ld	s9,200(sp)
    802005e8:	6d4e                	ld	s10,208(sp)
    802005ea:	6dee                	ld	s11,216(sp)
    802005ec:	7e0e                	ld	t3,224(sp)
    802005ee:	7eae                	ld	t4,232(sp)
    802005f0:	7f4e                	ld	t5,240(sp)
    802005f2:	7fee                	ld	t6,248(sp)
    802005f4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005f6:	10200073          	sret

00000000802005fa <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005fa:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005fe:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200600:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200604:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200606:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    8020060a:	f022                	sd	s0,32(sp)
    8020060c:	ec26                	sd	s1,24(sp)
    8020060e:	e84a                	sd	s2,16(sp)
    80200610:	f406                	sd	ra,40(sp)
    80200612:	e44e                	sd	s3,8(sp)
    80200614:	84aa                	mv	s1,a0
    80200616:	892e                	mv	s2,a1
    80200618:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    8020061c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    8020061e:	03067e63          	bleu	a6,a2,8020065a <printnum+0x60>
    80200622:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200624:	00805763          	blez	s0,80200632 <printnum+0x38>
    80200628:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020062a:	85ca                	mv	a1,s2
    8020062c:	854e                	mv	a0,s3
    8020062e:	9482                	jalr	s1
        while (-- width > 0)
    80200630:	fc65                	bnez	s0,80200628 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200632:	1a02                	slli	s4,s4,0x20
    80200634:	020a5a13          	srli	s4,s4,0x20
    80200638:	00001797          	auipc	a5,0x1
    8020063c:	be878793          	addi	a5,a5,-1048 # 80201220 <error_string+0x38>
    80200640:	9a3e                	add	s4,s4,a5
}
    80200642:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200644:	000a4503          	lbu	a0,0(s4)
}
    80200648:	70a2                	ld	ra,40(sp)
    8020064a:	69a2                	ld	s3,8(sp)
    8020064c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020064e:	85ca                	mv	a1,s2
    80200650:	8326                	mv	t1,s1
}
    80200652:	6942                	ld	s2,16(sp)
    80200654:	64e2                	ld	s1,24(sp)
    80200656:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200658:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020065a:	03065633          	divu	a2,a2,a6
    8020065e:	8722                	mv	a4,s0
    80200660:	f9bff0ef          	jal	ra,802005fa <printnum>
    80200664:	b7f9                	j	80200632 <printnum+0x38>

0000000080200666 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200666:	7119                	addi	sp,sp,-128
    80200668:	f4a6                	sd	s1,104(sp)
    8020066a:	f0ca                	sd	s2,96(sp)
    8020066c:	e8d2                	sd	s4,80(sp)
    8020066e:	e4d6                	sd	s5,72(sp)
    80200670:	e0da                	sd	s6,64(sp)
    80200672:	fc5e                	sd	s7,56(sp)
    80200674:	f862                	sd	s8,48(sp)
    80200676:	f06a                	sd	s10,32(sp)
    80200678:	fc86                	sd	ra,120(sp)
    8020067a:	f8a2                	sd	s0,112(sp)
    8020067c:	ecce                	sd	s3,88(sp)
    8020067e:	f466                	sd	s9,40(sp)
    80200680:	ec6e                	sd	s11,24(sp)
    80200682:	892a                	mv	s2,a0
    80200684:	84ae                	mv	s1,a1
    80200686:	8d32                	mv	s10,a2
    80200688:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020068a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    8020068c:	00001a17          	auipc	s4,0x1
    80200690:	a00a0a13          	addi	s4,s4,-1536 # 8020108c <etext+0x60e>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200694:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200698:	00001c17          	auipc	s8,0x1
    8020069c:	b50c0c13          	addi	s8,s8,-1200 # 802011e8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a0:	000d4503          	lbu	a0,0(s10)
    802006a4:	02500793          	li	a5,37
    802006a8:	001d0413          	addi	s0,s10,1
    802006ac:	00f50e63          	beq	a0,a5,802006c8 <vprintfmt+0x62>
            if (ch == '\0') {
    802006b0:	c521                	beqz	a0,802006f8 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006b2:	02500993          	li	s3,37
    802006b6:	a011                	j	802006ba <vprintfmt+0x54>
            if (ch == '\0') {
    802006b8:	c121                	beqz	a0,802006f8 <vprintfmt+0x92>
            putch(ch, putdat);
    802006ba:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006bc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006be:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006c0:	fff44503          	lbu	a0,-1(s0)
    802006c4:	ff351ae3          	bne	a0,s3,802006b8 <vprintfmt+0x52>
    802006c8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006cc:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006d0:	4981                	li	s3,0
    802006d2:	4801                	li	a6,0
        width = precision = -1;
    802006d4:	5cfd                	li	s9,-1
    802006d6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006d8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802006dc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006de:	fdd6069b          	addiw	a3,a2,-35
    802006e2:	0ff6f693          	andi	a3,a3,255
    802006e6:	00140d13          	addi	s10,s0,1
    802006ea:	20d5e563          	bltu	a1,a3,802008f4 <vprintfmt+0x28e>
    802006ee:	068a                	slli	a3,a3,0x2
    802006f0:	96d2                	add	a3,a3,s4
    802006f2:	4294                	lw	a3,0(a3)
    802006f4:	96d2                	add	a3,a3,s4
    802006f6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006f8:	70e6                	ld	ra,120(sp)
    802006fa:	7446                	ld	s0,112(sp)
    802006fc:	74a6                	ld	s1,104(sp)
    802006fe:	7906                	ld	s2,96(sp)
    80200700:	69e6                	ld	s3,88(sp)
    80200702:	6a46                	ld	s4,80(sp)
    80200704:	6aa6                	ld	s5,72(sp)
    80200706:	6b06                	ld	s6,64(sp)
    80200708:	7be2                	ld	s7,56(sp)
    8020070a:	7c42                	ld	s8,48(sp)
    8020070c:	7ca2                	ld	s9,40(sp)
    8020070e:	7d02                	ld	s10,32(sp)
    80200710:	6de2                	ld	s11,24(sp)
    80200712:	6109                	addi	sp,sp,128
    80200714:	8082                	ret
    if (lflag >= 2) {
    80200716:	4705                	li	a4,1
    80200718:	008a8593          	addi	a1,s5,8
    8020071c:	01074463          	blt	a4,a6,80200724 <vprintfmt+0xbe>
    else if (lflag) {
    80200720:	26080363          	beqz	a6,80200986 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200724:	000ab603          	ld	a2,0(s5)
    80200728:	46c1                	li	a3,16
    8020072a:	8aae                	mv	s5,a1
    8020072c:	a06d                	j	802007d6 <vprintfmt+0x170>
            goto reswitch;
    8020072e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200732:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200734:	846a                	mv	s0,s10
            goto reswitch;
    80200736:	b765                	j	802006de <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    80200738:	000aa503          	lw	a0,0(s5)
    8020073c:	85a6                	mv	a1,s1
    8020073e:	0aa1                	addi	s5,s5,8
    80200740:	9902                	jalr	s2
            break;
    80200742:	bfb9                	j	802006a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200744:	4705                	li	a4,1
    80200746:	008a8993          	addi	s3,s5,8
    8020074a:	01074463          	blt	a4,a6,80200752 <vprintfmt+0xec>
    else if (lflag) {
    8020074e:	22080463          	beqz	a6,80200976 <vprintfmt+0x310>
        return va_arg(*ap, long);
    80200752:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200756:	24044463          	bltz	s0,8020099e <vprintfmt+0x338>
            num = getint(&ap, lflag);
    8020075a:	8622                	mv	a2,s0
    8020075c:	8ace                	mv	s5,s3
    8020075e:	46a9                	li	a3,10
    80200760:	a89d                	j	802007d6 <vprintfmt+0x170>
            err = va_arg(ap, int);
    80200762:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200766:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200768:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020076a:	41f7d69b          	sraiw	a3,a5,0x1f
    8020076e:	8fb5                	xor	a5,a5,a3
    80200770:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200774:	1ad74363          	blt	a4,a3,8020091a <vprintfmt+0x2b4>
    80200778:	00369793          	slli	a5,a3,0x3
    8020077c:	97e2                	add	a5,a5,s8
    8020077e:	639c                	ld	a5,0(a5)
    80200780:	18078d63          	beqz	a5,8020091a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200784:	86be                	mv	a3,a5
    80200786:	00001617          	auipc	a2,0x1
    8020078a:	b4a60613          	addi	a2,a2,-1206 # 802012d0 <error_string+0xe8>
    8020078e:	85a6                	mv	a1,s1
    80200790:	854a                	mv	a0,s2
    80200792:	240000ef          	jal	ra,802009d2 <printfmt>
    80200796:	b729                	j	802006a0 <vprintfmt+0x3a>
            lflag ++;
    80200798:	00144603          	lbu	a2,1(s0)
    8020079c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020079e:	846a                	mv	s0,s10
            goto reswitch;
    802007a0:	bf3d                	j	802006de <vprintfmt+0x78>
    if (lflag >= 2) {
    802007a2:	4705                	li	a4,1
    802007a4:	008a8593          	addi	a1,s5,8
    802007a8:	01074463          	blt	a4,a6,802007b0 <vprintfmt+0x14a>
    else if (lflag) {
    802007ac:	1e080263          	beqz	a6,80200990 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    802007b0:	000ab603          	ld	a2,0(s5)
    802007b4:	46a1                	li	a3,8
    802007b6:	8aae                	mv	s5,a1
    802007b8:	a839                	j	802007d6 <vprintfmt+0x170>
            putch('0', putdat);
    802007ba:	03000513          	li	a0,48
    802007be:	85a6                	mv	a1,s1
    802007c0:	e03e                	sd	a5,0(sp)
    802007c2:	9902                	jalr	s2
            putch('x', putdat);
    802007c4:	85a6                	mv	a1,s1
    802007c6:	07800513          	li	a0,120
    802007ca:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007cc:	0aa1                	addi	s5,s5,8
    802007ce:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007d2:	6782                	ld	a5,0(sp)
    802007d4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007d6:	876e                	mv	a4,s11
    802007d8:	85a6                	mv	a1,s1
    802007da:	854a                	mv	a0,s2
    802007dc:	e1fff0ef          	jal	ra,802005fa <printnum>
            break;
    802007e0:	b5c1                	j	802006a0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007e2:	000ab603          	ld	a2,0(s5)
    802007e6:	0aa1                	addi	s5,s5,8
    802007e8:	1c060663          	beqz	a2,802009b4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802007ec:	00160413          	addi	s0,a2,1
    802007f0:	17b05c63          	blez	s11,80200968 <vprintfmt+0x302>
    802007f4:	02d00593          	li	a1,45
    802007f8:	14b79263          	bne	a5,a1,8020093c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007fc:	00064783          	lbu	a5,0(a2)
    80200800:	0007851b          	sext.w	a0,a5
    80200804:	c905                	beqz	a0,80200834 <vprintfmt+0x1ce>
    80200806:	000cc563          	bltz	s9,80200810 <vprintfmt+0x1aa>
    8020080a:	3cfd                	addiw	s9,s9,-1
    8020080c:	036c8263          	beq	s9,s6,80200830 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200810:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200812:	18098463          	beqz	s3,8020099a <vprintfmt+0x334>
    80200816:	3781                	addiw	a5,a5,-32
    80200818:	18fbf163          	bleu	a5,s7,8020099a <vprintfmt+0x334>
                    putch('?', putdat);
    8020081c:	03f00513          	li	a0,63
    80200820:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200822:	0405                	addi	s0,s0,1
    80200824:	fff44783          	lbu	a5,-1(s0)
    80200828:	3dfd                	addiw	s11,s11,-1
    8020082a:	0007851b          	sext.w	a0,a5
    8020082e:	fd61                	bnez	a0,80200806 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200830:	e7b058e3          	blez	s11,802006a0 <vprintfmt+0x3a>
    80200834:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200836:	85a6                	mv	a1,s1
    80200838:	02000513          	li	a0,32
    8020083c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020083e:	e60d81e3          	beqz	s11,802006a0 <vprintfmt+0x3a>
    80200842:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200844:	85a6                	mv	a1,s1
    80200846:	02000513          	li	a0,32
    8020084a:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020084c:	fe0d94e3          	bnez	s11,80200834 <vprintfmt+0x1ce>
    80200850:	bd81                	j	802006a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200852:	4705                	li	a4,1
    80200854:	008a8593          	addi	a1,s5,8
    80200858:	01074463          	blt	a4,a6,80200860 <vprintfmt+0x1fa>
    else if (lflag) {
    8020085c:	12080063          	beqz	a6,8020097c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200860:	000ab603          	ld	a2,0(s5)
    80200864:	46a9                	li	a3,10
    80200866:	8aae                	mv	s5,a1
    80200868:	b7bd                	j	802007d6 <vprintfmt+0x170>
    8020086a:	00144603          	lbu	a2,1(s0)
            padc = '-';
    8020086e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    80200872:	846a                	mv	s0,s10
    80200874:	b5ad                	j	802006de <vprintfmt+0x78>
            putch(ch, putdat);
    80200876:	85a6                	mv	a1,s1
    80200878:	02500513          	li	a0,37
    8020087c:	9902                	jalr	s2
            break;
    8020087e:	b50d                	j	802006a0 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200880:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200884:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200888:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020088a:	846a                	mv	s0,s10
            if (width < 0)
    8020088c:	e40dd9e3          	bgez	s11,802006de <vprintfmt+0x78>
                width = precision, precision = -1;
    80200890:	8de6                	mv	s11,s9
    80200892:	5cfd                	li	s9,-1
    80200894:	b5a9                	j	802006de <vprintfmt+0x78>
            goto reswitch;
    80200896:	00144603          	lbu	a2,1(s0)
            padc = '0';
    8020089a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    8020089e:	846a                	mv	s0,s10
            goto reswitch;
    802008a0:	bd3d                	j	802006de <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    802008a2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    802008a6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802008aa:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802008ac:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802008b0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008b4:	fcd56ce3          	bltu	a0,a3,8020088c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    802008b8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802008ba:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802008be:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008c2:	0196873b          	addw	a4,a3,s9
    802008c6:	0017171b          	slliw	a4,a4,0x1
    802008ca:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008ce:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008d2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802008d6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008da:	fcd57fe3          	bleu	a3,a0,802008b8 <vprintfmt+0x252>
    802008de:	b77d                	j	8020088c <vprintfmt+0x226>
            if (width < 0)
    802008e0:	fffdc693          	not	a3,s11
    802008e4:	96fd                	srai	a3,a3,0x3f
    802008e6:	00ddfdb3          	and	s11,s11,a3
    802008ea:	00144603          	lbu	a2,1(s0)
    802008ee:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802008f0:	846a                	mv	s0,s10
    802008f2:	b3f5                	j	802006de <vprintfmt+0x78>
            putch('%', putdat);
    802008f4:	85a6                	mv	a1,s1
    802008f6:	02500513          	li	a0,37
    802008fa:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802008fc:	fff44703          	lbu	a4,-1(s0)
    80200900:	02500793          	li	a5,37
    80200904:	8d22                	mv	s10,s0
    80200906:	d8f70de3          	beq	a4,a5,802006a0 <vprintfmt+0x3a>
    8020090a:	02500713          	li	a4,37
    8020090e:	1d7d                	addi	s10,s10,-1
    80200910:	fffd4783          	lbu	a5,-1(s10)
    80200914:	fee79de3          	bne	a5,a4,8020090e <vprintfmt+0x2a8>
    80200918:	b361                	j	802006a0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020091a:	00001617          	auipc	a2,0x1
    8020091e:	9a660613          	addi	a2,a2,-1626 # 802012c0 <error_string+0xd8>
    80200922:	85a6                	mv	a1,s1
    80200924:	854a                	mv	a0,s2
    80200926:	0ac000ef          	jal	ra,802009d2 <printfmt>
    8020092a:	bb9d                	j	802006a0 <vprintfmt+0x3a>
                p = "(null)";
    8020092c:	00001617          	auipc	a2,0x1
    80200930:	98c60613          	addi	a2,a2,-1652 # 802012b8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200934:	00001417          	auipc	s0,0x1
    80200938:	98540413          	addi	s0,s0,-1659 # 802012b9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020093c:	8532                	mv	a0,a2
    8020093e:	85e6                	mv	a1,s9
    80200940:	e032                	sd	a2,0(sp)
    80200942:	e43e                	sd	a5,8(sp)
    80200944:	102000ef          	jal	ra,80200a46 <strnlen>
    80200948:	40ad8dbb          	subw	s11,s11,a0
    8020094c:	6602                	ld	a2,0(sp)
    8020094e:	01b05d63          	blez	s11,80200968 <vprintfmt+0x302>
    80200952:	67a2                	ld	a5,8(sp)
    80200954:	2781                	sext.w	a5,a5
    80200956:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200958:	6522                	ld	a0,8(sp)
    8020095a:	85a6                	mv	a1,s1
    8020095c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020095e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200960:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200962:	6602                	ld	a2,0(sp)
    80200964:	fe0d9ae3          	bnez	s11,80200958 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200968:	00064783          	lbu	a5,0(a2)
    8020096c:	0007851b          	sext.w	a0,a5
    80200970:	e8051be3          	bnez	a0,80200806 <vprintfmt+0x1a0>
    80200974:	b335                	j	802006a0 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    80200976:	000aa403          	lw	s0,0(s5)
    8020097a:	bbf1                	j	80200756 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    8020097c:	000ae603          	lwu	a2,0(s5)
    80200980:	46a9                	li	a3,10
    80200982:	8aae                	mv	s5,a1
    80200984:	bd89                	j	802007d6 <vprintfmt+0x170>
    80200986:	000ae603          	lwu	a2,0(s5)
    8020098a:	46c1                	li	a3,16
    8020098c:	8aae                	mv	s5,a1
    8020098e:	b5a1                	j	802007d6 <vprintfmt+0x170>
    80200990:	000ae603          	lwu	a2,0(s5)
    80200994:	46a1                	li	a3,8
    80200996:	8aae                	mv	s5,a1
    80200998:	bd3d                	j	802007d6 <vprintfmt+0x170>
                    putch(ch, putdat);
    8020099a:	9902                	jalr	s2
    8020099c:	b559                	j	80200822 <vprintfmt+0x1bc>
                putch('-', putdat);
    8020099e:	85a6                	mv	a1,s1
    802009a0:	02d00513          	li	a0,45
    802009a4:	e03e                	sd	a5,0(sp)
    802009a6:	9902                	jalr	s2
                num = -(long long)num;
    802009a8:	8ace                	mv	s5,s3
    802009aa:	40800633          	neg	a2,s0
    802009ae:	46a9                	li	a3,10
    802009b0:	6782                	ld	a5,0(sp)
    802009b2:	b515                	j	802007d6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    802009b4:	01b05663          	blez	s11,802009c0 <vprintfmt+0x35a>
    802009b8:	02d00693          	li	a3,45
    802009bc:	f6d798e3          	bne	a5,a3,8020092c <vprintfmt+0x2c6>
    802009c0:	00001417          	auipc	s0,0x1
    802009c4:	8f940413          	addi	s0,s0,-1799 # 802012b9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009c8:	02800513          	li	a0,40
    802009cc:	02800793          	li	a5,40
    802009d0:	bd1d                	j	80200806 <vprintfmt+0x1a0>

00000000802009d2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009d2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009d4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009d8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009da:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009dc:	ec06                	sd	ra,24(sp)
    802009de:	f83a                	sd	a4,48(sp)
    802009e0:	fc3e                	sd	a5,56(sp)
    802009e2:	e0c2                	sd	a6,64(sp)
    802009e4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009e6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009e8:	c7fff0ef          	jal	ra,80200666 <vprintfmt>
}
    802009ec:	60e2                	ld	ra,24(sp)
    802009ee:	6161                	addi	sp,sp,80
    802009f0:	8082                	ret

00000000802009f2 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009f2:	00003797          	auipc	a5,0x3
    802009f6:	60e78793          	addi	a5,a5,1550 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009fa:	6398                	ld	a4,0(a5)
    802009fc:	4781                	li	a5,0
    802009fe:	88ba                	mv	a7,a4
    80200a00:	852a                	mv	a0,a0
    80200a02:	85be                	mv	a1,a5
    80200a04:	863e                	mv	a2,a5
    80200a06:	00000073          	ecall
    80200a0a:	87aa                	mv	a5,a0
}
    80200a0c:	8082                	ret

0000000080200a0e <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200a0e:	00003797          	auipc	a5,0x3
    80200a12:	60a78793          	addi	a5,a5,1546 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200a16:	6398                	ld	a4,0(a5)
    80200a18:	4781                	li	a5,0
    80200a1a:	88ba                	mv	a7,a4
    80200a1c:	852a                	mv	a0,a0
    80200a1e:	85be                	mv	a1,a5
    80200a20:	863e                	mv	a2,a5
    80200a22:	00000073          	ecall
    80200a26:	87aa                	mv	a5,a0
}
    80200a28:	8082                	ret

0000000080200a2a <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a2a:	00003797          	auipc	a5,0x3
    80200a2e:	5de78793          	addi	a5,a5,1502 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a32:	6398                	ld	a4,0(a5)
    80200a34:	4781                	li	a5,0
    80200a36:	88ba                	mv	a7,a4
    80200a38:	853e                	mv	a0,a5
    80200a3a:	85be                	mv	a1,a5
    80200a3c:	863e                	mv	a2,a5
    80200a3e:	00000073          	ecall
    80200a42:	87aa                	mv	a5,a0
    80200a44:	8082                	ret

0000000080200a46 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200a46:	c185                	beqz	a1,80200a66 <strnlen+0x20>
    80200a48:	00054783          	lbu	a5,0(a0)
    80200a4c:	cf89                	beqz	a5,80200a66 <strnlen+0x20>
    size_t cnt = 0;
    80200a4e:	4781                	li	a5,0
    80200a50:	a021                	j	80200a58 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a52:	00074703          	lbu	a4,0(a4)
    80200a56:	c711                	beqz	a4,80200a62 <strnlen+0x1c>
        cnt ++;
    80200a58:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a5a:	00f50733          	add	a4,a0,a5
    80200a5e:	fef59ae3          	bne	a1,a5,80200a52 <strnlen+0xc>
    }
    return cnt;
}
    80200a62:	853e                	mv	a0,a5
    80200a64:	8082                	ret
    size_t cnt = 0;
    80200a66:	4781                	li	a5,0
}
    80200a68:	853e                	mv	a0,a5
    80200a6a:	8082                	ret

0000000080200a6c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a6c:	ca01                	beqz	a2,80200a7c <memset+0x10>
    80200a6e:	962a                	add	a2,a2,a0
    char *p = s;
    80200a70:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a72:	0785                	addi	a5,a5,1
    80200a74:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a78:	fec79de3          	bne	a5,a2,80200a72 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a7c:	8082                	ret
