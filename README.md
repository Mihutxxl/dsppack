# dsppack - Filter Design and Analysis Tool for GNU Octave

A GUI-based tool for designing, analyzing, and testing IIR and FIR digital filters.
Developed as a Diploma Project at UPT (Universitatea Politehnica Timisoara).

**Author:** Mihut Vlad  
**License:** GPLv3+  
**Version:** 1.1.0

---

## Features

- **IIR Filter Design** - Butterworth, Chebyshev Type I/II, Elliptic
- **FIR Filter Design** - Hamming, Hanning, Blackman, Kaiser windows, Parks-McClellan, Least-Squares
- **Filter Types** - Low Pass, High Pass, Band Pass, Band Stop
- **Interactive Pole-Zero Editor** - Manually add poles and zeros on the unit circle to shape the filter
- **Detailed Analysis** - Magnitude, Phase, Group Delay, Impulse Response, Step Response, Pole-Zero Diagram
- **Frequency Axis Toggle** - Switch response plots between normalized (0 to pi rad/sample) and absolute (0 to Fs/2 Hz) frequency axes
- **Stability Analysis** - BIBO stability check with pole radius and margin indicators
- **Specification Mask Overlay** - Passband ripple (Rp) and stopband attenuation (Rs) visualization
- **Filter Comparison** - Overlay two filter responses side by side
- **Audio Demo** - Load WAV files, apply filters, play original/filtered, view spectrograms
- **Code Export** - Generate MATLAB/Octave, C header, or Python/SciPy code
- **Workspace Export** - Push the designed coefficients to the Octave workspace (`num_coeffs`, `den_coeffs`, `fs_val`)
- **Report Generation** - Export a self-contained HTML report with all plots and specifications
- **Save/Load** - Persist filter designs as `.mat` files
- **Presets** - 12 built-in presets for common audio/signal processing tasks

---

## Requirements

- **GNU Octave** >= 6.0.0
- **signal** package >= 1.4.0

---

## Installation

### Option 1: Install from official GNU Octave repo

1. In Octave, install the package:
   ```octave
   pkg install -forge dsppack
   ```

2. Load the required packages:
   ```octave
   pkg load dsppack
   ```
3. Launch the tool:
   ```octave
   dsppack_launch
   ```

### Option 2: Manual setup

1. Clone or download the repository.

2. In Octave, install the package:
   ```octave
   pkg install ./dsppack/
   ```

3. Load the required packages:
   ```octave
   pkg load signal
   pkg load dsppack
   ```

4. Launch the tool:
   ```octave
   dsppack_launch
   ```

### Verifying installation

```octave
pkg list dsppack
```

You should see `dsppack` listed with version `1.1.0`.

---

## Quick Start

```octave
% Load dependencies
pkg load signal
pkg load dsppack

% Launch the GUI
dsppack_launch
```

1. Select a **Preset** from the dropdown (e.g., "Bass Isolation") or configure manually
2. Set the sampling frequency, cutoff frequency, filter order, architecture, type, and topology
3. Click **DESIGN FILTER** to compute and plot the filter response
4. Use the **Freq Axis** button (top right, above the magnitude plot) to switch the frequency axes between normalized units (0 to pi rad/sample) and absolute frequency (0 to Fs/2, labelled in Hz/kHz). The setting is shared with the Detailed Analysis window, which has the same button
5. Use the bottom bar buttons to access additional features:
   - **COMPARE FILTERS** - Compare two filter designs
   - **GENERATE REPORT** - Export an HTML report
   - **AUDIO DEMO** - Test the filter on real audio files

---

## Project Structure

```
dsppack/
  COPYING                - GPLv3 license
  DESCRIPTION            - Octave package metadata
  INDEX                  - Octave package function index
  README.md              - This file
  doc/
    user_manual.md       - User manual
    code_walkthrough.txt - Line-by-line code explanation
  inst/
    dsppack_launch.m     - Main GUI entry point
    dsp_compute_filter.m - Filter computation (IIR + FIR)
    dsp_design_callback.m - Design button handler
    dsp_plot_response.m  - Magnitude/phase plotting
    dsp_check_stability.m - BIBO stability analysis
    dsp_compute_f3db.m   - -3 dB crossing computation
    dsp_update_stability.m - Stability indicator strip update
    dsp_draw_mask.m      - Specification mask overlay
    dsp_draw_zplane.m    - Pole-zero plane rendering
    dsp_new_window.m     - Standard application window factory
    dsp_freq_xticks.m    - Frequency axis tick labelling (normalized or Hz)
    dsp_freq_axis_hz.m   - Shared frequency-axis unit toggle state
    dsp_result_window.m  - Detailed analysis window
    dsp_compare_window.m - Filter comparison window
    dsp_audio_demo.m     - Audio demo window
    dsp_code_export.m    - Code generation (MATLAB/C/Python)
    dsp_generate_report.m - HTML report generation
    dsp_save_callback.m  - Save design to .mat
    dsp_load_callback.m  - Load design from .mat
    dsp_export_callback.m - Export coefficients to workspace
    fda_pz_editor.m      - Interactive pole-zero editor
    pz_tool.m            - Standalone pole-zero tool
```

---

## Presets

| Preset | Architecture | Type | Topology | Fc | Order |
|---|---|---|---|---|---|
| Anti-aliasing (CD Audio) | IIR | Low Pass | Butterworth | 20000 Hz | 8 |
| Voice Band-pass | IIR | Band Pass | Butterworth | 300-3400 Hz | 4 |
| Bass Isolation | IIR | Low Pass | Chebyshev I | 250 Hz | 4 |
| Treble Isolation | IIR | High Pass | Butterworth | 4000 Hz | 4 |
| Sub-bass Crossover | IIR | Low Pass | Butterworth | 80 Hz | 4 |
| 50 Hz Mains Notch | IIR | Band Stop | Butterworth | 45-55 Hz | 4 |
| 60 Hz Mains Notch | IIR | Band Stop | Butterworth | 55-65 Hz | 4 |
| DC Blocker | IIR | High Pass | Butterworth | 10 Hz | 2 |
| Wideband Noise Reduction | IIR | Low Pass | Chebyshev II | 8000 Hz | 6 |
| FIR Anti-aliasing (CD Audio) | FIR | Low Pass | Hamming | 20000 Hz | 64 |
| FIR Voice Band-pass | FIR | Band Pass | Hamming | 300-3400 Hz | 48 |
| FIR Noise Suppression | FIR | Low Pass | Blackman | 4000 Hz | 48 |

---

## Changelog

### 1.1.0 (2026-07-03)

- **New: frequency axis unit toggle.** A **Freq Axis** button on the main screen and in the Detailed Analysis window switches every frequency axis between normalized units (0 to pi rad/sample) and absolute frequency (0 to Fs/2), with round tick values labelled in Hz or kHz. The setting is shared between the two windows, persists while the tool is open, and is honored by the spec-mask overlay. Implemented by the new `dsp_freq_axis_hz` helper (shared state) and an extended `dsp_freq_xticks` (tick placement).
- The Filter Comparison window deliberately keeps normalized units, since the two compared filters may have different sampling rates.
- User manual updated with the new control; README feature list, quick start, and file listing brought up to date.

### 1.0.x (2026-06-02 to 2026-07-02)

- Initial releases: IIR/FIR filter designer with presets, detailed analysis window, interactive pole-zero editor, filter comparison, audio demo, specification mask overlay, save/load, code export, HTML report generation.

---

## License

This project is licensed under the GNU General Public License v3.0. See [COPYING](COPYING) for details.
