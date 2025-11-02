package main

import "core:fmt"
import "core:bytes"

Computer :: [2]u64

OpKind :: enum u8 {
    Inc,
    Hlf,
    Tpl,
    Jmp,
    Jie,
    Jio,
}

Op :: struct {
    kind: OpKind,
    reg_index: u8,
    offset: int,
}

parse_number :: proc(data: []byte) -> int {
    num := 0
    sign := data[0] == '+' ? 1 : -1
    for ch in data[1:] {
        num = num * 10 + int(ch - '0')
    }
    return sign * num
}

parse_instructions :: proc(raw_data: []byte) -> [dynamic]Op {
    instructions := make([dynamic]Op)
    parse_loop: for line, asdf in bytes.split(raw_data, []byte{'\n'}) {
        tokens := bytes.split(line, []byte{' '}) 
        if len(tokens) < 2 do continue
        offset_index := 2
        op: Op
        switch tokens[0][0] {
        case 'j':
            switch tokens[0][2] {
                case 'o': op.kind = .Jio
                case 'e': op.kind = .Jie
                case 'p':
                    op.kind = .Jmp
                    offset_index = 1
            }
            op.offset = parse_number(tokens[offset_index])

        case 'h': op.kind = .Hlf
        case 'i': op.kind = .Inc
        case 't': op.kind = .Tpl
        }
        op.reg_index = tokens[1][0] == 'a' ? 0 : 1
        append(&instructions, op)
    }
    return instructions
}

compute :: proc(computer: ^Computer, ops: [dynamic]Op) -> u64 {
    for pc := 0; pc < len(ops); pc += 1 {
        op := ops[pc]
        pre := pc
        switch op.kind {
        case .Inc:   
            computer[op.reg_index] += 1
        case .Hlf:   
            computer[op.reg_index] >>= 1
        case .Tpl:   
            computer[op.reg_index] *= 3
        case .Jmp:   
            pc += op.offset - 1
        case .Jie:   
            if computer[op.reg_index] & 1 == 0 {
                pc += op.offset - 1
            }
        case .Jio:   
            if computer[op.reg_index] == 1 {
                pc += op.offset - 1
            }
        } 
    }

    return computer[1]
} 

part_1 :: proc(ops: [dynamic]Op) -> u64 {
    computer: Computer
    return compute(&computer, ops)
}

part_2 :: proc(ops: [dynamic]Op) -> u64 {
    computer := Computer{1, 0}
    return compute(&computer, ops)
}
 
main :: proc() {
    raw_data := #load("day23.txt")
    instructions := parse_instructions(raw_data)
    defer delete(instructions)

    p1 := part_1(instructions)
    fmt.printfln("part 1 => %d", p1)

    p2 := part_2(instructions)
    fmt.printfln("part 2 => %d", p2)
    
}
