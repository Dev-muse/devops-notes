# 🟨 Bash Scripting for DevOps — Complete Beginner's Guide

> **Continued from:** Linux for DevOps. You already know how to navigate the file system, use commands like `grep`, `awk`, `sed`, manage files and permissions, and understand redirection (`>`, `>>`, `|`). This document builds directly on all of that.
>
> **How to use this document:** Read it top-to-bottom once. Every section has a plain-English explanation, the technical detail, real working code you can run immediately, and a "Why DevOps cares" note. Come back to any section whenever you forget something.
>
> **The goal:** By the end of this document you will be able to write real automation scripts from scratch — scripts that handle user input, make decisions, loop over files, define reusable functions, handle errors gracefully, and do work that would take you 30 minutes by hand in under a second.
>
> **Mental model:** A Bash script is just a list of commands you would type in the terminal, saved in a file, so the computer can run them all at once — automatically, reliably, and as many times as you need. That's it. If you can type it in the terminal, you can put it in a script.

---

# 📘 Chapter 1 — Getting Started

## 1.1 What is Bash Scripting?

You already know how to use Bash interactively — you type a command, press Enter, see the result. **Bash scripting** is writing those same commands into a file so they run as a program.

**The progression:**

```
Interactive:   You type 'mkdir logs' and press Enter → folder created
Script:        The script runs 'mkdir logs' automatically → same result
               But now it also creates 10 other folders, sets permissions,
               writes a log entry, and emails you — all in one command.
```

**Why scripting changes everything in DevOps:**

- **Consistency** — a script does the same thing every time. A human makes mistakes.
- **Speed** — a script that deploys an app runs in 10 seconds. A human clicking through menus takes 10 minutes.
- **Repeatability** — run the same deployment on 100 servers with one command.
- **Documentation** — a good script *is* the documentation of how a process works.
- **Automation** — scripts can run on a schedule (cron), triggered by events, or as part of a CI/CD pipeline.

> **The career reality:** The difference between a junior DevOps engineer and a senior one is largely the ability to automate. Automation is Bash scripting. This is one of the highest-leverage skills you can develop.

## 1.2 Setting Up Your Environment

### VS Code Setup

VS Code is the best editor for writing Bash scripts because it has syntax highlighting, extensions, and an integrated terminal.

1. **Install VS Code:** Download from [code.visualstudio.com](https://code.visualstudio.com)
2. **Install the Bash IDE extension:** Open VS Code → Extensions (Ctrl+Shift+X) → search "Bash IDE" by mads-hartmann → Install
3. **Install ShellCheck extension:** Search "ShellCheck" → Install. This extension lints your scripts and catches errors *before* you run them. Invaluable.
4. **Open an integrated terminal:** Ctrl+` (backtick) opens a terminal panel inside VS Code

### Create your first project folder

```bash
mkdir ~/bash-scripts
cd ~/bash-scripts
```

> **Tip:** Keep all your scripts in one place. At the end of this course, push this folder to GitHub. Your Bash scripts will be some of the first real code in your portfolio.

## 1.3 Your First Script — Anatomy of a Bash Script

Create a file called `hello.sh`:

```bash
#!/bin/bash
# My first Bash script
# Author: Your Name
# Date: 2024-01-15
# Description: Prints a greeting and some system info

echo "Hello, World!"
echo "Today is: $(date)"
echo "You are logged in as: $USER"
echo "Your home directory is: $HOME"
```

### The shebang line — `#!/bin/bash`

The **very first line** of every Bash script must be the **shebang** (also called hashbang):

```bash
#!/bin/bash
```

- `#!` — tells the OS "this is a script, use the following program to run it."
- `/bin/bash` — the full path to the Bash interpreter.
- **Without this line:** the OS might use `sh` (a simpler, older shell) or refuse to run the file. Scripts sometimes work without it — but they'll silently fail in subtle ways. **Always include it.**

Other shebangs you'll see:

```bash
#!/bin/sh          # portable sh (more compatible, fewer features)
#!/usr/bin/env bash # finds bash wherever it is (common in portability-focused scripts)
#!/usr/bin/python3 # Python scripts use this
```

### Comments

```bash
# This is a single-line comment — everything after # is ignored

echo "Hello"  # you can also put comments at the end of a line

# Multi-line comment using the : (colon) command:
: '
This entire block is treated as an argument to the no-op command ":"
and is effectively ignored.
Useful for temporarily disabling blocks of code.
'
```

> Comment your scripts generously. When you come back to a script 3 months later — or when a colleague reads it — comments are the difference between understanding it in 30 seconds and spending an hour reverse-engineering it.

## 1.4 Making a Script Executable and Running It

```bash
# Method 1: Make it executable first, then run it directly
chmod +x hello.sh
./hello.sh

# Method 2: Run it with bash explicitly (no chmod needed)
bash hello.sh

# Method 3: Run with sh (uses the sh shell, not bash — avoid this unless you need portability)
sh hello.sh

# What's the difference between ./hello.sh and bash hello.sh?
# ./hello.sh  → uses the shebang line (#!/bin/bash) to decide the interpreter
# bash hello.sh → always uses bash, ignores the shebang
# bash hello.sh → also runs it as a sub-process (can't modify parent shell's variables)
```

> **The `./` prefix:** It means "look in the current directory." Linux does not automatically search the current directory for executables (unlike Windows). If you just type `hello.sh`, the shell looks in `$PATH` directories only. `./hello.sh` explicitly says "the file right here."

### Script permissions best practice

```bash
# Give owner execute permission only (most common for personal scripts)
chmod 700 script.sh    # rwx------   (only you can read, write, execute)

# Give everyone execute permission (for shared scripts)
chmod 755 script.sh    # rwxr-xr-x   (everyone can execute, only you can write)

# Check what you set
ls -la script.sh
```

---

# 📗 Chapter 2 — Variables

## 2.1 What is a Variable?

A **variable** is a **named container that stores a value.** Instead of typing `"Hello, Alice"` every time, you store `"Alice"` in a variable called `name` and write `"Hello, $name"`. If Alice becomes Bob, you change one line.

> **Analogy:** A variable is like a labelled box. You put something in the box, give it a label, and later you can get the value back by asking for "the contents of the box labelled X."

## 2.2 Creating and Using Variables

```bash
#!/bin/bash

# Creating a variable: name="value"
# CRITICAL RULE: NO SPACES around the = sign
name="Alice"          # correct
age=30                # correct
city="London"         # correct

# name = "Alice"      # WRONG — bash interprets 'name' as a command
# name= "Alice"       # WRONG — sets name to empty, then tries to run "Alice" as a command

# Accessing a variable: prefix with $
echo $name            # prints: Alice
echo $age             # prints: 30

# Using ${} — the safer, clearer form
echo ${name}          # same result, but unambiguous
echo "Hello, ${name}! You are ${age} years old."

# Why ${} matters:
files=5
echo "I have $filesGB"       # WRONG: looks for variable 'filesGB' (doesn't exist)
echo "I have ${files}GB"     # CORRECT: clearly $files then literal "GB"
```

### Variable naming rules

```bash
# Valid names:
name="Alice"
first_name="Alice"     # underscores are fine
firstName="Alice"      # camelCase is fine
MY_CONSTANT="value"    # ALL_CAPS is convention for constants
_private="value"       # leading underscore is fine

# Invalid names:
# 1name="Alice"        # cannot start with a number
# my-name="Alice"      # hyphens are not allowed
# my name="Alice"      # spaces are not allowed
```

**Convention for DevOps scripts:**
- **ALL_CAPS** for constants and environment variables: `MAX_RETRIES=3`, `LOG_FILE="/var/log/deploy.log"`
- **lowercase_snake_case** for regular variables: `user_name`, `backup_dir`, `file_count`

## 2.3 Variable Types

Bash doesn't enforce types like Python or Java. Everything is technically a string. But there are patterns for different kinds of data:

### Strings

```bash
greeting="Hello, World"
empty_string=""
path="/home/alice/documents"
multiword="this is one value"    # quotes preserve spaces as part of the value

# String operations
name="Alice"
echo ${#name}           # length of string: 5
echo ${name^^}          # uppercase: ALICE
echo ${name,,}          # lowercase: alice
echo ${name:0:3}        # substring from position 0, length 3: Ali
echo ${name/Alice/Bob}  # replace Alice with Bob: Bob
```

### Numbers (integers)

```bash
count=42
year=2024
negative=-10

# NOTE: Bash stores these as strings internally.
# To do arithmetic, you need $(( )) — covered in Chapter 4.
echo $count             # prints 42 (as a string)
echo $((count + 1))     # prints 43 (arithmetic evaluation)
```

### Arrays

```bash
# Indexed array (like a list)
fruits=("apple" "banana" "orange" "grape")

# Access by index (0-based)
echo ${fruits[0]}       # apple
echo ${fruits[1]}       # banana
echo ${fruits[-1]}      # orange (last element)

# All elements
echo ${fruits[@]}       # apple banana orange grape
echo ${fruits[*]}       # same (subtle differences in quoting behaviour)

# Number of elements
echo ${#fruits[@]}      # 4

# Add an element
fruits+=("mango")
echo ${fruits[@]}       # apple banana orange grape mango

# Loop over array (preview — covered in Chapter 6)
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done

# Slice: elements from index 1, taking 2 elements
echo ${fruits[@]:1:2}   # banana orange
```

### Associative arrays (key-value / dictionary)

```bash
# Must be declared before use
declare -A config

config["host"]="localhost"
config["port"]="5432"
config["database"]="myapp"
config["user"]="admin"

# Access by key
echo ${config["host"]}      # localhost
echo ${config["port"]}      # 5432

# All keys
echo ${!config[@]}          # host port database user

# All values
echo ${config[@]}           # localhost 5432 myapp admin

# Loop over key-value pairs
for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

## 2.4 Variable Scope — Local vs Global

```bash
#!/bin/bash

global_var="I am global"

my_function() {
    local local_var="I am local"        # only visible inside this function
    global_var="I was modified"         # modifies the global variable
    echo "Inside function: $local_var"
    echo "Inside function: $global_var"
}

my_function

echo "Outside function: $global_var"   # "I was modified"
echo "Outside function: $local_var"    # empty — local_var doesn't exist here
```

> **Always use `local` for variables inside functions.** Without `local`, every variable you create inside a function pollutes the global namespace and can overwrite things you didn't intend to.

## 2.5 Special Built-in Variables

These are provided by Bash automatically. You don't set them — you just read them:

| Variable | What it contains | Example |
|---|---|---|
| `$0` | Name of the script itself | `./deploy.sh` |
| `$1`, `$2`... | Positional parameters (command-line arguments) | `$1` = first argument |
| `$@` | All positional parameters as separate words | `"arg1" "arg2" "arg3"` |
| `$*` | All positional parameters as one string | `"arg1 arg2 arg3"` |
| `$#` | Number of arguments passed | `3` |
| `$?` | Exit code of the last command | `0` = success, non-zero = error |
| `$$` | PID (process ID) of the current script | `12345` |
| `$!` | PID of the last background process | `12346` |
| `$_` | Last argument of the previous command | |

```bash
#!/bin/bash
echo "Script name:   $0"
echo "First arg:     $1"
echo "Second arg:    $2"
echo "All args:      $@"
echo "Arg count:     $#"
echo "My PID:        $$"
```

Run it: `./script.sh hello world` → outputs:
```
Script name:   ./script.sh
First arg:     hello
Second arg:    world
All args:      hello world
Arg count:     2
My PID:        5821
```

## 2.6 Command Substitution — Storing Command Output in Variables

```bash
# Capture the output of a command into a variable
current_date=$(date)
current_user=$(whoami)
file_count=$(ls | wc -l)
free_disk=$(df -h / | awk 'NR==2 {print $4}')

echo "Date: $current_date"
echo "User: $current_user"
echo "Files in directory: $file_count"
echo "Free disk space: $free_disk"

# You can use it inline too:
echo "Today is $(date +%A)"         # Today is Tuesday
echo "Uptime: $(uptime -p)"         # Uptime: up 3 days, 4 hours

# Old syntax (backticks) — still works but avoid it:
old_way=`date`      # harder to nest, harder to read
new_way=$(date)     # prefer this
```

> `$(command)` is called **command substitution.** It runs the command in a subshell and replaces itself with the output. It's one of the most powerful patterns in Bash scripting.

## 2.7 Quoting — Single vs Double vs No Quotes

This trips up everyone. Know it cold.

```bash
name="Alice"
greeting="Hello, World"

# Double quotes " " — preserves spaces, EXPANDS variables and $() 
echo "Hello, $name"          # Hello, Alice     (variable expanded)
echo "Today: $(date)"        # Today: Mon Jan 15... (command substituted)
echo "Path: $HOME/docs"      # Path: /home/alice/docs

# Single quotes ' ' — LITERAL. Nothing is expanded. Everything is a string.
echo 'Hello, $name'          # Hello, $name     (NOT expanded)
echo 'Today: $(date)'        # Today: $(date)   (NOT executed)
echo 'Path: $HOME/docs'      # Path: $HOME/docs (literal)

# No quotes — expands variables BUT splits on spaces and does glob expansion
files=*.txt
echo $files                  # expands to all .txt filenames (glob expansion)
echo "$files"                # prints: *.txt (no glob expansion)

message="hello world"
some_command $message        # passes TWO arguments: "hello" and "world"
some_command "$message"      # passes ONE argument: "hello world"
```

**The rule:** Always quote variables unless you specifically want word-splitting or glob expansion. Use `"$variable"` not `$variable`.

```bash
# This is why quoting matters — practical example:
file="my document.txt"

rm $file          # tries to delete "my" and "document.txt" — two args, both fail
rm "$file"        # correctly deletes "my document.txt"
```

---

# 📙 Chapter 3 — User Input and Script Parameters

## 3.1 Reading User Input with `read`

```bash
#!/bin/bash

# Basic read — waits for user to type something and press Enter
echo "What is your name?"
read name
echo "Hello, $name!"

# Inline prompt with -p (much cleaner)
read -p "Enter your username: " username
echo "Username: $username"

# Silent input — hides what the user types (for passwords)
read -sp "Enter password: " password
echo ""    # read -s doesn't add a newline, so we add one
echo "Password stored (not printing it!)"

# Read with a timeout — if user doesn't respond in 5 seconds, continue
read -t 5 -p "Press Enter to continue (5s timeout): " || echo "Timed out."

# Read into an array — splits input into array elements
read -p "Enter fruits separated by spaces: " -a fruit_array
echo "First fruit: ${fruit_array[0]}"
echo "All fruits: ${fruit_array[@]}"

# Read a single character (no Enter needed)
read -n 1 -p "Continue? [y/n]: " answer
echo ""
echo "You chose: $answer"
```

### Reading from a file line by line

```bash
#!/bin/bash
# Read each line of a file into a variable
while IFS= read -r line; do
    echo "Line: $line"
done < /etc/hosts

# IFS= means don't strip leading/trailing whitespace
# -r means don't interpret backslashes
# This is the correct, safe pattern for reading files
```

## 3.2 Command-Line Arguments — Positional Parameters

Scripts become far more powerful when they accept arguments, like how `ls -la /tmp` passes `-la` and `/tmp` to `ls`.

```bash
#!/bin/bash
# Script: greet.sh
# Usage: ./greet.sh Alice 30

name=$1
age=$2

echo "Hello, $name! You are $age years old."
```

```bash
./greet.sh Alice 30
# Output: Hello, Alice! You are 30 years old.
```

### Handling missing arguments

Always check that required arguments were provided:

```bash
#!/bin/bash
# Script: backup.sh
# Usage: ./backup.sh /source/dir /destination/dir

# Check argument count
if [ $# -lt 2 ]; then
    echo "Error: Not enough arguments."
    echo "Usage: $0 <source_directory> <destination_directory>"
    exit 1
fi

source_dir=$1
dest_dir=$2

echo "Backing up: $source_dir → $dest_dir"
```

### Processing all arguments

```bash
#!/bin/bash
# Process every argument passed to the script

echo "Total arguments: $#"
echo "All arguments: $@"
echo ""

# Loop over every argument
for arg in "$@"; do
    echo "Processing: $arg"
done

# Shift removes $1 and moves everything down ($2 becomes $1, etc.)
echo "--- Using shift ---"
while [ $# -gt 0 ]; do
    echo "Current arg: $1"
    shift
done
```

### `$@` vs `$*` — the important difference

```bash
#!/bin/bash
# If called as: ./script.sh "hello world" "foo bar"
# (two arguments, each containing a space)

# $@ preserves argument boundaries — ALWAYS use this
for arg in "$@"; do
    echo "arg: $arg"    # prints "hello world" then "foo bar" (2 iterations)
done

# $* merges all arguments into one string — rarely what you want
for arg in "$*"; do
    echo "arg: $arg"    # prints "hello world foo bar" (1 iteration)
done
```

> **Rule:** Always use `"$@"` when iterating over arguments. It correctly handles arguments with spaces.

## 3.3 Building Scripts with Proper Usage Messages

Professional scripts always tell you how to use them:

```bash
#!/bin/bash
# Script: deploy.sh
# A realistic example of argument handling

usage() {
    echo "Usage: $0 [OPTIONS] <environment>"
    echo ""
    echo "Deploy the application to a specified environment."
    echo ""
    echo "Arguments:"
    echo "  environment    Target environment: dev, staging, or prod"
    echo ""
    echo "Options:"
    echo "  -v             Verbose mode"
    echo "  -d             Dry run (don't actually deploy)"
    echo "  -h             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev"
    echo "  $0 -v staging"
    echo "  $0 -d prod"
    exit 1
}

# Check if no arguments given
if [ $# -eq 0 ]; then
    usage
fi

# Parse options with getopts
verbose=false
dry_run=false

while getopts "vdh" opt; do
    case $opt in
        v) verbose=true ;;
        d) dry_run=true ;;
        h) usage ;;
        ?) echo "Invalid option: -$OPTARG"; usage ;;
    esac
done

# Shift past the options to get positional args
shift $((OPTIND - 1))

environment=$1

if [ -z "$environment" ]; then
    echo "Error: environment argument required"
    usage
fi

# Validate the environment value
case $environment in
    dev|staging|prod) ;;    # valid — do nothing
    *)
        echo "Error: Invalid environment '$environment'"
        echo "Must be one of: dev, staging, prod"
        exit 1
        ;;
esac

echo "Deploying to: $environment"
[ "$verbose" = true ] && echo "Verbose mode enabled"
[ "$dry_run" = true ] && echo "DRY RUN — no changes will be made"
```

---

# 📕 Chapter 4 — Arithmetic

## 4.1 Integer Arithmetic with `$(( ))`

```bash
#!/bin/bash

# Basic arithmetic — all done inside $(( ))
echo $((5 + 3))         # 8
echo $((10 - 4))        # 6
echo $((6 * 7))         # 42
echo $((17 / 5))        # 3  (integer division — truncates)
echo $((17 % 5))        # 2  (remainder / modulo)
echo $((2 ** 8))        # 256 (exponentiation)

# Using variables
a=10
b=3
echo $((a + b))         # 13
echo $((a * b))         # 30
echo $((a / b))         # 3
echo $((a % b))         # 1

# Store result in a variable
result=$((a * b + 5))
echo "Result: $result"   # Result: 35

# Increment and decrement
count=0
((count++))             # increment by 1 → count is now 1
((count++))             # count is now 2
((count--))             # decrement by 1 → count is now 1
((count += 5))          # add 5 → count is now 6
((count *= 2))          # multiply by 2 → count is now 12
echo "Count: $count"    # Count: 12
```

### All arithmetic operators

| Operator | Meaning | Example | Result |
|---|---|---|---|
| `+` | Addition | `$((5 + 3))` | 8 |
| `-` | Subtraction | `$((10 - 4))` | 6 |
| `*` | Multiplication | `$((6 * 7))` | 42 |
| `/` | Division (integer) | `$((17 / 5))` | 3 |
| `%` | Modulo (remainder) | `$((17 % 5))` | 2 |
| `**` | Exponentiation | `$((2 ** 8))` | 256 |
| `++` | Increment | `((count++))` | count += 1 |
| `--` | Decrement | `((count--))` | count -= 1 |
| `+=` | Add and assign | `((x += 5))` | x = x + 5 |
| `-=` | Subtract and assign | `((x -= 3))` | x = x - 3 |
| `*=` | Multiply and assign | `((x *= 2))` | x = x * 2 |
| `/=` | Divide and assign | `((x /= 4))` | x = x / 4 |

## 4.2 Floating-Point Arithmetic with `bc`

Bash's `$(( ))` only handles integers. For decimal maths, use `bc`:

```bash
#!/bin/bash

# bc — the basic calculator
echo "scale=2; 10 / 3" | bc        # 3.33  (scale=2 means 2 decimal places)
echo "scale=4; 22 / 7" | bc        # 3.1428 (pi approximation)

# Store results
result=$(echo "scale=2; 1.5 * 2.3" | bc)
echo "1.5 × 2.3 = $result"         # 1.5 × 2.3 = 3.45

# Square root
echo "scale=4; sqrt(2)" | bc       # 1.4142

# Use variables
price=19.99
quantity=5
total=$(echo "scale=2; $price * $quantity" | bc)
echo "Total: £$total"              # Total: £99.95

# Practical: calculate percentage
used=75
total=100
percent=$(echo "scale=1; $used / $total * 100" | bc)
echo "Used: ${percent}%"           # Used: 75.0%
```

## 4.3 Practical Arithmetic Examples

```bash
#!/bin/bash
# Script: disk_alert.sh
# Alert if disk usage exceeds a threshold

THRESHOLD=80

# Get disk usage as a number (the % used for /)
usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

echo "Disk usage: ${usage}%"

if [ $usage -gt $THRESHOLD ]; then
    echo "ALERT: Disk usage is ${usage}% — above threshold of ${THRESHOLD}%"
else
    remaining=$((100 - usage))
    echo "OK: ${remaining}% disk space remaining"
fi
```

```bash
#!/bin/bash
# Script: calculator.sh

read -p "Enter first number: " num1
read -p "Enter second number: " num2
read -p "Enter operation (+, -, *, /): " op

case $op in
    +) result=$((num1 + num2)) ;;
    -) result=$((num1 - num2)) ;;
    \*) result=$((num1 * num2)) ;;  # * must be escaped in case
    /)
        if [ $num2 -eq 0 ]; then
            echo "Error: Cannot divide by zero"
            exit 1
        fi
        result=$(echo "scale=4; $num1 / $num2" | bc)
        ;;
    *)
        echo "Unknown operation: $op"
        exit 1
        ;;
esac

echo "$num1 $op $num2 = $result"
```

---

# 📒 Chapter 5 — Conditionals

## 5.1 The `if` Statement

```bash
#!/bin/bash

# Basic if
if [ condition ]; then
    # commands run when condition is TRUE
fi

# if-else
if [ condition ]; then
    echo "condition is true"
else
    echo "condition is false"
fi

# if-elif-else (multiple conditions)
if [ condition1 ]; then
    echo "condition1 is true"
elif [ condition2 ]; then
    echo "condition2 is true"
elif [ condition3 ]; then
    echo "condition3 is true"
else
    echo "none of the above"
fi
```

### `[ ]` vs `[[ ]]` — which to use

```bash
# Single brackets [ ] — POSIX compatible, works in sh
# Double brackets [[ ]] — Bash-specific, more powerful, fewer surprises

# Use [[ ]] for most things in Bash scripts — it's safer:
[[ $name == "Alice" ]]   # works as expected
[ $name == "Alice" ]     # can fail if $name is empty (unquoted variable)

# [[ ]] supports:
# - Pattern matching:  [[ $file == *.txt ]]
# - Regex matching:    [[ $email =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]]
# - && and || inside:  [[ $a == 1 && $b == 2 ]]

# [ ] requires:
# - -a and -o for and/or (deprecated, use && || outside brackets)
# - All variables quoted to avoid word-splitting issues
```

> **Rule for beginners:** Use `[[ ]]` for string and pattern comparisons. Use `[ ]` for numeric comparisons and file tests (both work, but `[ ]` is traditional for these).

## 5.2 Comparison Operators

### Numeric comparisons

```bash
a=10
b=20

if [ $a -eq $b ]; then echo "equal"; fi          # equal
if [ $a -ne $b ]; then echo "not equal"; fi      # not equal
if [ $a -lt $b ]; then echo "less than"; fi      # less than
if [ $a -gt $b ]; then echo "greater than"; fi   # greater than
if [ $a -le $b ]; then echo "less or equal"; fi  # ≤
if [ $a -ge $b ]; then echo "greater or equal"; fi # ≥
```

| Operator | Meaning | Example |
|---|---|---|
| `-eq` | Equal | `[ $a -eq $b ]` |
| `-ne` | Not equal | `[ $a -ne $b ]` |
| `-lt` | Less than | `[ $a -lt $b ]` |
| `-gt` | Greater than | `[ $a -gt $b ]` |
| `-le` | Less than or equal | `[ $a -le $b ]` |
| `-ge` | Greater than or equal | `[ $a -ge $b ]` |

> **Why `-eq` instead of `==` for numbers?** In Bash, `==` inside `[ ]` is a *string* comparison. `"10" == "10"` is true but `"10" == "010"` is false (different strings). `-eq` is a *numeric* comparison: `10 -eq 010` is true because both equal 10 mathematically.

### String comparisons

```bash
name="Alice"
other="Bob"

if [[ $name == "Alice" ]]; then echo "It's Alice"; fi
if [[ $name != "Bob" ]]; then echo "Not Bob"; fi
if [[ -z "$empty_var" ]]; then echo "Variable is empty"; fi
if [[ -n "$name" ]]; then echo "Variable is not empty"; fi

# Pattern matching with [[ ]]
filename="report_2024.txt"
if [[ $filename == *.txt ]]; then
    echo "It's a text file"
fi

if [[ $filename == report_* ]]; then
    echo "It's a report"
fi

# Regex matching with =~
email="alice@example.com"
if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Valid email format"
fi
```

| Operator | Meaning |
|---|---|
| `==` | String equal (use inside `[[ ]]`) |
| `!=` | String not equal |
| `<` | Alphabetically less than (inside `[[ ]]`) |
| `>` | Alphabetically greater than (inside `[[ ]]`) |
| `-z` | String is empty (zero length) |
| `-n` | String is not empty |

### File tests

```bash
file="/etc/passwd"
dir="/home/alice"

if [ -f "$file" ]; then echo "$file exists and is a regular file"; fi
if [ -d "$dir" ]; then echo "$dir exists and is a directory"; fi
if [ -e "$file" ]; then echo "$file exists (any type)"; fi
if [ -r "$file" ]; then echo "$file is readable"; fi
if [ -w "$file" ]; then echo "$file is writable"; fi
if [ -x "$file" ]; then echo "$file is executable"; fi
if [ -s "$file" ]; then echo "$file is not empty (has content)"; fi
if [ -L "$file" ]; then echo "$file is a symbolic link"; fi

# Combine: check if file exists AND is readable
if [ -f "$file" ] && [ -r "$file" ]; then
    echo "File exists and is readable"
fi
```

| Test | Meaning |
|---|---|
| `-f file` | Exists and is a regular file |
| `-d dir` | Exists and is a directory |
| `-e path` | Exists (any type) |
| `-r file` | Is readable |
| `-w file` | Is writable |
| `-x file` | Is executable |
| `-s file` | Exists and is not empty |
| `-L file` | Is a symbolic link |
| `-b file` | Is a block device |
| `f1 -nt f2` | f1 is newer than f2 |
| `f1 -ot f2` | f1 is older than f2 |

## 5.3 Logical Operators — Combining Conditions

```bash
#!/bin/bash

age=25
name="Alice"
file="/etc/passwd"

# AND: both conditions must be true
if [ $age -ge 18 ] && [ $age -le 65 ]; then
    echo "Working age"
fi

# Inside [[ ]] you can use && directly:
if [[ $age -ge 18 && $age -le 65 ]]; then
    echo "Working age (cleaner syntax)"
fi

# OR: at least one condition must be true
if [ "$name" == "Alice" ] || [ "$name" == "Bob" ]; then
    echo "It's Alice or Bob"
fi

# NOT: invert a condition
if ! [ -f "$file" ]; then
    echo "$file does not exist"
fi

# Chaining on the command line (not inside if):
mkdir logs && echo "logs created"          # run second command only if first succeeds
cd /nonexistent || echo "directory not found"   # run second command only if first fails
```

## 5.4 The `case` Statement — Cleaner Multi-Branch Logic

When you have many `elif` branches comparing one variable to different values, `case` is far cleaner:

```bash
#!/bin/bash

read -p "Enter day of week: " day

case $day in
    Monday|Tuesday|Wednesday|Thursday|Friday)
        echo "Weekday — work day"
        ;;
    Saturday|Sunday)
        echo "Weekend — rest day"
        ;;
    *)
        echo "Unknown day: $day"
        ;;
esac
```

```bash
#!/bin/bash
# case for script options / menu selection

read -p "Choose option [1-4]: " choice

case $choice in
    1)
        echo "Option 1: Create backup"
        ;;
    2)
        echo "Option 2: Restore backup"
        ;;
    3)
        echo "Option 3: View logs"
        ;;
    4)
        echo "Option 4: Exit"
        exit 0
        ;;
    *)
        echo "Invalid option: $choice"
        exit 1
        ;;
esac
```

**`case` syntax rules:**
- Each pattern ends with `)`.
- Commands for that pattern end with `;;`.
- `|` separates multiple patterns for the same block.
- `*` is the catch-all / default (like `else`).
- `esac` ends the block (it's `case` spelled backwards).

## 5.5 Nested Conditions

```bash
#!/bin/bash
# Real example: deploying to different environments with validation

environment=$1
confirm=$2

if [ -z "$environment" ]; then
    echo "Error: No environment specified"
    exit 1
else
    if [[ "$environment" == "prod" ]]; then
        if [[ "$confirm" != "--yes-i-am-sure" ]]; then
            echo "ERROR: Deploying to production requires --yes-i-am-sure flag"
            echo "Usage: $0 prod --yes-i-am-sure"
            exit 1
        else
            echo "Confirmed — deploying to PRODUCTION"
        fi
    elif [[ "$environment" == "staging" || "$environment" == "dev" ]]; then
        echo "Deploying to $environment"
    else
        echo "Unknown environment: $environment"
        exit 1
    fi
fi
```

---

# 📓 Chapter 6 — Loops

## 6.1 The `for` Loop

### Looping over a list of values

```bash
#!/bin/bash

# Loop over a literal list
for colour in red green blue yellow; do
    echo "Colour: $colour"
done

# Loop over an array
servers=("web01" "web02" "db01" "cache01")
for server in "${servers[@]}"; do
    echo "Checking server: $server"
    # ping -c 1 "$server" > /dev/null && echo "$server: UP" || echo "$server: DOWN"
done

# Loop over files matching a pattern
for file in /var/log/*.log; do
    echo "Processing: $file"
    wc -l "$file"
done

# Loop over command output
for user in $(cat /etc/passwd | cut -d: -f1); do
    echo "User: $user"
done
```

### Looping with a range

```bash
#!/bin/bash

# Range with {start..end}
for i in {1..5}; do
    echo "Iteration: $i"
done

# Range with a step {start..end..step}
for i in {0..20..5}; do
    echo "i = $i"    # 0, 5, 10, 15, 20
done

# C-style for loop — most like other programming languages
for ((i=1; i<=5; i++)); do
    echo "Count: $i"
done

# C-style with step
for ((i=0; i<=100; i+=10)); do
    echo "$i%"
done

# Countdown
for ((i=10; i>=1; i--)); do
    echo -n "$i... "
done
echo "Go!"
```

### Practical `for` loop examples

```bash
#!/bin/bash
# Create a directory structure for a new project

project_name=$1
dirs=("src" "tests" "docs" "scripts" "config" "logs")

mkdir -p "$project_name"
for dir in "${dirs[@]}"; do
    mkdir -p "$project_name/$dir"
    echo "Created: $project_name/$dir"
done

touch "$project_name/README.md"
echo "Project '$project_name' created successfully"
```

```bash
#!/bin/bash
# Rename all .txt files to .bak

for file in *.txt; do
    if [ -f "$file" ]; then
        new_name="${file%.txt}.bak"   # ${var%suffix} removes suffix
        mv "$file" "$new_name"
        echo "Renamed: $file → $new_name"
    fi
done
```

## 6.2 The `while` Loop

A `while` loop runs **as long as its condition is true.** Use it when you don't know in advance how many iterations you need.

```bash
#!/bin/bash

# Basic while loop
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done

# while loop reading user input until satisfied
while true; do
    read -p "Enter a number (0 to quit): " num
    if [ "$num" -eq 0 ]; then
        echo "Goodbye!"
        break
    fi
    echo "You entered: $num. Square: $((num * num))"
done

# while loop with a condition that will eventually become false
attempts=0
max_attempts=5

while [ $attempts -lt $max_attempts ]; do
    ((attempts++))
    echo "Attempt $attempts of $max_attempts"
    # In a real script, you'd try something here (e.g. ping a server)
    # and break out of the loop when it succeeds
done
```

### Interactive menus with `while`

```bash
#!/bin/bash
# A menu that keeps running until the user exits

show_menu() {
    echo ""
    echo "=== System Admin Menu ==="
    echo "1) Show disk usage"
    echo "2) Show memory usage"
    echo "3) Show running processes"
    echo "4) Show current users"
    echo "5) Exit"
    echo "========================="
}

while true; do
    show_menu
    read -p "Choose option [1-5]: " choice

    case $choice in
        1) df -h ;;
        2) free -h ;;
        3) ps aux | head -20 ;;
        4) who ;;
        5)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac
done
```

### Waiting for a service with `while`

```bash
#!/bin/bash
# Wait until a service is ready (e.g. after starting a database)

host="localhost"
port=5432
max_wait=60
waited=0

echo "Waiting for PostgreSQL at $host:$port..."

while ! nc -z "$host" "$port" 2>/dev/null; do
    if [ $waited -ge $max_wait ]; then
        echo "ERROR: Service not available after ${max_wait}s"
        exit 1
    fi
    echo "Still waiting... (${waited}s)"
    sleep 2
    ((waited += 2))
done

echo "PostgreSQL is ready! (waited ${waited}s)"
```

## 6.3 The `until` Loop

`until` is the opposite of `while` — it runs **until** its condition becomes true (i.e., while it's false):

```bash
#!/bin/bash

count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    ((count++))
done
# Exactly the same result as while [ $count -le 5 ]
# Use whichever reads more naturally for your use case
```

## 6.4 Loop Control — `break` and `continue`

```bash
#!/bin/bash

# break — exit the loop immediately
echo "--- break example ---"
for i in {1..10}; do
    if [ $i -eq 6 ]; then
        echo "Breaking at $i"
        break
    fi
    echo "i = $i"
done
# Prints 1 2 3 4 5, then breaks

# continue — skip the rest of this iteration, go to the next
echo "--- continue example ---"
for i in {1..10}; do
    if [ $((i % 2)) -eq 0 ]; then
        continue    # skip even numbers
    fi
    echo "i = $i"
done
# Prints 1 3 5 7 9 (odd numbers only)

# break with a level number (nested loops)
echo "--- break from nested loop ---"
for i in {1..3}; do
    for j in {1..3}; do
        if [ $j -eq 2 ]; then
            break 2    # break out of BOTH loops (2 levels up)
        fi
        echo "i=$i j=$j"
    done
done
```

## 6.5 Processing Files and Directories with Loops

```bash
#!/bin/bash
# Real-world: process all log files in a directory

log_dir="/var/log"
error_count=0

for log_file in "$log_dir"/*.log; do
    [ -f "$log_file" ] || continue    # skip if not a regular file (e.g. if no .log files)

    count=$(grep -c "ERROR" "$log_file" 2>/dev/null || echo 0)
    if [ "$count" -gt 0 ]; then
        echo "$log_file: $count errors"
        ((error_count += count))
    fi
done

echo "Total errors across all logs: $error_count"
```

```bash
#!/bin/bash
# Bulk file operations

# Compress all log files older than 7 days
find /var/log -name "*.log" -mtime +7 | while read -r file; do
    echo "Compressing: $file"
    gzip "$file"
done

# Process CSV: read each line, extract fields
while IFS=',' read -r name email department; do
    echo "Name: $name | Email: $email | Dept: $department"
done < employees.csv
```

---

# 📃 Chapter 7 — Functions

## 7.1 What is a Function?

A **function** is a named block of reusable code. Instead of copying the same 10 lines of code into 5 different places in your script, you write the function once and call it 5 times.

> **Analogy:** A function is like a recipe. You write the recipe once. Every time you want that dish, you follow the recipe — you don't rewrite it. If you want to change the recipe, you change it in one place and all future meals use the improved version.

## 7.2 Defining and Calling Functions

```bash
#!/bin/bash

# Define a function — either syntax works:
greet() {
    echo "Hello, World!"
}

function say_goodbye {
    echo "Goodbye, World!"
}

# Call the function (just use its name)
greet
say_goodbye

# CRITICAL: Define functions BEFORE you call them
# Bash reads top-to-bottom. If you call a function before its definition, it fails.
```

**Convention:** Define all functions near the top of the script, after the shebang and variable setup. Call them at the bottom in a `main` function (good practice for large scripts).

## 7.3 Function Parameters

Functions receive arguments exactly like scripts receive arguments — via `$1`, `$2`, etc.:

```bash
#!/bin/bash

# Function with parameters
greet_user() {
    local name=$1
    local greeting=${2:-"Hello"}    # default value if $2 not provided

    echo "$greeting, $name!"
}

# Call with arguments
greet_user "Alice"              # Hello, Alice!
greet_user "Bob" "Good morning" # Good morning, Bob!
greet_user "Carol" "Hi"         # Hi, Carol!
```

> **Important:** Inside a function, `$1` refers to the function's first argument, NOT the script's first argument. They are completely separate. The script's `$1` is not visible inside the function as `$1` (though you can pass it in: `my_function "$1"`).

```bash
#!/bin/bash

# More realistic example
create_user() {
    local username=$1
    local home_dir=${2:-"/home/$username"}
    local shell=${3:-"/bin/bash"}

    if [ -z "$username" ]; then
        echo "Error: username required"
        return 1    # return from function with error code
    fi

    echo "Creating user: $username"
    echo "  Home: $home_dir"
    echo "  Shell: $shell"
    # sudo useradd -m -d "$home_dir" -s "$shell" "$username"
}

create_user "alice"
create_user "bob" "/var/bob" "/bin/zsh"
create_user               # will trigger the error
```

## 7.4 Return Values and Exit Codes

Bash functions don't return values the way other languages do. They return **exit codes** (integers 0–255):

- `return 0` — success (by convention)
- `return 1` — general error
- `return 2` — misuse / bad argument
- Any non-zero — failure

To "return" actual data, either:
1. Print it with `echo` and capture with `$(function_name)`, or
2. Store it in a global variable (with a known name), or
3. Use a nameref variable (advanced).

```bash
#!/bin/bash

# Pattern 1: Return an exit code, check with $?
file_exists() {
    local file=$1
    if [ -f "$file" ]; then
        return 0    # success — file exists
    else
        return 1    # failure — file does not exist
    fi
}

file_exists "/etc/passwd"
if [ $? -eq 0 ]; then
    echo "File exists"
else
    echo "File not found"
fi

# Shorter — use the function directly as a condition:
if file_exists "/etc/hostname"; then
    echo "hostname file found"
fi

# Pattern 2: Echo a value, capture with $()
get_timestamp() {
    echo $(date +"%Y-%m-%d_%H-%M-%S")
}

timestamp=$(get_timestamp)
echo "Timestamp: $timestamp"    # Timestamp: 2024-01-15_14-30-00

# Pattern 3: Return multiple values via a global variable
get_disk_info() {
    DISK_USED=$(df / | awk 'NR==2 {print $3}')
    DISK_FREE=$(df / | awk 'NR==2 {print $4}')
    DISK_PERCENT=$(df / | awk 'NR==2 {print $5}')
}

get_disk_info
echo "Used: $DISK_USED | Free: $DISK_FREE | Percent: $DISK_PERCENT"
```

## 7.5 Local Variables — Always Use Them

```bash
#!/bin/bash

# WITHOUT local — dangerous
bad_function() {
    count=10          # This modifies the GLOBAL count
    echo "Inside function: count = $count"
}

count=0
echo "Before function: count = $count"   # 0
bad_function
echo "After function: count = $count"    # 10 — surprise!

# WITH local — safe
good_function() {
    local count=10    # This is a local copy — doesn't touch global count
    echo "Inside function: count = $count"
}

count=0
echo "Before function: count = $count"   # 0
good_function
echo "After function: count = $count"    # 0 — unchanged
```

## 7.6 Building a Function Library

For large projects, keep reusable functions in a separate file and `source` it:

```bash
# File: lib/utils.sh

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO]  $*"
}

log_warn() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN]  $*" >&2
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2
}

confirm() {
    local prompt=${1:-"Continue?"}
    read -p "$prompt [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

is_root() {
    [ "$EUID" -eq 0 ]
}

require_root() {
    if ! is_root; then
        log_error "This script must be run as root"
        exit 1
    fi
}

file_backup() {
    local file=$1
    local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$file" "$backup"
    log_info "Backed up $file to $backup"
}
```

```bash
# File: deploy.sh — uses the library

#!/bin/bash
source ./lib/utils.sh    # load all functions from utils.sh

require_root

log_info "Starting deployment"

if confirm "Deploy to production?"; then
    log_info "Deployment confirmed"
    # ... deploy code here
else
    log_warn "Deployment cancelled by user"
    exit 0
fi
```

## 7.7 Recursive Functions

Functions can call themselves — this is recursion. Use carefully (easy to create infinite loops):

```bash
#!/bin/bash

# Factorial: n! = n × (n-1) × ... × 1
factorial() {
    local n=$1
    if [ $n -le 1 ]; then
        echo 1
    else
        local sub=$(factorial $((n - 1)))
        echo $((n * sub))
    fi
}

echo "5! = $(factorial 5)"    # 5! = 120
echo "10! = $(factorial 10)"  # 10! = 3628800
```

---

# 📋 Chapter 8 — Error Handling

## 8.1 Exit Codes — The Foundation of Error Handling

Every command in Linux returns an **exit code** when it finishes:

- `0` = **success**
- `1–255` = **failure** (the specific number indicates the type of error)

This is universal — every command, every script, every function.

```bash
#!/bin/bash

# $? holds the exit code of the LAST command
ls /tmp
echo "Exit code: $?"     # 0 (success)

ls /nonexistent_dir
echo "Exit code: $?"     # 2 (file not found)

grep "pattern" /etc/passwd
echo "Exit code: $?"     # 0 (found match)

grep "zzz_no_match" /etc/passwd
echo "Exit code: $?"     # 1 (no match found)

# Check exit code immediately after the command — it changes after each command
cat /etc/passwd > /dev/null
result=$?    # save it if you need to check later
echo "Result: $result"
```

### Conventional exit codes

| Code | Meaning |
|---|---|
| `0` | Success |
| `1` | General error |
| `2` | Misuse of shell built-in / bad argument |
| `126` | Command found but not executable |
| `127` | Command not found |
| `128+n` | Script terminated by signal n (e.g. 130 = Ctrl+C) |

```bash
#!/bin/bash
# Every script should exit with a meaningful code
# Exit 0 at the end if everything worked
# Exit non-zero if something failed — so calling scripts know

main() {
    if ! do_something; then
        echo "do_something failed"
        exit 1
    fi
    echo "All done"
    exit 0
}
```

## 8.2 `set` Options — Making Scripts Fail Safely

By default, Bash ignores errors and keeps running. This is dangerous — a half-complete deployment that silently failed halfway is worse than one that stopped immediately.

```bash
#!/bin/bash
set -e          # Exit immediately if any command returns non-zero
set -u          # Treat unset variables as errors (exit if used)
set -o pipefail # If any command in a pipeline fails, the pipeline fails

# These three are almost always combined:
set -euo pipefail

# Or equivalently:
set -e
set -u
set -o pipefail
```

### What each option does — with examples

```bash
#!/bin/bash
set -e

# Without set -e:
rm /nonexistent_file    # fails silently
echo "This runs anyway" # continues — dangerous

# With set -e:
rm /nonexistent_file    # fails
echo "This NEVER runs"  # script exits immediately after the failure
```

```bash
#!/bin/bash
set -u

# Without set -u:
echo $UNDEFINED_VAR     # prints empty string — silently

# With set -u:
echo $UNDEFINED_VAR     # error: UNDEFINED_VAR: unbound variable → script exits
```

```bash
#!/bin/bash
set -o pipefail

# Without pipefail:
cat /nonexistent | sort    # cat fails with code 1, but sort succeeds with code 0
echo $?                    # 0 — the pipeline "succeeded" (misleading!)

# With pipefail:
cat /nonexistent | sort    # cat fails
echo $?                    # 1 — correctly reports failure
```

### The `set -x` debug flag

```bash
#!/bin/bash
set -x    # Print each command before executing it (prefixed with +)

name="Alice"
echo "Hello, $name"
ls /tmp

set +x    # Turn off debug output

echo "Debugging is off now"
```

Output with `set -x`:
```
+ name=Alice
+ echo 'Hello, Alice'
Hello, Alice
+ ls /tmp
file1.txt script.sh
+ set +x
Debugging is off now
```

> `set -x` is your first debugging tool. When a script misbehaves, add `set -x` at the top and you'll see exactly what's happening, line by line.

### Combining flags

```bash
#!/bin/bash
set -euxo pipefail
# e = exit on error
# u = exit on undefined variable
# x = print commands (good for debugging — remove before production)
# o pipefail = fail on pipe errors

# For production scripts:
set -euo pipefail

# For debugging:
set -euxo pipefail
```

## 8.3 `trap` — Running Cleanup on Exit or Error

`trap` lets you register commands that run when specific events happen — like when the script exits, or when it receives a signal (like Ctrl+C).

```bash
#!/bin/bash
set -euo pipefail

# Create a temp file
temp_file=$(mktemp)

# Register cleanup: run this function when the script exits (for ANY reason)
cleanup() {
    echo "Cleaning up..."
    rm -f "$temp_file"
    echo "Temp file removed"
}
trap cleanup EXIT    # EXIT fires on normal exit AND on errors

# Your script work
echo "Working with temp file: $temp_file"
echo "some data" > "$temp_file"
cat "$temp_file"

# Whether the script succeeds, fails, or is interrupted, cleanup() always runs
echo "Script complete"
```

```bash
#!/bin/bash

# Multiple signals
handle_interrupt() {
    echo ""
    echo "Script interrupted by user (Ctrl+C)"
    exit 130
}

handle_error() {
    echo "ERROR: Script failed on line $LINENO"
    echo "Command: $BASH_COMMAND"
    exit 1
}

trap handle_interrupt INT    # Ctrl+C
trap handle_error ERR        # any command that fails (with set -e)
trap cleanup EXIT            # always, on any exit

# Common signals:
# EXIT   — script exits (any reason)
# ERR    — a command fails (needs set -e to be reliable)
# INT    — Ctrl+C (SIGINT)
# TERM   — kill signal (SIGTERM)
# HUP    — terminal closed (SIGHUP)
```

## 8.4 Handling Errors Explicitly

Don't just rely on `set -e`. Write explicit error checks for important operations:

```bash
#!/bin/bash
set -euo pipefail

# Pattern 1: Check exit code with if
if ! cp source.txt destination.txt; then
    echo "Error: Failed to copy file"
    exit 1
fi

# Pattern 2: || (or) to handle failure inline
mkdir -p /tmp/mydir || { echo "Failed to create directory"; exit 1; }

# Pattern 3: Custom error function
die() {
    local message=$1
    local exit_code=${2:-1}
    echo "ERROR: $message" >&2    # write to stderr, not stdout
    exit $exit_code
}

[ -f config.txt ] || die "config.txt not found" 2

# Pattern 4: Retry logic
run_with_retry() {
    local max_attempts=$1
    local delay=$2
    shift 2
    local cmd=("$@")
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt/$max_attempts: ${cmd[*]}"
        if "${cmd[@]}"; then
            return 0
        fi
        echo "Attempt $attempt failed. Retrying in ${delay}s..."
        sleep $delay
        ((attempt++))
    done

    echo "All $max_attempts attempts failed"
    return 1
}

# Usage: retry 3 times with 5s delay
run_with_retry 3 5 curl -f https://example.com/api/health
```

## 8.5 Input Validation

Never trust input. Always validate before using it:

```bash
#!/bin/bash

validate_number() {
    local input=$1
    local name=${2:-"Input"}

    if [[ -z "$input" ]]; then
        echo "Error: $name cannot be empty"
        return 1
    fi

    if ! [[ "$input" =~ ^-?[0-9]+$ ]]; then
        echo "Error: $name must be an integer (got: '$input')"
        return 1
    fi

    return 0
}

validate_positive_number() {
    local input=$1
    local name=${2:-"Input"}

    validate_number "$input" "$name" || return 1

    if [ "$input" -le 0 ]; then
        echo "Error: $name must be a positive number (got: $input)"
        return 1
    fi

    return 0
}

validate_file() {
    local file=$1
    if [[ -z "$file" ]]; then
        echo "Error: filename cannot be empty"
        return 1
    fi
    if [[ ! -f "$file" ]]; then
        echo "Error: file not found: $file"
        return 1
    fi
    if [[ ! -r "$file" ]]; then
        echo "Error: file not readable: $file"
        return 1
    fi
    return 0
}

# Usage
read -p "Enter your age: " age
if validate_positive_number "$age" "Age"; then
    echo "Age is valid: $age"
fi

read -p "Enter filename: " filename
if validate_file "$filename"; then
    cat "$filename"
fi
```

---

# 📑 Chapter 9 — Environment Variables and Shell Config

## 9.1 Environment Variables in Scripts

You already know environment variables from the Linux module. In scripts, you use them the same way — and also create your own:

```bash
#!/bin/bash

# Reading built-in env variables
echo "Running as user: $USER"
echo "Home directory: $HOME"
echo "Current shell: $SHELL"
echo "Search path: $PATH"
echo "Hostname: $HOSTNAME"

# Creating your own for the script
export APP_ENV="production"
export DB_HOST="db.example.com"
export LOG_LEVEL="info"

# Child processes (commands called from this script) will inherit exported vars
./another_script.sh    # can read $APP_ENV, $DB_HOST, $LOG_LEVEL
```

### Using a `.env` file (12-factor app pattern)

Store configuration in a separate file, not hardcoded in the script:

```bash
# File: .env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=admin
DB_PASS=secret123
APP_PORT=8080
LOG_LEVEL=info
```

```bash
#!/bin/bash
# Script: start_app.sh

# Load the .env file
if [ -f ".env" ]; then
    # Export each key=value line (ignoring comments and blank lines)
    set -a    # automatically export all variables
    source .env
    set +a
    echo "Loaded configuration from .env"
else
    echo "Warning: no .env file found, using defaults"
fi

echo "Database: $DB_HOST:$DB_PORT/$DB_NAME"
echo "App port: $APP_PORT"
```

> ⚠️ **Never commit `.env` files to Git.** They contain secrets (passwords, API keys). Always add `.env` to your `.gitignore`.

## 9.2 Modifying `$PATH` in Scripts

```bash
#!/bin/bash
# Add a directory to PATH for this script
export PATH="$PATH:/opt/my-tool/bin:/usr/local/custom/bin"

# Check if a command is available
if ! command -v docker &>/dev/null; then
    echo "Error: docker is not installed or not in PATH"
    exit 1
fi

# command -v is better than which:
# 'which' only finds external commands
# 'command -v' also finds shell built-ins and functions
```

## 9.3 Script Configuration Patterns

Real-world scripts often need configuration that can come from multiple sources (defaults → config file → environment variables → command-line arguments), where each source overrides the previous:

```bash
#!/bin/bash
set -euo pipefail

# ── 1. Hardcoded defaults ──────────────────────────────────────────────────
DEFAULT_LOG_DIR="/var/log/myapp"
DEFAULT_MAX_BACKUPS=5
DEFAULT_ENVIRONMENT="dev"

# ── 2. Set variables from defaults ────────────────────────────────────────
LOG_DIR="$DEFAULT_LOG_DIR"
MAX_BACKUPS="$DEFAULT_MAX_BACKUPS"
ENVIRONMENT="$DEFAULT_ENVIRONMENT"

# ── 3. Override from config file (if it exists) ───────────────────────────
CONFIG_FILE="/etc/myapp/config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# ── 4. Override from environment variables ────────────────────────────────
LOG_DIR="${LOG_DIR_OVERRIDE:-$LOG_DIR}"
MAX_BACKUPS="${MAX_BACKUPS_OVERRIDE:-$MAX_BACKUPS}"

# ── 5. Override from command-line arguments ───────────────────────────────
while getopts "e:l:n:" opt; do
    case $opt in
        e) ENVIRONMENT="$OPTARG" ;;
        l) LOG_DIR="$OPTARG" ;;
        n) MAX_BACKUPS="$OPTARG" ;;
    esac
done

echo "Environment: $ENVIRONMENT"
echo "Log dir:     $LOG_DIR"
echo "Max backups: $MAX_BACKUPS"
```

---

# 📄 Chapter 10 — File Operations in Scripts

## 10.1 Reading and Writing Files

```bash
#!/bin/bash

# Write to a file (overwrite)
echo "Hello, file!" > output.txt

# Append to a file
echo "Another line" >> output.txt
echo "Third line" >> output.txt

# Write multiple lines with heredoc
cat > config.txt << EOF
# Application Configuration
host=localhost
port=8080
debug=false
EOF

# Append heredoc
cat >> config.txt << EOF
log_level=info
max_connections=100
EOF

# Read entire file
content=$(cat output.txt)
echo "File contents: $content"

# Read file line by line (the correct way)
while IFS= read -r line; do
    echo "Line: $line"
done < output.txt

# Read file into an array
mapfile -t lines < output.txt    # each line becomes an array element
echo "Line 1: ${lines[0]}"
echo "Total lines: ${#lines[@]}"
```

## 10.2 File Processing Scripts

```bash
#!/bin/bash
# Script: parse_config.sh
# Read a key=value config file and load values

CONFIG_FILE="app.conf"

declare -A config

while IFS='=' read -r key value; do
    # Skip blank lines and comments
    [[ -z "$key" || "$key" =~ ^# ]] && continue

    # Trim whitespace
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    config["$key"]="$value"
done < "$CONFIG_FILE"

# Access values
echo "Host: ${config[host]}"
echo "Port: ${config[port]}"
```

```bash
#!/bin/bash
# Script: log_analyser.sh
# Summarise errors in log files

LOG_FILE=${1:-"/var/log/syslog"}

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: $LOG_FILE not found"
    exit 1
fi

echo "=== Log Analysis: $LOG_FILE ==="
echo "Total lines:  $(wc -l < "$LOG_FILE")"
echo "ERROR count:  $(grep -c "ERROR" "$LOG_FILE" || echo 0)"
echo "WARN count:   $(grep -c "WARN"  "$LOG_FILE" || echo 0)"
echo "INFO count:   $(grep -c "INFO"  "$LOG_FILE" || echo 0)"
echo ""
echo "=== Last 5 Errors ==="
grep "ERROR" "$LOG_FILE" | tail -5
```

## 10.3 Working with CSV Files

```bash
#!/bin/bash
# Process a CSV file: users.csv
# Format: name,email,department,salary

CSV_FILE="users.csv"

echo "Processing: $CSV_FILE"
echo "---"

total_salary=0
count=0

# Skip the header line with 'tail -n +2'
while IFS=',' read -r name email dept salary; do
    echo "  $name ($dept) — £$salary"
    total_salary=$((total_salary + salary))
    ((count++))
done < <(tail -n +2 "$CSV_FILE")

echo "---"
echo "Total employees: $count"
echo "Total salary: £$total_salary"
echo "Average salary: £$((total_salary / count))"
```

## 10.4 Backup Script

```bash
#!/bin/bash
# Script: backup.sh
# Create timestamped backups of a directory

set -euo pipefail

SOURCE_DIR=${1:-"$HOME/projects"}
BACKUP_DIR=${2:-"$HOME/backups"}
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="backup_${TIMESTAMP}.tar.gz"
MAX_BACKUPS=10

# Validate source
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory not found: $SOURCE_DIR"
    exit 1
fi

# Create backup directory if needed
mkdir -p "$BACKUP_DIR"

# Create the backup
echo "Backing up: $SOURCE_DIR"
echo "Destination: $BACKUP_DIR/$BACKUP_NAME"

tar -czvf "$BACKUP_DIR/$BACKUP_NAME" "$SOURCE_DIR" 2>/dev/null
echo "Backup complete: $BACKUP_NAME"

# Remove old backups — keep only the most recent MAX_BACKUPS
backup_count=$(ls -1 "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | wc -l)
if [ "$backup_count" -gt "$MAX_BACKUPS" ]; then
    echo "Removing old backups (keeping last $MAX_BACKUPS)..."
    ls -1t "$BACKUP_DIR"/backup_*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -f
    echo "Cleanup complete"
fi

echo "Done. Total backups: $(ls -1 "$BACKUP_DIR"/backup_*.tar.gz | wc -l)"
```

---

# 🖥️ Chapter 11 — Five Complete Real-World Scripts

## Script 1: System Information Report

```bash
#!/bin/bash
# Script: sysinfo.sh
# Displays a comprehensive system information report

set -euo pipefail

SEPARATOR="─────────────────────────────────────────"

print_header() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║         SYSTEM INFORMATION REPORT        ║"
    echo "╚══════════════════════════════════════════╝"
    echo "Generated: $(date)"
    echo ""
}

print_section() {
    echo ""
    echo "── $1 ──────────────────────────────────────"
}

print_header

print_section "SYSTEM"
echo "Hostname:    $(hostname)"
echo "OS:          $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
echo "Kernel:      $(uname -r)"
echo "Uptime:      $(uptime -p)"
echo "Last boot:   $(who -b | awk '{print $3, $4}')"

print_section "CPU"
echo "CPU:         $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo "Cores:       $(nproc)"
echo "Load avg:    $(cat /proc/loadavg | awk '{print $1, $2, $3}')"

print_section "MEMORY"
free -h | grep -E "^Mem|^Swap"

print_section "DISK"
df -h | grep -E "^/dev|^Filesystem"

print_section "NETWORK"
ip -4 addr show | grep inet | awk '{print $NF": "$2}'

print_section "LOGGED IN USERS"
who

print_section "TOP 5 PROCESSES BY CPU"
ps aux --sort=-%cpu | head -6 | awk '{printf "%-10s %-6s %-6s %s\n", $1, $2, $3, $11}'

echo ""
echo "$SEPARATOR"
echo "Report complete"
```

## Script 2: User Manager

```bash
#!/bin/bash
# Script: user_manager.sh
# Create, delete, and list users

set -euo pipefail

# Must be run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (sudo)"
    exit 1
fi

usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  create <username> [--shell SHELL] [--groups GROUP1,GROUP2]"
    echo "  delete <username> [--remove-home]"
    echo "  list"
    echo "  info <username>"
    echo ""
    exit 1
}

create_user() {
    local username=$1
    shift
    local shell="/bin/bash"
    local groups=""

    while [ $# -gt 0 ]; do
        case $1 in
            --shell) shell=$2; shift 2 ;;
            --groups) groups=$2; shift 2 ;;
            *) echo "Unknown option: $1"; exit 1 ;;
        esac
    done

    if id "$username" &>/dev/null; then
        echo "Error: User '$username' already exists"
        exit 1
    fi

    useradd -m -s "$shell" "$username"
    echo "User '$username' created"

    if [ -n "$groups" ]; then
        IFS=',' read -ra group_list <<< "$groups"
        for group in "${group_list[@]}"; do
            usermod -aG "$group" "$username"
            echo "Added '$username' to group '$group'"
        done
    fi

    echo "Set password:"
    passwd "$username"
}

delete_user() {
    local username=$1
    local remove_home=false
    [ "${2:-}" == "--remove-home" ] && remove_home=true

    if ! id "$username" &>/dev/null; then
        echo "Error: User '$username' does not exist"
        exit 1
    fi

    read -p "Delete user '$username'? [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Cancelled"; exit 0; }

    if $remove_home; then
        userdel -r "$username"
        echo "User '$username' and home directory removed"
    else
        userdel "$username"
        echo "User '$username' removed (home directory kept)"
    fi
}

list_users() {
    echo "System Users (UID >= 1000):"
    echo "────────────────────────────"
    awk -F: '$3 >= 1000 && $3 < 65534 {printf "%-20s UID:%-6s Shell: %s\n", $1, $3, $7}' /etc/passwd
}

user_info() {
    local username=$1
    if ! id "$username" &>/dev/null; then
        echo "Error: User '$username' does not exist"
        exit 1
    fi
    echo "User: $username"
    id "$username"
    echo "Home: $(getent passwd "$username" | cut -d: -f6)"
    echo "Shell: $(getent passwd "$username" | cut -d: -f7)"
    echo "Last login: $(lastlog -u "$username" | tail -1)"
}

[ $# -eq 0 ] && usage

command=$1
shift

case $command in
    create) create_user "$@" ;;
    delete) delete_user "$@" ;;
    list)   list_users ;;
    info)   user_info "$@" ;;
    *)      echo "Unknown command: $command"; usage ;;
esac
```

## Script 3: File Organiser

```bash
#!/bin/bash
# Script: organise.sh
# Sort files in a directory into subdirectories by type

set -euo pipefail

TARGET_DIR=${1:-"$HOME/Downloads"}
DRY_RUN=false
[ "${2:-}" == "--dry-run" ] && DRY_RUN=true

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory not found: $TARGET_DIR"
    exit 1
fi

declare -A categories=(
    ["Images"]="jpg jpeg png gif bmp svg webp ico tiff"
    ["Videos"]="mp4 avi mkv mov wmv flv webm m4v"
    ["Audio"]="mp3 wav flac aac ogg m4a wma"
    ["Documents"]="pdf doc docx txt rtf odt pages"
    ["Spreadsheets"]="xls xlsx csv ods numbers"
    ["Archives"]="zip tar gz bz2 7z rar xz"
    ["Code"]="sh py js ts html css json yaml yml toml go rb java c cpp"
    ["Executables"]="exe dmg pkg deb rpm AppImage"
)

moved=0
skipped=0

echo "Organising: $TARGET_DIR"
[ "$DRY_RUN" = true ] && echo "(DRY RUN — no changes will be made)"
echo ""

for file in "$TARGET_DIR"/*; do
    [ -f "$file" ] || continue

    filename=$(basename "$file")
    extension="${filename##*.}"
    extension="${extension,,}"    # to lowercase

    dest_category=""
    for category in "${!categories[@]}"; do
        extensions="${categories[$category]}"
        if [[ " $extensions " == *" $extension "* ]]; then
            dest_category="$category"
            break
        fi
    done

    if [ -z "$dest_category" ]; then
        dest_category="Other"
    fi

    dest_dir="$TARGET_DIR/$dest_category"
    dest_file="$dest_dir/$filename"

    if [ "$DRY_RUN" = true ]; then
        echo "WOULD MOVE: $filename → $dest_category/"
    else
        mkdir -p "$dest_dir"
        mv "$file" "$dest_file"
        echo "Moved: $filename → $dest_category/"
    fi
    ((moved++))
done

echo ""
echo "Done: $moved files processed"
```

## Script 4: Deployment Helper

```bash
#!/bin/bash
# Script: deploy.sh
# Zero-downtime deployment with rollback capability

set -euo pipefail

APP_NAME="myapp"
DEPLOY_DIR="/var/www/$APP_NAME"
RELEASES_DIR="$DEPLOY_DIR/releases"
CURRENT_LINK="$DEPLOY_DIR/current"
SHARED_DIR="$DEPLOY_DIR/shared"
KEEP_RELEASES=5

log() { echo "[$(date '+%H:%M:%S')] $*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

cleanup_on_error() {
    log "Deployment failed. Rolling back..."
    rollback
}
trap cleanup_on_error ERR

deploy() {
    local git_ref=${1:-"main"}
    local release_id
    release_id=$(date +"%Y%m%d%H%M%S")
    local release_dir="$RELEASES_DIR/$release_id"

    log "Starting deployment of $APP_NAME ($git_ref)"
    log "Release ID: $release_id"

    # Create release directory
    mkdir -p "$release_dir"
    mkdir -p "$RELEASES_DIR" "$SHARED_DIR"

    # Clone/pull code
    log "Fetching code..."
    git clone --branch "$git_ref" --depth 1 https://github.com/org/$APP_NAME "$release_dir"

    # Link shared files (logs, uploads, .env)
    log "Linking shared files..."
    ln -sfn "$SHARED_DIR/logs" "$release_dir/logs"
    ln -sfn "$SHARED_DIR/.env" "$release_dir/.env"

    # Install dependencies
    log "Installing dependencies..."
    cd "$release_dir"
    npm ci --production 2>/dev/null || pip install -r requirements.txt

    # Run migrations
    log "Running database migrations..."
    # ./manage.py migrate --noinput

    # Switch the current symlink (atomic operation)
    log "Switching to new release..."
    ln -sfn "$release_dir" "$CURRENT_LINK"

    # Reload application (no downtime)
    log "Reloading application..."
    systemctl reload "$APP_NAME" || systemctl restart "$APP_NAME"

    # Clean up old releases
    log "Cleaning up old releases..."
    ls -1dt "$RELEASES_DIR"/*/ | tail -n +$((KEEP_RELEASES + 1)) | xargs rm -rf

    log "✓ Deployment successful! Release: $release_id"
}

rollback() {
    log "Rolling back..."
    local releases
    releases=$(ls -1dt "$RELEASES_DIR"/*/ 2>/dev/null)
    local count
    count=$(echo "$releases" | wc -l)

    if [ "$count" -lt 2 ]; then
        die "No previous release to roll back to"
    fi

    local prev_release
    prev_release=$(echo "$releases" | sed -n '2p')

    ln -sfn "$prev_release" "$CURRENT_LINK"
    systemctl reload "$APP_NAME" || systemctl restart "$APP_NAME"
    log "✓ Rolled back to: $(basename "$prev_release")"
}

case "${1:-}" in
    deploy)   deploy "${2:-main}" ;;
    rollback) rollback ;;
    *) echo "Usage: $0 deploy [branch] | rollback"; exit 1 ;;
esac
```

## Script 5: Health Check Monitor

```bash
#!/bin/bash
# Script: healthcheck.sh
# Monitor services and send alerts

set -euo pipefail

ALERT_EMAIL="ops@example.com"
SLACK_WEBHOOK="${SLACK_WEBHOOK_URL:-}"
LOG_FILE="/var/log/healthcheck.log"

declare -A SERVICES=(
    ["nginx"]="80"
    ["postgresql"]="5432"
    ["redis"]="6379"
    ["myapp"]="8080"
)

ENDPOINTS=(
    "https://example.com/health"
    "https://api.example.com/ping"
)

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(timestamp)] $*" | tee -a "$LOG_FILE"; }

send_alert() {
    local message=$1
    log "ALERT: $message"

    if [ -n "$SLACK_WEBHOOK" ]; then
        curl -s -X POST "$SLACK_WEBHOOK" \
            -H 'Content-type: application/json' \
            --data "{\"text\":\"🚨 Health Check Alert: $message\"}" \
            > /dev/null
    fi
}

check_port() {
    local service=$1
    local port=$2

    if nc -z localhost "$port" 2>/dev/null; then
        log "OK    $service (port $port)"
        return 0
    else
        send_alert "$service is DOWN (port $port not responding)"
        return 1
    fi
}

check_endpoint() {
    local url=$1
    local http_code

    http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" || echo "000")

    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 400 ]; then
        log "OK    $url (HTTP $http_code)"
        return 0
    else
        send_alert "Endpoint $url returned HTTP $http_code"
        return 1
    fi
}

check_disk() {
    local threshold=85
    local usage
    usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    if [ "$usage" -gt "$threshold" ]; then
        send_alert "Disk usage is ${usage}% (threshold: ${threshold}%)"
    else
        log "OK    Disk usage: ${usage}%"
    fi
}

check_memory() {
    local threshold=90
    local usage
    usage=$(free | awk 'NR==2 {printf "%.0f", $3/$2*100}')
    if [ "$usage" -gt "$threshold" ]; then
        send_alert "Memory usage is ${usage}% (threshold: ${threshold}%)"
    else
        log "OK    Memory usage: ${usage}%"
    fi
}

log "=== Health Check Start ==="

for service in "${!SERVICES[@]}"; do
    check_port "$service" "${SERVICES[$service]}" || true
done

for endpoint in "${ENDPOINTS[@]}"; do
    check_endpoint "$endpoint" || true
done

check_disk
check_memory

log "=== Health Check Complete ==="
```

---

# 🐛 Chapter 12 — Debugging

## 12.1 Debugging Techniques

```bash
#!/bin/bash
# Technique 1: set -x at the top (see every command)
set -x

# Technique 2: set -x around a specific block
set -x
problematic_command
another_command
set +x

# Technique 3: Print variable values at key points
echo "DEBUG: variable=${variable}" >&2   # >&2 sends to stderr (not mixed with real output)

# Technique 4: Exit early to isolate the problem
# Comment out sections until you find where it breaks

# Technique 5: Run with bash -x on the command line (no need to edit the file)
bash -x myscript.sh

# Technique 6: bash -n checks syntax without running
bash -n myscript.sh

# Technique 7: Check exit codes
some_command
echo "Exit code: $?"

# Technique 8: Print line numbers in errors
# $LINENO gives the current line number
echo "Reached line $LINENO"
```

## 12.2 Common Mistakes and Fixes

```bash
# ── MISTAKE 1: Spaces around = ────────────────────────────────────────────
# WRONG:
name = "Alice"      # bash tries to run command "name" with args = and "Alice"

# RIGHT:
name="Alice"

# ── MISTAKE 2: Not quoting variables ──────────────────────────────────────
file="my document.txt"

# WRONG — fails with spaces:
if [ -f $file ]; then ...

# RIGHT:
if [ -f "$file" ]; then ...

# ── MISTAKE 3: Using = instead of -eq for numbers ─────────────────────────
# WRONG (string comparison):
if [ $count = 0 ]; then ...    # "0" == "0" works, but "00" == "0" fails

# RIGHT (numeric comparison):
if [ $count -eq 0 ]; then ...

# ── MISTAKE 4: Missing quotes in arrays ───────────────────────────────────
files=("file one.txt" "file two.txt")

# WRONG — splits on spaces:
for f in ${files[@]}; do ...

# RIGHT:
for f in "${files[@]}"; do ...

# ── MISTAKE 5: Ignoring exit codes ────────────────────────────────────────
# WRONG:
rm important_file.txt   # what if it fails?
process_more_data       # this runs even if rm failed

# RIGHT:
rm important_file.txt || { echo "Error removing file"; exit 1; }
process_more_data

# ── MISTAKE 6: cd without error checking ──────────────────────────────────
# WRONG — if cd fails, the rest of the script runs in the wrong directory:
cd /some/dir
rm -rf *            # DANGER if cd failed and we're in the wrong place

# RIGHT:
cd /some/dir || { echo "Cannot cd to /some/dir"; exit 1; }
rm -rf *

# ── MISTAKE 7: Forgetting that functions define local scope ───────────────
# Always use 'local' for function variables (see Chapter 7)

# ── MISTAKE 8: $(cat file) vs < file ─────────────────────────────────────
# LESS EFFICIENT (spawns a subshell and cat process):
count=$(cat file.txt | wc -l)

# MORE EFFICIENT (redirect, no cat needed):
count=$(wc -l < file.txt)
```

## 12.3 ShellCheck — Automated Static Analysis

ShellCheck (available at shellcheck.net, as a VS Code extension, or via `sudo apt install shellcheck`) catches errors before you run them:

```bash
# Check a script from the command line
shellcheck myscript.sh

# Example output:
# myscript.sh line 5: variable="hello world"
# SC2034: variable appears unused. Verify it or export it.

# myscript.sh line 12: for f in $files; do
# SC2068: Double quote array expansions to avoid re-splitting elements.
```

> **Use ShellCheck on every script you write.** It catches quoting issues, undefined variables, bad patterns, and common mistakes that are hard to spot by eye. Install the VS Code extension so it checks in real-time as you type.

---

# 🏆 Chapter 13 — Quick Reference Cheat Sheet

## Script Skeleton

```bash
#!/bin/bash
set -euo pipefail

# ── Configuration ──────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/$(basename "$0" .sh).log"

# ── Functions ──────────────────────────────────────────
log()  { echo "[$(date '+%H:%M:%S')] $*"; }
die()  { echo "ERROR: $*" >&2; exit 1; }

usage() {
    echo "Usage: $0 [options] <argument>"
    echo "  -h    Show this help"
    exit 1
}

cleanup() {
    # runs on exit
    :
}
trap cleanup EXIT

# ── Argument parsing ───────────────────────────────────
while getopts "h" opt; do
    case $opt in
        h) usage ;;
        ?) usage ;;
    esac
done
shift $((OPTIND - 1))

[ $# -eq 0 ] && usage

# ── Main logic ─────────────────────────────────────────
main() {
    log "Starting"
    # your code here
    log "Done"
}

main "$@"
```

## Variables

```bash
name="Alice"            # string
count=42                # number
arr=(a b c)             # array
declare -A map          # associative array
map["key"]="value"

echo $name              # access
echo ${name}            # safer access
echo ${name:-default}   # use default if unset
echo ${#name}           # length
echo ${name^^}          # uppercase
echo ${name,,}          # lowercase
echo ${name:0:3}        # substring
echo ${name/old/new}    # replace
```

## Conditionals

```bash
# Numeric
[ $a -eq $b ]    [ $a -ne $b ]    [ $a -lt $b ]
[ $a -gt $b ]    [ $a -le $b ]    [ $a -ge $b ]

# String (use [[ ]])
[[ $a == $b ]]   [[ $a != $b ]]
[[ -z $a ]]      # empty
[[ -n $a ]]      # not empty
[[ $a =~ regex ]] # regex match

# File
[ -f file ]   # is regular file
[ -d dir ]    # is directory
[ -e path ]   # exists
[ -r file ]   # readable
[ -w file ]   # writable
[ -x file ]   # executable
[ -s file ]   # not empty

# Logic
[ cond1 ] && [ cond2 ]     # AND
[ cond1 ] || [ cond2 ]     # OR
! [ cond ]                  # NOT
```

## Loops

```bash
# for over list
for item in a b c; do
    echo $item
done

# for over array
for item in "${arr[@]}"; do echo $item; done

# for range
for i in {1..10}; do echo $i; done

# C-style for
for ((i=0; i<10; i++)); do echo $i; done

# while
while [ $i -lt 10 ]; do
    ((i++))
done

# read file
while IFS= read -r line; do
    echo "$line"
done < file.txt

# break / continue
break       # exit loop
continue    # next iteration
```

## Functions

```bash
my_function() {
    local arg1=$1
    local arg2=${2:-"default"}
    # ...
    return 0    # or return 1 for error
}

# Capture output
result=$(my_function arg1 arg2)

# Use as condition
if my_function arg1; then
    echo "success"
fi
```

## Error Handling

```bash
set -euo pipefail       # always add this

$?                       # exit code of last command
exit 0                   # exit success
exit 1                   # exit failure

cmd || { echo "failed"; exit 1; }    # inline error handling

trap cleanup EXIT        # run cleanup() on exit
trap 'die "Error on line $LINENO"' ERR  # catch errors
```

## Arithmetic

```bash
$((5 + 3))         # 8
$((a * b))         # multiply
$((a / b))         # integer division
$((a % b))         # remainder
$((2 ** 8))        # 256

((count++))        # increment
((count += 5))     # add to variable

# Floating point:
echo "scale=2; 10/3" | bc   # 3.33
```

## Useful Patterns

```bash
# Default value if variable is empty
name=${1:-"default_name"}

# Check if command exists
command -v docker &>/dev/null || die "docker not installed"

# Check if root
[ "$EUID" -eq 0 ] || die "Must run as root"

# Get script directory (absolute path)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Timestamp
TS=$(date +"%Y%m%d_%H%M%S")

# Confirm prompt
read -p "Are you sure? [y/N]: " ans
[[ "$ans" =~ ^[Yy]$ ]] || exit 0

# Load .env file
set -a; source .env; set +a

# Redirect all output to log
exec > >(tee -a "$LOG_FILE") 2>&1
```

---

# 📌 Appendix — Being Hireable: What You Must Know Cold

By the time you're interviewing or doing technical tests, the following must be completely fluent:

1. **Write a working script from scratch** — shebang, `set -euo pipefail`, variables, functions, error handling, clean exit. Do it without looking anything up.

2. **Explain what every line of `set -euo pipefail` does** and why you include it in every script.

3. **Variables** — create, access (`$var` vs `${var}`), default values (`${var:-default}`), command substitution (`$(command)`), difference between single and double quotes.

4. **Functions** — define, call with arguments, use `local`, return exit codes, capture output with `$()`.

5. **Conditionals** — write a complete `if/elif/else`, know all comparison operators (`-eq`, `-ne`, `-lt`, `-gt`, `-z`, `-n`, `-f`, `-d`), know `[[ ]]` vs `[ ]`.

6. **Loops** — write `for` (over list, range, array), `while` (with condition and `while true`), use `break` and `continue` correctly.

7. **Error handling** — `$?`, `exit 0`/`exit 1`, `trap cleanup EXIT`, inline `||` handling, the `die()` pattern.

8. **Read user input** — `read -p "prompt: " var`, handle empty input, validate type.

9. **Process files** — read line by line with `while IFS= read -r line`, write with `>` and `>>`, append with heredoc.

10. **Parameter handling** — `$1`, `$2`, `$@`, `$#`, `$0`, check for missing args and print usage.

11. **Debug a broken script** — add `set -x`, interpret the `+` prefix output, find the failing line, check `$?` after commands.

12. **ShellCheck** — run it on everything, understand and fix common warnings.

13. **The five real-world scripts in Chapter 11** — understand every line. These cover the patterns that come up in 90% of DevOps automation.
