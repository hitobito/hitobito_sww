# Hitobito SWW

This hitobito wagon defines the organization hierarchy with groups and roles
of Sww.

## Organization Hierarchy

<!-- roles:start -->
    * Schweizer Wanderwege
      * Schweizer Wanderwege
        * Mitarbeitende: [:layer_and_below_full]
        * Support: [:layer_and_below_full, :admin, :finance, :impersonation, :support, :complete_finance]
    * Benutzerkonten < Schweizer Wanderwege
      * Benutzerkonten
        * Benutzerkonto: []
        * Support: [:layer_full]
    * Fachorganisation < Schweizer Wanderwege
      * Vorstand
        * Präsident: [:contact_data, :layer_and_below_full]
        * Vizepräsident: [:contact_data, :layer_and_below_full]
        * Vorstandsmitglied: [:layer_and_below_full]
      * Geschäftsleitung
        * Geschäftsführer: [:contact_data, :layer_and_below_full, :finance]
        * Kassier: [:finance, :layer_and_below_full]
        * Technischer Leiter: [:layer_and_below_full]
        * Mitarbeiter: [:layer_and_below_full]
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
