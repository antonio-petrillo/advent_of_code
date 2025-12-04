package main

import "../utils"

import "core:fmt"
import "core:mem"
import "core:strings"
import "core:text/regex"


Replacement :: struct {
    from: string,
    to: string,
}

parse_input :: proc(input: string) -> ([]Replacement, string) {
    replacements := make([dynamic]Replacement)
    parts := strings.split(input, ODIN_OS == .Windows ? "\r\n\r\n" : "\n\n")
    defer delete(parts)
    assert(len(parts) == 2)

    regex_litearl := ODIN_OS == .Windows ? "(\\w+) => (\\w+)\r\n" :  "(\\w+) => (\\w+)\n"

    iter, err := regex.create_iterator(parts[0], regex_litearl)
    assert(err == nil)
    defer regex.destroy_iterator(iter)

    for match in regex.match_iterator(&iter) {
        replacement := Replacement{
            from = match.groups[1],
            to = match.groups[2],
        }
        append(&replacements, replacement)
    }

    return replacements[:], strings.trim_space(parts[1])
}

part_1 :: proc(mappings: []Replacement, start: string) -> int {
    /* Don't manage each string separatedly, just allocate as much as needed and at the end delete everything at once.
     * The alternative is to malloc each string individually and then deallocate each one separatedly, this is big no for me.
     * It's also possible to use an RefCount strategy and count how many times each string is referenced but... each string live up until the end of the procedure
     * not only the linear/arena allocator is easier to manage, it's more performant and also incapsulate the 'lifetime' of multiple objects with ease.
    */
    context.allocator = context.temp_allocator
    defer free_all(context.temp_allocator)

    molecules := make(map[string]struct{})
    defer delete(molecules)
    placeholder := struct{}{}

    /* molecules[start] = placeholder */ // Fuck I've counted one more y_y

    for replacement in mappings {
        iter, err_iter := regex.create_iterator(start, replacement.from)
        assert(err_iter == nil)
        defer regex.destroy_iterator(iter)

        for match in regex.match_iterator(&iter) {
            s := strings.builder_make()
            assert(len(match.pos) == 1)
            pos := match.pos[0]

            strings.write_string(&s, start[0:pos[0]])
            strings.write_string(&s, replacement.to)
            strings.write_string(&s, start[pos[1]:])

            molecules[strings.to_string(s)] = placeholder
        }
    }

    return len(molecules)
}

is_upper :: proc(ch: byte) -> bool { return ch >= 'A' && ch <= 'Z' }

read_parts :: proc(molecule: string) -> []string {
    parts := make([dynamic]string)
    size := len(molecule)

    curr := 0
    for curr < size {
        ch := molecule[curr]
        if is_upper(ch) && curr < size - 1 && !is_upper(molecule[curr + 1]) {
            append(&parts, molecule[curr:curr+2])
            curr += 2
        } else  {
            append(&parts, molecule[curr:curr+1])
            curr += 1
        }
    }
    return parts[:]
}

// See https://www.reddit.com/r/adventofcode/comments/3xflz8/comment/cy4etju
/* RULES:
 * 1. e => XX | X => XX
 * 2. X => X Rn X Ar | X => X Rn X Y X Ar | X => X Rn X Y X Y X Ar
 * 
 * Too much for me, I would never have found such a beautiful solution y_y
 */
part_2 :: proc(target: string) -> int {
    parts := read_parts(target)

    defer delete(parts)

    num_rn_or_ar, num_y := 0, 0
    for part in parts {
        switch part {
        case "Ar", "Rn": num_rn_or_ar += 1
        case "Y": num_y += 1
        }
    }

    return len(parts) - num_rn_or_ar - 2 * num_y - 1
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    input := #load("day19.txt", string)

    mappings, start := parse_input(input)
    defer delete(mappings)
    { // part 1
        p1 := part_1(mappings, start)
        fmt.println("part 1 =>", p1)
    }
    { // part 2
        p2 := part_2(start)
        fmt.println("part 2 =>", p2)
    }
}
