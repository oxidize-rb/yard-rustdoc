#![allow(rustdoc::broken_intra_doc_links)]
#![allow(rustdoc::invalid_html_tags)]

use magnus::{define_module, function, method, prelude::*, Error, Ruby, Value};

/// @yard
#[magnus::wrap(class = "Example::Foo")]
struct Foo {}

impl Foo {
    /// @yard
    /// @return Example::Foo
    fn new() -> Self {
        Self {}
    }

    /// @yard
    /// @def bar(req, opt = [], *args, reqkw:, optkw: nil, **kwargs, &block)
    /// @param req [T]
    /// @param opt [T]
    /// @param args [T]
    /// @param reqkw [T]
    /// @param optkw [T]
    /// @param kwargs [T]
    /// @return [nil]
    fn bar(&self, _args: &[Value]) -> () {}

    /// @yard
    /// @def renamed
    fn baz(&self) -> () {}

    /// @yard
    fn with_rb_self(rb_self: Value) -> Value {
        rb_self
    }

    /// @yard
    fn with_ruby_and_rb_self(_ruby: Ruby, rb_self: Value) -> Value {
        rb_self
    }

    /// @yard
    fn with_ruby_and_self(&self, _ruby: Ruby) -> Value {
        self
    }

    fn secret(&self) -> () {}
}

/// @yard
#[magnus::wrap(class = "Example::SomeEnum")]
enum SomeEnum {
    _A,
    _B,
}

/// @yard
/// @rename Example::Renamed
#[magnus::wrap(class = "Example::OriginalName")]
struct OriginalName {}

/// Secret: not documented
#[magnus::wrap(class = "Example::Secret")]
struct Secret {}

/// @yard
/// @module
#[allow(unused)]
struct NotClass {}

#[magnus::init]
fn init() -> Result<(), Error> {
    let example_ext = define_module("Example")?;
    let foo = example_ext.define_class("Example::Foo", Default::default())?;
    foo.define_singleton_method("new", function!(Foo::new, 0))?;
    foo.define_method("bar", method!(Foo::bar, -1))?;
    foo.define_method("baz", method!(Foo::baz, 0))?;
    foo.define_method("secret", method!(Foo::secret, 0))?;
    foo.define_method("with_rb_self", method!(Foo::with_rb_self, 0))?;
    foo.define_method("with_ruby_and_self", method!(Foo::with_ruby_and_self, 0))?;
    foo.define_method(
        "with_ruby_and_rb_self",
        method!(Foo::with_ruby_and_rb_self, 0),
    )?;
    let _some_enum = example_ext.define_class("Example::SomeEnum", Default::default())?;
    Ok(())
}
