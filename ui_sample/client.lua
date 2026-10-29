-- /bridgeui opens the panel; the Close button and Escape give focus back.
local open = false

local function setOpen(state)
    open = state
    SetNuiFocus(state, state)
    SendNUIMessage({ action = state and 'open' or 'close' })
end

RegisterCommand('bridgeui', function() setOpen(not open) end, false)

RegisterNUICallback('close', function(_, cb)
    setOpen(false)
    cb({ ok = true })
end)

RegisterNUICallback('hello', function(_, cb)
    TriggerServerEvent('frt_ui_sample:hello')
    cb({ ok = true })
end)
