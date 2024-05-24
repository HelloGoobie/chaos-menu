RegisterServerEvent("setGravityLevel")
AddEventHandler("setGravityLevel", function(gravityLevel)
    if gravityLevel == 0 then
        TriggerClientEvent("resetGravity", -1)
    else
        TriggerClientEvent("setGravityLevelClient", -1, gravityLevel)
    end
end)

RegisterServerEvent("disableSteering")
AddEventHandler("disableSteering", function(disable)
        TriggerClientEvent("disableSteering", -1, disable)
end)

RegisterServerEvent("swapSteering")
AddEventHandler("swapSteering", function(disable)
        TriggerClientEvent("swapSteering", -1, disable)
end)

RegisterServerEvent("disableBraking")
AddEventHandler("disableBraking", function(disable)
        TriggerClientEvent("disableBraking", -1, disable)
end)

RegisterServerEvent("switchVehicle")
AddEventHandler("switchVehicle", function()
        TriggerClientEvent("switchVehicle", -1)
end)

RegisterServerEvent("popWheelsCheckbox")
AddEventHandler("popWheelsCheckbox", function(disable)
    TriggerClientEvent("popWheelsCheckbox", -1, disable)
end)

RegisterServerEvent("drunkviewCheckbox")
AddEventHandler("drunkviewCheckbox", function(disable)
    TriggerClientEvent("drunkviewCheckbox", -1, disable)
end)

RegisterServerEvent("toggleTopDownCamera")
AddEventHandler("toggleTopDownCamera", function(disable)
    TriggerClientEvent("toggleTopDownCamera", -1, disable)
end)
