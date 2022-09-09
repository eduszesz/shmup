pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--simple shooter-bullet barrage
--by eduszesz

function _init()
	cartdata("ss-bulletbarrage")
	highscore=dget(0)
	initialize()
	newhighscore=false
end

function initialize()
	ver="v1.0"
	music(1)
	t=0
	newhighscore=false
	wtimer=90 --wave timer
	dtimer=60 --ship death timer
	bdtimer=150 --boss death timer
	cwave=1
	lwave=9
	debug=""
	state="start"
	score=0
	win=false
	give=true
	ship={
		sp=2,
		x=64,
		y=80,
		sx=0,
		sy=0,
		fl=4,
		fli=6,
		flw=51,
		h=4,
		imm=false,
		age=0,
		t=45,
		sh=false, --shield
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
						sy=0,
						age=0,
						t=0,
						typ=nil,
						imm=false,
						use=false,
						box={x1=0,y1=0,x2=7,y2=7}}
	drone={
						sp=42,
						x=64,
						y=140,
						sy=0,
						age=0,
						t=0,
						typ=nil,
						imm=false,
						use=false}
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
	
	bonustyp={"drone strike","drone strike","shield on","1 up!","triple shooting","1 up!","bullet barrage","multi shooting","1 up!","shield on","1 up!","1 up!"}
	
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
		if wtimer==85 and cwave<10 then
			sfx(9)
		end
		e_bullets={}
		update_game()
		if cwave==9 and wtimer==1 then
			music(7,300)
		end
		wtimer-=1
		if wtimer<=0 then
			wtimer=90
			if cwave>9 and
			win then
				fadeout()
				state="over"
			else
				state="game"
			end
		end
	end
	
	if state=="died" then
		music(-1,300)
		update_game()
		dtimer-=1
		if dtimer<=0 then
			dtimer=60
			sfx(6)
			fadeout()
			state="over"
		end
	end
	if state=="bdied" then
		local e=enemies[1]
		e_bullets={}
		update_game()
		bdtimer-=1
		if bdtimer==60 then
			sfx(12)
			sfx(11)
			explode(e.x+16,e.y+16,1,40)
			fracture(e.x+16,e.y+16,e.typ)
		end

		if bdtimer<=0 then
			bdtimer=150
			win=true
			music(13,3000)
			state="wave"
			enemies={}
			cwave=10
			--fadeout()
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
	if state=="bdied" then
		draw_game()
	end
	mkshake()
	mkflash()
	print(debug,110,1,7)
	
	--drcollbox(e)
	
end

function update_start()
	local spc=0.25/(6)
	if t%7==0 then
		for i=0,6 do
			fire(0.375+spc*i,5)
		end
		mksmoke()
	end
	
	upbullets()
	
	
	if btnp(5) then
		music(-1)
		sfx(7)
		fadeout()
		bullets={}
		state="wave"
	end
end

function update_game()
	upbonus()
	
	upshield()
	
	upbullets()
	
	if state=="game" then
		upe_bullets()
	end
	if state=="game" or state=="bdied" then	
		upenemies()
	end	
	
	upplayer()
		
	immortal(ship,ship.t)
	
	dofloats()
	
	checkwave()
	if state=="wave" then
		mkwave()
	end
	
	updrone()
	
end

function update_over()
	if score>highscore then
    highscore=score
    newhighscore=true
    dset(0,score)
 end
	if btnp(5) then
		initialize()
		fadeout()
		state="start"
	end
end

function draw_start()
	drbullets()
	drsmokes(ship.x,ship.y)
	local cl=7
	if t%16<8 then
		cl=5
	end
	drstars()
	drlogo()
	cprint("press x/❎ to start",63,96,1)
	cprint("press x/❎ to start",63,97,1)
	cprint("press x/❎ to start",64,96,cl)
	if highscore>0 then
		cprint("high score:"..highscore.."00",63,110,1)
		cprint("high score:"..highscore.."00",64,111,9)
	end
	print(ver,100,120,1)
	print("by eduardo szesz",0,120,1)
end

function draw_game()
	drstars()
		
	drbullets()
	if state=="game" then
		dre_bullets()
	end
	drenemies()
	
	drplayer()
	
	drdrone()
	
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
	if score==0 then
		cprint("score:"..score, 64,80,11)	
	else
		if newhighscore then
			cprint("new high score:"..score.."00", 64,80,11)
		else
			cprint("score:"..score.."00", 64,80,11)
		end
	end
	if cwave<10 then
		cprint("last enemy zone:"..cwave,64,96,9)
	end
	if win then
		sspr(2,81,52,6,15,10,100,20)
	else	
		sspr(1,65,29,14,25,10,80,40)
	end
end

function draw_wave()
	local cl=7
	local txt="warping to the enemy zone"
	local txt1=cwave.." of "..lwave
	if t%16<8 then
		cl=5
	end
	if not win then
		cprint(txt,63,65,1)
		cprint(txt,64,64,cl)
		cprint(txt1,63,73,1)
		cprint(txt1,64,72,cl)
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
		if b.y<0 then
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
	local picke=rnd(enemies)
	if state=="game" then
		if t%30==0 and picke.md=="wait" then
			picke.md="fly"
		end
	end
	
	for e in all(enemies) do	
		if e.md=="fly" then
			e.y+=(e.tgy-e.y)/4
			if e.typ==64 then
				shake=20
				sfx(10)
				if abs(e.y-e.tgy)<1 then
					e.y=e.tgy
					e.md="atk"
					e.bmd="atk1"
				end
			end
			if abs(e.y-e.tgy)<1 then
				e.y=e.tgy
				if e.typ==16 then
					sfx(5)
					explode(e.x+4,e.y+4,1,5)
				end
				e.md="atk"
			end
		end
		
		if e.md=="atk"	then
			if e.x<0 or e.x>124 then
				del(enemies,e)
			end
			
			if t%60==0 and e.typ==8 then	
				if rnd()>0.85 then
					e.imm=true	
					ene_fire(e,1,2)
				end
			end
			
			if e.typ==12 then
				if e.x>120 then
					e.sx=-1
					e.y+=16
				end
				if e.x<8 then
					e.sx=1
					e.y+=16
				end
				if t%30==0 and
				rnd()>0.7 then
					e.imm=true	
					ene_fire(e,1,2)
				end
			end
			
			if e.typ==16 then
				e.x=64+40*cos(e.f+t/120)
				e.y=68+40*sin(e.f+t/120)
				if t%60==0 then
					local a=atan2(68-e.y,64-e.x)
					e.imm=true
					ene_fire(e,a,2)
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
					e.sy=-1
					e.typ=20
				end
				if e.y<ship.y and e.t==0 then
					e.sy=1
					e.typ=20
				end
			end
			
			if e.typ==24 then
				e.x=e.tgx+8*cos(e.f+t/100)
				e.y=e.tgy+8*sin(e.f+t/100)
				if t%90==0 then
					local spc=0.25/(3)
					for i=0,3 do
						ene_fire(e,0.375+spc*i,-3)
					end
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
			
			if e.typ==8 or e.typ==12 or
			 e.typ==20 or e.typ==22 or
			 e.typ==28 then
				e.x+=e.sx
				e.y+=e.sy
			end
			
			if e.bmd=="atk1" then
				e.sx=0
				e.bt+=1
				if e.bt>300 then
					e.bmd="atk2"
					e.bt=0
					e.sx=1
				end
				if e.y>96 then
					e.sy=-1
				end
				if e.y<12 then
					e.sy=0.25
				end
				e.x+=e.sx
				e.y+=e.sy
				if t%20==0 then
					local spc=0.25/2
					for i=0,2 do
						ene_fire(e,0.375+spc*i,-3)
					end
				end
			end
			
			if e.bmd=="atk2" then
				e.sy=0
				if e.x>96 then
					e.sx=-1
					e.y+=10
				end
				if e.x<8 then
					e.sx=1
					e.y+=16
				end
				e.x+=e.sx
				e.y+=e.sy
				if t%20==0 then	
					ene_fire(e,1,2)
				end
				if e.y>96 and abs(e.x-64)<5 then
					sfx(5)
					explode(e.x+16,e.y+16,1,15)
					e.bmd="atk3"
				end
			end
			
			if e.bmd=="atk3" then
				e.x=50+40*cos(e.f+t/100)
				e.y=50+40*sin(e.f+t/100)
				local dy=-3
				if e.y>ship.y then
					dy=3
				end
				if t%90==0 then
					local spc=1/9
					for i=0,9 do
						ene_fire(e,0.375+spc*i,dy)
					end
				end
				e.bt+=1
				if e.bt>300 then
					e.bmd="atk4"
					e.bt=0
					e.sy=-1
					e.sx=0
				end
			end
			
			if e.bmd=="atk4" then
				if abs(e.y-ship.y)<3 then
					e.sy=0
				end	
				e.t+=1
				if t%30==0 and e.sy==0 then	
					ene_fire(e)
				end
				if e.t>90 then
					e.t=0
				end
				if e.y>ship.y and e.t==0 then
					e.sy=-1
				end
				if e.y<ship.y and e.t==0 then
					e.sy=1
				end
				e.x+=e.sx
				e.y+=e.sy
				e.bt+=1
				if e.bt>450 then
					e.bmd="atk5"
					e.bt=0
					e.sy=0.5
					e.sx=1
				end
			end
			
			if e.bmd=="atk5" then
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
					e.sy=0.5
				end
				if e.x>ship.x and e.t==0 then
					e.sx=-1
				end
				if e.x<ship.x and e.t==0 then
					e.sx=1
				end
				if e.x<8 then e.sx=1 end
				if e.x>96 then e.sx=-1 end
				e.x+=e.sx
				e.y+=e.sy
				e.bt+=1
				if e.y>96 then e.sy=-3 end
				if e.y<15 then e.sy=0.5 end
				if e.bt>300 then
					e.bmd="atk1"
					e.bt=0
					e.sy=0.5
					e.sx=0
				end
			end
			
			if e.y>128 then
				e.y=-15
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
				if e.x>ship.x and e.typ!=64 then
					e.x+=10
				end
				if e.x<ship.x and e.typ!=64 then
					e.x-=10
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
			if coll(e,b) and e.md=="atk" then
				if not e.imm then
					local x=e.sx
					local y=e.sy
					if e.typ==28 then
						y=e.sy*5
						x=e.sx*5
					end
					e.imm=true
					e.h-=b.dmg
					sfx(2)
					fracture(ex,ey+y/2,e.typ)
					explode(ex+x,ey+y,2,10*e.wd)
					del(bullets,b)
					if e.typ==64 then
						score+=1
					end
					if e.h<1 and e.typ<64 then
						explode(ex,ey+y,1,20*e.wd)
						sfx(3)
						shake=3*e.wd
						del(enemies,e)
						score+=1*e.wd
					end
				end
			end
		end
		if e.h<1 then
			if e.typ==64 then
				e.sx,e.sy=0,0
				e.bmd="atk1"
				if t%5==0 and bdtimer>60 then
					explode(e.x+rnd(32),e.y+rnd(32),1,20)
					fracture(e.x+16,e.y+16,e.typ)
					sfx(3)
					shake=10
					score+=1
					e.imm=true
				end
				if state=="game" then
					music(-1,300)
					state="bdied"
				end			
			end
		end
	end
end

function drenemies()
	for e in all(enemies) do
		if t%(6*e.as)==0 then
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
		if bdtimer >60 then
			spr(e.sp,e.x,e.y,e.wd,e.ht,e.flp)
		end
		pal()
		if e.typ==64 and e.imm  
			and  e.h>0 then
			line(14,12,114,12,8)
			line(14,12,14+e.h,12,11)
		end
	end
end

function upplayer()
	ship.sp=2
	ship.sx=0
	ship.sy=0
	ship.t=45
	
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
	
	if state!="died" then
		ship.x+=ship.sx
		ship.y+=ship.sy
	end
	
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
		ship.flw=52
	else
		ship.fl=4
		ship.fli=6
		ship.flw=51
	end
	
	if btnp(5) and bonus.use then
		sfx(30)
	end
	
	if btnp(5) and not bonus.use then
		if firetyp>1 or bonus.typ=="drone strike" then
			sfx(31)
		else
			sfx(30)
		end
		bonus.use=true
	end
			
	if btn(4) and frate<16
	 and state!="died" then
		if ftimer<=0 then
			if firetyp>1 and bonus.use then
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
		if t%45==0 then
			frate+=1
		end
	end
	ftimer-=1
	if btn(4)==false then
		if t%5==0 then
			frate-=1
		end
	end
	if frate<5 then
		frate=5
	end
	
	if ship.h<=0 then
		if t%5==0 then
			explode(ship.x+rnd(8),ship.y+rnd(8),1,20)
			fracture(ship.x+4,ship.y+4,"ship")
			sfx(3)
			shake=10
		end
		if state=="game" then
			state="died"
		end
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
	if state!="wave" then
		if ship.sx!=0 or 
				ship.sy!=0 then
			spr(ship.fl,ship.x,ship.y+8)
		else
			spr(ship.fli,ship.x,ship.y+8)	
		end
	end	
	if state=="wave" then
		
		spr(ship.flw,ship.x,ship.y+8)
		
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
	if frate>9 then
		local cl=8
		if t%8<4 then
			cl=14
		end
		print("overheating",2,121,1)
		print("overheating",3,120,cl)
	end
	line(0,128,0,188-frate*12,8)
end

function fire(_ang,_spd,_obj)
	if _obj==nil then _obj=ship end
	local sx=sin(_ang)*_spd
	local sy=cos(_ang)*_spd
	local b={
								sp=32,
								x=_obj.x,
								y=_obj.y-4,
								sx=sx,
								sy=sy,
								dmg=1,
								box={x1=2,y1=0,x2=6,y2=7}}
	if _obj==drone then
		b.dmg=5
	end
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

function mkenemy(_typ,_tgx,_tgy)
	local typ=_typ --rnd(e_typestg)
	local tgx=_tgx --rnd(100)+10
	local tgy=_tgy
	local e={
								sp=typ,
								typ=typ,
								x=tgx,
								y=-100,
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
								as=1,
								f=rnd(), --phase
								md="wait",
								bmd=nil,
								bt=0,
								tgx=tgx,
								tgy=tgy,
								box={x1=0,y1=0,x2=7,y2=7}}
	if e.typ==64  then
		--boss
		e.wd=4
		e.ht=4
		e.ani=12
		e.h=100
		e.sy=0.25
		e.sx=0.25
		e.tgy=40
		e.x=50
		e.box={x1=2,y1=2,x2=28,y2=26}
	end
	
	if e.typ==28  then
		e.wd=2
		e.ht=2
		e.as=2
		e.sy=0.25
		e.sx=0.25
		e.box={x1=0,y1=0,x2=15,y2=15}
	end
	if e.typ==24 then
		e.tgy=30
		e.h=3
	end
	if e.typ==20 then
		e.ani=1
		e.sy=1
	end
	if e.typ==16 then
		e.x=64
		e.h=2
		e.tgy=110
	end
	if e.typ==12 then
		e.sx=-1
		e.sy=0
		e.h=3
	end
	if e.typ==8 then
		e.h=2
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
		if d.typ==64 then d.age=20 end					
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
		if d.typ==64 then 
			cl=8
		end
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
	if state!="bdied" then
		local o=_obj
		local sp=34
		local sd=5
		local x=o.x+(-4+4*o.wd)
		local y=o.y+(-4+4*o.ht)
		if _ang==nil then _ang=1 end
		if _spd==nil then _spd=2 end
		if o.typ==22 or o.bmd=="atk4" then
			sp=36
			_ang=0.25
			_spd=6
			sd=8
			if o.typ==64	then	y=o.y+6 end
			if o.x<ship.x then
				_ang=0.75
			end
		end
		local sx=sin(_ang)*_spd
		local sy=cos(_ang)*_spd
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
		sfx(sd)
	end
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
		if _o.typ==64 then
			_o.sp=136
			if t%6<3 then
				pal(8,7)
				pal(1,14)
			else
				pal()	
			end
		else
			if t%6<3 then
				for i=2,15 do
					pal(i,7)
				end
			else
				pal()	
			end
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
	sfx(3)
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
	if score%10==0 and score!=0
		and give and state=="game" then
		bonus.sy=1
		give=false
	end
	
	immortal(bonus,10)
	bonus.y+=bonus.sy
	if bonus.use then
		bonus.t-=1
	end
	if bonus.y>128 then
		bonus.y=-10
		bonus.sy=0
		give=true
	end
	if coll(ship,bonus) and state!="died" then
		if not bonus.imm then
			local txt=rnd(bonustyp)
			explode(bonus.x+4,bonus.y+4,2,20)
			bonus.imm=true
			bonus.y=-10
			bonus.sy=0
			bonus.x=rnd(100)+10
			sfx(4)
			bonus.t=150
			score+=1
			if txt=="shield on" then
				ship.sh=true
				shield.t=300
				bonus.use=true
			end	
			if txt=="1 up!" then
				if ship.h<4 then
					ship.h+=1
					bonus.use=true
				else	
					if rnd()>0.5 then
						txt="bullet barrage"
					else
						txt="multi shooting"
					end	
				end
			end	
			if txt=="triple shooting" then
				firetyp=2
			end	
			if txt=="multi shooting" then
				firetyp=4
			end	
			if txt=="bullet barrage" then
				firetyp=6
				bonus.t=250
			end
			if txt=="drone strike" then
				bonus.t=70
				drone.sy=-2
			end
			bonus.typ=txt
			addfloat(txt,64,120,1)
			addfloat(txt,63,121,7,2)
		end
	end
	if bonus.t<0 then
				firetyp=1
				bonus.t=0
				bonus.use=false
				give=true
				drone.sy=0
				drone.y=140
				bonus.typ=nil
	end
end

function drbonus()
	local cl=7
	if t%6<3 then
		cl=5
	end
	if t%6==0 then
			bonus.sp+=1
		end
		if bonus.sp>(bonus.spi+3) then
			bonus.sp=bonus.spi
		end
	if firetyp>1 then
		line(126,128,126,128-(bonus.t),10)
		if not bonus.use then
			cprint("press ❎",100,120,1)
			cprint("press ❎",99,121,cl)
		end	
	end
	if not bonus.use and 
		bonus.typ=="drone strike" then
			cprint("press ❎",100,120,1)
			cprint("press ❎",99,121,cl)
		end
	spr(bonus.sp,bonus.x,bonus.y)
end

function checkwave()
	if state=="game" then
		if #enemies==0 
		 and not win then
			cwave+=1
			state="wave"
		end
	end
end

function mkwave()
	if cwave==1 then
		local lvl={{8,8,8,8,8},
												{8,8,8,8,8},
												{8,8,8,8,8}}
		local size=getsize(lvl)
		placeenemies(lvl,size)		
	end
	if cwave==2 then
		local lvl={{8,8,8,8,8},
												{12,12,12,12,12},
												{12,12,12,12,12},
												{8,8,8,8,8}}
		local size=getsize(lvl)
		placeenemies(lvl,size)		
	end
	if cwave==3 then
		local lvl={{8,8,8,8,8},
												{8,12,16,12,8},
												{8,12,12,12,8},
												{8,12,16,12,8}}
		local size=getsize(lvl)
		placeenemies(lvl,size)		
	end
	if cwave==4 then
		local lvl={{8,8,8,8,8},
												{12,8,8,8,12},
												{20,8,8,8,20},
												{8,8,8,8,8}}
		local size=getsize(lvl)
		placeenemies(lvl,size)		
	end
	if cwave==5 then
		local lvl={{8,8,8,24,8},
												{8,8,8,8,8},
												{8,8,8,8,8},
												{12,24,12,0,12}}
		local size=getsize(lvl)
		placeenemies(lvl,size)		
	end
	if cwave==6 then
		local lvl={{8,28,8,28,8},
												{12,8,8,8,12},
												{12,8,0,8,12},
												{8,8,8,8,8}}
		local size=getsize(lvl)
		placeenemies(lvl,size)		
	end
	if cwave==7 then
		local lvl={{12,20,8,20,12},
												{20,24,8,24,20},
												{8,8,8,8,8},
												{12,0,24,0,12}}
		local size=getsize(lvl)
		placeenemies(lvl,size)		
	end
	if cwave==8 then
		local lvl={{12,8,28,8,12},
												{0,24,16,24,0},
												{0,12,28,12,0},
												{8,0,16,0,8}}
		local size=getsize(lvl)
		placeenemies(lvl,size)		
	end
	if cwave==9 then
		local lvl={{0,0,0,0,0},
													{0,64,0,0,0}}
												
		local size=getsize(lvl)
		placeenemies(lvl,size)		
	end
end

function placeenemies(_lvl,size)
	local lvl=_lvl
	for j=1,#lvl do
		for i=1, #lvl[1] do
			if #enemies<size then
				local dx=0
				if j%2==0 then
					dx=8
				end
				if lvl[j][i]!=0 then
					mkenemy(lvl[j][i],dx+i*22,7+j*4)
				end
			end
		end
	end	
end

function getsize(lvl)
	local size=0
	for j=1,#lvl do
		for i=1, #lvl[1] do	
			if lvl[j][i]>0 then
				size+=1
			end
		end
	end
	return size
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

function addfloat(_txt,_x,_y,_c,_typ)
	if _typ==nil then _typ=1 end
 add(floats,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0,typ=_typ})
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
		local cl=f.c
		if f.typ==2 then
			if t%6<3 then
				cl=11
			end
		end
		cprint(f.txt,f.x,f.y,cl)
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

function drlogo()	
	local logo={
							{200,199,199,199,199,199,215},
							{192,193,194,195,196,197,198},
							{208,209,210,211,212,213,214}}
	
	for j=1,#logo do
		for i=1, #logo[1] do
			spr(logo[j][i],28+i*8,1+j*8)
		end
	end
	
	sspr(1,112,121,16,4,36)
	spr(2,64,80)
	if t%6<3 then
		spr(4,64,88)
	else
		spr(5,64,88)
	end
end

function updrone()
	if drone.y<0 then
		drone.y=140
	end
	if bonus.use then
		drone.y+=drone.sy
	end
	local spc=0.25/9
	if t%5==0 and bonus.use
		and drone.sy==-2 then
		sfx(29)
		for i=0,9 do
			fire(0.375+spc*i,5,drone)
		end
	end	
end

function drdrone()
	spr(drone.sp,drone.x,drone.y)
	spr(ship.fl,drone.x,drone.y+8)
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
0000000b00000000000000000000000003bbbb3003bbbb30000333300003333008088080080880800808808008088080001122cccc221100001122cccc221100
b00000b0b00000bbb00000b0000000bb32bbbb2337bbbb73bbb77223bbb2277300888800008888000088880000888800001122cccc221100011122cccc221110
0bbbbb000bbbbb000bbbbb0b3bbbbb0032b11b2337b11b73bbbbbbbbbbbbbbbb08b88b800828828008b88b8008288280111ccc5555ccc111111ccc5555ccc111
0b707b000b707b000b707b000b333b0037b11b7332b11b235d1166bb56611dbb88888888888888888888888888888888111cc57ee75cc11111ccc522225ccc11
0bb66b000bb66b000bb66b000bb66b0037b11b7332b11b235d1166bb56611dbb80aaaa0880aaaa0880aaaa0880aaaa081ccccc7887ccccc11ccccc2222ccccc1
00bbbbb000bbbbb000bbbbb000bbbbb00bb11bb00bb11bb0bbbbbbbbbbbbbbbb800000080800008008000080800000081ccccc7887ccccc11ccccc2222ccccc1
0b00000b0b00000b0b00000b0b00000b0bb11bb00bb11bb0bbb77223bbb22773080000800800008008800880888008881ccccc6006ccccc11ccccc6006ccccc1
b00000000b00000000b000000b00000b0bb55bb00bb55bb00003333000033330000000000000000000000000000000001ccc09600690ccc11ccc09600690ccc1
00099000000990000000000000000000088888800888888000aaaa000000a00000aaaa00000a0000000dd000000000001ccc09000990ccc11ccc09900090ccc1
009aa9000097790000000000000ff000eeeeeeee8888888809aaaaa000d1a0000aa1cc90000a1d0000633600000000001cc0090000000cc11cc0000000900cc1
0097a900009a7900000bb00000fbbf0077777777eeeeeeee9aaaaaa700c170007a1ca1c900071c0050637605000000001cc0099000000cc11cc0000009900cc1
00977900009aa90000b77b000fb66bf077777777777777779aaaaaaa00d5a000aaaaa1c9000a5d00501661050000000011c0000000000c1111c0000000000c11
000990000009900000b7fb000fb66bf077777777777777774aaaaaaa00c0a000aaaa1ca4000a0c00566dd6650000000011c0000000000c1101cc00000000cc11
0000900000090000000bb00000fbbf0077777777eeeeeeee4aaaaaaa0000a000aaaaaaa4000a0000d6d66d6d0000000001cc00000000cc10011c00000000c110
009000000000090000000000000ff000eeeeeeee8888888804aaaaa000c1a0000aaa1c40000a1c001116611100000000011c00000000c110001ccc0000ccc100
0000a000000a000000000000000000000888888008888880004aaa000000a00000aaa400000a000001d00d1000000000001ccc0000ccc1000001110000111000
000000000070070000700700000000000c7617c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800800078778700767767000017000ccdf6dcc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0888888078888887766666670cd7fdc0ccd6dccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
088e8880788e8887766666670cdf6dc00ccdcc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0088e8000788e870076666700cd6dcc000ccc00c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008800000788700007667000ccdcc00000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000770000007700000ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00e000000000eeeeeeee000000000e00000000000000eeeeeeee00000000000000e000000000eeeeeeee000000000e00000000000000eeeeeeee000000000000
00ee00000eeeeeeeeeeeeee00000ee000ee000000eeeeeeeeeeeeee000000ee000ee00000eeeeeeeeeeeeee00000ee000ee000000eeeeeeeeeeeeee000000ee0
008eee00eeeee888888eeeee00eee800088e0000eeeee888888eeeee0000e880008eee00eeeee888888eeeee00eee800088e0000eeeee888888eeeee0000e880
00288e00eee888eeee888eee00e88200028eee00eee888eeee888eee00eee82000288e00eee888eeee888eee00e88200028eee00eee888eeee888eee00eee820
00228888ee888e2211e888ee8888220000288888ee888e2112e888ee8888820000228888ee888e1122e888ee8888220000288888ee888e2222e888ee88888200
0002228ee88ee221111ee88ee82220000002228ee88ee211112ee88ee88820000002228ee88ee111122ee88ee82220000002228ee88ee212212ee88ee8882000
0000222888e2777111172e88822200000000222888e2771111772e88822200000000222888e2711117772e88822200000000222888e2222112222e8882220000
0000eee282277771111772282eee00000000eee282277711117772282eee00000000eee282277111177772282eee00000000eee282211222222112282eee0000
000eeeee2777771199117772eeeee000000eeeee2777711991177772eeeee000000eeeee2777119911777772eeeee000000eeeee2222211221122222eeeee000
00ee888827777711001177728888ee0000ee888827777110011777728888ee0000ee888827771100117777728888ee0000ee888822222221122222228888ee00
0ee88888267777119911776288888ee00ee88888267771199117776288888ee00ee88888267711991177776288888ee00ee88888212222122122221288888ee0
0ee82888226677711117662288828ee00ee88888226677111177662288888ee00ee82888226671111777662288828ee00ee88888221122122122112288888ee0
ee8228288226666111166228828228ee0e8888288226661111666228828888e0ee8228288226611116666228828228ee0e8888288221112112111228828888e0
e888228288222266112222882822888e0e8822828822226116222288282288e0e888228288222211662222882822888e0e8822828822221221222288282288e0
888222282882222211222882822228880e8222282882222112222882822228ee88822228288222112222288282222888ee8222282882222112222882822228e0
8822222288288aaaaaa88288222222880882222288288aaaaaa882882222288e8822222288288aaaaaa8828822222288e882222288288aaaaaa8828822222880
882000222288899999988822220002880882002222888999999888222200288e88200022228889999998882222000288e8820022228889999998882222002880
88200000228824444442882200000288088200002288824444288822000028888820000022882444444288220000028888820000228882444428882200002880
882000000e822440044228e0000002880882000000e8224444228e0000002888882000000e822440044228e0000002888822000000e8224444228e0000002880
888000000e882666000288e0000008880888000000e8826660288e0000000888888000000e882666000288e0000008888820000000e8826660288e0000008880
88800e00ee826600007728ee00e00888088800000ee8266007728ee000e0088888800000ee826600007728ee0000088888200e000ee8266007728ee000008880
88eee800e82700007777728e008eee88088800000e827007777728e00e8eee8888e00000e82700007777728e00000e8888eee8e00e827007777728e000008880
2888880ee27777000066662ee08888820e880000ee277770066662ee0288888288ee000ee27777000066662ee000ee8828888820ee277770066662ee00008880
2228880e8277777000066628e08882220e880000e82777770066628e02888222228ee00e8277777000066628e00ee82222288820e82777770066628e000088e0
0022220e8266600007777728e02222000e8e0000e82666007777728e002222000228ee0e8266600007777728e0ee822000222200e82666007777728e000088e0
000000088270000077777728800000000e8e000088277007777772880000000000228e08827000007777772880e822000000000088277007777772880000e8e0
000000088277700000666628800000000eee000088277700766662880000000000022e08827770000066662880e220000000000088277700766662880000e8e0
0000000888e77700000666888000000000e000008888777007666888000000000000000888e7770000066688800000000000000088887770076668880000eee0
00000008888e777000006888800000000000000088888777007688880000000000000008888e7770000068888000000000000000888887770076888800000e00
000000002288e000077788220000000000000000022888007778822000000000000000002288e000077788220000000000000000022888007778822000000000
00000000002886600008820000000000000000000002886600882000000000000000000000288660000882000000000000000000000288660088200000000000
00000000000220000002200000000000000000000000220000220000000000000000000000022000000220000000000000000000000022000022000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee00000000000000000000000000000000000000000000
00888000088888000180018001888800000000000000000000000000000000000ee000000eeeeeeeeeeeeee000000ee000000000000000000000000000000000
0180000008800800018001800180000000000000000000000000000000000000088e0000eeeee888888eeeee0000e88000000000000000000000000000000000
0180800008800800018801800188880000000000000000000000000000000000028eee00eee888eeee888eee00eee82000000000000000000000000000000000
018018000888880001808080018000000000000000000000000000000000000000288888ee888e2222e888ee8888820000000000000000000000000000000000
01801800088018000180808001800000000000000000000000000000000000000002228ee88ee212212ee88ee888200000000000000000000000000000000000
00888000088018000180808001888800000000000000000000000000000000000000222888e2222112222e888222000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000eee282211222222112282eee000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000eeeee2222211221122222eeeee00000000000000000000000000000000000
008880000180080001888800018888000000000000000000000000000000000000ee888822222221122222228888ee0000000000000000000000000000000000
01800800018008000180000001800800000000000000000000000000000000000ee88888212222122122221288888ee000000000000000000000000000000000
01800800018008000188880001888000000000000000000000000000000000000ee88888221122122122112288888ee000000000000000000000000000000000
01800800018008000180000001801800000000000000000000000000000000000e8888288221112112111228828888e000000000000000000000000000000000
01800800018808000180000001801800000000000000000000000000000000000e8822828822221221222288282288e000000000000000000000000000000000
00888000001880000188880001801800000000000000000000000000000000000e8222282882222112222882822228e000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000882222288288aaaaaa882882222288000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000882002222888999999888222200288000000000000000000000000000000000
005b0b0000bbb00005b00b000000000005b000b0005b00000bb00b00000000000882000022888244442888220000288000000000000000000000000000000000
005b0b0005b00b0005b00b000000000005b000b0005b00000bb00b00000000000882000000e8224444228e000000288000000000000000000000000000000000
005b0b0005b00b0005b00b000000000005b0b0b0005b00000bbb0b00000000000888000000e8826660288e000000888000000000000000000000000000000000
005bb00005b00b0005b00b000000000005b0b0b0005b00000bb0bb0000000000088800000ee8266007728ee00000888000000000000000000000000000000000
0005b00005b00b0005b00b000000000005bbb0b0005b00000bb05b0000000000088800000e827007777728e00000888000000000000000000000000000000000
0005b00000bbb000005bbb0000000000005bbb00005b00000bb05b000000000008880000ee277770066662ee0000888000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000088e0000e82777770066628e000088e000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000088e0000e82666007777728e000088e000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000e8e000088277007777772880000e8e000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000e8e000088277700766662880000e8e000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000eee000088887770076668880000eee000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000e00000888887770076888800000e0000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000002288800777882200000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000028866008820000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000002200002200000000000000000000000000000000000000000000
bbb00000bbbb000bbbb00b00bbb0000bbbb0bbbbbbb000bbbbbbbbbd000000000000000000000000000000000000000000000000000000000000000000000000
bbb0bbbbbbbbb0bbbbb0b0b0bbb0bb0bbbb0bbbbbbb0bbbbbbbbbbbd000000000000000000000000000000000000000000000000000000000000000000000000
bbb0000bbbbbb0bbbbb0bbb0bbb000bbbbb0bbbbbbb000bbbbbbbbbd000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbb0bbbbb000bbbb0bbb0bbb0bbbbbbb0bbbbbbb0bbbbbbbbbbbd000000000000000000000000000000000000000000000000000000000000000000000000
bbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbbbb000bbbbbbbbbdbbbbbbbb00bbbbbb00000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdbbbbbbbb0bbbbbbb00000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000
bbb00000bb0bb0bbbb0000bbbb0000bbb00000bbbbb000bbbb0000bd000000000000000000000000000000000000000000000000000000000000000000000000
bbb0bbbbbb0bb0bbbb0bb0bbbb0bb0bbbbb0bbbbbbb0bbbbbb0bb0bd000000000000000000000000000000000000000000000000000000000000000000000000
bbb0000bbb0000bbbb0bb0bbbb0bb0bbbbb0bbbbbbb000bbbb000bbd000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbb0bbb0bb0bbbb0000bbbb0000bbbbb0bbbbbbb0bbbbbb00bbbd000000000000000000000000000000000000000000000000000000000000000000000000
bbb0000bbb0bb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbbb0b0bbdbbbbbd000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0bb0bdbbbbbbd00000000000000000000000000000000000000000000000000000000000000000
0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd0bbbbbbbd0000000000000000000000000000000000000000000000000000000000000000
00dddddddddddddddddddddddddddddddddddddddddddddddddddd00bbbbbbbd0000000000000000000000000000000000000000000000000000000000000000
05886660005800586005860000005860000000588888600000588888058866600005888600588666000058866600000588860000058888600005888886000000
05888886605800586005860000005860000005888888600055886668058888866005888600588888660058888866000588860000588888600058888886000000
05888888865800586005860000005860000005855555008888860000058888888658005860588888886058888888605800586005880000000058555550000000
05800058865800586005860000005860000005860000008555860000058000588658005860580005886058000588605800586005800000000058600000000000
05800588605800586005860000005860000005860000000005860000058005886058005860580058860058005886005800586058800000000058600000000000
05805886005800586005860000005860000005860000000005860000058058860058005860580588600058058860005800586058800000000058600000000000
05858860005800586005860000005860000005860000000005860000058588600058005860585886000058588600005800586058800000000058600000000000
05888600005800586005860000005860000005888886000005860000058886000058665860588860000058886000005866586058800066600058888860000000
05888886005800586005860000005860000005888886000005860000058888860058888860588888600058888860005888886058800088860058888860000000
05800088605800586005860000005860000005855550000005860000058000886058005860580008860058000886005800586058800005886058555500000000
05800058605800586005860000005860000005860000000005860000058000586058005860580005860058000586005800586058800000886058600000000000
05800588605800586005860000005860000005860000000005860000058005886058005860580005860058000586005800586005800005860058600000000000
05805886005800586005860000005860000005860000000005860000058058860058005860580005860058000586005800586005880008860058600000000000
05858860005800580005866666605866666605866666000005860000058588600058005860580005860058000586005800586000588088600058666660000000
05888600005585860000588888800588888805888888600005860000058886000058005860580005860058000586005800586000058886000058888886000000
05886000000588860000055555500055555505888888600005860000058860000058005860580005860058000586005800586000005560000058888886000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000d9000000000000d0000000000000000000000000000000070000000000000
00000000000000000000000000000000000000000000000000000000000000000097790000000000000000000000000000000000000000000000000000000000
0000000000070000000000000000000000000000000000099000000000000000009a790000000000000000990000000000000000000000000000000000000000
0000000000000000000000000000000070000000000000977900000000000000009aa90000000000000009779000000000000000000000000000000000000000
00000000000000000000000000000000000000000000009a79000000000000000009900000000000000009a79000000000000000000000000000000000000000
00000000000000000000000000000000000000000000009aa9000000000000000009000000000000000009aa9000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000990000000000000000000090000000000000000990000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000090000000000000000000a000000000000000000900000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000009000000000000000000000000000000000000009000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000a00000000000000000000000000000000000000a00000000000000000000000000000000000000000
00000000000000000000000000000990000000000000000000000000000000000000000000000000000000000000000000000000990000000000000000000000
00000000000000000000000000009779000000000000000000000000000000000000000000000000000000000000000000000009779000000000000000000000
00000000000000000000000000009a79000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd00000000000009a79000000000000000000000
00000000000000000000000000009aa900000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd0000000000009aa9000000000000000000000
000000000000000000000000000009900000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd000000000000990000000000000000000000
000000000000000000000000000009000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd000000000000900000000000000000000000
000000000000000000000000000000090000bbb00000bbbb000bbbb00b00bbb0000bbbb0bbbbbbb000bbbbbbbbbd000000000000009000700000000000000000
00000000000000000000000000000a000000bbb0bbbbbbbbb0bbbbb0b0b0bbb0bb0bbbb0bbbbbbb0bbbbbbbbbbbd000000000000a00000000000000000000000
00a000000000000000000000000000000000bbb0000bbbbbb0bbbbb0bbb0bbb000bbbbb0bbbbbbb000bbbbbbbbbd000000000000000000000000000000000000
000000000000000000000000000000000000bbbbbb0bbbbb000bbbb0bbb0bbb0bbbbbbb0bbbbbbb0bbbbbbbbbbbd000000000000000000000000000000000000
000000000000000000007000000000000000bbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbbbb000bbbbbbbbbd000000000000000000000000000000000000
000000000000099000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd000000000000000000000000000099000000
000000000000977900000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd000000000000000000000000000977900000
0000000000009a7900000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd0000000000000000000000000009a7900000
0000000000009aa900000000000000000000bbb00000bb0bb0bbbb0000bbbb0000bbb00000bbbbb000bbbb0000bd0000000000d00000000000000009aa900000
000000000000099000000000000000000000bbb0bbbbbb0bb0bbbb0bb0bbbb0bb0bbbbb0bbbbbbb0bbbbbb0bb0bd000000000000000000000000000099000000
000000000000090000000000000000000000bbb0000bbb0000bbbb0bb0bbbb0bb0bbbbb0bbbbbbb000bbbb000bbd000000000000000000000000000090000000
000000000000000900000000000000000000bbbbbb0bbb0bb0bbbb0000bbbb0000bbbbb0bbbbbbb0bbbbbb00bbbd000000000000000000000000000000900000
0000000000000a0000000000000000000000bbb0000bbb0bb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbbb0b0bbd0000000000000000000000000000a0000000
000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0bb0bd000000000000000000000000000000000070
0000000000000000007000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd0000000000000000000000000000000000000
00000000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005886660005800586005860000005860000000588888600000588888058866609905888600588666000058866600000588860000058888600005888886000
00005888886605800586005860000005860000005888888600055886668058888866795888600588888660058888866000588860000588888600058888886000
00005888888865800586005860000005860000005855555008888869779058888888658005869588888886058888888605800586005880000000058555550000
00005800058865800586005860000005860000005860000008555869779058000588658005869589005886058000588605800586005800000000058600000000
00005800588605800586005860000005860000005860000000005869aa9058005886958005869589058860058005886005800586058800000000058600000000
00005805886005800586005860000005860000005860000990005860990058058869058005860580588600958058860005800586058800000000058600000000
00005858860005800586005860000005860000005860009779005860900058588600058005860585886009758588600005800586058800000000058600000000
00005888600005800586005860000005860000005888886a7900586000905888600a058665860588860009a58886000005866586058800066600058888860000
00005888886005800586005860000005860000005888886aa9005860a00058888860058888860588888609a58888860005888886058800088860058888860000
000058000886058005860058600000058600000058555509900058600a0058000886058005860580008860958000886005800586058800005886058555500000
00005800058605800586005860000005860000005860000900005860000058000586058005860580005860958000586005800586058800000886058600000000
00005800588605800586005860000005860000995860000009005860000058005886058005860580005860058000586995800586005800005860058600000000
00005805886005800586005860000005860009775860000a00005860000058058860058005860580005860a58000586775800586005880008860058600000000
00005858860005800580005866666605866666675866666000005860000058588600058005860580005860058000586a75800586000588088600058666660000
000058886000055858600005888888005888888a5888888600005860000058886000058005860580005860058000586aa5800586000058886000058888886000
00005886000000588860000055555500055555595888888600005860000058860000058005860580005860058000586995800586000005560000058888886000
00000000000000000000000000000000000000900000000000000000000000000000000000000000000000000000000900000000000000000000000000000000
00000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000009000000000000000000000000000000
00000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000007000000000000000000000000a0000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000
0000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000
0000000000000000000000000000000000000000000000000000000000000000999999900000000000000000000000000000000000000000000d000000000000
00000000000700000000000000000000000000000000000000000000000000099799979900000000000000000000000d00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000999a99997790000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000999a9999a790000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000009a997779aa90000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000097777777900000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000007000000000097777777900000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000077777777790000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000077777777700000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000d00000000000000000000007777d67770000000000000000000000000000000000000000000d000000000000
0000000000000000000000000000000000000000000000000000000000000000571d617500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006116611600000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000061dccd1600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006667c66600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006657756600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001665566100000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000001daad1000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000001700000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000087a80000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000008a980000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000089800000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008000000007000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000
000000000000000000000000000070000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000015551555155501550155000015150015015555500000155501550000015515551555155515550000000000000000000000000
00000000000000000000000000015151515151015101510000015150150155151550000115015150000151011501515151511500000000000000000000000000
00000000000000000000000000015551550155015551555000011500150155515550000015015150000155501501555155001500000000000000000000000000
00000000000000000000000000015101515150011151115000015150150155151550000015015150000111501501515151501500000000000000000000000000
00000000000000000000000000015001515155515501550000015151500115555500000015015500000155001501515151501500000000000000000000000000
00000000000000000000000000010001010111011001100000010101000011111000000010011000000110001001010101001000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000007000000000000000000000000000000000d0000000000000000000000000000000000007000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11101010000011101100101011101110110001100000011011101110011011100000000000000000000000000000000000001010111000001110111000000000
10101010000010001010101010101010101010100000100000101000100000100000000000000000000000000000000000001010101000001000001000000000
11001110000011001010101011101100101010100000111001001100111001000000000000000000000000007000000000001010101000001110001000000000
10100010000010001010101010101010101010100000001010001000001010000000000000000000000000000000000000001110101000000010001000000000
11101110000011101110011010101010111011000000110011101110110011100000000000000000000000000000000000000100111001001110001000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000d0000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
010e000005455054553f52511435111250f4350c43511125034550345511125182551b255182551d2551112501455014552025511125111252025511125202550345520255224552325522455202461d4551b255
19020000220001a0511701113021100310e0410b0410a051070510406102061020710000000501005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00020000106101a610126000c60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c80400002d636286162461622616206161b616196161661614616116160e6160e6160000500004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
100500003f0163a016360162a0163b010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4604000016007100070c0720907205072040720307202072010720007200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702007020070200702
110f00001e050000001e0501d0501b0501a0601a0621a062000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000011574160741357418074155641a064165641b064185641d0541a7541f5541b054217541d544220441f744245342103426734220342772424024297140070400704007040070400704007040070400704
010800001857218572185721857218572000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000205401d540205401d540205401d540205401d54022540225502255022550225500000000000000000000025534225302553022530255301d530255302253019531275322753027530275322753027530
5c0400000817120161181610f17108171171711017109171071710d1610f161091510715106151051410514105132041320313202132021320113201132001320113201132011320112200122001220012200122
090d00001b0001b0001b0001d0001b0001b0001b0001d0001e0002000020000200001b030200001b0301d0201e0302003020040200401b0001d7001b0001d0001e0002000020000200001b7001b7001c7001c700
940400003b6702b6403b67021620376702867031670266502c6502a650276502565022650206501d6501b6501965017640166401464012640106400d6400c6300a63008620076200562004620026200162000620
010e00000c0530c4451112518455306251425511255054450c0530a4353f52513435306251343518435054450c053111251b4353f525306251b4353f5251b4350c0331b4451d2451e445306251d2451844516245
010e00000145520255224552325522445202551d45503455034050345503455182551b455182551d455111250045520255224552325522455202461d4551b255014550145511125182551b455182551d45511125
010e00000c0531b4451d2451e445306251d245184450c05317200131253f52513435306251343518435014450c0431b4451d2451e445306251d245184451624511125111253f5251343530625134351843500455
010e0000004550045520455111251d125204551d1252912501455014552c455111251d1252c4551d12529125034552c2552e4552f2552e4552c2552945503455044552c2552e4552f2552e4552c246294551b221
010e00000c0530c0531b4551b225306251b4551b2250f4250c0530c05327455272253062527455272251b4250c0531b4451d2451e445306251d245184450c0530c0531b4451d2451e445306251d2451844500455
0116002006055061550d055061550d547061550d055061550d055060550615501155065470d15504055041550b055041550b547041550b055041550b0550b155040550b155045460b1550b055041550b0550b155
01160000190241902506535135000653500505065351a0241a025065351a0250653506404065351902419025045351702404535005050453500505045351e0241e025045351e0240453504535005050453504535
010b00201e4421e4321f4261e4261c4321c4221e4421e4321e4221e4221f4261e4261c4421c4321c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c42510125101051012510105
010b00201e4421e4361f4261e4261c4421c4421a4451c4451e4451f44521445234452644528445254422543219442194322544225432264362543623442234322144221432234472343625440234402144520445
01160000124101241212412124151251500505065351a0241a025065351a0250653500505065351902419025045351702404535005050453500505045351e0241e025045351e0240453504535005050453504535
010d00000c0530445504255134453f6150445513245044550c0531344513245044553f6150445513245134450c0530445504255134453f6150445513245044550c0531344513245044553f615044551324513445
010d00000c0530045500255104453f6150045510245004550c0530044500245104553f6150045510245104450c0530045500255104453f6150045510245004550c0531044510245004553f615004551024500455
010d00000c0530245502255124453f6150245512245024550c0531244512245024553f6150245502255124450c0530245502255124453f6150245512245024550c0530244512245024553f615124550224512445
010d00002b5552a4452823523555214451f2351e5551c4452b235235552a445232352d5552b4452a2352b555284452a235285552644523235215551f4451c2351a555174451e2351a5551c4451e2351f55523235
010d000028555234452d2352b5552a4452b2352f55532245395303725536540374353b2503954537430342553654034235325552f2402d5352b2502a4452b530284552624623530214551f24023535284302a245
010d00002b5552a45528255235552b5452a44528545235452b5352a03528535235352b0352a03528735237352b0352a03528735237351f7251e7251c725177251f7151e7151c715177151371512715107150b715
a40200000467605676056760767609676006060c676006060e676006061267600606156060060619606006061c6061e606006062060623606006062760629606006062c6062f6063260600606366063860639606
00090000197700d770030000c00009000130000400000000000001f000000000000000000000000000000000000000000000000000000000016000000000000000000000003f6000000000000000000000000000
31050000065120c512125321a552215522755230542385022d5002450018500185001850000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
__music__
01 000d4344
00 000d4344
00 000d4344
00 000d4344
00 0e0f4344
00 0e0f4344
02 10114344
01 12137f44
00 12167f44
00 12137f44
00 12167f44
00 12137f44
02 12167f44
01 17424344
00 18424344
00 19424344
00 17424344
00 171a4344
00 181a4344
00 191b4344
02 171c4344

