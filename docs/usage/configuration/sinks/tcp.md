---
description: Streams `log` events to a TCP connection.
---

<!--
     THIS FILE IS AUTOGENERATED!

     To make changes please edit the template located at:

     scripts/generate/templates/docs/usage/configuration/sinks/tcp.md.erb
-->

# tcp sink

![][assets.tcp_sink]


The `tcp` sink [streams](#streaming) [`log`][docs.data-model.log] events to a TCP connection.

## Config File

{% code-tabs %}
{% code-tabs-item title="vector.toml (simple)" %}
```coffeescript
[sinks.my_sink_id]
  type = "tcp" # must be: "tcp"
  inputs = ["my-source-id"]
  address = "92.12.333.224:5000"

  # For a complete list of options see the "advanced" tab above.
```
{% endcode-tabs-item %}
{% code-tabs-item title="vector.toml (advanced)" %}
```coffeescript
[sinks.tcp_sink]
  #
  # General
  #

  # The component type
  # 
  # * required
  # * no default
  # * must be: "tcp"
  type = "tcp"

  # A list of upstream source or transform IDs. See Config Composition for more
  # info.
  # 
  # * required
  # * no default
  inputs = ["my-source-id"]

  # The TCP address.
  # 
  # * required
  # * no default
  address = "92.12.333.224:5000"

  # Enables/disables the sink healthcheck upon start.
  # 
  # * optional
  # * default: true
  healthcheck = true

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

  #
  # Buffer
  #

  [sinks.tcp_sink.buffer]
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

  #
  # Tls
  #

  [sinks.tcp_sink.tls]
    # Enable TLS during connections to the remote.
    # 
    # * optional
    # * default: false
    enabled = false

    # If `true`, Vector will force certificate validation. Do NOT set this to
    # `false` unless you know the risks of not verifying the remote certificate.
    # 
    # * optional
    # * default: true
    verify = true

    # Absolute path to additional CA certificate file, in PEM format.
    # 
    # * optional
    # * no default
    ca_file = "/path/to/certificate_authority.crt"

    # Absolute path to certificate file used to identify this connection, in PEM
    # format. If this is set, `key_file` must also be set.
    # 
    # * optional
    # * no default
    crt_file = "/path/to/host_certificate.crt"

    # Absolute path to key file used to identify this connection, in PEM format. If
    # this is set, `crt_file` must also be set.
    # 
    # * optional
    # * no default
    key_file = "/path/to/host_certificate.key"

    # Pass phrase to unlock the encrypted key file. This has no effect unless
    # `key_file` above is set.
    # 
    # * optional
    # * no default
    key_phrase = "PassWord1"
```
{% endcode-tabs-item %}
{% endcode-tabs %}

## How It Works

### Delivery Guarantee

Due to the nature of this component, it offers a
[**best effort** delivery guarantee][docs.guarantees#best-effort-delivery].

### Encodings

The `tcp` sink encodes events before writing
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
it directly to the `tcp` sink. It is less
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

### Streaming

The `tcp` sink streams data on a real-time
event-by-event basis. It does not batch data.

## Troubleshooting

The best place to start with troubleshooting is to check the
[Vector logs][docs.monitoring#logs]. This is typically located at
`/var/log/vector.log`, then proceed to follow the
[Troubleshooting Guide][docs.troubleshooting].

If the [Troubleshooting Guide][docs.troubleshooting] does not resolve your
issue, please:

1. Check for any [open `tcp_sink` issues][urls.tcp_sink_issues].
2. If encountered a bug, please [file a bug report][urls.new_tcp_sink_bug].
3. If encountered a missing feature, please [file a feature request][urls.new_tcp_sink_enhancement].
4. If you need help, [join our chat/forum community][urls.vector_chat]. You can post a question and search previous questions.

## Resources

* [**Issues**][urls.tcp_sink_issues] - [enhancements][urls.tcp_sink_enhancements] - [bugs][urls.tcp_sink_bugs]
* [**Source code**][urls.tcp_sink_source]


[assets.tcp_sink]: ../../../assets/tcp-sink.svg
[docs.configuration#environment-variables]: ../../../usage/configuration#environment-variables
[docs.data-model.log]: ../../../about/data-model/log.md
[docs.guarantees#best-effort-delivery]: ../../../about/guarantees.md#best-effort-delivery
[docs.monitoring#logs]: ../../../usage/administration/monitoring.md#logs
[docs.sources.tcp]: ../../../usage/configuration/sources/tcp.md
[docs.troubleshooting]: ../../../usage/guides/troubleshooting.md
[urls.new_tcp_sink_bug]: https://github.com/timberio/vector/issues/new?labels=sink%3A+tcp&labels=Type%3A+bug
[urls.new_tcp_sink_enhancement]: https://github.com/timberio/vector/issues/new?labels=sink%3A+tcp&labels=Type%3A+enhancement
[urls.tcp_sink_bugs]: https://github.com/timberio/vector/issues?q=is%3Aopen+is%3Aissue+label%3A%22sink%3A+tcp%22+label%3A%22Type%3A+bug%22
[urls.tcp_sink_enhancements]: https://github.com/timberio/vector/issues?q=is%3Aopen+is%3Aissue+label%3A%22sink%3A+tcp%22+label%3A%22Type%3A+enhancement%22
[urls.tcp_sink_issues]: https://github.com/timberio/vector/issues?q=is%3Aopen+is%3Aissue+label%3A%22sink%3A+tcp%22
[urls.tcp_sink_source]: https://github.com/timberio/vector/tree/master/src/sinks/tcp.rs
[urls.vector_chat]: https://chat.vector.dev
