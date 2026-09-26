# Changer DNS (Windows)

Script `.bat` pour changer rapidement de serveur DNS sur Windows, sans repasser
par les Paramètres à chaque fois. Menu avec 7 fournisseurs (Google, OpenDNS,
Cloudflare, Quad9, Comodo, Yandex, AdGuard), IPv4 + IPv6 quand disponible.

## Ce qu'il fait

- Se relance automatiquement en administrateur si besoin (`netsh` l'exige)
- Vérifie si une nouvelle version est disponible sur ce dépôt et vous prévient
  (voir [Mise à jour](#mise-à-jour), ne télécharge et ne remplace jamais
  rien tout seul)
- Détecte les interfaces réseau réellement actives (Wi-Fi et/ou Ethernet) via
  PowerShell (`Get-NetAdapter`), pas de bidouille fragile avec `netsh+findstr`
- Applique le DNS choisi à toutes les interfaces actives d'un coup
- Affiche la config DNS finale pour vérifier

## Installation

1. Télécharger [`changer-dns.bat`](changer-dns.bat)
2. Double-clic, choisir un numéro dans le menu

Le fichier est en clair : ouvrez-le dans un éditeur de texte avant de le lancer
si vous voulez vérifier son contenu.

## Mise à jour

Le script compare sa propre version à celle publiée sur ce dépôt (fichier
[`VERSION`](VERSION)) à chaque lancement, avec un délai court (3 secondes) :
s'il ne peut pas joindre GitHub (hors ligne, `curl` absent sur les Windows
antérieurs à la mise à jour 1803), la vérification est simplement ignorée et
le script continue normalement.

**Il ne fait que vous prévenir**, jamais de téléchargement ni de
remplacement automatique. Si une nouvelle version est annoncée, revenez sur
ce dépôt et retéléchargez le fichier vous-même.

## Licence

MIT, voir [LICENSE](LICENSE).
