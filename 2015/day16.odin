package main

import "../utils"

import "core:fmt"
import "core:mem"
import "core:text/regex"

Sue :: struct {
    id: int,
    children: int,
    cats: int,
    samoyeds: int,
    pomeranians: int,
    akitas: int,
    vizslas: int,
    goldfish: int,
    trees: int,
    cars: int,
    perfumes: int,
}

Pair :: struct {
    k: string,
    v: int,
}

parse_key_param :: proc(key, val: string, sue: ^Sue) {
    val := utils.parse_number(val)
    switch key {
    case "children": 
        sue.children = val
    case "cats": 
        sue.cats = val
    case "samoyeds": 
        sue.samoyeds = val
    case "pomeranians": 
        sue.pomeranians = val
    case "akitas": 
        sue.akitas = val
    case "vizslas": 
        sue.vizslas = val
    case "goldfish": 
        sue.goldfish = val
    case "trees": 
        sue.trees = val
    case "cars": 
        sue.cars = val
    case "perfumes": 
        sue.perfumes = val
    }
}

when ODIN_OS == .Windows {
    @(private = "file")
    @(rodata)
    regex_literal :=  "Sue (\\d+): (\\w+): (\\d+), (\\w+): (\\d+), (\\w+): (\\d+)\r\n"
    
} else {
    @(private = "file")
    @(rodata)
    regex_literal :=  "Sue (\\d+): (\\w+): (\\d+), (\\w+): (\\d+), (\\w+): (\\d+)\n"
}

parse_aunts_sue :: proc(input: string) -> [dynamic]Sue {
    aunts := make([dynamic]Sue)

    iter, err_iter := regex.create_iterator(input, regex_literal)
    assert(err_iter == nil)
    defer regex.destroy_iterator(iter)

    for aunt in regex.match_iterator(&iter)  {
        sue: Sue = {
            children = -1,
            cats = -1,
            samoyeds = -1,
            pomeranians = -1,
            akitas = -1,
            vizslas = -1,
            goldfish = -1,
            trees = -1,
            cars = -1,
            perfumes = -1,
        }
        sue.id = utils.parse_number(aunt.groups[1])

        parse_key_param(aunt.groups[2], aunt.groups[3], &sue)
        parse_key_param(aunt.groups[4], aunt.groups[5], &sue)
        parse_key_param(aunt.groups[6], aunt.groups[7], &sue)

        append(&aunts, sue)
    }

    return aunts
}

target_sue := []Pair{
    {"children", 3},
    {"cats", 7},
    {"samoyeds", 2},
    {"pomeranians", 3},
    {"akitas", 0},
    {"vizslas", 0},
    {"goldfish", 5},
    {"trees", 3},
    {"cars", 2},
    {"perfumes", 1},
}

part_1 :: proc(input: string) -> int {
    aunts := parse_aunts_sue(input)
    auxiliar := make([dynamic]Sue)

    defer {
        delete(aunts)
        delete(auxiliar)
    }

    compare_field :: proc(p: Pair, s: Sue) -> (b: bool) {
        switch p.k {
        case "children": b = s.children <= -1 || s.children == p.v
        case "cats": b = s.cats <= -1 || s.cats == p.v
        case "samoyeds": b = s.samoyeds <= -1 || s.samoyeds == p.v
        case "pomeranians": b = s.pomeranians <= -1 || s.pomeranians == p.v
        case "akitas": b = s.akitas <= -1 || s.akitas == p.v
        case "vizslas": b = s.vizslas <= -1 || s.vizslas == p.v
        case "goldfish": b = s.goldfish <= -1 || s.goldfish == p.v
        case "trees": b = s.trees <= -1 || s.trees == p.v
        case "cars": b = s.cars <= -1 || s.cars == p.v
        case "perfumes": b = s.perfumes <= -1 || s.perfumes == p.v
        }
        return b
    }

    for pair in target_sue {
        for aunt in aunts {
            if compare_field(pair, aunt) {
                append(&auxiliar, aunt)
            } 
        }
        clear(&aunts)
        aunts, auxiliar = auxiliar, aunts
    }

    if len(aunts) == 1 {
       return aunts[0].id 
    }

    return -1
}

part_2 :: proc(input: string) -> int {
    aunts := parse_aunts_sue(input)
    auxiliar := make([dynamic]Sue)

    defer {
        delete(aunts)
        delete(auxiliar)
    }

    compare_field :: proc(p: Pair, s: Sue) -> (b: bool) {
        switch p.k {
        case "children": b = s.children <= -1 || s.children == p.v
        case "cats": b = s.cats <= -1 || s.cats > p.v
        case "samoyeds": b = s.samoyeds <= -1 || s.samoyeds == p.v
        case "pomeranians": b = s.pomeranians <= -1 || s.pomeranians < p.v
        case "akitas": b = s.akitas <= -1 || s.akitas == p.v
        case "vizslas": b = s.vizslas <= -1 || s.vizslas == p.v
        case "goldfish": b = s.goldfish <= -1 || s.goldfish < p.v
        case "trees": b = s.trees <= -1 || s.trees > p.v
        case "cars": b = s.cars <= -1 || s.cars == p.v
        case "perfumes": b = s.perfumes <= -1 || s.perfumes == p.v
        }
        return b
    }

    for pair in target_sue {
        for aunt in aunts {
            if compare_field(pair, aunt) {
                append(&auxiliar, aunt)
            } 
        }
        clear(&aunts)
        aunts, auxiliar = auxiliar, aunts
    }

    if len(aunts) == 1 {
       return aunts[0].id 
    }

    return -1
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)


    input := #load("day16.txt", string)

    {// part 1
        p1 := part_1(input) 
        fmt.println("part 1 =>", p1)
    }

    {// part 2
        p2 := part_2(input) 
        fmt.println("part 2 =>", p2)
    }
}
