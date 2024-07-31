
-- local MonitorAPI = require( "MonitorAPI" )
local TransmitAPI = require( "TransmitAPI" )
local FluxGateAPI = require( "FluxGateAPI" )

local ReactorAPI = {
    -- configurable reactor values 

    operatingThresholds = {
        temperature = 8200,
        fieldStrength = ( 100000000 * 0.33 ), -- min 
        energySaturation = ( 1000000000 * 0.1 ), -- min
        fuelConversion = ( 10368 * 0.6 ) -- max
    },

    -- API vars 
    monitors = {},
    peripheralToMonitors = {},
    lastResponse,
    replyFrequency = 0.5,
    responseTimeout = 20,

    draconicReactorPeripheral = nil,
    draconicReactor = {
        temperature = 0,
        fieldStability = 0,
        saturation = 0,
        fuelLevel = 0,
        status = "cold"
    },
    fluxGateFieldStabilizer = nil,
    fluxGateOutput = nil,
    -- stabilizerRateAtShutdown = 0,

    statuses = {
        OFFLINE = "cold",
        CHARGING = "warming_up",
        ACTIVE = "running",
        SHUTDOWN = "stopping",
        COOLDOWN = "cooling"
        -- MELTDOWN = ""
    },

    alerts = {},

    commands = {}
}



--[[
    Onsite reactor data collection and controller 
]]

local timestampedAlert = function ( message ) 
    return {
        timestamp = os.clock(),
        alert = "ReactorAPI: " .. message
    }
end 

-- Controller methods 

ReactorAPI.configureModem = function ( side, channel ) 
    TransmitAPI.setWirelessModem( side )
    TransmitAPI.openChannel( channel )
end 

ReactorAPI.configureReactor = function ( peripheral_name )
    ReactorAPI.draconicReactorPeripheral = peripheral.wrap( peripheral_name )
end 

ReactorAPI.configureStabilizer = function ( peripheral_name )
    ReactorAPI.fluxGateFieldStabilizer = FluxGateAPI.newFluxGate( peripheral_name )
end 

ReactorAPI.configureOutput = function ( peripheral_name )
    ReactorAPI.fluxGateOutput = FluxGateAPI.newFluxGate( peripheral_name )
end 

ReactorAPI.getAllData = function () 
    ReactorAPI.draconicReactor = ReactorAPI.draconicReactorPeripheral.getReactorInfo()
    ReactorAPI.fluxGateFieldStabilizer.getAllData()
    ReactorAPI.fluxGateOutput.getAllData()
end 

ReactorAPI.chargeReactor = function () 
    -- ReactorAPI.stabilizerRateAtShutdown = 0
    ReactorAPI.draconicReactorPeripheral.chargeReactor()
    ReactorAPI.fluxGateFieldStabilizer.setTransferLow( 2000000 )
end 

ReactorAPI.activateReactor = function () 
    -- ReactorAPI.stabilizerRateAtShutdown = 0
    ReactorAPI.draconicReactorPeripheral.activateReactor()
end 

ReactorAPI.shutdownReactor = function () 
    term.setTextColor( colors.red )
    print( "ReactorAPI.shutdownReactor" )
    term.setTextColor( colors.white )
    ReactorAPI.fluxGateOutput.setTransferLow( 0 )
    
    -- if ( ReactorAPI.stabilizerRateAtShutdown == 0 ) then 
    --     ReactorAPI.stabilizerRateAtShutdown = ReactorAPI.fluxGateFieldStabilizer.transferLow
    -- end 
    -- ReactorAPI.fluxGateFieldStabilizer.setTransferLow( ReactorAPI.stabilizerRateAtShutdown * 5 )
    ReactorAPI.fluxGateFieldStabilizer.setTransferLow( 50000000 )
    ReactorAPI.draconicReactorPeripheral.stopReactor()
end 

-- Main loop 

ReactorAPI.startReactorControllerListener = function () 
    parallel.waitForAny( 
        ReactorAPI.controllerResponseListener, 
        ReactorAPI.responseTimeoutListener, 
        ReactorAPI.commandsListener
    )
end

ReactorAPI.autoModerate = function () 
    if ( ReactorAPI.draconicReactor.status == ReactorAPI.statuses.ACTIVE ) then 
        if ( ReactorAPI.draconicReactor.temperature > ReactorAPI.operatingThresholds.temperature ) then 
            ReactorAPI.shutdownReactor()
            table.insert( ReactorAPI.alerts, timestampedAlert( "Threshold exceeded: temperature. Shutting down" ) )
        end 
        
        if ( ReactorAPI.draconicReactor.fieldStrength < ReactorAPI.operatingThresholds.fieldStrength ) then 
            ReactorAPI.shutdownReactor()
            table.insert( ReactorAPI.alerts, timestampedAlert( "Threshold exceeded: field stability. Shutting down" ) )
        end 
        
        if ( ReactorAPI.draconicReactor.energySaturation < ReactorAPI.operatingThresholds.energySaturation ) then 
            ReactorAPI.shutdownReactor()
            table.insert( ReactorAPI.alerts, timestampedAlert( "Threshold exceeded: saturation. Shutting down" ) )
        end 
        
        if ( ReactorAPI.draconicReactor.fuelConversion > ReactorAPI.operatingThresholds.fuelConversion ) then 
            ReactorAPI.shutdownReactor()
            table.insert( ReactorAPI.alerts, timestampedAlert( "Threshold exceeded: fuel level. Shutting down" ) )
        end 
    end 

    -- if ( ReactorAPI.draconicReactor.status == ReactorAPI.statuses.SHUTDOWN and ReactorAPI.stabilizerRateAtShutdown == 0 ) then 
    --     ReactorAPI.stabilizerRateAtShutdown = ReactorAPI.fluxGateFieldStabilizer.transferLow / 5
    -- end 
end 

-- Event listeners 

ReactorAPI.controllerResponseListener = function () 
    while true do 
        -- check for thresholds exceeded 
        ReactorAPI.autoModerate() 

        -- then send the response 
        ReactorAPI.getAllData()
        local payload = {
            reactorChannel = 28489, -- This is the receiver channel, not this reactor channel 
            draconicReactor = ReactorAPI.draconicReactor,
            fluxGateFieldStabilizer =  ReactorAPI.fluxGateFieldStabilizer,
            fluxGateOutput = ReactorAPI.fluxGateOutput,
            alerts = ReactorAPI.alerts
        }
    
        TransmitAPI.sendReply( payload )

        os.sleep( ReactorAPI.replyFrequency )
    end 
end

ReactorAPI.responseTimeoutListener = function () 
    while true do 
        os.sleep( ReactorAPI.responseTimeout )

        if ( not ReactorAPI.lastResponse ) then 
            table.insert( ReactorAPI.alerts, timestampedAlert( "No response from monitoring computer. Shutting down" ) )
            ReactorAPI.shutdownReactor()
        elseif ( ReactorAPI.lastResponse and 
            ReactorAPI.lastResponse.timestamp > ( os.clock() + ReactorAPI.responseTimeout )
        ) then 
            table.insert( ReactorAPI.alerts, timestampedAlert( "Paired clocks are desynchornized. Shutting down" ) )
            ReactorAPI.shutdownReactor()
        end 
    end 
end 

ReactorAPI.commandsListener = function () 
    while true do 
        local replyPayload = TransmitAPI.waitReply() 
        if ( replyPayload ) then 
            ReactorAPI.lastResponse = replyPayload
            if ( ReactorAPI.lastResponse and ReactorAPI.lastResponse.command and #ReactorAPI.lastResponse.command ) then 
                if ( ReactorAPI.commands[ ReactorAPI.lastResponse.command ] ) then 
                    ReactorAPI.commands[ ReactorAPI.lastResponse.command ]()
                end 
            end 
        end 
    end 
end 

-- Handlers 


-- Commands 

ReactorAPI.commands.setFluxGateFlow = function () 
    -- Get which fluxGate 
    local fluxGate = ReactorAPI[ ReactorAPI.lastResponse.fluxGate ]
    if ( fluxGate ) then 
        -- Apply setting 

        fluxGate.setTransferLow( fluxGate.transferLow + ReactorAPI.lastResponse.adjustRate )
    end 
end 

ReactorAPI.commands.reboot = function () 
    os.reboot() 
end 

ReactorAPI.commands.charge = function () 
    ReactorAPI.chargeReactor()
end 

ReactorAPI.commands.activate = function () 
    ReactorAPI.activateReactor()
end 

ReactorAPI.commands.shutdown = function () 
    table.insert( ReactorAPI.alerts, timestampedAlert( "Shutdown signal received from monitoring computer" ) )
    ReactorAPI.shutdownReactor()
end 

return ReactorAPI
