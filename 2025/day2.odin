package main

import "../utils"

import "core:fmt"

Interval :: #type [2]int

parse_input :: proc(raw: []byte) -> []Interval {
    raw := raw
    if raw[len(raw) - 1] == '\n' { raw = raw[:len(raw) - 1] }
    xs := make([dynamic]Interval)

    i: Interval
    idx := 0
    for b in raw {
        if b == ',' {
            append(&xs, i) 
            i[0], i[1] = 0, 0
            idx = 0
        } else if b == '-' {
           idx = 1 
        } else if b >= '0' && b <= '9' {
            i[idx] = i[idx] * 10 + int(b - '0') 
        }
    }

    append(&xs, i) 
    
    return xs[:]
}

is_invalid :: proc(n: int) -> bool {
    num_digits := 0
    n1 := n
    for n1 != 0 {
        num_digits += 1
        n1 /= 10
    }
    if num_digits & 1 != 0 { return false }

    half := num_digits >> 1

    ten_power := 1
    for i in 0..<half { ten_power *= 10 }

    return n % ten_power == n / ten_power
}

part_1 :: proc(intervals: []Interval) -> (n: int) {
    for i in intervals {
        for num in i[0]..=i[1] {
            if is_invalid(num) {
               n += num 
            }
        } 
    }
    return
}

is_invalid_2 :: proc(n: int) -> bool {
    num_digits := 0
    n1 := n
    for n1 != 0 {
        num_digits += 1
        n1 /= 10
    }

    half := num_digits >> 1

    for ten_pow, i := 10, 1; i <= half; ten_pow, i = ten_pow * 10, i + 1 {
        count := 0
        pattern := n % ten_pow
        n2 := n
        for n2 != 0 {
            if n2 % ten_pow == pattern { count += 1 }
            n2 /= ten_pow
        }
        if count >= 2 && num_digits == i * count { return true }
    }

    return false
}

part_2 :: proc(intervals: []Interval) -> (n: int) {
    for i in intervals {
        for num in i[0]..=i[1] {
            if is_invalid_2(num) {
               n += num 
            }
        } 
    }
    return
}

main :: proc() {
    raw_input := #load("day2.txt")
    /* raw_input := #load("day2_example.txt") */
    intervals := parse_input(raw_input)
    defer delete(intervals)

    { // part 1
        p1 := part_1(intervals) 
        fmt.println("part 1 =>", p1)
    }
    { // part 2
        p2 := part_2(intervals) 
        fmt.println("part 2 =>", p2)
    }
    
}
