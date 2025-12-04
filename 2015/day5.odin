package main

import "../utils"

import "core:fmt"
import "core:bytes"
import "core:mem"

raw_input := #load("day5.txt")

is_nice_p1 :: proc(line: []u8) -> bool {
    vowel_count := 0
    has_double := false
    size := len(line)
    for ch, i in line {
        switch {
        case ch == 'a': vowel_count += 1
        case ch == 'e': vowel_count += 1
        case ch == 'i': vowel_count += 1
        case ch == 'o': vowel_count += 1
        case ch == 'u': vowel_count += 1
        }
        if i + 1 < size {
            next := line[i + 1]

            if (ch == 'a' || ch == 'c' || ch == 'p' || ch == 'x') && ch + 1 == next  {
                return false
            }
            if line[i] == next do has_double = true 
        }
    }
    return vowel_count >= 3 && has_double
}

is_nice_p2 :: proc(line: []u8) -> bool {
    has_repetition := false
    has_surrounded := false

    size := len(line)

    for ch, i in line {
        if !has_repetition && i < size - 2 {
            for j := i + 2; j < size - 1; j += 1 {
                if line[i] == line[j] && line[i + 1] == line[j + 1] {
                    has_repetition = true
                    break
                }
            }
        }

        if !has_surrounded && i > 0 && i < size - 1 {
            if line[i - 1] == line[i + 1] {
                has_surrounded = true
            }
        }

        if has_repetition && has_surrounded do return true
    }

    return false
}

count_nice :: proc(lines: [][]u8, filter: proc([]u8) -> bool) -> (count: int) {
    l := lines[len(lines) - 1]
    for line in lines {
        if filter(line) do count += 1
    } 
    return
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    lines := utils.bytes_read_lines(raw_input)
    defer delete(lines)

    p1 := count_nice(lines, is_nice_p1)
    fmt.printf("part 1 => %d\n", p1)

    p2 := count_nice(lines, is_nice_p2)
    fmt.printf("part 2 => %d\n", p2)
    
}
