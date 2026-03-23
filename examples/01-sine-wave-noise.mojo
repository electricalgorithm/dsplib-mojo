import dsplib


def main() raises:
    # Prepare wave configuraitons.
    var config_a = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=44100.0,
        duration_s=0.1,
    )
    var config_b = dsplib.WaveConfig(
        frequency_hz=392.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=44100.0,
        duration_s=0.1,
    )

    # Generate basic sine waves.
    var wave_a = dsplib.generate_sine_wave_raw(config_a)
    var wave_b = dsplib.generate_sine_wave_raw(config_b)

    # Generate random noise waves.
    var wave_uniform_noisy = dsplib.generate_random_uniform_noise_raw(
        44100.0, 0.1
    )
    var wave_normal_noisy = dsplib.generate_random_normal_noise_raw(
        44100.0, 0.1
    )

    # Get the number of sampels to use for add waves.
    var num_samples = config_a.get_number_of_samples()

    # Add each pair of waves to eachother.
    var wave_a_uni_noise = dsplib.add_waves(
        wave_a, wave_uniform_noisy, num_samples
    )
    var wave_b_uni_noise = dsplib.add_waves(
        wave_b, wave_uniform_noisy, num_samples
    )
    var wave_a_normal_noise = dsplib.add_waves(
        wave_a, wave_normal_noisy, num_samples
    )
    var wave_b_normal_noise = dsplib.add_waves(
        wave_b, wave_normal_noisy, num_samples
    )
    var wave_a_plus_b = dsplib.add_waves(wave_a, wave_b, num_samples)
    var wave_a_plus_b_plus_uni_noise = dsplib.add_waves(
        wave_a_plus_b, wave_uniform_noisy, num_samples
    )
    var wave_a_plus_b_plus_normal_noise = dsplib.add_waves(
        wave_a_plus_b, wave_normal_noisy, num_samples
    )

    # Save the figures.
    dsplib.plot_wave(wave_a, num_samples, "wave_a.png")
    dsplib.plot_wave(wave_b, num_samples, "wave_b.png")
    dsplib.plot_wave(wave_uniform_noisy, num_samples, "wave_uniform_noisy.png")
    dsplib.plot_wave(wave_normal_noisy, num_samples, "wave_normal_noisy.png")
    dsplib.plot_wave(
        wave_a_normal_noise, num_samples, "wave_a_normal_noise.png"
    )
    dsplib.plot_wave(wave_a_uni_noise, num_samples, "wave_a_uniform_noise.png")
    dsplib.plot_wave(
        wave_b_normal_noise, num_samples, "wave_b_normal_noise.png"
    )
    dsplib.plot_wave(wave_b_uni_noise, num_samples, "wave_b_uniform_noise.png")
    dsplib.plot_wave(wave_a_plus_b, num_samples, "wave_a_plus_b.png")
    dsplib.plot_wave(
        wave_a_plus_b_plus_normal_noise,
        num_samples,
        "wave_a_plus_b_plus_normal_noise.png",
    )
    dsplib.plot_wave(
        wave_a_plus_b_plus_uni_noise,
        num_samples,
        "wave_a_plus_b_plus_uni_noise.png",
    )

    # Free the memories.
    wave_a.free()
    wave_b.free()
    wave_uniform_noisy.free()
    wave_normal_noisy.free()
    wave_a_uni_noise.free()
    wave_b_uni_noise.free()
    wave_a_plus_b.free()
    wave_a_plus_b_plus_uni_noise.free()
    wave_a_normal_noise.free()
    wave_b_normal_noise.free()
    wave_a_plus_b_plus_normal_noise.free()

    print("Completed.")
