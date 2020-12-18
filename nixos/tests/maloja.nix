{ system ? builtins.currentSystem, config ? { }
, pkgs ? import ../.. { inherit system config; } }:

import ../lib/testing-python.nix { inherit system pkgs; }
with pkgs.lib;
{
    name = "maloja";
    meta.maintainers = with maintainers; [ sohalt ];
    machine = { config, pkgs, ... }: {
      services.maloja = {
        enable = true;
        nginx = {
          forceSSL = false;
          enableACME = false;
        };
      };
      services.nginx.enable = true;
    };

    testScript = ''
      start_all()
      machine.wait_for_unit("maloja.service")
      machine.wait_for_unit("nginx.service")

      # without the grep the command does not produce valid utf-8 for some reason
      with subtest("welcome screen loads"):
          machine.succeed(
              "curl -sSfL http://localhost/ | grep '<title>Maloja[^<]*Installation'"
          )
    '';
}
