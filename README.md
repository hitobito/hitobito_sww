# Hitobito SWW

This hitobito wagon defines the organization hierarchy with groups and roles
of Sww.

## Organization Hierarchy


<!-- roles:start -->
    * Schweizer Wanderwege
      * Schweizer Wanderwege
        * Mitarbeitende: [:layer_and_below_full]
        * Support: [:layer_and_below_full, :admin, :impersonation, :support, :layer_and_below_finance]
    * Benutzerkonten < Schweizer Wanderwege
      * Benutzerkonten
        * Benutzerkonto: []
        * Support: [:layer_full]
        * Staging User: []
    * Fachorganisation < Schweizer Wanderwege
      * Fachorganisation
      * Vorstand
        * Präsident: [:group_and_below_full]
        * Vizepräsident: [:group_and_below_full]
        * Vorstandsmitglied: [:group_and_below_full]
        * Rechnungswesen: [:finance]
        * Leserechte: [:layer_and_below_read]
        * Schreibrechte: [:layer_and_below_full]
      * Geschäftsleitung
        * Geschäftsführer: [:group_and_below_full]
        * Kassier: [:group_and_below_full]
        * Technischer Leiter: [:group_and_below_full]
        * Mitarbeiter: [:group_and_below_full]
        * Rechnungswesen: [:finance]
        * Leserechte: [:layer_and_below_read]
        * Schreibrechte: [:layer_and_below_full]
      * Gremium/Projektgruppe
        * Leitung: [:group_and_below_full]
        * Mitglied: [:group_and_below_read]
      * Mitglieder
        * Aktivmitglied: []
        * Passivmitglied: []
        * Freimitglied: []
        * Organisationen: []
        * Partner: []
        * Spender: []
        * Magazin Abonnent: []
    * Global
      * Kontakte
        * Kontakt: []

(Output of rake app:hitobito:roles)
<!-- roles:end -->