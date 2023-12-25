# **操作系统 Lab08 实验报告**

> 小组成员：武桐西 2112515、胡亚飞 2111690、王祺鹏 2110608

## **练习1: 完成读文件操作的实现（需要编码）**

> 首先了解打开文件的处理流程，然后参考本实验后续的文件读写操作的过程分析，填写在 kern/fs/sfs/sfs_inode.c中 的sfs_io_nolock()函数，实现读文件中数据的代码。

在SFS文件系统中，`sfs_io_nolock()`函数在无锁的情况下进行文件读写操作。

**主要流程：**首先对输入的参数进行检查，随后根据操作的类型，选择对应的缓冲区/块操作函数，接下来根据读写的开始位置和结束位置计算出需要读写的块数量：

```C++
static int
sfs_io_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, void *buf, off_t offset, size_t *alenp, bool write) {
    struct sfs_disk_inode *din = sin->din;
    assert(din->type != SFS_TYPE_DIR); // 目录不支持读写操作，需要保证文件不是目录
    off_t endpos = offset + *alenp, blkoff;// 计算读/写操作的结束位置
    *alenp = 0;

    // 检查输入参数是否合法
    if (offset < 0 || offset >= SFS_MAX_FILE_SIZE || offset > endpos) {
        return -E_INVAL;
    }
    if (offset == endpos) {
        return 0;
    }
    if (endpos > SFS_MAX_FILE_SIZE) {
        endpos = SFS_MAX_FILE_SIZE;
    }
    if (!write) {
        if (offset >= din->size) {
            return 0;
        }
        if (endpos > din->size) {
            endpos = din->size;
        }
    }
    // 判断是什么操作，为其选择对应的缓冲区操作函数
    int (*sfs_buf_op)(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset);
    int (*sfs_block_op)(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks);
    if (write) {
        sfs_buf_op = sfs_wbuf, sfs_block_op = sfs_wblock;
    }
    else {
        sfs_buf_op = sfs_rbuf, sfs_block_op = sfs_rblock;
    }

    int ret = 0;
    size_t size, alen = 0;
    uint32_t ino;
    uint32_t blkno = offset / SFS_BLKSIZE;       //读/写的开始块号
    uint32_t nblks = endpos / SFS_BLKSIZE - blkno;  // 读/写的块数量
```

接下来处理**三种情况：**

- **偏移量与第一个块不对齐**：从偏移量开始读/写一些内容到第一个块的末尾；

```C++
if ((blkoff = offset % SFS_BLKSIZE) != 0) {
    size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);// 计算要处理的字节数
    if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
        goto out;
    }
    if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) {
        goto out;
    }
    alen += size;
    // 如果只有一个块则不需要处理，直接返回
    if (nblks == 0) {
        goto out;
    }
    blkno++;
    buf += size;
    nblks--;
}
```

- **读写对齐的完整块**：直接开始读/写操作;

```C++
 size = SFS_BLKSIZE;
while (nblks != 0) {
    if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
        goto out;
    }
    if ((ret = sfs_block_op(sfs, buf, ino, 1)) != 0) {
        goto out;
    }
    alen += size;
    buf += size;
    blkno++;
    nblks--;
}
```

- **结束位置与最后一个块不对齐**：更新最后一段的`size`为`endpos % SFS_BLKSIZE`，并将其加到`alen`中。

```C++
if ((size = endpos % SFS_BLKSIZE) != 0) {
    if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
        goto out;
    }
    if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {
        goto out;
    }
    alen += size;
}
```

## **练习2: 完成基于文件系统的执行程序机制的实现（需要编码）**

> 改写proc.c中的load_icode函数和其他相关函数，实现基于文件系统的执行程序机制。执行：make qemu。如果能看到sh用户程序的执行界面，则基本成功了。如果在sh用户界面上可以执行”ls”,”hello”等其他放置在sfs文件系统中的其他执行程序，则可以认为本实验基本成功。

在增加文件系统后，需要对`proc.c`中的代码进行一部分改动：

1. 首先在函数`alloc_proc()`中，需要增加对文件系统`struct files_struct * filesp;`的初始化：

```C++
proc->filesp = NULL;  // 进程文件结构体指针初始化
```

1. 随后在`do_fork()`函数中，要使用`copy_files()`函数复制父进程的文件系统信息到子进程中。

```C++
if (copy_files(clone_flags, proc) != 0) { //for LAB8
    goto bad_fork_cleanup_kstack;
}
```

1. 最后，还要再`load_icode()`中，使用文件系统加载程序。
2. `load_icode()`函数的主要流程如下：
   1. 建立内存管理器
   2. 建立页目录
   3. 将文件逐个段加载到内存中，（注意在这里设置虚拟地址与物理地址之间的映射）
   4. 建立相应的虚拟内存映射表
   5. 建立并初始化用户堆栈
   6. 处理用户栈中传入的参数
   7. 最后设置用户进程的中断帧
   8. 如果发生错误还需要进行错误处理。

具体的实现细节，已标明在代码注释中：

```C++
static int
load_icode(int fd, int argc, char **kargv) {
    assert(argc = 0 && argc <= EXEC_MAX_ARG_NUM);
    // (1)建立内存管理器
    // 判断当前进程的 mm 是否已经被释放掉了
    if (current->mm != NULL) {  //要求当前内存管理器为空
        panic("load_icode: current->mm must be empty.\n");
    }
 
    int ret = -E_NO_MEM;                // E_NO_MEM 代表因为存储设备产生的请求错误
    struct mm_struct *mm;               // 建立内存管理器
    if ((mm = mm_create()) == NULL) {   // 为进程创建一个新的 mm
        goto bad_mm;
    }
    
    // (2)建立页目录
    if (setup_pgdir(mm) != 0) {         // 对页表项进行设置
        goto bad_pgdir_cleanup_mm;
    }
    struct Page *page;                  // 建立页表
    
    // (3)从文件加载程序到内存
    struct elfhdr elf_content;
    struct elfhdr *elf = &elf_content;
    struct proghdr ph_content;
    struct proghdr *ph = &ph_content;
    // 读取 ELF 文件头
    if ((ret = load_icode_read(fd, elf, sizeof(struct elfhdr), 0)) != 0) {
        goto bad_elf_cleanup_pgdir;
    }
    // 判断该 ELF 文件是否合法
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }
    uint32_t vm_flags, perm, phnum = 0;
    // 根据 elf-header 中的信息，找到每一个 program header
    for (; phnum < elf->e_phnum; phnum ++) { // 这里e_phnum 代表程序段入口地址数目，即多少个段
        // 循环读取程序的每个段的头部
        if ((ret = load_icode_read(fd, ph, sizeof(struct proghdr), elf->e_phoff + sizeof(struct proghdr) * phnum)) != 0) {  // 读取program header
            goto bad_cleanup_mmap;
        }
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        if (ph->p_filesz  ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {
            // continue ;
        }
        // 建立虚拟地址与物理地址之间的映射
        vm_flags = 0, perm = PTE_U | PTE_V;
        // 根据 ELF 文件中的信息，对各个段的权限进行设置
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        // modify the perm bits here for RISC-V
        if (vm_flags & VM_READ) perm |= PTE_R;
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
        if (vm_flags & VM_EXEC) perm |= PTE_X;
        // 将这些段的虚拟内存地址设置为合法的
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        off_t offset = ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;
        // 复制数据段和代码段
        end = ph->p_va + ph->p_filesz;  // 计算数据段和代码段结束地址
        while (start < end) {
            // 为 TEXT/DATA 段逐页分配物理内存空间
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) { 
                ret = -E_NO_MEM;
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            // 每次读取size大小的块，直至全部读完
            if ((ret = load_icode_read(fd, page2kva(page) + off, size, offset)) != 0) {
                goto bad_cleanup_mmap;
            }
            start += size, offset += size;
        }

        // 建立BSS段
        end = ph->p_va + ph->p_memsz;
        // 如果存在 BSS 段，并且先前的 TEXT/DATA 段分配的最后一页没有被完全占用，则剩余的部分被BSS段占用，因此进行清零初始化     
        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end = la && start == la));
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                ret = -E_NO_MEM;
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    // 关闭传入的文件，之后的操作中已经不需要读文件了
    sysfile_close(fd);// 关闭文件，加载程序结束
    
    // （4）建立用户栈
    // 建立相应的虚拟内存映射表
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);

    // (5)设置当前进程的mm,cr3，重置pgdir
    mm_count_inc(mm); // 切换到用户的内存空间
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));

    // 处理用户栈中传入的参数，其中 argc 对应参数个数，uargv[] 对应参数的具体内容的地址
    uint32_t argv_size = 0;
    int i;
    for (i = 0; i < argc; i++) {
        argv_size += strnlen(kargv[i], EXEC_MAX_ARG_LEN + 1) + 1;
    }

    uintptr_t stacktop =
        USTACKTOP - (argv_size / sizeof(long) + 1) * sizeof(long);
    char **uargv = (char **)(stacktop - argc * sizeof(char *));
    argv_size = 0;
    for (i = 0; i < argc; i++) {
        uargv[i] = strcpy((char *)(stacktop + argv_size), kargv[i]);
        argv_size += strnlen(kargv[i], EXEC_MAX_ARG_LEN + 1) + 1;
    }
    stacktop = (uintptr_t)uargv - sizeof(int);
    *(int *)stacktop = argc;

    // (6)设置进程的中断帧
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));

    tf->gpr.sp = USTACKTOP;
    tf->epc = elf->e_entry;
    /*
    用户模式(将SPP清0，SPIE位置1) 
    SPP为0：User SPP为1：Supervisor
    SPIE置1，启用用户中断
    */
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;

    ret = 0;
    // 错误处理
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
}
```

## **扩展练习 Challenge1：完成基于“UNIX的PIPE机制”的设计方案**

> 如果要在ucore里加入UNIX的管道（Pipe)机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个(或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的PIPE机制“的概要设计方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

管道（Pipe）是一种在Unix和类Unix操作系统中用于进程间通信的机制。它允许一个进程的输出直接成为另一个进程的输入，从而实现这两个进程之间的数据流动。在Linux和其他类Unix系统中，管道通常用于将一个进程的输出连接到另一个进程的输入，实现进程之间的协作和数据交换。

在 Linux 中，管道（PIPE）是通过文件描述符和内核中的缓冲区实现的。以下是 Linux 中 PIPE 的基本实现原理：

1. **文件描述符：** 在 Linux 中，一切都是文件，包括管道。管道通过使用文件描述符进行标识和访问。当创建一个管道时，内核会为管道分配两个文件描述符，一个用于读取（read end），另一个用于写入（write end）。
2. **内核缓冲区：** 管道的数据传递是通过内核中的缓冲区实现的。内核为每个管道维护一个缓冲区，该缓冲区存储从一个进程写入的数据，以便另一个进程可以读取。
3. **数据流动：** 当一个进程向管道写入数据时，数据首先被复制到内核的缓冲区中。如果缓冲区没有满，写入的操作会成功完成，否则写入的进程会被阻塞，直到有足够的空间。另一方面，当一个进程从管道读取数据时，数据首先被复制到进程的缓冲区中。如果缓冲区为空，读取的操作会被阻塞，直到有数据可用。
4. **进程同步：** 管道提供了进程之间的同步机制。如果一个进程试图从空管道中读取数据，它会被阻塞，直到另一个进程向管道中写入数据。同样，如果一个进程试图向已满的管道写入数据，它会被阻塞，直到另一个进程从管道中读取数据。
5. **管道的生命周期：** 管道的生命周期通常与相关的文件描述符的生命周期相关联。当所有引用一个管道的文件描述符都被关闭时，内核会释放相关的资源，包括管道的内存缓冲区。

要在 ucore 中加入 UNIX 的管道机制，至少需要定义以下数据结构和接口：

### 数据结构：

1. **struct pipe_entry：**
   1. 描述管道的一个缓冲区块，用于存储数据。
   2. 包含缓冲区的指针、数据长度等信息。

```C
struct pipe_entry {
    char *data;         // 指向数据的指针
    size_t length;      // 数据长度
    int refcount;       // 引用计数
    // 可以添加其他字段
};
```

2. **struct pipe_buffer：**

- 描述整个管道的缓冲区，由多个 `struct pipe_entry` 组成。

```C
struct Pipe_buffer {
  	//  char buffer[PIPE_BUFFER_SIZE];
    struct pipe_entry entries[MAX_PIPE_ENTRIES];  // 一组缓冲区块
    int read_pos; // 读取位置的索引
    int write_pos;// 写入位置的索引
    int data_size;
    int read_fd;   // 读文件描述符
    int write_fd;  // 写文件描述符
    pthread_mutex_t mutex;
    pthread_cond_t read_cond;
    pthread_cond_t write_cond;
};
```

`read_index`（读取位置的索引）： 表示当前可以从缓冲区中读取数据的位置。当一个进程从管道中读取数据时，它将从 `read_index` 指示的位置开始读取，并且读取完数据后会更新这个索引。

`write_index`（写入位置的索引）： 表示当前可以向缓冲区中写入数据的位置。当一个进程向管道中写入数据时，它将数据写入到 `write_index` 指示的位置，并且写入完数据后会更新这个索引。

### 接口：

1. **pipe_create：**
   1. 创建一个新的管道。

```C
void create_pipe(struct pipe_buffer *buffer) {
    pthread_mutex_init(&buffer->mutex, NULL);
    sem_init(&buffer->read_sem, 0, 0);
    sem_init(&buffer->write_sem, 0, MAX_PIPE_ENTRIES);
    //还要初始化 fd
}
```

2. **pipe_read：**

- 从管道中读取数据。

```C
ssize_t pipe_read_(int fd,struct pipe_buffer *buffer, void *data, size_t count) {
    // 等待读信号量
    sem_wait(&buffer->read_sem);
    pthread_mutex_lock(&buffer->mutex);
    // 读取操作
    // ...
    
    pthread_mutex_unlock(&buffer->mutex);
    // 释放写信号量
    sem_post(&buffer->write_sem);
    // 返回实际读取的数据量
}
```

3. **pipe_write：**

- 向管道中写入数据。

```C
ssize_t pipe_write_(int fd, struct pipe_buffer *buffer, const void *data, size_t count) {
    // 等待写信号量
    sem_wait(&buffer->write_sem);
    pthread_mutex_lock(&buffer->mutex);
    // 写入操作
    // ...
    pthread_mutex_unlock(&buffer->mutex);
    // 释放读信号量
    sem_post(&buffer->read_sem);
    // 返回实际写入的数据量
}
```

4. **pipe_close：**

- 关闭管道。

```C
void pipe_close(struct pipe_inode *pipe);
```

5. **pipe_destroy：**

- 销毁管道，释放相关资源。

```C
void pipe_destroy(struct pipe_inode *pipe);
```

## **扩展练习 Challenge2：完成基于“UNIX的软连接和硬连接机制”的设计方案**

> 如果要在ucore里加入UNIX的软连接和硬连接机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个(或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的软连接和硬连接机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

### UNIX的软连接和硬连接机制

#### 硬连接机制

在同一个文件系统中，将一个文件名关联到一个已经存在的文件上，使得该文件名也可以访问该文件。硬链接与原文件共享`inode`，即它们有相同的`inode`号和相同的`device`号。因此，*对于硬链接和原文件来说，它们的访问权限、所有者、大小等属性都是相同的。*

> 相当于给文件加了一个别名，只有当所有的硬连接都被删除时，该文件才会真正被删除。

#### 软连接机制

软链接（也称符号链接）是指在不同的文件系统之间，将一个文件名关联到另一个文件上，使得该文件名也可以访问该文件。软链接与原文件不共享`inode`，它们有不同的`inode`号和`device`号。因此，*对于软链接和原文件来说，它们的访问权限、所有者、大小等属性可能不同*。

> 软连接类似于给文件创建了一个快捷方式。

### 数据结构实现

总的来说，硬链接通过共享相同的 `inode`实现，而软链接则是创建一个新的 `inode`，并在其内容中保存原路径的信息。硬链接的删除需要注意被链接文件的引用计数，而软链接的删除则相对简单。无论是硬链接还是软链接，它们提供了一种有效的方式来在文件系统中建立连接和引用关系。

因此，需要对`inode`进行扩展，并引入一个数据结构`link`表示连接。

对于`inode`的扩展，增加一个引用计数，每次创建该文件的硬连接时，就将引用次数加1：

```C++
// 文件信息结构（inode）
struct inode {
    // 其他字段
    int ref_count;        // 引用计数
    // ...
};
```

对于软连接来说，创建一个数据结构`link`。

```C++
// 软链接结构
struct link {
    struct inode *inode;  // 指向Inode的指针
    int link_count;       // 链接计数
    bool is_symlink;      // 是否是软链接
};
```

### 创建和删除软连接/硬连接

#### 硬连接

- **硬链接的创建：**
  - 创建硬链接时，系统为新路径`new_path`创建一个文件，并将其`inode` 指向原路径`old_path`所对应的`inode`。
  - 同时，原路径所对应`inode`的引用计数增加，表示有一个额外的硬链接指向它。
- **硬链接的删除：**
  - 删除硬链接时，除了需要删除硬链接的 `inode`，还需要将该硬链接所指向的文件的被链接计数减1。
  - 如果减到了0，表示没有其他硬链接指向该文件，此时需要将该文件对应的 inode 从磁盘上删除。

#### 软连接

- **软链接的创建：**
  - 创建软链接时，系统创建一个新的文件（新的 `inode`），并将其内容设置为原路径的内容。
  - 在磁盘上保存该文件时，该文件的`inode` 类型被标记为 `SFS_TYPE_LINK`，同时需要对这种类型的 `inode`进行相应的操作。
- **软连接的删除：**
  - 将软链接对应的 inode 从磁盘上删除即可。

### 接口实现

```C++
// 创建硬链接
int create_hlink(const char *source_path, const char *target_path);

// 创建软链接
int create_slink(const char *source_path, const char *target_path);

// 删除链接
int remove_link(const char *link_path);
```

### **同步互斥问题的处理**

解决同步互斥问题的方法：

- 使用互斥锁（`mutex`）或信号量（`semaphore`）来保护` inode` 的操作，确保在更新 `inode`时不会有并发冲突。
- 在文件系统操作中，尤其是在创建和删除链接时，应用适当的锁策略，避免死锁和竞态条件。

