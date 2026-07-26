# Wisper Modernization Report

This PR modernizes Wisper for the current Ruby ecosystem, targeting **Ruby 4.0.6**
(and 3.2 - 3.4) while keeping the gem's public API and behavior unchanged. All 111
tests pass, with 100% line and branch coverage, and the codebase is fully
RuboCop-clean.

## Summary

| | Before | After |
|---|---|---|
| `required_ruby_version` | `>= 2.7` | `>= 3.2` |
| CI Ruby matrix | 2.7, 3.0, 3.1, 3.2, jruby | 3.2, 3.3, 3.4, 4.0 |
| Coverage tooling | `coveralls` (broken install) | `simplecov`, enforced at 100% |
| Lint | none | RuboCop + rubocop-performance + rubocop-rspec, zero offenses |
| Security scanning | none | `bundler-audit`, zero advisories |
| Line coverage | unknown (suite could not install) | **100%** (246/246) |
| Branch coverage | unknown | **100%** (32/32) |
| Test count | 110 | 111 |

## 1. Dependencies

- **Removed `coveralls`.** It is unmaintained (last released 2020) and its
  dependency chain (old `faraday`, `thor`, `tins`, `term-ansicolor`) no longer
  resolves cleanly against a modern Bundler/RubyGems, which meant `bundle install`
  failed outright on Ruby 4.0.6 before this PR. Replaced with **`simplecov`**,
  which needs no service/API key, runs fully offline, and is actively maintained.
  `spec/spec_helper.rb` now calls `SimpleCov.start` with `enable_coverage :branch`
  and `minimum_coverage line: 100, branch: 100`, so the suite itself fails if
  coverage regresses.
- **Added `rubocop` + `rubocop-performance` + `rubocop-rspec`** (dev group) for
  static analysis, with a repo-specific `.rubocop.yml`.
- **Added `bundler-audit`** (dev group) for dependency vulnerability scanning,
  wired into `Rakefile` (`rake bundle:audit:check`) and a new `audit` CI job.
- **Dropped the `flay` dependency.** It was listed but unused anywhere in the
  Rakefile or docs; removing it keeps the dev dependency set lean, consistent
  with the project's own "Wisper is a micro library and will remain lean"
  philosophy (CONTRIBUTING.md).
- Kept `pry` and `yard` (both actively maintained) in the `:extras` group.
- No runtime dependencies changed — Wisper's runtime dependency list was, and
  remains, empty; only stdlib (`set`, `singleton`, `forwardable`) is used.

All of the above are pinned to currently-installed, current major versions in
`Gemfile.lock` (not committed, per this repo's existing `.gitignore` — same as
before).

## 2. Compatibility fixes for Ruby 4.0.6 (and 3.2+)

- **`.ruby-version`** added, set to `4.0.6`. It was previously listed in
  `.gitignore` (unusual for a repo that wants a declared target); the ignore
  rule was removed so the file is actually tracked.
- **`required_ruby_version` raised to `>= 3.2`.** 2.7-3.1 are long past their
  upstream EOL; 3.2 is the oldest version in active/security maintenance today
  and the oldest version this PR's CI matrix (3.2, 3.3, 3.4, 4.0) verifies.
  JRuby was dropped from the matrix — there's no current evidence it tracks
  Ruby 4.0 language/semantic changes, and this environment has no JRuby to
  verify it against; re-adding it is a reasonable follow-up if someone can
  confirm compatibility.
- **`Hash#inspect` format change (Ruby 3.4+).** Ruby 3.4 changed
  `Hash#inspect` to render symbol keys as `{x: :y}` instead of `{:x=>:y}`.
  `spec/lib/wisper/broadcasters/logger_broadcaster_spec.rb` had four
  hardcoded `{:x=>:y}`-style expectations that broke on Ruby 4.0.6 as a
  result (`LoggerBroadcaster#kwargs_info` simply calls `kwargs.inspect`, so
  the library code was never wrong — only the test literals were
  version-specific). Fixed by interpolating `kwargs.inspect` instead of
  hardcoding the expected string, so the spec is correct for any Ruby.
- **Dead `RUBY_VERSION < '3.0'` branches removed** from
  `send_broadcaster_spec.rb` and `logger_broadcaster_spec.rb`. These dated
  from the Ruby 2.7 -> 3.0 keyword-argument separation change and are
  unreachable now that the floor is 3.2.
- **Gemspec HOME-directory handling preserved correctly.** RuboCop's
  `Style/EnvHome` cop suggests `Dir.home` over `ENV['HOME']`, but `Dir.home`
  *raises* if it can't resolve a home directory (e.g. `HOME`/`USER` both
  unset, as on some minimal CI/container images) — that's exactly the bug
  fixed in Wisper 2.0.1 ("fix: safely get signing key in gemspec when HOME
  is not set"). Applying the cop's suggestion blindly would have
  reintroduced that bug. Kept `ENV.fetch('HOME', nil)`, which degrades to an
  empty string, with the cop locally disabled and a comment explaining why.
  Verified with `env -u HOME -u USER gem build wisper.gemspec` (succeeds
  before and after).
- No other stdlib removals/deprecations affected this codebase — it only
  uses `set`, `singleton`, and `forwardable`, all still present and
  unchanged in 4.0.6.
- `frozen_string_literal: true` added to every `lib/` and `spec/` file.
  Audited every string mutation site (`Prefix#initialize`'s `replace`) to
  confirm it mutates `self` (an instance under construction), never a frozen
  literal, so this is safe.
- Ruby 3.1+/3.2+ anonymous argument/block forwarding (`def foo(*, **, &);
  bar(*, **, &); end`) applied throughout by RuboCop's
  `Style/ArgumentsForwarding` autocorrect, used only where arguments were
  pure pass-through (never where the code inspected `args`/`kwargs`
  itself). Verified semantically equivalent and re-ran the full suite after
  each batch of changes.

## 3. Test coverage

- Baseline (pre-PR) suite: 110 examples; coverage was unmeasurable because
  `coveralls` could not even be installed on Ruby 4.0.6.
- Post-PR: **111 examples, 0 failures, 100% line coverage (246/246), 100%
  branch coverage (32/32)**, enforced by `SimpleCov.minimum_coverage`.
- One genuine coverage gap was found and closed:
  `LoggerBroadcaster#name` branches on `object.class == Class` (now
  `object.instance_of?(Class)`) to format class-listeners (e.g. when a
  listener is subscribed as a class rather than an instance, per the
  README's "the listener may need to be a class instead of an object")
  differently from instance-listeners. No existing spec exercised a real
  `Class` as listener/publisher, so that branch was silently untested. Added
  `logger_broadcaster_spec.rb`'s "when the listener is a class rather than
  an instance" example, using a real named class rather than a stubbed
  double (a double's `.class` is `RSpec::Mocks::Double`, not `Class`, so it
  can't exercise this branch).
- Also improved (not just relocated) the "clears registrations when an
  exception occurs" test in `temporary_global_listeners_spec.rb`: it used
  to define a `MyError` constant inline and silently rescue it, which meant
  a bug causing the wrong exception to propagate would have failed
  silently. It now asserts the exception explicitly propagates via
  `expect { ... }.to raise_error(...)`.

## 4. Documentation

- Added full YARD documentation (`@param`, `@return`, `@example`, etc.) to
  every public class and module in `lib/`, including previously-undocumented
  ones: `Wisper::Configuration`, `Wisper::Configuration::Broadcasters`,
  `Wisper::GlobalListeners`, `Wisper::TemporaryListeners`,
  `Wisper::Registration`, `Wisper::BlockRegistration`,
  `Wisper::ObjectRegistration`, `Wisper::Broadcasters::SendBroadcaster`,
  `Wisper::Broadcasters::LoggerBroadcaster`, and the top-level `Wisper`
  module/class methods. This also satisfies RuboCop's `Style/Documentation`
  cop, so it's enforced going forward.
- `README.md`: dropped the dead Coveralls badge (service no longer used),
  documented the Ruby 3.2+ requirement, and added "Linting" plus
  bundler-audit instructions under "Security".
- `CHANGELOG.md`: added a "HEAD (unreleased)" entry per this repo's own
  CONTRIBUTING.md guidance.

## 5. Lint

- Added `.rubocop.yml` (RuboCop + rubocop-performance + rubocop-rspec,
  `TargetRubyVersion: 3.2`, `NewCops: enable`). Ran `rubocop -A` and then
  hand-fixed everything that couldn't be safely auto-corrected.
- `Metrics/*` cops are disabled: Wisper is intentionally a small,
  single-purpose library (per CONTRIBUTING.md) where short classes/methods
  are the point, not something to be flagged.
- A handful of RSpec/Naming cops are relaxed with a documented rationale
  in `.rubocop.yml` (e.g. `listener_1`/`listener_2` naming, empty blocks
  that intentionally test chainability, the mixed `key:`/`:key =>` hash
  syntax the specs use on purpose to exercise both call styles).
- A few offenses were genuine, non-cosmetic fixes rather than blind
  auto-correct: moved `Publisher.included` above `private` (a `private`
  modifier has no effect on `self.foo` methods, so its old position was
  misleading — `Lint/IneffectiveAccessModifier`); replaced
  `methods.keys.detect(&list.method(:is_a?))` with an explicit block in
  `ValueObjects::Events` (`Performance/MethodObjectAsBlock` — method-object
  block-passing allocates an extra `Method` object per call); split an
  over-long interpolated log string in `LoggerBroadcaster` into a named
  `log_message` private method.
- `rake rubocop` / `rake rubocop:autocorrect(_all)` tasks added; a `lint`
  CI job runs `bundle exec rubocop` on every push/PR.

## 6. Security

- Ran `bundle exec bundler-audit check --update` against the full dependency
  tree (1219 advisories in `ruby-advisory-db` as of this PR):
  **no vulnerabilities found.**
- Added `gem.metadata['rubygems_mfa_required'] = 'true'` to the gemspec
  (RuboCop's `Gemspec/RequireMFA`), so future `gem push` to RubyGems.org
  requires the publishing account to have MFA enabled.
- Removed `coveralls`, which pinned old, less-maintained transitive
  dependencies (`faraday` < 1, `thor` < 1, `tins`) that were themselves
  sources of latent supply-chain risk, even though no specific CVE was the
  trigger — that dependency chain simply had no reason to exist anymore.
- Added a `bundler-audit` CI job (`audit`) so future dependency bumps are
  checked automatically, not just at release time.

## Design decisions worth flagging for review

- **JRuby dropped from the CI matrix.** This was a judgment call: JRuby's
  compatibility with Ruby 4.0-era syntax/semantics (e.g. anonymous
  argument forwarding) is unverified in this environment (no JRuby
  available to test against), and the original task instructions require
  the suite to pass on Ruby 4.0.6 specifically. If JRuby support is a
  priority, it should be re-added and verified separately.
- **`required_ruby_version` set to `>= 3.2`**, not `>= 4.0`. The code has no
  Ruby-4.0-only syntax; 3.2/3.3/3.4 are still reasonable, supportable
  floors, and narrowing further would drop real users for no functional
  benefit. The CI matrix verifies all of 3.2, 3.3, 3.4, and 4.0.
- No changes were made to Wisper's public API, `broadcast`/`subscribe`
  semantics, or the `VERSION` constant — this PR is purely
  infrastructure/compatibility/quality, not a behavior change.
