{ sources ? import ./nix/sources.nix
	, pkgs ? import <nixpkgs> { }
}:

with pkgs;
let
	inherit (lib) optional optionals;
in
mkShell {
	buildInputs = [
		(import ./nix/default.nix { inherit pkgs; })
		niv
	] ++ optional stdenv.isLinux inotify-tools;
}
