pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--topshooter
--by eduszesz

function _init()
	t=0
	initialize()
	mkrocks()
	mkmap()
end

function _update()
	t+=1
	
	if state=="start" then
		if btnp(🅾️) then
			state="game"
		end
	end
	
	if state=="game" then
		update_game()
	end
	
	if state=="over" then
		if btnp(🅾️) then
			state="start"
			initialize()
		end
	end
	
end

function _draw()
	cls(15)
	map()
	if state=="start" then
		print("press 🅾️ to start",30,64,0)
	end
	
	if state=="game" then
		draw_game()
	end
	
	if state=="over" then
		print("press 🅾️ to play again",20,64,0)
	end
end

function initialize()
	frate=3
	state="start"
	p={x=64,
				y=64,
				sp=1,
				dx=0,
				dy=0,
				h=10,
				t=10,
				t0=10,
				tsk="walk",
				id="player",
				dirx=false,
				diry=false,
				box={x1=2,y1=2,x2=5,y2=5}}
	bullets={}
	smoke={}
	enemies={}
	explosions={}
	sparks={}
	corpses={}
	dust={}
end

function update_game()
	for e in all(enemies) do
		invencible(e)
	end
	upplayer()
	updbullets()
	updsmoke()
	upenemies()
	upexplosions()
	upsparks()
	upcorpses()
	updust()
end

function draw_game()
	drbullets()
	drcorpses()
	drdust()
	drenemies()
	drplayer()
	drsparks()
	drsmoke()
	drexplosions()
end

function upplayer()
	invencible(p)
	p.dx=0
	p.dy=0
	if btn(⬆️) then
		p.dy=-1
		if not btn(🅾️) then
			p.sp=1
		end
	end
	if btn(⬇️) then
		p.dy=1
		if not btn(🅾️) then
			p.sp=5
		end	
	end
	if btn(⬅️) then
		p.dx=-1
		if not btn(🅾️) then
			p.sp=3
		end	
	end
	if btn(➡️) then
		p.dx=1
		if not btn(🅾️) then
			p.sp=7
		end	
	end
	if btn(❎) and frate==3 then
		fire(p)
	end
	
	frate-=1
	if frate<0 then
		frate=3
	end
	if hit((p.x+p.dx),p.y,4,4,0) then
		p.dx*=-1
	end
  	
	if hit(p.x,(p.y+p.dy),4,4,0) then
		p.dy*=-1
	end
	
	for b in all(bullets) do
		if coll(p,b) and b.id=="enemy" then
			del(bullets,b)
				if not p.inv then
					p.inv=true
					p.h-=1
					for i=1,rnd(5)+5 do
						mrsparks(p.x+4,p.y+4)
					end
					if p.h<1 then
						mkexplosions(p.x+4,p.y+4)
						mkcorpses(p.x,p.y,p)
						p.x,p.y=-500,-500
					end
				end
		end
	end
	
	for e in all(enemies) do
		if coll(p,e) then
			if p.x-e.x>0 then
				p.x+=2
			else
				p.x-=2	
			end
			if p.y-e.y>0 then
				p.y+=2
			else
				p.y-=2	
			end
		end
	end
	
	if p.h>0 then
		p.x+=p.dx
		p.y+=p.dy
	end
	if p.h>0 then
		if p.x<0 then p.x=0 end
		if p.x>120 then p.x=120 end
		if p.y<0 then p.y=0 end
		if p.y>120 then p.y=120 end
	end
end

function drplayer()
	if p.h>0 then
		aniwalk(p)
		if p.inv then
			for i=0,15 do
				if t%4<2 then
					pal(i,7)
				end
				aniwalk(p)
			end
		end
		pal()
	end
	line(0,128,0,128-12.8*p.h,8)	
end

function updbullets()
	for b in all(bullets) do
		b.x+=b.dx
		b.y+=b.dy
		if b.x<-8 or b.x>128
			or b.y<-8 or b.y>128 then
			del(bullets,b)
		end	
	end
end

function updsmoke()
	for s in all(smoke) do
		s.r-=1
		if s.r<0 then
			del(smoke,s)
		end
	end
end

function drbullets()
	for b in all(bullets) do
		spr(b.sp,b.x,b.y)
	end
end

function drsmoke()
	for s in all(smoke) do
		circfill(s.x,s.y,s.r,7)
	end
end

function fire(_p)
	local p=_p
	local dx,dy=0,-1
	local ox,oy=2,-4
	local sox,soy=5,0
	local sp=9
	if p.sp==5 or p.sp==6 then
		dx,dy=0,1
		ox,oy=-2,4
		sox,soy=2,8
	end
	if p.sp==3 or p.sp==4 then
		dx,dy=-1,0
		ox,oy=-2,-2
		sox,soy=0,2
		sp=10
	end
	if p.sp==7 or p.sp==8 then
		dx,dy=1,0
		ox,oy=2,1
		sox,soy=8,5
		sp=10
	end
	if p.sp==64 then
		if p.diry then
		 dx,dy=0,-1
		 ox,oy=4,2
		 sox,soy=7,7
		else
			dx,dy=0,1
			ox,oy=3,6
			sox,soy=7,7
		end
	end
	if p.sp==66 then
		if p.dirx then
		 dx,dy=-1,0
		 ox,oy=0,3
		 sox,soy=6,7
		 sp=10
		else
		 dx,dy=1,0
		 ox,oy=7,4
		 sox,soy=9,7
		 sp=10
		end
	end
	local b={x=p.x+ox,
										y=p.y+oy,
										sp=sp,
										dx=dx*6,
										dy=dy*6,
										id=p.id,
										box={x1=0,y1=0,x2=7,y2=7}}
	add(bullets,b)
	mksmoke(sox,soy,p)
end

function mksmoke(_ox,_oy,_obj)
	local ox,oy,p=_ox,_oy,_obj
	local s={r=3,x=p.x+ox,y=p.y+oy}
	add(smoke,s)
end

function mkrocks()
	for i=1,5 do
		mset(rnd(16),rnd(16),48)
	end
end

function mkenemies()
	local pint={"up","down","left","right"}
	local pi=rnd(pint)
	local x=rnd(112)+8
	local y=rnd(112)+8
	local dx,dy=0,0
	local typ="sdr"
	local sp=1
	local sz=1
	if pi=="up" then
		y=-10
		dy=1
	end
	if pi=="down" then
		y=130
		dy=-1
	end
	if pi=="left" then
		x=-10
		dx=1
	end
	if pi=="right" then
		x=130
		dx=-1
	end
	if rnd()<0.5 then
		typ="jipe"
		sp=64
		y=-10
		x=rnd(112)+8
		dy=1
		dx=0
		sz=2
	end
	local e={sp=sp,
										x=x,
										y=y,
										dx=dx,
										dy=dy,
										h=3,
										t0=5,
										t=5,
										ft=60,
										inv=false,
										tsk="walk",
										id="enemy",
										typ=typ,
										dirx=false,
										diry=false,
										box={x1=0,y1=0,x2=7*sz,y2=7*sz}}
	add(enemies,e)									
end

function upenemies()
	
	if #enemies==0 and t%30==0 then
		mkenemies()
	end
	
	for e in all(enemies) do
		for b in all(bullets) do
			if coll(e,b) and b.id=="player" then
				del(bullets,b)
				if not e.inv then
					e.inv=true
					e.h-=1
					for i=1,rnd(5)+5 do
						mrsparks(e.x+4,e.y+4)
					end
					if e.h<0 then
						mkexplosions(e.x+4,e.y+4)
						mkcorpses(e.x,e.y,e)
						del(enemies,e)
					end
				end
			end	
		end
		
		if e.tsk=="fire" then
			if t%20==0 and not e.inv then
				fire(e)
			end
			local dir={-1,1}
			e.ft-=1 
			if e.ft==0 then
				e.tsk="walk"
				e.ft=60
				if rnd()<0.5 then
					e.dx=rnd(dir)
					e.dy=0
				else
					e.dy=rnd(dir)
					e.dx=0	
				end
			end
		end
		
		if hit((e.x+e.dx),e.y,7,7,0) then
				e.dx*=-1
		end
  	
		if hit(e.x,(e.y+e.dy),7,7,0) then
				e.dy*=-1
		end
		enedir(e)
		if e.dx!=0 and 
			e.tsk=="walk" and abs(e.x-p.x)<7 then
			e.tsk="fire"
			if e.y>p.y then
				e.dy=-1
				e.dx=0	
			end
			if e.y<p.y then
				e.dy=1
				e.dx=0	
			end
		end
		
		if e.dx==0 and 
			e.tsk=="walk" and abs(e.y-p.y)<7 then
			if e.x>p.x then
				e.dx=-1
				e.dy=0	
			end
			if e.x<p.x then
				e.dx=1
				e.dy=0	
			end
			e.tsk="fire"
		end

		if e.tsk=="walk" then
			e.x+=e.dx
			e.y+=e.dy
			if e.typ=="jipe" then
				mkdust(e)
			end
		end
		if e.x>150 or e.x<-20
			or e.y>150 or e.y<-20 then
			del(enemies,e)
		end
		
	end
end

function drenemies()
	for e in all(enemies) do
		pal(11,8)
		aniwalk(e)
		if e.inv then
			for i=0,15 do
				if t%4<2 then
					pal(i,7)
				end
				aniwalk(e)
			end
		end
		pal()
	end
end

function enedir(_e)
	local e=_e
	if e.typ=="sdr" then
		if e.dx==1 then e.sp=7 end
		if e.dx==-1 then e.sp=3 end
		if e.dy==1 then e.sp=5 end
		if e.dy==-1 then e.sp=1 end
	end
	if e.typ=="jipe" then
		if e.dy==-1  then e.diry=true end
		if e.dy==1  then e.diry=false end
		if e.dx==-1  then e.dirx=true end
		if e.dx==1  then e.dirx=false end
		if e.dx!=0 then e.sp=66 end
		if e.dy!=0 then e.sp=64 end
	end
	
end

function invencible(_p)
	local p=_p
	if p.inv then
		p.t-=1
	end
	if p.t<0 then
		p.t=p.t0
		p.inv=false
	end
end

function aniwalk(_p)
	local p=_p
	local sz=1
	if p.typ=="jipe" then
		sz=2
	end
	if p.typ!="jipe" then
		if p.dx!=0 or p.dy!=0 then
			if t%8<4 and p.tsk=="walk" then
				spr(p.sp+sz,p.x,p.y,sz,sz,p.dirx,pdiry)
			else
				spr(p.sp,p.x,p.y,sz,sz,p.dirx,p.diry)		
			end
		else
			spr(p.sp,p.x,p.y,sz,sz,p.dirx,p.diry)
		end
	else
			spr(p.sp,p.x,p.y,sz,sz,p.dirx,p.diry)
	end
end

function mkexplosions(_x,_y)
	local ex={x=_x,
											y=_y,
											r=10}
	add(explosions,ex)										
end

function upexplosions()
	for ex in all(explosions) do
		ex.r-=1
		if ex.r<0 then
			del(explosions,ex)
		end
	end
end

function drexplosions()
	for ex in all(explosions) do
		circfill(ex.x,ex.y,ex.r,8)
	end
end

function mrsparks(_x,_y)
	local s={x=_x,
										y=_y,
										c=8,
										dx=rnd(2)-1,
										dy=rnd(2)-1,
										t=10}
	add(sparks,s)
end

function upsparks()
	for s in all(sparks) do
		s.t-=1
		s.x+=s.dx
		s.y+=s.dy
		if s.t<0 then
			del(sparks,s)
		end
	end
end

function drsparks()
	for s in all(sparks) do
		pset(s.x,s.y,s.c)
	end
end

function mkcorpses(_x,_y,_obj)
	local sp=11
	if _obj.typ=="jipe" then
		sp=68
	end
	local cr={x=_x,
											y=_y,
											sp=sp,
											id=_obj.id,
											t=90}
	add(corpses,cr)
end

function upcorpses()
	for cr in all(corpses) do
		cr.t-=1
		if cr.sp!=68 then
			if cr.t==60 then
				cr.sp=12
			end
			if cr.t==30 then
				cr.sp=13
			end
		end
		if cr.t<0 then
			mset((cr.x+4)/8,(cr.y+4)/8,14)
			if cr.id=="player"then
				state="over"
			end
			del(corpses,cr)
		end
	end
end

function drcorpses()
	for cr in all(corpses) do
		if cr.id=="player" then
			pal(8,11)
			spr(cr.sp,cr.x,cr.y)
			pal()
		else
			if cr.sp==68 then
				spr(cr.sp,cr.x,cr.y,2,2)
			else
				spr(cr.sp,cr.x,cr.y)
			end
		end	
	end
end

function mkdust(_obj)
	local e=_obj
	local dx,dy=7,-3
	if e.sp==64 and e.diry then
		dx,dy=7,18
	end
	if e.sp==66 then
		if e.dirx then
			dx,dy=18,7
		else
			dx,dy=-3,7
		end
	end
	
	local d={x=e.x+dx,
			y=e.y+dy,
			r=3}
	add(dust,d)
end

function updust()
	for d in all(dust) do
		d.r-=1
		if d.r<0 then
			del(dust,d)
		end
	end
end

function drdust()
	for d in all(dust) do
		fillp(░)
		circfill(d.x,d.y,d.r,6)
		fillp()
	end
end

function mkmap()
	
	for y=0,7 do
		for x=120,127 do
			if sget(x,y)==1 then
				mset(x-120,y,16)
			end
			if sget(x,y)==8 then
				mset(x-120,y,17)
			end
		end
	end
end

--collision map entities
function hit(x,y,w,h,flag)
	local f=flag
	collide = false
	
	for i=x,x+w,w do
		if fget(mget(i/8,y/8),f) or
		fget(mget(i/8,(y+h)/8),f) then
			collide = true
		end
	end
	return collide
end

--collision sprite based entities
function abs_box(s)
 local box = {}
 box.x1 = s.box.x1 + s.x
 box.y1 = s.box.y1 + s.y
 box.x2 = s.box.x2 + s.x
 box.y2 = s.box.y2 + s.y
 return box

end

function coll(a,b)
 
 local box_a = abs_box(a)
 local box_b = abs_box(b)
 
 if box_a.x1 > box_b.x2 or
    box_a.y1 > box_b.y2 or
    box_b.x1 > box_a.x2 or
    box_b.y1 > box_a.y2 then
    return false
 end
 return true 
end
__gfx__
0000000000000500000000000000000000000bbd00033d00db33d000000000000000000000008000000000000000000000000000000000000000000000000000
0000000000000d00000000500000bbd005d5555b0db44b00b544b000000000000000000000088000000000000800440007006600000066000006000010000000
0070070000000500000000d05d5555b00000b4430b544b00b544b000dbbbd000000000000008e000000000000de3440006076600060066000006600010000000
0007700000dbb50000000050000b04430000b4430b500b0005bbd0003440b000dbbd0000000e700088e7e8800033000000770000007700000000000010800000
0007700000b005b0000dbb50000b04430000dbbd005bbd00050000003440b000344b00000007e000088e7e880e33d05000776700000060000006000010000000
0070070000b445b0000b445b000dbbbd00000000005000000d0000000b5555d5344b0000000e800000000000088ee50007700000007000000000000010000000
0000000000b44bd0000b445b000000000000000000d00000050000000dbb0000b5555d5000088000000000008085508070700000000000000000000010000000
0000000000d33000000d33bd0000000000000000005000000000000000000000dbb0000000080000000000000058050000570000000000000000000000000000
11611611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11611611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66611666008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66611666008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11611611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11611611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9fffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fff66fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff6555ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f555551f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45555114000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44551144000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f444444f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000008888800000000000000000000000000080888000000eeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000
000188555881000000000000000000000001800008810000000000000e0000000000000000000000000000000000000000000000000000000000000000000000
000188555881000000000000000000000000005050810000000000000e0000000000000000000000000000000000000000000000000000000000000000000000
000188858881000000111000000111d000010000008100000d1110000e0111000000000000000000000000000000000000000000000000000000000000000000
000088858880000000888822c88888d000000805400000000d88888c2e8888000000000000000000000000000000000000000000000000000000000000000000
000022252220000008888822ccddd8500000000000000000058dddcc2e8888800000000000000000000000000000000000000000000000000000000000000000
000022222220000008558822ccd6d8500000002240000000058d6dcc2e8855800000000000000000000000000000000000000000000000000000000000000000
0000ccccccc0000008555552ccd6d850000000c440040000058d6dcc2e5555800000000000000000000000000000000000000000000000000000000000000000
00008ccccc80000008558822ccd6d85000000044c0040000058d6dcc228855800000000000000000000000000000000000000000000000000000000000000000
00008ddddd80000008888822ccddd85000000d0d00000000058dddcc228888800000000000000000000000000000000000000000000000000000000000000000
00018d666d81000000888822c88888d000000d60008100000d88888c228888000000000000000000000000000000000000000000000000000000000000000000
00018ddddd81000000111000000111d000000dddd08100000d111000000111000000000000000000000000000000000000000000000000000000000000000000
00018888888100000000000000000000000000000081000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd55555dd00000000000000000000000d055555dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000004000404040400000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
