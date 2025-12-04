package main

import "../utils"

import "core:fmt"
import "core:bytes"
import "core:mem"

Wire :: distinct string
Signal :: distinct u16

Data :: union {
    Wire,
    Signal,
}

BinOpKind :: enum u8 {
    And,
    Or,
    LShift,
    RShift,
}

BinOp :: struct {
    kind: BinOpKind,
    left: Data,
    right: Data,
}

UnaryNotOp :: distinct Data

Ast :: union{
    BinOp,
    UnaryNotOp,
    Data,
}

parse_data :: proc(data: []byte) -> Data {
    if data[0] >= '0' && data[0] <= '9' {
        acc: Signal = 0 
        for digit in data {
            acc = acc * 10 + Signal(digit - '0')
        }
        return acc
    } 
    return Wire(data)
}

parse_input :: proc(raw_data: []byte) -> map[Wire]Ast {
    circuit := make(map[Wire]Ast)

    lines := utils.bytes_read_lines(raw_data)
    defer delete(lines)

    for line in lines { // skip last blank line
        tokens := bytes.split(line, []byte{' '})
        defer delete(tokens)
        switch len(tokens) {
        case 5:

            op_kind: BinOpKind
            switch {
            case bytes.equal(tokens[1], []byte{'A', 'N', 'D'}): op_kind = .And
            case bytes.equal(tokens[1], []byte{'O', 'R'}): op_kind = .Or
            case bytes.equal(tokens[1], []byte{'L', 'S', 'H', 'I', 'F', 'T'}): op_kind = .LShift
            case bytes.equal(tokens[1], []byte{'R', 'S', 'H', 'I', 'F', 'T'}): op_kind = .RShift
            }

            circuit[parse_data(tokens[4]).(Wire)] = BinOp{
                left = parse_data(tokens[0]),
                right = parse_data(tokens[2]),
                kind = op_kind,
            }
        case 4:
            circuit[parse_data(tokens[3]).(Wire)] = UnaryNotOp(parse_data(tokens[1]))
        case 3:
            operand := parse_data(tokens[0])
            output := parse_data(tokens[2]).(Wire)
            circuit[output] = operand
        }
    }
    return circuit
}

@(private)
resolve :: proc(cache: ^map[Wire]Signal, circuit: map[Wire]Ast, any_data: Data) -> (signal: Signal) {
    cache := cache
    switch data in any_data {
    case Signal:
        signal = data 
    case Wire:
        if data in cache do return cache[data] 
        signal = eval(cache, circuit, data)
        cache[data] = signal
    }
    return 
}

@(private)
eval :: proc(cache: ^map[Wire]Signal, circuit: map[Wire]Ast, wire: Wire) -> (signal: Signal) {
    if wire in cache do return cache[wire] 
    switch ast in circuit[wire] {
    case BinOp:
        left := resolve(cache, circuit, ast.left)
        right := resolve(cache, circuit, ast.right)

        switch ast.kind {
        case .And: signal = left & right
        case .Or: signal = left | right
        case .LShift: signal = left << right
        case .RShift: signal = left >> right
        }

    case UnaryNotOp:
        signal = ~resolve(cache, circuit, Data(ast))

    case Data:
        signal = resolve(cache, circuit, ast)
    }
    cache[wire] = signal 
    return 
}

part_1 :: proc(circuit: map[Wire]Ast) -> Signal {
    cache := make(map[Wire]Signal)
    defer delete(cache)
    return eval(&cache, circuit, "a")
}

part_2 :: proc(circuit: map[Wire]Ast) -> Signal {
    result: Data = part_1(circuit)
    circuit := circuit
    circuit["b"] = result
    return part_1(circuit)
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)
 
    raw_data := #load("day7.txt")
    circuit := parse_input(raw_data) 
    defer delete(circuit)

    p1 := part_1(circuit)
    fmt.printfln("part 1 => %d", p1)
    p2 := part_2(circuit)
    fmt.printfln("part 2 => %d", p2)
}
