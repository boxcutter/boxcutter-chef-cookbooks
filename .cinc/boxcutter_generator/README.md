# Boxcutter Chef generator

Template for creating new cookbooks.

This skeleton was initially generated with: `cinc generate generator boxcutter_generator`

## Usage

1. Generate a cookbook using `cinc generate cookbook ...` with `cinc-workstation`, passing in the path to this generator as an argument

```shell
# generate your new cookbook using the generator as a template
cinc generate cookbook COOKBOOK_NAME \
  --copyright 'Taylor.dev, LLC' \
  --email 'noreply@boxcutter.dev' \
  --license 'apachev2' \
  --kitchen dokken \
  --generator-cookbook .cinc/boxcutter_generator
```

## Differences from the default generator skeleton

- kitchen.dokken.yaml uses images from Boxcutter dockerhub
- kitchen.dokken.yaml uses cinc instead of chef
- kitchen.dokken.yaml defaults to using Ubuntu 22.04 as the test platform
- metadata.rb notes that version should never change
- Policyfile adds dependency on the test cookbook

Here is a comparison of the file trees created by this generator and the default cinc-workstation generator:

```
boxcutter_generator/           default_cinc-workstation-generator/
  CHANGELOG.md                   CHANGELOG.md
  chefignore                     chefignore
    compliance/                    compliance/
    inputs/                        inputs/
    profiles/                      profiles/
    README.md                      README.md
    waivers/                       waivers/
  .gitignore                     .gitignore
  kitchen.yml                    kitchen.yml
  LICENSE                        LICENSE
  metadata.rb                    metadata.rb
  Policyfile.rb                  Policyfile.rb
  README.md                      README.md
  recipes/                       recipes/
    default.rb                     defualt.rb
  test/                          test/                                 
    cookbooks/                     integration/
      <COOKBOOK_NAME>_test           default/
        metadata.rb                    default_test.rb
        recipes/
          default.rb
```
