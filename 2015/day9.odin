package main

import "core:fmt"
import "core:bytes"

City :: enum u8 {
    AlphaCentauri,
    Arbre,
    Faerun,
    Norrath,
    Snowdin,
    Straylight,
    Tambi,
    Tristam, 
}

Cost :: int
Graph :: [City][City]Cost

bytes_to_City :: proc(b: ^[]byte) -> (c: City) {
    switch b[0] {
    case 'A': c = b[1] == 'l' ? .AlphaCentauri : .Arbre
    case 'F': c = .Faerun
    case 'N': c = .Norrath
    case 'S': c = b[1] == 'n' ? .Snowdin : .Straylight
    case 'T': c = b[1] == 'a' ? .Tambi : .Tristam
    }
    return 
}

parse_data_into_graph :: proc(g: ^Graph, raw_data: []byte) {
    lines := bytes.split(raw_data, []byte{'\n'})
    for line in lines[:len(lines) - 1] {
        tokens := bytes.split(line, []byte{' '}) 
        acc := 0
        for b in tokens[4] {
            acc = acc * 10 + int(b - '0')
        }
        from := bytes_to_City(&tokens[0])
        to := bytes_to_City(&tokens[2])
        g[from][to] = acc 
        g[to][from] = acc 
    }
}

City_Visited :: bit_set[City]     

Compare_Cost_Fn :: proc(c1, c2: Cost) -> bool

dfs_rec :: proc(g: ^Graph, start: City, visited: ^City_Visited, current_cost: Cost, compare: Compare_Cost_Fn) -> Cost {
    visited^ += { start }
    defer visited^ -= { start }

    if len(City) == card(visited^) do return current_cost

    cost: Maybe(Cost)

    for connected_cost, connected in g[start] {
        if connected == start do continue
        if connected not_in visited^ {
            next_cost := dfs_rec(g, connected, visited, current_cost + connected_cost, compare)
            if cost == nil do cost = next_cost
            else if compare(next_cost, cost.?) do cost = next_cost
        }
    }

    return cost.?
}

dfs :: proc(g: ^Graph, compare: Compare_Cost_Fn) -> Cost {
    visited: City_Visited

    cost: Maybe(Cost)
    for city in City {
        visited += { city }

        next_cost := dfs_rec(g, city, &visited, 0, compare)

        if cost == nil do cost = next_cost
        else if compare(next_cost, cost.?) do cost = next_cost

        visited -= { city }
    }
    return cost.?
}

minimum :: proc(c1, c2: Cost) -> bool {
    return c1 < c2
}

part_1 :: proc(g: ^Graph) -> Cost  {
    return dfs(g, minimum)
}


maximum :: proc(c1, c2: Cost) -> bool {
    return c1 > c2
}

part_2 :: proc(g: ^Graph) -> Cost  {
    return dfs(g, maximum)
}

main :: proc() {
    raw_data := #load("day9.txt")
    g: Graph
    parse_data_into_graph(&g, raw_data)

    p1 := part_1(&g)
    fmt.println("part 1 => ", p1)

    p2 := part_2(&g)
    fmt.println("part 2 => ", p2)
}
