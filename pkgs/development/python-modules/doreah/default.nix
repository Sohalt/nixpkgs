{ lib, buildPythonPackage, fetchPypi, lxml, beautifulsoup4, jinja2, pyyaml, requests, MechanicalSoup, parse }:

buildPythonPackage rec {
  pname = "doreah";
  version = "1.6.11";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    python = "py3";
    sha256 = "7c7c4f57197bd5b2b20c42d1e7769043ef30122e42bb0405bca0cee3d4bb18e2";
  };

  propagatedBuildInputs = [ lxml beautifulsoup4 jinja2 pyyaml requests MechanicalSoup parse ];

  pythonImportsCheck = [ "doreah" ];

  meta = with lib; {
    description = "Personal package of helpful utilities";
    homepage = "https://github.com/krateng/doreah/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ sohalt ];
  };
}
