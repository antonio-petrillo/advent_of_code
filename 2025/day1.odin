package main

import "../utils" 

import "core:bytes"
import "core:fmt"
import "core:mem"
import "core:strconv"

parse_input :: proc(raw: []byte) -> []int {
    lines := utils.bytes_read_lines(raw) 
    defer delete(lines)

    rotations := make([dynamic]int)
    
    for line in lines {
        sign := 1
        switch line[0] {
        case 'L': sign = -1
        case 'R': sign = 1
            case: panic("Unexpected rotation")
        }
        
        num_str := transmute(string)line[1:]
        num, ok := strconv.parse_int(num_str) 
        assert(ok)

        append(&rotations, num * sign)
    }

    return rotations[:]
}

part_1 :: proc(rotations: []int) -> (n: int) {
    pos := 50
    
    for rot in rotations {
        pos = (pos + rot) %% 100
        if pos == 0 { n += 1 }
    }

    return
}

part_2 :: proc(rotations: []int) -> (n: int) {
    pos := 50

    for rot in rotations {
        if rot >= 0 {
            pos += rot
            n += pos / 100 
        } else {
            // can be done using '%' but this should be more efficient, even with the branching
            to_0 := pos > 0 ? 100 - pos : 0
            /* to_0 := (100 - pos) % 100 */
            n += (to_0 - rot) / 100
            pos += rot
        }
        pos %%= 100
    }

    return
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    raw_input := #load("day1.txt")
    /* raw_input := #load("day1_example.txt") */
    /* raw_input := #load("day1_example_plus_5.txt") */
    
    rotations := parse_input(raw_input)
    defer delete(rotations)
    { // p1
        p1 := part_1(rotations) 
        fmt.println("part 1 =>", p1)
    }
    { // p2
        p2 := part_2(rotations) 
        fmt.println("part 2 =>", p2)
    }
}
