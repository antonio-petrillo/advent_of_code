package main

import "../utils"

import "core:fmt"
import "core:mem"
import "core:encoding/json"

part_1 :: proc(value: ^json.Value) -> (sum: f64) {
    #partial switch val in value^ {
        case i64: sum += f64(val) 
        case f64: sum += val
        case json.Array:
        for &value in val {
            sum += part_1(&value)
        }
        
        case json.Object:
        for _, &value in val {
            sum += part_1(&value)
        }
    }
    return
}

part_2 :: proc(value: ^json.Value) -> (sum: f64) {
    #partial switch val in value^ {
        case i64: sum += f64(val) 
        case f64: sum += val
        case json.Array:
        for &value in val {
            sum += part_2(&value)
        }
        
        case json.Object:
        if "red" in val {
            return
        }

        local_sum := 0.0
        for _, &value in val {
            if str, ok := value.(string); ok && str == "red" {
                return 0.0
            }

            local_sum += part_2(&value)
        }
        sum += local_sum
    }
    return
}

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer utils.track_report(&track)

    raw_data := #load("day12.txt")
    context.allocator = context.temp_allocator
    defer free_all(context.temp_allocator)

    value, err := json.parse(raw_data)
    if err != json.Error.None {
        fmt.eprintln("JSON parse error =>", err)
        return
    }

    p1 := part_1(&value)
    fmt.printfln("part 1 => %f", p1)

    p2 := part_2(&value)
    fmt.printfln("part 2 => %f", p2)
}
