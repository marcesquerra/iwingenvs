let
  loadPackage =
    url :
      let loadedPackages = (import (fetchTarball url){});
      in loadedPackages // {
      basicDerivation =
        params :
          let
            fullParams =
              rec {
                src = ./.;
                buildPhase = ''
                  echo
                  echo "================================================"
                  echo "STARTING BUILD (${params.name})"
                  echo "================================================"
                  echo
                  ${params.build}
                  echo
                  echo "==============="
                  echo "BUILD COMPLETED"
                  echo "==============="
                  echo
                  '';
                installPhase = "echo 'Install phase disabled'";
              } // params;
          in
            loadedPackages.stdenv.mkDerivation fullParams;
    };
  packages_17_09 =
    loadPackage https://github.com/NixOS/nixpkgs/archive/17.09.tar.gz;
  environment_builder =
    {packages, version, cabal_extra_ops ? ""}:
    with packages;
    let
        cabal        = haskellPackages.cabal-install;
        idris_native_libs = [
           libffi
           zlib
           ncurses
           gmp
           pkgconfig
         ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
           Cocoa
           CoreServices
         ]);
    in {
      inherit packages;
      idris = basicDerivation {
        name    = "idris_v${version}";
        build = ''
          export HOME=$TMP/home
          mkdir -p $HOME

          cabal update
          cabal --prefix="$out" install idris-${version} -f GMP -f ffi -f curses ${cabal_extra_ops}
            '';
        buildInputs = [ cabal ghc ] ++ idris_native_libs;
      };
    };
in
{
    idris_1_2_0 = environment_builder{ packages = packages_17_09; version = "1.2.0"; };
    idris_1_1_1 = environment_builder{ packages = packages_17_09; version = "1.1.1"; };
    idris_1_1_0 = environment_builder{ packages = packages_17_09; version = "1.1.0"; cabal_extra_ops = "--constraint=cheapskate==0.1.0.5";};
    idris_1_0   = environment_builder{ packages = packages_17_09; version = "1.0";   cabal_extra_ops = "--constraint=cheapskate==0.1.0.5";};
}
