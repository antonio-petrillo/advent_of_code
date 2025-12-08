package main

import "../utils"

import "base:runtime"

import pq "core:container/priority_queue"
import "core:fmt"
import "core:mem"
import "core:strings"
import "core:slice"
import "core:strconv"

Point :: #type [3]int

Union_Find :: struct($T: typeid) {
    val: T,
    parent: ^Union_Find(T),
    size: int,
}

new_union_find :: proc(value: $T, allocator: runtime.Allocator) -> ^Union_Find(T) {
    new_node, err := new(Union_Find(T), allocator = allocator)
    assert(err == nil)

    new_node.val = value
    new_node.parent = new_node
    new_node.size = 1

    return new_node
}

find_representative :: proc(node: ^Union_Find($T)) -> ^Union_Find(T) {
    node := node
    for node.parent != node {
        node, node.parent = node.parent, node.parent.parent
    }
    return node
}

union_sets :: proc(s1, s2: ^Union_Find($T)) -> bool  {
    p1 := find_representative(s1)
    p2 := find_representative(s2)

    if p1 == p2 { return false } // already connected

    if p1.size < p2.size {
        p1, p2 = p2, p1
    }

    p2.parent = p1
    p1.size += p2.size
    return true
}

parse_input :: proc(raw: ^string) -> []Point {
    points := make([dynamic]Point)
    for line in strings.split_iterator(raw, utils.string_line_separator) {
        line := line
        p: Point
        i := 0
        for comp in strings.split_iterator(&line, ",") {
            n, ok := strconv.parse_int(comp)
            assert(ok && i < 3)
            p[i] = n
            i += 1
        }
        append(&points, p)
    } 
    return points[:]
}

squared_distance :: proc(p1, p2: Point) -> int {
    s := p2 - p1
    s *= s
    return s[0] + s[1] + s[2]
}

part_1 :: proc(points: []Point, $N: int) -> int {
    arena_mem := make([]byte, 1 * mem.Gigabyte, context.allocator)
    defer { delete(arena_mem) }
    arena: mem.Arena
    mem.arena_init(&arena, arena_mem)

    alloc := mem.arena_allocator(&arena)

    Pairs :: struct {
        p1: Point,
        p2: Point,
        dist: int,
    }

    sets := make(map[Point]^Union_Find(Point), allocator = alloc)
    distances := make([dynamic]Pairs, allocator = alloc)

    for p1, i in points {
        sets[p1] = new_union_find(p1, alloc)
        for p2 in points[i + 1:] {
            dist := squared_distance(p1, p2) 
            append(&distances, Pairs{p1, p2, dist})
        }
    }

    less :: proc(a, b: Pairs) -> bool {
        return a.dist < b.dist
    }

    min_heap: pq.Priority_Queue(Pairs)
    pq.init_from_dynamic_array(&min_heap, less = less,  queue = distances, swap = pq.default_swap_proc(Pairs))

    for i in 0..<N {
        min_dist := pq.pop(&min_heap)
        union_sets(sets[min_dist.p1], sets[min_dist.p2])
    }

    sizes := make([dynamic]int, allocator = alloc)
    seen := make(map[^Union_Find(Point)]struct{}, allocator = alloc)
    for repr, set in sets {
        r := find_representative(set)
        if r in seen { continue }
        append(&sizes, r.size)
        seen[r] = struct{}{}
    }

    reverse :: proc(a, b: int) -> bool { return b < a }

    slice.sort_by(sizes[:], reverse)

    res := 1
    for i in sizes[:3] {
        res *= i
    }

    return res
}

part_2 :: proc(points: []Point) -> int {
    arena_mem := make([]byte, 1 * mem.Gigabyte, context.allocator)
    defer { delete(arena_mem) }
    arena: mem.Arena
    mem.arena_init(&arena, arena_mem)

    alloc := mem.arena_allocator(&arena)

    Pairs :: struct {
        p1: Point,
        p2: Point,
        dist: int,
    }

    sets := make(map[Point]^Union_Find(Point), allocator = alloc)
    distances := make([dynamic]Pairs, allocator = alloc)

    for p1, i in points {
        sets[p1] = new_union_find(p1, alloc)
        for p2 in points[i + 1:] {
            dist := squared_distance(p1, p2) 
            append(&distances, Pairs{p1, p2, dist})
        }
    }


    less :: proc(a, b: Pairs) -> bool {
        return a.dist < b.dist
    }

    min_heap: pq.Priority_Queue(Pairs)
    pq.init_from_dynamic_array(&min_heap, less = less,  queue = distances, swap = pq.default_swap_proc(Pairs))

    islands := len(points) - 1
    for {
        min_dist := pq.pop(&min_heap)
        if union_sets(sets[min_dist.p1], sets[min_dist.p2]) {
           islands -= 1 
        }
        if islands == 0 {
            return min_dist.p1[0] * min_dist.p2[0]
        }
    }

    return -1
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    /* raw_input := #load("day8_example.txt", string) */
    /* rounds :: 10 */

    raw_input := #load("day8.txt", string)
    rounds :: 1000

    points := parse_input(&raw_input)
    defer { delete(points) }

    { // part 1
        p1 := part_1(points, rounds)
        fmt.println("part 1 =>", p1)
    }

    { // part 2
        p2 := part_2(points)
        fmt.println("part 2 =>", p2)
    }

}
