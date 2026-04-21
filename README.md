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

Most stacks are now hardcoded for simplicity.

You can use `.env.example` in the repo root as a starting template.

Shared media paths:

- `MEDIA_LOCAL_PATH` (default: `/Users/bill/Documents/media_local`)
- `MEDIA_EXTERNAL_PATH` (default: `/Volumes/Stuff/media`)

Monica:

- `MONICA_DB_ROOT_PASSWORD` (change from default)
- `MONICA_DB_PASSWORD` (change from default)
- `MONICA_APP_KEY` (set your own key)

## Notes

- Config/data is stored in named Docker volumes by default.
- Media mounts are host bind mounts controlled by the two shared media vars above.
- `homarr` and `portainer` mount `/var/run/docker.sock`; keep those stacks trusted/admin-only.

