import ProblemSolving

/-!
# Easy Queries

Maintain an array of positive integers while processing updates and point queries.

* Input: the length $N$, the number of queries $Q$, $N$ positive integers, and then $Q$ queries.
  * `1 i x` : Add $x$ to the $i$-th number.
  * `2 i` : Print the $i$-th number.
* Output: the result of every query of type `2`, one per line
-/

inductive Query : Type where
  | «1» : (Nat × Nat) → Query
  | «2» : Nat → Query
  deriving PSRead

def handleQuery (xs : Array Nat) (q : Query) : IO (Array Nat) := do
  match q with
  | Query.«1» ⟨index, amount⟩ => return xs.modify (index - 1) (· + amount)
  | Query.«2» index => IO.println xs[index - 1]!; return xs

def main := mainWrapper (Σ n q : Nat, Vector Nat n × Vector Query q) fun ⟨_n, _q, xs, queries⟩ => do
  let mut xs := xs.toArray
  for q in queries do
    xs ← handleQuery xs q
