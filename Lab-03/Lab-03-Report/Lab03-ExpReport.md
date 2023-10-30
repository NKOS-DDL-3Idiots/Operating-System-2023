# **操作系统 Lab03 实验报告**

> 小组成员：武桐西 2112515、胡亚飞 2111690、王祺鹏 2110608

## **练习1：理解基于FIFO的页面替换算法（思考题）**

> 描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）
>
> - 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数

### 缺页异常处理流程：

在发生缺页异常时，首先使用`trap.c`中的`exception_handler`函数进行异常处理，在其中对应到缺页异常，调用`pgfault_handler`处理缺页异常，异常地址会传入其中的`do_pgfault`函数中。

在`vmm.c`中的`do_pgfault`函数里，首先使用`find_vma`函数通过内存控制块找到相应的`vma`段，并判断其是否可读或可写；接下来根据缺页异常的地址，通过`get_pte`函数找到其对应的页表和页表项。

- 若得到的页表项为0，说明该页未分配过，则使用`pgdir_alloc_page`进行物理页的分配，当页面数量不够时使用`swap_out`函数将对应数量的页面换出；在`swap_out`中使用`swap_out_victim`函数中按照相应的策略换出页面，并使用`swapfs_write`函数将页面内容写入"硬盘"（实际上是模拟的硬盘数组）中。
- 若得到的页表项非0，说明该页被swap_out过，则调用`swap_in`函数通过`swapfs_read`函数将磁盘数据换入，并使用`page_insert`函数将虚拟地址与物理地址的映射关系写入对应的页表项。最后使用`swap_map_swappable`函数使用不同策略的`map_swappable`，保证页面置换的正常运行。

### 十个函数的作用：

1. `find_vma(struct mm_struct *mm, uintptr_t addr)`：根据内存块和异常地址，找到相应的`vma`段。
1. `get_pte(pde_t *pgdir, uintptr_t la, bool create）`：根据触发缺页异常的虚拟地址，查找多级页表的叶节点对应的`PTE`，若其中某个页表不存在则分配一个页(4KB)存储相应的映射关系。
1. `pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm)`：分配物理页面，若不能分配则调用`swap_out`换出所需数量的页面。
1. `page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm)`：将虚拟地址和新分配的物理地址的映射关系写入对应的页表项。
1. `swap_out(struct mm_struct *mm, int n, int in_tick)`：根据所需页面的数量n，将对应数量的页面换出到硬盘里。
1. `swapfs_write(swap_entry_t entry, struct Page *page)`：换出页面的时候将页面内容写入硬盘（实际上是模拟的硬盘数组）。
1. `swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)`：根据传入的地址，通过`get_pte`函数查找其`PTE`，并根据页表项中`swap_entry_t`提供的信息将硬盘上的页面内容读入，重新写入页面的内存区域。（可能会导致换出，调用swap_out)
1. `swapfs_read(swap_entry_t entry, struct Page *page)`：根据`swap_entry_t`信息，从硬盘中读取对应的页面内容。
1. `_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)`：FIFO页面替换算法的替换策略，将新加入的页面存入FIFO算法所需要维护的队列(即`sm_priv`链表)的开头。
1. `_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)`：选择要替换出的页（也就是受害者，很形象），按照FIFO算法选择最早被访问的页。

## **练习2：深入理解不同分页模式的工作原理（思考题）**

> get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。
>
> - get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
> - 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

get_pte()函数中有两段形式类似的代码

这两段代码分别是：

```C
pde_t *pdep1 = &pgdir[PDX1(la)];//找到对应的Giga Page
if (!(*pdep1 & PTE_V)) {//如果下一级页表不存在，那就给它分配一页，创造新页表
    struct Page *page;
    if (!create || (page = alloc_page()) == NULL) {
        return NULL;
    }
    set_page_ref(page, 1);
    uintptr_t pa = page2pa(page);
    memset(KADDR(pa), 0, PGSIZE);
    // 我们现在在虚拟地址空间中，所以要转化为 KADDR 再 memset。
    // 不管页表怎么构造，我们确保物理地址和虚拟地址的偏移量始终相同，
    // 那么就可以用这种方式完成对物理内存的访问。
    *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);//注意这里 R,W,X 全零
}
```

```C
pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];//再下一级页表
// 这里的逻辑和前面完全一致，页表不存在就现在分配一个
if (!(*pdep0 & PTE_V)) {
    struct Page *page;
    if (!create || (page = alloc_page()) == NULL) {
            return NULL;
    }
    set_page_ref(page, 1);
    uintptr_t pa = page2pa(page);
    memset(KADDR(pa), 0, PGSIZE);
    *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
}
```

- 这两段代码的功能都是在页表中查找或创建一个表项（pte或pde），如果该表项不存在，则分配一个新的物理页，并将其地址和权限位写入该表项。这两段代码的**区别在于查找或创建的表项的级别不同**，第一段是二级页表项（pte），第二段是一级页表项（pde）。其中包含的逻辑都是一样的，所以相似。
- 这次实验采用了sv39的虚拟内存系统，即32位地址空间和两级页表结构。而sv32和sv48则是64位地址空间和三级或四级页表结构。这些虚拟内存系统的设计原理都是类似的，只是增加了更多的页表层级和更大的地址范围。因此，如果要在ucore lab3中实现sv32或sv48的虚拟内存系统，只需要在get_pte()函数中增加一段或两段类似的代码，来查找或创建三级或四级页表项即可。

目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？
- 这种写法可以简化调用者的逻辑，只需要调用一次get_pte()函数就可以完成查找或创建页表项的操作，并返回一个指向该页表项的指针。
- 增加了get_pte()函数的复杂度和耦合度，使得它既要负责查找页表项，又要负责分配物理页，并且还要处理create参数和返回值等细节。
- 我认为没有必要分开，因为查找的时候如果不存在一定需要插入。所以只需要思考有没有单独插入而不查找的情况即可。
  - 有 `create` 参数，可以控制是否分配。

## **练习3：给未被映射的地址映射上物理页（需要编程）**

> 补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
>
> - 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。
> - 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？
>   - 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

```C
if (swap_init_ok) {
    struct Page *page = NULL;
    // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
    //(1）According to the mm AND addr, try
    //to load the content of right disk page
    //into the memory which page managed.
    swap_in(mm, addr, &page);

    //(2) According to the mm,
    //addr AND page, setup the
    //map of phy addr <--->
    //logical addr
    page_insert(mm->pgdir, page, addr, perm);

    //(3) make the page swappable.
    swap_map_swappable(mm, addr, page, 1);

    page->pra_vaddr = addr;
} else {
    cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
    goto failed;
}
```

页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处：

- 页目录项和页表项中都有一个**P**位，表示该项是否有效。如果为0，表示该项没有对应的物理页，需要进行缺页处理。这个位可以用来判断是否发生了缺页异常。
- 页目录项和页表项中都有一个**A**位，表示该项是否被访问过。如果为1，表示该项被访问过，可以用来实现一些基于访问频率的页替换算法，如**Clock**算法。
- 页目录项和页表项中都有一个**D**位，表示该项是否被修改过。如果为1，表示该项被修改过，需要在换出时写回磁盘。这个位可以用来减少不必要的磁盘写操作。
- 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？
  - 硬件要做的事情如下：
    - 保存当前的程序状态，包括**程序计数器**（PC）、**程序状态字**（PSW）和**通用寄存器**（GPR）等。
    - 根据异常类型和异常参数，从**中断向量表**（IVT）中找到对应的异常处理入口地址，并跳转到该地址执行异常处理程序。
    - 如果异常处理程序成功返回，恢复之前保存的程序状态，并继续执行原来的程序。
- 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有对应关系。其对应关系是：
  - 数据结构Page的全局变量数组的下标就是物理页号，即物理地址除以物理页大小得到的值。
  - 页表是按照逻辑地址顺序，Page是按照物理地址顺序

## **练习4：补充完成Clock页替换算法（需要编程）**

> 通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。(提示:要输出curr_ptr的值才能通过make grade)
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
>
> - 比较Clock页替换算法和FIFO算法的不同。

相比于FIFO算法来说，Clock算法在初始化的时候不仅要初始化`pra_list_head`和`mm->sm_priv`以外，还要将`curr_ptr`的指针指向链表头`pra_list_head`，用于后面的遍历。

```C
static int
_clock_init_mm(struct mm_struct *mm)
{     
    /*LAB3 EXERCISE 4: 2112515、2111690、2110608 */ 
    // 初始化pra_list_head为空链表
    list_init(&pra_list_head);
    // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
    curr_ptr = &pra_list_head;
    // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
    mm->sm_priv = &pra_list_head;
    return 0;
}
```

在`map_swappable`时，需要将新加入的页面插入到链表尾，并将该页的`visited`值设为1，表示该页面已被访问。

```C
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: 2112515、2111690、2110608 */ 
    // 将页面page插入到页面链表pra_list_head的末尾
    list_add_before(mm->sm_priv, entry);
    // 将页面的visited标志置为1，表示该页面已被访问
    page->visited = 1;

    return 0;
}
```

在需要换出页面的时候，从当前的`curr_ptr`开始遍历链表，找到第一个未被访问的页面，即`visited==0`的页面，将该页面从页面链表中删除并换出，同时将`visited==1`的页面的`visited`属性重新置为0。

```C
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    while (1) {
        /*LAB3 EXERCISE 4: 2112515、2111690、2110608 */ 
        // 编写代码
        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        // 获取当前页面对应的Page结构指针
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        if (list_empty(&pra_list_head)) {
            break; // 页面链表为空，直接退出
        }
        if (curr_ptr == &pra_list_head) {
            curr_ptr = list_next(curr_ptr); // 从头结点后面开始遍历
        }
        struct Page *page = le2page(curr_ptr, pra_page_link);
        if (page->visited == 0) {
            *ptr_page = page;
            cprintf("curr_ptr %p\n", curr_ptr);
            curr_ptr = list_next(curr_ptr);
            list_del(list_prev(curr_ptr));
            break;
        } else {
            page->visited = 0;
            curr_ptr = list_next(curr_ptr);
        }
    }
    return 0;
}
```

### Clock页替换算法和FIFO算法的不同

相比于FIFO算法，Clock算法考虑了页面访问的情况，通过维护一个`curr_ptr`指针，并根据页面的`visited`属性，在换出页时查找最早的未被访问的页面，而FIFO算法只是换出最早的页面。clock因为操作过程类似一个栈，（可以理解为不会被打乱，小物理内存是大物理内存的子集）所以不会出现belady现象。

## **练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）**

> 如果我们采用"一个大页"的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？

- 好处：
  - **提高了地址转换的效率，减少了内存访问的开销**。一个大页只需要一次地址转换，而分级页表可能需要多次访问内存才能找到物理页号。
  - 减少了TLB（转换后备缓冲器）的失效率，提高了TLB的命中率。TLB是CPU用来缓存页表项的硬件结构，一个大页可以占用一个TLB条目，而分级页表可能需要多个TLB条目来存储同样大小的虚拟地址空间。
- 坏处：
  - **内存碎片**：降低了内存利用率。一个大页可能无法完全匹配进程所需的虚拟地址空间，导致一部分大页内存被浪费。而分级页表可以更灵活地分配和回收小页内存。
  - **灵活性，连续地址**：降低了内存管理的灵活性。一个大页需要预先分配和锁定在物理内存中。而分级页表可以根据进程的动态需求来调整和优化内存映射关系。
  - 可能会导致需要更多的页表项，从而增加内存空间占用。

## **扩展练习 Challenge：实现不考虑实现开销和效率的LRU页替换算法（需要编程）**

> challenge部分不是必做部分，不过在正确最后会酌情加分。需写出有详细的设计、分析和测试的实验报告。完成出色的可获得适当加分。
