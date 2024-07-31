
local args, opt = {...}
local findtext = args[ 1 ]
if ( not ( args and findtext ) ) then 
    print( "Usage: peripheral_dump <network peripheral>" )
    return
end

print( findtext )

local component = peripheral.wrap( findtext )

if not component then 
    print( "Peripheral " .. findtext .. " not found" ) 
    return
end 

local filePath = "workspace/peripheral_dumps/" .. findtext
if ( fs.exists( filePath ) ) then 
    print( "Peripheral dump already exists" )
    return
end

local fileText = ""

for k, v in pairs( component ) do 
    fileText = fileText .. k .. ": " .. type( v ) .. "\n"
end 

print( "Writing to " .. filePath .. "..." )
local newFile = io.open( filePath, "w" ):write( fileText )
newFile:close()

print( "Done!" )
return true