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

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    raw_input := #load("day6.txt", string)
    /* raw_input := #load("day6_example.txt", string) */
    nums, ops := parse_input(raw_input)

    defer {
        for &row in nums { delete(row) }
        
        delete(nums)
        delete(ops)
    }

    { // part 1
        p1 := part_1(nums, ops) 
        fmt.println("part 1 =>", p1)
    }

}
