rm -rf release
mkdir -p release release/mapserv release/searchserv release/web
(
    cd mapserv
    cp -R data/ prep_ms.sh tileserver.service tileserver-xvfb.service ../release/mapserv/
)
(
    cd searchserv
    cp -R searchserv.service db_connect.py prep_ss.sh db.sql search.py requirements.txt \
        ../release/searchserv
)
cp -R zskarte2/zskarte2/dist release/web/
cp prep_web.sh release/web/
cp nginx.conf release/web/
cp prep.sh release/
