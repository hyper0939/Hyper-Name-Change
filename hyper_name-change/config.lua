Config = {}

Config.Framework = "ESX"

Config.Price = 6700
Config.Account = "money" -- money | bank

Config.UseItem = false
Config.Item = "namechange"

Config.Cooldown = 7 -- Days

Config.MinLength = 3
Config.MaxLength = 15

Config.AllowGermanLetters = true

Config.DiscordLogs = true
Config.Webhook = ""

Config.ReloadCharacter = false

Config.CloseKey = "ESC"
Config.Command = "namechange"

Config.AdminGroups = {
    "admin"
}

Config.Blacklist = {
    "admin",
    "owner",
    "team",
    "developer",
    "dev"
}

Config.NPC = {
    Enabled = true,
    Model = "a_m_y_business_01",
    Coords = vector3(414.7470, -1631.8112, 29.2919),
    Heading = 139.7066
}

Config.CustomNotify = true -- if false then ox_lib
Config.Notify = function(title, message, type, time)
    exports["hyper_notify"]:Notify(title, message, type, time)
end

Config.Languages = {
    ["notify_type-error"] = "Error",
    ["notify_type-success"] = "Success",
    ["notify_title"] = "Namechange",

    ["cooldown_error"] = "Du musst noch %s Tag(e) warten, bevor du deinen Namen erneut ändern kannst.",
    ["item_error"] = "Du benötigst das Item %s",

    ["length_error"] = "Name muss zwischen %s und %d Zeichen lang sein",
    ["characters_error"] = "Name enthält ungültige Zeichen",
    ["blacklist_error"] = "Dieser Name ist nicht erlaubt",
    ["cooldown_error2"] = "Du musst noch warten, bevor du deinen Namen erneut ändern kannst",
    ["no_money_error"] = "Du hast nicht genug Geld",
    ["no_item_error"] = "Du benötigst das Item: %s",
    ["invalid_type_error"] = "Ungültige Eingabe",

    ["success"] = "Dein Name wurde erfolgreich geändert.",
    ["smth_happend"] = "Ein Fehler ist aufgetreten"
}