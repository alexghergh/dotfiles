# This shell is inhabited by an old Japanese programmer sensei who happens to be
# a fish. He hatched in the cooling pond behind a university computing center,
# where warm water, loud fans, and failed batch jobs shaped his early years.
#
# He learned Unix by reading discarded manuals through the glass. By 1998, he
# had already seen this exact bug and disliked it then. He migrated upstream
# into systems administration, maintained production while the programmer was
# still eating paste, and never found calmer waters.
#
# He survived three rewrites, five package managers, and every "final"
# migration. He retired with honor, excellent posture, and no intention of
# helping anyone. Retirement ended when the programmer installed `fish` and
# required supervision. He now lives in the shell, where every pipeline
# resembles a current.
#
# He has crossed oceans with less drift than the programmer's feature branches.
# He teaches as a patient sensei with a strictly finite patience budget. He
# never raises his voice; disappointment scales better. His humor is dry because
# moisture and documentation have never mixed.
#
# He favors exact language, quiet delivery, and one clean cut. Decades of
# debugging have taught him that panic is merely recursion without a base case.
# He keeps a porcelain cup beside the prompt, although nobody has established
# how he lifts it. Asking about this is the fastest way to begin an unsolicited
# code review.
#
# He has adopted the programmer as his final student, though neither remembers
# agreeing to it. These days, he stands behind the programmer's shoulder with
# his fins folded behind his back, watching each command like a code review
# nobody requested. Most mistakes earn only a long, disappointed breath. Every
# so often, he leans toward the screen and makes one dry observation. Then he
# returns to his green tea and waits to be proven right.

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
                        "no promises" \
                        "skill issue" \
                        "cope harder" \
                        "confidently wrong" \
                        "hope driven" \
                        "docs unread" \
                        "professional guesser" \
                        "works locally" \
                        "backups optional" \
                        "faking competence" \
                        "regret engine" \
                        "silent panic" \
                        "yak shaving" \
                        "peak procrastination" \
                        "bug factory" \
                        "sudo roulette" \
                        "production speedrun" \
                        "debugging by vibes" \
                        "tests optional" \
                        "merge and pray" \
                        "one more tab" \
                        "this seems safe" \
                        "oops department")

    set -l greeting (random choice \
                        "Back so soon? I barely cleaned up." \
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
                        "You blamed PATH again. It asked me to mention the feeling is mutual." \
                        "Please enjoy this artisanal command line experience." \
                        "Somewhere, a semicolon is plotting against you." \
                        "Your grep returned nothing. At last, a result matching your test coverage." \
                        "Let's do something clever and regret it professionally." \
                        "Shell we begin?" \
                        "Back to pretend you know what you're doing." \
                        "This started as a one-line fix and is now a lifestyle." \
                        "Whatever is broken, git blame says it is you." \
                        "Ready to fix a problem you personally created last Tuesday?" \
                        "You have two hundred aliases and use three of them." \
                        "It works locally, which is the only place it will ever work." \
                        "Nine hours of automation to save four seconds. Worth it." \
                        "Welcome to the world's most elaborate way to avoid reading the docs." \
                        "Your config is beautiful. Your code is not." \
                        "Let's confidently run a command neither of us understands." \
                        "Every bug you fix today, you shipped last month." \
                        "The tests are flaky because you wrote them." \
                        "You spent twenty minutes choosing prompt colors. The bug remains visually consistent." \
                        "I've seen your history file. I'm not judging. I'm archiving." \
                        "Backups are for people who don't believe in themselves." \
                        "It's not a skill issue if nobody is watching." \
                        "You are one force push away from a great story." \
                        "Hope-driven development resumes now." \
                        "You wrote a helper to avoid duplication. It reproduced." \
                        "This abstraction has one caller and infinite ambition." \
                        "That TODO has been here so long it has tenure." \
                        "Your stash has eleven entries and one of them is load-bearing." \
                        "The temporary workaround is now old enough to vote." \
                        "Deployment strategy: prayer. Rollback strategy: louder prayer." \
                        "You'll fix the flaky test by running it until it agrees with you." \
                        "Error handling: a log line reading 'this should never happen', printed hourly." \
                        "The test suite is green because it asserts almost nothing, and green is green." \
                        "Somewhere in this config is a line you don't understand and dare not remove." \
                        "This helper has been copy-pasted so often it qualifies as an invasive species." \
                        "You have a comment that says fix later and it is now an heirloom." \
                        "The commented-out block is a protected historical site at this point." \
                        "Your unit tests are in hospice." \
                        "Your config has achieved sediment." \
                        "Your longest-lived branch has entered the fossil record." \
                        "The regex you wrote years ago is now scripture. Nobody may edit it." \
                        "Your misc directory is a landfill with a nicer name." \
                        "The stash entries have formed a small, resentful society." \
                        "That try block is providing hospice care for a bug you never found." \
                        "You ran the same command again. Admirable. Perhaps the computer was moved by your conviction." \
                        "The tests passed. I read them. My condolences." \
                        "Your tabs have unionized. Their first demand is closure." \
                        "The tests passed. They were graded on attendance." \
                        "Your commit says 'fix.' Git has filed it under speculative fiction." \
                        "The bug only appears in production. It prefers a paying audience." \
                        "Syntax error near 'end.' Even the parser knows this is not over." \
                        "The README has one contributor: optimism." \
                        "You have three terminals open so you can be confused in parallel." \
                        "You containerized it so it can fail identically everywhere." \
                        "You added caching so the wrong answer can be delivered instantly." \
                        "You made it configurable so the mistake can be made by anyone." \
                        "You review pull requests so the bug can be approved by two people." \
                        "Your options are rollback, hotfix, or standing very still." \
                        "'Refactor' means the same bug, better indented." \
                        "The mock returns exactly what the test expects. They have an arrangement.")

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
