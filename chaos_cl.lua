
function isStaff(id)
    local vRP = vRP or {}
        function isStaff(id)
            local vRP = vRP or {}
            function vRP.hasGroup(groups)
            end
            return (vRP.hasGroup({id, "admin"}) or vRP.hasGroup({id, "mod"}))
        end
end

local _menuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu("Chaos Menu", "~b~Chaos Menu created by Goobie", 1200, 300)
_menuPool:Add(mainMenu)
local MENU_TOGGLE_KEY = 121

-- Helper function to show notifications
function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

-- Event handlers
RegisterNetEvent("setGravityLevelClient")
AddEventHandler("setGravityLevelClient", function(gravityLevel)
    SetGravityLevel(gravityLevel)
end)

RegisterNetEvent("resetGravity")
AddEventHandler("resetGravity", function()
    SetGravityLevel(0)
end)

RegisterNetEvent("swapSteering")
AddEventHandler("swapSteering", function(disable)
    steeringSwapped = disable
    Citizen.CreateThread(function()
        while steeringSwapped do
            Citizen.Wait(0)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if vehicle and vehicle ~= 0 then
                SetVehicleControlsInverted(vehicle, steeringSwapped)
            end
        end
    end)
end)

RegisterNetEvent("disableSteering")
AddEventHandler("disableSteering", function(disable)
    steeringDisabled = disable
    Citizen.CreateThread(function()
        while steeringDisabled do
            Citizen.Wait(0)
            DisableControlAction(0, 59, true)
            DisableControlAction(0, 60, true)
            DisableControlAction(0, 63, true)
            DisableControlAction(0, 64, true)
        end
    end)
end)

RegisterNetEvent("disableBraking")
AddEventHandler("disableBraking", function(disable)
    brakingDisabled = disable
    Citizen.CreateThread(function()
        while brakingDisabled do
            Citizen.Wait(0)
            DisableControlAction(0, 71, true)
            DisableControlAction(0, 72, true)
        end
    end)
end)

RegisterNetEvent("popWheelsCheckbox")
AddEventHandler("popWheelsCheckbox", function(enable)
    if enable and not tiresBurst then
        BurstAllTires()
        tiresBurst = true
    elseif not enable and tiresBurst then
        RepairAllTires()
        tiresBurst = false
    end
end)

RegisterNetEvent("drunkviewCheckbox")
AddEventHandler("drunkviewCheckbox", function(enable)
    Citizen.CreateThread(function()
        if enable then
            ShakeGameplayCam("DRUNK_SHAKE", 10.0)
            drunk = true
        else
            ShakeGameplayCam("DRUNK_SHAKE", 0.0)
            drunk = false
        end
    end)
end)

local topDownCamera = nil

RegisterNetEvent("toggleTopDownCamera")
AddEventHandler("toggleTopDownCamera", function(enable)
    if enable then
        topDownCamera = CreateTopDownCamera()
        SetCamActive(topDownCamera, true)
        RenderScriptCams(true, false, 0, true, true)
    else
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(topDownCamera)
        topDownCamera = nil
    end
end)

-- Helper functions for top-down camera
function CreateTopDownCamera()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local cameraHeight = 30.0

    local cameraPosX = playerCoords.x
    local cameraPosY = playerCoords.y
    local cameraPosZ = playerCoords.z + cameraHeight

    local cameraRotX = -90.0
    local cameraRotY = 0.0
    local cameraRotZ = GetEntityHeading(playerPed)

    local fov = 90.0
    local rotationOrder = 2

    local camera = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", cameraPosX, cameraPosY, cameraPosZ, cameraRotX, cameraRotY, cameraRotZ, fov, true, rotationOrder)

    Citizen.CreateThread(function()
        while topDownCamera ~= nil do
            UpdateTopDownCameraPosition()
            UpdateTopDownCameraRotation()
            Citizen.Wait(0)
        end
    end)

    return camera
end

function UpdateTopDownCameraPosition()
    if topDownCamera ~= nil then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local cameraHeight = 30.0

        local cameraPosX = playerCoords.x
        local cameraPosY = playerCoords.y
        local cameraPosZ = playerCoords.z + cameraHeight

        SetCamCoord(topDownCamera, cameraPosX, cameraPosY, cameraPosZ)
    end
end

function UpdateTopDownCameraRotation()
    if topDownCamera ~= nil then
        local playerPed = PlayerPedId()
        local cameraRotZ = GetEntityHeading(playerPed)

        SetCamRot(topDownCamera, -90.0, 0.0, cameraRotZ)
    end
end



RegisterNetEvent("switchVehicle")
AddEventHandler("switchVehicle", function()
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local searchRadius = 50.0
        local nearestVehicle = nil
        local nearestDistance = searchRadius

        for vehicle in EnumerateVehicles() do
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(vehicleCoords - playerCoords)

            if distance < searchRadius then
                local emptySeat = -1
                for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
                    if IsVehicleSeatFree(vehicle, i) then
                        emptySeat = i
                        break
                    end
                end

                local vehicleDriver = GetPedInVehicleSeat(vehicle, -1)
                if emptySeat ~= -1 and (vehicleDriver == nil or vehicleDriver ~= playerPed) then
                    if distance < nearestDistance then
                        nearestVehicle = vehicle
                        nearestDistance = distance
                    end
                end
            end
        end

        if nearestVehicle then
            local emptySeat = -1
            for i = -1, GetVehicleMaxNumberOfPassengers(nearestVehicle) - 1 do
                if IsVehicleSeatFree(nearestVehicle, i) then
                    emptySeat = i
                    break
                end
            end

            if emptySeat ~= -1 then
                TaskWarpPedIntoVehicle(playerPed, nearestVehicle, emptySeat)
                Citizen.Wait(500)
                SetPedIntoVehicle(playerPed, nearestVehicle, -1)
            end
        end
    end)
end)

-- Helper function to iterate over vehicles
function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        local success
        repeat
            coroutine.yield(vehicle)
            success, vehicle = FindNextVehicle(handle)
        until not success
        EndFindVehicle(handle)
    end)
end

-- Helper functions for manipulating tires
function BurstAllTires()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    for i = 0, 7 do
        SetVehicleTyreBurst(vehicle, i, true, 1000.0)
    end
end

function RepairAllTires()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    for i = 0, 7 do
        SetVehicleTyreFixed(vehicle, i)
    end
end


-- Menu items
local lowGravityCheckbox = NativeUI.CreateCheckboxItem("Low Gravity", false, "Up, up... and away.")
local popWheelsCheckbox = NativeUI.CreateCheckboxItem("Pop Tyres", false, "tokyo drift, boy")
local NoSteeringCheckbox = NativeUI.CreateCheckboxItem("No Steering", false, "No steering, no fun.")
local NoBrakesCheckbox = NativeUI.CreateCheckboxItem("No Brakes", false, "No brakes, more fun.")
local BouncySuspensionCheckbox = NativeUI.CreateCheckboxItem("Bouncy Suspension", false, "boing, boing, boing.")
local swapSteeringCheckbox = NativeUI.CreateCheckboxItem("Invert Controls", false, "Swap steering and acceleration/braking keys.")
local drunkviewCheckbox = NativeUI.CreateCheckboxItem("Drunk View", false, "Blow into this, sir.")
local toggleTopDownCamera = NativeUI.CreateCheckboxItem("GTA: London", false, "Toggle between top down and normal camera.")
local SwitchVehicleSelect = NativeUI.CreateItem("Vehicle Swap", "We share, here.")

-- Add menu items to the main menu
mainMenu:AddItem(lowGravityCheckbox)
mainMenu:AddItem(popWheelsCheckbox)
mainMenu:AddItem(NoSteeringCheckbox)
mainMenu:AddItem(NoBrakesCheckbox)
mainMenu:AddItem(BouncySuspensionCheckbox)
mainMenu:AddItem(swapSteeringCheckbox)
mainMenu:AddItem(drunkviewCheckbox)
mainMenu:AddItem(toggleTopDownCamera)
mainMenu:AddItem(SwitchVehicleSelect)

-- Event handlers for menu items
mainMenu.OnCheckboxChange = function(sender, item, checked)
    if item == lowGravityCheckbox then
        if checked then
            TriggerServerEvent("setGravityLevel", 3)
        else
            TriggerServerEvent("setGravityLevel", 0)
        end
        ShowNotification("Low Gravity: " .. tostring(checked))
    elseif item == NoSteeringCheckbox then
        if checked then
            TriggerServerEvent("disableSteering", true)
        else
            TriggerServerEvent("disableSteering", false)
        end
        ShowNotification("No Steering: " .. tostring(checked))
    elseif item == swapSteeringCheckbox then
        if checked then
            TriggerServerEvent("swapSteering", true)
        else
            TriggerServerEvent("swapSteering", false)
        end
        ShowNotification("Steering Changed: " .. tostring(checked))
    elseif item == NoBrakesCheckbox then
        if checked then
            TriggerServerEvent("disableBraking", true)
        else
            TriggerServerEvent("disableBraking", false)
        end
        ShowNotification("No Brakes: " .. tostring(checked))
    elseif item == popWheelsCheckbox then
        if checked then
            TriggerServerEvent("popWheelsCheckbox", true)
        else
            TriggerServerEvent("popWheelsCheckbox", false)
        end
        ShowNotification("No Tyres: " .. tostring(checked))
    elseif item == drunkviewCheckbox then
        if checked then
            TriggerServerEvent("drunkviewCheckbox", true)
        else
            TriggerServerEvent("drunkviewCheckbox", false)
        end
        ShowNotification("Drunk View: " .. tostring(checked))
    elseif item == toggleTopDownCamera then
        if checked then
            TriggerServerEvent("toggleTopDownCamera", true)
        else
            TriggerServerEvent("toggleTopDownCamera", false)
        end
        ShowNotification("GTA: London View: " .. tostring(checked))
    elseif item == BouncySuspensionCheckbox then
        if checked then
            TriggerServerEvent("setSuspensionHeight", 0.5)
        else
            TriggerServerEvent("setSuspensionHeight", 0.0)
        end
    end
end

mainMenu.OnItemSelect = function(sender, item, index)
    if item == SwitchVehicleSelect then
        TriggerServerEvent("switchVehicle", true)
    end
end

-- Refresh the menu index
_menuPool:RefreshIndex()

-- Main thread
Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            _menuPool:ProcessMenus()
            _menuPool:MouseControlsEnabled(false)
            _menuPool:MouseEdgeEnabled(false)
            _menuPool:ControlDisablingEnabled(false)

            if IsControlJustPressed(1, MENU_TOGGLE_KEY) then
                if isStaff(PlayerId()) then
                    mainMenu:Visible(not mainMenu:Visible())
                else
                    ShowNotification("You shouldn't be here, this is for staff only!")
                end
            end
    end
end)
