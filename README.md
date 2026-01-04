# AHB_LITE-master-
# AHB Master – SystemVerilog Verification

## Overview
This repository contains a SystemVerilog-based AHB master design along with a configurable verification environment.
The AHB master supports **all burst transfer types defined by the AMBA AHB specification**, and the transfer behavior can be dynamically controlled from the testbench without modifying the RTL.

In addition, the repository includes the **AMBA AHB specification** as a reference, making this project useful for both implementation and in-depth protocol study.

## Features
- Supports **all AHB burst transfer types (`HBURST = 000` to `111`)**
- Burst type selection is **fully configurable from the testbench**
- No RTL changes required to switch between transfer modes
- Proper AHB arbitration handling (`HBUSREQ` / `HGRANT`)
- Cycle-accurate address and data phase behavior
- Verified using waveform-based analysis

## Supported Burst Transfers
The following burst types defined by the AMBA AHB protocol are supported:

| HBURST Value | Burst Type |
|-------------|------------|
| `000` | SINGLE |
| `001` | INCR |
| `010` | INCR4 |
| `011` | WRAP4 |
| `100` | INCR8 |
| `101` | WRAP8 |
| `110` | INCR16 |
| `111` | WRAP16 |

All burst types can be selected and driven from the testbench.

## Protocol Compliance
- AMBA AHB / AHB-Lite compliant
- Correct `HTRANS` sequencing (`NONSEQ → SEQ → IDLE`)
- Supports configurable `HSIZE` (byte, halfword, word)
- Word-aligned address handling
- OKAY response handling (`HRESP = 00`)

## Verification Environment
- SystemVerilog-based testbench
- Configurable stimulus generation
- Waveform-based functional verification
- Burst and single transfers validated through simulation

## AMBA AHB Specification
The official **AMBA AHB specification** is included in this repository for reference and study.
This allows users to:
- Understand protocol timing and signal behavior
- Correlate waveform behavior with the specification
- Use the project as a learning resource for AMBA AHB

## Tools Used
- SystemVerilog
- EDA Playground (simulation)
- GTKWave (waveform analysis)

## Waveform Verification
- Verified SINGLE transfers (`HBURST = 000`)
- Verified multiple BURST transfers (`HBURST = 001` to `111`)
- Clean arbitration and transfer sequencing observed in waveforms
## EDA Playground Link

The complete AHB master design and verification environment can be simulated on EDA Playground using the link below:

🔗 **EDA Playground:**  
https://www.edaplayground.com/x/EsM7

## Author
Amrutha
