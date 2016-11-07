do_run ()
{
    # run with kcov for code coverage
    # include . in PATH in order to find mocked commands
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
    echo 'echo 1 responded' > arp-scan; chmod uog+x arp-scan
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
    [ "$(echo $output | grep '0 responded')" == "" ]
    [ "$(echo $output | grep '192.168.0.5')" == "" ]
}

teardown ()
{
    rm -f arp arp-scan
}
