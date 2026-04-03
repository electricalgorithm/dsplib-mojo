"""
Windowing Functions Demonstration

This example demonstrates how windowing functions affect spectral analysis.

Key Concept: Spectral Leakage
When we compute the FFT, we implicitly assume our signal is periodic.
If the signal's period doesn't fit exactly into our sample window,
the discontinuity at the boundaries causes energy to "leak" into
adjacent frequency bins.

The Problem:
    - FFT bins are at frequencies: 0, fs/N, 2fs/N, 3fs/N, ...
    - If our signal frequency falls between bins, energy leaks

Example:
    Sample rate: 44100 Hz
    Samples: 1024
    Bin spacing: 44100/1024 ≈ 43 Hz

    If our signal is 440 Hz:
    - Bin 10 = 430 Hz
    - Bin 11 = 473 Hz
    - 440 Hz is between them!
    - Energy spreads to both bins (leakage)

The Solution: Windowing
    Apply a window function to taper the edges before FFT.
    This reduces the discontinuity, reducing leakage.

This example generates a 440 Hz sine wave and shows how different
windows affect the resulting spectrum using the plot_spectrum_db function
with built-in window support.
"""

import dsplib
from std import os


def main() raises:
    var sample_rate: Float64 = 44100.0
    var frequency: Float64 = 440.0
    var num_samples = 1024

    os.makedirs("build/examples/windows", exist_ok=True)

    print("Windowing Functions Demonstration")
    print("================================")
    print("Frequency:", frequency, "Hz")
    print("Sample rate:", sample_rate, "Hz")
    print("Samples:", num_samples)
    print("FFT bin spacing:", sample_rate / Float64(num_samples), "Hz")
    print("")

    print("Generating 440 Hz sine wave (not aligned with FFT bins)...")

    var config = dsplib.WaveConfig(
        frequency_hz=frequency,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=Float64(num_samples) / sample_rate,
    )
    var signal = dsplib.generate_sine_wave_raw(config)

    print("")
    print("Plotting window shapes...")

    var rect_window = dsplib.generate_rectangular_window(num_samples)
    dsplib.plot_wave(
        rect_window,
        sample_rate,
        num_samples,
        "build/examples/windows/window_rectangular.png",
        title="Rectangular Window (No Tapering)",
    )

    var hann_window = dsplib.generate_hann_window(num_samples)
    dsplib.plot_wave(
        hann_window,
        sample_rate,
        num_samples,
        "build/examples/windows/window_hann.png",
        title="Hann Window (General Purpose)",
    )

    var hamming_window = dsplib.generate_hamming_window(num_samples)
    dsplib.plot_wave(
        hamming_window,
        sample_rate,
        num_samples,
        "build/examples/windows/window_hamming.png",
        title="Hamming Window (Better Sidelobe Suppression)",
    )

    var blackman_window = dsplib.generate_blackman_window(num_samples)
    dsplib.plot_wave(
        blackman_window,
        sample_rate,
        num_samples,
        "build/examples/windows/window_blackman.png",
        title="Blackman Window (Best Sidelobe Suppression)",
    )

    var cosine_window = dsplib.generate_cosine_window(num_samples)
    dsplib.plot_wave(
        cosine_window,
        sample_rate,
        num_samples,
        "build/examples/windows/window_cosine.png",
        title="Cosine Window (Simple Tapering)",
    )

    print("")
    print(
        "Plotting spectra with different windows (using plot_spectrum_db with"
        " window parameter)..."
    )

    print("  - Rectangular (no windowing)...")
    dsplib.plot_spectrum_db(
        signal,
        num_samples,
        sample_rate,
        "build/examples/windows/spectrum_rectangular.png",
        title="Rectangular - Spectrum (440 Hz sine)",
    )

    print("  - Hann window...")
    dsplib.plot_spectrum_db(
        signal,
        num_samples,
        sample_rate,
        "build/examples/windows/spectrum_hann.png",
        title="Hann Window - Spectrum (440 Hz sine)",
        window=hann_window,
    )

    print("  - Hamming window...")
    dsplib.plot_spectrum_db(
        signal,
        num_samples,
        sample_rate,
        "build/examples/windows/spectrum_hamming.png",
        title="Hamming Window - Spectrum (440 Hz sine)",
        window=hamming_window,
    )

    print("  - Blackman window...")
    dsplib.plot_spectrum_db(
        signal,
        num_samples,
        sample_rate,
        "build/examples/windows/spectrum_blackman.png",
        title="Blackman Window - Spectrum (440 Hz sine)",
        window=blackman_window,
    )

    print("  - Cosine window...")
    dsplib.plot_spectrum_db(
        signal,
        num_samples,
        sample_rate,
        "build/examples/windows/spectrum_cosine.png",
        title="Cosine Window - Spectrum (440 Hz sine)",
        window=cosine_window,
    )

    rect_window.free()
    hann_window.free()
    hamming_window.free()
    blackman_window.free()
    cosine_window.free()
    signal.free()

    print("")
    print("================================")
    print("Plots saved to: build/examples/windows")
    print("")
    print("Window shapes:")
    print("  - window_rectangular.png")
    print("  - window_hann.png")
    print("  - window_hamming.png")
    print("  - window_blackman.png")
    print("  - window_cosine.png")
    print("")
    print("Spectrum comparison (compare sidelobe levels):")
    print("  - spectrum_rectangular.png  (most leakage, -13 dB first sidelobe)")
    print("  - spectrum_cosine.png      (moderate, -23 dB)")
    print("  - spectrum_hann.png       (good, -31 dB)")
    print("  - spectrum_hamming.png   (better first sidelobe, -43 dB)")
    print("  - spectrum_blackman.png   (best sidelobe suppression, -58 dB)")
    print("")
    print("Key insight: Narrower window = sharper peak, more leakage")
    print("             Wider window = wider peak, less leakage")
