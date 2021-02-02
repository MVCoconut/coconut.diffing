package coconut.diffing;

import coconut.diffing.VMany.RMany;
import coconut.ui.internal.ImplicitContext;
import coconut.diffing.VNode;

class Implicit<Native, RenderResult:VNode<Native>> implements VNode<Native> {

  final children:Children<VNode<Native>>;
  final defaults:ImplicitValues;

  static final TYPE = new TypeId();

  public final type:TypeId = TYPE;
  public final key:Null<Key> = null;

  public function new(attr:{ defaults: ImplicitValues, children:Children<RenderResult> }) {
    this.children = attr.children;
    this.defaults = attr.defaults;
  }

  public function render(parent:Parent, cursor:Cursor<Native>, later):RNode<Native>
    return new RImplicit(this, parent, cursor, later);

}

@:access(coconut.diffing.Implicit)
private class RImplicit<Native> extends Parent implements RNode<Native> {
  public final type = Implicit.TYPE;

  final children:RMany<Native, VNode<Native>>;
  public function new<RenderResult:VNode<Native>>(v:Implicit<Native, RenderResult>, parent:Parent, cursor, later) {
    super(new ImplicitContext(parent.context), parent);
    this.context.update(v.defaults);
    this.children = new RMany(this, v.children, cursor, later);
  }

  public function reiterate(applicator)
    return children.reiterate(applicator);

  public function update(next, cursor, later) {
    var next = Cast.down(next, Implicit);
    context.update(next.defaults);
    return children.update(new VMany(next.children), cursor, later);
  }

  public function justInsert(cursor, later)
    return children.justInsert(cursor, later);

  public function destroy(applicator) // TODO: consider destroying context here
    return children.destroy(applicator);

}