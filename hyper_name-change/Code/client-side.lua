local ESX = exports['es_extended']:getSharedObject()

local isOpen = false

--#region
-- // Open UI \\ --
local function OpenUI()
    if isOpen then return end

    ESX.TriggerServerCallback("hyper_namechange:GetData", function(data)
        if not data then return end

        if data.cooldown and data.cooldown > 0 then
            if Config.CustomNotify then
                Config.Notify(Config.Languages["notify_title"], (Config.Languages["cooldown_error"]):format(data.cooldown), Config.Languages["notify_type-error"], 5000)
            else
                lib.notify({
                    title = Config.Languages["notify_title"],
                    description = Config.Languages["cooldown_error"]:format(data.cooldown),
                    type = "error"
                })
            end
            return
        end

        if data.useItem and not data.hasItem then
            if Config.CustomNotify then
                Config.Notify(Config.Languages["notify_title"], (Config.Languages["item_error"]):format(data.item), Config.Languages["notify_type-error"], 5000)
            else
                lib.notify({
                    title = Config.Languages["notify_title"],
                    description = Config.Languages["cooldown_error"]:format(data.cooldown),
                    type = "error"
                })
            end
            return
        end

        isOpen = true
        SetNuiFocus(true, true)

        SendNUIMessage({
            action = "Show",
            price = data.price,
            account = data.account,
            useItem = data.useItem,
            item = data.item,
            firstname = data.firstname,
            lastname = data.lastname,
            minLength = data.minLength,
            maxLength = data.maxLength
        })
    end)
end

local function CloseUI()
    if not isOpen then return end

    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "Hide" })
end
--#endregion

--#region
-- // Open Command / NPC \\ --
RegisterCommand(Config.Command, function()
    OpenUI()
end, false)

RegisterNetEvent("hyper_namechange:Open", function()
    OpenUI()
end)
--#endregion

--#region
-- // NUI Callbacks \\ --
RegisterNUICallback("Close", function(_, cb)
    CloseUI()
    cb("ok")
end)

RegisterNUICallback("Confirm", function(data, cb)
    if not data or not data.firstname or not data.lastname then
        cb("error")
        return
    end

    TriggerServerEvent("hyper_namechange:Confirm", data.firstname, data.lastname)
    cb("ok")
end)
--#endregion

--#region
-- // Server --> Client \\ --
local ErrorMessages = {
    length = (Config.Languages["length_error"]):format(Config.MinLength, Config.MaxLength),
    characters = Config.Languages["characters_error"],
    blacklist = Config.Languages["blacklist_error"],
    cooldown = Config.Languages["cooldown_error2"],
    no_money = Config.Languages["no_money_error"],
    no_item = (Config.Languages["no_item_error"]):format(Config.Item),
    invalid_type = Config.Languages["invalid_type_error"]
}

RegisterNetEvent("hyper_namechange:Result", function(success, reason)
    if success then
        if Config.CustomNotify then
                Config.Notify(Config.Languages["notify_title"], Config.Languages["success"], Config.Languages["notify_type-success"], 5000)
            else
                lib.notify({
                    title = Config.Languages["notify_title"],
                    description = Config.Languages["success"],
                    type = "success"
                })
        end
    else
        if Config.CustomNotify then
                Config.Notify(Config.Languages["notify_title"], ErrorMessages[reason] or Config.Languages["smth_happend"], Config.Languages["notify_type-error"], 5000)
            else
                lib.notify({
                    title = Config.Languages["notify_title"],
                    description = Config.Languages["success"],
                    type = "success"
                })
            end
        SendNUIMessage({ action = "Error", field = reason })
    end
end)

RegisterNetEvent("hyper_namechange:Reload", function()
    -- You can do here your custom logic
    TriggerEvent("esx:restoreLoadout")
end)
--endregion

--#region
-- // ESC \\ --
CreateThread(function()
    while true do
        local sleep = 500

        if isOpen then
            sleep = 0

            if IsControlJustPressed(0, 322) then
                CloseUI()
            end
        end
        Wait(sleep)
    end
end)
--#endregion

--#region
-- // NPC \\ --
if not Config.NPC or not Config.NPC.Enabled then return end

local npcEntity = nil

CreateThread(function()
    local model = GetHashKey(Config.NPC.Model)
    RequestModel(model)

    local Timeout = 0
    while not HasModelLoaded(modl) do
        Wait(10)
        Timeout = Timeout + 1
    end

    npcEntity = CreatePed(4, model, Config.NPC.Coords.x, Config.NPC.Coords.y, Config.NPC.Coords.z - 1.0, Config.NPC.Heading or 0.0, false, true)

    SetEntityInvincible(npcEntity, true)
    FreezeEntityPosition(npcEntity, true)
    SetBlockingOfNonTemporaryEvents(npcEntity, true)
    SetEntityAsMissionEntity(npcEntity, true, true)

    if GetResourceState("ox_target") == "started" then
        exports.ox_target:addLocalEntity(npcEntity, {
            {
                name = "hyper_namechange",
                icon = "fa-solid fa-pen",
                label = "Namechange", -- Languages
                onSelect = function()
                    TriggerEvent("hyper_namechange:Open")
                end
            }
        })
    end
end)

CreateThread(function()
    if GetResourceState("ox_target") == "started" then return end

    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.NPC.Coords)

        if dist < 10.0 then
            sleep = 0

            if dist < 2.0 then
                DrawMarker(2,
                    Config.NPC.Coords.x, Config.NPC.Coords.y, Config.NPC.Coords.z + 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0.3, 0.3, 0.3,
                    0, 163, 255, 150,
                    false, true, 2, false, nil, nil, false
                )

                if IsControlJustPressed(0, 38) then
                    TriggerEvent("hyper_namechange:Open")
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    if npcEntity and DoesEntityExist(npcEntity) then
        DeleteEntity(npcEntity)
    end
end)