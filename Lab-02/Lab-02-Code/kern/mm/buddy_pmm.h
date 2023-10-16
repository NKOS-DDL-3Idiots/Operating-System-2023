#ifndef __KERN_MM_BUDDY_PMM_H__
#define  __KERN_MM_BUDDY_PMM_H__

#include <pmm.h>

// 外部声明 buddy_pmm_manager
extern const struct pmm_manager buddy_pmm_manager;

// 以下，一些辅助函数

#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)<(b)?(a):(b))

static inline
size_t power_rounddown(size_t n) { // 返回小于等于 n 的最大的 2 的幂（不是指数）
    size_t ret = (size_t)1 << (sizeof(size_t) * 8 - 1);
    while ((ret & n) == 0) {
        ret >>= 1;
    }
    return ret;
};

static inline
size_t power_roundup(size_t n) { // 返回大于等于 n 的最小的 2 的幂（不是指数）
    if (n & (n - 1))
        return (power_rounddown(n) << 1);
    return n;
}

static inline
struct Page * siblings(struct Page * p, uintptr_t buddy_base, size_t buddy_pages) { // 返回 p 的兄弟节点
    size_t n = ((uintptr_t)(p) - buddy_base) / sizeof(struct Page);
    size_t left = 1;
    size_t right = buddy_pages;
    int plus_tag = -1;
    while((right - left + 1) > p->property) {
        size_t mid = (left + right) / 2;
        if (n < mid) {
            right = mid;
            plus_tag = 1;
        } else {
            left = mid + 1;
            plus_tag = 0;
        }
    }
    if (plus_tag == -1)
        return NULL; // 根节点
    else if (plus_tag == 1)
        return (struct Page *) (p + p->property);
    else
        return (struct Page *) (p - p->property);
}


#endif /* ! __KERN_MM_BUDDY_PMM_H__ */
