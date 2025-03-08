pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--[[
             todo

ˇidentify ball direction
ˇdetect side of brick hit
ˇcheck adjacent brick
 
- apply stylized defl
  setup mode switchable,if true:
  function,play when adj brick,
  display defl type on debug,
  invert ball delta
 
- timer for stylized vs normal
  deflection mode

- text commenting defl type

- implement modular system to
  breakout game

]]--

function _init()
	fgc=14      --foreground color
	bgc=2       --background color
	tc=1        --tertiary color
	
	brx={45,65} --brick 1+2 x
	bry={40,50} --bricks y
	brw=13      --brick width
	brh=4       --brick height
	brs=""      --brick side (hit)
	brhx=0      --brick hit x
	brhy=0      --brick hit y
	brtx=0      --brick test x
	brty=0      --brick test y
	adjbr=false --adjacent brick
	
	bx=29        --ball x 14,23
	by=90        --ball y 90
	bdx=1       --ball delta x
	bdy=-1       --ball delta y
	bsx=bx      --ball start x
	bsy=by      --ball start y
	bsdx=bdx    --ball start bdx
	bsdy=bdy    --ball start bdy
	bdir="none" --ball direction
	ih=false    --is horizontal?
	
	br=2        --ball radius
	col=false   --collision flag
	
	timer=0
end


function _update60()
	updateball()
end


function _draw()
	cls(bgc)
	
	--draw brick 1
	rectfill(brx[1],bry[1],
	         brx[1]+brw,
	         bry[1]+brh,fgc)
	
	--draw brick 2
	rectfill(brx[2],bry[1],
	         brx[2]+brw,
	         bry[1]+brh,fgc)
	     
--draw brick 3
	rectfill(brx[1],bry[2],
	         brx[1]+brw,
	         bry[2]+brh,fgc)
	
	--draw brick 4
	rectfill(brx[2],bry[2],
	         brx[2]+brw,
	         bry[2]+brh,fgc)
	
	--draw ball
	circfill(bx,by,br,fgc)
	
	--debug ball direction
	print("ball dir:"..bdir,
	      1,8,tc)
	
	--debug brick side hit
	print("brick side:"..brs)
	
	--debug deflection direction
	print("is hor:"..tostr(ih))
	
	--debug brick hit pos
	print("brick hit x:"..brhx..
	      " y:"..brhy)
	
	--debug brick test pos
	print("brick test x:"..brtx..
	      " y:"..brty)
	
	--debug adj brick
	print("adj brick:"..tostr(
	      adjbr))
end


function updateball()
	local nx,ny=
	      bx+bdx,by+bdy
	      
	col=false
	
	if timer==75 then
		bx=bsx by=bsy
		bdx=bsdx bdy=bsdy
		timer=0
	end
	
	for i=1,#brx do
		for j=1,#bry do
			if not col
			and ballcol(nx,ny,brx[i],
		            bry[j],brw,brh)
		 then
				handlecol(i,j)
				col=true
			end
		end
	end
	
	bx+=bdx
	by+=bdy
	timer+=1
end


function ballcol(nx,ny,tx,ty,
                 tw,th)
	return not (
		ny-br>ty+th or
		ny+br<ty or
		nx-br>tx+tw or
		nx+br<tx
	)
end


--★★★★★★★★★★★★★★★
function handlecol(i,j) --index
	
	ih,bdir,brs=
	balldefl(bx,by,bdx,bdy,
	         brx[i],bry[j],brw,brh)
	adjbr=checkadjbr(brs,brx[i],
	                 bry[j])
	
	normaldefl(ih)
end


--★★★★★★★★★★★★★★★
function balldefl(bx,by,dx,dy,tx,ty,tw,th)
	local bs=dy/dx
	local cx,cy,cs
	local dir,side,ishor
	
	--determine ball direction
	if dx>0 then
		dir=dy>0 and "dr" or "ur"
	else --dx<0
		dir=dy>0 and "dl" or "ul"
	end
	
	if dx==0 then     --100% vert
		side=dy>0 and "⬆️" or "⬇️" 
		return false,dir,side
	elseif dy==0 then --100% hor
		side=dx>0 and "⬅️" or "➡️"
		return true,dir,side
	
	--ball moving ⬇️➡️
	elseif dir=="dr" then
		cy=ty-by
		cx=tx-bx
		cs=cy/cx
		ishor=cx>0 and cs<=bs
		side=ishor and "⬅️" or "⬆️"
		return ishor,dir,side
		
	--ball moving ⬆️➡️
	elseif dir=="ur" then
		cy=ty+th-by
		cx=tx-bx
		cs=cy/cx
		ishor=cx>0 and cs>=bs
		side=ishor and "⬅️" or "⬇️"
		return ishor,dir,side
		
	--ball moving ⬆️⬅️
	elseif dir=="ul" then
		cy=ty+th-by
		cx=tx+tw-bx
		cs=cy/cx
		ishor=cx<0 and cs<=bs
		side=ishor and "➡️" or "⬇️"
		return ishor,dir,side
		
	--ball moving ⬇️⬅️
	else
		cy=ty-by
		cx=tx+tw-bx
		cs=cy/cx
		ishor=cx<0 and cs>=bs
		side=ishor and "➡️" or "⬆️"
		return ishor,dir,side
	end
end -- t=192,180,269


function checkadjbr(side,x,y)
	local adjbrx,adjbry=
	      false,false
	      
	brhx=x brhy=y --☉
	
	if side=="⬆️" then
		y=y-10--☉
	elseif side=="➡️" then
		x=x+20 --☉
	elseif side=="⬇️" then
		y=y+10 --☉
	elseif side=="⬅️" then
		x=x-20 --☉
	end
	
	brtx=x brty=y --☉
	
	
	for i=1,#brx do
		if brx[i]==x then
			adjbrx=true
		end
		for j=1,#bry do
			if bry[j]==y then
				adjbry=true
			end
		end
		if adjbrx and adjbry then
			return true
		end
	end
	
	return false
end


function normaldefl(ih)
	--ih = is horizontal
	if ih then
		bdx=-bdx
	else
		bdy=-bdy
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
