package main

import "core:fmt"
import "core:slice"

parse_data :: proc(raw_data: []byte) -> []byte {
    data := make([dynamic]byte)
    for b, i in raw_data {
        if b < '0' || b > '9' { break }
        append(&data, b - '0')
    }
    return data[:]
}

part_1 :: proc(data: []byte) -> (result: int) {
    return solution(data, 40)
}

part_2 :: proc(data: []byte) -> (result: int) {
    return solution(data, 50)
}

solution :: proc(data: []byte, n: int) -> (result: int) {
    data := slice.clone_to_dynamic(data)
    next := make([dynamic]byte)
    defer {
        delete(next)
        delete(data)
    }

    for _ in 0..<n {
        for i := 0; i < len(data); i += 1{
            count := 1
            elem := data[i]
            j := i + 1
            for ; j < len(data) && data[j] == elem; j += 1 {
                count += 1
            }
            if j != i + 1 do i = j - 1
            append(&next, byte(count))
            append(&next, elem)
        }
        
        delete(data)
        data = next
        next = make([dynamic]byte)
    }

    return len(data)
}

main :: proc() {
    raw_data := #load("day10.txt")
    { // part 1
        data := parse_data(raw_data)
        p1 := part_1(data)
        fmt.println("part 1 =>", p1)
        delete(data)
    }
    { // part 2
        data := parse_data(raw_data)
        p2 := part_2(data)
        fmt.println("part 2 =>", p2)
        delete(data)
    }
}
