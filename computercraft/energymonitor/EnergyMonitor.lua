
local MonitorAPI = require( "MonitorAPI-v1-1" )

local EnergyMonitor = {
    monitors = {},
    peripheralToMonitors = {}
}

-- Setup file db to save graph data 

EnergyMonitor.createFile = function () 

end

-- Setup monitor object, its config and GUI 
EnergyMonitor.newMonitor = function ( payload ) 
    if ( not payload.monitorId ) then 
        payload.monitorId = payload.peripheral_name 
    end 

    EnergyMonitor.monitors[ payload.monitorId ] = MonitorAPI.newMonitor( payload )
    if not EnergyMonitor.monitors[ payload.monitorId ] then 
        print( "EnergyMonitor err: monitor id " .. payload.monitorId .. " failed to init" )
        return false 
    end 

    EnergyMonitor.peripheralToMonitors[ payload.peripheral_name ] = payload.monitorId 

    EnergyMonitor.constructMonitorGUI( payload )
end 


-- The GUI. This function constructs and handles all the complex monitor components derived from very simple user config, such as the peripheral name and ID 
-- Any graph onRefresh functions called here should be forwarded back up to the root program for users to plug in their own data, then returned at the end of the refresh 

EnergyMonitor.constructMonitorGUI = function ( payload ) 
    local instancedMonitor = EnergyMonitor.monitors[ payload.monitorId ]

    instancedMonitor.addLabel( {
        id = "genericreactorlabel",
        text = "Draconic Reactor " .. payload.monitorId,
        x = 1,
        y = 1,
        textColor = colors.blue
    } )
end

EnergyMonitor.startMainMonitorListener = function () 
    parallel.waitForAny( 
        EnergyMonitor.refreshMonitors
    )
end

EnergyMonitor.refreshMonitors = function ()
    while true do 
        os.sleep( 0.5 )
        EnergyMonitor.updateMonitors()
    end 
end 

EnergyMonitor.updateMonitors = function () 
    for i, monitor in pairs( EnergyMonitor.monitors ) do 
        monitor.refresh( EnergyMonitor.lastResponse )
    end 
end 

return EnergyMonitor 