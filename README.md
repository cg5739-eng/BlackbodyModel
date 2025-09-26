# BlackbodyModel  

This repository contains a **self-consistent heat transfer model in MATLAB** for exploring the behavior of blackbody thermal sources.  

The model solves the heat equation in two spatial dimensions and time, while also incorporating empirical models for thermoelectric coolers (TECs) and heat sinks. This allows for rapid evaluation of thermal spatial uniformity as a function of design parameters, as well as implementation of thermal control logic to optimize rise, settle, and slew times and improve temperature stability.  

For demonstration purposes, the examples provided here use modified physical constants and time scales (intentionally unrealistic). They show a temperature distribution at six snapshots in equally spaced time intervals. In each case, the blackbody is heated to a target temperature of **500 K**.

---
![simple model](https://github.com/user-attachments/assets/06d7d8b1-1fcf-4b75-8d1c-36bb98a61495)
*Run this version using* **`bb2D.m`**.  

The simplified model illustrates the core physical mechanisms of blackbody heating:  
- Heat diffusion  
- Radiation  
- Proportional control for temperature regulation  

This provides a minimal, approachable framework for understanding how energy flows in the system.  

---
![full model](https://github.com/user-attachments/assets/40a60c57-909b-47de-9d6d-54d95c300226)
This demonstrates what a higher-fidelity model looks like for the blackbody's surface, constrained by real-world thermal effects such as geometry, boundary conditions, and heat transfer through supporting components. The full model builds on the simplified version by adding:  
- **Square heater geometries**  
- Coupled models for TECs and heat sinks  
- Visualization of spatial temperature uniformity across the surface, as well as percentage uniformity  

This makes it possible to study how design choices and control strategies influence the performance of the blackbody, specifically in terms of uniformity and rise/settle/slew time.

*See the documentation for a detailed explanation of the mathematical principles and their implementation in the code*
