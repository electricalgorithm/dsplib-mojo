"""
This module provides functions to design digital filters.

Find a guide below to understand design principles.
--------------------------------------

Fundamentals
==============

The filter design is realized as:
 a0 * y[n] + a1 * y[n-1] + ... = b0 * x[n] + b1 * x[n-1] + ...
in digital signal processing. The coefficients of y[n-t] are known
as a coefficients and x[n-t] are b coefficients. One can design a
filter based on only the coefficients since it can represent the
system response as feedforward and feedback loops.

Therefore, a digital filter can be written as
  H(z) = (b-coeff) / (a-coeff)
to calculate its response to a frequency easily.

A feedback is to change the current output based on previous
output. In our representation, it means that y[n] is affected by
y[n-1]. Therefore, it is represented with a-coefficients. The roots
of a feedback are called poles. Because the filter feeds its own
previous calculations back into itself to create the new one, its
response to an impulse can mathematically ring out forever, creating
an Infinite Impulse Response (IIR).

A feedforward is to change the current output based on previous
inputs. In our representation, it means that y[n] is affected by
x[n] or x[n-1] or etc. The roots of a feedforward are called zeros.
If a filter only uses b coefficients, it has a Finite Impulse
Response (FIR) because the signal eventually flushes out of the
system.


Deep Dive
============

One can calculate the roots of the system using Z-domain
representation. A time delay of "t" (y[n-t] or x[n-t]) in z-domain
is z^{-n}. By replacing them in our initial filter expression using

y[n] --> z-transform --> Y(z)
x[n] --> z-transform --> X(z)
y[n-t] --> z-transform --> Y(z) * z^{-t}
x[n-t] --> z-transform --> X(z) * z^{-t}

we can rewrite the expression in Z-domain:
  a0 * Y(z) + a1 * Y(z) * z^{-1} + ... = b0 * X(z) + b1 * X(z) * z^{-1} + ...
which helps us to find the transfer function H(z) = Y(z) / X(z). Let's
assume a0 = 1 to simplify the equation, and by rearranging it:

          Y(z)      (b0 + b1 * z^{-1} + b2 * z^{-2} + ...)
  H(z) = ------  = ------------------------------------------
          X(z)      (a1 * z^{-1} + a2 * z^{-2} + ...)

Zeros are the roots of numenator.
  z_{zeros} for (b0 + b1 * z^{-1} + b2 * z^{-2} + ...) = 0
Poles are the roots of denumenator.
  z_{poles} for (a1 * z^{-1} + a2 * z^{-2} + ...) = 0

Please remember that z = r * e^{jw} where w is angular frequency, and
r is the amplification factor.

Stability
===========

When designing a filter, one should be careful on its stability.
Due to the fact that a previous output can amplify the current
output in IIR filters, we need to be careful on poles of the system.

Since z = r * e^{jw}, we can conclude that "r" for poles should be
below than 1 to not amplify the signal indefinetly. On the other hand,
zeros can be anything since they do not affect the signal based on their
finite behaviour.
"""
from std.math import sin, cos, pi
from .core import Complex


fn evaluate_polynomial(
    coeffs: List[Float64], omega: Float64, r: Float64
) -> Complex:
    """
    Evaluate a given polynomial for a frequency given.

    Args:
      - coeffs: List of coefficients of the polynomials.
      - omega: The frequency in rad/s of the z-variable.
      - r: The radius of the z-variable.

    Returns:
      Complex: The result of the polynomial.
    """
    var real_part: Float64 = 0.0
    var imag_part: Float64 = 0.0

    # Calculate the function using z-polynomials.
    # a0 + a1 * z^(-1) + a2 * z^(-2) + ...
    # where z^(-k) = r^(-k) * e^(-jwk).
    # We can rewrite it using Euler's Formula.
    # e^(-j*x) = cos(x) - j sin(x)
    # So,
    # z^(-k) = r^(-k) * (cos(wk) - j sin(wk))
    # z^(-k) = r^(-k) * cos(wk) - j * r^(-k) * sin(wk)
    for k in range(len(coeffs)):
        var r_k = r ** Float64(-k)
        var angle = omega * Float64(k)
        real_part += coeffs[k] * r_k * cos(angle)
        imag_part += coeffs[k] * r_k * sin(angle)

    return Complex(real_part, -imag_part)


fn freqz(
    a_coeff: List[Float64], b_coeff: List[Float64], num_points: Int = 512
) -> Tuple[List[Float64], List[Complex]]:
    """
    Calculate the frequency response from the transfer function coefficients.

    Args:
      - a_coeff: List of a_n coefficients.
      - b_coeff: List of b_n coefficients.
      - num_points: Number of frequency points to evaluate.

    Returns:
        Tuple[List[Float64], List[Complex]]: The function returns two lists. The first
        one is the frequencies. The second one are the list of complex data which are
        the frequency responses.
    """
    var frequencies = List[Float64]()
    var responses = List[Complex]()

    # We go for num_points in frequency.
    # Each iteration calcualtes a different omega.
    for i in range(num_points):
        var omega = pi * Float64(i) / Float64(num_points - 1)
        var b_val = evaluate_polynomial(b_coeff, omega, 1.0)
        var a_val = evaluate_polynomial(a_coeff, omega, 1.0)
        frequencies.append(omega)
        responses.append(b_val / a_val)

    return (frequencies^, responses^)
