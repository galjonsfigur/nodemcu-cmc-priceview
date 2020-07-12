local M = {}
-- Set your own!
local apiKey = ""

M.frameTime = 512 -- in milliseconds
M.sda, M.scl, M.sla = 2, 1, 0x3c -- Default for WeMos D1 mini OLED Shield V1
M.coins = {
  [1] = "BCH",
  [2] = "BTC",
  [3] = "ETH",
  [4] = "LTC",
  [5] = "XLM",
  [6] = "XRP"
}

-- Default for v1 CMC API
function M.getURL()
  local coinString = "" 
  for i, key in ipairs(M.coins) do
    coinString = coinString..key..','
  end 
  coinString = coinString:sub(1, -2)
  return "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol="..coinString
end

function M.getHeaders()
  return "X-CMC_PRO_API_KEY: "..apiKey.."\r\n"
end

-- Retrieved by `openssl s_client -host pro-api.coinmarketcap.com -port 443 -prexit -showcerts`
-- You will need last certificate in chain - depth=0 -  (easier to verify because of low RAM)

M.rootca = [[-----BEGIN CERTIFICATE-----
MIIDozCCAougAwIBAgIQD/PmFjmqPRoSZfQfizTltjANBgkqhkiG9w0BAQsFADBa
MQswCQYDVQQGEwJJRTESMBAGA1UEChMJQmFsdGltb3JlMRMwEQYDVQQLEwpDeWJl
clRydXN0MSIwIAYDVQQDExlCYWx0aW1vcmUgQ3liZXJUcnVzdCBSb290MB4XDTE1
MTAxNDEyMDAwMFoXDTIwMTAwOTEyMDAwMFowbzELMAkGA1UEBhMCVVMxCzAJBgNV
BAgTAkNBMRYwFAYDVQQHEw1TYW4gRnJhbmNpc2NvMRkwFwYDVQQKExBDbG91ZEZs
YXJlLCBJbmMuMSAwHgYDVQQDExdDbG91ZEZsYXJlIEluYyBFQ0MgQ0EtMjBZMBMG
ByqGSM49AgEGCCqGSM49AwEHA0IABNFW9Jy25DGg9aRSz+Oaeob/8oayXsy1WcwR
x07dZP1VnGDjoEvZeFT/SFC6ouGhWHWPx2A3RBZNVZns7tQzeiOjggEZMIIBFTAS
BgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjA0BggrBgEFBQcBAQQo
MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTA6BgNVHR8E
MzAxMC+gLaArhilodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vT21uaXJvb3QyMDI1
LmNybDA9BgNVHSAENjA0MDIGBFUdIAAwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93
d3cuZGlnaWNlcnQuY29tL0NQUzAdBgNVHQ4EFgQUPnQtH89FdQR+P8Cihz5MQ4NR
E8YwHwYDVR0jBBgwFoAU5Z1ZMIJHWMys+ghUNoZ7OrUETfAwDQYJKoZIhvcNAQEL
BQADggEBADhfp//8hfJzMuTVo4mZlmCvMsEDs2Xfvh4DyqXthbKPr0uMc48qjKkA
DgEkF/fsUoV2yOUcecrDF4dQtgQzNp4qnhgXljISr0PMVxje28fYiCWD5coGJTH9
vV1IO1EB3SwUx8FgUemVAdiyM1YOR2aNbM2v+YXZ6xxHR4g06PD6wqtPaU4JWdRX
xszByOPmGcFYOFLi4oOF3iI03D+m968kvOBvwKtoLVLHawVXLEIbLUiHAwyQq0hI
qSi+NIr7uu30YJkdFXgRqtltU39pKLy3ayB2f6BVA3F59WensKAKF1eyAKmtz/9n
jD4m5ackvMJvEOiJxnCl0h+A7Q0/JxM=
-----END CERTIFICATE-----]]

return M