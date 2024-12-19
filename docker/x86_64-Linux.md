- #### **`"${HOME}/.config/gh-runner/.pkgforge_env"`** `(x86_64_Linux)`
> ```bash
> mkdir -p "${HOME}/.config/gh-runner" && touch "${HOME}/.config/gh-runner/.env"
> cat << 'EOF' > "${HOME}/.config/gh-runner/.env"
> ##DO NOT USE DOUBLE QUOTES
> #A random suffix is applied on RUNNER_NAME
> RUNNER_NAME=amd64-linux-bincache
> #[admin:org] :: repo (all) || read:public_key (on admin:public_key) || read:repo_hook (on admin:repo_hook) || admin:org_hook || notifications || workflow
> GITHUB_PERSONAL_TOKEN=ghp_azazazazaaaaazazazazazzazaza
> GITHUB_OWNER=pkgforge
> GITHUB_REPOSITORY=bincache
> RUNNER_LABELS=amd64-linux-bincache,x86_64-linux-bincache,pkgforge-builder
> EOF
> echo -e "\n[+] ${HOME}/.config/gh-runner/.env\n" && cat "${HOME}/.config/gh-runner/.env"
> ```
> > `"${HOME}/.dagu/dags/build_x86_64_Linux.yaml"`
> > ```yaml
> > schedule: 
> >   - "25 22 * * 0,2,5"
> > description: 'Build 📦 (bincache_x86_64_Linux) Binaries (https://github.com/pkgforge/bincache/actions/workflows/build_x86_64_Linux.yaml) [amd64-linux-bincache] @ 10:30 PM UTC (04:15 AM NPT Mrng Every Mon, Wed & Sat)'
> > tags: amd64-linux-bincache,x86_64-linux-bincache,pkgforge-builder
> > env:
> >   #- DOCKER_CONTAINER_NAME: 'gh-runner-bincache-x64-linux'
> >   - PODMAN_CONTAINER_NAME: 'gh-runner-bincache-x64-linux'
> >   #- DOCKER_CONTAINER_IMAGE: 'azathothas/gh-runner-x86_64-ubuntu'
> >   - PODMAN_CONTAINER_IMAGE: 'docker.io/azathothas/gh-runner-x86_64-ubuntu'
> >   #- DOCKER_ENV_FILE: '${HOME}/.config/gh-runner/.env'
> >   - PODMAN_ENV_FILE: '${HOME}/.config/gh-runner/.env'
> > steps:
> >   - name: Run
> >     description: 'Build 📦 (bincache_x86_64_Linux) Binaries (https://github.com/pkgforge/bincache/actions/workflows/build_x86_64_Linux.yaml)'
> >     command: "bash"
> >     script: |
> >       ##ENV VARS
> >       #At least $USER & ${HOME} must be readable
> >       USER="$(whoami)" && export USER="$USER"
> >       HOME="$(getent passwd "${USER}" | cut -d: -f6)" && export HOME="${HOME}"
> >       #PATH is optional, but often fixes most issues
> >       export PATH="${HOME}/bin:${HOME}/.cargo/bin:${HOME}/.cargo/env:${HOME}/.go/bin:${HOME}/go/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${HOME}/.local/bin:${HOME}/miniconda3/bin:${HOME}/miniconda3/condabin:/usr/local/zig:/usr/local/zig/lib:/usr/local/zig/lib/include:/usr/local/musl/bin:/usr/local/musl/lib:/usr/local/musl/include:$PATH"
> >       ##Pinting ENV VARS for sanity check
> >       eecho -e "\n[+] User: $USER (${HOME})"
> >       echo -e "[+] PATH: $PATH\n"
> >       ##----------Docker----------##
> >       #export SYSBOX="NO"
> >       #DOCKER_CONTAINER_NAME="gh-runner-bincache-x64-linux" DOCKER_CONTAINER_IMAGE="azathothas/gh-runner-x86_64-ubuntu" DOCKER_ENV_FILE="${HOME}/.config/gh-runner/.env" bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/devscripts/refs/heads/main/Github/Runners/run_linux.sh")
> >       ##----------Podman----------##
> >       #PODMAN_CONTAINER_NAME="gh-runner-bincache-x64-linux" PODMAN_CONTAINER_IMAGE="docker.io/azathothas/gh-runner-x86_64-ubuntu" PODMAN_ENV_FILE="${HOME}/.config/gh-runner/.env" bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/devscripts/refs/heads/main/Github/Runners/run_linux.sh")
> > 
> > ```
> >
