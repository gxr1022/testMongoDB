while inotifywait -r -e modify,create,delete /mnt/nvme0/home/gxr/mongdb-run/ramDisk; do
    sudo du -sh /mnt/nvme0/home/gxr/mongdb-run/ramDisk
    sudo free -h
done
