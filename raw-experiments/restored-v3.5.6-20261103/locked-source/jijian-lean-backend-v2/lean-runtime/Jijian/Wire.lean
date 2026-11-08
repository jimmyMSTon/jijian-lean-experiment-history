import Lean

/-
JSON 在审计进程中只被解码为 Expr 数据，不被当成 Lean 程序执行。
不编码自由变量、元变量、任意 IO、环境扩展或新公理。
-/
namespace Jijian
open Lean

inductive NameWire where
  | anonymous
  | str (parent : NameWire) (value : String)
  | num (parent : NameWire) (value : Nat)
  deriving ToJson, FromJson

inductive LevelWire where
  | zero
  | succ (value : LevelWire)
  | max (left right : LevelWire)
  | imax (left right : LevelWire)
  | param (name : NameWire)
  deriving ToJson, FromJson

inductive BinderWire where
  | explicit
  | implicit
  | strictImplicit
  | instImplicit
  deriving ToJson, FromJson

inductive ExprWire where
  | bvar (index : Nat)
  | sort (level : LevelWire)
  | const (name : NameWire) (levels : List LevelWire)
  | app (fn arg : ExprWire)
  | lam (name : NameWire) (type body : ExprWire) (binder : BinderWire)
  | forallE (name : NameWire) (type body : ExprWire) (binder : BinderWire)
  | letE (name : NameWire) (type value body : ExprWire) (nondep : Bool)
  | natLit (value : Nat)
  | strLit (value : String)
  | proj (name : NameWire) (index : Nat) (value : ExprWire)
  deriving ToJson, FromJson

structure DeclWire where
  kind : String
  name : NameWire
  levelParams : List NameWire
  type : ExprWire
  value : ExprWire
  hint : String := "opaque"
  depth : Nat := 0
  deriving ToJson, FromJson

structure Bundle where
  levelParams : List NameWire
  type : ExprWire
  value : Option ExprWire := none
  auxiliary : Array DeclWire := #[]
  deriving ToJson, FromJson

def nameToWire : Name → NameWire
  | .anonymous => .anonymous
  | .str p s => .str (nameToWire p) s
  | .num p n => .num (nameToWire p) n

def wireToName : NameWire → Name
  | .anonymous => .anonymous
  | .str p s => .str (wireToName p) s
  | .num p n => .num (wireToName p) n

def levelToWire : Level → Except String LevelWire
  | .zero => pure .zero
  | .succ l => return .succ (← levelToWire l)
  | .max a b => return .max (← levelToWire a) (← levelToWire b)
  | .imax a b => return .imax (← levelToWire a) (← levelToWire b)
  | .param n => pure (.param (nameToWire n))
  | .mvar _ => .error "Unresolved universe metavariable"

def wireToLevel : LevelWire → Level
  | .zero => .zero
  | .succ l => .succ (wireToLevel l)
  | .max a b => .max (wireToLevel a) (wireToLevel b)
  | .imax a b => .imax (wireToLevel a) (wireToLevel b)
  | .param n => .param (wireToName n)

def binderToWire : BinderInfo → BinderWire
  | .default => .explicit
  | .implicit => .implicit
  | .strictImplicit => .strictImplicit
  | .instImplicit => .instImplicit

def wireToBinder : BinderWire → BinderInfo
  | .explicit => .default
  | .implicit => .implicit
  | .strictImplicit => .strictImplicit
  | .instImplicit => .instImplicit

partial def exprToWire : Expr → Except String ExprWire
  | .bvar n => pure (.bvar n)
  | .sort l => return .sort (← levelToWire l)
  | .const n ls => return .const (nameToWire n) (← ls.mapM levelToWire)
  | .app f x => return .app (← exprToWire f) (← exprToWire x)
  | .lam n t b i => return .lam (nameToWire n) (← exprToWire t) (← exprToWire b) (binderToWire i)
  | .forallE n t b i => return .forallE (nameToWire n) (← exprToWire t) (← exprToWire b) (binderToWire i)
  | .letE n t v b d => return .letE (nameToWire n) (← exprToWire t) (← exprToWire v) (← exprToWire b) d
  | .lit (.natVal n) => pure (.natLit n)
  | .lit (.strVal s) => pure (.strLit s)
  | .mdata _ e => exprToWire e
  | .proj n i e => return .proj (nameToWire n) i (← exprToWire e)
  | .fvar _ => .error "Unexpected free variable"
  | .mvar _ => .error "Unresolved expression metavariable"

partial def wireToExpr : ExprWire → Expr
  | .bvar n => .bvar n
  | .sort l => .sort (wireToLevel l)
  | .const n ls => .const (wireToName n) (ls.map wireToLevel)
  | .app f x => .app (wireToExpr f) (wireToExpr x)
  | .lam n t b i => .lam (wireToName n) (wireToExpr t) (wireToExpr b) (wireToBinder i)
  | .forallE n t b i => .forallE (wireToName n) (wireToExpr t) (wireToExpr b) (wireToBinder i)
  | .letE n t v b d => .letE (wireToName n) (wireToExpr t) (wireToExpr v) (wireToExpr b) d
  | .natLit n => .lit (.natVal n)
  | .strLit s => .lit (.strVal s)
  | .proj n i e => .proj (wireToName n) i (wireToExpr e)

def declarationToWire (c : ConstantInfo) : Except String DeclWire := do
  let common (kind : String) (value : Expr) : Except String DeclWire := do
    return {
      kind := kind
      name := nameToWire c.name
      levelParams := c.levelParams.map nameToWire,
      type := ← exprToWire c.type, value := ← exprToWire value }
  match c with
  | .thmInfo t => common "theorem" t.value
  | .defnInfo d =>
    if d.safety != .safe then throw "Unsafe or partial auxiliary definition"
    let result ← common "definition" d.value
    match d.hints with
    | .«opaque» => pure result
    | .«abbrev» => pure { result with hint := "abbrev" }
    | .regular depth => pure { result with hint := "regular", depth := depth.toNat }
  | .opaqueInfo d =>
    if d.isUnsafe then throw "Unsafe opaque declaration"
    common "opaque" d.value
  | .axiomInfo _ => throw "New axiom in generated environment"
  | _ => throw "Auxiliary inductive/recursor export is not implemented"

def wireToDeclaration (d : DeclWire) : Except String Declaration := do
  let name := wireToName d.name
  let levels := d.levelParams.map wireToName
  let type := wireToExpr d.type
  let value := wireToExpr d.value
  match d.kind with
  | "theorem" => pure (.thmDecl { name, levelParams := levels, type, value })
  | "definition" =>
    let hints ← match d.hint with
      | "opaque" => pure ReducibilityHints.opaque
      | "abbrev" => pure ReducibilityHints.abbrev
      | "regular" => pure (ReducibilityHints.regular d.depth.toUInt32)
      | _ => throw "Invalid reducibility hint"
    pure (.defnDecl { name, levelParams := levels, type, value, hints, safety := .safe })
  | "opaque" => pure (.opaqueDecl { name, levelParams := levels, type, value, isUnsafe := false })
  | _ => throw "Declaration kind not supported by the data-only auditor"

/-- 只收集新出现、被表达式实际引用的声明，依赖在前；不会信任新公理。 -/
partial def visitConstant (baseline env : Environment) (name : Name)
    (seen : List Name) (acc : Array DeclWire) : Except String (List Name × Array DeclWire) := do
  if baseline.contains name || seen.contains name then return (seen, acc)
  let some c := env.find? name | throw s!"Unknown constant: {name}"
  let d ← declarationToWire c
  let mut seen := name :: seen
  let mut acc := acc
  let dependencies := c.type.getUsedConstants.toList ++
    (c.value? (allowOpaque := true)).toList.flatMap (fun e => e.getUsedConstants.toList)
  for dependency in dependencies do
    let next ← visitConstant baseline env dependency seen acc
    seen := next.1
    acc := next.2
  return (seen, acc.push d)

def auxiliaryFor (baseline env : Environment) (expressions : List Expr) : Except String (Array DeclWire) := do
  let mut seen := []
  let mut acc := #[]
  for e in expressions do
    for name in e.getUsedConstants.toList do
      let next ← visitConstant baseline env name seen acc
      seen := next.1
      acc := next.2
  return acc
end Jijian
