#!/bin/sh

dd if=/dev/zero of=/EMPTY bs=100M
rm -f /EMPTY
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync
echo "Done minimizing"
