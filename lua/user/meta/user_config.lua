---@meta

---@class UserConfig
---@field general UserConfigGeneral
---@field keybinding UserConfigKeybinding
---@field option UserConfigOption
---@field platform UserConfigPlatform
---@field env UserConfigEnv
---@field theme UserConfigTheme
---@field plugin UserConfigPlugin
---@field lsp UserConfigLsp

---@class UserConfigGeneral : ConfigEntry
---@field im_select UserConfigGeneralImSelect
---@field locale string
---@field filetype UserConfigGeneralFiletype

---@class UserConfigKeybinding : ConfigEntry
---@field global_search UserConfigKeybindingGlobalSearch

---@class UserConfigOption : ConfigEntry
---@field o UserConfigOptionO
---@field g UserConfigOptionG
---@field go UserConfigOptionGo

-- underlaying: any[]
---@class UserConfigPlatform : ConfigEntry

---@class UserConfigEnv : ConfigEntry
---@field NVIM_HOME string
---@field CONFIG_HOME string
---@field PROXY_URL string

---@class UserConfigTheme : ConfigEntry
---@field colorscheme string
---@field lualine_theme string
---@field highlight UserConfigThemeHighlight

---@class UserConfigPlugin : ConfigEntry
---@field nvim_lspconfig UserConfigPluginNvimLspconfig
---@field nvim_cursorline UserConfigPluginNvimCursorline
---@field nvim_cmp UserConfigPluginNvimCmp
---@field lsp_status UserConfigPluginLspStatus
---@field gitsigns UserConfigPluginGitsigns
---@field luasnip UserConfigPluginLuasnip
---@field nvim_ufo UserConfigPluginNvimUfo
---@field telescope_nvim UserConfigPluginTelescopeNvim
---@field nvim_treesitter UserConfigPluginNvimTreesitter
---@field lualine UserConfigPluginLualine
---@field null_ls UserConfigPluginNullLs
---@field nvim_tree UserConfigPluginNvimTree

---@class UserConfigLsp : ConfigEntry
---@field log_update_method string
---@field log_scroll_method string
---@field format_args UserConfigLspFormatArgs
---@field on_attach_callbacks UserConfigLspOnAttachCallbacks
---@field capabilities_settings UserConfigLspCapabilitiesSettings

---@class UserConfigGeneralImSelect : ConfigEntry
---@field off string
---@field check string
---@field on string
---@field isoff function

---@class UserConfigGeneralFiletype : ConfigEntry
---@field no_soft_tab UserConfigGeneralFiletypeNoSoftTab
---@field mapping UserConfigGeneralFiletypeMapping

---@class UserConfigKeybindingGlobalSearch : ConfigEntry
---@field make_cmd function
---@field cmd_template_map UserConfigKeybindingGlobalSearchCmdTemplateMap
---@field search_paths UserConfigKeybindingGlobalSearchSearchPaths

---@class UserConfigOptionO : ConfigEntry
---@field signcolumn string
---@field termguicolors boolean
---@field list boolean
---@field relativenumber boolean
---@field backspace string
---@field clipboard string
---@field splitbelow boolean
---@field splitright boolean
---@field timeoutlen number
---@field fileformats string
---@field fileencodings string
---@field autoread boolean
---@field softtabstop number
---@field autoindent boolean
---@field cindent boolean
---@field foldnestmax number
---@field ignorecase boolean
---@field smartcase boolean
---@field completeopt string
---@field grepprg string
---@field ruler boolean
---@field showcmd boolean
---@field showmatch boolean
---@field scrolloff number
---@field shiftwidth number
---@field tabstop number
---@field number boolean
---@field sidescrolloff number
---@field expandtab boolean
---@field cmdheight number
---@field listchars string
---@field conceallevel number
---@field foldenable boolean
---@field foldlevel number
---@field mouse string
---@field cursorline boolean
---@field updatetime number
---@field autochdir boolean
---@field wrap boolean
---@field colorcolumn string
---@field wrapmargin number
---@field textwidth number
---@field foldcolumn string
---@field foldlevelstart number
---@field hidden boolean

---@class UserConfigOptionG : ConfigEntry
---@field vimtex_compiler_latexmk_engines UserConfigOptionGVimtexCompilerLatexmkEngines
---@field indentLine_char_list UserConfigOptionGIndentLineCharList
---@field indentLine_setConceal boolean
---@field indentLine_color_gui string
---@field indentLine_color_term number
---@field plantuml_previewer#plantuml_jar_path string
---@field mkdp_open_to_the_world boolean
---@field mkdp_filetypes UserConfigOptionGMkdpFiletypes
---@field NERDSpaceDelims number
---@field mkdp_markdown_css string
---@field NERDCommentEmptyLines number
---@field NERDTrimTrailingWhitespace number
---@field NERDToggleCheckAllLines number
---@field python3_host_prog string
---@field voom_python_versions UserConfigOptionGVoomPythonVersions
---@field loaded_netrwPlugin number
---@field mkdp_page_title string
---@field tex_flavor string
---@field NERDCompactSexyComs number
---@field floaterm_shell string
---@field mkdp_highlight_css string
---@field mapleader string
---@field vimtex_view_general_viewer string
---@field indentLine_setColors boolean
---@field vimtex_quickfix_mode number
---@field vimtex_syntax_enabled number

---@class UserConfigOptionGo : ConfigEntry
---@field shellredir string
---@field shell string
---@field shellcmdflag string
---@field shellquote string
---@field shellxquote string
---@field shellpipe string

---@class UserConfigThemeHighlight : ConfigEntry
---@field LspLogTrace UserConfigThemeHighlightLspLogTrace
---@field DiffChange UserConfigThemeHighlightDiffChange
---@field CursorLine UserConfigThemeHighlightCursorLine
---@field LspLogError UserConfigThemeHighlightLspLogError
---@field LspLogInfo UserConfigThemeHighlightLspLogInfo
---@field Visual UserConfigThemeHighlightVisual
---@field LspLogWarn UserConfigThemeHighlightLspLogWarn
---@field DiffCommon UserConfigThemeHighlightDiffCommon
---@field PanelpalSelect UserConfigThemeHighlightPanelpalSelect
---@field DiffDelete UserConfigThemeHighlightDiffDelete
---@field PanelpalUnselect UserConfigThemeHighlightPanelpalUnselect
---@field DiffInsert UserConfigThemeHighlightDiffInsert
---@field LspLogDebug UserConfigThemeHighlightLspLogDebug
---@field Folded UserConfigThemeHighlightFolded

---@class UserConfigPluginNvimLspconfig : ConfigEntry
---@field config UserConfigPluginNvimLspconfigConfig
---@field lsp_servers UserConfigPluginNvimLspconfigLspServers

---@class UserConfigPluginNvimCursorline : ConfigEntry
---@field cursorword UserConfigPluginNvimCursorlineCursorword
---@field disable_in_buftype UserConfigPluginNvimCursorlineDisableInBuftype
---@field cursorline UserConfigPluginNvimCursorlineCursorline
---@field disable_in_filetype UserConfigPluginNvimCursorlineDisableInFiletype

---@class UserConfigPluginNvimCmp : ConfigEntry
---@field sources UserConfigPluginNvimCmpSources

---@class UserConfigPluginLspStatus : ConfigEntry
---@field indicator_warnings string
---@field status_symbol string
---@field indicator_info string
---@field update_interval number
---@field indicator_ok string
---@field spinner_frames UserConfigPluginLspStatusSpinnerFrames
---@field kind_labels UserConfigPluginLspStatusKindLabels
---@field current_function boolean
---@field show_filename boolean
---@field indicator_separator string
---@field component_separator string
---@field diagnostics boolean
---@field indicator_errors string
---@field indicator_hint string

---@class UserConfigPluginGitsigns : ConfigEntry
---@field update_debounce number
---@field word_diff boolean
---@field watch_gitdir UserConfigPluginGitsignsWatchGitdir
---@field preview_config UserConfigPluginGitsignsPreviewConfig
---@field attach_to_untracked boolean
---@field current_line_blame boolean
---@field current_line_blame_opts UserConfigPluginGitsignsCurrentLineBlameOpts
---@field signs UserConfigPluginGitsignsSigns
---@field linehl boolean
---@field yadm UserConfigPluginGitsignsYadm
---@field numhl boolean
---@field signcolumn boolean
---@field current_line_blame_formatter string
---@field max_file_length number
---@field sign_priority number

---@class UserConfigPluginLuasnip : ConfigEntry
---@field updateevents string
---@field ext_opts UserConfigPluginLuasnipExtOpts
---@field history boolean
---@field ext_base_prio number
---@field ext_prio_increase number
---@field enable_autosnippets boolean
---@field store_selection_keys string

---@class UserConfigPluginNvimUfo : ConfigEntry
---@field enable_get_fold_virt_text boolean
---@field open_fold_hl_timeout number
---@field close_fold_kinds UserConfigPluginNvimUfoCloseFoldKinds
---@field preview UserConfigPluginNvimUfoPreview

---@class UserConfigPluginTelescopeNvim : ConfigEntry
---@field config UserConfigPluginTelescopeNvimConfig
---@field preview_exclude UserConfigPluginTelescopeNvimPreviewExclude

---@class UserConfigPluginNvimTreesitter : ConfigEntry
---@field install UserConfigPluginNvimTreesitterInstall
---@field parsers UserConfigPluginNvimTreesitterParsers
---@field configs UserConfigPluginNvimTreesitterConfigs

---@class UserConfigPluginLualine : ConfigEntry
---@field winbar UserConfigPluginLualineWinbar
---@field options UserConfigPluginLualineOptions
---@field sections UserConfigPluginLualineSections
---@field extensions UserConfigPluginLualineExtensions
---@field tabline UserConfigPluginLualineTabline
---@field inactive_sections UserConfigPluginLualineInactiveSections
---@field inactive_winbar UserConfigPluginLualineInactiveWinbar

---@class UserConfigPluginNullLs : ConfigEntry
---@field sources UserConfigPluginNullLsSources

---@class UserConfigPluginNvimTree : ConfigEntry
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
---@field diagnostics UserConfigPluginNvimTreeDiagnostics
---@field trash UserConfigPluginNvimTreeTrash
---@field actions UserConfigPluginNvimTreeActions
---@field renderer UserConfigPluginNvimTreeRenderer
---@field log UserConfigPluginNvimTreeLog
---@field update_focused_file UserConfigPluginNvimTreeUpdateFocusedFile
---@field view UserConfigPluginNvimTreeView
---@field system_open UserConfigPluginNvimTreeSystemOpen
---@field filters UserConfigPluginNvimTreeFilters
---@field git UserConfigPluginNvimTreeGit

---@class UserConfigLspFormatArgs : ConfigEntry
---@field async boolean

-- underlaying: function[]
---@class UserConfigLspOnAttachCallbacks : ConfigEntry

-- underlaying: table[]
---@class UserConfigLspCapabilitiesSettings : ConfigEntry

-- underlaying: string[]
---@class UserConfigGeneralFiletypeNoSoftTab : ConfigEntry

---@class UserConfigGeneralFiletypeMapping : ConfigEntry
---@field snippet UserConfigGeneralFiletypeMappingSnippet
---@field vlang UserConfigGeneralFiletypeMappingVlang
---@field nu UserConfigGeneralFiletypeMappingNu
---@field json UserConfigGeneralFiletypeMappingJson
---@field tree-sitter-test UserConfigGeneralFiletypeMappingTree-sitter-test
---@field xml UserConfigGeneralFiletypeMappingXml

---@class UserConfigKeybindingGlobalSearchCmdTemplateMap : ConfigEntry
---@field default string

-- underlaying: string[]
---@class UserConfigKeybindingGlobalSearchSearchPaths : ConfigEntry

---@class UserConfigOptionGVimtexCompilerLatexmkEngines : ConfigEntry
---@field xelatex string
---@field context (pdftex) string
---@field pdflatex string
---@field context (luatex) string
---@field dvipdfex string
---@field context (xetex) string
---@field lualatex string
---@field _ string

-- underlaying: string[]
---@class UserConfigOptionGIndentLineCharList : ConfigEntry

-- underlaying: string[]
---@class UserConfigOptionGMkdpFiletypes : ConfigEntry

-- underlaying: number[]
---@class UserConfigOptionGVoomPythonVersions : ConfigEntry

---@class UserConfigThemeHighlightLspLogTrace : ConfigEntry
---@field bg string

---@class UserConfigThemeHighlightDiffChange : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightCursorLine : ConfigEntry
---@field bg string

---@class UserConfigThemeHighlightLspLogError : ConfigEntry
---@field bg string
---@field fg string

---@class UserConfigThemeHighlightLspLogInfo : ConfigEntry
---@field bg string
---@field fg string

---@class UserConfigThemeHighlightVisual : ConfigEntry
---@field bg string

---@class UserConfigThemeHighlightLspLogWarn : ConfigEntry
---@field bg string
---@field fg string

---@class UserConfigThemeHighlightDiffCommon : ConfigEntry
---@field fg string

---@class UserConfigThemeHighlightPanelpalSelect : ConfigEntry
---@field fg string

---@class UserConfigThemeHighlightDiffDelete : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightPanelpalUnselect : ConfigEntry
---@field fg string

---@class UserConfigThemeHighlightDiffInsert : ConfigEntry
---@field fg string
---@field bg string

---@class UserConfigThemeHighlightLspLogDebug : ConfigEntry
---@field bg string

---@class UserConfigThemeHighlightFolded : ConfigEntry
---@field bg string
---@field fg string

-- underlaying: any[]
---@class UserConfigPluginNvimLspconfigConfig : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginNvimLspconfigLspServers : ConfigEntry

---@class UserConfigPluginNvimCursorlineCursorword : ConfigEntry
---@field hl UserConfigPluginNvimCursorlineCursorwordHl
---@field min_length number
---@field enable boolean
---@field timeout number

-- underlaying: string[]
---@class UserConfigPluginNvimCursorlineDisableInBuftype : ConfigEntry

---@class UserConfigPluginNvimCursorlineCursorline : ConfigEntry
---@field enable boolean
---@field timeout number
---@field no_line_number_highlight boolean

-- underlaying: string[]
---@class UserConfigPluginNvimCursorlineDisableInFiletype : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginNvimCmpSources : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLspStatusSpinnerFrames : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLspStatusKindLabels : ConfigEntry

---@class UserConfigPluginGitsignsWatchGitdir : ConfigEntry
---@field follow_files boolean
---@field interval number

---@class UserConfigPluginGitsignsPreviewConfig : ConfigEntry
---@field border string
---@field col number
---@field row number
---@field relative string
---@field style string

---@class UserConfigPluginGitsignsCurrentLineBlameOpts : ConfigEntry
---@field virt_text boolean
---@field virt_text_pos string
---@field ignore_whitespace boolean
---@field delay number

---@class UserConfigPluginGitsignsSigns : ConfigEntry
---@field add UserConfigPluginGitsignsSignsAdd
---@field topdelete UserConfigPluginGitsignsSignsTopdelete
---@field changedelete UserConfigPluginGitsignsSignsChangedelete
---@field change UserConfigPluginGitsignsSignsChange
---@field untracked UserConfigPluginGitsignsSignsUntracked
---@field delete UserConfigPluginGitsignsSignsDelete

---@class UserConfigPluginGitsignsYadm : ConfigEntry
---@field enable boolean

---@class UserConfigPluginLuasnipExtOpts : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginNvimUfoCloseFoldKinds : ConfigEntry

---@class UserConfigPluginNvimUfoPreview : ConfigEntry
---@field win_config UserConfigPluginNvimUfoPreviewWinConfig

---@class UserConfigPluginTelescopeNvimConfig : ConfigEntry
---@field defaults UserConfigPluginTelescopeNvimConfigDefaults

-- underlaying: string[]
---@class UserConfigPluginTelescopeNvimPreviewExclude : ConfigEntry

---@class UserConfigPluginNvimTreesitterInstall : ConfigEntry
---@field prefer_git boolean
---@field compilers UserConfigPluginNvimTreesitterInstallCompilers
---@field command_extra_args UserConfigPluginNvimTreesitterInstallCommandExtraArgs

---@class UserConfigPluginNvimTreesitterParsers : ConfigEntry
---@field nu UserConfigPluginNvimTreesitterParsersNu

---@class UserConfigPluginNvimTreesitterConfigs : ConfigEntry
---@field ensure_installed UserConfigPluginNvimTreesitterConfigsEnsureInstalled
---@field query_linter UserConfigPluginNvimTreesitterConfigsQueryLinter
---@field sync_install boolean
---@field highlight UserConfigPluginNvimTreesitterConfigsHighlight
---@field incremental_selection UserConfigPluginNvimTreesitterConfigsIncrementalSelection
---@field playground UserConfigPluginNvimTreesitterConfigsPlayground
---@field rainbow UserConfigPluginNvimTreesitterConfigsRainbow
---@field indent UserConfigPluginNvimTreesitterConfigsIndent

-- underlaying: any[]
---@class UserConfigPluginLualineWinbar : ConfigEntry

---@class UserConfigPluginLualineOptions : ConfigEntry
---@field ignore_focus UserConfigPluginLualineOptionsIgnoreFocus
---@field always_divide_middle boolean
---@field theme string
---@field icons_enabled boolean
---@field component_separators UserConfigPluginLualineOptionsComponentSeparators
---@field section_separators UserConfigPluginLualineOptionsSectionSeparators
---@field globalstatus boolean
---@field refresh UserConfigPluginLualineOptionsRefresh
---@field disabled_filetypes UserConfigPluginLualineOptionsDisabledFiletypes

---@class UserConfigPluginLualineSections : ConfigEntry
---@field lualine_b UserConfigPluginLualineSectionsLualineB
---@field lualine_c UserConfigPluginLualineSectionsLualineC
---@field lualine_x UserConfigPluginLualineSectionsLualineX
---@field lualine_y UserConfigPluginLualineSectionsLualineY
---@field lualine_z UserConfigPluginLualineSectionsLualineZ
---@field lualine_a UserConfigPluginLualineSectionsLualineA

-- underlaying: any[]
---@class UserConfigPluginLualineExtensions : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLualineTabline : ConfigEntry

---@class UserConfigPluginLualineInactiveSections : ConfigEntry
---@field lualine_b UserConfigPluginLualineInactiveSectionsLualineB
---@field lualine_c UserConfigPluginLualineInactiveSectionsLualineC
---@field lualine_x UserConfigPluginLualineInactiveSectionsLualineX
---@field lualine_y UserConfigPluginLualineInactiveSectionsLualineY
---@field lualine_z UserConfigPluginLualineInactiveSectionsLualineZ
---@field lualine_a UserConfigPluginLualineInactiveSectionsLualineA

-- underlaying: any[]
---@class UserConfigPluginLualineInactiveWinbar : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginNullLsSources : ConfigEntry

---@class UserConfigPluginNvimTreeHijackDirectories : ConfigEntry
---@field auto_open boolean
---@field enable boolean

---@class UserConfigPluginNvimTreeDiagnostics : ConfigEntry
---@field icons UserConfigPluginNvimTreeDiagnosticsIcons
---@field enable boolean

---@class UserConfigPluginNvimTreeTrash : ConfigEntry
---@field require_confirm boolean
---@field cmd string

---@class UserConfigPluginNvimTreeActions : ConfigEntry
---@field open_file UserConfigPluginNvimTreeActionsOpenFile
---@field change_dir UserConfigPluginNvimTreeActionsChangeDir

---@class UserConfigPluginNvimTreeRenderer : ConfigEntry
---@field special_files UserConfigPluginNvimTreeRendererSpecialFiles
---@field group_empty boolean
---@field highlight_opened_files string
---@field icons UserConfigPluginNvimTreeRendererIcons
---@field highlight_git boolean

---@class UserConfigPluginNvimTreeLog : ConfigEntry
---@field types UserConfigPluginNvimTreeLogTypes
---@field enable boolean

---@class UserConfigPluginNvimTreeUpdateFocusedFile : ConfigEntry
---@field ignore_list UserConfigPluginNvimTreeUpdateFocusedFileIgnoreList
---@field enable boolean
---@field update_cwd boolean

---@class UserConfigPluginNvimTreeView : ConfigEntry
---@field signcolumn string
---@field hide_root_folder boolean
---@field relativenumber boolean
---@field width number
---@field side string
---@field number boolean
---@field preserve_window_proportions boolean
---@field mappings UserConfigPluginNvimTreeViewMappings

---@class UserConfigPluginNvimTreeSystemOpen : ConfigEntry
---@field args UserConfigPluginNvimTreeSystemOpenArgs

---@class UserConfigPluginNvimTreeFilters : ConfigEntry
---@field custom UserConfigPluginNvimTreeFiltersCustom
---@field dotfiles boolean

---@class UserConfigPluginNvimTreeGit : ConfigEntry
---@field ignore boolean
---@field timeout number
---@field enable boolean

-- underlaying: string[]
---@class UserConfigGeneralFiletypeMappingSnippet : ConfigEntry

-- underlaying: string[]
---@class UserConfigGeneralFiletypeMappingVlang : ConfigEntry

-- underlaying: string[]
---@class UserConfigGeneralFiletypeMappingNu : ConfigEntry

-- underlaying: string[]
---@class UserConfigGeneralFiletypeMappingJson : ConfigEntry

-- underlaying: string[]
---@class UserConfigGeneralFiletypeMappingTree-sitter-test : ConfigEntry

-- underlaying: string[]
---@class UserConfigGeneralFiletypeMappingXml : ConfigEntry

---@class UserConfigPluginNvimCursorlineCursorwordHl : ConfigEntry
---@field underline boolean
---@field bg string

---@class UserConfigPluginGitsignsSignsAdd : ConfigEntry
---@field hl string
---@field numhl string
---@field linehl string
---@field text string

---@class UserConfigPluginGitsignsSignsTopdelete : ConfigEntry
---@field hl string
---@field numhl string
---@field linehl string
---@field text string

---@class UserConfigPluginGitsignsSignsChangedelete : ConfigEntry
---@field hl string
---@field numhl string
---@field linehl string
---@field text string

---@class UserConfigPluginGitsignsSignsChange : ConfigEntry
---@field hl string
---@field numhl string
---@field linehl string
---@field text string

---@class UserConfigPluginGitsignsSignsUntracked : ConfigEntry
---@field hl string
---@field numhl string
---@field linehl string
---@field text string

---@class UserConfigPluginGitsignsSignsDelete : ConfigEntry
---@field hl string
---@field numhl string
---@field linehl string
---@field text string

---@class UserConfigPluginNvimUfoPreviewWinConfig : ConfigEntry
---@field winhighlight string
---@field border string
---@field winblend number
---@field maxheight number

---@class UserConfigPluginTelescopeNvimConfigDefaults : ConfigEntry
---@field buffer_previewer_maker function

-- underlaying: any[]
---@class UserConfigPluginNvimTreesitterInstallCompilers : ConfigEntry

---@class UserConfigPluginNvimTreesitterInstallCommandExtraArgs : ConfigEntry
---@field cl UserConfigPluginNvimTreesitterInstallCommandExtraArgsCl
---@field curl UserConfigPluginNvimTreesitterInstallCommandExtraArgsCurl

---@class UserConfigPluginNvimTreesitterParsersNu : ConfigEntry
---@field install_info UserConfigPluginNvimTreesitterParsersNuInstallInfo
---@field filetype string

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterConfigsEnsureInstalled : ConfigEntry

---@class UserConfigPluginNvimTreesitterConfigsQueryLinter : ConfigEntry
---@field lint_events UserConfigPluginNvimTreesitterConfigsQueryLinterLintEvents
---@field use_virtual_text boolean
---@field enable boolean

---@class UserConfigPluginNvimTreesitterConfigsHighlight : ConfigEntry
---@field additional_vim_regex_highlighting boolean
---@field enable boolean

---@class UserConfigPluginNvimTreesitterConfigsIncrementalSelection : ConfigEntry
---@field keymaps UserConfigPluginNvimTreesitterConfigsIncrementalSelectionKeymaps
---@field enable boolean

---@class UserConfigPluginNvimTreesitterConfigsPlayground : ConfigEntry
---@field keybindings UserConfigPluginNvimTreesitterConfigsPlaygroundKeybindings
---@field enable boolean

---@class UserConfigPluginNvimTreesitterConfigsRainbow : ConfigEntry
---@field colors UserConfigPluginNvimTreesitterConfigsRainbowColors
---@field enable boolean
---@field extended_mode boolean

-- underlaying: any[]
---@class UserConfigPluginNvimTreesitterConfigsIndent : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLualineOptionsIgnoreFocus : ConfigEntry

---@class UserConfigPluginLualineOptionsComponentSeparators : ConfigEntry
---@field right string
---@field left string

---@class UserConfigPluginLualineOptionsSectionSeparators : ConfigEntry
---@field right string
---@field left string

---@class UserConfigPluginLualineOptionsRefresh : ConfigEntry
---@field statusline number
---@field tabline number
---@field winbar number

---@class UserConfigPluginLualineOptionsDisabledFiletypes : ConfigEntry
---@field statusline UserConfigPluginLualineOptionsDisabledFiletypesStatusline
---@field winbar UserConfigPluginLualineOptionsDisabledFiletypesWinbar

-- underlaying: string[]
---@class UserConfigPluginLualineSectionsLualineB : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLualineSectionsLualineC : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLualineSectionsLualineX : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLualineSectionsLualineY : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLualineSectionsLualineZ : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginLualineSectionsLualineA : ConfigEntry

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

---@class UserConfigPluginNvimTreeDiagnosticsIcons : ConfigEntry
---@field warning string
---@field hint string
---@field error string
---@field info string

---@class UserConfigPluginNvimTreeActionsOpenFile : ConfigEntry
---@field quit_on_open boolean
---@field resize_window boolean
---@field window_picker UserConfigPluginNvimTreeActionsOpenFileWindowPicker

---@class UserConfigPluginNvimTreeActionsChangeDir : ConfigEntry
---@field global boolean
---@field enable boolean

---@class UserConfigPluginNvimTreeRendererSpecialFiles : ConfigEntry
---@field README.md number
---@field Makefile number
---@field MAKEFILE number

---@class UserConfigPluginNvimTreeRendererIcons : ConfigEntry
---@field padding string
---@field show UserConfigPluginNvimTreeRendererIconsShow
---@field glyphs UserConfigPluginNvimTreeRendererIconsGlyphs

---@class UserConfigPluginNvimTreeLogTypes : ConfigEntry
---@field git boolean
---@field config boolean
---@field all boolean

-- underlaying: any[]
---@class UserConfigPluginNvimTreeUpdateFocusedFileIgnoreList : ConfigEntry

---@class UserConfigPluginNvimTreeViewMappings : ConfigEntry
---@field custom_only boolean
---@field list UserConfigPluginNvimTreeViewMappingsList

-- underlaying: any[]
---@class UserConfigPluginNvimTreeSystemOpenArgs : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginNvimTreeFiltersCustom : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterInstallCommandExtraArgsCl : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterInstallCommandExtraArgsCurl : ConfigEntry

---@class UserConfigPluginNvimTreesitterParsersNuInstallInfo : ConfigEntry
---@field files UserConfigPluginNvimTreesitterParsersNuInstallInfoFiles
---@field branch string
---@field url string

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterConfigsQueryLinterLintEvents : ConfigEntry

---@class UserConfigPluginNvimTreesitterConfigsIncrementalSelectionKeymaps : ConfigEntry
---@field node_incremental string
---@field node_decremental string
---@field scope_incremental string
---@field init_selection string

---@class UserConfigPluginNvimTreesitterConfigsPlaygroundKeybindings : ConfigEntry
---@field toggle_hl_groups string
---@field toggle_injected_languages string
---@field toggle_anonymous_nodes string
---@field toggle_language_display string
---@field focus_language string
---@field unfocus_language string
---@field goto_node string
---@field show_help string
---@field update string
---@field toggle_query_editor string

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterConfigsRainbowColors : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLualineOptionsDisabledFiletypesStatusline : ConfigEntry

-- underlaying: any[]
---@class UserConfigPluginLualineOptionsDisabledFiletypesWinbar : ConfigEntry

---@class UserConfigPluginNvimTreeActionsOpenFileWindowPicker : ConfigEntry
---@field chars string
---@field exclude UserConfigPluginNvimTreeActionsOpenFileWindowPickerExclude
---@field enable boolean

---@class UserConfigPluginNvimTreeRendererIconsShow : ConfigEntry
---@field git boolean
---@field file boolean
---@field folder boolean
---@field folder_arrow boolean

---@class UserConfigPluginNvimTreeRendererIconsGlyphs : ConfigEntry
---@field git UserConfigPluginNvimTreeRendererIconsGlyphsGit
---@field default string
---@field folder UserConfigPluginNvimTreeRendererIconsGlyphsFolder
---@field symlink string

-- underlaying: any[]
---@class UserConfigPluginNvimTreeViewMappingsList : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginNvimTreesitterParsersNuInstallInfoFiles : ConfigEntry

---@class UserConfigPluginNvimTreeActionsOpenFileWindowPickerExclude : ConfigEntry
---@field buftype UserConfigPluginNvimTreeActionsOpenFileWindowPickerExcludeBuftype
---@field filetype UserConfigPluginNvimTreeActionsOpenFileWindowPickerExcludeFiletype

---@class UserConfigPluginNvimTreeRendererIconsGlyphsGit : ConfigEntry
---@field deleted string
---@field unstaged string
---@field staged string
---@field unmerged string
---@field renamed string
---@field untracked string
---@field ignored string

---@class UserConfigPluginNvimTreeRendererIconsGlyphsFolder : ConfigEntry
---@field open string
---@field empty string
---@field symlink_open string
---@field empty_open string
---@field arrow_open string
---@field default string
---@field arrow_closed string
---@field symlink string

-- underlaying: string[]
---@class UserConfigPluginNvimTreeActionsOpenFileWindowPickerExcludeBuftype : ConfigEntry

-- underlaying: string[]
---@class UserConfigPluginNvimTreeActionsOpenFileWindowPickerExcludeFiletype : ConfigEntry
