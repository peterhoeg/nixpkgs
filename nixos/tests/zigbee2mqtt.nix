import ./make-test-python.nix ({ pkgs, ... }:

  {
    machine = { pkgs, ... }:
      {
        services.zigbee2mqtt.enable = true;
      };

    # We don't have the hardware available when running the test, so the service
    # should be enabled but skipped. Unfortunately, we cannot test for "skipped
    # due to condition check failure" using systemctl, so instead we just check
    # that it is inactive.
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.wait_until_succeeds("systemctl is-enabled zigbee2mqtt.service")
      machine.require_unit_state("zigbee2mqtt.service", "inactive")
    '';
  }
)
