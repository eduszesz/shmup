pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--game of life
-- by eduszesz

function _init()
	t=0
	state="start"
	ngen=0
	ypop=0
	yspd=0
	selc=0
	initpop=0.1
	genspd=3
	debug={}
	agen={}
	emptymap()
	
		
end

function _update()
	t+=1
	if state=="start"then
		if btnp(⬅️) then
			selc=0
		end
		if btnp(➡️) then
			selc=1
		end
		if selc==0 then
			if btn(⬆️) then
				ypop-=1
			end
			if btn(⬇️) then
				ypop+=1
			end
		end
		if selc==1 then
			if btn(⬆️) then
				yspd-=1
			end
			if btn(⬇️) then
				yspd+=1
			end
		end
		if btnp(❎)then
			firstgen()
			gridst()
			state="game"
		end
	end
	if state=="game" then
		if t%genspd==0 then
			upstate()
			gridst()
			ngen+=1
		end
		if btnp(🅾️) then
			resetsim()
		end
	end
end

function _draw()
	cls()
	map()
	for i=1,#debug do
		print(debug[i],2,-1+i*9,8)
	end
	if state=="start" then
		line(2,127,2,ypop,11)
		line(125,127,125,yspd,12)
		if selc==0 then
			rect(0,0,4,127,7)
		else
			rect(123,0,127,127,7)
		end
		print("⬅️",6,ypop,11)
		print("➡️",115,yspd,12)
		print("conway's game of life",22,0,11)
	end
	
	
	if state=="game" then
		for g in all(agen) do
			pset(g.x,g.y,g.sp)
		end
		print("generations: "..ngen,2,0,11)
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
		for y=9,127 do
			local sp=0
			if rnd()<initpop then
				sp=7
				pset(x,y,sp)
			end
			local g={x=x,y=y,sp=sp,nb=nil}
				add(agen,g)
		end
	end
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

function resetsim()
	t=0
	--state="start"
	ngen=0
	initpop=0.1
	genspd=3
	debug={}
	agen={}
	emptymap()
	firstgen()
	gridst()

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
