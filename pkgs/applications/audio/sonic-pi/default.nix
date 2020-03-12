{ mkDerivation
, lib
, qtbase
, fetchFromGitHub
, fftwSinglePrec
, ruby
, rubyPackages_2_6
, libffi
, aubio
, cmake
, pkgconfig
, boost
, bash
, jack2Full
, supercollider
, qscintilla
, qwt
, osmid
}:

let

  supercollider_single_prec = supercollider.override {  fftw = fftwSinglePrec; };

in

mkDerivation rec {
  version = "3.2.0";
  pname = "sonic-pi";

  src = fetchFromGitHub {
    owner = "samaaron";
    repo = "sonic-pi";
    rev = "v${version}";
    sha256 = "04vxphfbydi7raiip7lghmvr1alydislfj0jsbmghsxw1flca2mw";
  };

  buildInputs = [
    bash
    cmake
    pkgconfig
    qtbase
    qscintilla
    qwt
    ruby
    rubyPackages_2_6.ffi
    libffi
    aubio
    supercollider_single_prec
    boost
  ];

  dontUseCmakeConfigure = true;

  preConfigure = ''
    patchShebangs .
  '';

  buildPhase = ''
    export SONIC_PI_HOME=$TMPDIR
    export AUBIO_LIB=${aubio}/lib/libaubio.so
    export OSMID_DIR=app/server/native/osmid

    mkdir -p $OSMID_DIR
    cp ${osmid}/bin/{m2o,o2m} $OSMID_DIR

    pushd app/server/ruby/bin
      ./compile-extensions.rb
      ./i18n-tool.rb -t
    popd

    pushd app/gui/qt
      cp -f utils/ruby_help.tmpl utils/ruby_help.h
      ../../server/ruby/bin/qt-doc.rb -o utils/ruby_help.h

      substituteInPlace SonicPi.pro \
        --replace "LIBS += -lrt -lqt5scintilla2" \
                  "LIBS += -lrt -lqscintilla2 -lqwt"

      lrelease SonicPi.pro
      cmake -DCMAKE_INSTALL_PREFIX=$out \
            -B build \
	    -S .
      make -C build
    popd
  '';

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  # $out/bin/sonic-pi is a shell script, and wrapQtAppsHook doesn't wrap them.
  dontWrapQtApps = true;
  preFixup = ''
    wrapQtApp "$out/bin/sonic-pi" \
      --prefix PATH : ${ruby}/bin:${bash}/bin:${supercollider}/bin:${jack2Full}/bin \
      --set AUBIO_LIB "${aubio}/lib/libaubio.so"
  '';

  meta = {
    homepage = "https://sonic-pi.net/";
    description = "Free live coding synth for everyone originally designed to support computing and music lessons within schools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Phlogistique kamilchm ];
    platforms = lib.platforms.linux;
  };
}
