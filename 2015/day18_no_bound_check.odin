package main

import "../utils"

import "core:bytes"
import "core:fmt"

Height :: 102
Width :: 102

Grid :: [Height][Width]bool

parse_data :: proc(raw: []byte) -> ^Grid #no_bounds_check {
    g := new(Grid)

    lines := utils.bytes_read_lines(raw)
    defer delete(lines)

    i := 1
    for line in lines {
        for ch, j in line {
            g^[i][j + 1] = ch == '#'
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

game_of_life_step :: proc(curr, next: ^Grid) #no_bounds_check {
    for r := 1; r < Height - 1; r += 1 {
        row := curr^[r]
        for c := 1; c < Width - 1; c += 1 {
            cur_pos := [2]int{r, c}
            alive := 0
            for delta in deltas {
                neighbour_pos := cur_pos + delta 
                dr, dc := neighbour_pos[0], neighbour_pos[1]
                if curr^[dr][dc] {
                    alive += 1
                }
            }
            switch {
            case alive == 2:
                next^[r][c] = row[c]
            case alive == 3:
                next^[r][c] = true
            case:
                next^[r][c] = false
            }
        }
    }
}

part_1 :: proc(g: ^Grid) -> int #no_bounds_check {
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

part_2 :: proc(g: ^Grid) -> int #no_bounds_check  {
    curr := g
    next_grid: Grid
    next_grid_ptr := &next_grid
    first := true
    for i in 0..<100 {
        game_of_life_step(curr, next_grid_ptr) 
        curr, next_grid_ptr = next_grid_ptr, curr
        curr^[1][1] = true
        curr^[1][Width - 2] = true
        curr^[Height - 2][1] = true
        curr^[Height - 2][Width - 2] = true
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
// https://www.reddit.com/r/adventofcode/comments/3xb3cj/day_18_solutions/
// Didn't notice any particular improvment without the bound check
// I stil have to check if the cell to increment 'alive', I don't see a way to avoid that branching op
