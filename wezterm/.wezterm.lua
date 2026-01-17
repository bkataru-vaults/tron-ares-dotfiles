-- =============================================================================
-- WezTerm Configuration - TRON ARES EDITION
-- =============================================================================
-- Inspired by the digital circuitry of the Grid and the crimson glow of Ares
-- Documentation: https://wezfurlong.org/wezterm/config/files.html

local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

-- Initialize config builder for better error messages
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- =============================================================================
-- TRON ARES THEME COLORS
-- =============================================================================
local tron = {
    -- Core colors
    black = '#000000',
    grid_dark = '#0a0505',
    grid_line = '#1a0808',
    circuit_dim = '#331111',
    circuit = '#4a1515',
    circuit_bright = '#661a1a',
    
    -- Ares crimson palette
    crimson_dark = '#992222',
    crimson = '#CC2222',
    crimson_medium = '#DF1F1F',
    crimson_bright = '#FF3333',
    crimson_glow = '#FF5555',
    crimson_hot = '#FF6666',
    crimson_white = '#FF8888',
    
    -- Text
    text = '#e6e6e6',
    text_bright = '#ffffff',
    text_dim = '#999999',
}

-- =============================================================================
-- STARTUP BEHAVIOR - Grid initialization
-- =============================================================================
wezterm.on('gui-startup', function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

-- =============================================================================
-- DEFAULT SHELL - NUSHELL
-- =============================================================================
config.default_prog = { 'nu' }

-- =============================================================================
-- FONT CONFIGURATION - Digital display
-- =============================================================================
config.font = wezterm.font_with_fallback({
    {
        family = 'JetBrainsMono Nerd Font',
        weight = 'Medium',
        harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },
    },
    { family = 'Symbols Nerd Font Mono', scale = 0.9 },
    'Noto Color Emoji',
})

config.font_size = 12.0
config.line_height = 1.0
config.cell_width = 1.0

-- Font rendering optimized for the Grid
config.freetype_load_target = 'Light'
config.freetype_render_target = 'HorizontalLcd'
config.font_shaper = 'Harfbuzz'

-- =============================================================================
-- COLOR SCHEME - Tron Ares (Accurate Crimson Circuitry)
-- =============================================================================
config.color_schemes = {
    ['Tron Ares'] = {
        foreground = tron.crimson_bright,
        background = tron.black,
        cursor_bg = tron.crimson_bright,
        cursor_fg = tron.black,
        cursor_border = tron.crimson_bright,
        selection_fg = tron.black,
        selection_bg = tron.crimson,
        scrollbar_thumb = tron.circuit,
        split = tron.crimson,
        
        ansi = {
            tron.black,
            tron.crimson_medium,
            tron.crimson_bright,
            tron.crimson_hot,
            tron.crimson_dark,
            tron.crimson,
            tron.crimson,
            tron.text,
        },
        brights = {
            tron.circuit_dim,
            tron.crimson_glow,
            tron.crimson_glow,
            tron.crimson_white,
            tron.crimson,
            tron.crimson_glow,
            tron.crimson,
            tron.text_bright,
        },
        
        -- Compose cursor for visual distinction
        compose_cursor = tron.crimson_hot,
        
        -- Copy mode colors
        copy_mode_active_highlight_bg = { Color = tron.crimson },
        copy_mode_active_highlight_fg = { Color = tron.black },
        copy_mode_inactive_highlight_bg = { Color = tron.circuit },
        copy_mode_inactive_highlight_fg = { Color = tron.crimson_bright },
        
        -- Quick select colors
        quick_select_label_bg = { Color = tron.crimson },
        quick_select_label_fg = { Color = tron.black },
        quick_select_match_bg = { Color = tron.circuit },
        quick_select_match_fg = { Color = tron.crimson_bright },
    }
}
config.color_scheme = 'Tron Ares'

-- =============================================================================
-- WINDOW APPEARANCE - The Grid backdrop (Pure Black)
-- =============================================================================
config.window_decorations = 'RESIZE'

-- Solid black background - no transparency
config.window_background_opacity = 1.0
config.win32_system_backdrop = 'Disable'
config.macos_window_background_blur = 0

-- Padding (circuit board margins)
config.window_padding = {
    left = 16,
    right = 16,
    top = 12,
    bottom = 8,
}

-- Initial size
config.initial_cols = 120
config.initial_rows = 35

-- =============================================================================
-- TAB BAR - Circuit tabs with Tron styling
-- =============================================================================
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.show_tab_index_in_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true

-- Fancy tab bar styling
config.window_frame = {
    font = wezterm.font({ family = 'JetBrainsMono Nerd Font', weight = 'Bold' }),
    font_size = 10.0,
    active_titlebar_bg = tron.black,
    inactive_titlebar_bg = tron.black,
    active_titlebar_fg = tron.crimson_bright,
    inactive_titlebar_fg = tron.crimson_dark,
    active_titlebar_border_bottom = tron.circuit,
    inactive_titlebar_border_bottom = tron.grid_line,
    button_fg = tron.crimson_bright,
    button_bg = tron.black,
    button_hover_fg = tron.crimson_glow,
    button_hover_bg = tron.grid_line,
    border_left_width = '0.2cell',
    border_right_width = '0.2cell',
    border_bottom_height = '0.1cell',
    border_top_height = '0.1cell',
    border_left_color = tron.circuit,
    border_right_color = tron.circuit,
    border_bottom_color = tron.circuit,
    border_top_color = tron.circuit,
}

-- Tab colors
config.colors = {
    tab_bar = {
        background = tron.black,
        active_tab = {
            bg_color = tron.circuit,
            fg_color = tron.crimson_hot,
            intensity = 'Bold',
            underline = 'Single',
            italic = false,
        },
        inactive_tab = {
            bg_color = tron.grid_dark,
            fg_color = tron.crimson_dark,
        },
        inactive_tab_hover = {
            bg_color = tron.grid_line,
            fg_color = tron.crimson_bright,
            italic = false,
        },
        new_tab = {
            bg_color = tron.black,
            fg_color = tron.crimson_dark,
        },
        new_tab_hover = {
            bg_color = tron.grid_line,
            fg_color = tron.crimson_bright,
        },
    },
}

-- Custom tab title formatting (Tron style)
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local edge_background = tron.black
    local background = tron.grid_dark
    local foreground = tron.crimson_dark
    local edge_foreground = tron.circuit
    
    if tab.is_active then
        background = tron.circuit
        foreground = tron.crimson_hot
        edge_foreground = tron.crimson
    elseif hover then
        background = tron.grid_line
        foreground = tron.crimson_bright
        edge_foreground = tron.crimson_dark
    end

    local title = tab.active_pane.title
    -- Truncate title if too long
    if #title > max_width - 4 then
        title = wezterm.truncate_right(title, max_width - 5) .. '...'
    end
    
    -- Tab index with circuit-style brackets
    local index = tab.tab_index + 1
    
    return {
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = '' },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
        { Text = ' ' .. index .. ':' .. title .. ' ' },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = '' },
    }
end)

-- =============================================================================
-- CURSOR - Pulsing energy cursor
-- =============================================================================
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 530
config.cursor_blink_ease_in = 'EaseIn'
config.cursor_blink_ease_out = 'EaseOut'
config.force_reverse_video_cursor = false

-- Cursor thickness for better visibility
config.cursor_thickness = '0.1cell'

-- =============================================================================
-- SCROLLBACK & PERFORMANCE - Optimized for the Grid
-- =============================================================================
config.scrollback_lines = 5000
config.enable_scroll_bar = false

-- Use WebGpu for better animations when available, fall back to OpenGL
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'

-- Smooth animations at 60fps
config.animation_fps = 60
config.max_fps = 120

-- Reduce latency
config.enable_wayland = false

-- =============================================================================
-- PANE MANAGEMENT - Grid sectors
-- =============================================================================
config.inactive_pane_hsb = {
    saturation = 0.7,
    brightness = 0.5,
}

-- =============================================================================
-- VISUAL BELL - Circuit pulse effect
-- =============================================================================
config.audible_bell = 'Disabled'
config.visual_bell = {
    fade_in_function = 'EaseIn',
    fade_in_duration_ms = 80,
    fade_out_function = 'EaseOut',
    fade_out_duration_ms = 150,
    target = 'BackgroundColor',
}

-- =============================================================================
-- HYPERLINKS - Data links
-- =============================================================================
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Windows file paths
table.insert(config.hyperlink_rules, {
    regex = [=[["]?([\w\d]{1}:[\\/][\w\d_\-\\/.]+)["]?]=],
    format = 'file:///$1',
})

-- =============================================================================
-- KEY BINDINGS
-- =============================================================================
config.disable_default_key_bindings = false
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
    -- Pane management (leader key based, like tmux)
    { key = '-', mods = 'LEADER', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
    { key = '\\', mods = 'LEADER', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
    { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane({ confirm = true }) },

    -- Pane navigation (Alt + arrow keys)
    { key = 'LeftArrow', mods = 'ALT', action = act.ActivatePaneDirection('Left') },
    { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection('Right') },
    { key = 'UpArrow', mods = 'ALT', action = act.ActivatePaneDirection('Up') },
    { key = 'DownArrow', mods = 'ALT', action = act.ActivatePaneDirection('Down') },

    -- Pane resizing (Alt + Shift + arrow keys)
    { key = 'LeftArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Left', 5 }) },
    { key = 'RightArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Right', 5 }) },
    { key = 'UpArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Up', 3 }) },
    { key = 'DownArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Down', 3 }) },

    -- Tab management
    { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab('CurrentPaneDomain') },
    { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab({ confirm = true }) },
    { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
    { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

    -- Quick tab switch (Alt + number)
    { key = '1', mods = 'ALT', action = act.ActivateTab(0) },
    { key = '2', mods = 'ALT', action = act.ActivateTab(1) },
    { key = '3', mods = 'ALT', action = act.ActivateTab(2) },
    { key = '4', mods = 'ALT', action = act.ActivateTab(3) },
    { key = '5', mods = 'ALT', action = act.ActivateTab(4) },
    { key = '6', mods = 'ALT', action = act.ActivateTab(5) },
    { key = '7', mods = 'ALT', action = act.ActivateTab(6) },
    { key = '8', mods = 'ALT', action = act.ActivateTab(7) },
    { key = '9', mods = 'ALT', action = act.ActivateTab(-1) },

    -- Font size
    { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
    { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
    { key = '0', mods = 'CTRL', action = act.ResetFontSize },

    -- Copy/Paste
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },

    -- Search
    { key = 'f', mods = 'CTRL|SHIFT', action = act.Search('CurrentSelectionOrEmptyString') },

    -- Command palette
    { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },

    -- Quick select (URLs, hashes, etc.)
    { key = 'Space', mods = 'LEADER', action = act.QuickSelect },

    -- Debug overlay
    { key = 'l', mods = 'CTRL|SHIFT', action = act.ShowDebugOverlay },

    -- Reload configuration
    { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
    
    -- Scroll
    { key = 'PageUp', mods = 'SHIFT', action = act.ScrollByPage(-1) },
    { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(1) },
    { key = 'Home', mods = 'SHIFT', action = act.ScrollToTop },
    { key = 'End', mods = 'SHIFT', action = act.ScrollToBottom },
}

-- =============================================================================
-- MOUSE BINDINGS - Fixed for Nushell clipboard integration
-- =============================================================================
config.mouse_bindings = {
    -- Right click: if there's a selection, copy it; otherwise paste
    {
        event = { Down = { streak = 1, button = 'Right' } },
        mods = 'NONE',
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ''
            if has_selection then
                window:perform_action(act.CopyTo('ClipboardAndPrimarySelection'), pane)
                window:perform_action(act.ClearSelection, pane)
            else
                window:perform_action(act.PasteFrom('Clipboard'), pane)
            end
        end),
    },
    -- Triple-click selects entire line
    {
        event = { Down = { streak = 3, button = 'Left' } },
        mods = 'NONE',
        action = act.SelectTextAtMouseCursor('Line'),
    },
    -- Ctrl+Click to open hyperlinks
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = act.OpenLinkAtMouseCursor,
    },
    -- Middle click paste (classic Unix behavior)
    {
        event = { Down = { streak = 1, button = 'Middle' } },
        mods = 'NONE',
        action = act.PasteFrom('PrimarySelection'),
    },
}

-- =============================================================================
-- QUICK SELECT PATTERNS
-- =============================================================================
config.quick_select_patterns = {
    -- Git commit hashes
    '[0-9a-f]{7,40}',
    -- IPv4
    '\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}',
    -- UUIDs
    '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
    -- File paths (Windows)
    '[A-Z]:\\\\[\\w\\\\.-]+',
}

-- =============================================================================
-- MISC
-- =============================================================================
config.automatically_reload_config = true
config.check_for_updates = false
config.show_update_window = false
config.adjust_window_size_when_changing_font_size = false
config.warn_about_missing_glyphs = false
config.use_dead_keys = false

-- Unicode handling
config.unicode_version = 14
config.allow_square_glyphs_to_overflow_width = 'WhenFollowedBySpace'

-- Windows-specific settings
config.prefer_egl = true
config.allow_win32_input_mode = true

-- =============================================================================
-- STATUS BAR - Tron-style data readout with animated elements
-- =============================================================================

-- Track time for animations
local function get_pulse_intensity()
    local time = os.time()
    -- Create a subtle pulsing effect (0.7 to 1.0 range)
    local pulse = 0.85 + 0.15 * math.sin(time * 2)
    return pulse
end

-- Animated circuit pattern characters
local circuit_chars = { '◢', '◣', '◤', '◥', '▶', '◀', '▲', '▼' }
local data_flow_chars = { '⟩', '»', '›', '⊳', '▸' }

wezterm.on('update-status', function(window, pane)
    local date = wezterm.strftime('%H:%M:%S')
    local short_date = wezterm.strftime('%H:%M')
    local cwd = pane:get_current_working_dir()
    local cwd_str = cwd and cwd.file_path or ''
    
    -- Shorten home directory
    cwd_str = cwd_str:gsub('^C:/Users/user', '~')
    cwd_str = cwd_str:gsub('^C:\\Users\\user', '~')
    cwd_str = cwd_str:gsub('\\', '/')
    
    -- Truncate long paths
    if #cwd_str > 30 then
        cwd_str = '...' .. cwd_str:sub(-27)
    end
    
    local workspace = window:active_workspace()
    
    -- Get current time for animation cycling
    local time_val = os.time()
    local anim_idx = (time_val % #data_flow_chars) + 1
    local flow_char = data_flow_chars[anim_idx]
    
    -- Determine if leader key is active
    local leader = ''
    if window:leader_is_active() then
        leader = ' LEADER '
    end
    
    -- Build the status bar with Tron circuit aesthetics
    local left_status = {}
    
    -- Leader indicator (when active)
    if #leader > 0 then
        table.insert(left_status, { Background = { Color = tron.crimson } })
        table.insert(left_status, { Foreground = { Color = tron.black } })
        table.insert(left_status, { Attribute = { Intensity = 'Bold' } })
        table.insert(left_status, { Text = leader })
        table.insert(left_status, { Background = { Color = tron.black } })
        table.insert(left_status, { Foreground = { Color = tron.crimson } })
        table.insert(left_status, { Text = '' })
    end
    
    window:set_left_status(wezterm.format(left_status))
    
    -- Right status with animated data flow
    window:set_right_status(wezterm.format({
        -- Workspace indicator
        { Foreground = { Color = tron.circuit } },
        { Text = '' },
        { Background = { Color = tron.circuit } },
        { Foreground = { Color = tron.crimson_bright } },
        { Text = '  ' .. workspace .. ' ' },
        
        -- Animated separator
        { Background = { Color = tron.black } },
        { Foreground = { Color = tron.crimson_dark } },
        { Text = ' ' .. flow_char .. ' ' },
        
        -- Directory indicator
        { Foreground = { Color = tron.circuit } },
        { Text = '' },
        { Background = { Color = tron.circuit } },
        { Foreground = { Color = tron.crimson_bright } },
        { Text = '  ' .. cwd_str .. ' ' },
        
        -- Animated separator
        { Background = { Color = tron.black } },
        { Foreground = { Color = tron.crimson_dark } },
        { Text = ' ' .. flow_char .. ' ' },
        
        -- Time indicator
        { Foreground = { Color = tron.circuit } },
        { Text = '' },
        { Background = { Color = tron.circuit } },
        { Foreground = { Color = tron.text_bright } },
        { Text = '  ' .. date .. ' ' },
        
        -- End cap
        { Background = { Color = tron.black } },
        { Foreground = { Color = tron.circuit } },
        { Text = '' },
    }))
end)

-- =============================================================================
-- LAUNCH MENU (Grid program selection)
-- =============================================================================
config.launch_menu = {
    { label = '  Nushell', args = { 'nu' } },
    { label = '  PowerShell 7', args = { 'pwsh' } },
    { label = '  PowerShell Preview', args = { 'pwsh-preview' } },
    { label = '  Command Prompt', args = { 'cmd' } },
    { label = '  Git Bash', args = { 'C:/Program Files/Git/bin/bash.exe', '-l' } },
    { label = '  System Monitor', args = { 'btm' } },
}

-- =============================================================================
-- NOTIFICATION HANDLING
-- =============================================================================
wezterm.on('bell', function(window, pane)
    -- Flash effect on bell
    window:set_right_status(wezterm.format({
        { Foreground = { Color = tron.crimson_glow } },
        { Attribute = { Intensity = 'Bold' } },
        { Text = '  SIGNAL  ' },
    }))
end)

-- =============================================================================
-- WINDOW RESIZE EVENT - Adaptive UI
-- =============================================================================
wezterm.on('window-resized', function(window, pane)
    -- Could add responsive UI changes here
end)

return config
