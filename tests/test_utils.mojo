from std.testing import (
    assert_equal,
    assert_true,
    assert_almost_equal,
    TestSuite,
)
from std.math import pi
from dsplib import (
    is_power_of_2,
    next_power_of_2,
    reverse_bits,
    omega_to_hz,
    magnitude_to_db,
)


def test_is_power_of_2_powers_of_two() raises:
    """Verify that powers of 2 (1, 2, 4, 8, 16, 1024, 2048) are correctly identified.
    """
    assert_true(is_power_of_2(1))
    assert_true(is_power_of_2(2))
    assert_true(is_power_of_2(4))
    assert_true(is_power_of_2(8))
    assert_true(is_power_of_2(16))
    assert_true(is_power_of_2(1024))
    assert_true(is_power_of_2(2048))


def test_is_power_of_2_non_powers_of_two() raises:
    """Verify that non-powers of 2 (0, 3, 5, 7, 100, 1000) are correctly rejected.
    """
    assert_true(not is_power_of_2(0))
    assert_true(not is_power_of_2(3))
    assert_true(not is_power_of_2(5))
    assert_true(not is_power_of_2(7))
    assert_true(not is_power_of_2(100))
    assert_true(not is_power_of_2(1000))


def test_next_power_of_2_exact_powers() raises:
    """Verify that exact powers of 2 return themselves unchanged."""
    assert_equal(next_power_of_2(1), 1)
    assert_equal(next_power_of_2(2), 2)
    assert_equal(next_power_of_2(4), 4)
    assert_equal(next_power_of_2(8), 8)
    assert_equal(next_power_of_2(1024), 1024)


def test_next_power_of_2_non_powers() raises:
    """Verify that non-powers of 2 round up to the next power of 2."""
    assert_equal(next_power_of_2(3), 4)
    assert_equal(next_power_of_2(5), 8)
    assert_equal(next_power_of_2(7), 8)
    assert_equal(next_power_of_2(9), 16)
    assert_equal(next_power_of_2(1000), 1024)
    assert_equal(next_power_of_2(1025), 2048)


def test_reverse_bits_3_bits() raises:
    """Verify bit reversal for 3-bit indices (N=8 values)."""
    assert_equal(reverse_bits(0, 3), 0)
    assert_equal(reverse_bits(1, 3), 4)
    assert_equal(reverse_bits(2, 3), 2)
    assert_equal(reverse_bits(3, 3), 6)
    assert_equal(reverse_bits(4, 3), 1)
    assert_equal(reverse_bits(5, 3), 5)
    assert_equal(reverse_bits(6, 3), 3)
    assert_equal(reverse_bits(7, 3), 7)


def test_reverse_bits_4_bits() raises:
    """Verify bit reversal for 4-bit indices (N=16 values)."""
    assert_equal(reverse_bits(0, 4), 0)
    assert_equal(reverse_bits(1, 4), 8)
    assert_equal(reverse_bits(3, 4), 12)
    assert_equal(reverse_bits(15, 4), 15)


def test_omega_to_hz_dc() raises:
    """Verify omega=0 returns 0 Hz."""
    var result = omega_to_hz(0.0, 44100.0)
    assert_almost_equal(result, 0.0, atol=1e-10)


def test_omega_to_hz_nyquist() raises:
    """Verify omega=pi at fs=44100 returns Nyquist (22050 Hz)."""
    var result = omega_to_hz(pi, 44100.0)
    assert_almost_equal(result, 22050.0, atol=1e-10)


def test_omega_to_hz_quarter_nyquist() raises:
    """Verify omega=pi/2 at fs=44100 returns 11025 Hz."""
    var result = omega_to_hz(pi / 2.0, 44100.0)
    assert_almost_equal(result, 11025.0, atol=1e-10)


def test_omega_to_hz_linearity() raises:
    """Verify omega_to_hz is linear with sample rate."""
    var omega: Float64 = pi / 4.0
    var result_44k = omega_to_hz(omega, 44100.0)
    var result_48k = omega_to_hz(omega, 48000.0)
    assert_almost_equal(result_44k / result_48k, 44100.0 / 48000.0, rtol=1e-10)


def test_magnitude_to_db_unity() raises:
    """Verify magnitude=1.0 returns 0 dB."""
    var result = magnitude_to_db(1.0)
    assert_almost_equal(result, 0.0, atol=1e-10)


def test_magnitude_to_db_half() raises:
    """Verify magnitude=0.5 returns approximately -6.02 dB (20*log10(0.5))."""
    var result = magnitude_to_db(0.5)
    assert_almost_equal(result, -6.0206, atol=0.01)


def test_magnitude_to_db_tenth() raises:
    """Verify magnitude=0.1 returns approximately -20 dB."""
    var result = magnitude_to_db(0.1)
    assert_almost_equal(result, -20.0, atol=0.01)


def test_magnitude_to_db_double() raises:
    """Verify magnitude=2.0 returns approximately +6.02 dB (20*log10(2))."""
    var result = magnitude_to_db(2.0)
    assert_almost_equal(result, 6.0206, atol=0.01)


def test_magnitude_to_db_near_zero() raises:
    """Verify near-zero magnitude returns floor value (-100 dB by default)."""
    var result = magnitude_to_db(1e-20)
    assert_almost_equal(result, -100.0, atol=0.1)


def test_magnitude_to_db_custom_floor() raises:
    """Verify custom floor value is used for near-zero."""
    var result = magnitude_to_db(1e-20, floor=-200.0)
    assert_almost_equal(result, -200.0, atol=0.1)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
