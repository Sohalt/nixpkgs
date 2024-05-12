{
  mkDerivation,
  lib,
  fetchFromGitLab,
  gitUpdater,
  wrapQtAppsHook,
  cmake,
  marble,
  libsForQt5,
}:
mkDerivation rec {
  pname = "zombietrackergps";
  version = "1.15";

  src = fetchFromGitLab {
    owner = "ldutils-projects";
    repo = pname;
    rev = "v_${version}";
    sha256 = "sha256-z/LFNRFdQQFxEWyAjcuGezRbTsv8z6Q6fK8NLjP4HNM=";
  };

  buildInputs =
    [
      marble.dev
    ]
    ++ (with libsForQt5; [
      qtbase
      qtcharts
      qtsvg
      qtwebengine
      ldutils
    ]);

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  preConfigure = ''
    export LANG=en_US.UTF-8
  '';

  cmakeFlags = [
    "-DLDUTILS_ROOT=${libsForQt5.ldutils}"
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v_";
  };

  meta = with lib; {
    description = "GPS track manager for Qt using KDE Marble maps";
    homepage = "https://www.zombietrackergps.net/ztgps/";
    changelog = "https://www.zombietrackergps.net/ztgps/history.html";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [sohalt];
    platforms = platforms.linux;
  };
}
