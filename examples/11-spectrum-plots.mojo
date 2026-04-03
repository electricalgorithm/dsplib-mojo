"""
Spectrum Plots Example

This example demonstrates the spectrum analysis functions for visualizing
the frequency content of signals.

Spectrum Analysis Overview:
    The frequency spectrum shows "how much" of each frequency is present
    in a signal. Unlike Bode plots (which show system gain), spectrum
    plots show the absolute magnitude of frequency components.

    Key differences from Bode plots:
    - Bode: |H(jω)| normalized so DC = 0 dB (for system analysis)
    - Spectrum: |X(k)| absolute magnitude (for signal analysis)

    Use Spectrum plots to:
    - Identify dominant frequencies in a signal
    - See harmonics of periodic signals
    - Observe noise floor levels
    - Compare amplitudes across frequencies

    Use Bode plots to:
    - Analyze filter characteristics
    - Study system frequency response
    - See relative gain at different frequencies
"""

import dsplib
from std import os


def main() raises:
    var sample_rate: Float64 = 44100.0
    var num_samples = 2048

    os.makedirs("build/examples", exist_ok=True)

    print("Spectrum Analysis Example")
    print("==========================")
    print("Sample rate:", sample_rate, "Hz")
    print("Samples:", num_samples)
    print("Frequency resolution:", sample_rate / Float64(num_samples), "Hz")
    print("")

    # --- Sine Wave Spectrum ---
    var sine_config = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=Float64(num_samples) / sample_rate,
    )
    var sine = dsplib.generate_sine_wave_raw(sine_config)

    print("1. Plotting sine wave spectrum (440 Hz)...")
    print("   A pure sine wave shows:")
    print("   - Peak at 440 Hz (the fundamental frequency)")
    print("   - All other frequencies near noise floor")
    dsplib.plot_spectrum_db(
        sine,
        num_samples,
        sample_rate,
        "build/examples/spectrum_sine.png",
        title="Sine Wave (440 Hz) - Spectrum",
    )
    sine.free()

    # --- Major Chord Spectrum ---
    print("")
    print("2. Creating A major chord (A4=440Hz, C#5=554Hz, E5=659Hz)...")

    var chord_config_a4 = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=Float64(num_samples) / sample_rate,
    )
    var chord_config_e5 = dsplib.WaveConfig(
        frequency_hz=659.25,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=Float64(num_samples) / sample_rate,
    )
    var chord_config_cs5 = dsplib.WaveConfig(
        frequency_hz=554.37,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=Float64(num_samples) / sample_rate,
    )

    var wave_a4 = dsplib.generate_sine_wave_raw(chord_config_a4)
    var wave_e5 = dsplib.generate_sine_wave_raw(chord_config_e5)
    var wave_cs5 = dsplib.generate_sine_wave_raw(chord_config_cs5)

    var chord = dsplib.add_waves(wave_a4, wave_e5, num_samples)
    chord = dsplib.add_waves(chord, wave_cs5, num_samples)

    print("   A chord shows:")
    print("   - Three peaks at 440 Hz, 554 Hz, and 659 Hz")
    print("   - Each peak represents one note of the chord")
    print("   - No harmonics (sine waves are pure tones)")
    dsplib.plot_spectrum_db(
        chord,
        num_samples,
        sample_rate,
        "build/examples/spectrum_chord.png",
        title="A Major Chord - Spectrum",
    )

    wave_a4.free()
    wave_e5.free()
    wave_cs5.free()
    chord.free()

    # --- Square Wave Spectrum ---
    print("")
    print("3. Creating square wave (220 Hz)...")
    var square_config = dsplib.SquareWaveConfig(
        frequency_hz=220.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=Float64(num_samples) / sample_rate,
        duty_cycle_perc=50.0,
    )
    var square = dsplib.generate_square_wave_raw(square_config)

    print("   A square wave shows:")
    print("   - Fundamental at 220 Hz")
    print("   - Odd harmonics at 3f=660Hz, 5f=1100Hz, 7f=1540Hz...")
    print("   - Each harmonic is smaller than the previous")
    print("   - Harmonics follow: amplitude ∝ 1/harmonic_number")
    dsplib.plot_spectrum_db(
        square,
        num_samples,
        sample_rate,
        "build/examples/spectrum_square.png",
        title="Square Wave (220 Hz) - Spectrum (odd harmonics)",
    )
    square.free()

    print("")
    print("========================================")
    print("Generated plots:")
    print("  - build/examples/spectrum_sine.png")
    print("    Shows single peak at 440 Hz")
    print("")
    print("  - build/examples/spectrum_chord.png")
    print("    Shows three peaks at chord frequencies")
    print("")
    print("  - build/examples/spectrum_square.png")
    print("    Shows fundamental + odd harmonics")
    print("")
    print("Key differences from Bode plots:")
    print("  - Spectrum: absolute magnitude in dB")
    print("  - Bode: magnitude normalized to DC = 0 dB")
    print("")
    print("Use spectrum plots for signal analysis (finding frequencies).")
    print("Use Bode plots for system analysis (filter characteristics).")
