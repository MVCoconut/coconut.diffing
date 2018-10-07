package ;

class RunTests {

  static function main() {
    travix.Logger.println('it works');
    travix.Logger.exit(0); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
  }
  
}

class DomDiffer<V> extends coconut.diffing.Differ<V, js.html.Node> {

  override function spliceChildren(target:js.html.Node, children:Array<js.html.Node>, start:js.html.Node, oldCount:Int) {

    var pos = 
      if (start == null) 0;
      else {
        var found = -1;
        for (i in 0...target.childNodes.length)
          if (target.childNodes[i] == start) {
            found = i;
            break;
          }
        if (found == -1) throw 'start node not found';
        0;
      }

    var created = 0,
        initial = pos;

    function add(nu:js.html.Node) {
      var old = target.childNodes[pos];
      if (old != nu) {
        if (nu.parentNode == null) created++;
        target.insertBefore(nu, old);
      }
      pos++;
    }
    
    for (c in children)
      add(c);

    var total = pos - initial;

    for (i in 0...total - oldCount + created)
      target.removeChild(target.childNodes[pos]);
  }

  override function setChildren(target:js.html.Node, children:Array<js.html.Node>) 
    spliceChildren(target, children, target.childNodes[0], target.childNodes.length);
}