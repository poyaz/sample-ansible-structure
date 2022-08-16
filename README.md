Intro
=====

This is a sample ansible with collecation folder running on docker


Usage
=====

You can run with a docker and use as fast as possible.

We create three containers with below name:

* `sample-ansible` This the ansible container
* `sample-ansible-debian-10` This is debian 10 server with ssh server on port 4440 (Can log in with user **ansible**
  and **root**)
* `sample-ansible-debian-11` This is debian 11 server with ssh server on port 4440 (Can log in with user **ansible**
  and **root**)

At first, you need add password (Or public-key) to ssh servers. You can use `.env` file. You should
copy `docker/env/ssh/.env.example` to `docker/env/ssh/.env` and fill variable.

```bash
cp docker/env/ssh/.env.example docker/env/ssh/.env

# Or use any editor you have for fill variable
vim docker/env/ssh/.env

docker-compose -f docker-compose.yml -f docker/docker-compose.ssh.yml up -d

# If you want change default ssh port you can use below env
ANSIBLE_DEBIAN_10_SSH_PORT=2230 ANSIBLE_DEBIAN_11_SSH_PORT=2231 docker-compose -f docker-compose.yml -f docker/docker-compose.ssh.yml up -d
```
