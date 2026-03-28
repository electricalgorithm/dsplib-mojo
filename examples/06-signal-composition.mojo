import dsplib


def main() raises:
    print("Example 06: Signal Composition")
    print("=" * 50)

    var sample_rate: Float64 = 44100.0
    var duration: Float64 = 0.02
    var num_samples = Int(sample_rate * duration)

    print("\n1. Adding two sine waves (harmonics)...")
    var sine_440 = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var sine_880 = dsplib.WaveConfig(
        frequency_hz=880.0,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var wave_440 = dsplib.generate_sine_wave_raw(sine_440)
    var wave_880 = dsplib.generate_sine_wave_raw(sine_880)
    var harmonics = dsplib.add_waves(wave_440, wave_880, num_samples)
    dsplib.plot_wave(
        harmonics, sample_rate, num_samples, "composition_harmonics.png"
    )

    print("\n2. Square wave + sine wave (filtered square approximation)...")
    var square_config = dsplib.SquareWaveConfig(
        frequency_hz=220.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
        duty_cycle_perc=50.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
    )
    var sine_config = dsplib.WaveConfig(
        frequency_hz=220.0,
        amplitude=0.3,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var wave_square = dsplib.generate_square_wave_raw(square_config)
    var wave_sine = dsplib.generate_sine_wave_raw(sine_config)
    var square_plus_sine = dsplib.add_waves(wave_square, wave_sine, num_samples)
    dsplib.plot_wave(
        square_plus_sine,
        sample_rate,
        num_samples,
        "composition_square_sine.png",
    )

    print("\n3. Triangle + sawtooth (additive synthesis)...")
    var triangle_config = dsplib.TriangleWaveConfig(
        frequency_hz=110.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var sawtooth_config = dsplib.SawtoothWaveConfig(
        frequency_hz=110.0,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var wave_triangle = dsplib.generate_triangle_wave_raw(triangle_config)
    var wave_sawtooth = dsplib.generate_sawtooth_wave_raw(sawtooth_config)
    var tri_plus_saw = dsplib.add_waves(
        wave_triangle, wave_sawtooth, num_samples
    )
    dsplib.plot_wave(
        tri_plus_saw, sample_rate, num_samples, "composition_triangle_saw.png"
    )

    print(
        "\n4. Three-partial harmonic series (fundamental + 2nd + 3rd"
        " harmonic)..."
    )
    var harm_1 = dsplib.WaveConfig(
        frequency_hz=220.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var harm_2 = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var harm_3 = dsplib.WaveConfig(
        frequency_hz=660.0,
        amplitude=0.33,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var wave_h1 = dsplib.generate_sine_wave_raw(harm_1)
    var wave_h2 = dsplib.generate_sine_wave_raw(harm_2)
    var wave_h3 = dsplib.generate_sine_wave_raw(harm_3)
    var temp = dsplib.add_waves(wave_h1, wave_h2, num_samples)
    var harmonic_series = dsplib.add_waves(temp, wave_h3, num_samples)
    dsplib.plot_wave(
        harmonic_series,
        sample_rate,
        num_samples,
        "composition_harmonic_series.png",
    )

    print("\n5. Sine + noise (SNR demonstration)...")
    var clean_sine = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var wave_clean = dsplib.generate_sine_wave_raw(clean_sine)
    var wave_noise = dsplib.generate_random_normal_noise_raw(
        sample_rate, duration, mean=0.0, std_dev=0.3
    )
    var noisy_signal = dsplib.add_waves(wave_clean, wave_noise, num_samples)
    dsplib.plot_wave(
        noisy_signal, sample_rate, num_samples, "composition_sine_noise.png"
    )

    print("\n6. DC offset + AC signal (bias addition)...")
    var ac_config = dsplib.WaveConfig(
        frequency_hz=220.0,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var dc_config = dsplib.WaveConfig(
        frequency_hz=0.0,
        amplitude=0.0,
        phase_rad=0.0,
        offset=0.5,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var wave_ac = dsplib.generate_sine_wave_raw(ac_config)
    var wave_dc = dsplib.generate_sine_wave_raw(dc_config)
    var biased_signal = dsplib.add_waves(wave_ac, wave_dc, num_samples)
    dsplib.plot_wave(
        biased_signal, sample_rate, num_samples, "composition_ac_dc_offset.png"
    )

    wave_440.free()
    wave_880.free()
    harmonics.free()
    wave_square.free()
    wave_sine.free()
    square_plus_sine.free()
    wave_triangle.free()
    wave_sawtooth.free()
    tri_plus_saw.free()
    wave_h1.free()
    wave_h2.free()
    wave_h3.free()
    temp.free()
    harmonic_series.free()
    wave_clean.free()
    wave_noise.free()
    noisy_signal.free()
    wave_ac.free()
    wave_dc.free()
    biased_signal.free()

    print("\n" + "=" * 50)
    print("Generated files:")
    print("  - composition_harmonics.png      : 440Hz + 880Hz (0.5 amp)")
    print(
        "  - composition_square_sine.png   : Square + sine (filtering effect)"
    )
    print("  - composition_triangle_saw.png  : Triangle + sawtooth")
    print(
        "  - composition_harmonic_series.png: Fundamental + 2nd + 3rd harmonic"
    )
    print("  - composition_sine_noise.png    : Clean sine + Gaussian noise")
    print(
        "  - composition_ac_dc_offset.png   : AC signal + DC bias (0.5 offset)"
    )
