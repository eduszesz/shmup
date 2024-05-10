pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	minimap=0
	debug={}
	rooms={}
	ways={}
	doors={}
	tledoors={}
	tleways={}
	fog={}
	auxt={}
	map_w=1024
	map_h=256
	p={sp=16,
							x=64,
							y=64,
							dx=0,
							dy=0,
							box={x1=0,y1=0,x2=7,y2=7}}
	
end

function _update()
	p.dx=0
	p.dy=0
	if btnp(🅾️) then
		clearmap()
		mkmaze()
		mkfog()
		setpl()
	end
	
	if btnp(❎) then
		minimap+=1
		if minimap>1 then
			minimap=0
		end
	end
	
	if btnp(⬆️) then
		p.dy=-8
	end
	if btnp(⬇️) then
		p.dy=8
	end
	if btnp(⬅️) then
		p.dx=-8
	end
	if btnp(➡️) then
		p.dx=8
	end
	
	if hit((p.x+p.dx),p.y,7,7,0) then
		p.dx=0
	end
  	
	if hit(p.x,(p.y+p.dy),7,7,0) then
		p.dy=0
	end
	
	if hit((p.x+p.dx),p.y,7,7,1) then
		local d={x=flr((p.x+p.dx)/8),
				y=flr(p.y/8),
				dir="x"}
				add(doors,d)
		--mset(flr((p.x+p.dx)/8),flr(p.y/8),6)
		p.dx=0
	end
  	
	if hit(p.x,(p.y+p.dy),7,7,1) then
		local d={x=flr(p.x/8),
				y=flr((p.y+p.dy)/8),
				dir="y"}
				add(doors,d)
		--mset(flr(p.y/8),flr((p.y+p.dy)/8),6)
		p.dy=0
	end
		
	p.x+=p.dx
	p.y+=p.dy
	
	opendoors()
	unfog()
end

function _draw()
	cls()
	map()
	cam(p.x,p.y)
	prdebug()
	if minimap==1 then
		drrooms()
	end
	if p.dx==0 or p.dy==0 then
		p.sp+=0.1
		if p.sp>17.9 then
			p.sp=16
		end
	else
		p.sp=16
	end
	spr(p.sp,p.x,p.y)
	drfog()
end

function mkmaze()
	local minrooms=6
	local maxrooms=11
	local maxw=14
	local maxh=14
	local nrooms=flr(rnd(maxrooms-minrooms))+minrooms

	for x=0, 127 do
		for y=0, 31 do
			mset(x,y,1)
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
				mset(x+ix,y+iy,2)
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
			if mget(x,y)==2 then
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
				mset(x1,y1,2)
				mset(x1,y1+1,2)
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
				mset(x1,y1+i,2)
				mset(x1+1,y1+i,2)	
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
			if mget(x,y)==2 then
				local w={x=x,y=y}
				add(tleways,w)
			end
		end
	end
end

function setdoors()
	for x=0,127 do
		mset(x,0,1)
		mset(x,31,1)
	end
	for y=0,31 do
		mset(0,y,1)
		mset(127,y,1)
	end
	for x=0, 127 do
		for y=0, 31 do
			if mget(x,y)==1 then
				if mget(x+1,y)==2 or
					mget(x-1,y)==2 or
					mget(x,y+1)==2 or
					mget(x,y-1)==2 or
					mget(x-1,y-1)==2 or
					mget(x+1,y+1)==2 or
					mget(x-1,y+1)==2 or
					mget(x+1,y-1)==2 then
						mset(x,y,3)
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
			if mget(x+ix,iy)==2 then
				--mset(x+ix,iy,4)
				add(du,{x=x+ix,y=iy})
			end	
			if mget(x+ix,iy+h)==2 then
				--mset(x+ix,iy+h,4)
				add(db,{x=x+ix,y=iy+h})
			end
		end
		for y=0,h do
			if mget(ix,y+iy)==2 then
				--mset(ix,y+iy,4)
				add(dl,{x=ix,y=y+iy})
			end	
			if mget(ix+w,y+iy)==2 then
				--mset(ix+w,y+iy,4)
				add(dr,{x=ix+w,y=y+iy})
			end
		end
		if #du<6 then
			for d in all(du) do
				mset(d.x,d.y,4)
			end
		end
		if #db<6 then
			for d in all(db) do
				mset(d.x,d.y,4)
			end
		end
		if #dl<6 then
			for d in all(dl) do
				mset(d.x,d.y,4)
			end
		end
		if #dr<6 then
			for d in all(dr) do
				mset(d.x,d.y,4)
			end
		end
	end
	for x=0,127 do
		for y=0,31 do
			if mget(x,y)==4 then
				 local d={x=x,y=y}
				 add(tledoors,d)
			end
		end
	end

	for d in all(tledoors) do
		local sum=0
					
		for i=-1,1,2 do
			if mget(d.x+i,d.y)==2 then
						sum+=1
			end
		end	
		for j=-1,1,2 do	
			if mget(d.x,d.y+j)==2 then
				sum+=1
			end
		end
		if sum==3 then
		local x,y=0,0
		for i=-1,1,2 do
			if mget(d.x+i,d.y)==3 then
				x=d.x+(i*-1)
				y=d.y
				mset(x,y,7)		
			end
		end	
		for j=-1,1,2 do	
			if mget(d.x,d.y+j)==3 then
				x=d.x
				y=d.y+(j*-1)
				mset(x,y,7)
			end
		end
	end
	end
	
	
end

function ydoors(x,y,j)
 local _j=j
 local j=0
	while mget(x+j,y)>=4 do 
		local i=1
		while mget(x+j,y+i)>=4 do
			mset(x+j,y+i,6)
			i+=1
		end
		i=-1
		while mget(x+j,y+i)>=4 do
			mset(x+j,y+i,6)
			i-=1
		end
		if mget(x+j,y)>=4 then
			mset(x+j,y,6)
			i=1
		end
		j+=_j
	end

end

function xdoors(x,y,j)
	local _j=j
	while mget(x,y+j)>=4 do
		local i=1
		while mget(x+i,y+j)>=4 do
			mset(x+i,y+j,6)
			i+=1
		end
		i=-1
		while mget(x+i,y+j)>=4 do
			mset(x+i,y+j,6)
			i-=1
		end
		if mget(x,y+j)>=4 then
			mset(x,y+j,6)
			i=1
		end
		j+=_j
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
	local x,y=camx,camy
	if #debug>0 then
		for i=1,#debug do
			print(debug[i],x+3,y+i*9,7)
			print(debug[i],x+5,y+i*9,7)
			print(debug[i],x+4,y+1+i*9,7)
			print(debug[i],x+4,y+-1+i*9,7)
			print(debug[i],x+4,y+i*9,8)
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
0000000055555551000000007777777d1111111200000000eeeeeeeecccccccc0000000000000000000000000000000000000000000000000000000000000000
0000000050000001000000007666666d1444444200000000eeeeeeeecccccccc0000000000000000000000000000000000000000000000000000000000000000
0070070050000001000000007666666d1444444200000000eeeeeeeecccccccc0000000000000000000000000000000000000000000000000000000000000000
0007700050000001000000007667d66d1444444200000000eeeeeeeecccccccc0000000000000000000000000000000000000000000000000000000000000000
000770005000000100000000766dd66d1444444200000000eeeeeeeecccccccc0000000000000000000000000000000000000000000000000000000000000000
00700700500000010000d0007666666d1444444200008000eeeeeeeecccccccc0000000000000000000000000000000000000000000000000000000000000000
0000000050000001000000007666666d1444444200000000eeeeeeeecccccccc0000000000000000000000000000000000000000000000000000000000000000
000000001111111100000000dddddddd2222222200000000eeeeeeeecccccccc0000000000000000000000000000000000000000000000000000000000000000
00888800008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08dddd8008d77d800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8dd77dd88d77d7d80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8d77d7d88d7dd7d80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8d7dd7d28d7dd7d20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8d7dd7d28dd77d720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08d77d70002222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
