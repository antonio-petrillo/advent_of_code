package main

import "core:os"
import "core:fmt"

Box :: struct {
    w: int,
    h: int,
    l: int,
}

parse_boxes :: proc(data: []u8) -> [dynamic]Box {
    boxes := make([dynamic]Box)

    i := 0
    for i < len(data){
        w := 0
        for j := i; true ; j += 1 {
            if data[j] == 'x' {
                i = j + 1
                break
            }
            w = w * 10 + int(data[j]) - '0'
        }
        h := 0
        for j := i; true ; j += 1 {
            if data[j] == 'x' {
                i = j + 1
                break
            }
            h = h * 10 + int(data[j]) - '0' 
        }
        l := 0
        for j := i; true ; j += 1 {
            if data[j] == '\n' || j == len(boxes) - 1 {
                i = j + 1
                break
            }
            l = l * 10 + int(data[j]) - '0'
        }
        append(&boxes, Box{w, h, l})
    }
    
    return boxes
}

part_1 :: proc(boxes: [dynamic]Box) -> (total_surface: int) {
    for box in boxes {
        wh := box.w * box.h 
        min := wh

        wl := box.w * box.l
        if wl < min do min = wl

        lh := box.l * box.h
        if lh < min do min = lh

        box_surface := 2 * wh + 2 * wl + 2 * lh + min

        total_surface += box_surface
    }
    return
} 

part_2 :: proc(boxes: [dynamic]Box) -> (total: int) {
    for box in boxes {
        wwhh := box.w * 2 + box.h * 2
        min := wwhh
        wwll := box.w * 2 + box.l * 2
        if wwll < min do min = wwll
        hhll := box.h * 2 + box.l * 2
        if hhll < min do min = hhll

        total += min + box.w * box.h * box.l
    }
    return
} 

main :: proc() {
    data := #load("day2.txt")

    boxes := parse_boxes(data)
    defer delete(boxes)

    p1 := part_1(boxes)
    fmt.printf("part 1 => %d\n", p1)

    p2 := part_2(boxes)
    fmt.printf("part 2 => %d\n", p2)
}
