## New machine setup (data not tracked in git)

These files / dirs contain local state that should be copied from a previous
machine or recreated manually. They should **NOT** be managed by stow / git.

### Shells

- fish history: `~/.local/share/fish/fish_history`
- zoxide db: `~/.local/share/zoxide/db.zo`

### SSH and GPG keys

Copy SSH and GPG state from the old machine:

    tar -czf ~/ssh-gpg.tgz -C ~ .ssh .gnupg

Restore it on the new machine:

    tar -xzf ~/ssh-gpg.tgz -C ~
    chmod 700 ~/.ssh ~/.gnupg
    find ~/.ssh -type f -name '*.pub' -exec chmod 644 {} +
    find ~/.ssh -type f ! -name '*.pub' -exec chmod 600 {} +
    find ~/.gnupg -type d -exec chmod 700 {} +
    find ~/.gnupg -type f -exec chmod 600 {} +
    gpgconf --kill all

Check that SSH and GPG can see the restored keys:

    ssh-add -l
    gpg --list-secret-keys --keyid-format=long

If GPG keys are hardware-backed, copy `~/.gnupg` for config, trust, and key
stubs, then pair the same hardware key on the new machine.

### NetworkManager profiles

NetworkManager profiles are stored as keyfiles in
`/etc/NetworkManager/system-connections/*.nmconnection`. Copy them from the old
machine:

    sudo tar -C /etc/NetworkManager -czf ~/nm-connections.tgz system-connections

Restore them on the new machine:

    sudo tar -C /etc/NetworkManager -xzf ~/nm-connections.tgz
    sudo chown root:root /etc/NetworkManager/system-connections/*.nmconnection
    sudo chmod 600 /etc/NetworkManager/system-connections/*.nmconnection
    sudo restorecon -Rv /etc/NetworkManager/system-connections
    sudo nmcli connection reload

### KDE Wallet

KDE Wallet data lives in `~/.local/share/kwalletd`. Copy the wallet data and
config from the old machine:

    tar -czf ~/kwallet.tgz -C ~ \
      .local/share/kwalletd \
      .config/kwalletrc \
      .config/kwalletmanagerrc

Restore them on the new machine:

    tar -xzf ~/kwallet.tgz -C ~
    chmod 700 ~/.local/share/kwalletd
    chmod 600 ~/.local/share/kwalletd/* ~/.config/kwalletrc ~/.config/kwalletmanagerrc

## npm

Set the global prefix so packages install under the user's home:

    npm config set prefix ~/.npm-global

## AI code agents + ACP servers

Agents:
- claude code: follow the [instructions](https://code.claude.com/docs/en/setup)
- codex: follow the [instructions](developers.openai.com/codex/cli), basically
just `npm install -g @openai/codex`

ACP servers:
- claude-agent-acp: `npm install -g @agentclientprotocol/claude-agent-acp`
- codex-acp: `npm install -g @agentclientprotocol/codex-acp`
