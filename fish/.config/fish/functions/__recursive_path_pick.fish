function __recursive_path_pick --description "Recursive file finder"
    # this picker depends on `fd` for recursive file discovery and `fzf`
    # for the interactive selector
    #
    # if either command is missing, warn and stop here
    if not command -q fd
        printf "recursive path picker requires `fd`\n" >&2
        return
    end

    if not command -q fzf
        printf "recursive path picker requires `fzf`\n" >&2
        return
    end

    # get the base command
    #
    # example: if the command line is `nvim file.c` and the cursor is at the
    # end, this becomes `nvim`
    #
    # we use this to avoid running on the command name itself
    set -l previous_tokens (commandline -xpc)

    # get the token under the cursor
    #
    # example: if the command line is `nvim file.c`, this becomes `file.c`
    set -l token (commandline -ct)

    # if there is no previous token, then the cursor is still on the command
    # name, so this binding should not try to replace it with a file path
    if test (count $previous_tokens) -eq 0
        commandline -f complete
        return
    end

    # if there is no current token, fall back to normal fish completion
    if test -z "$token"
        commandline -f complete
        return
    end

    # if the token starts with a dash, it is probably an option like `-h`
    # or `--help`, so let fish handle it normally
    if string match -qr -- '^-' $token
        commandline -f complete
        return
    end

    # if the user already typed a slash, they are already completing a path
    # directly, so let fish handle it normally
    if string match -q -- '*/*' $token
        commandline -f complete
        return
    end

    # collect recursive matches under the current directory
    #
    # `fd --glob "$token*"` does the recursive basename-prefix match directly,
    # so with a token like `some.c` it will return paths such as:
    #   some.c
    #   a/b/some.c
    #   a/c/some.c
    #
    # `--strip-cwd-prefix=always` removes the leading `./` from the results
    set -l matches (
        fd --hidden --exclude .git --type f --strip-cwd-prefix=always --glob "*$token*"
    )

    # if nothing matched, fall back to normal fish completion
    if test (count $matches) -eq 0
        commandline -f complete
        return
    end

    # pass the matches into fzf
    #
    # `--select-1` means:
    # if there is exactly one match, choose it automatically
    #
    # `--exit-0` means:
    # return success even if there was only one match and no interactive
    # selection step was needed
    set -l picked (
        printf '%s\n' $matches |
        fzf --select-1 --exit-0 --prompt="path> "
    )

    # if you selected something, replace the current token with that path
    if test -n "$picked"
        commandline --current-token --replace -- (string escape -- $picked)
    end

    commandline -f repaint
end
