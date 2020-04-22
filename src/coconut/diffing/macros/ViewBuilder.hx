package coconut.diffing.macros;

#if macro
import haxe.macro.Expr;
using tink.MacroApi;
using Lambda;

class ViewBuilder {

  static public function init(renders)
    return coconut.ui.macros.ViewBuilder.init(renders, function (ctx) {
      var t = ctx.target.target.name.asComplexType([for(p in ctx.target.target.params) TPType(p.t.toComplex())]);
      var attributes = TAnonymous(ctx.attributes);

      var def = macro class {
        static var __type = {
          create: $i{ctx.target.target.name}.new,
          update: function (attr, v) (cast v:$t).__initAttributes(attr) //TODO: unhardcode method name ... should probably come from ctx
        };

        static public function fromHxx(
          hxxMeta: {
            @:optional var key(default, never):coconut.diffing.Key;
            @:optional var ref(default, never):coconut.ui.Ref<$t>;
          },
          attributes:$attributes
        ):$renders
          return coconut.diffing.VNode.VNodeData.VWidget(cast __type, hxxMeta.ref, hxxMeta.key, attributes);
      }

      switch def.fields.find(function(f) return f.name == 'fromHxx').kind {
        case FFun(f): f.params = ctx.target.target.params.map(typeParameterToTypeParamDecl);
        case _: // unreachable
      }

      ctx.target.addMembers(def);

    });

    // TODO: this should go tink_macro
    static function typeParameterToTypeParamDecl(p:haxe.macro.Type.TypeParameter):TypeParamDecl {
      return {
        name: p.name,
        constraints: switch p.t {
          case TInst(_.get() => {kind: KTypeParameter(c)}, _): [for(c in c) c.toComplex()];
          case _: throw 'unreachable';
        }
      }
    }
}
#end