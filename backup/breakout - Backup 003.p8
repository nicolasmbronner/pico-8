pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- next: video 9 (game states)
-- 6:35

-- features wishlist
			-- buttons for use pow-up (4)
			-- collect money
			-- upgrade screen
						-- cool & simple upgrades
			-- pow-ups
						-- speed-up pad
						-- magnetic pad
						-- ghost ball
						-- explosive ball
						-- shotgun ball
						-- area box
						-- duplicate ball



function _init()
	cls()
	
	-- variables --

	-- ball
	ball_x=30 -- x coordinates
	ball_dx=1 -- horiz.delta
	ball_y=60 -- y coordinates
	ball_dy=1 -- vertic.delta
	ball_r=2 -- radius
	colliding=false
	col_cd=0 -- collision cooldown

	-- paddle
	pad_x=52 -- x coordinates
	pad_dx=0 -- horiz.delta
	pad_y=118 -- y coordinates
	pad_w=24 -- width
	pad_h=3 -- height
	pad_s=2 -- speed
	pad_d=1.3 -- decrease
	pad_c=7
end



function _update60()

	-- control the paddle --
	
	local buttpress=false
	local nextx, nexty
	
	if btn(0) then -- ⬅️
		pad_dx=-pad_s
		buttpress=true
	end
	
	if btn(1) then -- ➡️
		pad_dx=pad_s
		buttpress=true
	end
	
	-- slow down after btn release
	if not(buttpress) then
		pad_dx=pad_dx/pad_d
	end
	
	pad_x+=pad_dx -- move if ⬅️/➡️
	
	-- predict next ball pos
	nextx=ball_x+ball_dx
	nexty=ball_y+ball_dy


	-- make the ball bounce
	-- against the borders of
	-- the screen --
	
	if nextx>125 or nextx<2 then
		-- ball never go ooscreen
		nextx=mid(0,nextx,127)
		
		-- reverse horizontally
		ball_dx=-ball_dx
		sfx(00)
	end

	if nexty>125 or nexty<2 then
		-- ball never go ooscreen
		nexty=mid(0,nexty,127)
		
		-- reverse vertically
		ball_dy=-ball_dy
		sfx(00)
	end
	
	-- check if ball hit pad --
	
		-- collision cooldown --
		-- collision with pad can only
		-- happend every 5 frames to
		-- prevent shenanigans of
		-- collisions
	if col_cd>0 then
		col_cd-=1
	end
	
	-- only if cooldown is zero
	if col_cd==0 then
	
		-- check for collision
		if ball_col(
			nextx,nexty,pad_x,pad_y,
			pad_w,pad_h
		) then
			
			-- deal with collision
			if colliding == false then
				colliding = true
				
				-- cooldown reset:10 frames
				col_cd=10
				
				-- find direction to deflect
				if col_defl(
					ball_x,ball_y,ball_dx,
					ball_dy,pad_x,pad_y,
					pad_w,pad_h
				) then
				
					-- deflect horizontally
					ball_dx=-ball_dx
				else
					-- deflect vertically
					ball_dy=-ball_dy
				end
				sfx(1)
			end
			
		else
			colliding=false
		end
	end	
		
	
	-- make the ball move --
	
	-- ball_x=nextx
 --	ball_y=nexty
 ball_x+=ball_dx
 ball_y+=ball_dy
end



function _draw()
	rectfill(0,0,127,127,1)
	
	-- draw the ball
	circfill(
		ball_x,ball_y,ball_r,9)
	
	-- draw the paddle
	rectfill(
		pad_x,pad_y,pad_x+pad_w,
		pad_y+pad_h,pad_c)
end



-- ball + rect obj collision --

function ball_col(
	bx,by,box_x,box_y,box_w,box_h)

	-- if ball north > box south
	if by-ball_r>box_y+box_h then
		return false
	end
	
	-- if ball south < box north
	if by+ball_r<box_y then
		return false
	end
	
	-- if ball west > box est
	if bx-ball_r>box_x+box_w then
		return false
	end
	
	-- if ball est < box west
	if bx+ball_r<box_x then
		return false
	end
	
	-- else, there is collision!
	return true
end



-- collision-deflection --
 
function col_defl(
	bx,by,bdx,bdy,tx,ty,tw,th)
	-- b=ball,bd=ballspeed,
	-- t=target=box

	-- calculate wether to deflect
	-- the ball horizontally or
	-- vertically when it hits
	-- a box
	
	-- ball moves 100% vertical
	if bdx==0 then
		return false -- vertical
		
	-- ball moves 100% horizontal
	elseif bdy==0 then
		return true -- horizontal
		
	-- ball moves diagonally
	else
		
		-- calculate ball slope,it's
		-- line of trajectory
		local slp=bdy/bdx
		-- positive(1)=⬆️⬅️/⬇️➡️
		-- negative(-1)=⬆️➡️/⬇️⬅️
		
		-- todo:pixel art version ⬇️
		-- ⬅️=0,⬅️⬆️=1,⬆️=inf,
		-- ⬆️➡️=-1,➡️=0,➡️⬇️=1
		-- ⬇️=inf,⬇️⬅️=-1
		
		local cx,cy -- corner of box
		
		
		-- check diagonal direction --
		
		
		-- case 1 - ball moving ⬇️➡️
		
		if slp>0 and bdx>0 then
			
			-- distance x between
			-- ⬅️ of box, and ball center
			cx=tx-bx -- distance_x
			
			-- distance y between
			-- ⬆️ of box, and ball center
			cy=ty-by -- distance_y
			
			-- cy/cx= corner slope,a line
			-- between ball center and
			-- box closest corner
			
			-- if ball_x is further
			-- than ⬅️ of box
			if cx<=0 then
				return false -- vertical
			
			-- if corner slope is
			-- above ball slope
			elseif cy/cx>slp then
				return false -- vertical
				
			-- if corner slope is
			-- bellow ball slope
			else
				return true -- horizontal
			end
			
			
		-- case 2 - ball moving ⬆️➡️
		
		elseif slp<0 and bdx>0 then
			
			cx=tx-bx -- distance x
			cy=ty+th-by -- distance y
			
			if cx<=0 then
				return false -- vertical
			elseif cy/cx<slp then
				return false -- vertical
			else
				return true -- horizontal
			end
			
			
		-- case 3 - ball moving ⬆️⬅️
		
		elseif slp>0 and bdx<0 then
	
			cx=tx+tw-bx
			cy=ty+th-by
			
			if cx>=0 then
				return false -- vertical
			elseif cy/cx>slp then
				return false -- vertical
			else
				return true -- horizontal
			end
			
			
		-- case 4 - ball moving ⬇️⬅️
		
		else
			
			cx=tx+tw-bx
			cy=ty-by
			
			if cx>=0 then
				return false -- vertical
			elseif cy/cx<slp then
				return false -- vertical
			else
				return true -- horizontal
			end
		end
	end
	return false
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000115400e530095200351000500005000050000500005000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001a540155300f5200a51000500005000050000500005000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
