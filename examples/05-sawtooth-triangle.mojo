import dsplib


def main() raises:
    print("Example 05: Sawtooth and Triangle Wave Generation")
    print("=" * 50)

    var sr = 44100.0

    print("\n1. Basic sawtooth wave...")
    var sawtooth_config = dsplib.SawtoothWaveConfig(
        frequency_hz=220.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sr,
        duration_s=0.02,
    )
    var sawtooth = dsplib.generate_sawtooth_wave_raw(sawtooth_config)
    dsplib.plot_wave(
        sawtooth,
        sr,
        sawtooth_config.get_number_of_samples(),
        "sawtooth_basic.png",
    )

    print("\n2. Basic triangle wave...")
    var triangle_config = dsplib.TriangleWaveConfig(
        frequency_hz=220.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sr,
        duration_s=0.02,
    )
    var triangle = dsplib.generate_triangle_wave_raw(triangle_config)
    dsplib.plot_wave(
        triangle,
        sr,
        triangle_config.get_number_of_samples(),
        "triangle_basic.png",
    )

    print("\n3. Amplitude scaling (2x)...")
    var triangle_amp = dsplib.TriangleWaveConfig(
        frequency_hz=220.0,
        amplitude=2.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sr,
        duration_s=0.02,
    )
    var triangle_2x = dsplib.generate_triangle_wave_raw(triangle_amp)
    dsplib.plot_wave(
        triangle_2x,
        sr,
        triangle_amp.get_number_of_samples(),
        "triangle_2x_amp.png",
    )

    print("\n4. DC offset (shifted up by 0.5)...")
    var triangle_offset = dsplib.TriangleWaveConfig(
        frequency_hz=220.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.5,
        sample_rate_ss=sr,
        duration_s=0.02,
    )
    var triangle_dc = dsplib.generate_triangle_wave_raw(triangle_offset)
    dsplib.plot_wave(
        triangle_dc,
        sr,
        triangle_offset.get_number_of_samples(),
        "triangle_offset.png",
    )

    print("\n5. Phase shift (pi/4 radians)...")
    var triangle_phase = dsplib.TriangleWaveConfig(
        frequency_hz=220.0,
        amplitude=1.0,
        phase_rad=3.14159265 / 4.0,
        offset=0.0,
        sample_rate_ss=sr,
        duration_s=0.02,
    )
    var triangle_pi4 = dsplib.generate_triangle_wave_raw(triangle_phase)
    dsplib.plot_wave(
        triangle_pi4,
        sr,
        triangle_phase.get_number_of_samples(),
        "triangle_phase.png",
    )

    sawtooth.free()
    triangle.free()
    triangle_2x.free()
    triangle_dc.free()
    triangle_pi4.free()

    print("\n" + "=" * 50)
    print("Generated files:")
    print("  - sawtooth_basic.png   : Basic sawtooth wave")
    print("  - triangle_basic.png   : Basic triangle wave")
    print("  - triangle_2x_amp.png : Triangle with 2x amplitude")
    print("  - triangle_offset.png  : Triangle with DC offset")
    print("  - triangle_phase.png   : Triangle with phase shift")
