module
public import Std.Internal.Parsec.String

namespace ProblemSolving.Input

open Std.Internal.Parsec (many1Chars satisfy)
open Std.Internal.Parsec.String (Parser Parser.run digits ws)

export Std.Internal.Parsec.String (Parser Parser.run)

/--
A helper class for taking common inputs from stdin.

Basic types such as `Nat` or `String` take one token delimited by whitespace.
`Vector α n` takes `n` items of type `α`.
The types that end with `NL`, namely `StringNL` and `ByteArrayNL`,
take the rest of the current line.

For inputs involving queries of multiple kinds, you can define an inductive type
and derive `PSRead` on it.
-/
public class PSRead (α : Type) where
  parser : Parser α

instance : PSRead Unit :=
  ⟨return ()⟩

instance : PSRead Nat :=
  ⟨do { let _ ← ws; digits }⟩

private def isNotNewline (c : Char) :=
  c != '\n' && c != '\r'
private def isNotWhitespace (c : Char) :=
  c != '\n' && c != '\r' && c != ' ' && c != '\t'

instance : PSRead String :=
  ⟨do { let _ ← ws; many1Chars (satisfy isNotWhitespace) }⟩

instance : PSRead ByteArray :=
  ⟨do { let _ ← ws; let s ← many1Chars (satisfy isNotWhitespace); return s.toUTF8 }⟩

public structure StringNL where
  toString : String

instance : Coe StringNL String where
  coe := StringNL.toString

instance : PSRead StringNL :=
  ⟨do { let _ ← ws; let s ← many1Chars (satisfy isNotNewline); return ⟨s⟩ }⟩

public structure ByteArrayNL where
  toByteArray : ByteArray

instance : Coe ByteArrayNL ByteArray where
  coe := ByteArrayNL.toByteArray

instance : PSRead ByteArrayNL :=
  ⟨do { let _ ← ws; let s ← many1Chars (satisfy isNotNewline); return ⟨s.toUTF8⟩ }⟩

instance {α β : Type} [instα : PSRead α] [instβ : PSRead β] : PSRead (α × β) :=
  ⟨do { let a ← instα.parser; let b ← instβ.parser; return ⟨a, b⟩ }⟩

private def parseVector {α : Type} [instα : PSRead α] (n : Nat) : Parser (Vector α n) :=
  match n with
  | 0 => return #v[]
  | n + 1 => do
    let prevVector ← parseVector n
    let nextElem ← instα.parser
    return (prevVector.push nextElem)

instance {α : Type} [instα : PSRead α] (n : Nat) : PSRead (Vector α n) :=
  ⟨parseVector n⟩

instance {α : Type} {β : α → Type} [instα : PSRead α] [instβ : (a : α) → PSRead (β a)] : PSRead (Σ a : α, β a) :=
  ⟨do { let a ← instα.parser; let b ← (instβ a).parser; return ⟨a, b⟩ }⟩

end ProblemSolving.Input

export ProblemSolving.Input (StringNL ByteArrayNL PSRead)

namespace ProblemSolving.Output

/--
An output helper for sequence types that implement `ForIn`.

The `ToString` instance of `Joiner sep α` gives a string made of elements of `α`
joined by `sep`. Use `joiner sep xs` to construct a joiner with an arbitrary separator;
use `spJoiner xs` or `nlJoiner xs` to separate by spaces or newlines respectively.
-/
public structure Joiner (sep : String) (α : Type) where
  toInner : α

instance {ρ α : Type} [ForIn Id ρ α] [ToString α] {sep : String} : ToString (Joiner sep ρ) :=
  ⟨fun ⟨xs⟩ => String.intercalate sep ((ForIn.toList xs).map ToString.toString) ⟩

public def joiner (sep : String) {ρ : Type} (xs : ρ) : Joiner sep ρ := ⟨xs⟩

public def spJoiner {ρ : Type} (xs : ρ) : Joiner " " ρ := ⟨xs⟩

public def nlJoiner {ρ : Type} (xs : ρ) : Joiner "\n" ρ := ⟨xs⟩

end ProblemSolving.Output

export ProblemSolving.Output (Joiner joiner spJoiner nlJoiner)

/--
A convenience wrapper that should work for most problems.

The type `α` is the type that describes the entirety of the input.
The parsed result is passed to `solve`, in which you can implement the actual logic
that solves the given problem. For example, the following code solves A + B.

```
def main := mainWrapper (Nat × Nat) fun (a, b) => do
  IO.println (a + b)
```
-/
public def mainWrapper (α : Type) [instα : PSRead α] (solve : α → IO Unit) : IO Unit := do
  let stdin ← IO.getStdin
  let inputString ← stdin.readToEnd
  if let Except.ok input := ProblemSolving.Input.Parser.run instα.parser inputString then solve input
