pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--[[ next #16


goals

4.levels
  generate level patterns
  stage clearing
5.different bricks
6.powups
7.juiciness
  arrow anim (serve preview)
  text blinking
  particles
  screenshakes
8.high score
9.steampunk theme ]]



--iron earthbreaker
--by retropixie

--###########################--
--#     global functions    #--
--###########################--


--global init function

function _init()
	
	--bx,by,
	--bdx,bdy=
	--serveball()
	
	br,bc=2,9
	
	
	--paddle
	px,py,pdx,pw,
	ph,ps,pd,pc=
	52,118,0,24,3,2,1.3,6
	
	
	--brick
	brickx,bricky,brickv,
	brickw,brickh=
	{},{},{},9,4
	
	
	--gameplay
	mode,lives_start,
	lives,score,collided,
	god_mode=
	"start",3,3,0,false,false
	
	--sticky=serveball()
	--combo =serveball()
	
	--functions
	mode="start"
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
	nextx=bx+bdx
	nexty=by+bdy
	
	--move paddle left with btn
	if btn(⬅️) and not god_mode then
		pdx=-ps
		buttpress=true
		if sticky then
			bdx=-1
		end
	end
	
	--move paddle right with btn
	if btn(➡️) and not god_mode then 
		pdx=ps
		buttpress=true
		if sticky then
			bdx=1
		end
	end
	
	if sticky and btnp(❎) then
		sticky=false
	end
	
	--paddle deceleration
	if not(buttpress) then
		pdx/=pd
	end
	
	--update pad position if ⬅️/➡️
	px+=pdx
	
	--god mode
	if btnp(⬆️) then
		god_mode=not god_mode
	end
	
	if god_mode then
		px=nextx-(pw/2)
	end
	
	--prevent pad go ooscreen
	px=mid(0,px,127-pw)
	
	--sticky ball
	if sticky then
		bx=px+flr(pw/2)
		by=(py-br-1)
	
	--regular ball physics
	else
		--ball horizontal boundaries
		if nextx>125 or nextx<2 then
			nextx=mid(0,nextx,127) --oos
			bdx=-bdx --rev.hor
			sfx(0)
		end
		
		--ball vertical boundaries
		if nexty<9 then
		nexty=mid(0,nexty,127) --oos
			bdy=-bdy --rev.vert
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
		if ball_col(nextx,nexty,px,py,pw,ph) then
			
			--deal with deflection
			if ball_defl(bx,by,bdx,bdy,px,py,pw,ph) then
				
				--ball_defl=true,hor defl
				bdx=-bdx
				bdy=-bdy
				by=py-br-1 --safe teleport
			else
				
				--ball_defl=false,vert defl
				bdy=-bdy
				by=py-br-1 --safe teleport
				
				if abs(pdx)>1.8 then
					-- change angle
					if sign(pdx)==sign(bdx) then
						--flatten angle
						setang(mid(0,bang-1,2))
					else
						--raised angle
						if bang==2 then
							--reverse direction
							bdx=-bdx
						else
						setang(mid(0,bang+1,2))
						end
					end
				end
			end
			
			sfx(1)
			combo=1
		end --if ball-pad.col
		
		
		--ball/brick collision test
		
		collided = false
		
		for i=1,#brickx do
			
			if brickv[i]
				and not collided
				and ball_col(nextx,nexty,brickx[i],bricky[i],brickw,brickh) then
				
				local is_hor=ball_defl(bx,by,bdx,bdy,brickx[i],bricky[i],brickw,brickh)
				local adj_brick=false
				local adj_direction=""
					
				--determine col direction
				if is_hor then
					
					if bdx>0 then
						adj_direction="left"
						
					else adj_direction="right" end
					
				else
					if bdy>0 then 
						adj_direction="up"
						
					else 
						adj_direction="down"
					end
				end
					
				--check adj brick
				adj_brick=check_adj_brick(i,adj_direction)     
				
				--apply modif defl
				if adj_brick then
					if is_hor then
							
						--adjust y ball pos
						--ball goes ⬆️
						if bdy<0 then
							by=bricky[i]+brickh+br
						else  --ball goes ⬇️
							by=bricky[i]-br
						end
						
						--change to vert defl
						bdy=-bdy
					else
						
						--adjust x ball pos
						--ball goes to ➡️
						if bdx>0 then
							bx=brickx[i]-br
							
						else --ball goes to ⬅️ 
							bx=brickx[i]+brickw+br
						end
						
						--change to horiz defl
						bdx=-bdx
					end
				else
					
					--normal defl
					if is_hor then
						bdx=-bdx
						
					else
						bdy=-bdy
					end
				end
				
				sfx(2+combo)
				brickv[i]=false
				collided=true
				score+=10*combo
				combo+=1
				combo=mid(1,combo,7)
			end
		end
	end
	
	
	
	--update game position
	if not sticky then
		bx+=bdx
		by+=bdy
	end
end --update_game()



function draw_game()
	local i
	cls(1)
	
	--ball draw
	circfill(bx,by,br,bc)
	if sticky then
		
		--serve preview
		line(bx+bdx*4,by+bdy*4,bx+bdx*7,by+bdy*7,13)
	end
	
	--paddle draw     
	rectfill(px,py,px+pw,py+ph,pc)
	
	--bricks draw
	for i=1,#brickx do
		if brickv[i] then
			rectfill(brickx[i],bricky[i],brickx[i]+brickw,bricky[i]+brickh,14)
		end
	end
	
	--lives
	rectfill(0,0,128,6,0)
	print("lives: "..lives,1,1,7)
	
	--score
	print("score: "..score,40,1,7)
	
	--combo
	print("combo: "..combo.."x",90,1,7)
	
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
	buildbricks()
	serveball()
end --startgame()



--serve the ball

function serveball()
	bx=px+flr(pw/2)
	by=py-br-1
	bdx=1
	bdy=-1
	bang=1
	
	sticky=true
	combo=1
	
	--0.5
	--1
	--1.30
end



function setang(ang)
	bang=ang
	if ang==2 then
		bdx=0.50*sign(bdx)
		bdy=1.30*sign(bdy)
	elseif ang==0 then
		bdx=1.30*sign(bdx)
		bdy=0.50*sign(bdy)
		
	else
		bdx=1*sign(bdx)
		bdy=1*sign(bdy)
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



--build the bricks

function buildbricks()
	local i
	for i=1,66 do
		
		add(brickx,4+((i-1)%11)*(brickw+2))
		
		add(bricky,20+flr((i-1)/11)*(brickh+2))
		
		add(brickv,true)
	end
end



--ball collision

--nx=nextx, ny=nexty, t=target
function ball_col(nx,ny,tx,ty,tw,th)

	--is ball bellow box?
	if ny-br>ty+th then return false end --yes, no col
	
	--is ball above box?
	if ny+br<ty then return false end --yes, no col
	
	--is ball at the ⬅️ of box?
	if nx-br>tx+tw then return false end --yes, no col
	
	--is ball at the ➡️ of box?
	if nx+br<tx then return false end --yes, no col
	
	--if nothing else, ball is
	--colliding with box
	return true
end --ball_col()



--ball deflection

function ball_defl(ballx,bally,balldx,balldy,tx,ty,tw,th)
	
	--ball slope
	local bslp=balldy/balldx
	--corner slope
	local csx, csy, cslp
	
	if balldx==0 then
		--ball 100% vertial dir
		--vertical deflection
		return false
		
	elseif balldy==0 then
		--ball 100% horizontal dir
		--horizontal deflection
		return true
		
	--case 1:ball moving ⬇️➡️
	elseif bslp>0 and balldx>0 then
		csy=ty-bally
		csx=tx-ballx
		cslp=csy/csx
		return csx>0 and cslp<=bslp
		
	--case 2:ball moving ⬆️➡️
	elseif bslp<0 and balldx>0 then
		csy=ty+th-bally
		csx=tx-ballx
		cslp=csy/csx
		return csx>0 and cslp>=bslp
		
	--case 3:ball moving ⬆️⬅️
	elseif bslp>0 and balldx<0 then
		csy=ty+th-bally
		csx=tx+tw-ballx
		cslp=csy/csx
		return csx<0 and cslp<=bslp
		
	--case 4: ball moving ⬇️⬅️
	else
		csy=ty-bally
		csx=tx+tw-ballx
		cslp=csy/csx
		return csx<0 and cslp>=bslp
	end
end --ball_defl()



--check adjacent brick

function check_adj_brick(i,direction)
	
	--setup adj brick part 1
	local adjx,adjy=brickx[i],bricky[i]
	
	--setup adj brick part 2
	if direction=="up" then
		adjy-=brickh+2
		
	elseif direction=="down"then
		adjy+=brickh+2
		
	elseif direction=="left" then
		adjx-=brickw+2
		
	elseif direction=="right"then
		adjx+=brickw+2
	end
	
	--compare with all bricks 
	for j=1, #brickx do
		if brickv[j] and
		brickx[j]==adjx and
		bricky[j]==adjy then
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
000200001e7102f7302f720367102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001f7103073030720377102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000207103173031720387102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000217103273032720397102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002271033730337203a7102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002371034730347203b7102e700357002c700247001c00024700247001500014000130000d0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
