{ stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, intltool
, pkg-config
, alsaLib
, libjack2
, gtk2
, lash
, liblo
, lv2
, ladspaH
, dssi
, pandoc
, gettext
, wrapGAppsHook
, gsettings-desktop-schemas
}:

stdenv.mkDerivation  rec {
  pname = "amsynth";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "amsynth";
    repo = pname;
    rev = "release-${version}";
    sha256 = "059j2422zlxx0rkmksx8jic5qpzdkhpm228k7c689qlhfj6ailsx";
  };

  buildInputs = [
    gettext
    gtk2
    alsaLib
    dssi
    ladspaH
    lash
    liblo
    libjack2
  ];

  nativeBuildInputs = [
    autoconf
    automake
    autoreconfHook
    intltool
    pkg-config
    pandoc
    wrapGAppsHook
  ];

  propagatedBuildInputs = [
    gsettings-desktop-schemas
  ];

  preConfigure = ''set -x'';

  preAutoreconf = ''
    mkdir m4
    sed -ie '/AX_CXX_COMPILE_STDCXX_11(\[noext\], \[mandatory\])/d' configure.ac
  '';

  postAutoreconf = ''
    intltoolize
  '';

  meta = with stdenv.lib; {
    description = "Analog Modelling Synthesizer";
    homepage = "https://amsynth.github.io/";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers;[ sohalt ];
  };
}
