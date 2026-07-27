import ProblemSolving

/-!
# Sorting

$N$ positive numbers are given. Output them in nondecreasing order.

* Input: The number $N$ followed by $N$ positive integers to be sorted
* Output: $N$ positive integers in nondecreasing order, separated by spaces
-/

def main := mainWrapper (Σ n : Nat, Vector Nat n) fun ⟨n, values⟩ => do
  let sorted := values.toArray.mergeSort
  IO.println (spJoiner sorted)
