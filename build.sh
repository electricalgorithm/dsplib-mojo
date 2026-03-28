#!/bin/bash

# Exit on error
set -e

# Create build directories
echo "Creating build directories..."
mkdir -p build/lib
mkdir -p build/examples

# This compiles the 'dsplib' directory into a redistributable Mojo package (.mojopkg)
echo "Packaging dsplib..."
mojo package dsplib -o build/lib/dsplib.mojopkg

# We use 'mojo build' to create compiled executables.
# We include the current directory (-I .) so the compiler can find the 'dsplib' module.
echo "Building Example 01: Sine Wave and Noise..."
mojo build -I . examples/01-sine-wave-noise.mojo -o build/examples/01-sine-wave-noise

echo "Building Example 02: DFT Plots..."
mojo build -I . examples/02-dft-plots.mojo -o build/examples/02-dft-plots

echo "Building Example 03: DFT Unit Circle Representation..."
mojo build -I . examples/03-dft-unit-circle.mojo -o build/examples/03-dft-unit-circle

echo "Building Example 04: Square Wave..."
mojo build -I . examples/04-square-wave.mojo -o build/examples/04-square-wave

echo "--------------------------------------------------"
echo "Build complete! Artifacts are in the 'build/' directory."
echo ""
echo "To run the examples, ensure your Python environment is active:"
echo "  source .venv/bin/activate"
echo "  ./build/examples/01-sine-wave-noise"
echo "  ./build/examples/02-dft-plots"
echo "  ./build/examples/(...)"
echo "--------------------------------------------------"
