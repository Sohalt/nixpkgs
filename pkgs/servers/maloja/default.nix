{ stdenv, fetchurl, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "malojaserver";
  version = "2020-12-13-git";

  src = fetchFromGitHub {
    owner = "krateng";
    repo = "maloja";
    rev = "ce17f77cfdfc0097aaf155e51491af7d06e9a204";
    sha256 = "18z8gr9pwxa3j51cpg2clv1cdrmmjd622yviwc1p5vq2h800m9fc";
  };

  #patches = [ ./fixup.patch ];

  doCheck = false;
  preConfigure = ''
    export HOME=$(mktemp -d)
  '';

  propagatedBuildInputs = with python3Packages; [
    nimrodel
    setproctitle
    lru-dict
    lesscpy
    Wand
    htmlmin
    doreah
    css-html-js-minify
  ];

  meta = with stdenv.lib; {
    description = "Self-hosted music scrobble database to create personal listening statistics and charts";
    homepage    = "https://github.com/krateng/maloja";
    license     = with licenses; [gpl3];
    maintainers = with maintainers; [ sohalt ];
    platforms   = platforms.unix;
  };
}
