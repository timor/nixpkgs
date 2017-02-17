{ config, lib, pkgs, ... }:

with lib;

let

in

{
#### interface

#### implementation

  config = mkIf cfg.enable {

      users.extraUsers.openhab = {
      description = "openHAB Server user";
      group = "openhab";
      uid = config.ids.uids.openhab;;
      };

      users.extraGroups.openhab.gid = config.ids.gids.openhab;

  }
}
