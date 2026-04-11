from std.math import sin, cos, atan2, sqrt


struct Complex(Copyable, Movable):
    """A lightweight complex number struct for frequency domain calculations.

    Supports both Cartesian (re, im) and polar (radius, theta) representations.
    Use the `polar` variant constructor to create from polar coordinates.

    Examples:
        Cartesian: Complex(3.0, 4.0)
        Polar: Complex(5.0, 0.9273, polar=True)  # same point, theta in radians
    """

    var re: Float64
    """The real part of the complex number."""

    var im: Float64
    """The imaginary part of the complex number."""

    @always_inline
    fn __init__(out self, *, copy: Self):
        """Creates a copy of another Complex number."""
        self.re = copy.re
        self.im = copy.im

    @always_inline
    fn __init__(out self, *, deinit take: Self):
        """Creates a Complex from a moved value."""
        self.re = take.re
        self.im = take.im

    @always_inline
    fn __init__(out self, re: Float64, im: Float64):
        """Creates a Complex number from Cartesian coordinates.

        Args:
            re: The real part.
            im: The imaginary part.
        """
        self.re = re
        self.im = im

    @always_inline
    fn __init__(out self, radius: Float64, theta: Float64, polar: Bool):
        """Creates a Complex number from polar coordinates.

        z = r * e^(j*theta) where j is the imaginary unit.

        Args:
            radius: The magnitude (distance from origin). Must be non-negative.
            theta: The phase angle in radians.
            polar: Flag to indicate polar constructor. Pass True.
        """
        self.re = radius * cos(theta)
        self.im = radius * sin(theta)

    @always_inline
    fn __add__(self, other: Complex) -> Complex:
        """Adds two Complex numbers.

        Args:
            other: The Complex number to add.

        Returns:
            A new Complex representing the sum.
        """
        return Complex(self.re + other.re, self.im + other.im)

    @always_inline
    fn __mul__(self, other: Complex) -> Complex:
        """Multiplies two Complex numbers.

        Uses the formula: (a + bi)(c + di) = (ac - bd) + (ad + bc)i

        Args:
            other: The Complex number to multiply by.

        Returns:
            A new Complex representing the product.
        """
        return Complex(
            self.re * other.re - self.im * other.im,
            self.re * other.im + self.im * other.re,
        )

    @always_inline
    fn __mul__(self, scalar: Float64) -> Complex:
        """Multiplies a Complex number by a real scalar.

        Args:
            scalar: The real number to multiply by.

        Returns:
            A new Complex representing the scaled result.
        """
        return Complex(self.re * scalar, self.im * scalar)

    @always_inline
    fn __rmul__(self, scalar: Float64) -> Complex:
        """Multiplies a real scalar by a Complex number (reversed multiplication).

        Args:
            scalar: The real number to multiply by.

        Returns:
            A new Complex representing the scaled result.
        """
        return self * scalar

    @always_inline
    fn magnitude(self) -> Float64:
        """Computes the magnitude (absolute value) of the Complex number.

        |z| = sqrt(re² + im²)

        Returns:
            The distance from the origin to the point in the complex plane.
        """
        return sqrt(self.re * self.re + self.im * self.im)

    @always_inline
    fn phase(self) -> Float64:
        """Computes the phase angle (argument) of the Complex number.

        theta = atan2(im, re)

        Returns:
            The angle in radians from the positive real axis to this point.
        """
        return atan2(self.im, self.re)

    @always_inline
    fn __truediv__(self, other: Complex) -> Complex:
        """Divides this Complex number by another.

        (a + bi) / (c + di) = (ac + bd)/(c²+d²) + (bc - ad)/(c²+d²)i

        Args:
            other: The Complex number to divide by.

        Returns:
            A new Complex representing the quotient.
        """
        var denom = other.re * other.re + other.im * other.im
        return Complex(
            (self.re * other.re + self.im * other.im) / denom,
            (self.im * other.re - self.re * other.im) / denom,
        )
