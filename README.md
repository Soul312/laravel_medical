# laravel-medical

laravel-medical is a full-stack Laravel application for managing a medical clinic. It was originally an application project made by user abdelghanyMh, then extended by Soul312 with a DevOps layer for containerization, blue/green deployment, reverse proxying, and monitoring.

## What the app does

The system has three roles:

- Secretary: logs in, creates appointments, and views patients and doctors.
- Doctor: can do everything a secretary can do, plus manage assigned patients and their profiles.
- Admin: can do everything a doctor and secretary can do, plus manage users.

![Use case diagram](./public/useCaseDiagram.png)

## Tech Stack

- Laravel 9
- MySQL 8
- Vite for frontend builds
- AdminLTE Bootstrap admin template

## Running the app locally

Use this path if you want to run the code directly on your machine without Docker.

### Prerequisites

- PHP 8.1+
- Composer
- Node.js 18+ and npm
- MySQL

### Setup steps

1. Clone the repository and install dependencies.

   ```bash
   git clone https://github.com/Soul312/laravel_medical.git
   cd laravel_medical
   composer install
   npm install
   ```

2. Create your environment file.

   ```bash
   cp .env.example .env
   ```

   Update the database settings in `.env` to match your local MySQL instance. The default example points to a Docker service named `db`, so if you are running MySQL directly on your machine, change `DB_HOST` to `127.0.0.1`.

3. Generate the application key.

   ```bash
   php artisan key:generate
   ```

4. Create the database, then run the migrations and seeders.

   ```bash
   php artisan migrate --seed
   ```

   The seed data creates the default login accounts listed below.

5. Build the frontend and start the app.

   ```bash
   npm run build
   php artisan serve
   ```

   If you want live asset rebuilding during development, run `npm run dev` in a separate terminal instead of `npm run build`.

### Default users

If you seed the database, these demo accounts are created:

| Role | Email | Password |
| --- | --- | --- |
| Admin | admin@clinictlemcen.com | 123456 |
| Doctor | doctor@clinictlemcen.com | 123456 |
| Doctor | doctor2@clinictlemcen.com | 123456 |
| Secretary | secretary@clinictlemcen.com | 123456 |

## Running with Docker

The repository also includes a Docker setup for local testing and deployment-style runs.

### Local Docker stack

Use [docker-compose.yml](docker-compose.yml) to start the database and the app container together.

```bash
docker compose up -d --build
```

What happens in this stack:

- MySQL starts in a container and stores its data in a named volume.
- The Laravel container waits for MySQL, runs migrations, seeds the database, and then starts `php artisan serve` on port 8000.
- The app is available at `http://localhost:8000`.

### Deployment stack

Use [docker-compose.deploy.yml](docker-compose.deploy.yml) on the server side. This file is not just the app itself; it defines the runtime platform around the app.

- `traefik` is the reverse proxy in front of the web containers.
- `db` is the shared MySQL instance used by the deployed app.
- `app-blue` and `app-green` are the blue/green slots for zero-downtime switching.
- `prometheus`, `grafana`, and `uptime-kuma` are the monitoring services.

Only the active app slot is meant to receive traffic. The deployment process starts the new slot, waits for it to become healthy, and then stops the old slot.

## DevOps / CI-CD section

The DevOps part of this repository is the automation layer built on top of the application. It exists to build, deploy, and observe the app rather than to change the business features themselves.

The workflow in [.github/workflows/ci.yml](.github/workflows/ci.yml) does four main things:

1. Runs Laravel tests on pull requests and pushes to the `Green-Blue` branch.
2. Builds the frontend assets to make sure the Vite bundle still compiles.
3. Builds and publishes a Docker image to GitHub Container Registry with tags like `green-blue` and `sha-<commit>`.
4. Deploys that image on a self-hosted runner using a blue/green switch.

How the blue/green deployment works:

- The app runs in two interchangeable containers: blue and green.
- GitHub Actions checks which slot is live, deploys the new image into the inactive slot, and waits for health checks to pass.
- Once the new slot is healthy, the old slot is stopped.
- Traefik sits in front of both slots and routes traffic to the healthy one.

Monitoring is started as part of the deployment flow:

- Prometheus scrapes the app and Traefik metrics.
- Grafana is used to visualize those metrics.
- Uptime Kuma is used for uptime checks and availability monitoring.

### Required GitHub secrets

If you want to use the CI/CD pipeline, configure these secrets in GitHub:

- `APP_KEY`: Laravel application key used by the deployed container
- `SENTRY_AUTH_TOKEN`: optional, used to create Sentry releases
- `SENTRY_ORG`: Sentry organization slug
- `SENTRY_PROJECT`: Sentry project slug
- `SENTRY_LARAVEL_DSN`: optional Sentry DSN for the app
- `SERVER_HOST`: deployment server host or IP
- `SERVER_PORT`: SSH port, usually `22`
- `SERVER_USER`: SSH username
- `SERVER_SSH_KEY`: private SSH key for the self-hosted runner or deployment host
- `DEPLOY_PATH`: path on the server where the compose project lives
- `GHCR_USERNAME`: GitHub username used to pull from GHCR
- `GHCR_PAT`: GitHub token with `read:packages`

### Server requirements

- Docker and the Docker Compose plugin installed
- A self-hosted runner with the `self-hosted` and `green-blue-local` labels
- Access to pull the app image from GHCR
- A compose project that includes Traefik, the database, and the two app slots

## Repo structure

- `app/` contains the Laravel application code.
- `database/` contains migrations, seeders, and factories.
- `resources/` contains frontend assets and views.
- `docker-compose*.yml`, `Dockerfile`, and `docker-entrypoint.sh` define the container and deployment setup.
- `.github/workflows/ci.yml` defines the CI/CD pipeline.

## Notes

This project was built as a DevOps-oriented extension of an existing Laravel app. The application features come first, and the deployment stack exists to package, ship, and monitor that app in a more production-like way.
