from std.testing import assert_equal, assert_true, TestSuite
from dsplib import is_power_of_2, next_power_of_2, reverse_bits


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


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
