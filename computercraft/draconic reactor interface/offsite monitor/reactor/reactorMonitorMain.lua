
local ControllerAPI = require( "ControllerAPI" )
local irlib = require( "irlib" )

local reactorMonitorObject = {
    monitorId,
    peripheral_name,
    reactorChannel,
}

reactorMonitorObject.newMonitor = function ( payload )
    reactorMonitorObject.monitorId = payload.monitorId
    reactorMonitorObject.peripheral_name = payload.peripheral_name
    reactorMonitorObject.reactorChannel = payload.reactor_channel 

    if ( not reactorMonitorObject.monitorId ) then 
        reactorMonitorObject.monitorId = reactorMonitorObject.peripheral_name 
    end 

    ControllerAPI.addMonitor( reactorMonitorObject.monitorId, reactorMonitorObject.peripheral_name, reactorMonitorObject.reactorChannel )

    reactorMonitorObject.constructMonitorGUI(payload)
end 


-- The GUI 

reactorMonitorObject.constructMonitorGUI = function (igiveup) 
    local reactorMonitor = ControllerAPI.monitors[ reactorMonitorObject.monitorId ]
    -- First flux gate pair monitoring 

    reactorMonitor.addLabel( {
        id = "genericreactorlabel",
        text = "Draconic Reactor " .. reactorMonitorObject.monitorId,
        x = 1,
        y = 26,
        textColor = colors.gray
    } )

    local toggleReactorStatus = function ( payload )
        ControllerAPI.commands[ payload ]( igiveup.reactor_channel )
    end 
    local togglereactor = {
        id = "togglereactor",
        text = "err Reactor",
        x = 2,
        y = 24,
        textColor = colors.white,
        bgColor = colors.purple,
        method = toggleReactorStatus,
        payload = "shutdown"
    }
    togglereactor.onRefresh = function ( payload, lastResponse )
        local status = lastResponse.draconicReactor.status
        if ( status == ControllerAPI.statuses.OFFLINE or status == ControllerAPI.statuses.COOLDOWN ) then 
            togglereactor.text = "Charge"
            togglereactor.bgColor = colors.blue
            togglereactor.payload = "charge"
        elseif ( status == ControllerAPI.statuses.CHARGING ) then 
            togglereactor.text = "Activate"
            togglereactor.bgColor = colors.orange
            togglereactor.payload = "activate"
        elseif ( status == ControllerAPI.statuses.ACTIVE ) then 
            togglereactor.text = "Shutdown"
            togglereactor.bgColor = colors.red
            togglereactor.payload = "shutdown"
        else
            togglereactor.text = "Shutdown"
            togglereactor.bgColor = colors.gray
            togglereactor.payload = "shutdown"
        end 
    end 
    reactorMonitor.addButton( togglereactor )

    -- Synchronized clocks check 

    local onsiteclock2 = {
        id = "onsiteclock2",
        text = "test label here",
        x = 1,
        y = 1,
        textColor = colors.gray
    }

    onsiteclock2.onRefresh = function ( payload, lastResponse ) 
        -- print( lastResponse )
        onsiteclock2.text = "Offsite: " .. os.clock()
    end
    reactorMonitor.addLabel( onsiteclock2 )

    local onsiteclock = {
        id = "onsiteclock",
        text = "test label here",
        x = 21,
        y = 1,
        textColor = colors.gray
    }

    onsiteclock.onRefresh = function ( payload, lastResponse ) 
        -- print( lastResponse )
        onsiteclock.text = "Onsite: " .. lastResponse.timestamp
    end 
    reactorMonitor.addLabel( onsiteclock )



    -- Status bars 

    -- temperature 

    local labeltemperature = {
        id = "labeltemperature",
        text = "test label here",
        x = 2,
        y = 3,
        textColor = colors.white
    }

    labeltemperature.onRefresh = function ( payload, lastResponse ) 
        -- print( lastResponse )
        labeltemperature.text = "Temperature: " .. lastResponse.draconicReactor.temperature
    end
    reactorMonitor.addLabel( labeltemperature )

    local temperaturePercent = {
        id = "temperaturePercent",
        y = 4,
        textColor = colors.white,   
        bgColor = colors.lightGray,
        current = 0,
        max = 100,
        thresholds = {
            { max = 1, color = colors.white },
            { max = 0.8, color = colors.red },
            { max = 0.7, color = colors.orange },
            { max = 0.6, color = colors.yellow },
            { max = 0.4, color = colors.cyan },
            { max = 0.2, color = colors.blue }
        }
    }
    temperaturePercent.onRefresh = function ( payload, lastResponse ) 
        temperaturePercent.current = lastResponse.draconicReactor.temperature
        temperaturePercent.max = 10000
    end 
    reactorMonitor.addProgressBar( temperaturePercent )

    -- field stability 

    local labelstability = {
        id = "labelstability",
        text = "test label here",
        x = 2,
        y = 5,
        textColor = colors.white
    }

    labelstability.onRefresh = function ( payload, lastResponse ) 
        -- print( lastResponse )
        labelstability.text = "Field Stability: " .. irlib.toFixed( lastResponse.draconicReactor.fieldStrength / 1000000, 1 )
    end
    reactorMonitor.addLabel( labelstability )

    local stabilizerPercent = {
        id = "stabilizerPercent",
        y = 6,
        textColor = colors.white,   
        bgColor = colors.lightGray,
        current = 0,
        max = 100,
        thresholds = {
            { max = 1, color = colors.purple },
            { max = 0.8, color = colors.lightBlue },
            { max = 0.6, color = colors.blue },
            { max = 0.4, color = colors.orange },
            { max = 0.2, color = colors.red }
        }
    }
    stabilizerPercent.onRefresh = function ( payload, lastResponse ) 
        stabilizerPercent.current = lastResponse.draconicReactor.fieldStrength
        stabilizerPercent.max = lastResponse.draconicReactor.maxFieldStrength
    end 
    reactorMonitor.addProgressBar( stabilizerPercent )

    -- energy saturation 

    local labelSaturation = {
        id = "labelSaturation",
        text = "test label here",
        x = 2,
        y = 13,
        textColor = colors.white
    }

    labelSaturation.onRefresh = function ( payload, lastResponse ) 
        labelSaturation.text = "Saturation: " .. irlib.toFixed( lastResponse.draconicReactor.energySaturation / 10000000, 1 )
    end
    reactorMonitor.addLabel( labelSaturation )

    local saturationPercent = {
        id = "saturationPercent",
        y = 14,
        textColor = colors.white,   
        bgColor = colors.lightGray,
        current = 0,
        max = 100,
        thresholds = {
            { max = 1, color = colors.purple },
            { max = 0.8, color = colors.lightBlue },
            { max = 0.6, color = colors.blue },
            { max = 0.4, color = colors.orange },
            { max = 0.2, color = colors.red }
        }
    }
    saturationPercent.onRefresh = function ( payload, lastResponse ) 
        saturationPercent.current = lastResponse.draconicReactor.energySaturation
        saturationPercent.max = lastResponse.draconicReactor.maxEnergySaturation
    end 
    reactorMonitor.addProgressBar( saturationPercent )

    -- fuel conversion 

    local labelConversion = {
        id = "labelConversion",
        text = "test label here",
        x = 2,
        y = 15,
        textColor = colors.white
    }

    labelConversion.onRefresh = function ( payload, lastResponse ) 
        labelConversion.text = "Conversion: " .. lastResponse.draconicReactor.fuelConversion
    end
    reactorMonitor.addLabel( labelConversion )

    local fuelPercent = {
        id = "fuelPercent",
        y = 16,
        textColor = colors.white,   
        bgColor = colors.lightGray,
        current = 0,
        max = 100,
        thresholds = {
            { max = 1, color = colors.gray },
            { max = 0.8, color = colors.red },
            { max = 0.6, color = colors.yellow },
            { max = 0.5, color = colors.green }
        }
    }
    fuelPercent.onRefresh = function ( payload, lastResponse ) 
        fuelPercent.current = lastResponse.draconicReactor.fuelConversion
        fuelPercent.max = lastResponse.draconicReactor.maxFuelConversion
    end 
    reactorMonitor.addProgressBar( fuelPercent )

    -- Other useful labels 

    local powerProductionLabel = {
        id = "powerProductionLabel",
        text = "test label here",
        x = 2,
        y = 20,
        textColor = colors.white,
        bgColor = colors.black
    }

    powerProductionLabel.onRefresh = function ( payload, lastResponse ) 
        powerProductionLabel.bgColor = colors.black 

        if ( lastResponse.draconicReactor.status == ControllerAPI.statuses.ACTIVE ) then 
            powerProductionLabel.text = "Generation: " .. irlib.convertRF( lastResponse.draconicReactor.generationRate )

            if ( math.floor( lastResponse.draconicReactor.generationRate / 10000 ) ~= math.floor( lastResponse.fluxGateOutput.transferLow / 10000 ) ) then 
                powerProductionLabel.bgColor = colors.red 
            end 
        else 
            powerProductionLabel.text = "Generation: 0RF"
        end 
    end
    reactorMonitor.addLabel( powerProductionLabel )

    local netPowerLabel = {
        id = "netPowerLabel",
        text = "test label here",
        x = 2,
        y = 21,
        textColor = colors.white
    }

    netPowerLabel.onRefresh = function ( payload, lastResponse ) 
        netPowerLabel.text = "Net Power: " .. irlib.convertRF( lastResponse.draconicReactor.generationRate - lastResponse.fluxGateFieldStabilizer.transferLow )
    end
    reactorMonitor.addLabel( netPowerLabel )

    local conversionRate = {
        id = "conversionRate",
        text = "test label here",
        x = 2,
        y = 22,
        textColor = colors.white
    }

    conversionRate.onRefresh = function ( payload, lastResponse ) 
        conversionRate.text = "Conversion Rate: " .. irlib.toFixed( lastResponse.draconicReactor.fuelConversionRate / 100000, 3 )
    end
    reactorMonitor.addLabel( conversionRate )



    --[[
        Flux gate control buttons 
    ]]

    local adjustFluxGate = function ( payload )
        -- print( "reactorFluxGates adjust: " .. payload.amount )
        ControllerAPI.setFluxGateFlow( payload )
    end 
    
    -- First flux gate pair monitoring 
    
    local fluxGateLabel1 = {
        id = "fluxGateLabel1",
        text = "Label 1",
        x = 3,
        y = 8,
        textColor = colors.white,
        bgColor = colors.black
    }
    
    fluxGateLabel1.onRefresh = function ( payload, lastResponse ) 
        fluxGateLabel1.text = "Injector rate: " .. irlib.convertRF( lastResponse.fluxGateFieldStabilizer.transferLow )
    end 
    
    reactorMonitor.addLabel( fluxGateLabel1 )
    
    -- red 
    for i, button in ipairs( {
        { text = "^6", x = 3, amount = -1000000 }, 
        { text = "^5", x = 6, amount = -100000 }, 
        { text = "^4", x = 9, amount = -10000 }, 
        { text = "^3", x = 12, amount = -1000 }
    } ) do 
        reactorMonitor.addButton( {
            id = "fluxGateControl1" .. button.text,
            text = button.text,
            x = button.x,
            y = 9,
            textColor = colors.white,
            bgColor = colors.red,
            method = adjustFluxGate, 
            payload = { 
                reactorChannel = reactorMonitorObject.reactorChannel,
                fluxGate = "fluxGateFieldStabilizer", 
                amount = button.amount 
            }
        } )
    end 
    
    -- green 
    for i, button in ipairs( {
        { text = "^3", x = 27, amount = 1000 }, 
        { text = "^4", x = 30, amount = 10000 }, 
        { text = "^5", x = 33, amount = 100000 },
        { text = "^6", x = 36, amount = 1000000 }
    } ) do 
        reactorMonitor.addButton( {
            id = "fluxGateControl2" .. button.text,
            text = button.text,
            x = button.x,
            y = 9,
            textColor = colors.white,
            bgColor = colors.green,
            method = adjustFluxGate, 
            payload = { 
                reactorChannel = reactorMonitorObject.reactorChannel, 
                fluxGate = "fluxGateFieldStabilizer", 
                amount = button.amount 
            }
        } )
    end 
    
    -- Second flux gate pair monitoring 
    
    local fluxGateLabel2 = {
        id = "fluxGateLabel2",
        text = "Label 2",
        x = 3   ,
        y = 10,
        textColor = colors.white,
        bgColor = colors.black
    }
    
    fluxGateLabel2.onRefresh = function ( payload, lastResponse ) 
        fluxGateLabel2.text = "Output rate: " .. irlib.convertRF( lastResponse.fluxGateOutput.transferLow )
    end 
    
    reactorMonitor.addLabel( fluxGateLabel2 )
    
    for i, button in ipairs( {
        { text = "^6", x = 3, amount = -1000000 }, 
        { text = "^5", x = 6, amount = -100000 }, 
        { text = "^4", x = 9, amount = -10000 }, 
        { text = "^3", x = 12, amount = -1000 }
    } ) do 
        reactorMonitor.addButton( {
            id = "fluxGateControl3" .. button.text,
            text = button.text,
            x = button.x,
            y = 11,
            textColor = colors.white,
            bgColor = colors.red,
            method = adjustFluxGate, 
            payload = { 
                reactorChannel = reactorMonitorObject.reactorChannel,
                fluxGate = "fluxGateOutput", 
                amount = button.amount 
            }
        } )
    end 
    
    for i, button in ipairs( {
        { text = "^3", x = 27, amount = 1000 }, 
        { text = "^4", x = 30, amount = 10000 }, 
        { text = "^5", x = 33, amount = 100000 },
        { text = "^6", x = 36, amount = 1000000 }
    } ) do 
        reactorMonitor.addButton( {
            id = "fluxGateControl4" .. button.text,
            text = button.text,
            x = button.x,
            y = 11,
            textColor = colors.white,
            bgColor = colors.green,
            method = adjustFluxGate, 
            payload = { 
                reactorChannel = reactorMonitorObject.reactorChannel, 
                fluxGate = "fluxGateOutput", 
                amount = button.amount 
            }
        } )
    end 
    

end -- end constructMonitorGUI

return reactorMonitorObject
