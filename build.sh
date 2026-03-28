#!/bin/bash

set -e

echo "Creating build directories..."
mkdir -p build/lib
mkdir -p build/examples

echo "Packaging dsplib..."
mojo package dsplib -o build/lib/dsplib.mojopkg

echo ""
echo "========================================"
echo "Building Examples"
echo "========================================"

echo ""
echo "Building Example 01: Sine Wave and Noise..."
mojo build -I . examples/01-sine-wave-noise.mojo -o build/examples/01-sine-wave-noise

echo "Building Example 02: DFT Plots..."
mojo build -I . examples/02-dft-plots.mojo -o build/examples/02-dft-plots

echo "Building Example 03: DFT Unit Circle Representation..."
mojo build -I . examples/03-dft-unit-circle.mojo -o build/examples/03-dft-unit-circle

echo "Building Example 04: Square Wave..."
mojo build -I . examples/04-square-wave.mojo -o build/examples/04-square-wave

echo "Building Example 05: Sawtooth and Triangle Waves..."
mojo build -I . examples/05-sawtooth-triangle.mojo -o build/examples/05-sawtooth-triangle

echo "Building Example 06: Signal Composition..."
mojo build -I . examples/06-signal-composition.mojo -o build/examples/06-signal-composition

echo "Building Example 07: Signal-to-Noise Ratio..."
mojo build -I . examples/07-snr.mojo -o build/examples/07-snr

echo ""
echo "========================================"
echo "Build complete!"
echo "========================================"
echo ""
echo "Built examples:"
echo "  build/examples/01-sine-wave-noise"
echo "  build/examples/02-dft-plots"
echo "  build/examples/03-dft-unit-circle"
echo "  build/examples/04-square-wave"
echo "  build/examples/05-sawtooth-triangle"
echo "  build/examples/06-signal-composition"
echo "  build/examples/07-snr"
echo ""
echo "Run examples:"
echo "  source .venv/bin/activate"
echo "  ./build/examples/01-sine-wave-noise"
echo "  ./build/examples/02-dft-plots"
echo "  ./build/examples/03-dft-unit-circle"
echo "  ./build/examples/04-square-wave"
echo "  ./build/examples/05-sawtooth-triangle"
echo "  ./build/examples/06-signal-composition"
echo "  ./build/examples/07-snr"
echo ""
echo "Or run all with 'mojo -I . examples/*.mojo'"
