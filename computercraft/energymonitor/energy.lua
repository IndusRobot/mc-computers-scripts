
local DatabaseAPI = require( "DatabaseAPI" )
local energyGeneratorInput = peripheral.wrap( "energyDetector_0" )
local energyConsumerOutput = peripheral.wrap( "energyDetector_1" )
local storageUnit = peripheral.wrap( "eliteEnergyCube_0" )

print( "- Building energy monitors" )

local thelabelinquestion = {
    action = "addLabel", 
    id = "cube_label",
    text = "cube_label",
    x = 2,
    y = 16,
    textColor = colors.white,
}

thelabelinquestion.onRefresh = function ( component, monitorAPI ) 
    component.text = "Energy Storage: " .. math.ceil( storageUnit.getEnergy() / storageUnit.getMaxEnergy() * 100 ) .. "%"
end

local thebarinquestion = {
    action = "addProgressBar",
    id = "capacitor_readings",
    y = 17,
    height = 2,
    textColor = colors.white,   
    bgColor = colors.lightGray,
    current = 0,
    max = 100,
    thresholds = {
        { max = 1, color = colors.lime },
        { max = 0.75, color = colors.yellow },
        { max = 0.5, color = colors.orange },
        { max = 0.25, color = colors.red },
    },
}
thebarinquestion.onRefresh = function ( component, monitor ) 
    component.current = storageUnit.getEnergy()
    component.max = storageUnit.getMaxEnergy()
end

local theobjectinquestion = {
    id = "myMonitor1",
    peripheral_name = "monitor_3",
    components = {
        {
            action = "addLabel", 
            id = "i_o_readings", 
            text = "Energy Generation and Usage",
            x = 2,
            y = 2,
            textColor = colors.white,
        },
        {
            action = "addGraph",
            id = "energy_readings",
            maximum_values = 36,
            margin = {
                top = 2,
                right = 1, 
                bottom = 5,
                left = 1
            },
            axisColor = colors.gray,
            lineConnectors = false,
            energyGeneratorInput = {
                line_color = colors.lime
            },
            energyConsumerOutput = {
                line_color = colors.red
            },
        },
        thelabelinquestion,
        thebarinquestion,
        {
            action = "addLabel", 
            text = "-IndusRobot", 
            x = 29  ,
            y = 19,
            textColor = colors.gray,
        },
    },
    getDatapoints = function ()
        return {
            energy_readings = {
                energyGeneratorInput = energyGeneratorInput.getTransferRate(),
                energyConsumerOutput = energyConsumerOutput.getTransferRate(),
            },
            cube_readings = {
                power_level = storageUnit.getEnergy() * 0.4
            }
        }
    end 
}

DatabaseAPI.newMonitor( theobjectinquestion )

print( "- Starting controller" )
DatabaseAPI.startMainMonitorListener() 
