from std.testing import assert_almost_equal, TestSuite
from dsplib import (
    WaveConfig,
    generate_sine_wave_raw,
    add_waves,
    compute_dft_raw,
    compute_fft_recursive,
    compute_time_domain_energy,
    compute_spectral_energy,
)


def test_dft_fft_match_single_tone() raises:
    """Verify that FFT produces identical results to DFT for a single 400Hz tone.

    DFT and FFT are mathematically equivalent - FFT is just faster (O(N log N) vs O(N²)).
    This test generates a pure sine wave and compares the magnitude spectrum from both.
    """
    var sample_rate: Float64 = 44100.0
    var frequency: Float64 = 400.0
    var num_samples = 512

    var config = WaveConfig(
        frequency_hz=frequency,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=Float64(num_samples) / sample_rate,
    )
    var signal = generate_sine_wave_raw(config)

    var dft_result = compute_dft_raw(signal, num_samples)
    var fft_result = compute_fft_recursive(signal, num_samples)

    var max_diff: Float64 = 0.0
    for i in range(num_samples):
        var dft_mag = dft_result[i].magnitude()
        var fft_mag = fft_result[i].magnitude()
        var diff = abs(dft_mag - fft_mag)
        if diff > max_diff:
            max_diff = diff

    signal.free()
    dft_result.free()
    fft_result.free()

    assert_almost_equal(max_diff, 0.0, atol=1e-10)


def test_dft_fft_match_chord() raises:
    """Verify that FFT matches DFT for a chord (two simultaneous frequencies).

    A chord is a superposition of multiple frequencies. This test verifies
    that the FFT correctly handles the linear combination of A4 (440Hz) and E5 (659Hz).
    """
    var sample_rate: Float64 = 44100.0
    var num_samples = 512
    var duration = Float64(num_samples) / sample_rate

    var config_a4 = WaveConfig(
        frequency_hz=440.0,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var config_e5 = WaveConfig(
        frequency_hz=659.25,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )

    var wave_a4 = generate_sine_wave_raw(config_a4)
    var wave_e5 = generate_sine_wave_raw(config_e5)
    var chord = add_waves(wave_a4, wave_e5, num_samples)

    var dft_result = compute_dft_raw(chord, num_samples)
    var fft_result = compute_fft_recursive(chord, num_samples)

    var max_diff: Float64 = 0.0
    for i in range(num_samples):
        var dft_mag = dft_result[i].magnitude()
        var fft_mag = fft_result[i].magnitude()
        var diff = abs(dft_mag - fft_mag)
        if diff > max_diff:
            max_diff = diff

    wave_a4.free()
    wave_e5.free()
    chord.free()
    dft_result.free()
    fft_result.free()

    assert_almost_equal(max_diff, 0.0, atol=1e-10)


def test_parsevals_theorem_single_tone() raises:
    """Verify Parseval's theorem for a single 440Hz tone.

    Parseval's theorem states: total energy in time domain = total energy in frequency domain.
    For a signal x[n] with N samples:
        Σ|x[n]|² = (1/N) * Σ|X[k]|²

    This test computes energy both ways and verifies they match.
    """
    var sample_rate: Float64 = 44100.0
    var frequency: Float64 = 440.0
    var num_samples = 1024

    var config = WaveConfig(
        frequency_hz=frequency,
        amplitude=0.8,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=Float64(num_samples) / sample_rate,
    )
    var signal = generate_sine_wave_raw(config)

    var dft_result = compute_dft_raw(signal, num_samples)

    var time_energy = compute_time_domain_energy(signal, num_samples)
    var freq_energy = compute_spectral_energy(dft_result, num_samples)

    var ratio = freq_energy / time_energy
    var expected_ratio = Float64(num_samples)

    signal.free()
    dft_result.free()

    assert_almost_equal(ratio, expected_ratio, rtol=1e-10)


def test_parsevals_theorem_chord() raises:
    """Verify Parseval's theorem for an A major chord (A4, C#5, E5).

    Energy conservation should hold regardless of how many frequencies
    are present in the signal.
    """
    var sample_rate: Float64 = 44100.0
    var num_samples = 1024
    var duration = Float64(num_samples) / sample_rate

    var config_a4 = WaveConfig(
        frequency_hz=440.0,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var config_cs5 = WaveConfig(
        frequency_hz=554.37,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var config_e5 = WaveConfig(
        frequency_hz=659.25,
        amplitude=0.5,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )

    var wave_a4 = generate_sine_wave_raw(config_a4)
    var wave_cs5 = generate_sine_wave_raw(config_cs5)
    var wave_e5 = generate_sine_wave_raw(config_e5)

    var chord = add_waves(wave_a4, wave_cs5, num_samples)
    chord = add_waves(chord, wave_e5, num_samples)

    var dft_result = compute_dft_raw(chord, num_samples)

    var time_energy = compute_time_domain_energy(chord, num_samples)
    var freq_energy = compute_spectral_energy(dft_result, num_samples)

    var ratio = freq_energy / time_energy
    var expected_ratio = Float64(num_samples)

    wave_a4.free()
    wave_cs5.free()
    wave_e5.free()
    chord.free()
    dft_result.free()

    assert_almost_equal(ratio, expected_ratio, rtol=1e-10)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
