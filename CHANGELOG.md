# Change log

## main (unreleased)

## 2.2.0 (2024-02-05)

* Restore Rails 6.1 compatibility.
* Accept anything that responds to `===` in `Configuration.warnings_treated_as_deprecation`.

## 2.1.0 (2024-01-19)

* [#99](https://github.com/Shopify/deprecation_toolkit/pull/99): Fix `Warning.warn` hook to accept a category.
* [#95](https://github.com/Shopify/deprecation_toolkit/pull/95): Allow configuration of deprecation file paths and file names.

## 2.0.4 (2023-11-20)

* [#90](https://github.com/Shopify/deprecation_toolkit/pull/90) & [#93](https://github.com/Shopify/deprecation_toolkit/pull/93): Stop using deprecated behavior from Active Support. (@etiennebarrie)
* [#91](https://github.com/Shopify/deprecation_toolkit/pull/91): Require necessary Active Support core extension. (@etiennebarrie)

## 2.0.3 (2023-02-10)

* [#80](https://github.com/Shopify/deprecation_toolkit/pull/80): Filter out stack trace from Gem::Deprecate deprecation messages (@davidstosik)

## 2.0.2 (2023-02-08)

* [#78](https://github.com/Shopify/deprecation_toolkit/pull/78): Show deprecations without stacktrace. (@shioyama)

## 2.0.1 (2022-11-18)

* [#74](https://github.com/Shopify/deprecation_toolkit/pull/74): Add support for `Rails.application.deprecators`. (@gmcgibbon)

## 2.0.0 (2022-03-16)

* [#58](https://github.com/Shopify/deprecation_toolkit/pull/58): Drop support for Ruby < 2.6 & Active Support < 5.2. (@sambostock)
* [#58](https://github.com/Shopify/deprecation_toolkit/pull/58): Ensure compatibility with Rails 7. (@sambostock)

## 1.5.1 (2020-04-28)

* [#46](https://github.com/Shopify/deprecation_toolkit/pull/46): Handle another two part Ruby 2.7 keyword argument deprecation warning. (@casperisfine)

## 1.5.0 (2020-04-14)

* [#42](https://github.com/Shopify/deprecation_toolkit/pull/42): Fix Minitest plugin kicking in when it shouldn't. (@Edouard-chin)
* [#45](https://github.com/Shopify/deprecation_toolkit/pull/45): Handle two part Ruby 2.7 keyword argument deprecation warning. (@casperisfine)

## 1.4.0 (2019-04-29)

* [#37](https://github.com/Shopify/deprecation_toolkit/pull/37): Add Rspec support. (@andrewmarkle)

## 1.3.0 (2019-02-28)

* [#38](https://github.com/Shopify/deprecation_toolkit/pull/38): Add a way to mark test as flaky. (@Edouard-chin)
* [#39](https://github.com/Shopify/deprecation_toolkit/pull/39): Introduced a way to help recording massive amount of deprecations. (@Edouard-chin)

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
