
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
    newMonitor.registeredRefreshMethods = {}

    newMonitor.addLabel = function ( componentParams ) 
        if not newMonitor.monitor then return false end 
        if not componentParams.id then 
            componentParams.id = componentParams.text 
        end 
        newMonitor.labels[ componentParams.id ] = componentParams
        if ( componentParams.onRefresh ) then 
            table.insert( newMonitor.registeredRefreshMethods, componentParams )
        end 
    end

    newMonitor.addButton = function ( componentParams ) 
        if not newMonitor.monitor then return false end 
        newMonitor.buttons[ componentParams.id ] = componentParams
        if ( componentParams.onRefresh ) then 
            table.insert( newMonitor.registeredRefreshMethods, componentParams )
        end 
    end

    newMonitor.addProgressBar = function ( componentParams )
        if not newMonitor.monitor then return false end 
        newMonitor.progressBars[ componentParams.id ] = componentParams
        if ( componentParams.onRefresh ) then 
            table.insert( newMonitor.registeredRefreshMethods, componentParams )
        end 
    end 

    newMonitor.addGraph = function ( componentParams )
        if not newMonitor.monitor then return false end 
        newMonitor.graphs[ componentParams.id ] = componentParams
        if ( componentParams.onRefresh ) then 
            table.insert( newMonitor.registeredRefreshMethods, componentParams )
        end 
    end

    newMonitor.refresh = function () 
        if not newMonitor.monitor then return false end 

        -- Perform data collection before clearing and updating the monitor 
        if ( newMonitor.onRefresh ) then 
            newMonitor.onRefresh()
            for _, component in ipairs( newMonitor.registeredRefreshMethods ) do 
                component.onRefresh( component, newMonitor )
            end 
        end 
    
        -- Clear everything 
        newMonitor.monitor.setBackgroundColor( colors.black )
        newMonitor.monitor.setTextColor( colors.white )
        newMonitor.monitor.setTextScale( 1 )
        newMonitor.monitor.clear()

        local monX, monY = newMonitor.monitor.getSize()

        -- Render graphs 

        for i, graph in pairs( newMonitor.graphs ) do 
        
            local marginTop = graph.margin.top
            local marginLeft = graph.margin.left
            local marginBottom = graph.margin.bottom
            local marginRight = graph.margin.right

            if graph.datasets then 

                -- Find the min and max values of all datasets provided 
                local datavalues = {
                    min,
                    max
                }

                if ( graph.setMin ) then 
                    datavalues.min = graph.setMin 
                end 

                if ( graph.setMax ) then 
                    datavalues.max = graph.setMax 
                end 

                if ( graph.setMin == nil or graph.setMax == nil ) then 
                    for _, dataset in pairs( graph.datasets ) do 
                        for i, value in ipairs( dataset ) do 
                            -- Try not to exceed a thousand values :)
                            value = math.floor( tonumber( value ) )
                            if ( datavalues.min == nil or value < datavalues.min ) then 
                                datavalues.min = value 
                            end 

                            if ( datavalues.max == nil or value > datavalues.max ) then 
                                datavalues.max = value
                            end 
                        end 
                    end 
                end 

                -- axis x and y 

                if ( graph.axisColor ) then 
                    newMonitor.monitor.setBackgroundColor( graph.axisColor )
                else 
                    newMonitor.monitor.setBackgroundColor( colors.white )
                end
                
                blankText = ""
                for i = 0, math.ceil( monX / 3 ) do 
                    blankText = blankText .. " " 
                end 

                newMonitor.monitor.setCursorPos( 1 + monX - marginRight - #blankText, marginTop + 1 )
                newMonitor.monitor.write( blankText )

                newMonitor.monitor.setCursorPos( 1 + monX - marginRight - #blankText, monY - marginBottom )
                newMonitor.monitor.write( blankText )

                for i = 0, monY - 1 - marginTop - marginBottom do 
                    newMonitor.monitor.setCursorPos( 1 + marginLeft, i + marginTop + 1 )
                    newMonitor.monitor.write( " " )
                end

                -- Individual lines 

                local lastValue = {
                    value = nil,
                    pixel = nil,
                }
                for data_file, dataset in pairs( graph.datasets ) do 
                    for index, value in ipairs( dataset ) do 
                        -- Ignore excess data if it exceeds the graph width 
                        if not ( index > monX - 1 - marginRight - marginLeft ) then 
                            -- Value Percent of max, provides a scale of where to map raw values on an x y coordinate
                            local vp
                            if ( datavalues.max == datavalues.min ) then 
                                vp = 1
                            else 
                                vp = ( value - datavalues.min ) / ( datavalues.max - datavalues.min )
                            end 
                            -- local pixelY = math.floor( vp * ( monY - marginBottom - marginTop - 1 ) + marginTop + 1 + 0.5 )
                            local pixelY = math.floor( math.abs( 1 - vp ) * ( monY - marginBottom - marginTop - 1 ) + marginTop + 1 )

                            -- Write the mapped value 
                            -- newMonitor.monitor.setTextColor( graph[ data_file ].dot_color )
                            if ( graph[ data_file ] ) then 
                                newMonitor.monitor.setBackgroundColor( graph[ data_file ].line_color )
                            else 
                                newMonitor.monitor.setBackgroundColor( colors.white )
                            end 
                            newMonitor.monitor.setCursorPos( monX - index - marginRight + 1, pixelY )
                            newMonitor.monitor.write( " " )

                            if ( graph.lineConnectors and lastValue.value and lastValue.pixel and lastValue.pixel ~= pixelY ) then 
                                newMonitor.monitor.setBackgroundColor( colors.black )
                                newMonitor.monitor.setTextColor( colors.gray )
                                newMonitor.monitor.setCursorPos( monX - index - marginRight + 1, lastValue.pixel )
                                if ( lastValue.pixel > pixelY ) then 
                                    newMonitor.monitor.write( "\\" )
                                else 
                                    newMonitor.monitor.write( "/" )
                                end 

                                for pipe = lastValue.pixel + 1, pixelY - 1 do 
                                    newMonitor.monitor.setCursorPos( monX - index - marginRight + 1, pipe )
                                    newMonitor.monitor.write( "|" )
                                end 

                                for pipe = pixelY + 1, lastValue.pixel - 1 do 
                                    newMonitor.monitor.setCursorPos( monX - index - marginRight + 1, pipe )
                                    newMonitor.monitor.write( "|" )
                                end 
                            end 

                            lastValue.value = value 
                            lastValue.pixel = pixelY
                        end 
                    end 
                end 

                -- axis low/high labels 

                newMonitor.monitor.setBackgroundColor( colors.black )
                newMonitor.monitor.setTextColor( colors.white )

                newMonitor.monitor.setCursorPos( 2 + marginLeft, 1 + marginTop )
                newMonitor.monitor.write( "" .. datavalues.max )

                newMonitor.monitor.setCursorPos( 2 + marginLeft, monY - marginBottom )
                newMonitor.monitor.write( "" .. datavalues.min )
            end 
        end 

        -- Render the labels 
        for i, label in pairs( newMonitor.labels ) do 
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
            if ( button.bgColor ) then 
                newMonitor.monitor.setBackgroundColor( button.bgColor )
            end 
            newMonitor.monitor.setTextColor( button.textColor )
            newMonitor.monitor.setCursorPos( button.x, button.y )
            newMonitor.monitor.write( button.text )
        end 

        -- Render the progress bars  
        for i, bar in pairs( newMonitor.progressBars ) do 
            -- bar background 
            local blankText = ""
            local barWidth = monX - 3
            local calculatedPercent = ( bar.current / bar.max )

            for i = 0, barWidth do 
                blankText = blankText .. " " 
            end 

            if ( bar.bgColor ) then 
                newMonitor.monitor.setBackgroundColor( bar.bgColor )
            end 
            
            newMonitor.monitor.setTextColor( bar.textColor )

            for height = 0, bar.height - 1 do 
                newMonitor.monitor.setCursorPos( 2, bar.y + height )
                newMonitor.monitor.write( blankText )
            end 
            
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
            for height = 0, bar.height - 1 do 
                newMonitor.monitor.setCursorPos( 2, bar.y + height )
                newMonitor.monitor.write( blankText )
            end
        end 
    end 

    return newMonitor
end 

return MonitorAPI