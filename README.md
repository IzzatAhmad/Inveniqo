# Inveniqo — Docker Setup

Inventory management system built with Java EE (JSP / Servlets) + MySQL, containerised with Docker.

---

## Quick Start

> **Prerequisite**: Docker Desktop must be running.

```bash
# 1. Navigate to the project folder
cd "C:\Users\izzatahmad\Downloads\Inveniqo\Inveniqo"

# 2. Build & start all containers (first run downloads images & seeds the DB)
docker compose up --build

# 3. Open the app
#    http://localhost:8080
```

To run in the background:
```bash
docker compose up --build -d
```

---

## Services

| Container | Image | Port | Purpose |
|---|---|---|---|
| `inveniqo_db` | `mysql:8.0` | `3306` | Database (auto-seeded from `inveniqo.sql`) |
| `inveniqo_app` | `tomcat:9-jdk21` | `8080` | Tomcat app server (WAR at `ROOT`) |

---

## Stop / Clean Up

```bash
# Stop containers (keep data)
docker compose down

# Stop and DELETE database data (full reset)
docker compose down -v
```

---

## Rebuild After Code Changes

1. Build the WAR in NetBeans: **Clean and Build** → `dist/Inveniqo.war` is produced
2. Re-run Docker:
   ```bash
   docker compose up --build
   ```

---

## Environment Variables

The app reads these at startup (set in `docker-compose.yml`):

| Variable | Default (local) | Docker value |
|---|---|---|
| `DB_HOST` | `localhost` | `db` |
| `DB_PORT` | `3306` | `3306` |
| `DB_NAME` | `inveniqo` | `inveniqo` |
| `DB_USER` | `root` | `root` |
| `DB_PASS` | *(empty)* | *(empty)* |

---

## Troubleshooting

**App fails to connect to DB on first start**
> MySQL takes a few seconds to initialise. The `healthcheck` in `docker-compose.yml` makes Tomcat wait, but if you see connection errors, run:
> ```bash
> docker compose restart app
> ```

**Port 3306 already in use**
> Stop your local MySQL service or change the host port in `docker-compose.yml`:
> ```yaml
> ports:
>   - "3307:3306"   # use 3307 on the host instead
> ```
