FROM swift:5.10-jammy

# update
RUN apt-get -qq update

# VSCode DevContainer stuff
RUN apt-get -qq install git net-tools

# Bash
RUN apt-get -qq install bash

# Build Essentials
RUN apt-get -qq install build-essential

# libwebsockets.swift dependencies
RUN apt-get -qq install libssl-dev libdbus-1-dev libz-dev libsqlite3-dev

# VSCode Live Share in DevContainers
RUN apt-get install wget
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then echo "deb http://security.ubuntu.com/ubuntu focal-security main" | tee /etc/apt/sources.list.d/focal-security.list; fi
RUN if [ "$(dpkg --print-architecture)" != "amd64" ]; then echo "deb http://ports.ubuntu.com/ubuntu-ports focal-security main" | tee /etc/apt/sources.list.d/focal-security.list; fi
RUN apt-get -qq update
RUN apt-get -qq install libssl1.1
# RUN wget -O ~/vsls-reqs https://aka.ms/vsls-linux-prereq-script && chmod +x ~/vsls-reqs && ~/vsls-reqs
RUN rm /etc/apt/sources.list.d/focal-security.list

# ld-linx for solidity
RUN apt-get -qq install libc6
RUN ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2

# Reflex for "hot reloading"
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then wget -O reflex.tar.gz https://github.com/cespare/reflex/releases/download/v0.3.1/reflex_linux_amd64.tar.gz; fi
RUN if [ "$(dpkg --print-architecture)" != "amd64" ]; then wget -O reflex.tar.gz https://github.com/cespare/reflex/releases/download/v0.3.1/reflex_linux_arm64.tar.gz; fi
RUN mkdir reflex_out
RUN tar -xzvf reflex.tar.gz --strip-components=1 -C reflex_out/
RUN mv reflex_out/reflex /usr/bin/
RUN rm -rf reflex_out/
RUN rm -rf reflex.tar.gz

# ---- Swift Dev Tools
RUN apt-get install -qq curl
# SwiftFormat
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then curl -O --output-dir /usr/local/bin/ https://crypto-bot-main.fra1.digitaloceanspaces.com/kw-mev-bot/dev-tools/ubuntu-jammy-swift-5.7/amd64/swiftformat; fi
RUN if [ "$(dpkg --print-architecture)" != "amd64" ]; then curl -O --output-dir /usr/local/bin/ https://crypto-bot-main.fra1.digitaloceanspaces.com/kw-mev-bot/dev-tools/ubuntu-jammy-swift-5.9/arm64/swiftformat; fi
RUN chmod +x /usr/local/bin/swiftformat
# SwiftLint
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then curl -O --output-dir /usr/local/bin/ https://crypto-bot-main.fra1.digitaloceanspaces.com/kw-mev-bot/dev-tools/ubuntu-jammy-swift-5.7/amd64/swiftlint; fi
RUN if [ "$(dpkg --print-architecture)" != "amd64" ]; then curl -O --output-dir /usr/local/bin/ https://crypto-bot-main.fra1.digitaloceanspaces.com/kw-mev-bot/dev-tools/ubuntu-jammy-swift-5.9/arm64/swiftlint; fi
RUN chmod +x /usr/local/bin/swiftlint

# Swift Debug in VSCode dependencies
RUN apt-get -qq install libpython3.10
