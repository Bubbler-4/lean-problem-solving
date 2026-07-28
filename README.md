# Problem Solving utilities for Lean

A few programming contest sites including AtCoder and DMOJ allow submitting solutions in Lean 4.
This library intends to reduce boilerplate when writing submissions in these platforms.

At some point in the future, I'll request the site maintainers to include this library as a dependency
(along with `Batteries` which implements some common data structures).

The library will consist of mainly two parts: I/O and common data structures / algorithms.

## I/O

Input is handled via the `PSRead` typeclass. It is best explained with some examples:

* `PSRead Nat` gives a parser that reads a single number. Similarly, `PSRead String` gives a parser that reads a single token as a `String`.
* `PSRead (α × β)` gives a parser that parses a value of `α` and a value of `β` and returns a pair.
  Longer tuples are automatically supported, as they are nested tuples internally.
* `PSRead (Vector α n)` gives a parser that parses `n` values of `α` and wraps them in a vector.
* `PSRead (Σ n : Nat, Vector α n)` gives a parser that first parses the number `n`, and then parses a vector of length `n`.
* You can structurally combine these to get a matrix, multiple vectors, a jagged array, and so on.

As this is not enough to handle the inputs involving queries, a deriving handler is also provided.

<details>
<summary>How to use <code>deriving PSRead</code> for queries</summary>

For example, if the problem statement looks like

> * `1 i x`: Add `x` to the `i`-th element.
> * `2 i` : Print the `i`-th element.

then you can write the following inductive type:

```
inductive Query : Type where
  | «1» : (Nat × Nat) → Query
  | «2» : Nat → Query
  deriving PSRead
```

and then the `PSRead Query` instance will do the following.

* Read a token.
* If it is `1`, parse two `Nat`s `(a, b)` and return `Query.«1» (a, b)`.
* If it is `2`, parse a `Nat` `a` and return `Query.«2» a`.

The rule is to use the query identifier as the names of the constructors, and have a single field that describes the whole body of each query type.
If a query type does not have a body, it should be specified as `Unit`.

</details>

`mainWrapper` uses the `PSRead` instance to parse the input, and passes the result to the last argument. For example, the entire A + B solution looks like

```
def main := mainWrapper (Nat × Nat) fun (a, b) => do
  IO.println (a + b)
```

An output helper for sequence types `Joiner sep α` is also provided. Its `ToString` instance uses `sep` to join the elements of `α`.
You can use `spJoiner` or `nlJoiner` to separate by spaces or newlines respectively. Use `joiner` to use an arbitrary separator.

## Data structures / algorithms

Coming soon. Features beyond the "AtCoder library" are not planned at the moment.
