pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--game of life
-- by eduszesz

function _init()
	t=0
	state="start"
	ngen=0
	ypop=110
	yspd=12
	selc=0
	debug={}
	alives=0
	dgen={{x=64,y=64,sp=7,nb=nil},
							{x=64,y=65,sp=7,nb=nil},
							{x=64,y=66,sp=7,nb=nil},
							{x=65,y=66,sp=7,nb=nil},
							{x=63,y=65,sp=7,nb=nil},
							{x=30,y=64,sp=7,nb=nil},
							{x=31,y=64,sp=7,nb=nil},
							{x=32,y=64,sp=7,nb=nil},
							}
	agen={}
	--emptymap()
	curx=64
	cury=64		
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
		if yspd<0 then yspd=0 end
		if yspd>127 then yspd=127 end
		if ypop<0 then ypop=0 end
		if ypop>127 then ypop=127 end
		initpop=(-ypop/127)+1
		genspd=flr((31*yspd/127)+1)
		if btnp(🅾️) then
				
				state="draw"
		end
		
		if btnp(❎)then
			firstgen()
			gridst()
			state="game"
		end
	end
	if state=="draw" then
		if btnp(⬅️) then
			curx-=1
		end
		if btnp(➡️) then
			curx+=1
		end
		if btnp(⬆️) then
			cury-=1
		end
		if btnp(⬇️) then
			cury+=1
		end
		if btnp(🅾️) then
			local s={2,3,4,5,6,7}
			--mset(curx/8,cury/8,rnd(s))
			if pget(curx+1,cury+1)==0 then
				local g={x=curx+1,y=cury+1,sp=7,nb=nil}
				--add(agen,g)
			end
		end
		if btnp(❎) then
			getdr()
			gridst()
			state="game"
		end
	end
	if state=="game" then
		if t%genspd==0 then
			if alives!=#agen then
				upstate()
				gridst()
				ngen+=1
			end
			debug[1]=#agen
		end
		if btnp(🅾️) then
			resetsim()
		end
	end
end

function _draw()
	cls()
	map()
	
	if state=="start" then
		line(2,ypop,2,127,11)
		line(125,yspd,125,127,12)
		if selc==0 then
			rect(0,0,4,127,6)
			--print(initpop,64,64,13)
			print("initial population",25,122,11)
		else
			rect(123,0,127,127,6)
			--print(genspd,64,64,13)
			print("simulation speed",30,122,12)
		end
		print("press ❎ to start",32,64,8)
		print("⬅️",6,ypop,11)
		print("➡️",115,yspd,12)
		print("conway's game of life",22,0,11)
	end
	
	if state=="draw" then
		spr(1,curx,cury)
		for g in all(dgen) do
			pset(g.x,g.y,g.sp)
		end
	end
	
	if state=="game" then
		for g in all(agen) do
			pset(g.x,g.y,g.sp)
		end
		print("generations: "..ngen,2,0,11)
		print("🅾️ to reset",72,0,13)
	end
	for i=1,#debug do
		print(debug[i],2,-1+i*9,8)
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
	state="start"
	ngen=0
	debug={}
	agen={}
	emptymap()
end

function getdr()
	for x=0,127 do
		for y=0,127 do
			if pget(x,y)==7 then
				local g={x=x,y=y,sp=7,nb=nil}
				add(agen,g)
			end
		end
	end
end
__gfx__
00000000880000000000000000077000000000000000777700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000808000000000000000700700007770007777707000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700088000000007000007000070000000007077777000000000070700000000000000000000000000000000000000000000000000000000000000000000
00077000000000000077000070000007700000707070077000000000007700000000000000000000000000000000000000000000000000000000000000000000
00077000000000000007700070000007700000707070777000777000007000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000007000070700000707077707700700000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000700700000000007007777000070000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000077000007770007700707000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
000bb0bbb0bb00bbb0bbb0bbb0bbb0bbb00bb0bb000bb000000000bbb0000000000000000ddddd000000ddd00dd00000ddd0ddd00dd0ddd0ddd0000000000000
00b000b000b0b0b000b0b0b0b00b000b00b0b0b0b0b0000b000000b0b000000000000000dd000dd000000d00d0d00000d0d0d000d000d0000d00000000000000
00b000bb00b0b0bb00bb00bbb00b000b00b0b0b0b0bbb000000000b0b000000000000000dd0d0dd000000d00d0d00000dd00dd00ddd0dd000d00000000000000
00b0b0b000b0b0b000b0b0b0b00b000b00b0b0b0b000b00b000000b0b000000000000000dd000dd000000d00d0d00000d0d0d00000d0d0000d00000000000000
00bbb0bbb0b0b0bbb0b0b0b0b00b00bbb0bb00b0b0bb0000000000bbb0000000000000000ddddd0000000d00dd000000d0d0ddd0dd00ddd00d00000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007000007077770070000070000000000000000000070000077000000000000000700000000700007000000000000000000000000000077
00000000007000000000007000000700000000700000000000077007070007007000000000000000000000000000000000000000000070000700007000000000
00000700000070707000070707700070000000070070007000000000000000000000000700070000077000007000000000000700000000000000000000000000
70000000007000070700000070707007070007000007000007700000070000000000770007000000000000000000000000007007700000000700000000000707
00707000000000000007000000007000007770000007000700000000700000700000000000007000700000000000000770007000000000707000000000000000
00000070000000000000000000000700000000000000700007070000070070070000000000000000000070000000000000700700000000007000000000000070
00000000000007000000070000000007000000070000000000000000007000000007000000000000000000070007000000000000000000000000700000000070
00000007000077077000070000000700770000070000007000000000000000000000000000000000000007000007000000000007700000007000000000000000
00070000007700000007000000000770700000700007000000000000000000070007000000070000000000000000000007000000000000000007000000707000
00000000000070000000000000000000700000000000007000000000000700000700000000700007007000000070000000000000000000700000000000000000
07000007707070000000000007000007000007000000007000000070700077007000000000007000000000000000000000000700000700007000700000007000
00000000700000000000000700000070000000000007077000000000000000000007000000007770000070000000007700000000070000070077707070007000
70000070000000000000000000000007000070070000000700000000000000700000000000000000700000007007000000007070000000000700070000000000
70000000000000000000000000000000000000700000000007000000000007007000000000000000000000700700000007000000000000000007700000070000
70000070700000000000000070000070070000000770700700070077007000000000000700000700000007000000000000000000000000000000000000000000
00077000000000000007000007000000700000070000000000000000000000000000000000000007700000000700000000770007000070000000000000000000
00000000000000000000700700000000007000000000000000000000700000000070000070000000000007000007000000000000700000000000000700000070
00700000000070000000000000000770070700000070000007000000000000007000700000000000707000000700000700000000070077000000000000000000
00770000000000070700700000000000000000000007007000000700700000070000777070000000000000000000070000007000000700000070000000000000
00000070000007000007000000700000007000770007007707000070000070070700070000070070000007000000000707070000700000700007000707000000
07000000000000700000007000000000000000000000000000000070000000000070000000700700700000000000700070000000000000070000000007000700
70000000000000700000000000070007700000000000007070000000000000700700000000000700000000000070000000000700700070077700000700000007
00700000000000000007000000000070000000000000070070000700000000000000000000700700000000000000000000000000000000770707000000000000
00007000000770000000000000000070000000007000000007070070700000000000007000070000000007000070000770700007000000000000000000000007
00000000007000700070000000000007000000000000000000000000000070000070070007000000000700700000000070000000077000000000707700000007
07000070000077707000070000007070007070000007000000000707000000000007000000707000000700000000000070000770000700000700070000000070
00000770070000070000000070000000000700000770000000700007000707000000000000000070007707700007070077700000000700077000007770777000
00000000000000000007000000000000000000007000007000000000700700000007000700000000000070000000000000000000000000000007000700000007
00707000007070007700700000077000000007770000000000000007007000007707000007000000000070700070000007000000000000000000077000000000
07700000700000000000000000070000000000000700077700070000000000000000000000000000000070000000000000700000000000000000000070000000
00007000070000000000070000000077000000000000700000000000000070000000000000700000000000000700000000700000000000000000077000000000
07000000000000000770000000007000000000000000000000000000700000000000000000070000007770700000000000000700000000070000000000000000
00007000000700007000707000070000007700000000000700000000000000000700000000000000700000000770700000007700000070000700707000000000
77707700000000000000000000000000000000007000000007070000070070770000000000000000000000000000000070000700007070000000000007000000
00070700700000000007000000000070000000000070700000000000000007070000000700000000000000000007000000700070070000000000000007000000
00000000000000000000700000000070000000007707000000700700007070000000000000007000000007770000000000007000000070000000700070000000
07000000000070000700700000070000070000070070700000000070000000000000700000000770000000000000000000070077707000000000000070707000
00000000077000000070000070000000000000700000700070000000070000070000077700070000000000000070700000000000000000000700700007077070
00700070000000000000700000700007070000000007007000070007000000000700000000000000007000070007007070000000007000007000070000000000
00007000700007000000700000000007070007000000000000000000000000000000070770000000000700700000000007000007000070070700000700000000
00000000070700000000000000000000000000000070770000000000770000000000000700000000000000000000700000000000000000000000000000000007
00077700000707000007700000000077070070007000000070700000000000000070007007000000000000000700007000000070000007000007000000000000
00000000700070700000000007000070000070000077007707000077070000007000007000070077770700000700000700070700000000000000000700000070
00000007000000000000000070000000700000707000000007000000000000007000070000000000000700070000007070000700000700070077000000070000
70000000000700700000000070000000007000000007000000000000077000707000770007000070000000700000000000000700000000000707000000000000
00707700000000000070000070007000000770000007000000000000000000070000000070000000000700000000700070007007000000007000070000000070
00000000000000770000007000000000000000000000000700000000000077700000000007007000000000700000000000070007700770000000077070070007
00000007000070000000070000700007000700070000000000000000000000777000700000000070000000007070000000000000000000000070000000700700
00000000770000000000000077000000000007000700000000707000000007000000000000000000000000700070700000000000000777077000700000700000
00000070000707000700700770000700000000070070007000070070000000000000007000700000700000000007700000007070070000000000000000007000
00070000070007000000000000000007000000007000000000000007000000000700007000000700000700070070000000000007070700007770000007000007
70700000000700000000700707000000000070000000700000070000000000000707000700000000770700000000000000000000000000000000000000000070
00070007000000007000000000770007000000000000700070070000000007007000700000000070707000000007700000000007000000000000000070000700
00000000700000000070000000000000000000007700000000000000000000707000000000000700000700000000007700000007000070000000000000000000
07000000000000000007007000000700700007000700000000000000000700007007007070000000000000000000700000070000000007007070070000070007
00000000000000000700007070000000000000000070700000700000000000000770000000000700007000000070000000000000007000070000070000700000
00070000000000070000700070700000700000000000000000000000700007700000000700700000770000000000070007000000007000700070700070000000
00070000000000007700000000000000000070000000000000000000070000070000000770007000000700000000077000000007000000070000077000000000
00000000000700000000000770000000770000000000700000000077000000000000000000000000700000000000007000007000000000000070000700000000
00700000000000770000000000000070000077000000000007000000007000000000000000700000000070770007000000007007000077000000000000070070
00000000000000000007000007707007000000000000000000000000000007000007700000000000000070000000000007000707070000000000700000000070
00700000007070000000000000700070000000007000000000000700000700007000000077000007700000000000000007000000070000000000700000000007
00077000000070007007000070000700007000000077000007000000000070700000000707070077000000070000077000007070000000000000070000700000
07000000070007077700070070000000070000070770070070000770007000007000700000000000000000070000000000077000000000070000000000000007
07070000770000000000000700000070007000700070070000700000000070000007707000007000000000000000000707000000000000700000070000000070
00000070000000000000000070000000000070700000700700000070000007000000007000000000000000000770007000000000000000007000000000000000
77000777070700070700000000007000000777000000000000000070000700000770000000000000000070000007000007070000000000000707000000000000
00000000000700000000000077070007000000070000000000007700007070000000000700070000000000000000000007000070700000000007000000700070
77070000000000700000000000070000700000000000700070000700000700007700000000000000000000700000070000000000000000000000000700000770
00000000000000000000700070000000070707000000070000000000770000000007000000007000000000000000700770000000000000070000000000077000
00000000000070000770707000000000000000000700000000070000007000007000000007000700000000000070000000007007000000000000070000000000
00700070007000070700000000070700770007070700000000000000700007070007000000000000070000700000000070000000000000000700000000770000
00007000000000070000700070000770070070700007000000000000770000000000070000000000000007000700000070070770070000000700000070000007
00007770000000000000000000000000707000000000000000000000000000000000700070000700000000000000070000070000000000700700000000000007
70000000000007000000077007000000000070700070700000000000000000000070000000000000070700707070000000000000000700700707707700070000
07000007000007007000070000070777007070000000000000707000070070000770000000000000700707000000000000700070000000000707070000000000
00007700000077070000000007000700700000070000000000000000000000070000000000070000700000070700000000000000000000000070000777000000
00000000000000000000700000000007070000707007770000070070700007000000000000000007000000000070000000000700000000000000007007000000
00000000700700070000000007000007700000070700070000000000000000000000000000000000700000000000000000770000000070000000070000000000
00000007000000000000000070007000700000070000700000007000000000000000000700000000000000000707000700007000000000000007000070000000
00007000700000000070000000070000000000000007000700000000000000700007000007000700000000700000070000000000000000007000000007700000
00070000000007000070070070000000070707000000007000000000000700070000000000000000000700000000000000000000000000000007000070000000
00007007000000000070000070000000000700000700000000000000700000000000007000000000070000007070000007000707000007070070070007000000
00007000070007000700000070007700000007000000707070000007000700000000077070070007700707000007000000000007007007000007000000000007
07770000000070000000770000007700000000000000000000000000000070000700007000007070070000007000070000000070000000000700000000000000
00070000000007007707000000700007000000707070000000000770070000000007000000000070000700000000000700000070000000707000000000000000
00000000700000070000000000000007000070700000070000700000077000000007000000000000770070000770000070000000000000000007000070000000
07007007000000007700000000000000070070000000000000700000000000000000000000000000007007000700000000000007000000000000000000000000
07000000000000000007000000070070000000000007000070700007000700000000000070000000000000070070000000000000000070000000700000000000
00077007000070070000000070000000007000000007000000000000000007000007000000000000000707700700000000070007000000700000000700000000
00700700000000007000000000000000000000000000000000000770007700007000707000000070000000000000000077000000070070000000077700070070
07000000007700000000000700000070000000007000070000000000000000000000000000070007700000000000000000000000070000000000000000000000
00000700000000000000000000070000000000000007070000000077070000070000000000000007007000000000700000007707007000000007000000000007
00770000000700070000000000000000000000000000000070007077000700000070700000700000000070000707000000007000000700000070070070070070
00000000000000000000000000000000000000000000700000700007000000077000000000000007000700000000070000000000000000070077077000070000
00707700700000000700000000007000000000000700000000000000070007000000000000070000007707000000000000000000000000000000070000000007
70000000000000007070070070000000000000700000000000070077000000000007000000770077000000700000000000000000070700000000000000000007
07000000000000000000070000000000000700000000000700000070000070000000070000000707000000000000000000000000007000000000700000000007
07007070700000700000000000000000700000000000700000000000700000000700000000000007770000000000070000000007070000770007700700070000
07070000077077000000700070000000000000700000000000000000000700000000000000700000000007000000000070000700000000000070000000000000
00007000070000007000700000007000007070070000000707000000070700700000000070070000000000000000700000070070000070000700000007000007
70700000000077000000000770070700000070000000000070707000000000000000000007000070000000000007000007007000000000070000000000000000
00700000070000000070000000700000700000000000707000000000000700000070000000700700000700700070000700000000007000070007070000000000
00000000700007000007000000000000000000007070070000000000077077000070007070070000000700007700700070000700000000770000000000000007
00070000700000000700000000000000070070000000000707000007007000000000070000700000000000000000000000700070000000000077007000000070
00707000707000000000000000000000070000070000000700000700000007000000000070000000077700007007000007007070000000000000000000000000
00070000000070000000700700070007000000007000077070000070000000000000000000000070700000000000000000007000070000000000007000000000
70007000007000070000070000000070000707000000000007000000700700000000700000700000000000000000000770000000007070007000000700000700
70077070000000000000007000000000007000007070000707000000000000700000000070000700000777000000000000000000000000000000000000000700
07007000000000770770070000000007000700007000070700700770700000000000000000000000070000000000007007707000000000070000000000000000
00000700000700770000000000070000000000700000000070000000070077000007000070000000000000000000007000770070000000070000700000000070
00000000000070700000000000007000070000070000700000070000000000000000007000000000000070000000000000000000000000000070000007000077
00070000000000000000000000000700007007000000000000000000700000007007007000000000000700000700007000007000070000007077000000700000
07000000000000070000070000000077000000000000000070000000000000000700007000000700000000707000000700070000000000700000000000000007
00000007700700000000070707000700000000700700070000007000000000000007000000000000700077000700700000000070000007000000000000000000
00700000000700000000000000000070000070000007000000000000000000070070700007000000700000000000077007000000000000007000000070700077
00700007000700000700000000070000000700000700000000000000000000700070000000007000000000000000000000070007000000070000000000000000
00000000000070000000007700000007070007000000000070000000000070000000000000000000000000000000007000000000070007000700000007070700
00000000000000000000000000700000000700000700000007000000000070000000000007077070000700000000000000007000070000070000000700000000

