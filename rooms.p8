pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	minimap=0
	debug={}
	rooms={}
	ways={}
	doors={}
	map_w=1024
	map_h=256
	p={sp=4,
							x=64,
							y=64,
							dx=0,
							dy=0}
	debug[1]=minimap
end

function _update()
	p.dx=0
	p.dy=0
	if btnp(🅾️) then
		clearmap()
		mkmaze()
		mkway()
		setways()
		setdoors()
		setpl()
	end
	
	if btnp(❎) then
		minimap+=1
		if minimap>1 then
			minimap=0
		end
	end
	debug[1]=minimap
	if btnp(⬆️) then
		p.dy=-1
	end
	if btnp(⬇️) then
		p.dy=1
	end
	if btnp(⬅️) then
		p.dx=-1
	end
	if btnp(➡️) then
		p.dx=1
	end
	
	if hit((p.x+p.dx),p.y,7,7,0) then
		--p.dx*=-1
		p.dx=0
	end
  	
	if hit(p.x,(p.y+p.dy),7,7,0) then
		--p.dy*=-1
		p.dy=0
	end

		
	p.x+=8*p.dx
	p.y+=8*p.dy
	
end

function _draw()
	cls()
	map()
	cam(p.x,p.y)
	prdebug()
	if minimap==1 then
		drrooms()
	end
	spr(p.sp,p.x,p.y)
end

function mkmaze()
	local minrooms=6
	local maxrooms=13
	local maxw=12
	local maxh=12
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
			local ix=1--flr(rnd(1))
			local iy=flr(rnd(30-h))+1
			
			if #rooms>1 then
				local i=#rooms-1
				ix=rooms[i].x+rooms[i].x2+flr(rnd(2)+2)
				if ix+w>127  then
					ix-=ix+w-127
				end
			end
			
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
	--carving rooms
	for r in all(rooms) do
		local ix=r.x
		local iy=r.y
		local w=r.x2
		local h=r.y2
		for x=0,w do
			for y=0,h do
				mset(x+ix,y+iy,2)
			end
		end
	end
	
	
	debug[0]=#rooms
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
	for x=0,127 do
		for y=0,31 do
			mset(x,y,0)
		end
	end
end


function mkway()
	
	for i=1,#rooms-1 do
		local x1=(2*rooms[i].x+rooms[i].x2)/2
		local y1=(2*rooms[i].y+rooms[i].y2)/2
		local x2=(2*rooms[i+1].x+rooms[i+1].x2)/2
		local y2=(2*rooms[i+1].y+rooms[i+1].y2)/2
		local w={x1=x1,
											y1=y1,
											x2=x2,
											y2=y2}
		add(ways,w)									
	end
	

end

function setways()
	for w in all(ways) do
		local x1=w.x1
		local y1=w.y1
		local x2=w.x2
		local y2=w.y2
		
		
		while abs(x1-x2)>1 do
			mset(x1,y1,2)
			mset(x1,y1+1,2)
			if x1-x2<0 then 
				x1+=1
			else
				x1-=1
			end
		end
		
		while abs(y1-y2)>1 do
			mset(x1,y1,2)
			mset(x1+1,y1,2)
			if y1-y2<0 then 
				y1+=1
			else
				y1-=1
			end
		end
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
end

function setdoors()
	for r in all(rooms) do
		local ix=r.x-1
		local iy=r.y-1
		local w=r.x2+2
		local h=r.y2+2
		for x=0,w do
			if mget(x+ix,iy)==2 then
				mset(x+ix,iy,5)
			end	
			if mget(x+ix,iy+h)==2 then
				mset(x+ix,iy+h,5)
			end
		end
		for y=0,h do
			if mget(ix,y+iy)==2 then
				mset(ix,y+iy,5)
			end	
			if mget(ix+w,y+iy)==2 then
				mset(ix+w,y+iy,5)
			end
		end
	end
end

function drrooms()
	local x=camx
	local y=camy
	rectfill(x,y,x+127,y+31,0)
	rect(x,y,x+127,y+31,8)
	for r in all(rooms) do
		local rx=r.x+x
		local ry=r.y+y
		rect(rx,ry,rx+r.x2,ry+r.y2,8)
	end
	pset(x+flr(p.x/8),y+flr(p.y/8),12)
	
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
	for i=0,#debug do
		print(debug[i],x+3,y+i*9,7)
		print(debug[i],x+5,y+i*9,7)
		print(debug[i],x+4,y+1+i*9,7)
		print(debug[i],x+4,y+-1+i*9,7)
		print(debug[i],x+4,y+i*9,8)
	end
end


__gfx__
0000000055555551000000007777777d008888001111111200000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000050000001000000007666666d0e0000e01444444200000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070050000001000000007666666d80e00e081444444200000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700050000001000000007667d66d800990081444444200000000000000000000000000000000000000000000000000000000000000000000000000000000
000770005000000100000000766dd66d800990081444444200000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700500000010000d0007666666d80e00e081444444200000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000050000001000000007666666d0e0000e01444444200000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001111111100000000dddddddd008888002222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
