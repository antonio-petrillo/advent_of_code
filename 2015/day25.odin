package main

import "core:fmt"

starting :: 20151125
multiplier :: 252533
divider :: 33554393
up_right_dir :: [2]int{-1, 1}

parse_pos :: proc(raw_data: []byte) -> (pos: [2]int) {
    i := 0
    for raw_data[i] < '0' || raw_data[i] > '9' {
        i += 1
    }

    for j in 0..<4 {
        pos[0] = pos[0] * 10 + int(raw_data[i + j] - '0')
    }

    i += 4
    for raw_data[i] < '0' || raw_data[i] > '9' {
        i += 1
    }

    for j in 0..<4 {
        pos[1] = pos[1] * 10 + int(raw_data[i + j] - '0')
    }
    return
}

part_1 :: proc(target_pos: [2]int) -> int {
    pos := [2]int{1, 1}    
    curr := starting
    curr_row := 1

    for pos != target_pos {
        next_pos := pos + up_right_dir
        if next_pos[0] <= 0 {
            next_pos = [2]int{curr_row + 1, 1}
            curr_row += 1
        }
        pos = next_pos
        curr = curr * multiplier % divider
    }

    return curr
}

main :: proc() {
    raw_data := #load("day25.txt")
    target_pos := parse_pos(raw_data)

    p1 := part_1(target_pos)

    fmt.printf("Part 1 sol := %d\n", p1) 

}
