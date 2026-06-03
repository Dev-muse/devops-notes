# 🐧 Linux for DevOps — Complete Beginner's Guide

> **How to use this document:** This is your permanent reference. Read it top-to-bottom once. After that, use the headers to jump to whatever you've forgotten. Every section starts with a plain-English explanation, then the technical details, then real commands you will actually use.
>
> **The goal:** By the end of this document you will be able to navigate Linux confidently from the command line, manage files and permissions, understand processes, use power tools like `grep`, `awk`, `sed` and `find`, manage users and groups, and complete Levels 0–20 of the OverTheWire Bandit challenge.
>
> **Mental model:** Linux is just a computer where *everything is controlled by text commands.* No clicking. No menus. You type instructions; the system obeys. Once that feels normal, everything else follows.

---

# 📘 Chapter 1 — Introduction to Linux

## 1.1 What is Linux?

**Linux** is an **open-source operating system** (OS). An operating system is the software that sits between your hardware (CPU, RAM, disk) and your applications — it manages all the resources and lets programs run.

- **Created by Linus Torvalds** in 1991, originally as a personal project to build a free Unix-like OS.
- **Open-source** — the source code is freely available. Anyone can read it, modify it, and distribute it.
- **The backbone of the modern internet** — the vast majority of web servers, cloud infrastructure (AWS, GCP, Azure virtual machines), routers, Android phones, supercomputers, and container platforms (Docker, Kubernetes) all run Linux.

## 1.2 Why Learn Linux as a DevOps Engineer?

| Reason | What it means for you |
|---|---|
| **Essential** | You cannot work in DevOps without it — every server you touch will be Linux |
| **Cost-effective** | Free to use. No licence fees for servers, VMs, or containers |
| **Highly customisable** | You can configure, automate, and script literally everything |
| **Widely used** | It is the dominant OS in cloud infrastructure — AWS EC2, Docker containers, Kubernetes nodes — all Linux |

> **The harsh truth:** If you can't use Linux from the command line, you cannot be a DevOps engineer. It is not optional. The good news: it's learnable, and this document teaches you everything you need.

## 1.3 Linux Distributions

A **Linux distribution (distro)** is a complete OS package built on the Linux kernel, bundled with additional software. The kernel is the same; the packaging, tools, and defaults differ.

| Distro | Used for | Notes |
|---|---|---|
| **Ubuntu** | Servers, desktops, learning | Most beginner-friendly. What this course uses. |
| **Debian** | Servers | Very stable, minimal |
| **CentOS / RHEL** | Enterprise servers | Common in older corporate environments |
| **Alpine** | Docker containers | Tiny — only ~5MB. Used in lightweight containers |
| **Kali Linux** | Security / penetration testing | Pre-loaded with security tools |
| **Amazon Linux** | AWS EC2 instances | AWS's own distro |

> **For this course:** Use **Ubuntu** (LTS — Long Term Support version). It's what you'll encounter most in DevOps.

## 1.4 Setting Up Linux

### Mac Users

macOS is Unix-based, so the terminal is ready to go immediately. Open **Terminal** (Cmd + Space → type "Terminal"). You have `bash` or `zsh` already. For a full Ubuntu environment, install **UTM** (free virtualisation software for Mac) and run Ubuntu inside it.

### Windows Users

Two good options:

1. **WSL2 (Windows Subsystem for Linux)** — install Ubuntu directly inside Windows. Open PowerShell as Administrator and run:
   ```
   wsl --install
   ```
   After reboot, you'll have a full Ubuntu shell accessible from the Start menu.

2. **VirtualBox** — install VirtualBox (free), download the Ubuntu ISO, create a virtual machine. More isolated but heavier.

> **Recommendation:** WSL2 is the fastest and lightest option for Windows. VirtualBox is better if you want a fully isolated environment.

---

# 📗 Chapter 2 — The Terminal & The Shell

## 2.1 Introduction to the Terminal

**The terminal** (also called a terminal emulator) is the **application** — the window — in which you type commands. Think of it as the screen and keyboard wrapper.

Examples of terminal applications:
- **macOS:** Terminal, iTerm2
- **Ubuntu:** GNOME Terminal, Tilix
- **Windows:** Windows Terminal (used with WSL2)

The terminal itself is just a display. What actually *runs* your commands is the **shell**.

## 2.2 Introduction to the Shell

**The shell** is the **program** that reads your commands and executes them. It's the interpreter between you and the operating system.

When you type a command and press Enter, the shell:
1. Reads your input.
2. Interprets it (figures out what you want).
3. Tells the OS to do it.
4. Shows you the result (output).

### Different types of shells

| Shell | Notes |
|---|---|
| **Bash** (Bourne Again Shell) | The default on most Linux distros. What you'll use most. |
| **Zsh** (Z Shell) | Default on modern macOS. More features and plugins than Bash |
| **sh** (Bourne Shell) | The original. Still used for scripts that need to be portable |
| **Fish** | User-friendly with auto-suggestions built in |
| **Dash** | Minimal, fast — used for system scripts, not interactive use |

> **For this course:** Use **Bash.** It's what you'll find on every Linux server. Zsh is fine locally and we'll cover the differences, but learn Bash first.

### The shell prompt

When you open a terminal you see something like:

```
username@hostname:~$
```

Breaking it down:
- `username` — who you're logged in as.
- `hostname` — the name of the machine.
- `~` — your current directory (`~` is shorthand for your home directory, `/home/username`).
- `$` — means you're a regular user. A `#` means you're **root** (the superuser — be careful).

## 2.3 Anatomy of a Linux Command

Every command follows this structure:

```
$ command  [options]  [arguments]
```

| Part | What it is | Example |
|---|---|---|
| `command` | The program to run | `ls` |
| `options` | Flags that modify behaviour. Start with `-` or `--` | `-l` or `--all` |
| `arguments` | What the command acts on | `/home/user/documents` |

**Real example:**

```bash
ls -la /home/user
```

- `ls` = list directory contents
- `-la` = two options combined: `-l` (long format) and `-a` (show hidden files)
- `/home/user` = the directory to list

**Rules you must know:**
- Commands are **case-sensitive.** `ls` works. `LS` does not.
- Options can often be combined: `-l -a` = `-la`.
- When in doubt, read the manual: `man ls` opens the manual for `ls`. Press `q` to quit.

---

# 📙 Chapter 3 — The Linux File System

## 3.1 Everything is a File

In Linux, **everything is treated as a file** — your actual documents, directories, your keyboard input, your screen output, your hard drive, network connections. This unified model is what makes Linux so powerful and scriptable.

## 3.2 The File System Hierarchy

Linux uses a **single tree structure** rooted at `/` (called "root"). There are no drive letters like `C:\` or `D:\`. Everything hangs off `/`.

```
/
├── bin/       Essential command binaries (ls, cp, mv...)
├── boot/      Bootloader and kernel files
├── dev/       Device files (hard drives, USB, etc.)
├── etc/       System configuration files
├── home/      User home directories (/home/alice, /home/bob)
├── lib/       Shared libraries needed by binaries
├── media/     Mount point for removable media (USB drives, CDs)
├── mnt/       Temporary mount point for filesystems
├── opt/       Optional/third-party software
├── proc/      Virtual filesystem — live kernel/process info
├── root/      Home directory for the root user (NOT /home/root)
├── sbin/      System binaries (for admin use)
├── srv/       Data for services (web server files, etc.)
├── sys/       Virtual filesystem — hardware/kernel info
├── tmp/       Temporary files (cleared on reboot)
├── usr/       User programs and utilities
│   ├── bin/   Most user commands live here
│   └── local/ Locally installed software
└── var/       Variable data — logs, databases, mail spools
    └── log/   System logs (/var/log/syslog, /var/log/auth.log)
```

### The directories you'll use constantly

| Directory | Why you'll be there |
|---|---|
| `/home/username` | Your personal files. Shorthand: `~` |
| `/etc` | Config files for every service on the system |
| `/var/log` | Log files — your first stop when debugging |
| `/tmp` | Scratch space — safe to create/delete files here |
| `/usr/bin` | Where most installed commands live |
| `/proc` | Live process and kernel info — `cat /proc/cpuinfo` shows CPU details |

## 3.3 Navigating the File System

### Absolute vs Relative Paths

| Type | Description | Example |
|---|---|---|
| **Absolute path** | Starts from root `/`. Works from anywhere. | `/home/alice/documents/file.txt` |
| **Relative path** | Relative to your *current* location | `documents/file.txt` (if you're in `/home/alice`) |

**Special path symbols:**

| Symbol | Means |
|---|---|
| `~` | Your home directory (`/home/username`) |
| `.` | The current directory |
| `..` | The parent directory (one level up) |
| `-` | The previous directory you were in (use with `cd -`) |

### Essential navigation commands

```bash
# Print Working Directory — where am I right now?
pwd

# List files and directories
ls                  # basic list
ls -l               # long format (permissions, size, date)
ls -a               # show hidden files (those starting with .)
ls -la              # long format + hidden files (use this constantly)
ls -lh              # long format with human-readable file sizes
ls -lt              # sort by modification time (newest first)

# Change Directory
cd /etc             # go to /etc (absolute path)
cd documents        # go to documents/ in current dir (relative)
cd ~                # go home
cd ..               # go up one level
cd ../..            # go up two levels
cd -                # go back to where you just were
```

### Real-world workflow example

```bash
# You're hired and SSH'd into a new server. First thing you do:
pwd                  # find out where you are
ls -la               # see what's here, including hidden files
cd /etc              # navigate to configs
ls -la               # see all config files
cat /etc/os-release  # check what distro and version this is
```

## 3.4 Working with Files and Directories

### Creating files and directories

```bash
# Create an empty file
touch filename.txt

# Create a file with content
echo "Hello World" > file.txt

# Create a directory
mkdir my_folder

# Create nested directories (make all parents too)
mkdir -p projects/devops/scripts

# Create multiple directories at once
mkdir logs backups configs
```

### Copying, Moving, Renaming

```bash
# Copy a file
cp source.txt destination.txt

# Copy a file into a directory
cp file.txt /tmp/

# Copy a directory and all its contents (-r = recursive)
cp -r my_folder/ /tmp/my_folder_backup/

# Move a file (also used to rename)
mv old_name.txt new_name.txt

# Move a file into a directory
mv file.txt /tmp/

# Move a directory
mv my_folder/ /tmp/

# Rename a directory
mv old_folder/ new_folder/
```

### Deleting files and directories

```bash
# Delete a file
rm file.txt

# Delete multiple files
rm file1.txt file2.txt

# Delete with confirmation prompt (-i = interactive)
rm -i file.txt

# Delete a directory and everything in it (DANGEROUS — no undo)
rm -rf my_folder/

# Delete all .log files in current directory
rm *.log
```

> ⚠️ **`rm -rf` has no undo.** There is no Recycle Bin. Linux does not ask "Are you sure?" unless you add `-i`. The command `rm -rf /` would delete your entire system. Think before you type. When unsure, use `-i`.

### Viewing file contents

```bash
# Print entire file to screen
cat file.txt

# Print file with line numbers
cat -n file.txt

# View file page-by-page (press Space to advance, q to quit)
less file.txt

# View first 10 lines
head file.txt

# View first 20 lines
head -n 20 file.txt

# View last 10 lines
tail file.txt

# View last 20 lines
tail -n 20 file.txt

# Follow a file in real-time (essential for watching logs)
tail -f /var/log/syslog
```

> `tail -f` is one of the most-used DevOps commands. It's how you watch a log file live as your application writes to it.

### Finding files

```bash
# Find files by name in the current directory and below
find . -name "file.txt"

# Find files by name, case-insensitive
find / -iname "readme*"

# Find files modified in the last 24 hours
find /var/log -mtime -1

# Find files larger than 100MB
find / -size +100M

# Find files by type: f=file, d=directory
find /home -type f -name "*.txt"
find /home -type d -name "logs"

# Find and execute a command on each result
find . -name "*.log" -exec rm {} \;
```

### Linking files

```bash
# Hard link — another name for the same file data
ln file.txt hardlink.txt

# Soft (symbolic) link — a pointer/shortcut to the original
ln -s /path/to/original /path/to/link
```

| Type | Behaviour |
|---|---|
| **Hard link** | Points directly to the data. If original is deleted, data survives |
| **Soft link (symlink)** | Points to the original file's *name*. If original is deleted, link breaks |

---

# 📕 Chapter 4 — Essential Linux Commands

## 4.1 Getting Help

```bash
# Read the full manual for a command
man ls
man grep
man chmod

# Quick summary of a command
whatis ls

# Find which command does something
apropos "list files"

# Show built-in help for a command
ls --help
```

> Inside `man`, use: `Space` = next page, `b` = back, `/word` = search for "word", `n` = next match, `q` = quit.

## 4.2 Working with Text

### `cat`, `echo`, `printf`

```bash
# Print text to screen
echo "Hello, World"

# Print text with escape sequences (\n = newline, \t = tab)
echo -e "Line 1\nLine 2"

# Print variable value
echo $HOME

# Formatted output
printf "Name: %s\nAge: %d\n" "Alice" 30
```

### `grep` — Search text

`grep` is arguably the command you will use most as a DevOps engineer. It searches files (or input) for lines matching a pattern.

```bash
# Basic: find lines containing "error" in a file
grep "error" logfile.txt

# Case-insensitive search
grep -i "error" logfile.txt

# Show line numbers of matches
grep -n "error" logfile.txt

# Invert match — show lines that do NOT contain the pattern
grep -v "debug" logfile.txt

# Recursive — search in all files in a directory
grep -r "TODO" /home/user/projects/

# Count matching lines
grep -c "error" logfile.txt

# Show only the matching part, not the whole line
grep -o "error[0-9]*" logfile.txt

# Extended regex — more powerful patterns
grep -E "error|warning|critical" logfile.txt

# Combine: find "ERROR" in all .log files in /var/log
grep -r "ERROR" /var/log/*.log

# The most DevOps-typical grep: check if a service is running
ps aux | grep nginx
```

**Essential grep patterns:**

| Pattern | Matches |
|---|---|
| `error` | Literal text "error" |
| `^error` | Lines that *start with* "error" |
| `error$` | Lines that *end with* "error" |
| `err.r` | "err" + any character + "r" (`.` = any char) |
| `err*r` | "er" followed by zero or more "r" characters |
| `[Ee]rror` | "Error" or "error" |
| `error\|warning` | "error" or "warning" (with `-E`) |

### `awk` — Process and extract text columns

`awk` is a text-processing language. The most common use case: **extracting specific columns from structured output.**

```bash
# Print the first column of a file (columns are space-separated by default)
awk '{print $1}' file.txt

# Print the third column
awk '{print $3}' file.txt

# Print multiple columns
awk '{print $1, $3}' file.txt

# Use a different field separator (e.g. colon in /etc/passwd)
awk -F: '{print $1}' /etc/passwd

# Print lines where column 3 is greater than 1000
awk '$3 > 1000 {print $0}' file.txt

# Calculate a sum (column 2)
awk '{sum += $2} END {print sum}' file.txt

# Print lines matching a pattern
awk '/error/ {print $0}' logfile.txt

# Real DevOps example: list all user names from /etc/passwd
awk -F: '{print $1}' /etc/passwd

# Get process IDs from ps output
ps aux | awk '{print $2}'
```

### `sed` — Stream Editor (find and replace)

`sed` edits text streams. Its most common use: **find and replace** in files or pipelines.

```bash
# Replace first occurrence of "foo" with "bar" on each line
sed 's/foo/bar/' file.txt

# Replace ALL occurrences on each line (g = global)
sed 's/foo/bar/g' file.txt

# Case-insensitive replace
sed 's/foo/bar/gi' file.txt

# Edit the file in place (modify the actual file)
sed -i 's/foo/bar/g' file.txt

# Edit in place, keep backup with .bak extension
sed -i.bak 's/foo/bar/g' file.txt

# Delete lines containing a pattern
sed '/^#/d' config.txt      # delete comment lines (lines starting with #)

# Print only specific line numbers
sed -n '5,10p' file.txt     # print lines 5 through 10

# Delete blank lines
sed '/^$/d' file.txt

# Real DevOps: change a config value in place
sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config
```

### `sort` and `uniq`

```bash
# Sort lines alphabetically
sort file.txt

# Sort numerically
sort -n file.txt

# Sort in reverse order
sort -r file.txt

# Sort by column (e.g. column 2)
sort -k2 file.txt

# Remove duplicate lines (input must be sorted first)
sort file.txt | uniq

# Count occurrences of each unique line
sort file.txt | uniq -c

# Show only duplicate lines
sort file.txt | uniq -d

# Show only unique lines (no duplicates)
sort file.txt | uniq -u
```

### `cut` — Extract fields from lines

```bash
# Cut characters 1-5 from each line
cut -c1-5 file.txt

# Cut by delimiter (e.g. comma) and get field 2
cut -d',' -f2 file.csv

# Get username from /etc/passwd (colon-delimited, field 1)
cut -d':' -f1 /etc/passwd
```

### `wc` — Word/line/byte count

```bash
wc file.txt           # lines, words, bytes
wc -l file.txt        # count lines only (very common)
wc -w file.txt        # count words only
wc -c file.txt        # count bytes

# Count files in a directory
ls | wc -l
```

### `tr` — Translate/replace characters

```bash
# Convert lowercase to uppercase
echo "hello" | tr 'a-z' 'A-Z'

# Delete specific characters
echo "hello123" | tr -d '0-9'

# Replace colons with newlines
echo "one:two:three" | tr ':' '\n'
```

## 4.3 The Pipe `|` — Chaining Commands

The **pipe** (`|`) takes the **output of one command** and feeds it as **input to the next command.** This is one of the most powerful ideas in Linux — you build complex operations by chaining simple tools.

```bash
# Count how many running processes contain "python"
ps aux | grep "python" | wc -l

# List the 10 largest files in /var/log
ls -lhS /var/log | head -10

# Find all unique IP addresses in an access log
cat access.log | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | sort | uniq -c | sort -rn

# Show the top 5 most common errors
grep "ERROR" app.log | awk '{print $5}' | sort | uniq -c | sort -rn | head -5
```

> **The Unix philosophy:** Each tool does one thing well. Pipes let you compose tools into powerful pipelines. `grep` finds lines. `awk` extracts columns. `sort` orders them. `uniq -c` counts them. Chain them and you have a custom log analyser without writing a single line of code.

## 4.4 File Archiving and Compression

```bash
# Create a tar archive (uncompressed)
tar -cvf archive.tar folder/

# Create a compressed archive (gzip)
tar -czvf archive.tar.gz folder/

# Create a compressed archive (bzip2 — better compression, slower)
tar -cjvf archive.tar.bz2 folder/

# Extract a tar archive
tar -xvf archive.tar

# Extract a gzip-compressed archive
tar -xzvf archive.tar.gz

# Extract to a specific directory
tar -xzvf archive.tar.gz -C /tmp/

# List contents of an archive without extracting
tar -tvf archive.tar.gz

# Compress a single file with gzip
gzip file.txt            # creates file.txt.gz, removes original
gzip -k file.txt         # keep original

# Decompress
gunzip file.txt.gz
```

> **The tar flags:** `c` = create, `x` = extract, `v` = verbose (show progress), `f` = file, `z` = gzip, `j` = bzip2. Mix them as needed.

## 4.5 Disk Usage

```bash
# Disk free — how much space is available on each filesystem
df -h

# Disk usage — how much space a directory uses
du -h /var/log

# Show only the total for a directory
du -sh /var/log

# Show top-level directory sizes
du -h --max-depth=1 /var

# Find the 10 largest directories
du -h / 2>/dev/null | sort -rh | head -10
```

## 4.6 System Information Commands

```bash
# Display kernel and OS information
uname -a

# Detailed OS info
cat /etc/os-release

# CPU information
cat /proc/cpuinfo
lscpu

# Memory information
free -h

# Who is logged in
who
w

# System uptime
uptime

# Current date and time
date

# Calendar
cal

# Hostname
hostname

# All network interfaces and their IP addresses
ip a
# or (older syntax)
ifconfig
```

## 4.7 Searching Within Man Pages and Files

```bash
# Search for a command by keyword across all man pages
man -k "search term"

# Find where a command's binary lives
which ls
which python3

# Find all locations of a command
whereis ls

# Search the file-name database (faster than find for names)
locate filename
# Update the database first if file was just created:
sudo updatedb
```

---

# 📒 Chapter 5 — Vim: Basic Text Editing

> **Why Vim?** On a remote server, Vim is almost always available. GUI text editors are not. You *will* end up in Vim at some point — knowing how to get out of it and make basic edits is a hard requirement.

## 5.1 Opening and Closing Vim

```bash
# Open a file (creates it if it doesn't exist)
vim filename.txt

# Open at a specific line
vim +42 filename.txt

# Open in read-only mode
vim -R filename.txt
```

## 5.2 Vim's Modes

Vim has **modes** — this trips up every beginner. You cannot just start typing like a normal editor.

| Mode | How to enter | What it does |
|---|---|---|
| **Normal** | Press `Esc` | Navigate, issue commands. **This is the default/starting mode.** |
| **Insert** | Press `i` | Type and edit text |
| **Visual** | Press `v` | Select text |
| **Command** | Press `:` | Run commands like save and quit |

> **The golden rule:** When in doubt, press `Esc` first. This always returns you to Normal mode.

## 5.3 The Essential Vim Commands

### Getting in and out

```
i          → enter Insert mode (insert before cursor)
a          → enter Insert mode (insert after cursor)
o          → open a new line below and enter Insert mode
O          → open a new line above and enter Insert mode
Esc        → return to Normal mode (press this constantly)

:w         → save the file (write)
:q         → quit (only works if no unsaved changes)
:wq        → save and quit
:q!        → quit WITHOUT saving (force quit — use when stuck)
:x         → save and quit (same as :wq)
```

### Navigation (in Normal mode)

```
h  j  k  l        → move left, down, up, right (or use arrow keys)
w                  → jump forward one word
b                  → jump backward one word
0                  → go to start of line
$                  → go to end of line
gg                 → go to first line of file
G                  → go to last line of file
:42                → go to line 42
Ctrl+f             → page down
Ctrl+b             → page up
```

### Editing (in Normal mode)

```
dd         → delete (cut) the current line
5dd        → delete 5 lines
yy         → yank (copy) the current line
5yy        → copy 5 lines
p          → paste after cursor
P          → paste before cursor
u          → undo
Ctrl+r     → redo
x          → delete the character under cursor
r          → replace one character
```

### Search and replace (in Normal mode / Command mode)

```
/pattern          → search forward for "pattern"
?pattern          → search backward for "pattern"
n                 → next match
N                 → previous match

:%s/old/new/g     → replace all occurrences in the whole file
:%s/old/new/gc    → replace with confirmation for each match
:5,10s/old/new/g  → replace in lines 5 to 10
```

### Workflow to edit a config file on a server

```
vim /etc/nginx/nginx.conf    # open the file
/server_name                 # search for "server_name"
n                            # jump to next match
i                            # enter insert mode
# make your edit
Esc                          # back to normal mode
:wq                          # save and quit
```

> **Tip:** If you accidentally get stuck in a strange mode, press `Esc` repeatedly until you're back in Normal mode, then `:q!` to exit without saving.

---

# 📔 Chapter 6 — Users & Groups

## 6.1 The Linux User Model

Linux is a **multi-user operating system.** Every process, every file, every action belongs to a user. This is the foundation of Linux security.

**Three categories of users:**

| Type | UID range | Description |
|---|---|---|
| **Root** | 0 | The superuser. Unlimited power. Can do anything. |
| **System users** | 1–999 | Created by the OS for running services (e.g. `www-data` for nginx). No login shell. |
| **Regular users** | 1000+ | Human users like you. Limited privileges. |

## 6.2 Key User-Related Files

### `/etc/passwd` — User database

Every user account is a line in this file:

```
username:x:UID:GID:comment:home_directory:shell
```

Example:
```
alice:x:1001:1001:Alice Smith:/home/alice:/bin/bash
```

- `alice` — username
- `x` — password stored in `/etc/shadow` (not here)
- `1001` — User ID (UID)
- `1001` — Primary Group ID (GID)
- `Alice Smith` — comment/description
- `/home/alice` — home directory
- `/bin/bash` — default shell

### `/etc/shadow` — Encrypted passwords

Only readable by root. Contains the actual hashed passwords and password expiry settings. You don't edit this directly.

### `/etc/group` — Group database

```
groupname:x:GID:member1,member2
```

Example:
```
developers:x:1005:alice,bob,carol
```

## 6.3 Managing Users

```bash
# Create a new user (with home directory)
sudo useradd -m alice

# Create a user with a specific shell
sudo useradd -m -s /bin/bash alice

# Create a user with a comment/description
sudo useradd -m -c "Alice Smith" alice

# Set a password for a user
sudo passwd alice

# Modify a user — change their shell
sudo usermod -s /bin/zsh alice

# Modify a user — change their home directory
sudo usermod -d /new/home alice

# Lock a user account (disable login)
sudo usermod -L alice

# Unlock a user account
sudo usermod -U alice

# Delete a user (keeps their home directory)
sudo userdel alice

# Delete a user AND their home directory
sudo userdel -r alice

# See info about a user
id alice
```

## 6.4 Managing Groups

```bash
# Create a new group
sudo groupadd developers

# Add a user to a group
sudo usermod -aG developers alice

# (IMPORTANT: -a means APPEND. Without -a, you replace all groups)

# Add a user to multiple groups
sudo usermod -aG developers,docker,sudo alice

# Remove a user from a group
sudo gpasswd -d alice developers

# Change a user's primary group
sudo usermod -g developers alice

# Delete a group
sudo groupdel developers

# See what groups a user belongs to
groups alice
id alice
```

## 6.5 Switching Users

```bash
# Switch to another user (requires their password)
su alice

# Switch to root
su -

# Switch to a user with their full environment loaded (preferred)
su - alice

# Exit back to previous user
exit
```

## 6.6 sudo — Executing Commands as Root

**sudo** = "superuser do" — it lets an authorised regular user run a single command with root privileges, without becoming root.

```bash
# Run a single command as root
sudo apt update

# Open a root shell (be careful)
sudo -i

# Run a command as a specific user
sudo -u bob ls /home/bob

# See what sudo commands you're allowed to run
sudo -l
```

### The sudoers file

The file `/etc/sudoers` controls who can use `sudo` and what they can do. **Always edit it with `visudo`** — it validates syntax before saving, preventing a broken sudoers from locking you out.

```bash
sudo visudo
```

Common sudoers entries:

```
# Give alice full sudo access
alice ALL=(ALL:ALL) ALL

# Give alice sudo without a password prompt
alice ALL=(ALL) NOPASSWD: ALL

# Let the "developers" group use sudo
%developers ALL=(ALL:ALL) ALL
```

Format: `user  host=(run-as-user:run-as-group)  commands`

---

# 📃 Chapter 7 — File Permissions

## 7.1 Why Permissions Exist

Linux permissions control **who can read, write, or execute a file.** Every file and directory has:
- An **owner** (a user)
- A **group** (a group)
- **Permissions** for three categories: the owner, the group, and everyone else

## 7.2 Reading Permissions

Run `ls -l` and you see something like:

```
-rwxr-xr--  1  alice  developers  4096  Jan 15 10:30  script.sh
```

Breaking down that first field, `-rwxr-xr--`:

| Position | Character | Meaning |
|---|---|---|
| 1 | `-` | File type: `-` = regular file, `d` = directory, `l` = symlink |
| 2-4 | `rwx` | **Owner** permissions: read, write, execute |
| 5-7 | `r-x` | **Group** permissions: read, no write, execute |
| 8-10 | `r--` | **Others** permissions: read only |

**The three permission bits:**

| Letter | Permission | On a file | On a directory |
|---|---|---|---|
| `r` | Read | View file contents | List directory contents |
| `w` | Write | Modify file contents | Create/delete files inside |
| `x` | Execute | Run as a program | Enter (cd into) the directory |
| `-` | No permission | — | — |

## 7.3 The Octal (Numeric) System

Each permission is a bit. Three bits = one octal digit per category.

| Symbol | Binary | Octal | Permission |
|---|---|---|---|
| `---` | 000 | 0 | None |
| `--x` | 001 | 1 | Execute only |
| `-w-` | 010 | 2 | Write only |
| `-wx` | 011 | 3 | Write + Execute |
| `r--` | 100 | 4 | Read only |
| `r-x` | 101 | 5 | Read + Execute |
| `rw-` | 110 | 6 | Read + Write |
| `rwx` | 111 | 7 | Read + Write + Execute |

**Reading `rwxr-xr--` as octal:**

```
Owner: rwx = 4+2+1 = 7
Group: r-x = 4+0+1 = 5
Other: r-- = 4+0+0 = 4
Result: 754
```

**Most common permission combinations:**

| Octal | Symbol | Typical use |
|---|---|---|
| `644` | `rw-r--r--` | Regular files — owner can edit, everyone can read |
| `755` | `rwxr-xr-x` | Scripts and executables |
| `600` | `rw-------` | Private files (SSH keys) — owner only |
| `700` | `rwx------` | Private scripts — owner only |
| `777` | `rwxrwxrwx` | **Avoid** — everyone can do everything |

## 7.4 Changing Permissions with `chmod`

```bash
# Symbolic method
chmod u+x script.sh        # add execute for user (owner)
chmod g+w file.txt         # add write for group
chmod o-r file.txt         # remove read from others
chmod a+r file.txt         # add read for all (user, group, others)
chmod u+x,g-w file.txt     # multiple changes at once

# Octal method (most common in practice)
chmod 755 script.sh        # rwxr-xr-x
chmod 644 file.txt         # rw-r--r--
chmod 600 ~/.ssh/id_rsa    # rw------- (SSH keys MUST be 600)
chmod 700 private_script.sh # rwx------

# Recursive — apply to directory and all contents
chmod -R 755 /var/www/html/
```

**Symbolic method key:**

| Symbol | Who | | Symbol | What |
|---|---|---|---|---|
| `u` | user (owner) | | `+` | add permission |
| `g` | group | | `-` | remove permission |
| `o` | others | | `=` | set exactly |
| `a` | all | | | |

## 7.5 Changing Ownership with `chown` and `chgrp`

```bash
# Change owner of a file
sudo chown alice file.txt

# Change owner and group
sudo chown alice:developers file.txt

# Change only the group
sudo chgrp developers file.txt
# or
sudo chown :developers file.txt

# Recursive — change owner of directory and all contents
sudo chown -R alice:developers /var/www/html/
```

## 7.6 Special Permissions

### SUID (Set User ID) — Octal: 4xxx

When set on an *executable*, it runs as the **file's owner**, not the user who ran it.

```bash
# The passwd command uses SUID to write to /etc/shadow as root
ls -la /usr/bin/passwd
# -rwsr-xr-x  root  root  ... passwd
# The 's' in owner's execute position = SUID

# Set SUID
chmod u+s script.sh
chmod 4755 script.sh
```

### SGID (Set Group ID) — Octal: 2xxx

On an *executable*: runs as the file's **group**. On a *directory*: new files inherit the directory's group.

```bash
# Set SGID on a shared directory so all files get the same group
chmod g+s /shared/
chmod 2755 /shared/
```

### Sticky Bit — Octal: 1xxx

On a directory: users can only **delete their own files**, even if they have write permission to the directory. Used on `/tmp`.

```bash
ls -la /tmp
# drwxrwxrwt  ... tmp
# The 't' = sticky bit

# Set sticky bit
chmod +t /shared/
chmod 1777 /shared/
```

---

# 📑 Chapter 8 — Data Redirection and Manipulation

## 8.1 Standard Streams

Every Linux process has three default communication channels:

| Stream | Name | FD | Default |
|---|---|---|---|
| **stdin** | Standard Input | 0 | Keyboard |
| **stdout** | Standard Output | 1 | Terminal screen |
| **stderr** | Standard Error | 2 | Terminal screen |

**FD = File Descriptor** — a number the OS uses to refer to the stream.

## 8.2 Redirection Operators

### Output redirection

```bash
# Redirect stdout to a file (overwrites the file)
ls -la > file_list.txt

# Redirect stdout to a file (appends — keeps existing content)
echo "new line" >> file.txt

# Redirect stderr to a file
grep "error" /var/log/syslog 2> errors.txt

# Redirect both stdout and stderr to a file
command > output.txt 2>&1
# or (shorthand in bash)
command &> output.txt

# Discard output completely (send to the black hole)
command > /dev/null
command 2> /dev/null
command &> /dev/null
```

> `/dev/null` is the black hole of Linux. Anything written to it disappears. Very useful for suppressing noisy output you don't care about.

### Input redirection

```bash
# Feed a file into a command's stdin
sort < unsorted.txt

# Use a "here document" — provide multi-line input inline
cat << EOF
Line 1
Line 2
Line 3
EOF

# Here string — feed a single string as stdin
grep "pattern" <<< "some string to search"
```

### Pipe vs Redirection — the difference

```
command1 | command2     → connects stdout of command1 to stdin of command2 (between programs)
command > file          → redirects stdout of command to a file (to disk)
command < file          → redirects file content to stdin of command (from disk)
```

## 8.3 Practical Redirection Examples

```bash
# Save the output of a long-running command to a file AND see it live
command | tee output.txt

# Append to a file AND see output live
command | tee -a output.txt

# Run a script and log both its output and errors
./deploy.sh > deploy.log 2>&1

# Search a huge log file without displaying errors for unreadable files
grep "error" /var/log/* 2>/dev/null

# Count errors in today's log and save the count
grep -c "ERROR" app.log > error_count.txt
```

## 8.4 `tee` — Split Output

`tee` sends output to **both a file AND the terminal simultaneously.**

```bash
# See output on screen and save to file at the same time
ls -la | tee directory_listing.txt

# Append mode
ps aux | tee -a process_snapshot.txt
```

## 8.5 `xargs` — Build Commands from Input

`xargs` takes input (usually from a pipe) and uses it as arguments for another command.

```bash
# Find all .tmp files and delete them
find /tmp -name "*.tmp" | xargs rm

# Find all .log files and count their lines
find . -name "*.log" | xargs wc -l

# Download multiple URLs from a file
cat urls.txt | xargs wget

# Handle filenames with spaces safely (-I replaces {} with input)
find . -name "*.txt" | xargs -I {} cp {} /backup/
```

---

# 📋 Chapter 9 — Process Management & System Monitoring

## 9.1 What is a Process?

A **process** is a running instance of a program. Every time you run a command, a process is created. Linux tracks every process with a unique **PID (Process ID)**.

Every process also has a **PPID (Parent Process ID)** — the process that spawned it. All processes ultimately descend from PID 1 (`systemd` on modern Linux).

## 9.2 Viewing Processes

```bash
# Snapshot of all running processes
ps aux

# Column meanings:
# USER  PID  %CPU  %MEM  VSZ  RSS  TTY  STAT  START  TIME  COMMAND
# USER = owner, PID = process ID, %CPU = CPU usage, %MEM = memory
# STAT: R=running, S=sleeping, Z=zombie, D=uninterruptible sleep

# Process tree (see parent-child relationships)
pstree

# Search for a process by name
ps aux | grep nginx
pgrep nginx          # just the PIDs

# Real-time process viewer (like Task Manager)
top

# Better real-time viewer (install with: sudo apt install htop)
htop
```

### Reading `top`

Press `top` and you see a live dashboard. Key fields:
- `%Cpu(s)`: CPU usage split by user/system/idle
- `MiB Mem`: total, used, and free RAM
- `load average: 0.1, 0.2, 0.3` — system load over last 1, 5, and 15 minutes. If load > number of CPUs, you have a bottleneck.
- Press `P` = sort by CPU, `M` = sort by memory, `q` = quit

## 9.3 Managing Processes

```bash
# Kill a process by PID
kill PID
kill 1234

# Force kill (SIGKILL — cannot be ignored)
kill -9 PID

# Kill by name
killall nginx
pkill nginx

# Send other signals
kill -HUP PID      # reload (many services reload config on SIGHUP)
kill -TERM PID     # graceful terminate (same as kill with no flag)

# Find PID of a process
pgrep nginx
pidof nginx

# Run a process in the background
command &

# List background jobs
jobs

# Bring background job to foreground
fg %1

# Suspend a running process (Ctrl+Z sends it to background)
Ctrl+Z
bg %1       # resume it in background
fg %1       # bring it to foreground

# Run a process that continues after you log out
nohup command &
nohup ./long_script.sh > output.log 2>&1 &
```

## 9.4 System Monitoring

```bash
# Memory usage
free -h
# -h = human-readable (shows MB, GB)

# Disk I/O stats
iostat         # install with: sudo apt install sysstat
iotop          # real-time disk I/O by process (requires root)

# Network connections
netstat -tuln    # listening TCP/UDP ports (install: sudo apt install net-tools)
ss -tuln         # same but newer and faster (built-in)
ss -tulnp        # include process names

# Network traffic in real-time
iftop          # install with: sudo apt install iftop
nethogs        # traffic by process

# CPU and memory over time
vmstat 1        # stats every 1 second
vmstat 1 10     # 10 readings, one per second

# System load and uptime
uptime
cat /proc/loadavg

# Log monitoring
tail -f /var/log/syslog          # system log
tail -f /var/log/auth.log        # login/sudo events
journalctl -f                    # systemd journal live
journalctl -u nginx              # logs for a specific service
journalctl --since "1 hour ago"  # last hour of logs
```

## 9.5 `systemctl` — Managing Services

Modern Linux uses **systemd** to manage services. `systemctl` is how you control it.

```bash
# Start a service
sudo systemctl start nginx

# Stop a service
sudo systemctl stop nginx

# Restart a service
sudo systemctl restart nginx

# Reload config without restarting (if supported)
sudo systemctl reload nginx

# Check if a service is running
systemctl status nginx

# Enable a service to start on boot
sudo systemctl enable nginx

# Disable a service from starting on boot
sudo systemctl disable nginx

# See all running services
systemctl list-units --type=service --state=running

# See failed services
systemctl --failed
```

---

# 📝 Chapter 10 — Environment Variables

## 10.1 What are Environment Variables?

**Environment variables** are **named values stored in the shell's environment** that programs can read. They configure the behaviour of the shell and applications without hardcoding values into scripts.

Think of them as global settings for your session.

## 10.2 Common Built-in Variables

| Variable | What it stores |
|---|---|
| `$PATH` | Colon-separated list of directories the shell searches when you type a command |
| `$HOME` | Path to the current user's home directory (`/home/username`) |
| `$USER` | The current user's username |
| `$SHELL` | Path to the current shell (`/bin/bash`) |
| `$PWD` | The current working directory (same as `pwd` command) |
| `$HOSTNAME` | The machine's hostname |
| `$LANG` | Default system language and locale |
| `$EDITOR` | Default text editor (used by `git commit`, `crontab -e`, etc.) |
| `$UID` | User ID of the current user |

## 10.3 Reading and Setting Variables

```bash
# Print a single variable
echo $HOME
echo $PATH
echo $USER

# Print all environment variables
env
printenv

# Print a specific variable with printenv
printenv HOME

# Set a variable in the CURRENT shell session only
MY_VAR="hello"
echo $MY_VAR

# Export a variable so child processes inherit it
export MY_VAR="hello"
export JAVA_HOME=/usr/lib/jvm/java-11

# Verify it's set
echo $JAVA_HOME

# Unset a variable
unset MY_VAR
```

> **The key difference:**
> - `MY_VAR="hello"` — only the current shell can see it.
> - `export MY_VAR="hello"` — the current shell AND any programs it runs can see it.

## 10.4 Making Variables Permanent

Variables set with `export` disappear when you close the terminal. To make them permanent, add them to your shell's configuration file.

### For Bash: `~/.bashrc`

```bash
# Open .bashrc
vim ~/.bashrc

# Add at the bottom:
export JAVA_HOME=/usr/lib/jvm/java-11
export PATH=$PATH:$JAVA_HOME/bin
export EDITOR=vim

# Apply changes without restarting the terminal
source ~/.bashrc
# or
. ~/.bashrc
```

### For Zsh: `~/.zshrc`

```bash
vim ~/.zshrc
# Add the same export lines
source ~/.zshrc
```

### For system-wide variables (all users): `/etc/environment`

```bash
sudo vim /etc/environment
# Add:
JAVA_HOME=/usr/lib/jvm/java-11
```

## 10.5 `$PATH` — The Most Important Variable

`$PATH` is a colon-separated list of directories. When you type any command, the shell searches each directory in `$PATH` in order and runs the first match it finds.

```bash
# See your current PATH
echo $PATH
# Output: /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Add a new directory to PATH (append to existing)
export PATH=$PATH:/opt/my-tool/bin

# Prepend (searches this first)
export PATH=/opt/my-tool/bin:$PATH

# Which directory does a command come from?
which python3
# /usr/bin/python3
```

> **If you get "command not found":** The tool is either not installed, or it's installed somewhere that's not in your `$PATH`. Check both.

---

# 🖥️ Chapter 11 — Bash vs Zsh, and Shell Config Files

## 11.1 Bash vs Zsh

| Feature | Bash | Zsh |
|---|---|---|
| **Default on** | Most Linux distros | macOS (since Catalina) |
| **Scripting** | The standard for scripts | Compatible but less common |
| **Plugins** | Limited built-in | Oh-My-Zsh gives rich plugins |
| **Auto-complete** | Basic | More powerful |
| **History** | Per session | Shared, more configurable |
| **Best for** | Server scripts, remote work | Local development terminal |

> **Rule of thumb:** Write your scripts in `#!/bin/bash` for portability — every Linux server has Bash. Use Zsh locally for a better interactive experience.

## 11.2 Shell Configuration Files

When you open a terminal, your shell reads configuration files to set up your environment. Understanding which file to edit matters.

### Bash files

| File | When it's read | Use it for |
|---|---|---|
| `~/.bashrc` | Every interactive non-login shell (new terminal tab) | Aliases, functions, custom prompt |
| `~/.bash_profile` | Login shells (SSH sessions) | Environment variables that need to be set once |
| `~/.bash_aliases` | Manually sourced from `.bashrc` | Keeping aliases organised |
| `/etc/bash.bashrc` | System-wide, all users | Rarely touch this |

### Zsh files

| File | When it's read | Use it for |
|---|---|---|
| `~/.zshrc` | Every interactive Zsh shell | Everything — aliases, functions, plugins, PATH |
| `~/.zprofile` | Login shells | Same role as `.bash_profile` |

### Practical: setting up a useful `.bashrc`

```bash
vim ~/.bashrc

# ─── Add at the bottom ───────────────────────────────

# Useful aliases
alias ll='ls -la'
alias la='ls -la'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo apt update && sudo apt upgrade -y'
alias df='df -h'
alias free='free -h'
alias grep='grep --color=auto'

# Safer defaults
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Git shortcuts
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'

# Quick navigation
alias home='cd ~'
alias logs='cd /var/log'

# Set default editor
export EDITOR=vim

# Custom prompt (shows user, host, and current path)
PS1='\u@\h:\w\$ '

# ─────────────────────────────────────────────────────

source ~/.bashrc   # apply immediately
```

## 11.3 Aliases

Aliases are shortcuts for commands you type often.

```bash
# Define an alias (session only)
alias ll='ls -la'
alias update='sudo apt update && sudo apt upgrade -y'

# Remove an alias
unalias ll

# See all current aliases
alias

# Make permanent: add to ~/.bashrc
```

## 11.4 Functions in Bash

When an alias isn't enough, use a function:

```bash
# Add to ~/.bashrc

# Create a directory and immediately cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Search process list easily
psg() {
    ps aux | grep "$1"
}

# Quick backup of a file
backup() {
    cp "$1" "$1.bak"
    echo "Backed up $1 → $1.bak"
}
```

---

# 🎮 Chapter 12 — OverTheWire Bandit: Levels 0–20

> **What is Bandit?** It's a wargame at [overthewire.org/wargames/bandit/](https://overthewire.org/wargames/bandit/) that teaches Linux by making you solve puzzles. Each level gives you a password to find. You use that password to SSH into the next level. It is the best hands-on Linux practice that exists.
>
> **The rules here:** I'll give you the concept and tool for each level, plus a hint — not the direct answer. The learning happens when *you* run the commands. But if you're truly stuck, the full approach is explained.

## Setup — How to Connect

```bash
# Level 0 — connect to the game server
ssh bandit0@bandit.labs.overthewire.org -p 2220

# Password for bandit0: bandit0
# After finding the password for bandit1:
ssh bandit1@bandit.labs.overthewire.org -p 2220
```

Use a different user each level: `bandit0`, `bandit1`, `bandit2`, etc.

---

## Level 0 → 1 — Reading a file

**Task:** The password is stored in a file called `readme` in the home directory.

**Commands needed:** `ls`, `cat`

```bash
ls          # list what's here
cat readme  # read the file
```

**Concept:** `cat` prints a file's contents. This is the most basic file-reading operation.

---

## Level 1 → 2 — Filename starting with `-`

**Task:** The password is in a file called `-` (a dash).

**The problem:** `cat -` doesn't work — the shell interprets `-` as "read from stdin," not as a filename.

**Commands needed:** `cat`, path tricks

```bash
cat ./-       # use ./ to mean "in the current directory"
# or
cat < -       # use input redirection
```

**Concept:** When a filename starts with `-`, you must prefix it with `./` to tell the shell it's a file path, not an option flag.

---

## Level 2 → 3 — Filename with spaces

**Task:** The password is in a file called `spaces in this filename`.

**The problem:** The shell splits arguments on spaces.

**Commands needed:** `cat` with quoting or escaping

```bash
cat "spaces in this filename"
# or
cat spaces\ in\ this\ filename
```

**Concept:** Wrap filenames with spaces in double quotes, or escape each space with a backslash (`\`).

---

## Level 3 → 4 — Hidden file

**Task:** The password is in a hidden file inside the `inhere/` directory.

**The problem:** Hidden files start with `.` and `ls` doesn't show them by default.

```bash
cd inhere
ls -la       # -a shows hidden files
cat .hidden  # or whatever the hidden filename is
```

**Concept:** Files starting with `.` are hidden from `ls`. Use `ls -a` or `ls -la` to reveal them.

---

## Level 4 → 5 — Human-readable file

**Task:** The password is in the only **human-readable** file in the `inhere/` directory. Other files are binary.

**Commands needed:** `file`, `find`

```bash
cd inhere
file ./*            # check the type of every file
# Look for the one that says "ASCII text"
cat ./-file07       # (the actual name will vary)
```

**Concept:** The `file` command tells you what type of data a file contains — `ASCII text`, `ELF binary`, `data`, etc. Invaluable for identifying files without relying on extensions.

---

## Level 5 → 6 — File with specific properties

**Task:** The password is in a file in `inhere/` with these properties: human-readable, 1033 bytes in size, not executable.

**Commands needed:** `find`

```bash
find inhere/ -type f -size 1033c ! -executable
# -type f = regular files
# -size 1033c = exactly 1033 bytes ('c' = bytes)
# ! -executable = not executable
cat <the file find returns>
```

**Concept:** `find` is extraordinarily powerful. You can filter by type, size, permissions, date, owner, and more — in combination.

---

## Level 6 → 7 — File owned by specific user/group

**Task:** The password is somewhere on the **server** (not just home), owned by user `bandit7`, group `bandit6`, size 33 bytes.

```bash
find / -user bandit7 -group bandit6 -size 33c 2>/dev/null
# 2>/dev/null suppresses "Permission denied" errors
cat <the file find returns>
```

**Concept:** `find /` searches the entire filesystem. `2>/dev/null` discards error messages so you see only results.

---

## Level 7 → 8 — Finding a word in a file

**Task:** The password is in `data.txt`, next to the word `millionth`.

**Commands needed:** `grep`

```bash
grep "millionth" data.txt
```

**Concept:** `grep` searches a file for lines containing a pattern. The password will be on the matching line, next to the word.

---

## Level 8 → 9 — The line that appears only once

**Task:** The password in `data.txt` is the only line that appears exactly **once** (all other lines are duplicated).

**Commands needed:** `sort`, `uniq`

```bash
sort data.txt | uniq -u
# sort: required before uniq (uniq only detects adjacent duplicates)
# uniq -u: print only lines that appear ONCE
```

**Concept:** `uniq` works on *adjacent* duplicate lines, so you must `sort` first. `-u` means "unique" — show only the non-repeated lines.

---

## Level 9 → 10 — Strings in a binary file

**Task:** The password is in `data.txt`, in one of the few human-readable strings, preceded by several `=` characters.

**Commands needed:** `strings`, `grep`

```bash
strings data.txt | grep "==="
```

**Concept:** `strings` extracts all human-readable text sequences from a binary file. Pipe to `grep` to find the one with `===` prefix.

---

## Level 10 → 11 — Base64 encoded file

**Task:** The password is in `data.txt`, which is Base64 encoded.

**Commands needed:** `base64`

```bash
base64 -d data.txt
# -d = decode
```

**Concept:** **Base64** encodes binary data as text. It's used in emails, JWTs, and many config formats. `base64 -d` decodes it back. The output is the password.

---

## Level 11 → 12 — ROT13

**Task:** The password is in `data.txt`, where all lowercase and uppercase letters have been rotated by 13 positions (ROT13).

**Commands needed:** `tr`

```bash
cat data.txt | tr 'A-Za-z' 'N-ZA-Mn-za-m'
```

**Concept:** ROT13 is a simple Caesar cipher — rotate every letter 13 positions through the alphabet. `tr` translates characters: `A→N`, `B→O`, ..., `N→A`, etc. This is identical for both encode and decode (ROT13 is its own inverse).

---

## Level 12 → 13 — Decompressing a hexdump

**Task:** `data.txt` is a hexdump of a file that has been **repeatedly compressed** with multiple formats.

**Commands needed:** `xxd`, `file`, `gzip`, `bzip2`, `tar`, `mv`

This is the most complex level so far. You must:

1. Copy the file to `/tmp` so you have write access.
2. Reverse the hexdump to get a binary file.
3. Identify its type with `file`.
4. Decompress it (it might be gzip, bzip2, or tar).
5. Repeat steps 3–4 until you reach a plain text file.

```bash
mkdir /tmp/bandit12work
cp data.txt /tmp/bandit12work/
cd /tmp/bandit12work

# Reverse the hexdump
xxd -r data.txt > data.bin

# Now loop: check type, rename, decompress, repeat
file data.bin

# If file says "gzip compressed":
mv data.bin data.gz
gunzip data.gz
file data                  # check the result

# If file says "bzip2 compressed":
mv data.bin data.bz2
bunzip2 data.bz2
file data

# If file says "POSIX tar archive":
mv data.bin data.tar
tar -xvf data.tar
file <extracted file>

# Keep going until you see "ASCII text"
cat <final file>
```

**Concept:** `xxd` creates hexdumps and reverses them. Real-world files are often compressed multiple times. `file` is your guide at each step. This level teaches persistence and the complete decompression toolkit.

---

## Level 13 → 14 — SSH private key

**Task:** There is no password to find. Instead, you get an SSH **private key** (`sshkey.private`) that lets you log directly into `bandit14`.

**Commands needed:** `ssh -i`

```bash
# From bandit13's home:
ls                       # you'll see sshkey.private
ssh -i sshkey.private bandit14@localhost -p 2220
```

**Once in bandit14:**
```bash
cat /etc/bandit_pass/bandit14    # the password for this level lives here
```

**Concept:** SSH supports **key-based authentication** — instead of a password, you present a private key file. `-i` specifies the identity file. The permissions on the key must be `600` (`chmod 600 sshkey.private`) or SSH refuses to use it.

---

## Level 14 → 15 — Network: connecting to a port

**Task:** Submit the current level's password to port **30000** on localhost to get the next one.

**Commands needed:** `nc` (netcat) or `echo` + redirection

```bash
# Get the current password first
cat /etc/bandit_pass/bandit14

# Send it to the port
echo "THE_PASSWORD_HERE" | nc localhost 30000
# or
nc localhost 30000
# (then type the password and press Enter)
```

**Concept:** **Netcat (`nc`)** is the "Swiss army knife" of networking. It can open TCP/UDP connections, listen on ports, and transfer data. Used constantly in DevOps for testing if a port is open, transferring files, or debugging network services.

---

## Level 15 → 16 — SSL/TLS connection

**Task:** Submit the password to port **30001** on localhost, but it uses **SSL encryption**.

**Commands needed:** `openssl s_client` or `ncat --ssl`

```bash
openssl s_client -connect localhost:30001
# Once connected, type the current password and press Enter
```

**Concept:** Many services (HTTPS, SMTPS, etc.) wrap their communication in SSL/TLS encryption. You can't use plain `nc` — you need `openssl s_client` to open an encrypted connection.

---

## Level 16 → 17 — Port scanning

**Task:** Find which port in the range **31000–32000** is speaking SSL AND has the next credentials. Other ports speak plain text or don't respond.

**Commands needed:** `nmap`, `openssl s_client`

```bash
# Scan the port range to find open ports
nmap -p 31000-32000 localhost

# Try each open port with SSL
openssl s_client -connect localhost:<PORT>
# Submit the bandit16 password
# One port will return a private key instead of a password
```

**Concept:** **Nmap** is the standard network scanner. It discovers open ports and identifies services. In DevOps you use it to verify a service is listening, check firewall rules, or audit open ports. Save the private key it gives you (write it to a file with correct permissions) to log in to level 17.

---

## Level 17 → 18 — Comparing two files

**Task:** There are two files: `passwords.old` and `passwords.new`. The password for the next level is the **one line that differs** between them.

**Commands needed:** `diff`

```bash
diff passwords.old passwords.new
# Lines marked with < are in old, > are in new
# The new line is the password
```

**Concept:** `diff` compares two files line by line and shows what's different. Essential for comparing configs, log files, or any two versions of a file.

---

## Level 18 → 19 — The `.bashrc` trap

**Task:** The password is in `readme` in the home directory, but as soon as you SSH in, you get logged out immediately. The `.bashrc` has been modified to log you out.

**Commands needed:** SSH with a command argument

```bash
# SSH but run a command instead of starting an interactive shell
ssh bandit18@bandit.labs.overthewire.org -p 2220 'cat readme'
# OR
ssh bandit18@bandit.labs.overthewire.org -p 2220 'ls'
```

**Concept:** SSH can run a single command instead of opening an interactive shell — just add the command in quotes after the host. This bypasses the `.bashrc` entirely. This is how automation tools (Ansible, deployment scripts) run commands on remote servers.

---

## Level 19 → 20 — SUID binary

**Task:** There's a SUID binary in the home directory. Use it to read the password file.

**Commands needed:** `ls -la`, execute the binary

```bash
ls -la                      # notice the setuid binary
./bandit20-do               # run it without arguments to see how it works
./bandit20-do cat /etc/bandit_pass/bandit20
```

**Concept:** **SUID (Set User ID)** means the binary runs as its **owner** (bandit20) regardless of who executes it. So you (bandit19) can run a command *as* bandit20 by using the binary — which lets you read a file only bandit20 can read. This is how `sudo` and `passwd` work under the hood.

---

## Level 20 → 21 — Network daemon and SUID

**Task:** There's a SUID binary that connects to a port you specify and reads the current level's password from you. If it matches, it sends back the next level's password. You must set up a listener on one terminal and run the binary from another.

**Commands needed:** `nc -l`, background processes, `screen` or two SSH sessions

```bash
# In terminal 1 (set up a listener on any free port, e.g. 9999):
echo "bandit20_password_here" | nc -l -p 9999

# In terminal 2 (run the SUID binary pointing to your listener):
./suconnect 9999
```

**Concept:** This requires running two things simultaneously — a listener and a connector. This is network programming 101: one side listens, the other connects. It also reinforces SUID and how processes communicate over TCP. You can use `screen` (a terminal multiplexer) to run both in one SSH session.

---

# 🔧 Chapter 13 — Quick Reference Cheat Sheet

## Navigation

```bash
pwd                    # where am I?
ls -la                 # list all files (including hidden) with details
cd ~                   # go home
cd -                   # go back to previous directory
cd ..                  # up one level
find . -name "*.txt"   # find files by name
```

## File Operations

```bash
touch file.txt         # create empty file
mkdir -p a/b/c         # create nested dirs
cp -r src/ dst/        # copy directory
mv old new             # move/rename
rm -rf dir/            # delete directory (no undo!)
cat file.txt           # print file
less file.txt          # page through file
head -n 20 file.txt    # first 20 lines
tail -f file.txt       # follow live output
```

## Text Processing

```bash
grep -r "pattern" .                    # search recursively
grep -i "error" file.txt               # case-insensitive
awk -F: '{print $1}' /etc/passwd       # print column 1
sed -i 's/old/new/g' file.txt          # find and replace in file
sort file.txt | uniq -c | sort -rn     # count occurrences, most frequent first
cut -d',' -f2 file.csv                 # cut column 2 from CSV
wc -l file.txt                         # count lines
```

## Permissions

```bash
ls -la                                 # see permissions
chmod 755 script.sh                    # rwxr-xr-x
chmod 644 file.txt                     # rw-r--r--
chmod 600 ~/.ssh/id_rsa               # private key permissions
chown alice:developers file.txt        # change owner:group
chmod -R 755 /var/www/html/            # recursive chmod
```

## Users & Groups

```bash
id                             # who am I, what groups?
whoami                         # just the username
sudo command                   # run as root
su - alice                     # switch to alice
useradd -m alice               # create user
passwd alice                   # set password
usermod -aG sudo alice         # add alice to sudo group
groups alice                   # see alice's groups
```

## Processes

```bash
ps aux | grep nginx            # find nginx processes
kill -9 PID                    # force kill
top                            # live process monitor
htop                           # better live monitor
systemctl status nginx         # service status
systemctl restart nginx        # restart service
nohup ./script.sh &            # run detached from terminal
```

## Redirection

```bash
command > file.txt             # stdout to file (overwrite)
command >> file.txt            # stdout to file (append)
command 2> error.txt           # stderr to file
command &> all.txt             # stdout + stderr to file
command1 | command2            # pipe output to next command
command | tee file.txt         # output to screen AND file
```

## Environment Variables

```bash
echo $PATH                     # print PATH
export MY_VAR="value"          # set and export variable
source ~/.bashrc               # reload shell config
printenv                       # list all env vars
unset MY_VAR                   # delete variable
```

## Networking

```bash
ip a                           # show IP addresses
ss -tuln                       # show listening ports
ping google.com                # test connectivity
nc -zv host 80                 # test if port is open
curl -I https://example.com    # HTTP headers
wget https://example.com/file  # download file
ssh user@host -p 22            # connect via SSH
scp file.txt user@host:/tmp/   # copy file to remote host
```

## Archiving

```bash
tar -czvf archive.tar.gz dir/  # compress directory
tar -xzvf archive.tar.gz       # extract
gzip file.txt                  # compress file
gunzip file.txt.gz             # decompress
```

---

# 📌 Appendix — Being Hireable: What You Must Be Fluent In

A hiring manager or technical interviewer will expect you to demonstrate these **without hesitation:**

1. **Navigate the file system** — `pwd`, `ls -la`, `cd`, absolute vs relative paths, `find`.
2. **Read and write files** — `cat`, `less`, `head`, `tail -f`, `vim` (open, edit, save, quit), `echo >`, `>>`.
3. **Permissions** — read `ls -l` output, explain what `rwxr-xr--` means, use `chmod` (symbolic and octal), `chown`, know when a key needs `600`.
4. **Users and groups** — `useradd`, `usermod -aG`, `sudo`, `su`, read `/etc/passwd`, `id`.
5. **Text tools** — `grep -r`, `grep -v`, `awk '{print $N}'`, `sed 's/old/new/g'`, `sort | uniq -c`, `cut`, `wc -l`.
6. **Pipes** — chain three or more commands into a pipeline without hesitation.
7. **Redirection** — `>`, `>>`, `2>`, `&>`, `/dev/null`.
8. **Process management** — `ps aux | grep`, `kill -9`, `systemctl status/start/stop/restart/enable`.
9. **Monitoring** — `top`, `free -h`, `df -h`, `tail -f /var/log/syslog`, `ss -tuln`.
10. **Environment variables** — `export`, `$PATH`, make permanent in `.bashrc`, `source`.
11. **SSH** — connect (`ssh user@host -p PORT`), copy files (`scp`), use key auth (`ssh -i key`), understand `~/.ssh/authorized_keys`.
12. **Bandit levels 0–20** — completing these proves you can apply everything above under pressure.
