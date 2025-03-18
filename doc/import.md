# Mod Profile import

Im Zuge von https://github.com/hitobito/hitobito_sww/issues/228 wurde ein
für einen Export aus einem Umsystem (CMS(??) -> mod_profile.xlsx) ein neuer
Import implementiert.

Dabei werden Personen, deren E-Mail noch nicht existiert in die Gruppe
`Group::Benutzerkonten` im Dachverband importiert.

Siehe dazu `rake import:mod_profile_import`

