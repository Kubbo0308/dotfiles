-- Pull in the wezterm API
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

function merge_config(config, new_config)
    for k, v in pairs(new_config) do
        config[k] = v
    end
end

-- backgrounds
local background = require("config/background")
merge_config(config, background)

-- keybinds
local keybind = require("config/keybind")
if keybind.keys then config.keys = keybind.keys end
if keybind.leader then config.leader = keybind.leader end
if keybind.key_tables then config.key_tables = keybind.key_tables end
if keybind.mouse_bindings then config.mouse_bindings = keybind.mouse_bindings end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local bg_color = "#5c6d74"
    local fg_color = "#ffffff"

    if tab.is_active then
        bg_color = "#ae8b2d"
        fg_color = "#ffffff"
    end

    local title = "  " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "  "

    return {
        { Background = { Color = bg_color } },
        { Foreground = { Color = fg_color } },
        { Text = title },
    }
end)

-- colors
config.color_scheme = "Tokyo Night"

-- font
config.font = wezterm.font("Hack Nerd Font Mono", {weight="Regular", stretch="Normal", style="Normal"})
config.font_size = 16.0
config.use_ime = true

-- 右ステータスのカスタマイズ
wezterm.on("update-status", function(window, pane)
    local success, result = pcall(function()
        -- Helper functions for status components
        local function GetHostAndCwd(elems, pane)
            local cwd_uri = pane:get_current_working_dir()
            if cwd_uri then
                local cwd_str = tostring(cwd_uri)
                if cwd_str:find("file://") then
                    cwd_str = cwd_str:gsub("file://[^/]*/", "/")
                    -- ホームディレクトリを~に置換
                    local home = os.getenv("HOME")
                    if home and cwd_str:find(home, 1, true) == 1 then
                        cwd_str = "~" .. cwd_str:sub(#home + 1)
                    end
                    
                    -- Extract hostname and directory
                    local hostname = "localhost"
                    local dir = cwd_str
                    
                    -- Shorten directory path if too long
                    if #dir > 30 then
                        local parts = {}
                        for part in dir:gmatch("[^/]+") do
                            table.insert(parts, part)
                        end
                        if #parts > 2 then
                            dir = ".../" .. parts[#parts-1] .. "/" .. parts[#parts]
                        end
                    end
                    
                    table.insert(elems, {
                        icon = wezterm.nerdfonts.md_server,
                        text = hostname,
                        bg = "#75b1a9",
                        fg = "#ffffff"
                    })
                    table.insert(elems, {
                        icon = wezterm.nerdfonts.md_folder,
                        text = dir,
                        bg = "#92aac7", 
                        fg = "#ffffff"
                    })
                end
            end
        end
        
        local function GetDate(elems)
            local date = wezterm.strftime("%m/%d")
            table.insert(elems, {
                icon = wezterm.nerdfonts.md_calendar,
                text = date,
                bg = "#ffccac",
                fg = "#333333"
            })
        end
        
        local function GetTime(elems)
            local time = wezterm.strftime("%H:%M:%S")
            table.insert(elems, {
                icon = wezterm.nerdfonts.md_clock,
                text = time,
                bg = "#bcbabe",
                fg = "#333333"
            })
        end
        
        local function GetBattery(elems, window)
            local battery_info = wezterm.battery_info()
            if battery_info and #battery_info > 0 and window:get_dimensions().is_full_screen then
                for _, b in ipairs(battery_info) do
                    local charge = b.state_of_charge * 100
                    local icon = wezterm.nerdfonts.md_battery
                    if charge < 20 then
                        icon = wezterm.nerdfonts.md_battery_10
                    elseif charge < 50 then
                        icon = wezterm.nerdfonts.md_battery_40  
                    elseif charge < 80 then
                        icon = wezterm.nerdfonts.md_battery_70
                    end
                    
                    table.insert(elems, {
                        icon = icon,
                        text = string.format("%.0f%%", charge),
                        bg = "#dfe166",
                        fg = "#333333"
                    })
                end
            end
        end
        
        local function GetLeader(elems, window)
            if window:leader_is_active() then
                table.insert(elems, {
                    icon = wezterm.nerdfonts.md_crown,
                    text = "LEADER",
                    bg = "#ff6b6b",
                    fg = "#ffffff"
                })
            end
        end
        
        -- Collect status elements
        local elems = {}
        GetLeader(elems, window)
        GetHostAndCwd(elems, pane)
        GetDate(elems)
        GetTime(elems)
        GetBattery(elems, window)
        
        -- Format elements with improved styling
        local formatted = {}
        for i, elem in ipairs(elems) do
            -- Add background color
            table.insert(formatted, {Background = {Color = elem.bg}})
            table.insert(formatted, {Foreground = {Color = elem.fg}})
            
            -- Add icon and text with proper spacing
            table.insert(formatted, {Text = " " .. elem.icon .. " " .. elem.text .. " "})
            
            -- Add separator (except for last element)
            if i < #elems then
                local next_elem = elems[i + 1]
                table.insert(formatted, {Foreground = {Color = next_elem.bg}})
                table.insert(formatted, {Text = utf8.char(0xe0b2)})
            end
        end
        
        return wezterm.format(formatted)
    end)
    
    if success then
        window:set_right_status(result)
    else
        -- エラー時は簡単なステータスを表示
        local date = wezterm.strftime("%H:%M:%S")
        window:set_right_status(date)
    end
end)

-- and finally, return the configuration to wezterm
return config
