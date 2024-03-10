function fish_greeting
    # TODO colors for these too
    # TODO maybe a nice logo?
    set -l greeting (random choice \
                        "Hello trouble!" \
                        "What's cooking today?" \
                        "'aven't seen you here in a while, eh?" \
                        "こんにちは, motherfucker!")

    set -l is_login (status is-login
                        and echo "login"
                        or echo "non-login")

    set -l is_interactive (status is-interactive
                        and echo "interactive"
                        or echo "non-interactive")

    echo -s "$greeting ($is_login $is_interactive) - $(date +%X)"
end
