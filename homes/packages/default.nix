{
  pkgs,
  lib,
  my-utils,
  ...
}: let
  inherit (pkgs) vndrew unstable nix-alien;

  stable-pkgs = with pkgs; [
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
  ];

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
    # nomino
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
in {
  imports = my-utils.scanPaths ./.;

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
    ++ vndrew-pkgs;
}