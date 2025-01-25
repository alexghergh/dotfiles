return {
    s(
        'jit',
        fmt('@triton.jit\ndef {}_kernel({}):\n\t{}', {
            i(1, 'func'),
            c(2, {
                i(nil, {
                    '',
                    '\tinput_ptr,',
                    '\toutput_ptr,',
                    '\tn_elements,',
                    '\tBLOCK_SIZE: tl.constexpr,',
                    '',
                }),
                t(''),
            }),
            i(0),
        })
    ),
    s(
        'ifel',
        fmt('if {}:\n\t{}', {
            i(1, 'True'),
            c(2, {
                r(1, 'if_text'),
                fmt('{}\nelif {}:\n\t{}', {
                    r(1, 'if_text'),
                    r(2, 'elif1_cond'),
                    r(3, 'elif1_text'),
                }),
                fmt('{}\nelif {}:\n\t{}\nelse:\n\t{}', {
                    r(1, 'if_text'),
                    r(2, 'elif1_cond'),
                    r(3, 'elif1_text'),
                    r(4, 'elif2_cond'),
                }),
                fmt('{}\nelif {}:\n\t{}\nelif {}:\n\t{}', {
                    r(1, 'if_text'),
                    r(2, 'elif1_cond'),
                    r(3, 'elif1_text'),
                    r(4, 'elif2_cond'),
                    r(5, 'elif2_text'),
                }),
                fmt('{}\nelif {}:\n\t{}\nelif {}:\n\t{}\nelse:\n\t{}', {
                    r(1, 'if_text'),
                    r(2, 'elif1_cond'),
                    r(3, 'elif1_text'),
                    r(4, 'elif2_cond'),
                    r(5, 'elif2_text'),
                    i(6, 'pass'),
                }),
            }),
        }),
        {
            stored = {
                ['if_text'] = i(1, 'pass'),
                ['elif1_cond'] = i(2, 'True'),
                ['elif1_text'] = i(3, 'pass'),
                ['elif2_cond'] = i(4, 'True'),
                ['elif2_text'] = i(4, 'pass'),
            },
        }
    ),
}
