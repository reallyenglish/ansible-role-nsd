require "spec_helper"
require "serverspec"

package = "nsd"
service = "nsd"
config  = "/etc/nsd/nsd.conf"
config_dir = "/etc/nsd"
ports = [53, 8952]

case os[:family]
when "openbsd"
  config = "/var/nsd/etc/nsd.conf"
  config_dir = "/var/nsd/etc"
when "freebsd"
  config = "/usr/local/etc/nsd/nsd.conf"
  config_dir = "/usr/local/etc/nsd"
end

key_file = "#{config_dir}/my_tsig_key.key"

if os[:family] != "openbsd"
  describe package(package) do
    it { should be_installed }
  end
end

describe file(config) do
  it { should be_file }
  its(:content) { should match(/remote-control:/) }
  its(:content) { should match(/control-enable: yes/) }
  its(:content) { should match(/control-interface: 127\.0\.0\.1/) }
  its(:content) { should match(/control-port: 8952/) }
end

%w[nsd_server.key nsd_control.key].each do |f|
  describe file("#{config_dir}/#{f}") do
    it { should be_file }
    it { should be_mode 640 }
  end
end

%w[nsd_server.pem nsd_control.pem].each do |f|
  describe file("#{config_dir}/#{f}") do
    it { should be_file }
    it { should be_mode 640 }
  end
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

describe command("nsd-control reload") do
  its(:stdout) { should match(/ok/) }
  its(:stderr) { should match(/^$/) }
end

describe port(8952) do
  it do
    pending("serverspec does not properly handle netstat on OpenBSD") if os[:family] == "openbsd"
    pending("serverspec does not properly handle netstat on FreeBSD") if os[:family] == "freebsd"
    should_not be_listening.on("192.168.133.101").with("tcp")
  end
  it { should be_listening.on("127.0.0.1").with("tcp") }
end

describe file(key_file) do
  it { should be_file }
  it { should be_mode 600 }
  its(:content) { should match Regexp.escape("secret: Qes2X7V8Fjg+EMlqng1qlCvErGFxXWa4Gxfy1uDWKvQ=") }
  its(:content) { should match(/algorithm: hmac-sha256/) }
end
