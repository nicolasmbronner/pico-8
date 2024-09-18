pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	fgc=14 --foreground color
	bgc=2 --background color
	
	brx={} --brick x positions
	bry={} --brick y positions
	brc={} --brick colors
	brw=4 --brick width
	brm=4 --brick margin
	
	bx=20 --ball x
	by=20 --ball y
	bdx=1.4 --ball delta x
	bdy=2.3 --ball delta y
	br=4 --ball radius
	col=false --collision flag
	
	dfs=false --deflection style
	lsp=nil --last special brick
	
	createbricks()
end

function _update60()
	if btnp(❎) then
		dfs=not dfs
	end
	
	updateball()
end

function _draw()
	cls(bgc)
	
	print("stylized deflection",27,55,fgc)
	print("❎ "..tostr(dfs),48,62,fgc)
	
	drawbricks()
	drawball()
end

function createbricks()
	local function addbr(s,c,x,y,dx,dy)
		for i=s,s+c-1 do
			add(brx,x)
			add(bry,y)
			add(brc,fgc)
			x+=dx
			y+=dy
		end
	end
	
	local bsz=brw+brm --brick size
	
	addbr(1,15,5,5,bsz,0)
	addbr(16,14,brx[15],5+bsz,0,bsz)
	addbr(30,15,5,bry[29],bsz,0)
	addbr(45,13,5,5+bsz,0,bsz)
end

function drawbricks()
	for i=1,#brx do
		rectfill(brx[i],bry[i],brx[i]+brw,bry[i]+brw,brc[i])
	end
end

function drawball()
	circfill(bx,by,br,fgc)
end

function updateball()
	local nx,ny=bx+bdx,by+bdy
	col=false
	
	for i=1,#brx do
		if not col and ballcol(nx,ny,brx[i],bry[i],brw,brw) then
			handlecol(i) --handle collision
			col=true
		end
	end
	
	bx+=bdx
	by+=bdy
end

function handlecol(i)
	local ih=balldefl(bx,by,bdx,bdy,brx[i],bry[i],brw,brw)
	local ad=getadjdir(ih)
	local ab=checkadjbr(i,ad)
	
	if ab and not dfs then
		updatespecbr(i) --update special brick
	end
	
	if ab and dfs then
		styledefl(i,ih) --stylized deflection
	else
		normaldefl(ih) --normal deflection
	end
end

function getadjdir(ih)
	if ih then
		return bdx>0 and "left" or "right"
	else
		return bdy>0 and "up" or "down"
	end
end

function updatespecbr(i)
	if lsp then
		brc[lsp]=fgc
	end
	lsp=i
	brc[i]=8
end

function styledefl(i,ih)
	if ih then
		by=bdy<0 and bry[i]+brw+br or bry[i]-br
		bdy=-bdy
	else
		bx=bdx>0 and brx[i]-br or brx[i]+brw+br
		bdx=-bdx
	end
	updatespecbr(i)
end

function normaldefl(ih)
	if ih then
		bdx=-bdx
	else
		bdy=-bdy
	end
end

function ballcol(nx,ny,tx,ty,tw,th)
	if ny-br>ty+th then return false end
	if ny+br<ty then return false end
	if nx-br>tx+tw then return false end
	if nx+br<tx then return false end
	return true
end

function balldefl(bx,by,dx,dy,tx,ty,tw,th)
	local bs=dy/dx
	local cx,cy,cs
	
	if dx==0 then
		return false
	elseif dy==0 then
		return true
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

function checkadjbr(i,d)
	local ax,ay=brx[i],bry[i]
	
	if d=="up" then
		ay-=brw+brm
	elseif d=="down"then
		ay+=brw+brm
	elseif d=="left" then
		ax-=brw+brm
	elseif d=="right"then
		ax+=brw+brm
	end
	
	for j=1,#brx do
		if brx[j]==ax and bry[j]==ay then
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
