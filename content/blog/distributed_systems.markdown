---
title: "Yet Another Page on Readings in Distributed Systems"
description: "My own list of links, articles, papers, etc. I enjoyed reading
about distributed systems"
tags:
  - "Distributed Systems"
  - "Readings"
date: "2015-05-08"
categories:
  - "Distributed Systems"
slug: "readings-in-distributed-systems"
---

> "Distributed systems are hard."
-Everyone.

This page is dedicated to general discussion of distributed systems, references
to general overviews and the like. Distributed systems are difficult and even
the well established ones aren't [bulletproof][1]. How can we make this better?
As SysAdmins? As Developers? First we can attempt to understand some of the
issues related to designing and implementing distributed systems. Then we can
throw all that out and figure out what *really* happens to distributed systems.

## Recommended Reading ##

### General ###

*   [Fallacies of Distributed Computing][2]

*   [CAP Theorem][3]

    -   [LYSEFGG: Distribunomicon: My other cap is a theorem][4]

    -   For a more entertaining introduction to CAP, Hebert's ''Learn You Some
        Erlang for Great Good'' has a really good subsection on the topic that
        includes the zombie apocalypse and some introduction to how a blend
        between AP and CP systems can be achieved.

    -   [CAP Theorem Proof][5]

    -   [You can't sacrifice partition tolerance][6]

*   [Consistency Model][7]

    -   [List of Consistency Models][8]

    -   [Linearizability][9]

    -   [Linearizability versus Serializability][10]

    -   [Eventual Consistency][11]

*   [Paxos][12]

    -   [Understanding Paxos (Part 1)][13]

*   [Vector Clock][14]

*   [Split-Brain][15]

*   [Network Partitions][16]

*   [Distributed Systems and the End of the API][17]

*   [The Log][18]: What every software engineer should know about real time
    data's unifying abstraction

The [Jepsen][19] "Call me maybe" articles are really good, well written essays
on topics and technologies related to distributed systems.

Introductory post to the "Call me maybe" series:

*   [Call me maybe][20]

Here are some personal recommendations:

*   [The Network is Reliable][1]

*   [Strong Consistency Models][21]

*   [Asynchronous Replication with Failover][22]

Really anything from Ferd Herbert is good. Particularly, the first and last
chapters of [Erlang In Anger][30] which includes longer essays from his blog
posts.

*   [Queues Don't Fix Overload][31]

*   [It's About the Guarantees][32]

*   [Lessons Learned while Working on Large-Scale Server Software][33]

### General Networking ###

*   [TCP incast][29]

### Hadoop ecosystem ###

This link is more specific to HDFS and is a rather limited experiment but
nonetheless a good read to further understand partition issues that can arise
in Hadoop systems:

*   [Partition Tolerance in HDFS][23]

More links from the [Jepsen essays][19]:

*   [Call me maybe: Zookeeper][24]

*   [Call me maybe: Kafka][25]

*   [Call me maybe: Cassandra][26]

### Databases ###

-   [Wikipedia ACID][27]

-   [Call me maybe: Postgres][28]

[1]: http://aphyr.com/posts/288-the-network-is-reliable

[2]: http://en.wikipedia.org/wiki/Fallacies_of_Distributed_Computing

[3]: http://en.wikipedia.org/wiki/CAP_theorem

[4]: http://learnyousomeerlang.com/distribunomicon#my-other-cap-is-a-theorem

[5]: http://lpd.epfl.ch/sgilbert/pubs/BrewersConjecture-SigAct.pdf

[6]: http://codahale.com/you-cant-sacrifice-partition-tolerance/

[7]: http://en.wikipedia.org/wiki/Consistency_model

[8]: http://en.wikipedia.org/wiki/Category:Consistency_models

[9]: http://en.wikipedia.org/wiki/Linearizability

[10]: http://www.bailis.org/blog/linearizability-versus-serializability/

[11]: http://en.wikipedia.org/wiki/Eventual_consistency

[12]: http://en.wikipedia.org/wiki/Paxos_(computer_science)

[13]: http://distributedthoughts.wordpress.com/2013/09/22/understanding-paxos-part-1/

[14]: http://en.wikipedia.org/wiki/Vector_clock

[15]: http://en.wikipedia.org/wiki/Split-brain_(computing)

[16]: http://en.wikipedia.org/wiki/Network_partitioning

[17]: https://speakerdeck.com/cemerick/distributed-systems-and-the-end-of-the-api

[18]: http://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying

[19]: http://aphyr.com/tags/jepsen

[20]: http://aphyr.com/posts/281-call-me-maybe

[21]: http://aphyr.com/posts/313-strong-consistency-models

[22]: http://aphyr.com/posts/287-asynchronous-replication-with-failover

[23]: https://www.growse.com/2014/07/18/partition-tolerance-and-hadoop-part-1-hdfs/

[24]: http://aphyr.com/posts/291-call-me-maybe-zookeeper

[25]: http://aphyr.com/posts/293-call-me-maybe-kafka

[26]: http://aphyr.com/posts/294-call-me-maybe-cassandra

[27]: http://en.wikipedia.org/wiki/ACID

[28]: http://aphyr.com/posts/282-call-me-maybe-postgres

[29]: http://www.snookles.com/slf-blog/2012/01/05/tcp-incast-what-is-it/

[30]: http://www.erlang-in-anger.com/

[31]: http://ferd.ca/queues-don-t-fix-overload.html

[32]: http://ferd.ca/it-s-about-the-guarantees.html

[33]: http://ferd.ca/lessons-learned-while-working-on-large-scale-server-software.html
