pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	local ix=flr(rnd(8)+2)
	local iy=flr(rnd(8)+2)
	local w=flr(rnd(8)+4)
	local h=flr(rnd(8)+4)

	for x=ix,w do
			mset(x,iy,1)
			mset(x,h,1)
	end
	for y=iy,h do
			mset(ix,y,1)
			mset(w,y,1)
	end
end

function _update()


end

function _draw()
	cls()
	map()
end

__gfx__
00000000ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
