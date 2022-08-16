pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--my shmup
--by eduszesz

function _init()
	t=0
	state="start"
	score=0
	ship={
		sp=2,
		x=64,
		y=64,
		sx=0,
		sy=0,
		fl=4,
		fli=6,
		h=4,
		imm=false,
		age=0,
		box={x1=0,y1=0,x2=7,y2=7}}
		
	stars={}
	bullets={}
	enemies={}
	e_types={8,12,16,20,24,28}
	e_bullets={}
	smokes={}
	explosions={}
	debris={}
	mkstars()
	
	shake=0
	flash=0
	ftimer=0
	frate=5
			
end

function _update()
	t+=1
	
	if state=="start" then
		update_start()
	end
	
	if state=="game" then
		update_game()
	end
	
	if state=="over" then
		update_over()
	end
	

		
end

function _draw()
	cls()
	
	if state=="start" then
		draw_start()
	end
	
	if state=="game" then
		draw_game()
	end
	
	if state=="over" then
		draw_over()
	end
	
	mkshake()
	mkflash()
	
end

function update_start()
	if btnp(5) then
		state="game"
	end
end

function update_game()
	upbullets()
	
	upe_bullets()
		
	upenemies()
	
	upplayer()
		
	immortal(ship,20)
end

function update_over()

end

function draw_start()
	local cl=7
	if t%16<8 then
		cl=5
	end
	drstars()
	cprint("press x/❎ to start",63,64,1)
	cprint("press x/❎ to start",63,65,1)
	cprint("press x/❎ to start",64,64,cl)
end

function draw_game()
	drstars()
		
	drbullets()
	
	dre_bullets()
	
	drenemies()
	
	drplayer()
	
	--smokes
	drsmokes(ship.x,ship.y)
	--explosions
	mkexplosions()
	--debris
	mkdebris()
	
	drui()
end

function draw_over()

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

function drstars()
	for s in all(stars) do
		s.y+=s.sy
		if s.y>128 then
			s.y=-10
			s.x=rnd(128)
		end
		pset(s.x,s.y,s.cl)
	end
end

function upbullets()
	for b in all(bullets) do
		b.y+=b.sy
		if b.y<-10 then
			del(bullets,b)
		end
	end
end

function drbullets()
	for b in all(bullets) do
		if t%4<2 then
			b.sp=32
		else
			b.sp=33
		end
		spr(b.sp,b.x,b.y)
	end
end

function upe_bullets()
	for eb in all(e_bullets) do
		eb.x+=eb.sx
		eb.y+=eb.sy
		if coll(eb,ship) then
			if not ship.imm then
				ship.imm=true
				shake=10
				flash=10
				fracture(ship.x+4,ship.y+4,"ship")
				explode(ship.x+4,ship.y+4,2,10)
				ship.h-=1
				del(e_bullets,eb)
			end
		end
		if eb.y<-10 then
			del(e_bullets,eb)
		end
	end
end

function dre_bullets()
	for eb in all(e_bullets) do
		if t%8<4 then
			eb.sp=34
		else
			eb.sp=35
		end
		spr(eb.sp,eb.x,eb.y)
	end
end

function upenemies()
	for e in all(enemies) do
		if t%30==0 then	
			if rnd()>0.5 then
				e.imm=true
				ene_fire(e.x+(-4+4*e.wd),e.y+(4*e.ht),rnd(),2)
			end
		end	
		e.y+=e.sy
		if e.y>128 then
			e.y=-10
		end
		immortal(e,10)
	end
	--collision enemies x bullets
	for e in all(enemies) do
		local ex=e.x+(4*e.wd)
		local ey=e.y+(4*e.ht)
		
		for b in all(bullets) do
			if coll(e,b) then
				if not e.imm then
					e.imm=true
					e.h-=1
					sfx(2)
					fracture(ex,ey,e.typ)
					explode(ex,ey,2,10*e.wd)
					del(bullets,b)
					if e.h<1 then
						explode(ex,ey,1,20*e.wd)
						sfx(3)
						shake=5*e.wd
						del(enemies,e)
						score+=1
					end
				end
			end
		end
	end
end

function drenemies()
	for e in all(enemies) do
		if t%(6*e.wd)==0 then
			e.sp+=e.wd
		end
		if e.sp>(e.typ+3) then
			e.sp=e.typ
		end
		sprflash(e)
		spr(e.sp,e.x,e.y,e.wd,e.ht)
		pal()
	end
end

function upplayer()
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
	
	if ship.y<9 then
		ship.y=9
	end
	if ship.y>118 then
		ship.y=118
	end
	if t%4<2 then
		ship.fl=5
		ship.fli=7
	else
		ship.fl=4
		ship.fli=6
	end
	
	if btn(4) then
		if ftimer<=0 then
			fire()
			mksmoke()
			sfx(1)
			ftimer=frate
		end	
	end
	ftimer-=1
	if btnp(5) then
		mkenemy()
	end
end

function drplayer()
	sprflash(ship)
	spr(ship.sp,ship.x,ship.y)
	pal()
	if ship.sx!=0 or 
			ship.sy!=0 then
		spr(ship.fl,ship.x,ship.y+8)
	else
		spr(ship.fli,ship.x,ship.y+8)	
	end
end

function drui()
	rectfill(0,0,127,8,0)
	--rect(0,0,127,8,6)
	for i=1,4 do
		spr(50,9*i,1)
	end
	for i=1,ship.h do
		spr(48,9*i,1)
	end
	if score==0 then
		print("score:"..score,54,2,7)
	else
		print("score:"..score.."00",54,2,7)
	end
end

function fire()
	local b={
								sp=32,
								x=ship.x,
								y=ship.y-4,
								sx=0,
								sy=-5,
								box={x1=2,y1=0,x2=6,y2=7}}
	add(bullets,b)
end

function mksmoke()
	local sk={
								cl=7,
								age=5}
	add(smokes,sk)
end

function drsmokes(_x,_y)
	for sk in all(smokes) do
		if sk.age>0 then
			sk.age-=1
		end
		circfill(_x+3,_y-1,sk.age,sk.cl)
		if sk.age<=0 then
			del(smokes,sk)
		end
	end
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
	local typ=rnd(e_types)
	local e={
								sp=typ,
								typ=typ,
								x=rnd(100)+10,
								y=0,
								sx=0,
								sy=0.5,
								h=5,
								imm=false,
								age=0,
								wd=1,
								ht=1,
								box={x1=0,y1=0,x2=7,y2=7}}
	if e.typ==28  then
		e.wd=2
		e.ht=2
		e.sy=0.25
		e.box={x1=0,y1=0,x2=15,y2=15}
	end
	
	
	add(enemies,e)							
end

function explode(_x,_y,_typ,_age)
	if _typ==nil then _typ=1 end
	if _age==nil then _age=20 end
	local ex={
									x=_x,
									y=_y,
									typ=_typ,
									r=0,
									age=_age,
									cl={7,10,9,8,5,5},
									cli=0}
	add(explosions,ex)								
end

function mkexplosions()
	for ex in all(explosions) do
		ex.r+=2
		ex.cli+=1
		if ex.cli>5 then ex.cli=0 end	
		circ(ex.x,ex.y,ex.r,ex.cl[ex.cli])
		if ex.typ==1 then
			circfill(ex.x,ex.y,ex.r*0.5,9)
			circfill(ex.x,ex.y,ex.r*0.25,10)
			circfill(ex.x,ex.y,50/ex.r,7)
		end	
		if ex.r>ex.age then
			del(explosions,ex)
		end
	end
end

function fracture(_x,_y,_typ)
	for i=1,8 do
		local d={
								x=_x,
								y=_y,
								sx=rnd(4)-2,
								sy=rnd(4)-2,
								typ=_typ,
								age=10}
		add(debris,d)
	end						
end

function mkdebris()
	for d in all(debris) do
		local cl=11
		if d.typ==8 then cl=14 end
		if d.typ==12 then cl=3 end
		if d.typ==24 then cl=8 end
		if d.typ==28 then cl=12 end
		if d.typ=="ship" then cl=6 end
		d.x+=d.sx
		d.y+=d.sy
		d.age-=1
		pset(d.x,d.y,cl)
		if d.age<0 then
			del(debris,d)
		end
	end
end

function ene_fire(_x,_y,_ang,_spd)
	local sx=sin(_ang)*_spd
	local sy=cos(_ang)*_spd
	local eb={
								sp=32,
								x=_x,
								y=_y,
								sx=sx,
								sy=sy,
								box={x1=2,y1=2,x2=6,y2=6}}
	add(e_bullets,eb)
end

function immortal(_o,_t)
	 --o=obj 
	if _o.imm then
			_o.age+=1
	end
	if _o.age>_t then
		_o.age=0
		_o.imm=false
	end
end

function sprflash(_o)
	if _o.imm then
		if t%6<3 then
			for i=2,15 do
				pal(i,7)
			end
		else
			pal()	
		end	
	end
end

function mkshake()
	local s=rnd(shake)-(shake/2)
	if shake!=0 then
		shake-=1
		camera(s,0)
	end
	if shake<=0 then
		shake=0
		camera(0,0)
	end
end

function mkflash()
	if flash!=0 then
		local r=90-flash*2
		flash-=1
		if t%4<2 then 
			cls(2)
		end
		for i=1,10 do	
			circ(64,64,r+i,8)
		end
	end
	if flash<0 then
		flash=0
		cls()
	end
end

function cprint(txt,x,y,c)
 print(txt,x-#txt*2,y,c)
end
__gfx__
0000000000d61000000d60000001d600000170000009100000098000000800000000000000000000000000000000000000000000000000000000000000000000
0000000001d61050501d61050501d6100087a800008a98000008000000008000000ee000000ee000000ee000000ee00000333300000000000000000000333300
00700700016611616116611616116610008a980000898000000000000000000000ecce0000ecce0000ecce0000ecce0003c33c300033330000333300033cc330
000770000dc6d16161dccd16161d6cd00089800000080000000000000000000007eeee700e77eee00ee77ee00eee77e03333333303c33c3003c33c3033333333
0007700006c666616667c66616666c60000800000000080000000000000000000eeeeee00eeeeee00eeeeee00eeeeee083333338333333333333333388333388
0070070005765661665775661665675000000000000000000000000000000000008ccc0000c8cc0000cc8c0000ccc80000999900883333880833338003999930
0000000006556610166556610166556000000000000000000000000000000000000ee000000ee000000ee000000ee00000000000039999300399993000000000
000000000dadd10001daad10001ddad0000000000000000000000000000000000000000000000000000000000000000000000000000000000300003000000000
0000000b0000000000000000000000000b000b00000000000000000000b000b008088080080880800808808008088080001122cccc221100001122cccc221100
b00000b0b00000bbb00000b0000000bb0b000b00000000000000000000b000b000888800008888000088880000888800001122cccc221100011122cccc221110
0bbbbb000bbbbb000bbbbb0b3bbbbb0000bbb0000b000b0000b000b0000bbb0008b88b800828828008b88b8008288280111ccc5555ccc111111ccc5555ccc111
0b707b000b707b000b707b000b333b000bbbbb0000bbb000000bbb0000bbbbb088888888888888888888888888888888111cc57ee75cc11111ccc522225ccc11
0bb66b000bb66b000bb66b000bb66b0001e61b000bbbbb0000bbbbb000b16e1080aaaa0880aaaa0880aaaa0880aaaa081ccccc7887ccccc11ccccc2222ccccc1
00bbbbb000bbbbb000bbbbb000bbbbb00b66bb0001e61b0000b16e1000bb66b0800000080800008008000080800000081ccccc7887ccccc11ccccc2222ccccc1
0b00000b0b00000b0b00000b0b00000bbbaaaab00b66bb0000bb66b00baaaabb080000800800008008800880888008881ccccc6006ccccc11ccccc6006ccccc1
b00000000b00000000b000000b00000bb00000b0bbaaaab00baaaabb0b00000b000000000000000000000000000000001ccc09600690ccc11ccc09600690ccc1
0009900000099000000000000000000000000000000000000000000000000000000000000000000000000000000000001ccc09000990ccc11ccc09900090ccc1
009aa9000097790000000000000ff00000000000000000000000000000000000000000000000000000000000000000001cc0090000000cc11cc0000000900cc1
0097a900009a7900000bb00000fbbf0000000000000000000000000000000000000000000000000000000000000000001cc0099000000cc11cc0000009900cc1
00977900009aa90000b77b000fb66bf0000000000000000000000000000000000000000000000000000000000000000011c0000000000c1111c0000000000c11
000990000009900000b7fb000fb66bf0000000000000000000000000000000000000000000000000000000000000000011c0000000000c1101cc00000000cc11
0000900000090000000bb00000fbbf00000000000000000000000000000000000000000000000000000000000000000001cc00000000cc10011c00000000c110
009000000000090000000000000ff0000000000000000000000000000000000000000000000000000000000000000000011c00000000c110001ccc0000ccc100
0000a000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ccc0000ccc1000001110000111000
00000000007007000070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800800078778700767767000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880788888877666666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
088e8880788e88877666666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0088e8000788e8700766667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000007887000076670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000770000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06600660000660000006600006600660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000660000006600000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600006666000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0665c6600665c6600665c6600665c660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
066cb660066cb660066cb660066cb660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600006666000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06566560066556600656656006655660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
068aaa6006a8aa6006aa8a6006aaa860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19020000220001a0511701113021100310e0410b0410a051070510406102061020710000000501005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00020000106101a610126000c60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c80400002d636286162461622616206161b616196161661614616116160e6160e6160000500004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
