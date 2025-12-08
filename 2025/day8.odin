package main

import "../utils"

import "base:runtime"

import pq "core:container/priority_queue"
import "core:fmt"
import "core:mem"
import "core:os"
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

// don't compute the sqrt, it's not needed in this case
squared_distance :: proc(p1, p2: Point) -> int {
    s := p2 - p1
    s *= s
    return s[0] + s[1] + s[2]
}

solve :: proc(points: []Point, $N: int) -> (sol_1: int, sol_2: int) {
    /* arena_mem := make([]byte, 57 * mem.Gigabyte, context.allocator) // enough memory */
    arena_mem := make([]byte, 57 * mem.Megabyte, context.allocator) // just enough memory
    /* arena_mem := make([]byte, 1 * mem.Kilobyte, context.allocator) // cause a append Out_Of_Mem */
    /* arena_mem := make([]byte, 1 * mem.Kilobyte >> 1, context.allocator) // cause a map_insert Out_Of_Mem */
    defer { delete(arena_mem) }
    // Q: why a custom arena? A: Since day8 required a lot of memory (for my standards) I wanted to test how the code behaved with insufficient memory
    // Q: Why an `Arena` and not a `Heap` allocator? A: I wanted to test what would happen varying the available memory, I didn't want to free a tons of pointers individually.
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
        new_set := new_union_find(p1, alloc)
        _, v, inserted, err_map := map_entry(&sets, p1)
        if err_map != nil {
            fmt.println("Err on map_insert =>", err_map)
            os.exit(1)
        }
        assert(inserted)
        v^ = new_set
        for p2 in points[i + 1:] {
            dist := squared_distance(p1, p2) 
            _, err_dyn_array := append(&distances, Pairs{p1, p2, dist})
            if err_dyn_array != nil {
                fmt.println("Err on append =>", err_dyn_array)
                os.exit(1)
            }
        }
    }

    less :: proc(a, b: Pairs) -> bool {
        return a.dist < b.dist
    }

    min_heap: pq.Priority_Queue(Pairs)
    pq.init_from_dynamic_array(&min_heap, less = less,  queue = distances, swap = pq.default_swap_proc(Pairs))

    islands := len(points) - 1
    { // solve part 1
        // merge the first `N` shortest distances into strongly connected components
        for i in 0..<N {
            min_dist := pq.pop(&min_heap)
            if union_sets(sets[min_dist.p1], sets[min_dist.p2]) {
                islands -= 1 
            }
        }
        

        sizes := make([dynamic]int, allocator = alloc)
        seen := make(map[^Union_Find(Point)]struct{}, allocator = alloc)
        for repr, set in sets {
            r := find_representative(set)
            if r in seen { continue }
            _, err := append(&sizes, r.size)
            if err != nil {
                fmt.println(err)
                panic("Err on append")
            }
            seen[r] = struct{}{}
        }

        {
            more :: proc(a, b: int) -> bool { return b < a }

            /* ===
             * Instead of sorting (a whole O(n log n)) I can build an heap and get 3 values out of it
             * So the whole time is O(n) + 3 * O(log n) => O(n)
             * ===
             * slice.sort_by(sizes[:], more)
             * sol_1 = 1
             * for i in sizes[:3] {
             *    sol_1 *= i
             * }
             * ===
             */

            max_heap: pq.Priority_Queue(int)
            pq.init_from_dynamic_array(&max_heap, less = more, queue = sizes, swap = pq.default_swap_proc(int)) // for once less is more

            sol_1 = 1
            for i in 0..<3 {
                sol_1 *= pq.pop(&max_heap)
            }
        }
    }

    { // solve part 2
        // merge the shortest distances until there is on estrongly connected component
        for {
            min_dist := pq.pop(&min_heap)
            if union_sets(sets[min_dist.p1], sets[min_dist.p2]) {
                islands -= 1 
            }
            if islands == 0 {
                sol_2 = min_dist.p1[0] * min_dist.p2[0]
                break
            }
        }
    }

    return 
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

    p1, p2 := solve(points, rounds)
    fmt.println("part 1 =>", p1)
    fmt.println("part 2 =>", p2)

}
