{ lib, buildPythonPackage, fetchPypi}:

buildPythonPackage rec {
  pname = "css-html-js-minify";
  version = "2.5.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0v3l2dqdk2y4r6ax259gs4ij1zzm9yxg6491s6254vs9w3vi37sa";
    extension = "zip";
  };

  doCheck = false;

  pythonImportsCheck = [ "css_html_js_minify" ];

  meta = with lib; {
    description = "Async single-file cross-platform no-dependencies Minifier for the Web";
    homepage = "https://github.com/juancarlospaco/css-html-js-minify";
    license = licenses.gpl3;
    maintainers = with maintainers; [ sohalt ];
  };
}
