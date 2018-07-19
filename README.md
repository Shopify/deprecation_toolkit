# ⚒ Deprecation Toolkit ⚒

## Introduction

The Deprecation Toolkit is a gem to help you get rid of deprecations in your codebase.
Having deprecations in your application is usually a sign that something will break whenever a third dependency will get updated. The sooner the better to fix them!
Fixing all deprecations at once might be though depending on how big your app is and how much deprecations needs to be fixed. You might have to progressively resolve them while making sure your team doesn't add new one ➰. This is where this gem comes handy!


## How it works

The Deprecation Toolkit gem works by using a [shitlist approach](https://confreaks.tv/videos/reddotrubyconf2017-shitlist-driven-development-and-other-tricks-for-working-on-large-codebases).
First, all current existing deprecations in your codebase are recorded into `.yml` files. When running a test that has non-recorded deprecations, the Deprecation Toolkit gem will trigger a behavior of your choice (by default raise an error).

## Recording Deprecations

As said above, the Deprecation Toolkit works by using a shitlist approach. You have two ways to record deprecations.
Either set `DeprecationToolkit::Configuration.behavior` to `DeprecationToolkit::Behaviors::Record` (see the Configuration Reference below)
Or run your tests with the `--record-deprecations` flag (or simply the `-r` shortcut)
```sh
rails test <path_to_my_test.rb> -r
```

## Configuration Reference

### 🔨 `#DeprecationToolkit::Configuration#deprecation_path`

You can control where the recorded deprecations are read and write into. By default, deprecations will be recorded in the `test/deprecations` folder.

The `deprecation_path` either accepts a string or a proc. When using a proc, the proc will be passed an argument which is the path of the test file being run.

```ruby
DeprecationToolkit::Configuration.deprecation_path = 'test/deprecations'
DeprecationToolkit::Configuration.deprecation_path = -> (test_location) do
  if test_location == 'admin_test.rb'
    'test/deprecations/admin'
  else
    'test/deprecations/storefront'
  end
end
```

### 🔨 `#DeprecationToolkit::Configuration#behavior`

Behaviors defines what will happen when a non-recorded deprecations is encountered.

Behaviors are class that responds to the `trigger` message.

This gem provides 3 behaviors, the default one being `DeprecationToolkit::Behaviors::Raise`.

* `DeprecationToolkit::Behaviors::Raise` will raise either:
  - `DeprecationToolkit::DeprecationIntroduced` error if a new deprecation is introduced.
  - `DeprecationToolkit::DeprecationRemoved` error if a deprecation was removed (compare to the one recorded in the shitlist).
* `DeprecationToolkit::Behaviors::Record` will record deprecations.
* `DeprecationToolkit::Behaviors::Disabled` will do nothing.
  - This is useful if you want to disable this gem for a moment without removing the gem from your Gemfile.

```ruby
DeprecationToolkit::Configuration.behavior = DeprecationToolkit::Behaviors::Record
```

You can also create your own behavior class and perform the logic you want. Your behavior needs to respond to the `.trigger` message.

```ruby
class StatsdBehavior
  def self.trigger(test, deprecations, recorded_deprecations)
     # Could send some statsd event for example
  end
end

DeprecationToolkit::Configuration.behavior = StatsdBehavior
```

### 🔨 `#DeprecationToolkit::Configuration#allowed_deprecations`

If you want to allow some deprecations, this is where you'll configure it. The `allowed_deprecations` configuration accepts an
array of Regexp.

Whenever a deprecation matches one of the regex, the deprecation will be ignored

```ruby
DeprecationToolkit::Configuration.allowed_deprecations = [/Hello World/]

# Let's imagine a third dependency adds a deprecation like this,
# the Deprecation Toolkit will simply ignore it.
ActiveSupport::Deprecation.warn('Hello World')
```

### 🔨 `#DeprecationToolkit::Configuration#warnings_treated_as_deprecation`

Most gems doesn't use `ActiveSupport::Deprecation` to deprecate their code but instead just uses `Kernel#warn` to output
a message in the console.

The DeprecationToolkit gem allows you to configure which warnings should be treated as deprecations in order for you
to keep track of them as if they were regular deprecations.

## License

Deprecation Toolkit is licensed under the [MIT license](LICENSE.txt).
