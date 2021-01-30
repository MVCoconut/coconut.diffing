package coconut.diffing;

import coconut.diffing.Key.KeyMap;

class RChildren<Native> {
  var byType = new Map<TypeId, Array<RNode<Native>>>();
  var byKey:Null<KeyMap<RNode<Native>>>;
  var counts = new Map<TypeId, Int>();
  final parent:Parent;

  public function new(parent:Parent, children:ReadOnlyArray<VNode<Native>>, cursor:Cursor<Native>) {
    this.parent = parent;
    if (children != null)
      for (c in children) if (c != null) {
        var r = c.render(parent, cursor);
        switch [c.key, byType[r.type]] {
          case [null, null]: byType[r.type] = [r];
          case [null, a]: a.push(r);
          case [k, _]: setKey(k, r);
        }
      }
  }

  function setKey(k, v) {
    var m = switch byKey {
      case null: byKey = new KeyMap();
      case v: v;
    }
    m.set(k, v);
  }

  public function update(children:ReadOnlyArray<VNode<Native>>, cursor:Cursor<Native>) {
    for (k => _ in byType)
      counts[k] = 0;

    var oldKeyed = byKey;
    byKey = null;
    inline function getKey(k)
      return switch oldKeyed {
        case null: null;
        case m:
          m.get(k);
      }

    inline function insert(v:VNode<Native>)
      byType[v.type][counts[v.type]++] = v.render(parent, cursor);

    var deleteCount = 0;
    inline function delete(r:RNode<Native>)
      deleteCount += r.count();

    if (children != null)
      for (v in children) if (v != null)
        switch [v.key, byType[v.type]] {
          case [null, null]:
            byType[v.type] = [];
            counts[v.type] = 0;
            insert(v);
          case [null, rs]:
            switch rs[counts[v.type]] {
              case null: insert(v);
              case r:
                counts[v.type]++;
                r.update(v, cursor);
            }
          case [k, _]:
            inline function insert(v:VNode<Native>)
              setKey(k, v.render(parent, cursor));
            switch getKey(k) {
              case null:
                insert(v);
              case old:
                if (old.type == v.type) {
                  old.update(v, cursor);
                  setKey(k, old);
                }
                else {
                  delete(old);
                  insert(v);
                }
            }
        }

    for (id => count in counts)
      switch byType[id] {
        case _.length - count => 0:
        case a:
          for (i in count...a.length)
            delete(a[i]);
          a.resize(count);
      }

    if (oldKeyed != null)
      switch byKey {
        case null: oldKeyed.each(r -> delete(r));
        case m: oldKeyed.eachEntry((k, r) -> if (!m.exists(k)) delete(r));
      }

    cursor.delete(deleteCount);
  }

  public function count() {
    var ret = switch byKey {
      case null: 0;
      case m: m.count();
    }
    for (c in counts) ret += c;
    return ret;
  }

  public function delete(cursor:Cursor<Native>):Void {
    cursor.delete(count());
    // TODO: perhaps clear maps
  }
}