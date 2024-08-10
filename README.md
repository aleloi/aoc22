# What?
Me trying out Zig through [AoC 2022](https://adventofcode.com/2022). Tested with Zig 0.13.

# Build and run:

```bash
zig build -Dday=02  # builds day 2 and puts it in ./zig-out/bin/02
zig build check     # builds all days without generating a binary
zig build -Dday=02 -Doptimize=ReleaseFast   # no debug symbols, no msan/ubsan
./zig-out/bin/02    # run day 2
```

The `zig bulid check` setup enables to automatically show all errors
in your editor with LSP:
https://kristoff.it/blog/improving-your-zls-experience/

# Other solvers:
https://github.com/fjebaker/advent-of-code-2022/ (days 1-21)
https://github.com/pseudocc/advent-of-code-zig-2022/ (days 1-7)
