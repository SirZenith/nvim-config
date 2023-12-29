local snip_filetype = "tex"
local s = require("snippet-loader.utils")
local makers = s.snippet_makers(snip_filetype)
local condsp = makers.condsp
-- local condpsp = makers.condpsp
local condasp = makers.condasp
local condapsp = makers.condapsp
local psp = makers.psp
local apsp = makers.apsp

local function math()
    local groups = require "nvim-treesitter-playground.hl-info".get_treesitter_hl()
    local check = false
    for _, g in ipairs(groups) do
        if g:find("TSMath", 1, true) then
            check = true
            break
        end
    end
    return check or vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

psp("init", [[
\documentclass[a4paper]{ctexart}

\usepackage{
    amsfonts,
    amsmath,
    amssymb,
    amsthm,
    geometry,
    graphicx,
}

\geometry {
    left = 2cm, right = 2cm,
    top = 2cm, bottom = 2cm,
}

% \usepackage{tikz, tikz-3dplot}
% \tdplotsetmaincoords{60}{110}

\renewcommand{\labelenumi}{(\arabic{enumi})}

% \usepackage{
%     caption,
%     subcaption,
% }
% \renewcommand{\thesubfigure}{\arabic{subfigure}}
% \newcommand\Subref[2]{\ref{#1}(\subref{#2})}

\newtheorem{theorem}{Theorem}[section]
\newtheorem{corollary}{Corollary}[theorem]
\newtheorem{lemma}[theorem]{Lemma}

\theoremstyle{definition}
\newtheorem{definition}{Definition}[section]

\title{}
\date{}
\author{}

\begin{document}

\maketitle

$0

\end{document}
]])

psp("pac", "\\usepackage{${1}}${0}")

psp("bf", "\\textbf{${1:$TM_SELECTED_TEXT}}")
psp("it", "\\textit{${1:$TM_SELECTED_TEXT}}")

condapsp(s.conds.line_begin, "chap", "\\chapter{$1}\n\n$0")
condapsp(s.conds.line_begin, "sect", "\\section{$1}\n\n$0")
condapsp(s.conds.line_begin, "ssect", "\\subsection{$1}\n\n$0")
condapsp(s.conds.line_begin, "sssect", "\\subsubsection{$1}\n\n$0")
condapsp(s.conds.line_begin, "para", "\\paragraph{$1}\n\n$0")
condapsp(s.conds.line_begin, "spara", "\\subparagraph{$1}\n\n$0")

condapsp(s.conds.line_begin, "toc", "\\tableofcontents")
condapsp(s.conds.line_begin, "lof", "\\listoffigures")
condapsp(s.conds.line_begin, "lot", "\\listoftables")

-- ----------------------------------------------------------------------------
-- Environment
apsp("begg", [[
\begin{$1}
    $0
\end{$1}
]])

condapsp(s.conds.line_begin, "tableE", [[
\begin{table}[${1:htpb}]
    \centering
    \caption{${2:caption}}
    \label{tab:${3:label}}
    \begin{tabular}{${5:c}}
    $0
    \end{tabular}
\end{table}
]])

condapsp(s.conds.line_begin, "figE", [[
\begin{figure}[${1:htpb}]
    \centering
    ${2:\includegraphics[width=0.8\textwidth]{$3}}
    \caption{${4:$3}}
    \label{fig:${5:${3}}}
\end{figure}
]])

condapsp(s.conds.line_begin, "ol", [[
\begin{enumerate}
    \item $0
\end{enumerate}
]])

condapsp(s.conds.line_begin, "ul", [[
\begin{itemize}
    \item $0
\end{itemize}
]])

condapsp(s.conds.line_begin, "descE", [[
\begin{description}
    \item[$1] $0
\end{description}
]])

condapsp(s.conds.line_begin, "aliE", [[
\begin{align*}
    ${0:$TM_SELECTED_TEXT}
.\end{align*}
]])

condapsp(s.conds.line_begin, "plotE", [[
\begin{figure}[$1]
    \centering
    \begin{tikzpicture}
        \begin{axis}[
            xmin= ${2:-10}, xmax= ${3:10},
            ymin= ${4:-10}, ymax = ${5:10},
            axis lines = middle,
        ]
            \addplot[domain=$2:$3, samples=${6:100}]{$7};
        \end{axis}
    \end{tikzpicture}
    \caption{$8}
    \label{${9:$8}}
\end{figure}
]])


condapsp(s.conds.line_begin, "caseE", [[
\begin{cases}
    $1
\end{cases}
]])

psp("nn", [[
\node[$5] (${1}${2}) ${3:at (${4:0,0}) }{\\$${1}\\$};
$0
]])

-- ----------------------------------------------------------------------------
-- General
apsp("imt", "\\$$1\\$$0")
apsp("dmt", [[
\[
    ${1:$TM_SELECTED_TEXT}
.\] $0
]])

condapsp(math, "ceil", [[\left\lceil $1 \right\rceil $0]])
condapsp(math, "floor", [[\left\lfloor $1 \right\rfloor $0]])
apsp("pmat", [[\begin{pmatrix} $1 \end{pmatrix} $0]])
apsp("bmat", [[\begin{bmatrix} $1 \end{bmatrix} $0]])
condapsp(math, "lr(", "\\left( ${1:$TM_SELECTED_TEXT} \\right$0")
condapsp(math, "lr[", "\\left[ ${1:$TM_SELECTED_TEXT} \\right$0")
condapsp(math, "lr{", "\\left{ ${1:$TM_SELECTED_TEXT} \\right$0")
condapsp(math, "lr|", "\\left| ${1:$TM_SELECTED_TEXT} \\right| $0")
condapsp(math, "lra", "\\left< ${1:$TM_SELECTED_TEXT} \\right> $0")
condapsp(math, "conj", "\\overline{$1}$0")
condapsp(math, "mcal", "\\mathcal{$1}$0")
condapsp(math, "mbb", "\\mathbb{$1}$0")
condapsp(math, "...", "\\ldots ")
condapsp(math, "**", "\\cdot ")
condapsp(math, "ooo", "\\infty")
condapsp(math, "lll", "\\ell ")
condapsp(math, "nabl", "\\nabla ")
condapsp(math, "xx", "\\times ")
condapsp(math, "norm", "\\|$1\\| $0")
local func_names = {
    "sin", "cos", "arccot", "cot", "csc",
    "ln", "log", "exp", "star", "perp",
    "arcsin", "arccos", "arctan", "arccot",
    "arccsc", "arcsec", "pi", "zeta",
}
for _, name in ipairs(func_names) do
    condapsp(math, name, "\\" .. name .. " ")
end

-- ----------------------------------------------------------------------------
-- Arrow
condapsp(math, "<->", "\\leftrightarrow ")
condapsp(math, "rarr", "\\rightarrow ")
condapsp(math, "larr", "\\leftarrow ")
condapsp(math, "uarr", "\\uparrow ")
condapsp(math, "darr", "\\downarrow ")

-- ----------------------------------------------------------------------------
-- Sets and Mapping
condapsp(math, "invs", "^{-1} ")
condapsp(math, "compl", "^{c} ")
condapsp(math, "<!", "\\triangleleft ")
condapsp(math, "<>", "\\diamond ")
condapsp(math, "->", "\\to ")
condapsp(math, "!>", "\\mapsto ")

apsp("bigfun", [[
\begin{align*}
    $1: $2 &\longrightarrow $3 \\
    $4 &\longmapsto $1($4) = $0
.\end{align*}]])

condapsp(math, [[\\\]], "\\setminus")
condapsp(math, "set", "\\{$1\\}$0")
condapsp(math, "||", "\\mid ")
condapsp(math, "cc", "\\subset ")
condapsp(math, "notin", "\\not\\in ")
condapsp(math, "inn", "\\in ")
condapsp(math, "NN", "\\cap ")
condapsp(math, "UU", "\\cup ")
condapsp(math, "uuu", "\\bigcup_{$1} $0")
condapsp(math, "nnn", "\\bigcap_{$1} $0")
apsp("letw", [[Let \\$\Omega \subset \C\\$ be open.]])

-- ----------------------------------------------------------------------------
-- Special Sets
condapsp(math, "OO", "\\varnothing ")
condapsp(math, "NN", "\\N ")
condapsp(math, "ZZ", "\\Z ")
condapsp(math, "QQ", "\\Q ")
condapsp(math, "RR", "\\R ")
condapsp(math, "CC", "\\mathbb{C} ")
condapsp(math, "HH", "\\mathbb{H} ")
condapsp(math, "DD", "\\mathbb{D} ")
condapsp(math, "R0+", "\\R_0^+ ")

-- ----------------------------------------------------------------------------
-- Logic
condapsp(math, "=>", "\\implies ")
condapsp(math, "=<", "\\impliedby ")
condapsp(math, "iff", "\\iff ")
condapsp(math, "EE", "\\exists  ")
condapsp(math, "AA", "\\forall  ")
condapsp(math, "~~", "\\sim  ")
condapsp(math, "==", "&= $1 \\")
condapsp(math, "!=", "\\neq  ")
condapsp(math, "<=", "\\leqslant ")
condapsp(math, ">=", "\\geqslant ")
condapsp(math, ">>", "\\gg ")
condapsp(math, "<<", "\\ll ")

-- ----------------------------------------------------------------------------
-- Fraction

condapsp(math, "//", "\\frac{${1:TM_SELECTED_TEXT}}{$2} $0")

condasp(
    s.conds_ext.and_(math, s.conds.line_begin),
    { trig = "(.*%))/", regTrig = true },
    {
        s.f(
            function (_, snip)
                local target = snip.captures[1]
                local st = #target
                local depth = 0
                while st > 0 do
                    local here = target:sub(st, st)
                    if here == ")" then
                        depth = depth + 1
                    elseif here == "(" then
                        depth = depth - 1
                    elseif depth == 0 then
                        break
                    end
                    st = st - 1
                end
                return string.format("\\frac{%s}", target:sub(st))
            end, {}
        ),
        s.t("{"), s.i(1), s.t("}"),
        s.t(" "),
        s.i(0)
    }
)

-- ----------------------------------------------------------------------------
-- Sub- and Supscript
condapsp(math, { trig = "__", wordTrig = false }, "_{$1} $0")
condsp(math, { trig = "(%a)(%d+)", regTrig = true }, s.f(
    function (_, snip)
        return string.format("%s_{%s}", snip.captures[1], snip.captures[2])
    end, {}
))
condapsp(math, "rij", "(${1:x}_${2:n})_{${3:$2} \\in ${4:\\N}} $0")
condapsp(math, "xnn", "x_{n}")
condapsp(math, "ynn", "y_{n}")
condapsp(math, "xii", "x_{i}")
condapsp(math, "yii", "y_{i}")
condapsp(math, "xjj", "x_{j}")
condapsp(math, "yjj", "y_{j}")
condapsp(math, "xp1", "x_{n+1}")
condapsp(math, "xmm", "x_{m}")
condapsp(math, "sr", "\\sqrt{${1:$TM_SELECTED_TEXT}} $0")
condapsp(math, { trig = "sq", wordTrig = false }, "^2")
condapsp(math, { trig = "cb", wordTrig = false }, "^3")
condapsp(math, { trig = "td", wordTrig = false }, "^{$1}$0")
condapsp(math, { trig = "rd", wordTrig = false }, "^{($1)}$0")

-- ----------------------------------------------------------------------------
-- Limit Staff
condapsp(math, "sum", "\\sum_{n = ${1:1}}^{${2:\\infty}} ${0:a_n z^n}")
condapsp(
    math, "taylor",
    "\\sum_{${1:k} = ${2:0}}^{${3:\\infty}} ${4:c_$1} (x-a)^$1 $0"
)
condapsp(math, "limnormal", "\\lim_{${1:n} \\to ${2:\\infty}} $0")
condapsp(math, "limsup", "\\limsup_{${1:n} \\to ${2:\\infty}} $0")
condapsp(
    math, "prod",
    "\\prod_{${1:n = ${2:1}}}^{${3:\\infty}} ${4:${TM_SELECTED_TEXT}} $0"
)
condapsp(math, "part", "\\frac{\\partial ${1:V}}{\\partial ${2:x}} $0")
condapsp(math, "dint", "\\int_{${1:-\\infty}}^{${2:\\infty}} ${3:${TM_SELECTED_TEXT}} $0")

-- ----------------------------------------------------------------------------
-- Others
condapsp(math, "tt", "\\text{$1} $0")
condapsp(math, "SI", "\\SI{$1}{$2} $0")
apsp("cvec", [[\begin{pmatrix} ${1:x}_${2:1}\\ \vdots\\ ${1}_${3:n} \end{pmatrix}]])
condapsp(math, "bar", "\\overline{$1} $0")
condasp(math, { trig = "(%a)bar", regTrig = true }, s.f(
        function(_, snip) return string.format(
            "\\overline{%s}", snip.captures[1]
        ) end, {}
    )
)
condapsp(math, "hat", "\\hat{$1} $0")
condasp(math, { trig = "(%a)hat", regTrig = true }, s.f(
        function(_, snip) return string.format(
            "\\hat{%s}", snip.captures[1]
        ) end, {}
    )
)

-- ----------------------------------------------------------------------------
-- Greek Letters
condapsp(math, ";a", "\\alpha")
condapsp(math, ";A", "\\Alpha")
condapsp(math, ";b", "\\beta")
condapsp(math, ";B", "\\Beta")
condapsp(math, ";g", "\\gamma")
condapsp(math, ";G", "\\Gamma")
condapsp(math, ";d", "\\delta")
condapsp(math, ";D", "\\Delta")
condapsp(math, ";e", "\\epsilon")
condapsp(math, ";E", "\\Epsilon")
condapsp(math, ";z", "\\zeta")
condapsp(math, ";Z", "\\Zeta")
condapsp(math, ";h", "\\eta")
condapsp(math, ";H", "\\Eta")
condapsp(math, ";j", "\\theta")
condapsp(math, ";J", "\\Theta")
condapsp(math, ";i", "\\iota")
condapsp(math, ";I", "\\Iota")
condapsp(math, ";k", "\\kappa")
condapsp(math, ";K", "\\Kappa")
condapsp(math, ";l", "\\lambda")
condapsp(math, ";L", "\\Lambda")
condapsp(math, ";m", "\\mu")
condapsp(math, ";M", "\\Mu")
condapsp(math, ";n", "\\nu")
condapsp(math, ";N", "\\Nu")
condapsp(math, ";c", "\\xi")
condapsp(math, ";C", "\\Xi")
condapsp(math, ";o", "\\omicron")
condapsp(math, ";O", "\\Omicron")
condapsp(math, ";p", "\\pi")
condapsp(math, ";P", "\\Pi")
condapsp(math, ";r", "\\rho")
condapsp(math, ";R", "\\Rho")
condapsp(math, ";s", "\\sigma")
condapsp(math, ";S", "\\Sigma")
condapsp(math, ";t", "\\tau")
condapsp(math, ";T", "\\Tau")
condapsp(math, ";y", "\\upsilon")
condapsp(math, ";Y", "\\Upsilon")
condapsp(math, ";f", "\\phi")
condapsp(math, ";F", "\\Phi")
condapsp(math, ";x", "\\chi")
condapsp(math, ";X", "\\Chi")
condapsp(math, ";q", "\\psi")
condapsp(math, ";Q", "\\Psi")
condapsp(math, ";w", "\\omega")
condapsp(math, ";W", "\\Omega")
