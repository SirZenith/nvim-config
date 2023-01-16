local user = require "user"

user.g = {
    tex_flavor = "latex",
    vimtex_view_general_viewer = "SumatraPDF",
    -- vimtex_view_general_options = "--unique file:@pdf#src:@line@tex",
    -- vimtex_view_general_options_latexmk = "--unique",

    vimtex_quickfix_mode = 0,
    -- for syntax use nvim-treesitter instead
    vimtex_syntax_enabled = 0,
    -- vim.g.vimtex_syntax_conceal_disable = 1

    -- set command line argument for each engine, where _ is default engine.
    vimtex_compiler_latexmk_engines = {
        _                    = "-xelatex",
        pdflatex             = "-pdf",
        dvipdfex             = "-pdfdvi",
        lualatex             = "-lualatex",
        xelatex              = "-xelatex",
        ["context (pdftex)"] = "-pdf -pdflatex=texexec",
        ["context (luatex)"] = "-pdf -pdflatex=context",
        ["context (xetex)"]  = '-pdf -pdflatex="texexec --xtx"',
    },
}
