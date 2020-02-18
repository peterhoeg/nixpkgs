{ pkgs ? import ./. {}
, maintainer ? "peterhoeg"
}:

with pkgs.lib;

filterAttrs (name: value: (builtins.tryEval value).success && elem maintainers.${maintainer} (value.meta.maintainers or [])) pkgs
