![Build Status](https://travis-ci.org/bchabrier/mac-scan.svg?branch=master) [![Coverage Status](https://coveralls.io/repos/github/bchabrier/mac-scan/badge.svg)](https://coveralls.io/github/bchabrier/mac-scan)
# mac-scan
Scans a mac address on the local network, reporting if it is connected. Very useful to track if your iPhone is connected to your Wifi network.

## Installation

`map-scan`requires `arp-scan` to be installed. On Debian systems you can install this with:

```npm
$ sudo apt-get install arp-scan
```

`map-scan` can be run with `sh`, or directly if execute permissions are set:
```npm
$ sh map-scan
Usage: mac-scan <mac_address>

$ chmod uog+x map-scan
$ map-scan
Usage: mac-scan <mac_address>
```

## Usage

```npm
$ map-scan
Usage: mac-scan <mac_address>
```

`mac-scan` scans the local network for the specified mac address, reports any IP address associated to it as well as if the targeted device responded. 

## Examples

### With a responding device:

```npm
$ map-scan 05:c9:31:c8:d9:a7
05:c9:31:c8:d9:a7 responded 192.168.0.46 Intel Corporate
```

### With a non responding device:

```npm
$ map-scan 05:c9:31:c8:d9:a7
05:c9:31:c8:d9:a7 noresponse 192.168.0.46
```

### With an unknown device:

```npm
$ map-scan 05:c9:31:c8:d9:a1
05:c9:31:c8:d9:a1 noresponse
```

## Tests

Tests are run with `bats`(https://github.com/sstephenson/bats).

Test coverage uses `kcov` (http://simonkagstrom.github.io/kcov/index.html). Note that the bagde at the top of this file reports a wrong coverage (should be 100%).

