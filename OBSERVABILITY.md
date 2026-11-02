# Kora Analytics Observability

The app runs as one Docker container on a single aws EC2 instance. Logs stay on the EC2 instance, and the container
checks its own health with `/health` endpoint.

## Logs

Useful commands:

```bash
# follow logs live
docker compose logs -f app

# last 200 lines
docker compose logs --tail=200 app

# a time window
docker compose logs --since 2h --until 1h app

# logs of an older container, e.g. before the last redeploy
docker ps -a
docker logs --since 24h <container-id>

```

## Health check

The `Dockerfile` runs this every 30 seconds inside the container:

Docker marks the container `unhealthy` after 3 failures in a row.

```bash
# is it healthy?
docker compose ps
docker inspect --format '{{.State.Health.Status}}' $(docker compose ps -q app)

# the last probe result and its output
docker inspect --format '{{json .State.Health}}' $(docker compose ps -q app)

# check from outside the VM
curl -fsS -m 5 http://<server-ip>/health
```

## Spotting a failed deployment


- `docker compose ps` does not show `Up (healthy)` after ~30 seconds.
- `docker compose logs --tail=100 app` shows the process exiting on start (bad `PORT`, port
  already in use, syntax error).
- `curl http://<server-ip>/health` fails or returns non-200.
- `docker compose up` errors before a container is created — usually a bad image name or a
  failed pull.

Fix: deploy the previous image tag, then investigate.

## Spotting a crash

- `docker compose ps -a` shows `Exited (1)` or `Restarting`.
- The restart count goes up:

  ```bash
  docker inspect --format '{{.RestartCount}}' $(docker compose ps -q app)
  ```

- Restart loop in the last hour:

  ```bash
  docker events --filter type=container --since 1h
  ```

- Killed for memory (`true` means OOM):

  ```bash
  docker inspect --format '{{.State.OOMKilled}}' $(docker compose ps -q app)
  ```

## Rising error rates

- A crash loop looks like rising errors to users — check `RestartCount` and `docker events`.
- Memory in `/metrics` climbing over time points to a leak.
- Check applicatapplication logs for error messages.