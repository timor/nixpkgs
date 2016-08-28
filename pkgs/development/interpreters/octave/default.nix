{ stdenv, fetchurl, gfortran, readline, ncurses, perl, flex, texinfo, qhull, gl2ps, epstool
, libX11, graphicsmagick, pcre, pkgconfig, mesa, mesa_noglu, fltk, transfig
, fftw, fftwSinglePrec, zlib, curl, qrupdate, openblas, makeWrapper, pstoedit
, qt ? null, qscintilla ? null, ghostscript ? null, llvm ? null, hdf5 ? null,glpk ? null
, suitesparse ? null, gnuplot ? null, jdk ? null, python ? null, osmesa ? null
}:

let
  suitesparseOrig = suitesparse;
  qrupdateOrig = qrupdate;
  # if osmesa is used, use same llvm version as them
  selected_llvm = if (osmesa != null) then mesa_noglu.passthru.llvm else llvm;
in
# integer width is determined by openblas, so all dependencies must be built
# with exactly the same openblas
let
  suitesparse =
    if suitesparseOrig != null then suitesparseOrig.override { inherit openblas; } else null;
  qrupdate = if qrupdateOrig != null then qrupdateOrig.override { inherit openblas; } else null;
in

stdenv.mkDerivation rec {
  version = "4.0.3";
  name = "octave-${version}";
  src = fetchurl {
    url = "mirror://gnu/octave/${name}.tar.xz";
    sha256 = "11day29k4yfvxh4101x5yf26ld992x5n6qvmhjjk6mzsd26fqayw";
  };

  buildInputs = [ gfortran readline ncurses perl flex texinfo qhull libX11
    graphicsmagick pcre pkgconfig mesa fltk zlib curl openblas
    fftw fftwSinglePrec qrupdate makeWrapper transfig pstoedit epstool gl2ps ]
    ++ (stdenv.lib.optional (qt != null) qt)
    ++ (stdenv.lib.optional (qscintilla != null) qscintilla)
    ++ (stdenv.lib.optional (ghostscript != null) ghostscript)
    ++ (stdenv.lib.optional (selected_llvm != null) selected_llvm)
    ++ (stdenv.lib.optional (hdf5 != null) hdf5)
    ++ (stdenv.lib.optional (glpk != null) glpk)
    ++ (stdenv.lib.optional (suitesparse != null) suitesparse)
    ++ (stdenv.lib.optional (jdk != null) jdk)
    ++ (stdenv.lib.optional (gnuplot != null) gnuplot)
    ++ (stdenv.lib.optional (python != null) python)
    ++ (stdenv.lib.optional (osmesa != null) mesa_noglu.osmesa)
    ;


  preConfigure = stdenv.lib.optionalString (osmesa != null) ''
    export LLVM_CONFIG=${selected_llvm}/bin/llvm-config
  '';

  doCheck = true;

  enableParallelBuilding = true;

  patches = stdenv.lib.optional (osmesa != null) [ ./configure-enable-llvm.patch ];

  configureFlags =
    [ "--enable-readline"
      "--enable-dl"
      "--with-blas=openblas"
      "--with-lapack=openblas"
    ]
    ++ stdenv.lib.optional openblas.blas64 "--enable-64";

  # Keep a copy of the octave tests detailed results in the output
  # derivation, because someone may care

  # Add gnuplot and ghostscript to PATH if specified as build input.
  wrapList = [ transfig epstool pstoedit]
              ++ (stdenv.lib.optional (gnuplot != null) gnuplot)
              ++ (stdenv.lib.optional (ghostscript != null) ghostscript);
  postInstall = ''
    cp test/fntests.log $out/share/octave/${name}-fntests.log || true
  '' + stdenv.lib.optionalString (wrapList != []) ''
    wrapProgram $out/bin/octave --suffix PATH : ${stdenv.lib.makeBinPath wrapList}'';

  passthru = {
    inherit version;
    sitePath = "share/octave/${version}/site";
  };

  meta = {
    homepage = http://octave.org/;
    license = stdenv.lib.licenses.gpl3Plus;
    maintainers = with stdenv.lib.maintainers; [viric raskin];
    platforms = with stdenv.lib.platforms; linux;
  };
}
