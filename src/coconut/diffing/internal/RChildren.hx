package coconut.diffing.internal;

import coconut.diffing.Key.KeyMap;

class RChildren<Native, RenderResult:VNode<Native>> {
  var byType = new Map<TypeId, Array<RNode<Native>>>();
  var byKey:Null<KeyMap<RNode<Native>>>;
  var counts = new Map<TypeId, Int>();
  var order = new Array<RNode<Native>>();
  final parent:Parent;

  public function new(parent:Parent, children:Children<RenderResult>, cursor:Cursor<Native>, later) {
    this.parent = parent;
    for (c in children) if (c != null) {
      var r = c.render(parent, cursor, later);
      switch [c.key, byType[r.type]] {
        case [null, null]: byType[r.type] = [r];
        case [null, a]: a.push(r);
        case [k, _]: setKey(k, r);
      }
      order.push(r);
    }
  }

  function setKey(k, v) {
    var m = switch byKey {
      case null: byKey = new KeyMap();
      case v: v;
    }
    m.set(k, v);
    return v;
  }

  public function update(children:Children<RenderResult>, cursor:Cursor<Native>, later) {
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
      return byType[v.type][counts[v.type]++] = v.render(parent, cursor, later);

    var deleteCount = 0,
        applicator = cursor.applicator;

    inline function delete(r:RNode<Native>)
      deleteCount += r.destroy(applicator);

    var index = 0;

    for (v in children) if (v != null)
      order[index++] = switch [v.key, byType[v.type]] {
        case [null, null]:
          byType[v.type] = [];
          counts[v.type] = 0;
          insert(v);
        case [null, rs]:
          switch rs[counts[v.type]] {
            case null: insert(v);
            case r:
              counts[v.type]++;
              r.update(v, cursor, later);
              r;
          }
        case [k, _]:
          inline function insert(v:VNode<Native>)
            return setKey(k, v.render(parent, cursor, later));
          switch getKey(k) {
            case null:
              insert(v);
            case old:
              if (old.type == v.type) {
                old.update(v, cursor, later);
                setKey(k, old);
              }
              else {
                delete(old);
                insert(v);
              }
          }
      }

    order.resize(index);

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

  public function justInsert(cursor:Cursor<Native>, later)
    for (r in order)
      r.justInsert(cursor, later);

  public function destroy(applicator):Int {
    var ret = 0;
    for (r in order)
      ret += r.destroy(applicator);
    return ret;
    // TODO: perhaps clear maps
  }
}