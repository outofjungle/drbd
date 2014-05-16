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
    base = 2
    exp = 0
    not_synced = nil
    begin
      wait = base ** exp
      wait = (wait > 60) ? 60 : wait
      exp = exp + 1

      Chef::Log.info( "Waiting for #{wait} seconds for sync" )
      sleep( wait )

      cmd = shell_out( 'cat /proc/drbd' )
      not_synced = cmd.stdout =~ %r(cs:Connected ro:Primary/Secondary ds:UpToDate/UpToDate)
    end while not_synced.nil?
  end
end

execute 'mkfs.ext3 /dev/drbd1' do
  not_if 'file -sL /dev/drbd1 | grep ext3'
end

execute 'mount -t ext3 /dev/drbd1 /mnt/drbd' do
  not_if 'mount | grep "/dev/drbd1"'
end
