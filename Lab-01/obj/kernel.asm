
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
    80200024:	24d000ef          	jal	ra,80200a70 <memset>

    cons_init();  // init the console
    80200028:	15e000ef          	jal	ra,80200186 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a5c58593          	addi	a1,a1,-1444 # 80200a88 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a7450513          	addi	a0,a0,-1420 # 80200aa8 <etext+0x26>
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
    8020005a:	a5a50513          	addi	a0,a0,-1446 # 80200ab0 <etext+0x2e>
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
    802000a6:	5c4000ef          	jal	ra,8020066a <vprintfmt>
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
    802000b8:	a0c50513          	addi	a0,a0,-1524 # 80200ac0 <etext+0x3e>
void print_kerninfo(void) {
    802000bc:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000be:	fc1ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000c2:	00000597          	auipc	a1,0x0
    802000c6:	f4a58593          	addi	a1,a1,-182 # 8020000c <kern_init>
    802000ca:	00001517          	auipc	a0,0x1
    802000ce:	a1650513          	addi	a0,a0,-1514 # 80200ae0 <etext+0x5e>
    802000d2:	fadff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000d6:	00001597          	auipc	a1,0x1
    802000da:	9ac58593          	addi	a1,a1,-1620 # 80200a82 <etext>
    802000de:	00001517          	auipc	a0,0x1
    802000e2:	a2250513          	addi	a0,a0,-1502 # 80200b00 <etext+0x7e>
    802000e6:	f99ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000ea:	00004597          	auipc	a1,0x4
    802000ee:	f2658593          	addi	a1,a1,-218 # 80204010 <edata>
    802000f2:	00001517          	auipc	a0,0x1
    802000f6:	a2e50513          	addi	a0,a0,-1490 # 80200b20 <etext+0x9e>
    802000fa:	f85ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000fe:	00004597          	auipc	a1,0x4
    80200102:	f2a58593          	addi	a1,a1,-214 # 80204028 <end>
    80200106:	00001517          	auipc	a0,0x1
    8020010a:	a3a50513          	addi	a0,a0,-1478 # 80200b40 <etext+0xbe>
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
    80200138:	a2c50513          	addi	a0,a0,-1492 # 80200b60 <etext+0xde>
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
    8020015a:	0b9000ef          	jal	ra,80200a12 <sbi_set_timer>
}
    8020015e:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200160:	00004797          	auipc	a5,0x4
    80200164:	ec07b023          	sd	zero,-320(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200168:	00001517          	auipc	a0,0x1
    8020016c:	a2850513          	addi	a0,a0,-1496 # 80200b90 <etext+0x10e>
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
    80200182:	0910006f          	j	80200a12 <sbi_set_timer>

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
    8020018c:	06b0006f          	j	802009f6 <sbi_console_putchar>

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
    8020019e:	3ae78793          	addi	a5,a5,942 # 80200548 <__alltraps>
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
    802001b4:	b7050513          	addi	a0,a0,-1168 # 80200d20 <etext+0x29e>
void print_regs(struct pushregs *gpr) {
    802001b8:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001ba:	ec5ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001be:	640c                	ld	a1,8(s0)
    802001c0:	00001517          	auipc	a0,0x1
    802001c4:	b7850513          	addi	a0,a0,-1160 # 80200d38 <etext+0x2b6>
    802001c8:	eb7ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001cc:	680c                	ld	a1,16(s0)
    802001ce:	00001517          	auipc	a0,0x1
    802001d2:	b8250513          	addi	a0,a0,-1150 # 80200d50 <etext+0x2ce>
    802001d6:	ea9ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001da:	6c0c                	ld	a1,24(s0)
    802001dc:	00001517          	auipc	a0,0x1
    802001e0:	b8c50513          	addi	a0,a0,-1140 # 80200d68 <etext+0x2e6>
    802001e4:	e9bff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001e8:	700c                	ld	a1,32(s0)
    802001ea:	00001517          	auipc	a0,0x1
    802001ee:	b9650513          	addi	a0,a0,-1130 # 80200d80 <etext+0x2fe>
    802001f2:	e8dff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001f6:	740c                	ld	a1,40(s0)
    802001f8:	00001517          	auipc	a0,0x1
    802001fc:	ba050513          	addi	a0,a0,-1120 # 80200d98 <etext+0x316>
    80200200:	e7fff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    80200204:	780c                	ld	a1,48(s0)
    80200206:	00001517          	auipc	a0,0x1
    8020020a:	baa50513          	addi	a0,a0,-1110 # 80200db0 <etext+0x32e>
    8020020e:	e71ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200212:	7c0c                	ld	a1,56(s0)
    80200214:	00001517          	auipc	a0,0x1
    80200218:	bb450513          	addi	a0,a0,-1100 # 80200dc8 <etext+0x346>
    8020021c:	e63ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200220:	602c                	ld	a1,64(s0)
    80200222:	00001517          	auipc	a0,0x1
    80200226:	bbe50513          	addi	a0,a0,-1090 # 80200de0 <etext+0x35e>
    8020022a:	e55ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020022e:	642c                	ld	a1,72(s0)
    80200230:	00001517          	auipc	a0,0x1
    80200234:	bc850513          	addi	a0,a0,-1080 # 80200df8 <etext+0x376>
    80200238:	e47ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020023c:	682c                	ld	a1,80(s0)
    8020023e:	00001517          	auipc	a0,0x1
    80200242:	bd250513          	addi	a0,a0,-1070 # 80200e10 <etext+0x38e>
    80200246:	e39ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020024a:	6c2c                	ld	a1,88(s0)
    8020024c:	00001517          	auipc	a0,0x1
    80200250:	bdc50513          	addi	a0,a0,-1060 # 80200e28 <etext+0x3a6>
    80200254:	e2bff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200258:	702c                	ld	a1,96(s0)
    8020025a:	00001517          	auipc	a0,0x1
    8020025e:	be650513          	addi	a0,a0,-1050 # 80200e40 <etext+0x3be>
    80200262:	e1dff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200266:	742c                	ld	a1,104(s0)
    80200268:	00001517          	auipc	a0,0x1
    8020026c:	bf050513          	addi	a0,a0,-1040 # 80200e58 <etext+0x3d6>
    80200270:	e0fff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200274:	782c                	ld	a1,112(s0)
    80200276:	00001517          	auipc	a0,0x1
    8020027a:	bfa50513          	addi	a0,a0,-1030 # 80200e70 <etext+0x3ee>
    8020027e:	e01ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200282:	7c2c                	ld	a1,120(s0)
    80200284:	00001517          	auipc	a0,0x1
    80200288:	c0450513          	addi	a0,a0,-1020 # 80200e88 <etext+0x406>
    8020028c:	df3ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200290:	604c                	ld	a1,128(s0)
    80200292:	00001517          	auipc	a0,0x1
    80200296:	c0e50513          	addi	a0,a0,-1010 # 80200ea0 <etext+0x41e>
    8020029a:	de5ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020029e:	644c                	ld	a1,136(s0)
    802002a0:	00001517          	auipc	a0,0x1
    802002a4:	c1850513          	addi	a0,a0,-1000 # 80200eb8 <etext+0x436>
    802002a8:	dd7ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    802002ac:	684c                	ld	a1,144(s0)
    802002ae:	00001517          	auipc	a0,0x1
    802002b2:	c2250513          	addi	a0,a0,-990 # 80200ed0 <etext+0x44e>
    802002b6:	dc9ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002ba:	6c4c                	ld	a1,152(s0)
    802002bc:	00001517          	auipc	a0,0x1
    802002c0:	c2c50513          	addi	a0,a0,-980 # 80200ee8 <etext+0x466>
    802002c4:	dbbff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002c8:	704c                	ld	a1,160(s0)
    802002ca:	00001517          	auipc	a0,0x1
    802002ce:	c3650513          	addi	a0,a0,-970 # 80200f00 <etext+0x47e>
    802002d2:	dadff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002d6:	744c                	ld	a1,168(s0)
    802002d8:	00001517          	auipc	a0,0x1
    802002dc:	c4050513          	addi	a0,a0,-960 # 80200f18 <etext+0x496>
    802002e0:	d9fff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002e4:	784c                	ld	a1,176(s0)
    802002e6:	00001517          	auipc	a0,0x1
    802002ea:	c4a50513          	addi	a0,a0,-950 # 80200f30 <etext+0x4ae>
    802002ee:	d91ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002f2:	7c4c                	ld	a1,184(s0)
    802002f4:	00001517          	auipc	a0,0x1
    802002f8:	c5450513          	addi	a0,a0,-940 # 80200f48 <etext+0x4c6>
    802002fc:	d83ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    80200300:	606c                	ld	a1,192(s0)
    80200302:	00001517          	auipc	a0,0x1
    80200306:	c5e50513          	addi	a0,a0,-930 # 80200f60 <etext+0x4de>
    8020030a:	d75ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    8020030e:	646c                	ld	a1,200(s0)
    80200310:	00001517          	auipc	a0,0x1
    80200314:	c6850513          	addi	a0,a0,-920 # 80200f78 <etext+0x4f6>
    80200318:	d67ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020031c:	686c                	ld	a1,208(s0)
    8020031e:	00001517          	auipc	a0,0x1
    80200322:	c7250513          	addi	a0,a0,-910 # 80200f90 <etext+0x50e>
    80200326:	d59ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020032a:	6c6c                	ld	a1,216(s0)
    8020032c:	00001517          	auipc	a0,0x1
    80200330:	c7c50513          	addi	a0,a0,-900 # 80200fa8 <etext+0x526>
    80200334:	d4bff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200338:	706c                	ld	a1,224(s0)
    8020033a:	00001517          	auipc	a0,0x1
    8020033e:	c8650513          	addi	a0,a0,-890 # 80200fc0 <etext+0x53e>
    80200342:	d3dff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200346:	746c                	ld	a1,232(s0)
    80200348:	00001517          	auipc	a0,0x1
    8020034c:	c9050513          	addi	a0,a0,-880 # 80200fd8 <etext+0x556>
    80200350:	d2fff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200354:	786c                	ld	a1,240(s0)
    80200356:	00001517          	auipc	a0,0x1
    8020035a:	c9a50513          	addi	a0,a0,-870 # 80200ff0 <etext+0x56e>
    8020035e:	d21ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200362:	7c6c                	ld	a1,248(s0)
}
    80200364:	6402                	ld	s0,0(sp)
    80200366:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200368:	00001517          	auipc	a0,0x1
    8020036c:	ca050513          	addi	a0,a0,-864 # 80201008 <etext+0x586>
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
    80200382:	ca250513          	addi	a0,a0,-862 # 80201020 <etext+0x59e>
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
    8020039a:	ca250513          	addi	a0,a0,-862 # 80201038 <etext+0x5b6>
    8020039e:	ce1ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    802003a2:	10843583          	ld	a1,264(s0)
    802003a6:	00001517          	auipc	a0,0x1
    802003aa:	caa50513          	addi	a0,a0,-854 # 80201050 <etext+0x5ce>
    802003ae:	cd1ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003b2:	11043583          	ld	a1,272(s0)
    802003b6:	00001517          	auipc	a0,0x1
    802003ba:	cb250513          	addi	a0,a0,-846 # 80201068 <etext+0x5e6>
    802003be:	cc1ff0ef          	jal	ra,8020007e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	11843583          	ld	a1,280(s0)
}
    802003c6:	6402                	ld	s0,0(sp)
    802003c8:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ca:	00001517          	auipc	a0,0x1
    802003ce:	cb650513          	addi	a0,a0,-842 # 80201080 <etext+0x5fe>
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
    802003e4:	06f76f63          	bltu	a4,a5,80200462 <interrupt_handler+0x8a>
    802003e8:	00000717          	auipc	a4,0x0
    802003ec:	7c470713          	addi	a4,a4,1988 # 80200bac <etext+0x12a>
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
    802003fe:	8d650513          	addi	a0,a0,-1834 # 80200cd0 <etext+0x24e>
    80200402:	c7dff06f          	j	8020007e <cprintf>
            cprintf("Hypervisor software interrupt\n");
    80200406:	00001517          	auipc	a0,0x1
    8020040a:	8aa50513          	addi	a0,a0,-1878 # 80200cb0 <etext+0x22e>
    8020040e:	c71ff06f          	j	8020007e <cprintf>
            cprintf("User software interrupt\n");
    80200412:	00001517          	auipc	a0,0x1
    80200416:	85e50513          	addi	a0,a0,-1954 # 80200c70 <etext+0x1ee>
    8020041a:	c65ff06f          	j	8020007e <cprintf>
            cprintf("Supervisor software interrupt\n");
    8020041e:	00001517          	auipc	a0,0x1
    80200422:	87250513          	addi	a0,a0,-1934 # 80200c90 <etext+0x20e>
    80200426:	c59ff06f          	j	8020007e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020042a:	00001517          	auipc	a0,0x1
    8020042e:	8d650513          	addi	a0,a0,-1834 # 80200d00 <etext+0x27e>
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
            if (ticks == TICK_NUM) { // 当计数器加到100的时候
    80200448:	06400693          	li	a3,100
            ticks++; // 计数器加一
    8020044c:	0785                	addi	a5,a5,1
    8020044e:	00004617          	auipc	a2,0x4
    80200452:	bcf63923          	sd	a5,-1070(a2) # 80204020 <ticks>
            if (ticks == TICK_NUM) { // 当计数器加到100的时候
    80200456:	631c                	ld	a5,0(a4)
    80200458:	00d78763          	beq	a5,a3,80200466 <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020045c:	60a2                	ld	ra,8(sp)
    8020045e:	0141                	addi	sp,sp,16
    80200460:	8082                	ret
            print_trapframe(tf);
    80200462:	f15ff06f          	j	80200376 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200466:	06400593          	li	a1,100
    8020046a:	00001517          	auipc	a0,0x1
    8020046e:	88650513          	addi	a0,a0,-1914 # 80200cf0 <etext+0x26e>
    80200472:	c0dff0ef          	jal	ra,8020007e <cprintf>
                num++; // 同时打印次数（num）加一
    80200476:	00004717          	auipc	a4,0x4
    8020047a:	b9a70713          	addi	a4,a4,-1126 # 80204010 <edata>
    8020047e:	631c                	ld	a5,0(a4)
                if (num == 10) { // 判断打印次数，当打印次数为10时
    80200480:	46a9                	li	a3,10
                num++; // 同时打印次数（num）加一
    80200482:	0785                	addi	a5,a5,1
    80200484:	00004617          	auipc	a2,0x4
    80200488:	b8f63623          	sd	a5,-1140(a2) # 80204010 <edata>
                ticks = 0; // 计数器清零
    8020048c:	00004797          	auipc	a5,0x4
    80200490:	b807ba23          	sd	zero,-1132(a5) # 80204020 <ticks>
                if (num == 10) { // 判断打印次数，当打印次数为10时
    80200494:	631c                	ld	a5,0(a4)
    80200496:	fcd793e3          	bne	a5,a3,8020045c <interrupt_handler+0x84>
}
    8020049a:	60a2                	ld	ra,8(sp)
    8020049c:	0141                	addi	sp,sp,16
                    sbi_shutdown(); // 调用<sbi.h>中的关机函数sbi_shutdown()关机
    8020049e:	5900006f          	j	80200a2e <sbi_shutdown>

00000000802004a2 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    802004a2:	11853783          	ld	a5,280(a0)
    802004a6:	472d                	li	a4,11
    802004a8:	02f76863          	bltu	a4,a5,802004d8 <exception_handler+0x36>
    802004ac:	4705                	li	a4,1
    802004ae:	00f71733          	sll	a4,a4,a5
    802004b2:	6785                	lui	a5,0x1
    802004b4:	17cd                	addi	a5,a5,-13
    802004b6:	8ff9                	and	a5,a5,a4
    802004b8:	ef99                	bnez	a5,802004d6 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004ba:	1141                	addi	sp,sp,-16
    802004bc:	e022                	sd	s0,0(sp)
    802004be:	e406                	sd	ra,8(sp)
    802004c0:	00877793          	andi	a5,a4,8
    802004c4:	842a                	mv	s0,a0
    802004c6:	e3b1                	bnez	a5,8020050a <exception_handler+0x68>
    802004c8:	8b11                	andi	a4,a4,4
    802004ca:	eb09                	bnez	a4,802004dc <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004cc:	6402                	ld	s0,0(sp)
    802004ce:	60a2                	ld	ra,8(sp)
    802004d0:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004d2:	ea5ff06f          	j	80200376 <print_trapframe>
    802004d6:	8082                	ret
    802004d8:	e9fff06f          	j	80200376 <print_trapframe>
            cprintf("Exception type: Illegal instruction\n");
    802004dc:	00000517          	auipc	a0,0x0
    802004e0:	70450513          	addi	a0,a0,1796 # 80200be0 <etext+0x15e>
    802004e4:	b9bff0ef          	jal	ra,8020007e <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    802004e8:	10843583          	ld	a1,264(s0)
    802004ec:	00000517          	auipc	a0,0x0
    802004f0:	71c50513          	addi	a0,a0,1820 # 80200c08 <etext+0x186>
    802004f4:	b8bff0ef          	jal	ra,8020007e <cprintf>
            tf->epc += 4; // 指令长度 4 字节
    802004f8:	10843783          	ld	a5,264(s0)
}
    802004fc:	60a2                	ld	ra,8(sp)
            tf->epc += 4; // 指令长度 4 字节
    802004fe:	0791                	addi	a5,a5,4
    80200500:	10f43423          	sd	a5,264(s0)
}
    80200504:	6402                	ld	s0,0(sp)
    80200506:	0141                	addi	sp,sp,16
    80200508:	8082                	ret
            cprintf("Exception type: breakpoint\n");
    8020050a:	00000517          	auipc	a0,0x0
    8020050e:	72650513          	addi	a0,a0,1830 # 80200c30 <etext+0x1ae>
    80200512:	b6dff0ef          	jal	ra,8020007e <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
    80200516:	10843583          	ld	a1,264(s0)
    8020051a:	00000517          	auipc	a0,0x0
    8020051e:	73650513          	addi	a0,a0,1846 # 80200c50 <etext+0x1ce>
    80200522:	b5dff0ef          	jal	ra,8020007e <cprintf>
            tf->epc += 2; // 指令长度 2 字节
    80200526:	10843783          	ld	a5,264(s0)
}
    8020052a:	60a2                	ld	ra,8(sp)
            tf->epc += 2; // 指令长度 2 字节
    8020052c:	0789                	addi	a5,a5,2
    8020052e:	10f43423          	sd	a5,264(s0)
}
    80200532:	6402                	ld	s0,0(sp)
    80200534:	0141                	addi	sp,sp,16
    80200536:	8082                	ret

0000000080200538 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200538:	11853783          	ld	a5,280(a0)
    8020053c:	0007c463          	bltz	a5,80200544 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200540:	f63ff06f          	j	802004a2 <exception_handler>
        interrupt_handler(tf);
    80200544:	e95ff06f          	j	802003d8 <interrupt_handler>

0000000080200548 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200548:	14011073          	csrw	sscratch,sp
    8020054c:	712d                	addi	sp,sp,-288
    8020054e:	e002                	sd	zero,0(sp)
    80200550:	e406                	sd	ra,8(sp)
    80200552:	ec0e                	sd	gp,24(sp)
    80200554:	f012                	sd	tp,32(sp)
    80200556:	f416                	sd	t0,40(sp)
    80200558:	f81a                	sd	t1,48(sp)
    8020055a:	fc1e                	sd	t2,56(sp)
    8020055c:	e0a2                	sd	s0,64(sp)
    8020055e:	e4a6                	sd	s1,72(sp)
    80200560:	e8aa                	sd	a0,80(sp)
    80200562:	ecae                	sd	a1,88(sp)
    80200564:	f0b2                	sd	a2,96(sp)
    80200566:	f4b6                	sd	a3,104(sp)
    80200568:	f8ba                	sd	a4,112(sp)
    8020056a:	fcbe                	sd	a5,120(sp)
    8020056c:	e142                	sd	a6,128(sp)
    8020056e:	e546                	sd	a7,136(sp)
    80200570:	e94a                	sd	s2,144(sp)
    80200572:	ed4e                	sd	s3,152(sp)
    80200574:	f152                	sd	s4,160(sp)
    80200576:	f556                	sd	s5,168(sp)
    80200578:	f95a                	sd	s6,176(sp)
    8020057a:	fd5e                	sd	s7,184(sp)
    8020057c:	e1e2                	sd	s8,192(sp)
    8020057e:	e5e6                	sd	s9,200(sp)
    80200580:	e9ea                	sd	s10,208(sp)
    80200582:	edee                	sd	s11,216(sp)
    80200584:	f1f2                	sd	t3,224(sp)
    80200586:	f5f6                	sd	t4,232(sp)
    80200588:	f9fa                	sd	t5,240(sp)
    8020058a:	fdfe                	sd	t6,248(sp)
    8020058c:	14001473          	csrrw	s0,sscratch,zero
    80200590:	100024f3          	csrr	s1,sstatus
    80200594:	14102973          	csrr	s2,sepc
    80200598:	143029f3          	csrr	s3,stval
    8020059c:	14202a73          	csrr	s4,scause
    802005a0:	e822                	sd	s0,16(sp)
    802005a2:	e226                	sd	s1,256(sp)
    802005a4:	e64a                	sd	s2,264(sp)
    802005a6:	ea4e                	sd	s3,272(sp)
    802005a8:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802005aa:	850a                	mv	a0,sp
    jal trap
    802005ac:	f8dff0ef          	jal	ra,80200538 <trap>

00000000802005b0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802005b0:	6492                	ld	s1,256(sp)
    802005b2:	6932                	ld	s2,264(sp)
    802005b4:	10049073          	csrw	sstatus,s1
    802005b8:	14191073          	csrw	sepc,s2
    802005bc:	60a2                	ld	ra,8(sp)
    802005be:	61e2                	ld	gp,24(sp)
    802005c0:	7202                	ld	tp,32(sp)
    802005c2:	72a2                	ld	t0,40(sp)
    802005c4:	7342                	ld	t1,48(sp)
    802005c6:	73e2                	ld	t2,56(sp)
    802005c8:	6406                	ld	s0,64(sp)
    802005ca:	64a6                	ld	s1,72(sp)
    802005cc:	6546                	ld	a0,80(sp)
    802005ce:	65e6                	ld	a1,88(sp)
    802005d0:	7606                	ld	a2,96(sp)
    802005d2:	76a6                	ld	a3,104(sp)
    802005d4:	7746                	ld	a4,112(sp)
    802005d6:	77e6                	ld	a5,120(sp)
    802005d8:	680a                	ld	a6,128(sp)
    802005da:	68aa                	ld	a7,136(sp)
    802005dc:	694a                	ld	s2,144(sp)
    802005de:	69ea                	ld	s3,152(sp)
    802005e0:	7a0a                	ld	s4,160(sp)
    802005e2:	7aaa                	ld	s5,168(sp)
    802005e4:	7b4a                	ld	s6,176(sp)
    802005e6:	7bea                	ld	s7,184(sp)
    802005e8:	6c0e                	ld	s8,192(sp)
    802005ea:	6cae                	ld	s9,200(sp)
    802005ec:	6d4e                	ld	s10,208(sp)
    802005ee:	6dee                	ld	s11,216(sp)
    802005f0:	7e0e                	ld	t3,224(sp)
    802005f2:	7eae                	ld	t4,232(sp)
    802005f4:	7f4e                	ld	t5,240(sp)
    802005f6:	7fee                	ld	t6,248(sp)
    802005f8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005fa:	10200073          	sret

00000000802005fe <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005fe:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200602:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200604:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200608:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020060a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    8020060e:	f022                	sd	s0,32(sp)
    80200610:	ec26                	sd	s1,24(sp)
    80200612:	e84a                	sd	s2,16(sp)
    80200614:	f406                	sd	ra,40(sp)
    80200616:	e44e                	sd	s3,8(sp)
    80200618:	84aa                	mv	s1,a0
    8020061a:	892e                	mv	s2,a1
    8020061c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200620:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    80200622:	03067e63          	bleu	a6,a2,8020065e <printnum+0x60>
    80200626:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200628:	00805763          	blez	s0,80200636 <printnum+0x38>
    8020062c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020062e:	85ca                	mv	a1,s2
    80200630:	854e                	mv	a0,s3
    80200632:	9482                	jalr	s1
        while (-- width > 0)
    80200634:	fc65                	bnez	s0,8020062c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200636:	1a02                	slli	s4,s4,0x20
    80200638:	020a5a13          	srli	s4,s4,0x20
    8020063c:	00001797          	auipc	a5,0x1
    80200640:	bec78793          	addi	a5,a5,-1044 # 80201228 <error_string+0x38>
    80200644:	9a3e                	add	s4,s4,a5
}
    80200646:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200648:	000a4503          	lbu	a0,0(s4)
}
    8020064c:	70a2                	ld	ra,40(sp)
    8020064e:	69a2                	ld	s3,8(sp)
    80200650:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200652:	85ca                	mv	a1,s2
    80200654:	8326                	mv	t1,s1
}
    80200656:	6942                	ld	s2,16(sp)
    80200658:	64e2                	ld	s1,24(sp)
    8020065a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020065c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020065e:	03065633          	divu	a2,a2,a6
    80200662:	8722                	mv	a4,s0
    80200664:	f9bff0ef          	jal	ra,802005fe <printnum>
    80200668:	b7f9                	j	80200636 <printnum+0x38>

000000008020066a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020066a:	7119                	addi	sp,sp,-128
    8020066c:	f4a6                	sd	s1,104(sp)
    8020066e:	f0ca                	sd	s2,96(sp)
    80200670:	e8d2                	sd	s4,80(sp)
    80200672:	e4d6                	sd	s5,72(sp)
    80200674:	e0da                	sd	s6,64(sp)
    80200676:	fc5e                	sd	s7,56(sp)
    80200678:	f862                	sd	s8,48(sp)
    8020067a:	f06a                	sd	s10,32(sp)
    8020067c:	fc86                	sd	ra,120(sp)
    8020067e:	f8a2                	sd	s0,112(sp)
    80200680:	ecce                	sd	s3,88(sp)
    80200682:	f466                	sd	s9,40(sp)
    80200684:	ec6e                	sd	s11,24(sp)
    80200686:	892a                	mv	s2,a0
    80200688:	84ae                	mv	s1,a1
    8020068a:	8d32                	mv	s10,a2
    8020068c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020068e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200690:	00001a17          	auipc	s4,0x1
    80200694:	a04a0a13          	addi	s4,s4,-1532 # 80201094 <etext+0x612>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200698:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020069c:	00001c17          	auipc	s8,0x1
    802006a0:	b54c0c13          	addi	s8,s8,-1196 # 802011f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a4:	000d4503          	lbu	a0,0(s10)
    802006a8:	02500793          	li	a5,37
    802006ac:	001d0413          	addi	s0,s10,1
    802006b0:	00f50e63          	beq	a0,a5,802006cc <vprintfmt+0x62>
            if (ch == '\0') {
    802006b4:	c521                	beqz	a0,802006fc <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006b6:	02500993          	li	s3,37
    802006ba:	a011                	j	802006be <vprintfmt+0x54>
            if (ch == '\0') {
    802006bc:	c121                	beqz	a0,802006fc <vprintfmt+0x92>
            putch(ch, putdat);
    802006be:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006c0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006c2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006c4:	fff44503          	lbu	a0,-1(s0)
    802006c8:	ff351ae3          	bne	a0,s3,802006bc <vprintfmt+0x52>
    802006cc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006d0:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006d4:	4981                	li	s3,0
    802006d6:	4801                	li	a6,0
        width = precision = -1;
    802006d8:	5cfd                	li	s9,-1
    802006da:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006dc:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802006e0:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006e2:	fdd6069b          	addiw	a3,a2,-35
    802006e6:	0ff6f693          	andi	a3,a3,255
    802006ea:	00140d13          	addi	s10,s0,1
    802006ee:	20d5e563          	bltu	a1,a3,802008f8 <vprintfmt+0x28e>
    802006f2:	068a                	slli	a3,a3,0x2
    802006f4:	96d2                	add	a3,a3,s4
    802006f6:	4294                	lw	a3,0(a3)
    802006f8:	96d2                	add	a3,a3,s4
    802006fa:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006fc:	70e6                	ld	ra,120(sp)
    802006fe:	7446                	ld	s0,112(sp)
    80200700:	74a6                	ld	s1,104(sp)
    80200702:	7906                	ld	s2,96(sp)
    80200704:	69e6                	ld	s3,88(sp)
    80200706:	6a46                	ld	s4,80(sp)
    80200708:	6aa6                	ld	s5,72(sp)
    8020070a:	6b06                	ld	s6,64(sp)
    8020070c:	7be2                	ld	s7,56(sp)
    8020070e:	7c42                	ld	s8,48(sp)
    80200710:	7ca2                	ld	s9,40(sp)
    80200712:	7d02                	ld	s10,32(sp)
    80200714:	6de2                	ld	s11,24(sp)
    80200716:	6109                	addi	sp,sp,128
    80200718:	8082                	ret
    if (lflag >= 2) {
    8020071a:	4705                	li	a4,1
    8020071c:	008a8593          	addi	a1,s5,8
    80200720:	01074463          	blt	a4,a6,80200728 <vprintfmt+0xbe>
    else if (lflag) {
    80200724:	26080363          	beqz	a6,8020098a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200728:	000ab603          	ld	a2,0(s5)
    8020072c:	46c1                	li	a3,16
    8020072e:	8aae                	mv	s5,a1
    80200730:	a06d                	j	802007da <vprintfmt+0x170>
            goto reswitch;
    80200732:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200736:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200738:	846a                	mv	s0,s10
            goto reswitch;
    8020073a:	b765                	j	802006e2 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    8020073c:	000aa503          	lw	a0,0(s5)
    80200740:	85a6                	mv	a1,s1
    80200742:	0aa1                	addi	s5,s5,8
    80200744:	9902                	jalr	s2
            break;
    80200746:	bfb9                	j	802006a4 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200748:	4705                	li	a4,1
    8020074a:	008a8993          	addi	s3,s5,8
    8020074e:	01074463          	blt	a4,a6,80200756 <vprintfmt+0xec>
    else if (lflag) {
    80200752:	22080463          	beqz	a6,8020097a <vprintfmt+0x310>
        return va_arg(*ap, long);
    80200756:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    8020075a:	24044463          	bltz	s0,802009a2 <vprintfmt+0x338>
            num = getint(&ap, lflag);
    8020075e:	8622                	mv	a2,s0
    80200760:	8ace                	mv	s5,s3
    80200762:	46a9                	li	a3,10
    80200764:	a89d                	j	802007da <vprintfmt+0x170>
            err = va_arg(ap, int);
    80200766:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020076a:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020076c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020076e:	41f7d69b          	sraiw	a3,a5,0x1f
    80200772:	8fb5                	xor	a5,a5,a3
    80200774:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200778:	1ad74363          	blt	a4,a3,8020091e <vprintfmt+0x2b4>
    8020077c:	00369793          	slli	a5,a3,0x3
    80200780:	97e2                	add	a5,a5,s8
    80200782:	639c                	ld	a5,0(a5)
    80200784:	18078d63          	beqz	a5,8020091e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200788:	86be                	mv	a3,a5
    8020078a:	00001617          	auipc	a2,0x1
    8020078e:	b4e60613          	addi	a2,a2,-1202 # 802012d8 <error_string+0xe8>
    80200792:	85a6                	mv	a1,s1
    80200794:	854a                	mv	a0,s2
    80200796:	240000ef          	jal	ra,802009d6 <printfmt>
    8020079a:	b729                	j	802006a4 <vprintfmt+0x3a>
            lflag ++;
    8020079c:	00144603          	lbu	a2,1(s0)
    802007a0:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007a2:	846a                	mv	s0,s10
            goto reswitch;
    802007a4:	bf3d                	j	802006e2 <vprintfmt+0x78>
    if (lflag >= 2) {
    802007a6:	4705                	li	a4,1
    802007a8:	008a8593          	addi	a1,s5,8
    802007ac:	01074463          	blt	a4,a6,802007b4 <vprintfmt+0x14a>
    else if (lflag) {
    802007b0:	1e080263          	beqz	a6,80200994 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    802007b4:	000ab603          	ld	a2,0(s5)
    802007b8:	46a1                	li	a3,8
    802007ba:	8aae                	mv	s5,a1
    802007bc:	a839                	j	802007da <vprintfmt+0x170>
            putch('0', putdat);
    802007be:	03000513          	li	a0,48
    802007c2:	85a6                	mv	a1,s1
    802007c4:	e03e                	sd	a5,0(sp)
    802007c6:	9902                	jalr	s2
            putch('x', putdat);
    802007c8:	85a6                	mv	a1,s1
    802007ca:	07800513          	li	a0,120
    802007ce:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007d0:	0aa1                	addi	s5,s5,8
    802007d2:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007d6:	6782                	ld	a5,0(sp)
    802007d8:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007da:	876e                	mv	a4,s11
    802007dc:	85a6                	mv	a1,s1
    802007de:	854a                	mv	a0,s2
    802007e0:	e1fff0ef          	jal	ra,802005fe <printnum>
            break;
    802007e4:	b5c1                	j	802006a4 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007e6:	000ab603          	ld	a2,0(s5)
    802007ea:	0aa1                	addi	s5,s5,8
    802007ec:	1c060663          	beqz	a2,802009b8 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802007f0:	00160413          	addi	s0,a2,1
    802007f4:	17b05c63          	blez	s11,8020096c <vprintfmt+0x302>
    802007f8:	02d00593          	li	a1,45
    802007fc:	14b79263          	bne	a5,a1,80200940 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200800:	00064783          	lbu	a5,0(a2)
    80200804:	0007851b          	sext.w	a0,a5
    80200808:	c905                	beqz	a0,80200838 <vprintfmt+0x1ce>
    8020080a:	000cc563          	bltz	s9,80200814 <vprintfmt+0x1aa>
    8020080e:	3cfd                	addiw	s9,s9,-1
    80200810:	036c8263          	beq	s9,s6,80200834 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200814:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200816:	18098463          	beqz	s3,8020099e <vprintfmt+0x334>
    8020081a:	3781                	addiw	a5,a5,-32
    8020081c:	18fbf163          	bleu	a5,s7,8020099e <vprintfmt+0x334>
                    putch('?', putdat);
    80200820:	03f00513          	li	a0,63
    80200824:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200826:	0405                	addi	s0,s0,1
    80200828:	fff44783          	lbu	a5,-1(s0)
    8020082c:	3dfd                	addiw	s11,s11,-1
    8020082e:	0007851b          	sext.w	a0,a5
    80200832:	fd61                	bnez	a0,8020080a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200834:	e7b058e3          	blez	s11,802006a4 <vprintfmt+0x3a>
    80200838:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020083a:	85a6                	mv	a1,s1
    8020083c:	02000513          	li	a0,32
    80200840:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200842:	e60d81e3          	beqz	s11,802006a4 <vprintfmt+0x3a>
    80200846:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200848:	85a6                	mv	a1,s1
    8020084a:	02000513          	li	a0,32
    8020084e:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200850:	fe0d94e3          	bnez	s11,80200838 <vprintfmt+0x1ce>
    80200854:	bd81                	j	802006a4 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200856:	4705                	li	a4,1
    80200858:	008a8593          	addi	a1,s5,8
    8020085c:	01074463          	blt	a4,a6,80200864 <vprintfmt+0x1fa>
    else if (lflag) {
    80200860:	12080063          	beqz	a6,80200980 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200864:	000ab603          	ld	a2,0(s5)
    80200868:	46a9                	li	a3,10
    8020086a:	8aae                	mv	s5,a1
    8020086c:	b7bd                	j	802007da <vprintfmt+0x170>
    8020086e:	00144603          	lbu	a2,1(s0)
            padc = '-';
    80200872:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    80200876:	846a                	mv	s0,s10
    80200878:	b5ad                	j	802006e2 <vprintfmt+0x78>
            putch(ch, putdat);
    8020087a:	85a6                	mv	a1,s1
    8020087c:	02500513          	li	a0,37
    80200880:	9902                	jalr	s2
            break;
    80200882:	b50d                	j	802006a4 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200884:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200888:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    8020088c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020088e:	846a                	mv	s0,s10
            if (width < 0)
    80200890:	e40dd9e3          	bgez	s11,802006e2 <vprintfmt+0x78>
                width = precision, precision = -1;
    80200894:	8de6                	mv	s11,s9
    80200896:	5cfd                	li	s9,-1
    80200898:	b5a9                	j	802006e2 <vprintfmt+0x78>
            goto reswitch;
    8020089a:	00144603          	lbu	a2,1(s0)
            padc = '0';
    8020089e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    802008a2:	846a                	mv	s0,s10
            goto reswitch;
    802008a4:	bd3d                	j	802006e2 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    802008a6:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    802008aa:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802008ae:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802008b0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802008b4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008b8:	fcd56ce3          	bltu	a0,a3,80200890 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    802008bc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802008be:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802008c2:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008c6:	0196873b          	addw	a4,a3,s9
    802008ca:	0017171b          	slliw	a4,a4,0x1
    802008ce:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008d2:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008d6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802008da:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008de:	fcd57fe3          	bleu	a3,a0,802008bc <vprintfmt+0x252>
    802008e2:	b77d                	j	80200890 <vprintfmt+0x226>
            if (width < 0)
    802008e4:	fffdc693          	not	a3,s11
    802008e8:	96fd                	srai	a3,a3,0x3f
    802008ea:	00ddfdb3          	and	s11,s11,a3
    802008ee:	00144603          	lbu	a2,1(s0)
    802008f2:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802008f4:	846a                	mv	s0,s10
    802008f6:	b3f5                	j	802006e2 <vprintfmt+0x78>
            putch('%', putdat);
    802008f8:	85a6                	mv	a1,s1
    802008fa:	02500513          	li	a0,37
    802008fe:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200900:	fff44703          	lbu	a4,-1(s0)
    80200904:	02500793          	li	a5,37
    80200908:	8d22                	mv	s10,s0
    8020090a:	d8f70de3          	beq	a4,a5,802006a4 <vprintfmt+0x3a>
    8020090e:	02500713          	li	a4,37
    80200912:	1d7d                	addi	s10,s10,-1
    80200914:	fffd4783          	lbu	a5,-1(s10)
    80200918:	fee79de3          	bne	a5,a4,80200912 <vprintfmt+0x2a8>
    8020091c:	b361                	j	802006a4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020091e:	00001617          	auipc	a2,0x1
    80200922:	9aa60613          	addi	a2,a2,-1622 # 802012c8 <error_string+0xd8>
    80200926:	85a6                	mv	a1,s1
    80200928:	854a                	mv	a0,s2
    8020092a:	0ac000ef          	jal	ra,802009d6 <printfmt>
    8020092e:	bb9d                	j	802006a4 <vprintfmt+0x3a>
                p = "(null)";
    80200930:	00001617          	auipc	a2,0x1
    80200934:	99060613          	addi	a2,a2,-1648 # 802012c0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200938:	00001417          	auipc	s0,0x1
    8020093c:	98940413          	addi	s0,s0,-1655 # 802012c1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200940:	8532                	mv	a0,a2
    80200942:	85e6                	mv	a1,s9
    80200944:	e032                	sd	a2,0(sp)
    80200946:	e43e                	sd	a5,8(sp)
    80200948:	102000ef          	jal	ra,80200a4a <strnlen>
    8020094c:	40ad8dbb          	subw	s11,s11,a0
    80200950:	6602                	ld	a2,0(sp)
    80200952:	01b05d63          	blez	s11,8020096c <vprintfmt+0x302>
    80200956:	67a2                	ld	a5,8(sp)
    80200958:	2781                	sext.w	a5,a5
    8020095a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    8020095c:	6522                	ld	a0,8(sp)
    8020095e:	85a6                	mv	a1,s1
    80200960:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200962:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200964:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200966:	6602                	ld	a2,0(sp)
    80200968:	fe0d9ae3          	bnez	s11,8020095c <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020096c:	00064783          	lbu	a5,0(a2)
    80200970:	0007851b          	sext.w	a0,a5
    80200974:	e8051be3          	bnez	a0,8020080a <vprintfmt+0x1a0>
    80200978:	b335                	j	802006a4 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    8020097a:	000aa403          	lw	s0,0(s5)
    8020097e:	bbf1                	j	8020075a <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    80200980:	000ae603          	lwu	a2,0(s5)
    80200984:	46a9                	li	a3,10
    80200986:	8aae                	mv	s5,a1
    80200988:	bd89                	j	802007da <vprintfmt+0x170>
    8020098a:	000ae603          	lwu	a2,0(s5)
    8020098e:	46c1                	li	a3,16
    80200990:	8aae                	mv	s5,a1
    80200992:	b5a1                	j	802007da <vprintfmt+0x170>
    80200994:	000ae603          	lwu	a2,0(s5)
    80200998:	46a1                	li	a3,8
    8020099a:	8aae                	mv	s5,a1
    8020099c:	bd3d                	j	802007da <vprintfmt+0x170>
                    putch(ch, putdat);
    8020099e:	9902                	jalr	s2
    802009a0:	b559                	j	80200826 <vprintfmt+0x1bc>
                putch('-', putdat);
    802009a2:	85a6                	mv	a1,s1
    802009a4:	02d00513          	li	a0,45
    802009a8:	e03e                	sd	a5,0(sp)
    802009aa:	9902                	jalr	s2
                num = -(long long)num;
    802009ac:	8ace                	mv	s5,s3
    802009ae:	40800633          	neg	a2,s0
    802009b2:	46a9                	li	a3,10
    802009b4:	6782                	ld	a5,0(sp)
    802009b6:	b515                	j	802007da <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    802009b8:	01b05663          	blez	s11,802009c4 <vprintfmt+0x35a>
    802009bc:	02d00693          	li	a3,45
    802009c0:	f6d798e3          	bne	a5,a3,80200930 <vprintfmt+0x2c6>
    802009c4:	00001417          	auipc	s0,0x1
    802009c8:	8fd40413          	addi	s0,s0,-1795 # 802012c1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009cc:	02800513          	li	a0,40
    802009d0:	02800793          	li	a5,40
    802009d4:	bd1d                	j	8020080a <vprintfmt+0x1a0>

00000000802009d6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009d6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009d8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009dc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009de:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009e0:	ec06                	sd	ra,24(sp)
    802009e2:	f83a                	sd	a4,48(sp)
    802009e4:	fc3e                	sd	a5,56(sp)
    802009e6:	e0c2                	sd	a6,64(sp)
    802009e8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009ea:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009ec:	c7fff0ef          	jal	ra,8020066a <vprintfmt>
}
    802009f0:	60e2                	ld	ra,24(sp)
    802009f2:	6161                	addi	sp,sp,80
    802009f4:	8082                	ret

00000000802009f6 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009f6:	00003797          	auipc	a5,0x3
    802009fa:	60a78793          	addi	a5,a5,1546 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009fe:	6398                	ld	a4,0(a5)
    80200a00:	4781                	li	a5,0
    80200a02:	88ba                	mv	a7,a4
    80200a04:	852a                	mv	a0,a0
    80200a06:	85be                	mv	a1,a5
    80200a08:	863e                	mv	a2,a5
    80200a0a:	00000073          	ecall
    80200a0e:	87aa                	mv	a5,a0
}
    80200a10:	8082                	ret

0000000080200a12 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200a12:	00003797          	auipc	a5,0x3
    80200a16:	60678793          	addi	a5,a5,1542 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200a1a:	6398                	ld	a4,0(a5)
    80200a1c:	4781                	li	a5,0
    80200a1e:	88ba                	mv	a7,a4
    80200a20:	852a                	mv	a0,a0
    80200a22:	85be                	mv	a1,a5
    80200a24:	863e                	mv	a2,a5
    80200a26:	00000073          	ecall
    80200a2a:	87aa                	mv	a5,a0
}
    80200a2c:	8082                	ret

0000000080200a2e <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a2e:	00003797          	auipc	a5,0x3
    80200a32:	5da78793          	addi	a5,a5,1498 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a36:	6398                	ld	a4,0(a5)
    80200a38:	4781                	li	a5,0
    80200a3a:	88ba                	mv	a7,a4
    80200a3c:	853e                	mv	a0,a5
    80200a3e:	85be                	mv	a1,a5
    80200a40:	863e                	mv	a2,a5
    80200a42:	00000073          	ecall
    80200a46:	87aa                	mv	a5,a0
    80200a48:	8082                	ret

0000000080200a4a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200a4a:	c185                	beqz	a1,80200a6a <strnlen+0x20>
    80200a4c:	00054783          	lbu	a5,0(a0)
    80200a50:	cf89                	beqz	a5,80200a6a <strnlen+0x20>
    size_t cnt = 0;
    80200a52:	4781                	li	a5,0
    80200a54:	a021                	j	80200a5c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a56:	00074703          	lbu	a4,0(a4)
    80200a5a:	c711                	beqz	a4,80200a66 <strnlen+0x1c>
        cnt ++;
    80200a5c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a5e:	00f50733          	add	a4,a0,a5
    80200a62:	fef59ae3          	bne	a1,a5,80200a56 <strnlen+0xc>
    }
    return cnt;
}
    80200a66:	853e                	mv	a0,a5
    80200a68:	8082                	ret
    size_t cnt = 0;
    80200a6a:	4781                	li	a5,0
}
    80200a6c:	853e                	mv	a0,a5
    80200a6e:	8082                	ret

0000000080200a70 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a70:	ca01                	beqz	a2,80200a80 <memset+0x10>
    80200a72:	962a                	add	a2,a2,a0
    char *p = s;
    80200a74:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a76:	0785                	addi	a5,a5,1
    80200a78:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a7c:	fec79de3          	bne	a5,a2,80200a76 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a80:	8082                	ret
