local FRemap = require('foundation_remapping')
local remapper = FRemap.new({vendorID=0x29ea, productID=0x0102})

-- swap enter and space
remapper:remap(0x31, 0x24):remap(0x24, 0x31)
--remapper:remap(0x70000002c, 0x700000028):remap(0x700000028, 0x70000002c)

remapper:register()

return remapper
