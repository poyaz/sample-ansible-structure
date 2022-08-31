FROM node:18.7.0-bullseye-slim

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
	    sudo \
	    gnupg \
        dirmngr \
	    ca-certificates \
	    openssh-server \
	    python3 \
	; \
	groupadd --gid 1000 ansible; \
    useradd --uid 1000 -g ansible --home-dir /home/ansible --shell /bin/bash ansible; \
    usermod -aG sudo ansible; \
    mkdir -p /home/ansible/.ssh; \
    chown -R ansible:ansible /home/ansible/; \
    chmod -R 700 /home/ansible/.ssh; \
    \
    mkdir -p /root/.ssh; \
    chmod -R 700 /root/.ssh

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["sshd"]
