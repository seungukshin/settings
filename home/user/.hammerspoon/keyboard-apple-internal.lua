local FRemap = require('foundation_remapping')
--local remapper = FRemap.new({vendorID=0x05ac, productID=0x0340})
local remapper = FRemap.new({vendorID=0, productID=0})

-- swap capslock and left control
remapper:remap(0x39, 'lctrl'):remap('lctrl', 0x39)
-- swap escape and grave
--remapper:remap(0x35, 0x32):remap(0x32, 0x35)
--remapper:remap(0x35, 0x0a):remap(0x0a, 0x35)

remapper:register()

return remapper
