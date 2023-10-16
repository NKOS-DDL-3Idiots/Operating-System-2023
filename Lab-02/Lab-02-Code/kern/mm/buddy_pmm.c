#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

// 定义一些全局静态变量
static uintptr_t buddy_base; // 初始化的基址（虚拟）
static size_t buddy_pages; // 初始化的页数


static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    n = power_rounddown(n); // 规整化为 2 的幂
    buddy_base = (uintptr_t) base; // 记录基址
    buddy_pages = n; // 记录总页数
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}

static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    n = power_roundup(n); // 规整化为 2 的幂
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    size_t min_size = nr_free + 1; // 记录第一次扫描的最小值
    while ((le = list_next(le)) != &free_list) { // 第一次扫描
        struct Page *p = le2page(le, page_link);
        if (p->property >= n && p->property < min_size) {
            min_size = p->property;
            page = p;
        }
    }
    // 以上，第一次扫描完成

    if (page != NULL) { // 能够分配
        // 若可以分裂，则继续分裂
        while (page->property > n && ((page->property / 2) >= n)) {
            struct Page *p = page + ((page->property) / 2);
            p->property = page->property / 2;
            SetPageProperty(p);
            page->property /= 2;
            list_add(&(page->page_link), &(p->page_link));
        }
        list_del(&(page->page_link));
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    n = power_roundup(n); // 规整化为 2 的幂
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    // 合并
    p = base;
    struct Page* pair = NULL;
    while ((pair = (siblings(p, buddy_base, buddy_pages)))) { // 非根节点（注意括号内为赋值号，不是等于号）
        if (PageProperty(pair) && (pair->property == p->property)) { // 可以合并
            struct Page* head = MIN(pair,p);
            struct Page* tail = MAX(pair,p);
            head->property *= 2;
            ClearPageProperty(tail);
            list_del(&(tail->page_link));
            p = head;
            continue;
        }
        break;
    }
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
// 以上


// 以下为 check

static void
buddy_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    // 开始测试！
    struct Page *p0 = alloc_pages(17);
    struct Page *p1 = alloc_pages(33);
    struct Page *p2 = alloc_pages(31);
    struct Page *p3 = alloc_pages(18);
    struct Page *p4 = alloc_pages(63);

    assert(p0 != NULL && p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL);
    assert(!PageProperty(p0) && p0->property == 32);
    assert(!PageProperty(p1) && p1->property == 64);
    assert(!PageProperty(p2) && p2->property == 32);
    assert(!PageProperty(p3) && p3->property == 32);
    assert(!PageProperty(p4) && p4->property == 64);

    assert(p0 < p2 && p2 < p1 && p1 < p3 && p3 < p4);

    free_pages(p2, 31);
    assert(PageProperty(p2) && p2->property == 32);

    free_pages(p0, 17);
    assert(PageProperty(p0) && p0->property == 64);

    struct Page * p5 = alloc_pages(16);
    assert(!(PageProperty(p5)) && p5->property == 16);

    struct Page *p6 = alloc_pages(28);
    assert(!(PageProperty(p6)) && p6->property == 32);
    assert(p6 == p0);
}

// 定义 buddy_pmm_manager
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
