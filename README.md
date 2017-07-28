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
| `nsd_user` | `nsd` user | `{{ __nsd_user }}` |
| `nsd_group` | `nsd` group | `{{ __nsd_group }}` |
| `nsd_db_dir` | path to data base directory | `{{ __nsd_db_dir }}` |
| `nsd_run_dir` | path to run directory | `{{ __nsd_run_dir }}` |
| `nsd_state_dir` | path to state directory | `{{ __nsd_state_dir }}` |
| `nsd_service` | service name of `nsd` | `nsd` |
| `nsd_conf_dir` | path to config directory | `{{ __nsd_conf_dir }}` |
| `nsd_conf` | path to `nsd.conf` | `{{ nsd_conf_dir }}/nsd.conf` |
| `nsd_config_server` | list of configuration in `server` directive (see below) | `[]` |
| `nsd_config_remote_control` | list of configuration in `remote-control` directive (see below) | `[]` |
| `nsd_flags` | (not implemented) | `""` |
| `nsd_remote_setup` | run `nsd-control-setup` to create self-signed keys. when false, you need to provide certificates and keys (use `reallyenglish.x509-certificate` and see an example in `tests/serverspec/remote_control_with_variables.yml` | `false` |
| `nsd_zones` | dict of zones (see below) | `{}` |

## `nsd_config_server`

This variable is a list of dict or string for `server` directive in
`nsd.conf(5)`.

When an element of `nsd_config_server` is a dict, it must have a mandatory key,
`name`. It also must have either `values` or `value` as key. The value of
`values` is a list of string. Use `values` for options that are allowed to
appear multiple times in `nsd.conf(5)`. The value of `value` is a string and
used as the value for the option.

When an element of `nsd_config_server` is a string, it is appended to `server`
sections as-is.

An example:

```yaml
    nsd_config_server:
      - "server-count: 1"
      - name: ip-address
        values: "{{ ansible_all_ipv4_addresses }} + {{ ['127.0.0.1'] }}"
      - name: do-ip4
        value: "yes"
      - name: do-ip6
        value: "no"
      - name: verbosity
        value: 0
      - name: username
        value: "{{ nsd_user }}"
      - name: zonesdir
        value: '"{{ nsd_conf_dir }}"'
      - name: database
        value: '"{{ nsd_db_dir }}/nsd.db"'
      - name: pidfile
        value: '"{{ nsd_run_dir }}/nsd.pid"'
      - name: xfrdfile
        value: '"{{ nsd_state_dir }}/xfrd.state"'
      - name: hide-version
        value: "yes"
```

## `nsd_config_remote_control`

This variable is a list of dict or string for `remote-control` directive in
`nsd.conf(5)`.

The same rules describe in `nsd_config_server` apply.

## `nsd_zones`

This variable is a dict of zones. Keys are domain name of zones. Each key must
have a dict as a value, and explained below.

| Key | Value | Mandatory? |
|-----|-------|------------|
| `zonefile` | relative path to the zone file from `nsd_conf_dir` | no |
| `zone` | the zone definition | no |
| `config` | list of configurations of the zone (see below) | no |

`config` is a list of configurations for the zone. An element can be a dict or
a string.

When an element of `config` is a dict, the dict must have a mandatory key,
`name`, which is one of zone options described in `nsd.conf(5)`. The dict must
have either `values` or `value` as a key. `values` is a list of string values
for the option. Use `values` for options that are allowed to appear multiple
times.  `value` is a string for the option.

When an element of `config` is a string, the string is simply added to the zone
configuration.

An example:

```yaml
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
    config:
      - name: provide-xfr
        values:
          - 192.168.133.101 my_tsig_key
          - 127.0.0.1 NOKEY
      - name: allow-notify
        value: 192.168.0.111 NOKEY
      - name: request-xfr
        values:
          - 192.168.0.111 NOKEY
      - name: outgoing-interface
        values:
          - 192.168.0.1
      - 'allow-axfr-fallback: yes'
```

## Debian

| Variable | Default |
|----------|---------|
| `__nsd_user` | `nsd` |
| `__nsd_group` | `nsd` |
| `__nsd_db_dir` | `/var/lib/nsd` |
| `__nsd_conf_dir` | `/etc/nsd` |
| `__nsd_run_dir` | `/var/run/nsd` |
| `__nsd_state_dir` | `{{ __nsd_db_dir }}` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__nsd_user` | `nsd` |
| `__nsd_group` | `nsd` |
| `__nsd_db_dir` | `/var/db/nsd` |
| `__nsd_conf_dir` | `/usr/local/etc/nsd` |
| `__nsd_run_dir` | `/var/run/nsd` |
| `__nsd_state_dir` | `{{ __nsd_db_dir }}` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__nsd_user` | `_nsd` |
| `__nsd_group` | `_nsd` |
| `__nsd_db_dir` | `/var/nsd/db` |
| `__nsd_conf_dir` | `/var/nsd/etc` |
| `__nsd_run_dir` | `/var/nsd/run` |
| `__nsd_state_dir` | `{{ __nsd_run_dir }}` |

## RedHat

| Variable | Default |
|----------|---------|
| `__nsd_user` | `nsd` |
| `__nsd_group` | `nsd` |
| `__nsd_db_dir` | `/var/lib/nsd` |
| `__nsd_conf_dir` | `/etc/nsd` |
| `__nsd_run_dir` | `/var/run/nsd` |
| `__nsd_state_dir` | `{{ __nsd_db_dir }}` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-nsd
  vars:
    nsd_config_server:
      - "server-count: 1"
      - name: ip-address
        values: "{{ ansible_all_ipv4_addresses }} + {{ ['127.0.0.1'] }}"
      - name: do-ip4
        value: "yes"
      - name: do-ip6
        value: "no"
      - name: verbosity
        value: 0
      - name: username
        value: "{{ nsd_user }}"
      - name: zonesdir
        value: '"{{ nsd_conf_dir }}"'
      - name: database
        value: '"{{ nsd_db_dir }}/nsd.db"'
      - name: pidfile
        value: '"{{ nsd_run_dir }}/nsd.pid"'
      - name: xfrdfile
        value: '"{{ nsd_state_dir }}/xfrd.state"'
      - name: hide-version
        value: "yes"
    nsd_remote_enable: "{% if ansible_os_family == 'FreeBSD' %}False{% else %}true{% endif %}"
    nsd_remote_setup: "{% if ansible_os_family == 'FreeBSD' %}False{% else %}true{% endif %}"
    nsd_config_remote_control:
      - "control-enable: {% if ansible_os_family == 'FreeBSD' %}no{% else %}yes{% endif %}"
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
        config:
          - name: provide-xfr
            values:
              - 192.168.133.101 my_tsig_key
              - 127.0.0.1 NOKEY
          - name: allow-notify
            value: 192.168.0.111 NOKEY
          - name: request-xfr
            values:
              - 192.168.0.111 NOKEY
          - name: outgoing-interface
            values:
              - 192.168.0.1
          - 'allow-axfr-fallback: yes'
      example.net:
        zonefile: example.net.zone
        zone: |
          example.net. 86400 IN SOA ns1.example.net. hostmaster.example.net. 2013020201 10800 3600 604800 3600
          example.net. 86400 IN NS ns1.example.net.
          example.net. 120 IN A 192.168.0.1
          ns1.example.net. 120 IN A 192.168.0.1
          mail.example.net. 120 IN A 192.168.0.1
          example.net. 120 IN MX 25 mail.example.net.
        config: []

    redhat_repo_extra_packages:
      - epel-release
    redhat_repo:
      epel:
        mirrorlist: "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-{{ ansible_distribution_major_version | default(7) }}&arch={{ ansible_architecture }}"
        gpgcheck: yes
        enabled: yes
```

Master-slave example can be found at
[tests/integration/example](https://github.com/reallyenglish/ansible-role-nsd/tree/master/tests/integration/example).

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
