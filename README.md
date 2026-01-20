# Projekt SQL Analýza dostupnosti potravín v porovnaní so mzdami

>*Autor:* Lukáš Bakši  
*Dátové sady:*  
>- primárna tabuľka (mzdy podľa odvetví, ceny potravín)  
>- sekundárna tabuľka (makroekonomické ukazovatele vrátane HDP, GINI a populácie krajín sveta)

## Úvod do projektu

Projekt bol vytvorený ako projekt pre kurz Datovej akadémie Engeto 

**Zadanie projektu**

V analytickom oddelení nezávislej spoločnosti, ktorá sa zaoberá životnou úrovňou občanov, sme sa dohodli, že sa pokúsime odpovedať na niekoľko definovaných výskumných otázok, ktoré sa týkajú **dostupnosti základných potravín pre širokú verejnosť**. Kolegovia už vydefinovali základné otázky, na ktoré sa pokúsime odpovedať a poskytnúť tieto informácie tlačovému oddeleniu. Toto oddelenie výsledky predstaví na nadchádzajúcej konferencii zameranej na túto oblasť.

**<ins>Výskumné otázky</ins>**

1. Zisťujeme, či mzdy v priebehu rokov rastú vo všetkých odvetviach, alebo v niektorých klesajú.
2. Zisťujeme, koľko litrov mlieka a kilogramov chleba si môžeme kúpiť za prvé a posledné porovnateľné obdobie v dostupných údajoch o cenách a mzdách.
3. Chceme zistiť, ktorá kategória potravín zdražieva najpomalšie, teda má najnižší percentuálny medziročný nárast.
4. Skúmame, či existuje rok, v ktorom bol medziročný nárast cien potravín výrazne vyšší ako rast miezd (viac než 10 %).
5. Zisťujeme, či má výška HDP vplyv na zmeny miezd a cien potravín; inými slovami, ak HDP v jednom roku výraznejšie vzrastie, prejaví sa to na cenách potravín alebo mzdách v tom istom alebo nasledujúcom roku výraznejším rastom.

Ako hlavný zdroje pre náš upravený dataset sme použili verejne dostupné datové sady:
- **czechia_payroll** – Informácie o mzdách v rôznych odvetviach za niekoľko rokov. Dátová sada pochádza z Portálu otvorených dát ČR.
- **czechia_price** – Informácie o cenách vybraných potravín za niekoľko rokov. Dátová sada pochádza z Portálu otvorených dát ČR.
- **countries** – Rôzne informácie o krajinách sveta, napríklad hlavné mesto, mena, národné jedlo alebo priemerná výška obyvateľstva.
- **economies** – HDP, GINI, daňové zaťaženie a ďalšie ekonomické ukazovatele pre daný štát a rok.

## Preprocessing a vytvorenie datových sád - tabuliek

### Princíp tvorenia primárnej tabuľky

Z primárnych datasetov o mzdách a cenách som vytvoril zjednotenú primárnu tabuľku spájaním priemerných miezd podľa odvetví s priemernými cenami potravín pre rovnaké roky.

**Kľúčové kroky v SQL:**
1. agregácia priemernej mzdy podľa odvetvia a roka pomocou AVG
2. agregácia priemernej ceny potravín podľa kategórie a roka pomocou AVG
3. následné spojenie tabuliek pomocou JOIN za základe roka.

Výsledkom je tabuľka, ktorá obsahuje stĺpce industry_code, industry, salary_by_industry, payroll_year, food_type, food_price, food_year (spojené podľa roka do jednej tabuľky s jednotným rokom payroll_year).

*Poznámky k dátam*  
Pre zjednodušenie sú použité celorepublikové hodnoty cien (region_code IS NULL), eliminácia nulových hodnôt pre odvetvia bez dát (industry_branch_code IS NOT NULL) a filtrované typy hodnôt miezd podľa kódu hodnoty (napr. priemerná hrubá mzda).  
Hodnoty sú zaokrúhlené na dve desatinné miesta tam, kde to skripty definujú (príkaz ROUND).  
Ceny prevedené na NUMERIC tam, kde to bolo potrebné; priemery a percentuálne zmeny zaokrúhlené na 2 desatinné miesta.  
Neprebehla žiadna úprava primárnych datasetov mimo vytvárania nových tabuliek a agregácií.  
Regionálne rozdiely nie sú v primárnej analýze zohľadnené, pretože ceny sú filtrované ako celorepublikové.  
Rozsah hodnôt v tabuľkách je od rokov 2006 - 2018, keďže toto je limit dostupných dát z datasetu

### Princíp tvorenia sekundárnej tabuľky

Z datasetov *economies* a *countries* je vytvorená sekundárna tabuľka, ktorá popisuje 
makroekonomické ukazovatele vrátane HDP, GINI a populácie krajín sveta. 
Tabuľky economies a countries sú následne na základe stĺpca **country** prepojené.
Keďže hodnoty s pôvodného datasetu *economies* začínajú už roku 1960, tak sme rozsah limitovali na základe rozsahu z primárnej tabuľky, t.j. **od roku 2006 do roku 2018**.
Následne sme tabuľku upravili len pre Európske krajiny.

## Popis výsledných tabuliek a dátových polí

**Tabuľka primárna**  
*t_lukas_baksi_project_SQL_primary_final*

| industry_code | industry | salary_by_industry | payroll_year | food_type | food_price | food_year |  
|---|---|---|---|---|---|---|

*Poznámka:*  
payroll_year a food_year sú zjednotené pri spojení a hodnoty sú priemery za rok.

**Tabuľka sekundárna**  
*t_lukas_baksi_project_SQL_secondary_final*

| year | country | hdp | currency_code | gini | population | 
|---|---|---|---|---|---|

*Poznámka:*  
Agregovaná na úrovni krajiny, použitá pre analýzy HDP vs mzdy/ceny.


## Otázka č.1: Rastú mzdy vo všetkých odvetviach?

>Zisťujeme, či mzdy v priebehu rokov rastú vo všetkých odvetviach, alebo v niektorých klesajú.

**SQL princíp**

V prvom scripte sme vytvorili **porovnávaciu tabuľku** pre všetky odvetvia priemyslu na základe medziročných zmien.
Porovnanie medziročných párov pre každé odvetvie sme dosiahli pomocou self-joinu na payroll_year = payroll_year + 1. Tento self-join nám pomohol vytvoriť porovnateľné hodnoty miezd v  rámci ročných cyklov. Rozdielom týchto hodnôt sme zistili zmenu hodnôt priemernej mzdy za rok.  
Na základe kladnej či zápornej hodnoty rozdielu sme potom mohli priradiť kategóriu a zistiť, či mzdy v odvetví boli v raste, bez zmeny alebo v poklese.

Vypočítané polia: salary_prev, salary_next, salary_change a kategorizácia INCREASE/DECREASE/NO CHANGE.

Dodatočné scripty spočítajú **počet a výskyt medziročných poklesov** pre každé odvetvie prehľadne a počet zoradí podľa počtu poklesov.

**<ins>Výsledok:</ins>**

Získali sme pre každé odvetvie sériu medziročných zmien a agregovaný počet poklesov.

Zistili sme, že odvetvia s vysokým decrease_count sú tie, kde mzdy klesali častejšie, konkrétne **Těžba a dobývání**. Naopak, z 15 skúmaných odvetví až **9 odvetví** klesalo v skúmanom období iba raz. Prehľad medziročných zmien ukázal, že ide o jednorazové výkyvy a nie systematický trend.  
Vďaka poslednému skriptu sme mohli porovnať výskyty jednotlivých poklesov miezd a dalo by sa vyvodiť, že rok **2012** bol pre všetky odvetvia kritický, pretože 9 z 15 skúmaných odvetví zaznamenal pokles v mzdách.

## Otázka č.2: Kúpyschopnosť mlieka a chleba

> Zisťujeme, koľko litrov mlieka a kilogramov chleba si môžeme kúpiť za prvé a posledné porovnateľné obdobie v dostupných údajoch o cenách a mzdách.

**SQL princíp**

V prvom skripte sme vyfiltrovali dve kategórie potravín *(Mléko polotučné pasterované, Chléb konzumní kmínový)* z primárnej tabuľky a zistili prvý a posledný rok dostupných dát pre naše porovnanie pre každý jeden priemysel zvlášť.

Výpočet, koľko jednotiek potraviny si priemerný zamestnanec v odvetví môže dovoliť došlo pomocou zaokrúhlenej jednoduchej funkcie podielu: ROUND(salary_by_industry / food_price).

Druhý skript poskytuje porovnanie pre prvý a posledný dostupný na základe priemerných hodnôt pre vybrané roky.

Finálne posledný script ukazuje prehľad pre jednotlivé potraviny samostatne. 

**<ins>Výsledok:</ins>**

Výsledkom prvého scriptu je priamy ukazovateľ reálnej kúpnej sily pre základné potraviny (mlieko a chlieba) pre jednotlivé odvetvia separátne v rokoch **2006 a 2018**. 

Vďaka druhému skriptu zistíme, že je evidentný rozdiel medzi rokmi 2006 a 2018, ale prekvapivo len v stovkách jednotiek potravín. Pre názornosť sme si v roku 2018 mohli kúpiť priemerne o **55 kg chleba** a **205 litrov mlieka viac** ako v roku 2006. 

Nakoniec ako bonus zistíme i najzabezpečenejšie odvetvie pre rok 2006 a 2018.  
Pre rok 2006 to bolo **Peněžnictví a pojišťovnictví**, ktoré si mohlo dovoliť kúpiť 2 462 kg chleba a 2 749 litrov mlieka.  
Pre rok 2018 to bolo **Informační a komunikační činnosti**, ktoré si mohlo dovoliť kúpiť 2 314 kg chleba a 2 831 litrov mlieka.  
Naopak pre rok 2006 i 2018 je najmenej zabezpečené odvetvie **Ubytování, stravování a pohostinství**, ktoré si mohlo dovoliť kúpiť 774 kg chleba 947 litrov mlieka v roku 2018.

## Otázka č.3: Ktorá kategória potravín zdražuje najpomalšie?

> Chceme zistiť, ktorá kategória potravín zdražieva najpomalšie, teda má najnižší percentuálny medziročný nárast.

**SQL princíp**

Pre každú kategóriu potravín sa počíta medziročná percentuálna zmena jednoduchou matematickou formulou: 

$$
\Delta p \;=\; \frac{p_2.foodprice - p_1.foodprice}{p_1.foodprice} \cdot 100\%
$$

Následne sa pre každú kategóriu počíta priemer (AVG) týchto medziročných zmien a zoradí sa vzostupne. Len ako kozmetický dodatok sme doplnili znak % za vypočítané hodnoty.

**<ins>Výsledok:</ins>**

Získali sme zoznam kategórií s priemerným ročným percentuálnym nárastom cien. Najnižšie hodnoty indikujú kategórie s najpomalším rastom cien, v našom prípade i dokonca pokles cien (záporné hodnoty) pre **Cukr krystálový (-1,92%)** a **Rajská jablka červená kulatá (-0,74%)**. Naopak najviac zdraželi dovážané produkty ako **Papriky (+7,29%)**.

Z toho nám vyplýva, že kategórie s nízkym priemerným nárastom sú relatívne stabilné z pohľadu cien.

## Otázka č.4: Roky s výraznejším rastom cien než miezd

>Skúmame, či existuje rok, v ktorom bol medziročný nárast cien potravín výrazne vyšší ako rast miezd (viac než 10 %)

**SQL princíp**

Obdobne ako v otázke č.1 je tento script postavený na posune hodnôt +1 a následné porovnanie hodnôt medzi sebou. Pre každý pár po sebe idúcich rokov sa vypočíta priemerný rast miezd a priemerný rast cien potravín v percentách. Použitím matematickej formle z otázky č.3 dostaneme následne 2 samostatné stĺpčeky v percentuálnych podieloch, konkrétne pre mzdy *(salary_growth_prc)* a ceny *(price_growth_prc)*

Následne sa vypočíta rozdiel *price_growth_pct - salary_growth_pct* pre každý medziročný pár do stĺpčeka *difference_pct*.  
**Kladné hodnoty** definujú situáciu, kedy **ceny potravín rástli rýchlejšie** ako mzdy občanov.  
**Záporné hodnoty** naopak definujú situáciu, kedy **mzdy rástli rýchlejšie** ako ceny potravín.

**<ins>Výsledok:</ins>**

Získali sme teda tabuľku, ktorá nám definuje medziročné zmeny cien a miezd. 
Vďaka výsledkom nemožno povedať, že by existoval rok, kde nárast cien výrazne prevýšil nárast miezd, **NIE JE** teda možné identifikovať roky s rozdielom väčším než 10 %. Najbližšie k tomu mal rok **2012** s rozdielom **6,65%**. Tento rok koreluje i s výsledkami z otázky č.1, kde bol rok 2012 kritický a 9 z 15 skúmaných odvetví zaznamenal pokles miezd.  
Naopak najlepšie na tom bol rok **2008**, kde bol rozdiel až **-9,57%**. To znamená, že ceny výrazne klesali a mzdy naopak i naďalej stúpali. 

## Otázka č.5: Vplyv HDP na mzdy a ceny potravín

> Zisťujeme, či má výška HDP vplyv na zmeny miezd a cien potravín. Inými slovami, ak HDP v jednom roku výraznejšie vzrastie, prejaví sa to na cenách potravín alebo mzdách v tom istom alebo nasledujúcom roku výraznejším rastom.

**SQL princíp**

Hlavným rozdielom oproti predošlým otázkam je použitie sekundárnej tabuľky, ktorá poskytuje dodatočné dáta pre jednotlivé krajiny sveta. Keďže jednotlivé krajiny nemajú k dispozícii dáta cien miez a potravín, tak sa náš príklad bude musieť zamieriť **iba na Českú republiku**, ktorej dáta máme k dispozícii z predošlých analýz.

Získanie základných dát dôjde z tabuľky *t_lukas_baksi_project_SQL_secondary_final*, kde vyberieme ročný HDP pre Českú republiku a pripojíme k nemu agregované ročné priemery miezd a cien potravín z *t_lukas_baksi_project_SQL_primary_final* (spojenie podľa roku).

Obdobne ako v predošlých otázkach budeme porovnávať percentuálne hodnoty v medziročných rozdieloch pomocou napojenia dát ako y2 = y1 + 1. Následne sa jednotlivé rastre vypočítajú pomocou percentuálneho podielu rozdielov.

Keďže dáta sú v celku bohaté, pomocou filtrácie vrátime len riadky s neprázdnymi hodnotami rastu cien a zoradíme podľa počiatočného roku.

Ako poslednú analýzu doplníme heuristické prahy ku kategorizácii výsledkov pomocou formuly CASE. Prahy slúžia len pre rýchlo a jednoduchšie porovnávanie:
- ▲▲ pre výrazný rast > 5 % 
- ▲ pre rast > 0 %, 
- ▼ pre pokles < 0 %

**<ins>Výsledok:</ins>**

V niekoľkých rokoch (napr. 2006→2007, 2016→2017) sa HDP výrazne zvýšilo a súčasne rástli aj mzdy a ceny, čo naznačuje súbežný rast ekonomiky a tlaky na mzdy a ceny.

Avšak nie vždy platí, že rast HDP vedie k rastu miezd alebo cien. Sú roky, kde HDP rastie mierne, ale mzdy rastú výraznejšie (napr. 2007→2008), alebo kde HDP klesá a ceny reagujú odlišne (napr. 2008→2009 ceny klesli výrazne).

Žiadny extrémny prípad podľa kritéria "ceny rastú výraznejšie než mzdy o viac než 10 %“ sa v poskytnutých dátach nenašiel. Výsledky však naďalej potvrdzujú, že rok **2012** bol veľmi náročný čo sa týka ako HDP, tak i miezd, pretože ceny potravín výrazne stúpali.

HDP má v niektorých obdobiach súbežný vzťah s mzdami a cenami, ale vzťah nie je stabilný ani dostatočne silný. **Nemôžme teda tvrdiť, že výraznejší rast HDP *vždy* vedie k výraznejšiemu rastu miezd alebo cien v tom istom alebo nasledujúcom roku.**

