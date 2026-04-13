# Snipe Admin Menu

## Table of Contents
1. [Initial Setup](#initial-setup)
2. [Configuration & Compatibility](#configuration--compatibility)
3. [Permissions & Roles](#permissions--roles)
4. [Features](#features)
5. [Customization](#customization)
6. [Exports & Developer Options](#exports--developer-options)

---

## Initial Setup

### Step 1: Configuration
- Read the comments in the config files carefully
- Only edit the necessary settings for your server
- Configuration files are located in the `config/` folder

### Step 2: Compatibility
This script includes compatibility for multiple paid scripts. Review `config/config_compatibility.lua` and make the necessary adjustments for:
- Your inventory system
- Your clothing system
- Your framework (ESX, QB, QBX)
- Any other paid scripts you use

### Step 3: Inventory Setup (QB/LJ Inventory)
Add the following events at the **end** of `inventory/client/main.lua` (not at the beginning):

```lua
RegisterNetEvent('inventory:client:SetCurrentTrunk', function(vehicle)
    CurrentVehicle = vehicle
end)

RegisterNetEvent('inventory:client:SetCurrentGlovebox', function(vehicle)
    CurrentGlovebox = vehicle
end)
```

### Step 4: Database Setup (ESX Only)
Run the provided SQL file to set up the bans table:
- Located in `sql/bans.sql`

### Step 5: QB WeatherSync Integration (Optional)
If using `qb-weathersync`, update the `isAllowedToChange()` function in `qb-weathersync/server/main.lua`:

```lua
local function isAllowedToChange(src)
    if src == 0 or QBCore.Functions.HasPermission(src, "admin") or IsPlayerAceAllowed(src, 'command') or exports["snipe-menu"]:isAdmin(src) then
        return true
    end
    return false
end
```

### Step 6: Illenium Appearance & ESX Setup (Optional)
Add this event to `illenium-appearance/client/framework/esx/compatibility.lua`:

```lua
RegisterNetEvent("snipe-menu:client:openAppearance", function()
    local config = GetDefaultConfig()
    config.ped = true
    config.headBlend = true
    config.faceFeatures = true
    config.headOverlays = true
    config.components = true
    config.props = true
    config.tattoos = true
    OpenShop(config, true, "all")
end)
```

---

## Configuration & Compatibility

### Permissions Configuration
Check `config/permissions.lua` for role management:

- **God Role**: Can access all commands and configure panels for other roles (DO NOT REMOVE)
- **Admin/Mod Roles**: Can only access panels assigned by God roles
- **Custom Roles**: Add new roles as needed

Example configuration:
```lua
Config.GodRoles = {
    ["god"] = "God", 
    ["admin"] = "Admin",
    ["mod"] = "Moderator",
    -- Add more roles here as needed
}
```

### Admin Duty System
Version 3.5.0+ includes an Admin Duty feature:
- Use `/adminduty` to toggle duty status
- Admin menu is only accessible while on duty
- Configure options in `config/config_new.lua`
- Set permissions in `config/permissions.lua`
- Configure webhooks in `server/open/sv_webhooks.lua`

---

## Permissions & Roles

### Role Hierarchy
- **God**: Full access to all commands and settings
- **Admin**: Access to panels assigned by God roles
- **Mod**: Access to panels assigned by God roles
- **Custom Roles**: Can be added and customized in `Config.GodRoles`

### Permission Structure
```lua
eg. ["new_role"] = "God",      -- Full access level
eg. ["dev"] = "Admin",         -- Admin access level
```

---

## Features

### Keybinds Configuration
Before deployment, review `client/open/cl_keybinds.lua`:
- Keybinds can be modified in-game via Settings
- Navigate to: GTA 5 Settings → Keybinds → FiveM → snipe-menu
- Keybinds only work when Dev Mode is enabled (God roles only)
- Recommendation: Use mouse keys for delete laser for easier multi-key access

### Localization & UI Languages
To add a new language:

1. Create a new file in `html/locales/` (e.g., `sp.json` for Spanish)
2. Copy contents from `en.json` and translate the right-side values only
3. Do NOT change the left-side keys

Example:
```json
"Revive": "Reanimar",
```

4. Update `html/config.json` to set the language code
5. Type `refresh` in the server console before restarting

### Discord Logging
- Configure webhook in `server/open/sv_webhooks.lua`
- Logs all admin commands and their targets
- Limited language options (logged to Discord)

### Miscellaneous
- Unencrypted client/server scripts available for custom modifications
- Logic for additional paid scripts can be added upon request

---

## Customization

### Developer Options
Create custom panels and add them to the admin menu:
- All customization is done in the `custom/` folder
- See `custom/custom_config.lua` for available options
- Refer to the examples in the `custom/` folder

### Component Types
Available input types for custom panels:
- **"string-input"** - Text input field
- **"number-input"** - Numeric input field
- **"checkbox"** - Boolean checkbox
- **"regular-dropdown"** - Dropdown list: `{"Option 1", "Option 2"}`
- **"searchable-dropdown"** - Searchable dropdown: `{{id = 1, name = "Option 1"}, {id = 2, name = "Option 2"}}`

---

## Exports & Developer Options

### Dev Mode Exports
Check if a player is in Dev Mode:

**Client:**
```lua
exports["snipe-menu"]:isDevMode()
```

**Server:**
```lua
exports["snipe-menu"]:isDevMode(source)  -- source = player ID
```

### Admin Permission Exports
Check if a player has Admin permissions:

**Client:**
```lua
exports["snipe-menu"]:isAdmin()
```

**Server:**
```lua
exports["snipe-menu"]:isAdmin(source)  -- source = player ID
```

### Spectate Export
Check if a player is spectating:

```lua
exports["snipe-menu"]:isInSpectating()
```

### Admin Role Name Export
Get the admin role name for a player:

**Server:**
```lua
exports["snipe-menu"]:GetAdminRoleName(source)  -- source = player ID
```

---

## Notes
- The `custom/` folder contains unencrypted scripts for easy editing
- Most settings can be changed in `config/` files without code modifications
- Use `/adminduty` command to toggle admin duty status
- Not all paid scripts are officially supported; however, integration logic is available
