{ stdenv, fetchurl, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "malojaserver";
  version = "2.9.8";
  format = "wheel";

  src = python3Packages.fetchPypi {
    inherit pname version format;
    python = "py3";
    sha256 = "264df4194cc47b54eb6d9d953e2e31765a2e3781df0e7e01fc94d532430d86f7";
  };

  propagatedBuildInputs = with python3Packages; [
    nimrodel
    setproctitle
    lru-dict
    lesscpy
    Wand
    htmlmin
    doreah
  ];

  meta = with stdenv.lib; {
    description = "Self-hosted music scrobble database to create personal listening statistics and charts";
    homepage    = "https://github.com/krateng/maloja";
    license     = with licenses; [gpl3];
    maintainers = with maintainers; [ sohalt ];
    platforms   = platforms.unix;
  };
}
