pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--my shmup
--by eduszesz

function _init()
	t=0
	ship={
		sp=2,
		x=64,
		y=64,
		sx=0,
		sy=0,
		fl=4,
		fli=32,
		box={x1=0,y1=0,x2=7,y2=7}}
		
	stars={}
	bullets={}
	enemies={}
	e_bullets={}
	smokes={}
	
	mkstars()
		
end

function _update()
	t+=1
	ship.sp=2
	ship.sx=0
	ship.sy=0
	if btn(0) then
		ship.sp=1
		ship.sx=-3
	end
	if btn(1) then
		ship.sp=3
		ship.sx=3
	end
	if btn(2) then
		ship.sy=-3
	end
	if btn(3) then
		ship.sy=3
	end
	
	ship.x+=ship.sx
	ship.y+=ship.sy
	
	if ship.x<0 then
		ship.x=0
	end
	if ship.x>120 then
		ship.x=120
	end
	
	if ship.y<0 then
		ship.y=0
	end
	if ship.y>120 then
		ship.y=120
	end
	if t%4<2 then
		ship.fl=5
		ship.fli=33
	else
		ship.fl=4
		ship.fli=32
	end
	
	if btnp(4) then
		fire()
		mksmoke()
		sfx(1)
	end
	
	if btnp(5) then
		mkenemy()
	end
	
	
	--update bullets
	for b in all(bullets) do
		b.y+=b.sy
		if b.y<-10 then
			del(bullets,b)
		end
	end
	--update enemies
	for e in all(enemies) do
		e.y+=e.sy
		if e.y>128 then
			e.y=-10
		end
		if e.imm then
			e.age+=1
		end
		if e.age>10 then
			e.age=0
			e.imm=false
		end
	end
	--collision enemies x bullets
	for e in all(enemies) do
		for b in all(bullets) do
			if coll(e,b) then
				if not e.imm then
					e.imm=true
					e.h-=1
				end	
			end
			if e.h<0 then
					del(enemies,e)
				end
		end
	end
	
		
end

function _draw()
	cls()
	--stars
	for s in all(stars) do
		s.y+=s.sy
		if s.y>128 then
			s.y=-10
			s.x=rnd(128)
		end
		pset(s.x,s.y,s.cl)
	end
	
	--player
	spr(ship.sp,ship.x,ship.y)
	if ship.sx!=0 or 
			ship.sy!=0 then
		spr(ship.fl,ship.x,ship.y+8)
	else
		spr(ship.fli,ship.x,ship.y+8)	
	end
	--bullets
	for b in all(bullets) do
		if t%4<2 then
			b.sp=6
		else
			b.sp=7
		end
		spr(b.sp,b.x,b.y)
	end
	
	--enemies
	for e in all(enemies) do
		if t%4==0 then
			e.sp+=1
		end
		if e.sp>31 then
			e.sp=8
		end
		if e.imm then
			if t%6<3 then
				for i=1,15 do
					pal(i,7)
				end
			else
				pal()	
			end	
		end
		spr(e.sp,e.x,e.y)
		pal()
	end
	
	--smokes
	for sk in all(smokes) do
		if sk.age>0 then
			sk.age-=1
		end
		circfill(ship.x+3,ship.y-1,sk.age,sk.cl)
		if sk.age<=0 then
			del(smokes,sk)
		end
	end
	
	
end

function mkstars()
	for i=1,50 do
		local s={
									x=rnd(128),
									y=rnd(128),
									sy=rnd(1)+1,
									cl=flr(rnd(4)+7)}
		if rnd()>0.15 then
			s.cl=7
		end
		if s.sy<1.4 then
			s.cl=13
		end						
		add(stars,s)							
	end
end


function fire()
	local b={
								sp=6,
								x=ship.x,
								y=ship.y-4,
								sx=0,
								sy=-5,
								box={x1=3,y1=0,x2=6,y2=7}}
	add(bullets,b)
end

function mksmoke()
	local sk={
								cl=7,
								age=5}
	add(smokes,sk)
end

--collision
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

function mkenemy()
	local e={
								sp=8,
								x=64,
								y=0,
								sx=0,
								sy=0.5,
								h=5,
								imm=false,
								age=0,
								box={x1=3,y1=0,x2=6,y2=7}}
	add(enemies,e)							
end

__gfx__
0000000000d61000000d60000001d600000170000009100000099000000990000000000000000000000000000000000000000000000000000000000000000000
0000000001d61050501d61050501d6100087a800008a9800009aa90000977900000ee000000ee000000ee000000ee00000333300000000000000000000333300
00700700016611616116611616116610008a9800008980000097a900009a790000ecce0000ecce0000ecce0000ecce0003c33c300033330000333300033cc330
000770000dc6d16161dccd16161d6cd0008980000008000000977900009aa90007eeee700e77eee00ee77ee00eee77e03333333303c33c3003c33c3033333333
0007700006c666616667c66616666c60000800000000080000099000000990000eeeeee00eeeeee00eeeeee00eeeeee083333338333333333333333388333388
0070070005765661665775661665675000000000000000000000900000090000008ccc0000c8cc0000cc8c0000ccc80000999900883333880833338003999930
0000000006556610166556610166556000000000000000000090000000000900000ee000000ee000000ee000000ee00000000000039999300399993000000000
000000000dadd10001daad10001ddad000000000000000000000a000000a00000000000000000000000000000000000000000000000000000300003000000000
0000000b0000000000000000000000000b000b00000000000000000000b000b00808808008088080080880800808808006600660000660000006600006600660
b00000b0b00000bbb00000b0000000bb0b000b00000000000000000000b000b00088880000888800008888000088880000066000000660000006600000066000
0bbbbb000bbbbb000bbbbb0b3bbbbb0000bbb0000b000b0000b000b0000bbb0008b88b800828828008b88b800828828000666600006666000066660000666600
0b707b000b707b000b707b000b333b000bbbbb0000bbb000000bbb0000bbbbb08888888888888888888888888888888806651b600665cb600665cb600665cb60
0bb66b000bb66b000bb66b000bb66b0001e61b000bbbbb0000bbbbb000b16e1080aaaa0880aaaa0880aaaa0880aaaa0806bcbc6006bcb16006bcbc6006b1bc60
00bbbbb000bbbbb000bbbbb000bbbbb00b66bb0001e61b0000b16e1000bb66b080000008080000800800008080000008006bc600006bc600006b1600006bc600
0b00000b0b00000b0b00000b0b00000bbbaaaab00b66bb0000bb66b00baaaabb0800008008000080088008808880088806565660065656600656566006565660
b00000000b00000000b000000b00000bb00000b0bbaaaab00baaaabb0b00000b00000000000000000000000000000000668aaa6606a8aa6006aa8a6066aaa866
00898000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19020000220001a0511701113021100310e0410b0410a051070510406102061020710000000501005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
