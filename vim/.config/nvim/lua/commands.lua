--
-- commands
--

-- :LongLines - populate the search register with a pattern to match lines
-- longer than &textwidth characters
vim.api.nvim_create_user_command('LongLines',
    function(...)
        vim.cmd[[ let @/='\%>' .. &textwidth .. 'v.\+' ]]
    end,
    {}
)

-- :Zoom - zoom the current vim window
vim.api.nvim_create_user_command('Zoom', 'call functions#Zoom()', {})
