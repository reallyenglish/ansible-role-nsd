require 'spec_helper'
require 'serverspec'

package = 'nsd'
service = 'nsd'
config  = '/etc/nsd/nsd.conf'
config_dir = '/etc/nsd'
user    = 'nsd'
group   = 'nsd'
ports   = [ 53, 8952 ]
log_dir = '/var/log/nsd'
db_dir  = '/var/lib/nsd'
run_dir = '/var/run/nsd'

case os[:family]
when 'freebsd'
  config = '/usr/local/etc/nsd/nsd.conf'
  config_dir = '/usr/local/etc/nsd'
  db_dir = '/var/db/nsd'
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match /remote-control:/ }
  its(:content) { should match /control-enable: yes/ }
  its(:content) { should match /control-interface: 127\.0\.0\.1/ }
  its(:content) { should match /control-port: 8952/ }
  its(:content) { should match Regexp.escape("server-key-file: \"#{config_dir}/nsd_server.key\"") }
  its(:content) { should match Regexp.escape("server-cert-file: \"#{config_dir}/nsd_server.pem\"") }
  its(:content) { should match Regexp.escape("control-key-file: \"#{config_dir}/nsd_control.key\"") }
  its(:content) { should match Regexp.escape("control-cert-file: \"#{config_dir}/nsd_control.pem\"") }
end

%w[ nsd_server.key nsd_control.key ].each do |f|
  file ("#{config_dir}/#{f}") do
    it { should be_file }
    it { should be_mode 600 }
  end
end

%w[ nsd_server.pem nsd_control.pem ].each do |f|
  file ("#{config_dir}/#{f}") do
    it { should be_file }
    it { should be_mode 644 }
  end
end

case os[:family]
when 'freebsd'
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe command('nsd-control reload') do
  its(:stdout) { should match /ok/ }
  its(:stderr) { should match /^$/ }
end

# serverspec on FreeBSD does not support this
case os[:family]
when 'freebsd'
else
  describe port(8952) do
    it { should_not be_listening.on('192.168.133.i01').with('tcp') }
    it { should be_listening.on('192.168.133.i01').with('tcp') }
  end
end
