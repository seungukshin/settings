-- check input method
--hs.hotkey.bind({'cmd'}, 'i', function()
--	local input_source = hs.keycodes.currentSourceID()
--	print(input_source)
--end)

-- change input method to english with esc
local inputEnglish = "com.apple.keylayout.US"
local esc_bind
function convert_to_eng_with_esc()
	local inputSource = hs.keycodes.currentSourceID()
	if not (inputSource == inputEnglish) then
		hs.eventtap.keyStroke({}, 'right')
		hs.keycodes.currentSourceID(inputEnglish)
	end
	esc_bind:disable()
	hs.eventtap.keyStroke({}, 'escape')
	esc_bind:enable()
end
esc_bind = hs.hotkey.new({}, 'escape', convert_to_eng_with_esc):enable()

return esc_bind
