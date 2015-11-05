--[[ Vanaheim is home of the Vanir, a group a gods associated with fertility, 
-- wisdom, nature, magic, and the ability to see the future.
--
-- Author: Seth Cook <cooker52@gmail.com>
--]]

local ARGS = {...}
local VARGS = table.getn(ARGS)

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

function detectDevices()
  local reactor_devices = {}
  local reactor_index = 0
  local turbine_index = 0

  reactor_devices['reactors'] = {}
  reactor_devices['turbines'] = {}

  local sidesWithPeripherals = peripheral.getNames()
  for i, table.getn(sidesWithPeripherals) do
    if peripheral.getType(sidesWithPeripherals[i]) == 'BigReactors-Reactor' then
      reactor_devices['reactors'][reactor_index] = {}
      reactor_devices['reactors'][reactor_index]['side'] = sidesWithPeripherals[i]
      reactor_devices['reactors'][reactor_index]['peripheral'] = peripheral.wrap(sidesWithPeripherals[i])
      reactor_index = reactor_index + 1
    elseif peripheral.getType(sidesWithPeripherals[i]) == 'BigReactors-Turbine' then
      reactor_devices['turbines'][turbine_index] = {}
      reactor_devices['turbines'][turbine_index]['side'] = sidesWithPeripherals[i]
      reactor_devices['turbines'][turbine_index]['peripheral'] = peripheral.wrap(sidesWithPeripherals[i])
      turbine_index = turbine_reactor + 1
    end
  end

  reactor_devices['reactors']['count'] = reactor_index
  reactor_devices['turbines']['count'] = turbine_index
  reactor_devices['count'] = reactor_index + turbine_index
  return reactor_devices
end -- func detectDevices()


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

function main()
  print(LOGO)
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