pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	debug={}
	rooms={}
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
end

function mkmaze()
	local minrooms=6
	local maxrooms=13
	local maxw=12
	local maxh=12
	local nrooms=flr(rnd(maxrooms-minrooms))+minrooms

	
	for x=0,127 do
		mset(x,0,2)
		mset(x,31,2)
	end
	for y=0,31 do
		mset(0,y,2)
		mset(127,y,2)
	end
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
	end
end
function clearmap()
	rooms={}
	for x=0,127 do
		for y=0,31 do
			mset(x,y,0)
		end
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
end
__gfx__
00000000dddddddd33333333eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd33333333eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700dddddddd33333333eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000dddddddd33333333eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000dddddddd33333333eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700dddddddd33333333eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd33333333eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd33333333eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
