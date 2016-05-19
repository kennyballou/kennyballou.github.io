---
title: "Releasing Elixir/OTP applications to the World"
description: "The perils of releasing OTP applications in the wild"
tags:
  - "Erlang/OTP"
  - "Elixir"
  - "Phoenix"
  - "Docker"
  - "How-to"
  - "Tips and Tricks"
date: "2016-05-27"
categories:
  - "Development"
slug: "elixir-otp-releases"
---

Developing Elixir/OTP applications is an enlightening, mind-boggling, and
ultimately enjoyable experience. There are so many features of the language
that change the very way we as developers think about concurrency and program
structure. From writing pure functional code, to using message passing to
coordinate complex systems, it is one of the best languages for the SMP
revolution that has been slowly boiling under our feet.

However, _releasing_ Elixir and OTP applications is an entirely different and
seemingly seldom discussed topic.

The distribution tool chain of Erlang and OTP is a complicated one, There's
[`systools`][9], [`reltool`][10], [`rebar(?3)`][11], and [`relx`][12] just to
name a few that all ultimately help in creating an Erlang/OTP ["release"][13].
Similar to `rebar3`, [`exrm`][7] takes the high-level abstraction approach to
combining `reltool` and `relx` into a single tool chain for creating releases of
Elixir projects. Of course, we can also borrow from the collection of
[autotools][14].

There are plenty of articles and posts discussing how and why to use
`exrm`. I feel many of them, however, fail to _truly_ discuss _how_ to do this
effectively. Most will mention the surface of the issue, but never give the
issue any real attention. As any developer that wants to eventually _ship_
code, this is entirely too frustrating to leave alone.

There are "ways" of deploying OTP code relatively simply, however, these
methods generally avoid good practice of continuous integration/continuous
deployment, e.g., "build the OTP application _on_ the target system" or simply
use `mix run`, etc.

I cannot speak for everyone, but my general goal is to _not_ have such a
manual step in my release pipeline, let alone having a possibly full autotool
chain and Erlang/Elixir stack on the production system is slightly unnerving
for it's own set of reasons.

## Problem ##

Here are some selected quotes; I'm not trying to pick on anyone in particular
or the community at large, but I'm trying to show a representation of why this
very topic is an issue in the first place.

> We need to be sure that the architectures for both our build and hosting
> environments are the same, e.g. 64-bit Linux -> 64-bit Linux. If the
> architectures don't match, our application might not run when deployed. Using
> a virtual machine that mirrors our hosting environment as our build
> environment is an easy way to avoid that problem.
[Phoenix Exrm Releases][8].

And another, similar quote:

> One important thing to note, however: *you must use the same architecture for
> building your release that the release is getting deployed to.* If your
> development machine is OS X and you’re deploying to a Linux server, you need
> a Linux machine to build your exrm release or it isn't going to work, or you
> can just build on the same server you’re going to be running everything on.
[Brandon Richey][1].

Unfortunately, these miss a lot of the more subtle issues, dependency hell is
real, and we're about to really dive into it.

There are a few examples where "same architecture" isn't enough, and this is
where we will spend the majority of our time.

For these examples, we will assume our host machine is running GNU/Linux,
specifically Arch Linux, and our target machine is running CentOS 7.2. Both
machines are running the `AMD64` instruction sets, the architectures are the
_same_.

### Shared Objects ###

Let's start with the most simplistic issue, different versions of shared
objects.

Arch Linux is a rolling release distribution that is generally _right_ on the
bleeding edge of packages, upstream is usually the development sources
themselves. When `ncurses` moves version 6, Arch isn't far behind in putting it
in the stable package repository (and rebuilding a number of packages that
depend on `ncurses`). CentOS, on the other hand, is not so aggressive.
Therefore, when using the default `relx` configuration with `exrm`, the Erlang
runtime system (ERTS) bundled with the release _will_ be incompatible with the
target system.

When the OTP application is started, an obscure linking error will be emitted
complaining about how ERTS cannot find a `ncurses.so.6` file and promptly fail.

Worse, after possibly "fixing" this issue, `ncurses` is only one of a few
shared objects Erlang needs to run, depending on what was enabled when Erlang
was built or what features the deployed application needs.

### Erlang Libraries ###

We may try to resolve this issue by adding a particular `rel/relx.config` file
to our Elixir project. Specifically, we will _not_ bundle ERTS, opting to use
the target's ERTS instead.

    {include_erts, false}.

This seems like a promising approach, until another error message is emitted at
startup, namely, ERTS cannot find `stdlib-2.8` in the `/usr/lib/erlang/lib`
folder.

Did I mention that our current build system is Arch and our target is CentOS?
Arch may have the _newest_ version of Erlang in the repository and CentOS is
still at whatever it was at before: R16B unless the [Erlang Solutions][1]
release is being used.

Since Erlang applications do (patch number) version locking, applications in
the dependency tree will need to match exactly and it's guaranteed that any and
all OTP applications will be at least depending on the Erlang kernel and the
Erlang standard library, these are at least two OTP applications _our_
application is going to need that are *no longer packaged when `relx` doesn't
bundle ERTS*.

Even if we specify another option to `relx`, namely, `{system_libs, true}.`, we
are left with the same lack of Erlang system libraries.

That's correct and there is some sensible reasons for this. If we ask `exrm`
and therefore `relx` to not include the build system's ERTS, we are _also_
excluding the standard Erlang libraries from the release as well, asking to
include the standard libraries of the build system's ERTS could run into the
_very_ same issues as above for a whole host of other reasons.

We are left to attempt more solutions.

### Docker or Virtualization ###

Next, since we do want to ultimately get our build running in a CI/CD
environment, we may look toward virutalization/containerization. Being sensible
people, we try to use a small image, maybe basing our image on [Alpine
Linux][2] as to be nice to our precious `/var` or SSD space. We may even go so
far as to build Erlang and Elixir ourselves in these images to make sure we
have the most control over them as we can. Furthermore, since we are building
everything ourself, shipping the built ERTS seems like a good idea too, so we
can delete the `rel/relx.config` file.

This seems promising. However, we have shared object problems again. Since we
are building Erlang and Elixir ourselves, we decided to disable `termcap`
support thus no longer requiring the `ncurses` library altogether. We hope that
the `openssl` libraries are the same, so we don't have to worry about that
mess, and we move on.

This time, when we attempt to deploy the application get a different, obscure
error: something about our `musl` C library isn't found on the target system.
Right, because we are trying to create a small image, we opted to use the
`musl` C library because of it's size and being easily supported in the Alpine
Linux container. Trying to use GNU C library is too cumbersome and would only
inflate the image beyond any gains we would achieve by using Alpine in the
first place.

That's not going to work.

### OTP as Project Dependency ###

Another option we might try is make Erlang a build dependency of our Elixir
application, this _could_ be achieved via the following structure:

    {:otp,
     "~> 18.3.2",
     github: "erlang/otp",
     tag: "OTP-18.3.2",
     only: :prod,
     compile: "./otp_build autoconf;" <>
              "./configure --without-termcap --without-javac;" <>
              "make -j4" <>
              "DISTDIR=/tmp/erlang make install"
    }

Then using `rel/relx.config` with:

    {include_erts, "/tmp/erlang"}.

*May* turn out to work, assuming the build server and the target system have
the same shared objects for OpenSSL and others that may be enabled by default.

> However, I didn't follow this idea all the way to the end as I wasn't
> entirely happy with it, and it would fall to some later issues.

Notably, though, this will inflate the production builds drastically since our
`mix deps.get` and `mix deps.compile` steps will hang attempting to build
Erlang itself.

However, again, we will likely run into issues with the C library used by the
build system/container. Going this route doesn't allow us to use Alpine Linux
either.

Worse, there's another issue that hasn't even shown itself but is lying in
wait: native implemented (or interface) functions (NIFs).

If our project has a dependency that builds a NIF as part of its build
(Elixir's [comeonin][16] is a good example of this), unless the NIF is
statically compiled, we are back to square one and shared objects are not our
friends. Furthermore, if we are using a different standard library
implementation, i.e., `musl` vs `glibc`, the dependency will likely complain
about it as well.

## Non-Solution Solutions ##

Of course, all of these above issues can be solved by "just building on the
target machine" or by simply using `mix run` on the target instead. However, I
personally find these solutions unacceptable.

I'm not overly fond of requiring my target hosts, my production machines,
running a full development tool chain. Before this is dismissed as a personal
issue, remember that our dependency tree may contain NIFs outside of our
control. Therefore, it's not just Erlang/Elixir that are required to be on the
machine, but a C standard library and autotools too.

This solution doesn't immediately give the impression of scaling architecture.
If a new release needs to be deployed, each server will now need to spare some
load for building the project and its dependencies before any real, actual
upgrading can continue.

## Solutions(?) ##

What are we to do? How are we to build Erlang/Elixir/OTP applications as part
of our CI/CD pipeline? Particularly, how are we to build our applications on a
CI/CD system and *not* the production box(es) themselves?

If any of the above problems tell us anything, it's that the build system must
be either the *exact same* machine or clone with build tools. Thankfully, we
can achieve a "clone" without too much work using [Docker][3] and the [official
image registries][4].

By using the official CentOS image and a specific tag, we can match our target
system almost exactly. Furthermore, building the Erlang/Elixir stack from
source is a relatively small order for a Docker container too, making
versioning completely within reach. Moreover, since the build host and the
target host are nearly identical, bundling ERTS should be a non-issue.

> This is the observed result of using [docker-elixir-centos][5] for a base
> image for CI builds.

Another possible solution is to ship Docker containers as the artifact of the
build. However, this, to do well, requires a decent Docker capable
infrastructure and deployment process. Furthermore, going this route, it's
unlikely that `exrm` is even necessary at all. It is likely more appropriate to
simply use `mix run` or whatever the project's equivalent is. Another thing
lost here, is [relups][6], which is essentially the whole reason of wanting to
use `exrm` in the first place.

As such, if using `exrm` is desired, setting up a build server will be
imperative to building reliably and without building on production. Scaling
from a solid build foundation will be much easier than building and "deploying"
on the production farm itself.

## Moving Forward ##

Releasing software isn't in a particularly hard class of problems, but it does
have its challenges. Some languages attempt to solve this challenge in its
artifact/build result. Other languages, unfortunately, don't attempt to solve
this problem at all. Though, I can see it possible to eventually reach a goal
of being able to create binary releases with steps as simple as `./configure &&
make && make install && tar`.

But we aren't there yet.

But we are close.

The current way Erlang/OTP applications want to be deployed includes wanting to
ship _with_ the runtime, this is a great starting point.

To move to a better, easier release cycle, we need a few things:

*   The ability to (natively) cross-compile to different architectures and
    different versions of ERTS _and_ cross-compile Erlang code itself.

*   The ability to easily statically compile ERTS and bundle the result for the
    specified architecture.

Cross-compiling to different versions of ERTS is likely a harder problem to
tackle. But being able to cross-compile the ERTS itself is likely much easier
since this is already a [feature][15] of GCC.

Thus, our problem is now how do we add and/or expose the facility of
customizing the appropriate build flags to our projects and dependencies to
cross-compile a static ERTS and any NIFs and bundle these into a solid OTP
release.

[1]: https://erlang-solutions.com

[2]: http://alpinelinux.org

[3]: https://docker.com

[4]: https://hub.docker.com/explore/

[5]: https://github.com/kennyballou/docker-elixir-centos

[6]: http://erlang.org/doc/man/relup.html

[7]: https://github.com/bitwalker/exrm

[8]: http://www.phoenixframework.org/docs/advanced-deployment

[9]: http://erlang.org/doc/man/systools.html

[10]: http://erlang.org/doc/man/reltool.html

[11]: https://github.com/erlang/rebar3/releases

[12]: https://github.com/erlware/relx

[13]: http://erlang.org/doc/design_principles/release_structure.html

[14]: https://en.wikipedia.org/wiki/GNU_Build_System

[15]: https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation

[16]: https://hex.pm/packages/comeonin
