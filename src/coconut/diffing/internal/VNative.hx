package coconut.diffing.internal;

import coconut.diffing.internal.VNativeBase;

class VNative<Data, Native, Concrete:Native> extends VNativeBase<Native, Concrete> {

  public final data:Data;
  public final factory:Factory<Data, Native, Concrete>;

  public function new(factory:Factory<Data, Native, Concrete>, data, ?key, ?ref, ?children) {
    super(factory.type, key, ref, children);
    this.factory = factory;
    this.data = data;
  }

  override public function render(parent, cursor, later, hydrate:Bool):RNode<Native> {
    return new RNative(this, VNative, parent, cursor, later, hydrate);
  }

  override function create(?previous):Concrete
    return switch previous {
      case null: factory.create(data);
      case v:
        switch factory.adopt(v) {
          case null: factory.create(data);
          case v:
            factory.hydrate(v, data);
            v;
        }
    }
}

class RNative<Data, Native, Concrete:Native> extends RNativeBase<VNative<Data, Native, Concrete>, Native, Concrete> {
  override function updateNative(native:Concrete, next:VNative<Data, Native, Concrete>, last:VNative<Data, Native, Concrete>, _, _) {
    next.factory.update(native, next.data, last.data);
  }
}