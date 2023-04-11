```
docker-compose exec rails bash
rails runner ../hitobito_sww/lib/import_fix/stats_import_csv.rb
```

```
RAILS_MAIL_DELIVERY_CONFIG='address: disabled' rails runner ../hitobito_sww/lib/import_fix/repair_emails_and_passwords.rb
```
