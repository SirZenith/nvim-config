---@meta

---@class UserConfig
---@field general UserConfigGeneral
---@field keybinding UserConfigKeybinding
---@field env UserConfigEnv
---@field theme UserConfigTheme
---@field lsp UserConfigLsp
---@field plugin UserConfigPlugin
---@field platform UserConfigPlatform
---@field option UserConfigOption

---@class UserConfigGeneral : ConfigEntry
---@field filetype UserConfigGeneralFiletype
---@field im_select UserConfigGeneralImSelect
---@field locale string

---@class UserConfigKeybinding : ConfigEntry
---@field global_search UserConfigKeybindingGlobalSearch
---@field cursor_file UserConfigKeybindingCursorFile

---@class UserConfigEnv : ConfigEntry
---@field NVIM_HOME string
---@field CONFIG_HOME string
---@field PROXY_URL string

---@class UserConfigTheme : ConfigEntry
---@field colorscheme string
---@field lualine_theme string
---@field highlight UserConfigThemeHighlight

---@class UserConfigLsp : ConfigEntry
---@field capabilities_settings UserConfigLspCapabilitiesSettings
---@field log_update_method string
---@field format_args UserConfigLspFormatArgs
---@field log_scroll_method string
---@field on_attach_callbacks UserConfigLspOnAttachCallbacks

---@class UserConfigPlugin : ConfigEntry
---@field nvim_cursorline UserConfigPluginNvimCursorline
---@field nvim_treesitter UserConfigPluginNvimTreesitter
---@field lualine UserConfigPluginLualine
---@field nvim_lspconfig UserConfigPluginNvimLspconfig
---@field nvim_autopairs UserConfigPluginNvimAutopairs
---@field comment_nvim UserConfigPluginCommentNvim
---@field telescope_nvim UserConfigPluginTelescopeNvim
---@field nvim_ufo UserConfigPluginNvimUfo
---@field lsp_status UserConfigPluginLspStatus
---@field null_ls UserConfigPluginNullLs
---@field luasnip UserConfigPluginLuasnip
---@field nvim_tree UserConfigPluginNvimTree
---@field gitsigns UserConfigPluginGitsigns

---@class UserConfigPlatform : ConfigEntry
---@field windows UserConfigPlatformWindows

---@class UserConfigOption : ConfigEntry
---@field go UserConfigOptionGo
---@field o UserConfigOptionO
---@field g UserConfigOptionG

---@class UserConfigGeneralFiletype : ConfigEntry
---@field mapping UserConfigGeneralFiletypeMapping
---@field no_soft_tab UserConfigGeneralFiletypeNoSoftTab

---@class UserConfigGeneralImSelect : ConfigEntry
---@field off string
---@field check string
---@field on string
---@field isoff function

---@class UserConfigKeybindingGlobalSearch : ConfigEntry
---@field search_paths UserConfigKeybindingGlobalSearchSearchPaths
---@field make_cmd function
---@field cmd_template_map UserConfigKeybindingGlobalSearchCmdTemplateMap

---@class UserConfigKeybindingCursorFile : ConfigEntry
---@field jump_pattern UserConfigKeybindingCursorFileJumpPattern

---@class UserConfigThemeHighlight : ConfigEntry
---@field TabStatusSignActive UserConfigThemeHighlightTabStatusSignActive
---@field CursorLine UserConfigThemeHighlightCursorLine
---@field Visual UserConfigThemeHighlightVisual
---@field DiffChange UserConfigThemeHighlightDiffChange
---@field DiffCommon UserConfigThemeHighlightDiffCommon
---@field DiffDelete UserConfigThemeHighlightDiffDelete
---@field TabStatusSign UserConfigThemeHighlightTabStatusSign
---@field DiffInsert UserConfigThemeHighlightDiffInsert
---@field LspLogTrace UserConfigThemeHighlightLspLogTrace
---@field Folded UserConfigThemeHighlightFolded
---@field TabSignActive UserConfigThemeHighlightTabSignActive
---@field TabBar UserConfigThemeHighlightTabBar
---@field TabIcon UserConfigThemeHighlightTabIcon
---@field TabActive UserConfigThemeHighlightTabActive
---@field LspLogDebug UserConfigThemeHighlightLspLogDebug
---@field TabInactive UserConfigThemeHighlightTabInactive
---@field LspLogInfo UserConfigThemeHighlightLspLogInfo
---@field TabSign UserConfigThemeHighlightTabSign
---@field LspLogWarn UserConfigThemeHighlightLspLogWarn
---@field LspLogError UserConfigThemeHighlightLspLogError
---@field TabStatus UserConfigThemeHighlightTabStatus
---@field PanelpalSelect UserConfigThemeHighlightPanelpalSelect
---@field PanelpalUnselect UserConfigThemeHighlightPanelpalUnselect

-- underlaying: table[]
---@class UserConfigLspCapabilitiesSettings : ConfigEntry

---@class UserConfigLspFormatArgs : ConfigEntry
---@field async boolean

-- underlaying: function[]
---@class UserConfigLspOnAttachCallbacks : ConfigEntry

---@class UserConfigPluginNvimCursorline : ConfigEntry
---@field cursorword UserConfigPluginNvimCursorlineCursorword
---@field disable_in_buftype UserConfigPluginNvimCursorlineDisableInBuftype
---@field cursorline UserConfigPluginNvimCursorlineCursorline
---@field disable_in_filetype UserConfigPluginNvimCursorlineDisableInFiletype

---@class UserConfigPluginNvimTreesitter : ConfigEntry
---@field install UserConfigPluginNvimTreesitterInstall
---@field configs UserConfigPluginNvimTreesitterConfigs
---@field parsers UserConfigPluginNvimTreesitterParsers

---@class UserConfigPluginLualine : ConfigEntry
---@field inactive_sections UserConfigPluginLualineInactiveSections
---@field options UserConfigPluginLualineOptions
---@field extensions UserConfigPluginLualineExtensions
---@field winbar UserConfigPluginLualineWinbar
---@field tabline UserConfigPluginLualineTabline
---@field sections UserConfigPluginLualineSections
---@field inactive_winbar UserConfigPluginLualineInactiveWinbar

---@class UserConfigPluginNvimLspconfig : ConfigEntry
---@field config UserConfigPluginNvimLspconfigConfig
---@field lsp_servers UserConfigPluginNvimLspconfigLspServers

---@class UserConfigPluginNvimAutopairs : ConfigEntry
---@field enable_check_bracket_line boolean

---@class UserConfigPluginCommentNvim : ConfigEntry
---@field opleader UserConfigPluginCommentNvimOpleader
---@field padding boolean
---@field sticky boolean
---@field toggler UserConfigPluginCommentNvimToggler
---@field extra UserConfigPluginCommentNvimExtra
---@field mappings UserConfigPluginCommentNvimMappings

---@class UserConfigPluginTelescopeNvim : ConfigEntry
---@field config UserConfigPluginTelescopeNvimConfig
---@field preview_exclude UserConfigPluginTelescopeNvimPreviewExclude

---@class UserConfigPluginNvimUfo : ConfigEntry
---@field preview UserConfigPluginNvimUfoPreview
---@field close_fold_kinds UserConfigPluginNvimUfoCloseFoldKinds
---@field enable_get_fold_virt_text boolean
---@field open_fold_hl_timeout number

---@class UserConfigPluginLspStatus : ConfigEntry
---@field indicator_hint string
---@field status_symbol string
---@field kind_labels UserConfigPluginLspStatusKindLabels
---@field current_function boolean
---@field show_filename boolean
---@field indicator_separator string
---@field component_separator string
---@field update_interval number
---@field indicator_errors string
---@field diagnostics boolean
---@field indicator_warnings string
---@field spinner_frames UserConfigPluginLspStatusSpinnerFrames
---@field indicator_info string
---@field indicator_ok string

---@class UserConfigPluginNullLs : ConfigEntry
---@field sources UserConfigPluginNullLsSources

---@class UserConfigPluginLuasnip : ConfigEntry
---@field ext_base_prio number
---@field ext_prio_increase number
---@field enable_autosnippets boolean
---@field store_selection_keys string
---@field updateevents string
---@field history boolean
---@field ext_opts UserConfigPluginLuasnipExtOpts

---@class UserConfigPluginNvimTree : ConfigEntry
---@field log UserConfigPluginNvimTreeLog
---@field renderer UserConfigPluginNvimTreeRenderer
---@field trash UserConfigPluginNvimTreeTrash
---@field actions UserConfigPluginNvimTreeActions
---@field respect_buf_cwd boolean
---@field create_in_closed_folder boolean
---@field disable_netrw boolean
---@field hijack_netrw boolean
---@field hijack_cursor boolean
---@field auto_reload_on_write boolean
---@field open_on_tab boolean
---@field update_cwd boolean
---@field hijack_unnamed_buffer_when_opening boolean
---@field hijack_directories UserConfigPluginNvimTreeHijackDirectories
---@field filters UserConfigPluginNvimTreeFilters
---@field diagnostics UserConfigPluginNvimTreeDiagnostics
---@field view UserConfigPluginNvimTreeView
---@field git UserConfigPluginNvimTreeGit
---@field update_focused_file UserConfigPluginNvimTreeUpdateFocusedFile
---@field system_open UserConfigPluginNvimTreeSystemOpen

---@class UserConfigPluginGitsigns : ConfigEntry
---@field signs UserConfigPluginGitsignsSigns
---@field preview_config UserConfigPluginGitsignsPreviewConfig
---@field attach_to_untracked boolean
---@field current_line_blame boolean
---@field numhl boolean
---@field yadm UserConfigPluginGitsignsYadm
---@field linehl boolean
---@field signcolumn boolean
---@field max_file_length number
---@field watch_gitdir UserConfigPluginGitsignsWatchGitdir
---@field current_line_blame_formatter string
---@field current_line_blame_opts UserConfigPluginGitsignsCurrentLineBlameOpts
---@field sign_priority number
---@field update_debounce number
---@field word_diff boolean

---@class UserConfigPlatformWindows : ConfigEntry
---@field nu_config_path string
---@field nu_env_path string

---@class UserConfigOptionGo : ConfigEntry
---@field shellpipe string
---@field shell string
---@field shellredir string
---@field shellcmdflag string
---@field shellquote string
---@field shellxquote string

---@class UserConfigOptionO : ConfigEntry
---@field expandtab boolean
---@field softtabstop number
---@field autoindent boolean
---@field cindent boolean
---@field conceallevel number
---@field foldenable boolean
---@field foldcolumn string
---@field foldlevelstart number
---@field mouse string
---@field foldnestmax number
---@field ignorecase boolean
---@field smartcase boolean
---@field completeopt string
---@field grepprg string
---@field ruler boolean
---@field list boolean
---@field showmatch boolean
---@field scrolloff number
---@field wrap boolean
---@field textwidth number
---@field wrapmargin number
---@field sidescrolloff number
---@field colorcolumn string
---@field foldlevel number
---@field cmdheight number
---@field updatetime number
---@field number boolean
---@field tabstop number
---@field shiftwidth number
---@field listchars string
---@field cursorline boolean
---@field showcmd boolean
---@field relativenumber boolean
---@field autochdir boolean
---@field autoread boolean
---@field backspace string
---@field termguicolors boolean
---@field clipboard string
---@field hidden boolean
---@field splitbelow boolean
---@field splitright boolean
---@field timeoutlen number
---@field fileformats string
---@field signcolumn string
---@field fileencodings string

---@class UserConfigOptionG : ConfigEntry
---@field mkdp_markdown_css string
---@field indentLine_setConceal boolean
---@field mkdp_highlight_css string
---@field vimtex_quickfix_mode number
---@field vimtex_syntax_enabled number
---@field vimtex_compiler_latexmk_engines UserConfigOptionGVimtexCompilerLatexmkEngines
---@field mapleader string
---@field mkdp_page_title string
---@field mkdp_open_to_the_world boolean
---@field python3_host_prog string
---@field plantuml_previewer#plantuml_jar_path string
---@field loaded_netrwPlugin number
---@field floaterm_shell string
---@field tex_flavor string
---@field indentLine_setColors boolean
---@field indentLine_color_term number
---@field indentLine_color_gui string
---@field vimtex_view_general_viewer string
---@field indentLine_char_list UserConfigOptionGIndentLineCharList
---@field mkdp_filetypes UserConfigOptionGMkdpFiletypes
---@field voom_python_versions UserConfigOptionGVoomPythonVersions

-- underlaying: table[]
---@class UserConfigGeneralFiletypeMapping : ConfigEntry

-- underlaying: string[]
---@class UserConfigGeneralFiletypeNoSoftTab : ConfigEntry

-- underlaying: string[]
---@class UserConfigKeybindingGlobalSearchSearchPaths : ConfigEntry

---@class UserConfigKeybindingGlobalSearchCmdTemplateMap : ConfigEntry
---@field default string

-- underlaying: string[]
---@class UserConfigKeybindingCursorFileJumpPattern : ConfigEntry

---@class UserConfigThemeHighlightTabStatusSignActive : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightCursorLine : ConfigEntry
---@field bg string

---@class UserConfigThemeHighlightVisual : ConfigEntry
---@field bg string

---@class UserConfigThemeHighlightDiffChange : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightDiffCommon : ConfigEntry
---@field fg string

---@class UserConfigThemeHighlightDiffDelete : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightTabStatusSign : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightDiffInsert : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightLspLogTrace : ConfigEntry
---@field bg string

---@class UserConfigThemeHighlightFolded : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightTabSignActive : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightTabBar : ConfigEntry
---@field bg string

---@class UserConfigThemeHighlightTabIcon : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightTabActive : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightLspLogDebug : ConfigEntry
---@field bg string

---@class UserConfigThemeHighlightTabInactive : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightLspLogInfo : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightTabSign : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightLspLogWarn : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightLspLogError : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightTabStatus : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightPanelpalSelect : ConfigEntry
---@field fg string

---@class UserConfigThemeHighlightPanelpalUnselect : ConfigEntry
---@field fg string

---@class UserConfigPluginNvimCursorlineCursorword : ConfigEntry
---@field timeout number
---@field min_length number
---@field hl UserConfigPluginNvimCursorlineCursorwordHl
---@field enable boolean

-- underlaying: string[]
---@class UserConfigPluginNvimCursorlineDisableInBuftype : ConfigEntry

---@class UserConfigPluginNvimCursorlineCursorline : ConfigEntry
---@field timeout number
---@field no_line_number_highlight boolean
---@field enable boolean

-- underlaying: string[]
---@class UserConfigPluginNvimCursorlineDisableInFiletype : ConfigEntry

---@class UserConfigPluginNvimTreesitterInstall : ConfigEntry
---@field prefer_git boolean
---@field compilers UserConfigPluginNvimTreesitterInstallCompilers
---@field command_extra_args UserConfigPluginNvimTreesitterInstallCommandExtraArgs

---@class UserConfigPluginNvimTreesitterConfigs : ConfigEntry
---@field incremental_selection UserConfigPluginNvimTreesitterConfigsIncrementalSelection
---@field playground UserConfigPluginNvimTreesitterConfigsPlayground
---@field ensure_installed UserConfigPluginNvimTreesitterConfigsEnsureInstalled
---@field rainbow UserConfigPluginNvimTreesitterConfigsRainbow
---@field indent UserConfigPluginNvimTreesitterConfigsIndent
---@field highlight UserConfigPluginNvimTreesitterConfigsHighlight
---@field sync_install boolean
---@field query_linter UserConfigPluginNvimTreesitterConfigsQueryLinter

---@class UserConfigPluginNvimTreesitterParsers : ConfigEntry
---@field nu UserConfigPluginNvimTreesitterParsersNu

---@class UserConfigPluginLualineInactiveSections : ConfigEntry
---@field lualine_b UserConfigPluginLualineInactiveSectionsLualineB
---@field lualine_c UserConfigPluginLualineInactiveSectionsLualineC
---@field lualine_x UserConfigPluginLualineInactiveSectionsLualineX
---@field lualine_y UserConfigPluginLualineInactiveSectionsLualineY
---@field lualine_z UserConfigPluginLualineInactiveSectionsLualineZ
---@field lualine_a UserConfigPluginLualineInactiveSectionsLualineA

---@class UserConfigPluginLualineOptions : ConfigEntry
---@field icons_enabled boolean
---@field component_separators string
---@field theme string
---@field refresh UserConfigPluginLualineOptionsRefresh
---@field ignore_focus UserConfigPluginLualineOptionsIgnoreFocus
---@field always_divide_middle boolean
---@field globalstatus boolean
---@field disabled_filetypes UserConfigPluginLualineOptionsDisabledFiletypes
---@field section_separators UserConfigPluginLualineOptionsSectionSeparators

-- underlaying: any[]
---@class UserConfigPluginLualineExtensions : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLualineWinbar : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLualineTabline : ConfigEntry

---@class UserConfigPluginLualineSections : ConfigEntry
---@field lualine_b UserConfigPluginLualineSectionsLualineB
---@field lualine_c UserConfigPluginLualineSectionsLualineC
---@field lualine_x UserConfigPluginLualineSectionsLualineX
---@field lualine_y UserConfigPluginLualineSectionsLualineY
---@field lualine_z UserConfigPluginLualineSectionsLualineZ
---@field lualine_a UserConfigPluginLualineSectionsLualineA

-- underlaying: any[]
---@class UserConfigPluginLualineInactiveWinbar : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginNvimLspconfigConfig : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginNvimLspconfigLspServers : ConfigEntry

---@class UserConfigPluginCommentNvimOpleader : ConfigEntry
---@field line string
---@field block string

---@class UserConfigPluginCommentNvimToggler : ConfigEntry
---@field line string
---@field block string

---@class UserConfigPluginCommentNvimExtra : ConfigEntry
---@field eol string
---@field below string
---@field above string

---@class UserConfigPluginCommentNvimMappings : ConfigEntry
---@field extra boolean
---@field basic boolean

---@class UserConfigPluginTelescopeNvimConfig : ConfigEntry
---@field defaults UserConfigPluginTelescopeNvimConfigDefaults

-- underlaying: string[]
---@class UserConfigPluginTelescopeNvimPreviewExclude : ConfigEntry

---@class UserConfigPluginNvimUfoPreview : ConfigEntry
---@field win_config UserConfigPluginNvimUfoPreviewWinConfig

-- underlaying: any[]
---@class UserConfigPluginNvimUfoCloseFoldKinds : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLspStatusKindLabels : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLspStatusSpinnerFrames : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginNullLsSources : ConfigEntry

---@class UserConfigPluginLuasnipExtOpts : ConfigEntry

---@class UserConfigPluginNvimTreeLog : ConfigEntry
---@field types UserConfigPluginNvimTreeLogTypes
---@field enable boolean

---@class UserConfigPluginNvimTreeRenderer : ConfigEntry
---@field icons UserConfigPluginNvimTreeRendererIcons
---@field highlight_opened_files string
---@field special_files UserConfigPluginNvimTreeRendererSpecialFiles
---@field highlight_git boolean
---@field group_empty boolean

---@class UserConfigPluginNvimTreeTrash : ConfigEntry
---@field require_confirm boolean
---@field cmd string

---@class UserConfigPluginNvimTreeActions : ConfigEntry
---@field change_dir UserConfigPluginNvimTreeActionsChangeDir
---@field open_file UserConfigPluginNvimTreeActionsOpenFile

---@class UserConfigPluginNvimTreeHijackDirectories : ConfigEntry
---@field auto_open boolean
---@field enable boolean

---@class UserConfigPluginNvimTreeFilters : ConfigEntry
---@field dotfiles boolean
---@field custom UserConfigPluginNvimTreeFiltersCustom

---@class UserConfigPluginNvimTreeDiagnostics : ConfigEntry
---@field icons UserConfigPluginNvimTreeDiagnosticsIcons
---@field enable boolean

---@class UserConfigPluginNvimTreeView : ConfigEntry
---@field preserve_window_proportions boolean
---@field relativenumber boolean
---@field number boolean
---@field width number
---@field signcolumn string
---@field hide_root_folder boolean
---@field side string
---@field mappings UserConfigPluginNvimTreeViewMappings

---@class UserConfigPluginNvimTreeGit : ConfigEntry
---@field timeout number
---@field enable boolean
---@field ignore boolean

---@class UserConfigPluginNvimTreeUpdateFocusedFile : ConfigEntry
---@field ignore_list UserConfigPluginNvimTreeUpdateFocusedFileIgnoreList
---@field update_cwd boolean
---@field enable boolean

---@class UserConfigPluginNvimTreeSystemOpen : ConfigEntry
---@field args UserConfigPluginNvimTreeSystemOpenArgs

---@class UserConfigPluginGitsignsSigns : ConfigEntry
---@field topdelete UserConfigPluginGitsignsSignsTopdelete
---@field change UserConfigPluginGitsignsSignsChange
---@field changedelete UserConfigPluginGitsignsSignsChangedelete
---@field untracked UserConfigPluginGitsignsSignsUntracked
---@field add UserConfigPluginGitsignsSignsAdd
---@field delete UserConfigPluginGitsignsSignsDelete

---@class UserConfigPluginGitsignsPreviewConfig : ConfigEntry
---@field style string
---@field border string
---@field col number
---@field row number
---@field relative string

---@class UserConfigPluginGitsignsYadm : ConfigEntry
---@field enable boolean

---@class UserConfigPluginGitsignsWatchGitdir : ConfigEntry
---@field follow_files boolean
---@field interval number

---@class UserConfigPluginGitsignsCurrentLineBlameOpts : ConfigEntry
---@field ignore_whitespace boolean
---@field delay number
---@field virt_text boolean
---@field virt_text_pos string

---@class UserConfigOptionGVimtexCompilerLatexmkEngines : ConfigEntry
---@field pdflatex string
---@field context (luatex) string
---@field dvipdfex string
---@field context (xetex) string
---@field lualatex string
---@field _ string
---@field xelatex string
---@field context (pdftex) string

-- underlaying: string[]
---@class UserConfigOptionGIndentLineCharList : ConfigEntry

-- underlaying: string[]
---@class UserConfigOptionGMkdpFiletypes : ConfigEntry

-- underlaying: number[]
---@class UserConfigOptionGVoomPythonVersions : ConfigEntry

---@class UserConfigPluginNvimCursorlineCursorwordHl : ConfigEntry
---@field underline boolean
---@field bg string

-- underlaying: any[]
---@class UserConfigPluginNvimTreesitterInstallCompilers : ConfigEntry

---@class UserConfigPluginNvimTreesitterInstallCommandExtraArgs : ConfigEntry
---@field curl UserConfigPluginNvimTreesitterInstallCommandExtraArgsCurl
---@field cl UserConfigPluginNvimTreesitterInstallCommandExtraArgsCl

---@class UserConfigPluginNvimTreesitterConfigsIncrementalSelection : ConfigEntry
---@field keymaps UserConfigPluginNvimTreesitterConfigsIncrementalSelectionKeymaps
---@field enable boolean

---@class UserConfigPluginNvimTreesitterConfigsPlayground : ConfigEntry
---@field keybindings UserConfigPluginNvimTreesitterConfigsPlaygroundKeybindings
---@field enable boolean

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterConfigsEnsureInstalled : ConfigEntry

---@class UserConfigPluginNvimTreesitterConfigsRainbow : ConfigEntry
---@field colors UserConfigPluginNvimTreesitterConfigsRainbowColors
---@field extended_mode boolean
---@field enable boolean

-- underlaying: any[]
---@class UserConfigPluginNvimTreesitterConfigsIndent : ConfigEntry

---@class UserConfigPluginNvimTreesitterConfigsHighlight : ConfigEntry
---@field additional_vim_regex_highlighting boolean
---@field enable boolean

---@class UserConfigPluginNvimTreesitterConfigsQueryLinter : ConfigEntry
---@field use_virtual_text boolean
---@field lint_events UserConfigPluginNvimTreesitterConfigsQueryLinterLintEvents
---@field enable boolean

---@class UserConfigPluginNvimTreesitterParsersNu : ConfigEntry
---@field install_info UserConfigPluginNvimTreesitterParsersNuInstallInfo
---@field filetype string

-- underlaying: any[]
---@class UserConfigPluginLualineInactiveSectionsLualineB : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLualineInactiveSectionsLualineC : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLualineInactiveSectionsLualineX : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLualineInactiveSectionsLualineY : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLualineInactiveSectionsLualineZ : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLualineInactiveSectionsLualineA : ConfigEntry

---@class UserConfigPluginLualineOptionsRefresh : ConfigEntry
---@field statusline number
---@field tabline number
---@field winbar number

-- underlaying: any[]
---@class UserConfigPluginLualineOptionsIgnoreFocus : ConfigEntry

---@class UserConfigPluginLualineOptionsDisabledFiletypes : ConfigEntry
---@field statusline UserConfigPluginLualineOptionsDisabledFiletypesStatusline
---@field winbar UserConfigPluginLualineOptionsDisabledFiletypesWinbar

---@class UserConfigPluginLualineOptionsSectionSeparators : ConfigEntry
---@field right string
---@field left string

-- underlaying: string[]
---@class UserConfigPluginLualineSectionsLualineB : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLualineSectionsLualineC : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLualineSectionsLualineX : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLualineSectionsLualineY : ConfigEntry

-- underlaying: table[]
---@class UserConfigPluginLualineSectionsLualineZ : ConfigEntry

-- underlaying: table[]
---@class UserConfigPluginLualineSectionsLualineA : ConfigEntry

---@class UserConfigPluginTelescopeNvimConfigDefaults : ConfigEntry
---@field buffer_previewer_maker function

---@class UserConfigPluginNvimUfoPreviewWinConfig : ConfigEntry
---@field winblend number
---@field maxheight number
---@field winhighlight string
---@field border string

---@class UserConfigPluginNvimTreeLogTypes : ConfigEntry
---@field all boolean
---@field config boolean
---@field git boolean

---@class UserConfigPluginNvimTreeRendererIcons : ConfigEntry
---@field padding string
---@field glyphs UserConfigPluginNvimTreeRendererIconsGlyphs
---@field show UserConfigPluginNvimTreeRendererIconsShow

---@class UserConfigPluginNvimTreeRendererSpecialFiles : ConfigEntry
---@field Makefile number
---@field MAKEFILE number
---@field README.md number

---@class UserConfigPluginNvimTreeActionsChangeDir : ConfigEntry
---@field global boolean
---@field enable boolean

---@class UserConfigPluginNvimTreeActionsOpenFile : ConfigEntry
---@field window_picker UserConfigPluginNvimTreeActionsOpenFileWindowPicker
---@field quit_on_open boolean
---@field resize_window boolean

-- underlaying: string[]
---@class UserConfigPluginNvimTreeFiltersCustom : ConfigEntry

---@class UserConfigPluginNvimTreeDiagnosticsIcons : ConfigEntry
---@field hint string
---@field info string
---@field error string
---@field warning string

---@class UserConfigPluginNvimTreeViewMappings : ConfigEntry
---@field list UserConfigPluginNvimTreeViewMappingsList
---@field custom_only boolean

-- underlaying: any[]
---@class UserConfigPluginNvimTreeUpdateFocusedFileIgnoreList : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginNvimTreeSystemOpenArgs : ConfigEntry

---@class UserConfigPluginGitsignsSignsTopdelete : ConfigEntry
---@field linehl string
---@field numhl string
---@field hl string
---@field text string

---@class UserConfigPluginGitsignsSignsChange : ConfigEntry
---@field linehl string
---@field numhl string
---@field hl string
---@field text string

---@class UserConfigPluginGitsignsSignsChangedelete : ConfigEntry
---@field linehl string
---@field numhl string
---@field hl string
---@field text string

---@class UserConfigPluginGitsignsSignsUntracked : ConfigEntry
---@field linehl string
---@field numhl string
---@field hl string
---@field text string

---@class UserConfigPluginGitsignsSignsAdd : ConfigEntry
---@field linehl string
---@field numhl string
---@field hl string
---@field text string

---@class UserConfigPluginGitsignsSignsDelete : ConfigEntry
---@field linehl string
---@field numhl string
---@field hl string
---@field text string

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterInstallCommandExtraArgsCurl : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterInstallCommandExtraArgsCl : ConfigEntry

---@class UserConfigPluginNvimTreesitterConfigsIncrementalSelectionKeymaps : ConfigEntry
---@field node_incremental string
---@field node_decremental string
---@field scope_incremental string
---@field init_selection string

---@class UserConfigPluginNvimTreesitterConfigsPlaygroundKeybindings : ConfigEntry
---@field update string
---@field toggle_query_editor string
---@field toggle_hl_groups string
---@field toggle_injected_languages string
---@field toggle_anonymous_nodes string
---@field toggle_language_display string
---@field focus_language string
---@field unfocus_language string
---@field goto_node string
---@field show_help string

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterConfigsRainbowColors : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterConfigsQueryLinterLintEvents : ConfigEntry

---@class UserConfigPluginNvimTreesitterParsersNuInstallInfo : ConfigEntry
---@field url string
---@field branch string
---@field files UserConfigPluginNvimTreesitterParsersNuInstallInfoFiles

-- underlaying: any[]
---@class UserConfigPluginLualineOptionsDisabledFiletypesStatusline : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLualineOptionsDisabledFiletypesWinbar : ConfigEntry

---@class UserConfigPluginNvimTreeRendererIconsGlyphs : ConfigEntry
---@field folder UserConfigPluginNvimTreeRendererIconsGlyphsFolder
---@field symlink string
---@field git UserConfigPluginNvimTreeRendererIconsGlyphsGit
---@field default string

---@class UserConfigPluginNvimTreeRendererIconsShow : ConfigEntry
---@field folder boolean
---@field folder_arrow boolean
---@field file boolean
---@field git boolean

---@class UserConfigPluginNvimTreeActionsOpenFileWindowPicker : ConfigEntry
---@field chars string
---@field exclude UserConfigPluginNvimTreeActionsOpenFileWindowPickerExclude
---@field enable boolean

-- underlaying: any[]
---@class UserConfigPluginNvimTreeViewMappingsList : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterParsersNuInstallInfoFiles : ConfigEntry

---@class UserConfigPluginNvimTreeRendererIconsGlyphsFolder : ConfigEntry
---@field arrow_closed string
---@field empty_open string
---@field arrow_open string
---@field default string
---@field open string
---@field symlink string
---@field empty string
---@field symlink_open string

---@class UserConfigPluginNvimTreeRendererIconsGlyphsGit : ConfigEntry
---@field staged string
---@field unmerged string
---@field renamed string
---@field untracked string
---@field ignored string
---@field deleted string
---@field unstaged string

---@class UserConfigPluginNvimTreeActionsOpenFileWindowPickerExclude : ConfigEntry
---@field buftype UserConfigPluginNvimTreeActionsOpenFileWindowPickerExcludeBuftype
---@field filetype UserConfigPluginNvimTreeActionsOpenFileWindowPickerExcludeFiletype

-- underlaying: string[]
---@class UserConfigPluginNvimTreeActionsOpenFileWindowPickerExcludeBuftype : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginNvimTreeActionsOpenFileWindowPickerExcludeFiletype : ConfigEntry
