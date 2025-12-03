package main

import "../utils"

import "core:bytes"
import "core:fmt"
import "core:slice"

Battery_Bank :: #type []byte

parse_input :: proc(raw: []byte) -> ([]Battery_Bank) {
    lines := utils.bytes_read_lines(raw)
    defer delete(lines)

    input := make([dynamic]Battery_Bank)

    for line in lines {
        for &el in line { el -= '0' }
        append(&input, line)
    }

    return input[:] // just a bodge to free it later
}

to_jolt :: proc(bs: []byte) -> int {
    jolt := 0
    for b in bs {
        jolt = jolt * 10 + int(b)
    }
    return jolt
}

build_pack_of_size_from_bank :: proc(pack: Battery_Bank, $N: int) -> [N]byte {
    res: [N]byte

    max_offset := len(pack) - N + 1

    start := 0
    for i in 0..<N {
        window := pack[start:max_offset + i]
        idx := slice.max_index(window) // don't check for 'ok'
        res[i] = window[idx]
        start += idx + 1
          
    }
    
    return res
}

solve :: proc(batteries: []Battery_Bank, $N: int) -> int {
    total_joltage := 0

    for battery in batteries {
        pack := build_pack_of_size_from_bank(battery, N)
        total_joltage += to_jolt(pack[:])
    }

    return total_joltage
}

main :: proc() {
    /* raw_input := #load("day3_example.txt") */
    raw_input := #load("day3.txt")
    raw_clone := bytes.clone(raw_input)
    batteries := parse_input(raw_clone)
    defer {
        delete(batteries)
        delete(raw_clone)
    }

    { // part 1
        p1 := solve(batteries, 2) 
        fmt.println("part 1 =>", p1)
    }
    { // part 2
        p2 := solve(batteries, 12) 
        fmt.println("part 2 =>", p2)
    }
}
