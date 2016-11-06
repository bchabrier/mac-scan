
@test "missing argument should return exit code 2" {
    run sh ../mac-scan
    [ $status = 2 ]
    first_word=$(echo $output | cut -d' ' -f1)
    echo $first_word
    [ "$first_word" = "Usage:" ]
}

@test "2 arguments should return exit code 2" {
    run sh ../mac-scan "mac1" "mac2"
    [ $status = 2 ]
    first_word=$(echo $output | cut -d' ' -f1)
    echo $first_word
    [ "$first_word" = "Usage:" ]
}

@test "1 argument should be accepted" {
    run sh ../mac-scan "a mac address"
    [ $status != 2 ]
}



@test "an existing mac address in arp -n should give its ip address" {
    # mock arp -n
    cat > arp-n.txt <<EOF
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.0.46             ether   03:23:14:ec:1b:24   C                     wlan0
192.168.0.5              ether   03:12:7b:b3:71:40   C                     wlan0
EOF
    sed -e 's/arp -n/cat arp-n.txt/' \
	-e 's/arp-scan/echo 1 responded/' \
	../mac-scan > mocked_mac-scan
    run sh ./mocked_mac-scan 03:12:7b:b3:71:40
    [ $status = 0 ]
    echo $output
    [ "$output" = "03:12:7b:b3:71:40 noresponse 192.168.0.5" ]
}

@test "a mixed case existing mac address in arp -n should give its ip address" {
    # mock arp -n
    cat > arp-n.txt <<EOF
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.0.46             ether   03:23:14:ec:1b:24   C                     wlan0
192.168.0.5              ether   03:12:7b:b3:71:40   C                     wlan0
EOF
    sed -e 's/arp -n/cat arp-n.txt/' \
	-e 's/arp-scan/echo 1 responded/' \
	../mac-scan > mocked_mac-scan
    run sh ./mocked_mac-scan 03:12:7b:B3:71:40
    [ $status = 0 ]
    echo $output
    [ "$output" = "03:12:7b:B3:71:40 noresponse 192.168.0.5" ]
}


@test "a mac address not found in arp -n should give 0 response" {
    # mock arp -n
    cat > arp-n.txt <<EOF
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.0.46             ether   03:23:14:ec:1b:24   C                     wlan0
192.168.0.5              ether   03:12:7b:b3:71:40   C                     wlan0
EOF
    sed -e 's/arp -n/cat arp-n.txt/' \
	../mac-scan > mocked_mac-scan
    run sh ./mocked_mac-scan 00:00:00:00:00:00
    [ "$status" = 0 ]
    echo $output
    [ "$(echo $output | grep '0 responded')" == "" ]
    [ "$(echo $output | grep '192.168.0.5')" == "" ]
}

teardown ()
{
    rm -f arp-n.txt mocked_mac-scan arp-scan.mock
}
