module

public import ProblemSolving.Basic
public import Lean.Elab.Deriving.Basic
import Lean.Elab.Deriving.Util

/-!
This module implements the deriving handler for `ProblemSolving.Input.PSRead`
on simple inductive types. For example, the following code

```
inductive Query : Type where
  | «1» : (Nat × Nat) → Query
  | «2» : Nat → Query
  deriving PSRead
```

gives the following derived instance

```
instance : ProblemSolving.Input.PSRead Query :=
  ⟨Std.Internal.Parsec.String.ws >>= fun _ =>
    (do
      Std.Internal.Parsec.String.skipString "1"
      let data ← (inferInstance : Input.PSRead _).parser
      return Query.«1» data
    ) <|>
    (do
      Std.Internal.Parsec.String.skipString "2"
      let data ← (inferInstance : Input.PSRead _).parser
      return Query.«2» data
    )
  ⟩
```
-/

public section

namespace ProblemSolving.Deriving

open Lean Elab Command
open Lean.Parser.Term

private def mkConstructorParser (ctorName : Name) : CommandElabM Term := do
  let ctorInfo ← getConstInfoCtor ctorName
  unless ctorInfo.numFields == 1 do
    throwError
      "Cannot derive `Input.PSRead` for constructor `{.ofConstName ctorName}`: \
       expected exactly one parameter, but found {ctorInfo.numFields}"
  let tag := ctorName.eraseMacroScopes.getString!
  `(do
      Std.Internal.Parsec.String.skipString $(quote tag)
      let data ← (inferInstance : Input.PSRead _).parser
      return $(mkIdent ctorName) data)

private def mkPSReadInstance (declName : Name) : CommandElabM Unit := do
  let inductiveInfo ← getConstInfoInduct declName
  let ctorParsers ← inductiveInfo.ctors.toArray.mapM mkConstructorParser
  let some firstParser := ctorParsers[0]?
    | throwError
        "Cannot derive `Input.PSRead` for `{.ofConstName declName}`: \
         the type has no constructors"
  let parser ← ctorParsers[1:].foldlM (init := firstParser) fun parser alternative =>
    `($parser <|> $alternative)
  let header ← liftTermElabM <|
    Lean.Elab.Deriving.mkHeader ``Input.PSRead 0 inductiveInfo
  let binders := header.binders
  let targetType := header.targetType
  elabCommand <| ← withFreshMacroScope `(
    instance $binders:bracketedBinder* : Input.PSRead $targetType :=
      ⟨Std.Internal.Parsec.String.ws >>= fun _ => $parser⟩)

private def mkPSReadInstanceHandler (declNames : Array Name) : CommandElabM Bool := do
  unless declNames.size > 0 && (← declNames.allM isInductive) do
    return false
  declNames.forM mkPSReadInstance
  return true

initialize
  registerDerivingHandler ``Input.PSRead mkPSReadInstanceHandler

end ProblemSolving.Deriving
