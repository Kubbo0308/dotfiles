local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}

-- キーバインド設定
M.keys = {
    -- タブ操作
    { key = 't', mods = 'CMD', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'w', mods = 'CMD', action = act.CloseCurrentTab { confirm = true } },
    { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
    { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
    
    -- ペイン操作
    { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'w', mods = 'CMD|SHIFT', action = act.CloseCurrentPane { confirm = true } },
    { key = 'w', mods = 'CMD|ALT', action = act.CloseCurrentPane { confirm = false } },
    
    -- ペイン間移動
    { key = 'h', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Left' },
    { key = 'l', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Right' },
    { key = 'k', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Up' },
    { key = 'j', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Down' },
    
    -- ペインリサイズ
    { key = 'H', mods = 'CMD|ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
    { key = 'L', mods = 'CMD|ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
    { key = 'K', mods = 'CMD|ALT|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
    { key = 'J', mods = 'CMD|ALT|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
    
    -- コピー・ペースト
    { key = 'c', mods = 'CMD', action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = 'CMD', action = act.PasteFrom 'Clipboard' },
    
    -- 検索
    { key = 'f', mods = 'CMD', action = act.Search 'CurrentSelectionOrEmptyString' },
    
    -- フォントサイズ調整
    { key = '=', mods = 'CMD', action = act.IncreaseFontSize },
    { key = '-', mods = 'CMD', action = act.DecreaseFontSize },
    { key = '0', mods = 'CMD', action = act.ResetFontSize },
    
    -- フルスクリーン
    { key = 'Return', mods = 'CMD|SHIFT', action = act.ToggleFullScreen },
    
    -- リーダーキー設定（Ctrl+a）
    { key = 'a', mods = 'CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },
    
    -- ワークスペース操作
    { key = 's', mods = 'CMD|SHIFT', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
}

-- リーダーキー（tmuxライクな操作）
M.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- リーダーキー後のキーバインド
M.leader_keys = {
    -- タブ作成・切り替え
    { key = 'c', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'n', action = act.ActivateTabRelative(1) },
    { key = 'p', action = act.ActivateTabRelative(-1) },
    
    -- ペイン分割
    { key = '%', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '"', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    
    -- ペイン間移動
    { key = 'h', action = act.ActivatePaneDirection 'Left' },
    { key = 'l', action = act.ActivatePaneDirection 'Right' },
    { key = 'k', action = act.ActivatePaneDirection 'Up' },
    { key = 'j', action = act.ActivatePaneDirection 'Down' },
    
    -- ペインリサイズモード
    { key = 'r', action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false } },
    
    -- ペインクローズ
    { key = 'x', action = act.CloseCurrentPane { confirm = true } },
    
    -- デタッチ（最小化）
    { key = 'd', action = act.Hide },
}

-- リサイズモード用キーテーブル
M.key_tables = {
    resize_pane = {
        { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
        { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
        { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
        { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
        { key = 'H', action = act.AdjustPaneSize { 'Left', 5 } },
        { key = 'L', action = act.AdjustPaneSize { 'Right', 5 } },
        { key = 'K', action = act.AdjustPaneSize { 'Up', 5 } },
        { key = 'J', action = act.AdjustPaneSize { 'Down', 5 } },
        { key = 'Escape', action = 'PopKeyTable' },
        { key = 'Enter', action = 'PopKeyTable' },
    },
}

-- マウス操作設定
M.mouse_bindings = {
    -- 右クリックでペースト
    {
        event = { Down = { streak = 1, button = 'Right' } },
        mods = 'NONE',
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ''
            if has_selection then
                window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
                window:perform_action(act.ClearSelection, pane)
            else
                window:perform_action(act({ PasteFrom = 'Clipboard' }), pane)
            end
        end),
    },
}

return M