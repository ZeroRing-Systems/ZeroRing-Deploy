FROM emscripten/emsdk:4.0.3 AS wasm-builder

RUN pip3 install cmake

WORKDIR /build/kernel
COPY ZeroKernel/ /build/kernel/

RUN mkdir -p build && cd build && \
    emcmake cmake /build/kernel && \
    cmake --build . --parallel $(nproc)

FROM ubuntu:24.04 AS backend-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake pkg-config \
    libpqxx-dev libpq-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build/cloud
COPY ZeroRing-Cloud/ /build/cloud/

RUN mkdir -p build && cd build && \
    cmake /build/cloud -DUSE_POSTGRES=ON && \
    cmake --build . --parallel $(nproc)

FROM ubuntu:24.04 AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpqxx-7.8t64 libpq5 libssl3t64 nginx postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY --from=backend-builder /build/cloud/build/server /usr/local/bin/server
COPY --from=wasm-builder /build/kernel/build/kernel.wasm /var/www/html/wasm/kernel.wasm
COPY ZeroRing-Cloud/public/index.html /var/www/html/index.html
COPY ZeroRing-Cloud/public/terminal.js /var/www/html/terminal.js

COPY nginx.conf /etc/nginx/sites-available/default

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 8080

CMD ["/entrypoint.sh"]
