# dsplib-mojo

An educational Digital Signal Processing (DSP) library built with **Mojo**. This project is designed to teach the fundamentals of signal processing while leveraging Mojo's high-performance features like SIMD.

## Project Structure

The library is organized into logical submodules:

| Module | Description |
|--------|-------------|
| `dsplib.core` | Custom `Complex` number struct with magnitude and phase |
| `dsplib.waves` | SIMD-accelerated waveform generators (sine, sawtooth, triangle, square) and noise |
| `dsplib.fourier` | DFT, FFT, and spectrum analysis functions |
| `dsplib.windows` | Windowing functions for spectral analysis (Hann, Hamming, Blackman, etc.) |
| `dsplib.plotting` | Visualization utilities using matplotlib |
| `dsplib.audio` | WAV file writing utilities |

## Quick Start

```bash
# Create virtual environment and install dependencies
$ uv venv
$ source .venv/bin/activate
$ uv sync

# Full build (format + compile lib + tests + compile examples)
$ ./build.sh release

# Or build incrementally
$ ./build.sh compile lib    # Compile library only
$ ./build.sh tests          # Run unit tests
$ ./build.sh compile examples  # Compile all examples
```

## Examples

| # | Example | Description |
|---|---------|-------------|
| 01 | `sine-wave-noise` | Basic sine wave generation with added Gaussian noise |
| 02 | `dft-plots` | Visualize DFT bin magnitudes as bar charts |
| 03 | `dft-unit-circle` | Plot DFT twiddle factors on the unit circle |
| 04 | `square-wave` | Generate and visualize square waves |
| 05 | `sawtooth-triangle` | Compare sawtooth and triangle waveforms |
| 06 | `signal-composition` | Mix multiple sine waves into chords |
| 07 | `snr` | Signal-to-Noise ratio calculation and visualization |
| 08 | `audio-io` | Write synthesized audio to WAV files |
| 09 | `harmonics` | Explore harmonic content of different waveforms |
| 10 | `spectrum-analysis` | Magnitude and phase spectra visualization |
| 11 | `spectrum-plots` | Frequency spectrum of sine, chord, and square waves |
| 12 | `windowing` | Compare windowing functions (Hann, Hamming, Blackman, etc.) |

Run examples:
```bash
$ ./build/examples/01-sine-wave-noise
$ ./build/examples/11-spectrum-plots
```

## License

MIT
