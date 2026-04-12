function fish_greeting
    set -l normal (set_color normal)
    set -l logo_color $fish_color_command
    set -l banner_color $fish_color_keyword
    set -l greeting_color $fish_color_quote
    set -l status_color $fish_color_comment
    set -l meta_color $fish_color_comment
    set -l time_color $fish_color_param

    set -l banner_greeting (random choice \
                        "hello trouble" \
                        "shell time" \
                        "goblin mode" \
                        "alias chaos" \
                        "code fish" \
                        "bad ideas" \
                        "caffeine mode" \
                        "blame path" \
                        "restless fish" \
                        "local chaos" \
                        "side quest" \
                        "pipe dreams" \
                        "tiny changes" \
                        "careful now" \
                        "ship it" \
                        "moral hazard" \
                        "grep swiftly" \
                        "calm mostly" \
                        "loop season" \
                        "debug dance" \
                        "oops engine" \
                        "git roulette" \
                        "shell goblin" \
                        "mostly harmless" \
                        "good luck" \
                        "chaos mode" \
                        "bug buffet" \
                        "late commits" \
                        "no promises")

    set -l greeting (random choice \
                        "Hello trouble!" \
                        "What's cooking today?" \
                        "'aven't seen you here in a while, eh?" \
                        "こんにちは!" \
                        "Fighting!" \
                        "Back so soon? I barely cleaned up." \
                        "Welcome back, keyboard goblin." \
                        "Ready to break production locally?" \
                        "Another beautiful day to alias something irresponsible." \
                        "The shell has been gossiping about you." \
                        "All systems nominal. Morals uncertain." \
                        "You bring the commands. I'll bring the consequences." \
                        "The prompt believes in you. I do not." \
                        "Time to turn caffeine into side effects." \
                        "Let's commit something we'll defend later." \
                        "Good evening to you and your thirty-seven tabs." \
                        "The terminal yearns for vaguely destructive input." \
                        "Today's forecast: mostly loops with a chance of pipes." \
                        "You type. I judge silently." \
                        "Welcome aboard, captain of avoidable complexity." \
                        "Let's make a tiny change and somehow touch six files." \
                        "If this works first try, remain calm." \
                        "Another session, another opportunity to blame PATH." \
                        "The fish are restless today." \
                        "Please enjoy this artisanal command line experience." \
                        "Somewhere, a semicolon is plotting against you." \
                        "May your grep be swift and your logs be short." \
                        "Let's do something clever and regret it professionally." \
                        "Shell we begin?")

    set -l is_login (status is-login
                        and echo "login"
                        or echo "non-login")

    set -l is_interactive (status is-interactive
                        and echo "interactive"
                        or echo "non-interactive")

    set -l now (date +%X)

    # if toilet exists, print the banner
    if command -sq toilet
        set -l banner_width 120
        set -q COLUMNS; and set banner_width $COLUMNS

        set -l banner (printf '%s\n' $banner_greeting | toilet -w $banner_width 2>/dev/null)

        if string match -rq '\S' -- $banner
            for line in (string split \n -- $banner)
                set -l trimmed_line (string trim -- $line)

                if test -n "$trimmed_line"
                    echo -s (set_color $banner_color) $line $normal
                end
            end

            echo
        end
    end

    # print the regular greeting + the other elements
    echo -s \
        (set_color $logo_color) "><(((('> " \
        (set_color $greeting_color) $greeting " " \
        (set_color $meta_color) "(" \
        (set_color --dim $status_color) $is_login " " $is_interactive \
        (set_color $meta_color) ") - " \
        (set_color $time_color) $now \
        $normal
end
