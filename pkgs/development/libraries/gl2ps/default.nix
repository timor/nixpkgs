{stdenv, fetchurl, cmake, freeglut, zlib, libpng, mesa, xorg }:

stdenv.mkDerivation rec {
  name = "gl2ps-${version}";
  version = "1.3.8";

  src = fetchurl {
    url = "http://geuz.org/gl2ps/src/gl2ps-${version}.tgz";
    sha256 = "1r8y62y3sh3algs02jcmjw3vygh90cc0prw8q6l8hrphbpcqvr9g";
  };

  # documentation wants latex, remove for simplicity
  patches = [ ./disable-doc.patch ];

  buildInputs = [ cmake freeglut zlib libpng mesa xorg.libXmu xorg.libXi ];

}
