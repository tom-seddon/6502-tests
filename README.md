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

I've written it to be (hopefully) portable without too much work, but
so far that's only a theory. Currently it is aimed at 8-bit Acorn
systems only.

# running the tests

1. Look in `releases` folder
2. Use ssd file with newest date (Note if downloading from the GitHub
   site: don't do right click/Save as. Click the file, producing a
   mostly useless file info page, and use the Download button)
3. Run on BBC or emulator with Shift+Break

There's two versions of the tests: one for the NMOS 6502 (BBC B; BBC
B+; Electron), and one for the CMOS 65c02 (BBC Master series;
virtually all 6502 second processors). The tests auto-detect the CPU
and will run the appropriate set.

If an error is found, you'll get output along these lines:

    I: O=7F A=00 X=00 Y=00 S=80 nvUBdiZc
    o: O=7F A=00 X=00 Y=00 S=00 nvUBdizc
    s: O=7F A=00 X=00 Y=00 S=00 nvUBdiZc

`I` is the input state, `o` the output state, and `s` the expected
simulated state.

The tests are not currently very automation-friendly, but this will
improve. 

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
