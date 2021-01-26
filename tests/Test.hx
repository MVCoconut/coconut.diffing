import coconut.diffing.*;
import coconut.fake.*;
import coconut.fake.Tags.*;
import haxe.Exception;
import haxe.ds.ReadOnlyArray;
import coconut.diffing.VWidget;

class MyView extends View {
  function render() {
    return null;
  }
}

class Test {
  static function main() {
    var dummy = new Dummy('root');
    var root = new Root(dummy, DummyApplicator.INST);

    function update(v:VNode<Dummy>) {
      root.render(v);
      var diffed = dummy.render();
      var dummy = new Dummy('root');
      var root = new Root(dummy, DummyApplicator.INST);
      root.render(v);
      var created = dummy.render();
      if (diffed != created) {
        trace(diffed, created);
        throw 'whooops';
      }
    }

    update(new VMany([button({ onclick: 'foo'}), div({ id: 'bar' })]));
    update(new VMany([div({ id: 'bar' }), div({ id: 'test' })]));

    function random(depth = 0)
      return div([for (i in 0...depth) if (Math.random() > .35) 'attr$i' => '$i'], [for (i in 0...Std.random(9 - depth)) random(depth + 1)]);

    for (i in 0...10)
      update(random());

    trace('done!');
  }
}