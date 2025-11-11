package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:text/regex"



Replacement :: struct {
    from: string,
    to: string,
}

parse_input :: proc(input: string) -> ([]Replacement, string) {
    replacements := make([dynamic]Replacement)
    parts := strings.split(input, "\n\n")
    defer delete(parts)
    assert(len(parts) == 2)

    iter, err := regex.create_iterator(parts[0], "(\\w+) => (\\w+)\n")
    if err != nil {
        fmt.println(err)
        os.exit(1)
    }
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
        if err_iter != nil {
            fmt.println(err_iter)
            os.exit(1)
        }
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

main :: proc() {
    input := #load("day19.txt", string)

    mappings, start := parse_input(input)
    defer free_all(context.temp_allocator)
    { // part 1
        p1 := part_1(mappings, start)
        fmt.println("part 1 =>", p1)
    }
}
