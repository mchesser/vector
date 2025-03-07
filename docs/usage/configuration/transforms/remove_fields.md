---
description: Accepts `log` events and allows you to remove one or more log fields.
---

<!--
     THIS FILE IS AUTOGENERATED!

     To make changes please edit the template located at:

     scripts/generate/templates/docs/usage/configuration/transforms/remove_fields.md.erb
-->

# remove_fields transform

![][assets.remove_fields_transform]


The `remove_fields` transform accepts [`log`][docs.data-model.log] events and allows you to remove one or more log fields.

## Config File

{% code-tabs %}
{% code-tabs-item title="vector.toml (simple)" %}
```coffeescript
[transforms.my_transform_id]
  type = "remove_fields" # must be: "remove_fields"
  inputs = ["my-source-id"]
  fields = ["field1", "field2"]

  # For a complete list of options see the "advanced" tab above.
```
{% endcode-tabs-item %}
{% code-tabs-item title="vector.toml (advanced)" %}
```coffeescript
[transforms.remove_fields_transform]
  # The component type
  # 
  # * required
  # * no default
  # * must be: "remove_fields"
  type = "remove_fields"

  # A list of upstream source or transform IDs. See Config Composition for more
  # info.
  # 
  # * required
  # * no default
  inputs = ["my-source-id"]

  # The log field names to drop.
  # 
  # * required
  # * no default
  fields = ["field1", "field2"]
```
{% endcode-tabs-item %}
{% endcode-tabs %}

## How It Works

### Environment Variables

Environment variables are supported through all of Vector's configuration.
Simply add `${MY_ENV_VAR}` in your Vector configuration file and the variable
will be replaced before being evaluated.

You can learn more in the [Environment Variables][docs.configuration#environment-variables]
section.

## Troubleshooting

The best place to start with troubleshooting is to check the
[Vector logs][docs.monitoring#logs]. This is typically located at
`/var/log/vector.log`, then proceed to follow the
[Troubleshooting Guide][docs.troubleshooting].

If the [Troubleshooting Guide][docs.troubleshooting] does not resolve your
issue, please:

1. Check for any [open `remove_fields_transform` issues][urls.remove_fields_transform_issues].
2. If encountered a bug, please [file a bug report][urls.new_remove_fields_transform_bug].
3. If encountered a missing feature, please [file a feature request][urls.new_remove_fields_transform_enhancement].
4. If you need help, [join our chat/forum community][urls.vector_chat]. You can post a question and search previous questions.


### Alternatives

Finally, consider the following alternatives:

* [`add_fields` transform][docs.transforms.add_fields]
* [`lua` transform][docs.transforms.lua]

## Resources

* [**Issues**][urls.remove_fields_transform_issues] - [enhancements][urls.remove_fields_transform_enhancements] - [bugs][urls.remove_fields_transform_bugs]
* [**Source code**][urls.remove_fields_transform_source]


[assets.remove_fields_transform]: ../../../assets/remove_fields-transform.svg
[docs.configuration#environment-variables]: ../../../usage/configuration#environment-variables
[docs.data-model.log]: ../../../about/data-model/log.md
[docs.monitoring#logs]: ../../../usage/administration/monitoring.md#logs
[docs.transforms.add_fields]: ../../../usage/configuration/transforms/add_fields.md
[docs.transforms.lua]: ../../../usage/configuration/transforms/lua.md
[docs.troubleshooting]: ../../../usage/guides/troubleshooting.md
[urls.new_remove_fields_transform_bug]: https://github.com/timberio/vector/issues/new?labels=transform%3A+remove_fields&labels=Type%3A+bug
[urls.new_remove_fields_transform_enhancement]: https://github.com/timberio/vector/issues/new?labels=transform%3A+remove_fields&labels=Type%3A+enhancement
[urls.remove_fields_transform_bugs]: https://github.com/timberio/vector/issues?q=is%3Aopen+is%3Aissue+label%3A%22transform%3A+remove_fields%22+label%3A%22Type%3A+bug%22
[urls.remove_fields_transform_enhancements]: https://github.com/timberio/vector/issues?q=is%3Aopen+is%3Aissue+label%3A%22transform%3A+remove_fields%22+label%3A%22Type%3A+enhancement%22
[urls.remove_fields_transform_issues]: https://github.com/timberio/vector/issues?q=is%3Aopen+is%3Aissue+label%3A%22transform%3A+remove_fields%22
[urls.remove_fields_transform_source]: https://github.com/timberio/vector/tree/master/src/transforms/remove_fields.rs
[urls.vector_chat]: https://chat.vector.dev
