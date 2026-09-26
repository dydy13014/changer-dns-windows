# Changer DNS (Windows)

Script `.bat` pour changer rapidement de serveur DNS sur Windows, sans repasser
par les Paramètres à chaque fois. Menu avec 7 fournisseurs (Google, OpenDNS,
Cloudflare, Quad9, Comodo, Yandex, AdGuard), une option DNS personnalisé, et
une option pour revenir au DNS automatique (DHCP). IPv4 + IPv6 quand
disponible.

## Ce qu'il fait

- Se relance automatiquement en administrateur si besoin (`netsh` l'exige)
- Vérifie si une nouvelle version est disponible sur ce dépôt et vous prévient
  (voir [Mise à jour](#mise-à-jour), ne télécharge et ne remplace jamais
  rien tout seul)
- Détecte les interfaces réseau réellement actives (Wi-Fi et/ou Ethernet) via
  PowerShell (`Get-NetAdapter`), pas de bidouille fragile avec `netsh+findstr`
- Applique le DNS choisi à toutes les interfaces actives d'un coup
- Option **DNS personnalisé** (menu 8) : saisie manuelle d'une IPv4 (et
  optionnellement IPv6) si vous voulez un fournisseur qui n'est pas dans la
  liste
- Option **Restaurer le DNS automatique** (menu 9) : repasse toutes les
  interfaces actives en DHCP, pour annuler un changement précédent
- Signale explicitement si une commande `netsh` échoue sur une interface
  (adresse invalide, interface qui refuse le changement...), au lieu d'un
  échec silencieux
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
