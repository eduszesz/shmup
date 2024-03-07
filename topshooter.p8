pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--topshooter
--by eduszesz

function _init()
	t=0
	p={x=64,y=64,sp=1,dx=0,dy=0}
	bullets={}
end

function _update()
	t+=1
	p.dx=0
	p.dy=0
	if btn(⬆️) then
		p.dy=-1
		p.sp=1
	end
	if btn(⬇️) then
		p.dy=1
		p.sp=5
	end
	if btn(⬅️) then
		p.dx=-1
		p.sp=3
	end
	if btn(➡️) then
		p.dx=1
		p.sp=7
	end
	if btnp(❎) then
		fire()
	end
	p.x+=p.dx
	p.y+=p.dy
	updbullets()
end

function _draw()
	cls(15)
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
end

function updbullets()
	for b in all(bullets) do
		if t%3==0 then
			b.sp+=1
			if b.sp>12 then
				b.sp=9
			end
		end
		b.x+=b.dx
		b.y+=b.dy
	end
end

function drbullets()
	for b in all(bullets) do
		spr(b.sp,b.x,b.y)
	end
end

function fire()
	local b={x=p.x+2,y=p.y,sp=9,dx=0,dy=-6}
	add(bullets,b)
end
__gfx__
0000000000000500000000000000000000000bbd00033d00db33d000000000000000000000099000000990000009900000099000000000000000000000000000
0000000000000d00000000500000bbd005d5555b0db44b00b544b0000000000000000000009aa900009779000097790000977900000000000000000000000000
0070070000000500000000d05d5555b00000b4430b544b00b544b000dbbbd000000000000097a900009a7900009a7900009a7900000000000000000000000000
0007700000dbb50000000050000b04430000b4430b500b0005bbd0003440b000dbbd000000977900009aa900009aa900009aa900000000000000000000000000
0007700000b005b0000dbb50000b04430000dbbd005bbd00050000003440b000344b000000099000000990000009900000099000000000000000000000000000
0070070000b445b0000b445b000dbbbd00000000005000000d0000000b5555d5344b000000009000000900000009000000090000000000000000000000000000
0000000000b44bd0000b445b000000000000000000d00000050000000dbb0000b5555d5000900000000a00000000090000090000000000000000000000000000
0000000000d33000000d33bd0000000000000000005000000000000000000000dbb000000000a000000a0000000a0000000a0000000000000000000000000000
__gff__
0000000000000000000000000000000000000004040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000