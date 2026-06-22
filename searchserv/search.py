from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from psycopg_pool import AsyncConnectionPool
from contextlib import asynccontextmanager
from typing import List
import os

pool = AsyncConnectionPool(
  "host=offlinekarte-search-db "
  f"port={os.environ.get('SEARCH_DB_PORT', 5432)} "
  f"user={os.environ.get('SEARCH_DB_USER', 'postgres')} "
  f"password={os.environ.get('SEARCH_DB_PASSWORD', 'postgres')} "
  , open=False)

@asynccontextmanager
async def lifespan(instance: FastAPI):
    await pool.open()
    yield
    await pool.close()

app = FastAPI(lifespan=lifespan)

app.add_middleware(CORSMiddleware, 
        allow_origins = ["*"],
        allow_credentials=False, allow_methods=['*'], allow_headers=['*'])

debugExplain = False

class QueryBuilder:
    def __init__(self, columns, table):
        self.query = f"select {columns} from {table} "
        self.args = ()
        self.conds = []
        self.order = ""
    def finish(self):
        self.query += "where " + " and ".join(self.conds) + " "
        self.query += self.order
        self.query += "limit 50;"
        return self.query, self.args
    def extendArgs(self, *a):
        self.args = (*self.args, *a)
    def nameCheck(self, col, text):
        self.conds += [f"{col} like lower(%s || '%%')"]
        self.extendArgs(text)
        return self
    def orderBy(self, col, bbox, sortbbox):
        if sortbbox and bbox is not None:
            self.order = (f"order by {col} <-> "
                           "ST_Transform(ST_Centroid("
                             "ST_MakeEnvelope(%s,%s,%s,%s,21781)), 4326) ")
            self.extendArgs(*bbox)
        else:
            self.order = (f"order by {col} <-> "
                           "ST_Point(8.30882407298, 47.3038127715, 4326) ")
        return self
    def bbox(self, here, bbox):
        if bbox is None:
            return self
        self.conds += [f"ST_Within({here},"
                        "ST_Transform(ST_MakeEnvelope(%s,%s,%s,%s,21781), 4326))"]
        self.extendArgs(*bbox)
        return self
    async def execOn(self, curs):
        query, args = self.finish()
        if debugExplain:
            await curs.execute("explain " + query, args)
            print("\nquery:\n---\n", self.query, "\n---\n",
              *await curs.fetchall(), "\n---")
        await curs.execute(query, args)

def attrdict(label, lon, lat):
    return {"attrs" : {"label": label, "lon": lon, "lat": lat}}

async def get_ort_by_PLZ(curs, text, bbox, sortbbox):
    if not all(x.isdigit() for x in text):
        return []
    await (
      QueryBuilder("ortschaftsname, PLZ, E, N", "import.ortschaften")
        .nameCheck("PLZ", text)
        .bbox("ST_Point(E :: real, N :: real, 4326)", bbox)
        .orderBy("ST_Point(E :: real, N :: real, 4326)", bbox, sortbbox)
        .execOn(curs)
    )
    return [attrdict(f"<i>Ort</i> <b>{plz} {name}</b>", e, n)
            for name, plz, e, n, *_ in await curs.fetchall()]

async def get_ort(curs, text, bbox, sortbbox):
    await (
      QueryBuilder("ortschaftsname, PLZ, E, N", "import.ortschaften")
        .nameCheck("lower(ortschaftsname)", text)
        .bbox("ST_Point(E :: real, N :: real, 4326)", bbox)
        .orderBy("ST_Point(E :: real, N :: real, 4326)", bbox, sortbbox)
        .execOn(curs)
    )
    return [attrdict(f"<i>Ort</i> <b>{plz} {name}</b>", e, n)
            for name, plz, e, n, *_ in await curs.fetchall()]

async def get_strasse(curs, text, bbox, sortbbox):
    await (
      QueryBuilder("STN_LABEL, ZIP_LABEL, ST_x(wgs_point), ST_y(wgs_point)",
           "import.strassen")
         .nameCheck("full_str_lower", text.replace(',',''))
         .bbox("wgs_point", bbox)
         .orderBy("wgs_point", bbox, sortbbox)
         .execOn(curs)
    )
    return [attrdict(f"<i>Str</i> <b>{lbl}</b>, {zpl}", e, n)
            for lbl, zpl, e, n, *_ in await curs.fetchall()]

async def get_addr(curs, text, bbox, sortbbox):
    await (
      QueryBuilder("STN_LABEL, ADR_NUMBER, ZIP_LABEL, ST_x(wgs_point), ST_y(wgs_point)",
          "import.adressen")
        .nameCheck("full_addr_lower", text.replace(',',''))
        .bbox("wgs_point", bbox)
        .orderBy("wgs_point", bbox, sortbbox)
        .execOn(curs)
    )
    return [attrdict(f"<i>Adr</i> <b> {st} {an}</b>, {zl}", e, n)
            for st, an, zl, e, n, *_ in await curs.fetchall()]

async def get_lname(curs, text, bbox, sortbbox):
    await (
      QueryBuilder("NAME, OBJEKTART, closest_town, closest_town_plz, "
          "ST_x(wgs_point), ST_y(wgs_point)", "import.namen")
        .nameCheck("full_name_lower", text.replace(',',''))
        .bbox("wgs_point", bbox)
        .orderBy("wgs_point", bbox, sortbbox)
        .execOn(curs)
    )
    return [attrdict(f"<i>{oa}</i> <b>{name}</b>, <i>Nähe</i> {ctplz} {ct}", e, n)
            for name, oa, ct, ctplz, e, n, *_ in await curs.fetchall()]


@app.get("/search/")
async def func(type: str = "",
      searchText: str = "",
      bbox: str = None,
      sortbbox: bool = False):
    if bbox is not None:
        bbox = bbox.split(',')
        if len(bbox) != 4:
            print("unexpected bbox size")
            bbox = None
            sortbbox = False
    print("bbox:", bbox)
    print("sortbbox:", sortbbox)
    searchText = searchText.strip();
    if type != "locations" or len(searchText) < 2: return {"results": {}}
    async with pool.connection() as conn:
        async with conn.cursor() as curs:
            l = []
            l += await get_ort_by_PLZ(curs, searchText, bbox, sortbbox)
            if(len(l) < 50): l += await get_ort(curs, searchText, bbox, sortbbox)
            if(len(l) < 50): l += await get_strasse(curs, searchText, bbox, sortbbox)
            if(len(l) < 50): l += await get_lname(curs, searchText, bbox, sortbbox)
            if(len(l) < 50): l += await get_addr(curs, searchText, bbox, sortbbox)
            return {"results":l}
    

@app.on_event("shutdown")
def close_them():
    curs.close()
    conn.close()
