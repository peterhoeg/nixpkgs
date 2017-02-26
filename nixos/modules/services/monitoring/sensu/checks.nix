{ lib }:

with lib;

{
  options = {
    type = mkOption {
      type = types.enum [ "standard" "metric" ];
      default = "standard";
      description = "Type of check.";
    };

    standalone = mkOption {
      type = types.bool;
      default = false;
      description = "Scheduled by the client instead of the server.";
    };

    command = mkOption {
      type = types.str;
      description = "Command to run.";
    };

    subscribers = mkOption {
      type = types.listOf types.str;
      default = [
        "client:sensu"
      ];
      description = "Subscribers";
    };

    interval = mkOption {
      type = types.int;
      default = 60;
      description = "Check interval.";
    };

    timeout = mkOption {
      type = types.int;
      default = 30;
      description = "Check timeout.";
    };
  };
}
