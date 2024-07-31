
local ControllerAPI = require( "ControllerAPI" )
local irlib = require( "irlib" )

local storageMonitorObject = {
    energyStorages = {}
}

storageMonitorObject.newMonitor = function ( payload )
    if not payload.storage_name then return end 
    storageMonitorObject.energyStorages[ payload.storage_name ] = {
        monitorId,
        peripheral_name,
        storage_name,
        storageChannel
    }

    local energyStorage = storageMonitorObject.energyStorages[ payload.storage_name ]

    energyStorage.monitorId = payload.monitorId
    energyStorage.peripheral_name = payload.peripheral_name
    energyStorage.storage_name = payload.storage_name
    -- energyStorage.storageChannel = payload.storageChannel

    if ( not energyStorage.monitorId ) then 
        energyStorage.monitorId = energyStorage.peripheral_name 
    end 
    
    -- ControllerAPI.addMonitor( "storage", "monitor_29" )
    ControllerAPI.addMonitor( energyStorage.monitorId, energyStorage.peripheral_name )
    ControllerAPI.configureStorage( energyStorage.storage_name )

    storageMonitorObject.constructMonitorGUI( payload )
end 


-- The GUI 

storageMonitorObject.constructMonitorGUI = function ( payload2 ) -- "payload arg already in use below"

    -- ControllerAPI.configureStorage( "draconic_rf_storage_3" )
    local energyStorage = storageMonitorObject.energyStorages[ payload2.storage_name ]
    local monStorage = ControllerAPI.monitors[ energyStorage.monitorId ]

    -- First flux gate pair monitoring 

    monStorage.addLabel( {
        id = "genericstoragelabel",
        -- text = "Energy Storage " .. energyStorage.monitorId,
        text = "Storage " .. energyStorage.storage_name,
        x = 1,
        y = 12,
        textColor = colors.gray
    } )

    local storageCurrentEnergy = {
        id = "storageCurrentEnergy",
        text = "test label here",
        x = 2,
        y = 2,
        textColor = colors.white,
        bgColor = colors.black
    }

    storageCurrentEnergy.onRefresh = function ( payload, lastResponse ) 
        storageCurrentEnergy.text = "Current RF: " .. irlib.convertRF( lastResponse.energyStorages[ energyStorage.storage_name ].energyStored )
    end 
    monStorage.addLabel( storageCurrentEnergy )

    local storageMaxEnergy = {
        id = "storageMaxEnergy",
        text = "test label here",
        x = 2,
        y = 5,
        textColor = colors.white,
        bgColor = colors.black
    }

    storageMaxEnergy.onRefresh = function ( payload, lastResponse ) 
        storageMaxEnergy.text = "Max RF: " .. irlib.convertRF( lastResponse.energyStorages[ energyStorage.storage_name ].maxEnergyStored )
    end 
    monStorage.addLabel( storageMaxEnergy )

    local transferRate = {
        id = "transferRate",
        text = "test label here",
        x = 2,
        y = 6,
        textColor = colors.white,
        bgColor = colors.black
    }

    transferRate.onRefresh = function ( payload, lastResponse ) 
        transferRate.text = "Transfer RF: " .. irlib.convertRF( lastResponse.energyStorages[ energyStorage.storage_name ].transferRate, true )
    end 
    monStorage.addLabel( transferRate )

    local energyPercentage = {
        id = "energyPercentage",
        y = 3,
        textColor = colors.white,
        bgColor = colors.lightGray,
        current = 0,
        max = 100,
        thresholds = {
            { max = 1, color = colors.lime },
            { max = 0.9, color = colors.orange },
            { max = 0.5, color = colors.red }
        }
    }

    energyPercentage.onRefresh = function ( payload, lastResponse ) 
        energyPercentage.current = lastResponse.energyStorages[ energyStorage.storage_name ].energyStored
        energyPercentage.max = lastResponse.energyStorages[ energyStorage.storage_name ].maxEnergyStored
    end 
    monStorage.addProgressBar( energyPercentage )
end 

return storageMonitorObject