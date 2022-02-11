FROM ubuntu:focal

#
# Systemd installation
# ref: https://github.com/nestybox/dockerfiles/blob/master/ubuntu-focal-systemd/Dockerfile
#
RUN apt-get update &&                            \
    apt-get install -y --no-install-recommends   \
            systemd                              \
            systemd-sysv                         \
            libsystemd0                          \
            ca-certificates                      \
            dbus                                 \
            iptables                             \
            iproute2                             \
            kmod                                 \
            locales                              \
            sudo                                 \
            udev &&                              \
                                                 \
    # Prevents journald from reading kernel messages from /dev/kmsg
    echo "ReadKMsg=no" >> /etc/systemd/journald.conf &&               \
                                                                      \
    # Housekeeping
    apt-get clean -y &&                                               \
    rm -rf                                                            \
       /var/cache/debconf/*                                           \
       /var/lib/apt/lists/*                                           \
       /var/log/*                                                     \
       /tmp/*                                                         \
       /var/tmp/*                                                     \
       /usr/share/doc/*                                               \
       /usr/share/man/*                                               \
       /usr/share/local/*

#
# Docker install
# ref: https://github.com/nestybox/dockerfiles/blob/master/ubuntu-focal-systemd-docker/Dockerfile
#
RUN apt-get update && apt-get install --no-install-recommends -y      \
       apt-transport-https                                            \
       ca-certificates                                                \
       curl                                                           \
       gnupg-agent                                                    \
       software-properties-common &&                                  \
                                                                      \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg           \
         | apt-key add - &&                                           \
	                                                              \
    apt-key fingerprint 0EBFCD88 &&                                   \
                                                                      \
    add-apt-repository                                                \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu     \
       $(lsb_release -cs)                                             \
       stable" &&                                                     \
                                                                      \
    apt-get update && apt-get install --no-install-recommends -y      \
       docker-ce docker-ce-cli containerd.io &&                       \
                                                                      \
    # Housekeeping
    apt-get clean -y &&                                               \
    rm -rf                                                            \
       /var/cache/debconf/*                                           \
       /var/lib/apt/lists/*                                           \
       /var/log/*                                                     \
       /tmp/*                                                         \
       /var/tmp/*                                                     \
       /usr/share/doc/*                                               \
       /usr/share/man/*                                               \
       /usr/share/local/* &&                                          \
                                                                      \
    # Docker compose install
    curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o /usr/libexec/docker/cli-plugins/docker-compose && \
    chmod +x /usr/libexec/docker/cli-plugins/docker-compose

# Sshd install
RUN apt-get update && apt-get install --no-install-recommends -y      \
            openssh-server 
EXPOSE 22

# Make use of stopsignal (instead of sigterm) to stop systemd containers.
STOPSIGNAL SIGRTMIN+3

# Set systemd as entrypoint.
ENTRYPOINT [ "/sbin/init", "--log-level=err" ]
