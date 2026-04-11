#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.venv/bin/activate"

COMMAND="${1:-help}"

create_dirs() {
	mkdir -p build/lib
	mkdir -p build/examples
	mkdir -p build/tests
}

format_code() {
	mojo format dsplib examples tests
}

package_lib() {
	echo "Packaging dsplib..."
	create_dirs
	mojo package dsplib -o build/lib/dsplib.mojopkg
}

run_tests() {
	echo "Running test_utils..."
	mojo run -I . tests/test_utils.mojo

	echo ""
	echo "Running test_fourier..."
	mojo run -I . tests/test_fourier.mojo

	echo ""
	echo "Running test_filters..."
	mojo run -I . tests/test_filters.mojo

	echo ""
	echo "Running test_plotting..."
	mojo run -I . tests/test_plotting.mojo
}

compile_examples() {
	create_dirs

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

	echo "Building Example 11: Spectrum Plots (Sine, Chord, Square)..."
	mojo build -I . examples/11-spectrum-plots.mojo -o build/examples/11-spectrum-plots

	echo "Building Example 12: Windowing Functions..."
	mojo build -I . examples/12-windowing.mojo -o build/examples/12-windowing

	echo "Building Example 13: Bode Plots..."
	mojo build -I . examples/13-bode-plots.mojo -o build/examples/13-bode-plots
}

package_release() {
	local pkg_name="dsplib-mojo"
	local version=$(git describe --tags --abbrev=0 2>/dev/null || echo "latest")

	# Detect platform and architecture
	local platform=$(uname -s | tr '[:upper:]' '[:lower:]')
	local arch=$(uname -m)

	# Normalize architecture names
	case "$arch" in
	x86_64) arch="x86_64" ;;
	arm64 | aarch64) arch="arm64" ;;
	*) arch="$arch" ;;
	esac

	local tar_name="${pkg_name}-${version}-${platform}-${arch}.tar.gz"

	echo "Creating release package: ${tar_name}"
	echo "  Platform: ${platform}"
	echo "  Architecture: ${arch}"
	echo ""

	rm -rf build/release
	mkdir -p build/release

	cp -r build/lib build/release/
	cp -r build/examples build/release/
	cp -r dsplib/*.mojo build/release/dsplib/ 2>/dev/null || true

	tar -czf "build/${tar_name}" -C build release

	echo ""
	echo "Release package created: build/${tar_name}"
	echo ""
	echo "To extract:"
	echo "  tar -xzf build/${tar_name}"
	echo "  cd release"
	echo "  ./examples/01-sine-wave-noise"
}

show_help() {
	cat <<'EOF'
dsplib-mojo build script

Usage: ./build.sh <command>

Commands:
  format       Run mojo format on dsplib, examples, and tests directories.
  compile lib  Compile and package the dsplib library.
  compile examples
               Compile all example programs.
  tests        Run unit tests using Mojo's TestSuite.
  release      Run format, compile lib, run tests, and compile examples.
  package      Create a release tar.gz for distribution on GitHub.
  help         Show this help message.

Examples:
  ./build.sh format              # Format code
  ./build.sh compile lib         # Build library only
  ./build.sh tests               # Run tests
  ./build.sh release             # Full release build

EOF
}

case "$COMMAND" in
format)
	echo "Formatting code..."
	format_code
	;;

compile)
	case "${2:-}" in
	lib)
		echo "Compiling library..."
		package_lib
		;;
	examples)
		echo "Compiling examples..."
		compile_examples
		;;
	*)
		echo "Unknown compile target: $2"
		echo "Usage: ./build.sh compile [lib|examples]"
		exit 1
		;;
	esac
	;;

tests)
	echo "Running tests..."
	run_tests
	;;

release)
	echo "========================================"
	echo "Starting release build"
	echo "========================================"
	echo ""
	echo "Step 1/4: Formatting..."
	format_code
	echo ""
	echo "Step 2/4: Compiling library..."
	package_lib
	echo ""
	echo "Step 3/4: Running tests..."
	run_tests
	echo ""
	echo "Step 4/4: Compiling examples..."
	compile_examples
	echo ""
	echo "========================================"
	echo "Release build complete!"
	echo "========================================"
	;;

package)
	echo "========================================"
	echo "Creating release package"
	echo "========================================"
	echo ""
	echo "Running release build first..."
	./build.sh release
	echo ""
	echo "Creating distribution package..."
	package_release
	echo ""
	echo "========================================"
	echo "Package created successfully!"
	echo "========================================"
	;;

help | --help | -h)
	show_help
	;;

*)
	echo "Unknown command: $COMMAND"
	echo ""
	show_help
	exit 1
	;;
esac
