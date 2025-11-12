package main 

import "core:fmt"
import "core:c/libc"
import "core:bytes"

Character :: struct {
    hp: int,
    damage: int,
    mana: int,
}

parse_number :: proc(bs: []byte) -> (n: int) {
    for b in bs {
        n = n * 10 + int(b - '0')
    }
    return
}

parse_boss :: proc(input: []byte) -> (c: Character) {
    lines := bytes.split(input, []byte{'\n'})
    defer delete(lines)
    l1 := len(lines[0])
    c.hp = parse_number(lines[0][l1-2:])
    l2 := len(lines[1])
    c.damage = parse_number(lines[1][l2-2:])
    return
}

Spell :: enum {
    Missile,
    Drain,
    Shield,
    Poison,
    Recharge,
}

spell_cost :: proc(s: Spell) -> (cost: int) {
    switch s {
    case .Missile: cost = 53
    case .Drain: cost = 73
    case .Shield: cost = 113
    case .Poison: cost = 173
    case .Recharge: cost = 229
    }
    return
}

Effects :: struct {
    poison: int,
    shield: int,
    recharge: int,
}

part_1 :: proc(boss, wizard: Character) -> int {
    boss, wizard := boss, wizard
    min_spent_to_win := 1e9 // sure it is big enough

    effects: Effects
    turn, mana_spent := 0, 0
    dfs(&wizard, &boss, &effects, turn, mana_spent, &min_spent_to_win)

    return min_spent_to_win
}

part_2 :: proc(boss, wizard: Character) -> int {
    boss, wizard := boss, wizard
    min_spent_to_win := 2e9 // sure it is big enough

    effects: Effects
    turn, mana_spent := 0, 0
    dfs(&wizard, &boss, &effects, turn, mana_spent, &min_spent_to_win, true)

    return min_spent_to_win
}

can_cast_effect :: proc(w: ^Character, s: Spell, e: ^Effects) -> bool {
    res := true
    #partial switch s {
        case .Poison: res = e.poison == 0
        case .Recharge: res = e.recharge == 0
        case .Shield: res = e.shield == 0
    }
    return res
}

Do_or_Undo :: enum { Do, Undo }

apply_spell :: proc(wizard, enemy: ^Character, spell: Spell, effects: ^Effects, action: Do_or_Undo) {
    sign := action == .Do ? 1 : -1

    switch spell {
    case .Missile:
        enemy.hp -= 4 * sign
    case .Drain:
        enemy.hp -= 2 * sign
        wizard.hp += 2 * sign
    case .Poison:
        effects.poison = 6 if action == .Do  else 0
    case .Shield:
        effects.shield = 6 if action == .Do  else 0
    case .Recharge:
        effects.recharge = 5 if action == .Do else 0
    }
}

dfs :: proc(wizard, enemy: ^Character, effects: ^Effects, turn, mana_spent: int, min_spent_to_win: ^int, hard: bool = false) {

    if hard && turn & 1 == 0 {
        wizard.hp -= 1
        if wizard.hp <= 0 {
            wizard.hp += 1
            return
        }
    }
    defer if hard && turn & 1 == 0 { wizard.hp += 1 }
    

    shield := 0
    active_poison, active_shield, active_recharge := effects.poison > 0, effects.shield > 0, effects.recharge > 0
    if active_poison {
        enemy.hp -= 3
        effects.poison -= 1
    }
    if active_shield {
        shield = 7
        effects.shield -= 1
    }
    if active_recharge {
        wizard.mana += 101
        effects.recharge -= 1
    }

    defer if active_poison {
        enemy.hp += 3
        effects.poison += 1
    }
    defer if active_shield {
        effects.shield += 1
    }
    defer if active_recharge {
        wizard.mana -= 101
        effects.recharge += 1
    }

    if enemy.hp <= 0 {
        if mana_spent < min_spent_to_win^ { min_spent_to_win^ = mana_spent }
        return
    } 

    if turn & 1 == 0 { // player turn
        mana_spent := mana_spent
        for spell in Spell {
            cost := spell_cost(spell)

            if mana_spent + cost > min_spent_to_win^ || cost > wizard.mana { continue }

            if !can_cast_effect(wizard, spell, effects) { continue }

            {
                mana_spent += cost
                wizard.mana -= cost
                assert(wizard.mana >= 0)

                apply_spell(wizard, enemy, spell, effects, .Do)

                if enemy.hp <= 0 {
                    if mana_spent < min_spent_to_win^ { min_spent_to_win^ = mana_spent }
                } else {
                    dfs(wizard, enemy, effects, turn + 1, mana_spent, min_spent_to_win, hard)
                }

                mana_spent -= cost
                wizard.mana += cost
                apply_spell(wizard, enemy, spell, effects, .Undo)
            }
        }

    } else { // enemy turn
        dmg := max(enemy.damage - shield, 1)
        wizard.hp -= dmg

        if wizard.hp > 0 {
            dfs(wizard, enemy, effects, turn + 1, mana_spent, min_spent_to_win, hard)
        }
        
        wizard.hp += dmg
    }
} 

main :: proc() {
    input := #load("day22.txt")
    boss := parse_boss(input)
    wizard := Character{ hp = 50, mana = 500 }

    {// part 1
        p1 := part_1(boss, wizard)
        fmt.println("part 1 =>", p1)
    }

    {// part 2
        p2 := part_2(boss, wizard)
        fmt.println("part 2 =>", p2)
    }
}
