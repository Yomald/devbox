# Fedora Development Container

A Fedora-based development environment with a collection of common command-line tools, the [Pi coding agent](https://github.com/earendil-works/pi), OpenCode, SDKMAN!, and Java language-server support.

## Included tools

- **Build and development:** GCC, G++, Make, CMake, Ninja, Go, Python, Node.js, npm
- **CLI utilities:** Git, curl, wget, HTTPie, jq, ripgrep, fd, tree, tmux, and more
- **Editors:** Helix (`hx`)
- **AI coding tools:** Pi and OpenCode
- **Java tooling:** SDKMAN! with Java 8, 21, and 25; JDTLS wrapper and LSP setup

## Requirements

Install [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/).

## Build

From the directory containing the `Dockerfile`:

```sh
docker build -t fedora-dev .
```

Or with Podman:

```sh
podman build -t fedora-dev .
```

The image installs Pi from npm. To override the package:

```sh
docker build \
  --build-arg PI_PACKAGE=@earendil-works/pi-coding-agent \
  -t fedora-dev .
```

The default package is `@earendil-works/pi-coding-agent`.

## Run

Start an interactive container:

```sh
docker run --rm -it fedora-dev
```

To work on a project from your host, mount its directory into the container:

```sh
docker run --rm -it \
  -v "$PWD:/workspace" \
  -w /workspace \
  fedora-dev
```

The container starts a login Bash shell. Run tools such as `pi`, `opencode`, `hx`, `go`, `python3`, and `java` from the shell.

## User configuration

The image creates a non-root user named `user` with UID and GID `1000` by default. Override these values at build time to match your host account:

```sh
docker build \
  --build-arg USERNAME=dev \
  --build-arg USER_UID="$(id -u)" \
  --build-arg USER_GID="$(id -g)" \
  -t fedora-dev .
```

The user has passwordless `sudo` access inside the container.

## Files required in the build context

The Dockerfile expects these files and directories alongside it:

- `.config/` — copied to the user’s `~/.config`
- `setup-lsp.sh` — installs/configures language-server components
- `jdtls-wrapper` — installed under `~/.lsp` and linked as `~/.lsp/java`

Ensure these are present before building.

## Java versions

SDKMAN! is installed for the normal user, along with these Java versions:

- `8.0.502-tem`
- `25.0.4-tem`
- `21.0.12-tem`

SDKMAN! is initialized in interactive Bash shells. Select a version inside the container with:

```sh
sdk use java 21.0.12-tem
```

## Notes

- The image uses `fedora:latest`, so a future build may install newer Fedora packages or behave differently. For reproducible builds, consider pinning the Fedora base image and tool versions.
- The image includes development utilities and tools that can access files and run commands as the container user. Mount only directories you intend to make available to the container.
- Pi’s npm package is installed globally. The project’s Pi documentation notes that npm installation does not pin transitive dependencies. <citation src="1"></citation>
- This image is intended as a development environment, not a minimal runtime image.
