pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--ball
ball_x=60
ball_dx=0.5 --delta
ball_y=10
ball_dy=1.5
ball_r=3    --radius
ball_c=9				--color

--rectangle x43 w40
rec_x=43
rec_y=53
rec_w=40
rec_h=20
rec_c=6
rec_nhc=11		--no hit color
rec_hc=8				--hit color



function _init()
	cls()
end



function _update60()

	--make ball move
	ball_x+=ball_dx
	ball_y+=ball_dy
	
	--ball horizontal boundaries
	if ball_x>120
	or ball_x<5 then
		ball_dx=-ball_dx
	end
	
	--ball vertical boundaries
	if ball_y>120
	or ball_y<5 then
		ball_dy=-ball_dy
	end
	
	rec_c=rec_nhc
	
	
	--check if ball hit rectangle
	if ball_col(
	rec_x,rec_y,rec_w,rec_h) then
		rec_c=rec_hc
	end
	
end

function _draw()
	cls(1)
	
	--draw ball
	circfill(
	ball_x,ball_y,ball_r,ball_c)
	
	--draw rectangle
	rectfill(
	rec_x,rec_y,rec_x+rec_w,
	rec_y+rec_h,rec_c)
end

--check collision of the ball
--with the rectangle
--by elimination
function ball_col(
box_x,box_y,box_w,box_h)

	--is ball bellow box?
	if ball_y-ball_r>
	box_y+box_h then
		return false --yes, no col
	end
	
	--is ball above box?
	if ball_y+ball_r<box_y then
		return false --yes, no col
	end
	
	--is ball at the ⬅️ of box?
	if ball_x-ball_r>
	box_x+box_w then
		return false --yes, no col
	end
	
	--is ball at the ➡️ of box?
	if ball_x+ball_r<box_x then
		return false --yes, no col
	end
	
	--if nothing else, ball is
	--colliding with rectangle
	return true
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
