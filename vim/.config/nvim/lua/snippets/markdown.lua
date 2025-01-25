return {
    s(
        'paper',
        fmt('- ["{}" ({} et al. - {})]({}) - {}', {
            i(1, 'Paper title'),
            i(2, "Author's last name"),
            i(3, 'Date published'),
            i(4, 'URL'),
            i(0, 'Description'),
        })
    ),
}
