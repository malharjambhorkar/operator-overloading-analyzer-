# Operator Overloading Analyzer

This project implements a syntax and semantic analyzer for C++ operator overloading using Flex and Bison. The project now uses string-style operations instead of complex numbers so the analyzer output is easier to explain.

## Features

- Lexical analysis using Flex
- Syntax analysis using Bison
- Semantic checks for duplicate operators and wrong return types
- Supported operators: `+`, `-`, `*`, `/`, `==`, `[]`
- AST-style display for detected operator overloads
- Demonstration output lines for string operators when analyzing `input1.cpp`

## Demo Files

- `input1.cpp`: primary analyzer demo file with intentional semantic errors
- `input.cpp`: secondary analyzer sample with similar string operator error cases

## How to Run

Build the analyzer:

```bash
cd /g/OperatorOverloadingAnalyzer

flex lexer.l
bison -d parser.y
g++ lex.yy.c parser.tab.c symtab.cpp -o analyzer
```

Run the analyzer on `input1.cpp` to show operator detection and semantic errors:

```bash
./analyzer < input1.cpp
```

This is the main file for demonstrating:

- duplicate operator detection
- wrong return type detection
- AST-style operator output
- output-style lines for string operators

You will see output-style lines such as:

```text
Output -> Hello + World = HelloWorld
```

Optional: run the analyzer on the secondary sample file:

```bash
./analyzer < input.cpp
```
