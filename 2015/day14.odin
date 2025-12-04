package main

import "../utils"

import "core:fmt"
import "core:mem"
import "core:bytes"

Reindeer_State :: enum {
    Running,
    Resting,
}

Reindeer :: struct {
    speed: int,
    flying_time: int,
    rest_time: int,

    state: Reindeer_State,
    distance_travelled: int,
    remaining_time: int, 
    points: int,
}

// pretty dirty parsing
parse_data :: proc(raw: []byte) -> []Reindeer {
    reindeers := make([dynamic]Reindeer)
    lines := utils.bytes_read_lines(raw)
    defer delete(lines)
    for &line, j in lines[:len(lines) - 1] {
        r: Reindeer
        for ch, i in line {
            if ch >= '0' && ch <= '9' {
                line = line[i:]
                break
            }
        } 
        for ch, i in line {
            if ch >= '0' && ch <= '9' {
                r.speed = r.speed * 10 + int(ch - '0')
            } else {
                line = line[i:]
                break
            }
        }
        for ch, i in line {
            if ch >= '0' && ch <= '9' {
                line = line[i:]
                break
            }
        } 
        for ch, i in line {
            if ch >= '0' && ch <= '9' {
                r.flying_time = r.flying_time * 10 + int(ch - '0')
            } else {
                line = line[i:]
                break
            }
        }
        for ch, i in line {
            if ch >= '0' && ch <= '9' {
                line = line[i:]
                break
            }
        } 
        for ch, i in line {
            if ch >= '0' && ch <= '9' {
                r.rest_time = r.rest_time * 10 + int(ch - '0')
            } else {
                break
            }
        }
        r.remaining_time = r.flying_time
        append(&reindeers, r)
    }
    return reindeers[:]
}

simulate_second :: proc(reindeers: []Reindeer) -> int {
    max_dist := - 1
    for &r in reindeers {
        switch r.state {
        case .Running:
            r.remaining_time -= 1
            r.distance_travelled += r.speed
            if r.remaining_time <= 0 {
                r.state = .Resting
                r.remaining_time = r.rest_time
            }
        case .Resting:
            r.remaining_time -= 1
            if r.remaining_time <= 0 {
                r.state = .Running
                r.remaining_time = r.flying_time
            }
        }
        if r.distance_travelled > max_dist { max_dist = r.distance_travelled } 
    }
    return max_dist
}

part1 :: proc(reindeers: []Reindeer) -> int {
    for i in 0..<2503 {
        _ = simulate_second(reindeers)
    }
    max_dist := -1
    for r in reindeers {
        if r.distance_travelled > max_dist {
            max_dist = r.distance_travelled
        }
    }
    return max_dist
}

part2 :: proc(reindeers: []Reindeer) -> int {
    for i in 0..<2503 {
        max_dist := simulate_second(reindeers)
        for &r in reindeers {
            if r.distance_travelled == max_dist { r.points += 1 }
        }
    }
    max_points := -1
    for r in reindeers {
        if r.points > max_points {
            max_points = r.points
        }
    }
    return max_points
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    raw_data := #load("day14.txt")
    { // part 1
        reindeers := parse_data(raw_data)
        defer delete(reindeers)

        p1 := part1(reindeers)
        fmt.println("p1 =>", p1)
    }
    { // part 2
        reindeers := parse_data(raw_data)
        defer delete(reindeers)

        p2 := part2(reindeers)
        fmt.println("p2 =>", p2)
    }
}
