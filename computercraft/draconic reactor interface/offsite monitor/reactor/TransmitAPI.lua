
local TransmitAPI = {
    thisChannel = nil,
    modem = nil
}

TransmitAPI.setWirelessModem = function ( side )
    TransmitAPI.modem = peripheral.wrap( side )
end 

TransmitAPI.openChannel = function ( number ) 
    TransmitAPI.thisChannel = number 
    TransmitAPI.modem.open( TransmitAPI.thisChannel )
end

TransmitAPI.closeChannel = function () 
    TransmitAPI.modem.close( TransmitAPI.thisChannel )
end

TransmitAPI.sendReply = function ( payload ) 
    if not payload then payload = {} end 

    payload.timestamp = os.clock()
    TransmitAPI.modem.transmit( payload.reactorChannel, TransmitAPI.thisChannel, payload )
    return true 
end 

TransmitAPI.waitReply = function () 
    local event_type, peripheral_name, _thischannel, reactorChannel, payload = os.pullEvent( "modem_message" )
    return reactorChannel, payload
end 

return TransmitAPI
