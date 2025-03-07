---
description: Batches `log` events to AWS Kinesis Data Stream via the `PutRecords` API endpoint.
---

<!--
     THIS FILE IS AUTOGENERATED!

     To make changes please edit the template located at:

     scripts/generate/templates/docs/usage/configuration/sinks/aws_kinesis_streams.md.erb
-->

# aws_kinesis_streams sink

![][assets.aws_kinesis_streams_sink]

{% hint style="warning" %}
The `aws_kinesis_streams` sink is in beta. Please see the current
[enhancements][urls.aws_kinesis_streams_sink_enhancements] and
[bugs][urls.aws_kinesis_streams_sink_bugs] for known issues.
We kindly ask that you [add any missing issues][urls.new_aws_kinesis_streams_sink_issue]
as it will help shape the roadmap of this component.
{% endhint %}

The `aws_kinesis_streams` sink [batches](#buffers-and-batches) [`log`][docs.data-model.log] events to [AWS Kinesis Data Stream][urls.aws_kinesis_data_streams] via the [`PutRecords` API endpoint](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_PutRecords.html).

## Config File

{% code-tabs %}
{% code-tabs-item title="vector.toml (simple)" %}
```coffeescript
[sinks.my_sink_id]
  type = "aws_kinesis_streams" # must be: "aws_kinesis_streams"
  inputs = ["my-source-id"]
  region = "us-east-1"
  stream_name = "my-stream"

  # For a complete list of options see the "advanced" tab above.
```
{% endcode-tabs-item %}
{% code-tabs-item title="vector.toml (advanced)" %}
```coffeescript
[sinks.aws_kinesis_streams_sink]
  #
  # General
  #

  # The component type
  # 
  # * required
  # * no default
  # * must be: "aws_kinesis_streams"
  type = "aws_kinesis_streams"

  # A list of upstream source or transform IDs. See Config Composition for more
  # info.
  # 
  # * required
  # * no default
  inputs = ["my-source-id"]

  # The AWS region of the target Kinesis stream resides.
  # 
  # * required
  # * no default
  region = "us-east-1"

  # The stream name of the target Kinesis Logs stream.
  # 
  # * required
  # * no default
  stream_name = "my-stream"

  # Enables/disables the sink healthcheck upon start.
  # 
  # * optional
  # * default: true
  healthcheck = true

  # Custom hostname to send requests to. Useful for testing.
  # 
  # * optional
  # * no default
  hostname = "127.0.0.0:5000"

  # The log field used as the Kinesis record's partition key value.
  # 
  # * optional
  # * no default
  partition_key_field = "user_id"

  #
  # Batching
  #

  # The maximum size of a batch before it is flushed.
  # 
  # * optional
  # * default: 1049000
  # * unit: bytes
  batch_size = 1049000

  # The maximum age of a batch before it is flushed.
  # 
  # * optional
  # * default: 1
  # * unit: seconds
  batch_timeout = 1

  #
  # Requests
  #

  # The encoding format used to serialize the events before flushing. The default
  # is dynamic based on if the event is structured or not.
  # 
  # * optional
  # * no default
  # * enum: "json" or "text"
  encoding = "json"
  encoding = "text"

  # The window used for the `request_rate_limit_num` option
  # 
  # * optional
  # * default: 1
  # * unit: seconds
  rate_limit_duration = 1

  # The maximum number of requests allowed within the `rate_limit_duration`
  # window.
  # 
  # * optional
  # * default: 5
  rate_limit_num = 5

  # The maximum number of in-flight requests allowed at any given time.
  # 
  # * optional
  # * default: 5
  request_in_flight_limit = 5

  # The maximum time a request can take before being aborted.
  # 
  # * optional
  # * default: 30
  # * unit: seconds
  request_timeout_secs = 30

  # The maximum number of retries to make for failed requests.
  # 
  # * optional
  # * default: 5
  retry_attempts = 5

  # The amount of time to wait before attempting a failed request again.
  # 
  # * optional
  # * default: 5
  # * unit: seconds
  retry_backoff_secs = 5

  #
  # Buffer
  #

  [sinks.aws_kinesis_streams_sink.buffer]
    # The buffer's type / location. `disk` buffers are persistent and will be
    # retained between restarts.
    # 
    # * optional
    # * default: "memory"
    # * enum: "memory" or "disk"
    type = "memory"
    type = "disk"

    # The behavior when the buffer becomes full.
    # 
    # * optional
    # * default: "block"
    # * enum: "block" or "drop_newest"
    when_full = "block"
    when_full = "drop_newest"

    # The maximum size of the buffer on the disk.
    # 
    # * optional
    # * no default
    # * unit: bytes
    max_size = 104900000

    # The maximum number of events allowed in the buffer.
    # 
    # * optional
    # * default: 500
    # * unit: events
    num_items = 500
```
{% endcode-tabs-item %}
{% endcode-tabs %}

## Examples

The `aws_kinesis_streams` sink batches [`log`][docs.data-model.log] up to the `batch_size` or `batch_timeout` options. When flushed, Vector will write to [AWS Kinesis Data Stream][urls.aws_kinesis_data_streams] via the [`PutRecords` API endpoint](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_PutRecords.html). The encoding is dictated by the `encoding` option. For example:

```http
POST / HTTP/1.1
Host: kinesis.<region>.<domain>
Content-Length: <byte_size>
Content-Type: application/x-amz-json-1.1
Connection: Keep-Alive 
X-Amz-Target: Kinesis_20131202.PutRecords
{
    "Records": [
        {
            "Data": "<base64_encoded_event>",
            "PartitionKey": "<partition_key>"
        },
        {
            "Data": "<base64_encoded_event>",
            "PartitionKey": "<partition_key>"
        },
        {
            "Data": "<base64_encoded_event>",
            "PartitionKey": "<partition_key>"
        },
    ],
    "StreamName": "<stream_name>"
}
```

## How It Works

### Authentication

Vector checks for AWS credentials in the following order:

1. Environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
2. The [`credential_process` command][urls.aws_credential_process] in the AWS config file. (usually located at `~/.aws/config`)
3. The [AWS credentials file][urls.aws_credentials_file]. (usually located at `~/.aws/credentials`)
4. The [IAM instance profile][urls.iam_instance_profile]. (will only work if running on an EC2 instance with an instance profile/role)

If credentials are not found the [healtcheck](#healthchecks) will fail and an
error will be [logged][docs.monitoring#logs].

#### Obtaining an access key

In general, we recommend using instance profiles/roles whenever possible. In
cases where this is not possible you can generate an AWS access key for any user
within your AWS account. AWS provides a [detailed guide][urls.aws_access_keys] on
how to do this.

### Buffers & Batches

![][assets.sink-flow-serial]

The `aws_kinesis_streams` sink buffers & batches data as
shown in the diagram above. You'll notice that Vector treats these concepts
differently, instead of treating them as global concepts, Vector treats them
as sink specific concepts. This isolates sinks, ensuring services disruptions
are contained and [delivery guarantees][docs.guarantees] are honored.

#### Buffers types

The `buffer.type` option allows you to control buffer resource usage:

| Type     | Description                                                                                                    |
|:---------|:---------------------------------------------------------------------------------------------------------------|
| `memory` | Pros: Fast. Cons: Not persisted across restarts. Possible data loss in the event of a crash. Uses more memory. |
| `disk`   | Pros: Persisted across restarts, durable. Uses much less memory. Cons: Slower, see below.                      |

#### Buffer overflow

The `buffer.when_full` option allows you to control the behavior when the
buffer overflows:

| Type          | Description                                                                                                                        |
|:--------------|:-----------------------------------------------------------------------------------------------------------------------------------|
| `block`       | Applies back pressure until the buffer makes room. This will help to prevent data loss but will cause data to pile up on the edge. |
| `drop_newest` | Drops new data as it's received. This data is lost. This should be used when performance is the highest priority.                  |

#### Batch flushing

Batches are flushed when 1 of 2 conditions are met:

1. The batch age meets or exceeds the configured `batch_timeout` (default: `1 seconds`).
2. The batch size meets or exceeds the configured `batch_size` (default: `1049000 bytes`).

### Delivery Guarantee

This component offers an [**at least once** delivery guarantee][docs.guarantees#at-least-once-delivery]
if your [pipeline is configured to achieve this][docs.guarantees#at-least-once-delivery].

### Encodings

The `aws_kinesis_streams` sink encodes events before writing
them downstream. This is controlled via the `encoding` option which accepts
the following options:

| Encoding | Description |
| :------- | :---------- |
| `json` | The payload will be encoded as a single JSON payload. |
| `text` | The payload will be encoded as new line delimited text, each line representing the value of the `"message"` key. |

#### Dynamic encoding

By default, the `encoding` chosen is dynamic based on the explicit/implcit
nature of the event's structure. For example, if this event is parsed (explicit
structuring), Vector will use `json` to encode the structured data. If the event
was not explicitly structured, the `text` encoding will be used.

To further explain why Vector adopts this default, take the simple example of
accepting data over the [`tcp` source][docs.sources.tcp] and then connecting
it directly to the `aws_kinesis_streams` sink. It is less
surprising that the outgoing data reflects the incoming data exactly since it
was not explicitly structured.

### Environment Variables

Environment variables are supported through all of Vector's configuration.
Simply add `${MY_ENV_VAR}` in your Vector configuration file and the variable
will be replaced before being evaluated.

You can learn more in the [Environment Variables][docs.configuration#environment-variables]
section.

### Health Checks

Health checks ensure that the downstream service is accessible and ready to
accept data. This check is performed upon sink initialization.

If the health check fails an error will be logged and Vector will proceed to
start. If you'd like to exit immediately upon health check failure, you can
pass the `--require-healthy` flag:

```bash
vector --config /etc/vector/vector.toml --require-healthy
```

And finally, if you'd like to disable health checks entirely for this sink
you can set the `healthcheck` option to `false`.

### Partitioning

By default, Vector issues random 16 byte values for each
[Kinesis record's partition key][urls.aws_kinesis_partition_key], evenly
distributing records across your Kinesis partitions. Depending on your use case
this might not be sufficient since random distribution does not preserve order.
To override this, you can supply the `partition_key_field` option. This option
represents a field on your event to use for the partition key value instead.
This is useful if you have a field already on your event, and it also pairs
nicely with the [`add_fields` transform][docs.transforms.add_fields].

#### Missing keys or blank values

Kenisis requires a value for the partition key and therefore if the key is
missing or the value is blank the event will be dropped and a
[`warning` level log event][docs.monitoring#logs] will be logged. As such,
the field specified in the `partition_key_field` option should always contain
a value.

#### Values that exceed 256 characters

If the value provided exceeds the maximum allowed length of 256 characters
Vector will slice the value and use the first 256 characters.

#### Non-string values

Vector will coerce the value into a string.

#### Provisioning & capacity planning

This is generally outside the scope of Vector but worth touching on. When you
supply your own partition key it opens up the possibility for "hot spots",
and you should be aware of your data distribution for the key you're providing.
Kinesis provides the ability to
[manually split shards][urls.aws_kinesis_split_shards] to accomodate this.
If they key you're using is dynamic and unpredictable we highly recommend
recondsidering your ordering policy to allow for even and random distribution.

### Rate Limits

Vector offers a few levers to control the rate and volume of requests to the
downstream service. Start with the `rate_limit_duration` and `rate_limit_num`
options to ensure Vector does not exceed the specified number of requests in
the specified window. You can further control the pace at which this window is
saturated with the `request_in_flight_limit` option, which will guarantee no
more than the specified number of requests are in-flight at any given time.

Please note, Vector's defaults are carefully chosen and it should be rare that
you need to adjust these. If you found a good reason to do so please share it
with the Vector team by [opening an issie][urls.new_aws_kinesis_streams_sink_issue].

### Retry Policy

Vector will retry failed requests (status == `429`, >= `500`, and != `501`).
Other responses will _not_ be retried. You can control the number of retry
attempts and backoff rate with the `retry_attempts` and `retry_backoff_secs` options.

### Timeouts

To ensure the pipeline does not halt when a service fails to respond Vector
will abort requests after `30 seconds`.
This can be adjsuted with the `request_timeout_secs` option.

It is highly recommended that you do not lower value below the service's
internal timeout, as this could create orphaned requests, pile on retries,
and result in deuplicate data downstream.

## Troubleshooting

The best place to start with troubleshooting is to check the
[Vector logs][docs.monitoring#logs]. This is typically located at
`/var/log/vector.log`, then proceed to follow the
[Troubleshooting Guide][docs.troubleshooting].

If the [Troubleshooting Guide][docs.troubleshooting] does not resolve your
issue, please:

1. Check for any [open `aws_kinesis_streams_sink` issues][urls.aws_kinesis_streams_sink_issues].
2. If encountered a bug, please [file a bug report][urls.new_aws_kinesis_streams_sink_bug].
3. If encountered a missing feature, please [file a feature request][urls.new_aws_kinesis_streams_sink_enhancement].
4. If you need help, [join our chat/forum community][urls.vector_chat]. You can post a question and search previous questions.

## Resources

* [**Issues**][urls.aws_kinesis_streams_sink_issues] - [enhancements][urls.aws_kinesis_streams_sink_enhancements] - [bugs][urls.aws_kinesis_streams_sink_bugs]
* [**Source code**][urls.aws_kinesis_streams_sink_source]
* [**Service Limits**][urls.aws_kinesis_service_limits]


[assets.aws_kinesis_streams_sink]: ../../../assets/aws_kinesis_streams-sink.svg
[assets.sink-flow-serial]: ../../../assets/sink-flow-serial.svg
[docs.configuration#environment-variables]: ../../../usage/configuration#environment-variables
[docs.data-model.log]: ../../../about/data-model/log.md
[docs.guarantees#at-least-once-delivery]: ../../../about/guarantees.md#at-least-once-delivery
[docs.guarantees]: ../../../about/guarantees.md
[docs.monitoring#logs]: ../../../usage/administration/monitoring.md#logs
[docs.sources.tcp]: ../../../usage/configuration/sources/tcp.md
[docs.transforms.add_fields]: ../../../usage/configuration/transforms/add_fields.md
[docs.troubleshooting]: ../../../usage/guides/troubleshooting.md
[urls.aws_access_keys]: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html
[urls.aws_credential_process]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html
[urls.aws_credentials_file]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
[urls.aws_kinesis_data_streams]: https://aws.amazon.com/kinesis/data-streams/
[urls.aws_kinesis_partition_key]: https://docs.aws.amazon.com/kinesis/latest/APIReference/API_PutRecordsRequestEntry.html#Streams-Type-PutRecordsRequestEntry-PartitionKey
[urls.aws_kinesis_service_limits]: https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html
[urls.aws_kinesis_split_shards]: https://docs.aws.amazon.com/streams/latest/dev/kinesis-using-sdk-java-resharding-split.html
[urls.aws_kinesis_streams_sink_bugs]: https://github.com/timberio/vector/issues?q=is%3Aopen+is%3Aissue+label%3A%22sink%3A+aws_kinesis_streams%22+label%3A%22Type%3A+bug%22
[urls.aws_kinesis_streams_sink_enhancements]: https://github.com/timberio/vector/issues?q=is%3Aopen+is%3Aissue+label%3A%22sink%3A+aws_kinesis_streams%22+label%3A%22Type%3A+enhancement%22
[urls.aws_kinesis_streams_sink_issues]: https://github.com/timberio/vector/issues?q=is%3Aopen+is%3Aissue+label%3A%22sink%3A+aws_kinesis_streams%22
[urls.aws_kinesis_streams_sink_source]: https://github.com/timberio/vector/tree/master/src/sinks/aws_kinesis_streams.rs
[urls.iam_instance_profile]: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html
[urls.new_aws_kinesis_streams_sink_bug]: https://github.com/timberio/vector/issues/new?labels=sink%3A+aws_kinesis_streams&labels=Type%3A+bug
[urls.new_aws_kinesis_streams_sink_enhancement]: https://github.com/timberio/vector/issues/new?labels=sink%3A+aws_kinesis_streams&labels=Type%3A+enhancement
[urls.new_aws_kinesis_streams_sink_issue]: https://github.com/timberio/vector/issues/new?labels=sink%3A+aws_kinesis_streams
[urls.vector_chat]: https://chat.vector.dev
