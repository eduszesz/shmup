pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--game of life
-- by eduszesz

function _init()
	t=0
	debug={}
	agen={}
	emptymap()
	firstgen()
	gridst()
	curx=0
	cury=0
end

function _update()
	t+=1
	if btnp(⬅️) then
		curx-=8
	end
	if btnp(➡️) then
		curx+=8
	end
	if btnp(⬆️) then
		cury-=8
	end
	if btnp(⬇️) then
		cury+=8
	end
	if btnp(🅾️) then
		getnb(curx,cury)
	end
	--if btnp(❎) then
	if t%3==0 then
		upstate()
		gridst()
	end
end

function _draw()
	cls()
	map()
	for i=1,#debug do
		print(debug[i],2,-1+i*9,8)
	end
	spr(3,curx,cury)
	for g in all(agen) do
		pset(g.x,g.y,g.sp)
	end
end

function emptymap()
	for x=0,127 do
		for y=0,127 do
			pset(x,y,0)
		end
	end
end

function firstgen()
	for x=0,127 do
		for y=0,127 do
			local sp=0
			if rnd()<0.1 then
				sp=7
				pset(x,y,sp)
			end
			local g={x=x,y=y,sp=sp,nb=nil}
				add(agen,g)
		end
	end
end

function getnb(_x,_y,_m) 
		if _m==nil then
			x,y=_x,_y
		end
		local nb=0
		for i=-1,1 do
			for j=-1,1 do
				if pget(x+i,y+j)==7 then
					nb+=1
				end
			end
		end
		if pget(x,y)==7 then
			nb-=1
		end
		
		add(debug,nb)
end

function gridst()
	for g in all(agen) do
		local nb=0
		for i=-1,1 do
			for j=-1,1 do
				if pget(g.x+i,g.y+j)==7 then
					nb+=1
				end
			end
		end
		if pget(g.x,g.y)==7 then
			nb-=1
		end
		g.nb=nb
	end
end

function upstate()
	for g in all(agen) do
		local tle=pget(g.x,g.y)
		if g.nb>3 then
			g.sp=0
		elseif g.nb==3 then
			g.sp=7
		elseif g.nb==2 and tle==7 then
			g.sp=7
		else
			g.sp=0
		end
	end
	for g in all(agen) do
		pset(g.x,g.y,g.sp)
	end
end
__gfx__
00000000666666666666666688000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006000000d6777777d80000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007006000000d6777777d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770006000000d6777777d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770006000000d6777777d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007006000000d6777777d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006000000d6777777d80000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006ddddddd6ddddddd88000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
