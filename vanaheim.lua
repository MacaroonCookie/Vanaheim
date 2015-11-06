--[[ Vanaheim is home of the Vanir, a group a gods associated with fertility, 
-- wisdom, nature, magic, and the ability to see the future.
--
-- Author: Seth Cook <cooker52@gmail.com>
--]]

-- Constants
local TICKSPERSECOND = 20
local LOGO = [[                        `
         `-:///:.        -:
     `/yNMMMMMMMMMdo.     :y`
   .sMMho:.   `-+hMMMy.    +h
  +NNo`  .+syhyo/`.hMMN.    mo
 sMh`  .hMMMMMMMMN/ dMMd    ym
/Mh   :MMMMMMMMMMMM-dMMM.   yM
dN`   NMMMMMMMMMMMMMMMMN`  `Nm
Mh   `MMMm-MMMMMMMMMMMM/   yM+
my    dMMd /NMMMMMMMMd-  `yMy
+N    .NMMh.`/syhhy+.  `+NMo
 h+    `yMMMh+-`   `-+yNMy.
  y:     .odMMMMNNMMMNh+`
   ::        .:////:.
     `  
<<<===      Vanaheim      ===>>>
       BigReactor Control]]

-- Globals
local pid_integral_sum = 0
local pid_previous_error = 0


-- Event Handler
local event_listeners = {}

function addEventListener(eventName, event_callback)
  event_listeners[eventName] = event_callback
end

function removeEventListener(eventName)
  event_listeners[eventName] = nil
end

function eventWatcherDaemon()
  while true do
    local event = { os.pullEvent() }
    if event_listeners[event[1]] ~= nil then
      event_listeners[event[1]](event)
    end
  end
end


-- Configuration Management
local global_configuration = {}
local global_configuration_file = './vanaheim.conf'

function saveConfiguration(config_file, configuration)
  file = fs.open(config_file .. '.new', 'w')

  for key,value in configuration do
    file.writeLine(key .. ' = ' .. value)
  end

  file.close()
  fs.move(config_file .. '.new', config_file)
end

function loadConfiguration(config_file)
  if ~ fs.exists(config_file) then
    error('Can not find confg file ' .. config_file .. '.')
  end

  file = fs.open(config_file, 'r')
  configuration = {}

  line = nil
  while (line = file.readLine()) ~= nil do
    key, value = string.gmatch(line, '(%w+) = (%w+)')
    configuration[key] = value
  end
end

function saveGlobalConfig()
  saveConfiguration(global_configuration_file, global_configuration)
end

function loadGlobalConfig()
  global_configuration = loadConfiguration(global_configuration_file)
end

function modifyGlobalConfig(key, value)
  global_configuration[key] = value
  saveConfiguration(global_configuration_file, global_configuration)
end

function getGlobalConfig(key)
  return global_configuration[key]
end


-- Peripheral Management
function detectDevices()
  local reactor_devices = {}
  local reactor_index = 0
  local turbine_index = 0

  reactor_devices['reactors'] = {}
  reactor_devices['turbines'] = {}

  local sidesWithPeripherals = peripheral.getNames()
  for i=1, table.getn(sidesWithPeripherals) do
    if peripheral.getType(sidesWithPeripherals[i]) == 'BigReactors-Reactor' then
      reactor_index = reactor_index + 1
      reactor_devices['reactors'][reactor_index] = {}
      reactor_devices['reactors'][reactor_index]['side'] = sidesWithPeripherals[i]
      reactor_devices['reactors'][reactor_index]['peripheral'] = peripheral.wrap(sidesWithPeripherals[i])
    elseif peripheral.getType(sidesWithPeripherals[i]) == 'BigReactors-Turbine' then
      turbine_index = turbine_reactor + 1
      reactor_devices['turbines'][turbine_index] = {}
      reactor_devices['turbines'][turbine_index]['side'] = sidesWithPeripherals[i]
      reactor_devices['turbines'][turbine_index]['peripheral'] = peripheral.wrap(sidesWithPeripherals[i])
    end
  end

  reactor_devices['reactors']['count'] = reactor_index
  reactor_devices['turbines']['count'] = turbine_index
  reactor_devices['count'] = reactor_index + turbine_index
  return reactor_devices
end -- func detectDevices()


-- Abstract Control Functions
function getPidValue(setValue,  processValue, proportionalGain, integralGain, derivativeGain)
  local errorValue = processValue - setValue
  local proportionalError = 0
  local integralError = 0
  local derivativeError = 0

  -- Proportional Calculation
  proportionalError = proportionalGain * errorValue

  -- Integral Calculation
  pid_integral_sum = pid_integral_sum + errorValue
  integralError = integralGain * pid_integral_sum

  -- Derivative Calculation
  derivativeError = derivativeGain(errorValue - pid_previous_error)
  pid_previous_error = errorValue

  return propotionalError + integralError + derivativeError
end -- func getPidValue()


-- Main Loops
function controlDaemon()

while true do

  os.sleep(.1)
end

end

function main()
  args = {...}
  print(LOGO)
  os.sleep(3)
  print("\n\n")

  devices = detectDevices()
  if devices['count'] == 0 then
    print("No BigReactor devices detected.")
  else
    if devices['reactors']['count'] > 0 then
      print("Found "..devices['reactors']['count'].." reactors.")
    end

    if devices['turbines']['count'] > 0 then
      print("Found "..devices['turbines']['count'].." turbines.")
    end
  end
end -- func


-- Start Primary Process
parallel.waitForAny(main, eventWatcherDaemon, controlDaemon)
