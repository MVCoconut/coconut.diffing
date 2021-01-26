import coconut.diffing.*;

import haxe.Exception;
import haxe.ds.ReadOnlyArray;
import coconut.diffing.VWidget;

typedef Attr = Map<String, String>;

class DummyFactory implements Factory<Attr, Dummy> {

  public final type:TypeId;
  public final tag:String;

  public function new(type, tag) {
    this.type = type;
    this.tag = tag;
  }

  public function create(data:Attr):Dummy {
    var ret = new Dummy(tag);
    update(ret, data, null);
    return ret;
  }

  public function update(target:Dummy, next:Attr, prev:Attr) {

    for (k => v in next)
      target.attr[k] = v;

    if (prev != null)
      for (k in prev.keys())
        if (!next.exists(k))
          target.attr.remove(k);
  }
}

@:allow(RDummy)
class VDummy extends VNative<Attr, Dummy, Dummy> {
  static final byTag = new Map<String, (attr:Attr, children:ReadOnlyArray<VNode<Dummy>>)->VDummy>();

  function new(factory:DummyFactory, data, ?children)
    super(factory, data, null, children);

  static public function forTag(tag:String)
    return switch byTag[tag] {
      case null:
        byTag[tag] = (attr, children) -> new VDummy(new DummyFactory(new TypeId(), tag), attr, children);
      case v: v;
    }
}

class Dummy {
  public final tag:String;
  public var parent(default, null):Null<Dummy>;
  final children = new Array<Dummy>();
  public final attr = new Map<String, String>();
  public function new(tag) {
    this.tag = tag;
  }

  public function getChildIndex(n:Dummy)
    return children.indexOf(n);

  public function insert(index, n:Dummy) {
    if (n.parent == this) {
      var prev = children.indexOf(n);
      if (prev != index) {
        children[prev] = children[index];
        children[index] = n;
      }
    }
    else {
      children.insert(index, n);
      n.parent = this;
    }
  }

  public function render()
    return
      if (tag == null) '';
      else ['<$tag'].concat([for (k => v in attr) '$k="$v"']).join(' ') + switch children {
        case []: ' />';
        case c: '>' + [for (c in children) c.render()].join('') + '</$tag>';
      }

  public function remove(n:Dummy)
    if (n.parent == this) {
      children.remove(n);
      n.parent = null;
    }

  public function removeMany(many:Array<Dummy>) {
    for (m in many)
      remove(m);// not exactly optimal
  }
}

class Test {
  static function main() {
    // coconut.vdom.Html.div({}, {});
    var dummy = new Dummy('root');
    var root = new Root(dummy, DummyApplicator.INST);

    function div(attr, children)
      return VDummy.forTag('div')(attr, children);

    function button(attr, children) {
      return VDummy.forTag('button')(attr, children);
    }

    function update(v:VNode<Dummy>) {
      root.render(v);
      var diffed = dummy.render();
      var dummy = new Dummy('root');
      var root = new Root(dummy, DummyApplicator.INST);
      root.render(v);
      var created = dummy.render();
      if (diffed != created) {
        trace(diffed, created);
        throw 'whooops';
      }
    }

    update(new VMany([button(["onclick" => 'foo'], []), div(["id" => 'bar'], [])]));
    update(new VMany([div(["id" => 'bar'], []), div(["id" => 'test'], [])]));

    function random(depth = 0)
      return div([for (i in 0...depth) if (Math.random() > .35) 'attr$i' => '$i'], [for (i in 0...Std.random(9 - depth)) random(depth + 1)]);

    // for (i in 0...100)
    //   update(random());
  }
}

@:allow(DummyBookmark)
class DummyCursor implements Cursor<Dummy> {

  public final applicator:Applicator<Dummy>;
  var deleted = [];
  var index:Int;
  final target:Dummy;

  public function new(applicator, target, index) {
    this.applicator = applicator;
    this.target = target;
    this.index = index;
  }

  public function insert(native:Dummy)
    target.insert(index++, native);

  public function close() {
    target.removeMany(deleted);
  }

  public function markForDeletion(native:Dummy)
    deleted.push(native);

  // public function bookmark()
  //   return new DummyBookmark(this);
}

// class DummyBookmark implements Cursor.Bookmark<Dummy> {
//   final cursor:DummyCursor;
//   final index:Int;
//   public function new(cursor) {
//     this.cursor = cursor;
//     this.index = cursor.index;
//   }
//   public function didMove()
//     return this.index != cursor.index;
// }

class DummyApplicator implements Applicator<Dummy> {
  static public final INST = new DummyApplicator();
  function new() {}

  public function delete(n:Dummy)
    switch n.parent {
      case null:
      case p:
        p.remove(n);
    }

  public function emptyMarker()
    return new Dummy(null);

  public function siblings(n:Dummy)
    return switch n.parent {
      case null: throw 'assert';
      case parent: new DummyCursor(this, parent, parent.getChildIndex(n));
    }

  public function children(n:Dummy)
    return new DummyCursor(this, n, 0);

}