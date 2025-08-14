from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from db_connect import db_connect   

conn, curs = db_connect()

app = FastAPI()
app.add_middleware(CORSMiddleware, 
        allow_origins = ["http://localhost", "http://localhost:8000"],
        allow_credentials=True, allow_methods=['*'], allow_headers=['*'])

def attrdict(label, lon, lat):
    return {"attrs" : {"label": label, "lon": lon, "lat": lat}}

def get_ort_by_PLZ(curs, text):
    if not all(x.isdigit() for x in text):
        return []
    curs.execute("""
    select ortschaftsname, PLZ, E, N from import.ortschaften
    where PLZ like lower(%s || '%%')
    limit 50;
    """, (text,))
    return [attrdict(f"<i>Ort</i> <b>{plz} {name}</b>", e, n)
            for name, plz, e, n, *_ in curs.fetchall()]

def get_ort(curs, text):
    curs.execute("""
    select ortschaftsname, PLZ, E, N from import.ortschaften
    where lower(ortschaftsname) like lower(%s || '%%')
    limit 50;
    """, (text,))
    return [attrdict(f"<i>Ort</i> <b>{plz} {name}</b>", e, n)
            for name, plz, e, n, *_ in curs.fetchall()]

def get_strasse(curs, text):
    curs.execute("""
    select STN_LABEL, ZIP_LABEL, ST_x(wgs_point), ST_y(wgs_point)
    from import.strassen
    where full_str_lower like lower(%s || '%%')
    order by wgs_point <-> ST_Point(8.30882407298, 47.3038127715, 4326) 
    limit 50;
    """, (text.replace(',',''),))
    return [attrdict(f"<i>Str</i> <b>{lbl}</b>, {zpl}", e, n)
            for lbl, zpl, e, n, *_ in curs.fetchall()]

def get_addr(curs, text):
    curs.execute("""
    select STN_LABEL, ADR_NUMBER, ZIP_LABEL, ST_x(wgs_point), ST_y(wgs_point)
    from import.adressen
    where full_addr_lower like lower(%s || '%%')
    order by wgs_point <-> ST_Point(8.30882407298, 47.3038127715, 4326) 
    limit 50;
    """, (text.replace(',',''),))
    return [attrdict(f"<i>Adr</i> <b> {st} {an}</b>, {zl}", e, n)
            for st, an, zl, e, n, *_ in curs.fetchall()]

def get_lname(curs, text):
    curs.execute("""
    select NAME, OBJEKTART, closest_town, closest_town_plz, ST_x(wgs_point), ST_y(wgs_point)
    from import.namen
    where full_name_lower like lower(%s || '%%')
    order by wgs_point <-> ST_Point(8.30882407298, 47.3038127715, 4326) 
    limit 50;
    """, (text.replace(',',''),))
    return [attrdict(f"<i>{oa}</i> <b>{name}</b>, <i>Nähe</i> {ctplz} {ct}", e, n)
            for name, oa, ct, ctplz, e, n, *_ in curs.fetchall()]


@app.get("/search/")
async def func(type: str = "", searchText: str = ""):
    if type != "locations" or len(searchText) < 2: return {"results": {}}
    l = get_ort_by_PLZ(curs, searchText)
    if(len(l) < 50): l += get_ort(curs, searchText)
    if(len(l) < 50): l += get_strasse(curs, searchText)
    if(len(l) < 50): l += get_lname(curs, searchText)
    if(len(l) < 50): l += get_addr(curs, searchText)
    return {"results":l}
    

@app.on_event("shutdown")
def close_them():
    curs.close()
    conn.close()
