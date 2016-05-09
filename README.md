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
