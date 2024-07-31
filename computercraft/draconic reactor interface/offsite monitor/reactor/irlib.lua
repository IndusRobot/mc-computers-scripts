
local irlib = {
    rfUnits = {
        "RF",
        "kRF",
        "MRF",
        "GRF",
        "TRF",
        "PRF",
        "ERF",
        "ZRF",
        "YRF"
    }
}

irlib.toFixed = function ( number, decimals )
    if not decimals then decimals = 0 end 
    local decimalmath = math.pow( 10, decimals )
    return math.floor( number * decimalmath ) / decimalmath
end 

irlib.convertRF = function ( number )
    local unit = 1
    
    while ( ( number <= -1000 or number >= 1000 ) and unit < #irlib.rfUnits ) do 
        unit = unit + 1
        number = number / 1000
    end 

    return irlib.toFixed( number, 3 ) .. irlib.rfUnits[ unit ]
end 

return irlib 
