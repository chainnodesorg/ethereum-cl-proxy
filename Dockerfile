# ================================
# Build image
# ================================
FROM swift:5.10-jammy as build

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y

# libwebsockets.swift dependencies
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -qq install libssl-dev libdbus-1-dev libz-dev libsqlite3-dev

# Remove apt list
RUN rm -rf /var/lib/apt/lists/*

# Set up a build area
ARG PROXY_BUILD_DIR=/build/proxy
RUN mkdir -p ${PROXY_BUILD_DIR}
WORKDIR ${PROXY_BUILD_DIR}

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
# Resolve dependencies
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
# --static-swift-stdlib
RUN swift build -c release

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path ${PROXY_BUILD_DIR} -c release --show-bin-path)/Run" ./

# Copy resources bundled by SPM to staging area
RUN find -L "$(swift build --package-path ${PROXY_BUILD_DIR} -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# Copy any resources from the public directory and views directory if the directories exist
# Ensure that by default, neither the directory nor any of its contents are writable.
RUN [ -d ${PROXY_BUILD_DIR}/Public ] && { mv ${PROXY_BUILD_DIR}/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d ${PROXY_BUILD_DIR}/Resources ] && { mv ${PROXY_BUILD_DIR}/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
# FROM ubuntu:jammy
FROM swift:5.10-jammy-slim

# Make sure all system packages are up to date, and install only essential packages.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
    ca-certificates \
    tzdata \
    # This is necessary as our pre update script requires wget
    wget \
    # If your app or its dependencies import FoundationNetworking, also install `libcurl4`.
    libcurl4
# If your app or its dependencies import FoundationXML, also install `libxml2`.
# libxml2

# libwebsockets.swift dependencies
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -qq install libssl-dev libdbus-1-dev libz-dev libsqlite3-dev

# Remove apt list
RUN rm -rf /var/lib/apt/lists/*

# Create a vapor user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build --chown=vapor:vapor /staging /app

# Ensure all further commands run as the vapor user
USER vapor:vapor

# Let Docker bind to port 8080
EXPOSE 8080

# Start the Vapor service when the image is run, default to listening on 8080 in production environment
ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production"]
