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

Most stacks work with defaults, but these are the important ones to set in Portainer.

Common:

- `TZ` (example: `America/New_York`)
- `PUID` (example: `1000`)
- `PGID` (example: `1000`)

Media paths:

- `DOWNLOADS_PATH` (default: `/srv/downloads`)
- `SONARR_TV_PATH` (default: `/srv/media/tv`)
- `RADARR_MOVIES_PATH` (default: `/srv/media/movies`)
- `JELLYFIN_MEDIA_PATH` (default: `/srv/media`)
- `AUDIOBOOKS_PATH` (default: `/srv/media/audiobooks`)
- `PODCASTS_PATH` (default: `/srv/media/podcasts`)

Monica:

- `MONICA_DB_ROOT_PASSWORD` (change from default)
- `MONICA_DB_PASSWORD` (change from default)
- `MONICA_APP_KEY` (set your own key)
- `MONICA_APP_URL` (set to your real URL)

## Image Tag Pinning

Every stack supports an optional image tag environment variable. If you set it in Portainer, it overrides `latest`.

Available tag variables:

- `PORTAINER_TAG`
- `SONARR_TAG`
- `RADARR_TAG`
- `JELLYFIN_TAG`
- `AUDIOBOOKSHELF_TAG`
- `HOMARR_TAG`
- `UPTIME_KUMA_TAG`
- `METABASE_TAG`
- `MONICA_TAG`
- `MONICA_DB_TAG`
- `VAULTWARDEN_TAG`

## Notes

- Config/data is stored in named Docker volumes by default.
- Media/download mounts are host bind mounts via environment variables above.
- `homarr` and `portainer` mount `/var/run/docker.sock`; keep those stacks trusted/admin-only.

