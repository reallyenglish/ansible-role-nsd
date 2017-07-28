## Release 2.0.0

* 3b4b5a7 [feature][backward incompatible] support arbitrary config (#32)

This release is backward incompatible. 

Introducing `nsd_config_server` and `nsd_config_remote`, which allow you to
create flexible `nsd.conf(5)`. The previous releases have had hard-coded
options in `nsd.conf(5)` template, but the release removed them. 

As a consequence, many variables have been removed.  See `default/main.yml` in
[3b4b5a71](https://github.com/reallyenglish/ansible-role-nsd/commit/3b4b5a715bdeca2a857f849ebf74b1f902fd003f#diff-7eeda618087b49ae876084ab6c73fdbb).
You need to stop using them.

Certificate management logic has also been removed. Provide certificates or use
`reallyenglish.x509-certificate`. An example is provided in
[`remote_control_with_variables.yml`](https://github.com/reallyenglish/ansible-role-nsd/blob/master/tests/serverspec/remote_control_with_variables.yml).

## Release 1.2.0

* ec958dd QA; rubocop 0.48 passes but 0.47.1 does not
* b015b9d [bugfix] fix modes in the spec to pass the tests
* 6d9034b remove accidentally added `)`
* 156b478 remove jinja2 expressions from `when` statements
* cef91bb fix incomplete updating CentOS to 7.3
* 94533ba QA
* b9c0492 use old format
* 328888f restore centos in `platforms`
* acdcd50 update readme with nsd_state_dir
* 79bd2e6 newlines for each config attribute
* 49ab42d qansible qa
* e7ec4df disable centos-7.2-x86_64 for now
* 7a22e23 fix variables for serverspec
* 8c81365 add few missing attributes for zone
* 78887fb create xfrd.state file in run dir on openbsd
* 39ecd20 fixes #issue-21
* 30ccd4e Validate certs and keys, fixes Issue #18
* 292da62 QA (#20)
* ebde6b8 QA (#19)
* f3c6687 QA (#17)
* 510bb13 reallyenglish.redhat-repo requires 2.1
* bf66cbc clone redhat-repo in prepare_role
* 854dcc8 support CentOS
* 8e34605 QA
* b0cd0d9 QA

## Release 1.1.0

* update metadata

## Release 1.0.0

* Initail release
