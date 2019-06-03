--[[
    volumio_shutdown.lua
    Shutdown volumio_shutdown
    Project: atHome
    Interpreter: dzVents, Timer
    See: athome.pdf
    Author: Robert W.B. Linn
    Version: 20190207
]]--

-- Request url (see reference https://volumio.github.io/docs/API/REST_API.html)
local cmd = '/volumio/app/plugins/system_controller/volumio_command_line_client/commands/playback.js shutdown'

-- Idx of the devices
local IDX_VOLUMIOSHUTDOWNSWITCH = 150

-- volume
local volume

return {
	on = {
		devices = {
			IDX_VOLUMIOSHUTDOWNSWITCH
		}
	},
	execute = function(domoticz, device)
		domoticz.log('Device ' .. device.name .. ' was changed:' .. tostring(device.state), domoticz.LOG_INFO)

        -- check if the device has been switched off = 
        if (device.state == 'On') then
            local handle = io.popen(cmd .. ' || echo error')
            local result = handle:read("*a")
            handle:close()
            if(result ~= 'error\n') then
	            domoticz.log(result)
            else
	            domoticz.log('failure with io.popen')
            end
            -- local r = tostring(os.execute(cmd))
		    -- domoticz.log('Volumio shutdown initiated. State:' .. r, domoticz.LOG_INFO)
		    device.switchOff()
		end
	end
}

