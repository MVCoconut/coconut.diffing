package coconut.fake;

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

  public function insert(index, n:Dummy)
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

  public function render()
    return switch tag {
      case null: '';
      case '': attr['text'];
      case tag:
        ['<$tag'].concat([for (k => v in attr) '$k="$v"']).join(' ') + switch children {
          case []: ' />';
          case c: '>' + [for (c in children) if (c == null) '#NULL' else c.render()].join('') + '</$tag>';
        }
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