{ config, pkgs, lib, ... }:

let
  inherit (lib) mkOption mkIf concatStringsSep;

  cfg = config.services.openafsClient;

  upstreamCellServDB = pkgs.fetchurl {
    url = http://dl.central.org/dl/cellservdb/CellServDB.2016-01-01;
    sha256 = "03pp3fyf45ybjsmmmrp5ibdcjmrcc2l0zax0nvlij1n9fg6a2dzg";
  };

  cellServDB = if (cfg.cellName != "") && (cfg.cellServers != []) then
    pkgs.runCommand "CellServDB" {} ''
      printf ">${cfg.cellName}\n" >> $out
      printf "${concatStringsSep "\n" (map ({ address, hostname }: concatStringsSep " \#" [ address hostname ]) cfg.cellServers)}\n" >> $out
      cat ${upstreamCellServDB} >> $out
    '' else upstreamCellServDB;

  afsConfig = pkgs.runCommand "afsconfig" {} ''
    mkdir -p $out
    echo ${cfg.cellName} > $out/ThisCell
    cp ${cellServDB} $out/CellServDB
    echo "/afs:${cfg.cacheDirectory}:${cfg.cacheSize}" > $out/cacheinfo
  '';

  openafsPkgs = config.boot.kernelPackages.openafsClient;
in
{
  ###### interface

  options = {

    services.openafsClient = {

      enable = mkOption {
        default = false;
        description = "Whether to enable the OpenAFS client.";
      };

      cellName = mkOption {
        default = "grand.central.org";
        description = "This cell's name.";
      };

      cellServers = mkOption {
        default = [];
	description = "This cell's servers, a list of {address, hostname} sets.";
      };

      cacheSize = mkOption {
        default = "100000";
        description = "Cache size.";
      };

      cacheDirectory = mkOption {
        default = "/var/cache/openafs";
        description = "Cache directory.";
      };

      crypt = mkOption {
        default = false;
        description = "Whether to enable (weak) protocol encryption.";
      };

      sparse = mkOption {
        default = false;
        description = "Minimal cell list in /afs.";
      };

      memCache = mkOption {
        default = true;
        description = "Run diskless using in-memory caching.";
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ openafsPkgs ];

    system.activationScripts.openafs = lib.stringAfter [ "etc" "groups" "users" ] ''
      mkdir -p /etc/openafs
      cp -r ${afsConfig}/*  /etc/openafs #*/
    '';

    systemd.services.afsd = {
      description = "AFS client";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-interfaces.target" ];

      serviceConfig = { RemainAfterExit = "yes"; };

      preStart = ''
        mkdir -p -m 0755 /afs
        ${lib.optionalString (cfg.memCache == false) "mkdir -m 0700 -p ${cfg.cacheDirectory}"}
        ${pkgs.kmod}/bin/insmod ${openafsPkgs}/lib/openafs/libafs-*.ko || true
        ${openafsPkgs}/sbin/afsd -confdir ${afsConfig} ${if cfg.memCache then "-memcache" else "-cachedir ${cfg.cacheDirectory}"} ${if cfg.sparse then "-dynroot-sparse" else "-dynroot"} -fakestat -afsdb
        ${openafsPkgs}/bin/fs setcrypt ${if cfg.crypt then "on" else "off"}
      '';

      # Doing this in preStop, because after these commands AFS is basically
      # stopped, so systemd has nothing to do, just noticing it.  If done in
      # postStop, then we get a hang + kernel oops, because AFS can't be
      # stopped simply by sending signals to processes.
      preStop = ''
        ${pkgs.utillinux}/bin/umount /afs
        ${openafsPkgs}/sbin/afsd -shutdown
        ${pkgs.kmod}/sbin/rmmod libafs
      '';
    };

    networking.firewall.allowedUDPPorts = [ 7001 ];

  };
}
