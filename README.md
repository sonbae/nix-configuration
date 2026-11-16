# nix-configuration

Nix config for installing the same apps and settings on all my devices. It uses [home-manager](https://github.com/nix-community/home-manager) to install packages and manage dotfiles.

| Tool | Config file | Defined in |
| --- | --- | --- |
| [`cloudflared`](https://github.com/cloudflare/cloudflared) | `~/.cloudflared/config.yml` | `home/cloudflared.nix` |
| `tmux` | `~/.config/tmux/tmux.conf` | `home/tmux.nix` |
| `vim` | built into the `vim` wrapper (no `~/.vimrc`) | `home/vim.nix` |

The tmux and vim configs are ported from [sonbae/dotfiles](https://github.com/sonbae/dotfiles).

Supported platforms: `aarch64-darwin` (Apple Silicon), `x86_64-linux`, `aarch64-linux`. Intel Macs are not supported because nixpkgs 26.11 dropped x86_64-darwin.

## Layout

```
flake.nix           inputs (nixpkgs, home-manager) and one entry per device
flake.lock          pinned versions; commit it so every device matches
home/default.nix    shared config, imports the files below
home/cloudflared.nix
home/tmux.nix
home/vim.nix
```

## Prerequisites

Install Nix with flakes enabled. The [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) turns flakes on by default:

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

If you installed Nix some other way, enable flakes by adding this line to `~/.config/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

Open a new terminal afterwards so `nix` is on your `PATH`.

## Set up a device

1. Clone the repo:

   ```sh
   git clone <this-repo-url> ~/projects/nix-configuration
   cd ~/projects/nix-configuration
   ```

2. If this device isn't listed in `homeConfigurations` in `flake.nix`, add it. The name must be `<user>@<hostname>`, using the output of `whoami` and `hostname -s`:

   ```nix
   homeConfigurations = {
     "sonbae@corona" = mkHome { system = "aarch64-darwin"; username = "sonbae"; };
     "sonbae@my-linux-box" = mkHome { system = "x86_64-linux"; username = "sonbae"; };
   };
   ```

   Then `git add flake.nix`. Nix flakes only see files tracked by git.

3. Apply the config. The first run uses the home-manager version pinned in `flake.lock`, so you don't need to install it first:

   ```sh
   nix run .#home-manager -- switch --flake .
   ```

   If a file it wants to manage already exists, such as an old `~/.vimrc` or `tmux.conf`, the switch stops and nothing gets overwritten. Add `-b backup` to rename the existing files to `*.backup` and continue.

4. Check it worked:

   ```sh
   cloudflared --version
   tmux -V
   vim --version | head -1
   ```

After the first switch, `home-manager` itself is on your `PATH`.

## Making changes

Edit the files under `home/`, then apply:

```sh
home-manager switch --flake .
```

home-manager symlinks the generated files into the Nix store, so they're read-only. Edit the `.nix` files instead of the config files themselves.

To add a package with no config, add it to `home.packages` in `home/default.nix`:

```nix
home.packages = with pkgs; [ jq ripgrep ];
```

Look up package names at [search.nixos.org](https://search.nixos.org/packages) or with `nix search nixpkgs <name>`. For a tool's built-in options (e.g. `programs.git`), see the [home-manager options reference](https://home-manager-options.extranix.com/).

## Updating

Bump nixpkgs and home-manager to their latest versions and apply:

```sh
nix flake update
home-manager switch --flake .
```

Commit `flake.lock` afterwards. On other devices, `git pull` and then run `home-manager switch --flake .` to get the same versions.

Leave `home.stateVersion` in `home/default.nix` alone when updating. It records the release this config was first set up with, not the current one.

## Rolling back

```sh
home-manager generations              # list previous generations
/nix/store/<hash>-home-manager-generation/activate   # switch back to one
```

## cloudflared notes

The repo only manages `~/.cloudflared/config.yml`. Credentials never go in the repo:

- `cloudflared tunnel login` writes `~/.cloudflared/cert.pem`
- `cloudflared tunnel create <name>` writes `~/.cloudflared/<tunnel-id>.json`

Both stay as regular files on each device. To run a named tunnel, fill in the commented `tunnel`, `credentials-file` and `ingress` lines in `home/cloudflared.nix`.

The config sets `no-autoupdate: true` because Nix manages the binary, so cloudflared shouldn't replace itself.

## tmux notes

- Prefix is `` ` `` (backtick) instead of `C-b`. Press it twice to type a literal backtick.
- `` ` - `` and `` ` | `` split panes in the current directory. `Alt-h/j/k/l` moves between panes and `Alt-Shift-h/j/k/l` resizes them.
- The status bar shows the load average. The original config read `/proc/loadavg`, which only exists on Linux, so on macOS it reads `sysctl vm.loadavg` instead.

## vim notes

- `m` toggles highlighting of tabs and trailing spaces, using the [spacehi](https://github.com/vim-scripts/spacehi.vim) plugin. It isn't in nixpkgs, so `home/vim.nix` builds it from a pinned commit.
- Indentation uses real tabs, 4 wide. Arrow keys are disabled, `Ctrl-h/j/k/l` moves between splits, `Enter` clears search highlighting, and `:w!!` saves a file with sudo.

home-manager passes the vim config to a wrapper script (`vim -u <generated vimrc>`) instead of writing `~/.vimrc`. That means `/usr/bin/vim` (the macOS system vim) won't pick up these settings. Run `which vim` to check you get `~/.nix-profile/bin/vim`.

## Uninstall

```sh
home-manager uninstall
```

This removes the managed packages and config files. Nix itself stays installed.
