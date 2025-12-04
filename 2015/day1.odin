package main

import "../utils"

import "core:mem"
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
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)


    instrs := #load("day1.txt")
    p1 := part_1(instrs)
    fmt.printf("Floor => %d\n", p1)
   
    p2 := part_2(instrs)
    fmt.printf("Floor => %d\n", p2)
}
