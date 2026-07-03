# dsppack User Manual

**Filter Design and Analysis Tool for GNU Octave**  
Version 1.0.0  
Author: Mihut Vlad

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Installation and Setup](#2-installation-and-setup)
3. [Main Window Overview](#3-main-window-overview)
4. [Designing a Filter](#4-designing-a-filter)
5. [Specification Mask Overlay](#5-specification-mask-overlay)
6. [Detailed Analysis Window](#6-detailed-analysis-window)
7. [Interactive Pole-Zero Editor](#7-interactive-pole-zero-editor)
8. [Filter Comparison](#8-filter-comparison)
9. [Audio Demo](#9-audio-demo)
10. [Saving and Loading Designs](#10-saving-and-loading-designs)
11. [Exporting Filters](#11-exporting-filters)
12. [Report Generation](#12-report-generation)
13. [Theoretical Background](#13-theoretical-background)
14. [Troubleshooting](#14-troubleshooting)

---

## 1. Introduction

**dsppack** is a graphical tool for designing and analyzing digital filters in GNU Octave.
It supports both IIR (Infinite Impulse Response) and FIR (Finite Impulse Response) architectures,
providing real-time visualization of filter characteristics and audio-based testing.

The tool is designed to be used for educational purposes and practical filter design work,
offering a workflow similar to MATLAB's Filter Design and Analysis Tool (fdatool).

### Key Capabilities

- Design IIR filters using Butterworth, Chebyshev Type I/II, and Elliptic methods
- Design FIR filters using windowed-sinc (Hamming, Hanning, Blackman, Kaiser), Parks-McClellan, and Least-Squares methods
- Analyze filters through magnitude response, phase response, group delay, impulse response, step response, and pole-zero diagrams
- Verify stability with automatic BIBO stability analysis
- Check designs against specification masks with configurable passband ripple and stopband attenuation
- Test filters on real audio files with playback and spectrogram visualization
- Export filter coefficients as MATLAB/Octave, C, or Python code
- Generate professional HTML reports
- Compare two filter designs side by side

---

## 2. Installation and Setup

### Prerequisites

1. **GNU Octave** version 6.0.0 or later (download from https://octave.org)
2. **signal package** version 1.4.0 or later

### Installing the signal package

If you do not have the signal package installed, run in Octave:

```octave
pkg install -forge signal
```

### Installing dsppack

From the Octave command line:

```octave
pkg install /path/to/dsppack/
```

Replace `/path/to/dsppack/` with the actual path to the dsppack directory.

### Launching the tool

```octave
pkg load signal
pkg load dsppack
dsppack_launch
```

The main window opens at 1920x1080 resolution. Ensure your display supports this resolution
for optimal layout.

---

## 3. Main Window Overview

The main window is divided into three areas:

### Left Panel: Filter Specifications

This panel contains all the input controls for defining a filter:

- **Preset** - Dropdown with 12 built-in filter configurations. Selecting a preset automatically fills in all parameters and designs the filter.
- **Sampling Frequency (Fs)** - The sampling rate in Hz. Must be positive.
- **Cutoff Frequency (Fc)** - The primary cutoff frequency in Hz. Must be less than Fs/2 (Nyquist frequency).
- **Cutoff Frequency 2 (Fc2)** - Used only for Band Pass and Band Stop filters. Must satisfy Fc < Fc2 < Fs/2.
- **Filter Order (N)** - The order of the filter. Higher orders give steeper rolloff but increased complexity. For FIR filters, this is the number of taps minus one.
- **Architecture** - IIR or FIR. Changing this updates the Topology dropdown.
- **Filter Type** - Low Pass, High Pass, Band Pass, or Band Stop.
- **Topology / Method** - For IIR: Butterworth, Chebyshev I, Chebyshev II, Elliptic. For FIR: Hamming Window, Hanning Window, Blackman Window, Kaiser Window, Parks-McClellan, Least-Squares.

### Right Area: Response Plots

- **Magnitude Response** (top) - Shows the filter gain in dB across frequency.
- **Stability Indicator** (middle strip) - Green for stable, red for unstable. Displays max pole radius and stability margin.
- **Phase Response** (bottom) - Shows the phase shift in degrees across frequency.
- **Freq Axis toggle** (top right, above the magnitude plot) - Switches the frequency axis of both plots between normalized units (0 to pi rad/sample) and absolute frequency (0 to Fs/2, labelled in Hz or kHz). The setting is shared with the Detailed Analysis window, which has the same button. The comparison window always uses normalized units, since its two filters may have different sampling rates.

### Bottom Bar

- **COMPARE FILTERS** - Opens the filter comparison window.
- **GENERATE REPORT** - Exports an HTML report of the current design.
- **AUDIO DEMO** - Opens the audio testing window.
- **EXIT** - Closes the application (with confirmation).

### Panel Buttons

- **Interactive P/Z Editor** - Opens the pole-zero editor for manual filter shaping.
- **DETAILED ANALYSIS** - Opens the detailed analysis window with 6 plots.
- **Save Design / Load Design** - Persist and restore filter designs as .mat files.
- **Export to Workspace** - Exports coefficients (num_coeffs, den_coeffs, fs_val) to the Octave workspace.
- **Export Code** - Opens the code generation window.
- **DESIGN FILTER** - Computes the filter and updates all plots.

---

## 4. Designing a Filter

### Using a Preset

1. Select a preset from the **Preset** dropdown (e.g., "Bass Isolation").
2. All parameters are automatically filled and the filter is designed immediately.
3. You can modify any parameter after selecting a preset and click **DESIGN FILTER** to update.

### Manual Configuration

1. Enter the **Sampling Frequency** (e.g., 44100 for CD-quality audio).
2. Enter the **Cutoff Frequency** (e.g., 1000 Hz for a 1 kHz low-pass filter).
3. For Band Pass or Band Stop, also enter **Cutoff Frequency 2**.
4. Set the **Filter Order** (start with 4; increase for steeper rolloff).
5. Choose the **Architecture** (IIR or FIR).
6. Choose the **Filter Type** (Low Pass, High Pass, Band Pass, Band Stop).
7. Choose the **Topology / Method**.
8. Click **DESIGN FILTER**.

### Understanding the Results

After clicking DESIGN FILTER:

- The **Magnitude Response** plot shows how much the filter attenuates or passes each frequency. The y-axis is in decibels (dB); 0 dB means no attenuation, -3 dB is the conventional cutoff point, -40 dB means the signal is reduced to 1% of its original amplitude.
- The **Phase Response** plot shows the phase shift introduced at each frequency, in degrees.
- The **Stability Indicator** strip between the plots shows whether the filter is BIBO stable. A stable filter has all poles inside the unit circle (max pole radius < 1).

### IIR vs FIR Guidelines

| Aspect | IIR | FIR |
|---|---|---|
| Order for same rolloff | Lower (4-8) | Higher (32-128) |
| Phase response | Non-linear | Can be linear |
| Stability | Can be unstable | Always stable (a=1) |
| Computational cost | Lower | Higher |
| Best for | Real-time, low latency | Linear phase requirements |

---

## 5. Specification Mask Overlay

The specification mask shows whether a filter meets its design requirements by overlaying allowed and forbidden zones on the magnitude plot.

### Enabling the Mask

1. Check the **Show Spec Mask** checkbox above the magnitude plot.
2. Set **Rp (dB)** - the maximum allowed passband ripple (default: 1 dB).
3. Set **Rs (dB)** - the minimum required stopband attenuation (default: 40 dB).
4. Click **DESIGN FILTER** to see the mask.

### Reading the Mask

- **Light green zones** = allowed region. The response curve should stay here in the passband.
- **Light red zones** = forbidden region. The response curve should not enter these areas.
- **Red dashed lines** = the Rp and Rs boundary limits.
- **Gray dotted lines** = passband and stopband edge frequencies.
- **Transition band** (between the dotted lines) = no constraints; the filter rolls off here.

A filter **passes** the specification if the blue response curve stays within the green zones and outside the red zones.

> **Note:** The passband/stopband edge lines are positioned at a fixed ±10% of the cutoff frequency as a visual approximation of a typical transition band — they are not computed from the filter's actual order or roll-off. Use the mask to check that the response stays within the allowed zones, not to read exact band-edge frequencies.

### Typical Rp and Rs Values

| Application | Rp (dB) | Rs (dB) |
|---|---|---|
| Audio (general) | 0.5 - 1.0 | 40 - 60 |
| Telecommunications | 0.1 - 0.5 | 50 - 80 |
| Measurement/instrumentation | 0.01 - 0.1 | 60 - 100 |

---

## 6. Detailed Analysis Window

Click **DETAILED ANALYSIS** to open a comprehensive view with six plots arranged in a 3x2 grid. The **Freq Axis** button in the top-right corner switches the frequency axes (Phase Response, Group Delay) between normalized units and Hz, using the same shared setting as the main window.

### Row 1: Pole-Zero Diagram and Phase Response

- **Pole-Zero Diagram** - Shows zeros (blue circles) and poles (colored crosses) on the complex z-plane. The unit circle is drawn as a dashed black circle.
  - Green crosses: poles well inside the unit circle (radius < 0.95) — safe.
  - Orange crosses: poles near the unit circle (0.95 <= radius < 1.0) — caution.
  - Red crosses: poles on or outside the unit circle (radius >= 1.0) — unstable.
  - A dotted circle shows the maximum pole radius.
- **Phase Response** - Same as the main window, shown in degrees.

### Row 2: Group Delay and Impulse Response

- **Group Delay** - Shows the delay in samples as a function of frequency. A flat group delay indicates linear phase (no signal distortion). IIR filters typically have non-flat group delay, especially near the cutoff frequency.
- **Impulse Response** - Shows the filter output when the input is a single unit impulse (delta function). IIR filters have an infinite-duration impulse response that decays over time. FIR filters have a finite-duration response equal to the filter coefficients.

### Row 3: Step Response and Filter Metrics

- **Step Response** - Shows the filter output when the input is a unit step function (constant 1). Useful for evaluating settling time and overshoot.
- **Filter Metrics** - Numerical summary including filter order, max gain, DC gain, -3 dB crossing frequencies, max pole radius, stability margin, and stability status. The -3 dB crossings are measured relative to the filter's **peak** gain, not an absolute 0 dB. For equiripple designs (Chebyshev I, Elliptic), whose passband peak can sit slightly above 0 dB, this shifts the reported crossing accordingly.
- **Filter Coefficients** - Scrollable display of the numerator (b) and denominator (a) coefficient arrays.

---

## 7. Interactive Pole-Zero Editor

Click **Interactive P/Z Editor** to manually place poles and zeros on the z-plane.

### Controls

The editor provides a table where you can enter the real and imaginary parts of each pole and zero. Changes are applied when you click the submit button.

### Usage Tips

- Poles inside the unit circle produce a stable filter.
- Placing a zero at a specific frequency creates a null (notch) at that frequency.
- Complex poles/zeros must come in conjugate pairs for the filter to have real-valued coefficients.
- Moving poles closer to the unit circle increases the filter's resonance (gain peak) near the corresponding frequency.
- The editor updates the main window's magnitude and phase plots when you submit changes.

---

## 8. Filter Comparison

Click **COMPARE FILTERS** to open a window that overlays two filter responses.

### Loading Filters

Each filter slot (A and B) has two options:
- **Use Current** - Uses the filter currently designed in the main window.
- **Load from File** - Loads a previously saved .mat design file.

### Comparison Plots

The window shows three overlaid plots:
- **Magnitude Response** - Filter A (blue) vs Filter B (orange).
- **Phase Response** - Both filters on the same axes.
- **Group Delay** - Both filters on the same axes.

A metrics panel shows key values for both filters side by side.

---

## 9. Audio Demo

Click **AUDIO DEMO** to test the filter on real audio files.

### Workflow

1. Click **Load WAV** to select an audio file (WAV or FLAC format).
2. The tool applies the currently designed filter and displays:
   - **Original waveform** (blue) and **filtered waveform** (orange)
   - **Original spectrogram** and **filtered spectrogram** with matched color scales
3. Use **Play Original** and **Play Filtered** to hear the difference.
4. Adjust the **Volume** slider at the bottom of the window.
5. Click **Save WAV** to export the filtered audio as a new WAV file.

### Notes

- Stereo files are automatically converted to mono.
- If the audio sample rate differs from the filter's design sample rate, a warning is shown. The filter is still applied, but the effective cutoff frequencies will shift.
- The spectrograms use a shared color scale so the attenuation is visually accurate.
- Use **Stop** to halt playback. Clicking a different play button also stops the current playback.

---

## 10. Saving and Loading Designs

### Saving

1. Design a filter in the main window.
2. Click **Save Design**.
3. Choose a filename and location. The design is saved as a .mat file.

The saved file includes: Fs, Fc, Fc2, filter order, type, topology, architecture, coefficients (b, a), and metadata (version, date, topology name, type name).

### Loading

1. Click **Load Design**.
2. Select a previously saved .mat file.
3. All parameters are restored, the filter is re-plotted, and the stability indicator updates.

Saved designs are backward-compatible. Files saved before FIR support was added will load as IIR filters.

---

## 11. Exporting Filters

### Export to Workspace

Click **Export to Workspace** to make the filter available in the Octave command line:
- `num_coeffs` - Numerator coefficients (b)
- `den_coeffs` - Denominator coefficients (a)
- `fs_val` - Sampling frequency

### Export Code

Click **Export Code** to open the code generation window:

1. Select the output format:
   - **MATLAB / Octave (.m)** - Script with coefficients, `freqz` visualization
   - **C Header (.h)** - Header file with `static const double` arrays and `#define` macros
   - **Python / SciPy (.py)** - Script with `numpy` arrays, `scipy.signal.freqz` visualization
2. Preview the generated code in the text area.
3. Click **Save to File** to write the code to disk.

---

## 12. Report Generation

Click **GENERATE REPORT** to create a self-contained HTML report.

### Report Contents

- **Filter Specifications** table (architecture, type, topology, order, frequencies)
- **Analysis Metrics** table (stability, pole radius, margin, gains, -3 dB crossings)
- **Frequency Response** plots (Magnitude and Phase)
- **Pole-Zero Diagram** and **Group Delay** plots
- **Time Domain Response** plots (Impulse and Step Response)
- **Filter Coefficients** (numerator and denominator)

### Output Format

The report is a single HTML file with all plot images embedded as base64-encoded PNGs.
It can be opened in any web browser and printed to PDF using the browser's print function
(Ctrl+P or Cmd+P).

---

## 13. Theoretical Background

### Digital Filter Fundamentals

A digital filter processes a discrete-time signal x[n] to produce an output y[n]. The general
difference equation is:

```
y[n] = b0*x[n] + b1*x[n-1] + ... + bM*x[n-M] - a1*y[n-1] - ... - aN*y[n-N]
```

where b = [b0, b1, ..., bM] are the numerator (feedforward) coefficients and
a = [1, a1, ..., aN] are the denominator (feedback) coefficients.

### IIR Filters

IIR filters use both feedforward and feedback coefficients (a != [1]). They can achieve
sharp frequency selectivity with low order but have non-linear phase response.

- **Butterworth** - Maximally flat passband. Monotonic rolloff. The -3 dB point is exactly at the cutoff frequency.
- **Chebyshev Type I** - Equiripple in the passband, monotonic in the stopband. Steeper rolloff than Butterworth for the same order.
- **Chebyshev Type II** - Monotonic in the passband, equiripple in the stopband.
- **Elliptic (Cauer)** - Equiripple in both passband and stopband. Achieves the steepest rolloff for a given order but has ripple everywhere.

### FIR Filters

FIR filters use only feedforward coefficients (a = [1]). They are always stable and can
have exactly linear phase (symmetric coefficients), but require higher orders than IIR
for equivalent selectivity.

- **Windowed-sinc methods** (Hamming, Hanning, Blackman, Kaiser) - Multiply the ideal impulse response by a window function to limit its length.
- **Parks-McClellan** - Optimal equiripple design using the Remez exchange algorithm.
- **Least-Squares** - Minimizes the squared error between the desired and actual response.

### BIBO Stability

A discrete-time LTI system is Bounded-Input Bounded-Output (BIBO) stable if and only if all
poles of its transfer function H(z) lie strictly inside the unit circle (|z| < 1).

- **Max pole radius** - The largest absolute value among all poles. Must be < 1 for stability.
- **Stability margin** - Defined as 1 - max_pole_radius. Larger margin means more robust stability.
- FIR filters have no feedback poles (a = [1]), so they are always BIBO stable.

### Normalized Frequency

Filter design functions in Octave use normalized frequency Wn = Fc / (Fs/2), where Fc is the
cutoff frequency in Hz and Fs is the sampling frequency. The range [0, 1] maps to [0, Fs/2] Hz.

---

## 14. Troubleshooting

### "The 'signal' package is not loaded"

Run `pkg load signal` before launching dsppack. To load it automatically, add
`pkg load signal` to your `~/.octaverc` file.

### Window is too large for my screen

The main window is fixed at 1920x1080. If your screen is smaller, you may need to adjust
your display scaling or resolution settings.

### Spectrograms appear blank in Audio Demo

This can happen with very long audio files. The tool automatically scales the FFT window
to keep the spectrogram renderable, but extremely large files may still cause issues.
Try a shorter audio clip (under 5 minutes).

### Filter design produces warnings

Some filter designs (especially high-order Chebyshev or Elliptic) may produce numerical
warnings. The filter is still computed, but the results may be less accurate. Consider
reducing the filter order or using a different topology.

### Audio playback does not work

Audio playback requires Octave's audio subsystem. Ensure your system has working audio
output. The tool uses `audioplayer` for non-blocking playback.

### "base64_encode" not found during report generation

This function requires Octave 4.0 or later. Update your Octave installation.
