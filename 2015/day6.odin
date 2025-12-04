package main

import "../utils"

import "core:bytes"
import "core:fmt"
import "core:mem"

raw_data := #load("day6.txt")

Action :: enum {
    Toggle,
    Turn_On,
    Turn_Off,
}

Instruction :: struct {
    start: [2]int,
    end: [2]int,
    action: Action,
}

parse_instructions :: proc(lines: [][]u8) -> []Instruction {
    parsed := make([dynamic]Instruction)
    turn_on := transmute([]byte)string("turn on")
    turn_off := transmute([]byte)string("turn off")
    toggle := transmute([]byte)string("toggle")
    
    index := 0

    for line in lines {
        if len(line) == 0 do continue

        instr: Instruction
        switch {
        case bytes.has_prefix(line, turn_on):
            instr.action = .Turn_On
            index = len(turn_on) + 1

        case bytes.has_prefix(line, turn_off):
            instr.action = .Turn_Off
            index = len(turn_off) + 1

        case bytes.has_prefix(line, toggle):
            instr.action = .Toggle
            index = len(toggle) + 1
        }

        acc := 0
        for ; line[index] != ' '; index += 1 {
            if line[index] == ',' {
                instr.start[0] = acc
                acc = 0
                continue
            } 
            acc = acc * 10 + int(line[index] - '0')
        }
        instr.start[1] = acc
        acc = 0


        index += 9 // len(" through ") == 9

        for ; index < len(line); index += 1 {
            if line[index] == ',' {
                instr.end[0] = acc
                acc = 0
                continue
            } 
            acc = acc * 10 + int(line[index] - '0')
        }
        instr.end[1] = acc
        append(&parsed, instr)
    }  
    return parsed[:]
}

pair_to_index :: #force_inline proc(i,j, col_size: int) -> int {
    return i * col_size + j
}

part_1 :: proc(instructions: []Instruction) -> (count: int) {
    board := make([]bool, 1000*1000)
    defer delete(board)

    on :: #force_inline proc(cell: ^bool) {
        cell^ = true
    }

    off :: #force_inline proc(cell: ^bool) {
        cell^ = false
    }

    toggle :: #force_inline proc(cell: ^bool) {
        cell^ = !cell^
    }

    for instr in instructions {
        fn: proc(^bool)
        switch instr.action {
        case .Toggle:
            fn = toggle
        case .Turn_On:
            fn = on
        case .Turn_Off:
            fn = off
        }

        for i in instr.start[0]..=instr.end[0] {
            for j in instr.start[1]..=instr.end[1] {
                index := pair_to_index(i, j, 1000) 
                fn(&board[index])
            }
        }
    }

    for cell in board {
        if cell do count += 1
    }

    return 
}

part_2 :: proc(instructions: []Instruction) -> (brightness: int) {
    board := make([]int, 1000*1000)
    defer delete(board)

    on :: #force_inline proc(cell: ^int) {
        cell^ += 1
    }

    off :: #force_inline proc(cell: ^int) {
        cell^ -= cell^ == 0 ? 0 : 1
    }

    toggle :: #force_inline proc(cell: ^int) {
        cell^ += 2
    }

    for instr in instructions {
        fn: proc(^int)
        switch instr.action {
        case .Toggle:
            fn = toggle
        case .Turn_On:
            fn = on
        case .Turn_Off:
            fn = off
        }

        for i in instr.start[0]..=instr.end[0] {
            for j in instr.start[1]..=instr.end[1] {
                index := pair_to_index(i, j, 1000) 
                fn(&board[index])
            }
        }
    }

    for cell in board {
        brightness += cell
    }

    return 
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    raw_data := #load("day6.txt")
    raw_lines := utils.bytes_read_lines(raw_data)
    instructions := parse_instructions(raw_lines)
    defer {
        delete(raw_lines)
        delete(instructions)
    }

    p1 := part_1(instructions)
    fmt.printf("part 1 => %d\n", p1)

    p2 := part_2(instructions)
    fmt.printf("part 2 => %d\n", p2)
}
