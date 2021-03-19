{ config, pkgs, lib, ... }:
{
   # [...]
   nixpkgs.overlays = [ (self: super: /* overlay goes here */) ];
}
