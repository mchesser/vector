---
description: Install Vector from pre-compiled archives
---

# Install From Archives

Installing Vector from a pre-built archive should be a last resort if Vector
cannot be installed through a supported [platform][docs.platforms] or
[operating system][docs.operating_systems]. Archives are built for released
versions as well as nightly builds.

## Installation

### 1. Download The Archive

{% hint style="info" %}
If you don't see your architecture, then we recommend [building Vector from \
source][docs.from_source].
{% endhint %}

{% tabs %}
{% tab title="Releases" %}
Vector retains archives for all [releases][urls.vector_releases].

#### Latest

"Latest" archive URLs point to the latest [release][urls.vector_releases]:

| Architecture                                                                                         | Notes                                                                            |
|:-----------------------------------------------------------------------------------------------------|:---------------------------------------------------------------------------------|
| [`latest-x86_64-apple-darwin`][urls.vector_latest_release_x86_64-apple-darwin]                        | 64-bit OSX (10.7+, Lion+)                                                        |
| [`latest-unknown-linux-musl`][urls.vector_latest_release_x86_64-unknown-linux-musl]            | 64-bit Linux with MUSL. Fully static, stripped, and LTO. (Recommended for Linux) |
| [`latest-x86_64-unknown-linux-gnu`][urls.vector_latest_release_x86_64-unknown-linux-gnu]              | 64-bit Linux (2.6.18+)                                                           |
| [`latest-armv7-unknown-linux-gnueabihf`][urls.vector_latest_release_armv7-unknown-linux-gnueabihf] ⚠️ | ARMv7 Linux                                                                      |

#### Historical

Vector retains historical builds for all releases:

```
https://packages.timber.io/vector/X.X.X/vector-X.X.X-ARCH-TRIPLE.tar.gz
```

Replace:

* `X.X.X` => your desired version. Ex: `0.3.0`
* `ARCH` => your desired architecture. Ex: `x86_64`
* `TRIPLE` => your desired [target triple][urls.rust_target_triples]. Ex: `unknown-linux-musl`
{% endtab %}
{% tab title="Nightly" %}
"Nightly" builds are built from the [`master` repo branch][urls.vector_repo]
every night. They contain the latest features but may be less stable.

#### Latest

| Architecture                                                                                                          | Notes                                                                            |
|:----------------------------------------------------------------------------------------------------------------------|:---------------------------------------------------------------------------------|
| [`nightly-x86_64-apple-darwin`][urls.vector_latest_nightly_x86_64-apple-darwin]                                        | 64-bit OSX (10.7+, Lion+)                                                        |
| [`nightly-x86_64-unknown-linux-musl`][urls.vector_latest_nightly_x86_64-unknown-linux-musl]                            | 64-bit Linux with MUSL. Fully static, stripped, and LTO. (Recommended for Linux) |
| [`nightly-x86_64-unknown-linux-gnu`][urls.vector_latest_nightly_x86_64-unknown-linux-gnu]                              | 64-bit Linux (2.6.18+)                                                           |
| [`nightly-armv7-unknown-linux-gnueabihf`][urls.vector_latest_nightly_armv7-unknown-linux-gnueabihf] ⚠️ | ARMv7 Linux                                                                      |

#### Historical

Vector retains all historical builds for nightly releases:

```
https://packages.timber.io/vector/nightly/vector-YYY-MM-DD-ARCH-TRIPLE.tar.gz
```

Replace:

* `YYY-MM-DD` => your desired date. Ex: `2019-08-19`
* `ARCH` => your desired architecture. Ex: `x86_64`
* `TRIPLE` => your desired [target triple][urls.rust_target_triples]. Ex: `unknown-linux-musl`
{% endtab %}
{% endtabs %}

⚠️ = This release is limited, it does not support on-disk buffers or the [`kafka` sink][docs.sinks.kafka]. See issue [issue 546][urls.issue_661] for more details.

### 2. Unpack The Archive

Copy the appropriate download link above and then proceed to download it:

```bash
curl -o <release-download-url> | tar -xzf --directory="vector" --strip-components=1
```

This will create a directory called `vector`. Let's change into that directory:

```bash
cd vector
```

Issuing the `ls` command shows the following directory structure:

```
LICENSE
README.md
bin/vector - The vector binary
config/vector.toml - Default Vector configuration
config/vector.spec.toml - Full Vector configuration specification
config/examples/* - A variety of configuration examples
etc/systemd/vector.service - Systemd service file
etc/init.d/vector - Init.d service file
```

### 3. Move vector into your $PATH

To ensure `vector` is in your `$PATH` let's add it to your profile:

```bash
echo "export PATH=\"$(pwd)/vector/bin:\$PATH\"" >> $HOME/.profile
source $HOME/.profile
```

### 4. Start Vector

That's it! You can start vector with:

```bash
vector --config config/vector.toml
```

## Next Steps

### Configuring

The Vector configuration file is located at:

```
config/vector.toml
```

A full spec is located at `config/vector.spec.toml` and examples are
located in `config/vector/examples/*`. You can learn more about configuring
Vector in the [Configuration][docs.configuration] section.

### Data Directory

We highly recommend creating a [data directory][docs.configuration#data-directory]
that Vector can use:

```
mkdir /var/lib/vector
```

And in your `vector.toml` file:

```coffeescript
data_dir = "/var/lib/vector"
```

{% hint style="warning" %}
If you plan to run Vector under a separate user, be sure that the directory
is writable by the `vector` process.
{% endhint %}

### Service Managers

Vector archives ship with service files in case you need them:

#### Init.d

To install Vector into Init.d run:

```bash
cp -a etc/init.d/vector /etc/init.d
```

#### Systemd

To install Vector into Systemd run:

```bash
cp -a etc/systemd/vector /etc/systemd/system
```

### Updating

Simply follow the same [installation instructions above](#installation).


[docs.configuration#data-directory]: ../../../usage/configuration#data-directory
[docs.configuration]: ../../../usage/configuration
[docs.from_source]: ../../../setup/installation/manual/from-source.md
[docs.operating_systems]: ../../../setup/installation/operating-systems
[docs.platforms]: ../../../setup/installation/platforms
[docs.sinks.kafka]: ../../../usage/configuration/sinks/kafka.md
[urls.issue_661]: https://github.com/timberio/vector/issues/661
[urls.releases]: https://github.com/timberio/vector/releases
[urls.rust_target_triples]: https://forge.rust-lang.org/platform-support.html
[urls.vector_latest_nightly_armv7-unknown-linux-gnueabihf]: https://packages.timber.io/vector/nightly/vector-nightly-armv7-unknown-linux-gnueabihf.tar.gz
[urls.vector_latest_nightly_x86_64-apple-darwin]: https://packages.timber.io/vector/nightly/vector-nightly-x86_64-apple-darwin.tar.gz
[urls.vector_latest_nightly_x86_64-unknown-linux-gnu]: https://packages.timber.io/vector/nightly/vector-nightly-x86_64-unknown-linux-gnu.tar.gz
[urls.vector_latest_nightly_x86_64-unknown-linux-musl]: https://packages.timber.io/vector/nightly/vector-nightly-x86_64-unknown-linux-musl.tar.gz
[urls.vector_latest_release_armv7-unknown-linux-gnueabihf]: https://packages.timber.io/vector/latest/vector-latest-armv7-unknown-linux-gnueabihf.tar.gz
[urls.vector_latest_release_x86_64-apple-darwin]: https://packages.timber.io/vector/latest/vector-latest-x86_64-apple-darwin.tar.gz
[urls.vector_latest_release_x86_64-unknown-linux-gnu]: https://packages.timber.io/vector/latest/vector-latest-x86_64-unknown-linux-gnu.tar.gz
[urls.vector_latest_release_x86_64-unknown-linux-musl]: https://packages.timber.io/vector/latest/vector-latest-x86_64-unknown-linux-musl.tar.gz
[urls.vector_repo]: https://github.com/timberio/vector
