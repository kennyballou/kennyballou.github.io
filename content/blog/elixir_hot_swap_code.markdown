---
title: "Elixir/Erlang Hot Swapping Code"
description: "Hot code reloading with Elixir and Erlang"
tags:
  - "Erlang/OTP"
  - "Elixir"
  - "Hot Swapping Code"
  - "How-to"
  - "distillery"
date: "2016-12-07"
categories:
  - "Development"
slug: "elixir-hot-swapping"
---

{{<youtube xrIjfIjssLE>}}

> Warning, there be black magic here.

One of the untold benefits of having a runtime is the ability for that runtime
to enable loading and unloading code while the runtime is active. Since the
runtime is itself, essentially, a virtual machine with its own operating system
and process scheduling, it has the ability to start and stop, load and unload
processes and code similar to how "real" operating systems do.

This enables some spectacular power in terms of creating deployments and
rolling out those deployments. That is, if we can provide a particular artifact
for the runtime to load and replace the running system with, we can instruct it
to upgrade our system(s) _without_ restarting them, without interrupting our
services or affecting users of those systems. Furthermore, if we constrain the
system and make a few particular assumptions, this can all happen nearly
instantaneously. For example, Erlang releases happen in seconds because of the
functional approach taken by the language, this compared to other systems like
[Docker][13] and/or [Kubernetes][14] which may take several minutes or hours
to transition a version because there is no safe assumptions to make about
running code.

This post will be a small tour through how Elixir and Erlang can perform code
hot swapping, and how this can be useful for deployments.

## Hot Code Swapping: Basics ##

There are several functions defined in the [`:sys`][5] and [`:code`][6] modules
that are required for this first example. Namely, the following functions:

*   `:code.load_file/1`

*   `:sys.suspend/1`

*   `:sys.change_code/4`

*   `:sys.resume/1`

The `:sys.suspend/1` function takes a single parameter, the Process ID (PID) of
the process to suspend, similarly, `:sys.resume` also takes a PID of the
process to resume. The `:code.load_file/1` function, unfortunately named, takes
a single parameter: the _module_ to load into memory. Finally, the
`:sys.change_code` function takes four parameters: `name`, `module`,
`old_version`, and `extra`. The `name` is the PID or the registered atom of the
process. The `extra` argument is a reserved parameter for each process, it's
the same `extra` that will be passed to the restarted process's `code_change/3`
function.

### Example ###

Let's assume we have a particularly simple module, say `KV`, similar to the
following:

```elixir
defmodule KV do
  use GenServer

  @vsn 0

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def get(key, default \\ nil) do
    GenServer.call(__MODULE__, {:get, key, default})
  end

  def put(key, value) do
    GenServer.call(__MODULE__, {:put, key, value})
  end

  def handle_call({:get, key, default}, _caller, state) do
    {:reply, Map.get(state, key, default), state}
  end

  def handle_call({:put, key, value}, _caller, state) do
    {:reply, :ok, Map.put(state, key, value)}
  end

end
```

Save this into a file, say, `kv.ex`. Next we will compile it and load it into
an `iex` session:

```
% elixirc kv.ex
% iex
iex> l KV
{:module, KV}
```

We can start the process and try it out:

```
iex> KV.start_link
{:ok, #PID<0.84.0>}
iex> KV.get(:a)
nil
iex> KV.put(:a, 42)
:ok
iex> KV.get(:a)
42
```

Now, let's say we wish to add some logging to the handling of the `:get` and
`:put` messages. We will apply a patch similar to the following:

```
--- a/kv.ex
+++ b/kv.ex
@@ -1,7 +1,8 @@
 defmodule KV do
+  require Logger
   use GenServer

-  @vsn 0
+  @vsn 1

   def start_link() do
     GenServer.start_link(__MODULE__, [], name: __MODULE__)
@@ -20,10 +21,12 @@ defmodule KV do
   end

   def handle_call({:get, key, default}, _caller, state) do
+    Logger.info("#{__MODULE__}: Handling get request for #{key}")
     {:reply, Map.get(state, key, default), state}
   end

   def handle_call({:put, key, value}, _caller, state) do
+    Logger.info("#{__MODULE__}: Handling put request for #{key}:#{value}")
     {:reply, :ok, Map.put(state, key, value)}
   end
```

Without closing the current `iex` session, apply the patch to the file and
compile the module:

```
% patch kv.ex kv.ex.patch
% elixirc kv.ex
```

> You may see a warning about redefining an existing module, this warning can
> be safely ignored.

Now, in the still open `iex` session, let's begin the black magic incantations:

```
iex> :code.load_file KV
{:module, KV}
iex> :sys.suspend(KV)
:ok
iex> :sys.change_code(KV, KV, 0, nil)
:ok
iex> :sys.resume(KV)
:ok
```

Now, we should be able to test it again:

```
iex> KV.get(:a)
21:28:47.989 [info]  Elixir.KV: Handling get request for a
42
iex> KV.put(:b, 2)
21:28:53.729 [info]  Elixir.KV: Handling put request for b:2
:ok
```

Thus, we are able to hot-swap running code, without stopping, losing state, or
effecting processes waiting for that data!

But the above is merely an example of manually invoking the code reloading API,
there are better ways to achieve the same result.

### Example: `iex` ###

There are several functions available to us when using `iex` that essentially
perform the above actions for us:

*   `c/1`: compile file

*   `r/1`: (recompile and) reload module

The `r/1` helper takes an atom of the module to reload, `c/1` takes a binary of
the path to the module to compile. Check the [documentation][15] for more
information.

Therefore, using these, we can simplify what we did in the previous example to
simply a call to `r/1`:

```
iex> r KV
warning: redefining module KV (current version loaded from Elixir.KV.beam)
  kv.ex:1

{:reloaded, KV, [KV]}
iex> KV.get(:a)

21:52:47.829 [info]  Elixir.KV: Handling get request for a
42
```

In one function, we have done what previously took four functions. However, the
story does not end here. This was only for a single module, one `GenServer`.
What about when we want to upgrade more modules, or an entire application?

> Although `c/1` and `r/1` are great for development. They are *not*
> recommended for production use. Do not depend on them to perform deployments.

## Relups ##

Fortunately, there is another set of tooling that allows us to more easily
deploy releases, and more pointedly, perform upgrades: Relups. Before we dive
straight into relups, let's discuss a few other related concepts.

### Erlang Applications ###

As part of Erlang "Applications", there is a related file, the [`.app`][16]
file. This resource file describes the application: other applications that
should be started and other metadata about the application. Using Elixir, this
file can be found in the `_build/{Mix.env}/lib/{app_name}/ebin/` folder.

Here's an example `.app` file from the [octochat][17] demo application:

```
± cat _build/dev/lib/octochat/ebin/octochat.app
{application,octochat,
         [{registered,[]},
          {description,"Demo Application for How Swapping Code"},
          {vsn,"0.3.3"},
          {modules,['Elixir.Octochat','Elixir.Octochat.Acceptor',
                    'Elixir.Octochat.Application','Elixir.Octochat.Echo',
                    'Elixir.Octochat.ServerSupervisor',
                    'Elixir.Octochat.Supervisor']},
          {applications,[kernel,stdlib,elixir,logger]},
          {mod,{'Elixir.Octochat.Application',[]}}]}.
```

This is a pretty good sized triple (3-tuple). By the first element of the
triple, we can tell it is an `application`, the application's name is
`octochat` given by the second element, and everything in the list that follows
is a keyword list that describes more about the `octochat` application.
Notably, we have the usual metadata found in the `mix.exs` file, the `modules`
that make up the application, and the other OTP applications this application
requires to run.

### Erlang Releases ###

An Erlang "release", similar to Erlang application, is an entire system: the
Erlang VM, the dependent set of applications, and arguments for the Erlang VM.

After building a release for the Octochat application with the
[`distillery`][4] project, we get a `.rel` file similar to the following:

```
± cat rel/octochat/releases/0.3.3/octochat.rel
{release,{"octochat","0.3.3"},
     {erts,"8.1"},
     [{logger,"1.3.4"},
      {compiler,"7.0.2"},
      {elixir,"1.3.4"},
      {stdlib,"3.1"},
      {kernel,"5.1"},
      {octochat,"0.3.3"},
      {iex,"1.3.4"},
      {sasl,"3.0.1"}]}.
```

This is an Erlang 4-tuple; it's a `release` of the `"0.0.3"` version of
`octochat`. It will use the `"8.1"` version of "erts" and it depends on the
list of applications (and their versions) provided in the last element of the
tuple.

### Appups and Relups ###

As the naming might suggest, "appups" and "relups" are the "upgrade" versions
of applications and releases, respectively. Appups describe how to take a
single application and upgrade its modules, specifically, it will have
instructions for upgrading modules that require "extras". or, if we are
upgrading supervisors, for example, the Appup will have the correct
instructions for adding and removing child processes.

Before we examine some examples of these files, let's first look at the type
specification for each.

Here is the syntax structure for the `appup` resource file:

```
{Vsn,
  [{UpFromVsn, Instructions}, ...],
  [{DownToVsn, Instructions}, ...]}.
```

The first element of the triple is the version we are either upgrading to or
downgrading from. The second element is a keyword list of upgrade instructions
keyed by the version the application would be coming _from_. Similarly, the
third element is a keyword list of downgrade instructions keyed by the version
the application will downgrade _to_. For more information about the types
themselves, see the [SASL documentation][18].

Now that we have seen the syntax, let's look at an example of the appup
resource file for the octochat application generated using [distillery][4]:

```
± cat rel/octochat/lib/octochat-0.2.1/ebin/octochat.appup
{"0.2.1",
 [{"0.2.0",[{load_module,'Elixir.Octochat.Echo',[]}]}],
 [{"0.2.0",[{load_module,'Elixir.Octochat.Echo',[]}]}]}.
```

Comparing this to the syntax structure above, we see that we have a `Vsn`
element of `"0.2.1"`, we have a `{UpFromVsn, Instructions}` pair:
`[{"0.2.0",[{load_module,'Elixir.Octochat.Echo',[]}]}]`, and we have a single
`{DownToVsn, Instructions}` pair:
`[{"0.2.0",[{load_module,'Elixir.Octochat.Echo',[]}]}]`.

The instructions themselves tell us what exactly is required to go from one
version to the another. Specifically, in this example, to upgrade, we need to
"load" the `Octochat.Echo` module into the VM. Similarly, the instructions to
downgrade are the same. For a [semantically versioned][21] project, this is an
understandably small change.

It's worth noting the instructions found in the `.appup` files are usually
high-level instructions, thus, `load_module` covers both the loading of object
code into memory and the suspend, replace, resume process of upgrading
applications.

Next, let's look at the syntax structure of a `relup` resource file:

```
{Vsn,
 [{UpFromVsn, Descr, Instructions}, ...],
 [{DownToVsn, Descr, Instructions}, ...]}.
```

This should look familiar. It's essentially the exact same as the `.appup`
file. However, there's an extra term, `Descr`. The `Descr` field can be used as
part of the version identification, but is optional. Otherwise, the syntax of
this file is the same as the `.appup`.

Now, let's look at an example `relup` file for the same release of octochat:

```
± cat rel/octochat/releases/0.2.1/relup
{"0.2.1",
 [{"0.2.0",[],
   [{load_object_code,{octochat,"0.2.1",['Elixir.Octochat.Echo']}},
    point_of_no_return,
    {load,{'Elixir.Octochat.Echo',brutal_purge,brutal_purge}}]}],
 [{"0.2.0",[],
   [{load_object_code,{octochat,"0.2.0",['Elixir.Octochat.Echo']}},
    point_of_no_return,
    {load,{'Elixir.Octochat.Echo',brutal_purge,brutal_purge}}]}]}.
```

This file is a little more dense, but still adheres to the basic triple syntax
we just examined. Let's take a closer look at the upgrade instructions:

```
[{load_object_code,{octochat,"0.2.1",['Elixir.Octochat.Echo']}},
 point_of_no_return,
 {load,{'Elixir.Octochat.Echo',brutal_purge,brutal_purge}}]
```

The first instruction,
`{load_object_code,{octochat,"0.2.1",['Elixir.Octochat.Echo']}}`, tells the
[release handler][22] to load into memory the new version of the
"Octochat.Echo" module, specifically the one associated with version "0.2.1".
But this instruction will not instruct the release handler to (re)start or
replace the existing module yet. Next, `point_of_no_return`, tells the release
handler that failure beyond this point is fatal, if the upgrade fails after
this point, the system is restarted from the old release version ([appup
documentation][18]). The final instruction,
`{load,{'Elixir.Octochat.Echo',brutal_purge,brutal_purge}}`, tells the release
handler to replace the running version of the module and use the newly loaded
version.

For more information regarding `burtal_purge`, check out the "PrePurge" and
"PostPurge" values in the [appup documentation][18].

Similar to the `.appup` file, the third element in the triple describes to the
release handler how to downgrade the release as well. The version numbers in
this case make this a bit more obvious as well, however, the steps are
essentially the same.

### Generating Releases and Upgrades with Elixir ###

Now that we have some basic understanding of releases and upgrades, let's see
how we can generate them with Elixir. We will generate the releases with the
[distillery][4] project, however, the commands should also work with the soon
to be deprecated [exrm][2] project.

> This has been written for the `0.10.1` version of [distillery][4]. This is a
> fast moving project that is in beta, be prepared to update as necessary.

Add the [distillery][4] application to your `deps` list:

    {:distillery, "~> 0.10"}

Perform the requisite dependency download:

```
± mix deps.get
```

Then, to build your first production release, you can use the following:

```
± MIX_ENV=prod mix release --env prod
```

> For more information on why you must specify both environments, please read
> the [FAQ][19] of distillery. If the environments match, there's a small
> modification to the `./rel/config.exs` that can be made so that specifying
> both is no longer necessary.

After this process is complete, there should be a new folder under the `./rel`
folder that contains the new release of the project. Within this directory,
there will be several directories, namely, `bin`, `erts-{version}`, `lib`, and
`releases`. The `bin` directory will contain the top level Erlang entry
scripts, the `erts-{version}` folder will contain the requisite files for the
Erlang runtime, the `lib` folder will contain the compiled beam files for the
required applications for the release, and finally, the `releases` folder will
contain the versions of the releases. Each folder for each version will have
its own `rel` file, generated boot scripts, as per the [OTP releases
guide][20], and a tarball of the release for deployment.

Deploying the release is a little out of scope for this post and may be the
subject of another. For more information about releases, see the [System
Principles][23] guide. However, for Elixir, it may look similar to the
following:

*   Copy the release tarball to the target system:

    ```
    ± scp rel/octochat/releases/0.3.2/octochat.tar.gz target_system:/opt/apps/.
    ```

*   On the target system, unpack the release:

    ```
    ± ssh target_system
    (ts)# cd /opt/apps
    (ts)# mkdir -p octochat
    (ts)# tar -zxf octochat.tar.gz -C octochat
    ```

*   Start the system:

    ```
    (ts)# cd octochat
    (ts)# bin/octochat start
    ```

This will bring up the Erlang VM and the application tree on the target system.

Next, after making some applications changes and bumping the project version,
we can generate an upgrade release using the following command:

```
± MIX_ENV=prod mix release --upgrade
```

> Note, This will _also_ generate a regular release.

Once this process finishes, checking the `rel/{app_name}/releases` folder,
there should be a new folder for the new version, and a `relup` file for the
upgrade:

```
± cat rel/octochat/releases/0.3.3/octochat.rel
{release,{"octochat","0.3.3"},
     {erts,"8.1"},
     [{logger,"1.3.4"},
      {compiler,"7.0.2"},
      {elixir,"1.3.4"},
      {stdlib,"3.1"},
      {kernel,"5.1"},
      {octochat,"0.3.3"},
      {iex,"1.3.4"},
      {sasl,"3.0.1"}]}.

± cat rel/octochat/releases/0.3.3/relup
{"0.3.3",
 [{"0.3.2",[],
   [{load_object_code,{octochat,"0.3.3",['Elixir.Octochat.Echo']}},
    point_of_no_return,
    {suspend,['Elixir.Octochat.Echo']},
    {load,{'Elixir.Octochat.Echo',brutal_purge,brutal_purge}},
    {code_change,up,[{'Elixir.Octochat.Echo',[]}]},
    {resume,['Elixir.Octochat.Echo']}]}],
 [{"0.3.2",[],
   [{load_object_code,{octochat,"0.3.1",['Elixir.Octochat.Echo']}},
    point_of_no_return,
    {suspend,['Elixir.Octochat.Echo']},
    {code_change,down,[{'Elixir.Octochat.Echo',[]}]},
    {load,{'Elixir.Octochat.Echo',brutal_purge,brutal_purge}},
    {resume,['Elixir.Octochat.Echo']}]}]}.
```

Similarly, to deploy this new upgrade, copy the tarball to the target system
and unpack it into the same directory as before.

After it's unpacked, upgrading the release can be done via a stop and start, or
we can issue the `upgrade` command:

    (ts)# bin/octochat stop
    (ts)# bin/octochat start

Or:

    (ts)# bin/octochat upgrade "0.3.3"

When starting and stopping, the entry point script knows how to select the
"newest" version.

When upgrading, it is required to specify the desired version, this is
necessary since the upgrade process may require more than simply jumping to the
"latest" version.

## Summary ##

Release management is a complex topic, upgrading without restarting seemingly
even more so. However, the process _can_ be understood, and knowing how the
process works will allow us to make more informed decisions regarding when to
use it.

The tooling for performing hot upgrades has been around for a while, and while
the tooling for Elixir is getting closer, we are not quite ready for prime
time. But it won't remain this way for long. Soon, it will be common place for
Elixir applications to be just as manageable as the Erlang counterparts.

[1]: http://erlang.org/doc/reference_manual/code_loading.html

[2]: https://github.com/bitwalker/exrm

[3]: https://github.com/erlware/relx

[4]: https://github.com/bitwalker/distillery

[5]: http://erlang.org/doc/man/sys.html

[6]: http://erlang.org/doc/man/code.html

[7]: http://elixir-lang.org/docs/stable/elixir/

[8]: http://elixir-lang.org/docs/stable/elixir/Code.html

[9]: http://erlang.org/doc/man/relup.html

[10]: http://andrealeopardi.com/posts/handling-tcp-connections-in-elixir/

[11]: https://git.devnulllabs.io/demos/octochat.git

[12]: https://www.youtube.com/watch?v=xrIjfIjssLE

[13]: https://docker.com

[14]: http://kubernetes.io/

[15]: http://elixir-lang.org/docs/stable/iex/IEx.Helpers.html

[16]: http://erlang.org/doc/man/app.html

[17]: https://git.devnulllabs.io/demos/octochat.git

[18]: http://erlang.org/doc/man/appup.html

[19]: https://hexdocs.pm/distillery/common-issues.html#why-do-i-have-to-set-both-mix_env-and-env

[20]: http://erlang.org/doc/design_principles/release_structure.html

[21]: http://semver.org

[22]: http://erlang.org/doc/man/release_handler.html

[23]: http://erlang.org/doc/system_principles/create_target.html
