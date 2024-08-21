pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--ball
ball_x=60
ball_dx=1.5 --delta
ball_y=10
ball_dy=0.5
ball_r=3    --radius
ball_c=9	--color

--rectangle x43 w40
rec_x=43
rec_y=53
rec_w=40
rec_h=20
rec_c=6
rec_nhc=11	--no hit color
rec_hc=8	--hit color



function _init()
	cls()
end



function _update60()
	
	--ball horizontal boundaries
	if ball_x>120
	or ball_x<5 then
		ball_dx=-ball_dx
	end
	
	--ball vertical boundaries
	if ball_y>120
	or ball_y<5 then
		ball_dy=-ball_dy
	end
	
	--predict next ball pos
	nextx=ball_x+ball_dx
	nexty=ball_y+ball_dy
	
	--check if ball hit rectangle
	rec_c=rec_nhc
	if ball_col(
	nextx,nexty,rec_x,rec_y,
	rec_w,rec_h) then
	
	--deal with deflection
		if ball_defl(
		ball_x,ball_y,ball_dx,
		ball_dy,rec_x,rec_y,
		rec_w,rec_h) then
		
			--ball_defl=true
			--horizontal deflection
			ball_dx=-ball_dx
			
		else
			
			--ball_defl=false
			--vertical deflection
			ball_dy=-ball_dy
			
		end
	end
	
		--make ball move
	ball_x+=ball_dx
	ball_y+=ball_dy
	
end



function _draw()
	cls(1)
	
	--draw ball
	circfill(
	ball_x,ball_y,ball_r,ball_c)
	
	--draw rectangle
	rectfill(
	rec_x,rec_y,rec_x+rec_w,
	rec_y+rec_h,rec_c)
end



--check collision of the ball
--with the rectangle
--by elimination

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

function ball_defl(
bx,by,bdx,bdy,tx,ty,tw,th)
	
	local bslp=bdy/bdx --ball slope
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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
