{ stdenv
, cmake
, llvm
, version
, fetchpatch
, fetchFromGitHub
}:

let
  llvmsrc = fetchFromGitHub {
    owner = "llvm";
    repo = "llvm-project";
    # 11.1.0
    rev = "1fdec59bffc11ae37eb51a1b9869f0696bfd5312";
    sha256 = "0bgzqyk6w285k1nilnsim4hrcgy0kdr0z8d3kac06lkdflydgcz8";
    # rev = "854de7c4d074f1c5d10be08809fa631e53b168b0";
    # sha256 = "07a4bvdqkzgd1rg4g31ar9z2p86rl6zsp2j31qly220z46xyh184";
  };

in

stdenv.mkDerivation rec {
  pname = "mlir";
  inherit version;

  src = llvmsrc ;

  patches = [(
    fetchpatch {
      url = "https://github.com/llvm/llvm-project/commit/2aa1af9b1da0d832270d9b8afcba19a4aba2c366.patch";
      sha256 = "0wpg33qg9ixivq25r4phijnj1zckh67ppbx0cnc2bk9zvr0zf7sg";
    }
  )];

  # sourceRoot = "source/mlir";

  postPatch = ''
    # sourceRoot=$sourceRoot/mlir
    cd mlir
  '';


  # postPatch = ''
  #   sed -i -e '1i cmake_policy(SET CMP0057 NEW)' CMakeLists.txt
  # '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ llvm ];

  cmakeFlags = [
    # "-DCMAKE_POLICY_"
    # "-DLLVM_ENABLE_PROJECTS=mlir"
    "-DLLVM_TARGETS_TO_BUILD=X86;RISCV"
    "-DLLVM_ENABLE_ASSERTIONS=ON"
  ];

  enableParallelBuilding = true;
}
