---
title: "Apache Storm and Apache Spark Streaming"
description: "Comparison of Apache Storm and Apache Spark Streaming"
tags:
  - "Apache Storm"
  - "Apache Spark"
  - "Apache"
  - "Real-time Streaming"
  - "ZData Inc."
date: "2014-09-08"
categories:
  - "Apache"
  - "Development"
  - "Real-time Systems"
slug: "apache-storm-and-apache-spark"
---

This is the last post in the series on real-time systems. In the [first
post][3] we discussed [Apache Storm][1] and [Apache Kafka][5]. In the [second
post][4] we discussed [Apache Spark (Streaming)][3]. In both posts we examined
a small Twitter Sentiment Analysis program. Today, we will be reviewing both
systems: how they compare and how they contrast.

The intention is not to cast judgment over one project or the other, but rather
to exposit the differences and similarities. Any judgments made, subtle or not,
are mistakes in exposition and/ or organization and are not actual endorsements
of either project.

## Apache Storm ##

"Storm is a distributed real-time computation system" [[1][1]]. Apache Storm is
a [task parallel][7] continuous computational engine. It defines its workflows
in Directed Acyclic Graphs (DAG's) called "topologies". These topologies run
until shutdown by the user or encountering an unrecoverable failure.

Storm does not natively run on top of typical Hadoop clusters, it uses
[Apache ZooKeeper][8] and its own master/ minion worker processes to
coordinate topologies, master and worker state, and the message guarantee
semantics. That said, both [Yahoo!][9] and [Hortonworks][10] are working on
providing libraries for running Storm topologies on top of Hadoop 2.x YARN
clusters. Furthermore, Storm can run on top of the [Mesos][11] scheduler as
well, [natively][12] and with help from the [Marathon][13] framework.

Regardless though, Storm can certainly still consume files from HDFS and/ or
write files to HDFS.

## Apache Spark (Streaming) ##

"Apache Spark is a fast and general purpose engine for large-scale data
processing" [[2][2]]. [Apache Spark][2] is a [data parallel][8] general purpose
batch processing engine. Workflows are defined in a similar and reminiscent
style of MapReduce, however, is much more capable than traditional Hadoop
MapReduce. Apache Spark has its Streaming API project that allows for
continuous processing via short interval batches. Similar to Storm, Spark
Streaming jobs run until shutdown by the user or encounter an unrecoverable
failure.

Apache Spark does not itself require Hadoop to operate. However, its data
parallel paradigm requires a shared filesystem for optimal use of stable data.
The stable source can range from [S3][14], [NFS][15], or, more typically,
[HDFS][16].

Executing Spark applications does not _require_ Hadoop YARN. Spark has its own
standalone master/ server processes. However, it is common to run Spark
applications using YARN containers. Furthermore, Spark can also run on Mesos
clusters.

## Development ##

As of this writing, Apache Spark is a full, top level Apache project. Whereas
Apache Storm is currently undergoing incubation. Moreover, the latest stable
version of Apache Storm is `0.9.2` and the latest stable version of Apache
Spark is `1.0.2` (with `1.1.0` to be released in the coming weeks). Of course,
as the Apache Incubation reminder states, this does not strictly reflect
stability or completeness of either project. It is, however, a reflection to
the state of the communities. Apache Spark operations and its process are
endorsed by the [Apache Software Foundation][27]. Apache Storm is working on
stabilizing its community and development process.

Spark's `1.x` version does state that the API has stabilized and will not be
doing major changes undermining backward compatibility. Implicitly, Storm has
no guaranteed stability in its API, however, it is [running in production for
many different companies][34].

### Implementation Language ###

Both Apache Spark and Apache Storm are implemented in JVM based languages:
[Scala][19] and [Clojure][20], respectively.

Scala is a functional meets object-oriented language. In other words, the
language carries ideas from both the functional world and the object-oriented
world. This yields an interesting mix of code reusability, extensibility, and
higher-order functions.

Clojure is a dialect of [Lisp][21] targeting the JVM providing the Lisp
philosophy: code-as-data and providing the rich macro system typical of Lisp
languages. Clojure is predominately functional in nature, however, if state or
side-effects are required, they are facilitated with a transactional memory
model, aiding in making multi-threaded based applications consistent and safe.

#### Message Passing Layer ####

Until version `0.9.x`, Storm was using the Java library [JZMQ][22] for
[ZeroMQ][23] messages. However, Storm has since moved the default messaging
layer to [Netty][24] with efforts from [Yahoo!][25]. Although Netty is now
being used by default, users can still use ZeroMQ, if desired, since the
migration to Netty was intended to also make the message layer pluggable.

Spark, on the other hand, uses a combination of [Netty][24] and [Akka][26] for
distributing messages throughout the executors.

### Commit Velocity ###

As a reminder, these data are included not to cast judgment on one project or
the other, but rather to exposit the fluidness of each project. The continuum
of the dynamics of both projects can be used as an argument for or against,
depending on application requirements. If rigid stability is a strong
requirement, arguing for a slower commit velocity may be appropriate.

Source of the following statistics were taken from the graphs at
[GitHub](https://github.com/) and computed from [this script][38].

#### Spark Commit Velocity ####

Examining the graphs from
[GitHub](https://github.com/apache/spark/graphs/commit-activity), over the last
month (as of this writing), there have been over 330 commits. The previous
month had about 340.

#### Storm Commit Velocity ####

Again examining the commit graphs from
[GitHub](https://github.com/apache/incubator-storm/graphs/commit-activity),
over the last month (as of this writing), there have been over 70 commits. The
month prior had over 130.

### Issue Velocity ###

Sourcing the summary charts from JIRA, we can see that clearly Spark has a huge
volume of issues reported and closed in the last 30 days. Storm, roughly, an
order of magnitude less.

Spark Open and Closed JIRA Issues (last 30 days):

[![Spark JIRA Issues][spark_jira_issues]][18]

Storm Open and Closed JIRA Issues (last 30 days):

[![Storm JIRA Issues][storm_jira_issues]][17]

### Contributor/ Community Size ###

#### Storm Contributor Size ####

Sourcing the reports from
[GitHub](https://github.com/apache/incubator-storm/graphs/contributors), Storm
has over a 100 contributors. This number, though, is just the unique number of
people who have committed at least one patch.

Over the last 60 days, Storm has seen 34 unique contributors and 16 over the
last 30.

#### Spark Contributor Size ####

Similarly sourcing the reports from [GitHub](https://github.com/apache/spark),
Spark has roughly 280 contributors. A similar note as before must be made about
this number: this is the number of at least one patch contributors to the
project.

Apache Spark has had over 140 contributors over the last 60 days and 94 over
the last 30 days.

## Development Friendliness ##

### Developing for Storm ###

*   Describing the process structure with DAG's feels natural to the
    [processing model][7]. Each node in the graph will transform the data in a
    certain way, and the process continues, possibly disjointly.

*   Storm tuples, the data passed between nodes in the DAG, have a very natural
    interface. However, this comes at a cost to compile-time type safety.

### Developing for Spark ###

*   Spark's monadic expression of transformations over the data similarly feels
    natural in this [processing model][6]; this falls in line with the idea
    that RDD's are lazy and maintain transformation lineages, rather than
    actuallized results.

*   Spark's use of Scala Tuples can feel awkward in Java, and this awkwardness
    is only exacerbated with the nesting of generic types. However, this
    awkwardness does come with the benefit of compile-time type checks.

    -   Furthermore, until Java 1.8, anonymous functions are inherently
        awkward.

    -   This is probably a non-issue if using Scala.

## Installation / Administration ##

Installation of both Apache Spark and Apache Storm are relatively straight
forward. Spark may be simpler in some regards, however, since it technically
does not _need_ to be installed to function on YARN or Mesos clusters. The
Spark application will just require the Spark assembly be present in the
`CLASSPATH`.

Storm, on the other hand, requires ZooKeeper to be properly installed and
running on top of the regular Storm binaries that must be installed.
Furthermore, like ZooKeeper, Storm should run under [supervision][35];
installation of a supervisor service, e.g., [supervisord][28], is recommended.

With respect to installation, supporting projects like Apache Kafka are out of
scope and have no impact on the installation of either Storm or Spark.

## Processing Models ##

Comparing Apache Storm and Apache Spark's Streaming, turns out to be a bit
challenging. One is a true stream processing engine that can do micro-batching,
the other is a batch processing engine which micro-batches, but cannot perform
streaming in the strictest sense. Furthermore, the comparison between streaming
and batching isn't exactly a subtle difference, these are fundamentally
different computing ideas.

### Batch Processing ###

[Batch processing][31] is the familiar concept of processing data en masse. The
batch size could be small or very large. This is the processing model of the
core Spark library.

Batch processing excels at processing _large_ amounts of stable, existing data.
However, it generally incurs a high-latency and is completely unsuitable for
incoming data.

### Event-Stream Processing ###

[Stream processing][32] is a _one-at-a-time_ processing model; a datum is
processed as it arrives. The core Storm library follows this processing model.

Stream processing excels at computing transformations as data are ingested with
sub-second latencies. However, with stream processing, it is incredibly
difficult to process stable data efficiently.

### Micro-Batching ###

Micro-batching is a special case of batch processing where the batch size is
orders smaller. Spark Streaming operates in this manner as does the Storm
[Trident API][33].

Micro-batching seems to be a nice mix between batching and streaming. However,
micro-batching incurs a cost of latency. If sub-second latency is paramount,
micro-batching will typically not suffice. On the other hand, micro-batching
trivially gives stateful computation, making [windowing][37] an easy task.

## Fault-Tolerance / Message Guarantees ##

As a result of each project's fundamentally different processing models, the
fault-tolerance and message guarantees are handled differently.

### Delivery Semantics ###

Before diving into each project's fault-tolerance and message guarantees, here
are the common delivery semantics:

*   At most once: messages may be lost but never redelivered.

*   At least once: messages will never be lost but may be redelivered.

*   Exactly once: messages are never lost and never redelivered, perfect
    message delivery.

### Apache Storm ###

To provide fault-tolerant messaging, Storm has to keep track of each and every
record. By default, this is done with at least once delivery semantics.
Storm can be configured to provide at most once and exactly once. The delivery
semantics offered by Storm can incur latency costs; if data loss in the stream
is acceptable, at most once delivery will improve performance.

### Apache Spark Streaming ###

The resiliency built into Spark RDD's and the micro-batching yields a trivial
mechanism for providing fault-tolerance and message delivery guarantees. That
is, since Spark Streaming is just small-scale batching, exactly once delivery
is a trivial result for each batch; this is the _only_ delivery semantic
available to Spark. However some failure scenarios of Spark Streaming degrade
to at least once delivery.

## Applicability ##

### Apache Storm ###

Some areas where Storm excels include: near real-time analytics, natural
language processing, data normalization and [ETL][36] transformations. It also
stands apart from traditional MapReduce and other course-grained technologies
yielding fine-grained transformations allowing very flexible processing
topologies.

### Apache Spark Streaming ###

Spark has an excellent model for performing iterative machine learning and
interactive analytics. But Spark also excels in some similar areas of Storm
including near real-time analytics, ingestion.

## Final Thoughts ##

Generally, the requirements will dictate the choice. However, here are some
major points to consider when choosing the right tool:

*   Latency: Is the performance of the streaming application paramount? Storm
    can give sub-second latency much more easily and with less restrictions
    than Spark Streaming.

*   Development Cost: Is it desired to have similar code bases for batch
    processing _and_ stream processing? With Spark, batching and streaming are
    _very_ similar. Storm, however, departs dramatically from the MapReduce
    paradigm.

*   Message Delivery Guarantees: Is there high importance on processing _every_
    single record, or is some nominal amount of data loss acceptable?
    Disregarding everything else, Spark trivially yields perfect, exactly once
    message delivery. Storm can provide all three delivery semantics, but
    getting perfect exactly once message delivery requires more effort to
    properyly achieve.

*   Process Fault Tolerance: Is high-availability of primary concern? Both
    systems actually handle fault-tolerance of this kind really well and in
    relatively similar ways.

    -   Production Storm clusters will run Storm processes under
        [supervision][35]; if a process fails, the supervisor process will
        restart it automatically. State management is handled through
        ZooKeeper. Processes restarting will reread the state from ZooKeeper on
        an attempt to rejoin the cluster.

    -   Spark handles restarting workers via the resource manager: YARN, Mesos,
        or its standalone manager. Spark's standalone resource manager handles
        master node failure with standby-masters and ZooKeeper. Or, this can be
        handled more primatively with just local filesystem state
        checkpointing, not typically recommended for production environments.

Both Apache Spark Streaming and Apache Storm are great solutions that solve the
streaming ingestion and transformation problem. Either system can be a great
choice for part of an analytics stack. Choosing the right one is simply a
matter of answering the above questions.

## References ##

[spark_jira_issues]: https://kennyballou.com/media/spark_issues_chart.png

[storm_jira_issues]: https://kennyballou.com/media/storm_issues_chart.png

[1]: http://storm.incubator.apache.org/documentation/Home.html

*   [Apache Storm Home Page][1]

[2]: http://spark.apache.org

*   [Apache Spark][2]

[3]: http://www.zdatainc.com/2014/07/real-time-streaming-apache-storm-apache-kafka/

*   [Real Time Streaming with Apache Storm and Apache Kafka][3]

[4]: http://www.zdatainc.com/2014/08/real-time-streaming-apache-spark-streaming/

*   [Real Time Streaming with Apache Spark (Streaming)][4]

[5]: http://kafka.apache.org/

*   [Apache Kafka][5]

[6]: http://en.wikipedia.org/wiki/Data_parallelism

*   [Wikipedia: Data Parallelism][6]

[7]: http://en.wikipedia.org/wiki/Task_parallelism

*   [Wikipedia: Task Parallelism][7]

[8]: http://zookeeper.apache.org

*   [Apache ZooKeeper][8]

[9]: https://github.com/yahoo/storm-yarn

*   [Yahoo! Storm-YARN][9]

[10]: http://hortonworks.com/kb/storm-on-yarn-install-on-hdp2-beta-cluster/

*   [Hortonworks: Storm on YARN][10]

[11]: http://mesos.apache.org

*   [Apache Mesos][11]

[12]: https://mesosphere.io/learn/run-storm-on-mesos/

*   [Run Storm on Mesos][12]

[13]: https://github.com/mesosphere/marathon

*   [Marathon][13]

[14]: http://aws.amazon.com/s3/

[15]: http://en.wikipedia.org/wiki/Network_File_System

[16]: http://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html

[17]: https://issues.apache.org/jira/browse/STORM/

[18]: https://issues.apache.org/jira/browse/SPARK/

[19]: http://www.scala-lang.org/

[20]: http://clojure.org/

[21]: http://en.wikipedia.org/wiki/Lisp_(programming_language)

[22]: https://github.com/zeromq/jzmq

[23]: http://zeromq.org/

[24]: http://netty.io/

[25]: http://yahooeng.tumblr.com/post/64758709722/making-storm-fly-with-netty

[26]: http://akka.io

[27]: http://www.apache.org/

[28]: http://supervisord.org

[29]: http://xinhstechblog.blogspot.com/2014/06/storm-vs-spark-streaming-side-by-side.html

*   [Storm vs Spark Streaming: Side by Side][29]

[30]: http://www.slideshare.net/ptgoetz/apache-storm-vs-spark-streaming

*   [Storm vs Spark Streaming (Slideshare)][30]

[31]: http://en.wikipedia.org/wiki/Batch_processing

[32]: http://en.wikipedia.org/wiki/Event_stream_processing

[33]: https://storm.incubator.apache.org/documentation/Trident-API-Overview.html

[34]: http://storm.incubator.apache.org/documentation/Powered-By.html

[35]: http://en.wikipedia.org/wiki/Process_supervision

[36]: http://en.wikipedia.org/wiki/Extract,_transform,_load

[37]: http://en.wikipedia.org/wiki/Window_function_(SQL)#Window_function

[38]: https://gist.github.com/kennyballou/c6ff37e5eef6710794a6
