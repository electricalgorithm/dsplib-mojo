import dsplib


def main() raises:
    print("Example 10: Magnitude and Phase Spectra")
    print("=" * 60)
    print()
    print("THEORY: What does the DFT tell us?")
    print("-" * 60)
    print()
    print("The Discrete Fourier Transform (DFT) converts a time-domain signal")
    print("into the frequency domain. Each output bin is a COMPLEX number")
    print("that contains TWO pieces of information:")
    print()
    print("  1. MAGNITUDE: How much of this frequency is in the signal?")
    print("     |X[k]| = sqrt(Re^2 + Im^2)")
    print()
    print("  2. PHASE: Where in the cycle is this frequency?")
    print("     arg(X[k]) = atan2(Im, Re)  (in radians)")
    print()
    print("Together: X[k] = |X[k]| * e^(j * arg(X[k]))")
    print()
    print("For real signals, the spectrum is symmetric:")
    print("  - Only positive frequencies needed (0 to Nyquist)")
    print("  - Magnitudes scaled by 2/N to account for negative frequencies")
    print()

    var sample_rate: Float64 = 44100.0
    var duration: Float64 = 0.1
    var num_samples = Int(sample_rate * duration)

    # Create A major chord with harmonics for richer sound
    print("1. Creating A major chord (A4, C#5, E5)...")

    fn create_piano_note(
        freq: Float64, amp: Float64
    ) -> UnsafePointer[Float64, MutExternalOrigin]:
        # Fundamental + 3 harmonics
        var result = dsplib.allocate_buffer(num_samples)

        # Harmonic amplitudes (piano-like)
        var harmonics = dsplib.allocate_buffer(4)
        harmonics[0] = 1.0
        harmonics[1] = 0.5
        harmonics[2] = 0.25
        harmonics[3] = 0.125

        for h in range(4):
            var h_freq = freq * Float64(h + 1)
            var h_amp = amp * harmonics[h]

            var config = dsplib.WaveConfig(
                frequency_hz=h_freq,
                amplitude=h_amp,
                phase_rad=0.0,
                offset=0.0,
                sample_rate_ss=sample_rate,
                duration_s=duration,
            )
            var harmonic = dsplib.generate_sine_wave_raw(config)

            for i in range(num_samples):
                result[i] = result[i] + harmonic[i]

            harmonic.free()

        harmonics.free()
        return result

    var a4 = create_piano_note(440.0, 0.5)
    var cs5 = create_piano_note(554.37, 0.5)
    var e5 = create_piano_note(659.25, 0.5)

    var chord = dsplib.add_waves(a4, cs5, num_samples)
    chord = dsplib.add_waves(chord, e5, num_samples)

    print("   Notes: A4=440Hz, C#5=554Hz, E5=659Hz")
    print("   Samples:", num_samples)
    print("   Duration:", duration, "seconds")
    print(
        "   Frequency resolution:",
        sample_rate / Float64(num_samples),
        "Hz per bin",
    )
    print()

    a4.free()
    cs5.free()
    e5.free()

    # Plot the time-domain signal
    print("2. Plotting time-domain signal...")
    dsplib.plot_wave(
        chord,
        sample_rate,
        Int(Float64(num_samples) * 0.1),  # First 10% for visibility
        "example_10_time_domain.png",
        "A Major Chord - Time Domain",
    )
    print()

    # Compute DFT
    print("3. Computing DFT...")
    var dft_result = dsplib.compute_dft_raw(chord, num_samples)
    print()

    # Compute magnitude spectrum
    print("4. Extracting magnitude spectrum...")
    var mag_result = dsplib.compute_magnitude_spectrum(dft_result, num_samples)
    var magnitudes = mag_result[0]
    var num_bins = mag_result[1]

    # Find peaks
    var threshold: Float64 = 0.05
    print()
    print("5. Peak Analysis:")
    print("-" * 60)
    print()

    var peaks_found = 0
    for i in range(1, num_bins - 1):
        if (
            magnitudes[i] > threshold
            and magnitudes[i] > magnitudes[i - 1]
            and magnitudes[i] > magnitudes[i + 1]
        ):
            var freq = Float64(i) * sample_rate / Float64(num_samples)
            peaks_found = peaks_found + 1

    print("   Found", peaks_found, "significant peaks")
    print()

    # Print notable peaks with their magnitudes
    print("   Notable frequency peaks:")
    for i in range(num_bins):
        if magnitudes[i] > 0.15:
            var freq = Float64(i) * sample_rate / Float64(num_samples)
            print("     ", freq, "Hz  ->  magnitude:", magnitudes[i])

    magnitudes.free()
    print()

    # Compute phase spectrum
    print("6. Extracting phase spectrum...")
    var phase_result = dsplib.compute_phase_spectrum(dft_result, num_samples)
    var phases = phase_result[0]

    # Show phase at peak frequencies
    print()
    print("   Phase at dominant frequencies:")
    for i in range(num_bins):
        if magnitudes[i] > 0.15:
            var freq = Float64(i) * sample_rate / Float64(num_samples)
            var phase_deg = phases[i] * 180.0 / 3.14159265
            print(
                "     ",
                freq,
                "Hz  ->  phase:",
                phases[i],
                "rad",
                "(",
                phase_deg,
                "deg)",
            )

    phases.free()
    print()

    # Cleanup
    chord.free()
    dft_result.free()

    print("=" * 60)
    print("Generated files:")
    print("  - example_10_time_domain.png  : Time-domain plot")
    print()
    print("KEY INSIGHTS:")
    print("  - Magnitude tells you HOW MUCH of each frequency")
    print("  - Phase tells you WHEN in the cycle each frequency occurs")
    print("  - Together they fully describe the frequency content")
