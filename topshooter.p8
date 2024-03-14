pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--topshooter
--by eduszesz

function _init()
	t=0
	p={x=64,y=64,sp=1,dx=0,dy=0}
	bullets={}
	smoke={}
	mkrocks()
end

function _update()
	t+=1
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
	if btnp(❎) then
		fire()
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
end

function _draw()
	cls(15)
	map()
	if p.dx!=0 or p.dy!=0 then
		if t%8<4 then
			spr(p.sp+1,p.x,p.y)
		else
			spr(p.sp,p.x,p.y)		
		end
	else
		spr(p.sp,p.x,p.y)
	end
	drbullets()
	drsmoke()
	
end

function updbullets()
	for b in all(bullets) do
		if t%3==0 then
			b.sp+=1
			if b.sp>10 then
				b.sp=9
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

function fire()
	local dx,dy=0,-1
	local ox,oy=2,-4
	local sox,soy=5,0
	if p.sp==5 or p.sp==6 then
		dx,dy=0,1
		ox,oy=-2,4
		sox,soy=2,8
	end
	if p.sp==3 or p.sp==4 then
		dx,dy=-1,0
		ox,oy=-2,-2
		sox,soy=0,2
	end
	if p.sp==7 or p.sp==8 then
		dx,dy=1,0
		ox,oy=2,1
		sox,soy=8,5
	end
	local b={x=p.x+ox,
										y=p.y+oy,
										sp=9,
										dx=dx*6,
										dy=dy*6
										}
	add(bullets,b)
	mksmoke(sox,soy)
end

function mksmoke(_ox,_oy)
	local ox,oy=_ox,_oy
	local s={r=3,x=p.x+ox,y=p.y+oy}
	add(smoke,s)
end

function mkrocks()
	for i=1,11 do
		mset(rnd(16),rnd(16),48)
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
0000000000000500000000000000000000000bbd00033d00db33d000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000d00000000500000bbd005d5555b0db44b00b544b000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000500000000d05d5555b00000b4430b544b00b544b000dbbbd0000000000000088000000888000000000000000000000000000000000000000000
0007700000dbb50000000050000b04430000b4430b500b0005bbd0003440b000dbbd0000008ae800008ee9800000000000000000000000000000000000000000
0007700000b005b0000dbb50000b04430000dbbd005bbd00050000003440b000344b0000008ee800008aee800000000000000000000000000000000000000000
0070070000b445b0000b445b000dbbbd00000000005000000d0000000b5555d5344b0000008e9800000888000000000000000000000000000000000000000000
0000000000b44bd0000b445b000000000000000000d00000050000000dbb0000b5555d5000088000000000000000000000000000000000000000000000000000
0000000000d33000000d33bd0000000000000000005000000000000000000000dbb0000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088000000880000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008ea8000089e8000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000089e800008ea8000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088000000880000000000000000000
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
__gff__
0000000000000000000000000000000000000004000404040404040000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
