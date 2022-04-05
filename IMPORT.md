# Import People FO

`rails import:people_fo[42]`

whereas 42 represents id of Group 'Mitglieder'

# Import Invoices FO

`rails import:people_fo[42]`

whereas 42 represents FO Layer id

# Re-Import People

## Delete Person entries

To clear previously imported people fo ...
```
person_csv = Wagons.find('sww').root.join('db/seeds/production/people_fo.csv')
people = CSV.read(person_csv)
people.shift
alnr = people.collect {|p| p[26]}
Person.where(alabus_id: alnr).each {|p| p.destroy!}
```

## Check for orphins

```
pids = Person.all.pluck(:id)
ActsAsTaggableOn::Tagging.where(taggable_type: 'Person').where.not(taggable_id: pids).count
AdditionalEmail.where(contactable_type: 'Person').where.not(contactable_id: pids).count
SocialAccount.where(contactable_type: 'Person').where.not(contactable_id: pids).count
PhoneNumber.where(contactable_type: 'Person').where.not(contactable_id: pids).count
Note.where(subject_type: 'Person').where.not(subject_id: pids).count
```
