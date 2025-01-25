return {
    s('lreq', fmt("local {} = require('{}')", { i(1), i(0) })),
    s('f', fmt('function({})\n\t{}\nend', { i(1), i(0) })),
}
