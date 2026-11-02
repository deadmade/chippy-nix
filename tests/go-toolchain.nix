{ lib }:

let
  select = pkgs: goMod: import ../pkgs/go-toolchain.nix {
    pkgs = { inherit lib; } // pkgs;
    inherit goMod;
  };
  toolchains = {
    go.version = "1.26.10";
    go_1_27.version = "1.27.3";
  };
  succeeds = value: (builtins.tryEval value).success;
in
assert (select toolchains "module chippy\n\ngo 1.27.3\n").version == "1.27.3";
assert (select toolchains "module chippy\n\ngo\t1.26\r\n").version == "1.26.10";
assert (select toolchains "go 1.27.3 // minimum toolchain\n").version == "1.27.3";
assert (select (toolchains // { go.version = "1.28.1"; }) "go 1.27.3\n").version == "1.28.1";
assert !(succeeds (select toolchains "go 1.27.4\n"));
assert !(succeeds (select toolchains "go 1.26.11\n"));
assert !(succeeds (select toolchains "go 1.28.1\n"));
assert !(succeeds (select toolchains "module chippy\n"));
true
