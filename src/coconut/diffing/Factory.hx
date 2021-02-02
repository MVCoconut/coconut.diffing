package coconut.diffing;

import coconut.ui.Ref;

@:using(coconut.diffing.Factory.FactoryTools)
interface Factory<Data, Concrete> {
  final type:TypeId;
  function create(data:Data):Concrete;
  function update(target:Concrete, next:Data, prev:Data):Void;
}

class FactoryTools {
  static public function instantiate<Data, Native, Concrete:Native, RenderResult:VNode<Native>>(f:Factory<Data, Concrete>, data:Data, ?key:Key, ?ref:Ref<Concrete>, ?children:Children<RenderResult>):Node<Native>
    return new VNative<Data, Native, Concrete>(f, data, key, ref, children);
}