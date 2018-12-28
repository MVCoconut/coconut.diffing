package coconut.diffing.macros;

import haxe.macro.Expr;
using tink.MacroApi;
using Lambda;

class Setup {

  static function all() 
  
    coconut.ui.macros.ViewBuilder.afterBuild.whenever(function (ctx) {
      var t = ctx.target.target.name.asComplexType([for(p in ctx.target.target.params) TPType(p.t.toComplex())]);
      
      var allAttributes = TAnonymous(ctx.attributes.concat(
        (macro class {
          @:optional var key(default, never):coconut.diffing.Key;
          @:optional var ref(default, never):coconut.ui.Ref.RefSetter<$t>;
        }).fields      
      ));

      var attributes = ctx.attributes;
      
      var def = macro class {
        static public function fromHxx(attributes:$allAttributes) {
          return @:privateAccess coconut.ui.RenderResult.widget(
            $v{ctx.target.target.pack.concat([ctx.target.target.name]).join('.')},
            attributes.key,
            attributes.ref,
            attributes,
            {
              create: $i{ctx.target.target.name}.new,
              update: function (attr, v) (cast v:$t).__initAttributes(attr) //TODO: unhardcode method name ... should probably come from ctx
            }
          );
        }
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