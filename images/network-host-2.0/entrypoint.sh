#!/bin/sh
# Starts sshd in the background, then runs the container's command.
# Host keys are generated at container start, so each container gets its own
# keys instead of sharing the ones baked into the image.
set -e
ssh-keygen -A
/usr/sbin/sshd
exec "$@"
