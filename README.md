# dsplib-mojo

An educational Digital Signal Processing (DSP) library built with **Mojo**. This project is designed to teach the fundamentals of signal processing—such -- while leveraging Mojo's high-performance features like SIMD.

> **Note:** This library is created for **educational purposes**. It prioritizes readability and fundamental implementations (like $O(N^2)$ DFT) over production-grade optimizations to help students and developers understand how DSP algorithms work under the hood.

## Project Structure

The library is organized into logical submodules to separate core math, signal generation, and visualization:

- **`dsplib.core`**: Fundamental types, including a custom `Complex` number struct.
- **`dsplib.waves`**: SIMD-accelerated sine wave generation and various noise generators (Normal, Uniform).
- **`dsplib.fourier`**: Discrete Fourier Transform (DFT) and Inverse DFT implementations.
- **`dsplib.plotting`**: Visualization utilities powered by Python's `matplotlib` and `numpy`.

## Quick Start

### Build 
Clone the repository and install the necessary Python dependencies (`numpy`, `matplotlib`) into a virtual environment:

```bash
$ uv venv
$ source .venv/bin/activate
$ uv sync
$ ./build.sh
```

After a successfull build, one can find the artifacts under `./build` directory.

- `build/lib/dsplib.mojopkg`: The library to use in your Mojo projects.
- `build/examples/*`: All example executables that showcases libraries functionality.

## License
MIT
