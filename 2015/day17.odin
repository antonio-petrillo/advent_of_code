package main

import "../utils"

import "core:fmt"
import "core:bytes"
import "core:os"
import "core:slice"
import "core:container/queue"

parse_input :: proc(input: []byte) -> []int {
    lines := utils.bytes_read_lines(input)
    defer delete(lines)

    containers := make([dynamic]int)
    for line in lines {
        append(&containers, utils.parse_number(line))
    }

    return containers[:]
}

part_1 :: proc($TARGET: int, containers: []int) -> int {
    recursive_count :: proc($TARGET: int, curr_index, sum: int, containers: []int, result: ^int) {
        if curr_index >= len(containers) { return }

        for index := curr_index + 1; index < len(containers); index += 1 {
            next_sum := sum + containers[index]
            if next_sum == TARGET {
                result^ += 1
            } else if  next_sum < TARGET {
                recursive_count(TARGET, index, next_sum, containers, result)
            }
        }
    }
    result := 0
    for container, index in containers {
        recursive_count(TARGET, index, container, containers, &result)
    }
    
    return result
}

part_2 :: proc($TARGET: int, containers: []int) -> int {
    recursive_count :: proc($TARGET: int, containers: []int, curr_index, sum, running_sum_length: int, result: ^[dynamic]int) {
        if curr_index >= len(containers) { return }

        for index := curr_index + 1; index < len(containers); index += 1 {
            next_sum := sum + containers[index]
            if next_sum == TARGET {
                append(result, running_sum_length + 1)
            } else if  next_sum < TARGET {
                recursive_count(TARGET, containers, index, next_sum, running_sum_length + 1, result)
            }
        }
    }

    min_size := -1

    sum_up_to_target := make([dynamic]int)
    defer delete(sum_up_to_target)
    for container, index in containers {
        recursive_count(TARGET, containers, index, container, 1, &sum_up_to_target)
    }

    if len(sum_up_to_target) == 0 { return -1 } // ERR:

    min_required := sum_up_to_target[0]

    for sum in sum_up_to_target[1:] {
        if sum < min_required {
            min_required = sum
        }
    }

    result := 0

    for sum in sum_up_to_target {
        if sum == min_required { result += 1 } 
    }

    return result
}

main :: proc() {
    input := #load("day17.txt") 

    { // part 1
        containers := parse_input(input) 
        defer delete(containers)

        p1 := part_1(150, containers[:])
        fmt.println("part 1 => ", p1)
    }

    { // part 2
        containers := parse_input(input) 
        defer delete(containers)

        p2 := part_2(150, containers[:])
        fmt.println("part 2 => ", p2)
    }

}
