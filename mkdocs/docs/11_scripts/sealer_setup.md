## Prerequisites

To get things started we need the "age" binary in a valid version (v1.3.1).

The repository is [here](https://github.com/FiloSottile/age) and the release can be downloaded via curl.

`e.g. download v1.3.1`
```shell
curl -LO https://github.com/FiloSottile/age/releases/download/v1.3.1/age-v1.3.1-linux-amd64.tar.gz
tar xzf age-v1.3.1-linux-amd64.tar.gz
cd age
mv age* /usr/local/bin/
cd ..
rm -rf age
rm age-v1.3.1-linux-amd64.tar.gz
```

After downloading and install the age binaries you can use the sealer.sh script.

<hr>

## Usage


The help option is all you need to know:

```shell
Flags:
------
 -d|--directory  Target directory of files to en/decrypt (default pwd/myfiles)
 -a|--action     Action to perform (seal/unseal) (default none)
 -i|--identfile  Path to age ident file (default pwd/age-ident)
 -h|--help       Displays this help
 -u|--update     Updates the script from GitHub
 -v|--version    Print the version of the script

Usage:
------
 - e.g. ./sealer.sh -d ./mydir -a seal -i ./myident
 - e.g. ./sealer.sh -d ./mydir -a unseal -i ./myident

Info:
-----
 - if you do not have an ident file it will be created on first use (don't lose it)
```

To ease up usage the script also looks into the ENV var "AGEIDENTF". You can set a path to your already created identity file and just omit the "-i" flag.

Using this you only need to set "-d" and "-a" and can seal/unseal your directories faster.

<hr>

## Drawbacks

Since using the encrypted identity file the password for this file must be entered manually. I wanted it this way but if you want to use the script in headless mode (for pipelining oder automation) you would need to modify it and create an identity file that is not encrypted.

The rest should work out-of-the-box.

<hr>
