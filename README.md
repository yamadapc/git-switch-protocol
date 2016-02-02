git-switch-protocol
===================
[![Analytics](https://ga-beacon.appspot.com/UA-54450544-1/git-switch-protocol/README)](https://github.com/igrigorik/ga-beacon)
- - -
A helper to easily switch a git repositories remotes from `ssh` to `https` and
back. Useful for places where `ssh` is blocked (such as some mermaid
coffee-shops in São Paulo, as of recently). URLs starting with `git://` are also
supported.

## Usage
```bash
$ git-switch-protocol -p https
Switching all remotes to `https`...
  > git remote -v
Switching remote `origin` from `ssh` to `https`...
  > git remote set-url origin https://github.com/yamadapc/pyjamas.git
Remote `bitbucket` is already using `https`. Skipping...
```

## Installing

To install, either build it from source with `dub` and `dmd` (version 2.066 or
greater) or download a binary release from the releases section.

## License
This code is licensed under the GPLv3 license. See the [LICENSE](/LICENSE) file
for more information.

## Donations
Would you like to buy me a beer? Send bitcoin to 3JjxJydvoJjTrhLL86LGMc8cNB16pTAF3y
