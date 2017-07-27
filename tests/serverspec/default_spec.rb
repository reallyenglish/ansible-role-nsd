require "spec_helper"
require "serverspec"

package = "nsd"
service = "nsd"
config  = "/etc/nsd/nsd.conf"
config_dir = "/etc/nsd"
user    = "nsd"
group   = "nsd"
ports   = [53]
db_dir  = "/var/lib/nsd"
run_dir = "/var/run/nsd"
state_dir = db_dir

case os[:family]
when "openbsd"
  user = "_nsd"
  group = user
  config = "/var/nsd/etc/nsd.conf"
  config_dir = "/var/nsd/etc"
  db_dir = "/var/nsd/db"
  run_dir = "/var/nsd/run"
  state_dir = run_dir
when "freebsd"
  config = "/usr/local/etc/nsd/nsd.conf"
  config_dir = "/usr/local/etc/nsd"
  db_dir = "/var/db/nsd"
  state_dir = db_dir
end

key_file = "#{config_dir}/my_tsig_key.key"

if os[:family] != "openbsd"
  describe package(package) do
    it { should be_installed }
  end
end

describe file(config) do
  it { should be_file }
  its(:content) { should match(/ip-address: 10\.0\.2\./) }
  its(:content) { should match(/ip-address: 127\.0\.0\.1/) }
  its(:content_as_yaml) { should include("server" => include("do-ip4" => true)) }
  its(:content_as_yaml) { should include("server" => include("do-ip6" => false)) }
  its(:content_as_yaml) { should include("server" => include("verbosity" => 0)) }
  its(:content_as_yaml) { should include("server" => include("username" => user)) }
  its(:content_as_yaml) { should include("server" => include("zonesdir" => config_dir)) }
  its(:content_as_yaml) { should include("server" => include("database" => "#{db_dir}/nsd.db")) }
  its(:content_as_yaml) { should include("server" => include("pidfile" => "#{run_dir}/nsd.pid")) }
  its(:content_as_yaml) { should include("server" => include("xfrdfile" => "#{state_dir}/xfrd.state")) }
  its(:content) { should_not match(/^chroot: /) }
  its(:content) { should_not match(/^key:\n\+name: my_tsig_key\n\s+include: "#{Regexp.escape("/usr/local/etc/nsd/my_tsig_key.key")}"/) }

  zone = <<-__EOF__
    name: example.com
    zonefile: example.com.zone
    provide-xfr: 192.168.133.101 my_tsig_key
    provide-xfr: 127.0.0.1 NOKEY
    allow-notify: 192.168.0.111 NOKEY
    request-xfr: 192.168.0.111 NOKEY
    outgoing-interface: 192.168.0.1
    allow-axfr-fallback: yes
  __EOF__
  its(:content) { should match(/^zone:\n#{zone}/) }
  its(:content_as_yaml) { should include("remote-control" => include("control-enable" => os[:family] == "freebsd" ? false : true)) }
  its(:content) { should_not match(/round-robin:/) }
  if os[:family] == "freebsd"
    its(:content) { should_not match(/control-enable: yes/) }
  end
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
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
  its(:content) { should match(Regexp.escape("secret: Qes2X7V8Fjg+EMlqng1qlCvErGFxXWa4Gxfy1uDWKvQ=")) }
  its(:content) { should match(/algorithm: hmac-sha256/) }
end

describe command("drill -o rd example.com @127.0.0.1 ns") do
  its(:stdout) { should match(/;; flags: qr aa ; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1/) }
  its(:stdout) { should match(/example\.com.\s+86400\s+IN\s+NS\s+ns1\.example\.com\./) }
  its(:stdout) { should match(/ns1\.example\.com\.\s+120\s+IN\s+A\s+192\.168\.0\.1/) }
  its(:stdout) { should match(/;; SERVER: 127\.0\.0\.1/) }
  its(:stderr) { should match(/^$/) }
end

describe command("drill example.com @127.0.0.1 axfr") do
  its(:stdout) { should match(/example\.com\.\s+86400\s+IN\s+SOA\s+ns1\.example\.com\.\s+hostmaster\.example\.com\.\s+2013020201\s+10800\s+3600\s+604800\s+3600/) }
  its(:stderr) { should match(/^$/) }
end
