package main

import "core:os"
import "core:fmt"

part_1 :: proc(instrs: []u8) -> int {
    floor := 0 
    for instr in instrs {
        switch {
        case instr == u8('('): floor += 1
        case instr == u8(')'): floor -= 1
        }
    }

    return floor
}

part_2 :: proc(instrs: []u8) -> int {
    floor := 0
    for instr, i in instrs {
        switch {
        case instr == u8('('): floor += 1
        case instr == u8(')'): floor -= 1
        }
        if floor == -1 do return i + 1
    }
    
    return -1
}

main :: proc() {
    instrs, ok := os.read_entire_file_from_filename("day1.txt")
    if !ok {
        panic("Can't read input file")
    }
    p1 := part_1(instrs)
    fmt.printf("Floor => %d\n", p1)
   
    p2 := part_2(instrs)
    fmt.printf("Floor => %d\n", p2)
}
