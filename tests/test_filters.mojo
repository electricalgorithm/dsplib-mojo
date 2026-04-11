from std.testing import assert_almost_equal, TestSuite
from std.math import pi
from dsplib import freqz
from dsplib.filters import evaluate_polynomial
from dsplib.core import Complex


def test_evaluate_polynomial_at_dc() raises:
    """Verify polynomial evaluation at DC (omega=0).

    At omega=0, z^(-k) = r^(-k), so the polynomial should simplify to:
        P(0, r) = sum(coeff[k] * r^(-k))

    For r=1 and coeff=[1.0, 2.0], expected result is 1.0 + 2.0 = 3.0 (real).
    """
    var coeffs = List[Float64]()
    coeffs.append(1.0)
    coeffs.append(2.0)

    var result = evaluate_polynomial(coeffs, 0.0, 1.0)

    assert_almost_equal(result.re, 3.0, atol=1e-10)
    assert_almost_equal(result.im, 0.0, atol=1e-10)


def test_evaluate_polynomial_at_dc_with_r_not_one() raises:
    """Verify polynomial evaluation at DC with r != 1.

    For omega=0 and r=2, z^(-k) = 2^(-k):
        P(0, r=2) = coeff[0]*2^0 + coeff[1]*2^(-1) + coeff[2]*2^(-2)
                   = 1.0*1.0 + 0.5*0.5 + 0.25*0.25
                   = 1.0 + 0.25 + 0.0625 = 1.3125
    """
    var coeffs = List[Float64]()
    coeffs.append(1.0)
    coeffs.append(0.5)
    coeffs.append(0.25)

    var result = evaluate_polynomial(coeffs, 0.0, 2.0)

    assert_almost_equal(result.re, 1.3125, atol=1e-10)
    assert_almost_equal(result.im, 0.0, atol=1e-10)


def test_evaluate_polynomial_at_nyquist() raises:
    """Verify polynomial evaluation at Nyquist (omega=pi).

    At omega=pi, z^(-k) = r^(-k) * e^(-j*pi*k) = r^(-k) * (-1)^k
    This should produce a complex result in general.
    """
    var coeffs = List[Float64]()
    coeffs.append(1.0)
    coeffs.append(1.0)

    var result = evaluate_polynomial(coeffs, pi, 1.0)

    assert_almost_equal(result.re, 0.0, atol=1e-10)
    assert_almost_equal(result.im, 0.0, atol=1e-10)


def test_evaluate_polynomial_single_coeff() raises:
    """Verify polynomial evaluation with single coefficient.

    With just coeff[0]=5.0, the result should always be 5.0 regardless of omega.
    """
    var coeffs = List[Float64]()
    coeffs.append(5.0)

    var result1 = evaluate_polynomial(coeffs, 0.0, 1.0)
    var result2 = evaluate_polynomial(coeffs, pi / 2.0, 1.0)
    var result3 = evaluate_polynomial(coeffs, pi, 1.0)

    assert_almost_equal(result1.re, 5.0, atol=1e-10)
    assert_almost_equal(result2.re, 5.0, atol=1e-10)
    assert_almost_equal(result3.re, 5.0, atol=1e-10)


def test_freqz_output_length() raises:
    """Verify freqz returns the correct number of points."""
    var a_coeff = List[Float64]()
    a_coeff.append(1.0)
    a_coeff.append(0.0)

    var b_coeff = List[Float64]()
    b_coeff.append(1.0)
    b_coeff.append(1.0)

    var num_points = 256
    var result = freqz(a_coeff, b_coeff, num_points)

    assert_almost_equal(
        Float64(result[0].__len__()), Float64(num_points), atol=0.0
    )
    assert_almost_equal(
        Float64(result[1].__len__()), Float64(num_points), atol=0.0
    )


def test_freqz_lowpass_at_dc() raises:
    """Verify low-pass filter has unity gain at DC.

    For a simple low-pass filter with b=[1, 1], a=[1, 0]:
    At omega=0: H(0) = (1 + 1) / (1 + 0) = 2.0

    The magnitude should be 2.0 at DC.
    """
    var a_coeff = List[Float64]()
    a_coeff.append(1.0)
    a_coeff.append(0.0)

    var b_coeff = List[Float64]()
    b_coeff.append(1.0)
    b_coeff.append(1.0)

    var result = freqz(a_coeff, b_coeff, 512)
    var h_dc = result[1][0].magnitude()

    assert_almost_equal(h_dc, 2.0, atol=1e-10)


def test_freqz_lowpass_at_nyquist() raises:
    """Verify low-pass filter attenuates at Nyquist frequency.

    For a simple low-pass filter with b=[1, 1], a=[1, 0]:
    At omega=pi: H(pi) = (1 - 1) / (1 + 0) = 0.0

    The magnitude should be approximately 0 at Nyquist.
    """
    var a_coeff = List[Float64]()
    a_coeff.append(1.0)
    a_coeff.append(0.0)

    var b_coeff = List[Float64]()
    b_coeff.append(1.0)
    b_coeff.append(1.0)

    var result = freqz(a_coeff, b_coeff, 512)
    var h_nyquist = result[1][511].magnitude()

    assert_almost_equal(h_nyquist, 0.0, atol=1e-10)


def test_freqz_highpass_at_nyquist() raises:
    """Verify high-pass filter has unity gain at Nyquist frequency.

    For a simple high-pass filter with b=[1, -1], a=[1, 0]:
    At omega=pi: H(pi) = (1 - (-1)) / (1 + 0) = 2.0

    The magnitude should be 2.0 at Nyquist.
    """
    var a_coeff = List[Float64]()
    a_coeff.append(1.0)
    a_coeff.append(0.0)

    var b_coeff = List[Float64]()
    b_coeff.append(1.0)
    b_coeff.append(-1.0)

    var result = freqz(a_coeff, b_coeff, 512)
    var h_nyquist = result[1][511].magnitude()

    assert_almost_equal(h_nyquist, 2.0, atol=1e-10)


def test_freqz_fir_filter() raises:
    """Verify FIR filter (all a coefficients = 1) works correctly.

    A simple moving average FIR filter: y[n] = (x[n] + x[n-1]) / 2
    b = [0.5, 0.5], a = [1.0]

    At omega=0: H(0) = 0.5 + 0.5 = 1.0
    """
    var a_coeff = List[Float64]()
    a_coeff.append(1.0)

    var b_coeff = List[Float64]()
    b_coeff.append(0.5)
    b_coeff.append(0.5)

    var result = freqz(a_coeff, b_coeff, 512)
    var h_dc = result[1][0].magnitude()

    assert_almost_equal(h_dc, 1.0, atol=1e-10)


def test_freqz_omega_range() raises:
    """Verify omega values range from 0 to pi."""
    var a_coeff = List[Float64]()
    a_coeff.append(1.0)

    var b_coeff = List[Float64]()
    b_coeff.append(1.0)

    var result = freqz(a_coeff, b_coeff, 512)

    assert_almost_equal(result[0][0], 0.0, atol=1e-10)
    assert_almost_equal(result[0][511], pi, atol=1e-10)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
