# DSP Learning Roadmap

A structured learning path for mastering Digital Signal Processing fundamentals through hands-on implementation in Mojo.

---

## Phase 1: Foundations

### `dsplib.core` — Core Math & Types

**Learning Objectives:**
- Understand complex number representation and arithmetic
- Learn polar ↔ cartesian coordinate conversion
- Master Euler's formula: $e^{j\omega} = \cos(\omega) + j\sin(\omega)$

**Topics:**
- [ ] Complex number struct (real, imaginary, magnitude, phase)
- [ ] Complex addition, subtraction, multiplication, division
- [ ] Complex conjugate and magnitude calculation
- [ ] Polar form (r, θ) ↔ Cartesian form (x, y) conversion
- [ ] Unit circle visualization
- [ ] Phasor representation of sinusoidal signals

**Exercises:**
- Implement complex exponential $e^{j\omega t}$
- Visualize phasor rotation on unit circle
- Verify Euler's identity: $e^{j\pi} = -1$

---

## Phase 2: Signal Generation

### `dsplib.waves` — Waveforms & Noise

**Learning Objectives:**
- Generate common waveform types used in signal processing
- Understand signal parameters: amplitude, frequency, phase, offset
- Learn about different noise distributions and their properties

**Topics:**
- [ ] Sine wave generation with SIMD acceleration
- [ ] Cosine wave (phase-shifted sine)
- [ ] Square wave (via sign function)
- [ ] Sawtooth / triangle wave
- [ ] Signal parameters: amplitude, frequency (Hz), phase, DC offset
- [ ] Time array generation (sampling instants)
- [ ] Signal composition (adding multiple frequencies)
- [ ] Normal (Gaussian) noise generation
- [ ] Uniform noise generation
- [ ] Signal-to-Noise Ratio (SNR) concepts
- [ ] Adding noise to clean signals

**Exercises:**
- Generate and plot 440 Hz sine wave (musical A)
- Create a chord (multiple frequencies simultaneously)
- Generate white noise and visualize frequency spectrum
- Add 20 dB SNR noise to a signal

---

## Phase 3: Frequency Analysis

### `dsplib.fourier` — Fourier Transforms

**Learning Objectives:**
- Understand the relationship between time and frequency domains
- Learn how DFT converts discrete signals to frequency representation
- Visualize frequency content of signals

**Topics:**
- [ ] Discrete Fourier Transform (DFT) — O(N²) implementation
- [ ] Inverse DFT (IDFT) — signal reconstruction
- [ ] Complex exponential basis functions $W_N^{kn} = e^{-j2\pi kn/N}$
- [ ] Magnitude and phase spectra
- [ ] Power spectrum and spectral energy
- [ ] Parseval's theorem (energy conservation)
- [ ] Fast Fourier Transform (FFT) — O(N log N) implementation
- [ ] Radix-2 Cooley-Tukey algorithm
- [ ] Zero-padding for frequency resolution
- [ ] Windowing functions (Hann, Hamming, Blackman)
- [ ] Spectral leakage and windowing tradeoffs

**Exercises:**
- DFT of a pure sine wave → verify single frequency peak
- DFT of multi-tone signal → identify all frequency components
- Compare DFT vs FFT computational complexity
- Apply Hann window to reduce spectral leakage
- Zero-pad signal to interpolate frequency bins

---

## Phase 4: Filtering

### `dsplib.filters` — Digital Filters

**Learning Objectives:**
- Understand how filters modify signal frequency content
- Learn FIR vs IIR filter characteristics
- Implement convolution and difference equations

**Topics:**
- [ ] Filter fundamentals: passband, stopband, cutoff frequency
- [ ] Convolution theorem and linear convolution
- [ ] FIR filters (Finite Impulse Response)
  - Moving average filter
  - Windowed-sinc filter
  - Design using frequency sampling
- [ ] IIR filters (Infinite Impulse Response)
  - Difference equations
  - Direct Form I and II implementations
- [ ] Biquad filters (second-order sections)
  - Low-pass, high-pass, band-pass, band-stop
- [ ] Filter design basics
  - Butterworth (maximally flat magnitude)
  - Chebyshev (ripple in passband/stopband)
- [ ] Frequency response analysis (magnitude & phase plots)
- [ ] Group delay
- [ ] Stability considerations for IIR filters

**Exercises:**
- Implement 3-point moving average filter
- Design low-pass FIR filter with specific cutoff
- Create 2nd-order Butterworth low-pass
- Plot frequency response (magnitude in dB, phase)
- Filter noisy signal and compare SNR before/after

---

## Phase 5: Advanced Topics & Applications

### `dsplib.applications` — Real-World DSP

**Learning Objectives:**
- Apply DSP techniques to practical problems
- Understand real-time processing considerations
- Combine multiple techniques for complete solutions

**Topics:**
- [ ] **Audio Processing**
  - Simple audio effects (echo, reverb via delay)
  - Equalizer design using biquad filters
  - Dynamic range compression
  
- [ ] **Spectral Analysis**
  - Short-Time Fourier Transform (STFT)
  - Spectrogram visualization
  - Harmonic analysis of musical instruments
  
- [ ] **Signal Reconstruction**
  - Zero-order hold interpolation
  - Linear interpolation
  - Sinc interpolation / ideal low-pass reconstruction
  
- [ ] **Resampling**
  - Upsampling (zero-insertion + interpolation)
  - Downsampling (decimation + anti-aliasing)
  - Sample rate conversion
  
- [ ] **Correlation & Detection**
  - Cross-correlation
  - Auto-correlation
  - Matched filtering for signal detection
  
- [ ] **Modulation Basics**
  - AM modulation/demodulation
  - Complex baseband representation

**Exercises:**
- Build a simple 3-band audio equalizer
- Create spectrogram of a musical recording
- Implement sample rate converter (e.g., 44.1kHz → 48kHz)
- Detect a known signal buried in noise using matched filtering

---

## Suggested Project Order

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5
   ↓         ↓          ↓          ↓          ↓
 core     waves      fourier    filters   applications
```

Each phase builds upon the previous. Skipping phases may leave gaps in understanding.

---

## Quick Reference: DSP Pipeline

```
Signal → Generation → Analysis → Filtering → Applications
              ↓            ↓           ↓
          time-domain   frequency   frequency
                         domain      shaping
```

Most DSP work follows this pattern: generate/analyze signals in time domain, examine frequency content, apply filters to shape the spectrum, and build applications.
