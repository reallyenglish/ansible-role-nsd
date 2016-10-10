require 'spec_helper'
require 'serverspec'

package = 'nsd'
service = 'nsd'
config  = '/etc/nsd/nsd.conf'
config_dir = '/etc/nsd'
user    = 'nsd'
group   = 'nsd'
ports   = [ 53 ]
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
  its(:content) { should match /ip-address: 10\.0\.2\./ }
  its(:content) { should match /ip-address: 127\.0\.0\.1/ }
  its(:content) { should match /do-ip4: yes/ }
  its(:content) { should match /do-ip6: no/ }
  its(:content) { should match /verbosity: 0/ }
  its(:content) { should match /username: #{user}/ }
  its(:content) { should_not match /chroot: / }
  its(:content) { should match Regexp.escape("zonesdir: \"#{config_dir}\"") }
  its(:content) { should match Regexp.escape("database: \"#{db_dir}/nsd.db\"") }
  its(:content) { should match Regexp.escape("pidfile: \"#{run_dir}/nsd.pid\"") }
  its(:content) { should match Regexp.escape("xfrdfile: \"#{db_dir}/xfrd.state\"") }
  its(:content) { should match /verbosity: 0/ }
  its(:content) { should match /round-robin: no/ }
  if os[:family] == 'freebsd'
    its(:content) { should_not match /control-enable: yes/ }
  end
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
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

describe file(key_file) do
  it { should be_file }
  it { should be_mode 600 }
  its(:content) { should match Regexp.escape("secret: Qes2X7V8Fjg+EMlqng1qlCvErGFxXWa4Gxfy1uDWKvQ=") }
  its(:content) { should match /algorithm: hmac-sha256/ }
end

describe command('drill -o rd example.com @127.0.0.1 ns') do
  its(:stdout) { should match /;; flags: qr aa ; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1/ }
  its(:stdout) { should match /example\.com.\s+86400\s+IN\s+NS\s+ns1\.example\.com\./ }
  its(:stdout) { should match /ns1\.example\.com\.\s+120\s+IN\s+A\s+192\.168\.0\.1/ }
  its(:stdout) { should match /;; SERVER: 127\.0\.0\.1/ }
  its(:stderr) { should match /^$/ }
end

describe command('drill example.com @127.0.0.1 axfr') do
  its(:stdout) { should match /example\.com\.\s+86400\s+IN\s+SOA\s+ns1\.example\.com\.\s+hostmaster\.example\.com\.\s+2013020201\s+10800\s+3600\s+604800\s+3600/ }
  its(:stderr) { should match /^$/ }
end
