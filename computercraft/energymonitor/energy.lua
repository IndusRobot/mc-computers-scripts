
local EnergyMonitor = require( "EnergyMonitor" )

print( "- Building energy monitors" )

local monitorParams = {
    peripheral_name = "myMonitor1"
}

-- This function is called directly before the graph is updated. If there are any delays or async handling it won't look right! 
monitorParams.onRefresh = function ( payload )
    
end 

EnergyMonitor.newMonitor( monitorParams )

print( "- Starting controller" )
EnergyMonitor.startMainMonitorListener() 

