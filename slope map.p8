pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
    cls(0)
end

function _draw()
    cls(0)
    
    -- draw the outer square
    rect(0,0,127,127,13)
    
    -- draw the center point
    pset(64,64,7)
    
    -- draw the dotted lines
    local straight_length=50
    local diagonal_length=35

    -- straight lines
    draw_dotted_line(64,64,
    64-straight_length,
    64,13) -- west
    
    draw_dotted_line(64,64,
    64+straight_length,
    64,13) -- east
    
    draw_dotted_line(64,64,64,
    64-straight_length,
    13) -- north
    
    draw_dotted_line(64,64,64,
    64+straight_length,
    13) -- south

    -- diagonal lines
    draw_dotted_line(64,64,
    64-diagonal_length,
    64-diagonal_length,11) --nw
    
    draw_dotted_line(64,64,
    64+diagonal_length,
    64+diagonal_length,11) --se
    
    draw_dotted_line(64,64,
    64+diagonal_length,
    64-diagonal_length,8) --ne
    
    draw_dotted_line(64,64,
    64-diagonal_length,
    64+diagonal_length,8) --sw
    
    -- draw the numbers and text
    print("0",4,62,7) --west
    print("0",120,62,7) --east
    print("inf",60,4,7) --north
    print("inf",60,120,7) --s
    print("1",14,14,7) --nw
    print("1",110,110,7) --se
    print("-1",105,14,7) --ne
    print("-1",14,110,7) --sw
end

function draw_dotted_line(
x1,y1,x2,y2,col)

    local dx=x2-x1
    local dy=y2-y1
    local steps=max(abs(dx),
    abs(dy))
    local xinc=dx/steps
    local yinc=dy/steps
    
    for i=0,steps,2 do
        pset(x1+xinc*i,y1+
        yinc*i,col)
    end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000115700e560095400351000500005000050000500005000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
