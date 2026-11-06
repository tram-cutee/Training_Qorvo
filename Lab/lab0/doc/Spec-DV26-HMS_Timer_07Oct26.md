# Hour-Minute-Second (HMS) Timer Specification

## Overview

Design a simple Hour-Minute-Second Timer.

### Requirements

- Output the real-time value through:
  - `h_out` (Hour)
  - `m_out` (Minute)
  - `s_out` (Second)
- Time value can be adjusted using:
  - `sel_in`
  - `up_in`
  - `down_in`
- `sel_in` selects which field to adjust (Hour, Minute, or Second).
- `up_in` increases the selected value.
- `down_in` decreases the selected value.
- A qualified low-to-high transition of `sel_in`, `up_in`, or `down_in` generates a one-clock internal trigger.
- Input clock frequency is 1 MHz.
- Reset is asynchronous active-low.

---

# I/O Definition

| Port Name | Direction | Width | Description |
|-----------|-----------|--------|-------------|
| `clk` | Input | 1 | Clock signal |
| `rstn` | Input | 1 | Reset signal (asynchronous active low) |
| `sel_in` | Input | 1 | Raw asynchronous select control input |
| `up_in` | Input | 1 | Raw asynchronous increment control input |
| `down_in` | Input | 1 | Raw asynchronous decrement control input |
| `h_out` | Output | 5 | Hour output value |
| `m_out` | Output | 6 | Minute output value |
| `s_out` | Output | 6 | Second output value |

---

# Time Format and Reset

## Time Format

- 24-hour format
- Hour: 00-23
- Minute: 00-59
- Second: 00-59
- Rollover: `23:59:59 -> 00:00:00`
- Outputs use unsigned binary encoding

## Reset Values

| Signal | Value |
|----------|-------|
| `h_out` | 0 |
| `m_out` | 0 |
| `s_out` | 0 |
| FSM State | `NORMAL` |

## Example Time Progression

| Current Time | After One-Second Tick |
|--------------|----------------------|
| 12:34:58 | 12:34:59 |
| 12:34:59 | 12:35:00 |
| 12:59:59 | 13:00:00 |
| 23:59:59 | 00:00:00 |

---

# Control Input Handling

## Synchronization

- `sel_in`, `up_in`, and `down_in` may be asynchronous to `clk`.
- Each input shall pass through a two-stage synchronizer.
- Asserted and de-asserted levels shall be stable for at least two complete clock cycles.
- Deglitching and debouncing are not supported.

## Trigger Behavior

- One `sel_in` trigger causes exactly one FSM state transition.
- One `up_in` or `down_in` trigger changes the selected field by exactly one unit.
- High-to-low transitions generate no trigger.
- Holding an input high does not generate repeated actions.
- Auto-repeat is not supported.

## Clocking

- FSM and counters update on the rising edge of `clk`.
- 1 second = exactly 1,000,000 rising edges of `clk`.

---

# FSM

## States

1. `NORMAL`
2. `HOUR_ADJ`
3. `MIN_ADJ`
4. `SEC_ADJ`

## State Transition Sequence

```text
NORMAL
  -> HOUR_ADJ
  -> MIN_ADJ
  -> SEC_ADJ
  -> NORMAL
```

## Counting While Adjusting

- Counting is paused in all adjustment states.
- The sub-second divider value is preserved.
- The divider resumes when returning to `NORMAL`.

---

# Manual Adjustment

## Rules

- One qualified edge of `up_in` or `down_in` changes the selected field by exactly one unit.
- In `NORMAL` state, `up_in` and `down_in` are ignored.

## Wrap Behavior

| State | Selected Field | Wrap on `up_in` | Wrap on `down_in` |
|---------|----------------|-----------------|-------------------|
| `HOUR_ADJ` | Hour | 23 -> 00 | 00 -> 23 |
| `MIN_ADJ` | Minute | 59 -> 00 | 00 -> 59 |
| `SEC_ADJ` | Second | 59 -> 00 | 00 -> 59 |

- Only the selected field wraps.
- No carry or borrow into adjacent fields.
- Natural timer counting still performs normal carry operations.

---

# Simultaneous Control Events

## Conflict Rule

If more than one trigger among `sel_in`, `up_in`, and `down_in` occurs on the same clock edge:

- All control events are dropped.
- FSM state remains unchanged.
- Time values remain unchanged.
- Normal counting is paused for that cycle.

## Reset Priority

`rstn` has highest priority.

When `rstn = 0`:

```text
Hour   = 0
Minute = 0
Second = 0
State  = NORMAL
```
