{ stdenv, fetchurl,
  makeUserService, userServiceHook }:

stdenv.mkDerivation rec {
  name = "hello-2.10";

  src = fetchurl {
    url = "mirror://gnu/hello/${name}.tar.gz";
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
  };

  nativeBuildInputs = [ userServiceHook ];

  userService = makeUserService {
    name = "hello";
    dbus = "org.gnu.hello";
    exec = "bin/hello";
    description = "Hello World!";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A program that produces a familiar, friendly greeting";
    longDescription = ''
      GNU Hello is a program that prints "Hello, world!" when you run it.
      It is fully customizable.
    '';
    homepage = http://www.gnu.org/software/hello/manual/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ eelco ];
    platforms = platforms.all;
  };
}
