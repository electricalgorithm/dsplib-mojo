from std.memory import alloc
from .core import Complex


@always_inline
fn sign(x: Float64) -> Float64:
    """Returns the sign of x: 1.0 if x >= 0.0, -1.0 otherwise."""
    return 1.0 if x >= 0.0 else -1.0


fn generate_time_array(
    sample_rate: Float64, num_samples: Int
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a time array for given sample rate and number of samples.

    Each element represents the time in seconds of that sample:
    time[n] = n / sample_rate

    Example:
        For sample_rate=44100 and num_samples=10:
        Returns: [0, 1/44100, 2/44100, ..., 9/44100]

    Params:
        sample_rate: Sample rate in samples per second.
        num_samples: Number of samples.

    Returns:
        Pointer to array of time values in seconds.
    """
    var time = alloc[Float64](num_samples)
    var dt = 1.0 / sample_rate
    for i in range(num_samples):
        time[i] = Float64(i) * dt
    return time
