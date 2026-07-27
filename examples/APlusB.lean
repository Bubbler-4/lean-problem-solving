import ProblemSolving

/-!
# A + B

Compute the sum of two positive integers.

* Input: two positive integers $A$ and $B$
* Output: the value of $A + B$
-/

def main := mainWrapper (Nat × Nat) fun (a, b) => do
  IO.println (a + b)
