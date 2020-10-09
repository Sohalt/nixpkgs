{ stdenv, pythonPackages, mopidy }:

pythonPackages.buildPythonApplication rec {
  pname = "Mopidy-Scrobbler";
  version = "2.0.0";

  src = pythonPackages.fetchPypi {
    inherit pname version;
    sha256 = "0s8xx4hf3dr76wml5rvr7ys6dh7zidipdx2flbsm0nfd0ciyj494";
  };

  propagatedBuildInputs = [ mopidy pythonPackages.pylast ];

  doCheck = false;

  meta = with stdenv.lib; {
    homepage = "https://github.com/mopidy/mopidy-scrobbler";
    description = "Mopidy extension for scrobbling played tracks to Last.fm";
    license = licenses.asl20;
    maintainers = [ ];
  };
}
