{
  mkDerivation,
  extra-cmake-modules, kdoctools,
  libpthreadstubs,
  bluez-qt, kactivities, kauth, kconfig, kdbusaddons, kdelibs4support,
  kglobalaccel, ki18n, kidletime, kio, knotifyconfig, kwayland, libkscreen,
  networkmanager-qt, plasma-workspace, qtx11extras, solid, udev,
  makeUserService, userServiceHook
}:

mkDerivation rec {
  name = "powerdevil";

  nativeBuildInputs = [ extra-cmake-modules kdoctools userServiceHook ];

  buildInputs = [
    kconfig kdbusaddons knotifyconfig solid udev bluez-qt kactivities kauth
    kdelibs4support kglobalaccel ki18n kio kidletime kwayland libkscreen
    networkmanager-qt plasma-workspace qtx11extras
    libpthreadstubs
  ];

  userService = makeUserService {
    name = "woot";
    dbus = "fef.fefe.fefe";
    exec = "@out@/bin/woot";
    description = "fefef";
  };
}
