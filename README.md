# Operator Overloading Analyzer (Compiler Design Project)

## 📌 Overview

This project implements a **Syntax and Semantic Analyzer** for C++ operator overloading using **Flex and Bison**.

## ⚙️ Features

* Lexical Analysis using Flex
* Syntax Analysis using Bison
* Semantic Checks:

  * Duplicate operator detection
  * Return type validation
* Supports operators: +, -, *, /, ==, []
* Abstract Syntax Tree (AST) visualization

## 🛠️ Tech Stack

* C++
* Flex (Lex)
* Bison (Yacc)

## ▶️ How to Run

```bash

cd /g/OperatorOverloadingAnalyzer

flex lexer.l
bison -d parser.y
g++ lex.yy.c parser.tab.c symtab.cpp -o analyzer
./analyzer < input.cpp

```

## 🌳 Sample Output

Displays AST structure for operator overloading.

## 👨‍💻 Author

Malhar Jambhorkar
