FROM centos:7
MAINTAINER Volodymyr M. Lisivka <vlisivka@gmail.com>

# Systemd needs /sys/fs/cgroup directoriy to be mounted from host in
# read-only mode.
VOLUME /sys/fs/cgroup

# Systemd needs /run directory to be a mountpoint, otherwise it will try
# to mount tmpfs here (and will fail).
VOLUME /run

# Mask (create override which points to /dev/null) system services, which
# cannot be started in container anyway.
RUN systemctl mask \
    dev-mqueue.mount \
    dev-hugepages.mount \
    remote-fs.target \
    systemd-remount-fs.service \
    sys-kernel-config.mount \
    sys-kernel-debug.mount \
    sys-fs-fuse-connections.mount \
    systemd-ask-password-wall.path \
    systemd-readahead-collect.service \
    systemd-readahead-replay.service \
    systemd-sysctl.service \
    display-manager.service \
    systemd-logind.service \
    network.service \
    getty.service

# Change target init stage from from graphical mode to multiuser text-only mode
RUN systemctl disable graphical.target && systemctl enable multi-user.target

# Copy initialization script, which will execute kickstart and then start systemd as pid 1
COPY init.sh /

# Run systemd by default via init.sh script, to start required services
CMD ["/init.sh"]
