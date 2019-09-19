# v0 Changelog

* [**0.4.0**](#0-4-0-sep-17-2019) - 9 new features, 43 enhancements, 12 bug fixes

## [0.4.0][url.v0-4-0] - Sep 17, 2019

### New features

* *new*: [`aws_cloudwatch_metrics` sink][docs.aws_cloudwatch_metrics_sink] ([#707][url.pr_707])
* *new*: [`clickhouse` sink][docs.clickhouse_sink] ([#693][url.pr_693])
* *new*: [`file` sink][docs.file_sink] ([#688][url.pr_688])
* *new*: [`udp` source][docs.udp_source] ([#738][url.pr_738])
* *new*: [`kafka` source][docs.kafka_source] ([#774][url.pr_774])
* *new*: [`journald` source][docs.journald_source] ([#702][url.pr_702])
* *new*: [`coercer` transform][docs.coercer_transform] ([#666][url.pr_666])
* *new*: [`remove_tags` transform][docs.remove_tags_transform] ([#785][url.pr_785])
* *new*: [`add_tags` transform][docs.add_tags_transform] ([#785][url.pr_785])

### Enhancements

* *[`aws_cloudwatch_logs` sink][docs.aws_cloudwatch_logs_sink]*: Add cloudwatch partitioning and refactor partition buffer ([#519][url.pr_519])
* *[`aws_cloudwatch_logs` sink][docs.aws_cloudwatch_logs_sink]*: Add retry ability to cloudwatch ([#663][url.pr_663])
* *[`aws_cloudwatch_logs` sink][docs.aws_cloudwatch_logs_sink]*: Add dynamic group creation ([#759][url.pr_759])
* *[`aws_kinesis_streams` sink][docs.aws_kinesis_streams_sink]*: Add configurable partition keys ([#692][url.pr_692])
* *[`aws_s3` sink][docs.aws_s3_sink]*: Add filename extension option and fix trailing slash ([#596][url.pr_596])
* *cli*: Add `--color` option and tty check for ansi colors ([#623][url.pr_623])
* *[config][docs.configuration]*: Improve configuration validation and make it more strict ([#552][url.pr_552])
* *[config][docs.configuration]*: Reusable templating system for event values ([#656][url.pr_656])
* *[config][docs.configuration]*: Validation of sinks and sources for non-emptiness. ([#739][url.pr_739])
* *[`console` sink][docs.console_sink]*: Accept both logs and metrics ([#631][url.pr_631])
* *[`elasticsearch` sink][docs.elasticsearch_sink]*: Default `doc_type` to `_doc` and make it op… ([#695][url.pr_695])
* *[`elasticsearch` sink][docs.elasticsearch_sink]*: Use templates for es index and s3 key prefix ([#686][url.pr_686])
* *[`elasticsearch` sink][docs.elasticsearch_sink]*: Add http basic authorization ([#749][url.pr_749])
* *[`elasticsearch` sink][docs.elasticsearch_sink]*: Add support for additional headers to the elasticsearch sink ([#758][url.pr_758])
* *[`elasticsearch` sink][docs.elasticsearch_sink]*: Add support for custom query parameters ([#766][url.pr_766])
* *[`file` source][docs.file_source]*: Add file checkpoint feature. ([#609][url.pr_609])
* *[`file` source][docs.file_source]*: Fall back to global data_dir option (#644) ([#673][url.pr_673])
* *[`file` source][docs.file_source]*: Make fingerprinting strategy configurable ([#780][url.pr_780])
* *[`file` source][docs.file_source]*: Allow aggregating multiple lines into one event ([#809][url.pr_809])
* *[`file` source][docs.file_source]*: Favor older files and allow configuring greedier reads ([#810][url.pr_810])
* *[`grok_parser` transform][docs.grok_parser_transform]*: Add type coercion ([#632][url.pr_632])
* *[`http` sink][docs.http_sink]*: Add support for unverified https ([#815][url.pr_815])
* *[`journald` source][docs.journald_source]*: Add checkpointing support ([#816][url.pr_816])
* *[`log_to_metric` transform][docs.log_to_metric_transform]*: Output multiple metrics from a single log ([d8eadb0][url.commit_d8eadb08f469e7e411138ed9ff9e318bd4f9954c])
* *[`log_to_metric` transform][docs.log_to_metric_transform]*: Push histogram and set metrics from logs ([#650][url.pr_650])
* *[`log_to_metric` transform][docs.log_to_metric_transform]*: Use templates for metric names in log_to_metric ([#668][url.pr_668])
* *[`lua` transform][docs.lua_transform]*: Add tags support to log_to_metric transform ([#786][url.pr_786])
* *[metric data model][docs.metric]*: Use floats for metrics values ([#553][url.pr_553])
* *[metric data model][docs.metric]*: Add timestamps into metrics ([#726][url.pr_726])
* *[metric data model][docs.metric]*: Add tags into metrics model ([#754][url.pr_754])
* *[observability][docs.monitoring]*: Initial rate limit subscriber ([#494][url.pr_494])
* *[observability][docs.monitoring]*: Add rate limit notice when it starts ([#696][url.pr_696])
* *operations*: Add `jemallocator` feature flag ([#653][url.pr_653])
* *operations*: Build for x86_64-unknown-linux-musl with all features and optimized binary size ([#689][url.pr_689])
* *[`prometheus` sink][docs.prometheus_sink]*: Support histograms ([#675][url.pr_675])
* *[`prometheus` sink][docs.prometheus_sink]*: Support sets ([#733][url.pr_733])
* *[`prometheus` sink][docs.prometheus_sink]*: Add labels support ([#773][url.pr_773])
* *[`prometheus` sink][docs.prometheus_sink]*: Add namespace config ([#782][url.pr_782])
* *[`regex_parser` transform][docs.regex_parser_transform]*: Log when regex does not match (#618 ([0098034][url.commit_009803467f4513827abbe4a28d8170a5593ea2c5])
* *[`tcp` sink][docs.tcp_sink]*: Add support for tls ([#765][url.pr_765])
* *[`tokenizer` transform][docs.tokenizer_transform]*: Convert "-" into "nil" ([#580][url.pr_580])
* *topology*: Adjust transform trait for multiple output events ([fe7f2b5][url.commit_fe7f2b503443199a65a79dad129ed89ace3e287a])
* *topology*: Add sink healthcheck disable ([#731][url.pr_731])

### Performance improvements

* *[observability][docs.monitoring]*: Add initial rework of rate limited logs ([#778][url.pr_778])

### Bug fixes

* *[`aws_cloudwatch_logs` sink][docs.aws_cloudwatch_logs_sink]*: `encoding = "text"` overrides ([#803][url.pr_803])
* *[`aws_s3` sink][docs.aws_s3_sink]*: Retry httpdispatch errors for s3 and kinesis ([#651][url.pr_651])
* *[config][docs.configuration]*: Reload with unparseable config ([#752][url.pr_752])
* *[`elasticsearch` sink][docs.elasticsearch_sink]*: Make the headers and query tables optional. ([#831][url.pr_831])
* *[log data model][docs.log]*: Unflatten event before outputting ([#678][url.pr_678])
* *[log data model][docs.log]*: Don't serialize mapvalue::null as a string ([#725][url.pr_725])
* *networking*: Retry requests on timeouts ([#691][url.pr_691])
* *operations*: Use gnu ld instead of llvm lld for x86_64-unknown-linux-musl ([#794][url.pr_794])
* *operations*: Fix docker nightly builds ([#830][url.pr_830])
* *[`prometheus` sink][docs.prometheus_sink]*: Update metric::set usage ([#756][url.pr_756])
* *security*: Rustsec-2019-0011 by updating crossbeam-epoch ([#723][url.pr_723])
* *topology*: It is now possible to reload a with a non-overlap… ([#681][url.pr_681])


[docs.add_tags_transform]: https://docs.vector.dev/usage/configuration/transforms/add_tags
[docs.aws_cloudwatch_logs_sink]: https://docs.vector.dev/usage/configuration/sinks/aws_cloudwatch_logs
[docs.aws_cloudwatch_metrics_sink]: https://docs.vector.dev/usage/configuration/sinks/aws_cloudwatch_metrics
[docs.aws_kinesis_streams_sink]: https://docs.vector.dev/usage/configuration/sinks/aws_kinesis_streams
[docs.aws_s3_sink]: https://docs.vector.dev/usage/configuration/sinks/aws_s3
[docs.clickhouse_sink]: https://docs.vector.dev/usage/configuration/sinks/clickhouse
[docs.coercer_transform]: https://docs.vector.dev/usage/configuration/transforms/coercer
[docs.configuration]: https://docs.vector.dev/usage/configuration/README
[docs.console_sink]: https://docs.vector.dev/usage/configuration/sinks/console
[docs.elasticsearch_sink]: https://docs.vector.dev/usage/configuration/sinks/elasticsearch
[docs.file_sink]: https://docs.vector.dev/usage/configuration/sinks/file
[docs.file_source]: https://docs.vector.dev/usage/configuration/sources/file
[docs.grok_parser_transform]: https://docs.vector.dev/usage/configuration/transforms/grok_parser
[docs.http_sink]: https://docs.vector.dev/usage/configuration/sinks/http
[docs.journald_source]: https://docs.vector.dev/usage/configuration/sources/journald
[docs.kafka_source]: https://docs.vector.dev/usage/configuration/sources/kafka
[docs.log]: https://docs.vector.dev/about/data-model/log
[docs.log_to_metric_transform]: https://docs.vector.dev/usage/configuration/transforms/log_to_metric
[docs.lua_transform]: https://docs.vector.dev/usage/configuration/transforms/lua
[docs.metric]: https://docs.vector.dev/about/data-model/metric
[docs.monitoring]: https://docs.vector.dev/usage/administration/monitoring
[docs.prometheus_sink]: https://docs.vector.dev/usage/configuration/sinks/prometheus
[docs.regex_parser_transform]: https://docs.vector.dev/usage/configuration/transforms/regex_parser
[docs.remove_tags_transform]: https://docs.vector.dev/usage/configuration/transforms/remove_tags
[docs.tcp_sink]: https://docs.vector.dev/usage/configuration/sinks/tcp
[docs.tokenizer_transform]: https://docs.vector.dev/usage/configuration/transforms/tokenizer
[docs.udp_source]: https://docs.vector.dev/usage/configuration/sources/udp
[url.commit_009803467f4513827abbe4a28d8170a5593ea2c5]: https://github.com/timberio/vector/commit/009803467f4513827abbe4a28d8170a5593ea2c5
[url.commit_d8eadb08f469e7e411138ed9ff9e318bd4f9954c]: https://github.com/timberio/vector/commit/d8eadb08f469e7e411138ed9ff9e318bd4f9954c
[url.commit_fe7f2b503443199a65a79dad129ed89ace3e287a]: https://github.com/timberio/vector/commit/fe7f2b503443199a65a79dad129ed89ace3e287a
[url.pr_494]: https://github.com/timberio/vector/pull/494
[url.pr_519]: https://github.com/timberio/vector/pull/519
[url.pr_552]: https://github.com/timberio/vector/pull/552
[url.pr_553]: https://github.com/timberio/vector/pull/553
[url.pr_580]: https://github.com/timberio/vector/pull/580
[url.pr_596]: https://github.com/timberio/vector/pull/596
[url.pr_609]: https://github.com/timberio/vector/pull/609
[url.pr_623]: https://github.com/timberio/vector/pull/623
[url.pr_631]: https://github.com/timberio/vector/pull/631
[url.pr_632]: https://github.com/timberio/vector/pull/632
[url.pr_650]: https://github.com/timberio/vector/pull/650
[url.pr_651]: https://github.com/timberio/vector/pull/651
[url.pr_653]: https://github.com/timberio/vector/pull/653
[url.pr_656]: https://github.com/timberio/vector/pull/656
[url.pr_663]: https://github.com/timberio/vector/pull/663
[url.pr_666]: https://github.com/timberio/vector/pull/666
[url.pr_668]: https://github.com/timberio/vector/pull/668
[url.pr_673]: https://github.com/timberio/vector/pull/673
[url.pr_675]: https://github.com/timberio/vector/pull/675
[url.pr_678]: https://github.com/timberio/vector/pull/678
[url.pr_681]: https://github.com/timberio/vector/pull/681
[url.pr_686]: https://github.com/timberio/vector/pull/686
[url.pr_688]: https://github.com/timberio/vector/pull/688
[url.pr_689]: https://github.com/timberio/vector/pull/689
[url.pr_691]: https://github.com/timberio/vector/pull/691
[url.pr_692]: https://github.com/timberio/vector/pull/692
[url.pr_693]: https://github.com/timberio/vector/pull/693
[url.pr_695]: https://github.com/timberio/vector/pull/695
[url.pr_696]: https://github.com/timberio/vector/pull/696
[url.pr_702]: https://github.com/timberio/vector/pull/702
[url.pr_707]: https://github.com/timberio/vector/pull/707
[url.pr_723]: https://github.com/timberio/vector/pull/723
[url.pr_725]: https://github.com/timberio/vector/pull/725
[url.pr_726]: https://github.com/timberio/vector/pull/726
[url.pr_731]: https://github.com/timberio/vector/pull/731
[url.pr_733]: https://github.com/timberio/vector/pull/733
[url.pr_738]: https://github.com/timberio/vector/pull/738
[url.pr_739]: https://github.com/timberio/vector/pull/739
[url.pr_749]: https://github.com/timberio/vector/pull/749
[url.pr_752]: https://github.com/timberio/vector/pull/752
[url.pr_754]: https://github.com/timberio/vector/pull/754
[url.pr_756]: https://github.com/timberio/vector/pull/756
[url.pr_758]: https://github.com/timberio/vector/pull/758
[url.pr_759]: https://github.com/timberio/vector/pull/759
[url.pr_765]: https://github.com/timberio/vector/pull/765
[url.pr_766]: https://github.com/timberio/vector/pull/766
[url.pr_773]: https://github.com/timberio/vector/pull/773
[url.pr_774]: https://github.com/timberio/vector/pull/774
[url.pr_778]: https://github.com/timberio/vector/pull/778
[url.pr_780]: https://github.com/timberio/vector/pull/780
[url.pr_782]: https://github.com/timberio/vector/pull/782
[url.pr_785]: https://github.com/timberio/vector/pull/785
[url.pr_786]: https://github.com/timberio/vector/pull/786
[url.pr_794]: https://github.com/timberio/vector/pull/794
[url.pr_803]: https://github.com/timberio/vector/pull/803
[url.pr_809]: https://github.com/timberio/vector/pull/809
[url.pr_810]: https://github.com/timberio/vector/pull/810
[url.pr_815]: https://github.com/timberio/vector/pull/815
[url.pr_816]: https://github.com/timberio/vector/pull/816
[url.pr_830]: https://github.com/timberio/vector/pull/830
[url.pr_831]: https://github.com/timberio/vector/pull/831
[url.v0-4-0]: https://github.com/timberio/vector/releases/tag/0.4.0
