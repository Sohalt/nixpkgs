{ lib, buildPythonPackage, fetchPypi, lxml, beautifulsoup4, jinja2, pyyaml, requests, MechanicalSoup, parse }:

buildPythonPackage rec {
  pname = "doreah";
  version = "1.6.12";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    python = "py3";
    sha256 = "18mkbacqmv0dkyip4w02hmczjqzv467j8xs6wdcm0varaca8cvy6";
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
