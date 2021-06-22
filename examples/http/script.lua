---@diagnostic disable: undefined-global

local white = color.new(255, 255, 255)
local black = color.new(0, 0, 0)

screen.print(10, 10, "wlan init", 0.6, white, black)

screen.flip()

-- enable wlan
local wlan_init = wlan.init()

if wlan_init == 1 then
  local get_stat, content = http.get("http://baidu.com")

  screen.flip()

  if get_stat then
    screen.print(10, 10, "http get success: \n" .. content, 0.6, white, black)
  else
    screen.print(10, 10, "http get failed: " .. tostring(get_stat), 0.6, white, black)
  end
else
  screen.print(10, 10, "wlan off", 0.6, white, black)
end

screen.flip()

while true do
    screen.waitvblankstart()
end
