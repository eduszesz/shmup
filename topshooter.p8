pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--topshooter
--by eduszesz

function _init()
	t=0
	frate=3
	p={x=64,
				y=64,
				sp=1,
				dx=0,
				dy=0,
				tsk="walk",
				id="player",
				box={x1=2,y1=2,x2=5,y2=5}}
	bullets={}
	smoke={}
	mkrocks()
	enemies={}
	explosions={}
	sparks={}
	corpses={}
end

function _update()
	t+=1
	for e in all(enemies) do
		invencible(e)
	end
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
	if hit((p.x+p.dx),p.y,7,7,0) then
		p.dx=0
	end
  	
	if hit(p.x,(p.y+p.dy),7,7,0) then
		p.dy=0
	end
	
	p.x+=p.dx
	p.y+=p.dy
	updbullets()
	updsmoke()
	upenemies()
	upexplosions()
	upsparks()
	upcorpses()
end

function _draw()
	cls(15)
	map()
	drbullets()
	drcorpses()
	drenemies()
	drexplosions()
	drsparks()
	aniwalk(p)
	drsmoke()
end

function updbullets()
	for b in all(bullets) do
		if t%3==0 then
			--b.sp+=1
			if b.sp>10 then
				--b.sp=9
			end
		end
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
	local e={sp=1,
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
										box={x1=0,y1=0,x2=7,y2=7}}
	add(enemies,e)									
end

function upenemies()
	
	if #enemies==0 and t%30==0 then
		mkenemies()
	end
	
	for e in all(enemies) do
		for b in all(bullets) do
			if coll(e,b) and b.id!="enemy"
				and not e.inv then
				del(bullets,b)
				e.inv=true
				e.h-=1
				for i=1,rnd(5)+5 do
					mrsparks(e.x+4,e.y+4)
				end
				if e.h<0 then
					mkexplosions(e.x+4,e.y+4)
					mkcorpses(e.x,e.y)
					del(enemies,e)
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
			e.tsk=="walk" and abs(e.x-p.x)<3 then
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
			e.tsk=="walk" and abs(e.y-p.y)<3 then
			e.tsk="fire"
			if e.x>p.x then
				e.dx=-1
				e.dy=0	
			end
			if e.x<p.x then
				e.dx=1
				e.dy=0	
			end
		end
		
		if e.tsk=="fire" then
			if t%3==0 and not e.inv then
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
		
		if e.tsk=="walk" then
			e.x+=e.dx
			e.y+=e.dy
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
	if e.dx==1 then e.sp=7 end
	if e.dx==-1 then e.sp=3 end
	if e.dy==1 then e.sp=5 end
	if e.dy==-1 then e.sp=1 end
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
	if p.dx!=0 or p.dy!=0 then
		if t%8<4 and p.tsk=="walk" then
			spr(p.sp+1,p.x,p.y)
		else
			spr(p.sp,p.x,p.y)		
		end
	else
		spr(p.sp,p.x,p.y)
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

function mkcorpses(_x,_y)
	local cr={x=_x,
											y=_y,
											sp=11,
											t=90}
	add(corpses,cr)
end

function upcorpses()
	for cr in all(corpses) do
		cr.t-=1
		if cr.t==60 then
			cr.sp=12
		end
		if cr.t==30 then
			cr.sp=13
		end
		if cr.t<0 then
			mset((cr.x+4)/8,(cr.y+4)/8,14)
			del(corpses,cr)
		end
	end
end

function drcorpses()
	for cr in all(corpses) do
		spr(cr.sp,cr.x,cr.y)
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
0000000000000d00000000500000bbd005d5555b0db44b00b544b000000000000000000000088000000000000800440007006600000066000006000000000000
0070070000000500000000d05d5555b00000b4430b544b00b544b000dbbbd000000000000008e000000000000de3440006076600060066000006600000000000
0007700000dbb50000000050000b04430000b4430b500b0005bbd0003440b000dbbd0000000ef00088efe8800033000000770000007700000000000000000000
0007700000b005b0000dbb50000b04430000dbbd005bbd00050000003440b000344b0000000fe000088efe880e33d05000776700000060000006000000000000
0070070000b445b0000b445b000dbbbd00000000005000000d0000000b5555d5344b0000000e800000000000088ee50007700000007000000000000000000000
0000000000b44bd0000b445b000000000000000000d00000050000000dbb0000b5555d5000088000000000008085508070700000000000000000000000000000
0000000000d33000000d33bd0000000000000000005000000000000000000000dbb0000000080000000000000058050000570000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008800000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008e00000000000000000000000000000088000000880000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000ef00088efe8800000000000000000008ea8000089e8000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000fe000088efe8800000000000000000089e800008ea8000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000e800000000000000000000000000000088000000880000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008800000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000
9fffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fff66fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff6555ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f555551f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45555114000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44551144000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f444444f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000004000404040400000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
