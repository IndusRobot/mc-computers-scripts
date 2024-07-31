
local ControllerAPI = require( "ControllerAPI" )
local status = ControllerAPI.addMonitor( "alertsmonitor", "monitor_28" )
local irlib = require( "irlib" )

ControllerAPI.monitors.alertsmonitor.onRefresh = function ( lastResponse )
    ControllerAPI.monitors.alertsmonitor.labels = {}

    ControllerAPI.monitors.alertsmonitor.addLabel( {
        id = "genericalertlabel",
        text = "Alerts Monitor",
        x = ControllerAPI.monitors.alertsmonitor.monitor.getSize() - 14,
        y = 1,
        textSize = 0.5,
        textColor = colors.lightGray,
        bgColor = colors.black
    } )

    ControllerAPI.monitors.alertsmonitor.addLabel( {
        id = "alertstatus",
        text = "Status: " .. lastResponse.draconicReactor.status,
        x = 1,
        y = 1,
        textSize = 0.5,
        textColor = colors.white,
        bgColor = ControllerAPI.statusColors[ ControllerAPI.statusindex[ lastResponse.draconicReactor.status ] ]
    } )

    if ( lastResponse and lastResponse.alerts and #lastResponse.alerts > 0 ) then 
        for i, message in ipairs( lastResponse.alerts ) do 
            ControllerAPI.monitors.alertsmonitor.addLabel( {
                id = "alertlabel" .. tostring( i ),
                text = tostring( message.timestamp ) .. ": " .. message.alert,
                x = 1,
                y = i + 2,
                textSize = 0.5,
                textColor = colors.red,
                bgColor = colors.black
            } )
        end 
    else 
        ControllerAPI.monitors.alertsmonitor.addLabel( {
            id = "genericalertlabel2",
            text = "No alerts",
            x = 1,
            y = 2,
            textSize = 0.5,
            textColor = colors.lightGray,
            bgColor = colors.black
        } )
    end  
end 
