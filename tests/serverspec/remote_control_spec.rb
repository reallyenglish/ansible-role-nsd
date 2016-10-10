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
when 'openbsd'
  user = '_nsd'
  group = user
  config = '/var/nsd/etc/nsd.conf'
  config_dir = '/var/nsd/etc'
  db_dir = '/var/nsd/db'
  run_dir = '/var/nsd/run'
when 'freebsd'
  config = '/usr/local/etc/nsd/nsd.conf'
  config_dir = '/usr/local/etc/nsd'
  db_dir = '/var/db/nsd'
end

key_file = "#{ config_dir }/my_tsig_key.key"

if os[:family] != 'openbsd'
  describe package(package) do
    it { should be_installed }
  end
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
    it {
      pending('serverspec does not properly handle netstat on OpenBSD') if os[:family] == 'openbsd'
      should_not be_listening.on('192.168.133.101').with('tcp')
    }
    it { should be_listening.on('192.168.133.101').with('tcp') }
  end
end

describe file(key_file) do
  it { should be_file }
  it { should be_mode 600 }
  its(:content) { should match Regexp.escape("secret: Qes2X7V8Fjg+EMlqng1qlCvErGFxXWa4Gxfy1uDWKvQ=") }
  its(:content) { should match /algorithm: hmac-sha256/ }
end

describe command('drill -o rd example.com @192.168.133.100  ns') do
  its(:stdout) { should match /;; flags: qr aa ; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1/ }
  its(:stdout) { should match /example\.com.\s+86400\s+IN\s+NS\s+ns1\.example\.com\./ }
  its(:stdout) { should match /ns1\.example\.com\.\s+120\s+IN\s+A\s+192\.168\.0\.1/ }
  its(:stdout) { should match /;; SERVER: 192\.168\.133\.100/ }
  its(:stderr) { should match /^$/ }
end

describe command('drill -o rd example.com @127.0.0.1 ns') do
  its(:stdout) { should match /;; flags: qr aa ; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1/ }
  its(:stdout) { should match /example\.com.\s+86400\s+IN\s+NS\s+ns1\.example\.com\./ }
  its(:stdout) { should match /ns1\.example\.com\.\s+120\s+IN\s+A\s+192\.168\.0\.1/ }
  its(:stdout) { should match /;; SERVER: 127\.0\.0\.1/ }
  its(:stderr) { should match /^$/ }
end

describe command('drill -y my_tsig_key:Qes2X7V8Fjg+EMlqng1qlCvErGFxXWa4Gxfy1uDWKvQ=:hmac-sha256 example.com @192.168.133.100 axfr') do
  its(:stdout) { should match /example\.com\.\s+86400\s+IN\s+SOA\s+ns1\.example\.com\.\s+hostmaster\.example\.com\.\s+2013020201\s+10800\s+3600\s+604800\s+3600/ }
  its(:stderr) { should match /^$/ }
end
