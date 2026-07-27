import ProblemSolving

/-!
# Mispelling

For each test case, remove the $N$-th (one-based) character from a string $S$.

* Input: the number of test cases $T$ followed by $T$ test cases.
  * Each test case is a single line containing $N$ and $S$ separated by whitespace.
  * $S$ consists of ASCII alphanumeric characters.
  * $1 ≤ N ≤ |S|$; $|S| ≥ 2$.
* Output: The answer for each test case on its own line.
-/

def main := mainWrapper (Σ t : Nat, Vector (Nat × ByteArray) t) fun ⟨_, testcases⟩ => do
  for ⟨index, string⟩ in testcases do
    let left := string.extract 0 (index - 1)
    let right := string.extract index (string.size)
    IO.println s!"{String.fromUTF8! (left.append right)}"
