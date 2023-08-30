local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s({trig="ff", dscr="Expands 'ff' into '\frac{}{}'"},
        fmt(
            "\\frac{<>}{<>}",
            {
                i(1),
                i(2)
            },
            {delimiters = "<>"}
        )
    ),
    s({trig="vspan", dscr="Expands 'vspan' into '\vspan\\left\\{\\right\\}'"},
        fmt(
            "\\vspan\\left\\{<>\\right\\}",
            {
                i(1),
            },
            {delimiters = "<>"}
        )
    ),
    s({trig="norma", dscr="Expands 'norma' into '\\lVert \\rVert'"},
        fmt(
            "\\lVert <>\\rVert",
            {
                i(1)
            },
            {delimiters = "<>"}
        )
    ),
    s({trig="det", dscr="Expands 'det' into '\\text{det}'"},
        t {"\\text{det}"}
    ),
    s({trig="im", dscr="Expands 'im' into '\\text{Im}()'"},
        fmt(
            "\\text{Im}(<>)",
            {
                i(1)
            },
            {delimiters = "<>"}
        )
    ),
    s({trig="ker", dscr="Expands 'ker' into '\\text{Ker}()'"},
        fmt(
            "\\text{Ker}(<>)",
            {
                i(1)
            },
            {delimiters = "<>"}
        )
    ),
    s({trig="cal", dscr="Expands 'cal' into '\\mathcal{}'"},
        fmt(
            "\\mathcal{<>}",
            {
                i(1)
            },
            {delimiters = "<>"}
        )
    ),
    s({trig="bb", dscr="Expands 'bb' into '\\mathbb{}'"},
        fmt(
            "\\mathbb{<>}",
            {
                i(1)
            },
            {delimiters = "<>"}
        )
    ),
    s({trig="id", dscr="Expands 'id' into '\\text{id}_{}'"},
        fmt(
            "\\text{id}_{<>}",
            {
                i(1)
            },
            {delimiters = "<>"}
        )
    ),
    s({trig="cimg", dscr="Inserts a centered image"},
        fmt(
            "\\begin{center}\n" ..
            "    \\includegraphics[width=<>cm]{<>}\n" ..
            "\\end{center}",
            {
                i(1),
                i(2),
            },
            {delimiters = "<>"}
        )
    ),
    s({trig="abs", dscr="Expands 'abs' into '\\left\\lvert \\right\\rvert'"},
        fmt(
            "\\left\\lvert <>\\right\\rvert",
            {
                i(1)
            },
            {delimiters = "<>"}
        )
    ),
    s({trig="ti", dscr="Expands 'ti' into '\\tilde{}'"},
        fmt(
            "\\tilde{<>}",
            {
                i(1)
            },
            {delimiters = "<>"}
        )
    ),
    s({trig="st", dscr="Expands 'st' into '\\big|_{}^{}'"},
        fmt(
            "\\big|_{<>}^{<>}",
            {
                i(1),
                i(2)
            },
            {delimiters = "<>"}
        )
    ),
}
