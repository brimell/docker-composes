# docker-composes

Portainer-first Docker Compose repository.

This repo is organized as one stack per folder so you can point Portainer at this repo and select a single compose path for each stack.

## Layout

Each stack is self-contained in:

- `stacks/portainer/docker-compose.yml`
- `stacks/sonarr/docker-compose.yml`
- `stacks/radarr/docker-compose.yml`
- `stacks/jellyfin/docker-compose.yml`
- `stacks/audiobookshelf/docker-compose.yml`
- `stacks/homarr/docker-compose.yml`
- `stacks/uptime-kuma/docker-compose.yml`
- `stacks/metabase/docker-compose.yml`
- `stacks/monica/docker-compose.yml` (includes `monica` + `monica-db`)
- `stacks/vaultwarden/docker-compose.yml`

## Portainer Usage

For each stack in Portainer:

1. `Stacks` -> `Add stack` -> `Repository`.
2. Set repository URL to this repo.
3. Set `Compose path` to one of the stack files above.
4. Add environment variables as needed.
5. Deploy.

Example compose paths:

- `stacks/sonarr/docker-compose.yml`
- `stacks/monica/docker-compose.yml`
- `stacks/vaultwarden/docker-compose.yml`

## Environment Variables

You can use `.env.example` in the repo root as a starting template.

Common:

- `CONFIG_ROOT` path on the Docker host where app config/data is stored. Defaults to `/Users/bill/Documents/GitHub/docker-composes/data`.
- `MEDIA_LOCAL_PATH` local media folder mounted into media apps. Defaults to `/Users/bill/Documents/media_local`.
- `MEDIA_EXTERNAL_PATH` external media folder mounted into media apps. Defaults to `/Volumes/Stuff/media`.

Monica:

- `MONICA_DB_ROOT_PASSWORD` (change from default)
- `MONICA_DB_PASSWORD` (change from default)
- `MONICA_APP_KEY` (set your own key)

## Config and Data

Container config/data is stored under `CONFIG_ROOT`, with one folder per app:

- `data/portainer`
- `data/sonarr/config`
- `data/radarr/config`
- `data/jellyfin/config`
- `data/jellyfin/cache`
- `data/audiobookshelf/config`
- `data/audiobookshelf/metadata`
- `data/homarr`
- `data/uptime-kuma`
- `data/metabase`
- `data/monica/db`
- `data/monica/storage`
- `data/vaultwarden`

The `data/` folder is intentionally ignored by git because it can contain databases, passwords, API keys, sessions, and other private runtime state. Back it up separately if you want to recreate the machine exactly.

Existing named Docker volumes are not moved automatically. For example, the current Portainer volume is `documents_portainer_data`, mounted at `/data` in the container. To migrate it, stop the stack, copy the contents of that volume into `data/portainer`, then redeploy the stack with this compose file.

## Notes

- Config/data is stored in bind-mounted folders under `CONFIG_ROOT`.
- Media mounts default to `/Users/bill/Documents/media_local` and `/Volumes/Stuff/media`.
- `homarr` and `portainer` mount `/var/run/docker.sock`; keep those stacks trusted/admin-only.
