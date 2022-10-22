# 6502 test suite

BBC Micro-oriented 6502 test suite, for testing under-documented
corners of the 6502.

For testing my BBC emulator, I've long used
[Wolfgang Lorenz's test suite](https://github.com/tom-seddon/b2/tree/master/etc/testsuite-2.15),
which checks the NMOS 6502 behaviour including (crucially) illegal
opcodes and ADC/SBC BCD operations with invalid values. But it's never
been run on genuine Acorn hardware, as the code is very C64-specific,
and its significant non-DRYness gets in the way of any porting effort.

I also use
[Klaus Dormann's test suite](https://github.com/Klaus2m5/6502_65C02_functional_tests),
which has some 65c02 stuff, and also comes in
[a form you can can run on the BBC Micro](https://github.com/mungre/beeb6502test).
But it doesn't test illegal opcodes.

So, this test suite attempts to fill the gaps, by being something you
can run as-is on 8-bit Acorn hardware and see it run to completion.
I've restricted it to (so far) testing just the opcodes that are known
to be consistent on the C64, which with one exception seem to be
consistent on my BBC B too.

This test suite may become more comprehensive over time.

For any comments or feedback, raise a GitHub issue
(https://github.com/tom-seddon/6502-tests/issues) or post on this
project's Stardot thread
(https://stardot.org.uk/forums/viewtopic.php?p=368026#p368026).

# running the tests on a BBC Micro (or emulator)

1. Look in `releases` folder
2. Use ssd file with newest date (Note if downloading from the GitHub
   site: don't do right click/Save as. Click the file, producing a
   mostly useless file info page, and use the Download button)
3. Run on BBC or emulator with Shift+Break

There's two versions of the tests: one for the NMOS 6502 (BBC B; BBC
B+; Electron), and one for the CMOS 65c02 (BBC Master series;
virtually all 6502 second processors). The tests auto-detect the CPU
and will run the appropriate set.

If you run the tests on real hardware, you should get no errors.
(Please raise a GitHub issue or post in the Stardot thread if you find
otherwise!)

If you run on an emulator, you may get an error, indicating that the
emulator isn't emulating the 6502 quite right. For each failing case,
you'll get test state output along these lines:

    I: O=7F A=00 X=00 Y=00 S=80 nvUBdiZc
    o: O=7F A=00 X=00 Y=00 S=00 nvUBdizc
    s: O=7F A=00 X=00 Y=00 S=00 nvUBdiZc

`I` is the input state: register/operand values before executing the
instruction. (`O` is the operand value, `A`/`X`/`Y`/`S` are the 6502
registers, and then the status register bits: upper case letter for
bits set, lower case for bits reset.)

`o` is the output state: register/operand values after having the 6502
execute the instruction.

`s` is the simulated state: register/operand values after having the
6502 simulate the instruction's expected behaviour using documented
instructions only.

# running the tests on some other system

You can modify the source code as required, and build for the target
of interest. Note how `TARGET` is set in the Makefile and used by the
code. The Acorn target would serve as an example.

Alternatively, the generic version of the test can be runtime patched.
Look in the `releases` folder and find the `6502-tests-generic` file
with the most newest date. Load this at $2000 in RAM (it is
self-modifying), and start execution by jumping to $2000.

It uses its own data, zero page between $60 and $8f, and all of
page 1. (It does not write to other areas.)

At the start of the loaded code are a set of callbacks, called as the
tests run. There's 8 bytes allocated for each, allowing space for a
short snippet of code, or a JMP to somewhere else.

The callbacks are:

## $2003 - `start_callback`

Called before the tests start. 

## $200b - `test_begin_callback`

Called when a test is about to be run. The address of the test's name,
a 0-terminated ASCII string, is held in Y (MSB) and X (LSB).

Return with carry set to run the test, or carry clear to skip it.

Default callback does `sec:rts`.

## $2013 - `test_fail_callback`

Called when a test case fails. The address of the test state is held
in Y (MSB) and X (LSB).

The test state consists of 3 state structs: input state, output state
(from having the 6502 do the test), and simulated state (from having
the 6502 simulate the test). Each state struct is 6 bytes: A, X, Y, S,
P and operand, 1 byte each.

Return with carry set to have the test state printed (see above), or
carry clear to have it fail silently (e.g., if you're going to store
the test data somewhere for later retrieval).

Default callback does `sec:rts`.

## $201b - `test_pass_callback`

Called when a test passes.

Default callback does `rts`.

## $2023 - `test_end_callback`

Called when a test finishes, pass or fail.

Default callback does `rts`.

## $202b - `finish_callback`

Called when the tests are finished. The stack will have been
overwritten so (if running on a real system) you may have to arrange
for some kind of reset.

Default callback does `jmp tests_end_callback`.

## $2033 - `print_char`

Print a single character. Control codes used are:

ASCII 8 = non-destructive backspace
ASCII 10 = line feed
ASCII 13 = carriage return

Default callback does `rts`.

# what's tested

All combinations of inputs stated are tested. 256 possible values for
operand, A, X, Y or S, and 2 possible values for C (carry flag) and D
(BCD mode).

Non-inputs are given changing values during the tests, in case this
might reveal anything surprising.

The testing for indexed addressing modes is not very comprehensive;
the index register is left at 0 for the whole test.

## NMOS

Takes about 17 minutes to run on a BBC B.

- `adc` (BCD), `SBC` (BCD) - operand, A, C
- `usbc` - operand, A, C, D
- `arr` - operand, A, C, D
- `asr` - operand, A, C
- `anc`, `anc2` - operand, A, C
- `dcp` - operand, A, C
- `isb` - operand, A, C, D
- `lax` - operand
- `lds` - operand, S
- `rla` - operand, A, C
- `rra` - operand, A, C, D
- `sax` - A, X
- `slo` - operand, A, C
- `sre` - operand, A, C

I've run this on a BBC B.

Notes:

- the tests for `lds` assume the Z flag is not set consistently
- `usbc` is compared simply against the results of running ordinary
  `sbc`

## CMOS

Takes about 35 seconds to run on a 3 MHz 65c02.

` ADC` (BCD), `SBC` (BCD) - operand, A, C

I've run this on a Master 128, external 6502 second processor, and
Master Turbo.

# building

Note that this repo has submodules: https://stackoverflow.com/questions/3796927/how-do-i-git-clone-a-repo-including-its-submodules

Prerequisites:

- [64tass](http://tass64.sourceforge.net/)
- Python 3.x
- POSIX-type system (I use macOS; on Windows, Git Bash might suffice)

To build, type `make`. The output is `.build/6502-tests.ssd` in the
working copy.

There is also a
[BeebLink](https://github.com/tom-seddon/beeblink/)-friendly volume in
the `beeb` folder in the working copy, called `6502-tests` on the
Beeb.

# licence

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.
