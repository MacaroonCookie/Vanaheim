local text = 'Slawtor Hauz'
local colorBackground = colors.blue
local colorText = colors.green

local monitor = nil

for index, side in pairs(peripherals.getNames()) do
  if peripherals.getType(side) == 'monitor' then
    monitor = peripheral.wrap(side)
    break
  end
end

if monitor == nil then
  error("Can't find monitor.")
end

local width
local height

-- Find correct text scale
local textScale = 5
width, height = monitor.getSize()

while string.len(text) > width and textScale > 0 do
  textScale = textScale - 0.5
  monitor.setTextScale(textScale)
  width, height = monitor.getSize()
end

-- Centering
local padding = width - string.len(text)
padding = padding / 2

local printText = ''
for i=1,padding do
  printText = printText .. ' '
end

printText = printText .. text

-- Print text
-- If blinking different colors, logic goes here
while true do
  monitor.setBackroundColor(colorBackground)
  monitor.setTextColor(colorText)
  monitor.clear()
  monitor.setCursorPos(1,height/2)
  monitor.write(printText)
  os.sleep(1)
end
