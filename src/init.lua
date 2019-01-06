local disp = nil
local data = nil
local success = false

local function getPrice()
  disp = nil -- Remove display - buffer in display will keep content and those 2kb of RAM is important
  collectgarbage()
  print("Heap before handshake:", node.heap())
  tls.cert.verify(LFS.config().rootca)
  http.get(LFS.config().getURL(), LFS.config().getHeaders(), function(code, jsonData)
    if (code < 0) then
      print("HTTP request failed")     
    else
      print("Success")
      data = sjson.decode(jsonData)
      if data.status.error_code == 0 then success = true end -- CMC can send error code
    end
    disp = LFS.dispFunctions().initOled() -- Setup display again
    LFS.dispFunctions().u8g2_prepare(disp)
    LFS.dispFunctions().drawLoop(disp, data, success) -- Run the draw loop
  end)
end

local function main()
  node.flashindex("_init")()
  local disp = LFS.dispFunctions().initOled()
  LFS.dispFunctions().u8g2_prepare(disp)
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    getPrice()
  end)
  disp:clearBuffer()
  LFS.dispFunctions().drawMessage(disp, "Getting...")
  disp:sendBuffer()
  end
main()