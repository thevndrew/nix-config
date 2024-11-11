{
  config,
  pkgs,
  lib,
  self,
  inputs,
  flake-path,
  users,
  username,
  stateVersion,
  home-modules,
  isDesktop ? false,
  isWSL ? false,
  isStandalone ? false,
  hostname,
  my-utils,
  ...
} @ args: let
  inherit (pkgs) vndrew unstable nix-alien;

  stable-pkgs = with pkgs;
    [
      dig
      hddtemp
      iotop
      lsof
      ngrep
      nmap
      nvme-cli
      tdns-cli
      wakeonlan

      nix-du
    ]
    ++ (lib.optionals (!isWSL) [
      # Do install the docker CLI to talk to podman.
      # Not needed when virtualisation.docker.enable = true;
      pkgs.docker-client
      pkgs.docker-compose

      unstable.wl-clipboard # on WSL just use: winget install win32yank
    ]);

  unstable-pkgs = with unstable; [
    # pueue
    # pprof
    # perf
    # buf
    # srgn
    bfs
    bottom # module avalible
    btop
    charm-freeze
    choose
    cht-sh
    coreutils
    ctop
    curlie
    distrobox
    dog
    dotenvx
    duf
    dust
    eza
    fd
    fx
    gitleaks
    glow
    gping
    htop
    jq
    killall
    lf
    ncdu
    nix-output-monitor
    nix-tree
    nomino
    nvd
    parallel
    plocate
    procs
    rclone
    rnr
    rsync
    sd
    shellcheck
    shellharden
    shfmt
    silver-searcher
    skim
    sops
    ssh-to-age
    teller
    # termscp
    tmux
    tokei
    tree
    trufflehog
    unar
    unzip
    uutils-coreutils
    #uutils-coreutils-noprefix
    wget
    xh
    yazi
    yq
    yt-dlp
    zip

    #findutils
    #mkcert
    #vhs # only install on desktop
    #bitwarden-cli
    #cosmopolitan
    #croc
    #gost
    #glances # python based
    #wormhole-william
    #rbw
    #pinentry # rbw dep

    nix-alien.nix-alien
  ];

  vndrew-pkgs = with vndrew; [
    bootdev
    megadl
    yt-dlp-youtube-oauth2
    yt-dlp-get-pot
  ];

  standalone = with unstable; [
    nh
  ];

  zja = {pkgs}:
    pkgs.writeShellApplication {
      name = "zja";
      runtimeInputs = with pkgs; [skim ripgrep];
      text = ''
        set +o errexit
        set +o nounset
        set +o pipefail

        ZJ_SESSIONS=$(zellij list-sessions  | \
                      rg -v EXITED\|current | \
                      cut -d" " -f1         | \
                      sed -r 's/[\x1B\x9B][][()#;?]*(([a-zA-Z0-9;]*\x07)|([0-9;]*[0-9A-PRZcf-ntqry=><~]))//g')
        CURRENT_SESSION=$(zellij list-sessions | \
                          rg "(current)"    | \
                          cut -d" " -f1        | \
                          sed -r 's/[\x1B\x9B][][()#;?]*(([a-zA-Z0-9;]*\x07)|([0-9;]*[0-9A-PRZcf-ntqry=><~]))//g')
        NO_SESSIONS=$(echo "''${ZJ_SESSIONS}" | wc -l)

        if [ "''${NO_SESSIONS}" -ge 2 ]; then
            zellij attach \
            "$(echo "''${ZJ_SESSIONS}" | sk)"
        elif [ -n "''${CURRENT_SESSION}" ]; then
            echo "You're currently in session $CURRENT_SESSION!!"
        else
            zellij attach -c
        fi
      '';
    };

  #zsh_defs = mylib.writeLines {lines = mylib.sourceFiles (mylib.relativeToRoot "config/zsh/source");};
  zsh_config = my-utils.writeLines {lines = my-utils.readFiles ./zsh;};
  bash_config = my-utils.writeLines {lines = my-utils.readFiles ./bash;};
in {
  imports = with home-modules; [
    # alacritty
    # tmux
    # shell.bash
    # shell.zsh
    # shell.fish
    # firefox
    vndrew-nvim
    # ranger
    # thunar
    gui-home
    terminals
  ];

  nvim = {
    enable = true;
    packageNames = ["nvim-nightly"];
  };

  vndrewMods = {
    # zsh.enable = true;
    # bash.enable = true;
    # alacritty.enable = true;
    # tmux.enable = true;
    # firefox.enable = true;
    # thunar.enable = true;
    terminals.enable = isDesktop;
    terminals.kitty = isDesktop;
    gui-home.enable = isDesktop;
    gui-home.wm.enable = isDesktop;
    gui-home.audio.enable = isDesktop;
  };

  nix.registry = {
    # nixpkgs.flake = inputs.nixpkgs-unstable;
    home-manager.flake = inputs.home-manager;
    gomod2nix.to = {
      type = "github";
      owner = "nix-community";
      repo = "gomod2nix";
    };
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/templates";
      videos = "${config.home.homeDirectory}/videos";
      extraConfig = {
        XDG_MISC_DIR = "${config.home.homeDirectory}/misc";
      };
    };
    configFile = {
      # Nothing here for now...
    };
    mimeApps.defaultApplications = {
      "application/pdf" = ["firefox.desktop" "draw.desktop" "gimp.desktop"];
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = stateVersion; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = lib.mkDefault users.homeManager.${username}.homeDirectory;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/andrew/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
    FLAKE = "/home/${username}/nix-config";
    _ZO_ECHO = "1";
    NIXOS_OZONE_WL = "1"; # This variable fixes electron apps in wayland
    # WLR_NO_HARDWARE_CURSORS = "1"; # if cursor becomes invisible
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    # JAVA_HOME = "${pkgs.jdk}";
  };

  home.shellAliases =
    {
      zj = "zellij";
      cat = "bat --paging never --theme DarkNeon --style plain";
      c = "clear";
      fzfp = "alias fzfp='fzf --preview \"bat --style numbers --color always {}\"'";
      gc = "nix-collect-garbage --delete-old";
      ks = "tmux kill-server";
      nb = "nix build --json --no-link --print-build-logs";
      top_used = "fc -ln 0 | sort | uniq -c | sort -nr | head -20";
      dugood = ''${unstable.writeShellScript "dugood" ''du -hd1 $@ | sort -hr''}'';
      get_secrets = "source ${pkgs.my_pkgs.sops_secrets_key}/bin/get_sops_key";
      remove_secrets = "source ${pkgs.my_pkgs.sops_secrets_key}/bin/remove_sops_key";
    }
    // lib.optionalAttrs isWSL {
      pbcopy = "/mnt/c/Windows/System32/clip.exe";
      pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
      explorer = "/mnt/c/Windows/explorer.exe";
    }
    // {
      flakeUpAndAddem = ''${pkgs.writeShellScript "flakeUpAndAddem.sh"
          /*
          bash
          */
          ''
            target=""; [[ $# > 0 ]] && target=".#$1" && shift 1;
            git add . && nix flake update && nom build --show-trace $target && git add .; $@
          ''}'';
      autorepl = ''${pkgs.writeShellScript "autorepl" ''
          exec nix repl --show-trace --expr '{ pkgs = import ${inputs.nixpkgs.outPath} { system = "${pkgs.system}"; config.allowUnfree = true; }; }'
        ''}'';
      yolo = ''git add . && git commit -m "$(curl -fsSL https://whatthecommit.com/index.txt)" -m '(auto-msg whatthecommit.com)' -m "$(git status)" && git push'';
      scratch = ''export OGDIR="$(realpath .)" && export SCRATCHDIR="$(mktemp -d)" && cd "$SCRATCHDIR"'';
      exitscratch = ''cd "$OGDIR" && rm -rf "$SCRATCHDIR"'';
      lsnc = "lsd --color=never";
      la = "lsd -a";
      ll = "lsd -lh";
      l = "lsd -alh";
      yeet = "rm -rf";
      dugood = ''${pkgs.writeShellScript "dugood" ''du -hd1 $@ | sort -hr''}'';
      run = "nohup xdg-open";

      me-build-system = ''${pkgs.writeShellScript "me-build-system" ''
          export FLAKE="${flake-path}";
          exec ${self}/scripts/system "$@"
        ''}'';
      me-build-home = ''${pkgs.writeShellScript "me-build-home" ''
          export FLAKE="${flake-path}";
          exec ${self}/scripts/home "$@"
        ''}'';
      me-build-both = ''${pkgs.writeShellScript "me-build-both" ''
          export FLAKE="${flake-path}";
          exec ${self}/scripts/both "$@"
        ''}'';
    };

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = ["ignoredups" "ignorespace"];
      historyFile = "/home/${username}/.bash_eternal_history";
      historyFileSize = -1;
      historySize = -1;
      bashrcExtra = ''
        # No Extras for now
      '';
      shellOptions = [
        #"checkjobs"
        #"checkwinsize"
        #"histappend"
        "dotglob"
        "extglob"
        "globstar"
      ];
      sessionVariables = {
        HISTTIMEFORMAT = "[%F %T] ";
        PROMPT_COMMAND = "history -a; $PROMPT_COMMAND";
      };
      initExtra = ''
        ${bash_config}
      '';
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "emacs";
      dotDir = ".config/zsh";

      history = {
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
        save = 1000000000;
        size = 1000000000;
        path = "$ZDOTDIR/.zsh_history";
      };

      initExtra = ''
        #$${zsh_defs}
        ${zsh_config}
      '';

      historySubstringSearch = {
        enable = true;
        searchDownKey = [
          "^[[B"
          "^[OB"
        ];
        searchUpKey = [
          "^[[A"
          "^[OA"
        ];
      };

      oh-my-zsh = {
        enable = false;
        plugins = [
          "command-not-found"
          "git"
          "kubectl"
          "kubectx"
          "sudo"
        ];
        theme = "robbyrussell";
      };

      #initExtraBeforeCompInit
      #initExtraFirst
      #localVariables
      plugins = [
        #{
        #  name = "powerlevel10k";
        #  src = pkgs.zsh-powerlevel10k;
        #  file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        #}
        {
          name = "zsh-completions";
          src = inputs.zsh-completions;
        }
        {
          name = "fzf-tab";
          src = inputs.fzf-tab;
        }
      ];
    };

    nushell = {
      enable = true;
      package = unstable.nushell;
    };
  };

  sops = {
    age.sshKeyPaths = ["/home/${username}/.ssh/${hostname}"];
    defaultSopsFile = "${inputs.mysecrets}/secrets/services.yaml";

    secrets = {
      "services/env" = {
        sopsFile = "${inputs.mysecrets}/secrets/services.yaml";
        path = "/home/${username}/.config/services/services.env";
      };

      "services/${hostname}" = lib.mkIf (!isWSL) {
        sopsFile = "${inputs.mysecrets}/secrets/services.yaml";
        path = "/home/${username}/.config/services/${hostname}.yaml";
      };

      "atuin_key" = {
        sopsFile = "${inputs.mysecrets}/secrets/atuin.yaml";
      };
    };
  };

  home.packages =
    [
      (zja {pkgs = unstable;})

      pkgs.my_pkgs.clone_repos
      pkgs.my_pkgs.sops_secrets_key
      pkgs.my_pkgs.update_input

      (pkgs.writeShellApplication {
        name = "zipcbz";
        runtimeInputs = with unstable; [zip];
        text = builtins.readFile ./zipcbz.bash;
      })

      (pkgs.writeShellApplication {
        name = "find_gc_roots";
        text = builtins.readFile ./find_gc_roots.bash;
      })

      (pkgs.writeShellApplication {
        name = "rip_streams";
        runtimeInputs =
          (with unstable; [yq])
          ++ (with pkgs.vndrew; [
            yt-dlp-youtube-oauth2
            yt-dlp-get-pot
          ]);
        text = builtins.readFile ./rip_streams.bash;
      })
      (pkgs.writeShellApplication {
        name = "rip_streams_stop";
        runtimeInputs =
          (with unstable; [yq coreutils])
          ++ (with pkgs.vndrew; [
            yt-dlp-youtube-oauth2
            yt-dlp-get-pot
          ]);
        text = builtins.readFile ./rip_streams_stop.bash;
      })
      (pkgs.writeShellApplication {
        name = "rip_stream_helper";
        runtimeInputs =
          (with unstable; [yq yt-dlp])
          ++ (with pkgs.vndrew; [
            yt-dlp-youtube-oauth2
            yt-dlp-get-pot
          ]);
        text = builtins.readFile ./rip_stream_helper.bash;
      })

      (pkgs.writeShellApplication {
        name = "spkgname";
        runtimeInputs = with unstable; [nix-search-cli];
        text = (
          /*
          bash
          */
          ''
            nix-search -n "$@"
          ''
        );
      })
      (pkgs.writeShellApplication {
        name = "spkgprog";
        runtimeInputs = with unstable; [nix-search-cli];
        text = (
          /*
          bash
          */
          ''
            nix-search -q  "package_programs:($*)"
          ''
        );
      })
      (pkgs.writeShellApplication {
        name = "spkgdesc";
        runtimeInputs = with unstable; [nix-search-cli];
        text = (
          /*
          bash
          */
          ''
            nix-search -q  "package_description:($*)"
          ''
        );
      })
    ]
    ++ stable-pkgs
    ++ unstable-pkgs
    ++ vndrew-pkgs
    ++ (lib.optionals isStandalone standalone);

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
          HostName github.com
          PreferredAuthentications publickey
          IdentityFile ~/.ssh/${hostname}
    '';
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    package = unstable.starship;
    settings = {
      #palette = "gruvbox_dark";

      palettes.gruvbox_dark = {
        fg = "#fbf1c7";
        bg = "#3c3836";
        bg3 = "#665c54";
        blue = "#458588";
        aqua = "#689d6a";
        green = "#98971a";
        orange = "#d65d0e";
        purple = "#b16286";
        red = "#cc241d";
        yellow = "#d79921";
      };

      aws.disabled = true;
      directory.truncate_to_repo = false;
      directory.truncation_length = 8;
      direnv.disabled = false;
      gcloud.disabled = true;
      git_branch.style = "242";
      kubernetes.disabled = false;
      ruby.disabled = true;

      hostname.ssh_only = false;
    };
  };

  programs.thefuck = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    package = unstable.thefuck;
  };

  programs = {
    ripgrep = {
      enable = true;
      package = unstable.ripgrep;
    };

    broot = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = unstable.broot;
      settings = {
        modal = true;
      };
    };

    bat = {
      enable = true;
      package = unstable.bat;
      extraPackages = with unstable.bat-extras; [
        #batdiff
        batgrep
        batman
        batpipe
        batwatch
        prettybat
      ];
    };
  };

  programs.zellij = {
    enable = true;
    package = unstable.zellij;
    settings = {
      #theme = "gruvbox-dark";
      #theme = "custom"
      #themes.custom.fg = "#ffffff";
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    package = unstable.zoxide;
    options = ["--cmd cd"];
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    package = unstable.atuin;
    settings = {
      auto_sync = true;
      dialect = "us";
      filter_mode = "global";
      key_path = config.sops.secrets.atuin_key.path;
      search_mode = "fuzzy";
      secrets_filter = true;
      show_help = true;
      show_preview = true;
      show_tabs = true;
      store_failed = true;
      sync_address = "http://going-merry.ainu-kanyu.ts.net:9085";
      #sync_address = "https://atuin.local.vndrew.com";
      sync_frequency = "15m";
      update_check = true;

      sync = {
        records = true;
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    package = unstable.direnv;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    package = unstable.fzf;
  };

  programs.git =
    users.git.${username}
    // {
      enable = true;
      package = unstable.git;

      userEmail = "69527486+thevndrew@users.noreply.github.com";

      aliases = {
        an = "commit --amend --no-edit";
        br = "branch";
        bump = "commit --amend --no-edit --date=now";
        c = "commit";
        co = "checkout";
        st = "status";
        wt = "worktree";
      };

      delta = {
        enable = true;
        options = {
          line-numbers = true;
          side-by-side = true;
          navigate = true;
        };
      };

      extraConfig = {
        branch.sort = "-committerdate";
        commit.gpgsign = true;
        column.ui = "auto";

        core = {
          editor = "vim";
          fsmonitor = true;
        };

        diff = {
          colorMoved = "default";
        };

        fetch = {
          prune = true;
          writeCommitGraph = true;
        };

        gpg.format = "ssh";
        init.defaultBranch = "main";

        merge = {
          conflictstyle = "diff3";
        };

        pull.rebase = true;
        push = {
          default = "current";
          autoSetupRemote = true;
        };

        rebase.updateRefs = true;
        rerere.enabled = true;

        user = {
          gpgsign = true;
          signingkey = "/home/${username}/.ssh/${hostname}.pub";
        };
      };

      ignores = [
        "*.swp"
      ];

      lfs = {
        enable = true;
      };
    };

  programs.gh = {
    enable = true;
    package = unstable.gh;
    settings = {
      git_protocol = "ssh";
      #pager = "";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };

  programs.lsd = {
    enable = true;
  };

  programs.nix-index-database.comma.enable = true;

  programs.nix-index = {
    enableBashIntegration = true;
    enableZshIntegration = true;
    enable = true;
    package = unstable.nix-index;
  };

  programs.scmpuff = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    package = unstable.scmpuff;
  };

  programs.lf = {
    enable = true;
    package = unstable.lf;
  };

  programs.yazi = {
    enableBashIntegration = true;
    enableZshIntegration = true;
    enable = true;
    package = unstable.yazi;
  };

  programs.nnn = {
    enable = true;
    package = unstable.nnn.override {withNerdIcons = true;};
    plugins = {
      mappings = {
        f = "finder";
        z = "autojump";
      };
      src = "${inputs.nnn}/plugins";
    };
  };
}
