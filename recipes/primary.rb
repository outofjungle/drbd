require 'chef/mixin/shell_out'
Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)

directory '/mnt/drbd' do
  owner 'root'
  group 'root'
  mode 00755
end

execute '/sbin/drbdadm -- --overwrite-data-of-peer primary r0'

ruby_block 'wait till sync happen' do
  block do
    exp = 0
    base = 2
    not_synced = nil

    begin
      wait = base ** exp
      wait = (wait > 60) ? 60 : wait
      exp = exp + 1

      Chef::Log.info( "Waiting for #{wait} seconds for sync" )
      sleep( wait )

      cmd = shell_out( '/bin/cat /proc/drbd' )
      not_synced = cmd.stdout =~ %r(cs:Connected ro:Primary/Secondary ds:UpToDate/UpToDate)
    end while not_synced.nil?
  end
end

execute '/sbin/mkfs.ext3 /dev/drbd0' do
  not_if '/usr/bin/file -sL /dev/drbd0 | /bin/grep ext3'
end

execute '/bin/mount -t ext3 /dev/drbd0 /mnt/drbd' do
  not_if '/bin/mount | /bin/grep "/dev/drbd0"'
end
