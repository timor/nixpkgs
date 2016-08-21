{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.services.spacenavd;

in {
  options = {
    services.spacenavd = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable spacenavd, for using SpaceNavigator devices.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.spacenavd = {
      description = "spacenavd daemon for SpaceNavigator devices";
      wantedBy = [ "multi-user.target" ];
      after = [ "display-manager.service" ];
      serviceConfig.ExecStart = "${pkgs.spacenavd}/bin/spacenavd -d";
    };
  };
}
