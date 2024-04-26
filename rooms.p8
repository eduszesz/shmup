pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	debug={}
	rooms={}
	doors={}
	ways={}
	camx=0
	camy=0
	dx=0
	dy=0
	
end

function _update()
	dx=0
	dy=0
	if btnp(🅾️) then
		clearmap()
		mkmaze()
		scandoors()
		mkway()
		setways()
	end
	
	if btnp(⬆️) then
		dy=-8
	end
	if btnp(⬇️) then
		dy=8
	end
	if btnp(⬅️) then
		dx=-8
	end
	if btnp(➡️) then
		dx=8
	end
	camx+=dx
	camy+=dy
	
end

function _draw()
	cls(15)
	map()
	camera(camx,camy)
	prdebug()
	drrooms()
	drways()
	spr(4,camx,camy)
end

function mkmaze()
	local minrooms=6
	local maxrooms=13
	local maxw=12
	local maxh=12
	local nrooms=flr(rnd(maxrooms-minrooms))+minrooms

	--[[
	for x=0,127 do
		mset(x,0,2)
		mset(x,31,2)
	end
	for y=0,31 do
		mset(0,y,2)
		mset(127,y,2)
	end]]
	for x=0, 127 do
		for y=0, 31 do
			mset(x,y,1)
		end
	end
	
	
	
	
	while #rooms<nrooms do
		for i=1, nrooms-#rooms do
			local w=maxw-flr(rnd(8))
			local h=maxh-flr(rnd(8))
			local ix=0--flr(rnd(1))
			local iy=flr(rnd(32-h))
			
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
				--del(rooms,r)
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
	
	
	--[[ --draw rooms
	for r in all(rooms) do
		local ix=r.x
		local iy=r.y
		local w=r.x2
		local h=r.y2
		
		for x=0,w do
				mset(x+ix,iy,1)
				mset(x+ix,iy+h,1)
				if x==flr(w/2) then
					mset(x+ix,iy,3)
					mset(x+ix,iy+h,3)					
				end
		end
		for y=0,h do
				mset(ix,y+iy,1)
				mset(ix+w,y+iy,1)
				if y==flr(h/2) then
					mset(ix,y+iy,3)
					mset(ix+w,y+iy,3)
				end
		end		
	end]]
	debug[0]=#rooms
end
function clearmap()
	rooms={}
	doors={}
	ways={}
	for x=0,127 do
		for y=0,31 do
			mset(x,y,0)
		end
	end
end

function scandoors()
	for x=0,127 do
		for y=0,31 do
			if mget(x,y)==3 then
				local d={x=x,y=y,
														box={x1=0,y1=0,x2=1,y2=1}}
				add(doors,d)
			end
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
	--[[
	for i=1,#doors do
		for j=1,#doors do
			if i!=j then
				for r in all(rooms) do
					if coll(r,doors[i]) and
					not  coll(r,doors[j]) then
						if abs(doors[i].x-doors[j].x)<8 and
							abs(doors[i].y-doors[j].y)<8 then
							local w={x1=doors[i].x,
															y1=doors[i].y,
															x2=doors[j].x,
															y2=doors[j].y}
							add(ways,w)
						end										
					end
				end
			end
		end
	end]]

end

function setways()
	for w in all(ways) do
		local x1=w.x1
		local y1=w.y1
		local x2=w.x2
		local y2=w.y2
		
		
		while abs(x1-x2)>1 do
			mset(x1,y1,2)
			if x1-x2<0 then 
				x1+=1
			else
				x1-=1
			end
		end
		
		while abs(y1-y2)>1 do
			mset(x1,y1,2)
			if y1-y2<0 then 
				y1+=1
			else
				y1-=1
			end
		end
	end
end

function drways()
	for w in all(ways) do
		--line(w.x1,w.y1,w.x2,w.y2,8)
	end
end

function drrooms()
	local x=camx
	local y=camy
	rect(x,y,x+127,y+31,8)
	for r in all(rooms) do
		local rx=r.x+x
		local ry=r.y+y
		rect(rx,ry,rx+r.x2,ry+r.y2,8)
	end
	pset(x+flr(x/8),y+flr(y/8),12)
	for d in all(doors) do
		local dx=d.x+x
		local dy=d.y+y
		pset(dx,dy,14)
	end 
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
	for i=0,#debug do
		print(debug[i],3,i*9,7)
		print(debug[i],5,i*9,7)
		print(debug[i],4,1+i*9,7)
		print(debug[i],4,-1+i*9,7)
		print(debug[i],4,i*9,8)
	end
end


__gfx__
00000000dddddddd33333333eeeeeeee008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd33333333eeeeeeee0e0000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700dddddddd33333333eeeeeeee80e00e080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000dddddddd33333333eeeeeeee800ee0080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000dddddddd33333333eeeeeeee800ee0080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700dddddddd33333333eeeeeeee80e00e080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd33333333eeeeeeee0e0000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd33333333eeeeeeee008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
