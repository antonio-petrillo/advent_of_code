package main

import "core:fmt"

part_1 :: proc(data: []u8) -> int {
    visited := make(map[[2]int]int)
    defer delete(visited)

    pos := [2]int{0, 0}
    visited[pos] = 1
    for move in data {
        switch {
        case move == '>':
            pos += [2]int{1, 0}
        case move == '^':
            pos += [2]int{0, 1}
        case move == '<':
            pos += [2]int{-1, 0}
        case move == 'v':
            pos += [2]int{0, -1}
        } 

        visited[pos] += 1
    }
    return len(visited)
}

part_2 :: proc(data: []u8) -> int {
    visited := make(map[[2]int]int)
    defer delete(visited)

    santa := [2]int{0, 0}
    robot_santa := [2]int{0, 0}
    visited[santa] = 2

    is_robot := false
    pos := &santa

    for move in data {
        switch {
        case move == '>':
            pos^ += [2]int{1, 0}
        case move == '^':
            pos^ += [2]int{0, 1}
        case move == '<':
            pos^ += [2]int{-1, 0}
        case move == 'v':
            pos^ += [2]int{0, -1}
        } 

        visited[pos^] += 1

        pos = is_robot ? &santa : &robot_santa
        is_robot = !is_robot
    }
    return len(visited)
}

main :: proc() {
    data := #load("day3.txt") 

    p1 := part_1(data)
    fmt.printf("part 1 => %d\n", p1)

    p2 := part_2(data)
    fmt.printf("part 2 => %d\n", p2)
}
