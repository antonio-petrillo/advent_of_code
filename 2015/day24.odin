package main

import "core:bytes"
import "core:fmt"
import "core:os"

import "./utils"

parse_number :: proc(bs: []byte) -> (n: int) {
    for b in bs {
        n = n * 10 + int(b - '0')
    }
    return
}

parse_weights :: proc(input: []byte) -> []int {
    weights := make([dynamic]int)
    lines := bytes.split(input, []byte{'\n'})
    defer delete(lines)

    for line in lines[:len(lines) - 1] {
        append(&weights, parse_number(line))
    }

    return weights[:]
}

balance :: proc(weights: []int, parts: int) -> int {
    sum := 0
    for weight in weights { sum += weight }

    target_weight := sum / parts

    entanglements := make([dynamic]int)
    defer delete(entanglements)

    min_entanglements: Maybe(int) = nil 

    size := len(weights) 
    for i in 1..=size {
        iter, err_iter := utils.make_combination_iterator(weights, uint(i))
        assert(err_iter == nil)
        defer utils.destroy_combination_iterator(iter)

        found := false
        for utils.combine(&iter) {
            combination := iter.combination
            sum = 0
            quantum_entanglement := 1
            for item in combination {
                sum += item
                quantum_entanglement *= item
            }
            if sum != target_weight { continue } // invalid config

            found = true

            if min_entanglements == nil || min_entanglements.? > quantum_entanglement {
                min_entanglements = quantum_entanglement
            }
        }
        if found { break }
    }

    return min_entanglements.?
}

part_1 :: proc(weights: []int) -> int {
    return balance(weights, 3)
}

part_2 :: proc(weights: []int) -> int {
    return balance(weights, 4)
}

main :: proc() {
    input := #load("day24.txt")
    weights := parse_weights(input)

    defer delete(weights)

    { // part 1
        p1 := part_1(weights)
        fmt.println("part 1 =>", p1)
    }

    { // part 2
        p2 := part_2(weights)
        fmt.println("part 2 =>", p2)
    }
}
