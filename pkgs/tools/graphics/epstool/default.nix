{stdenv, fetchurl, ghostscript }:

stdenv.mkDerivation rec {
  name = "epstool-${version}";
  version = "3.08";

  src = fetchurl {
   url = "http://ftp.ntua.gr/mirror/ghost/ghostgum/epstool-${version}.tar.gz";
   sha256 = "1pfgqbipwk36clhma2k365jkpvyy75ahswn8jczzys382jalpwgk";
  };

  patches = [ ./rootdir.patch ];

  preInstall= ''
    export EPSTOOL_ROOT="$out"
  '';
  
  buildInputs = [ ghostscript ];

}
