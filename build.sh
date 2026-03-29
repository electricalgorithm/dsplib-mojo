#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.venv/bin/activate"

echo ""
echo "========================================"
echo "Formatting code with mojo format"
echo "========================================"
mojo format dsplib examples tests

echo ""
echo "========================================"
echo "Creating build directories..."
echo "========================================"
mkdir -p build/lib
mkdir -p build/examples
mkdir -p build/tests

echo "Packaging dsplib..."
mojo package dsplib -o build/lib/dsplib.mojopkg

echo ""
echo "========================================"
echo "Building and Running Tests"
echo "========================================"

echo ""
echo "Running test_utils..."
mojo run -I . tests/test_utils.mojo

echo ""
echo "Running test_fourier..."
mojo run -I . tests/test_fourier.mojo

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

echo "Building Example 08: Audio I/O..."
mojo build -I . examples/08-audio-io.mojo -o build/examples/08-audio-io

echo "Building Example 09: Harmonics and Instrument Timbre..."
mojo build -I . examples/09-harmonics.mojo -o build/examples/09-harmonics

echo "Building Example 10: Magnitude and Phase Spectra..."
mojo build -I . examples/10-spectrum-analysis.mojo -o build/examples/10-spectrum-analysis

echo ""
echo "========================================"
echo "Build complete!"
echo "========================================"
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
echo "  ./build/examples/08-audio-io"
echo "  ./build/examples/09-harmonics"
echo "  ./build/examples/10-spectrum-analysis"
