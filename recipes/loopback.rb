directory '/var/drbd' do
  owner 'root'
  group 'root'
  mode 00755
end

execute '/bin/dd if=/dev/zero of=/var/drbd/disk.img bs=512 count=2095104' do
  not_if { ::File.exists? '/var/drbd/disk.img' }
end

execute '/sbin/losetup /dev/loop0 /var/drbd/disk.img' do
  not_if '/sbin/losetup -a | /bin/grep "/var/drbd/disk.img"'
end
