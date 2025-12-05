package main

import "../utils"

import "base:runtime"

import "core:fmt"
import "core:mem"
import "core:strings"


// I could've used the "core:container/avl" but sometime you just want to implement a BST
Node :: struct {
    start: int,
    end: int,
    left: ^Node,
    right: ^Node,
}

Tree :: struct {
    node_allocator: runtime.Allocator,
    root: ^Node,
}

init_tree :: proc(t: ^Tree, allocator := context.allocator) {
    t.root = nil
    t.node_allocator = allocator
}

destroy_node_rec :: proc(root: ^Node, allocator: runtime.Allocator) {
    if root != nil {
        destroy_node_rec(root.left, allocator)
        destroy_node_rec(root.right, allocator)
        free(root, allocator)
    }
}

destroy_tree :: proc(t: ^Tree) {
    destroy_node_rec(t.root, t.node_allocator) 
    t.root = nil
}

// can be done better, but it is ok for AoC and one hour of time
insert_rec :: proc(root: ^Node, start, end: int, allocator: runtime.Allocator) -> ^Node {
    if root == nil {
        new_node := new(Node, allocator)
        new_node^ = {
            start = start,
            end = end,
        }
        return  new_node
    }

    if root.start <= start && root.end >= end {
        return root
    }

    if start < root.start && end > root.end {
        root.left = insert_rec(root.left, start, root.start - 1, allocator)
        root.right = insert_rec(root.right, root.end + 1, end, allocator)
        return root
    }

    // go right
    if start > root.end {
        root.right = insert_rec(root.right, start, end, allocator) 
    } else if end < root.start {
        // go left
        root.left = insert_rec(root.left, start, end, allocator) 
    } else if start < root.start && end <= root.end {
        end := root.start - 1
        
        root.left = insert_rec(root.left, start, end, allocator) 
    } else if end > root.end && start >= root.start {
        start := root.end + 1
        
        root.right = insert_rec(root.right, start, end, allocator) 
    } else {
        panic("unreachable")
    }

    return root
}

insert :: proc(t: ^Tree, start, end: int) {
    assert(start <= end) 
    t.root = insert_rec(t.root, start, end, t.node_allocator)
}

print_tree_rec :: proc(r: ^Node) {
    if r != nil {
        print_tree_rec(r.left)
        fmt.printfln("[%10d - %10d]", r.start, r.end)
        print_tree_rec(r.right)
    }
}

print_tree :: proc(t: ^Tree) {
    print_tree_rec(t.root) 
}

parse_input :: proc(raw: string, allocator := context.allocator) -> (Tree, []int) {
    intervals: Tree
    to_check := make([dynamic]int, allocator)    

    init_tree(&intervals, allocator)

    when ODIN_OS == .Windows {
        separator := "\r\n\r\n" 
    } else {
        separator := "\n\n" 
    }

    parts := utils.read_lines(raw, separator)

    assert(len(parts) == 2)
    defer delete(parts)

    { // ranges
        sep := "-"
        lines := utils.read_lines(parts[0]) 
        defer delete(lines)
        for line in lines {
            index := strings.index(line, sep)
            start, end := line[:index], line[index + 1:]
            insert(&intervals, utils.parse_number(start), utils.parse_number(end))
        }
    }

    { // targets
        lines := utils.read_lines(parts[1]) 
        defer delete(lines)

        for line in lines {
            append(&to_check, utils.parse_number(line))
        }
    }

    return intervals, to_check[:]
}

is_in_range_rec :: proc(target: int, root: ^Node) -> bool {
    if root == nil { return false }
    else if target < root.start { return is_in_range_rec(target, root.left) }
    else if target > root.end { return is_in_range_rec(target, root.right) }
    else { return true }
}

is_in_range :: proc(target: int, t: ^Tree) -> bool {
    return is_in_range_rec(target, t.root) 
}

part_1 :: proc(t: ^Tree, targets: []int) -> (n: int) {
    for target in targets {
        if is_in_range(target, t) { n += 1 }
    } 
    return
}

count_ranges_rec :: proc(root: ^Node, acc: ^int) {
    if root != nil {
        count_ranges_rec(root.left, acc)
        count_ranges_rec(root.right, acc)
        acc^ = acc^ + root.end - root.start + 1
    }
}

part_2 :: proc(t: ^Tree) -> int {
    n := 0
    count_ranges_rec(t.root, &n)

    return n
}

main :: proc() { 
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    raw_input := #load("day5.txt", string)
    intervals, target := parse_input(raw_input)

    defer {
        destroy_tree(&intervals)
        delete(target)
    }

    /* print_tree(&intervals) */
    { // part 1
        p1 := part_1(&intervals, target)
        fmt.println("part 1 =>", p1)
    }
    { // part 2
        p2 := part_2(&intervals)
        fmt.println("part 2 =>", p2)
    }
}
