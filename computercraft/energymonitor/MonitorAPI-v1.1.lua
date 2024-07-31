
local MonitorAPI = {
    
}

MonitorAPI.newMonitor = function ( newMonitor )
    -- newMonitor.api_name
    -- newMonitor.peripheral_name
    newMonitor.monitor = peripheral.wrap( newMonitor.peripheral_name )
    if not newMonitor.monitor then return false end 
    
    newMonitor.labels = {}
    -- Separate buttons and text so event listeners don't have to iterate as much 
    newMonitor.buttons = {}
    newMonitor.progressBars = {}
    newMonitor.graphs = {}

    newMonitor.addLabel = function ( buttonTable ) 
        if not newMonitor.monitor then return false end 
        newMonitor.labels[ buttonTable.id ] = buttonTable
    end

    newMonitor.addButton = function ( buttonTable ) 
        if not newMonitor.monitor then return false end 
        newMonitor.buttons[ buttonTable.id ] = buttonTable
    end

    newMonitor.addProgressBar = function ( buttonTable )
        if not newMonitor.monitor then return false end 
        newMonitor.progressBars[ buttonTable.id ] = buttonTable
    end 

    newMonitor.addGraph = function ( buttonTable )
        if not newMonitor.monitor then return false end 
        newMonitor.graphs[ buttonTable.id ] = buttonTable
    end

    newMonitor.refresh = function ( lastResponse ) 
        if not newMonitor.monitor then return false end 

        if ( newMonitor.onRefresh ) then 
            newMonitor.onRefresh( lastResponse )
        end 
    
        -- Clear everything 
        newMonitor.monitor.setBackgroundColor( colors.black )
        newMonitor.monitor.setTextColor( colors.white )
        newMonitor.monitor.setTextScale( 1 )
        newMonitor.monitor.clear()

        -- Render the labels 
        for i, label in pairs( newMonitor.labels ) do 
            if ( label.onRefresh ) then 
                label.onRefresh( payload, lastResponse ) 
            end 

            if ( label.bgColor ) then 
                newMonitor.monitor.setBackgroundColor( label.bgColor )
            else 
                newMonitor.monitor.setBackgroundColor( colors.black )
            end

            if ( label.textSize ) then 
                newMonitor.monitor.setTextScale( label.textSize )
            end 

            newMonitor.monitor.setTextColor( label.textColor )
            newMonitor.monitor.setCursorPos( label.x, label.y )
            newMonitor.monitor.write( label.text )
        end 

        -- Render the buttons 
        for i, button in pairs( newMonitor.buttons ) do 
            if ( button.onRefresh ) then 
                button.onRefresh( payload, lastResponse ) 
            end 

            if ( button.bgColor ) then 
                newMonitor.monitor.setBackgroundColor( button.bgColor )
            end 
            newMonitor.monitor.setTextColor( button.textColor )
            newMonitor.monitor.setCursorPos( button.x, button.y )
            newMonitor.monitor.write( button.text )
        end 

        -- Render the progress bars  
        for i, bar in pairs( newMonitor.progressBars ) do 
            if ( bar.onRefresh ) then 
                bar.onRefresh( payload, lastResponse ) 
            end 

            -- bar background 
            local blankText = ""
            local barWidth = newMonitor.monitor.getSize() - 3
            local calculatedPercent = ( bar.current / bar.max )

            for i = 0, barWidth do 
                blankText = blankText .. " " 
            end 

            if ( bar.bgColor ) then 
                newMonitor.monitor.setBackgroundColor( bar.bgColor )
            end 
            newMonitor.monitor.setTextColor( bar.textColor )
            newMonitor.monitor.setCursorPos( 2, bar.y )
            newMonitor.monitor.write( blankText )
            
            -- bar foreground
            blankText = ""
            for i2 = 0, barWidth * calculatedPercent do 
                blankText = blankText .. " " 
            end 

            local progressColor = colors.purple
            for i3, threshold in ipairs( bar.thresholds ) do 
                if ( calculatedPercent <= threshold.max ) then 
                    progressColor = threshold.color 
                end 
            end 

            newMonitor.monitor.setBackgroundColor( progressColor )
            newMonitor.monitor.setTextColor( bar.textColor )
            newMonitor.monitor.setCursorPos( 2, bar.y )
            newMonitor.monitor.write( blankText )
        end 

        -- Render graphs 
        for i, graph in pairs( newMonitor.graphs ) do 
            -- Start data collection before graphing new data 
            if ( graph.onRefresh ) then 
                graph.onRefresh( payload, lastResponse ) 
            end 

            -- axis x and y 

            -- axis low/high labels 

            -- Individual lines 


        end 
    end 

    return newMonitor
end 

return MonitorAPI