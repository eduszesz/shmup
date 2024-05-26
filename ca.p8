pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--game of life
-- by eduszesz

function _init()
	t=0
	debug={}
	agen={}
	ngen={}
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
	if btnp(❎) then
	--if t%30==0 then
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
end

function emptymap()
	for x=0,15 do
		for y=0,15 do
			mset(x,y,1)
		end
	end
end

function firstgen()
	for x=0,15 do
		for y=0,15 do
			local sp=1
			if rnd()<0.25 then
				sp=2
				mset(x,y,sp)
			end
			local g={x=x,y=y,sp=sp,nb=nil}
				add(agen,g)
		end
	end
end

function getnb(_x,_y,_m) 
		if _m==nil then
			x,y=_x/8,_y/8
		end
		local nb=0
		for i=-1,1 do
			for j=-1,1 do
				if mget(x+i,y+j)==2 then
					nb+=1
				end
			end
		end
		if mget(x,y)==2 then
			nb-=1
		end
		
		add(debug,nb)
end

function gridst()
	for g in all(agen) do
		local nb=0
		for i=-1,1 do
			for j=-1,1 do
				if mget(g.x+i,g.y+j)==2 then
					nb+=1
				end
			end
		end
		if mget(g.x,g.y)==2 then
			nb-=1
		end
		g.nb=nb
	end
end

function upstate()
	for g in all(agen) do
		local tle=mget(g.x,g.y)
		if g.nb>3 then
			g.sp=1
		elseif g.nb==3 then
			g.sp=2
		elseif g.nb==2 and tle==2 then
			g.sp=2
		else
			g.sp=1
		end
	end
	for g in all(agen) do
		mset(g.x,g.y,g.sp)
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
