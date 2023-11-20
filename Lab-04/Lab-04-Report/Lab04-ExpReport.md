# **操作系统 Lab04 实验报告**

> 小组成员：武桐西 2112515、胡亚飞 2111690、王祺鹏 2110608

## **练习1：分配并初始化一个进程控制块（需要编码）**

> alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。
>
> 【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。
>
> 请在实验报告中简要说明你的设计实现过程。

在初始化一个进程控制块时，需要将各个成员变量的值置零（指针的话则置`NULL`），并将`proc_state`置为`PROC_UNINIT`（即进程状态为"初始态"）， 设置进程的`proc->pid`为`-1`，并将页表基址切换成内核页表的基址`boot_cr3`。

```C++
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
        //LAB4:EXERCISE1 YOUR CODE
        /*2112515 2111690 2110608*/
        proc->state = PROC_UNINIT;
        proc->pid = -1;
        proc->cr3 = boot_cr3;
        
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL;
        proc->flags = 0;
        memset(proc->name, 0, PROC_NAME_LEN);
    }
    return proc;
}
```

请回答如下问题：

> - 请说明proc_struct中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

`struct context context`：用于在进程切换中存储进程的上下文，具体来说，就是保存一些重要的寄存器的值，以便在进程切换中还原一个进程的运行状态。

`struct trapframe *tf`：在`tf`中保存了进程的中断帧，当进程在内核态和用户态切换的时候，保存其执行状态。

## **练习2：为新创建的内核线程分配资源（需要编码）**

> 创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用**do_fork**函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们**实际需要"fork"的东西就是stack和trapframe**。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：
>
> - 调用alloc_proc，首先获得一块用户信息块。
> - 为进程分配一个内核栈。
> - 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
> - 复制原进程上下文到新进程
> - 将新进程添加到进程列表
> - 唤醒新进程
> - 返回新进程号
>
> 请在实验报告中简要说明你的设计实现过程。

首先调用`alloc_proc()`函数，分配一个进程块并将当前进程设置为其父进程；随后调用`setup_kstack()`函数，为该进程分配一个内核栈；随后根据`clone_flags`决定是复制还是共享内存管理系统，并将原进程的上下文复制到新进程；接下来要进行全局资源的改动，所以先禁用中断，其中的`local_intr_restore(flag)`和 ` local_intr_save(flag)`函数在文件`sync.h`中定义；然后为进程分配`pid`并将进程块链入哈希表和进程链表；最后恢复中断，唤醒进程，并返回进程的`pid`。

具体实现细节见代码：

```C++
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE
    /*2112515 2111690 2110608*/
    
    // 调用alloc_proc(),分配一个进程块
    proc = alloc_proc();
    if(proc == NULL){
        goto fork_out;
    }
    
    // 将当前进程设置为所分配的进程块的父进程
    proc->parent = current;
    
    // 调用setup_kstack()，为proc分配一个内核栈
    if(setup_kstack(proc) != 0){
        goto bad_fork_cleanup_kstack;
    }
    
    // 根据clone_flags决定是复制还是共享内存管理系统
    if(copy_mm(clone_flags, proc) != 0){
        goto bad_fork_cleanup_proc;
    }
    
    //  使用copy_thread将原进程的上下文复制到新进程
    copy_thread(proc, stack, tf);
    
    // 要对全局资源进行改动，所以先禁用中断
    bool intr_flag;
    local_intr_save(intr_flag);
    
    // 为进程分配pid
    proc->pid = get_pid();
    
    // 将进程块链入哈希表和进程链表
    hash_proc(proc);
    list_add(&proc_list, &(proc->list_link));
    nr_process++;
    
    // 恢复中断
    local_intr_restore(intr_flag);
    
    // 唤醒进程，即设置新的进程的状态为RUNNABLE
    wakeup_proc(proc);
    
    // 返回线程的pid
    ret = proc->pid;
 
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

请回答如下问题：

> - 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

ucore可以给每个新fork的线程一个唯一的id。

ucore用于分配`id`的函数是`get_pid()`。

```C++
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    // last_pid每次自增，并在达到PID的最大值以后重置为1
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```

在这个函数中，定义了一个静态变量`last_pid`，用于存储最后一次分配的`PID`，在每次调用`get_pid()`函数时，`last_pid`都会加1，当`last_pid`达到最大值`MAX_PID`以后会被重置为1。

随后进入`inside`和`repeat`代码块，在`repeat`代码块中，对`proc_list`进行遍历，如果在进程列表中存在一个进程的`PID`与`last_pid`相等，则`last_pid`加1，随后检查`last_pid`是否达到最大值，如果没有，则继续遍历进程列表。

最后返回`last_pid`，可以确保该`PID`与其他所有进程都不同，即每个进程有自己唯一的`PID`。

这里考虑如果只写一个while循环，会出现什么问题。举一个例子，首先首先判断last_pid=4，进程链表的pid是5、4，首先和5判断发现不等，然后和4判断所以last_pid++。但是这时last_pid会和之前判断的5相等。

为了解决这个问题我们这里使用了goto，形如两层循环的嵌套。这样可以解决问题但是我们还可以进行一些操作来降低时间复杂度，也就是引入next_safe。从上个例子中我们可以看到，不好的情况是因为++后last_pid有可能和之前出现过的值相等。所以这里我们使用next_safe（其实感觉next_danger更妙）来记录可能产生这种情况的值。而也只有在大于next_safe的时候才goto，这样降低了时间复杂度。

## **练习3：编写proc_run 函数（需要编码）**

> proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：
>
> - 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
> - 禁用中断。你可以使用`/kern/sync/sync.h`中定义好的宏`local_intr_save(x)`和`local_intr_restore(x)`来实现关、开中断。
> - 切换当前进程为要运行的进程。
> - 切换页表，以便使用新进程的地址空间。`/libs/riscv.h`中提供了`lcr3(unsigned int cr3)`函数，可实现修改CR3寄存器值的功能。
> - 实现上下文切换。`/kern/process`中已经预先编写好了`switch.S`，其中定义了`switch_to()`函数。可实现两个进程的context切换。
> - 允许中断继续触发。

首先通过`local_intr_save(intr_flag)`函数禁用中断，避免在进行进程切换期间被中断打断（这里使用了一个局部变量 `intr_flag` 来保存中断状态）；接下来使用一个`pro_struct*`的结构体指针`prev`记录当前进程，并将当前进程`current`切换为`proc`；

> 刚开始在这里遇到了一点小问题，在`switch_to`函数以后才将`current`切换为`proc`，但实际上在`switch_to`函数后会跳转到`forkrets`函数中，在这里用到了`current->tf`，因此，需要在`switch_to`函数之前将`current`切换为`proc`。

接下来使用`lcr3`函数切换页表，使用新进程`proc`的地址空间，并通过`switch_to`函数实现上下文切换；

最后使用`local_intr_save(intr_flag)`函数允许中断继续触发。

```C++
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4:EXERCISE3 YOUR CODE
        /*2112515 2111690 21110608 */
        
        // Disable interrupts 
        bool intr_flag;
        local_intr_save(intr_flag);
        
        struct proc_struct *prev = current;
        
        current = proc;
        lcr3(proc->cr3);
        switch_to(&(prev->context), &(proc->context));

        // Enable interrupts 
        local_intr_restore(intr_flag);
    }
}
```

请回答如下问题：

> - 在本实验的执行过程中，创建且运行了几个内核线程？

一共两个。

第一个是`idle`，在完成新的内核线程的创建以及各种初始化工作之后，进入死循环，用于调度其他进程或线程；

第二个是执行`init_main`的`init`线程，打印"Hello world!!"。

## **扩展练习 Challenge：**

> - 说明语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？

`local_intr_save`函数是`__intr_save`函数的一个宏，在`__intr_save`中，通过状态寄存器`sstatus`的`SIE`位来确定是否调用`intr_disable`函数(`clear_csr(sstatus, SSTATUS_SIE)`通过清除状态寄存器`sstatus`的`SIE`位从而禁用中断)禁用中断；

同理，`local_intr_restore`函数就是设置`sstatus`的`SIE`位来允许中断继续触发的。
