{ pkgs, goMod }:

let
  lib = pkgs.lib;
  directives = builtins.filter (match: match != null) (
    map (line: builtins.match "[ \t]*go[ \t]+([0-9]+\\.[0-9]+(\\.[0-9]+)?)[ \t\r]*(//.*)?" line)
      (lib.splitString "\n" goMod)
  );
  requiredVersion =
    if builtins.length directives == 1 then
      builtins.head (builtins.head directives)
    else
      throw "Chippy: expected one Go version directive in go.mod";
  versionParts = lib.splitString "." requiredVersion;
  goAttr = "go_${builtins.elemAt versionParts 0}_${builtins.elemAt versionParts 1}";
  unavailable = throw "Chippy requires Go >= ${requiredVersion}; refresh nixpkgs to provide a compatible ${goAttr} toolchain";
  # nixpkgs can ship a newer Go before making it the default.
  go =
    if lib.versionAtLeast pkgs.go.version requiredVersion then
      pkgs.go
    else
      pkgs.${goAttr} or unavailable;
in
if lib.versionAtLeast go.version requiredVersion then go else unavailable
