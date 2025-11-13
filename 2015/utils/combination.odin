package utils

import "base:runtime"
import "base:intrinsics"

@(private="file")
gray_code :: proc(n: uint) -> uint { return  n ~ (n >> 1) }

Combination_Iterator :: struct($T: typeid) {
    k: uint,
    index: int,
    slice: []T,
    combination: []T,
}

make_combination_iterator :: proc(
    slice: []$T,
    k: uint,
    allocator := context.allocator,
) -> (
    iter: Combination_Iterator(T),
    error: runtime.Allocator_Error, 
) #optional_allocator_error {

    assert(k > 0)
    iter.slice = slice
    iter.combination = make([]int, k, allocator) or_return
    iter.k = k

    return
}

destroy_combination_iterator :: proc(
    iter: Combination_Iterator($T),
    allocator := context.allocator,
) {
    delete(iter.combination, allocator = allocator)
}

combine :: proc(iter: ^Combination_Iterator($T)) -> (ok: bool) {
    n := uint(len(iter.slice))
    for i := iter.index; i < (1 << n) ; i += 1 {
        curr := gray_code(uint(i))
        if intrinsics.count_ones(curr) == iter.k {
            idx := 0
            for j: uint = 0; j < n; j += 1 {
                if (curr & (1 << j) != 0) {
                    iter.combination[idx] = iter.slice[j]         
                    idx += 1
                }
            }
            ok = true
            iter.index = i + 1
            return
        }
    }

    return
}

/* main :: proc() { */
/*     nums := []int{6,7,8,9,10} */

/*     for i in 1..=3 { */
/*         iter, err := make_combination_iterator(nums, uint(i)) */
/*         assert(err == nil) */
/*         defer destroy_combination_iterator(iter) */

/*         idx := 0 */
/*         for combine(&iter) { */
/*             fmt.printfln("comb %d (chosing %d) => %v", idx, i, iter.combination) */
/*             idx += 1 */
/*         } */
/*     } */
/* } */
