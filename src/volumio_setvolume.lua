--[[
    volumio_setvolume.lua
    Set the volume of Volumio by sending API request using the level of a Domoticz switch, type dimmer (slider).
    The Volumio response is a JSON string, i.e {"time":1549566800842,"response":"volume Success"}

    Request Example setting the volume to 80:
    requesturl = 'volumio.local/api/v1/commands/?cmd=volume&volume=80'
    Response:
    {"time":1549566800842,"response":"volume Success"}

    Project: atHome
    Interpreter: dzVents, Timer
    See: athome.pdf
    Author: Robert W.B. Linn
    Version: 20190207
]]--

-- Request url (see reference https://volumio.github.io/docs/API/REST_API.html)
-- Example setting the Volumiovolume to 80:
-- volumio.local/api/v1/commands/?cmd=volume&volume=80
-- Response: 
-- {"time":1549566800842,"response":"volume Success"}
-- Added to the url is the value (level) of the switch (dimmer)
local requesturl = 'volumio.local/api/v1/commands/?cmd=volume&volume='

-- Idx of the devices
local IDX_VOLUMIOVOLUMESLIDER = 148

-- volume
local volume

return {
	on = {
		devices = {
			IDX_VOLUMIOVOLUMESLIDER
		},
		httpResponses = {
            'volumioSetVolume'
        }
	},
	execute = function(domoticz, item)
		domoticz.log('Device ' .. domoticz.devices(IDX_VOLUMIOVOLUMESLIDER).name .. ' was changed:' .. tostring(domoticz.devices(IDX_VOLUMIOVOLUMESLIDER).level), domoticz.LOG_INFO)

        -- if the device is changed then set the volume by adding the switch level to the api command
		if (item.isDevice) then

            -- get the level =  volume
            volume = domoticz.devices(IDX_VOLUMIOVOLUMESLIDER).level

            -- check if the device has been switched off = set volume to 0
            if (domoticz.devices(IDX_VOLUMIOVOLUMESLIDER).state == 'Off') then
                volume = 0    
            end

            domoticz.openURL({
                url = requesturl .. tostring(volume),
                method = 'GET',
                callback = 'volumioSetVolume'
            })
		end

		-- callback handling the url get request response
        if (item.isHTTPResponse) then

            if (item.ok) then -- statusCode == 2xx
                domoticz.log('[INFO] Volumio Volume set to ' .. tostring(domoticz.devices(IDX_VOLUMIOVOLUMESLIDER).level), domoticz.LOG_INFO)
            end

            if not (item.ok) then -- statusCode != 2xx
                local message = '[ERROR] Volumio Volume: ' .. tostring(item.statusCode) .. ' ' .. msgbox.isnowdatetime(domoticz)
                domoticz.helpers.alertmsg(domoticz, domoticz.ALERTLEVEL_YELLOW, message)
                domoticz.log(message, domoticz.LOG_INFO)
            end
        end

	end
}

