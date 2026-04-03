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
