pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- variables globales
brick_groups = {}
debug_mode = false
debug_group_colors = {8,9,10,11,12,13,14,15}

function _init()
    cls()
    mode = "start"
    level = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    debug_mode = false
end

function _update60()
    if mode == "game" then
        update_game()
    elseif mode == "start" then
        update_start()
    elseif mode == "gameover" then
        update_gameover()
    end
end

function update_start()
    if btn(❎) then
        startgame()
    end
end

function startgame()
    mode = "game"

    --ball
    ball_r = 2 --radius
    ball_x = 64
    ball_y = 63
    ball_dx = 1
    ball_dy = -1
    ball_ang = 1

    --paddle
    pad_x = 52
    pad_y = 118
    pad_dx = 0 --delta x
    pad_w = 24 --width
    pad_h = 3 --height
    pad_s = 2 --speed
    pad_d = 1.3 --deceleration
    pad_c = 7 --color

    --bricks
    brick_w = 9
    brick_h = 4
    brick_c = 8
    
    --debug
    debug1 = ""
    godmode = false

    buildbricks(level)

    lives = 3
    points = 0
    
    sticky = true --sticky ball
    chain = 1 --combo chain mult
    
    serveball()
end

function buildbricks(lvl)
    local char, last
    brick_x = {}
    brick_y = {}
    brick_v = {} --visible
    local j = 0

    for i = 1, #lvl do
        j += 1
        char = sub(lvl, i, i)
        
        if char == "b" then
            last = "b"
            add(brick_x, 4 + ((j-1) % 11) * (brick_w + 2))
            add(brick_y, 20 + flr((j-1) / 11) * (brick_h + 2))
            add(brick_v, true)
        elseif char == "x" then
            last = "x"
        elseif char == "/" then
            j = (flr((j-1) / 11) + 1) * 11
        elseif char >= "0" and char <= "9" then
            debug1 = char
            for o = 1, char + 0 do
                if last == "b" then
                    add(brick_x, 4 + ((j-1) % 11) * (brick_w + 2))
                    add(brick_y, 20 + flr((j-1) / 11) * (brick_h + 2))
                    add(brick_v, true)
                elseif last == "x" then
                    --nothing
                end
                j += 1
            end
            j -= 1
        end
    end
    
    identify_groups()
end

function identify_groups()
    brick_groups = {}
    local checked = {}
    
    for i = 1, #brick_x do
        if brick_v[i] and not checked[i] then
            local group = {i}
            checked[i] = true
            grow_group(group, i, checked)
            add(brick_groups, group)
        end
    end
end

function grow_group(group, index, checked)
    local dirs = {{0,-1},{0,1},{-1,0},{1,0}}
    for _, dir in ipairs(dirs) do
        local nx, ny = brick_x[index] + dir[1] * (brick_w + 2), brick_y[index] + dir[2] * (brick_h + 2)
        for j = 1, #brick_x do
            if brick_v[j] and not checked[j] and brick_x[j] == nx and brick_y[j] == ny then
                add(group, j)
                checked[j] = true
                grow_group(group, j, checked)
            end
        end
    end
end

function create_group_hitboxes(group)
    local hitboxes = {}
    for _, i in ipairs(group) do
        add(hitboxes, {x = brick_x[i], y = brick_y[i], w = brick_w, h = brick_h})
    end
    return hitboxes
end

function serveball()
    ball_x = pad_x + flr(pad_w / 2)
    ball_y = pad_y - ball_r
    ball_dx = 1
    ball_dy = -1
    ball_ang = 1
    sticky = true
end

function setang(ang)
    ball_ang = ang
    if ang == 2 then
        ball_dx = 0.5 * sign(ball_dx)
        ball_dy = 1.3 * sign(ball_dy)
    elseif ang == 0 then
        ball_dx = 1.3 * sign(ball_dx)
        ball_dy = 0.5 * sign(ball_dy)
    else
        ball_dx = 1 * sign(ball_dx)
        ball_dy = 1 * sign(ball_dy)
    end
end

function sign(n)
    if n < 0 then
        return -1
    elseif n > 0 then
        return 1
    else
        return 0
    end
end

function gameover()
    mode = "gameover"
end

function update_gameover()
    if btnp(5) then
        startgame()
    end
end

function update_game()
    --control the paddle--
    local buttpress = false
    local nextx, nexty
    
    --god mode
    if btnp(⬆️) and not (godmode) then
        godmode = true
    elseif btnp(⬆️) and (godmode) then
        godmode = false
    end
    
    if (godmode) then
        pad_x = ball_x - (pad_w / 2)
    end
    
    -- moving pad
    if btn(⬅️) then
        pad_dx = -pad_s
        buttpress = true
        
        if sticky then
            ball_dx = -1
        end
    end

    if btn(➡️) then
        pad_dx = pad_s
        buttpress = true
        
        if sticky then
            ball_dx = 1
        end
    end

    --pad deceleration
    if not(buttpress) then
        pad_dx = pad_dx / pad_d
    end

    pad_x += pad_dx --move if ⬅️/➡️

    --prevent pad to go offscreen
    pad_x = mid(0, pad_x, 127 - pad_w)
    
    if sticky and btnp(❎) then
        sticky = false
    end
    
    if btnp(🅾️) then
        debug_mode = not debug_mode
    end
    
    if sticky then
        ball_x = pad_x + flr(pad_w / 2)
        ball_y = pad_y - ball_r - 1
    else
        --predict next ball pos
        nextx = ball_x + ball_dx
        nexty = ball_y + ball_dy

        --ball bounce screen borders--
        if nextx > 125 or nextx < 2 then
            nextx = mid(0, nextx, 127) --oos
            --reverse horizontally
            ball_dx = -ball_dx
            sfx(0)
        end

        if nexty < 9 then
            nexty = mid(0, nexty, 127) --oos
            --reverse vertically
            ball_dy = -ball_dy
            sfx(0)
        end

        --lose a life
        if nexty > 128 then
            sfx(2)
            chain = 1
            lives -= 1
            if lives < 0 then
                gameover()
            else
                serveball()
            end
        end

        --ball/pad collision--
        if ball_box(nextx, nexty, pad_x, pad_y, pad_w, pad_h) then
            --deal with deflection
            if ball_defl(ball_x, ball_y, ball_dx, ball_dy, pad_x, pad_y, pad_w, pad_h) then
                --paddle's side deflect
                ball_dx = -ball_dx
                ball_dy = -ball_dy
                
                --safe teleport
                ball_y = pad_y - ball_r
            else
                --paddle's top deflect
                ball_dy = -ball_dy
                
                --safe teleport
                ball_y = pad_y - ball_r

                --change angle
                if abs(pad_dx) > 1.5 then
                    if sign(pad_dx) == sign(ball_dx) then
                        --flatten angle
                        setang(mid(0, ball_ang - 1, 2))
                    else
                        --raise angle
                        --reverse?
                        if ball_ang == 2 then
                            ball_dx = -ball_dx
                        else
                            setang(mid(0, ball_ang + 1, 2))
                        end
                    end
                end
            end
            sfx(1)
            chain = 1
        end

        --ball/brick group collision--
        local collision = check_ball_collision(nextx, nexty)
        if collision then
            handle_collision(collision)
        else
            ball_x = nextx
            ball_y = nexty
        end
    end
end

function check_ball_collision(nextx, nexty)
    -- vれたrifier les collisions avec toutes les briques
    for i = 1, #brick_x do
        if brick_v[i] and ball_box(nextx, nexty, brick_x[i], brick_y[i], brick_w, brick_h) then
            return {type = "brick", index = i}
        end
    end
    
    -- si aucune collision directe, vれたrifier avec les groupes
    for _, group in ipairs(brick_groups) do
        local group_collision = check_group_collision(nextx, nexty, group)
        if group_collision then
            return group_collision
        end
    end
    
    return nil
end

function check_group_collision(nextx, nexty, group)
    local hitboxes = create_group_hitboxes(group)
    for i, hitbox in ipairs(hitboxes) do
        if ball_box(nextx, nexty, hitbox.x, hitbox.y, hitbox.w, hitbox.h) then
            return {type = "group", group = group, brick_index = group[i]}
        end
    end
    return nil
end

function handle_collision(collision)
    if collision.type == "brick" then
        handle_brick_collision(collision.index)
    elseif collision.type == "group" then
        handle_brick_collision(collision.brick_index)
    end
end

function handle_brick_collision(i)
    -- calculer les distances aux bords de la brique
    local dx1 = abs(ball_x - brick_x[i])
    local dx2 = abs(ball_x - (brick_x[i] + brick_w))
    local dy1 = abs(ball_y - brick_y[i])
    local dy2 = abs(ball_y - (brick_y[i] + brick_h))
    local min_dist = min(dx1, dx2, dy1, dy2)

    -- rebond basれた sur le cれひtれた le plus proche
    if min_dist == dx1 or min_dist == dx2 then
        ball_dx = -ball_dx
    end
    if min_dist == dy1 or min_dist == dy2 then
        ball_dy = -ball_dy
    end

    -- ajuster la position de la balle pour れたviter qu'elle ne reste coincれたe
    ball_x = mid(ball_x + ball_dx, brick_x[i] - ball_r - 1, brick_x[i] + brick_w + ball_r + 1)
    ball_y = mid(ball_y + ball_dy, brick_y[i] - ball_r - 1, brick_y[i] + brick_h + ball_r + 1)

    destroy_brick(i)
end

function destroy_brick(i)
    brick_v[i] = false
    sfx(2 + chain)
    points += 10 * chain
    chain += 1
    chain = mid(1, chain, 7)
    identify_groups()  -- update groups after brick destruction
end

function dist(x1, y1, x2, y2)
    return sqrt((x2-x1)^2 + (y2-y1)^2)
end

function ball_box(bx, by, box_x, box_y, box_w, box_h)
    if by - ball_r > box_y + box_h then return false end
    if by + ball_r < box_y then return false end
    if bx - ball_r > box_x + box_w then return false end
    if bx + ball_r < box_x then return false end
    return true
end

function ball_defl(bx, by, bdx, bdy, tx, ty, tw, th)
    local slp = bdy / bdx
    local cx, cy --target corners
    
    if bdx == 0 then
        --ball 100% vert
        return false
    elseif bdy == 0 then
        --ball 100% horiz
        return true
    --case 1:ball moving ⬇️➡️
    elseif slp > 0 and bdx > 0 then
        cx = tx - bx
        cy = ty - by
        return cx > 0 and cy / cx < slp
    --case 2:ball moving ⬆️➡️
    elseif slp < 0 and bdx > 0 then
        cx = tx - bx
        cy = ty + th - by
        return cx > 0 and cy / cx >= slp
    --case 3:ball moving ⬆️⬅️
    elseif slp > 0 and bdx < 0 then
        cx = tx + tw - bx
        cy = ty + th - by
        return cx < 0 and cy / cx <= slp
    --case 4:ball moving ⬇️⬅️
    else
        cx = tx + tw - bx
        cy = ty - by
        return cx < 0 and cy / cx >= slp
    end
end

function _draw()
    if mode == "game" then
        draw_game()
    elseif mode == "start" then
        draw_start()
    elseif mode == "gameover" then
        draw_gameover()
    end
end

function draw_start()
    cls()
    print("breakout story", 37, 40, 7)
    print("press ❎ to start", 32, 80, 11)
end

function draw_gameover()
    rectfill(0, 60, 128, 75, 0)
    print("game over", 45, 62, 7)
    print("press ❎ to restart", 25, 69, 6)
end

function draw_game()
    cls(1)

    -- draw the ball
    circfill(ball_x, ball_y, ball_r, 9)
    
    if sticky then
        -- serve preview
        line(ball_x + ball_dx * 4, ball_y + ball_dy * 4,
             ball_x + ball_dx * 7, ball_y + ball_dy * 7, 4)
    end

    -- draw the paddle
    rectfill(pad_x, pad_y, pad_x + pad_w, pad_y + pad_h, pad_c)

    -- draw bricks
    for i = 1, #brick_x do
        if brick_v[i] then
            rectfill(brick_x[i], brick_y[i],
                     brick_x[i] + brick_w, brick_y[i] + brick_h, brick_c)
        end
    end
    
    print("god(⬆️):" .. tostr(godmode), 2, 10, 5)
    print(debug1, 120, 10, 5)

    -- draw the upper ui 
    rectfill(0, 0, 128, 6, 0)
    print("lives:" .. lives, 1, 1, 7)
    print("score:" .. points, 40, 1, 7)
    print("chain:" .. " X" .. chain, 90, 1, 7)

    if debug_mode then
        draw_debug()
    end
end

function draw_debug()
    -- dessiner les contours des groupes
    for i, group in ipairs(brick_groups) do
        local color = debug_group_colors[(i-1) % #debug_group_colors + 1]
        local hitboxes = create_group_hitboxes(group)
        for _, hitbox in ipairs(hitboxes) do
            rect(hitbox.x, hitbox.y, hitbox.x + hitbox.w, hitbox.y + hitbox.h, color)
        end
    end

    -- afficher des informations de dれたbogage
    print("groups: " .. #brick_groups, 2, 20, 7)
    print("ball: " .. flr(ball_x) .. "," .. flr(ball_y), 2, 28, 7)
    print("vel: " .. flr(ball_dx*10)/10 .. "," .. flr(ball_dy*10)/10, 2, 36, 7)
end

-- fin du code
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000115700e560095400351000500005000050000500005000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001a570155500f5300a51000500005000050000500005000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001b7501875015750127500f7500d7500a75008750057500275000750007000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001d7102e7302e720357102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001e7102f7302f720367102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001f7103073030720377102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000207103173031720387102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000217103273032720397102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002271033730337203a7102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002371034730347203b7102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
