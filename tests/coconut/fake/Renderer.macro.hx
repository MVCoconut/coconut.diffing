package coconut.fake;

class Renderer {
  static public function hxx(e)
    return coconut.fake.macros.HXX.parse(e);

  static function mount(target, markup)
    return coconut.ui.macros.Helpers.mount(macro coconut.fake.Renderer.mountInto, target, markup, hxx);

}