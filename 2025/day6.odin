package main

import "../utils"

import "core:fmt"
import "core:mem"
import "core:strings"
import "core:strconv"

Op :: enum { Add, Mul }

parse_input :: proc(input: string) -> ([][]int, []Op) {
    alloc := context.temp_allocator
    defer free_all(alloc)
    lines := utils.read_lines(input, allocator = alloc)

    nums := make([dynamic][]int, context.allocator)
    ops :=  make([dynamic]Op, context.allocator)

    for line, i in lines {
        tokens := strings.fields(line, allocator = alloc)
        if i == len(lines) - 1 {
            for tok in tokens {
                switch tok[0] {
                case '+': append(&ops, Op.Add)
                case '*': append(&ops, Op.Mul)
                case: panic("Unknonw op")
                }
            }
        } else {
            row := make([dynamic]int, context.allocator)

            for tok in tokens {
                num, ok := strconv.parse_int(tok)
                assert(ok)
                append(&row, num)
            }

            append(&nums, row[:])
        }
    }
    
    return nums[:], ops[:]
}

part_1 :: proc(nums: [][]int, ops: []Op) -> int {
    { // assert precond
        assert(len(nums) > 0)
        len_first := len(nums[0])
        assert(len_first == len(ops)) 

        for row in nums[1:] { assert(len_first == len(row)) }
    }

    size := len(nums[0])
    results := make([]int, size)
    defer delete(results)

    for j := 0; j < size; j += 1 { results[j] = nums[0][j]}

    for i := 0; i < size; i += 1 {
        op := ops[i]
        for j := 1; j < len(nums); j += 1  {
            switch op {
            case .Add: results[i] += nums[j][i]
            case .Mul: results[i] *= nums[j][i]
            } 
        }
    }
    
    res := 0
    for r in results { res += r }

    return res
}

// Not the best solution today...
// Since I knew that the input has specific shape I don't check for sizes and indexes each time
parse_input_2 :: proc(input: string) -> ([][][]byte, []Op) {
    alloc := context.allocator
    defer free_all(context.temp_allocator)

    lines := utils.read_lines(input, allocator = context.temp_allocator)
    last_idx := len(lines) - 1

    ops := make([dynamic]Op, allocator = alloc)
    metadata_cols := make([dynamic]int, allocator = context.temp_allocator)
    {
        col_width := 0

        last_line := lines[last_idx]
        for ch, i in last_line {
            switch ch {
            case '+':
                append(&ops, Op.Add)
                if i > 0 { append(&metadata_cols, col_width) }
                col_width = 0
            case '*':
                append(&ops, Op.Mul)
                if i > 0 { append(&metadata_cols, col_width) }
                col_width = 0
            case ' ':
                col_width += 1
            } 
            if i == len(last_line) - 1 { append(&metadata_cols, col_width + 1) }
        }
    }

    nums := make([][][]byte, last_idx, allocator = alloc)
    col_nums := len(ops)

    for line, row in lines[:last_idx] {
        row_acc := make([dynamic][]byte, allocator = alloc)
        as_bytes := transmute([]byte) line

        start := 0
        for col_width, col in metadata_cols {
            num_as_bytes := as_bytes[start : start + col_width]
            start += col_width + 1

            append(&row_acc, num_as_bytes)
        }
        nums[row] = row_acc[:]
    }

    return nums, ops[:]
}

part_2 :: proc(nums: [][][]byte, ops: []Op) -> int {
    results := make([dynamic]int, context.allocator)
    defer delete(results)

    size := len(nums)
    for op, col_id in ops {
        rows := make([]int, len(nums[0][col_id]), allocator = context.temp_allocator)
        defer free_all(context.temp_allocator)

        for i := 0; i < size; i += 1 {
            num_as_byte := nums[i][col_id]
            for ch, row_id in num_as_byte {
                if ch == ' ' { continue }

                digit := int(ch - '0')
                rows[row_id] = rows[row_id] * 10 + digit
            }
        }

        neutro := op == .Add ? 0 : 1
        switch op {
        case .Add: for r in rows { neutro += r }
        case .Mul: for r in rows { neutro *= r }
        }
        append(&results, neutro)
    }

    res := 0
    for r in results { res += r }
    return res
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    raw_input := #load("day6.txt", string)
    /* raw_input := #load("day6_example.txt", string) */

    { // part 1
        nums, ops := parse_input(raw_input)
        defer {
            for &row in nums { delete(row) }
            
            delete(nums)
            delete(ops)
        }

        p1 := part_1(nums, ops) 
        fmt.println("part 1 =>", p1)
    }
    { // part 2
        nums, ops := parse_input_2(raw_input) 
        defer {
            for &row in nums { delete(row) }
            
            delete(nums)
            delete(ops)
        }

        p2 := part_2(nums, ops)
        fmt.println("part 2 =>", p2)
    }

}

/*
 * ===
 * Until now this is the worst code I've written this year, 
 * there are a lot of hidden assumption, shared memory, conversion and unreadable 'if's and 'for's.b
 * === 
 */
