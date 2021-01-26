import coconut.diffing.*;
import coconut.fake.*;
import coconut.fake.Tags.*;
import haxe.Exception;
import haxe.ds.ReadOnlyArray;
import coconut.fake.Renderer.hxx;
import coconut.diffing.VWidget;

class MyView extends View {
  @:attribute var foo:String;
  function render() '
    <div>
      Hohoho ${foo}!
    </div>
  ';
}

class Test {
  static function main() {
    var dummy = new Dummy('root');

    function render(dummy, v) {
      Renderer.mountInto(dummy, v);
      return dummy.render();
    }

    // var s = new tink.state.State('123');
    // trace(render(dummy, hxx('<MyView foo=${s.value} />')));
    // s.set('321');
    // trace(dummy.render());
    // return;

    function update(v:VNode<Dummy>) {

      var diffed = render(dummy, v),
          created = render(new Dummy('root'), v);

      if (diffed != created) {
        trace(diffed, created);
        throw 'whooops';
      }
    }

    // update(new VMany([button({ onclick: 'foo'}), div({ id: 'bar' })]));
    // update(new VMany([div({ id: 'bar' }), div({ id: 'test' })]));

    function random(depth = 0)
      return VDummy.forTag('div')([for (i in 0...depth) if (Math.random() > .35) 'attr$i' => '$i'], [for (i in 0...Std.random(9 - depth)) random(depth + 1)]);

    for (i in 0...10)
      update(random(7));

    trace('done!');
  }
}