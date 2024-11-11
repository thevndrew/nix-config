{
  moduleNamespace,
  inputs,
  my-utils,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.${moduleNamespace}.gui-home;

  startupScript = pkgs.writeShellScriptBin "start" ''
    ${pkgs.waybar}/bin/waybar &
    swww-daemon &
    sleep 1
    swww img ${./sci-fi_wallpaper.webp} &
  '';

  inherit (pkgs) unstable;
in {
  _file = ./default.nix;

  options = {
    ${moduleNamespace}.gui-home = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "enable GUI related configuration";
      };

      wm.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "enable Window Manager related configuration";
      };

      audio.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "enable sound relatded configuration";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with unstable; [
      (nerdfonts.override {fonts = ["FiraCode" "DroidSansMono" "JetBrainsMono"];})
      pkgs.secret.berkeley-mono
      bustle
      clipse
      dbeaver-bin
      hyprpicker
      hyprshade
      mullvad-browser
      networkmanagerapplet
      signal-desktop
      swww
      # waycheck
      waypaper
      wayvnc
      webcord-vencord
    ];

    programs = {
      anyrun = {
        enable = true;
        config = {
          plugins = [
            # An array of all the plugins you want, which either can be paths to the .so files, or their packages
            inputs.anyrun.packages.${pkgs.system}.applications
            inputs.anyrun.packages.${pkgs.system}.rink
            inputs.anyrun.packages.${pkgs.system}.shell
            inputs.anyrun.packages.${pkgs.system}.translate
            inputs.anyrun.packages.${pkgs.system}.websearch
          ];
          x = {fraction = 0.5;};
          y = {fraction = 0.3;};
          width = {fraction = 0.3;};
          hideIcons = false;
          ignoreExclusiveZones = false;
          layer = "overlay";
          hidePluginInfo = false;
          closeOnClick = false;
          showResultsImmediately = false;
          maxEntries = null;
        };
      };

      bemenu = {
        enable = true;
        package = unstable.bemenu;
      };
    };

    services = {
      hyprpaper = {
        enable = false;
        package = unstable.hyprpaper;
      };

      swaync = {
        enable = true;
        package = unstable.swaynotificationcenter;
      };

      udiskie = {
        enable = true;
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = unstable.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    gtk = {
      enable = true;

      theme = {
        package = unstable.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = unstable.catppuccin-papirus-folders.override {
          flavor = "mocha";
          accent = "lavender";
        };
      };

      font = {
        name = "BerkeleyMono";
        size = 12;
      };
    };

    wayland.windowManager.hyprland = {
      enable = cfg.wm.enable;
      xwayland.enable = cfg.wm.enable;

      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

      plugins = [
        #inputs.hyprland-plugins.packages.${pkgs.system}.borders-plus-plus
      ];

      extraConfig = ''
        # This is an example Hyprland config file.
        # Refer to the wiki for more information.
        # https://wiki.hyprland.org/Configuring/Configuring-Hyprland/

        # Please note not all available settings / options are set here.
        # For a full list, see the wiki

        # You can split this configuration into multiple files
        # Create your files separately and then link them to this file like this:
        # source = ~/.config/hypr/myColors.conf


        ################
        ### MONITORS ###
        ################

        # See https://wiki.hyprland.org/Configuring/Monitors/
        monitor=,preferred,auto,auto


        #####################
        ### LOOK AND FEEL ###
        #####################

        # Refer to https://wiki.hyprland.org/Configuring/Variables/

        # https://wiki.hyprland.org/Configuring/Variables/#general
        general {
            gaps_in = 5
            gaps_out = 20

            border_size = 2

            # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
            col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
            col.inactive_border = rgba(595959aa)

            # Set to true enable resizing windows by clicking and dragging on borders and gaps
            resize_on_border = false

            # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
            allow_tearing = false

            layout = dwindle
        }

        # https://wiki.hyprland.org/Configuring/Variables/#decoration
        decoration {
            rounding = 10

            # Change transparency of focused and unfocused windows
            active_opacity = 1.0
            inactive_opacity = 1.0

            shadow {
                enabled = true
                range = 4
                render_power = 3
                color = rgba(1a1a1aee)
            }

            # https://wiki.hyprland.org/Configuring/Variables/#blur
            blur {
                enabled = true
                size = 3
                passes = 1

                vibrancy = 0.1696
            }
        }

        # https://wiki.hyprland.org/Configuring/Variables/#animations
        animations {
            enabled = yes, please :)

            # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

            bezier = easeOutQuint,0.23,1,0.32,1
            bezier = easeInOutCubic,0.65,0.05,0.36,1
            bezier = linear,0,0,1,1
            bezier = almostLinear,0.5,0.5,0.75,1.0
            bezier = quick,0.15,0,0.1,1

            animation = global, 1, 10, default
            animation = border, 1, 5.39, easeOutQuint
            animation = windows, 1, 4.79, easeOutQuint
            animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
            animation = windowsOut, 1, 1.49, linear, popin 87%
            animation = fadeIn, 1, 1.73, almostLinear
            animation = fadeOut, 1, 1.46, almostLinear
            animation = fade, 1, 3.03, quick
            animation = layers, 1, 3.81, easeOutQuint
            animation = layersIn, 1, 4, easeOutQuint, fade
            animation = layersOut, 1, 1.5, linear, fade
            animation = fadeLayersIn, 1, 1.79, almostLinear
            animation = fadeLayersOut, 1, 1.39, almostLinear
            animation = workspaces, 1, 1.94, almostLinear, fade
            animation = workspacesIn, 1, 1.21, almostLinear, fade
            animation = workspacesOut, 1, 1.94, almostLinear, fade
        }

        # Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
        # "Smart gaps" / "No gaps when only"
        # uncomment all if you wish to use that.
        # workspace = w[tv1], gapsout:0, gapsin:0
        # workspace = f[1], gapsout:0, gapsin:0
        # windowrulev2 = bordersize 0, floating:0, onworkspace:w[tv1]
        # windowrulev2 = rounding 0, floating:0, onworkspace:w[tv1]
        # windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
        # windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        dwindle {
            pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = true # You probably want this
        }

        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        master {
            new_status = master
        }

        # https://wiki.hyprland.org/Configuring/Variables/#misc
        misc {
            force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
            disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
        }


        #############
        ### INPUT ###
        #############

        # https://wiki.hyprland.org/Configuring/Variables/#input
        input {
            kb_layout = us
            kb_variant =
            kb_model =
            kb_options =
            kb_rules =

            follow_mouse = 1

            sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

            touchpad {
                natural_scroll = false
            }
        }

        # https://wiki.hyprland.org/Configuring/Variables/#gestures
        gestures {
            workspace_swipe = false
        }

        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
        device {
            name = epic-mouse-v1
            sensitivity = -0.5
        }

        ##############################
        ### WINDOWS AND WORKSPACES ###
        ##############################

        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

        # Example windowrule v1
        # windowrule = float, ^(kitty)$

        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

        windowrulev2 = suppressevent maximize, class:.* # You'll probably like this.

      '';

      # systemd = {
      #   enable = cfg.wm.enable;
      #   variables = [
      #     "--all"
      #   ];
      # };
      #
      settings = {
        #############################
        ### ENVIRONMENT VARIABLES ###
        #############################

        # See https://wiki.hyprland.org/Configuring/Environment-variables/

        windowrulev2 = [
          "float,class:(clipse)"
          "size 622 652,class:(clipse)"
        ];

        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
          "GDK_BACKEND,wayland,x11,*"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "QT_QPA_PLATFORM,wayland;xcb"
        ];

        ###################
        ### MY PROGRAMS ###
        ###################

        # See https://wiki.hyprland.org/Configuring/Keywords/

        # Set programs that you use
        "$terminal" = "kitty";
        "$fileManager" = "dolphin";
        "$menu" = "wofi --show drun";

        ####################
        ### KEYBINDINGSS ###
        ####################

        # See https://wiki.hyprland.org/Configuring/Keywords/
        "$mod" = "SUPER"; # Sets "Windows" key as main modifier

        bind =
          [
            "$mod, V, exec, $terminal --class clipse -e clipse"

            # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
            "$mod, Q, exec, $terminal"
            "$mod, C, killactive,"
            "$mod, M, exit,"
            "$mod, E, exec, $fileManager"
            "$mod, F, togglefloating,"
            "$mod, R, exec, $menu"
            "$mod, P, pseudo, # dwindle"
            "$mod, J, togglesplit, # dwindle"

            # Move focus with mainMod + arrow keys
            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"

            # Example special workspace (scratchpad)
            "$mod, S, togglespecialworkspace, magic"
            "$mod SHIFT, S, movetoworkspace, special:magic"

            # Scroll through existing workspaces with mainMod + scroll
            "$mod, mouse_down, workspace, e+1"
            "$mod, mouse_up, workspace, e-1"
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
            builtins.concatLists (builtins.genList (
                x: let
                  ws = let
                    c = (x + 1) / 10;
                  in
                    builtins.toString (x + 1 - (c * 10));
                in [
                  "$mod, ${ws}, workspace, ${toString (x + 1)}"
                  "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                ]
              )
              10)
          );

        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        "plugin:borders-plus-plus" = {
          add_borders = 1; # 0 - 9

          # you can add up to 9 borders
          "col.border_1" = "rgb(ffffff)";
          "col.border_2" = "rgb(2222ff)";

          # -1 means "default" as in the one defined in general:border_size
          border_size_1 = 10;
          border_size_2 = -1;

          # makes outer edges match rounding of the parent. Turn on / off to better understand. Default = on.
          natural_rounding = "yes";
        };

        #################
        ### AUTOSTART ###
        #################

        # Autostart necessary processes (like notifications daemons, status bars, etc.)
        # Or execute your favorite apps at launch like this:

        exec-once = [
          # exec-once = waybar & hyprpaper & firefox
          "clipse -listen"
          "nm-applet &"
          "systemctl --user start sunshine"
          "${startupScript}/bin/start"
          "$terminal"
        ];
      };
    };
  };
}
