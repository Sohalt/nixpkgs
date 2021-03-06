{ lib, stdenv, fetchurl
, pkgconfig, wrapGAppsHook
, glib, glib-networking, gsettings-desktop-schemas, gtk, libsoup, webkitgtk
, xorg, dmenu, findutils, gnused, coreutils
, patches ? null
}:

stdenv.mkDerivation rec {
  pname = "surf";
  version = "2.0";

  src = fetchurl {
    url = "https://dl.suckless.org/surf/surf-${version}.tar.gz";
    sha256 = "07cmajyafljigy10d21kkyvv5jf3hxkx06pz3rwwk3y3c9x4rvps";
  };

  nativeBuildInputs = [ pkgconfig wrapGAppsHook ];
  buildInputs = [ glib glib-networking gsettings-desktop-schemas gtk libsoup webkitgtk ];

  inherit patches;

  installFlags = [ "PREFIX=$(out)" ];

  # Add run-time dependencies to PATH. Append them to PATH so the user can
  # override the dependencies with their own PATH.
  preFixup = let
    depsPath = lib.makeBinPath [ xorg.xprop dmenu findutils gnused coreutils ];
  in ''
    gappsWrapperArgs+=(
      --suffix PATH : ${depsPath}
    )
  '';

  meta = with stdenv.lib; {
    description = "A simple web browser based on WebKit/GTK";
    longDescription = ''
      Surf is a simple web browser based on WebKit/GTK. It is able to display
      websites and follow links. It supports the XEmbed protocol which makes it
      possible to embed it in another application. Furthermore, one can point
      surf to another URI by setting its XProperties.
    '';
    homepage = "https://surf.suckless.org";
    license = licenses.mit;
    platforms = webkitgtk.meta.platforms;
    maintainers = with maintainers; [ joachifm ];
  };
}
