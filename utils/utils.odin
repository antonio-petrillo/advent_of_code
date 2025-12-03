package utils

import "base:runtime"

import "core:bytes"

Combination_Iterator :: struct($T: typeid) {
    k: int,
    j: int,
    first: bool,
    counters: []int,
    slice: []T,
    combination: []T,
}

make_combination_iterator :: proc(
    slice: []$T,
    k: int,
    allocator := context.allocator,
) -> (
    iter: Combination_Iterator(T),
    error: runtime.Allocator_Error, 
) #optional_allocator_error {
    assert(k >= 0 && len(slice) >= k)

    iter.combination = make([]T, k, allocator = allocator) or_return
    iter.counters, error = make([]int, k + 2, allocator = allocator)
    if error != nil {
        delete(iter.combination, allocator = allocator)
        return iter, error
    }

    for i in 0..<k {
        iter.counters[i] = i
    }
    iter.counters[k] = len(slice)

    iter.j = k
    iter.k = k
    iter.slice = slice
    iter.first = true

    return
}

destroy_combination_iterator :: proc(
    iter: Combination_Iterator($T),
    allocator := context.allocator,
) {
    delete(iter.combination, allocator = allocator)
    delete(iter.counters, allocator = allocator)
}


combine :: proc(iter: ^Combination_Iterator($T)) -> (ok: bool) #no_bounds_check {
    defer if ok {
        for i in 0..<iter.k {
            iter.combination[i] = iter.slice[iter.counters[i]]
        }
    }

    if iter.first {
        iter.first = false
        return true
    }

    j := iter.j

    if j > 0 {
        x := iter.counters[j - 1] + 1
        iter.counters[j - 1] = x
        iter.j -= 1
        return true
    }

    if iter.counters[0] + 1 < iter.counters[1] {
        iter.counters[0] += 1
        return true
    }

    j = 2
    for {
        iter.counters[j - 2] = j - 2
        x := iter.counters[j - 1] + 1
        if x != iter.counters[j] {
            break
        }
        j += 1
    }

    if j > iter.k {
        return false
    }

    iter.counters[j - 1] = iter.counters[j - 1] + 1
    iter.j = j - 1
    return true
}


when ODIN_OS == .Windows {
    @(private="file")
    @(rodata)
    byte_line_separator := []byte{'\r', '\n'}
} else {
    @(private="file")
    @(rodata)
    bytes_line_separator := []byte{'\n'}
}

bytes_read_lines :: proc(input: []byte, allocator := context.allocator, skip_last_empty_line: bool = true) -> [][]byte {
    lines := bytes.split(input, byte_line_separator, allocator = allocator)

    if l := len(lines); l > 0 && len(lines[l - 1]) == 0 {
	lines = lines[:l - 1]
    }

    return lines
}

parse_number_from_string :: proc(input: string) -> (n: int) {
    return parse_number_from_bytes(transmute([]byte)input)
}

parse_number_from_bytes :: proc(input: []byte) -> (n: int) {
    input := input
    sign := 1 

    i := 0
    for input[i] == '-' || input[i] == '+' {
        sign *=  input[i] == '-' ? -1 : 1
        i += 1
    }
    input = input[i:]

    for b in input {
        n = n * 10 + int(b - '0') 
    }

    return sign * n
}

parse_number :: proc{
    parse_number_from_bytes,
    parse_number_from_string,
}
