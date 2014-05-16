#
# Cookbook Name:: drbd
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'ntp'

template '/etc/hosts' do
  source 'hosts.erb'
  mode 00644
  owner 'root'
  group 'root'
end

execute '/bin/rpm -ivh http://elrepo.org/elrepo-release-6-5.el6.elrepo.noarch.rpm' do
  not_if { ::File.exists? '/etc/yum.repos.d/elrepo.repo' }
end

packages = %w(kmod-drbd83 drbd83-utils)
packages.each do | pkg |
  execute "/usr/bin/yum install -y #{pkg}" do
    not_if "/bin/rpm -qa #{pkg} | /bin/grep #{pkg}"
  end
end

execute '/sbin/modprobe drbd' do
  not_if 'lsmod | /bin/grep drbd'
end

template '/etc/drbd.d/r0.res' do
  source 'resource.res.erb'
  mode 00644
  owner 'root'
  group 'root'
end

execute '/sbin/drbdadm create-md r0' do
  not_if '/sbin/drbdadm get-gi r0'
end

execute '/etc/init.d/drbd start'
