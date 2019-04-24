# Coconut Diffing Library

This library provides a platform agnostic diffing algorithm to render and update UI hierarchies. The rest of this README illustrates how you would go about creating an OpenFl backend for coconut based on coconut.diffing.

## Virtual Nodes

The basic data structure of the virtual UI hierarchy, that we'll henceforth refer to as "virtual tree" is defined like so:

```haxe
package coconut.diffing;

abstract VNode<Real:{}> {  
  static function native<A, R:{}>(type:NodeType<A, R>, ?ref:R->Void, ?key:Key, attr:A, ?children:Array<VNode<R>>):VNode<R>;
}
interface NodeType<Attr, Real:{}> {
  function create(a:Attr):Real;
  function update(w:Real, old:Attr, nu:Attr):Void;
}
```

The most trivial implementation of `NodeType` would look something like this:

```haxe
package coconut.openfl;

import openfl.display.*;

class OpenFlNodeType<Attr:{}, Real:DisplayObject> implements NodeType<Attr, Real> {
  
  var factory:Void->Real;

  public function new(factory) 
    this.factory = factory;

  function setListener(target, prop, val, old) 
    if (old != val) {
      if (old != null) target.removeEventListener(prop, old);
      if (val != null) target.addEventListener(prop, val);
    }

  inline function set(target, prop, val, old)
    switch prop {
      case 'on': Differ.updateObject(target, val, old, setListener);
      default: Reflect.setProperty(target, prop, val);
    }

  public function create(a:Attr):Real {
    var ret = factory();
    Differ.updateObject(ret, a, null, set);
    return ret;
  }

  public function update(r:Real, old:Attr, nu:Attr):Void 
    Differ.updateObject(r, nu, old, set);
}
```

Before we define our first native view, let's start with some boilerplate (yay, boilerplate!):

```haxe
package coconut.openfl.*;
import openfl.events.Event.*;

class Invalidatable extends Sprite {

  var dirty:Bool = false;

  public function new() {
    super();
    this.addEventListener(RENDER, function (_) {
      dirty = false;
      redraw();
    });
    rerenderWith();
  }  
  
  function rerenderWith<T>(?ret:T):T {
    if (!dirty) {
      dirty = true;
      switch this.stage {
        case null:
          this.addEventListener(ADDED_TO_STAGE, function added(_) {
            this.removeEventListener(ADDED_TO_STAGE, added);
            this.stage.invalidate();
          });
        case v: 
          v.invalidate();
      }
    }
    return ret;
  }  

  function redraw() {

  } 
}
```

Side note: if you're using an existent OpenFl component set, the above is not necessary.

Now let's make a very simple OpenFl view for this:

```haxe
import coconut.openfl.*;
import openfl.display.*;
import openfl.events.Event.*;

typedef RectAttr = {
  @:optional final x:Int;
  @:optional final y:Int;
  final w:Int;
  final h:Int;
  @:optional final fill:Int;
  @:optional final on:{
    @:optional final click:openfl.events.MouseEvent->Void;
  }
}

class Rect extends Invalidatable {

  public var w(default, set):Int = 0;
    function set_w(param)
      return invalidate(w = param);

  public var h(default, set):Int = 0;
    function set_h(param)
      return invalidate(h = param);

  public var fill(default, set):Int = 0;
    function set_fill(param)
      return invalidate(fill = param);

  override function redraw() {
    this.graphics.clear();
    this.graphics.beginFill(this.fill);
    this.graphics.drawRect(0, 0, w, h);
  }

  static var nodeType:NodeType<RectAttr, Rect> = new OpenFlNodeType<RectAttr, Rect>(Rect.new);

  static public inline function fromHxx(hxxMeta:{ ?ref: Rect->Void, ?key:coconut.diffing.Key }, attr:RectAttr, ?children:coconut.ui.Children)
    return coconut.diffing.VNode.native(TYPE, hxxMeta.ref, hxxMeta.key, attr, children);
}
```

Additionally, we will need to define this:

```haxe
package coconut.ui;

typedef RenderResult = coconut.diffing.VNode<openfl.display.DisplayObject>;
```

With this in place, we can write the following for example:

```haxe
coconut.UI.hxx(
  <Rect w={200} h={400} on.click={event -> trace('yay!')}>
    <Rect x={10} y={10} w={180} h={185} fill={0xFF0000} />
    <Rect x={205} y={10} w={180} h={185} fill={0x00FF00} />
  </Rect>
);
```

So far, this doesn't do anything yet, because we've merely created a virtual tree.

## Rendering

To actually render things, we have to create a renderer. Let's start with something like this, which is roughly the structure of a renderer you'll want to go with when using `coconut.diffing`.

```haxe
package coconut.ui;

import coconut.diffing.*;
import openfl.display.*;

class Renderer {
  
  static var DIFFER = new coconut.diffing.Differ(new OpenFlBackend());

  static public function mount(target:DisplayObjectContainer, virtual:RenderResult)
    DIFFER.render([virtual], target);

  static public function getNative(view:View):Null<DisplayObject>
    return getAllNative(view)[0];

  static public function getAllNative(view:View):Array<DisplayObject>
    return switch @:privateAccess view._coco_lastRender {
      case null: [];
      case r: r.flatten(null);
    }

  static public inline function updateAll()
    tink.state.Observable.updateAll();
}
```

None of this is OpenFl specific, except for this `OpenFlBackend` class that we'll implement in a moment.

For the differ to be able to perform its job, it relies on you to implement the following interfaces:

```haxe
interface Cursor<Real:{}> {
  function insert(real:Real):Bool;
  function delete(count:Int):Int;
  function step():Bool;
  function current():Real;
}

interface Applicator<Real:{}> {
  function unsetLastRender(target:Real):Rendered<Real>;
  function setLastRender(target:Real, r:Rendered<Real>):Void;
  function getLastRender(target:Real):Null<Rendered<Real>>;
  function traverseSiblings(first:Real):Cursor<Real>;
  function traverseChildren(parent:Real):Cursor<Real>;
  function placeholder(forTarget:Widget<Real>):VNode<Real>;
}
```

We'll add the implementations to the above module:

```haxe
package coconut.ui;

import coconut.diffing.*;
import openfl.display.*;

class Renderer { /* same as above */ }
private class OpenFlCursor implements Cursor<DisplayObject> {
  
  var pos:Int;
  var container:DisplayObjectContainer;

  public function new(container:DisplayObjectContainer, pos:Int) {
    this.container = container;
    this.pos = this.pos = pos;
  }

  public function insert(real:DisplayObject):Bool { 
    var inserted = real.parent != container;
    container.addChildAt(real, pos);
    return inserted;
  }

  public function delete():Bool
    return 
      if (pos <= container.numChildren) {
        container.removeChildAt(pos);
        true;
      }
      else false;

  public function step():Bool 
    return
      if (pos >= container.numChildren) false;
      else ++pos == container.numChildren;

  public function current():DisplayObject 
    return container.getChildAt(pos);
}

private class OpenFlBackend implements Applicator<DisplayObject> {
  public function new() {}
  var registry:Map<DisplayObject, Rendered<DisplayObject>> = new Map();
  
  public function unsetLastRender(target:DisplayObject):Rendered<DisplayObject> {
    var ret = registry[target];
    registry.remove(target);
    return ret;
  }

  public function setLastRender(target:DisplayObject, r:Rendered<DisplayObject>):Void 
    registry[target] = r;

  public function getLastRender(target:DisplayObject):Null<Rendered<DisplayObject>> 
    return registry[target];

  public function traverseSiblings(target:DisplayObject):Cursor<DisplayObject> 
    return new OpenFlCursor(target.parent, target.parent.getChildIndex(target));

  public function traverseChildren(target:DisplayObject):Cursor<DisplayObject> 
    return new OpenFlCursor(cast target, 0);

  public function placeholder(forTarget:Widget<DisplayObject>):VNode<DisplayObject>
    return VNode.native(PLACEHOLDER, null, null, null, null); 

  static final PLACEHOLDER = new coconut.openfl.OpenFlNodeType(Shape.new);
}
```

Lo and behold, we can now do:

```haxe
import coconut.Ui.hxx;
import coconut.ui.*;
import coconut.openfl.*;
import openfl.display.*;
import coconut.diffing.*;

class Main {

  static function main() {
    openfl.Lib.current.stage.scaleMode = NO_SCALE;
    var root = new Sprite();
    openfl.Lib.current.stage.addChild(root);
    var state = new tink.state.State(200);
    Renderer.mount(
      root,
      hxx(//the <Isolated /> is needed to make sure the UI is rendered within a coconut view
        <Isolated>
          <Rect w={state.value} h={400}>
            <Rect x={10} y={10} w={state.value - 20} h={185} fill={0xFF0000} onClick={state.set(state.value - 5)}/>
            <Rect x={10} y={205} w={state.value - 20} h={185} fill={0x00FF00} onClick={state.set(state.value + 5)}/>
          </Rect>
        </Isolated>
      )
    );
  }
}
```

## More seamless integration with native views

In this example, the integration with native views was relatively tedious. We had to define `RectAttr` and then also a `fromHxx` method on `Rect` and what not. Booooring ...

An easier way to do this more broadly would be to use something like this:

```
--macro addMetadata('openfl.display.DisplayObject', '@:autoBuild(coconut.openfl.macros.HxxIntegration.boot())')
```

Here, `coconut.openfl.macros.HxxIntegration.boot` is a build macro that generates this glue code automatically. When working with a ui component framework, you may actually want to use its base class as the target for this macro call. That does not exclude you from using plain display objects. To run the same macro on another class, you may then follow up with:

```
--macro addGlobalMetadata('path.to.ParticularClass', '@:build(coconut.openfl.macros.HxxIntegration.boot())')
```

Also, the `fromHxx` method doesn't have to exist on the class that it is constructing. You can have a "wrapper" class with a static `fromHxx` method that returns the right `VNode` to construct the thing you want. Or you may even define a facade like this:

```haxe
class Gui {
  static public function hbox(...)
    return VNode.native(...);

  static public function vbox(...)
    return VNode.native(...);

  static public function checkbox(...)
    return VNode.native(...);

  static public function button(...)
    return VNode.native(...);

  static public function radio(...)
    return VNode.native(...);
}

// and then use it like so:
import Gui.*;

coconut.Ui.hxx(
  <hbox>
    <vbox>
      <button>Test 1</button>
      <button>Test 2</button>
      <button>Test 3</button>
      <button>Test 4</button>
    </vbox>
    <vbox>
      <checkbox>I'm a checkbox!</checkbox>
      <radio>I'm a radio button!</radio>
    </vbox>
  </hbox>
);
```