# ansible-role-nsd

Configure NSD

## Notes for CentOS

Custom SELinux policy will be installed to workaround a bug ([Bug 1311299 -
Cannot start nsd with selinux
enabled](https://bugzilla.redhat.com/show_bug.cgi?id=1311299)). The policy is
created to support CentOS for the completeness. The author is not an expert of
SELinux at all.

# Requirements

Requires `reallyenglish.redhat-repo` for CentOS. Although the role depends on
it, other platforms do not require it.

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| nsd\_user | nsd user | \_\_nsd\_user |
| nsd\_group | nsd group | \_\_nsd\_group |
| nsd\_db\_dir | db dir | {{ \_\_nsd\_db\_dir }} |
| nsd\_run\_dir | run dir | \_\_nsd\_run\_dir |
| nsd\_state\_dir | state dir | \_\_nsd\_state\_dir |
| nsd\_service | service name | nsd |
| nsd\_conf\_dir | path to config dir | {{ \_\_nsd\_conf\_dir }} |
| nsd\_conf | path to nsd.conf | {{ nsd\_conf\_dir }}/nsd.conf |
| nsd\_flags | (not used yet) | "" |
| nsd\_chroot\_enable | enable chroot | false |
| nsd\_chroot\_dir | dir to chroot | {{ nsd\_conf\_dir }} |
| nsd\_statistics\_enable | enable statistics | false |
| nsd\_ip\_addresses | a list of ip address to listen on | all available ip addresses |
| nsd\_listen\_on\_localhost | listen on localhost | true |
| nsd\_conf\_do\_ip4 | enable ip4 | yes |
| nsd\_conf\_do\_ip6 | enable ip6 | no |
| nsd\_conf\_verbosity | verbosesity | 0 |
| nsd\_conf\_zonesdir | zone dir | {{ nsd\_conf\_dir }} |
| nsd\_conf\_statistics | interval to update stats if nsd\_statistics\_enable is true | 3600 |
| nsd\_conf\_round\_robin | set "yes" to enable round robin | False |
| nsd\_remote\_enable | enable remote control | false |
| nsd\_remote\_setup | run nsd-control-setup to create keys. if false, nsd\_conf\_server\_key, nsd\_conf\_server\_cert, nsd\_conf\_control\_key and nsd\_conf\_control\_cert should be provided by the user | false |
| nsd\_conf\_control\_interface | list of interfaces to listen on | ["127.0.0.1"] |
| nsd\_conf\_control\_port | port for remote control | 8952 |
| nsd\_conf\_server\_key\_file | server key | {{ nsd\_conf\_dir }}/nsd\_server.key |
| nsd\_conf\_server\_cert\_file | server public key | {{ nsd\_conf\_dir }}/nsd\_server.pem |
| nsd\_conf\_control\_key\_file | nsd-control key | {{ nsd\_conf\_dir }}/nsd\_control.key |
| nsd\_conf\_control\_cert\_file | nsd-control public key | {{ nsd\_conf\_dir }}/nsd\_control.pem |
| nsd\_conf\_server\_key | content of nsd\_server.key | "" |
| nsd\_conf\_server\_cert | content of nsd\_server.pem | "" |
| nsd\_conf\_control\_key | content of nsd\_control.key | "" |
| nsd\_conf\_control\_cert | content of nsd\_control.pub | "" |
| nsd\_zones | dict of zone date (see below) | Null |

## Debian

| Variable | Default |
|----------|---------|
| \_\_nsd\_user | nsd |
| \_\_nsd\_group | nsd |
| \_\_nsd\_db\_dir | /var/lib/nsd |
| \_\_nsd\_conf\_dir | /etc/nsd |
| \_\_nsd\_run\_dir | /var/run/nsd |
| \_\_nsd\_state\_dir | /var/lib/nsd |

## FreeBSD

| Variable | Default |
|----------|---------|
| \_\_nsd\_user | nsd |
| \_\_nsd\_group | nsd |
| \_\_nsd\_db\_dir | /var/db/nsd |
| \_\_nsd\_conf\_dir | /usr/local/etc/nsd |
| \_\_nsd\_run\_dir | /var/run/nsd |
| \_\_nsd\_state\_dir | /var/db/nsd |

## OpenBSD

| Variable | Default |
|----------|---------|
| \_\_nsd\_user | \_nsd |
| \_\_nsd\_group | \_nsd |
| \_\_nsd\_db\_dir | /var/nsd/db |
| \_\_nsd\_conf\_dir | /var/nsd/etc |
| \_\_nsd\_run\_dir | /var/nsd/run |
| \_\_nsd\_state\_dir | /var/nsd/run |

## RedHat

| Variable | Default |
|----------|---------|
| \_\_nsd\_user | nsd |
| \_\_nsd\_group | nsd |
| \_\_nsd\_db\_dir | /var/lib/nsd |
| \_\_nsd\_conf\_dir | /etc/nsd |
| \_\_nsd\_run\_dir | /var/run/nsd |
| \_\_nsd\_state\_dir | /var/lib/nsd |

Created by [yaml2readme.rb](https://gist.github.com/trombik/b2df709657c08d845b1d3b3916e592d3)

# Dependencies

None

# Example Playbook

## Master DNS

      - hosts: localhost
        roles:
          - ansible-role-nsd
        vars:
          nsd_keys:
            my_tsig_key:
              secret: Qes2X7V8Fjg+EMlqng1qlCvErGFxXWa4Gxfy1uDWKvQ=
              algorithm: hmac-sha256
          nsd_zones:
            example.com:
              zonefile: example.com.zone
              zone: |
                example.com. 86400 IN SOA ns1.example.com. hostmaster.example.com. 2013020201 10800 3600 604800 3600
                example.com. 86400 IN NS ns1.example.com.
                example.com. 120 IN A 192.168.0.1
                ns1.example.com. 120 IN A 192.168.0.1
                mail.example.com. 120 IN A 192.168.0.1
                example.com. 120 IN MX 25 mail.example.com.
              provide_xfr:
                - 192.168.133.101 my_tsig_key
                - 127.0.0.1 NOKEY

* allow secure AXFR from 192.168.133.101
* allow insecure AXFR from localhost

## Slave

      - hosts: localhost
        roles:
          - ansible-role-nsd
        vars:
          nsd_keys:
            my_tsig_key:
              secret: Qes2X7V8Fjg+EMlqng1qlCvErGFxXWa4Gxfy1uDWKvQ=
              algorithm: hmac-sha256
          nsd_conf_control_enable: "yes"
          nsd_remote_enable: true
          nsd_remote_setup: true
          nsd_zones:
            example.com:
              request_xfr:
                - 192.168.133.100 my_tsig_key

* enable remote control
* setup keys for remote control automatically
* request AXFR with TSIG key

# License

```
Copyright (c) 2016 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
