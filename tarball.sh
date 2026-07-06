#!/bin/bash
# create a tarball named malteseUser.tar.gz from the MalteseUser directory
tar -cvzf malteseUser.tar.gz --exclude='.*' MalteseUser
exit 0