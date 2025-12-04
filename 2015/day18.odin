package main

import "../utils"

import "core:bytes"
import "core:mem"
import "core:fmt"

Height :: 100
Width :: 100

Grid :: [Height][Width]bool

parse_data :: proc(raw: []byte) -> ^Grid {
    g := new(Grid)

    lines := utils.bytes_read_lines(raw)
    defer delete(lines)

    i := 0
    for line in lines {
        for ch, j in line {
            g^[i][j] = ch == '#'
        }
        i += 1
    }

    return g
}

deltas :: [8][2]int{
    {1, 0},
    {-1, 0},
    {0, 1},
    {0, -1},
    {1, 1},
    {-1, -1},
    {-1, 1},
    {1, -1},
}

is_valid_pos :: proc(pos: [2]int) -> bool {
    return pos[0] >= 0 && pos[0] < Height && pos[1] >= 0 && pos[1] < Width
}

game_of_life_step :: proc(curr, next: ^Grid) {
    for row, r in curr^ {
        for cell, c in row {
            cur_pos := [2]int{r, c}
            alive := 0
            for delta in deltas {
                neighbour_pos := cur_pos + delta 
                dr, dc := neighbour_pos[0], neighbour_pos[1]
                if is_valid_pos(neighbour_pos) && curr^[dr][dc] {
                    alive += 1
                }
            }
            switch {
            case alive == 2:
                next^[r][c] = cell
            case alive == 3:
                next^[r][c] = true
            case:
                next^[r][c] = false
            }
        }
    }
}

part_1 :: proc(g: ^Grid) -> int {
    curr := g
    next_grid: Grid
    next_grid_ptr := &next_grid
    first := true
    for i in 0..<100 {
        game_of_life_step(curr, next_grid_ptr) 
        curr, next_grid_ptr = next_grid_ptr, curr
    }
    result := 0
    for row in curr^ {
        for cell in row {
            if cell { result += 1 }
        }
    }
    return result
}

part_2 :: proc(g: ^Grid) -> int  {
    curr := g
    next_grid: Grid
    next_grid_ptr := &next_grid
    first := true
    for i in 0..<100 {
        game_of_life_step(curr, next_grid_ptr) 
        curr, next_grid_ptr = next_grid_ptr, curr
        curr^[0][0] = true
        curr^[0][Width - 1] = true
        curr^[Height - 1][0] = true
        curr^[Height - 1][Width - 1] = true
    }
    result := 0
    for row in curr^ {
        for cell in row {
            if cell { result += 1 }
        }
    }
    return result
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    raw_data := #load("day18.txt")
    {// part 1
        grid := parse_data(raw_data)
        defer free(grid)
        p1 := part_1(grid)
        fmt.println("p1 =>", p1)
    }
    {// part 2
        grid := parse_data(raw_data)
        defer free(grid)
        p1 := part_2(grid)
        fmt.println("p2 =>", p1)
    }
}
