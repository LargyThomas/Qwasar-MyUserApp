# Welcome to My Users App


## Task
Créer une API REST en Ruby avec Sinatra permettant de gérer des utilisateurs : création, authentification, mise à jour et suppression. 
Le challenge était de gérer les sessions, la sécurité des mots de passe et la persistance des données avec SQLite.

## Description
L'API expose plusieurs routes HTTP (GET, POST, PUT, DELETE) pour gérer les utilisateurs.
Les données sont stockées dans une base SQLite. Les mots de passe ne sont jamais retournés dans les réponses. Un système de session permet de sécuriser les actions sensibles (mise à jour, suppression).

## Installation
gem install sinatra
gem install sqlite3

## Usage
Le serveur tourne sur http://localhost:8080.
| Méthode | Route | Description |
|--------|-------|-------------|
| GET | `/users` | Récupère tous les utilisateurs |
| POST | `/users` | Crée un utilisateur |
| POST | `/sign_in` | Connecte un utilisateur |
| PUT | `/users` | Met à jour le mot de passe (connecté) |
| DELETE | `/sign_out` | Déconnecte l'utilisateur |
| DELETE | `/users` | Supprime le compte (connecté) |


### The Core Team


<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
