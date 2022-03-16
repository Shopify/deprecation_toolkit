# Contribution to Deprecation Toolkit

## Releasing a new version

1. Audit PRs and commits merged since the last release, ensuring **all user fancing changes are documented** in `CHANGELOG.md`.
2. Based on the changes, determine whether to increment the major, minor, or patch version, adhering to [Semantic Versioning][semver].
3. Update the gem version string accordingly in `lib/deprecation_toolkit/version.rb`.
4. Run `bundle install` to update the `Gemfile.lock`.
5. Insert a new heading in `CHANGELOG.md` containing the version identifier and expected release date (e.g. `## 1.2.3 (1999-12-31)`).
6. Commit changes on a new branch and open a PR.
7. **Draft** a [new release][github-new-release] on GitHub, but **do not publish it yet**.
8. Once you have received approval on your PR, merge it into `main`.
9. Deploy using the [ShipIt][shipit] UI, and **verify** the new version is available on [RubyGems][rubygems].
10. Publish the drafted release, tagging the deployed commit (should be `HEAD` of the `main` branch) with a tag of the form `vMAJOR.MINOR.PATCH`.

If something goes wrong during the deploy process, address it and tag whatever commit was successfully deployed as that version.

[semver]: https://semver.org
[github-new-release]: https://github.com/Shopify/deprecation_toolkit/releases/new
[shipit]: https://shipit.shopify.io/shopify/deprecation_toolkit/rubygems
[rubygems]: https://rubygems.org/gems/deprecation_toolkit/versions
