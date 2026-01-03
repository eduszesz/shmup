pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--topshooter+rooms
--by eduszesz

function _init()
	t=0
	mx=0
	my=16
	md=0.06
	map_w=1024 --1024
	map_h=256 --256
	rooms={}
	debug={}
	initialize()
	
	--mkmap(0,0,0)
	--clearmap()
	--mkmaze()
	

end

function _update()
	t+=1
	
	if state=="start" then
		if btnp(🅾️) then
			state="game"
			clearmap()
			mkmaze()
			setpl()
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
	if state=="start" then
		print("press 🅾️ to start",30,64,0)
	end
	
	if state=="game" then
		draw_game()
	end
	
	if state=="over" then
		print("press 🅾️ to play again",20,64,0)
	end
	prdebug()

end

function initialize()
	minimap=0
	debug={}
	rooms={}
	ways={}
	doors={}
	tledoors={}
	tleways={}
	fog={}
	auxt={}
	
	frate=3
	state="start"
	camx=0
	camy=0
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
	
	coldoors()
	opendoors()
	
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
	drhud()
end

function updbullets()
	for b in all(bullets) do
		if hit((b.x+b.dx),b.y,2,2,0) then 
			mksparks(b,13)
			del(bullets,b)
		end
		
		if hit((b.x+b.dx),b.y,2,2,1) then 
			mksparks(b,4)
			del(bullets,b)
		end
  	
		if hit(b.x,(b.y+b.dy),2,2,0) then
			mksparks(b,13)
			del(bullets,b)
		end
		
		if hit(b.x,(b.y+b.dy),2,2,1) then
			mksparks(b,4)
			del(bullets,b)
		end
		
		b.x+=b.dx
		b.y+=b.dy
		
		if abs(b.x-b.ix)>80 or
			abs(b.y-b.iy)>80 then
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
	local ox,oy=4,-4
	local sox,soy=5,0
	local sp=9
	if p.sp==5 or p.sp==6 then
		dx,dy=0,1
		ox,oy=1,4
		sox,soy=2,8
	end
	if p.sp==3 or p.sp==4 then
		dx,dy=-1,0
		ox,oy=-2,2
		sox,soy=0,2
		sp=10
	end
	if p.sp==7 or p.sp==8 then
		dx,dy=1,0
		ox,oy=2,4
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
										box={x1=0,y1=0,x2=2,y2=7}}
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
	local x=rnd(map_w)--rnd(map_w-16)+8
	local y=rnd(map_h)--rnd(map_h-16)+8
	local dx,dy=0,0
	local typ="sdr"
	local sp=1
	local sz=1
	if pi=="up" then
		--y=-10
		dy=1
	end
	if pi=="down" then
		--y=map_h+2
		dy=-1
	end
	if pi=="left" then
		--x=-10
		dx=1
	end
	if pi=="right" then
		--x=map_w+2
		dx=-1
	end
	--if rnd()<0.5 then
	if mget(x/8,y/8)==48 then
		typ="jipe"
		sp=64
		--y=-10
		--x=rnd(map_w-16)+8
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
	if mget(x/8,y/8)==48 or
		mget(x/8,y/8)==49 then
		add(enemies,e)
	end
	
	add(enemies,e)									
end

function upenemies()
	
	if #enemies<25 and t%30==0 then
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
		if e.x>map_w+20 or e.x<-20
			or e.y>map_h+20 or e.y<-20 then
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

function mksparks(_obj,_c)
	local p=_obj
	local crx,cry=4,4
	local c=_c
	if c==nil then c=8 end
	if p.typ=="jipe" then
		crx,cry=8,8
	end
	if p.typ=="bull" then
		if p.dx==0 then
			cry=p.dy
			crx=0
		else
			crx=p.dx
			cry=0
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
											t=120}
	add(corpses,cr)
end

function upcorpses()
	for cr in all(corpses) do
		cr.t-=1
		if cr.sp!=68 then
			if cr.t==90 then
				cr.sp=12
			end
			if cr.t==60 then
				cr.sp=13
			end
		else
			mkfumes(cr)	
		end
		if cr.t==30 then
			if cr.sp==68 then
				cr.sp=70			
			else
				cr.sp=14
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

function drhud()
	line(camx,camy+128,camx,camy+128-12.8*p.h,8)
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


function cam(_x,_y)
	camx,camy=_x-64,_y-64
	if camx<0 then --camera lower x limit
		camx=0
	end
	
	if camx>(map_w-128) then --camera upper x limit
		camx=(map_w-128)
	end
	
	if camy<0 then --camera lower y limit
		camy=0
	end
	
	if map_h<128 then --camera upper y limit
		camy=-32
	end
	if camy>=(map_h-128) and
	map_h>=128 then
		camy=map_h-128
	end
	camera(camx,camy)
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

function prdebug()
	for i=0,#debug do
		print(debug[i],3,i*9,7)
		print(debug[i],5,i*9,7)
		print(debug[i],4,1+i*9,7)
		print(debug[i],4,-1+i*9,7)
		print(debug[i],4,i*9,8)
	end
end

function mkmaze()
	local minrooms=6
	local maxrooms=11
	local maxw=14
	local maxh=14
	local nrooms=flr(rnd(maxrooms-minrooms))+minrooms

	for x=0, 127 do
		for y=0, 31 do
			mset(x,y,48)
		end
	end
	
	
	while #rooms<nrooms do
		for i=1, nrooms-#rooms do
			local w=maxw-flr(rnd(8))
			local h=maxh-flr(rnd(8))
			local ix=flr(rnd(127-w))+1
			local iy=flr(rnd(30-h))+1
			
			--[[
			if #rooms>1 then
				local j=#rooms-1
				if rnd()>0.9 then
					ix=3
					iy=30-h
				else
					ix=rooms[j].x+rooms[j].x2+flr(rnd(2)+4)
					iy=flr(rnd(30-h))+1
				end
				if ix+w>127  then
					ix-=ix+w-125
				end
			end]]
			
			local r={x=ix,
												y=iy,
												x2=w,
												y2=h,
												d=false,
												box={x1=0,y1=0,x2=w,y2=h}}
												
				
			add(rooms,r)
					
		end
		sortbyx(rooms)
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
	
	mkway()
	setways()
	--carving rooms
	for r in all(rooms) do
		local ix=r.x
		local iy=r.y
		local w=r.x2
		local h=r.y2
		for x=1,w-1 do
			for y=1,h-1 do
				mset(x+ix,y+iy,49)
			end
		end
	end
	--test()
	setdoors()
	getways()
	
end

function setpl()
	for x=0,127 do
		for y=0,31 do
			if mget(x,y)==49 then
				p.x=x*8
				p.y=y*8
				return
			end
		end
	end
end

function clearmap()
	rooms={}
	ways={}
	doors={}
	tledoors={}
	tleways={}
	fog={}
	for x=0,127 do
		for y=0,31 do
			mset(x,y,0)
		end
	end
end


function mkway()
	
	for i=1,#rooms-1 do
		local x11=rooms[i].x
		local y11=rooms[i].y
		local x12=rooms[i].x+rooms[i].x2
		local y12=rooms[i].y+rooms[i].y2
		
		local x21=rooms[i+1].x
		local y21=rooms[i+1].y
		local x22=rooms[i+1].x+rooms[i+1].x2
		local y22=rooms[i+1].y+rooms[i+1].y2
		
		local x1m=(x11+x12)/2
		local y1m=(y11+y12)/2
		local x2m=(x21+x22)/2
		local y2m=(y21+y22)/2
		
		local xf=true
		
		if rnd()>0.5 then
			xf=false
		else
			xf=true
		end
		
		if abs(y1m-y21)<3 then  
			if abs(y12-y21)>1 then
				y1m=(y12+y21)/2
				y2m=y1m
			else
				xf=false
			end
		end
		
		if abs(y1m-y22)<3 then
			if abs(y11-y22)>1 then
				y1m=(y11+y22)/2
				y2m=y1m
			else
				xf=false
			end
		end
		
		if abs(x1m-x21)<3 then
			if abs(x21-x12)>1 then
				x1m=(x21+x12)/2
				x2m=x1m
			else
				xf=true
			end
		end
		
		if abs(x1m-x22)<3 then
			if abs(x11-x22)>1then
				x1m=(x11+x22)/2
				x2m=x1m
			else
				xf=true
			end
		end
				
		local w={x1=x1m,
											y1=y1m,
											x2=x2m,
											y2=y2m,
											xf=xf}
		add(ways,w)									
	end
	

end

function setways()
	for w in all(ways) do
		
		auxt={w.x1,w.y1,w.x2,w.y2}
		if w.xf then
			xways(unpack(auxt))		
			yways(unpack(auxt))		
		else	
			yways(unpack(auxt))		
			xways(unpack(auxt))	
		end
	end
end

function xways(x1,y1,x2,y2)
	while abs(x1-x2)>1 do
		local c={x=x1,
										y=x2,
										box={x1=0,y1=0,x2=1,y2=1}}
		for r in all(rooms) do
			if not coll(r,c) do
				mset(x1,y1,49)
				mset(x1,y1+1,49)
			end
		end
		
		if x1-x2<0 then 
			x1+=1
		else
			x1-=1
		end
	end
	auxt={x1,y1,x2,y2}
end

function yways(x1,y1,x2,y2)
	while abs(y1-y2)>1 do
		local c={x=x1,
										y=x2,
										box={x1=0,y1=0,x2=1,y2=1}}
		for r in all(rooms) do
			if not coll(r,c) do
				local i=0
				if y1-y2>0 then
					i=1
				end
				mset(x1,y1+i,49)
				mset(x1+1,y1+i,49)	
			end
		end
		
		if y1-y2<0 then 
			y1+=1
		else
			y1-=1
		end
	end
	auxt={x1,y1,x2,y2}	
end

function getways()
	for x=0,127 do
		for y=0,31 do
			if mget(x,y)==49 then
				local w={x=x,y=y}
				add(tleways,w)
			end
		end
	end
end

function setdoors()
	for x=0,127 do
		mset(x,0,48)
		mset(x,31,48)
	end
	for y=0,31 do
		mset(0,y,48)
		mset(127,y,48)
	end
	for x=0, 127 do
		for y=0, 31 do
			if mget(x,y)==48 then
				if mget(x+1,y)==49 or
					mget(x-1,y)==49 or
					mget(x,y+1)==49 or
					mget(x,y-1)==49 or
					mget(x-1,y-1)==49 or
					mget(x+1,y+1)==49 or
					mget(x-1,y+1)==49 or
					mget(x+1,y-1)==49 then
						mset(x,y,50)
				end
			end
		end
	end
	for r in all(rooms) do
		local ix=r.x
		local iy=r.y
		local w=r.x2
		local h=r.y2
		local du={}
		local db={}
		local dl={}
		local dr={}
		for x=0,w do
			if mget(x+ix,iy)==49 then
				--mset(x+ix,iy,4)
				add(du,{x=x+ix,y=iy})
			end	
			if mget(x+ix,iy+h)==49 then
				--mset(x+ix,iy+h,4)
				add(db,{x=x+ix,y=iy+h})
			end
		end
		for y=0,h do
			if mget(ix,y+iy)==49 then
				--mset(ix,y+iy,4)
				add(dl,{x=ix,y=y+iy})
			end	
			if mget(ix+w,y+iy)==49 then
				--mset(ix+w,y+iy,4)
				add(dr,{x=ix+w,y=y+iy})
			end
		end
		if #du<6 then
			for d in all(du) do
				mset(d.x,d.y,51)
			end
		end
		if #db<6 then
			for d in all(db) do
				mset(d.x,d.y,51)
			end
		end
		if #dl<6 then
			for d in all(dl) do
				mset(d.x,d.y,51)
			end
		end
		if #dr<6 then
			for d in all(dr) do
				mset(d.x,d.y,51)
			end
		end
	end
	for x=0,127 do
		for y=0,31 do
			if mget(x,y)==51 then
				 local d={x=x,y=y}
				 add(tledoors,d)
			end
		end
	end

	for d in all(tledoors) do
		local sum=0
					
		for i=-1,1,2 do
			if mget(d.x+i,d.y)==49 then
						sum+=1
			end
		end	
		for j=-1,1,2 do	
			if mget(d.x,d.y+j)==49 then
				sum+=1
			end
		end
		if sum==3 then
		local x,y=0,0
		for i=-1,1,2 do
			if mget(d.x+i,d.y)==50 then
				x=d.x+(i*-1)
				y=d.y
				mset(x,y,54)		
			end
		end	
		for j=-1,1,2 do	
			if mget(d.x,d.y+j)==50 then
				x=d.x
				y=d.y+(j*-1)
				mset(x,y,54)
			end
		end
	end
	end
	
	
end

function ydoors(x,y,j)
 local _j=j
 local j=0
	while mget(x+j,y)>=51 do 
		local i=1
		while mget(x+j,y+i)>=51 do
			mset(x+j,y+i,53)
			i+=1
		end
		i=-1
		while mget(x+j,y+i)>=51 do
			mset(x+j,y+i,53)
			i-=1
		end
		if mget(x+j,y)>=51 then
			mset(x+j,y,53)
			i=1
		end
		j+=_j
	end

end

function xdoors(x,y,j)
	local _j=j
	while mget(x,y+j)>=51 do
		local i=1
		while mget(x+i,y+j)>=51 do
			mset(x+i,y+j,53)
			i+=1
		end
		i=-1
		while mget(x+i,y+j)>=51 do
			mset(x+i,y+j,53)
			i-=1
		end
		if mget(x,y+j)>=51 then
			mset(x,y+j,53)
			i=1
		end
		j+=_j
	end
end

function coldoors()
	if hit((p.x+p.dx),p.y,7,7,1) then
		local d={x=flr((p.x+p.dx)/8),
											y=flr(p.y/8),
											dir="x"}
		add(doors,d)
		p.dx=0
	end
  	
	if hit(p.x,(p.y+p.dy),7,7,1) then
		local d={x=flr(p.x/8),
											y=flr((p.y+p.dy)/8),
									dir="y"}
		add(doors,d)
		p.dy=0
	end
end

function opendoors()
	for d in all(doors) do
		local x,y=d.x,d.y
		ydoors(x,y,1)
		ydoors(x,y,-1)
		xdoors(x,y,1)
		xdoors(x,y,-1)		
	end
end

function drrooms()
	local x=camx
	local y=camy
	local i=1
	rectfill(x,y,x+127,y+31,0)
	rect(x,y,x+127,y+31,8)
	for w in all(tleways) do
		local wx=w.x+x
		local wy=w.y+y
		pset(wx,wy,2)
	end
	for r in all(rooms) do
		local rx=r.x+x
		local ry=r.y+y
		rect(rx,ry,rx+r.x2,ry+r.y2,8)
		print(i,rx+2,ry+2,7)
		i+=1
	end
	for d in all(tledoors) do
		local dx=d.x+x
		local dy=d.y+y
		pset(dx,dy,7)
	end
	
	pset(x+flr(p.x/8),y+flr(p.y/8),12)
	
end

function  mkfog()
	for x=0,127 do
		for y=0,31 do
			local tle=mget(x,y)
			if tle>1 then
				local f={x=x*8,
													y=y*8,
													flag=fget(tle),
													box={x1=0,y1=0,x2=7,y2=7}}
				add(fog,f)
			end
		end
	end
end

function drfog()
	for f in all(fog) do
		local fx=f.x
		local fy=f.y
		local fx2=8+f.x
		local fy2=8+f.y
		rectfill(fx,fy,fx2,fy2,0)
	end
end

function unfog()
	for f in all(fog) do
		local _p={x=p.x,y=p.y,box={x1=-15,y1=-15,x2=23,y2=23}}
		if coll(_p,f) then
			del(fog,f)
		end
	end
end



function sortbyx(a)
    for i=1,#a do
        local j = i
        while j > 1 and a[j-1].x > a[j].x do
            a[j].x,a[j-1].x = a[j-1].x,a[j].x
            j = j - 1
        end
    end
end


__gfx__
0000000000000500000000000000000000000bbd00033d00db33d00000000000000000000800000088e7e8800000000000000000000000000000000000000000
0000000000000d00000000500000bbd005d5555b0db44b00b544b000000000000000000088000000088e7e880800440007006600000066000006000000000000
0070070000000500000000d05d5555b00000b4430b544b00b544b000dbbbd000000000008e000000000000000de3440006076600060066000006600000000000
0007700000dbb50000000050000b04430000b4430b500b0005bbd0003440b000dbbd0000e7000000000000000033000000770000007700000000000001108110
0007700000b005b0000dbb50000b04430000dbbd005bbd00050000003440b000344b00007e000000000000000e33d05000776700000060000006000000000000
0070070000b445b0000b445b000dbbbd00000000005000000d0000000b5555d5344b0000e800000000000000088ee50007700000007000000000000000000000
0000000000b44bd0000b445b000000000000000000d00000050000000dbb0000b5555d5088000000000000008085508070700000000000000000000009000000
0000000000d33000000d33bd0000000000000000005000000000000000000000dbb0000080000000000000000058050000570000000000000000000000000000
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
00000000ffffffff666666651111111200000000ffffffffcccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff6dddddd51444444200000000ffffffffcccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff6dddddd51444444200000000ffffffffcccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff6dd65dd51444444200000000ffffffffcccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff6dd55dd51444444200000000ffffffffcccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffff5fff6dddddd51444444200008000f5ff5fffcccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff6dddddd51444444200000000ffffffffcccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff555555552222222200000000ffffffffcccccccc000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
