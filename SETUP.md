New machine setup (data not tracked in git)
---

These files contain local state that should be copied from a previous machine
or recreated manually. They are NOT managed by stow / git.

- atuin history db: ~/.local/share/atuin/history.db
  (or import fish history: `atuin import fish`)
- fish history: ~/.local/share/fish/fish_history
  (fish still writes to this even with atuin enabled)
- zoxide db: ~/.local/share/zoxide/db.zo

npm
---

Set the global prefix so packages install under the user's home:

    npm config set prefix ~/.npm-global

ACP servers
---

- claude-agent-acp: `npm install -g @agentclientprotocol/claude-agent-acp`
- codex-acp: download binary from the codex-acp repo's releases page
