{ stdenv
, fetchFromGitHub
, fetchzip
, cmake
, irrlicht
, libpng
, bzip2
, curl
, libogg
, jsoncpp
, libjpeg
, libXxf86vm
, libGLU
, libGL
, openal
, libvorbis
, sqlite
, luajit
, freetype
, gettext
, doxygen
, ncurses
, graphviz
, xorg
, gmp
, libspatialindex
, leveldb
, postgresql
, hiredis
, libiconv
, OpenGL
, OpenAL ? openal
, Carbon
, Cocoa
}:

with stdenv.lib;

let
  boolToCMake = b: if b then "ON" else "OFF";

  generic =
    { version
    , rev ? version
    , sha256
    , dataRev ? version
    , dataSha256
    , buildClient ? true
    , buildServer ? false
    , games ? {}
    }: let
      src = fetchFromGitHub {
        owner = "minetest";
        repo = "minetest";
        inherit rev sha256;
      };
    in
      stdenv.mkDerivation {
        pname = "minetest";
        inherit src version;

        cmakeFlags = [
          "-DBUILD_CLIENT=${boolToCMake buildClient}"
          "-DBUILD_SERVER=${boolToCMake buildServer}"
          "-DENABLE_FREETYPE=1"
          "-DENABLE_GETTEXT=1"
          "-DENABLE_SYSTEM_JSONCPP=1"
          "-DIRRLICHT_INCLUDE_DIR=${irrlicht}/include/irrlicht"
        ] ++ optionals buildClient [
          "-DOpenGL_GL_PREFERENCE=GLVND"
        ];

        NIX_CFLAGS_COMPILE = "-DluaL_reg=luaL_Reg"; # needed since luajit-2.1.0-beta3

        nativeBuildInputs = [ cmake doxygen graphviz ];

        buildInputs = [
          irrlicht
          luajit
          jsoncpp
          gettext
          freetype
          sqlite
          curl
          bzip2
          ncurses
          gmp
          libspatialindex
        ] ++ optionals stdenv.isDarwin [
          libiconv
          OpenGL
          OpenAL
          Carbon
          Cocoa
        ] ++ optionals buildClient [
          libpng
          libjpeg
          libGLU
          libGL
          openal
          libogg
          libvorbis
          xorg.libX11
          libXxf86vm
        ] ++ optionals buildServer [
          leveldb
          postgresql
          hiredis
        ];

        postInstall = concatStringsSep "\n" (
          mapAttrsToList (
            game: source:
              ''
                mkdir -pv $out/share/minetest/games/${game}/
                cp -rv ${source}/* $out/share/minetest/games/${game}/
              ''
          )
            ({
              minetest = fetchFromGitHub {
                owner = "minetest";
                repo = "minetest_game";
                rev = dataRev;
                sha256 = dataSha256;
              };
            } // games)
        );

        meta = with stdenv.lib; {
          homepage = "http://minetest.net/";
          description = "Infinite-world block sandbox game";
          license = licenses.lgpl21Plus;
          platforms = platforms.linux ++ platforms.darwin;
          maintainers = with maintainers; [ pyrolagus fpletz ];
        };
      };

  v4 = {
    version = "0.4.17.1";
    sha256 = "19sfblgh9mchkgw32n7gdvm7a8a9jxsl9cdlgmxn9bk9m939a2sg";
    dataSha256 = "1g8iw2pya32ifljbdx6z6rpcinmzm81i9minhi2bi1d500ailn7s";
  };

  v5 = {
    version = "5.3.0";
    sha256 = "03ga3j3cg38w4lg4d4qxasmnjdl8n3lbizidrinanvyfdyvznyh6";
    dataSha256 = "1liciwlh013z5h08ib0psjbwn5wkvlr937ir7kslfk4vly984cjx";
  };

in
{
  minetestclient_4 = generic (v4 // { buildClient = true; buildServer = false; });
  minetestserver_4 = generic (v4 // { buildClient = false; buildServer = true; });

  minetestclient_5 = generic (v5 // { buildClient = true; buildServer = false; });
  minetestserver_5 = generic (v5 // { buildClient = false; buildServer = true; });

  mineclone2 = generic (
    v5 // {
      buildClient = true;
      buildServer = false;
      games = {
        mineclone2 = (
          fetchzip {
            url = "https://repo.or.cz/MineClone/MineClone2.git/snapshot/0.67.2.tar.gz";
            sha256 = "1icz14gb3y5rw2fkcjds0wk5zsqv1jwp3hiy6rsaphbjrl3c7cp5";
          }
        );
      };
    }
  );
}
