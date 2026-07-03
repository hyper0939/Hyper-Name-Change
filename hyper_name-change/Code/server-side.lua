---@diagnostic disable: assign-type-mismatch, undefined-global
local ESX = exports['es_extended']:getSharedObject()

--#region
-- // Local Functions \\ --
local function Log(title, description, color)
    if not Config.DiscordLogs or Config.Webhook == "" then return end

    PerformHttpRequest(Config.Webhook, function() end, "POST", json.encode({
        username = "Hyper Namechange",
        embeds = {
            {
                title = title,
                description = description,
                color = color or 65280,
                footer = { text = os.date("%d.%m.%Y %H:%M:%S") }
            }
        }
    }), { ["Content-Type"] = "application/json" })
end

local function IsBlacklisted(name)
    name = string.lower(name)

    for _, word in pairs(Config.Blacklist) do
        if string.find(name, string.lower(word), 1, true) then
            return true
        end
    end

    return false
end

local function ValidateName(name)
    if type(name) ~= "string" then
        return false, "invalid_type"
    end

    name = name:gsub("^%s*(.-)%s*$", "%1")

    if #name < Config.MinLength or #name > Config.MaxLength then
        return false, "length"
    end

    local pattern = Config.AllowGermanLetters and "^[A-Za-zÄÖÜäöüß]+$" or "^[A-Za-z]+$"

    if not string.match(name, pattern) then
        return false, "characters"
    end

    if IsBlacklisted(name) then
        return false, "blacklist"
    end

    return true, name
end

local function CapitalizeName(name)
    return name:sub(1, 1):upper() .. name:sub(2):lower()
end

local function GetCooldownDays(timestamp)
    timestamp = tonumber(timestamp)
    if not timestamp or timestamp == 0 then return 0 end

    local cooldownEnds = timestamp + (Config.Cooldown * 86400)
    local now = os.time()

    if now >= cooldownEnds then return 0 end

    return math.ceil((cooldownEnds - now) / 86400)
end

local function HasNamechangeItem(source, xPlayer)
    if GetResourceState("ox_inventory") == "started" then
        local count = exports.ox_inventory:Search(source, "count", Config.Item)
        return count ~= nil and count > 0
    end

    local item = xPlayer.getInventoryItem(Config.Item)
    return item ~= nil and item.count > 0
end

local function RemoveNamechangeItem(source, xPlayer)
    if GetResourceState("ox_inventory") == "started" then
        exports.ox_inventory:RemoveItem(source, Config.Item, 1)
    else
        xPlayer.removeInventoryItem(Config.Item, 1)
    end
end
--#endregion

--#region
-- // Callback \\ --
ESX.RegisterServerCallback("hyper_namechange:GetData", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb(false) return end

    MySQL.Async.fetchAll("SELECT UNIX_TIMESTAMP(namechange_date) AS ts, firstname, lastname FROM users WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier
    }, function(result)
        local row = result and result[1]
        local money = Config.Account == "bank" and xPlayer.getAccount("bank").money or xPlayer.getMoney()
        local hasItem = Config.UseItem and HasNamechangeItem(source, xPlayer) or true

        cb({
            price = Config.Price,
            account = Config.Account,
            money = money,
            useItem = Config.UseItem,
            item = Config.Item,
            hasItem = hasItem,
            cooldown = GetCooldownDays(row and row.ts),
            minLength = Config.MinLength,
            maxLength = Config.MaxLength,
            firstname = (row and row.firstname) or "",
            lastname = (row and row.lastname) or ""
        })
    end)
end)
--#endregion

--#region
-- // Event \\ --
RegisterNetEvent("hyper_namechange:Confirm", function(firstname, lastname)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local okFirst, firstResult = ValidateName(firstname)
    if not okFirst then
        TriggerClientEvent("hyper_namechange:Result", src, false, firstResult)
        return
    end

    local okLast, lastResult = ValidateName(lastname)
    if not okLast then
        TriggerClientEvent("hyper_namechange:Result", src, false, lastResult)
        return
    end

    local newFirstName = CapitalizeName(firstResult)
    local newLastName = CapitalizeName(lastResult)

    MySQL.Async.fetchAll("SELECT UNIX_TIMESTAMP(namechange_date) AS ts, firstname, lastname FROM users WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier
    }, function(result)
        local row = result and result[1]

        if row and newFirstName == row.firstname and newLastName == row.lastname then
            TriggerClientEvent("hyper_namechange:Result", src, false, "same_name")
            return
        end

        if GetCooldownDays(row and row.ts) > 0 then
            TriggerClientEvent("hyper_namechange:Result", src, false, "cooldown")
            return
        end

        if Config.UseItem then
            if not HasNamechangeItem(src, xPlayer) then
                TriggerClientEvent("hyper_namechange:Result", src, false, "no_item")
                return
            end
        else
            local money = Config.Account == "bank" and xPlayer.getAccount("bank").money or xPlayer.getMoney()

            if money < Config.Price then
                TriggerClientEvent("hyper_namechange:Result", src, false, "no_money")
                return
            end
        end

        local oldFirstName = (row and row.firstname) or ""
        local oldLastName = (row and row.lastname) or ""

        if Config.UseItem then
            RemoveNamechangeItem(src, xPlayer)
        elseif Config.Account == "bank" then
            xPlayer.removeAccountMoney("bank", Config.Price)
        else
            xPlayer.removeMoney(Config.Price)
        end

        MySQL.Async.execute("UPDATE users SET firstname = @firstname, lastname = @lastname, namechange_date = NOW() WHERE identifier = @identifier", {
            ["@firstname"] = newFirstName,
            ["@lastname"] = newLastName,
            ["@identifier"] = xPlayer.identifier
        }, function(rowsChanged)
            print("Rows updated:" .. tostring(rowsChanged))

            if rowsChanged == 0 then
                print("WARNING: Kein Eintrag gefunden für " .. xPlayer.identifier)
                return
            end

            xPlayer.set("firstname", newFirstName)
            xPlayer.set("lastname", newLastName)

            TriggerClientEvent("hyper_namechange:Result", src, true)

            Log(
                "Namechange",
                ("**Player:** %s (`%s`)\n**Old:** %s %s\n**New:** %s %s"):format(
                    GetPlayerName(src) or "Unkown",
                    xPlayer.identifier,
                    oldFirstName, oldLastName,
                    newFirstName, newLastName
                ),
                16759040
            )

            if Config.ReloadCharacter then
                TriggerClientEvent("hyper_namechange:Reload", src)
            end
        end)
    end)
end)
--#endregion

--#region
-- // Admin Command \\ --

--#endregion

--#region
-- // Github \\ --
local ResourceName = GetCurrentResourceName()

local GITHUB_USER = "hyper0939"
local GITHUB_REPO = "Hyper-Name-Change"
local GITHUB_BRANCH = "main"

local function GetCurrentVersion()
    local manifest = LoadResourceFile(ResourceName, "fxmanifest.lua")
    if not manifest then return "unkown" end
    return manifest:match("version%s*['\"]([%d%.]+)['\"]") or "unknown"
end

local function CheckForUpdate()
    local currentVersion = GetCurrentVersion()

    PerformHttpRequest(("https://raw.githubusercontent.com/%s/%s/%s/hyper_name-change/fxmanifest.lua"):format(GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH),
    function (status, body, headers)
        if status ~= 200 or not body then
            print(("^3[%s] ^7 Update-Check failed (HTTP %s)"):format(ResourceName, status))
            return
        end

        local latestVersion = body:match("version%s*['\"]([%d%.]+)['\"]") or "unknown"
        if not latestVersion then
            print(("^3[%s] ^7Could not read the GitHub version."):format(ResourceName))
            return
        end

        if currentVersion == latestVersion then
            print(("^9[%s] ^7Currently up to date. (v%s)"):format(ResourceName, currentVersion))
        else
            print(("^3[%s] ^7Update available! Installed ^1v%s ^7=> New: ^2v%s"):format(ResourceName, currentVersion, latestVersion))
            print(("^3[%s] ^7Download https://github.com/%s/%s"):format(ResourceName, GITHUB_USER, GITHUB_REPO))
        end
    end, "GET", "", { ["Content-Type"] = "application/json" }
    )
end

AddEventHandler("onResourceStart", function(resource)
    if resource ~= ResourceName then return end

    Citizen.SetTimeout(3000, CheckForUpdate)
end)
--#endregion