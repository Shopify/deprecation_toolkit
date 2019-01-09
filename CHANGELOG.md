# Change log

## master (unreleased)

## 1.2.1 (2019-01-09)

### Bug fixes
* [#34](https://github.com/Shopify/deprecation_toolkit/pull/34): Fixes SystemStackError with RubyGems v3 and Ruby 2.5+. (@dylanahsmith)

## 1.2.0 (2018-11-28)

### New features

* [#30](https://github.com/Shopify/deprecation_toolkit/pull/30): Introduce a `DeprecationMismatch` error class. (@Edouard-chin)
### Bug fixes
* [#29](https://github.com/Shopify/deprecation_toolkit/pull/29): Fix issue where the error class triggered was incorrect in some circumstances. (@Edouard-chin)

## 1.1.0 (2018-11-13)

### New features

* [#28](https://github.com/Shopify/deprecation_toolkit/pull/28): `Configuration.allowed_deprecations` now accepts Procs.
  This is useful if you need to whitelist deprecations based on the caller.

## 1.0.3 (2018-10-25)

### Bug fixes

* [#22](https://github.com/Shopify/deprecation_toolkit/pull/22): Fixes `Kernel.warn` not triggering deprecation. (@rmacklin)

## 1.0.2 (2018-10-01)

### New features

* [#15](https://github.com/Shopify/deprecation_toolkit/pull/15): Add support for ActiveSupport 4.2. (@andrewmarkle)
