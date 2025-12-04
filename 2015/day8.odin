package main

import "../utils" 

import "core:bytes" 
import "core:fmt"
import "core:mem"

part_1 :: proc(lines: [][]byte) -> int {
    code_sum, literal_sum := 0, 0

    for line in lines {
        size := len(line)
        code_sum += size 
        literal := 0
        for i := 1; i < size - 1; i += 1 {
            if line[i] == '\\' {
                switch line[i + 1] {
                case 'x':
                    i += 3
                case '\\', '"': // "
                    i += 1
                }
                literal += 1
            } else do literal += 1
        }
        literal_sum += literal
    }
    
    return code_sum - literal_sum
}

part_2 :: proc(lines: [][]byte) -> int {
    extended, code_sum := 0, 0 

    for line in lines {
        code_sum += len(line)
        extended_size := 2

        for ch in line {
            switch ch {
            case '\\': extended_size += 2
            case '"': extended_size += 2 // "
            case: extended_size += 1
            }
        }
        extended += extended_size
    }
    return extended - code_sum
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    raw_data := #load("day8.txt")

    lines := utils.bytes_read_lines(raw_data)
    defer delete(lines)

    p1 := part_1(lines)
    fmt.printf("part 1 => %d\n", p1)

    p2 := part_2(lines)
    fmt.printf("part 2 => %d\n", p2)
    
}
