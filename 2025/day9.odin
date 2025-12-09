package main

import "../utils"

import "core:fmt"
import "core:mem"
import "core:strings"
import "core:strconv"

Point :: #type [2]int

parse_input :: proc(raw: ^string) -> []Point {
    points := make([dynamic]Point)
    for line in strings.split_iterator(raw, utils.string_line_separator) {
        line := line
        p: Point
        i := 0
        for comp in strings.split_iterator(&line, ",") {
            n, ok := strconv.parse_int(comp)
            assert(ok && i < 2)
            p[i] = n
            i += 1
        }
        append(&points, p)
    } 
    return points[:]
}

part_1 :: proc(ps: []Point) -> int {
    result := 0
    for p1, i in ps {
        for p2 in ps[i + 1:] {
            rect := p2 - p1
            area := (abs(rect[0]) + 1) * (abs(rect[1]) + 1)

            if area > result { result = area }
        } 
    }
    return result
}


// Today I've got beaten up by this problem, I've almost found a working solution on myself, but I don't know my raycasting algorithm didn't cover all the cases
// https://www.reddit.com/r/adventofcode/comments/1pi3hff/2025_day_9_part_2_a_simple_method_spoiler/
// https://github.com/blfuentes/AdventOfCode_AllYears/blob/main/AdventOfCode_2025_Go/day09/day09_2.go
// https://kishimotostudios.com/articles/aabb_collision/
part_2 :: proc(ps: []Point) -> int {
    min_row, min_col := 1e9, 1e9
    max_row, max_col := 0, 0

    for p in ps {
        min_col = min(min_col, p[0])
        max_col = max(max_col, p[0])
        min_row = min(min_row, p[1])
        max_row = max(max_row, p[1])
    }

    sides := make([dynamic][2]Point)
    defer delete(sides)

    n := len(ps)
    for p1, idx in ps {
        p2 := ps[(idx + 1) % n]
        append(&sides, [2]Point{p1, p2})        
    }
     
    result := 0
    for p1, idx in ps {
        for p2 in ps[idx + 1:] {
            rect := p2 - p1
            // euristic: The best area is not on a straight line
            if rect[0] == 0 || rect[1] == 0 { continue }

            area := (abs(rect[0]) + 1) * (abs(rect[1]) + 1)

            if area > result {

                min_x, max_x := min(p1[1], p2[1]), max(p1[1], p2[1])
                min_y, max_y := min(p1[0], p2[0]), max(p1[0], p2[0])


                if !intersect(min_x, min_y, max_x, max_y, sides[:]) {
                    result = area
                }
            }
         }        
    }

    return result
}

intersect :: proc(min_x, min_y, max_x, max_y: int, edges: [][2]Point) -> bool {
    for edge in edges {
        i_min_x, i_max_x := min(edge[0][1], edge[1][1]), max(edge[0][1], edge[1][1])
        i_min_y, i_max_y := min(edge[0][0], edge[1][0]), max(edge[0][0], edge[1][0])

        if min_x < i_max_x && max_x > i_min_x && min_y < i_max_y && max_y > i_min_y { return true }
    }

    return false
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    /* raw_input := #load("day9_example.txt", string) */
    raw_input := #load("day9.txt", string)

    points := parse_input(&raw_input)
    defer { delete(points) }

    { // part  1
        p1 := part_1(points)
        fmt.println("part 1 =>", p1) 
    }

    { // part  2
        p2 := part_2(points)
        fmt.println("part 2 =>", p2) 
    }

}
