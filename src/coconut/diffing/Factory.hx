package coconut.diffing;

interface Factory<Data, Concrete> {
  final type:TypeId;
  function create(data:Data):Concrete;
  function update(target:Concrete, next:Data, prev:Data):Void;
}

class SimpleFactory<Data, Concrete> implements Factory<Data, Concrete> {
  public final type = new TypeId();

  final _create:(data:Data)->Concrete;
  final _update:(target:Concrete, next:Data, prev:Data)->Void;

  public function new(create, update) {
    this._create = create;
    this._update = update;
  }

  public function create(data:Data)
    return _create(data);

  public function update(target:Concrete, next:Data, prev:Data)
    _update(target, next, prev);
}