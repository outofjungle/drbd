require 'chef/mixin/shell_out'
Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)

directory '/mnt/drbd' do
  owner 'root'
  group 'root'
  mode 00755
end

execute '/sbin/drbdadm -- --overwrite-data-of-peer primary disk1'

ruby_block 'wait till sync happen' do
  block do
    not_synced = nil
    begin
      Chef::Log.info( 'Waiting for 5 seconds for sync' )
      sleep(5)

      cmd = shell_out( 'cat /proc/drbd' )
      not_synced = cmd.stdout =~ %r(cs:Connected ro:Primary/Secondary ds:UpToDate/UpToDate)
    end while not_synced.nil?
  end
end

execute 'mkfs -t ext3 /dev/drbd1' do
  not_if 'file -sL /dev/drbd1 | grep ext3'
end

execute 'mount -t ext2 /dev/drbd1 /mnt/drbd' do
  not_if 'mount | grep "/dev/drbd1"'
end
