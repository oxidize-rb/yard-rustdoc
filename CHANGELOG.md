# Changelog

## v0.3.2

- Fix bad release in v0.3.1

## v0.3.1

- Add `@module` tag to turn a struct into a module.

## v0.3.0

- Remove the `@yard` annotation when sending to docstring to YARD.
  It's unecessary and makes it harder to use the `(see ...)` pattern.

## v0.2.0

- Define instance methods when the function's first parameter is `rb_self`
- Support documenting `Enum`s.
