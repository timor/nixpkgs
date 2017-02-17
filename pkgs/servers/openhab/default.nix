{ stdenv, fetchurl, jre }:

stdenv.mkDerivation rec {
  name = "openhab-${version}";
  version = "0.2.6";

  src = fetchurl {
    url = "https://bintray.com/openhab/mvn/download_file?file_path=org/openhab/distro/openhab/2.0.0/openhab-2.0.0.tar.gz";
    sha256 = "b40ba9bae69326cbb36af87e7f335bb90af02b11bce638a7c3838aed64f3ce8b";
  };

  unpackPhase = ''
  mkdir openhab
  cd openhab
  tar xzf $src
  '';
}
