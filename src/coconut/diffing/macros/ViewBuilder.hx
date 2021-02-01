package coconut.diffing.macros;

#if macro
import haxe.macro.Expr;
using tink.MacroApi;
using Lambda;

class ViewBuilder {

  static public function autoBuild(renders:ComplexType)
    return
      coconut.ui.macros.ViewBuilder.autoBuild({
        renders: renders,
        implicits: {
          name: '_coco_implicits',
          fields: [],
        },
        afterBuild: postprocess.bind(renders),
      });

  static public function postprocess(renders:ComplexType, ctx:coconut.ui.macros.ViewBuilder.ViewInfo) {
    var t = ctx.target.target.name.asComplexType([for(p in ctx.target.target.params) TPType(p.t.toComplex())]);
    var ctor = ctx.target.getConstructor();
    ctor.addArg('implicits', macro : coconut.ui.internal.ImplicitContext, true);
    ctor.addStatement(macro _coco_implicits = implicits, true);

    var attributes = TAnonymous(ctx.attributes);

    var def = macro class {
      @:noCompletion static var __factory(get, null) = null;
      @:noCompletion static inline function get___factory()
        return switch __factory {
          case null:
            __factory = new coconut.diffing.WidgetFactory(
              $i{ctx.target.target.name}.new,
              function (v, attr) v.__initAttributes(attr) //TODO: unhardcode method name ... should probably come from ctx
            );
          case v: v;
        }

      static public function fromHxx(
        hxxMeta: {
          @:optional var key(default, never):coconut.diffing.Key;
          @:optional var ref(default, never):coconut.ui.Ref<$t>;
        },
        attributes:$attributes
      ):$renders
        return new coconut.diffing.VWidget(__factory, attributes, hxxMeta.key, hxxMeta.ref);
    }

    {
      var fromHxx = def.fields.find(function(f) return f.name == 'fromHxx');
      fromHxx.pos = ctx.target.target.pos;
      switch  fromHxx.kind {
        case FFun(f): f.params = ctx.target.target.params.map(typeParameterToTypeParamDecl);
        case _: // unreachable
      }
    }

    ctx.target.addMembers(def);
  }

  static public function init(renders)
    return coconut.ui.macros.ViewBuilder.init(renders, postprocess.bind(renders));

  // TODO: this should go tink_macro
  static function typeParameterToTypeParamDecl(p:haxe.macro.Type.TypeParameter):TypeParamDecl
    return {
      name: p.name,
      constraints: switch p.t {
        case TInst(_.get() => {kind: KTypeParameter(c)}, _): [for(c in c) c.toComplex()];
        case _: throw 'unreachable';
      }
    }
}
#end