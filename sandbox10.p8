pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--[[
             todo

-identify ball direction
 get from balldefl(),display
 on debug
 
-detect side of brick hit
 get from balldefl(),display
 on debug
 
-check adjacent brick
 from side hit.function,display
 on debug
 
-apply stylized defl
 setup mode switchable,if true:
 function,play when adj brick,
 display defl type on debug,
 invert ball delta
 
-timer for stylized vs normal
 deflection mode

-text commenting defl type

-implement modular system to
 breakout game

]]--

function _init()
	fgc=14      --foreground color
	bgc=2       --background color
	
	brx={45,65} --brick 1+2 x
	bry=40      --bricks y
	brw=13      --brick width
	brh=8       --brick height
	
	bx=14       --ball x 23
	by=90       --ball y
	bdx=1       --ball delta x
	bdy=-1      --ball delta y
	bsx=bx      --ball start x
	bsy=by      --ball start y
	bsdx=bdx    --ball start bdx
	bsdy=bdy    --ball start bdy
	
	br=3        --ball radius
	col=false   --collision flag
	
	timer=0
end


function _update60()
	updateball()
end


function _draw()
	cls(bgc)
	
	--draw brick 1
	rectfill(brx[1],bry,
	         brx[1]+brw,
	         bry+brh,fgc)
	
	--draw brick 2
	rectfill(brx[2],bry,
	         brx[2]+brw,
	         bry+brh,fgc)
	
	--draw ball
	circfill(bx,by,br,fgc)
end


function updateball()
	local i,nx,ny=
	      1,bx+bdx,by+bdy
	      
	col=false
	
	if timer==75 then
		bx=bsx by=bsy
		bdx=bsdx bdy=bsdy
		timer=0
	end
	
	for i=1,#brx do
		if not col
		and ballcol(nx,ny,brx[i],
		            bry,brw,brh) then
			handlecol(i)
			col=true
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


function handlecol(i) --index
	--ih = is horizontal
	local ih=balldefl(bx,by,
	                  bdx,bdy,
	                  brx[i],bry,
	                  brw,brh)
	
	normaldefl(ih)
end


function balldefl(bx,by,dx,dy,tx,ty,tw,th)
	local bs=dy/dx
	local cx,cy,cs
	
	if dx==0 then return false
	elseif dy==0 then return true
	
	elseif bs>0 and dx>0 then
		cy=ty-by
		cx=tx-bx
		cs=cy/cx
		return cx>0 and cs<=bs
		
	elseif bs<0 and dx>0 then
		cy=ty+th-by
		cx=tx-bx
		cs=cy/cx
		return cx>0 and cs>=bs
		
	elseif bs>0 and dx<0 then
		cy=ty+th-by
		cx=tx+tw-bx
		cs=cy/cx
		return cx<0 and cs<=bs
		
	else
		cy=ty-by
		cx=tx+tw-bx
		cs=cy/cx
		return cx<0 and cs>=bs
	end
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
