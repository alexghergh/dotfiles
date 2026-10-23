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

### Fonts

The `fonts` Stow package only carries the custom icon font and the fontconfig
setup. Install everything else from where it is packaged (e.g. on Fedora):

    sudo dnf install rsms-inter-vf-fonts adwaita-sans-fonts \
      cascadia-fonts-all fira-code-fonts jetbrains-mono-fonts-all \
      adobe-source-code-pro-fonts source-foundry-hack-fonts powerline-fonts \
      google-noto-fonts-all google-roboto-fonts google-roboto-condensed-fonts

Inter is the KDE system font (matches Apples' font; set it in System Settings);
Adwaita Sans is the Thunderbird UI font; the monospace fonts are the WezTerm
fallback chain for code.

Other fonts without a package go in `/usr/local/share/fonts/<first letter>/`.
Some of them may not be redistributable, so they stay out of this repo. Download
them manually or copy from the previous machine:

- Nerd Fonts from https://github.com/ryanoasis/nerd-fonts/releases:
  `NerdFontsSymbolsOnly`, `JetBrainsMono`, `FiraCode`, `Hack`, `AnonymousPro`,
  `ProFont`
- Klee One and Zen Maru Gothic from https://fonts.google.com
- SF Mono from https://developer.apple.com/fonts (Apple license, no
  redistribution)
- Meiryo and Klingon pIqaD HaSta: copy from the previous machine

Then rebuild the font cache:

    fc-cache -f

### Anki

Install the official Linux ARM64 bundle from https://apps.ankiweb.net/ under
`~/packages/anki-<version>/anki-linux`. Do not use the old Python virtual
environment.

Anki data, including profiles, media, add-ons, and preferences, lives in
`~/.local/share/Anki2`. Copy it from the previous machine or restore it from a
backup.

After installing a new Anki version, update the `Exec`, `TryExec`, and `Icon`
paths in `desktop/.local/share/applications/anki.desktop` to point at the new
bundle.

### Local LLMs

Keep downloaded models in `~/packages/llms` as a Btrfs subvolume to exclude them
from home snapshots. The `llms` Stow package links only
`llama-server-models.ini` into that directory; the installer disables directory
folding for this package. Edit the linked preset beside the models to update the
tracked copy in dotfiles. `lmgo` reads `$PACKAGES/llms/llama-server-models.ini`.

On a new machine, create the model subvolume before stowing the preset:

    mkdir -p ~/packages
    btrfs subvolume create ~/packages/llms
    STOW_FOLDERS=llms sh install

### npm

Set the global prefix so packages install under the user's home:

    npm config set prefix ~/.npm-global

### AI code agents + ACP servers

Agents:
- claude code: follow the [instructions](https://code.claude.com/docs/en/setup)
- codex: follow the [instructions](developers.openai.com/codex/cli), basically
just `npm install -g @openai/codex`

ACP servers:
- claude-agent-acp: `npm install -g @agentclientprotocol/claude-agent-acp`
- codex-acp: `npm install -g @agentclientprotocol/codex-acp`
