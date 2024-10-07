# Table of Contents

- [STTR Script - VJaBoG32](#sttr-script---vjabog32)
- [VJaBoG32 Range Management Module](#vjabog32-range-management-module)
  - [Features](#features)
  - [How to use](#how-to-use)
  - [Detailed Algorithm Design & Naming Convention](#detailed-algorithm-design--naming-convention)
- [VJaBoG32 Bombing Feedback](#vjabog32-bombing-feedback)
  - [Overview](#overview)
  - [Author](#author)
  - [Purpose](#purpose)
  - [Getting Started](#getting-started)
- [Key Classes & Functions](#key-classes--functions)
  - [Bomb Class](#bomb-class)
  - [togglevJaBoG32bombingfeedback()](#togglevjabog32bombingfeedback)
  - [BombEventHandler:onEvent(event)](#bombeventhandleroneventevent)
- [Usage](#usage)


# STTR Script - VJaBoG32

This is the Script for our Training TEmplate
Copyright (C) 2024  JaBoG32 Team
MIST is not included in this Repository but a prerequisite to use the script
- See: https://github.com/mrSkortch/MissionScriptingTools

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.


This project provides a modular framework for managing various aspects of DCS (Digital Combat Simulator) missions for the VJaBoG32 virtual squadron. The STTR script Template system is built to support mission builders by offering flexible, reusable scripts and tools for managing training ranges, bombing feedback, and other mission-critical components.

## Key Features

- **Modular Design**: Each component of the STTR Template is divided into modules that serve different functionalities, such as range management, bombing feedback, and utility functions. This ensures ease of maintenance and extensibility.
- **Extensive Configuration**: The system relies on naming conventions to categorize and manage training ranges dynamically.
- **Radio Menu System**: Automatic creation of in-game F10 radio menus for mission control, allowing real-time activation, deactivation, and configuration of training areas and feedback mechanisms.

## Modules Overview

### 1. **sttr-modules**
This directory contains the core modular scripts used in the STTR system. Each module has a specific role in managing certain aspects of DCS missions. Some key modules include:

- **Range Management Module**: Manages spawning, despawning, and rules of engagement (ROE) for AI units on designated training ranges. It uses a flexible naming convention to categorize units and build a radio menu structure dynamically.
  - This module has its own detailed README file that describes its structure, usage, and design.
  
- **Bombing Feedback Module**: Provides real-time bombing accuracy feedback during training sessions. It calculates the impact of bombs and gives pilots direct feedback through the radio menu.
  - Like the Range Management module, this also has its own dedicated README for detailed usage instructions.

- **Utility Modules**: The `utils` and `misc` modules provide helper functions, logging mechanisms, and general utility methods that are shared across the entire STTR framework.

### 2. **STTR_vJaBoG32Template_Script.lua**
This is the main entry point for loading and running the STTR framework. It orchestrates the execution of the modules and sets up the necessary components such as the radio menu, feedback loops, and range control systems.

### 3. **doc** 
This directory contains any relevant documentation that helps developers and mission builders understand, and modify the system.

### 4. **dev**
A folder  containing experimental or additional scripts used during the development process.
It also features a DCS mock API and a name checker such that you can use it from Terminal.

### Modular Approach

The modular approach allows each aspect of range management and mission control to be separated into distinct components, which can be independently updated or extended without affecting the entire system. Each module is well-structured, following a clear flow, and uses naming conventions to simplify unit categorization.

### Naming Convention

The naming convention used for categorizing units in training ranges is essential to how the Range Management Module dynamically handles spawning and management. The format is as follows:

```
country-rangeID-metagroup-id
```

Where:
- **country**: A three-letter country code (e.g., `SWE`, `USA`).
- **rangeID**: A unique identifier for the range (e.g., `ESR01`, `R92A`).
- **metagroup**: A group of units that are treated as a single spawn entity (e.g., `Artillery Group`).
- **id**: A unique ID to distinguish between different DCS groups (e.g., `01`, `02`).

### Radio Menu System

The system automatically builds a structured F10 radio menu based on the categorized groups. This allows mission builders and players to easily control range activities through an intuitive interface. For example, spawning a group or activating ROE settings can be done through this menu, simplifying the workflow during missions.

### How to Use

For mission builders, setting up the STTR system is straightforward:

1. Create a mission `.miz` file and ensure that unit groups follow the predefined naming conventions.
2. In your mission's top-level script, load the required modules and initialize the STTR main.
3. Use the F10 radio menu to control ranges, spawn AI units, and receive feedback during training.

For specific usage of the Range Management and Bombing Feedback modules, refer to their respective README files.

### Developer Guide

For developers looking to extend the STTR system, the modular approach makes it easy to add new functionalities or modify existing ones. Each module follows a clear structure and naming pattern, and shared utility functions are located in the `utils` and `misc` directories for easy access.

Feel free to explore the `sttr-modules` folder and inspect the individual scripts to understand the logic and flow. The entire system is designed to be flexible and easily integrated into other DCS mission scenarios.

---

**Happy Mission Planning!**
