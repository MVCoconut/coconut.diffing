package coconut.diffing;

import coconut.ui.Ref;

@:using(coconut.diffing.Factory.FactoryTools)
interface Factory<Data, Native, Target:Native> {
  final type:TypeId;
  function create(data:Data):Target;
  function update(target:Target, next:Data, prev:Data):Void;
}

class FactoryTools {
  static public function vnode<Data, Native, Concrete:Native, RenderResult:VNode<Native>>(f:Factory<Data, Native, Concrete>, data:Data, ?key:Key, ?ref:Ref<Concrete>, ?children:Children<RenderResult>):VNode<Native>
    return new VNative<Data, Native, Concrete>(f, data, key, ref, children);
}

private typedef Dict<T> = Null<haxe.DynamicAccess<Null<T>>>;

class Properties<Value, Native:{}, Target:Native> implements Factory<Dict<Value>, Native, Target> {

  public final type = new TypeId();

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