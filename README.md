# YARD::Rustdoc

YARD plugin for documenting Magnus-based Rust gems. Supports writing class
documentation on Struct and Enums, and method documentation on Struct and Enum
methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "yard-rustdoc"
```

Load the plugin through `--plugin rustdoc` (e.g. in your project's `.yardopts`).
See `test/samples/example-ext` for full example.

## Usage

1. Write YARD-compatible documentation in Rust documentation block
   (`///` or `//!`), and tag them with `@yard`.

2. Generate Rustdoc as JSON:

   ```sh
     cargo +nightly rustdoc -p path/to/extension -- \
        -Zunstable-options --output-format json  \
        --document-private-items
   ```

   `nightly` is required because the JSON format isn't stable yet.  
   `--document-private-items` is included so that you don't have to make
   everything in the crate public.

3. Run YARD on Ruby files and the Rustdoc's JSON:

   ```sh
   yard lib path/to/rustdoc.json
   ```

### Writing documentation

YARD::Rustdoc only targets docblocks starting with `@yard` so that you can
still write Rust-style docblocks for non-Ruby parts of your crate.

#### Examples

The class name will be extracted from Magnus' `class =`.

```rust
/// @yard
/// High-level documentation for Foo::Bar.
#[magnus(class = "Foo::Bar")]
pub struct Bar { }
```

The `@rename` tag renames the class to `Foo::Baz`.

```rust
/// @yard
/// @rename Foo::Baz
pub struct InnerName { }
```

Defines `Foo::Bar.new` -- class method because the first argument isn't `self`.

```rust
impl Bar {
    /// @yard
    /// @return [Foo::Bar]
    fn build() -> Self {}
}
```

Defines `Foo::Bar#baz` and `#qux` -- instance method because the method's first
argument is either `&self` or `rb_self`.

```rust
impl Bar {
    /// @yard
    fn baz(&self) {}

    /// @yard
    fn qux(rb_self: Value) {}
}
```

Specifies the method's name and params with `@def`. This lets YARD know which params
are required, optional, keyword arguments, etc.

`@def` must be a single, valid ruby method definition, without the `end`.

```rust
impl Bar {
    /// @yard
    /// @def qux=(val = "")
    /// @param val [Object]
    fn write_qux(&self, val: Value) {}
}
```

This will be ignored as it's not tagged with `@yard`.

```rust
impl Bar {
    fn secret {}
}
```

#### Tips

YARD's syntax differs from what Rustdoc expects. Linters you might want to disable:

```rust
#![allow(rustdoc::broken_intra_doc_links)]
#![allow(rustdoc::invalid_html_tags)]
#![allow(rustdoc::bare_urls)]
```

## Development

Run tests with `rake`. The tests use a sample project located in
`test/samples/example-ext`. To regenerate its json doc, run `rake doc:rustdoc`
from that directory. See the test project's Rakefile for details.
