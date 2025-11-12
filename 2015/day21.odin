#+feature dynamic-literals
package main

import "core:fmt"
import "core:slice"

Character :: struct {
    hp: int,
    damage: int,
    armor: int, 
    cost_equip: int,
}

parse_number :: proc(bs: []byte) -> (n: int) {
    for b in bs {
        n = n * 10 + int(b - '0')
    }
    return
}

advance_until :: proc(bs: []byte, offset: ^int, pred: proc(b: byte) -> bool) {
    for pred(bs[offset^]) {
       offset^ += 1 
    } 
}

Item :: [3]int // Cost, Damage, Armor

Shop :: struct {
    weapons: []Item,
    armors: []Item,
    rings: []Item,
}

shop := Shop{
    weapons = []Item{
        {8 , 4, 0}, 
        {10, 5, 0}, 
        {25, 6, 0}, 
        {40, 7, 0}, 
        {74, 8, 0}, 
    },
    armors = []Item{
        {13  , 0, 1}, 
        {31  , 0, 2}, 
        {53  , 0, 3}, 
        {75  , 0, 4}, 
        {102 , 0, 5}, 
    },
    rings = []Item{
        {25 , 1, 0}, 
        {50 , 2, 0}, 
        {100, 3, 0}, 
        {20 , 0, 1}, 
        {40 , 0, 2}, 
        {80 , 0, 3}, 
    },
}

parse_character :: proc(input: []byte) -> (c: Character) {
    is_num :: proc(b: byte) -> bool {
        return b >= '0' && b <= '9'
    }

    is_not_num :: proc(b: byte) -> bool {
        return !is_num(b)
    }

    i := 0
    advance_until(input, &i, is_not_num)
    offset := i
    advance_until(input, &offset, is_num)
    c.hp = parse_number(input[i:offset])

    i = offset
    advance_until(input, &i, is_not_num)
    offset = i
    advance_until(input, &offset, is_num)
    c.damage = parse_number(input[i:offset])

    i = offset
    advance_until(input, &i, is_not_num)
    offset = i
    advance_until(input, &offset, is_num)
    c.armor = parse_number(input[i:offset])
    
    return
}

// pretty ugly to see/read but it's straight forward and also works
create_configs :: proc() -> [dynamic]Character {
    configs := make([dynamic]Character) 

    for weapon in shop.weapons {
        with_weapon := Character{ hp = 100, cost_equip = weapon[0] }
        with_weapon.damage = weapon[1]

        append(&configs, with_weapon)

        {
            for ring_1, i in shop.rings {
                with_one_ring := with_weapon
                with_one_ring.cost_equip += ring_1[0]
                if ring_1[1] > 0 {
                   with_one_ring.damage += ring_1[1] 
                } else {
                   with_one_ring.armor += ring_1[2] 
                }

                append(&configs, with_one_ring)

                for ring_2, j in shop.rings {
                    if i == j { continue }
                    with_two_ring := with_one_ring
                    with_two_ring.cost_equip += ring_2[0]
                    if ring_2[1] > 0 {
                        with_two_ring.damage += ring_2[1] 
                    } else {
                        with_two_ring.armor += ring_2[2] 
                    }

                    append(&configs, with_two_ring)
                }
            }
        }


        for armor in shop.armors {
            with_armor := with_weapon
            with_armor.cost_equip += armor[0]
            with_armor.armor = armor[2]

            append(&configs, with_armor)

            for ring_1, i in shop.rings {
                with_one_ring := with_armor
                with_one_ring.cost_equip += ring_1[0]
                if ring_1[1] > 0 {
                   with_one_ring.damage += ring_1[1] 
                } else {
                   with_one_ring.armor += ring_1[2] 
                }

                append(&configs, with_one_ring)

                for ring_2, j in shop.rings {
                    if i == j { continue }
                    with_two_ring := with_one_ring
                    with_two_ring.cost_equip += ring_2[0]
                    if ring_2[1] > 0 {
                        with_two_ring.damage += ring_2[1] 
                    } else {
                        with_two_ring.armor += ring_2[2] 
                    }

                    append(&configs, with_two_ring)
                }
            }
        }
    }

    return configs
}

can_player_win :: proc(player, boss: Character) -> bool {
    player_dmg := clamp(player.damage - boss.armor, 1, player.damage)
    boss_dmg := clamp(boss.damage - player.armor, 1, player.damage)

    player_attacks_required := boss.hp / player_dmg + (boss.hp % player_dmg > 0 ? 1 : 0)
    boss_attacks_required := player.hp / boss_dmg + (player.hp % boss_dmg > 0 ? 1 : 0)

    return player_attacks_required <= boss_attacks_required
}

// players goes first
part_1 :: proc(configs: []Character, boss: Character) -> int {
    winning_configs := make([dynamic]Character)
    defer delete(winning_configs)

    by_cost :: proc(c1, c2: Character) -> bool {
        return c1.cost_equip < c2.cost_equip
    }

    for config in configs {
        if can_player_win(config, boss) {
            append(&winning_configs, config)
        }
    }

    slice.sort_by(winning_configs[:], by_cost)
    return winning_configs[0].cost_equip
}

// players goes first
part_2 :: proc(configs: []Character, boss: Character) -> int {
    winning_configs := make([dynamic]Character)
    defer delete(winning_configs)

    by_cost_reverse :: proc(c1, c2: Character) -> bool {
        return c1.cost_equip > c2.cost_equip
    }

    for config in configs {
        if !can_player_win(config, boss) {
            append(&winning_configs, config)
        }
    }

    slice.sort_by(winning_configs[:], by_cost_reverse)
    return winning_configs[0].cost_equip
}

main :: proc() {
    input := #load("day21.txt") 

    boss := parse_character(input)

    configs := create_configs()
    defer delete(configs)

    { // part 1
        p1 := part_1(configs[:], boss) 
        fmt.println("part 1 =>", p1)
    }

    { // part 2
        p2 := part_2(configs[:], boss) 
        fmt.println("part 2 =>", p2)
    }

}
