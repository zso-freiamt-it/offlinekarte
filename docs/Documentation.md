# Documentation

## Architecture
The Offlinekarte architecture consist of the following dockerised components:

```mermaid
graph TD;
    A[Angular Frontend ZS-Karte] --> B[Strapi Backend ZS-Karte];
    B-->E[(Postgres DB ZS-Karte)]
    A-->C[(Tile Server Offlinekarte)];
    A-->D[(Search Server Offlinekarte)];
```

## Search server
The search server provides search results for the zskarte search function.

<img src="images/Searchserver.png " alt="Screenshot Search Server" width="50%" height="50%">

While the original zskarte project fetches data directly from Geo Admin, Offlinekarte hosts a dedicated search server to ensure offline functionality.


### Data sources
The data for the search server is obtained automatically during the initialization phase of the project. It is recommended to update the data on a regular basis in a 6 to 12 month interval.  
The data fetched by the search server is optained from the following sources:

- [csv_LV95_LN02 swissnames3d](https://www.swisstopo.admin.ch/en/landscape-model-swissnames3d) Get newest csv file (swissnames3d_<year>_2056.csv.zip) e.g. swissnames3d_2026_2056.csv.zip

- [pure_adr: amtl. address verzeichnis](https://www.swisstopo.admin.ch/de/amtliches-verzeichnis-der-gebaeudeadressen) Get newest csv file e.g. amtliches-gebaeudeadressverzeichnis_ch_2056.csv.zip

- [pure_str: amtl str verzeichnis](https://www.swisstopo.admin.ch/de/amtliches-verzeichnis-der-strassen) Get newest csv file e.g. amtliches-strassenverzeichnis_ch_2056.csv.zip

- [AMTOVZ_CSV_WGS84: amtl ortschaftsverz mit plz](https://www.swisstopo.admin.ch/de/amtliches-ortschaftenverzeichnis) Download csv, IMPORTANT with number 4236 and not 2056! e.g. ortschaftenverzeichnis_plz_4326.csv.zip

## Map server

The map tile server provides an offline map layer for use without internet connectivity.
The map layer is integrated into zskarte as an additional map layer `Basiskarten` called `Self-hosted Basiskarten`. If the internet is available, the user can choose between the self-hosted map layer and other map layers from Swisstopo, OpenStreetMap, etc., with additional features such as satellite imagery. If no internet is available, the user is limited to the `Self-hosted Basiskarten`.

<img src="images/offlineMapLayer.png" alt="Screenshot Tile Server" width="50%" height="50%">

### Data source
The data for the tile server is obtained automatically during the initialization phase of the project. It is recommended to update the data on a regular basis in a 6 to 12 month interval.  
The data fetched is optained from the following source: [Geo Admin Vector Tiles](https://docs.geo.admin.ch/visualize-data/vector-tiles.html)

## NTP layer AG
For offline use, a layer with NTPs has been added. The layer can be opened by searching in the list of available layers and is called `NTP Notfalltreffpunkte Offline AG`.

<img src="images/NTPOfflineLayer1.png" alt="Screenshot NTP offline layer" width="50%" height="50%">
<img src="images/NTPOfflineLayer2.png" alt="Screenshot NTP offline layer" width="100%" height="100%">

### Data source
The data for the tile server is obtained automatically during the initialization phase of the project. It is recommended to update the data on a regular basis in a 6 to 12 month interval.

The data fetched is optained from the following source: [Geo Admin BABS Notfalltreffpunkte](https://data.geo.admin.ch/browser/index.html#/collections/ch.babs.notfalltreffpunkte/items/notfalltreffpunkte). 

Note: While the API provides all NTPs in Switzerland, the list is filtered to only include NTPs in Aargau.

After fetching the NTPs are stored in the `GeoJSON` format in the zskarte submodule. The zskarte db init script has been extended with a script to add `NTP Notfalltreffpunkte Offline AG` as a layer.  