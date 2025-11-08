package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:text/regex"

// Measured in teaspoon
/* Properties :: struct { */
/*     capacity: int, */
/*     durability: int, */
/*     flavor: int, */
/*     texture: int, */
/*     calories: int, */
/* } */
Properties :: [5]int

parse_number :: proc(str: string) -> (n: int) {
    sign := str[0] == '-' ? -1 : 1
    start := sign == 1 ? 0 : 1
    for ch in str[start:] {
        n = n * 10 + int(ch - '0') 
    }
    return n * sign
}

parse_properties :: proc(raw: string) -> ([4][4]int, [4]int) {
    raw := raw
    ingrediends: [4][4]int
    calories: [4]int

    iter, err_iter := regex.create_iterator(raw, "(-?\\d+)")
    if err_iter != nil {
        fmt.println(err_iter)
        os.exit(1)
    }
    defer regex.destroy_iterator(iter)

    i := 0
    for capacity_str in regex.match_iterator(&iter)  {
        prop: Properties
        ingrediends[i][0] = parse_number(capacity_str.groups[0])
        durability_str, _, _ := regex.match_iterator(&iter)
        ingrediends[i][1] = parse_number(durability_str.groups[0])
        flavor_str, _, _ := regex.match_iterator(&iter)
        ingrediends[i][2] = parse_number(flavor_str.groups[0])
        texture_str, _, _ := regex.match_iterator(&iter)
        ingrediends[i][3] = parse_number(texture_str.groups[0])
        calories_str, _, _ := regex.match_iterator(&iter)
        calories[i] = parse_number(calories_str.groups[0])
        i += 1
    }
    
    return ingrediends, calories
}


part_1 :: proc(ingredients: [4][4]int) -> int {
    max_score := 0

    l1: for i := 1; i <= 100; i += 1{
        l2: for j := 1; j <= 100; j += 1{
            if i + j > 100 { continue l1 }
            l3: for k := 1; k <= 100; k += 1{
                if i + j + k > 100 { continue l2 }
                for z := 1; z <= 100; z += 1{
                    if i + j + k + z > 100 { continue l3 }
                    if i + j + k + z == 100 {
                        config := i * ingredients[0] + j * ingredients[1] + k * ingredients[2] + z * ingredients[3]
                        score := 1
                        for param in config {
                            if param > 0 { score *= param }
                        }
                        if score > max_score { max_score = score}
                    }
                }
            }
        }
    }

    return max_score
}

part_2 :: proc(ingredients: [4][4]int, calories: [4]int) -> int {
    max_score := 0

    l1: for i := 1; i <= 100; i += 1{
        l2: for j := 1; j <= 100; j += 1{
            if i + j > 100 { continue l1 }
            l3: for k := 1; k <= 100; k += 1{
                if i + j + k > 100 { continue l2 }
                l4: for z := 1; z <= 100; z += 1{
                    if i + j + k + z > 100 { continue l3 }
                    if i * calories[0] + j * calories[1] + k * calories[2] + z * calories[3] != 500 { continue }
                    if i + j + k + z == 100 {
                        config := i * ingredients[0] + j * ingredients[1] + k * ingredients[2] + z * ingredients[3]
                        score := 1
                        for param in config {
                            if param > 0 { score *= param }
                        }
                        if score > max_score { max_score = score}
                    }
                }
            }
        }
    }

    return max_score
}

main :: proc() {
    raw_data := #load("day15.txt", string)

    ingrediends, calories := parse_properties(raw_data)


    v := [3]int{1, 2, 3}
    { // part 1
        p1 := part_1(ingrediends)
        fmt.println("part 1 =>", p1)
    }
    { // part 2
        p2 := part_2(ingrediends, calories)
        fmt.println("part 2 =>", p2)
    }
    
}
