import Jijian.Wire
import Lean.Util.CollectAxioms

/- 审计器不导入生成的模块、不运行候选 tactic，不接收 Lean 程序字符串。 -/
namespace Jijian
open Lean Elab Command

private def readBundle (path : String) : CommandElabM Bundle := do
  let text ← liftIO <| IO.FS.readFile path
  let json ← match Json.parse text with
    | .ok value => pure value
    | .error e => throwError "Invalid proof data: {e}"
  match fromJson? json with
  | .ok value => pure value
  | .error e => throwError "Invalid proof schema: {e}"

private partial def usesBoundAt (expression : Expr) (target : Nat) (depth : Nat := 0) : Bool :=
  match expression with
  | .bvar index => index == target + depth
  | .app fn arg => usesBoundAt fn target depth || usesBoundAt arg target depth
  | .lam _ type body _ => usesBoundAt type target depth || usesBoundAt body target (depth + 1)
  | .forallE _ type body _ => usesBoundAt type target depth || usesBoundAt body target (depth + 1)
  | .letE _ type value body _ => usesBoundAt type target depth ||
      usesBoundAt value target depth || usesBoundAt body target (depth + 1)
  | .mdata _ value => usesBoundAt value target depth
  | .proj _ _ value => usesBoundAt value target depth
  | _ => false

private partial def usesOuterBinder (expression : Expr) (depth : Nat := 0) : Bool :=
  match expression with
  | .bvar index => index == depth
  | .app fn arg => usesOuterBinder fn depth || usesOuterBinder arg depth
  | .lam _ type body _ => usesOuterBinder type depth || usesOuterBinder body (depth + 1)
  | .forallE _ type body _ => usesOuterBinder type depth || usesOuterBinder body (depth + 1)
  | .letE _ _ value body _ =>
      if usesBoundAt body 0 then
        usesOuterBinder (body.instantiate1 value) depth
      else
        usesOuterBinder body (depth + 1)
  | .mdata _ value => usesOuterBinder value depth
  | .proj _ _ value => usesOuterBinder value depth
  | _ => false

private partial def dependencyUsage (type proof : Expr) : Array Json :=
  match type with
  | .mdata _ body => dependencyUsage body proof
  | .letE _ _ value body _ => dependencyUsage (body.instantiate1 value) proof
  | .forallE name _ typeBody _ =>
      match proof with
      | .mdata _ body => dependencyUsage type body
      | .letE _ _ value body _ => dependencyUsage type (body.instantiate1 value)
      | .lam _ _ proofBody _ =>
          let binderName := name.toString
          let current := if binderName.startsWith "jjdep_" then
            #[Json.mkObj [("dependencyId", toJson (binderName.drop 6).toString),
                          ("used", toJson (usesOuterBinder proofBody))]]
          else #[]
          current ++ dependencyUsage typeBody proofBody
      | _ => #[]
  | _ =>
      match proof with
      | .mdata _ body => dependencyUsage type body
      | .letE _ _ value body _ => dependencyUsage type (body.instantiate1 value)
      | _ => #[]

private def replay (declarations : Array DeclWire) (seen : Array DeclWire) : CommandElabM (Array DeclWire) := do
  let mut seen := seen
  for d in declarations do
    let name := wireToName d.name
    if (← getEnv).contains name then
      match seen.find? (fun old => wireToName old.name == name) with
      | some old =>
        if (toJson old).compress != (toJson d).compress then
          throwError "Conflicting auxiliary declaration: {name}"
      | none => throwError "Attempt to replace an imported declaration: {name}"
    else
      let declaration ← match wireToDeclaration d with
        | .ok value => pure value
        | .error message => throwError "{message}"
      liftCoreM <| withOptions (fun o => (o.setBool `debug.skipKernelTC false).setBool `Elab.async false) do
        Lean.addDecl declaration
      seen := seen.push d
  return seen

syntax (name := auditCommand) "jj_audit " str str str : command

elab_rules : command
  | `(jj_audit $nonce:str $expectedPath:str $proofPath:str) => withoutModifyingEnv do
      -- Each batch entry starts from the import-only environment.
      -- Earlier audited declarations cannot be referenced by this proof.
      try
        let expected ← readBundle expectedPath.getString
        let proof ← readBundle proofPath.getString
        let some rawValue := proof.value | throwError "Proof data has no term"
        if proof.levelParams.length != expected.levelParams.length then
          throwError "Universe parameter mismatch"
        let seen ← replay expected.auxiliary #[]
        discard <| replay proof.auxiliary seen
        let target := wireToExpr expected.type
        let levels := expected.levelParams.map wireToName
        let value := (wireToExpr rawValue).instantiateLevelParams
          (proof.levelParams.map wireToName) (levels.map Level.param)
        let actualTarget := (wireToExpr proof.type).instantiateLevelParams
          (proof.levelParams.map wireToName) (levels.map Level.param)
        let statementMatches ← liftTermElabM <| Lean.Meta.isDefEq target actualTarget
        unless statementMatches do
          throwError "STATEMENT_DRIFT: candidate declaration type differs from fixed target"
        liftCoreM <| withOptions (fun o => (o.setBool `debug.skipKernelTC false).setBool `Elab.async false) do
          Lean.addDecl (.thmDecl { name := `JJAudited, levelParams := levels, type := target, value })
        let axioms ← liftCoreM <| Lean.collectAxioms `JJAudited
        let statement ← liftTermElabM <| Lean.Meta.ppExpr target
        let certificate := Json.mkObj [
          ("checked", toJson true),
          ("statementMatched", toJson statementMatches),
          ("typeComparisonMethod", toJson "fresh_environment_lean_definitional_equality"),
          ("axioms", toJson (axioms.map Name.toString)),
          ("formalStatement", toJson statement.pretty),
          ("auditMethod", toJson "fresh_environment_data_only_kernel_replay"),
          ("dependencyUsage", toJson (dependencyUsage (wireToExpr expected.type) (wireToExpr rawValue)))]
        liftIO <| IO.println s!"JJ_CERT:{nonce.getString}:{certificate.compress}"
      catch ex =>
        if ex.isInterrupt then throw ex
        let diagnostic ← liftIO ex.toMessageData.format
        let diagnostic := (diagnostic.pretty.replace "\n" " ").replace "\r" " "
        liftIO <| IO.println s!"JJ_AUDIT_ERROR:{nonce.getString}:{diagnostic}"
        liftIO <| IO.println s!"JJ_AUDIT_FAILED:{nonce.getString}"
end Jijian
