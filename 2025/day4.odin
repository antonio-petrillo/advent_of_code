package main

import "../utils"

import "core:fmt"
import "core:slice"

Board :: #type [][]byte
Position :: #type [2]int

count_rolls :: proc(b: Board, p: Position) -> (n: int) {
    @(static)
    @(rodata)
    deltas := [?]Position{
        {1, 0}, {1, 1}, {0, 1}, {-1, 1},
        {-1, 0}, {-1, -1}, {0, -1}, {1, -1}
    }
    
    for delta in deltas {
        new_pos := p + delta
        if new_pos[0] < 0 || new_pos[0] >= len(b[0]) || new_pos[1] < 0 || new_pos[1] >= len(b) {
            continue
        }
        if b[new_pos[0]][new_pos[1]] == '@' { n += 1}
    }
    return 
}

solve :: proc(b: Board, $REMOVE: bool) -> (n: int) {
    for row, x in b {
        for &cell, y in row {
            if cell == '@' && count_rolls(b, {x, y}) < 4 {
                n += 1
                if REMOVE { cell = '.' }
            }
        }
    }

    return
}

part_1 :: proc(b: Board) -> (n: int) {
    return solve(b, false)
}

clone_board :: proc(b: Board, allocator := context.allocator) -> Board {
    cloned, err := slice.clone(b, allocator) 
    assert(err == nil)
    for row, i in b {
        cloned[i], err = slice.clone(row, allocator)
        assert(err == nil)
    }
    return cloned
}

remove_rolls :: proc(b: Board) -> (n: int) {
    for row, x in b {
        for &cell, y in row {
            if cell == '@' && count_rolls(b, {x, y}) < 4 {
                n += 1
                cell = '.'
            }
        }
    }

    return
}

part_2 :: proc(b: Board) -> (n: int) {
    context.allocator = context.temp_allocator
    defer free_all(context.allocator)
    b := clone_board(b)

    for {
        num_removed := solve(b, true)
        if num_removed == 0 { break }
        n += num_removed
    }    

    return
}

main :: proc() {
    raw := #load("day4.txt")
    /* raw := #load("day4_example.txt")  */
    board := utils.bytes_read_lines(raw)
    defer delete(board)
    { // part 1
        p1 := part_1(board) 
        fmt.println("part 1 =>", p1)
    }
    { // part 2
        p2 := part_2(board) 
        fmt.println("part 2 =>", p2)
    }
}
