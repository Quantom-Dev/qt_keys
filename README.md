# Quantom Keys - Système de gestion de clés de véhicules pour FiveM

## Description
Quantom Keys est un système complet de gestion de clés de véhicules pour votre serveur FiveM utilisant le framework ESX. Il permet aux joueurs de verrouiller/déverrouiller leurs véhicules, aux concessionnaires de créer et distribuer des clés, et intègre une interface utilisateur moderne pour la gestion des clés.

## Caractéristiques
- Système de verrouillage/déverrouillage de véhicules avec animation et effets sonores
- Interface utilisateur moderne pour la gestion des clés
- Intégration complète avec les concessionnaires automobiles
- Support pour les touches de raccourci configurables
- Compatible avec ox_target pour les interactions
- Menu concessionnaire pour la création et distribution de clés
- Animations et effets visuels lors du verrouillage/déverrouillage
- Support pour le partage de clés entre joueurs
- Génération automatique de clés pour les véhicules possédés
- Intégration avec ox_inventory pour les objets de clés

## Dépendances
- ESX Legacy
- ox_lib
- ox_inventory
- oxmysql

## Installation
1. Téléchargez les fichiers et placez-les dans votre dossier `resources`
2. Ajoutez `ensure quantom_keys` à votre fichier `server.cfg`
3. Importez l'item `vehicle_key` dans votre système d'inventaire ox_inventory
4. Redémarrez votre serveur

## Configuration
Le fichier `config.lua` vous permet de personnaliser entièrement le système:

### Options générales
```lua
Config.NotificationSystem = 'ox' -- Système de notification ('ox' ou 'esx')
Config.UseTarget = true -- Utiliser ox_target pour les interactions

-- Configuration du verrouillage
Config.UseKeybind = true -- Activer/désactiver la touche de raccourci
Config.KeybindKey = 303 -- Touche U pour verrouiller/déverrouiller
Config.LockDistance = 10.0 -- Distance maximale pour verrouiller un véhicule

-- Configuration de l'animation
Config.UseAnimation = true -- Activer/désactiver l'animation
Config.AnimationDict = 'anim@mp_player_intmenu@key_fob@'
Config.AnimationName = 'fob_click'
Config.AnimationDuration = 800 -- Durée de l'animation (en ms)

-- Configuration des sons et effets
Config.LockSound = 'Remote_Control_Close' -- Son lors du verrouillage
Config.UnlockSound = 'Remote_Control_Open' -- Son lors du déverrouillage
Config.FlashLights = true -- Faire clignoter les phares
Config.FlashCount = 2 -- Nombre de clignotements
```

### Menu concessionnaire
```lua
Config.MenuSettings = {
    UseKeyBinding = true, -- Utiliser une touche pour ouvrir le menu
    UseInteractionPoint = false, -- Utiliser un point d'interaction
    InteractionKey = 38, -- Touche E pour interagir
    KeyBinding = 167, -- Touche F6 par défaut
    InteractionPoint = {
        coords = vector3(-31.53, -1113.31, 26.42), -- Position du point d'interaction
        radius = 1.5, -- Rayon d'interaction
        marker = {
            enabled = true,
            type = 1,
            size = vector3(1.0, 1.0, 1.0),
            color = {r = 0, g = 100, b = 255, a = 100},
            bobUpAndDown = false,
            rotate = false
        },
        blip = {
            enabled = true,
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "Gestion des clés"
        }
    }
}
```

### Configuration des items
```lua
Config.Items = {
    KeyItem = 'vehicle_key' -- Nom de l'item de clé dans l'inventaire
}
```

### Traductions
```lua
Config.Locales = {
    ['not_cardealer'] = "Vous n'êtes pas un concessionnaire",
    ['key_created'] = "Clé créée avec succès",
    ['key_received'] = "Vous avez reçu une clé pour le véhicule %s",
    ['key_given'] = "Vous avez donné une clé pour le véhicule %s",
    ['no_vehicle_found'] = "Aucun véhicule trouvé avec cette plaque",
    ['press_e_interact'] = "Appuyez sur ~INPUT_CONTEXT~ pour accéder à la gestion des clés",
    ['vehicle_locked'] = "Véhicule verrouillé",
    ['vehicle_unlocked'] = "Véhicule déverrouillé",
    ['not_owner'] = "Vous n'avez pas les clés de ce véhicule",
    ['no_vehicle'] = "Aucun véhicule à proximité"
}
```

## Fonctionnalités

### Système de verrouillage
Le joueur peut verrouiller/déverrouiller son véhicule en:
- Appuyant sur la touche configurée (U par défaut)
- Utilisant l'item clé dans l'inventaire
- Interagissant avec le véhicule via ox_target

### Menu concessionnaire
Le menu concessionnaire permet aux joueurs ayant le métier `cardealer` de:
- Créer des clés pour les véhicules à proximité
- Créer des clés manuellement en spécifiant la plaque et le modèle
- Donner des clés à d'autres joueurs
- Gérer leurs propres clés

## Intégration avec ox_inventory
Le système s'intègre parfaitement avec ox_inventory. Assurez-vous d'ajouter l'item suivant à votre fichier `items.lua` de ox_inventory:

```lua
['vehicle_key'] = {
    label = 'Clé de véhicule',
    weight = 50,
    stack = false,
    close = true,
    description = "Clé pour un véhicule",
    client = {
        image = 'vehicle_key',
        metadata = {
            plate = "Plaque",
            model = "Modèle"
        }
    }
}
```

## Commandes
```
/givekey [ID du joueur] [plaque] [modèle] - Donne une clé à un joueur (admin)
/createvehiclekey [ID du joueur] [plaque] [modèle] - Crée une clé pour un joueur (admin/concessionnaire)
/cardealerkeys - Ouvre le menu concessionnaire (concessionnaire uniquement)
```

## Exports
```lua
-- Client
exports['quantom_keys']:toggleLock(vehicle) -- Verrouille/déverrouille un véhicule
exports['quantom_keys']:hasKey(plate, callback) -- Vérifie si le joueur a une clé pour cette plaque

-- Serveur
exports['quantom_keys']:CreateKey(source, plate, model) -- Crée une clé pour un joueur
exports['quantom_keys']:CheckHasKey(source, plate) -- Vérifie si un joueur a une clé
exports['quantom_keys']:CopyKey(source, targetId, plate, model) -- Copie une clé pour un autre joueur
```

## Événements
```lua
-- Client
TriggerEvent('quantom_keys:toggleLock') -- Verrouille/déverrouille le véhicule le plus proche
TriggerEvent('quantom_keys:openCardealerMenu') -- Ouvre le menu concessionnaire

-- Serveur
TriggerEvent('quantom_keys:createKey', plate, model) -- Crée une clé
TriggerEvent('quantom_keys:giveKey', targetId, plate, model) -- Donne une clé à un joueur
TriggerEvent('quantom_keys:cardealerCreateKey', targetId, plate, model) -- Crée une clé via le concessionnaire
```

## Développement et Support
Pour toute question ou problème concernant ce script, n'hésitez pas à me contacter.

## Licence
Ce script est distribué sous licence privée et ne peut être redistribué sans autorisation.

---

J'espère que vous apprécierez ce système de gestion de clés pour votre serveur! N'hésitez pas à me faire part de vos commentaires ou suggestions d'amélioration.
