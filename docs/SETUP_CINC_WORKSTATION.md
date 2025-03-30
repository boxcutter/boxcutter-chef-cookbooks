# Cinc Workstation

## Linux Install

Use the installation script provided by Cinc. The script detects your
OS version and downloads the appropriate package.

```
curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -P cinc-workstation
```

Verify the installation:

```
cinc --version
```

Should list the versions of all the Cinc-related tools:

```
Cinc Workstation version: 25.2.1075
Cookstyle version: 7.32.8
Cinc Client version: 18.6.2
Cinc Auditor version: 5.22.65
Cinc CLI version: 5.6.16
Biome version: 1.6.821
Test Kitchen version: 3.6.0
```

### Configure the Ruby environment (simple)

Configure the Ruby environment Cinc uses by adding the following
commands to the configuration file for bash (`~/.bashrc`):

```
# Add the Cinc Workstation initialization content
echo 'eval "$(cinc shell-init bash)"' >> ~/.bashrc
```

Reload the config in the current shell with `source ~/.bashrc` or
restart the current terminal.

Verify that the Ruby interpreter being used is the cin-workstation
ruby instead of the system ruby:

```
% which ruby
/opt/cinc-workstation/embedded/bin/ruby
```

### Configure the Ruby environment (advanced)

```
mkdir -m 0755 ~/.bashrc.d
```

```
# User specific aliases and functions
if [[ -d ~/.bashrc.d ]]; then
  for rc in ~/.bashrc.d/*; do
    if [[ -f "$rc" ]]; then
      source "$rc"
    fi
  done
fi

unset rc
```

```
cat <<'EOF' > ~/.bashrc.d/100.cinc-workstation.sh
#!/bin/bash

eval "$(cinc shell-init bash)"
EOF
```

## macOS Install

Download the latest version of the Cinc Workstation package from
https://downloads.cinc.sh/files/stable/cinc-workstation/ for your version
of macOS and CPU architecture.

Mount the DMG file and double-click the PKG file to start the install.
The operation will warn you that it cannot verify the package. Click
on the Done button. Then go to "System Settings > Privacy & Security".
Scroll all the way down to view the "Security" section. You'll see
that it says that the package was block to protect your Mac. Clcik on
the "Open Anyway" button to run the install.

The bulk of the Cinc Workstation install is in `/opt/cinc-workstation`,
with a few copies of the main program binaries in `/usr/local/bin` to
be in the default `PATH`.

### Configure the Ruby environment (simple)

Configure the Ruby environment Cinc uses by adding the following
commands to the configuration file for Z Shell (`~/.zshrc`):

```
# Load the zsh completion system - required to configure autocomplete
echo 'autoload -Uz compinit' >> ~/.zshrc
echo 'compinit' >> ~/.zshrc
# Add the Cinc Workstation initialization content
echo 'eval "$(cinc shell-init zsh)"' >> ~/.zshrc
```

Reload the config in the current shell with `source ~/.zshrc` or
restart the current terminal.

Verify that the Ruby interpreter being used is the cin-workstation
ruby instead of the system ruby:

```
% which ruby
/opt/cinc-workstation/embedded/bin/ruby
```

### Configure the Ruby environment (advanced)

```
mkdir -m 0755 ~/.zshrc.d
```

```
# User specific aliases and functions
if [[ -d ~/.zshrc.d ]]; then
  for rc in ~/.zshrc.d/*; do
    if [[ -f "$rc" ]]; then
      source "$rc"
    fi
  done
fi

unset rc
```

```
cat <<'EOF' > ~/.zshrc.d/100.cinc-workstation.sh
#!/bin/bash

autoload -Uz compinit
compinit
eval "$(cinc shell-init zsh)"
EOF
```

## macOS Uninstall

To remove Cinc Workstation, run `uninstall_chef_workstation` (located
in `/usr/local/bin/uninstall_chef_workstation`).
