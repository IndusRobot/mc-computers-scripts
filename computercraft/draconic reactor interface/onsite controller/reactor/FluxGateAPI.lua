
local FluxGateAPI = {

}

FluxGateAPI.newFluxGate = function ( peripheral_name )
    local newGate = {
        peripheral = peripheral.wrap( peripheral_name ),
        transferLow = 0,
        transferHigh = 0,
        transferRate = 0
    }

    -- init 
    newGate.transferLow = newGate.peripheral.getSignalLowFlow()
    newGate.transferHigh = newGate.peripheral.getSignalHighFlow()
    newGate.peripheral.setOverrideEnabled( false )

    -- methods 
    newGate.setTransferLow = function ( num )
        newGate.transferLow = num 
        newGate.peripheral.setSignalLowFlow( newGate.transferLow )
        print( peripheral_name .. " setTransferLow: " .. tostring( num ) )
    end 

    newGate.setTransferHigh = function ( num )
        newGate.transferHigh = num 
        newGate.peripheral.setSignalHighFlow( newGate.transferHigh )
        print( peripheral_name .. " setSignalHighFlow: " .. tostring( num ) )
    end 

    newGate.getAllData = function ( num )
        newGate.transferRate = newGate.peripheral.getFlow()
    end 

    return newGate
end 

return FluxGateAPI 
