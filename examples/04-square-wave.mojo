import dsplib


def main() raises:
    print("Example 04: Square Wave Generation")
    print("=" * 40)

    print("\n1. Basic 50% duty cycle square wave...")
    var config_basic = dsplib.SquareWaveConfig(
        frequency_hz=440.0,
        sample_rate_ss=44100.0,
        duration_s=0.01,
        duty_cycle_perc=50.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
    )
    var wave_basic = dsplib.generate_square_wave_raw(config_basic)
    dsplib.plot_wave(
        wave_basic,
        config_basic.get_number_of_samples(),
        "square_wave_50pct.png",
    )

    print("\n2. 75% duty cycle (spends more time HIGH)...")
    var config_75 = dsplib.SquareWaveConfig(
        frequency_hz=440.0,
        sample_rate_ss=44100.0,
        duration_s=0.01,
        duty_cycle_perc=75.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
    )
    var wave_75 = dsplib.generate_square_wave_raw(config_75)
    dsplib.plot_wave(
        wave_75, config_75.get_number_of_samples(), "square_wave_75pct.png"
    )

    print("\n3. 25% duty cycle (spends more time LOW)...")
    var config_25 = dsplib.SquareWaveConfig(
        frequency_hz=440.0,
        sample_rate_ss=44100.0,
        duration_s=0.01,
        duty_cycle_perc=25.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
    )
    var wave_25 = dsplib.generate_square_wave_raw(config_25)
    dsplib.plot_wave(
        wave_25, config_25.get_number_of_samples(), "square_wave_25pct.png"
    )

    print("\n4. Amplitude scaling (amplify by 2x)...")
    var config_amp = dsplib.SquareWaveConfig(
        frequency_hz=440.0,
        sample_rate_ss=44100.0,
        duration_s=0.01,
        duty_cycle_perc=50.0,
        amplitude=2.0,
        phase_rad=0.0,
        offset=0.0,
    )
    var wave_amp = dsplib.generate_square_wave_raw(config_amp)
    dsplib.plot_wave(
        wave_amp, config_amp.get_number_of_samples(), "square_wave_2x_amp.png"
    )

    print("\n5. DC offset (shifted up by 1.0)...")
    var config_offset = dsplib.SquareWaveConfig(
        frequency_hz=440.0,
        sample_rate_ss=44100.0,
        duration_s=0.01,
        duty_cycle_perc=50.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=1.0,
    )
    var wave_offset = dsplib.generate_square_wave_raw(config_offset)
    dsplib.plot_wave(
        wave_offset,
        config_offset.get_number_of_samples(),
        "square_wave_offset.png",
    )

    print("\n6. Phase shift (shifted by pi/2 radians)...")
    var config_phase = dsplib.SquareWaveConfig(
        frequency_hz=440.0,
        sample_rate_ss=44100.0,
        duration_s=0.01,
        duty_cycle_perc=50.0,
        amplitude=1.0,
        phase_rad=3.14159265 / 2.0,
        offset=0.0,
    )
    var wave_phase = dsplib.generate_square_wave_raw(config_phase)
    dsplib.plot_wave(
        wave_phase,
        config_phase.get_number_of_samples(),
        "square_wave_phase.png",
    )

    wave_basic.free()
    wave_75.free()
    wave_25.free()
    wave_amp.free()
    wave_offset.free()
    wave_phase.free()

    print("\n" + "=" * 40)
    print("Generated files:")
    print("  - square_wave_50pct.png   : 50% duty cycle (standard)")
    print("  - square_wave_75pct.png   : 75% duty cycle (more HIGH time)")
    print("  - square_wave_25pct.png   : 25% duty cycle (more LOW time)")
    print("  - square_wave_2x_amp.png : Amplitude scaled by 2x")
    print("  - square_wave_offset.png  : DC offset (shifted up)")
    print("  - square_wave_phase.png   : Phase shifted by pi/2")
