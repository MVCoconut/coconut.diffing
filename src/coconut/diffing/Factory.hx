package coconut.diffing;

import coconut.ui.Ref;

abstract class Factory<Data, Native, Target:Native> {
  public final type = new TypeId();

  public abstract function create(data:Data):Target;
  public abstract function update(target:Target, next:Data, prev:Data):Void;

  /**
    Only used in hydration (by coconut.vdom). The currently encountered native node is passed to `adopt`.
    Return `null` if the wrong type of node is encountered.
  **/
  public function adopt(target:Native):Null<Target> return null;
  /**
    The actual implementation of the hydration (only used by coconut.vdom)
  **/
  public function hydrate(target:Target, data:Data):Void {}

  public function vnode<RenderResult:VNode<Native>>(data:Data, ?key:Key, ?ref:Ref<Target>, ?children:Children<RenderResult>):VNode<Native>
    return new VNative<Data, Native, Target>(this, data, key, ref, children);
}

private typedef Dict<T> = Null<haxe.DynamicAccess<Null<T>>>;

class Properties<Value, Native:{}, Target:Native> extends Factory<Dict<Value>, Native, Target> {

  final construct:()->Target;
  final apply:(target:Target, name:String, nu:Null<Value>, old:Null<Value>)->Void;

  public function new(construct, apply) {
    this.construct = construct;
    this.apply = apply;
  }

  public function create(data:Dict<Value>):Target {
    var ret = construct();
    update(ret, data, null);
    return ret;
  }

  public function update(target:Target, next:Dict<Value>, prev:Dict<Value>)
    set(target, next, prev, apply);

  static public function set<X, V>(target:X, nu:Dict<V>, old:Dict<V>, apply:(target:X, name:String, nu:Null<V>, old:Null<V>)->Void) {
    switch [nu, old] {
      case [null, null]:
      case [null, old]:
        for (k in old.keys())
          apply(target, k, null, null);
      case [nu, null]:
        for (k => v in nu)
          apply(target, k, v, null);
      case [nu, old]:
        for (k => v in nu) {
          var old = old[k];
          if (v != old)
            apply(target, k, v, old);
        }
        for (k in old.keys())
          if (!nu.exists(k))
            apply(target, k, null, null);
    }
  }

}