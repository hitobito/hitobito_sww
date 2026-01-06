# Droptours Export

Es wird ein täglicher Export der Mitglieder für Droptours erstellt und per SFTP hochgeladen.
Jede Fachorganisation kann konfigurieren, welche Mitgliedergruppen im Export berücksichtigt werden, 
indem in den Einstellungen der Mitgliedergruppen unter "Weitere Einstellungen" die Option 
"In Droptours Export einbeziehen" aktiviert wird.

Die Angaben zum SFTP-Server müssen für jede Fachorganisation, welche den Export nutzt, im config file
`config/droptours-upload-config.yml` hinterlegt werden. Die Datei muss im YAML-Format vorliegen und 
einen Hash mit den Fachorganisations-IDs als Schlüssel enthalten. Die values sind wiederum Hashes mit den
folgenden möglichen Parametern:
 
- `host` (erforderlich): Der Hostname oder die IP-Adresse des SFTP-Servers.
- `port` (optional): Der Port des SFTP-Servers. Standard ist 22.
- `user` (erforderlich): Der Benutzername für die Authentifizierung am SFTP-Server.
- `password` (optional): Das Passwort für die Authentifizierung am SFTP-Server.
- `private_key` (optional): Der private SSH-Schlüssel für die Authentifizierung am SFTP-Server.
- `remote_path` (erforderlich): Der Pfad auf dem SFTP-Server, in den die Exportdateien hochgeladen werden sollen.

Entweder `password` oder `private_key` muss angegeben werden.

Beispiel:

```yaml
---
42:
  host: sftp.droptours.com
  port: 22
  user: fachorganisation42
  password: "*****"
  remote_path: /uploads/exports/
43:
  host: some.other-sftp.com
  user: fachorganisation43
  private_key: >
    -----BEGIN OPENSSH PRIVATE KEY-----
    abcd1234...
    -----END OPENSSH PRIVATE KEY-----
  remote_path: /data/exports/
```
