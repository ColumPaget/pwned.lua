## pwned.lua

pwned.lua is a command-line client for the 'haveibeenpwned.com' web API written in lua. It can list details on all known breaches, breaches for a given email/user account, occurances of a given password in all breaches, and instances of account details being pasted to pastbin-style sites.

## LICENCE

pwned.lua is licenced under the GPL v3.

## INSTALL

pwned.lua requires the following libraries to be installed

libUseful      https://github.com/ColumPaget/libUseful   
libUseful-lua  https://github.com/ColumPaget/libUseful-lua


## USAGE

```
pwned.lua breaches [options]                   - list all breaches
pwned.lua account <account name> [options]     - list breaches for named account
pwned.lua password <password> [options]        - check number of occurances of <password> in breaches
pwned.lua pastes <account name> [options]      - list sites where account details have been pasted

options: 
  -s <sort type>    - sort breaches by 'date', 'size' or 'name'
  -d <date>         - only show breaches matching fnmatch-style pattern <date>. e.g. -d 2017-*
  -v                - show more detail
  -q                - output just a number representing the number of accounts/passwords found
  -n                - format qty as full number rather than metric (i.e. 1200 rather than 1.2k)
  -u <user-agent>   - set user-agent string for https communications
  -p <proxy>        - use proxy. e.g. socks4:127.0.0.1:1080, socks5:192.168.1.1:1080, sshtunnel:user:password@ssh-server, https:user@proxy.com:1080
  -D                - enable debug output
```

most queries will return the number of matching breaches found, or in the case of 'password' queries, the number of accounts using that password. Unfortunately exit codes cannot go above 127, thus for scripts it is better to use the -q option.

## PASSWORD SECURITY

'password' queries never send you password. Instead they generate a sha1 has of the password, and send the first 5 bytes of it. haveibeenpwned.com responds with information on all the sha1 hashes of passwords that start with the same 5 bytes. From these we pick out the one that matches our sha1 hash, if any do, thus identifying our password amoung the data. Thus passwords are never disclosed in using the service.


