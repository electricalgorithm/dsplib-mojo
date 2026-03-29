import dsplib


def main() raises:
    var sample_rate: Float64 = 44100.0
    var num_samples = 2048

    print("Generating frequency spectrum plots...")
    print("Sample rate:", sample_rate, "Hz")
    print("Samples:", num_samples)
    print("")

    var sine_config = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=Float64(num_samples) / sample_rate,
    )
    var sine = dsplib.generate_sine_wave_raw(sine_config)

    print("Plotting sine wave (440 Hz)...")
    dsplib.plot_fft_db(
        sine,
        num_samples,
        sample_rate,
        "build/examples/spectrum_sine.png",
        title="Sine Wave (440 Hz) - Frequency Spectrum",
    )
    sine.free()

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

    print("Plotting A major chord (A4=440Hz, C#5=554Hz, E5=659Hz)...")
    dsplib.plot_fft_db(
        chord,
        num_samples,
        sample_rate,
        "build/examples/spectrum_chord.png",
        title="A Major Chord - Frequency Spectrum",
    )

    wave_a4.free()
    wave_e5.free()
    wave_cs5.free()
    chord.free()

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

    print("Plotting square wave (220 Hz) - note the odd harmonics...")
    dsplib.plot_fft_db(
        square,
        num_samples,
        sample_rate,
        "build/examples/spectrum_square.png",
        title="Square Wave (220 Hz) - Frequency Spectrum (shows odd harmonics)",
    )
    square.free()

    print("")
    print("Plots saved:")
    print("  - build/examples/spectrum_sine.png")
    print("  - build/examples/spectrum_chord.png")
    print("  - build/examples/spectrum_square.png")
