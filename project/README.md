# DVDA projektas - Paskolos įvertinimo aplikacija
## Aprašymas
Šis projektas buvo skirtas sukurti aplikacija, skirta paskolos įvertinimui. Projektas susidėjo iš skirtingų dalių:
- **Žvalgomoji analizė** - Atlikta duomenų žvalgomoji analizė, kuri leidžia susipažinti su duomenimis bei surasti ryšius ar anomalijas tarp duomenų.
- **Modelio kūrimas** - Šioje dalyje buvo kuriamas modelis, kuris labiausiai tiktų esantiems duomenimis. Įvertinimui buvo naudota AUC įvertinimas.
- **"Shiny" aplikacijos kūrimas** - Patalpinti egzistuojantį modelį bei įvykdyti norimus veiksmus, buvo sukurta "web" aplikaciją, kuri leidžia interaktyviai naudotis esamu modeliu. Ją galima pasiekti adresu - https://stelmokas-popiera-dvda.shinyapps.io/loan_app/
## Aplankų struktūra

```markdown
├── project
│   ├── 1-data
│   ├── 2-report
│   ├── 3-R
│   ├── 4-model
│   ├── 5-predictions
│   ├── app
```
- **1-data** - Šiame aplanke yra pateikti pagrindiniai duomenys, kurie bus naudojami apmokyti bei testuoti modelį. Duomenis galima gauti adresu - https://drive.google.com/drive/folders/17NsP84MecXHyctM94NLwps_tsowld_y8
- **2 -report** - Šiame aplanke yra žvalgomosios analizės fail'as, kuriame atlikta duomenų žvalgomoji analizė.
- **3 - R** - Šiame aplanke yra pagrindiniai fail'ai, kurie buvo sukurti duomenų transformacijai bei modelio sukūrimui
- **3 - model** - šiame aplanke yra modeliai, kurie buvo sukurti ir pasirinktas vienas, kuris buvo  naudojamas tolimesniems veiksmams.
- **5-predictions**  - Šiame aplanke yra spėjimai, kuriuos atliko geriausias modelis.
- **app** - Šiame aplanke yra "Shiny" aplikacijos programos fail'as, kuriuo pagalba buvo sukurtas interenetinis puslapis ir patalpintas debesyje
## Programinių failų paleidimas

**data_transformation.R**
``` bash
cd ./project/3-R/
Rscript data_transformation.R
```
**modelling.R**
``` bash
cd ./project/3-R/
Rscript modelling.R
```
**loan_app.R**
``` bash
cd ./project/3app/
Rscript -e 'shiny::runApp("./", launch.browser = TRUE)'
```
