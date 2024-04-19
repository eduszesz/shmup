pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--topshooter
--by eduszesz

function _init()
	t=0
	mx=0
	my=16
	md=0.06
	map_w=1024
	map_h=256
	rooms={}
	debug={}
	initialize()
	for x=0,7 do
		for y=0,1 do
			mkmap(x,y,51+x)
		end
	end
	--mkmap(0,0,0)
	mkmaze()
	debug[0]=#rooms
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
	cam(p.x,p.y)
	--movemap()
	if state=="start" then
		print("press 🅾️ to start",30,64,0)
	end
	
	if state=="game" then
		draw_game()
	end
	
	if state=="over" then
		print("press 🅾️ to play again",20,64,0)
	end
	for i=0,#debug do
		print(debug[i],3,i*9,7)
		print(debug[i],5,i*9,7)
		print(debug[i],4,1+i*9,7)
		print(debug[i],4,-1+i*9,7)
		print(debug[i],4,i*9,8)
	end
	for r in all(roms) do
		rect(r.x,r.y,r.x+r.x2,r.y+r.y2,0)
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
	fumes={}
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
	upfumes()
end

function draw_game()
	drbullets()
	drcorpses()
	drdust()
	drenemies()
	drfumes()
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
		--my+=md*p.dy
		if not btn(🅾️) then
			p.sp=1
		end
	end
	if btn(⬇️) then
		p.dy=1
		--my+=md*p.dy
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
						mksparks(p)
					end
					if p.h<1 then
						mkexplosions(p)
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
		if p.x>map_w-8 then p.x=map_w-8 end
		if p.y<0 then p.y=0 end
		if p.y>map_h-8 then p.y=map_h-8 end
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
		if hit((b.x+b.dx),b.y,4,4,0) then
			if abs(b.x-b.ix)>24 then 
				mksparks(b)
				del(bullets,b)
			end
		end
  	
		if hit(b.x,(b.y+b.dy),4,4,0) then
			if	abs(b.y-b.iy)>24 then 
				mksparks(b)
				del(bullets,b)
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
										ix=p.x+ox,
										iy=p.y+oy,
										id=p.id,
										typ="bull",
										box={x1=2,y1=0,x2=4,y2=7}}
	add(bullets,b)
	mksmoke(sox,soy,p)
end

function mksmoke(_ox,_oy,_obj)
	local ox,oy,p=_ox,_oy,_obj
	local s={r=3,x=p.x+ox,y=p.y+oy}
	add(smoke,s)
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
						mksparks(e)
					end
					if e.h<0 then
						mkexplosions(e)
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

function mkexplosions(_obj)
	local p=_obj
	local r=10
	local ct=4
	if p.typ=="jipe" then
		r=14
		ct=8
	end
	local ex={x=p.x+ct,
											y=p.y+ct,
											r=r,
											typ=p.typ}
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
	local c=8
	local ca={7,8,9,10}
	for ex in all(explosions) do
		if ex.typ=="jipe" then
			c=rnd(ca)
		end
		circfill(ex.x,ex.y,ex.r,c)
	end
end

function mksparks(_obj)
	local p=_obj
	local crx,cry=4,4
	local c=8
	if p.typ=="jipe" then
		crx,cry=8,8
	end
	if p.typ=="bull" then
		c=13
		if p.dx==0 then
			cry=p.dy+4
			crx=4
		else
			crx=p.dx+4
			cry=4
		end
	end
	local s={x=p.x+crx,
										y=p.y+cry,
										c=c,
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
		else
			mkfumes(cr)	
		end
		if cr.t<0 then
			if cr.sp==68 then
				mset((cr.x+8)/8,(cr.y+8)/8,70)			
			else
				mset((cr.x+4)/8,(cr.y+4)/8,14)
			end
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
				local c=flr(rnd(15))
				local c2={9,10}
				pal(c,rnd(c2))
				spr(cr.sp,cr.x,cr.y,2,2)
				pal()
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
			r=5}
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
		local dx=rnd(4)-2
		local dy=rnd(4)-2
		circfill(d.x+dx,d.y+dy,d.r,6)
		fillp(✽)
		circfill(d.x+dx,d.y+dy,d.r,15)		
		fillp()
	end
end

function mkfumes(_obj)
	local p=_obj
	local f={x=p.x+rnd(10)+3,
										y=p.y+8,
										t=10,
										dy=-1}
	add(fumes,f)									
end

function upfumes()
	for f in all(fumes) do
		f.t-=1
		f.y+=f.dy
		f.x+=sin(t/30)
		if f.t<0 then
			del(fumes,f)
		end
	end
end

function drfumes()
	for f in all(fumes) do
		pset(f.x,f.y,13)
	end
end

function mkmap(_x,_y,_sp)
	local sp=_sp
	local mx,my=_x*16,_y*16
	local tmp={{120,127,0,7},
											{0,7,8,15},
											{8,15,8,15},
											{16,23,8,15}}
	local mc={{1,19},{2,20},{3,21},{4,22},{5,23},{6,24},{7,25},{8,26},{9,27}}										
	for cx=0,8,8 do
		for cy=0,8,8 do
			local sp=rnd(tmp)
			for y=sp[3],sp[4] do
				for x=sp[1],sp[2] do
					for i=1,#mc do
						if sget(x,y)==mc[i][1] then
							mset(mx+x-sp[1]+cx,my+y-sp[3]+cy,mc[i][2])
						end
					end
				end
			end
		end
	end
	mset(mx,my,sp)		
end

function mkmaze()
	local minrooms=6
	local maxrooms=13
	local maxw=12
	local maxh=12
	local nrooms=flr(rnd(maxrooms-minrooms))+minrooms
	debug[1]=nrooms
	--[[
	for x=0,127 do
		mset(x,0,28)
		mset(x,31,28)
	end
	for y=0,31 do
		mset(0,y,28)
		mset(127,y,28)
	end]]
	while #rooms<nrooms do
		for i=1, nrooms-#rooms do
			local w=maxw-flr(rnd(8))
			local h=maxh-flr(rnd(8))
			local ix=flr(rnd(128-w))
			local iy=flr(rnd(32-h))
			local r={x=ix,
												y=iy,
												x2=w,
												y2=h,
												d=false,
												box={x1=0,y1=0,x2=w,y2=h}}

			add(rooms,r)		
		end
		for j=1,#rooms do
			for i=1,#rooms do
				if j!=i then
					if coll(rooms[j],rooms[i]) then
							rooms[j].d=true
					end
				end
			end
		end
		for r in all(rooms) do
			if r.d then
				del(rooms,r)
			end
		end
		
	end
	for r in all(rooms) do
		local ix=r.x
		local iy=r.y
		local w=r.x2
		local h=r.y2
		
		for x=0,w do
				mset(x+ix,iy,28)
				mset(x+ix,iy+h,28)
				if x==flr(w/2) then
					mset(x+ix,iy,29)
					mset(x+ix,iy+h,29)					
				end
		end
		for y=0,h do
				mset(ix,y+iy,28)
				mset(ix+w,y+iy,28)
				if y==flr(h/2) then
					mset(ix,y+iy,29)
					mset(ix+w,y+iy,29)
				end
		end		
	end
end

function cam(_x,_y)
	local cx,cy=_x-64,_y-64
	if cx<0 then --camera lower x limit
		cx=0
	end
	
	if cx>(map_w-128) then --camera upper x limit
		cx=(map_w-128)
	end
	
	if cy<0 then --camera lower y limit
		cy=0
	end
	
	if map_h<128 then --camera upper y limit
		cy=-32
	end
	if cy>=(map_h-128) and
	map_h>=128 then
		cy=map_h-128
	end
		
	camera(cx,cy)
end

function movemap()
	--maps scrolls when player move
	
	if my<0 then
		mx+=16
		my=16
	if 	mx>48 then
		mx=0
		my=16
	end
	end
	map(mx,my,0,0,16,16)
	
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
0007700000dbb50000000050000b04430000b4430b500b0005bbd0003440b000dbbd0000000e700088e7e8800033000000770000007700000000000001108110
0007700000b005b0000dbb50000b04430000dbbd005bbd00050000003440b000344b00000007e000088e7e880e33d05000776700000060000006000000000000
0070070000b445b0000b445b000dbbbd00000000005000000d0000000b5555d5344b0000000e800000000000088ee50007700000007000000000000000000000
0000000000b44bd0000b445b000000000000000000d00000050000000dbb0000b5555d5000088000000000008085508070700000000000000000000009000000
0000000000d33000000d33bd0000000000000000005000000000000000000000dbb0000000080000000000000058050000570000000000000000000000000000
000000000000000000000000fffffffffffffccccccffffffcd1111111116dcffcd1111111111dcfffffffffffffffffdddddddd666556660000000000000000
009000000230000000000000fddffddfffffc6dddd6cfffffcd11111d1111dcff6d1111111111d6fffffffffffffffffd666666d666556660000000000000000
000000000670000000009100d66dd66dfffcdd1111ddcffffccd11111111dccff6d1111111111d6fffffffffffffffffd666666d666556660000000000000000
000000000450009000009900d66dd66dffcd11111111dcffffcd66111111dcfffcd111111d111dcfffff9ffffffbfbffd665566d555555550000000000000000
0000009000000000001100006dd66dd6ffcd11111111dcffffccdd1111ddccfffcd1111111111dcffff94ffffff535ffd665566d555555550000000000000000
00000230000000000990080066666666fcd1111111111dcffffcc6dddd6ccffffc611111111116cffff4ffffffff5fffd666666d666556660000000000000000
00000450000000000000000055555555fcd111d111116dcffffffccccccffffffc611111111116cfffffffffffffffffd666666d666556660000000000000000
000000000000000000000000fffffffffcd1111111116dcffffffffffffffffffcd1111d11111dcfffffffffffffffffdddddddd666556660000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ff6dd6ffffffffff88888888888888888888888888888888888888888888888888888888888888880000000000000000000000000000000000000000
ffffffff1dd66dd1fff66fff8888888888888888888888888888888888888888888a888888888888888888880000000000000000000000000000000000000000
fddffddfd66dd66dff6555ff8888888888aaa88888aaa88888a8a888888aaa88888a888888aaa88888aaa8880000000000000000000000000000000000000000
d66dd66dfdd66ddff555551f888aa8888888a8888888a88888a8a888888a8888888aaa888888a88888a8a8880000000000000000000000000000000000000000
d66dd66dd66dd66d455551148888a88888aaa888888aa88888aaa888888aaa88888a8a88888aaa8888aaa8880000000000000000000000000000000000000000
6dd66dd61dd66dd1445511448888a88888a888888888a8888888a88888888a88888aaa888888a88888a8a8880000000000000000000000000000000000000000
66666666f166661ff444444f8888a88888aaa88888aaa8888888a888888aaa88888888888888a88888aaa8880000000000000000000000000000000000000000
55555555ff5555ffffffffff88888888888888888888888888888888888888888888888888888888888888880000000000000000000000000000000000000000
00000888880000000000000000000000000008088800000060000000000000000000000000000000000000000000000000000000000000000000000000000000
000188555881000000000000000000000c018000088100000000600d000000000000000000000000000000000000000000000000000000000000000000000000
000188555881000000000000000000000000005050810c000d60d000000000000000000000000000000000000000000000000000000000000000000000000000
000188858881000000111000000111d0000100a00081000000060000000000000000000000000000000000000000000000000000000000000000000000000000
000088858880000000888822c88888d0000008a54000080000000000000000000000000000000000000000000000000000000000000000000000000000000000
000022252220000008888822ccddd850800000900e900000060d0d00000000000000000000000000000000000000000000000000000000000000000000000000
000022222220000008558822ccd6d8500000e99240a0008000000600000000000000000000000000000000000000000000000000000000000000000000000000
0000ccccccc0000008555552ccd6d8500000eac440040880d00d000d000000000000000000000000000000000000000000000000000000000000000000000000
00008ccccc80000008558822ccd6d8500000a044ce04080000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008ddddd80000008888822ccddd85000000d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00018d666d81000000888822c88888d080000d600080000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00018ddddd81000000111000000111d008000d9dd001000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00018888888100000000000000000000000000a90001000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd55555dd00000000000000000000000d059050d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
