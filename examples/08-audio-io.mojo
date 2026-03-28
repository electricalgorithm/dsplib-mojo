import dsplib


def main() raises:
    print("Example 08: WAV Audio File I/O")
    print("=" * 50)

    var sample_rate: Int = 44100
    var duration: Float64 = 3
    var num_samples = Int(Float64(sample_rate) * duration)

    print("\n1. Generate a 440 Hz sine wave...")
    var config = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=0.8,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=Float64(sample_rate),
        duration_s=duration,
    )
    var sine_wave = dsplib.generate_sine_wave_raw(config)

    print("\n2. Save as WAV file...")
    dsplib.write_wav("sine_440hz.wav", sample_rate, sine_wave, num_samples)
    print("  Saved: sine_440hz.wav")

    print("\n3. Create a chord (A major: A4 + C#5 + E5)...")
    var config_a4 = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=Float64(sample_rate),
        duration_s=duration,
    )
    var config_cs5 = dsplib.WaveConfig(
        frequency_hz=554.37,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=Float64(sample_rate),
        duration_s=duration,
    )
    var config_e5 = dsplib.WaveConfig(
        frequency_hz=659.25,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=Float64(sample_rate),
        duration_s=duration,
    )

    var wave_a4 = dsplib.generate_sine_wave_raw(config_a4)
    var wave_cs5 = dsplib.generate_sine_wave_raw(config_cs5)
    var wave_e5 = dsplib.generate_sine_wave_raw(config_e5)
    var num_chord = config_a4.get_number_of_samples()

    var chord = dsplib.add_waves(wave_a4, wave_cs5, num_chord)
    chord = dsplib.add_waves(chord, wave_e5, num_chord)

    print("\n4. Save the chord as WAV...")
    dsplib.write_wav("a_major_chord.wav", sample_rate, chord, num_chord)
    print("  Saved: a_major_chord.wav")

    sine_wave.free()
    wave_a4.free()
    wave_cs5.free()
    wave_e5.free()
    chord.free()

    print("\n" + "=" * 50)
    print("Generated files:")
    print("  WAV files:")
    print("    - sine_440hz.wav     : 440 Hz sine wave")
    print("    - a_major_chord.wav : A4 + C#5 + E5 chord")
