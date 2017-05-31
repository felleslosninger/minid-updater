

ssh -tt -o StrictHostKeyChecking=no eid-puppetmaster.dmz.local  "cd /etc/puppet/environments/systest; sudo git pull; sudo librarian-puppet update"

hosts=(eid-systest-ldap01.dmz.local eid-systest-admin01.dmz.local eid-systest-app01.dmz.local  eid-systest-web01.dmz.local eid-systest-authlevel01.dmz.local eid-systest-otf-app01.dmz.local)

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


