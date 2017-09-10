{ stdenv, fetchurl,  flex,
 qtbase, openmpi, paraview, scotch }:

stdenv.mkDerivation rec {
  name = "openfoam-${version}";
  version = "5.0";

  srcs = [
    (fetchurl {
      url = "http://dl.openfoam.org/source/5-0";
      sha256 = "1f0n5ic475h17gk32sv8mkb0d4j751ls3f39bh3aaj4pl3qpdzab";
      name = "${name}.tar.gz";
    })

    (fetchurl {
      url = "http://dl.openfoam.org/third-party/5-0";
      sha256 = "1bfp0dg5l3incvdnizynm5l2wjvwm5vk59vzcyzlalhwzqnq8hgz";
      name = "${name}-3rdParty.tar.gz";
    })
  ];

  buildInputs = [  flex
   openmpi paraview qtbase scotch ];

  setSourceRoot = ''
    mv OpenFOAM-5.x-version-${version} OpenFOAM-${version}
    export sourceRoot=OpenFOAM-${version};
  '';

  postUnpack = ''
    mv ThirdParty-5.x-version-${version} $sourceRoot/ThirdParty
  '';

  configurePhase = ''
    patchShebangs wmake/
    source etc/bashrc
  '';

  buildPhase = ''
    ./Allwmake -j$NIX_BUILD_CORES
  '';

  meta = {
    description = "OpenFoam simulator";
    # license     = stdenv.lib.licenses.gpl2;
    homepage    = https://openfoam.org;
    platforms   = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ ];
  };
}
