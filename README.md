# Flat Fading Wireless Channel Simulation

## Description
This project simulates a realistic wireless channel in an outdoor urban environment using MATLAB. It models:

- **Path Loss** via the log-distance model
- **Shadowing** using a log-normal distribution (slow fading)
- **Rayleigh Fading** using Clarke’s model (fast fading)

The simulation includes statistical validation through histograms and spectral analysis compared to theoretical expectations.

---

## Project Structure

- `code/`: Contains the main MATLAB script (`Kiner_FlatFadingv18.m`) and supplemental code for AWGN
- `report/`: Final PDF write-up
- `figures/`: Example plots of simulation results
- `LICENSE`: Project license

---

## Features

- Realistic simulation of wireless fading phenomena
- Validation via:
  - Shadowing PDF
  - Rayleigh amplitude PDF
  - Power Spectral Density (PSD) vs. Jakes’ theoretical spectrum
- Clean, modular, and reproducible MATLAB code

---

## How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/SaganDog/FlatFadingWirelessChannel.git
   cd FlatFadingWirelessChannel/code
