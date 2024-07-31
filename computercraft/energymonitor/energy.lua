
local EnergyMonitor = require( "EnergyMonitor" )

print( "- Building energy monitors" )

local monitorParams = {
    peripheral_name
}
monitorParams.onRefresh = function ( payload, lastResponse )
    -- This function is called directly before the graph is updated. If there are any delays or async handling it won't look right! 
end 

EnergyMonitor.newMonitor( monitorParams )

print( "- Starting controller" )
EnergyMonitor.startMainMonitorListener() 

