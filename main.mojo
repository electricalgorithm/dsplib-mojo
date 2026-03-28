import dsplib


def main() raises:
    var wave_config = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=1,
        phase_rad=0,
        offset=0,
        sample_rate_ss=44100.0,
        duration_s=0.05,
    )

    var wave_a = dsplib.generate_sine_wave_raw(wave_config)
    dsplib.plot_wave(
        wave_a, 44100.0, wave_config.get_number_of_samples(), "wave_a.png"
    )
    wave_a.free()

    print("DSPLib is imported, and works great. Feel free to check examples!")
