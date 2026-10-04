# Fedora Development Container

A Fedora-based development environment with compilers, build tools, language runtimes, command-line utilities, Java SDKs managed by SDKMAN!, and several language servers for use with editor integrations.

## Included tooling

The image includes:

- GCC and G++
- CMake and Ninja
- Git, Curl, Wget, OpenSSH, Rsync
- Go
- Python 3 and pip
- Node.js and npm
- Java SDKs through SDKMAN!
- ShellCheck
- jq, ripgrep, fd, tree, tmux, less, file, and procps
- Helix editor
- OpenCode
- Pi coding agent
- T3 Code

The configured language servers are installed under:

```text
/home/user/.lsp
```

## Language servers

The build creates the following `.lsp` entries:

| Entry | Purpose |
|---|---|
| `gopls` | Go language server |
| `ruff` | Python linting and language-server functionality |
| `ty` | Python type checking |
| `typescript-language-server` | TypeScript and JavaScript language server |
| `typescript-language-server_dir/` | Local npm installation directory |
| `jdtls_dir/` | Eclipse JDT Language Server |
| `java` | Entry point or symlink for the Java language server |
| `lombok.jar` | Lombok Java agent |
| `jdtls-wrapper` | Manually maintained JDTLS launcher |

The expected layout is:

```text
.lsp/
├── java/
│   └── lombok.jar
├── gopls
├── jdtls-wrapper
├── jdtls_dir/
├── ruff
├── ty
├── typescript-language-server
└── typescript-language-server_dir/
```

## Repository layout

```text
.
├── Dockerfile
├── README.md
├── setup-lsp.sh
└── jdtls-wrapper
```

`setup-lsp.sh` installs and configures generated language-server files. The `jdtls-wrapper` file is kept in the repository and copied into the image manually.

## Building the image

Build with Docker:

```bash
docker build -t devbox .
```

Or with Podman:

```bash
podman build -t devbox .
```

The default Pi package is:

```text
@earendil-works/pi-coding-agent
```

To override it during the build:

```bash
podman build \
    --build-arg PI_PACKAGE=@earendil-works/pi-coding-agent \
    -t devbox .
```

## Running the container

Start an interactive shell:

```bash
podman run --rm -it devbox
```

With the current directory mounted:

```bash
podman run --rm -it \
    -v "$PWD:/workspace:Z" \
    -w /workspace \
    devbox
```

For Docker, omit `:Z` unless SELinux labeling is required:

```bash
docker run --rm -it \
    -v "$PWD:/workspace" \
    -w /workspace \
    devbox
```

The container starts with:

```bash
/bin/bash -l
```

The default user is:

```text
user
```

The user has passwordless `sudo` access.

## Java SDKs

SDKMAN! is installed for the normal development user. The image installs:

```text
Java 21.0.12-tem
Java 25.0.4-tem
Java 8.0.502-tem
```

SDKMAN! is initialized automatically in interactive Bash shells.

To inspect installed Java versions:

```bash
sdk list java
```

To select a Java version for the current shell:

```bash
sdk use java 21.0.12-tem
```

To make a version the default:

```bash
sdk default java 21.0.12-tem
```

## Language-server setup

`setup-lsp.sh` creates the `.lsp` directory and installs the language servers.

### Go

```bash
go install golang.org/x/tools/gopls@latest
```

The resulting executable is linked into:

```text
~/.lsp/gopls
```

### Python

The following tools are installed with pip:

```bash
python3 -m pip install --user --upgrade ruff ty
```

They are linked into:

```text
~/.lsp/ruff
~/.lsp/ty
```

### TypeScript

The TypeScript language server is installed locally under:

```text
~/.lsp/typescript-language-server_dir
```

The executable is exposed as:

```text
~/.lsp/typescript-language-server
```

### Eclipse JDT Language Server

JDTLS is downloaded from the Eclipse milestone release:

```text
https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.61.0/jdt-language-server-1.61.0-202609031315.tar.gz
```

The archive is extracted into:

```text
~/.lsp/jdtls_dir
```

The download uses `curl -fL` because the Eclipse URL redirects to a download mirror.

### Lombok

Lombok is downloaded to:

```text
~/.lsp/java/lombok.jar
```

The setup script uses:

```bash
curl -fL \
    -o "${LSP_HOME}/java/lombok.jar" \
    https://projectlombok.org/downloads/lombok.jar
```

The JDTLS wrapper should launch Java with Lombok as a Java agent:

```bash
-javaagent:"${HOME}/.lsp/java/lombok.jar"
```

## Environment variables

The image defines:

```text
COLORTERM=truecolor
TERM=xterm
SHELL=/bin/bash
EDITOR=hx
VISUAL=hx
T3CODE_HOME=/home/user/.t3
T3_BOOT_SERVICE_UNIT=t3code.service
LSP_HOME=/home/user/.lsp
```

The language-server directory is included in `PATH`:

```text
/home/user/.lsp
```

The user-local Python binary directory is also included:

```text
/home/user/.local/bin
```

## Rebuilding after changes

Rebuild the image after modifying the Dockerfile or language-server setup:

```bash
podman build --no-cache -t devbox .
```

For a normal incremental rebuild:

```bash
podman build -t devbox .
```

## Notes

- The image uses `fedora:latest`, so package versions may change between builds.
- Language servers installed with `@latest`, pip upgrades, or floating download URLs may also change between builds.
- The JDTLS version is currently pinned to milestone `1.61.0`.
- The `jdtls-wrapper` file is intentionally maintained manually and copied into `.lsp` during the image build.
- The `.lsp` directory itself does not need to be copied from the host. It is generated by `setup-lsp.sh`.
