pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--arkanoid
--by eduszesz

function _init()
	p={sp=1,x=2,y=120,dx=0,dy=0, box={x1=0,y1=0,x2=15,y2=5}}
	b={sp=3,x=p.x+4,y=p.y-6,dx=1, dy=1, v=3, ang=0.18, box={x1=2,y1=2,x2=5,y2=5}}
	bs="on pad" -- ball state
	
end

function _update()
	p.dx=0
	p.dy=0
	if btn(⬅️) then
		p.dx=-4
	end
	if btn(➡️) then
		p.dx=4
	end
	p.x+=p.dx
	p.y+=p.dy
	if bs=="on pad" then
		b.x+=p.dx
	end
	
	if btnp(5) then
		bs = "moving"
	end
	if bs=="moving" then
		
		if b.x>120 or b.x<0 then
			reflect("x")
		end
		if b.y>127 or b.y<1 then
			reflect("y")
		end
		
		if coll(p,b) then
			b.ang+=0.2-rnd(0.3)
			reflect("x")
			reflect("y")
		end
		
		b.x+=b.v*cos(b.ang)*b.dx
		b.y+=b.v*sin(b.ang)*b.dy
	end
	
	if btnp(4) then
		_init()
	end
	
end

function _draw()
	cls()
	rrect(p.x,p.y,15,4,2,11)
	rrect(b.x,b.y,4,4,2,11)
	--spr(p.sp,p.x,p.y,2,1)
	--spr(b.sp,b.x,b.y)
	rect(0,0,127,127,7)
	--rect(p.x+p.box.x1,p.y+p.box.y1,p.x+p.box.x2,p.y+p.box.y2,10)
	--rect(b.x+b.box.x1,b.y+b.box.y1,b.x+b.box.x2,b.y+b.box.y2,10)
end

function reflect(_dir) --_dir ="x" or "y"
	local dir=_dir
	if dir=="x" then
		if b.dx==1 then
			b.dx=-1
		else
			b.dx=1
		end
	end
	if dir=="y" then
		if b.dy==1 then
			b.dy=-1
		else
			b.dy=1
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

__gfx__
00000000066666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000611111111111111600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700055555555555555000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000566500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000566500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
