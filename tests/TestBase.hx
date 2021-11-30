@:asserts
class TestBase {
  var root:Native;

  public function new() {

  }

  @:before public function init() {
    root = createRoot();
    return Promise.NOISE;
  }

  function createRoot() {
    return
      #if coconut.vdom
        js.Browser.document.createElement('main')
      #else
        new Dummy('main')
      #end
    ;
  }

  function byClass(name:String)
    return
      #if coconut.vdom
        [for (e in root.getElementsByClassName(name)) e];
      #else
        root.find(d -> d.get('className') == name);
      #end
}