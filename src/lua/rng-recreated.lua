
while true do
--     x_pos_0015 = memory.readbyteunsigned(0x0015)
--  if(x_pos_0015 == 181) then print("QUICK LEFT") --emu.pause()
-- end
--  if(x_pos_0015 == 178) then print("SLOW LEFT") --emu.pause()
-- end
--  if(x_pos_0015 == 175) then print("RIGHT") --emu.pause()
-- end
    inputs = memory.readbyteunsigned(0x0019)
    currentFrame = memory.readbyteunsigned(0x001E)  
    realRNG = memory.readbyteunsigned(0x0018)
    crowdMove = memory.readbyteunsigned(0x0400)    

    shifted_0019 = AND(inputs, 0x01)
  shifted_0019 = AND(inputs, 0x02) * 2 + shifted_0019
  shifted_0019 = AND(inputs, 0x04) * 4 + shifted_0019
  shifted_0019 = AND(inputs, 0x08) * 8 + shifted_0019
  shifted_0019 = AND(inputs, 0x10) / 8 + shifted_0019
  shifted_0019 = AND(inputs, 0x20) / 4 + shifted_0019
  shifted_0019 = AND(inputs, 0x40) / 2 + shifted_0019
  shifted_0019 = AND(inputs, 0x80) + shifted_0019

  shifted_001E = AND(currentFrame, 0x01) * 128
  shifted_001E = AND(currentFrame, 0x02) / 2 + shifted_001E
  shifted_001E = AND(currentFrame, 0x04) * 16 + shifted_001E
  shifted_001E = AND(currentFrame, 0x08) / 4 + shifted_001E
  shifted_001E = AND(currentFrame, 0x10) * 2 + shifted_001E
  shifted_001E = AND(currentFrame, 0x20) / 8 + shifted_001E
  shifted_001E = AND(currentFrame, 0x40) / 4 + shifted_001E
  shifted_001E = AND(currentFrame, 0x80) / 16 + shifted_001E

  calculatedRNG = (shifted_0019 + shifted_001E) % 0x100
--  messageA = "NONE"
--  if(x_pos_0015 == 181) then messageA = "QUICK LEFT" 
--  end
--  if(x_pos_0015 == 178) then messageA = "SLOW LEFT"
--  end
--  if(x_pos_0015 == 175) then messageA = "RIGHT"
--  end
  --if((shifted_0019 + shifted_001E) % 0x100 > 0) then print((shifted_0019 + shifted_001E) % 0x100)
 -- end
print(calculatedRNG .. "\t" .. realRNG .. "\t" .. crowdMove)
--    file:write(calculatedRNG, " ", messageA, "\n")

    
    
    ----print(memory.readbyte(0x18, "RAM")-128)
    --memory.writebyte(0x0019, 1)
    --memory.writebyte(0x001E, 255)
    --memory.writebyte(57, 0)
    --memory.writebyte(0x0301, 1)
    ----memory.writebyte(1, 0)
    emu.frameadvance()
end