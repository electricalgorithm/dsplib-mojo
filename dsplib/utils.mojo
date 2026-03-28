from std.math import iota, align_down
from std.memory import alloc
from .core import Complex


@always_inline
fn sign(x: Float64) -> Float64:
    """Returns the sign of x: 1.0 if x >= 0.0, -1.0 otherwise."""
    return 1.0 if x >= 0.0 else -1.0
