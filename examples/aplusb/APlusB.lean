import ProblemSolving
import Parser

/-!
# A + B

Read two positive integers and print their sum.

* Input: two positive integers separated by whitespace
* Output: the sum of the two integers
-/

open Parser Char

/-- Parse two natural numbers separated by whitespace. -/
def parseAPlusB : SimpleParser String.Slice Char (Nat × Nat) := do
  let _ ← dropMany ASCII.whitespace
  let a ← ASCII.parseNat
  let _ ← dropMany ASCII.whitespace
  let b ← ASCII.parseNat
  return (a, b)

def main : IO Unit := do
  let stdin ← IO.getStdin
  let input ← stdin.readToEnd
  match parseAPlusB.run input with
  | .ok _ (a, b) => IO.println (a + b)
  | .error _ e => throw <| IO.userError e.toString
