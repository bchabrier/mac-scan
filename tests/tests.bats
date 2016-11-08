do_run ()
{
    # run with kcov for code coverage
    # include . in PATH in order to find mocked commands
    PATH=.:$PATH hash -r
    ls -l
    which arp-scan || true
    which arp || true
    PATH=.:$PATH run kcov --coveralls-id=$TRAVIS_JOB_ID --exclude-pattern=mac-scan/tests coverage "$@"

    # then run for the test 
    echo status=$status
    echo output=$output
}


@test "missing argument should return exit code 2" {
    do_run ../mac-scan
    [ $status = 2 ]
    first_word=$(echo $output | cut -d' ' -f1)
    echo first_word=$first_word
    [ "$first_word" = "Usage:" ]
}

@test "2 arguments should return exit code 2" {
    do_run ../mac-scan "mac1" "mac2"
    [ $status = 2 ]
    first_word=$(echo $output | cut -d' ' -f1)
    echo first_word=$first_word
    [ "$first_word" = "Usage:" ]
}

@test "1 argument should be accepted" {
    do_run ../mac-scan "a mac address"
    [ $status != 2 ]
}



@test "an existing mac address in arp -n should give its ip address" {
    # mock arp -n
    echo 'cat <<EOF
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.0.46             ether   03:23:14:ec:1b:24   C                     wlan0
192.168.0.5              ether   03:12:7b:b3:71:40   C                     wlan0
EOF
' > arp; chmod uog+x arp
    # mock arp-scan
    echo 'echo 1 responded' > arp-scan; chmod uog+x arp-scan; ls -l
    do_run ../mac-scan 03:12:7b:b3:71:40
    [ $status = 0 ]
    [ "$output" = "03:12:7b:b3:71:40 noresponse 192.168.0.5" ]
}

@test "a mixed case existing mac address in arp -n should give its ip address" {
    # mock arp -n
    echo 'cat <<EOF
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.0.46             ether   03:23:14:ec:1b:24   C                     wlan0
192.168.0.5              ether   03:12:7b:b3:71:40   C                     wlan0
EOF
' > arp; chmod uog+x arp
    # mock arp-scan
    echo 'echo 1 responded' > arp-scan; chmod uog+x arp-scan
    do_run ../mac-scan 03:12:7b:B3:71:40
    [ $status = 0 ]
    [ "$output" = "03:12:7b:B3:71:40 noresponse 192.168.0.5" ]
}


@test "a mac address not found in arp -n should give 0 response" {
    # mock arp -n
    echo 'cat <<EOF
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.0.46             ether   03:23:14:ec:1b:24   C                     wlan0
192.168.0.5              ether   03:12:7b:b3:71:40   C                     wlan0
EOF
' > arp; chmod uog+x arp
    do_run ../mac-scan 00:00:00:00:00:00
    [ "$status" = 0 ]
    [ "$output" = "00:00:00:00:00:00 noresponse" ]
}

@test "a mac address found in arp -n should give a response" {
    # find a known ip address that is accessible
    local mac
    local ip
    local tmpfile=/tmp/arp-n.$$.txt
    arp -n | awk 'NR>1' > $tmpfile
    while read line
    do
	ip=$(echo "$line" | awk '{print $1}')
	if ping -w 1 $ip
	then
	    mac=$(echo "$line" | awk '$3 ~ /^[0-9a-fA-F:]+$/ {print $3}')
	    echo "Will mac-scan $mac ($ip), which responds to ping."
	    break
	fi
    done < $tmpfile
    rm -f $tmpfile

    do_run ../mac-scan "$mac"
    [ "$status" = 0 ]
    local words123=$(echo $output | awk '{print $1, $2, $3}')
    echo words123=$words123
    [ "$words123" = "$mac responded $ip" ]
}

teardown ()
{
    rm -f arp arp-scan
}
