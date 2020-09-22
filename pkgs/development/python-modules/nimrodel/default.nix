{ lib, buildPythonPackage, fetchPypi, bottle, waitress, doreah }:

buildPythonPackage rec {
  pname = "nimrodel";
  version = "0.6.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "44432b11b71f0c5b39c441f5102333707b947490b5dc7594bf8de91308b5c9d3";
  };

  propagatedBuildInputs = [ bottle waitress doreah];

  pythonImportsCheck = [ "nimrodel" ];

  meta = with lib; {
    description = "Bottle-wrapper to make python objects accessible via HTTP API";
    homepage = "https://github.com/krateng/nimrodel/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ sohalt ];
  };
}
