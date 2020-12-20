import ./make-test-python.nix (
  { pkgs, lib, ... }: {
    name = "maloja";
    meta.maintainers = with lib.maintainers; [ sohalt ];

    machine = { ... }: {
      services.maloja = {
        enable = true;
        port = 8080;
      };
    };

    testScript = ''
      start_all()

      machine.wait_for_unit("maloja.service")
      "Maloja" in machine.succeed("curl --insecure -L http://localhost:8080/")
    '';
  }
)
