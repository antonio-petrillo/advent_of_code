package main

import "../utils"

import "core:fmt"
import "core:mem"

Graph :: [][]byte
Pos :: [2]int

parse_input :: proc(raw: []byte) -> (Graph, Pos) {
    start: Pos
    graph := utils.read_lines(raw)

    outer: for row, x in graph {
        for cell, y in row {
            if cell == 'S' {
                start = {x, y}
                break outer
            }
        }
    }

    return graph[:], start
}

solve :: proc(g: Graph, s: Pos) -> (int, int) {
    width := len(g[0])

    cur_beam := make([]int, width)
    next_beam := make([]int, width)

    defer {
        delete(cur_beam)
        delete(next_beam)
    }

    cur_beam[s[1]] = 1
    splits := 0

    for row in g[1:] {
        for cell, idx in row {
            next_beam[idx] += cur_beam[idx]
            if cell == '^' {
                if cur_beam[idx] > 0 {splits += 1}
                if idx >= 1 {
                    next_beam[idx - 1] += cur_beam[idx]
                }
                if idx < width - 1 {
                    next_beam[idx + 1] += cur_beam[idx]
                }
                next_beam[idx] = 0
            }
            cur_beam[idx] = 0
        }
        cur_beam, next_beam = next_beam, cur_beam
    }

    sum  := 0
    for beam in cur_beam {
        sum += beam
    }
    
    return splits, sum
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    /* raw_input := #load("day7_example.txt") */
    raw_input := #load("day7.txt")
    graph, start := parse_input(raw_input)

    defer {
        delete(graph)
    }

    { // part 1 & 2
        p1, p2 := solve(graph, start)
        fmt.println("part 1 =>", p1)
        fmt.println("part 2 =>", p2)
    }

}
