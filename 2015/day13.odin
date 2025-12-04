package main

import "../utils"

import "core:fmt"
import "core:mem"
import "core:slice"
import "core:strings"

Knight :: enum {
    Alice,
    Bob,
    Carol,
    David,
    Eric,
    Frank,
    George,
    Mallory,
    Ntonio, // Hey it's me!
}

name_to_knights :: proc(name: string) -> (k: Knight) {
    switch name[0] {
    case 'A': k = .Alice
    case 'B': k = .Bob
    case 'C': k = .Carol
    case 'D': k = .David
    case 'E': k = .Eric
    case 'F': k = .Frank
    case 'G': k = .George
    case 'M': k = .Mallory
    case:
        fmt.println("Who the fuck is this?", name)
        panic("unknown knight")
    }
    return 
}

parse_data :: proc(data: string) -> (knights: [Knight][Knight]int) {
    context.allocator = context.temp_allocator
    defer free_all(context.temp_allocator)

    lines := strings.split_lines(data)
    for line in lines[:len(lines) - 1] {
        line_without_dot_end, _ := strings.substring_to(line, len(line) - 1)
        parts := strings.fields(line_without_dot_end)
        from := name_to_knights(parts[0])
        num := utils.parse_number(parts[3])
        if parts[2] == "lose" { num *= -1 }
        to := name_to_knights(parts[len(parts) - 1])

        knights[from][to] += num
        knights[to][from] += num
    }

    return
}

// Basically a TSP, but fixing the first person I limit the tries from n! to (n-1)!
max_happiness :: proc(happiness_costs: [Knight][Knight]int, other_knights: []Knight) -> int {
    other_knights := other_knights

    iterator, _ := slice.make_permutation_iterator(other_knights)
    defer slice.destroy_permutation_iterator(iterator)

    last_index := len(other_knights) - 1
    max_happiness := 0

    for slice.permute(&iterator) {
        from := Knight.Alice
        accum := happiness_costs[.Alice][other_knights[last_index]]
        for k in other_knights {
            accum += happiness_costs[from][k]
            from = k
        }
        max_happiness = accum > max_happiness ? accum : max_happiness
    }

    return max_happiness
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    data := #load("day13.txt", string)
    knights := parse_data(data)
    p1 := max_happiness(knights, []Knight{.Bob, .Carol, .David, .Eric, .Frank, .George, .Mallory })
    fmt.println("part 1 =>", p1)
    p2 := max_happiness(knights, []Knight{.Bob, .Carol, .David, .Eric, .Frank, .George, .Mallory, .Ntonio })
    fmt.println("part 2 =>", p2)
}
