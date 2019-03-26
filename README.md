## VHDL library

A collection of hardware modules written in VHDL. This is a work in progress.

## Overview

- [common](src/common)
- [counters](src/counters)
  - [generic](src/counters/generic)
  - [modulo](src/counters/modulo)
- [display](src/display)
  - [segment](src/display/segment)
  - LCD
- [encoder](src/encoder)
- [flipflop](src/flipflop)
- [keypad](src/keypad)
- [memory](src/memory)
  - [RAM single port](src/memory/ram_sp)
  - [RAM dual port](src/memory/ram_dp)
- [register](src/register)
- [sync](src/sync)
- [timer](src/timer)
- [uart](src/uart)
  - [receive](src/uart/receive)
  - transmit
- [vendor](src/vendor)
  - [lattice](src/vendor/lattice)

## Usage

All VHDL source files should be analysed into the VHDL library `SVDB`.

```VHDL
library SVDB;
use SVDB.package_name.all;
```

## License

Distributed under the MIT License. See `LICENSE` for more information.
