# Hyper Name Change

![alt text](<Group 1.png>)

# Features:
- Payment by cash, bank account, or item.
- Configurable cooldown between name changes
- Blacklist for prohibited names
- Support for German umlauts (Ä, Ö, Ü, ä, ö, ü, ß) can be enabled optionally.
- Optional NPC to open the menu (with `ox_target` support or a custom marker system)
- Discord webhook logging of all name changes
- Compatible with `ox_lib` notifications or a custom notification system (e.g., `hyper_notify`)
- Automatic update check upon resource startup

# Dependencies:
- oxmysql
- ox_lib (optional, if "Config.CustomNotify = false")
- ox_target (optional, NPC Interaction)
- ox_inventory (optional)

# Use:
- Open menu via command: `/namechange`
- Or via NPC (default: interact with `E` or `ox_target`)
- ESC closes the menu at any time.