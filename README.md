# spoutwire: Spout2 to PipeWire bridge

spoutwire is a fork of [spout2pw](https://github.com/hoshinolina/spout2pw):

**[Spout2PW website](https://spout2pw.lina.yt)**

[![Github-sponsors](https://img.shields.io/github/sponsors/hoshinolina?label=Sponsor&logo=GitHub)](https://lina.yt/sponsor)
[![Ko-Fi](https://shields.io/badge/ko--fi-Tip-ff5f5f?logo=ko-fi)](https://lina.yt/kofi)

**If you like this, please help support hoshinolina with the links above!**

See the [wiki page](https://github.com/hoshinolina/spout2pw/wiki) for installation and usage instructions, but make sure to replace `spout2pw` with `spoutwire`. E.g. `~/spout2pw/spout2pw.sh umu-run your-favorite-app.exe` becomes `~/spoutwire/spoutwire.sh umu-run your-favorite-app.exe`.

## Building

```bash
git submodule init
git submodule update
./build.sh
```

This creates a package at `build/pkg`.

## Build dependencies

On Debian: `sudo apt install meson ninja-build libdbus-1-dev libwine-dev mingw-w64 libgbm-dev libdrm-dev libvulkan-dev wine64-tools`

## Credits
Original author:
* hoshinolina

Based on a prototype by tytan652:

* https://codeberg.org/tytan652/spoutdxtoc
* https://codeberg.org/tytan652/spout2xdp

Contributors:
* hoshinolina
* marysaka
* yofukashino
* h-banii

## NixOS

Currently only [nix flakes](https://nixos.wiki/wiki/flakes) are supported.

To use this project on NixOS or by using the nix package manager, follow the following steps:

- Add the following to your `flake.nix`:

    ```nix
    inputs.spoutwire = {
      url = "git+https://github.com/tasokait/spoutwire.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ```
  Note that the `github:tasokait/spoutwire` URL will not work, because of how git submodules are handled in nix.

- *(Optionally)* Add `inputs.spoutwire.overlays.default` to [your overlays](https://wiki.nixos.org/wiki/Overlays#Using_overlays).

- Add `pkgs.spoutwire` (or `inputs.spoutwire.packages.x86_64-linux.spoutwire` if you did not add the overlay) to your installation using [home-manager](https://github.com/nix-community/home-manager) (recommended):

  ```nix
  home.packages = with pkgs; [
    spoutwire
    umu-launcher
  ];
  ```

  You may also install the package without home-manager or use the package directly within a bash script: `${lib.getExe pkgs.spoutwire}`.

Then you can use `spoutwire` like it is used on other linux distributions.

If you want a desktop icon for the app you are starting with `spoutwire` you can use the following with home-manager:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # to get VNyan.ico icon use: `nix shell nixpkgs#icoutils --command sh -c 'wrestool -x -t14 VNyan.exe > VNyan.ico'`
  vNyanFolder = "${config.home.homeDirectory}/your/path/to/vnyan";
  protonVersion = "GE-Proton11-1";
  protonPath = pkgs.fetchzip {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${protonVersion}/${protonVersion}.tar.gz";
    hash = "sha256-I7SSvzQQ/NqdvwjpJ9IFFtAaTS+rgHUyXx0us1vIOnw=";
  };
in
{
  xdg.desktopEntries = {
    vnyan = {
      name = "VNyan";
      genericName = "3D VTubing";
      exec = "env PROTONPATH=${protonPath} ${lib.getExe pkgs.spoutwire} -quiet ${lib.getExe pkgs.umu-launcher} ${vNyanFolder}/VNyan.exe -portable -p ${config.home.username}";
      icon = "${vNyanFolder}/VNyan.ico";
      terminal = false;
      categories = [
        "Graphics"
        "3DGraphics"
      ];
    };
  };
}
```

If you run into issues make sure to remove `-quiet` and/or change the `PROTONPATH` environment variable.
