
local ControllerAPI = require( "ControllerAPI" )
local status = ControllerAPI.addMonitor( "storagecontrolmon", "monitor_9" )

local adjustFluxGate = function ( payload )
    print( "storageFluxGates adjust: " .. payload.amount )
end 

-- First flux gate pair monitoring 

ControllerAPI.monitors.storagecontrolmon.addLabel( {
    id = "fluxGateLabel3",
    text = "Label 3",
    x = 2,
    y = 1,
    textColor = colors.white,
    bgColor = colors.black
} )

for i, button in ipairs( {
    { text = "---", x = 3, amount = -100000 }, 
    { text = "--", x = 7, amount = -10000 }, 
    { text = "-", x = 10, amount = -1000 }
} ) do 
    ControllerAPI.monitors.storagecontrolmon.addButton( {
        id = "fluxGateControl3" .. button.text,
        text = button.text,
        x = button.x,
        y = 2,
        textColor = colors.white,
        bgColor = colors.red,
        method = adjustFluxGate, 
        payload = { amount = button.amount }
    } )
end 

for i, button in ipairs( {
    { text = "+", x = 20, amount = 1000 }, 
    { text = "++", x = 22, amount = 10000 }, 
    { text = "+++", x = 25, amount = 100000 }
} ) do 
    ControllerAPI.monitors.storagecontrolmon.addButton( {
        id = "fluxGateControl3" .. button.text,
        text = button.text,
        x = button.x,
        y = 2,
        textColor = colors.white,
        bgColor = colors.cyan,
        method = adjustFluxGate, 
        payload = { amount = button.amount }
    } )
end 

-- Second flux gate pair monitoring 

ControllerAPI.monitors.storagecontrolmon.addLabel( {
    id = "fluxGateLabel4",
    text = "Label 4",
    x = 2,
    y = 3,
    textColor = colors.white,
    bgColor = colors.black
} )

for i, button in ipairs( {
    { text = "---", x = 3, amount = -100000 }, 
    { text = "--", x = 7, amount = -10000 }, 
    { text = "-", x = 10, amount = -1000 }
} ) do 
    ControllerAPI.monitors.storagecontrolmon.addButton( {
        id = "fluxGateControl4" .. button.text,
        text = button.text,
        x = button.x,
        y = 4,
        textColor = colors.white,
        bgColor = colors.red,
        method = adjustFluxGate, 
        payload = { amount = button.amount }
    } )
end 

for i, button in ipairs( {
    { text = "+", x = 20, amount = 1000 }, 
    { text = "++", x = 22, amount = 10000 }, 
    { text = "+++", x = 25, amount = 100000 }
} ) do 
    ControllerAPI.monitors.storagecontrolmon.addButton( {
        id = "fluxGateControl4" .. button.text,
        text = button.text,
        x = button.x,
        y = 4,
        textColor = colors.white,
        bgColor = colors.cyan,
        method = adjustFluxGate, 
        payload = { amount = button.amount }
    } )
end 
