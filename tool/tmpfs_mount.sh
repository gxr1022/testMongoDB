sudo mount -t tmpfs -o size=64g,mpol=bind:0 tmpfs /mnt/nvme0/home/gxr/mongdb-run/ramDisk

# sudo umount  /mnt/nvme0/home/gxr/mongdb-run/ramDisk