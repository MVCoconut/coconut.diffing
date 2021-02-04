package coconut.fake;

class Renderer {

  static public function mountInto(target:Dummy, vdom:RenderResult) {
    var ret = Root.fromNative(target, DummyApplicator.INST);
    ret.render(vdom);
    return ret;
  }

  static public macro function mount(target, markup);

  static public inline function updateAll()
    tink.state.Observable.updateAll();

  static public macro function hxx(e);
}