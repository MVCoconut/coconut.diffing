package coconut.fake;

class View {
  static function hxx(_, e)
    return coconut.fake.macros.HXX.parse(e);

  static function autoBuild()
    return
      coconut.diffing.macros.ViewBuilder.autoBuild(macro : coconut.fake.RenderResult);
}