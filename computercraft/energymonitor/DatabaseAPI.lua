local irlib = require( "irlib" )
local MonitorAPI = require( "MonitorAPI-v1-1" )

local DatabaseAPI = {
    monitors = {},
    peripheralToMonitors = {}
}

-- Setup file db to save graph data 

DatabaseAPI.getFile = function ( params ) 
    local file = fs.open( params.data_file, "r" )
    local contents = file.readAll()
    file.close()
    
    return contents 
end 

DatabaseAPI.postFile = function ( params ) 
    local contents = ""
    if ( fs.exists( params.data_file ) ) then 
        contents = DatabaseAPI.getFile( params ) 
    end 

    -- Update data 
    contents = split( contents, "," )
    table.insert( contents, 1, params.value )
    while ( #contents and #contents > params.maximum_values ) do 
        table.remove( contents, #contents )
    end 

    -- Save the file and return data 
    local file = fs.open( params.data_file, "w" )
    file.write( table.concat( contents, "," ) )
    file.close()

    return contents
end 

-- Setup monitor object, its config and GUI 
DatabaseAPI.newMonitor = function ( monitorParams ) 
    if ( not monitorParams.id ) then 
        monitorParams.id = monitorParams.peripheral_name 
    end 

    DatabaseAPI.monitors[ monitorParams.id ] = MonitorAPI.newMonitor( monitorParams )
    if not DatabaseAPI.monitors[ monitorParams.id ] then 
        print( "DatabaseAPI err: monitor id " .. monitorParams.id .. " failed to init" )
        return false 
    end 

    DatabaseAPI.peripheralToMonitors[ monitorParams.peripheral_name ] = monitorParams.id 

    DatabaseAPI.constructMonitorGUI( monitorParams )
end 


-- The GUI. This function constructs and handles all the complex monitor components derived from very simple user config, such as the peripheral name and ID 
-- Any graph onRefresh functions called here should be forwarded back up to the root program for users to plug in their own data, then returned at the end of the refresh 

DatabaseAPI.constructMonitorGUI = function ( monitorParams ) 
    local instancedMonitor = DatabaseAPI.monitors[ monitorParams.id ]

    for key, component in pairs( monitorParams.components ) do 
        if not component.id then component.id = component.text end 

        if ( instancedMonitor[ component.action ] ) then 
            instancedMonitor[ component.action ]( component ) -- Pass component as params 
        else 
            print( "Unsupported component \"" .. component.action .. "\"" )
        end 
    end 

    -- local maximum_values = peripheral.wrap( instancedMonitor.peripheral_name ).getSize() -- get x width 
    
    instancedMonitor.onRefresh = function ()
        -- Update datasets and their files 
        if ( monitorParams.getDatapoints ) then 
            local datapoints = monitorParams.getDatapoints()
            -- for _, graph_id in ipairs( datapoints ) do 
            for graph_id, graph_params in pairs( instancedMonitor.graphs ) do 
                -- Access the graph data inside the MonitorAPI 
                local datasets = {}

                -- Gather and compile the data 
                for data_file, value in pairs( datapoints[ graph_id ] ) do 
                    local dataset = DatabaseAPI.postFile( { 
                        data_file = data_file, 
                        value = value, 
                        maximum_values = graph_params.maximum_values
                    } )
                    datasets[ data_file ] = dataset
                end 

                -- Send data back to the monitor 
                instancedMonitor.graphs[ graph_id ].datasets = datasets 
            end 
        end 
    end 
end

DatabaseAPI.startMainMonitorListener = function () 
    parallel.waitForAny( 
        DatabaseAPI.refreshMonitors
    )
end

DatabaseAPI.refreshMonitors = function ()
    while true do 
        os.sleep( 1 )
        DatabaseAPI.updateMonitors()
    end 
end 

DatabaseAPI.updateMonitors = function () 
    for i, monitor in pairs( DatabaseAPI.monitors ) do 
        monitor.refresh()
    end 
end 

return DatabaseAPI 