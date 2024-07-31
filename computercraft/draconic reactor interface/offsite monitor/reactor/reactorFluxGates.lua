--[[
    This code is currently deprecated and not used
    However, it will be repurposed when a central power backup is created for the reactor cluster 
]]

local ControllerAPI = require( "ControllerAPI" )
local status = ControllerAPI.addMonitor( "reactorcontrolmon", "monitor_11" )
local irlib = require( "irlib" )

local adjustFluxGate = function ( payload )
    -- print( "reactorFluxGates adjust: " .. payload.amount )
    ControllerAPI.setFluxGateFlow( payload )
end 

-- First flux gate pair monitoring 

local fluxGateLabel1 = {
    id = "fluxGateLabel1",
    text = "Label 1",
    x = 2,
    y = 1,
    textColor = colors.white,
    bgColor = colors.black
}

fluxGateLabel1.onRefresh = function ( payload, lastResponse ) 
    fluxGateLabel1.text = "Injector rate: " .. irlib.convertRF( lastResponse.fluxGateFieldStabilizer.transferLow )
end 

ControllerAPI.monitors.reactorcontrolmon.addLabel( fluxGateLabel1 )

-- red 
for i, button in ipairs( {
    { text = "^6", x = 2, amount = -1000000 }, 
    { text = "^5", x = 5, amount = -100000 }, 
    { text = "^4", x = 8, amount = -10000 }, 
    { text = "^3", x = 11, amount = -1000 }
} ) do 
    ControllerAPI.monitors.reactorcontrolmon.addButton( {
        id = "fluxGateControl1" .. button.text,
        text = button.text,
        x = button.x,
        y = 2,
        textColor = colors.white,
        bgColor = colors.red,
        method = adjustFluxGate, 
        payload = { fluxGate = "fluxGateFieldStabilizer", amount = button.amount }
    } )
end 

-- green 
for i, button in ipairs( {
    { text = "^3", x = 17, amount = 1000 }, 
    { text = "^4", x = 20, amount = 10000 }, 
    { text = "^5", x = 23, amount = 100000 },
    { text = "^6", x = 26, amount = 1000000 }
} ) do 
    ControllerAPI.monitors.reactorcontrolmon.addButton( {
        id = "fluxGateControl2" .. button.text,
        text = button.text,
        x = button.x,
        y = 2,
        textColor = colors.white,
        bgColor = colors.green,
        method = adjustFluxGate, 
        payload = { fluxGate = "fluxGateFieldStabilizer", amount = button.amount }
    } )
end 

-- Second flux gate pair monitoring 

local fluxGateLabel2 = {
    id = "fluxGateLabel2",
    text = "Label 2",
    x = 2,
    y = 3,
    textColor = colors.white,
    bgColor = colors.black
}

fluxGateLabel2.onRefresh = function ( payload, lastResponse ) 
    fluxGateLabel2.text = "Output rate: " .. irlib.convertRF( lastResponse.fluxGateOutput.transferLow )
end 

ControllerAPI.monitors.reactorcontrolmon.addLabel( fluxGateLabel2 )

for i, button in ipairs( {
    { text = "^6", x = 2, amount = -1000000 }, 
    { text = "^5", x = 5, amount = -100000 }, 
    { text = "^4", x = 8, amount = -10000 }, 
    { text = "^3", x = 11, amount = -1000 }
} ) do 
    ControllerAPI.monitors.reactorcontrolmon.addButton( {
        id = "fluxGateControl3" .. button.text,
        text = button.text,
        x = button.x,
        y = 4,
        textColor = colors.white,
        bgColor = colors.red,
        method = adjustFluxGate, 
        payload = { fluxGate = "fluxGateOutput", amount = button.amount }
    } )
end 

for i, button in ipairs( {
    { text = "^3", x = 17, amount = 1000 }, 
    { text = "^4", x = 20, amount = 10000 }, 
    { text = "^5", x = 23, amount = 100000 },
    { text = "^6", x = 26, amount = 1000000 }
} ) do 
    ControllerAPI.monitors.reactorcontrolmon.addButton( {
        id = "fluxGateControl4" .. button.text,
        text = button.text,
        x = button.x,
        y = 4,
        textColor = colors.white,
        bgColor = colors.green,
        method = adjustFluxGate, 
        payload = { fluxGate = "fluxGateOutput", amount = button.amount }
    } )
end 
