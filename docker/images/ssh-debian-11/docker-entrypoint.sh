#!/usr/bin/env bash
set -Eeo pipefail

declare -r SSH_USER_USERNAME=ansible

file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(<"${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

docker_setup_env() {
  file_env 'SSH_USER_PASSWORD'
  file_env 'SSH_PUBLIC_KEY_VALUE'
}

sshd_config_init() {
  mkdir -p /run/sshd

  sed -i s/#*AllowTcpForwarding.*/AllowTcpForwarding\ yes/ /etc/ssh/sshd_config
  sed -i s/#*PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config
}

generate_host_keys() {
  ssh-keygen -A
}

sshd_set_password() {
  if [ -z "$SSH_USER_PASSWORD" ]; then
    return
  fi

  echo "$SSH_USER_USERNAME:$SSH_USER_PASSWORD" | chpasswd
}

sshd_set_root_password() {
  if [ -z "$SSH_USER_PASSWORD" ]; then
    return
  fi

  echo "root:$SSH_USER_PASSWORD" | chpasswd
}

sshd_set_public_key() {
  if [ -z "$SSH_PUBLIC_KEY_VALUE" ]; then
    return
  fi

  declare -r AUTHORIZED_KEYS_FILE="/home/$SSH_USER_USERNAME/.ssh/authorized_keys"

  if ! [ -f "$AUTHORIZED_KEYS_FILE" ]; then
    touch "$AUTHORIZED_KEYS_FILE"
  fi

  chmod 600 "$AUTHORIZED_KEYS_FILE"
  chown $SSH_USER_USERNAME:$SSH_USER_USERNAME "$AUTHORIZED_KEYS_FILE"

  grep -q -F "$SSH_PUBLIC_KEY_VALUE" "$AUTHORIZED_KEYS_FILE" 2>/dev/null || echo "$SSH_PUBLIC_KEY_VALUE" >>"$AUTHORIZED_KEYS_FILE"
}

sshd_set_root_public_key() {
  if [ -z "$SSH_PUBLIC_KEY_VALUE" ]; then
    return
  fi

  declare -r AUTHORIZED_KEYS_FILE="/root/.ssh/authorized_keys"

  if ! [ -f "$AUTHORIZED_KEYS_FILE" ]; then
    touch "$AUTHORIZED_KEYS_FILE"
  fi

  chmod 600 "$AUTHORIZED_KEYS_FILE"
  chown root:root "$AUTHORIZED_KEYS_FILE"

  grep -q -F "$SSH_PUBLIC_KEY_VALUE" "$AUTHORIZED_KEYS_FILE" 2>/dev/null || echo "$SSH_PUBLIC_KEY_VALUE" >>"$AUTHORIZED_KEYS_FILE"
}

run_sshd() {
  exec /usr/sbin/sshd -D -e "$@"
}

_main() {
  if [ $1 = 'sshd' ]; then
    docker_setup_env

    generate_host_keys

    sshd_config_init

    sshd_set_password
    sshd_set_root_password

    sshd_set_public_key
    sshd_set_root_public_key

    run_sshd "${@:2}"
  fi

  exec "$@"
}

_main "$@"
