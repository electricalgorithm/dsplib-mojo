@fieldwise_init
struct Complex(Copyable, Movable):
    """A lightweight complex number struct for frequency domain calculations."""

    var re: Float64
    var im: Float64

    @always_inline
    fn __init__(out self, *, copy: Self):
        self.re = copy.re
        self.im = copy.im

    @always_inline
    fn __init__(out self, *, deinit take: Self):
        self.re = take.re
        self.im = take.im

    @always_inline
    fn __add__(self, other: Complex) -> Complex:
        return Complex(self.re + other.re, self.im + other.im)

    @always_inline
    fn __mul__(self, other: Complex) -> Complex:
        # (a + bi) * (c + di) = (ac - bd) + (ad + bc)i
        return Complex(
            self.re * other.re - self.im * other.im, self.re * other.im + self.im * other.re
        )

    @always_inline
    fn __mul__(self, scalar: Float64) -> Complex:
        return Complex(self.re * scalar, self.im * scalar)

    @always_inline
    fn __rmul__(self, scalar: Float64) -> Complex:
        return self * scalar

    @always_inline
    fn magnitude(self) -> Float64:
        # sqrt(re^2 + im^2)
        return (self.re**2 + self.im**2) ** 0.5
