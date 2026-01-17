# =============================================================================
# Nushell Configuration
# =============================================================================
# Documentation: https://www.nushell.sh/book/configuration.html

# =============================================================================
# SHELL SETTINGS
# =============================================================================

$env.config = {
    # Display settings
    show_banner: false
    
    # LS colors (use eza instead, but fallback)
    ls: {
        use_ls_colors: true
        clickable_links: true
    }
    
    # Table display
    table: {
        mode: rounded
        index_mode: auto
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: '...'
        }
        header_on_separator: false
    }
    
    # Error display
    error_style: fancy
    
    # Datetime format
    datetime_format: {
        normal: '%Y-%m-%d %H:%M:%S'
        table: '%Y-%m-%d %H:%M'
    }
    
    # History settings
    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: sqlite
        isolation: false
    }
    
    # Completions
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: prefix
        sort: smart
        external: {
            enable: true
            max_results: 100
            completer: null
        }
        use_ls_colors: true
    }
    
    # History hints - show inline suggestions as you type (like PSReadLine PredictionSource)
    highlight_resolved_externals: true
    
    # Cursor shape (matches WezTerm)
    cursor_shape: {
        emacs: line
        vi_insert: line
        vi_normal: block
    }
    
    # Color config
    color_config: (get_tron_ares_colors)
    
    # Footer mode
    footer_mode: 25
    
    # Float precision
    float_precision: 2
    
    # Buffer editor
    buffer_editor: code
    
    # Use ANSI coloring
    use_ansi_coloring: true
    
    # Bracketed paste
    bracketed_paste: true
    
    # Edit mode (emacs or vi)
    edit_mode: emacs
    
    # Shell integration (for WezTerm)
    # Note: osc133 and osc633 disabled to fix scrolling/rendering issues
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: false
        osc633: false
        reset_application_mode: true
    }
    
    # Rendering
    render_right_prompt_on_last_line: false
    
    # Hooks
    hooks: {
        pre_prompt: [{ || null }]
        pre_execution: [{ || null }]
        env_change: {
            PWD: [{ |before, after|
                # Auto-run fnm use when entering directory with .nvmrc or .node-version
                if (($after | path join '.nvmrc' | path exists) or ($after | path join '.node-version' | path exists)) {
                    fnm use --silent-if-unchanged
                }
            }]
        }
        display_output: 'if (term size).columns >= 100 { table -e } else { table }'
        command_not_found: { || null }
    }
    
    # Menus
    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: '| '
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: { attr: r }
                description_text: yellow
                match_text: { attr: u }
                selected_match_text: { attr: ur }
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: '? '
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: '? '
            type: {
                layout: description
                columns: 4
                col_width: 20
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
    ]
    
    # Keybindings
    keybindings: [
        # Tab completion
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        # Shift+Tab for previous completion
        {
            name: completion_previous
            modifier: shift
            keycode: backtab
            mode: [emacs vi_insert]
            event: { send: menuprevious }
        }
        # Ctrl+R for history search
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs vi_insert]
            event: { send: menu name: history_menu }
        }
        # Ctrl+X for external editor
        {
            name: open_editor
            modifier: control
            keycode: char_x
            mode: [emacs vi_insert]
            event: { send: openeditor }
        }
        # Alt+Enter for multiline
        {
            name: newline
            modifier: alt
            keycode: enter
            mode: [emacs vi_insert]
            event: { edit: insertnewline }
        }
        # Ctrl+D to exit (if buffer empty)
        {
            name: exit_shell
            modifier: control
            keycode: char_d
            mode: [emacs vi_insert]
            event: { send: ctrld }
        }
        # Up/Down for history search with current input (PSReadLine-like behavior)
        {
            name: history_search_up
            modifier: none
            keycode: up
            mode: [emacs vi_insert]
            event: {
                until: [
                    { send: menuup }
                    { send: up }
                ]
            }
        }
        {
            name: history_search_down
            modifier: none
            keycode: down
            mode: [emacs vi_insert]
            event: {
                until: [
                    { send: menudown }
                    { send: down }
                ]
            }
        }
        # Ctrl+P/Ctrl+N for previous/next history (alternative)
        {
            name: history_prev
            modifier: control
            keycode: char_p
            mode: [emacs vi_insert]
            event: { send: up }
        }
        {
            name: history_next
            modifier: control
            keycode: char_n
            mode: [emacs vi_insert]
            event: { send: down }
        }
        # Ctrl+L to clear screen
        {
            name: clear_screen
            modifier: control
            keycode: char_l
            mode: [emacs vi_insert]
            event: { send: clearscreen }
        }
        # Ctrl+A to move to start
        {
            name: move_to_start
            modifier: control
            keycode: char_a
            mode: [emacs vi_insert]
            event: { edit: movetolinestart }
        }
        # Ctrl+E to move to end
        {
            name: move_to_end
            modifier: control
            keycode: char_e
            mode: [emacs vi_insert]
            event: { edit: movetolineend }
        }
        # Ctrl+W to delete word backward
        {
            name: delete_word_backward
            modifier: control
            keycode: char_w
            mode: [emacs vi_insert]
            event: { edit: backspaceword }
        }
        # Ctrl+U to clear line before cursor
        {
            name: clear_to_start
            modifier: control
            keycode: char_u
            mode: [emacs vi_insert]
            event: { edit: cutfromlinestart }
        }
        # Ctrl+K to clear line after cursor
        {
            name: clear_to_end
            modifier: control
            keycode: char_k
            mode: [emacs vi_insert]
            event: { edit: cuttolineend }
        }
        # Alt+Left/Right for word navigation
        {
            name: word_left
            modifier: alt
            keycode: left
            mode: [emacs vi_insert]
            event: { edit: movewordleft }
        }
        {
            name: word_right
            modifier: alt
            keycode: right
            mode: [emacs vi_insert]
            event: { edit: movewordright }
        }
        # Ctrl+Right to accept history hint word by word (PSReadLine-like)
        {
            name: accept_hint_word
            modifier: control
            keycode: right
            mode: [emacs vi_insert]
            event: { send: historyhintwordcomplete }
        }
        # Right arrow to accept full history hint when at end of line
        {
            name: accept_hint_or_right
            modifier: none
            keycode: right
            mode: [emacs vi_insert]
            event: {
                until: [
                    { send: historyhintcomplete }
                    { edit: moveright }
                ]
            }
        }
        # Ctrl+F for fzf file search (like PowerShell PSFzf)
        {
            name: fzf_file
            modifier: control
            keycode: char_f
            mode: [emacs vi_insert]
            event: [
                { send: executehostcommand cmd: "commandline edit --insert (fd --type f --hidden --exclude .git | fzf --height 40% --reverse | str trim)" }
            ]
        }
    ]
}

# =============================================================================
# COLOR THEME - Tron Ares V3 (Gentle Orange + Soft Red - Matches WezTerm)
# =============================================================================

def get_tron_ares_colors [] {
    {
        separator: { fg: '#996655' }
        leading_trailing_space_bg: { attr: n }
        header: { fg: '#e8a862' attr: b }
        empty: { fg: '#4a3020' }
        bool: { fg: '#f0c080' }
        int: { fg: '#e8a862' }
        filesize: { fg: '#d99055' }
        duration: { fg: '#cc8866' }
        date: { fg: '#f0b878' }
        range: { fg: '#e8a862' }
        float: { fg: '#e8a862' }
        string: { fg: '#e6e6e6' }
        nothing: { fg: '#4a3020' }
        binary: { fg: '#cc6655' }
        cellpath: { fg: '#d99055' }
        row_index: { fg: '#996655' }
        record: { fg: '#ffffff' }
        list: { fg: '#ffffff' }
        block: { fg: '#e8a862' }
        hints: { fg: '#996655' }
        search_result: { fg: '#000000' bg: '#e8a862' }
        shape_and: { fg: '#cc8866' attr: b }
        shape_binary: { fg: '#cc6655' attr: b }
        shape_block: { fg: '#e8a862' attr: b }
        shape_bool: { fg: '#f0c080' }
        shape_closure: { fg: '#dd9977' attr: b }
        shape_custom: { fg: '#dd9977' }
        shape_datetime: { fg: '#f0b878' attr: b }
        shape_directory: { fg: '#e8a862' }
        shape_external: { fg: '#d99055' }
        shape_externalarg: { fg: '#e6e6e6' }
        shape_external_resolved: { fg: '#d99055' attr: b }
        shape_filepath: { fg: '#e8a862' }
        shape_flag: { fg: '#cc8866' attr: b }
        shape_float: { fg: '#e8a862' attr: b }
        shape_garbage: { fg: '#cc6655' attr: bu }
        shape_glob_interpolation: { fg: '#f0b878' attr: b }
        shape_globpattern: { fg: '#f0b878' attr: b }
        shape_int: { fg: '#e8a862' attr: b }
        shape_internalcall: { fg: '#d99055' attr: b }
        shape_keyword: { fg: '#cc7a4a' attr: b }
        shape_list: { fg: '#f0b878' attr: b }
        shape_literal: { fg: '#e8a862' }
        shape_match_pattern: { fg: '#dd9977' }
        shape_matching_brackets: { attr: u }
        shape_nothing: { fg: '#996655' }
        shape_operator: { fg: '#f0c080' }
        shape_or: { fg: '#cc8866' attr: b }
        shape_pipe: { fg: '#cc7a4a' attr: b }
        shape_range: { fg: '#f0c080' attr: b }
        shape_raw_string: { fg: '#e6e6e6' }
        shape_record: { fg: '#f0b878' attr: b }
        shape_redirection: { fg: '#cc6655' attr: b }
        shape_signature: { fg: '#dd9977' attr: b }
        shape_string: { fg: '#e6e6e6' }
        shape_string_interpolation: { fg: '#f0b878' attr: b }
        shape_table: { fg: '#e8a862' attr: b }
        shape_vardecl: { fg: '#d99055' attr: u }
        shape_variable: { fg: '#dd9977' }
    }
}

# =============================================================================
# ALIASES - Modern CLI Tool Replacements
# =============================================================================

# eza (modern ls replacement with icons)
alias ls = eza --icons --group-directories-first
alias ll = eza -la --icons --group-directories-first --git
alias la = eza -a --icons --group-directories-first
alias lt = eza --tree --icons --group-directories-first --level=2
alias lta = eza --tree --icons --group-directories-first -a --level=2
alias l = eza -l --icons --group-directories-first

# bat (better cat)
alias cat = bat --paging=never
alias catp = bat --plain --paging=never

# fd (better find)
alias find = fd

# ripgrep (better grep)
alias grep = rg

# dust (better du)
alias du = dust

# bottom (better top/htop)
alias top = btm
alias htop = btm

# Quick navigation
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..
alias ..... = cd ../../../..

# Git shortcuts
alias g = git
alias gs = git status
alias ga = git add
alias gc = git commit
alias gp = git push
alias gl = git pull
alias gd = git diff
alias gco = git checkout
alias gb = git branch
alias glog = git log --oneline --graph --decorate -15

# Misc
alias c = clear
alias q = exit
alias e = exit
alias cls = clear

# Reload config function (can't use alias with source keyword)
def reload [] {
    exec nu
}

# Show PATH entries
def path [] {
    $env.Path | split row ';'
}

# =============================================================================
# CUSTOM FUNCTIONS
# =============================================================================

# System information
def sysinfo [] {
    print "=== System Information ==="
    print $"OS: (sys host | get name) (sys host | get os_version)"
    print $"Hostname: (sys host | get hostname)"
    print $"Uptime: (sys host | get uptime)"
    print ""
    print "=== CPU ==="
    let cpu = (sys cpu | first)
    print $"CPU: ($cpu.brand)"
    print $"Cores: ($cpu.core_count)"
    print $"Usage: ($cpu.cpu_usage | math round --precision 1)%"
    print ""
    print "=== Memory ==="
    let mem = (sys mem)
    let used_gb = ($mem.used / 1GB | math round --precision 2)
    let total_gb = ($mem.total / 1GB | math round --precision 2)
    let percent = (($mem.used / $mem.total) * 100 | math round --precision 1)
    print $"Memory: ($used_gb)GB / ($total_gb)GB \(($percent)%\)"
    print ""
    print "=== Disks ==="
    sys disks | select device mount total used free | table
}

# Quick file preview with bat
def peek [file: path] {
    bat --style=numbers --color=always $file | less -R
}

# Create directory and cd into it
def --env mkcd [dir: path] {
    mkdir $dir
    cd $dir
}

# Find files by name pattern
def ff [pattern: string] {
    fd $pattern --type f
}

# Find directories by name pattern
def fdir [pattern: string] {
    fd $pattern --type d
}

# Search file contents
def fgrep [pattern: string, --files (-f)] {
    if $files {
        rg $pattern --files-with-matches
    } else {
        rg $pattern
    }
}

# Get current weather (requires curl)
def weather [city?: string] {
    let location = if ($city | is-empty) { "" } else { $city }
    curl -s $"wttr.in/($location)?format=3"
}

# Quick HTTP server
def serve [port?: int] {
    let p = if ($port | is-empty) { 8000 } else { $port }
    print $"Serving current directory on http://localhost:($p)"
    python -m http.server $p
}

# JSON pretty print
def jpp [] {
    $in | from json | to json --indent 2
}

# Extract various archive types
def extract [file: path] {
    let ext = ($file | path parse | get extension)
    match $ext {
        "zip" => { unzip $file }
        "tar" => { tar -xvf $file }
        "gz" => { tar -xzvf $file }
        "tgz" => { tar -xzvf $file }
        "bz2" => { tar -xjvf $file }
        "xz" => { tar -xJvf $file }
        "7z" => { 7z x $file }
        "rar" => { unrar x $file }
        _ => { print $"Unknown archive type: ($ext)" }
    }
}

# Get process by name
def psg [name: string] {
    ps | where name =~ $name
}

# Kill process by name
def killp [name: string] {
    let procs = (ps | where name =~ $name)
    if ($procs | length) == 0 {
        print $"No processes found matching: ($name)"
    } else {
        $procs | each { |p| 
            print $"Killing: ($p.name) \(PID: ($p.pid)\)"
            kill $p.pid
        }
    }
}

# Quick notes
def note [action: string, ...args: string] {
    let notes_file = ($env.USERPROFILE | path join 'notes.txt')
    match $action {
        "add" => { 
            let content = ($args | str join ' ')
            let timestamp = (date now | format date '%Y-%m-%d %H:%M')
            $"[($timestamp)] ($content)\n" | save --append $notes_file
            print "Note added."
        }
        "list" => {
            if ($notes_file | path exists) {
                cat $notes_file
            } else {
                print "No notes yet."
            }
        }
        "clear" => {
            if ($notes_file | path exists) {
                rm $notes_file
                print "Notes cleared."
            }
        }
        _ => { print "Usage: note [add|list|clear] [text...]" }
    }
}

# =============================================================================
# INTEGRATIONS
# =============================================================================

# Initialize zoxide (smart cd)
source ~/.cache/zoxide.nu

# Initialize carapace completions
source ~/.cache/carapace.nu

# Initialize FNM (Node.js version manager)
if (which fnm | length) > 0 {
    # FNM uses hook for auto-switching based on .nvmrc or .node-version
    # Already configured in env_change hook above
}

# =============================================================================
# STARTUP MESSAGE
# =============================================================================

def startup_info [] {
    let nu_version = (version | get version)
    let shell = 'Nushell'
    print $"(ansi blue_bold)($shell)(ansi reset) (ansi cyan)v($nu_version)(ansi reset) | Type (ansi yellow_bold)help(ansi reset) for commands"
}

# Show startup info (disabled for faster startup - uncomment if desired)
# startup_info
