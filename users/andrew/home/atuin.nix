{
  config,
  other-pkgs,
  ...
}: {
  programs.atuin =
    import ./settings/shell_integrations.nix
    // {
      enable = true;
      package = other-pkgs.unstable.atuin;
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
}
