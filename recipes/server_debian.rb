#
# Cookbook Name:: postgresql
# Recipe:: server
#
# Copyright 2009-2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "postgresql::client"

node.default[:postgresql][:ssl] = node[:postgresql][:version].to_f > 8.3

package "postgresql"

template "#{node[:postgresql][:dir]}/pg_hba.conf" do
  source "debian.pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :reload, "service[postgresql]"
end

template "#{node[:postgresql][:dir]}/postgresql.conf" do
  source "debian.postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  variables node[:postgresql]
  notifies :restart, "service[postgresql]"
end

service "postgresql" do
  if node[:platform] == 'ubuntu' && node[:platform_version].to_f >= 11.04
    service_name "postgresql"
  else
    service_name "postgresql-#{node.postgresql.version}"
  end
  supports :restart => true, :status => true, :reload => true
  action :nothing
end
