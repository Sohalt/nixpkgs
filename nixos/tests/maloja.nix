import ./make-test-python.nix ({ pkgs, lib, ... }: {
  name = "maloja";
  meta.maintainers = with lib.maintainers; [ sohalt ];

  machine = { ... }: { services.maloja = { enable = true; }; };

  testScript = ''
    start_all()

    machine.wait_for_unit("maloja.service")
    assert "maloja" in machine.succeed(
        "curl --fail --insecure -L http://localhost/"
    )
  '';
})
