from std.math import sin, cos, pi
from std.memory import alloc
from .core import Complex


def compute_dft_raw(
    samples: UnsafePointer[Float64, MutExternalOrigin], num_samples: Int
) -> UnsafePointer[Complex, MutExternalOrigin]:
    """
    Performs a Discrete Fourier Transform (DFT).
    Complexity: O(N^2).

    Params:
      samples (UnsafePointer): Pointer to the time-domain samples.
      num_samples (Int): Number of samples.

    Returns:
      UnsafePointer[Complex, MutExternalOrigin]: An array of complex frequency components.
    """
    var results: UnsafePointer[Complex, MutExternalOrigin] = alloc[Complex](num_samples)

    # Outer loop 'k' iterates through each "Frequency Bin".
    for k in range(num_samples):
        var sum = Complex(0, 0)

        # Inner loop 'n' iterates through every "Time Sample" in the signal.
        for n in range(num_samples):
            # Calculate the 'twiddle factor' (a rotating vector in the complex plane).
            var angle = -2.0 * pi * Float64(k) * Float64(n) / Float64(num_samples)
            var twiddle = Complex(cos(angle), sin(angle))

            # Multiply the sample at time 'n' by the probe at frequency 'k'.
            sum = sum + (twiddle * samples[n])

        results[k] = sum ^

    return results


def compute_idft_raw(
    freq_bins: UnsafePointer[Complex, MutExternalOrigin], num_samples: Int
) -> UnsafePointer[Complex, MutExternalOrigin]:
    """
    Performs an Inverse Discrete Fourier Transform (IDFT).
    Complexity: O(N^2).

    Params:
      freq_bins (UnsafePointer): Pointer to the complex frequency domain bins.
      num_samples (Int): Number of bins/samples.

    Returns:
      UnsafePointer[Complex, MutExternalOrigin]: An array of complex time-domain samples.
    """
    var results: UnsafePointer[Complex, MutExternalOrigin] = alloc[Complex](num_samples)

    # Outer loop 'n' iterates through each point in "Time".
    for n in range(num_samples):
        var sum = Complex(0, 0)

        # Inner loop 'k' iterates through every "Frequency Bin".
        # We are summing up all frequency components to reconstruct the original signal at time 'n'.
        for k in range(num_samples):
            var angle = 2.0 * pi * Float64(k) * Float64(n) / Float64(num_samples)
            var twiddle = Complex(cos(angle), sin(angle))

            # Add the contribution of this frequency to the sample at time 'n'.
            sum = sum + (freq_bins[k] * twiddle)

        # Final step: Normalize by dividing by the total number of samples.
        results[n] = (sum * (1.0 / Float64(num_samples))) ^

    return results
