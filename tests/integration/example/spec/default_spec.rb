require 'spec_helper'

class ServiceNotReady < StandardError
end

context 'after provisioning finished' do

  describe server(:ns1) do

    it "should NOT be able to AXFR from ns2" do
      result = current_server.ssh_exec('drill -y my_tsig_key:Qes2X7V8Fjg+EMlqng1qlCvErGFxXWa4Gxfy1uDWKvQ=:hmac-sha256 example.com @192.168.133.101 axfr')
      expect(result).to match(/AXFR failed/)
    end

    #describe command('drill example.com @127.0.0.1 axfr') do
    it "should be able to AXFR from localhost" do
      result = current_server.ssh_exec('drill example.com @127.0.0.1 axfr')
      expect(result).to match(/example\.com\.\s+86400\s+IN\s+SOA\s+ns1\.example\.com\.\s+hostmaster\.example\.com\.\s+2013020201\s+10800\s+3600\s+604800\s+3600/)
    end

  end

  describe server(:ns2) do

    it "should be able to query NS example.com and get a reply from 192.168.133.100" do
      result = current_server.ssh_exec("drill -o rd example.com @192.168.133.100 ns")
      expect(result).to match(/;; flags: qr aa ; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1/)
      expect(result).to match(/example\.com.\s+86400\s+IN\s+NS\s+ns1\.example\.com\./)
      expect(result).to match(/ns1\.example\.com\.\s+120\s+IN\s+A\s+192\.168\.0\.1/)
      expect(result).to match(/;; SERVER: 192\.168\.133\.100/)
    end

    it "should be able to query NS example.com and get a reply from 127.0.0.1" do
      result = current_server.ssh_exec("drill -o rd example.com @127.0.0.1 ns")
      expect(result).to match(/;; flags: qr aa ; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1/)
      expect(result).to match(/example\.com.\s+86400\s+IN\s+NS\s+ns1\.example\.com\./)
      expect(result).to match(/ns1\.example\.com\.\s+120\s+IN\s+A\s+192\.168\.0\.1/)
      expect(result).to match(/;; SERVER: 127\.0\.0\.1/)
    end


    it "should be able to axfr from master" do

      result = current_server.ssh_exec("drill -y my_tsig_key:Qes2X7V8Fjg+EMlqng1qlCvErGFxXWa4Gxfy1uDWKvQ=:hmac-sha256 example.com @192.168.133.100 axfr")
      expect(result).to match(/example\.com\.\s+86400\s+IN\s+SOA\s+ns1\.example\.com\.\s+hostmaster\.example\.com\.\s+2013020201\s+10800\s+3600\s+604800\s+3600/)
    end

  end

end
