# Offlinekarte

This repository is a fork of https://github.com/zskarte/zskarte and enhances zskarte with additional capabilities like using zskarte offline.

## Full feature list
Following is a complete list of features in Offlinekarte enhancing zskarte:
- Local search server for offline search of addresses
- Local map tile server for offline map layers
- Local layer with NTP in Aargau
- Embedded mode for use in third party applications like Incident Manager

## Documentation
A detailed documentation is available [here](docs/Documentation.md)

## Deployment
Before executing the Docker containers, all local data must first be fetched. For that, the following command can be executed. It is recommended to rerun this command periodically, e.g. once or twice a year, to refresh the data.

```
zskarte init
```

TODO:
- Update urls in environment.ts
- Update urls in tileserver.env
- Add user in db init script
- Traffic?
- run docker containers

