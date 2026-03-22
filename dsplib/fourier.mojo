from std.math import pi
from std.memory import alloc
from .core import Complex


def compute_dft_raw(
    samples: UnsafePointer[Float64, MutExternalOrigin], num_samples: Int
) -> UnsafePointer[Complex, MutExternalOrigin]:
    """
    Performs a Discrete Fourier Transform (DFT).
    Complexity: O(N^2).

    The DFT answers: "How much does my signal look like e^(j*2π*k*n/N)?"

    Params:
      samples (UnsafePointer): Pointer to the time-domain samples.
      num_samples (Int): Number of samples.

    Returns:
      UnsafePointer[Complex, MutExternalOrigin]: An array of complex frequency components.
    """
    var results: UnsafePointer[Complex, MutExternalOrigin] = alloc[Complex](num_samples)

    # Outer loop 'k' iterates through each "Frequency Bin".
    # Each bin represents a specific frequency in the signal.
    for k in range(num_samples):
        var sum = Complex(0.0, 0.0)

        # Inner loop 'n' iterates through every "Time Sample" in the signal.
        # We multiply each sample by a spinning probe (twiddle factor).
        for n in range(num_samples):
            # Calculate the angle for this twiddle factor: W_N^(kn) = e^(-j*2π*k*n/N)
            # This is a point on the unit circle, rotating based on k and n.
            var angle = -2.0 * pi * Float64(k) * Float64(n) / Float64(num_samples)

            # Polar form: radius=1 (unit circle), theta=angle
            # This is equivalent to Complex(cos(angle), sin(angle))
            var twiddle = Complex(1.0, angle, True)

            # Multiply the sample at time 'n' by the probe at frequency 'k'.
            # This projects the signal onto this spinning direction.
            sum = sum + (twiddle * samples[n])

        # Store the result for this frequency bin.
        # Large magnitude = this frequency is strong in the signal.
        results[k] = sum ^

    return results


def compute_idft_raw(
    freq_bins: UnsafePointer[Complex, MutExternalOrigin], num_samples: Int
) -> UnsafePointer[Complex, MutExternalOrigin]:
    """
    Performs an Inverse Discrete Fourier Transform (IDFT).
    Complexity: O(N^2).

    Reconstructs the time-domain signal by summing all frequency components.
    This is the reverse of the DFT: we start with frequency bins and get back time samples.

    Params:
      freq_bins (UnsafePointer): Pointer to the complex frequency domain bins.
      num_samples (Int): Number of bins/samples.

    Returns:
      UnsafePointer[Complex, MutExternalOrigin]: An array of complex time-domain samples.
    """
    var results: UnsafePointer[Complex, MutExternalOrigin] = alloc[Complex](num_samples)

    # Outer loop 'n' iterates through each point in "Time".
    # We're reconstructing what the signal looks like at each time instant.
    for n in range(num_samples):
        var sum = Complex(0.0, 0.0)

        # Inner loop 'k' iterates through every "Frequency Bin".
        # We sum up all frequency components to reconstruct the original signal at time 'n'.
        for k in range(num_samples):
            # Calculate the angle for reconstruction: W_N^(kn) = e^(j*2π*k*n/N)
            # Note: positive sign here (opposite of DFT) for reconstruction.
            var angle = 2.0 * pi * Float64(k) * Float64(n) / Float64(num_samples)

            # Polar form: radius=1 (unit circle), theta=angle
            var twiddle = Complex(1.0, angle, True)

            # Add the contribution of this frequency to the sample at time 'n'.
            # Each frequency bin contributes a spinning component.
            sum = sum + (freq_bins[k] * twiddle)

        # Final step: Normalize by dividing by the total number of samples.
        # This is required because we summed N terms during reconstruction.
        results[n] = (sum * (1.0 / Float64(num_samples))) ^

    return results
