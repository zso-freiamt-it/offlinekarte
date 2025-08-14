set -xe
(cd mapserv && sh prep_ms.sh)
(cd searchserv && sh prep_ss.sh)
(cd web && sh prep_web.sh)
