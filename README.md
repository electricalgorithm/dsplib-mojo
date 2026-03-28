# dsplib-mojo

An educational Digital Signal Processing (DSP) library built with **Mojo**. This project is designed to teach the fundamentals of signal processing—such -- while leveraging Mojo's high-performance features like SIMD.

> **Note:** This library is created for **educational purposes**. It prioritizes readability and fundamental implementations (like $O(N^2)$ DFT) over production-grade optimizations to help students and developers understand how DSP algorithms work under the hood.

## Project Structure

The library is organized into logical submodules to separate core math, signal generation, and visualization:

- **`dsplib.core`**: Fundamental types, including a custom `Complex` number struct.
- **`dsplib.waves`**: SIMD-accelerated sine wave generation and various noise generators (Normal, Uniform).
- **`dsplib.fourier`**: Discrete Fourier Transform (DFT) and Inverse DFT implementations.
- **`dsplib.plotting`**: Visualization utilities powered by Python's `matplotlib` and `numpy`.

## Key Features

- **SIMD Acceleration**: Uses Mojo's `SIMD` capabilities for fast wave generation and arithmetic.
- **Python Interop**: Seamlessly integrates with `matplotlib` for high-quality plotting.
- **Modular Design**: Easy to navigate and extend for different DSP tasks.
- **Manual Memory Management**: Demonstrates the use of `UnsafePointer` and `alloc` for high-performance buffer handling.

## Quick Start

### Setup Environment
Clone the repository and install the necessary Python dependencies (`numpy`, `matplotlib`) into a virtual environment:

```bash
# Install dependencies and create venv
uv sync

# Activate the virtual environment
source .venv/bin/activate
```

### Run Examples
You can run the provided examples using the Mojo CLI. Always include the `-I .` flag so Mojo can locate the `dsplib` module in the current directory:

```bash
# Example 01: Generate sine waves and add noise
mojo -I . examples/01-sine-wave-noise.mojo

# Example 02: Perform DFT and plot frequency spectrum
mojo -I . examples/02-dft-plots.mojo
```

## License
MIT
