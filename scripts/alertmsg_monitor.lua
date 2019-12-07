--[[
    alertmsg_monitor.lua
    If level (nValue) of the Alert Messages device > threshold (set by uservarable TH_ALERTTOEMAIL) , then send email notification.
    Project: domoticz-homeautomation-workbook
    Interpreter: dzVents
    Author: Robert W.B. Linn
    Version: 20190713
]]--

-- Idx of the devices used
local IDX_ALERTMSG = 55
local IDX_TH_ALERTTOEMAIL = 14

return {
    -- Check which device(s) have a state change
  on = {
    devices = { IDX_ALERTMSG}
  },
  data = {
      -- keep the prev notified date
      prevtimenotified = { initial = os.time() }
    },
    -- Handle the switch if its state has changed to On
  execute = function(domoticz, device)

    domoticz.log('Device ' .. device.name .. ' was changed ' .. tostring(device.nValue) .. ' (timediff:' .. tostring(domoticz.helpers.timediff(domoticz.data.prevtimenotified)) .. ')')

        -- Send email notification in case level = 4 (or other see user var TH_ALERTTOEMAIL)
        -- Only the subject is used
      if (device.nValue == domoticz.variables(IDX_TH_ALERTTOEMAIL).value) and (domoticz.helpers.timediff(domoticz.data.prevtimenotified) > 60) then
            domoticz.notify(device.text, '' , domoticz.PRIORITY_HIGH)
        domoticz.log('Device ' .. device.name .. ' notification sent: ' .. tostring(domoticz.helpers.timediff(os.time())))
            domoticz.data.prevtimenotified = os.time()
    end

    end
}
