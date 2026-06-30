fx_version "cerulean"
game "gta5"

author "Hyper"
version "0.0.1"

client_scripts {
    "Code/client-side.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "Code/server-side.lua"
}

shared_scripts {
    "config.lua"
}

ui_page "UI/index.html"

files {
    "UI/*.html",
    "UI/*.css",
    "UI/*.js",
    "UI/*.otf",
    "UI/images/*.png"
}

lua54 "yes"