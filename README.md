# docker-composes

Portainer-first Docker Compose repository.

This repo is organized as one stack per folder so you can point Portainer at this repo and select a single compose path for each stack.

## Layout

Each stack is self-contained in:

- `stacks/portainer/docker-compose.yml`
- `stacks/sonarr/docker-compose.yml`
- `stacks/radarr/docker-compose.yml`
- `stacks/bazarr/docker-compose.yml`
- `stacks/jellyfin/docker-compose.yml`
- `stacks/audiobookshelf/docker-compose.yml`
- `stacks/homarr/docker-compose.yml`
- `stacks/uptime-kuma/docker-compose.yml`
- `stacks/actualbudget/docker-compose.yml` (includes `caddy` + `actual-server`)
- `stacks/metabase/docker-compose.yml`
- `stacks/monica/docker-compose.yml` (includes `monica` + `monica-db`)
- `stacks/vaultwarden/docker-compose.yml`
- `stacks/photoprism/docker-compose.yml`
- `stacks/homebox/docker-compose.yml`
- `stacks/homeassistant/docker-compose.yml`

Actual Budget:

- Edit `stacks/actualbudget/Caddyfile` and set your real domain before deploying.

## Portainer Usage

For each stack in Portainer:

1. `Stacks` -> `Add stack` -> `Repository`.
2. Set repository URL to this repo.
3. Set `Compose path` to one of the stack files above.
4. Add environment variables as needed.
5. Deploy.

Example compose paths:

- `stacks/sonarr/docker-compose.yml`
- `stacks/bazarr/docker-compose.yml`
- `stacks/monica/docker-compose.yml`
- `stacks/vaultwarden/docker-compose.yml`

## Environment Variables

You can use `.env.example` in the repo root as a starting template.

Common:

- `CONFIG_ROOT` path on the Docker host where app config/data is stored. Defaults to `/Users/bill/Documents/GitHub/docker-composes/data`.
- `MEDIA_MOVIES_PATH` movies folder mounted into movie-capable apps. Defaults to `/Volumes/Stuff/media/movies`.
- `MEDIA_SHOWS_PATH` TV shows folder mounted into show-capable apps. Defaults to `/Volumes/Stuff/media/shows`.
- `MEDIA_AUDIOBOOKS_PATH` audiobooks folder mounted into audiobook-capable apps. Defaults to `/Volumes/Stuff/media/audiobooks`.
- `MEDIA_PHOTOS_PATH` photos folder mounted into PhotoPrism. Defaults to `/Volumes/Stuff/media/photos`.
- `MEDIA_LOCAL_MOVIES_PATH` local movies folder mounted into Jellyfin. Defaults to `/Users/bill/Documents/media_local/movies`.
- `MEDIA_LOCAL_SHOWS_PATH` local shows folder mounted into Jellyfin. Defaults to `/Users/bill/Documents/media_local/shows`.
- `MEDIA_LOCAL_AUDIOBOOKS_PATH` local audiobooks folder mounted into Jellyfin. Defaults to `/Users/bill/Documents/media_local/audiobooks`.
- `MEDIA_LOCAL_PHOTOS_PATH` local photos folder mounted into Jellyfin. Defaults to `/Users/bill/Documents/media_local/photos`.
- `TZ` timezone used by Home Assistant. Defaults to `Europe/London`.

Monica:

- `MONICA_DB_ROOT_PASSWORD` (change from default)
- `MONICA_DB_PASSWORD` (change from default)
- `MONICA_APP_KEY` (set your own key)

PhotoPrism:

- `PHOTOPRISM_ADMIN_PASSWORD` (change from default)

## Config and Data

Container config/data is stored under `CONFIG_ROOT`, with one folder per app:

- `data/portainer`
- `data/sonarr/config`
- `data/radarr/config`
- `data/bazarr/config`
- `data/jellyfin/config`
- `data/jellyfin/cache`
- `data/audiobookshelf/config`
- `data/audiobookshelf/metadata`
- `data/homarr`
- `data/uptime-kuma`
- `data/actualbudget`
- `data/metabase`
- `data/monica/db`
- `data/monica/storage`
- `data/vaultwarden`
- `data/photoprism/storage`
- `data/homebox`
- `data/homeassistant`

The `data/` folder is intentionally ignored by git because it can contain databases, passwords, API keys, sessions, and other private runtime state. Back it up separately if you want to recreate the machine exactly.

Existing named Docker volumes are not moved automatically. For example, the current Portainer volume is `documents_portainer_data`, mounted at `/data` in the container. To migrate it, stop the stack, copy the contents of that volume into `data/portainer`, then redeploy the stack with this compose file.

## Notes

- Config/data is stored in bind-mounted folders under `CONFIG_ROOT`.
- Media mounts are split by library folder: `movies`, `shows`, `audiobooks`, and `photos`.
- Jellyfin mounts both external media and local media. External paths appear as `/movies`, `/shows`, and `/audiobooks`; local paths appear under `/media_local`.
- PhotoPrism mounts photos read-only at `/photoprism/originals` and stores its own index/cache under `data/photoprism/storage`.
- `homarr` and `portainer` mount `/var/run/docker.sock`; keep those stacks trusted/admin-only.
- Home Assistant uses host networking for local device discovery and is available on `http://<host>:8123` after startup.
