pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- next: video 12 (debugging)

--theme: steampunk

--plot: dig to the surface, 
--love story

--features
---ressources collection
----charcoal (carburant)
----iron (upgrades)
----artifacts (modules)

---character,mini-management
----ressources gathering
----charge steam bottle
----control desk
----activate machine

---upgrade
----regenerate ball
-----consume ressources,
-----if too much balls
-----lost,not enough
-----ressources to finish game 

---artifacts
----pad dupli-ball
----magnetic pad
----ghost ball
----shotgun ball
----area box
----dupli-ball


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
	if btn(4) then
		startgame()
	end
end


function startgame()
	mode="game"

	--ball
	ball_x=30
	ball_dx=1 --delta x
	ball_y=85
	ball_dy=1 --delta y
	ball_r=2 --radius
	colliding=false
	col_cd=0 --collision cooldown

	--paddle
	pad_x=52
	pad_dx=0 --delta x
	pad_y=118
	pad_w=24 --width
	pad_h=3 --height
	pad_s=2 --speed
	pad_d=1.3 --decrease
	pad_c=7 --color

	--bricks
	brick_x={}
	brick_y={}
	brick_v={} --visible
	brick_w=9
	brick_h=4
	brick_c=8

	buildbricks()

	lives=3
	points=0
	serveball()
end


function buildbricks()
	local i

	for i=1,66 do
		add(brick_x,
			4+((i-1)%11)*(brick_w+2))
		add(brick_y,20+flr((i-1)/11)
			*(brick_h+2))
		add(brick_v,true)
	end
end


function serveball()
	ball_x=30
	ball_dx=1
	ball_y=85
	ball_dy=1
end


function gameover()
	mode="gameover"
end


function update_gameover()
	if btn(4) then
		startgame()
	end
end


function update_game()

	--control the paddle--

	local buttpress=false
	local nextx,nexty--,brickhit

	if btn(0) then --⬅️
		pad_dx=-pad_s
		buttpress=true
	end

	if btn(1) then --➡️
		pad_dx=pad_s
		buttpress=true
	end

	--pad deceleration
	if not(buttpress) then
		pad_dx=pad_dx/pad_d
	end

	pad_x+=pad_dx --move if ⬅️/➡️

	--prevent pad to go ooscreen
	pad_x=mid(0,pad_x,127-pad_w)

	--predict next ball pos
	nextx=ball_x+ball_dx
	nexty=ball_y+ball_dy


	--ball bounce screen borders--

	if nextx>125 or nextx<2 then
		nextx=mid(0,nextx,127) --oos
		--reverse horizontally
		ball_dx=-ball_dx
		sfx(00)
	end

	if nexty<9 then
		nexty=mid(0,nexty,127) --oos
		--reverse vertically
		ball_dy=-ball_dy
		sfx(00)
	end

	if nexty > 128 then
		sfx(3)
		lives-=1
		if lives<0 then
			gameover()
		else
			serveball()
		end
	end


	--ball / pad collision--

	--collision cooldown
	if col_cd>0 then
		col_cd-=1
	end


	--if no collision
	if not ball_col(
	nextx,nexty,pad_x,pad_y,
	pad_w,pad_h) then

		colliding = false


	--if collision & cooldown is
	--zero & colliding is false
	elseif ball_col(
	nextx,nexty,pad_x,pad_y,
	pad_w,pad_h) and 
	col_cd==0 and
	colliding==false then
		colliding = true
		col_cd=10

		--deal with deflection
		if col_defl(
		ball_x,ball_y,ball_dx,
		ball_dy,pad_x,pad_y,
		pad_w,pad_h) then

			--horizontally
			ball_dx=-ball_dx
		else

			--vertically
			ball_dy=-ball_dy
		end

		sfx(1)
		points+=1


	--if collision & cooldown is
	--still counting
	elseif ball_col(
	nextx,nexty,pad_x,pad_y,
	pad_w,pad_h) and 
	col_cd>0 then

		colliding = true
	end


	--brick / ball collision--

	--for each brick
	for i=1,#brick_x do

	 --check if ball hit brick
		if brick_v[i] and ball_col(
		nextx,nexty,brick_x[i],
		brick_y[i],brick_w,brick_h)
		then

			--deal with deflection
			if col_defl(
			ball_x,ball_y,ball_dx,
			ball_dy,brick_x[i],
			brick_y[i],brick_w,brick_h)
		 then

				--horizontally
				ball_dx=-ball_dx
			else

				--vertically
				ball_dy=-ball_dy
			end

			brick_v[i]=false
			sfx(2)
			points+=10
		end
	end
	
	
	--make the ball move--
	
	--ball_x=nextx
 --ball_y=nexty
 ball_x+=ball_dx
 ball_y+=ball_dy
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
	local i
	cls(1)

	--draw the ball
	circfill(
	ball_x,ball_y,ball_r,9)

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
	end

	--draw the upper ui	
	rectfill(0,0,128,6,0)
	print("lives:"..lives,1,1,7)
	print("score:"..points,40,1,7)
end


----------------functions


--ball + obj collision--

function ball_col(
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


function col_defl(
bx,by,bdx,bdy,tx,ty,tw,th)

	--slope:positive(1)=⬆️⬅️/⬇️➡️
	--negative(-1)=⬆️➡️/⬇️⬅️

	--⬇️⬅️=0,⬅️⬆️=1,⬆️=inf,
	--⬆️➡️=-1,➡️=0,➡️⬇️=1
	--⬇️=inf,⬇️⬅️=-1
	
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
		--cy/cx=corner slope,a line
		--between ball center and
		--box closest corner
		
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
000200001f710317303172031710317102a7002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001b7501875015750127500f7500d7500a75008750057500275000750007000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
