import Jijian.Wire

namespace Jijian
open Lean Elab Command

-- All batched statements share the import-only baseline. Earlier generated
-- numeral/typeclass auxiliaries must be included for independent replay.
private initialize expectedBaseline : IO.Ref (Option Environment) ← IO.mkRef none

private def parseTerm (text : String) : CommandElabM (TSyntax `term) := do
  match Parser.runParserCategory (← getEnv) `term text with
  | .ok stx => pure ⟨stx⟩
  | .error message => throwError "Term parsing failed: {message}"

private def liftResult (result : Except String α) : CommandElabM α := do
  match result with
  | .ok value => pure value
  | .error message => throwError "Export failed: {message}"

syntax (name := expectedCommand) "jj_expected " str str : command
syntax (name := exportCommand) "jj_export " str str str str : command
syntax (name := expectedExportCommand) "jj_export_expected " str str str str : command

elab_rules : command
  | `(jj_expected $nonce:str $text:str) => do
    try
      let current ← getEnv
      let saved ← liftIO expectedBaseline.get
      let baseline := saved.getD current
      if saved.isNone then liftIO <| expectedBaseline.set (some current)
      let typeSyntax ← parseTerm text.getString
      let expectedName := Name.str .anonymous ("JJExpected_" ++ nonce.getString)
      let name := mkIdent expectedName
      elabCommand (← `(command| def $name : Prop := $typeSyntax))
      let env ← getEnv
      let some (.defnInfo info) := env.find? expectedName
        | throwError "Expected proposition was not elaborated"
      if info.value.getUsedConstants.contains `sorryAx then
        throwError "Expected proposition contains Lean sorryAx recovery"
      let bundle : Bundle := {
        levelParams := info.levelParams.map nameToWire
        type := ← liftResult (exprToWire info.value)
        auxiliary := ← liftResult (auxiliaryFor baseline env [info.value]) }
      liftIO <| IO.println s!"JJ_EXPECTED:{nonce.getString}:{(toJson bundle).compress}"
    catch ex =>
      if ex.isInterrupt then throw ex
      let diagnostic ← liftIO ex.toMessageData.format
      let diagnostic := (diagnostic.pretty.replace "\n" " ").replace "\r" " "
      liftIO <| IO.println s!"JJ_EXPECTED_ERROR:{nonce.getString}:{diagnostic}"
      liftIO <| IO.println s!"JJ_EXPECTED_FAILED:{nonce.getString}"
  | `(jj_export $nonce:str $candidateName:str $text:str $proof:str) => withoutModifyingEnv do
      try
        let baseline ← getEnv
        let typeSyntax ← parseTerm text.getString
        let proofSyntax ← parseTerm proof.getString
        let theoremName := Name.mkSimple candidateName.getString
        let name := mkIdent theoremName
        elabCommand (← `(command| theorem $name : $typeSyntax := $proofSyntax))
        let env ← getEnv
        let some (.thmInfo info) := env.find? theoremName
          | throwError "Candidate proof was not elaborated"
        let bundle : Bundle := {
          levelParams := info.levelParams.map nameToWire
          type := ← liftResult (exprToWire info.type)
          value := some (← liftResult (exprToWire info.value))
          auxiliary := ← liftResult (auxiliaryFor baseline env [info.type, info.value]) }
        liftIO <| IO.println s!"JJ_PROOF:{nonce.getString}:{(toJson bundle).compress}"
      catch ex =>
        if ex.isInterrupt then throw ex
        let diagnostic ← liftIO ex.toMessageData.format
        let diagnostic := (diagnostic.pretty.replace "\n" " ").replace "\r" " "
        liftIO <| IO.println s!"JJ_PROOF_ERROR:{nonce.getString}:{diagnostic}"
        liftIO <| IO.println s!"JJ_PROOF_FAILED:{nonce.getString}"
  | `(jj_export_expected $nonce:str $candidateName:str $text:str $proof:str) => withoutModifyingEnv do
      let nonce := nonce.getString
      let importOnly ← getEnv
      let expectedResult : Except String Bundle ←
        try
          let typeSyntax ← parseTerm text.getString
          let expectedName := Name.str .anonymous ("JJExpected_" ++ nonce)
          let expectedIdent := mkIdent expectedName
          elabCommand (← `(command| def $expectedIdent : Prop := $typeSyntax))
          let env ← getEnv
          let some (.defnInfo info) := env.find? expectedName
            | throwError "Expected proposition was not elaborated"
          if info.value.getUsedConstants.contains `sorryAx then
            throwError "Expected proposition contains Lean sorryAx recovery"
          let bundle : Bundle := {
            levelParams := info.levelParams.map nameToWire
            type := ← liftResult (exprToWire info.value)
            auxiliary := ← liftResult (auxiliaryFor importOnly env [info.value]) }
          pure (.ok bundle)
        catch ex =>
          if ex.isInterrupt then throw ex
          let diagnostic ← liftIO ex.toMessageData.format
          pure (.error ((diagnostic.pretty.replace "\n" " ").replace "\r" " "))
      match expectedResult with
      | .error diagnostic =>
          liftIO <| IO.println s!"JJ_EXPECTED_ERROR:{nonce}:{diagnostic}"
          liftIO <| IO.println s!"JJ_EXPECTED_FAILED:{nonce}"
          liftIO <| IO.println s!"JJ_PROOF_ERROR:{nonce}:Fixed proposition did not elaborate"
          liftIO <| IO.println s!"JJ_PROOF_FAILED:{nonce}"
      | .ok expectedBundle =>
          setEnv importOnly
          try
            -- Drop the temporary expected-proposition declaration before the
            -- candidate is elaborated. The proof starts from the import-only
            -- environment, just like a standalone jj_export command.
            let typeSyntax ← parseTerm text.getString
            let proofSyntax ← parseTerm proof.getString
            let theoremName := Name.mkSimple candidateName.getString
            let theoremIdent := mkIdent theoremName
            elabCommand (← `(command| theorem $theoremIdent : $typeSyntax := $proofSyntax))
            let env ← getEnv
            let some (.thmInfo info) := env.find? theoremName
              | throwError "Candidate proof was not elaborated"
            let proofBundle : Bundle := {
              levelParams := info.levelParams.map nameToWire
              type := ← liftResult (exprToWire info.type)
              value := some (← liftResult (exprToWire info.value))
              auxiliary := ← liftResult (auxiliaryFor importOnly env [info.type, info.value]) }
            liftIO <| IO.println s!"JJ_PROOF:{nonce}:{(toJson proofBundle).compress}"
            -- This successful marker is deliberately last so diagnostic event
            -- scoping can associate any command diagnostics with this nonce.
            liftIO <| IO.println s!"JJ_EXPECTED:{nonce}:{(toJson expectedBundle).compress}"
          catch ex =>
            if ex.isInterrupt then throw ex
            let diagnostic ← liftIO ex.toMessageData.format
            let diagnostic := (diagnostic.pretty.replace "\n" " ").replace "\r" " "
            liftIO <| IO.println s!"JJ_PROOF_ERROR:{nonce}:{diagnostic}"
            liftIO <| IO.println s!"JJ_PROOF_FAILED:{nonce}"
            liftIO <| IO.println s!"JJ_EXPECTED:{nonce}:{(toJson expectedBundle).compress}"
end Jijian
