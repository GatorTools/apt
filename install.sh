#!/bin/sh
# Ajoute le dépôt APT de GatorTools à Debian ou Ubuntu :
#
#   wget -qO- gatortools.github.io/apt/install.sh | sudo sh
#
# Écrit la clé de signature dans /etc/apt/keyrings/gatortools.asc, la source
# dans /etc/apt/sources.list.d/gatortools.list, puis met apt à jour. Sans
# risque à relancer : les deux fichiers sont simplement réécrits.
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root:  wget -qO- gatortools.github.io/apt/install.sh | sudo sh" >&2
    exit 1
fi

install -d -m 755 /etc/apt/keyrings
cat > /etc/apt/keyrings/gatortools.asc <<'CLE'
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEarqaExYJKwYBBAHaRw8BAQdAbSeB2oF6rk5FWkt0GAlqE76YMxlsU20xvcDV
hVu6W0W0DkdhdG9yVG9vbHMgQVBUiJMEExYKADsWIQQ5iQqM56j/S7hwfH1zZV1a
LHlUpgUCarqaEwIbAwULCQgHAgIiAgYVCgkICwIEFgIDAQIeBwIXgAAKCRBzZV1a
LHlUpsr3AP4iRg+u/t6T57JOxDpnDdRsv04E5+PLNo6mMMxcYbaIsAD/bwEK5J3g
5dPpmYDoThWQc3bJ8zaWwzrN86JIzv0qjQI=
=HZlZ
-----END PGP PUBLIC KEY BLOCK-----
CLE
chmod 644 /etc/apt/keyrings/gatortools.asc

echo "deb [signed-by=/etc/apt/keyrings/gatortools.asc] https://gatortools.github.io/apt stable main" \
    > /etc/apt/sources.list.d/gatortools.list

apt-get update -qq
echo "GatorTools repository added. Install CloneGator with:  sudo apt install clonegator"
