#!/usr/bin/env bash

ssh -tt -o StrictHostKeyChecking=no eid-utv-est.dmz.local  "cd /etc/puppetlabs/code/environments/atest; sudo git pull; sudo librarian-puppet update"

hosts=(eid-atest-web01.dmz.local eid-atest-db01.dmz.local eid-atest-ldap01.dmz.local eid-atest-ki-front01.dmz.local eid-atest-idp-app01.dmz.local eid-atest-ki-app01.dmz.local eid-atest-pinkode01.dmz.local eid-atest-standalone01.dmz.local eid-atest-admin01.dmz.local eid-atest-idp-stork01.dmz.local eid-atest-minid-app01.dmz.local eid-atest-authlevel01.dmz.local)


for host in ${hosts[*]}
do
  ssh -tt -o StrictHostKeyChecking=no $host  "sudo -i  puppet agent --test ;  test \`echo \$?\` == '2'" 
    echo $!
done

FAIL=0
for job in `jobs -p`
do
    wait $job 
    
    code=$? 
    echo $code
    if [ "$code" -ne "0" ] ; then
    FAIL=$((FAIL+1))
    fi
done

exit  $FAIL


