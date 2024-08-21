pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--next: video 16, brick patterns


--debug (after end of course)
-- ◆multi-brick+ball collision
--   ★not through both bricks
--   ◆never u-turn ball
--   ◆never break 2 bricks
-- idea:modify corner slope?


--goals
-- 4.levels
--    generate level patterns
--    stage clearing
-- 5.different bricks
-- 6.powups
-- 7.juiciness
--    arrow anim
--    text blinking
--    particles
--    screenshakes
-- 8.high score

-- 9.theme:steampunk
-- 10.test artifacts with btn
-- 11.character mini-management


function _init()
	cls()
	mode="start"
end


function _update60()
	if mode=="game" then
		update_game()
	elseif mode=="start" then
		update_start()
	elseif mode=="gameover" then
		update_gameover()
	end
end


function update_start()
	if btn(❎) then
		startgame()
	end
end


function startgame()
	mode="game"

	--ball
	ball_r=2 --radius

	--paddle
	pad_x=52
	pad_y=118
	pad_dx=0 --delta x
	pad_w=24 --width
	pad_h=3 --height
	pad_s=2 --speed
	pad_d=1.3 --deceleration
	pad_c=7 --color

	--bricks
	brick_w=9
	brick_h=4
	brick_c=8
	
	--debug
	debug1="nil"
	godmode=false
	

	buildbricks()

	lives=3
	points=0
	
	sticky=true --sticky ball
	chain=1 --combo chain mult
	
	serveball()
end


function buildbricks()
	brick_x={}
	brick_y={}
	brick_v={} --visible

	for i=1,66 do
		add(brick_x,
			4+((i-1)%11)*(brick_w+2))
		add(brick_y,20+flr((i-1)/11)
			*(brick_h+2))
		add(brick_v,true)
	end
end


function serveball()
	ball_x=pad_x+flr(pad_w/2)
	ball_y=pad_y-ball_r
	ball_dx=1
	ball_dy=-1
	ball_ang=1
	sticky=true
end


function setang(ang)
	ball_ang=ang
	if ang==2 then
		ball_dx=0.5*sign(ball_dx)
		ball_dy=1.3*sign(ball_dy)
	elseif ang==0 then
		ball_dx=1.3*sign(ball_dx)
		ball_dy=0.5*sign(ball_dy)
	else
		ball_dx=1*sign(ball_dx)
		ball_dy=1*sign(ball_dy)
	end
end


function sign(n)
 if n<0 then
 	return -1
 elseif n>0 then
 	return 1
 else
 	return 0
 end
end


function gameover()
	mode="gameover"
end


function update_gameover()
	if btnp(5) then
		startgame()
	end
end


function update_game()

	--control the paddle--

	local buttpress=false
	local nextx,nexty,brickhit
	
	--god mode
	if btnp(⬆️) and not (godmode) 
	then
		godmode=true
	elseif btnp(⬆️) and (godmode)
	then
		godmode=false
	end
	
	if (godmode) then
		pad_x=ball_x-(pad_w/2)
	end
	
	-- moving pad
	if btn(⬅️) then
		pad_dx=-pad_s
		buttpress=true
		
		if sticky then
			ball_dx=-1
		end
	end

	if btn(➡️) then
		pad_dx=pad_s
		buttpress=true
		
		if sticky then
			ball_dx=1
		end
	end

	--pad deceleration
	if not(buttpress) then
		pad_dx=pad_dx/pad_d
	end

	pad_x+=pad_dx --move if ⬅️/➡️

	--prevent pad to go ooscreen
	pad_x=mid(0,pad_x,127-pad_w)
	
	if sticky and btnp(❎) then
		sticky=false
	end
	
	if sticky then
		ball_x=pad_x+flr(pad_w/2)
		ball_y=pad_y-ball_r-1
	else
		--predict next ball pos
		nextx=ball_x+ball_dx
		nexty=ball_y+ball_dy


		--ball bounce screen borders--

		if nextx>125 or nextx<2 then
			nextx=mid(0,nextx,127) --oos
			--reverse horizontally
			ball_dx=-ball_dx
			sfx(0)
		end

		if nexty<9 then
			nexty=mid(0,nexty,127) --oos
			--reverse vertically
			ball_dy=-ball_dy
			sfx(0)
		end

		--lose a life
		if nexty > 128 then
			sfx(2)
			chain=1
			lives-=1
			if lives<0 then
				gameover()
			else
				serveball()
			end
		end


 	--ball/pad collision--
 
	 if ball_box(
	 nextx,nexty,pad_x,pad_y,
	 pad_w,pad_h) then
 
	 	--deal with deflection
	 	if ball_defl(
	 	ball_x,ball_y,ball_dx,
	 	ball_dy,pad_x,pad_y,
	 	pad_w,pad_h) then
 		
	 		--padle's side deflect
	 		ball_dx=-ball_dx
	 		ball_dy=-ball_dy
	 		
	 		--safe teleport
	 		ball_y=pad_y-ball_r
	 	else
 		
	 		--padle's top deflect
	 		ball_dy=-ball_dy
	 		
	 		--safe teleport
	 		ball_y=pad_y-ball_r

	 		--change angle
	 		if abs(pad_dx)>1.5 then
	 			if sign(pad_dx)==
	 			sign(ball_dx) then
	 				
	 				--flatten angle
	 				setang(mid(
	 				0,ball_ang-1,2))
	 			else
	 				
	 				--raise angle
	 				--reverse?
	 				if ball_ang==2 then
	 					ball_dx=-ball_dx
	 				else
	 					setang(mid(
	 					0,ball_ang+1,2))
	 				end
	 			end
	 		end
 		
	 	end
	 	sfx(1)
	 	chain=1
	 end


		--ball/brick collision--
		
		brickhit=false
	
		--for each brick
		for i=1,#brick_x do
	
		 --check if ball hit brick
			if brick_v[i] and ball_box(
			nextx,nexty,brick_x[i],
			brick_y[i],brick_w,brick_h)
			then
		
				if not(brickhit) then

					--deal with ball deflection
					if ball_defl(
					ball_x,ball_y,ball_dx,
					ball_dy,brick_x[i],
					brick_y[i],brick_w,brick_h)
			 	then
		
						--horizontal deflection
						ball_dx=-ball_dx
					else
		
						--vertical deflection
						ball_dy=-ball_dy
					end
				end
			
				brickhit=true
				brick_v[i]=false
				sfx(2+chain)
				points+=10*chain
				chain+=1
				chain=mid(1,chain,7)
				break
			end

		end


	--make the ball move--
 ball_x+=ball_dx
 ball_y+=ball_dy
 end
end


----------------draw


function _draw()
	if mode=="game" then
		draw_game()
	elseif mode=="start" then
		draw_start()
	elseif mode=="gameover" then
		draw_gameover()
	end
end


function draw_start()
	cls()
	print("breakout story",
		37,40,7)
	print("press ❎ to start",
		32,80,11)
end


function draw_gameover()
	rectfill(0,60,128,75,0)
	print("game over",45,62,7)
	print("press ❎ to restart",
		25,69,6)
end


function draw_game()
	cls(1)

	--draw the ball
	circfill(
	ball_x,ball_y,ball_r,9)
	
	if sticky then
		-- serve preview
		line(ball_x+ball_dx*4,
		ball_y+ball_dy*4,
		ball_x+ball_dx*7,
		ball_y+ball_dy*7,4)
	end

	--draw the paddle
	rectfill(
	pad_x,pad_y,pad_x+pad_w,
	pad_y+pad_h,pad_c)

	--draw bricks
 for i=1,#brick_x do
	 if brick_v[i] then
			rectfill(
			brick_x[i],brick_y[i],
			brick_x[i]+brick_w,
			brick_y[i]+brick_h,
			brick_c)
		end
		
	print("god(⬆️):"..tostr(godmode)
	,2,10,5)
	end

	--draw the upper ui	
	rectfill(0,0,128,6,0)
	print("lives:"..lives,1,1,7)
	print("score:"..points,40,1,7)
	print("chain:".." X"..chain,
	90,1,7)
end


----------------functions


--ball + obj collision--

function ball_box(
	bx,by,box_x,box_y,box_w,box_h)

	--if ball north>box south
	if by-ball_r>box_y+box_h then
		return false
	end

	--if ball south<box north
	if by+ball_r<box_y then
		return false
	end

	--if ball west>box est
	if bx-ball_r>box_x+box_w then
		return false
	end

	--if ball est<box west
	if bx+ball_r<box_x then
		return false
	end

	--else,there is collision
	return true
end


--ball deflection--

function ball_defl(
bx,by,bdx,bdy,tx,ty,tw,th)

	local slp=bdy/bdx
	local cx,cy --target corners
	
	if bdx==0 then
		--ball 100% vert
		return false
	elseif bdy==0 then
		--ball 100% horiz
		return true
	
	--case 1:ball moving ⬇️➡️
	elseif slp>0 and bdx>0 then
		cx=tx-bx
		cy=ty-by
		return cx>0 and cy/cx<slp
		
	--case 2:ball moving ⬆️➡️
	elseif slp<0 and bdx>0 then
		cx=tx-bx
		cy=ty+th-by
		return cx>0 and cy/cx>=slp
	
	--case 3:ball moving ⬆️⬅️
	elseif slp>0 and bdx<0 then
		cx=tx+tw-bx
		cy=ty+th-by
		return cx<0 and cy/cx<=slp
	
	--case 4:ball moving ⬇️⬅️
	else
		cx=tx+tw-bx
		cy=ty-by
		return cx<0 and cy/cx>=slp
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
000100001a570155500f5300a51000500005000050000500005000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001b7501875015750127500f7500d7500a75008750057500275000750007000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001d7102e7302e720357102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001e7102f7302f720367102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001f7103073030720377102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000207103173031720387102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000217103273032720397102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002271033730337203a7102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002371034730347203b7102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
