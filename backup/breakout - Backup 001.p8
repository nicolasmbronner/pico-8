pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- next: video 6 (collision)
-- features wishlist
			-- button to speed-up pad ?
			-- button for use pow-up (2?)
			-- collect money
			-- upgrade screen
						-- cool & simple upgrades


-- variables --

-- ball
ball_x=30 -- x coordinates
ball_dx=2 -- horiz.delta
ball_y=60 -- y coordinates
ball_dy=2.5 -- vertic.delta
ball_r=2 -- radius

-- paddle
pad_x=52 -- x coordinates
pad_dx=0 -- horiz.delta
pad_y=120 -- y coordinates
pad_w=24 -- width
pad_h=3 -- height
pad_s=4 -- speed
pad_sd=1.7 -- slow-down



function _init()
	cls()
end



function _update()

	-- control the paddle --
	
	buttpress=false
	
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
		pad_dx=pad_dx/pad_sd
	end
	
	pad_x+=pad_dx -- move if ⬅️/➡️

	-- make the ball move --
	
	ball_x=ball_x+ball_dx
	ball_y=ball_y+ball_dy

	-- make the ball bounce --
	
	if ball_x>124 or ball_x<3 then
		ball_dx=-ball_dx -- reverse
		sfx(00)
	end

	if ball_y>124 or ball_y<3 then
		ball_dy=-ball_dy -- reverse
		sfx(00)
	end
end



function _draw()
	rectfill(0,0,127,127,1)
	
	-- draw the ball
	circfill(ball_x,ball_y,ball_r,9)
	
	-- draw the paddle
	rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,7)
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
