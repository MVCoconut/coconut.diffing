package coconut.diffing;

import coconut.ui.internal.ImplicitContext;

class WidgetFactory<Attr, Native, Concrete:Widget<Native>> {
  public final type:TypeId = new TypeId();

  final _create:(data:Attr, ctx:ImplicitContext)->Concrete;
  final _update:(target:Concrete, next:Attr)->Void;

  public function new(create, update) {
    this._create = create;
    this._update = update;
  }

  public function create(data:Attr, context:ImplicitContext):Concrete
    return _create(data, context);

  public function update(target:Concrete, next:Attr)
    _update(target, next);

}