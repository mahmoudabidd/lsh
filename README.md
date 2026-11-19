# lsh — a small Unix shell in C

A minimal, from-scratch command-line shell written in C, following the classic
*Write a Shell in C* exercise. It reads a line, splits it into arguments, checks
for builtins, and otherwise forks a child process to run the command.

Written mostly to learn how a shell actually works: process creation, `exec`,
`waitpid`, and manual memory management.

## Features

- Interactive prompt (`> `)
- Dynamic line reading — the input buffer grows as needed
- Tokenization of arguments on whitespace
- `fork` + `execvp` + `waitpid` for external commands
- Three builtins: `cd`, `help`, `exit`

## Not implemented (yet)

These are intentionally out of scope for the moment:

- Pipes (`|`), redirection (`>`, `<`), and command chaining (`&&`, `;`)
- Quoting and escaping (`"a b"`, `'...'`, `\ `)
- Background jobs (`&`), signals, and job control
- Environment variable expansion (`$HOME`), globbing (`*.c`), and `~`
- Multi-line input and command history

## Build

The project depends on POSIX APIs (`fork`, `unistd.h`, `sys/wait.h`), so it
does **not** build in a plain Windows terminal — use WSL, Linux, or macOS.

### With `make`

```sh
make          # builds ./lsh
make run      # builds and starts it
make clean    # removes the binary
```

### Or directly with gcc/clang

```sh
cc -Wall -Wextra -std=c11 -O2 -o lsh shell.c
./lsh
```

## Usage

```sh
$ ./lsh
> help
this is LSH
Type program names and arguments, and hit enter.
The following are builtin:
  cd
  help
  exit
Use the man command for information on other programs.
> ls -la
> cd ..
> echo hello world
hello world
> exit
```

Passing `exit` (or sending EOF with `Ctrl+D`) leaves the shell with status `0`.

## How it works

| Function          | Role                                                       |
| ----------------- | ---------------------------------------------------------- |
| `lsh_loop`        | The REPL: prompt, read, parse, execute                     |
| `lsh_read_line`   | Reads a line from `stdin` into a growing heap buffer       |
| `lsh_split_line`  | Splits the line into a `NULL`-terminated argv array        |
| `lsh_execute`     | Dispatches to a builtin, or falls back to `lsh_launch`     |
| `lsh_launch`      | `fork`s, `execvp`s in the child, `waitpid`s in the parent  |
| `lsh_cd`          | Builtin — wraps `chdir`                                    |
| `lsh_help`        | Builtin — prints usage                                     |
| `lsh_exit`        | Builtin — returns `0` to end the loop                      |

Builtins live in a lookup table (`builtin_str` / `builtin_func`), so adding a new
one means writing the function and appending one entry to each array.

## Notes on memory

`lsh_read_line` and `lsh_split_line` both return heap memory owned by the caller,
and `lsh_loop` frees both each iteration. `lsh_split_line` stores pointers *into*
the line buffer, so the line must stay alive until the command has finished
executing — freeing the line first would leave dangling `argv` entries.

## License

MIT — see [LICENSE](LICENSE).
