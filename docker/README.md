- [Setup aarch64-Linux](https://github.com/pkgforge/bincache/blob/main/docker/aarch64-Linux.md)
- [Setup x86_64-Linux](https://github.com/pkgforge/bincache/blob/main/docker/x86_64-Linux.md)
---
- #### Additional Notes & Refs
> - [Install Dagu](https://github.com/pkgforge/devscripts/blob/main/Linux/DAGU_CRON.md)
> ```bash
> export DAGU_USER="$(whoami)"
> export DAGU_HOME="$(getent passwd $DAGU_USER | cut -d: -f6)" ; mkdir -p "$DAGU_HOME/.dagu"
> export DAGU_HOST="$(ip addr show tailscale0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || sudo tailscale ip -4 2>/dev/null | tr -d '\n' | tr -d '[:space:]')"
> export DAGU_PORT="8080"
> DAGU_BASICAUTH_USERNAME="$SECURE_USERNAME"
> DAGU_BASICAUTH_PASSWORD="$SECURE_PASSWORD"
> 
> sudo curl -qfsSL "https://bin.ajam.dev/$(uname -m)/dagu" -o "/usr/bin/dagu" && sudo chmod +x "/usr/bin/dagu"
> sudo mkdir -p "/etc/systemd/system/" && sudo touch "/etc/systemd/system/dagu_ts.service"
> cat << 'EOF' | sed -e "s|DG_USER|$DAGU_USER|g" -e "s|DG_HOME|$DAGU_HOME|g" -e "s|DG_HOST|$DAGU_HOST|g" -e "s|DG_PORT|$DAGU_PORT|g" -e "s|DG_SUSER|$DAGU_BASICAUTH_USERNAME|g" -e "s|DG_SPASSWD|$DAGU_BASICAUTH_PASSWORD|g" | sudo tee "/etc/systemd/system/dagu_ts.service"
> [Unit]
> Description=Dagu Job Scheduler
> Wants=network-online.target
> Requires=tailscaled.service
> After=network-online.target network.target tailscaled.service
> 
> [Service]
> Type=simple
> User=DG_USER
> Environment="DAGU_HOME=DG_HOME/.dagu"
> Environment="DAGU_HOST=DG_HOST"
> Environment="DAGU_PORT=DG_PORT"
> Environment="DAGU_IS_BASICAUTH=1"
> Environment="DAGU_BASICAUTH_USERNAME=DG_SUSER"
> Environment="DAGU_BASICAUTH_PASSWORD=DG_SPASSWD"
> ExecStartPre=/bin/mkdir -p DG_HOME/.dagu/syslog
> ExecStartPre=/bin/sleep 10
> ExecStart=/usr/bin/dagu start-all
> StandardOutput=DG_HOME/.dagu/syslog/dagu_ts.log
> StandardError=DG_HOME/.dagu/syslog/dagu_ts.log
> Restart=always
> KillMode=process
> 
> [Install]
> WantedBy=multi-user.target
> EOF
> 
> sudo systemctl daemon-reload
> sudo systemctl enable "dagu_ts.service" --now
> #If Unit tailscaled.service not found: 
> # sudo sed -i -e '/Requires=/d' -e 's/tailscaled.service//g' "/etc/systemd/system/dagu_ts.service"
> # sudo systemctl daemon-reload
> # sudo systemctl enable "dagu_ts.service" --now
> sudo systemctl restart "dagu_ts.service"
> sudo systemctl status "dagu_ts.service"
> journalctl -xeu "dagu_ts.service"
> ```
> ---
> - [Install Docker](https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script)
> ```bash
> curl -qfsSL "https://get.docker.com" | sed 's/sleep 20//g' | sudo bash
> sudo groupadd docker 2>/dev/null ; sudo usermod -aG docker "${USER}" 2>/dev/null
> sudo service docker restart 2>/dev/null && sleep 10
> sudo service docker status 2>/dev/null
> ```
> ---
> - [Install Podman](https://podman.io/docs/installation)
> ```bash
> ##Install podman :: https://software.opensuse.org/download/package?package=podman&project=home%3Aalvistack
>
> #(Alpine) : https://wiki.alpinelinux.org/wiki/Podman
> apk update --no-cache && apk add docker podman --latest --no-cache --upgrade --no-interactive
> rc-update add "cgroups" ; rc-service "cgroups" start && sleep 5 ; rc-service "cgroups" status
>
> 
> #(Debian)
> # https://software.opensuse.org/download/package?package=podman&project=home%3Aalvistack#manualDebian
> 
> #(Ubuntu)
> VERSION="$(grep -oP 'VERSION_ID="\K[^"]+' "/etc/os-release")"
> echo "deb http://download.opensuse.org/repositories/home:/alvistack/xUbuntu_${VERSION}/ /" | sudo tee "/etc/apt/sources.list.d/home:alvistack.list"
> curl -fsSL "https://download.opensuse.org/repositories/home:alvistack/xUbuntu_${VERSION}/Release.key" | gpg --dearmor | sudo tee "/etc/apt/trusted.gpg.d/home_alvistack.gpg" >/dev/null
> sudo apt update -y
> sudo apt install podman -y
> #if errors: sudo apt purge golang-github-containers-common -y
> # sudo dpkg -i --force-overwrite /var/cache/apt/archives/containers-common_100%3a0.59.1-1_amd64.deb
> # sudo apt --fix-broken install
>
> cat "$(systemctl show podman.service -p FragmentPath 2>/dev/null | cut -d '=' -f 2 | tr -d '[:space:]')"
> sudo systemctl daemon-reexec ; sudo systemctl daemon-reload
> sudo systemctl status podman
> sudo systemctl reload "podman.service"
> sudo service podman reload ; sudo service podman restart ; sudo systemctl status podman
> #If errors: sudo apt-get install netavark -y || sudo apt-get install containernetworking-plugins podman-netavark -y
> podman --version
> 
> ##Running :: https://docs.podman.io/en/latest/markdown/podman-run.1.html
> sudo mkdir -p "/var/lib/containers/tmp"
> sudo podman run --rm --privileged --network="bridge" --systemd="always" --ulimit="host" --volume="/var/lib/containers/tmp:/tmp" --tz="UTC" --pull="always" "docker.io/azathothas/gh-runner-x86_64-ubuntu:latest"
> # --device="/dev/net/tun:rwm"
> # --cap-add="NET_ADMIN,NET_BIND_SERVICE,NET_RAW,SYS_ADMIN"
> sudo podman exec --env-file="/path/to/GH_AUTH_ENV" -u "runner" "${POD_ID from sudo podman ps}" "/usr/local/bin/manager.sh"
> 
> #For Testing/Debug/Interactive Use
> sudo podman exec -it -u "runner" "$(sudo podman ps --format json | jq -r '.[] | select(.Image == "docker.io/azathothas/gh-runner-x86_64-ubuntu:latest") | .Id')" bash
>
> !#PrePacked Build ENV (remove --rm to Preserve Container)
> sudo mkdir -p "/var/lib/containers/tmp"
> sudo podman run --detach --rm --privileged --network="bridge" --systemd="always" --ulimit="host" --volume="/var/lib/containers/tmp:/tmp" --tz="UTC" --pull="always" --name="bincache-dbg" "docker.io/azathothas/ubuntu-systemd-base:$(uname -m)"
> #Run an Interactive Session
> sudo podman exec -it -u "runner" "$(sudo podman ps --filter "name=bincache-dbg" --filter "ancestor=docker.io/azathothas/ubuntu-systemd-base:$(uname -m)" --format "{{.ID}}")" bash -l
> #Inside the container
> bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/devscripts/main/Linux/install_bins_curl.sh") #Installs needed Tooling
> export GHCR_TOKEN="GHCR_PKG_RW" #Token for reading/writing Packages to GHCR
> export GITHUB_TOKEN="GHP_NON_PRIVS" #Token for making Github API Requests to Access Public Assets
> export GITLAB_TOKEN="GLP_NON_PRIVS" #Token for making Gitlab API Requests to Access Public Assets
> source <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/bincache/refs/heads/main/scripts/runner/setup_env.sh")
>
> #Enable SSHD (replace keys with yours)
> sudo podman exec -it -u "runner" "bincache-dbg" bash -c 'sudo curl -qfsSL "https://github.com/Azathothas.keys" | sudo sort -u -o "/etc/ssh/authorized_keys" ; sudo systemctl restart sshd'
> 
> #Stop & Delete Container
> sudo podman stop "bincache-dbg"
> sudo podman rm "bincache-dbg" --force
>
> #To delete all images
> sudo docker image prune -a -f
> sudo podman image prune -a -f
>
> #{WARNING] To reset everything
> sudo docker system reset -f
> sudo podman system reset -f
> ```
> ---
> - [Install Sysbox](https://github.com/nestybox/sysbox)
> ```bash
> !# Del Existing Docker
> docker rm $(docker ps -a -q) -f
> 
> !# Install Deps
> sudo apt-get install fuse3 libfuse-dev -y
> sudo apt-get install "linux-headers-$(uname -r)" -y
> sudo apt-get install linux-headers-{amd64|arm64} -y
> sudo apt-get --fix-broken install -y
> # Get .Deb PKGS
> #aarch64 | arm64
> pushd "$(mktemp -d)" > /dev/null 2>&1 && wget --quiet --show-progress "$(curl -qfsSL 'https://api.github.com/repos/nestybox/sysbox/releases/latest' | jq -r '.body' | sed -n 's/.*(\(https:\/\/.*\.deb\)).*/\1/p' | grep -i 'arm64')" -O "./sysbox.deb" && sudo dpkg -i "./sysbox.deb" ; popd > /dev/null 2>&1
> sudo apt-get autoremove -y ; sudo apt-get update -y && sudo apt-get upgrade -y
> #amd x86_64
> pushd "$(mktemp -d)" > /dev/null 2>&1 && wget --quiet --show-progress "$(curl -qfsSL 'https://api.github.com/repos/nestybox/sysbox/releases/latest' | jq -r '.body' | sed -n 's/.*(\(https:\/\/.*\.deb\)).*/\1/p' | grep -i 'amd64')" -O "./sysbox.deb" && sudo dpkg -i "./sysbox.deb" ; popd > /dev/null 2>&1
> sudo apt-get autoremove -y ; sudo apt-get update -y && sudo apt-get upgrade -y
> #Test
> sysbox-runc --version
> ```
