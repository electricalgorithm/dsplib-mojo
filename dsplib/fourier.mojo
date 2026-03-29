from std.math import pi, cos, sin
from std.memory import alloc
from .core import Complex
from .utils import next_power_of_2, is_power_of_2


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
    var results: UnsafePointer[Complex, MutExternalOrigin] = alloc[Complex](
        num_samples
    )

    # Outer loop 'k' iterates through each "Frequency Bin".
    # Each bin represents a specific frequency in the signal.
    for k in range(num_samples):
        var sum = Complex(0.0, 0.0)

        # Inner loop 'n' iterates through every "Time Sample" in the signal.
        # We multiply each sample by a spinning probe (twiddle factor).
        for n in range(num_samples):
            # Calculate the angle for this twiddle factor: W_N^(kn) = e^(-j*2π*k*n/N)
            # This is a point on the unit circle, rotating based on k and n.
            var angle = (
                -2.0 * pi * Float64(k) * Float64(n) / Float64(num_samples)
            )

            # Polar form: radius=1 (unit circle), theta=angle
            # This is equivalent to Complex(cos(angle), sin(angle))
            var twiddle = Complex(1.0, angle, True)

            # Multiply the sample at time 'n' by the probe at frequency 'k'.
            # This projects the signal onto this spinning direction.
            sum = sum + (twiddle * samples[n])

        # Store the result for this frequency bin.
        # Large magnitude = this frequency is strong in the signal.
        results[k] = sum^

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
    var results: UnsafePointer[Complex, MutExternalOrigin] = alloc[Complex](
        num_samples
    )

    # Outer loop 'n' iterates through each point in "Time".
    # We're reconstructing what the signal looks like at each time instant.
    for n in range(num_samples):
        var sum = Complex(0.0, 0.0)

        # Inner loop 'k' iterates through every "Frequency Bin".
        # We sum up all frequency components to reconstruct the original signal at time 'n'.
        for k in range(num_samples):
            # Calculate the angle for reconstruction: W_N^(kn) = e^(j*2π*k*n/N)
            # Note: positive sign here (opposite of DFT) for reconstruction.
            var angle = (
                2.0 * pi * Float64(k) * Float64(n) / Float64(num_samples)
            )

            # Polar form: radius=1 (unit circle), theta=angle
            var twiddle = Complex(1.0, angle, True)

            # Add the contribution of this frequency to the sample at time 'n'.
            # Each frequency bin contributes a spinning component.
            sum = sum + (freq_bins[k] * twiddle)

        # Final step: Normalize by dividing by the total number of samples.
        # This is required because we summed N terms during reconstruction.
        results[n] = (sum * (1.0 / Float64(num_samples)))^

    return results


fn compute_magnitude_spectrum(
    dft_output: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
) -> Tuple[UnsafePointer[Float64, MutExternalOrigin], Int]:
    """
    Extracts the magnitude spectrum from DFT output.

    For real-valued input signals, the spectrum is symmetric around DC.
    This function returns only the positive frequencies (0 to Nyquist).
    Magnitudes are scaled by 2/N to account for negative frequency energy.

    Params:
        dft_output: Pointer to the complex DFT output.
        num_samples: Number of samples in the original DFT.

    Returns:
        A tuple of (magnitudes, num_magnitudes).
        Magnitudes are scaled: |X[k]| * 2/N for k > 0.
        DC bin (k=0) is not scaled.
        Caller must free the magnitudes pointer.
    """
    # We don't want to have complex conjugates.
    var num_positive = num_samples // 2 + 1
    var magnitudes = alloc[Float64](num_positive)

    for i in range(num_positive):
        var mag = dft_output[i].magnitude()
        if i > 0:
            mag = mag * 2.0 / Float64(num_samples)
        magnitudes[i] = mag

    return (magnitudes, num_positive)


fn compute_phase_spectrum(
    dft_output: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
) -> Tuple[UnsafePointer[Float64, MutExternalOrigin], Int]:
    """
    Extracts the phase spectrum from DFT output.

    For real-valued input signals, the phase spectrum is anti-symmetric around DC.
    This function returns only the positive frequencies (0 to Nyquist).
    Phase is in radians, in the range [-pi, pi].

    Params:
        dft_output: Pointer to the complex DFT output.
        num_samples: Number of samples in the original DFT.

    Returns:
        A tuple of (phases, num_phases).
        Phase is in radians [-pi, pi].
        Caller must free the phases pointer.
    """
    var num_positive = num_samples // 2 + 1
    var phases = alloc[Float64](num_positive)

    for i in range(num_positive):
        phases[i] = dft_output[i].phase()

    return (phases, num_positive)


fn compute_power_spectrum(
    dft_output: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
) -> Tuple[UnsafePointer[Float64, MutExternalOrigin], Int]:
    """
    Computes the power spectrum from DFT output.

    Power = |X[k]|^2 (magnitude squared)

    For real-valued input signals, returns only positive frequencies.
    Power is scaled by (2/N)^2 for k > 0 to account for negative frequencies.

    Params:
        dft_output: Pointer to the complex DFT output.
        num_samples: Number of samples in the original DFT.

    Returns:
        A tuple of (power, num_bins).
        Power is in squared magnitude units.
        Caller must free the power pointer.
    """
    var num_positive = num_samples // 2 + 1
    var power = alloc[Float64](num_positive)

    for i in range(num_positive):
        var mag = dft_output[i].magnitude()
        if i > 0:
            mag = mag * 2.0 / Float64(num_samples)
        power[i] = mag * mag

    return (power, num_positive)


fn compute_spectral_energy(
    dft_output: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
) -> Float64:
    """
    Computes the total spectral energy from DFT output.

    Uses Parseval's theorem: energy in time domain = energy in frequency domain

    Energy = sum of |X[k]|^2 for all bins (not scaled)
    This includes both positive and negative frequencies.

    Params:
        dft_output: Pointer to the complex DFT output.
        num_samples: Number of samples in the original DFT.

    Returns:
        Total spectral energy.
    """
    var energy: Float64 = 0.0

    for i in range(num_samples):
        var mag = dft_output[i].magnitude()
        energy = energy + (mag * mag)

    return energy


fn compute_time_domain_energy(
    samples: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
) -> Float64:
    """
    Computes the total energy in the time domain.

    Energy = sum of |x[n]|^2 for all samples

    Params:
        samples: Pointer to the time-domain samples.
        num_samples: Number of samples.

    Returns:
        Total time-domain energy.
    """
    var energy: Float64 = 0.0

    for i in range(num_samples):
        var sample = samples[i]
        energy = energy + (sample * sample)

    return energy


fn _fft_recursive(
    samples: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
) -> UnsafePointer[Complex, MutExternalOrigin]:
    """
    Internal recursive FFT implementation using Cooley-Tukey decimation-in-time.

    This is the divide-and-conquer step that splits the DFT into smaller parts.

    Params:
        samples: Pointer to complex input samples.
        num_samples: Number of samples (must be power of 2).

    Returns:
        Complex FFT output.
    """
    # Base case: N = 1
    if num_samples == 1:
        var result = alloc[Complex](1)
        result[0].re = samples[0].re
        result[0].im = samples[0].im
        return result

    # Split into even and odd indices
    var half_size = num_samples // 2
    var even = alloc[Complex](half_size)
    var odd = alloc[Complex](half_size)

    for i in range(half_size):
        even[i].re = samples[2 * i].re
        even[i].im = samples[2 * i].im
        odd[i].re = samples[2 * i + 1].re
        odd[i].im = samples[2 * i + 1].im

    # Recursively compute FFT of even and odd halves
    var even_fft = _fft_recursive(even, half_size)
    var odd_fft = _fft_recursive(odd, half_size)

    # Free temporary arrays
    even.free()
    odd.free()

    # Combine: butterfly operations with twiddle factors
    var result = alloc[Complex](num_samples)

    for k in range(half_size):
        var twiddle_angle = -2.0 * pi * Float64(k) / Float64(num_samples)
        var twiddle_re = cos(twiddle_angle)
        var twiddle_im = sin(twiddle_angle)

        var odd_re = odd_fft[k].re
        var odd_im = odd_fft[k].im
        var twiddled_re = twiddle_re * odd_re - twiddle_im * odd_im
        var twiddled_im = twiddle_re * odd_im + twiddle_im * odd_re

        result[k].re = even_fft[k].re + twiddled_re
        result[k].im = even_fft[k].im + twiddled_im

        result[k + half_size].re = even_fft[k].re - twiddled_re
        result[k + half_size].im = even_fft[k].im - twiddled_im

    # Free recursion results
    even_fft.free()
    odd_fft.free()

    return result


fn compute_fft_recursive(
    samples: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
) raises -> UnsafePointer[Complex, MutExternalOrigin]:
    """
    Computes Fast Fourier Transform using recursive Cooley-Tukey algorithm.

    Complexity: O(N log N)

    Params:
        samples: Pointer to real-valued input samples.
        num_samples: Number of samples.

    Returns:
        Complex FFT output.
    """
    var size = num_samples

    # Check if padding is needed
    if not is_power_of_2(size):
        print("Warning: N =", size, "is not a power of 2.")
        print("Padding to next power of 2.")

        size = next_power_of_2(size)

        var padded = alloc[Float64](size)
        for i in range(num_samples):
            padded[i] = samples[i]
        for i in range(num_samples, size):
            padded[i] = 0.0

        var complex_samples = alloc[Complex](size)
        for i in range(size):
            complex_samples[i].re = padded[i]
            complex_samples[i].im = 0.0

        padded.free()

        var fft_result = _fft_recursive(complex_samples, size)
        complex_samples.free()

        return fft_result

    # Already power of 2: convert to complex and compute
    var complex_samples = alloc[Complex](size)
    for i in range(size):
        complex_samples[i].re = samples[i]
        complex_samples[i].im = 0.0

    var fft_result = _fft_recursive(complex_samples, size)
    complex_samples.free()

    return fft_result
