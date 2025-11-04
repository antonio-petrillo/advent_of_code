package main

import "core:fmt"
import "core:slice"

// can be done better, but it's not trivial to do since
// the indexes of 'inc sequence' and 'double pair' move at
// different speed
is_valid_passwd :: proc(passwd: []byte) -> bool {
    for ch in passwd {
        if ch == 'i' || ch == 'o' || ch == 'l' {
            return false
        }
    }

    pair_count := 0
    for i := 0; i < len(passwd) - 1; i += 1 {
        if passwd[i] == passwd[i + 1] {
            pair_count += 1
            i += 1
        }
    }

    if pair_count < 2 do return false

    has_increasing := false
    for i := 1; i < len(passwd) - 1; i += 1 {
        if passwd[i] - 1 == passwd[i - 1] && passwd[i] + 1 == passwd[i + 1] {
            has_increasing = true
            break
        }
    }
    return has_increasing
}

// In place destroying procedure
next_candidate :: proc(passwd: []byte) {
    passwd := passwd
    #reverse for ch, i in &passwd {
        if ch == 'z' {
            passwd[i] = 'a'
        } else {
            passwd[i] = ch + 1
            break
        } 
    }
}

part_1 :: proc(passwd: []byte) -> string {
    passwd := slice.clone(passwd)
    last := len(passwd) - 1
    for {
        next_candidate(passwd)

        if is_valid_passwd(passwd) {
            return string(passwd)
        }
    }

    return ""
}

main :: proc() {
    // note that #load put data into BSS so it's immutable (it's part of the binary)
    input := #load("day11.txt")
    input = input[:len(input) - 1] // discard 'newline'

    p1 := part_1(input)
    fmt.println("part 1 =>", p1)
    defer delete(p1)


    p2 := part_1(transmute([]u8)p1) // safe because I know that p1 contains only ascii characters
    fmt.println("part 2 =>", p2)
    delete(p2)
}
