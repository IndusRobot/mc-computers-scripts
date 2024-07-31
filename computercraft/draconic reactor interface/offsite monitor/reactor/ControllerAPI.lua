
local MonitorAPI = require( "MonitorAPI" )
local TransmitAPI = require( "TransmitAPI" )
local FluxGateAPI = require( "FluxGateAPI" )

local ControllerAPI = {
    monitors = {},
    peripheralToMonitors = {},
    lastResponse = nil,
    replyFrequency = 0.5,
    responseTimeout = 20,

    reactors = {
        
    },

    energyStorages = {},

    statuses = {
        OFFLINE = "cold",
        CHARGING = "warming_up",
        ACTIVE = "running",
        SHUTDOWN = "stopping",
        COOLDOWN = "cooling"
        -- MELTDOWN = ""
    },

    statusindex = {},

    statusColors = {
        OFFLINE = colors.blue,
        CHARGING = colors.purple,
        ACTIVE = colors.orange,
        SHUTDOWN = colors.red,
        COOLDOWN = colors.purple
    },

    commands = {}
}



--[[
    Methods utilized by both computers 
]]

ControllerAPI.configureModem = function ( side, channel ) 
    TransmitAPI.setWirelessModem( side )
    TransmitAPI.openChannel( channel )
end 



--[[
    Offsite remote monitoring and configuring 
]]

-- Monitoring methods 

ControllerAPI.addMonitor = function ( api_name, peripheral_name, reactorChannel )
    local newMonitor = {
        api_name = api_name,
        peripheral_name = peripheral_name
    }

    if ( reactorChannel ) then 
        newMonitor.reactorChannel = reactorChannel 
    end 

    ControllerAPI.monitors[ api_name ] = MonitorAPI.newMonitor( newMonitor )
    if not ControllerAPI.monitors[ api_name ] then 
        print( "ControllerAPI err: monitor id " .. api_name .. " failed to init" )
        return false 
    end 

    ControllerAPI.peripheralToMonitors[ peripheral_name ] = api_name 

    if ( reactorChannel ) then 
        ControllerAPI.reactors[ reactorChannel ] = {
            lastResponse = nil 
        }
    end 

    return true 
end

ControllerAPI.configureStorage = function ( peripheral_name )
    -- ControllerAPI.energyStorage.peripheral = peripheral.wrap( peripheral_name )

    ControllerAPI.energyStorages[ peripheral_name ] = {
        peripheral,
        energyStored = 0,
        maxEnergyStored = 0,
        transferRate = 0
    }

    ControllerAPI.energyStorages[ peripheral_name ].peripheral = peripheral.wrap( peripheral_name )

    return ControllerAPI.energyStorages[ peripheral_name ]
end 

ControllerAPI.getAllEnergyStorageData = function ()
    for index, battery in pairs( ControllerAPI.energyStorages ) do 
        battery.energyStored = battery.peripheral.getEnergyStored()
        battery.maxEnergyStored = battery.peripheral.getMaxEnergyStored()
        battery.transferRate = battery.peripheral.getTransferPerTick()
    end 
end 

ControllerAPI.setFluxGateFlow = function ( payload )
    TransmitAPI.sendReply( { 
        reactorChannel = payload.reactorChannel,
        command = "setFluxGateFlow",
        fluxGate = payload.fluxGate,
        adjustRate = payload.amount
    } )
end 

-- Main loop 

ControllerAPI.startMainMonitorListener = function () 
    for key, value in pairs( ControllerAPI.statuses ) do 
        ControllerAPI.statusindex[ value ] = key 
    end 

    parallel.waitForAny( 
        ControllerAPI.buttonClickListener, 
        ControllerAPI.monitorResponseListener, 
        ControllerAPI.responseTimeoutListener,
        ControllerAPI.commandsListener,
        ControllerAPI.sendPing,
        ControllerAPI.refreshMonitors
    )
end

-- Event listeners 

ControllerAPI.buttonClickListener = function ()
    while true do 
        event_type, peripheral_name, x, y = os.pullEvent("monitor_touch")
        ControllerAPI.handleButtonClick( {
            event_type = event_type, 
            peripheral_name = peripheral_name, 
            x = x, 
            y = y 
        } )
    end
end

ControllerAPI.monitorResponseListener = function ()
    while true do 
        local reactorChannel, reactorResponse = TransmitAPI.waitReply() 

        if ( ControllerAPI.reactors[ reactorChannel ] ) then 
            ControllerAPI.reactors[ reactorChannel ].lastResponse = reactorResponse 

            ControllerAPI.getAllEnergyStorageData()
            
            ControllerAPI.lastResponse = reactorResponse 
            ControllerAPI.lastResponse.energyStorages = ControllerAPI.energyStorages
        end 
    end
end

ControllerAPI.refreshMonitors = function ()
    while true do 
        os.sleep( 0.5 )
        ControllerAPI.updateMonitors()
    end 
end 

ControllerAPI.responseTimeoutListener = function () 
    while true do 
        os.sleep( ControllerAPI.responseTimeout )

        if ( ControllerAPI.lastResponse and 
            ControllerAPI.lastResponse.timestamp < ( os.clock() - ControllerAPI.responseTimeout )
            -- false 
        ) then 
            print( "No response from controller computer, or paired clocks are desynchornized!" )
            ControllerAPI.commands.shutdown()
            ControllerAPI.updateMonitors()
        end 
    end 
end 

ControllerAPI.commandsListener = function () 
    os.sleep( 5 )
    while true do 
        for reactorChannel, value in pairs( ControllerAPI.reactors ) do 
            TransmitAPI.sendReply( {
                reactorChannel = reactorChannel,
            } )
        end 
        os.sleep( 15 )
    end 
end 

ControllerAPI.sendPing = function () 
    while true do 
        os.sleep( 1 )
        term.setTextColor( colors.red )
        write( "> " )
        term.setTextColor( colors.white )

        local commandText = read()
        if ( #commandText ) then 
            if ( ControllerAPI.commands[ commandText ] ) then 
                ControllerAPI.commands[ commandText ]()
            else 
                print( "Unknown command \"" .. commandText .. "\"" )
            end 
        end 
    end 
end 

-- Handlers 

ControllerAPI.handleButtonClick = function ( event ) 
    -- print( "Clicked monitor " .. event.peripheral_name .. " x: " .. event.x .. " y: " .. event.y )
    if ( not ( 
        event.peripheral_name and 
        ControllerAPI.peripheralToMonitors[ event.peripheral_name ] and 
        ControllerAPI.monitors[ ControllerAPI.peripheralToMonitors[ event.peripheral_name ] ] 
    ) ) then 
        return false 
    end 

    for i, button in pairs( ControllerAPI.monitors[ ControllerAPI.peripheralToMonitors[ event.peripheral_name ] ].buttons ) do 
        if ( event.y == button.y ) then 
            if ( event.x >= button.x and event.x < ( button.x + #button.text ) ) then 
                if ( button.method ) then 
                    button.method( button.payload )
                end 
            end 
        end 
    end 
end 

ControllerAPI.updateMonitors = function () 
    for i, monitor in pairs( ControllerAPI.monitors ) do 
        if ( monitor.reactorChannel ) then 
            if not ( ControllerAPI.reactors[ monitor.reactorChannel ] and ControllerAPI.reactors[ monitor.reactorChannel ].lastResponse ) then return false end 
            monitor.refresh( ControllerAPI.reactors[ monitor.reactorChannel ].lastResponse  )
        else 
            if not ControllerAPI.lastResponse then return false end 
            monitor.refresh( ControllerAPI.lastResponse )
        end 
    end 
end 

-- Commands 

ControllerAPI.commands.reboot = function () 
    for reactorChannel, value in pairs( ControllerAPI.reactors ) do 
        TransmitAPI.sendReply( { 
            reactorChannel = reactorChannel,
            command = "reboot" 
        } )
    end 
    os.sleep( 0.5 )
    os.reboot()
end 

ControllerAPI.commands.charge = function ( reactorChannel )
    if not reactorChannel then return false end -- Terminal command not supported 

    print( "Sending charge signal to " .. tostring( reactorChannel ) )
    TransmitAPI.sendReply( { 
        reactorChannel = reactorChannel,
        command = "charge" 
    } )
end

ControllerAPI.commands.activate = function ( reactorChannel ) 
    if not reactorChannel then return false end -- Terminal command not supported 

    print( "Sending activate signal to " .. tostring( reactorChannel ) )
    TransmitAPI.sendReply( { 
        reactorChannel = reactorChannel,
        command = "activate" 
    } )
end

ControllerAPI.commands.shutdown = function ( reactorChannel ) 
    if ( reactorChannel ) then 
        print( "Sending shutdown signal to " .. tostring( reactorChannel ) )
        TransmitAPI.sendReply( { 
            reactorChannel = reactorChannel,
            command = "shutdown" 
        } )
    else 
        for reactorChannel, value in pairs( ControllerAPI.reactors ) do 
            print( "Sending shutdown signal to " .. tostring( reactorChannel ) )
            TransmitAPI.sendReply( { 
                reactorChannel = reactorChannel,
                command = "shutdown" 
            } )
        end 
    end 
end

return ControllerAPI
