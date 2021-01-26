package coconut.diffing;

@:access(coconut.diffing.VMany)
class RMany<Native> implements RNode<Native> {
  public final type = VMany.TYPE;

  var byType = new Map<TypeId, Array<RNode<Native>>>();
  var counts = new Map<TypeId, Int>();
  final first:Native;
  final parent:Parent;

  public function new(parent:Parent, children:ReadOnlyArray<VNode<Native>>, cursor:Cursor<Native>) {
    cursor.insert(this.first = cursor.applicator.emptyMarker());
    this.parent = parent;
    for (c in children) {
      var r = c.render(parent, cursor);
      switch byType[r.type] {
        case null: byType[r.type] = [r];
        case a: a.push(r);
      }
    }
  }

  public function reiterate(applicator:Applicator<Native>) {
    var ret = applicator.siblings(first);
    ret.insert(first);
    return ret;
  }

  public function update(next:VNode<Native>, cursor:Cursor<Native>) {
    cursor.insert(first);
    for (k => _ in byType)
      counts[k] = 0;

    inline function insert(v:VNode<Native>)
      byType[v.type][counts[v.type]++] = v.render(parent, cursor);

    for (v in Cast.down(next, VMany).children)
      switch byType[v.type] {
        case null:
          byType[v.type] = [];
          counts[v.type] = 0;
          insert(v);
        case rs:
          switch rs[counts[v.type]] {
            case null: insert(v);
            case r:
              counts[v.type]++;
              r.update(v, cursor);
          }
      }

    inline function remove(r:RNode<Native>)
      r.delete(cursor);

    for (id => count in counts)
      switch byType[id] {
        case _.length - count => 0:
        case a:
          for (i in count...a.length)
            remove(a[i]);
          a.resize(count);
      }
  }

  public function delete(cursor:Cursor<Native>):Void {
    for (stack in byType)
      for (r in stack) r.delete(cursor);
    byType = null;
    counts = null;
  }
}