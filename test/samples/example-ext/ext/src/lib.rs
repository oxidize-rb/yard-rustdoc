#![allow(rustdoc::broken_intra_doc_links)]
#![allow(rustdoc::invalid_html_tags)]

use magnus::{define_module, function, method, prelude::*, Error, Value};

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

    fn secret(&self) -> () {}
}

/// @yard
/// @rename Example::Renamed
#[magnus::wrap(class = "Example::OriginalName")]
struct OriginalName {}

/// Secret: not documented
#[magnus::wrap(class = "Example::Secret")]
struct Secret {}

#[magnus::init]
fn init() -> Result<(), Error> {
    let example_ext = define_module("Example")?;
    let foo = example_ext.define_class("Example::Foo", Default::default())?;
    foo.define_singleton_method("new", function!(Foo::new, 0))?;
    foo.define_method("bar", method!(Foo::bar, -1))?;
    foo.define_method("baz", method!(Foo::baz, 0))?;
    foo.define_method("secret", method!(Foo::secret, 0))?;
    Ok(())
}
