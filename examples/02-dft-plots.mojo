import dsplib


def main() raises:
    # Set global sample rate and duration for all the signals.
    var SAMPLE_RATE = 44100.0
    var DURATION = 0.05

    # Create configs for sine functions.
    var config_a = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=SAMPLE_RATE,
        duration_s=DURATION,
    )
    var config_b = dsplib.WaveConfig(
        frequency_hz=880.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=SAMPLE_RATE,
        duration_s=DURATION,
    )

    var wave_a = dsplib.generate_sine_wave_raw(config_a)
    var wave_b = dsplib.generate_sine_wave_raw(config_b)
    var wave_uniform_noisy = dsplib.generate_random_uniform_noise_raw(
        SAMPLE_RATE, DURATION
    )
    var wave_normal_noisy = dsplib.generate_random_normal_noise_raw(
        SAMPLE_RATE, DURATION
    )
    var num_samples = config_a.get_number_of_samples()
    var wave_a_plus_b = dsplib.add_waves(wave_a, wave_b, num_samples)

    print("Plotting time domain waves...")
    dsplib.plot_wave(wave_a, num_samples, "wave_a.png")
    dsplib.plot_wave(wave_b, num_samples, "wave_b.png")
    dsplib.plot_wave(wave_a_plus_b, num_samples, "wave_a_plus_b.png")

    print("Calculating and plotting frequency domains (DFT)...")

    print("  Processing Wave A (440Hz)...")
    var dft_a = dsplib.compute_dft_raw(wave_a, num_samples)
    dsplib.plot_frequency_domain(
        dft_a, num_samples, config_a.sample_rate_ss, "dft_a.png"
    )
    dft_a.free()

    print("  Processing Wave B (880Hz)...")
    var dft_b = dsplib.compute_dft_raw(wave_b, num_samples)
    dsplib.plot_frequency_domain(
        dft_b, num_samples, config_b.sample_rate_ss, "dft_b.png"
    )
    dft_b.free()

    print("  Processing Uniform Noise...")
    var dft_uni = dsplib.compute_dft_raw(wave_uniform_noisy, num_samples)
    dsplib.plot_frequency_domain(
        dft_uni, num_samples, SAMPLE_RATE, "dft_uniform_noise.png"
    )
    dft_uni.free()

    print("  Processing Normal Noise...")
    var dft_norm = dsplib.compute_dft_raw(wave_normal_noisy, num_samples)
    dsplib.plot_frequency_domain(
        dft_norm, num_samples, SAMPLE_RATE, "dft_normal_noise.png"
    )
    dft_norm.free()

    print("  Processing Wave A + B...")
    var dft_ab = dsplib.compute_dft_raw(wave_a_plus_b, num_samples)
    dsplib.plot_frequency_domain(
        dft_ab, num_samples, config_a.sample_rate_ss, "dft_a_plus_b.png"
    )
    dft_ab.free()

    wave_a.free()
    wave_b.free()
    wave_uniform_noisy.free()
    wave_normal_noisy.free()
    wave_a_plus_b.free()

    print("Completed.")
