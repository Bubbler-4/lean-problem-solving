import ProblemSolving

/-!
# Hello World

Print `Hello, world!`.

* Input: none
* Output: `Hello, world!`
-/

def main := mainWrapper Unit fun () => do
  IO.println s!"Hello, world!"
