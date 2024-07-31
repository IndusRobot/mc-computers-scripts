
os.sleep( 1 ) -- Wait for world to finish loading 
local ControllerAPI = require( "ControllerAPI" )
local reactorMonitorObject = require( "reactorMonitorMain" )
local storageMonitorMain = require( "storageMonitorMain" )

print( "- Building reactor monitors" )

-- ControllerAPI.addMonitor( "mainreactor", "monitor_12" )
-- reactorMonitorObject.newMonitor( {
--     peripheral_name = "monitor_18",
--     reactor_channel = 20001
-- } )

reactorMonitorObject.newMonitor( {
    peripheral_name = "monitor_26",
    reactor_channel = 20001
} )
reactorMonitorObject.newMonitor( {
    peripheral_name = "monitor_27",
    reactor_channel = 20002
} )
reactorMonitorObject.newMonitor( {
    peripheral_name = "monitor_24",
    reactor_channel = 20003
} )

storageMonitorMain.newMonitor( {
    storage_name = "draconic_rf_storage_3",
    peripheral_name = "monitor_29"
} )

storageMonitorMain.newMonitor( {
    storage_name = "draconic_rf_storage_4",
    peripheral_name = "monitor_30"
} )

require( "alertsMonitor" )
print( "- Starting controller" )

ControllerAPI.configureModem( "bottom", 28489 )
ControllerAPI.startMainMonitorListener() 
