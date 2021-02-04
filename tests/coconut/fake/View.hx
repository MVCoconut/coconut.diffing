package coconut.fake;

@:build(coconut.ui.macros.ViewBuilder.build((_:coconut.fake.RenderResult)))
@:autoBuild(coconut.fake.View.autoBuild())
class View extends coconut.diffing.Widget<Dummy> {
  macro function hxx(e);
}