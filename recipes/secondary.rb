require 'chef/mixin/shell_out'
Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)

directory '/mnt/drbd' do
  owner 'root'
  group 'root'
  mode 00755
end

execute '/sbin/drbdadm secondary disk1'
