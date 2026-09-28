# Dépôt APT de GatorTools

Les paquets .deb des logiciels GatorTools, publiés sur GitHub Pages :
<https://gatortools.github.io/apt/>.

## Installer

```bash
wget -qO- gatortools.github.io/apt/install.sh | sudo sh
sudo apt install clonegator
```

`install.sh` écrit la clé et la source, puis met apt à jour. À la main :

```bash
sudo install -d /etc/apt/keyrings
wget -qO- https://gatortools.github.io/apt/gatortools.gpg | sudo tee /etc/apt/keyrings/gatortools.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/gatortools.gpg] https://gatortools.github.io/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/gatortools.list
sudo apt update
sudo apt install clonegator
```

## Fonctionnement

Aucun paquet n'est rangé dans ce dépôt git. Le workflow `publier`
(`.github/workflows/publier.yml`) télécharge les .deb des trois dernières
releases de chaque dépôt de [logiciels.txt](logiciels.txt), en tire les index
avec `apt-ftparchive`, les signe, et publie le tout sur GitHub Pages
(`outils/construire.sh`).

Il tourne chaque heure, à chaque modification de ce dépôt, et à la demande :

```bash
gh workflow run publier -R GatorTools/apt
```

Ajouter un logiciel : une ligne dans `logiciels.txt`. Ses releases doivent
porter des paquets versionnés, nommés `nom_version_architecture.deb`.

## Clé de signature

« GatorTools APT », ed25519, empreinte `39890A8CE7A8FF4BB8707C7D73655D5A2C7954A6`.
La clé privée est le secret `CLE_SIGNATURE` du dépôt ; une copie de sauvegarde
est gardée hors ligne par Kevin. La clé publique est dans `gatortools.asc` et
`gatortools.gpg`.
