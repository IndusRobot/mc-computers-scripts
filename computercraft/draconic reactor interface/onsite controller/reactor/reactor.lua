
os.sleep( 1 )
local ReactorAPI = require( "ReactorAPI" )

print( "- Starting reactor controller" )

ReactorAPI.configureModem( "bottom", 20003 )
ReactorAPI.configureReactor( "draconic_reactor_2" )
ReactorAPI.configureStabilizer( "flux_gate_13" )
ReactorAPI.configureOutput( "flux_gate_12" )

ReactorAPI.startReactorControllerListener()
