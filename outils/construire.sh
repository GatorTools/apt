#!/usr/bin/env bash
#
# Construit le dépôt APT de GatorTools dans public/, prêt à publier.
#
#   CLE=<empreinte GPG> ./outils/construire.sh
#
# Pour chaque dépôt de logiciels.txt, les paquets .deb des trois dernières
# releases sont téléchargés dans pool/ ; apt-ftparchive en tire les index,
# et la clé désignée par CLE signe le tout (InRelease, Release.gpg).
#
# Il faut : gh (connecté, ou GH_TOKEN), apt-utils, gnupg, et la clé privée
# dans le trousseau de gpg.
set -euo pipefail
cd "$(dirname "$0")/.."

: "${CLE:?désigner la clé de signature : CLE=<empreinte>}"
VERSIONS_GARDEES=3
SUITE=stable
ARCHITECTURES="amd64 arm64"

rm -rf public
mkdir -p public/pool/main

# ------------------------------------------------------------------ paquets ---

grep -v -e '^#' -e '^\s*$' logiciels.txt | while read -r depot; do
    etiquettes=$(gh release list -R "$depot" --limit 50 --exclude-drafts \
                     --json tagName,createdAt --jq 'sort_by(.createdAt) | reverse | .[].tagName' \
                 | head -n "$VERSIONS_GARDEES")
    for etiquette in $etiquettes; do
        # Seulement les paquets versionnés (nom_version_arch.deb) : pas les
        # copies qui servent aux adresses courtes (clonegator.deb).
        gh release download "$etiquette" -R "$depot" -p '*_*_*.deb' -D public/pool/main --skip-existing
    done
    echo "$depot : $(echo $etiquettes | wc -w) release(s)"
done

# On range chaque paquet sous pool/main/<initiale>/<nom>/, comme Debian.
for deb in public/pool/main/*.deb; do
    nom=$(dpkg-deb --field "$deb" Package)
    mkdir -p "public/pool/main/${nom:0:1}/$nom"
    mv "$deb" "public/pool/main/${nom:0:1}/$nom/"
done

# ------------------------------------------------------------------- index ---

cd public
for architecture in $ARCHITECTURES; do
    dossier="dists/$SUITE/main/binary-$architecture"
    mkdir -p "$dossier"
    apt-ftparchive --arch "$architecture" packages pool > "$dossier/Packages"
    gzip -9 --keep --no-name "$dossier/Packages"
done

apt-ftparchive \
    -o APT::FTPArchive::Release::Origin=GatorTools \
    -o APT::FTPArchive::Release::Label=GatorTools \
    -o APT::FTPArchive::Release::Suite="$SUITE" \
    -o APT::FTPArchive::Release::Codename="$SUITE" \
    -o APT::FTPArchive::Release::Architectures="$ARCHITECTURES" \
    -o APT::FTPArchive::Release::Components=main \
    -o APT::FTPArchive::Release::Description="Logiciels GatorTools" \
    release "dists/$SUITE" > Release.tmp   # hors du dossier : il se listerait lui-même
mv Release.tmp "dists/$SUITE/Release"

gpg --batch --yes --local-user "$CLE" --clearsign --output "dists/$SUITE/InRelease" "dists/$SUITE/Release"
gpg --batch --yes --local-user "$CLE" --armor --detach-sign --output "dists/$SUITE/Release.gpg" "dists/$SUITE/Release"
cd ..

# --------------------------------------------------------- clé et accueil ---

cp gatortools.asc gatortools.gpg install.sh public/
cp index.html public/
touch public/.nojekyll
echo "public/ : $(find public/pool -name '*.deb' | wc -l) paquet(s)"
