; extends

; the stock bash injections (nvim-treesitter runtime/queries/bash/injections.scm)
; cover heredoc bodies (the delimiter names the language, e.g. <<'PYTHON') but
; have no rule for interpreter -c string arguments, so `python -c '...'` renders
; plain; the patterns below inject python there; two separate patterns because
; #offset! must trim the surrounding quotes only for raw_string captures
; (string_content already excludes them)
;
; these are captured so commands rendered in markdown filetypes (mainly
; codecompanion) highlight correctly inside backtick guards

; python -c '...'; the raw_string capture includes the quotes, trimmed via offset
((command
  name: (command_name) @_cmd
  argument: (word) @_flag
  .
  argument: (raw_string) @injection.content)
  (#any-of? @_cmd "python" "python3")
  (#eq? @_flag "-c")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "python"))

; python -c "..."
((command
  name: (command_name) @_cmd
  argument: (word) @_flag
  .
  argument: (string (string_content) @injection.content))
  (#any-of? @_cmd "python" "python3")
  (#eq? @_flag "-c")
  (#set! injection.language "python"))
