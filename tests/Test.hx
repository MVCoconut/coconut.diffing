import coconut.diffing.*;
import coconut.fake.*;
import coconut.fake.Tags.*;
import haxe.Exception;
import haxe.ds.ReadOnlyArray;
import coconut.fake.Renderer.hxx;
import coconut.diffing.VWidget;

class MyView extends View {
  @:attribute var foo:String;
  function render()
    return switch foo {
      case null: null;
      case Std.parseInt(_) => i if (i != null):
        hxx('
          <>
            <for ${v in 0...i}>
              <div>${'$v'}</div>
            </for>
          </>
        ');
      case v: hxx('<div>$v</div>');
    }
}

class Test {
  static function main() {
    var dummy = new Dummy('root');

    function render(dummy, v) {
      Renderer.mountInto(dummy, v);
      return dummy.render();
    }

    var s = new tink.state.State('y123');
    trace(render(dummy, hxx('<MyView foo=${s.value} />')));
    s.set('x321');
    Renderer.updateAll(); trace(dummy.render());
    s.set(null);
    Renderer.updateAll(); trace(dummy.render());
    s.set('2');
    Renderer.updateAll(); trace(dummy.render());
    s.set('5');
    Renderer.updateAll(); trace(dummy.render());
    s.set('3');
    Renderer.updateAll(); trace(dummy.render());
    s.set('yo');
    Renderer.updateAll(); trace(dummy.render());

    function update(v:VNode<Dummy>) {

      var diffed = render(dummy, v),
          created = render(new Dummy('root'), v);

      if (diffed != created) {
        trace(diffed, created);
        throw 'whooops';
      }
    }

    update(new VMany([button({ onclick: 'foo'}), div({ id: 'bar' })]));
    update(new VMany([div({ id: 'bar' }), div({ id: 'test' })]));

    function random(depth = 0)
      return VDummy.forTag('div')([for (i in 0...depth) if (Math.random() > .35) 'attr$i' => '$i'], [for (i in 0...Std.random(9 - depth)) random(depth + 1)]);

    for (i in 0...10)
      update(random());

    trace('done!');
  }
}