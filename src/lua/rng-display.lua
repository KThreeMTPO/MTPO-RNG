local frameCounterAddr = 0x001E;
local controllerAddr = 0x0019;
local rngAddr = 0x0018;

local frameCounter;
local controller;
local rng;

function drawUI()

	gui.drawtext(0,50, string.format("frame counter:%d\t%X\t%s", frameCounter, frameCounter, toBits(frameCounter)));
	gui.drawtext(0,75, string.format("controller:\t%d\t%X\t%s", controller, controller, toBits(controller)));
	gui.drawtext(0,100, string.format("rng:\t%d\t%X\t%s", rng, rng, toBits(rng)));
end


function toBits(num)
    local bits = 8;
    -- returns a table of bits
    local t={} -- will contain the bits
    for b=bits,1,-1 do
        rest=math.fmod(num,2)
        t[b]=rest
        num=(num-rest)/2
    end
    return table.concat(t);
end

while(true) do
	frameCounter = memory.readbyte(frameCounterAddr);
	controller = memory.readbyte(controllerAddr);
	rng = memory.readbyte(rngAddr);
	drawUI();
	FCEU.frameadvance();
end