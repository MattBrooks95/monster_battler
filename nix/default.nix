{ sources ? import ./sources.nix
, pkgs ? import sources.nixpkgs { }
}:

with pkgs;

buildEnv {
	name = "builder";
	paths = [
		nodejs-18_x
		postgresql_12
		zlib.dev
	];
}
