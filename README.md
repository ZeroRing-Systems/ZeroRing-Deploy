# ZeroRing Deployment

This repository acts as the master umbrella for deploying the ZeroRing OS environment, which consists of the WASM Kernel and the C++ WebSocket Cloud Backend.

## Prerequisites
- Docker
- Docker Compose

## Getting Started

1. Clone this repository with its submodules:
   ```bash
   git clone --recursive https://github.com/ZeroRing-Systems/ZeroRing-Deploy.git
   cd ZeroRing-Deploy
   ```
   *(If you cloned it without `--recursive`, run `git submodule update --init --recursive`)*

2. Start the services:
   ```bash
   docker compose up --build
   ```

3. Open your browser to `http://localhost:8000`

## Architecture
- **postgres**: A PostgreSQL 16 database for persistent Virtual File System (VFS) storage.
- **zeroring**: A multi-stage Docker container that builds the WASM frontend (via emscripten) and the C++ backend (via libpqxx), serving everything through `nginx`.
