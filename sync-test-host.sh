#!/bin/bash
#
# Copy local files to remote test host
#
TEST_HOST=172.24.24.234
scp vytool root@${TEST_HOST}:/usr/sbin/vytool
scp SimpleRouter.sample root@${TEST_HOST}:/etc/vytool/config-samples/SimpleRouter.sample
scp validate-vyatta-config.pl root@${TEST_HOST}:/usr/share/vytool/validate-vyatta-config.pl
