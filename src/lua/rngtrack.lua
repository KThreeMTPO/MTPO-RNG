
local bignibblehist = {};
local littlenibblehist = {};
local bytehist = {};
local last3hist = {};

local rngAddr = 0x0018
gui.opacity(0.75);
function rngUpdated()
    newRng = memory.readbyte(rngAddr);
    lastNibble = bit.band(0x0F, newRng);
    firstNibble = bit.band(0xF0, newRng)/16;
    
    last3 = bit.band(0x07, newRng);
    registerEntry(bytehist, newRng);
    registerEntry(bignibblehist, firstNibble);
    registerEntry(littlenibblehist, lastNibble);
    registerEntry(last3hist, last3);
end

function registerEntry(table, index)
    current = table[index+1]
    if (current == nil) then
    current = 0;
    table[index+1] = 0;
    end
    table[index+1] = current+1;
end

function drawHistogram(x, y, name, hist)
    i =0;
    gui.drawtext(x,y, name);
    line = 0;
    col = 0;
    for k,v in ipairs(hist) do
	line = i*9+y+10;
        gui.drawtext(col*70 + x, line, string.format("%X", k-1) .. " : " .. v)
        i=i+1
        if (i % 20==0) then
            col = col+1
            i = 0
        end
    end
end


-- uncomment this if you want to track RNG each time it's used.
--memory.register(rngAddr, rngUpdated)

while (true) do

	rngUpdated(); --comment this out if you want to track rng each time it's used.
    drawHistogram(0, 25, "3LSB", last3hist);
    drawHistogram(90, 25, "Big Nibble",  bignibblehist);
    drawHistogram(180, 25, "Small Nibble", littlenibblehist);
	gui.drawtext(0, 120, "rng: " .. string.format("%X",memory.readbyte(rngAddr)));
	gui.drawtext(0, 130, "controller: " .. string.format("%X", memory.readbyte(0x0019)));
	gui.drawtext(0, 140, "clock: " .. string.format("%X", memory.readbyte(0x001E)));
    FCEU.frameadvance();
end
