FROM rust:buster as builder

WORKDIR /elexeum
COPY . /elexeum

RUN rustup default nightly-2021-11-07 && \
	rustup target add wasm32-unknown-unknown --toolchain nightly-2021-11-07

RUN apt-get update && \
	apt-get dist-upgrade -y -o Dpkg::Options::="--force-confold" && \
	apt-get install -y cmake pkg-config libssl-dev git clang libclang-dev  

ARG GIT_COMMIT=
ENV GIT_COMMIT=$GIT_COMMIT
ARG BUILD_ARGS

RUN cargo build --release $BUILD_ARGS

FROM phusion/baseimage:bionic-1.0.0

LABEL description="Docker image for Elexeum Chain" \
	io.parity.image.type="builder" \
	io.parity.image.authors="nath@elexeum.xyz" \
	io.parity.image.vendor="Elexeum" \
	io.parity.image.description="Elexeum: elexeum chain" \
	io.parity.image.source="https://github.com/elexeum/elexeum-node/blob/${VCS_REF}/scripts/docker/selendra.Dockerfile" \
	io.parity.image.documentation="https://github.com/elexeum/elexeum-node"

COPY --from=builder /selendra/target/release/elexeum /usr/local/bin

RUN useradd -m -u 1000 -U -s /bin/sh -d /elexeum elexeum && \
	mkdir -p /data /elexeum/.local/share && \
	chown -R elexeum:elexeum /data && \
	ln -s /data /elexeum/.local/share/elexeum && \
# unclutter and minimize the attack surface
	rm -rf /usr/bin /usr/sbin && \
# check if executable works in this container
	/usr/local/bin/elexeum --version

USER elexeum

EXPOSE 30333 9933 9944 9615
VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/elexeum"]
