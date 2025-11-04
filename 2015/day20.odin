package main

import "base:intrinsics"
import "core:fmt"
import "core:slice"

parse_data :: proc(raw: []byte) -> (id: int) {
    for b in raw[:len(raw) - 1] {
        id = id * 10 + int(b - '0')
    }
    return
}

sum_of_factors :: proc(n: int, limit: Maybe(int) = nil) -> int {
    sum := 0 
    count := 0
    for i in 1..=int(intrinsics.sqrt(f64(n))) {
        if n % i == 0 {
            if limit == nil {
                sum += i
            } else if n / i <= limit.? {
                sum += i
            }

            big_div := n / i
            if limit == nil {
                if i != big_div {
                    sum += big_div
                }
            } else if n / big_div <= limit.? {
                sum += big_div
            }
        }
    }
    return sum
}

solution :: proc(target, mul_factor: int, limit: Maybe(int) = nil) -> int {
    for i := 1; ; i += 1 {
        sum := sum_of_factors(i, limit) * mul_factor
        if sum >= target {
            return i
        }
    }

    return -1
}

main :: proc() {
    raw_data := #load("day20.txt")
    target := parse_data(raw_data)
    { // part 1
        p1 := solution(target, 10)
        fmt.println("part 1 =>", p1)
    }
    { // part 2
        p2 := solution(target, 11, 50)
        fmt.println("part 2 =>", p2)
    }
}
