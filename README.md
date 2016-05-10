ansible-role-nsd
=====================

Configure NSD

Requirements
------------

None

Role Variables
--------------

| Variable | Description | Default |
|----------|-------------|---------|
| nsd\_user | nsd user | nsd |
| nsd\_group | nsd group | nsd |
| nsd\_db\_dir | db dir | {{ \_\_nsd\_db\_dir }} |
| nsd\_run\_dir | run dir | /var/run/nsd |
| nsd\_service | service name | nsd |
| nsd\_conf\_dir | path to config dir | {{ \_\_nsd\_conf\_dir }} |
| nsd\_conf | path to nsd.conf | {{ nsd\_conf\_dir }}/nsd.conf |
| nsd\_flags | (not used yet) | "" |
| nsd\_chroot\_enable | enable chroot | false |
| nsd\_chroot\_dir | dir to chroot | {{ nsd\_conf\_dir }} |
| nsd\_statistics\_enable | enable statistics | true |
| nsd\_ip\_addresses | a list of ip address to listen on | all available ip addresses |
| nsd\_listen\_on\_localhost | listen on localhost | true |
| nsd\_conf\_do\_ip4 | enable ip4 | yes |
| nsd\_conf\_do\_ip6 | enable ip6 | no |
| nsd\_conf\_verbosity | verbosesity | 0 |
| nsd\_conf\_zonesdir | zone dir | {{ nsd\_conf\_dir }} |
| nsd\_conf\_statistics | interval to update stats if nsd\_statistics\_enable is true | 3600 |
| nsd\_conf\_round\_robin | enable round robin | no |
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


### FreeBSD

| Variable |  Default |
|----------|----------|
| \_\_nsd\_db\_dir | /var/db/nsd |
| \_\_nsd\_conf\_dir | /usr/local/etc/nsd |

Dependencies
------------

None

Example Playbook
----------------


License
-------

BSD

Author Information
------------------

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
