function split (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end 

function replace( text, symbol1, symbol2 )
    return table.concat( split( text, symbol1 ), symbol2 )
end  

function writeFile( filename, text )
    local file = fs.open( filename, "w" )
    file.write( text )
    file.close()
    return true 
end 


