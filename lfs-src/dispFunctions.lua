local M = {}
local state = -1
local currency = 0
--[[
  Possible states:
  -1 - failed
  0 - change and animate currency logo
  <1,5> - show price
  <6-10> - 7Day change
  <11-15> - 24H change
]]--

function M.initOled()
  i2c.setup(0, LFS.config().sda, LFS.config().scl, i2c.SLOW)
  return (u8g2.ssd1306_i2c_64x48_er(0, LFS.config().sla))
end

function M.u8g2_prepare(display)
  display:setFont(u8g2.font_6x10_tf)
  display:setFontRefHeightExtendedText()
  display:setDrawColor(1)
  display:setFontPosTop()
  display:setFontDirection(0)
end

function M.drawMessage(display, msg)
  display:setBitmapMode(0)
  display:drawXBM(0, 0, 63, 32, string.char(LFS.bitmaps().CMC()))
  local x = math.floor((64 - display:getStrWidth(msg)) / 2)
  display:drawStr(x, 33, msg)  
end

-- Important: this function have to draw shorter than frameTime
-- TODO: Smoother animation when I2C rework PR will be merged
local function animateLogo(display, logo)
 display:setBitmapMode(0)
 local logoY = -32
 local deltaT = math.floor(LFS.config().frameTime / 4)
 local bitmap = string.char(LFS.bitmaps()[logo]())
 local timer = tmr.create()
 timer:alarm(deltaT, tmr.ALARM_AUTO, function()
   display:clearBuffer()
   display:drawXBM(0, logoY, 64, 32, bitmap)     
   display:sendBuffer()
   if logoY >= 0 then timer:unregister() end
   logoY = logoY + 16
   collectgarbage() -- To prevent E:M messages
 end) 
end

local function drawLogo(display, logo)
  display:drawXBM(0, 0, 64, 32, string.char(LFS.bitmaps()[logo]()))
end

local function drawPrice(display, price)
  local formattedPrice = '$'..string.format("%.2f", price)
  local x = math.floor((64 - display:getStrWidth(formattedPrice)) / 2)
  display:drawStr(x, 33, tostring(formattedPrice))
end

local function drawPercent(display, percent, msg)
  local formattedChange = msg..string.format("%.2f", percent)..'%'
  local x = math.floor((64 - display:getStrWidth(formattedChange)) / 2)
  display:drawStr(x, 33, tostring(formattedChange))
end


local function draw(display, data)
  local curr = LFS.config().coins[currency]
  -- reset counter:
  if state > 15 then state = 0 end
  
  if state < 0 then
    M.drawMessage(display, "Failed!")
  elseif state == 0 then
    if LFS.config().coins[currency + 1] ~= nil then
      currency = currency + 1
    else
      currency = 1      
    end
    curr = LFS.config().coins[currency]
    animateLogo(display, data.data[curr].symbol)
    state = state + 1
  elseif state > 0 and state <= 5 then
    drawLogo(display, data.data[curr].symbol)
    drawPrice(display, data.data[curr].quote.USD.price)
    state = state + 1
  elseif state > 5 and state <=10 then
    drawLogo(display, data.data[curr].symbol)
    drawPercent(display, data.data[curr].quote.USD.percent_change_7d, "7D:") 
    state = state + 1
  elseif state > 10 and state <= 15 then
    drawLogo(display, data.data[curr].symbol)
    drawPercent(display, data.data[curr].quote.USD.percent_change_24h, "24H:")  
    state = state + 1
  end
  return state, currency
end

function M.drawLoop(disp, data, success)
  if success then state = 0 end
  tmr.create():alarm(LFS.config().frameTime, tmr.ALARM_AUTO, function()
    if disp ~= nil then
      disp:clearBuffer()
      draw(disp, data, state, currency)
      disp:sendBuffer()
    end
  end)
end

return M