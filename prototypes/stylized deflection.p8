pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	fgc=14
	bgc=2
	
	brx={}
	bry={}
	brc={}
	brwh=4
	brm=4
	
	bx=20
	by=20
	bdx=1.4
	bdy=2.3
	br=4
	collided=false
	
	deflstyle=false
	lastspec=nil
	
	createbricks()
end

function _update60()
	if btnp(❎) then
		deflstyle=not deflstyle
	end
	
	update_ball()
end

function _draw()
	cls(bgc)
	
	print("stylized deflection",27,55,fgc)
	print("❎ "..tostr(deflstyle),48,62,fgc)
	
	draw_bricks()
	draw_ball()
end

function createbricks()
	local function add_bricks(start,count,x,y,dx,dy)
		for i=start,start+count-1 do
			add(brx,x)
			add(bry,y)
			add(brc,fgc)
			x+=dx
			y+=dy
		end
	end
	
	local brick_size=brwh+brm
	
	-- top row
	add_bricks(1,15,5,5,brick_size,0)
	
	-- right column
	add_bricks(16,14,brx[15],5+brick_size,0,brick_size)
	
	-- bottom row
	add_bricks(30,15,5,bry[29],brick_size,0)
	
	-- left column
	add_bricks(45,13,5,5+brick_size,0,brick_size)
end

function draw_bricks()
	for i=1, #brx do
		rectfill(brx[i],bry[i],brx[i]+brwh,bry[i]+brwh,brc[i])
	end
end

function draw_ball()
	circfill(bx,by,br,fgc)
end

function update_ball()
	local nextx,nexty=bx+bdx,by+bdy
	collided=false
	
	for i=1,#brx do
		if not collided and ball_col(nextx,nexty,brx[i],bry[i],brwh,brwh) then
			handle_collision(i)
			collided=true
		end
	end
	
	bx+=bdx
	by+=bdy
end

function handle_collision(i)
	local is_hor=ball_defl(bx,by,bdx,bdy,brx[i],bry[i],brwh,brwh)
	local adj_direction = get_adj_direction(is_hor)
	local adj_brick=check_adj_brick(i,adj_direction)
	
	if adj_brick and not deflstyle then
		update_special_brick(i)
	end
	
	if adj_brick and deflstyle then
		stylized_deflection(i,is_hor)
	else
		normal_deflection(is_hor)
	end
end

function get_adj_direction(is_hor)
	if is_hor then
		return bdx>0 and "left" or "right"
	else
		return bdy>0 and "up" or "down"
	end
end

function update_special_brick(i)
	if lastspec then
		brc[lastspec]=fgc
	end
	lastspec=i
	brc[i]=8
end

function stylized_deflection(i, is_hor)
	if is_hor then
		by=bdy<0 and bry[i]+brwh+br or bry[i]-br
		bdy=-bdy
	else
		bx=bdx>0 and brx[i]-br or brx[i]+brwh+br
		bdx=-bdx
	end
	update_special_brick(i)
end

function normal_deflection(is_hor)
	if is_hor then
		bdx=-bdx
	else
		bdy=-bdy
	end
end

function ball_col(nx,ny,tx,ty,tw,th)
	if ny-br>ty+th then return false end
	if ny+br<ty then return false end
	if nx-br>tx+tw then return false end
	if nx+br<tx then return false end
	return true
end

function ball_defl(ballx,bally,balldx,balldy,tx,ty,tw,th)
	local bslp=balldy/balldx
	local csx,csy,cslp
	
	if balldx==0 then
		return false
	elseif balldy==0 then
		return true
	elseif bslp>0 and balldx>0 then
		csy=ty-bally
		csx=tx-ballx
		cslp=csy/csx
		return csx>0 and cslp<=bslp
	elseif bslp<0 and balldx>0 then
		csy=ty+th-bally
		csx=tx-ballx
		cslp=csy/csx
		return csx>0 and cslp>=bslp
	elseif bslp>0 and balldx<0 then
		csy=ty+th-bally
		csx=tx+tw-ballx
		cslp=csy/csx
		return csx<0 and cslp<=bslp
	else
		csy=ty-bally
		csx=tx+tw-ballx
		cslp=csy/csx
		return csx<0 and cslp>=bslp
	end
end

function check_adj_brick(i,direction)
	local adjx,adjy=brx[i],bry[i]
	
	if direction=="up" then
		adjy-=brwh+brm
	elseif direction=="down"then
		adjy+=brwh+brm
	elseif direction=="left" then
		adjx-=brwh+brm
	elseif direction=="right"then
		adjx+=brwh+brm
	end
	
	for j=1,#brx do
		if brx[j]==adjx and bry[j]==adjy then
			return true
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
