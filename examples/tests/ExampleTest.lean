import Lean.Data.Json

open Lean

structure TestCase where
  input : String
  output : String
  deriving FromJson

private def executableName (testName : String) : String :=
  testName.foldl (fun name c =>
    if c.isUpper then
      if name.isEmpty then name.push c.toLower else (name.push '_').push c.toLower
    else
      name.push c) ""

private def loadCases (path : System.FilePath) : IO (Array TestCase) := do
  let contents ← IO.FS.readFile path
  let json ←
    match Json.parse contents with
    | .ok json => pure json
    | .error message => throw <| IO.userError s!"{path}: invalid JSON: {message}"
  match fromJson? json with
  | .ok cases => pure cases
  | .error message => throw <| IO.userError s!"{path}: invalid test cases: {message}"

private def runCase (executable : System.FilePath) (jsonFile : System.FilePath)
    (caseIndex : Nat) (testCase : TestCase) : IO Unit := do
  let some fixtureDirectory := jsonFile.parent
    | throw <| IO.userError s!"could not determine fixture directory for {jsonFile}"
  let inputPath := fixtureDirectory / testCase.input
  let outputPath := fixtureDirectory / testCase.output
  let input ← IO.FS.readFile inputPath
  let expectedOutput ← IO.FS.readFile outputPath
  let result ← IO.Process.output { cmd := executable.toString } input
  if result.exitCode != 0 then
    throw <| IO.userError s!"{jsonFile}, case {caseIndex}: {executable} exited with code \
      {result.exitCode}\nstderr:\n{result.stderr}"
  if result.stdout != expectedOutput then
    throw <| IO.userError s!"{jsonFile}, case {caseIndex}: output mismatch\nexpected:\n\
      {repr expectedOutput}\nactual:\n{repr result.stdout}"

def main : IO Unit := do
  let testDirectory : System.FilePath := "examples/tests"
  let jsonFiles := (← testDirectory.readDir).filter fun entry => entry.path.extension == some "json"
  if jsonFiles.isEmpty then
    throw <| IO.userError s!"no JSON test files found in {testDirectory}"
  let mut summaries : Array (String × Nat) := #[]
  for jsonFile in jsonFiles do
    let some testName := jsonFile.path.fileStem
      | throw <| IO.userError s!"could not determine test name from {jsonFile.path}"
    let executable := ((".lake/build/bin" : System.FilePath) / executableName testName)
      |>.withExtension System.FilePath.exeExtension
    let cases ← loadCases jsonFile.path
    for h : index in [0:cases.size] do
      runCase executable jsonFile.path index cases[index]
    summaries := summaries.push (testName, cases.size)
  for (testName, count) in summaries do
    IO.println s!"{testName}: {count} tests passed"
