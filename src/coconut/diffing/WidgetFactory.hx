package coconut.diffing;

class WidgetFactory<Attr, Native, Concrete:Widget<Native>> implements Factory<Attr, Concrete> {
  public final type:TypeId = new TypeId();

  final _create:(data:Attr)->Concrete;
  final _update:(target:Concrete, next:Attr)->Void;

  public function new(create, update) {
    this._create = create;
    this._update = update;
  }

  public function create(data:Attr):Concrete
    return _create(data);

  public function update(target:Concrete, next:Attr, prev:Attr)
    _update(target, next);

}