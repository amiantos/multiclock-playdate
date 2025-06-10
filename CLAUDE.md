# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This is a Playdate game project. There are no standard build/test commands as this uses the Playdate SDK's development workflow.

## Architecture Overview

MultiClock is a Playdate game that displays time using 24 animated analog clocks arranged in a 4x6 grid. Each digit of the time (HH:MM) is represented by 6 clocks in specific formations.

### Core Components

- **main.lua**: Entry point containing the main game loop, clock grid management, theme system, and action queue for animations
- **Clock.lua**: Wrapper class that manages a single clock unit (face + hour/minute hands)  
- **ClockHand.lua**: Sprite-based animated clock hand that moves between degree positions using image tables
- **Patterns.lua**: Defines digit patterns (0-9) and decorative patterns as arrays of hand positions
- **Action.lua**: Simple action/animation system for sequencing functions with delays

### Key Architecture Details

The game uses a 24-clock grid organized into 4 groups of 6 clocks each, representing the 4 digits of time display. Clock hands animate by moving through frames in image tables, with degree-to-frame conversion for positioning.

The main game loop runs different behaviors based on crank state:
- Crank docked: Runs automated action sequences (time display, random patterns, decorative animations)
- Crank undocked: Manual control of clock hand rotation

Themes are supported with different image assets for clock faces, hands, and backgrounds. The current themes are "default" (black background) and "defaultReversed" (white background).

### File Structure

- `source/images/themes/`: Theme assets (face.png, hourHands.gif, minuteHands.gif)
- `source/images/`: Background images and other graphics
- Pattern definitions use degree values (0-359) for hand positions
- Game uses 30 FPS timing (delays converted from seconds to ticks)