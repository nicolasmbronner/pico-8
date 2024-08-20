pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--next breakout #7 start!

--goals
-- 4.levels
--				generate level patterns
--				stage clearing
--	5.different bricks
--	6.powups
-- 7.juiciness
--				arrow anim
--				text blinking
--				particles
--				screenshakes
--	8.high score

--debug (end of course!)
-- ◆never u-turn ball
-- ◆never multi-break 1 frame
-- ◆not through both bricks

--art
-- ◆theme:steampunk



function _init()
	cls()
	
	--ball
	ball_x=60
	ball_dx=1 --delta
	ball_y=10
	ball_dy=1
	ball_r=2 			--radius
	ball_c=9 			--color
	
	--paddle
	pad_x=52
	pad_y=118
	pad_dx=0 			--delta
	pad_w=24 			--width
	pad_h=3 				--height
	pad_s=2 				--speed
	pad_d=1.3 		--deceleration
	pad_c=6 				--color
	pad_nor=6   --normal color
	pad_nohit=11--no hit color
	pad_hit=8			--colision color
	
	--screen
	screen_c=1
	
end --_init()



function _update60()
	local buttpress=false
	local nextx,nexty
	
	--!debug
	slope=ball_dy/ball_dx
	
	--move paddle left with btn
	if btn(⬅️) then
		pad_dx=-pad_s
		buttpress=true
	end
	
	--move paddle right with btn
	if btn(➡️) then 
		pad_dx=pad_s
		buttpress=true
	end
	
	--paddle deceleration
	if not(buttpress) then
		pad_dx/=pad_d
	end
	
	--update pad position if ⬅️/➡️
	pad_x+=pad_dx
	
	--prevent pad go ooscreen
	pad_x=mid(0,pad_x,127-pad_w)
	
	--predict next ball pos
	nextx=ball_x+ball_dx
	nexty=ball_y+ball_dy
	
	--ball horizontal boundaries
	if nextx>125	or nextx<2 then
		nextx=mid(0,nextx,127) --oos
		ball_dx=-ball_dx --rev.hor
		sfx(0)
	end
	
	--ball vertical boundaries
	if nexty>125	or nexty<2 then
	nexty=mid(0,nexty,127) --oos
		ball_dy=-ball_dy --rev.vert
		sfx(0)
	end
	
	--ball/pad collision test
	pad_c=pad_nor
	
	if ball_col(
	nextx,nexty,pad_x,pad_y,
	pad_w,pad_h) then
	
		--deal with deflection
		if ball_defl(
		ball_x,ball_y,ball_dx,
		ball_dy,pad_x,pad_y,
		pad_w,pad_h) then
		
			--ball_defl=true
			--horizontal deflection
			ball_dx=-ball_dx
			ball_dy=-ball_dy
			
			--safe teleport ball
			ball_y=pad_y-ball_r
		else
			
			--ball_defl=false
			--vertical deflection
			ball_dy=-ball_dy
			
			--safe teleport ball
			ball_y=pad_y-ball_r
			
		end
	end --if ball_col()
	
	--update ball position
	ball_x+=ball_dx
	ball_y+=ball_dy
end --_update60()



function _draw()
	cls(screen_c)
	
	--ball draw
	circfill(
	ball_x,ball_y,ball_r,ball_c)
	
	--paddle draw     
	rectfill(
	pad_x,pad_y,pad_x+pad_w,
	pad_y+pad_h,pad_c)
	
	--!debug
	print("slope:"..
	slope,0,0)

end --_draw



------ functions ------



--check collision of the ball
--with a rectangle (box)
--by elimination

--nx=nextx, ny=nexty, t=target
function ball_col(
nx,ny,tx,ty,tw,th)

	--is ball bellow box?
	if ny-ball_r>ty+th then
		return false --yes, no col
	end
	
	--is ball above box?
	if ny+ball_r<ty then
		return false --yes, no col
	end
	
	--is ball at the ⬅️ of box?
	if nx-ball_r>
	tx+tw then
		return false --yes, no col
	end
	
	--is ball at the ➡️ of box?
	if nx+ball_r<tx then
		return false --yes, no col
	end
	
	--if nothing else, ball is
	--colliding with box
	return true
end --ball_col()



--ball deflection

--slope (bdy/bdx) map
--	positive(1)=⬆️⬅️/⬇️➡️
--	negative(-1)=⬆️➡️/⬇️⬅️
-- null(0)=⬅️/➡️
-- infinite=⬆️/⬇️

function ball_defl(
nx,ny,bdx,bdy,tx,ty,tw,th)
	
	local slp=bdy/bdx --slope decl
	local cx,cy --target corners
	
	if bdx==0 then
		--ball 100% vertial dir
		--vertical deflection
		return false
		
	elseif bdy==0 then
		--ball 100% horizontal dir
		--horizontal deflection
		return true
		
	--case 1:ball moving ⬇️➡️
	elseif slp>0 and bdx>0 then
		--cornerx=targetx-nextx
		cx=tx-nx
		--cornery=targety-nexty
		cy=ty-ny
		return cx>0 and cy/cx<=slp
		--cy/cx=corner slope,a line
		--between ball center and
		--box closest corner
		
		--return true (horzntl) if
		--		cornerx>0 (ball is at the
		--  left of target corner)
		--  and if
		--  corner slope<ball slope
		--else false (vertical defl)
		
		--first condition:need ball
		--to be at the ⬅️ of corner
		--for horzntl defl
		
		--2nd condition:need corner
		--slope to be lower than
		--ball slope for horzntl defl
		
	--case 2:ball moving ⬆️➡️	
	elseif slp<0 and bdx>0 then
		cx=tx-nx
		cy=ty+th-ny
		return cx>0 and cy/cx>=slp
		
	--case 3:ball moving ⬆️⬅️
	elseif slp>0 and bdx<0 then
		cx=tx+tw-nx
		cy=ty+th-ny
		return cx<0 and cy/cx<=slp
		
	--case 4: ball moving ⬇️⬅️
	else
		cx=tx+tw-nx --1
		cy=ty-ny --2
		return cx<0 and cy/cx>=slp
	end
end --ball_defl()
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000115700e560095400351000500005000050000500005000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
