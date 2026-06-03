# 🐳 Docker & Containers for DevOps — Complete Guide

> **Before you start:** You know Linux, the terminal, and basic scripting. That's everything you need. Docker is just commands you type — it will feel familiar immediately.
>
> **How to use this document:** Work through it in order the first time. Each section teaches one concept, explains why it matters, then shows you the real commands to run. Come back to any section whenever you forget something.
>
> **What you'll be able to do:** Build Docker images, run and manage containers, connect them together over networks, use Docker Compose to manage multi-container apps, push images to Docker Hub and AWS ECR, debug problems confidently, optimise image size with multi-stage builds, and explain containers clearly in a job interview.

---

# Chapter 1 — Introduction: What Are Containers and Why Do They Exist?

## 1.1 The problem containers solve

Picture this: you spend a week building a web app on your laptop. Python 3.11, Flask 3.0, a MySQL connector library — it all works perfectly. You push the code to GitHub and ask a colleague to run it.

They have Python 3.9. Different Flask version. MySQL connector not installed. It breaks on the first command.

You then deploy to a production server. It's running Ubuntu 20.04 with Python 3.8 and a completely different set of system libraries. It breaks differently.

This is called **dependency hell** — when your application relies on specific software versions that don't exist in the same combination on other machines.

**Containers solve this completely.** Instead of shipping just your code, you ship your code *and* everything it needs to run — the Python version, the libraries, the config, the file structure — all packaged together into one portable unit. If it runs on your machine, it runs anywhere Docker is installed. No surprises.

## 1.2 What is a container?

A **container** is a self-contained, runnable package that includes:

- Your application code
- The exact runtime it needs (Python 3.11, Node 20, Java 17...)
- All its dependencies and libraries
- Any configuration it requires

Think of it as a **lunchbox**. Instead of hoping the destination has the right ingredients and kitchen equipment, you pack everything ready to eat. You hand over the box. It works anywhere.

Containers are:

- **Lightweight** — they start in seconds, not minutes. A container is just a process.
- **Isolated** — each container has its own filesystem and network. They can't interfere with each other.
- **Portable** — the same container image runs identically on any machine with Docker installed.
- **Consistent** — no more "it works on my machine." The container carries the machine.
- **Disposable** — if something breaks, you don't fix it in place. You throw it away and start a fresh one from the image.

## 1.3 Benefits of containers for DevOps

| Benefit | What it means in practice |
|---|---|
| **Consistency** | Dev, staging, and production all run identical environments |
| **Speed** | New containers start in seconds. Deployments are fast. |
| **Isolation** | One broken container doesn't affect others |
| **Efficiency** | Run many containers on one machine — far more than VMs |
| **Portability** | Build once, run anywhere Docker runs |
| **CI/CD integration** | Containers are the natural unit of deployment in pipelines |
| **Microservices** | Each service runs in its own container, scales independently |

## 1.4 What is Docker?

**Docker** is the tool that made containers practical and mainstream. Containers existed before Docker (Linux has supported them since 2008 via LXC), but they were complex and required deep Linux expertise.

Docker, released in 2013, wrapped all that complexity into a clean, simple interface. It gave developers:

- A simple CLI (`docker run`, `docker build`, `docker push`)
- A standard image format that works everywhere
- **Docker Hub** — a public library of millions of ready-made images
- **Dockerfile** — a plain text format for building your own images
- **Docker Compose** — a tool for running multi-container applications

Today Docker is installed on almost every developer machine and CI/CD server in the world. It is the industry standard for containerisation.

**Docker's key components:**

| Component | What it is | What it does |
|---|---|---|
| **Docker Engine** | Software running on your machine | Builds images, runs containers, manages networking and storage |
| **Docker CLI** | The `docker` command | How you talk to Docker Engine |
| **Docker Hub** | hub.docker.com | Public registry — download ready-made images or share your own |
| **Docker Compose** | The `docker compose` command | Manages multi-container apps from a single YAML file |

## 1.5 Images and containers — the critical distinction

Every beginner confuses these. Get it clear now.

**Image** = a read-only template. A snapshot. A blueprint. Nothing is "running." It's the recipe.

**Container** = a running instance created from an image. It's the actual thing executing. It's the meal cooked from the recipe.

```
Image: python:3.11-slim  (a ready-made Python image from Docker Hub)
  ├─► Container A  (running your web app)
  ├─► Container B  (running a database migration script)
  └─► Container C  (running your test suite)
```

All three containers started from the same image. The image is unchanged. Each container gets its own isolated writeable layer on top of the shared read-only image.

> **Cookie cutter = image. Cookie = container.** One cutter makes infinite cookies. Eating (stopping/deleting) a cookie doesn't affect the cutter or any other cookie.

| | Image | Container |
|---|---|---|
| What it is | Read-only blueprint | Running process |
| Created by | `docker build` | `docker run` |
| Listed by | `docker images` | `docker ps` |
| Deleted by | `docker rmi` | `docker rm` |
| Analogy | Recipe | Cooked meal |

## 1.6 Why containers matter in modern development

In modern DevOps, containers are the **unit of deployment**. Here is how they fit into the full workflow:

```
Developer writes code
       ↓
docker build → creates an image
       ↓
CI/CD pipeline tests the image
       ↓
docker push → image stored in a registry (Docker Hub, AWS ECR)
       ↓
Production server pulls the image
       ↓
docker run → container runs in production
```

This pipeline works the same whether you're deploying to a single server, a Kubernetes cluster with 500 nodes, or AWS Fargate. The container image is always the artefact being built, tested, and deployed.

## 1.7 The famous interview question: VMs vs Containers

You will be asked this in every DevOps interview. Know it cold.

**How a Virtual Machine works:**

```
Physical Server
└── Hypervisor (VMware, VirtualBox, KVM, Hyper-V)
    ├── VM 1: Full Guest OS + App A + Libraries
    ├── VM 2: Full Guest OS + App B + Libraries
    └── VM 3: Full Guest OS + App C + Libraries
```

Each VM runs its own complete operating system — its own kernel, its own system processes. The hypervisor manages access to the physical hardware.

**How containers work:**

```
Physical Server
└── Host OS (one shared kernel)
    └── Docker Engine
        ├── Container 1: App A + Libraries  (no separate OS)
        ├── Container 2: App B + Libraries
        └── Container 3: App C + Libraries
```

Containers share the host machine's OS kernel. Docker uses two Linux kernel features to make this work:
- **Namespaces** — give each container its own isolated view of the system (its own filesystem, network, process list)
- **cgroups** — control how much CPU, memory, and disk each container can use

**The comparison table — memorise this:**

| | Virtual Machine | Container |
|---|---|---|
| **Startup time** | Minutes (full OS boot) | Seconds (just start a process) |
| **Size** | Gigabytes (entire OS) | Megabytes (just app + libs) |
| **OS** | Full copy per VM | Shared host kernel |
| **Isolation** | Very strong (separate kernel) | Process-level (shared kernel) |
| **Resource overhead** | High | Low — many containers per machine |
| **Portability** | Hypervisor-specific | Runs anywhere Docker runs |
| **Best for** | Different OSes, strong isolation | App packaging and deployment |

**The answer that impresses interviewers:** "In practice, we use both. Cloud providers like AWS run your containers *inside* virtual machines. EC2 is a VM; Docker runs on top of it. VMs handle infrastructure isolation; containers handle application packaging. They solve different problems and complement each other."

---

# Chapter 2 — Installation and First Steps

## 2.1 Installing Docker

**Mac or Windows:** Download Docker Desktop from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop). Install it, open it, and wait for the whale icon in your menu bar/taskbar to show "Docker Desktop is running." Docker Desktop includes Docker Engine, the CLI, and Docker Compose — everything you need.

**Ubuntu Linux:**

```bash
# Remove any old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Set up the repository
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Allow your user to run Docker without sudo every time
sudo usermod -aG docker $USER
newgrp docker
```

## 2.2 Verifying the installation

Run these three commands. If all three work, you're set up correctly.

```bash
# Check the version
docker --version
# Expected: Docker version 24.0.7, build afdd53b

# See detailed info about your installation
docker info
# Shows: container count, image count, storage driver, OS, kernel version

# Run the official test container
docker run hello-world
```

When `hello-world` runs, Docker:
1. Looks for the `hello-world` image locally — not found
2. Automatically downloads it from Docker Hub
3. Creates a container from it
4. Runs it — it prints a success message and exits

You should see: `Hello from Docker!` and a description of what happened. This confirms Docker Engine is running and can talk to Docker Hub.

## 2.3 Introduction to Docker images

An **image** is a layered, read-only file that contains everything needed to run a piece of software. You either:
- **Pull** a ready-made image from Docker Hub (`docker pull nginx`)
- **Build** your own from a Dockerfile (`docker build`)

Docker Hub has official images for almost everything: Python, Node.js, MySQL, Redis, Nginx, Ubuntu, Alpine. These are maintained by the software teams themselves and are safe to use as base images.

```bash
# Download an image from Docker Hub
docker pull nginx

# Download a specific version (always use specific versions in production)
docker pull python:3.11-slim

# List all images on your machine
docker images
```

Reading `docker images` output:
```
REPOSITORY       TAG          IMAGE ID       CREATED        SIZE
nginx            latest       abc123def456   2 days ago     187MB
python           3.11-slim    def456ghi789   5 days ago     149MB
hello-world      latest       ghi789jkl012   2 months ago   13.3kB
```

- `REPOSITORY` — the image name
- `TAG` — the version label (`latest`, `3.11-slim`, `8.0`, etc.)
- `IMAGE ID` — a unique identifier for this image
- `SIZE` — how much disk space it uses

> **Create a GitHub repository now.** Call it `docker-learning` or `devops-bootcamp/docker`. Put everything from this module in it — your Dockerfiles, compose files, and app code. This becomes your portfolio. Push it to GitHub as you go.

---

# Chapter 3 — Understanding the Dockerfile

## 3.1 What is a Dockerfile?

A **Dockerfile** is a plain text file that contains step-by-step instructions for building a Docker image. You write it once; Docker follows it every time you build.

```
Your Dockerfile (the recipe)
         ↓
    docker build
         ↓
   Docker Image (the baked result)
         ↓
    docker run
         ↓
   Container (running instance)
```

Every instruction in a Dockerfile creates a **layer**. Layers are stacked on top of each other to form the final image. Docker **caches** each layer — if a layer hasn't changed since the last build, it reuses the cached version instead of re-running it. This is what makes rebuilds fast.

## 3.2 Dockerfile instructions — every one you need

```dockerfile
# FROM — always the first instruction. Sets the base image to start from.
# You're building on top of someone else's work.
FROM python:3.11-slim

# WORKDIR — sets the working directory inside the image.
# All following commands run from this path. Creates it if it doesn't exist.
# Use this instead of RUN mkdir && RUN cd.
WORKDIR /app

# COPY — copies files from your machine into the image.
# Format: COPY <source on your machine> <destination in image>
COPY requirements.txt .
COPY . .

# RUN — executes a command during the BUILD phase.
# Used for installing software, setting up the environment.
# Each RUN creates a new layer.
RUN pip install --no-cache-dir -r requirements.txt

# ENV — sets an environment variable.
# Available inside the container at runtime.
ENV PYTHONUNBUFFERED=1
ENV APP_PORT=5000

# EXPOSE — documents which port the app uses.
# This is informational only — it does NOT open the port.
# You still need -p when running the container.
EXPOSE 5000

# CMD — the default command to run when the container starts.
# Use list format ["command", "arg1"] — this is the exec form.
# Only one CMD per Dockerfile. If you provide a command in docker run, this is overridden.
CMD ["python", "app.py"]
```

## 3.3 The layer caching rule — critical for fast builds

This is one of the most practical things to understand about Docker. Get it right from the start.

Docker caches each layer. **When a layer changes, every layer after it is invalidated and must be rebuilt.** So the order of your instructions matters enormously.

**Slow Dockerfile — breaks cache on every code change:**

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY . .                              # copies EVERYTHING including app.py
RUN pip install -r requirements.txt   # re-runs every time you change app.py
CMD ["python", "app.py"]
```

Every time you edit `app.py`, the `COPY . .` layer changes, which busts the cache on `pip install`. You wait for a full pip install on every single code change. That gets old fast.

**Fast Dockerfile — dependencies cached separately from code:**

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .              # copy only this file first
RUN pip install -r requirements.txt  # cached as long as requirements.txt doesn't change
COPY . .                             # copy code AFTER installing dependencies
CMD ["python", "app.py"]
```

Now pip only re-runs when `requirements.txt` actually changes. Code changes are instant — just the `COPY . .` layer rebuilds.

**The rule:** Things that change **rarely** (dependencies, system packages) go **before** things that change **often** (your application code).

---

# Chapter 4 — Containerising a Web Application

## 4.1 Create a simple Flask web application

First, set up your project folder and files:

```bash
mkdir flask-docker-app
cd flask-docker-app
```

**app.py:**

```python
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def home():
    env = os.getenv('APP_ENV', 'development')
    return f"<h1>Hello from Docker!</h1><p>Environment: {env}</p>"

@app.route('/health')
def health():
    return {"status": "healthy"}, 200

if __name__ == '__main__':
    port = int(os.getenv('APP_PORT', 5002))
    app.run(host='0.0.0.0', port=port, debug=False)
```

**requirements.txt:**

```
flask==3.0.0
```

## 4.2 Write the Dockerfile

Create a file called `Dockerfile` (no extension) in the same folder:

```dockerfile
# Start from the official Python 3.11 slim image
# 'slim' means it's a minimal version — fewer pre-installed tools, smaller size
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Copy requirements first — so pip install is cached separately from code
COPY requirements.txt .

# Install dependencies
# --no-cache-dir reduces image size by not storing the pip download cache
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Tell Docker this container will use port 5002
EXPOSE 5002

# Set an environment variable
ENV APP_ENV=production

# The command to run when the container starts
CMD ["python", "app.py"]
```

**Create a `.dockerignore` file** — tells Docker what to exclude when copying files:

```
# .dockerignore
__pycache__
*.pyc
*.pyo
venv/
.env
.git
.gitignore
*.log
README.md
```

Without this, `COPY . .` would drag your entire `.git` folder, virtual environment, and any `.env` files into the image. Always create this file.

## 4.3 Build and run the container

```bash
# Build the image
# -t gives it a name and tag
# The . tells Docker where to find the Dockerfile (current directory)
docker build -t flask-app:v1 .

# You'll see output for each layer:
# [1/4] FROM python:3.11-slim
# [2/4] WORKDIR /app
# [3/4] COPY requirements.txt .
# [4/4] RUN pip install...
# ...

# Verify the image was created
docker images flask-app

# Run the container
docker run -d \
  --name flask-app \
  -p 5002:5002 \
  flask-app:v1

# -d        = detached (runs in background)
# --name    = give it a human-readable name
# -p 5002:5002 = map port 5002 on your machine to port 5002 in the container
```

## 4.4 Test it and explore it

```bash
# Test the app is responding
curl http://localhost:5002
# <h1>Hello from Docker!</h1><p>Environment: production</p>

curl http://localhost:5002/health
# {"status":"healthy"}

# See running containers
docker ps

# Check the logs
docker logs flask-app

# Open a shell inside the running container
docker exec -it flask-app bash

# Inside the container, explore:
ls /app           # your files are here
env               # environment variables including APP_ENV=production
python --version  # Python 3.11.x
cat /etc/os-release  # Debian — the base of python:3.11-slim
exit              # leave the container
```

## 4.5 Make a change and rebuild

```bash
# Edit app.py — change the return message
# ...

# Rebuild
docker build -t flask-app:v2 .
# Notice: only layers after the code change rebuild — pip install is cached

# Stop old container, run new one
docker stop flask-app
docker rm flask-app
docker run -d --name flask-app -p 5002:5002 flask-app:v2
```

---

# Chapter 5 — Core Docker Commands

## 5.1 Running containers — all the options you need

```bash
# Basic run
docker run nginx

# Run in background (detached)
docker run -d nginx

# Give it a name
docker run -d --name my-nginx nginx

# Map a port: -p HOST_PORT:CONTAINER_PORT
docker run -d --name my-nginx -p 8080:80 nginx
# Now http://localhost:8080 reaches nginx's port 80

# Set environment variables
docker run -d \
  --name my-db \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=myapp \
  mysql:8.0

# Run and automatically delete when it stops
docker run --rm ubuntu:22.04 echo "Hello and goodbye"

# Run interactively with a shell
docker run -it ubuntu:22.04 bash
# You're now inside the container. Type 'exit' to leave.
```

## 5.2 Managing containers

```bash
# List running containers
docker ps

# List ALL containers (running and stopped)
docker ps -a

# Stop a running container (graceful)
docker stop flask-app

# Start a stopped container
docker start flask-app

# Restart
docker restart flask-app

# Delete a stopped container
docker rm flask-app

# Force delete a running container (stop + delete in one)
docker rm -f flask-app

# Delete all stopped containers at once
docker container prune
```

## 5.3 Managing images

```bash
# List images
docker images

# Pull from Docker Hub
docker pull nginx:alpine

# Delete an image
docker rmi flask-app:v1

# Delete all unused images (not used by any container)
docker image prune -a

# See how an image was built (its layers)
docker history flask-app:v1
```

## 5.4 Debugging commands

These are the commands you'll use every time something goes wrong:

```bash
# See what the container printed (errors, startup messages, app output)
docker logs flask-app

# Follow logs live (like tail -f)
docker logs -f flask-app

# Last 50 lines only
docker logs --tail 50 flask-app

# Open an interactive shell inside a running container
docker exec -it flask-app bash
# or if bash isn't installed:
docker exec -it flask-app sh

# Run a specific command inside a running container
docker exec flask-app env              # check environment variables
docker exec flask-app ls /app          # check files are there
docker exec flask-app cat /etc/hosts   # check networking

# See full details of a container (networking, volumes, config, etc.)
docker inspect flask-app

# See live CPU and memory usage
docker stats

# See processes running inside a container
docker top flask-app
```

## 5.5 Cleanup

Docker accumulates containers, images, networks, and volumes. Clean up regularly:

```bash
# See how much disk Docker is using
docker system df

# Remove all stopped containers, unused images, unused networks, build cache
docker system prune

# Same but also remove volumes (WARNING: deletes data)
docker system prune --volumes

# Selective cleanup
docker container prune    # stopped containers only
docker image prune -a     # unused images only
docker volume prune       # unused volumes only
docker network prune      # unused networks only
```

---

# Chapter 6 — Docker Networking

## 6.1 Why containers need networking

Each container is isolated — it has its own network interface and can't reach other containers by default. But a real application is never just one container. You have:

- A web application container
- A database container
- Maybe a Redis cache container

These need to communicate. Docker networking is how you connect them.

## 6.2 How Docker networking works

When you create a **custom Docker network**, containers on that network can reach each other using their **container name as the hostname**. Docker's built-in DNS resolver handles the translation.

```bash
# Create a network
docker network create my-app-network

# Start two containers on that network
docker run -d --name web-server --network my-app-network flask-app:v1
docker run -d --name database   --network my-app-network mysql:8.0

# Inside web-server, 'database' resolves to the MySQL container's IP
# Your app code can connect to host="database", port=3306
```

> **Why create a custom network instead of using the default?** The default Docker bridge network doesn't support DNS resolution by container name — you'd have to use IP addresses, which change every time. A custom network gives you automatic name resolution. Always create one for multi-container apps.

## 6.3 Useful network commands

```bash
# List all networks
docker network ls

# Create a network
docker network create app-network

# See which containers are on a network (and their IPs)
docker network inspect app-network

# Connect a running container to a network
docker network connect app-network my-container

# Remove a network
docker network rm app-network
```

## 6.4 Linking Flask to MySQL — a real two-container setup

This is the practical exercise from the course. Follow each step carefully.

```bash
# Step 1: Create the network
docker network create app-network

# Step 2: Start the MySQL database container
docker run -d \
  --name mysql-db \
  --network app-network \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=myapp \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppass \
  mysql:8.0
```

MySQL takes around 20–30 seconds to initialise on first run. Check it's ready:

```bash
docker logs mysql-db
# Wait until you see: ready for connections
```

```bash
# Step 3: Start the Flask app on the same network
# Pass the database hostname as an environment variable
# The hostname is the container name: 'mysql-db'
docker run -d \
  --name flask-web \
  --network app-network \
  -p 5002:5002 \
  -e DB_HOST=mysql-db \
  -e DB_USER=appuser \
  -e DB_PASSWORD=apppass \
  -e DB_NAME=myapp \
  flask-app:v1

# Step 4: Verify the connection from inside the Flask container
docker exec -it flask-web bash
# Inside the container:
ping mysql-db        # should get replies — name resolves to the MySQL container's IP
exit
```

## 6.5 Debugging MySQL connection errors

MySQL errors are common when first connecting containers. Here's a systematic approach:

```bash
# Is MySQL actually running?
docker ps | grep mysql-db

# What does MySQL say? (look for "ready for connections")
docker logs mysql-db

# Is Flask seeing the right environment variables?
docker exec flask-web env | grep DB_

# Can Flask's container reach MySQL's port?
docker exec flask-web bash
# Inside:
apt-get update && apt-get install -y netcat-openbsd -q
nc -zv mysql-db 3306    # should say: open
exit

# Are they actually on the same network?
docker network inspect app-network
# Look for both 'flask-web' and 'mysql-db' in the Containers section

# Common errors and fixes:
# "Can't connect to MySQL server" → MySQL not ready yet, wait longer
# "Access denied for user" → wrong username/password in environment variables
# "Unknown database" → database name doesn't match what MySQL was started with
# "Name or service not known" → containers are not on the same network
```

---

# Chapter 7 — Docker Compose

## 7.1 What is Docker Compose?

Running multiple containers with `docker run` gets messy fast. For our Flask + MySQL setup, you're already typing four long commands, remembering the right order, and managing a shared network manually.

**Docker Compose solves this by letting you define your entire application stack in one file** — `docker-compose.yml` — and manage it with simple commands.

```bash
# Instead of four manual commands...
# One command starts everything:
docker compose up -d
# That's it.
```

## 7.2 Why Docker Compose matters in DevOps

Docker Compose is not just a convenience tool. It's used in real production workflows because:

- **Reproducibility** — the compose file is code. It's committed to Git. Anyone can run your stack with one command, identically, every time.
- **Onboarding** — a new team member runs `docker compose up` and has the full dev environment in seconds. No setup guide needed.
- **CI/CD pipelines** — compose files run integration tests by spinning up real databases and services, not mocks.
- **Documentation** — the compose file shows exactly what services your app needs, what ports they use, and what environment variables they require. It's living documentation.

## 7.3 Writing your first `docker-compose.yml`

Create this file in your project root:

```yaml
# docker-compose.yml

services:

  # ─── Web application ───────────────────────────────────────────────────
  web:
    build: .                    # build from the Dockerfile in this directory
    container_name: flask-web
    ports:
      - "5002:5002"             # host:container
    environment:
      - DB_HOST=db              # 'db' is the name of the service below — Compose resolves it
      - DB_USER=appuser
      - DB_PASSWORD=apppass
      - DB_NAME=myapp
      - APP_ENV=production
    depends_on:
      - db                      # start 'db' before 'web'
    restart: unless-stopped     # restart if it crashes, but not if you manually stop it

  # ─── MySQL database ────────────────────────────────────────────────────
  db:
    image: mysql:8.0            # use this image directly from Docker Hub
    container_name: mysql-db
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: myapp
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppass
    volumes:
      - db-data:/var/lib/mysql  # persist database data (see Chapter 8)
    restart: unless-stopped

# Named volumes must be declared here
volumes:
  db-data:
```

**What Compose does automatically:**
- Creates a shared network for all services (no `docker network create` needed)
- Each service is reachable by its service name within that network
- That's why `DB_HOST=db` works — `db` is the service name, which resolves to that container

## 7.4 Docker Compose commands

```bash
# Start all services in background
docker compose up -d

# Start and rebuild images first (use this after changing code or the Dockerfile)
docker compose up -d --build

# See what's running
docker compose ps

# See logs for all services
docker compose logs

# Follow logs live
docker compose logs -f

# Follow logs for one service only
docker compose logs -f web

# Stop everything (containers stop but are not deleted — data preserved)
docker compose stop

# Stop and delete containers and network (named volumes are kept)
docker compose down

# Stop and delete everything including data volumes (DATA LOSS — use carefully)
docker compose down -v

# Open a shell in a running service
docker compose exec web bash
docker compose exec db bash

# Run a one-off command in a service
docker compose run web python --version

# Rebuild images without starting
docker compose build

# Pull latest versions of all images
docker compose pull
```

## 7.5 Debugging: container name conflicts

A common error when using Compose:

```
Error response from daemon: Conflict. The container name "/flask-web" is already in use
```

This happens when a container with that name already exists from a previous run. Fix:

```bash
# Stop and remove the conflicting container
docker compose down

# Then start again
docker compose up -d
```

Or force remove the container by name:

```bash
docker rm -f flask-web
docker compose up -d
```

## 7.6 `depends_on` — start order

```yaml
services:
  web:
    depends_on:
      - db    # Docker starts 'db' container before 'web'
```

**Important to understand:** `depends_on` only controls *start order* — not *readiness*. The `db` container starts before `web`, but MySQL takes 20–30 seconds to be ready for connections. Your app might start before MySQL is accepting connections.

The production-grade solution is a health check:

```yaml
services:
  web:
    depends_on:
      db:
        condition: service_healthy    # wait until db health check passes

  db:
    image: mysql:8.0
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s             # give MySQL 30s to start before checking
```

---

# Chapter 8 — Volumes: Persisting Your Data

## 8.1 The problem: containers are ephemeral

Containers are designed to be disposable. When you delete a container, its writable layer is deleted too — along with any data your app wrote to it.

```bash
docker run -d --name my-db -e MYSQL_ROOT_PASSWORD=secret mysql:8.0
# ... create tables, insert data ...
docker rm -f my-db
docker run -d --name my-db -e MYSQL_ROOT_PASSWORD=secret mysql:8.0
# All your data is gone. Fresh database.
```

This is fine for stateless apps (web servers, API services). It's a problem for anything that stores data (databases, file uploads, logs that must persist).

**Volumes** solve this by storing data outside the container's lifecycle.

## 8.2 Named volumes — for databases and persistent data

Docker manages where the data lives on your machine. You give it a name and reference it when running a container.

```bash
# Create a named volume
docker volume create db-data

# Use it: -v volume-name:/path/inside/container
docker run -d \
  --name my-db \
  -v db-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  mysql:8.0

# Delete the container
docker rm -f my-db

# Recreate — data is still there because it lives in the volume, not the container
docker run -d \
  --name my-db \
  -v db-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  mysql:8.0
# Your databases and tables are still there

# Manage volumes
docker volume ls                # list all volumes
docker volume inspect db-data   # see where Docker stores it on your machine
docker volume rm db-data        # delete a volume (DATA LOSS — irreversible)
```

## 8.3 Bind mounts — for development

Mount a directory from your machine directly into the container. Changes you make on your laptop appear immediately inside the container.

```bash
# $(pwd) = your current directory
docker run -d \
  --name flask-dev \
  -p 5002:5002 \
  -v $(pwd):/app \
  flask-app:v1

# Edit app.py on your laptop
# The container sees the file change immediately
# Restart Flask inside the container to pick it up
```

This is useful during development — no need to rebuild the image every time you change a file.

## 8.4 Volumes in Docker Compose

```yaml
services:
  db:
    image: mysql:8.0
    volumes:
      - db-data:/var/lib/mysql    # named volume — data persists across container restarts

  web:
    build: .
    volumes:
      - .:/app                    # bind mount — for development only, not production

volumes:
  db-data:    # named volumes must be declared at the bottom
```

---

# Chapter 9 — Docker Registries

## 9.1 What is a Docker registry?

A **registry** is a storage and distribution system for Docker images. When you run `docker pull nginx`, you're downloading from Docker Hub — the world's largest public registry.

For your own applications in a company, you use a **private registry** so images are only accessible to authorised people and systems.

**Public registries:**
- **Docker Hub** (hub.docker.com) — the default. Free for public repos. Millions of public images.
- **GitHub Container Registry** (ghcr.io) — integrated with GitHub, great for open source projects.

**Private registries (for company use):**
- **AWS ECR** (Elastic Container Registry) — stores images in your AWS account
- **Google Artifact Registry** — GCP's registry
- **Azure Container Registry** — Azure's registry

## 9.2 Docker Hub — pushing your image

```bash
# 1. Create a free account at hub.docker.com

# 2. Log in from your terminal
docker login
# Enter your Docker Hub username and password

# 3. Tag your image — must follow the format: your-username/image-name:tag
docker tag flask-app:v1 yourusername/flask-app:v1
docker tag flask-app:v1 yourusername/flask-app:latest

# 4. Push it to Docker Hub
docker push yourusername/flask-app:v1
docker push yourusername/flask-app:latest

# 5. Pull it on any other machine with Docker installed
docker pull yourusername/flask-app:v1
docker run -d -p 5002:5002 yourusername/flask-app:v1

# 6. Log out when done
docker logout
```

Your image is now publicly available at `hub.docker.com/r/yourusername/flask-app`. Anyone can pull it.

## 9.3 AWS ECR — pushing to a private registry

AWS ECR stores images privately in your AWS account. Only people (and services) with the right AWS credentials can pull them. This is what companies use in production.

**Prerequisites:** AWS CLI installed (`pip install awscli`) and configured (`aws configure` with your access key and secret).

```bash
# Step 1: Create a repository in ECR
aws ecr create-repository \
  --repository-name flask-app \
  --region eu-west-1

# The output gives you the repository URI — copy it:
# 123456789012.dkr.ecr.eu-west-1.amazonaws.com/flask-app

# Step 2: Authenticate Docker to your ECR registry
# This command gets a temporary token and logs Docker in
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.eu-west-1.amazonaws.com

# Step 3: Tag your image with the full ECR URI
docker tag flask-app:v1 \
  123456789012.dkr.ecr.eu-west-1.amazonaws.com/flask-app:v1

# Step 4: Push it
docker push \
  123456789012.dkr.ecr.eu-west-1.amazonaws.com/flask-app:v1

# Step 5: Use the image from ECR (pull and run)
docker pull \
  123456789012.dkr.ecr.eu-west-1.amazonaws.com/flask-app:v1

docker run -d \
  --name flask-from-ecr \
  -p 5002:5002 \
  123456789012.dkr.ecr.eu-west-1.amazonaws.com/flask-app:v1
```

> **ECR authentication expires after 12 hours.** In CI/CD pipelines, you must run the `aws ecr get-login-password` command again before each push. This is normal — scripts that push to ECR always include the auth step.

## 9.4 Debugging: networking issues when pulling from ECR

If your container can't connect to services after being pulled from ECR, the most common causes are:

```bash
# 1. Wrong environment variables — check what the container actually has
docker exec flask-from-ecr env | grep DB_

# 2. Not on the right network
docker network inspect app-network
# Check the container appears in the network

# 3. Image was built with hardcoded values — always use ENV variables
# Rebuild with -e flags or docker-compose env: section

# 4. Security group or firewall blocking the port (on a cloud VM)
# Check the VM's inbound rules allow the port your app uses
```

---

# Chapter 10 — Multi-Stage Builds: Making Images Smaller

## 10.1 The problem: bloated images

When you build an application, you often need tools that are only required during the build — compilers, test frameworks, development dependencies. If you include these in your final image, it becomes unnecessarily large.

A Python app with full build tools might be 1GB. It only needs to be 150MB in production.

Large images cause real problems:
- Slow to push and pull from the registry
- More disk space on every server running them
- Larger attack surface for security vulnerabilities

## 10.2 The solution: multi-stage builds

A multi-stage build uses multiple `FROM` instructions in one Dockerfile. Each `FROM` starts a new **stage**. You can copy specific files from one stage to another — leaving everything else behind.

**Without multi-stage (bloated):**

```dockerfile
FROM python:3.11                    # full Python — ~900MB base
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt  # includes dev tools
COPY . .
RUN python -m pytest                 # runs tests during build (not needed in final image)
CMD ["python", "app.py"]
# Final image: 900MB+ with tests, dev packages, everything
```

**With multi-stage (lean):**

```dockerfile
# ─── Stage 1: Build and test ──────────────────────────────────────────────
FROM python:3.11 AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt
COPY . .
# Run tests here — if they fail, the build fails (nothing gets deployed)
RUN python -m pytest --tb=short

# ─── Stage 2: Production ─────────────────────────────────────────────────
FROM python:3.11-slim AS production
# 'slim' is a much smaller base image

WORKDIR /app

# Copy ONLY the installed packages from the builder stage
COPY --from=builder /root/.local /root/.local

# Copy ONLY the application code
COPY --from=builder /app/app.py .
COPY --from=builder /app/requirements.txt .

ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

RUN useradd --create-home appuser
USER appuser

EXPOSE 5002
CMD ["python", "app.py"]
# Final image: ~160MB — tests, build tools, and full Python are left behind
```

```bash
# Build normally — Docker uses only the final stage
docker build -t flask-app:prod .

# Compare sizes
docker images flask-app
# flask-app   prod    ...   163MB
# (vs 900MB+ without multi-stage)
```

The `COPY --from=builder` line is the key — it reaches back into the `builder` stage and copies only what you specify, leaving all build tools and test code behind in a stage that's then discarded.

---

# Chapter 11 — Orchestration: What Comes After Docker

## 11.1 The limits of running containers on one machine

Docker on a single machine works well for development and simple deployments. But in production at scale, you have problems Docker alone can't solve:

- What if the machine crashes? Your containers die with it.
- What if traffic spikes? You need more containers — fast.
- How do you update a container without downtime?
- How do you manage secrets, health checks, and load balancing across 50 containers?
- What if you have 10 servers and need to decide which server runs which container?

These problems require **container orchestration** — a system that manages containers across multiple machines automatically.

## 11.2 Brief Kubernetes introduction

**Kubernetes** (also written K8s) is the industry-standard container orchestration platform. Originally built by Google and open-sourced in 2014. Now maintained by the CNCF (Cloud Native Computing Foundation).

Kubernetes runs your containers across a **cluster** — a group of machines working together. It decides which machine runs which container, restarts failed containers automatically, scales up when traffic increases, and rolls out updates without downtime.

Key concepts you'll learn in the Kubernetes module:
- **Pod** — the smallest deployable unit. Usually one container.
- **Deployment** — manages a set of identical pods. Handles updates and scaling.
- **Service** — gives pods a stable network address and load balances traffic between them.
- **Node** — a machine in the cluster.
- **Control plane** — the brain of the cluster. Manages scheduling and state.

Cloud providers offer managed Kubernetes so you don't have to manage the control plane yourself:
- **AWS EKS** (Elastic Kubernetes Service)
- **Google GKE** (Google Kubernetes Engine)
- **Azure AKS** (Azure Kubernetes Service)

## 11.3 Docker Swarm vs Kubernetes

Docker Swarm is Docker's built-in clustering tool. It's simpler than Kubernetes but less powerful.

| | Docker Swarm | Kubernetes |
|---|---|---|
| **Setup** | Very simple — `docker swarm init` | Complex — many components |
| **Learning curve** | Gentle — familiar Docker commands | Steep — new concepts throughout |
| **Auto-scaling** | Manual only | Built-in (Horizontal Pod Autoscaler) |
| **Community** | Small and declining | Massive — the industry standard |
| **Cloud support** | Limited | EKS, GKE, AKS — all major clouds |
| **Production use** | Small teams, simple setups | Large organisations, complex systems |

**The honest advice:** Swarm is easier to learn first, but Kubernetes is what employers use and what the job market wants. Your bootcamp covers Kubernetes next — that's the right call.

## 11.4 Why orchestration tools exist

Orchestration tools solve the problems that emerge when you go from "one container on one machine" to "many containers across many machines":

| Problem | What orchestration provides |
|---|---|
| Machine crashes | Automatically restarts containers on healthy nodes |
| Traffic spike | Scales containers up automatically |
| Deployment | Rolls out updates without downtime (rolling updates) |
| Multiple machines | Schedules containers across the cluster intelligently |
| Networking | Service discovery — containers find each other by name |
| Configuration | Manages config and secrets centrally |
| Health | Continuously monitors containers and replaces failed ones |

> **Where you are now:** You understand how to build, run, and manage containers. That knowledge is the foundation for Kubernetes — pods are just containers, deployments are like Compose services, services are like port mappings. The concepts transfer directly. Kubernetes adds the multi-machine layer on top.

---

# Chapter 12 — Best Practices

## 12.1 Dockerfile best practices

```dockerfile
# ✅ Use specific version tags — never 'latest' in production
FROM python:3.11.7-slim

# ❌ This can change without warning and break your build
# FROM python:latest

# ✅ Minimise layers — chain RUN commands and clean up in one step
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl vim && \
    rm -rf /var/lib/apt/lists/*

# ❌ Three separate layers that each add size
# RUN apt-get update
# RUN apt-get install -y curl
# RUN apt-get install -y vim

# ✅ Copy dependencies before code (cache optimisation)
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

# ✅ Use .dockerignore — always
# Keep __pycache__, .git, venv, .env out of the image

# ✅ Don't run as root
RUN useradd --create-home appuser
USER appuser

# ✅ Use exec form for CMD — signals go directly to your app
CMD ["python", "app.py"]

# ❌ Shell form — signals go to sh, not your app. Graceful shutdown breaks.
# CMD python app.py

# ✅ Set Python-specific environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
```

## 12.2 Security basics

```bash
# Never put secrets in a Dockerfile
# ❌ This is visible to anyone who runs docker history
ENV DB_PASSWORD=mysecretpassword

# ✅ Pass secrets at runtime
docker run -e DB_PASSWORD=mysecretpassword myapp
# Or use a secrets manager in production (AWS Secrets Manager, Vault)

# ✅ Use specific image tags — unpinned images are a supply chain risk
FROM python:3.11.7-slim    # not python:latest

# ✅ Use official or verified images from Docker Hub
FROM python:3.11-slim      # official Python image
# ❌ FROM randomguy/python  # unknown contents, unknown author
```

## 12.3 The complete best-practice Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Deps before code — cache optimisation
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Non-root user — security
RUN useradd --create-home --no-log-init appuser && \
    chown -R appuser /app
USER appuser

# Python settings
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

EXPOSE 5002

# Exec form — proper signal handling
CMD ["python", "app.py"]
```

---

# Chapter 13 — Quick Reference Cheat Sheet

## Images

```bash
docker pull image:tag             # download from registry
docker build -t name:tag .        # build from Dockerfile in current dir
docker images                     # list local images
docker rmi image:tag              # delete an image
docker tag source:tag target:tag  # tag an image with a new name
docker history image:tag          # see layers and sizes
```

## Containers

```bash
docker run -d -p 8080:80 --name myapp image  # run detached, port mapped, named
docker run -it image bash                     # interactive shell
docker run --rm image command                 # run and auto-delete when done
docker run -e KEY=VALUE image                 # set environment variable
docker ps                                     # list running containers
docker ps -a                                  # list all containers
docker stop name                              # graceful stop
docker start name                             # start a stopped container
docker restart name                           # restart
docker rm name                                # remove stopped container
docker rm -f name                             # force remove running container
```

## Debugging

```bash
docker logs name                  # see output
docker logs -f name               # follow live
docker logs --tail 50 name        # last 50 lines
docker exec -it name bash         # open shell in running container
docker exec -it name sh           # if bash not available
docker exec name env              # check environment variables
docker exec name ls /app          # check files inside container
docker inspect name               # full config and details
docker stats                      # live CPU and memory per container
docker top name                   # processes inside container
```

## Networking

```bash
docker network create mynet               # create a network
docker network ls                         # list all networks
docker network inspect mynet              # see containers on network + their IPs
docker run --network mynet image          # attach container to network
docker network connect mynet container    # connect running container
docker network rm mynet                   # delete network
```

## Volumes

```bash
docker volume create myvol                # create a named volume
docker volume ls                          # list volumes
docker volume inspect myvol              # details (where it's stored)
docker run -v myvol:/data image           # use named volume
docker run -v $(pwd):/app image           # bind mount current directory
docker volume rm myvol                   # delete volume (data gone permanently)
```

## Docker Compose

```bash
docker compose up -d               # start all services in background
docker compose up -d --build       # rebuild images then start
docker compose down                # stop and remove containers, keep volumes
docker compose down -v             # also remove volumes (data loss)
docker compose ps                  # see service status
docker compose logs -f             # follow all logs
docker compose logs -f web         # follow one service
docker compose exec web bash       # shell into running service
docker compose run web python -V   # one-off command in a new container
docker compose build               # build images without starting
docker compose pull                # pull latest images
```

## Registry

```bash
# Docker Hub
docker login
docker tag myapp:v1 username/myapp:v1
docker push username/myapp:v1
docker pull username/myapp:v1

# AWS ECR
aws ecr create-repository --repository-name myapp --region eu-west-1
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.eu-west-1.amazonaws.com
docker tag myapp:v1 123456789012.dkr.ecr.eu-west-1.amazonaws.com/myapp:v1
docker push 123456789012.dkr.ecr.eu-west-1.amazonaws.com/myapp:v1
```

## Cleanup

```bash
docker system df               # how much disk Docker is using
docker system prune            # remove unused containers, images, networks
docker system prune --volumes  # also remove volumes (data loss)
docker container prune         # stopped containers only
docker image prune -a          # unused images only
docker volume prune            # unused volumes only
```

---

# Appendix — Interview Prep

Every question you'll be asked. Written as short, clear answers — the kind that land well in interviews.

**1. What problem do containers solve?**
They solve the dependency problem — packaging an application with everything it needs so it runs identically on any machine. Eliminates "works on my machine."

**2. What is Docker specifically?**
The tool that made containers practical. It provides the CLI, a standard image format, Docker Hub for sharing images, Dockerfile for defining builds, and Docker Compose for multi-container apps.

**3. What is the difference between an image and a container?**
An image is a read-only template — a blueprint. A container is a running instance created from that image. One image can produce many containers.

**4. Containers vs virtual machines?**
VMs run a full OS per VM — gigabytes, minutes to start. Containers share the host OS kernel — megabytes, seconds to start. VMs give stronger isolation; containers are more efficient and portable. In production, both are used — containers run inside VMs.

**5. What is a Dockerfile?**
A text file with step-by-step instructions for building a Docker image. Each instruction creates a layer.

**6. Why does the order of Dockerfile instructions matter?**
Docker caches layers. When a layer changes, all layers after it rebuild. Putting dependencies before code means a dependency install is only re-run when dependencies actually change — not on every code edit.

**7. What does EXPOSE do in a Dockerfile?**
Documents which port the app uses. It does not publish the port. You still need `-p` when running the container.

**8. What is a custom Docker network and why create one?**
A custom bridge network that lets containers reach each other by container name. The default bridge doesn't support name resolution — you'd need IP addresses. Always create a custom network for multi-container apps.

**9. What is Docker Compose?**
A tool for defining and managing multi-container applications. You describe all your services in `docker-compose.yml` and manage them with commands like `docker compose up` and `docker compose down`.

**10. How do services communicate in Docker Compose?**
Compose creates a shared network automatically. Services can reach each other using the service name as the hostname. A service called `db` is reachable at `db:3306` from any other service.

**11. What is a Docker volume?**
Persistent storage that exists outside the container's lifecycle. When the container is deleted, the volume survives. Used for databases and any data that must persist.

**12. Named volume vs bind mount?**
Named volume: Docker manages the storage location — use for databases and production data. Bind mount: you specify a path on your machine — use for development when you want live code changes inside the container.

**13. How do you debug a container that won't start?**
First `docker logs name` to see the error. Then `docker run -it image bash` to enter the image interactively and run the app manually to see the exact failure.

**14. How do you debug a running container?**
`docker logs -f name` to follow output. `docker exec -it name bash` to open a shell inside it. `docker inspect name` for full config. `docker stats` for resource usage.

**15. How do you push an image to Docker Hub?**
Tag it as `username/imagename:tag`, run `docker login`, then `docker push username/imagename:tag`.

**16. How do you push to AWS ECR?**
Create a repository with `aws ecr create-repository`, authenticate Docker with `aws ecr get-login-password | docker login ...`, tag your image with the ECR URI, then `docker push`.

**17. What is a multi-stage build?**
A Dockerfile with multiple `FROM` instructions. Each stage can install tools and run commands, but only files explicitly copied with `COPY --from=stage` carry over to the final stage. Build tools and test code are left behind, producing a much smaller production image.

**18. Why not run containers as root?**
If an attacker exploits a vulnerability in your app, running as root inside the container gives them root-level access. Creating a non-root user and switching to it limits the blast radius.

**19. What is `docker system prune`?**
Removes all stopped containers, unused images, unused networks, and build cache. With `--volumes` it also removes data volumes. Run regularly to reclaim disk space.

**20. What is Kubernetes and why does it exist?**
A container orchestration platform. It runs containers across a cluster of machines, automatically restarts failed containers, scales up/down based on load, and handles zero-downtime deployments. Docker manages containers on one machine; Kubernetes manages containers across many machines.
