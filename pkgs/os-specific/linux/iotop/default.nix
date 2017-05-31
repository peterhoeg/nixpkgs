{ stdenv, fetchurl, python2Packages }:

let
  policy = ''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
        "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>
  <vendor>The systemd Project</vendor>
  <vendor_url>http://www.freedesktop.org/wiki/Software/systemd</vendor_url>

  <action id="org.freedesktop.systemd1.reply-password">
    <description>Send passphrase back to system</description>
    <message>Authentication is required to send the entered passphrase back to the system.</message>
    <defaults>
      <allow_any>no</allow_any>
      <allow_inactive>no</allow_inactive>
      <allow_active>auth_admin_keep</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">/nix/store/4mhj2swvnacffi9zyj54gd5ig343jwga-systemd-232/lib/systemd/systemd-reply-password</annotate>
  </action>

  <action id="org.freedesktop.systemd1.manage-units">
    <description>Manage system services or other units</description>
    <message>Authentication is required to manage system services or other units.</message>
    <defaults>
      <allow_any>auth_admin</allow_any>
      <allow_inactive>auth_admin</allow_inactive>
      <allow_active>auth_admin_keep</allow_active>
    </defaults>
  </action>
</policyconfig>'';

in python2Packages.buildPythonApplication rec {
  name = "iotop-${version}";
  version = "0.6";

  src = fetchurl {
    url = "http://guichaz.free.fr/iotop/files/${name}.tar.bz2";
    sha256 = "0nzprs6zqax0cwq8h7hnszdl3d2m4c2d4vjfxfxbnjfs9sia5pis";
  };

  postInstall = ''
  '';

  # there are no tests as of v0.6
  doCheck = false;

  meta = with stdenv.lib; {
    description = "A tool to find out the processes doing the most IO";
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.linux;
  };
}
