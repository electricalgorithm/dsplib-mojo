import dsplib


fn generate_harmonic_series(
    fundamental_hz: Float64,
    sample_rate: Float64,
    duration: Float64,
    num_harmonics: Int,
    amplitudes: UnsafePointer[Float64, MutExternalOrigin],
) raises -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a complex tone by summing harmonics (additive synthesis).

    Each harmonic is an integer multiple of the fundamental frequency.
    Harmonic 1 = fundamental, Harmonic 2 = 2x fundamental, etc.

    Params:
        fundamental_hz: Base frequency (e.g., 440 for A4).
        sample_rate: Samples per second.
        duration: Length in seconds.
        num_harmonics: How many harmonics to include.
        amplitudes: Array of relative amplitudes for each harmonic.

    Returns:
        Pointer to the generated samples (caller must free).
    """
    var num_samples = Int(sample_rate * duration)
    var result = dsplib.allocate_buffer(num_samples)

    for h in range(num_harmonics):
        var harmonic_freq = fundamental_hz * Float64(h + 1)
        var harmonic_amp = amplitudes[h]

        var config = dsplib.WaveConfig(
            frequency_hz=harmonic_freq,
            amplitude=harmonic_amp,
            phase_rad=0.0,
            offset=0.0,
            sample_rate_ss=sample_rate,
            duration_s=duration,
        )
        var harmonic = dsplib.generate_sine_wave_raw(config)

        for i in range(num_samples):
            result[i] = result[i] + harmonic[i]

        harmonic.free()

    return result


def main() raises:
    print("Example 09: Harmonics and Instrument Timbre")
    print("=" * 60)
    print()
    print("THEORY: What makes instruments sound different?")
    print("-" * 60)
    print()
    print("Every periodic sound can be decomposed into sine waves called")
    print("HARMONICS. The pattern of which harmonics are present and how")
    print("loud they are determines TIMBRE (the 'character' of the sound).")
    print()
    print("Harmonic Series:")
    print("  Harmonic 1: f (fundamental - the pitch we hear)")
    print("  Harmonic 2: 2f (one octave up)")
    print("  Harmonic 3: 3f (fifth above 2nd octave)")
    print("  Harmonic 4: 4f (two octaves up)")
    print("  Harmonic 5: 5f (major third above 2nd octave)")
    print("  ...and so on")
    print()
    print("Different instruments emphasize different harmonics:")
    print("  - Piano: Strong fundamental, quickly fading harmonics")
    print("  - Violin: Rich in upper harmonics, sustained")
    print("  - Flute: Very few harmonics, mostly fundamental")
    print("  - Sawtooth: All harmonics present (synthesizer sound)")
    print()
    print("This example generates 3-second WAV files for listening,")
    print("but plots only 0.01 seconds for better visualization.")
    print()

    var sample_rate: Float64 = 44100.0
    var wav_duration: Float64 = 3.0  # For WAV files (listenable)
    var plot_duration: Float64 = 0.01  # For plots (visual clarity)
    var frequency: Float64 = 440.0  # A4

    var num_samples_wav = Int(sample_rate * wav_duration)
    var num_samples_plot = Int(sample_rate * plot_duration)

    # 1. Pure sine wave (fundamental only)
    print("1. Generating pure sine wave (fundamental only)...")

    # WAV (3 seconds)
    var pure_config_wav = dsplib.WaveConfig(
        frequency_hz=frequency,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=wav_duration,
    )
    var pure_sine_wav = dsplib.generate_sine_wave_raw(pure_config_wav)
    dsplib.write_wav(
        "harmonics_01_pure_sine.wav", 44100, pure_sine_wav, num_samples_wav
    )

    # Plot (0.01 seconds)
    var pure_config_plot = dsplib.WaveConfig(
        frequency_hz=frequency,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=plot_duration,
    )
    var pure_sine_plot = dsplib.generate_sine_wave_raw(pure_config_plot)
    dsplib.plot_wave(
        pure_sine_plot,
        sample_rate,
        num_samples_plot,
        "harmonics_01_pure_sine.png",
        "Pure Sine Wave (440 Hz)",
    )
    pure_sine_plot.free()

    # 2. Piano-like tone: strong fundamental, fading harmonics
    print("2. Building piano-like tone (7 harmonics)...")

    var piano_amps = dsplib.allocate_buffer(7)
    piano_amps[0] = 1.0
    piano_amps[1] = 0.5
    piano_amps[2] = 0.25
    piano_amps[3] = 0.125
    piano_amps[4] = 0.0625
    piano_amps[5] = 0.03
    piano_amps[6] = 0.015

    var piano_tone_wav = generate_harmonic_series(
        frequency, sample_rate, wav_duration, 7, piano_amps
    )
    dsplib.write_wav(
        "harmonics_02_piano_tone.wav", 44100, piano_tone_wav, num_samples_wav
    )

    var piano_tone_plot = generate_harmonic_series(
        frequency, sample_rate, plot_duration, 7, piano_amps
    )
    piano_amps.free()

    dsplib.plot_wave(
        piano_tone_plot,
        sample_rate,
        num_samples_plot,
        "harmonics_02_piano_tone.png",
        "Piano-like Tone (7 harmonics)",
    )
    piano_tone_plot.free()

    # 3. Violin-like tone: rich in upper harmonics
    print("3. Building violin-like tone (8 harmonics)...")

    var violin_amps = dsplib.allocate_buffer(8)
    violin_amps[0] = 1.0
    violin_amps[1] = 0.8
    violin_amps[2] = 0.7
    violin_amps[3] = 0.5
    violin_amps[4] = 0.3
    violin_amps[5] = 0.2
    violin_amps[6] = 0.1
    violin_amps[7] = 0.05

    var violin_tone_wav = generate_harmonic_series(
        frequency, sample_rate, wav_duration, 8, violin_amps
    )
    dsplib.write_wav(
        "harmonics_03_violin_tone.wav", 44100, violin_tone_wav, num_samples_wav
    )

    var violin_tone_plot = generate_harmonic_series(
        frequency, sample_rate, plot_duration, 8, violin_amps
    )
    violin_amps.free()

    dsplib.plot_wave(
        violin_tone_plot,
        sample_rate,
        num_samples_plot,
        "harmonics_03_violin_tone.png",
        "Violin-like Tone (8 harmonics)",
    )
    violin_tone_plot.free()

    # 4. Flute-like tone: very few harmonics
    print("4. Building flute-like tone (4 harmonics)...")

    var flute_amps = dsplib.allocate_buffer(4)
    flute_amps[0] = 1.0
    flute_amps[1] = 0.2
    flute_amps[2] = 0.05
    flute_amps[3] = 0.01

    var flute_tone_wav = generate_harmonic_series(
        frequency, sample_rate, wav_duration, 4, flute_amps
    )
    dsplib.write_wav(
        "harmonics_04_flute_tone.wav", 44100, flute_tone_wav, num_samples_wav
    )

    var flute_tone_plot = generate_harmonic_series(
        frequency, sample_rate, plot_duration, 4, flute_amps
    )
    flute_amps.free()

    dsplib.plot_wave(
        flute_tone_plot,
        sample_rate,
        num_samples_plot,
        "harmonics_04_flute_tone.png",
        "Flute-like Tone (4 harmonics)",
    )
    flute_tone_plot.free()

    # 5. Sawtooth wave (built-in harmonics)
    print("5. Sawtooth wave (many harmonics - synthesizer sound)...")

    # WAV
    var saw_config_wav = dsplib.SawtoothWaveConfig(
        frequency_hz=frequency,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=wav_duration,
    )
    var sawtooth_wav = dsplib.generate_sawtooth_wave_raw(saw_config_wav)
    dsplib.write_wav(
        "harmonics_05_sawtooth.wav", 44100, sawtooth_wav, num_samples_wav
    )

    # Plot
    var saw_config_plot = dsplib.SawtoothWaveConfig(
        frequency_hz=frequency,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=plot_duration,
    )
    var sawtooth_plot = dsplib.generate_sawtooth_wave_raw(saw_config_plot)
    dsplib.plot_wave(
        sawtooth_plot,
        sample_rate,
        num_samples_plot,
        "harmonics_05_sawtooth.png",
        "Sawtooth Wave (Rich in harmonics)",
    )
    sawtooth_plot.free()

    # 6. A major chord with piano-like harmonics
    print("6. Creating A major chord (piano-like)...")

    var chord_duration: Float64 = 3.0  # Chord is shorter for better sound

    # Note: A4 = 440 Hz, C#5 = 554.37 Hz, E5 = 659.25 Hz
    fn create_piano_note_wav(
        freq: Float64, dur: Float64
    ) raises -> UnsafePointer[Float64, MutExternalOrigin]:
        var amps = dsplib.allocate_buffer(7)
        amps[0] = 1.0
        amps[1] = 0.5
        amps[2] = 0.25
        amps[3] = 0.125
        amps[4] = 0.0625
        amps[5] = 0.03
        amps[6] = 0.015
        return generate_harmonic_series(freq, sample_rate, dur, 7, amps)

    var a4 = create_piano_note_wav(440.0, chord_duration)
    var cs5 = create_piano_note_wav(554.37, chord_duration)
    var e5 = create_piano_note_wav(659.25, chord_duration)

    var num_chord_wav = Int(sample_rate * chord_duration)

    var chord = dsplib.add_waves(a4, cs5, num_chord_wav)
    chord = dsplib.add_waves(chord, e5, num_chord_wav)

    a4.free()
    cs5.free()
    e5.free()

    dsplib.write_wav(
        "harmonics_06_chord_piano.wav", 44100, chord, num_chord_wav
    )

    # Plot version (shorter)
    var a4_plot = create_piano_note_wav(440.0, plot_duration)
    var cs5_plot = create_piano_note_wav(554.37, plot_duration)
    var e5_plot = create_piano_note_wav(659.25, plot_duration)

    var chord_plot = dsplib.add_waves(a4_plot, cs5_plot, num_samples_plot)
    chord_plot = dsplib.add_waves(chord_plot, e5_plot, num_samples_plot)

    a4_plot.free()
    cs5_plot.free()
    e5_plot.free()

    dsplib.plot_wave(
        chord_plot,
        sample_rate,
        num_samples_plot,
        "harmonics_06_chord_piano.png",
        "A Major Chord (Piano-like)",
    )
    chord_plot.free()

    # Cleanup
    pure_sine_wav.free()
    piano_tone_wav.free()
    violin_tone_wav.free()
    flute_tone_wav.free()
    sawtooth_wav.free()
    chord.free()

    print()
    print("=" * 60)
    print("Generated files:")
    print()
    print("  WAV files (3 seconds each - LISTEN to them!):")
    print("    - harmonics_01_pure_sine.wav    : Just 440 Hz")
    print("    - harmonics_02_piano_tone.wav  : Fundamental + 6 harmonics")
    print("    - harmonics_03_violin_tone.wav : Rich upper harmonics")
    print("    - harmonics_04_flute_tone.wav  : Mostly fundamental")
    print("    - harmonics_05_sawtooth.wav    : All harmonics (bright)")
    print("    - harmonics_06_chord_piano.wav : Chord with harmonics")
    print()
    print("  Plots (0.01 seconds - visual clarity):")
    print("    - harmonics_01_pure_sine.png")
    print("    - harmonics_02_piano_tone.png")
    print("    - harmonics_03_violin_tone.png")
    print("    - harmonics_04_flute_tone.png")
    print("    - harmonics_05_sawtooth.png")
    print("    - harmonics_06_chord_piano.png")
    print()
    print("LISTEN: Notice how the 'character' changes with harmonics!")
    print()
    print("ANALYSIS: Look at the plots - pure sine is smooth, while")
    print("sawtooth looks 'sharp' because of the high-frequency harmonics.")
