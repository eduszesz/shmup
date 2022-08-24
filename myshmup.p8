pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--my shmup
--by eduszesz

function _init()
	t=0
	wtimer=90 --wave timer
	dtimer=30 --ship death timer
	cwave=1
	lwave=7
	debug=""
	state="start"
	score=0
	win=false
	ship={
		sp=2,
		x=64,
		y=100,
		sx=0,
		sy=0,
		fl=4,
		fli=6,
		h=4,
		imm=false,
		age=0,
		sh=true, --shield
		sr=10, --shield radius
		box={x1=0,y1=0,x2=7,y2=7}}
		
	shield={
							x=ship.x,
							y=ship.y,
							t=300,
							box={x1=-6,y1=-6,x2=14,y2=14}}	
	bonus={
						sp=38,
						spi=38,
						x=rnd(100)+10,
						y=-10,
						sy=1,
						age=0,
						t=150,
						imm=false,
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
	firetyp=1
	
	bonustyp={"shield on","1 up!","triple fire","multi fire","mega fire"}
	
	----------------------------
	-- required for fade
	dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
	fadeperc=1
	-----------------------------
	--required for float
	floats={}
	
end

function _update()
	t+=1
	checkfade()
	if state=="start" then
		update_start()
	end
	
	if state=="game" then
		update_game()
	end
	
	if state=="over" then
		update_over()
	end
	
	if state=="wave" then
		update_game()
		wtimer-=1
		if wtimer<=0 then
			wtimer=90
			state="game"
		end
	end
	
	if state=="died" then
		update_game()
		dtimer-=1
		if dtimer<=0 then
			dtimer=30
			fadeout()
			state="over"
		end
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
	
	if state=="wave" then
		draw_game()
		draw_wave()
	end
	
	if state=="died" then
		draw_game()
	end
	mkshake()
	mkflash()
	print(debug,64,64,8)
	--drcollbox(shield)
end

function update_start()
	if btnp(5) then
		fadeout()
		state="wave"
	end
end

function update_game()
	upbonus()
	
	upshield()
	
	upbullets()
	
	upe_bullets()
		
	upenemies()
	
	upplayer()
		
	immortal(ship,45)
	
	dofloats()
end

function update_over()
	if btnp(5) then
		_init()
		fadeout()
		state="start"
	end
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
	
	drbonus()
	
	drfloats()
	
	drui()
end

function draw_over()
		local cl=7
	if t%16<8 then
		cl=5
	end
	drstars()
	cprint("press x/❎ to play again",63,64,1)
	cprint("press x/❎ to play again",63,65,1)
	cprint("press x/❎ to play again",64,64,cl)
	if win then
		sspr(2,81,52,6,15,10,100,20)
	else	
		sspr(1,65,29,14,25,10,80,40)
	end
end

function draw_wave()
	local cl=7
	local txt="wave "..cwave.." of "..lwave
	if t%16<8 then
		cl=5
	end
	cprint(txt,64,64,cl)
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
	local spd=1
	for s in all(stars) do
		if s.y>128 then
			s.y=-10
			s.x=rnd(128)
		end
		if state=="wave" then
			spd=3
			line(s.x,s.y,s.x,s.y+(wtimer/5),s.cl)
		else
			pset(s.x,s.y,s.cl)
		end
		s.y+=s.sy*spd
	end
end

function upbullets()
	for b in all(bullets) do
		b.x+=b.sx
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
			if not ship.imm and not ship.sh then
				shipdmg()
				del(e_bullets,eb)
			end
		end
		if coll(eb,shield) then
			if ship.sh then
				explode(eb.x,eb.y,1,5)
				sfx(2)
				del(e_bullets,eb)
			end
		end
		if eb.y<-10 then
			del(e_bullets,eb)
		end
		if eb.y>128 then
			del(e_bullets,eb)
		end
		if eb.x<-10 then
			del(e_bullets,eb)
		end
		if eb.x>128 then
			del(e_bullets,eb)
		end
	end
end

function dre_bullets()
	for eb in all(e_bullets) do
		if t%8<4 then
			eb.sp=eb.spi
		else
			eb.sp=eb.spi+1
		end
		if eb.spi==36 then
			local x=ship.x
			if eb.xi<x then x=128 end
			if eb.xi>x then x=0 end
			rectfill(eb.xi,eb.yi+1,x,eb.yi+6,8)
			rectfill(eb.xi,eb.yi+2,x,eb.yi+5,14)
			rectfill(eb.xi,eb.yi+3,x,eb.yi+4,7)
		end
		spr(eb.sp,eb.x,eb.y)
	end
end

function upenemies()
	for e in all(enemies) do
		if e.md=="fly" then
			e.y+=(e.tgy-e.y)/4
			if abs(e.y-e.tgy)<1 then
				e.y=e.tgy
				e.md="atk"
			end
		end
		
		if e.md=="atk"	then
			if e.x<0 or e.x>128 then
				del(enemies,e)
			end
			
			if t%30==0 then	
				if rnd()>0.5 then
				--e.imm=true	
				--	ene_fire(e,1,2)
				end
			end
			
			if e.typ==16 then
				e.x=64+50*cos(e.f+t/100)
				e.y=68+50*sin(e.f+t/100)
				if t%60==0 then
					local a=atan2(68-e.y,64-e.x)
					e.imm=true
					ene_fire(e,a,2)
				end
			end
			
			if e.typ==12 then
				if e.x>120 then
					e.sx=-1
					e.y+=8
				end
				if e.x<8 then
					e.sx=1
					e.y+=8
				end
				if t%30==0 and
				rnd()>0.7 then
					e.imm=true	
					ene_fire(e,1,2)
				end
			end
			
			if e.typ==20 or e.typ==22 then
				if e.y==ship.y then
					e.sy=0
					e.typ=22
				end	
				e.t+=1
				if t%30==0 and e.sy==0 then
					e.imm=true	
					ene_fire(e)
				end
				if e.t>90 then
					e.t=0
				end
				if e.y>ship.y and e.t==0 then
					e.sy=-0.5
					e.typ=20
				end
				if e.y<ship.y and e.t==0 then
					e.sy=0.5
					e.typ=20
				end
			end
			
			if e.typ==28 then
				if abs(e.x-ship.x)<3 and
				e.y<ship.y then
					e.sx=0
				end	
				e.t+=1
				if e.sx==0 and	e.y>8 then
					e.sy=3
				end
				if e.t>30 then
					e.t=0
					e.sy=0.25
				end
				if e.x>ship.x and e.t==0 then
					e.sx=-0.5
				end
				if e.x<ship.x and e.t==0 then
					e.sx=0.5
				end
			end
			
			if e.typ!=16 then
				e.x+=e.sx
				e.y+=e.sy
			end
			
			if e.y>128 then
				e.y=0
				e.tgy=15
				e.md="fly"
			end
		end
		immortal(e,10)
		if coll(ship,e) and
		not ship.imm and not ship.sh then
			shipdmg()		
		end
		if coll(e,shield) then
			if ship.sh and not e.imm then
				e.imm=true
				explode(e.x+4,e.y+4,2,5)
				fracture(e.x+4,e.y+4,e.typ)
				sfx(2)
				if e.x>ship.x then
					e.x+=8
				end
				if e.x<ship.x then
					e.x-=8
				end
				explode(e.x,e.y,1,5)
			end
		end
	end
	--collision enemies x bullets
	for e in all(enemies) do
		local ex=e.x+(4*e.wd)
		local ey=e.y+(4*e.ht)
		
		for b in all(bullets) do
			if coll(e,b) then
				if not e.imm then
					local x=e.sx
					local y=e.sy
					if e.typ==28 then
						y=e.sy*5
						x=e.sx*5
					end
					e.imm=true
					e.h-=1
					sfx(2)
					fracture(ex,ey+y/2,e.typ)
					explode(ex+x,ey+y,2,10*e.wd)
					del(bullets,b)
					if e.h<1 then
						explode(ex,ey+y,1,20*e.wd)
						sfx(3)
						shake=3*e.wd
						del(enemies,e)
						score+=1*e.wd
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
		if e.sp>(e.typ+e.ani) then
			e.sp=e.typ
		end
		sprflash(e)
		if e.typ==22 then
			if ship.x>e.x then
				e.flp=true
			else
				e.flp=false
			end
		end
		spr(e.sp,e.x,e.y,e.wd,e.ht,e.flp)
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
			if firetyp>1 then
				local spc=0.25/(firetyp)
				for i=0,firetyp do
					fire(0.375+spc*i,5)
				end					
			else
				fire(0.5,5)
			end	
			mksmoke()
			sfx(1)
			ftimer=frate
		end	
	end
	ftimer-=1
	if btnp(5) and state=="game" then
		mkenemy()
	end
	if ship.h<=0 then
		state="died"
	end
end

function drplayer()
	sprflash(ship)
	if ship.sh then
		local cl={5,6,12}
		local i=1
		if shield.t<90 then
			ship.sr=8
		end
		if shield.t<30 then
			ship.sr=7
			cl={5,14,8}
		end
		if t%8<4 then
			i=2
		end
		if t%16<8 then
			i=3
		end
		circ(ship.x+4,ship.y+4,ship.sr+i,cl[i])
	end
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

function fire(_ang,_spd)
	local sx=sin(_ang)*_spd
	local sy=cos(_ang)*_spd
	local b={
								sp=32,
								x=ship.x,
								y=ship.y-4,
								sx=sx,
								sy=sy,
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
	local tgx=rnd(100)+10
	local tgy=30
	local e={
								sp=typ,
								typ=typ,
								x=tgx,
								y=-10,
								sx=0,
								sy=0.5,
								h=5,
								imm=false,
								age=0,
								wd=1,
								ht=1,
								t=0,
								flp=false,
								ani=3,
								f=rnd(), --phase
								md="fly",
								tgx=tgx,
								tgy=tgy,
								box={x1=0,y1=0,x2=7,y2=7}}
	if e.typ==28  then
		e.wd=2
		e.ht=2
		e.sy=0.25
		e.sx=0.25
		e.box={x1=0,y1=0,x2=15,y2=15}
	end
	if e.typ==20 then
		e.ani=1
	end
	if e.typ==16 then
		e.x=64
	end
	if e.typ==12 then
		e.sx=-1
		e.sy=0
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

function ene_fire(_obj,_ang,_spd)
	local o=_obj
	local sp=34
	if _ang==nil then _ang=1 end
	if _spd==nil then _spd=2 end
	if o.typ==22 then
		sp=36
		_ang=0.25
		_spd=6
		if o.x<ship.x then
			_ang=0.75
		end
	end
	local sx=sin(_ang)*_spd
	local sy=cos(_ang)*_spd
	local x=o.x+(-4+4*o.wd)
	local y=o.y+(-4+4*o.ht)
	local eb={
								sp=sp,
								spi=sp,
								x=x,
								y=y,
								xi=x,
								yi=y,
								sx=sx,
								sy=sy,
								box={x1=2,y1=2,x2=6,y2=6}}
	add(e_bullets,eb)
	sfx(5)
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

function shipdmg()
	ship.imm=true
	shake=10
	flash=10
	fracture(ship.x+4,ship.y+4,"ship")
	explode(ship.x+4,ship.y+4,2,10)
	ship.h-=1
end

function upshield()
	shield.x=ship.x
	shield.y=ship.y
	if ship.sh then
		shield.t-=1
		if shield.t<=0 then
			ship.sh=false
		end
	end
end

function upbonus()
	immortal(bonus,10)
	bonus.y+=bonus.sy
	bonus.t-=1
	if bonus.y>128 then
		bonus.y=-10
	end
	if coll(ship,bonus) then
		if not bonus.imm then
			local txt=rnd(bonustyp)
			explode(bonus.x+4,bonus.y+4,2,20)
			bonus.imm=true
			bonus.y=-10
			bonus.x=rnd(100)+10
			sfx(4)
			bonus.t=150
			if txt=="shield on" then
				ship.sh=true
				shield.t=300
			end	
			if txt=="1 up!" then
				if ship.h<4 then
					ship.h+=1
				else	
					txt="triple fire"
				end
			end	
			if txt=="triple fire" then
				firetyp=2
			end	
			if txt=="multi fire" then
				firetyp=4
			end	
			if txt=="mega fire" then
				firetyp=6
			end
			addfloat(txt, ship.x+4, ship.y,7)
		end
	end
	if bonus.t<0 then
				firetyp=1
				bonus.t=0
	end
end

function drbonus()
	
	if t%6==0 then
			bonus.sp+=1
		end
		if bonus.sp>(bonus.spi+3) then
			bonus.sp=bonus.spi
		end
	
	spr(bonus.sp,bonus.x,bonus.y)
end

function drcollbox(_o)
	--bebug collisions
	local xi=_o.x+_o.box.x1
	local xf=_o.x+_o.box.x2
	local yi=_o.y+_o.box.y1
	local yf=_o.y+_o.box.y2
	rect(xi,yi,xf,yf,7)
end

--functions from
--porklike tutorial
--by lazydevs

function addfloat(_txt,_x,_y,_c)
 add(floats,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function dofloats()
 for f in all(floats) do
  f.y+=(f.ty-f.y)/10
  f.t+=1
  if f.t>60 then
   del(floats,f)
  end
 end
end

function drfloats()
	for f in all(floats) do
		cprint(f.txt,f.x,f.y,f.c)
	end
end

function dofade()
 local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
 for j=1,15 do
  col = j
  kmax=flr((p+(j*1.46))/22)
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end

function checkfade()
 if fadeperc>0 then
  fadeperc=max(fadeperc-0.04,0)
  dofade()
 end
end

function wait(_wait)
 repeat
  _wait-=1
  flip()
 until _wait<0
end

function fadeout(spd,_wait)
 if (spd==nil) spd=0.04
 if (_wait==nil) _wait=0
 repeat
  fadeperc=min(fadeperc+spd,1)
  dofade()
  flip()
 until fadeperc==1
 wait(_wait)
end
-- ---------------
__gfx__
0000000000d61000000d60000001d600000170000009100000098000000800000000000000000000000000000000000000000000000000000000000000000000
0000000001d61050501d61050501d6100087a800008a98000008000000008000000ee000000ee000000ee000000ee00000333300000000000000000000333300
00700700016611616116611616116610008a980000898000000000000000000000ecce0000ecce0000ecce0000ecce0003c33c300033330000333300033cc330
000770000dc6d16161dccd16161d6cd00089800000080000000000000000000007eeee700e77eee00ee77ee00eee77e03333333303c33c3003c33c3033333333
0007700006c666616667c66616666c60000800000000080000000000000000000eeeeee00eeeeee00eeeeee00eeeeee083333338333333333333333388333388
0070070005765661665775661665675000000000000000000000000000000000008ccc0000c8cc0000cc8c0000ccc80000999900883333880833338003999930
0000000006556610166556610166556000000000000000000000000000000000000ee000000ee000000ee000000ee00000000000039999300399993000000000
000000000dadd10001daad10001ddad0000000000000000000000000000000000000000000000000000000000000000000000000000000000300003000000000
0000000b00000000000000000000000003bbbb3003bbbb30000333300003333008088080080880800808808008088080001122cccc221100001122cccc221100
b00000b0b00000bbb00000b0000000bb32bbbb2337bbbb73bbb77223bbb2277300888800008888000088880000888800001122cccc221100011122cccc221110
0bbbbb000bbbbb000bbbbb0b3bbbbb0032b11b2337b11b73bbbbbbbbbbbbbbbb08b88b800828828008b88b8008288280111ccc5555ccc111111ccc5555ccc111
0b707b000b707b000b707b000b333b0037b11b7332b11b235d1166bb56611dbb88888888888888888888888888888888111cc57ee75cc11111ccc522225ccc11
0bb66b000bb66b000bb66b000bb66b0037b11b7332b11b235d1166bb56611dbb80aaaa0880aaaa0880aaaa0880aaaa081ccccc7887ccccc11ccccc2222ccccc1
00bbbbb000bbbbb000bbbbb000bbbbb00bb11bb00bb11bb0bbbbbbbbbbbbbbbb800000080800008008000080800000081ccccc7887ccccc11ccccc2222ccccc1
0b00000b0b00000b0b00000b0b00000b0bb11bb00bb11bb0bbb77223bbb22773080000800800008008800880888008881ccccc6006ccccc11ccccc6006ccccc1
b00000000b00000000b000000b00000b0bb55bb00bb55bb00003333000033330000000000000000000000000000000001ccc09600690ccc11ccc09600690ccc1
00099000000990000000000000000000088888800888888000aaaa000000a00000aaaa00000a000000000000000000001ccc09000990ccc11ccc09900090ccc1
009aa9000097790000000000000ff000eeeeeeee8888888809aaaaa000d1a0000aa1cc90000a1d0000000000000000001cc0090000000cc11cc0000000900cc1
0097a900009a7900000bb00000fbbf0077777777eeeeeeee9aaaaaa700c170007a1ca1c900071c0000000000000000001cc0099000000cc11cc0000009900cc1
00977900009aa90000b77b000fb66bf077777777777777779aaaaaaa00d5a000aaaaa1c9000a5d00000000000000000011c0000000000c1111c0000000000c11
000990000009900000b7fb000fb66bf077777777777777774aaaaaaa00c0a000aaaa1ca4000a0c00000000000000000011c0000000000c1101cc00000000cc11
0000900000090000000bb00000fbbf0077777777eeeeeeee4aaaaaaa0000a000aaaaaaa4000a0000000000000000000001cc00000000cc10011c00000000c110
009000000000090000000000000ff000eeeeeeee8888888804aaaaa000c1a0000aaa1c40000a1c000000000000000000011c00000000c110001ccc0000ccc100
0000a000000a000000000000000000000888888008888880004aaa000000a00000aaa400000a00000000000000000000001ccc0000ccc1000001110000111000
00000000007007000070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800800078778700767767000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880788888877666666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
088e8880788e88877666666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0088e8000788e8700766667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000007887000076670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000770000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000088888000180018001888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01800000088008000180018001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01808000088008000188018001888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01801800088888000180808001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01801800088018000180808001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000088018000180808001888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000018008000188880001888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01800800018008000180000001800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01800800018008000188880001888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01800800018008000180000001801800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01800800018808000180000001801800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000001880000188880001801800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005b0b0000bbb00005b00b000000000005b000b0005b00000bb00b00000000000000000000000000000000000000000000000000000000000000000000000000
005b0b0005b00b0005b00b000000000005b000b0005b00000bb00b00000000000000000000000000000000000000000000000000000000000000000000000000
005b0b0005b00b0005b00b000000000005b0b0b0005b00000bbb0b00000000000000000000000000000000000000000000000000000000000000000000000000
005bb00005b00b0005b00b000000000005b0b0b0005b00000bb0bb00000000000000000000000000000000000000000000000000000000000000000000000000
0005b00005b00b0005b00b000000000005bbb0b0005b00000bb05b00000000000000000000000000000000000000000000000000000000000000000000000000
0005b00000bbb000005bbb0000000000005bbb00005b00000bb05b00000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19020000220001a0511701113021100310e0410b0410a051070510406102061020710000000501005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00020000106101a610126000c60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c80400002d636286162461622616206161b616196161661614616116160e6160e6160000500004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
100500003f0163a016360162a0163b010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000016007100070c0370903705037040370303702037010370003700707007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707
