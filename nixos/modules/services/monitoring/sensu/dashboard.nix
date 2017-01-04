{ lib }:

with lib;

{
  options = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the dashboard";
    };

    bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The interface Uchiwa will listen on.";
    };

    port = mkOption {
      type = types.int;
      default = 3000;
      description = "The port Uchiwa will listen on.";
    };

    refresh = mkOption {
      type = types.int;
      default = 5;
      description = "UI refresh interval.";
    };
  };
}
