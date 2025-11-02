package main

import "core:fmt"
import "core:crypto/legacy/md5"

secret := #load("day4.txt")

is_valid_part_1 :: proc(hashed: []byte) -> bool {
    return hashed[0] == 0 && hashed[1] == 0 && hashed[2] & 0xf0 == 0
}

is_valid_part_2 :: proc(hashed: []byte) -> bool {
    return hashed[0] == 0 && hashed[1] == 0 && hashed[2] == 0
}

mine_coins :: proc(secret: []byte, valid: proc([]byte) -> bool) -> int {
    ctx: md5.Context 
    dst: [md5.DIGEST_SIZE]byte
    buff: [4096]byte

    size := 0
    mod_size := 10

    secret_bytes := transmute([]byte)secret  

    for ch, i in secret_bytes {
       buff[i] = ch 
    }

    offset := len(secret_bytes)

    for i := 1; ; i += 1 {
        md5.init(&ctx)
        if i % mod_size == 0 {
            size += 1
            mod_size *= 10
        }
        n := i
        for j in 0..=size {
            buff[offset + size - j] = u8(n % 10 + '0')
            n /= 10
        }
        md5.update(&ctx, buff[:offset + size + 1])
        md5.final(&ctx, dst[:])

        if valid(dst[:]) do return i
    }
    return -1
}

main :: proc() {
    p1 := mine_coins(secret, is_valid_part_1) 
    fmt.printf("part 1 => %d\n", p1)
    
    p2 := mine_coins(secret, is_valid_part_2) 
    fmt.printf("part 2 => %d\n", p2)
}
