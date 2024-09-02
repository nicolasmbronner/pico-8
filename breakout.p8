pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--[[ next #14 angle control


goals

1.sticky paddle
2.angle control
3.combos

4.levels
   -generate level patterns
   -stage clearing
   
5.different bricks
6.powups

7.juiciness
   -arrow anim (serve preview)
   -text blinking
   -particles
   -screenshakes
   
8.high score


◆theme:steampunk ]]



--iron earthbreaker
--by retropixie

--###########################--
--#     global functions    #--
--###########################--


--global init function

function _init()
	
	--ball_x,ball_y,
	--ball_dx,ball_dy=
	--serveball()
	
	ball_r,ball_c=2,9
	
	
	--paddle
	pad_x,pad_y,pad_dx,pad_w,
	pad_h,pad_s,pad_d,pad_c=
	52,118,0,25,3,2,1.3,6
	
	
	--brick
	brick_x,brick_y,brick_v,
	brick_w,brick_h=
	{},{},{},9,4
	
	
	--gameplay
	mode,lives_start,
	lives,score,collided,god_mode=
	"start",3,3,0,false,false
	
	--sticky=serveball()
	
	--functions
	buildbricks()
end --_init()



--global update function

function _update60()
	
	if mode=="game" then
		update_game()
		
	elseif mode=="start" then
		update_start()
		
	elseif mode=="gameover" then
		update_gameover()
	end
end --_update60()



--global draw function

function _draw()
	if mode=="game" then
		draw_game()
		
	elseif mode=="start" then
		draw_start()
		
	elseif mode=="gameover" then
		draw_gameover()
	end
end --_draw



--###########################--
--#      state functions    #--
--###########################--


--"start" state functions

function update_start()
	if btnp(❎) then
		startgame()
	end
end --update_start



function draw_start()
	local screen_w=128
	local screen_h=128
	
	cls(1)
	
	--centered game title
	print("iron earthbreaker",31,50,7)
	
	--centered instructions
	print("press ❎ to start",31,70,11)
end --draw_start()



--"game" state functions

function update_game()
	local buttpress=false
	local nextx,nexty
	
	--predict next ball pos
	nextx=ball_x+ball_dx
	nexty=ball_y+ball_dy
	
	--move paddle left with btn
	if btn(⬅️) and not god_mode then
		pad_dx=-pad_s
		buttpress=true
		if sticky then
			ball_dx=-1
		end
	end
	
	--move paddle right with btn
	if btn(➡️) and not god_mode then 
		pad_dx=pad_s
		buttpress=true
		if sticky then
			ball_dx=1
		end
	end
	
	if sticky and btnp(❎) then
		sticky=false
	end
	
	--paddle deceleration
	if not(buttpress) then
		pad_dx/=pad_d
	end
	
	--update pad position if ⬅️/➡️
	pad_x+=pad_dx
	
	--god mode
	if btnp(⬆️) then
		god_mode=not god_mode
	end
	
	if god_mode then
		pad_x=nextx-(pad_w/2)
	end
	
	--prevent pad go ooscreen
	pad_x=mid(0,pad_x,127-pad_w)

	--sticky ball
	if sticky then
		ball_x=pad_x+flr(pad_w/2)
		ball_y=pad_y-ball_r

	--regular ball physics
	else
		--ball horizontal boundaries
		if nextx>125 or nextx<2 then
			nextx=mid(0,nextx,127) --oos
			ball_dx=-ball_dx --rev.hor
			sfx(0)
		end
		
		--ball vertical boundaries
		if nexty<9 then
		nexty=mid(0,nexty,127) --oos
			ball_dy=-ball_dy --rev.vert
			sfx(0)
		end
		
		--ball lost ⬇️
		if nexty>125 then
			sfx(2)
			lives-=1
			if lives<0 then
				gameover()
			else
				serveball()
			end
		end
		
		--ball/pad collision test
		if ball_col(nextx,nexty,pad_x,pad_y,pad_w,pad_h) then
			
			--deal with deflection
			if ball_defl(ball_x,ball_y,ball_dx,ball_dy,pad_x,pad_y,pad_w,pad_h) then
				
				--ball_defl=true,hor defl
				ball_dx=-ball_dx
				ball_dy=-ball_dy
				ball_y=pad_y-ball_r --safe teleport
			else
				
				--ball_defl=false,vert defl
				ball_dy=-ball_dy
				ball_y=pad_y-ball_r --safe teleport
			end
			
			sfx(1)
			score+=1
		end --if ball-pad.col
		
		
		--ball/brick collision test
		
		collided = false
		
		for i=1,#brick_x do
			
			if brick_v[i]
				and not collided
				and ball_col(nextx,nexty,brick_x[i],brick_y[i],brick_w,brick_h) then
				
				local is_hor=ball_defl(ball_x,ball_y,ball_dx,ball_dy,brick_x[i],brick_y[i],brick_w,brick_h)
				local adj_brick=false
				local adj_direction=""
					
				--determine col direction
				if is_hor then
					
					if ball_dx>0 then
						adj_direction="left"
						
					else adj_direction="right" end
					
				else
					if ball_dy>0 then 
						adj_direction="up"
						
					else 
						adj_direction = "down"
					end
				end
					
				--check adj brick
				adj_brick=check_adj_brick(i,adj_direction)     
				
				--apply modif defl
				if adj_brick then
					if is_hor then
							
						--adjust y ball pos
						--ball goes ⬆️
						if ball_dy<0 then
							ball_y=brick_y[i]+brick_h+ball_r
						else  --ball goes ⬇️
							ball_y=brick_y[i]-ball_r
						end
						
						--change to vert defl
						ball_dy=-ball_dy
					else
						
						--adjust x ball pos
						--ball goes to ➡️
						if ball_dx>0 then
							ball_x=brick_x[i]-ball_r
							
						else --ball goes to ⬅️ 
							ball_x=brick_x[i]+brick_w+ball_r
						end
						
						--change to horiz defl
						ball_dx=-ball_dx
					end
				else
					
					--normal defl
					if is_hor then
						ball_dx=-ball_dx
						
					else
						ball_dy=-ball_dy
					end
				end
				
				sfx(3)
				brick_v[i] = false
				collided = true
				score += 10
			end
		end
	end
	
	
	
	--update game position
	ball_x+=ball_dx
	ball_y+=ball_dy
end --update_game()



function draw_game()
	local i
	cls(1)
	
	--ball draw
	circfill(ball_x,ball_y,ball_r,ball_c)
	if sticky then
		
		--serve preview
		line(ball_x+ball_dx*4,ball_y+ball_dy*4,ball_x+ball_dx*7,ball_y+ball_dy*7,13)
	end
	
	--paddle draw     
	rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)
	
	--bricks draw
	for i=1,#brick_x do
		if brick_v[i] then
			rectfill(brick_x[i],brick_y[i],brick_x[i]+brick_w,brick_y[i]+brick_h,14)
		end
	end
	
	--lives
	rectfill(0,0,128,6,0)
	print("lives: "..lives,1,1,7)
	
	--score
	print("score: "..score,40,1,7)
	
	--debug
	print("god(⬆️):"..tostr(god_mode),1,8,13)
end --draw_game()



--"game over" state functions
--merge with "start" state if
--it does same thing at end

function update_gameover()
	
	if btnp(❎) then
		startgame()
	end
end --update_gameover



function draw_gameover()
	
	local screen_w=128
	local screen_h=128
	
	rectfill(0,60,128,74,0)
	
	print("game over",47,62,7)
	
	print("press ❎ to restart",27,68,6)
end --draw_gameover()



--###########################--
--#   utilitary functions   #--
--###########################--


--start game

function startgame()
	mode="game"
	lives=lives_start
	score=0
	serveball()
end --startgame()



--serve the ball

function serveball()
	ball_x=pad_x+flr(pad_w/2)
	ball_y=pad_y-ball_r
	ball_dx=1
	ball_dy=-1
	sticky=true
end



--build the bricks

function buildbricks()
	local i
	for i=1,66 do
		
		add(brick_x,4+((i-1)%11)*(brick_w+2))
		
		add(brick_y,20+flr((i-1)/11)*(brick_h+2))
		
		add(brick_v,true)
	end
end



--ball collision

--nx=nextx, ny=nexty, t=target
function ball_col(nx,ny,tx,ty,tw,th)

	--is ball bellow box?
	if ny-ball_r>ty+th then return false end --yes, no col
	
	--is ball above box?
	if ny+ball_r<ty then return false end --yes, no col
	
	--is ball at the ⬅️ of box?
	if nx-ball_r>tx+tw then return false end --yes, no col
	
	--is ball at the ➡️ of box?
	if nx+ball_r<tx then return false end --yes, no col
	
	--if nothing else, ball is
	--colliding with box
	return true
end --ball_col()



--ball deflection

function ball_defl(bx,by,bdx,bdy,tx,ty,tw,th)
	
	--ball slope
	local bslp=bdy/bdx
	--corner slope
	local csx, csy, cslp
	
	if bdx==0 then
		--ball 100% vertial dir
		--vertical deflection
		return false
		
	elseif bdy==0 then
		--ball 100% horizontal dir
		--horizontal deflection
		return true
		
	--case 1:ball moving ⬇️➡️
	elseif bslp>0 and bdx>0 then
		csy=ty-by
		csx=tx-bx
		cslp=csy/csx
		return csx>0 and cslp<=bslp
		
	--case 2:ball moving ⬆️➡️
	elseif bslp<0 and bdx>0 then
		csy=ty+th-by
		csx=tx-bx
		cslp=csy/csx
		return csx>0 and cslp>=bslp
		
	--case 3:ball moving ⬆️⬅️
	elseif bslp>0 and bdx<0 then
		csy=ty+th-by
		csx=tx+tw-bx
		cslp=csy/csx
		return csx<0 and cslp<=bslp
		
	--case 4: ball moving ⬇️⬅️
	else
		csy=ty-by
		csx=tx+tw-bx
		cslp=csy/csx
		return csx<0 and cslp>=bslp
	end
end --ball_defl()



--check adjacent brick

function check_adj_brick(i,direction)
	
	--setup adj brick part 1
	local adj_x,adj_y=brick_x[i],brick_y[i]
	
	--setup adj brick part 2
	if direction=="up" then
		adj_y-=brick_h+2
		
	elseif direction=="down"then
		adj_y+=brick_h+2
		
	elseif direction=="left" then
		adj_x-=brick_w+2
		
	elseif direction=="right"then
		adj_x+=brick_w+2
	end
	
	--compare with all bricks 
	for j=1, #brick_x do
		if brick_v[j] and
		brick_x[j]==adj_x and
		brick_y[j]==adj_y then
			return true
		end
	end
	
	return false
end


--game over

function gameover()
	mode="gameover"
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
