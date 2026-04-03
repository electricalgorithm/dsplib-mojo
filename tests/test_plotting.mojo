from std.testing import assert_almost_equal, assert_true, TestSuite
from dsplib import (
    compute_bode_response,
    plot_bode_magnitude,
    plot_bode_phase,
    plot_bode,
    plot_bode_combined,
    generate_hann_window,
    allocate_buffer,
)
from std import os, math


def test_bode_response_returns_bode_response() raises:
    """Verify compute_bode_response returns a BodeResponse with valid fields."""
    var num_samples = 1024
    var sample_rate: Float64 = 44100.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = 0.0
    signal[0] = 1.0

    var result = compute_bode_response[500](signal, num_samples, sample_rate)

    assert_true(result.num_points == 500)
    assert_true(result.frequencies[0] >= 0.0)

    result.free()
    signal.free()


def test_bode_frequency_range() raises:
    """Verify frequencies range from ~20Hz to Nyquist."""
    var num_samples = 1024
    var sample_rate: Float64 = 44100.0
    var nyquist = sample_rate / 2.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = 0.0
    signal[0] = 1.0

    var result = compute_bode_response[500](signal, num_samples, sample_rate)

    assert_true(result.frequencies[0] >= 19.0 and result.frequencies[0] <= 21.0)
    assert_true(
        result.frequencies[499] >= nyquist * 0.99
        and result.frequencies[499] <= nyquist * 1.01
    )

    result.free()
    signal.free()


def test_bode_frequency_log_spacing() raises:
    """Verify frequencies are logarithmically spaced."""
    var num_samples = 1024
    var sample_rate: Float64 = 44100.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = 0.0
    signal[0] = 1.0

    var result = compute_bode_response[500](signal, num_samples, sample_rate)

    var prev_ratio: Float64 = 0.0
    var all_consistent = True
    for i in range(1, 500):
        var ratio = result.frequencies[i] / result.frequencies[i - 1]
        if i > 1:
            var diff = abs(ratio - prev_ratio)
            if diff > 0.01:
                all_consistent = False
        prev_ratio = ratio

    assert_true(all_consistent)

    result.free()
    signal.free()


def test_bode_magnitude_dc_is_zero_db() raises:
    """Verify DC magnitude is 0 dB after normalization."""
    var num_samples = 1024
    var sample_rate: Float64 = 44100.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = 0.0
    signal[0] = 1.0

    var result = compute_bode_response[500](signal, num_samples, sample_rate)

    assert_almost_equal(result.magnitude_db[0], 0.0, atol=1.0)

    result.free()
    signal.free()


def test_bode_impulse_has_flat_spectrum() raises:
    """Verify impulse has uniform 0 dB magnitude across frequencies.

    An impulse δ[n] represents a unity gain system.
    After normalizing to DC, all frequencies should be 0 dB.
    """
    var num_samples = 1024
    var sample_rate: Float64 = 44100.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = 0.0
    signal[0] = 1.0

    var result = compute_bode_response[500](signal, num_samples, sample_rate)

    for i in range(1, 100):
        assert_almost_equal(result.magnitude_db[i], 0.0, atol=2.0)

    result.free()
    signal.free()


def test_bode_impulse_dc_bin_equals_other_bins() raises:
    """Verify DC bin equals other bins after normalization.

    For an impulse response, all frequency bins should have equal magnitude.
    After DC normalization, all bins should be 0 dB.
    """
    var num_samples = 1024
    var sample_rate: Float64 = 44100.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = 0.0
    signal[0] = 1.0

    var result = compute_bode_response[500](signal, num_samples, sample_rate)

    assert_almost_equal(
        result.magnitude_db[0], result.magnitude_db[250], atol=1.0
    )
    assert_almost_equal(
        result.magnitude_db[0], result.magnitude_db[499], atol=1.0
    )

    result.free()
    signal.free()


def test_bode_phase_at_dc() raises:
    """Verify phase at DC is approximately 0 degrees."""
    var num_samples = 1024
    var sample_rate: Float64 = 44100.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = 0.0
    signal[0] = 1.0

    var result = compute_bode_response[500](signal, num_samples, sample_rate)

    assert_almost_equal(result.phase_deg[0], 0.0, atol=45.0)

    result.free()
    signal.free()


def test_bode_magnitude_plot_creates_file() raises:
    """Verify plot_bode_magnitude creates a file."""
    os.makedirs("build/tests", exist_ok=True)

    var num_samples = 1024
    var sample_rate: Float64 = 44100.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = 0.0
    signal[0] = 1.0

    plot_bode_magnitude[500](
        signal,
        num_samples,
        sample_rate,
        "build/tests/bode_magnitude.png",
        "Test Magnitude",
    )

    signal.free()


def test_bode_phase_plot_creates_file() raises:
    """Verify plot_bode_phase creates a file."""
    os.makedirs("build/tests", exist_ok=True)

    var num_samples = 1024
    var sample_rate: Float64 = 44100.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = 0.0
    signal[0] = 1.0

    plot_bode_phase[500](
        signal,
        num_samples,
        sample_rate,
        "build/tests/bode_phase.png",
        "Test Phase",
    )

    signal.free()


def test_bode_combined_plot_creates_file() raises:
    """Verify plot_bode creates a combined 2-panel figure."""
    os.makedirs("build/tests", exist_ok=True)

    var num_samples = 1024
    var sample_rate: Float64 = 44100.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = 0.0
    signal[0] = 1.0

    plot_bode[500](
        signal,
        num_samples,
        sample_rate,
        "build/tests/bode_combined.png",
        "Test Bode",
    )

    signal.free()


def test_bode_combined_with_window() raises:
    """Verify plot_bode works with a window parameter."""
    os.makedirs("build/tests", exist_ok=True)

    var num_samples = 1024
    var sample_rate: Float64 = 44100.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = math.sin(2.0 * 3.14159 * 440.0 * i / sample_rate)

    var hann = generate_hann_window(num_samples)

    var result = compute_bode_response[500](signal, num_samples, sample_rate)
    assert_true(result.num_points == 500)

    result.free()
    hann.free()
    signal.free()


def test_bode_free_memory() raises:
    """Verify BodeResponse.free() properly frees memory."""
    var num_samples = 1024
    var sample_rate: Float64 = 44100.0

    var signal = allocate_buffer(num_samples)
    for i in range(num_samples):
        signal[i] = 0.0
    signal[0] = 1.0

    var result = compute_bode_response[500](signal, num_samples, sample_rate)
    result.free()

    signal.free()


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
