{
  inputs,
  lib,
}:
with builtins; rec {
  linkFarmPair = name: path: {inherit name path;};

  eachSystem = with builtins;
    systems: f: let
      # Merge together the outputs for all systems.
      op = attrs: system: let
        ret = f system;
        op = attrs: key:
          attrs
          // {
            ${key} =
              (attrs.${key} or {})
              // {${system} = ret.${key};};
          };
      in
        foldl' op attrs (attrNames ret);
    in
      foldl' op {}
      (systems
        ++ # add the current system if --impure is used
        (
          if builtins ? currentSystem
          then
            if elem currentSystem systems
            then []
            else [currentSystem]
          else []
        ));

  mkRecBuilder = {
    src ? "$src",
    outdir ? "$out",
    action ? "cp $1 $2",
    ...
  }:
  /*
  bash
  */
  ''
    builder_file_action() {
      ${action}
    }
    dirloop() {
      local dir=$1
      local outdir=$2
      local action=$3
      shift 3
      local dirnames=("$@")
      local file=""
      mkdir -p "$outdir"
      for file in "$dir"/*; do
        if [ -d "$file" ]; then
          dirloop "$file" "$outdir/$(basename "$file")" $action "''${dirnames[@]}" "$(basename "$file")"
        else
          $action "$file" "$outdir" "''${dirnames[@]}"
        fi
      done
    }
    dirloop ${src} ${outdir} builder_file_action
  '';

  # getSopsKeys = user: builtins.map (name: "/home/${user}/.ssh/${name}") ["gopsing-merry" "thousand-sunny" "polar-tang"];

  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;

  # # Get a list of .nix files in the directory "path"
  # scanPaths = path: let
  #   excludeDirs = [
  #     #"modules"
  #     "packages"
  #     "pkgs"
  #     "scripts"
  #     "settings"
  #     "systemd"
  #   ];
  #
  #   excludeNamePrefix = [
  #     "_"
  #   ];
  #
  #   excludeNameSuffix = [
  #     "_settings"
  #     "_module"
  #   ];
  #
  #   filterDir = path: builtins.all (dir: path != dir) excludeDirs;
  #   filterFileSuffix = path: builtins.all (suffix: !lib.strings.hasSuffix "${suffix}.nix" path) excludeNameSuffix;
  #   filterFilePrefix = path: builtins.all (prefix: !lib.strings.hasPrefix "${prefix}" path) excludeNamePrefix;
  # in
  #   builtins.map
  #   (f: (path + "/${f}"))
  #   (builtins.attrNames
  #     (lib.attrsets.filterAttrs
  #       (
  #         path: _type:
  #           (
  #             _type
  #             == "directory" # include directories
  #             && filterDir path # filter excluded dirs
  #           )
  #           || (
  #             (path != "default.nix") # ignore default.nix
  #             && (filterFileSuffix path) # ignore *settings.nix files
  #             && (filterFilePrefix path) # ignore files starting with exluded prefixes
  #             && (lib.strings.hasSuffix ".nix" path) # include .nix files
  #           )
  #       )
  #       (builtins.readDir path)));

  operateOnFiles = path: op:
    builtins.map
    (f: (op (path + "/${f}")))
    (builtins.attrNames
      (
        lib.attrsets.filterAttrs
        (
          _path: _type: (
            _type
            != "directory"
          )
        )
        (builtins.readDir path)
      ));

  # Get a list of strings containing the contents of each file
  # in a directory
  readFiles = path: operateOnFiles path (f: builtins.readFile f);

  sourceFiles = path: operateOnFiles path (f: "source ${f}");

  # merge list of strings using a seperator
  writeLines = {
    lines,
    sep ? "\n",
  }:
    lib.concatStringsSep sep lines;

  # use callPackage
  backup_rotator = ./backup_rotator.nix;

  inherit (import ./mkLuaStuff.nix {inherit mkRecBuilder inputs;}) compile_lua_dir mkLuaApp;
}
