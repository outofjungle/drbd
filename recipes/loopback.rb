directory '/var/drbd' do
  owner 'root'
  group 'root'
  mode 00755
end

directory '/mnt/drbd' do
  owner 'root'
  group 'root'
  mode 00755
end

execute 'dd if=/dev/zero of=/var/drbd/disk.img bs=512 count=2095104' do
  not_if { ::File.exists? '/var/drbd/disk.img' }
end

execute 'losetup /dev/loop0 /var/drbd/disk.img' do
  not_if 'losetup -a | grep "/var/drbd/disk.img"'
end

execute 'mkfs -t ext3 /dev/loop0' do
  not_if 'fdisk /dev/loop0 -l | grep "/dev/loop0"'
end

execute 'mount -t ext2 /dev/loop0 /mnt/drbd' do
  not_if 'mount | grep "/dev/loop0"'
end
