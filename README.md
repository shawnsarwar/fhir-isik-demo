# fhir-isik-demo

requirements:
 - yq (yaml extended jq)
 - npm

expectations:
 - you're running this in a linux environment

The purpose of this demo is to show the bootstrapping of a FHIR server with a set of profile dependencies. In this case a set of versioned ISIK profiles, which are defined in `/hapi/config/package.json` as FHIR profiles are available via the simplifier npm repository. Note the `.npmrc` file which points to simplifier instead of the general repo. We will eventually take the same approach with the BFARM terminology packages.

```json
{
    "dependencies": {
      "hl7.fhir.r4.core": "4.0.1",
      "hl7.terminology.r4": "5.5.0",
      "hl7.fhir.uv.ips": "1.0.0",
      "ihe.mhd.fhir": "4.0.1",
      "de.basisprofil.r4": "1.4.0",
      "kbv.basis": "1.6.0-Expansions",
      "de.gematik.isik-basismodul": "^2.0.6",
      "de.gematik.isik-dokumentenaustausch": "^2.0.1",
      "de.gematik.isik-medikation": "^2.0.2",
      "de.gematik.isik-terminplanung": "^2.0.3",
      "de.gematik.isik-vitalparameter": "^2.0.3",
      "de.medizininformatikinitiative.kerndatensatz.medikation": "1.0.10",
      "dvmd.kdl.r4.2021": "2021.1.1",
      "rki.demis.common": "1.0.1",
      "rki.demis.disease": "1.3.0"
    }
  }
  
```

After running the populate_deps.sh the correct package-lock.json is created from the repository:
```json
{
    "name": "config",
    "lockfileVersion": 3,
    "requires": true,
    "packages": {
        "": {
            "dependencies": {
                "de.basisprofil.r4": "1.4.0",
                "de.gematik.isik-basismodul": "^2.0.6",
                "de.gematik.isik-dokumentenaustausch": "^2.0.1",
                "de.gematik.isik-medikation": "^2.0.2",
                "de.gematik.isik-terminplanung": "^2.0.3",
                "de.gematik.isik-vitalparameter": "^2.0.3",
                "de.medizininformatikinitiative.kerndatensatz.medikation": "1.0.10",
                "dvmd.kdl.r4.2021": "2021.1.1",
                "hl7.fhir.r4.core": "4.0.1",
                "hl7.fhir.uv.ips": "1.0.0",
                "hl7.terminology.r4": "5.5.0",
                "ihe.mhd.fhir": "4.0.1",
                "kbv.basis": "1.6.0-Expansions",
                "rki.demis.common": "1.0.1",
                "rki.demis.disease": "1.3.0"
            }
        },
        "node_modules/de.basisprofil.r4": {
            "version": "1.4.0",
            "resolved": "https://packages.simplifier.net/de.basisprofil.r4/1.4.0",
            "integrity": "sha1-IZ1yyGg9VfHvK0/NVo58eY2pHoQ="
        }...continues
```

And, importantly a corresponding `output.yaml` is generated which is in the proper format to insert the resolved dependencies into the `implementationguides` section of the `hapi.yaml` file:

```yaml
de_basisprofil_r4:
  name: de.basisprofil.r4
  version: 1.4.0
  url: https://packages.simplifier.net/de.basisprofil.r4/1.4.0
  installMode: STORE_AND_INSTALL
  reloadExisting: false
de_gematik_isik-basismodul:
  name: de.gematik.isik-basismodul
  version: 2.0.6
  url: https://packages.simplifier.net/de.gematik.isik-basismodul/2.0.6
  installMode: STORE_AND_INSTALL
  reloadExisting: false
de_gematik_isik-dokumentenaustausch:
  name: de.gematik.isik-dokumentenaustausch
  version: 2.0.1
  url: https://packages.simplifier.net/de.gematik.isik-dokumentenaustausch/2.0.1
  installMode: STORE_AND_INSTALL
  reloadExisting: false
...continues
```

*Note, you must currently update the hapi.yaml file manually*
In the future it should be done via CI when changes are made to the package.json.
It is also possible and highly preferable in production to not link to packages via url, but to download and cache them as part of package to be referenced locally. This will help us avoid configuration creep.

Once the `hapi.yaml` file is up to date, you can start the FHIR container and it will pick-up and install the dependencies from the remote repository.