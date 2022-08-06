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
		fl=4}
		
		stars={}
		bullets={}
		enemies={}
		e_bullets={}
	
	for i=1,100 do
		local s={
									x=rnd(128),
									y=rnd(128),
									sy=rnd(2)+1,
									cl=7}
		if s.sy<2 then
			s.cl=13
		end							
		add(stars,s)							
	end
		
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
	else
		ship.fl=4
	end
	
	if btnp(4) then
		fire()
	end
	
	
	--update bullets
	for b in all(bullets) do
		b.y+=b.sy
		if b.y<-10 then
			del(bullets,b)
		end
	end
	
	
	
		
end

function _draw()
	cls()
	
	--stars
	for s in all(stars) do
		s.y+=s.sy
		if s.y>128 then
			s.y=-100
			s.x=rnd(128)
		end
		pset(s.x,s.y,s.cl)
	end
	
	--player
	spr(ship.sp,ship.x,ship.y)
	spr(ship.fl,ship.x,ship.y+8)
	
	--bullets
	for b in all(bullets) do
		if t%4<2 then
			b.sp=6
		else
			b.sp=7
		end
		spr(b.sp,b.x,b.y)
	end
	
	
end

function fire()
	local b={
								sp=6,
								x=ship.x,
								y=ship.y-4,
								sx=0,
								sy=-5}
	add(bullets,b)
end


__gfx__
00000000006610000006600000016600000170000009100000099000000990000000000000000000000000000000000000000000000000000000000000000000
000000000166105050166105050166100087a800008a9800009aa900009779000000000000000000000000000000000000000000000000000000000000000000
00700700016611616116611616116610008a9800008980000097a900009a79000000000000000000000000000000000000000000000000000000000000000000
000770000d76d16161d77d16161d67d0008980000008000000977900009aa9000000000000000000000000000000000000000000000000000000000000000000
0007700006766661666c766616666760000800000000080000099000000990000000000000000000000000000000000000000000000000000000000000000000
0070070005c65661665cc56616656c50000000000000000000009000000900000000000000000000000000000000000000000000000000000000000000000000
00000000065566101665566101665560000000000000000000900000000009000000000000000000000000000000000000000000000000000000000000000000
000000000dadd10001daad10001ddad000000000000000000000a000000a00000000000000000000000000000000000000000000000000000000000000000000
