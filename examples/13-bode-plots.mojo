"""
Bode Plot Example

This example demonstrates the Bode plot functions for analyzing
the frequency response of signals and systems.

Bode Plot Overview:
    A Bode plot shows how a system responds to different frequencies.
    It consists of:
    - Magnitude plot: |H(jw)| in dB vs log frequency
    - Phase plot: arg(H(jw)) in degrees or radians vs log frequency

This example shows:
    1. Bode plot of a simple impulse response
    2. Bode plot with windowing
    3. Phase in degrees and radians
    4. Using the flexible API with pre-computed data
"""

import dsplib
from std import os


def main() raises:
    var sample_rate: Float64 = 44100.0
    var num_samples = 1024

    os.makedirs("build/examples/bode", exist_ok=True)

    print("Bode Plot Example")
    print("==================")
    print("Sample rate:", sample_rate, "Hz")
    print("Samples:", num_samples)
    print("Frequency range: 20 Hz to", sample_rate / 2.0, "Hz (Nyquist)")
    print("")

    print("Creating impulse response (unity gain system)...")
    var impulse = dsplib.allocate_buffer(num_samples)
    for i in range(num_samples):
        impulse[i] = 0.0
    impulse[0] = 1.0

    print("Generating Bode plots...")
    print("")

    print("1. Plotting combined magnitude and phase (degrees)...")
    dsplib.plot_bode[500](
        impulse,
        num_samples,
        sample_rate,
        "build/examples/bode/bode_combined_degrees.png",
        title="Impulse Response - Bode Plot (degrees)",
    )

    print("2. Plotting combined magnitude and phase (radians)...")
    dsplib.plot_bode[500](
        impulse,
        num_samples,
        sample_rate,
        "build/examples/bode/bode_combined_radians.png",
        title="Impulse Response - Bode Plot (radians)",
        phase_unit="radians",
    )

    print("3. Plotting magnitude only...")
    dsplib.plot_bode_magnitude[500](
        impulse,
        num_samples,
        sample_rate,
        "build/examples/bode/bode_magnitude.png",
        title="Impulse Response - Magnitude",
    )

    print("4. Plotting phase in degrees...")
    dsplib.plot_bode_phase[500](
        impulse,
        num_samples,
        sample_rate,
        "build/examples/bode/bode_phase_degrees.png",
        title="Impulse Response - Phase (degrees)",
        phase_unit="degrees",
    )

    print("5. Plotting phase in radians...")
    dsplib.plot_bode_phase[500](
        impulse,
        num_samples,
        sample_rate,
        "build/examples/bode/bode_phase_radians.png",
        title="Impulse Response - Phase (radians)",
        phase_unit="radians",
    )

    print("6. Plotting with Hann window (reduced leakage)...")
    var hann = dsplib.generate_hann_window(num_samples)
    dsplib.plot_bode[500](
        impulse,
        num_samples,
        sample_rate,
        "build/examples/bode/bode_with_hann.png",
        title="Impulse Response with Hann Window",
        window=hann,
    )
    hann.free()

    print("7. Using flexible API (compute then plot)...")
    var result = dsplib.compute_bode_response[500](
        impulse, num_samples, sample_rate
    )

    dsplib.plot_bode_combined(
        result.frequencies,
        result.magnitude_db,
        result.phase_deg,
        500,
        "build/examples/bode/bode_flexible_api.png",
        title="Flexible API Example",
        phase_unit="degrees",
    )

    result.free()

    impulse.free()

    print("")
    print("========================================")
    print("")
    print("Generated plots:")
    print("  1. bode_combined_degrees.png   - Magnitude and phase (degrees)")
    print("  2. bode_combined_radians.png  - Magnitude and phase (radians)")
    print("  3. bode_magnitude.png         - Magnitude only (dB)")
    print("  4. bode_phase_degrees.png     - Phase only (degrees)")
    print("  5. bode_phase_radians.png     - Phase only (radians)")
    print("  6. bode_with_hann.png        - With Hann window")
    print("  7. bode_flexible_api.png      - Using flexible API")
    print("")
    print("Look for:")
    print("  - Logarithmic frequency axis (20 Hz to Nyquist)")
    print("  - Magnitude in dB (0 dB flat for impulse)")
    print("  - Phase: 0 degrees for impulse (constant)")
    print("  - Phase: 0 radians for impulse when using radians")
    print("  - -3 dB reference line on magnitude plot")
    print("  - Grid lines for easier reading")
