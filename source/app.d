// Licensed under the GPLv3 license. See LICENSE for more information.
import std.algorithm : map, uniq;
import std.conv : to;
import std.getopt : getopt;
import std.process : execute;
import std.regex : ctRegex, match;
import std.string : format, join, split;

import colorize : cwriteln, color, cwritefln;

static immutable string usage = "Usage: git-switch-protocol -p <protocol>";

version(unittest) void main() {}
else
int main(string[] args)
{
  if(args.length == 1)
  {
    usage.color("yellow").cwriteln;
    return 1;
  }

  try
  {
    bool help;
    string targetRemote;
    protocol targetProtocol;

    getopt(
      args,
      "protocol|p", &targetProtocol,
      "help|h", &help
    );

    if(help)
    {
      usage.color("yellow").cwriteln;
      return 1;
    }

    "Switching all remotes to `%s`..."
      .format(targetProtocol.to!string)
      .color("light_blue")
      .cwriteln;

    foreach(remote; readRemotes)
      remote.switchToProtocol(targetProtocol);
    return 0;
  }
  catch(Exception err)
  {
    "ERROR: %s".format(err.msg).color("red").cwriteln;
    return 1;
  }
}

enum protocol { ssh, https, git }

struct Remote
{
  protocol type;
  string name;
  string host;
  string path;

  void switchToProtocol(protocol targetProtocol)
  {
    if(type == targetProtocol)
    {
      "Remote `%s` is already using `%s`. Skipping...".color("yellow")
        .cwritefln(name, targetProtocol.to!string);
      return;
    }

    cwritefln(
      "Switching remote `%s` from `%s` to `%s`...".color("light_blue"),
      name,
      type.to!string,
      targetProtocol.to!string
    );

    auto cmdResult = git("remote", [
      "set-url",
      name,
      targetProtocol == protocol.https ? httpsUrl : sshUrl
    ]);

    auto exitCode = cmdResult.status;
    if(exitCode != 0)
    {
      throw new Exception("Failed with code " ~ exitCode.to!string);
    }
  }

  @property string sshUrl()
  {
    return "git@%s:%s".format(host, path);
  }

  @property string httpsUrl()
  {
    return "https://%s/%s".format(host, path);
  }

  @property string gitUrl()
  {
    return "git://%s/%s".format(host, path);
  }

  unittest
  {
    auto r = Remote(protocol.https, "origin", "github.com", "yamadapc/pyjamas");
    assert(r.sshUrl == "git@github.com:yamadapc/pyjamas");
    assert(r.httpsUrl == "https://github.com/yamadapc/pyjamas");
    assert(r.gitUrl == "git://github.com/yamadapc/pyjamas");
  }
}

Remote toRemote(in string descriptor)
{
  static auto rgx = ctRegex!(
    `(?P<name>[^\s]+)\s`
    `(?P<prefix>.+(@|(://)))`
    `(?P<host>[^:/]+)(:|/)`
    `(?P<path>[^\s]+)`
  );
  auto cs = descriptor.match(rgx).captures;

  protocol p = protocol.git;
  switch(cs["prefix"]) {
    case "https://": p = protocol.https; break;
    case "git@": p = protocol.ssh; break;
    default: break;
  }

  return Remote(
    p,
    cs["name"],
    cs["host"],
    cs["path"]
  );
}

unittest
{
  auto remote = toRemote(
    "origin\tgit@github.com:yamadapc/git-switch-protocol.git (fetch)"
  );

  assert(remote.type == protocol.ssh);
  assert(remote.name == "origin");
  assert(remote.host == "github.com");
  assert(remote.path == "yamadapc/git-switch-protocol.git");
}

auto readRemotes()
{
  auto result = git("remote", ["-v"]);
  if(result.status != 0) throw new Exception("Coundn't fetch remotes");

  return result.output
    .split("\n")[0..$-1]
    .map!(toRemote)
    .uniq;
}

auto git(in string gitcmd, in string[] args = [])
{
  auto cmd = ["git", gitcmd] ~ args;
  ("  >" ~ cmd).join(" ").color("light_green").cwriteln;
  return execute(cmd);
}
