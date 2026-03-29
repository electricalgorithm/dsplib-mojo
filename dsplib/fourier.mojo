"""
Fourier Transform Module

The Fourier Transform is one of the most important mathematical tools in all of
engineering. It transforms signals between time domain and frequency domain.

Key Insight:
    Any periodic signal can be represented as a sum of sinusoids.
    The Fourier Transform finds "how much" of each frequency is in the signal.

The Big Picture:
    Time Domain:     x[n] = [samples over time]
    Frequency Domain: X[k] = [how much of each frequency]

This is like asking:
    - Time domain: "What notes are playing?" (waveform view)
    - Frequency domain: "What notes are playing?" (spectrum view)

Why It Matters:
    - Audio processing (EQ, compression, effects)
    - Image processing (filters, compression)
    - Communications (modulation, filtering)
    - Scientific analysis (spectroscopy, seismology)
"""

from std.math import pi, cos, sin
from std.memory import alloc
from .core import Complex
from .utils import next_power_of_2, is_power_of_2


# ============================================================================
# Discrete Fourier Transform (DFT)
# ============================================================================
# The DFT is the mathematical foundation. It's the discrete version of the
# continuous-time Fourier Transform, adapted for sampled signals.
#
# The DFT answers: "How much does this signal look like e^(j*2π*k*n/N)?"
# where e^(j*θ) = cos(θ) + j*sin(θ) is Euler's formula.


def compute_dft_raw(
    samples: UnsafePointer[Float64, MutExternalOrigin], num_samples: Int
) -> UnsafePointer[Complex, MutExternalOrigin]:
    """
    Computes the Discrete Fourier Transform (DFT).

    Mathematical Definition:
        X[k] = Σ x[n] * e^(-j*2π*k*n/N), for k = 0, 1, ..., N-1

    The DFT consists of N "frequency bins". Each bin k measures how much
    of frequency f_k = k * fs/N is present in the signal.

    The Term e^(-j*2π*k*n/N) is called the "twiddle factor":
        e^(-j*θ) = cos(θ) - j*sin(θ)

    This is a spinning phasor on the unit circle:
        - At n=0: angle = 0 (points right)
        - At n=N: angle = 2π (back to start, one complete rotation)
        - k controls how fast it spins (higher k = faster spin)

    Parameters:
        samples: Pointer to N time-domain samples x[n]
        num_samples: Number of samples N

    Returns:
        Complex array X[k] of length N, where:
            - X[k].re = magnitude * cos(phase)
            - X[k].im = magnitude * sin(phase)
            - magnitude = sqrt(re² + im²)
            - phase = atan2(im, re)

    How It Works:
        For each frequency bin k:
            1. Create a "spinning probe" at frequency f_k
            2. Multiply every sample by the probe at its time instant
            3. Sum up all these products
            4. If the signal has frequency f_k, the sum will be large
               (constructive interference)
            5. If the signal doesn't have f_k, the sum will be small
               (destructive interference)

    Example:
        Input: 1024 samples at 44100 Hz
        Output: 1024 bins, each representing 44100/1024 ≈ 43 Hz

        Bin 0:   0 Hz (DC, average value)
        Bin 10:  430 Hz
        Bin 440: 18900 Hz (near Nyquist)
        Bin 512: 22050 Hz (Nyquist, highest detectable frequency)

    Complexity: O(N²) - for N=1024, that's ~1 million operations.
    Use FFT for large N!
    """
    var results: UnsafePointer[Complex, MutExternalOrigin] = alloc[Complex](
        num_samples
    )

    # Outer loop: iterate through each frequency bin k
    # Each k represents a different frequency in the spectrum
    for k in range(num_samples):
        var sum = Complex(0.0, 0.0)

        # Inner loop: multiply signal by spinning probe for this frequency
        # This is the "correlation" or "projection" step
        for n in range(num_samples):
            # Calculate angle for twiddle factor: W_N^(kn) = e^(-j*2π*k*n/N)
            # The negative sign is crucial: e^(-j*θ) vs e^(+j*θ)
            # Negative = "analysis" (looking for frequencies)
            # Positive = "synthesis" (building from frequencies)
            var angle = (
                -2.0 * pi * Float64(k) * Float64(n) / Float64(num_samples)
            )

            # Create twiddle factor: radius=1 (on unit circle), at given angle
            # This is e^(-j*angle) = cos(angle) - j*sin(angle)
            var twiddle = Complex(1.0, angle, True)

            # Multiply sample by twiddle and accumulate
            # If signal matches this frequency, contributions add constructively
            sum = sum + (twiddle * samples[n])

        results[k] = sum^

    return results


def compute_idft_raw(
    freq_bins: UnsafePointer[Complex, MutExternalOrigin], num_samples: Int
) -> UnsafePointer[Complex, MutExternalOrigin]:
    """
    Computes the Inverse Discrete Fourier Transform (IDFT).

    Mathematical Definition:
        x[n] = (1/N) * Σ X[k] * e^(+j*2π*k*n/N), for n = 0, 1, ..., N-1

    The IDFT is the "reverse" of DFT. Given a frequency spectrum X[k],
    it reconstructs the time-domain signal x[n].

    Key Differences from DFT:
        1. Positive exponent: e^(+j*θ) instead of e^(-j*θ)
        2. Division by N: 1/N normalization factor

    Why the 1/N?
        The DFT has N terms in the sum, so the IDFT needs 1/N
        to be a true inverse. Without it, x[n] would be N times too large.

    Parameters:
        freq_bins: Pointer to complex frequency bins X[k]
        num_samples: Number of samples N

    Returns:
        Complex time-domain signal x[n]

    The Complete Picture:
        DFT:  x[n] ---> X[k]  (analysis, finding frequencies)
        IDFT: X[k] ---> x[n]  (synthesis, building from frequencies)

        DFT + IDFT = identity (with proper normalization)
    """
    var results: UnsafePointer[Complex, MutExternalOrigin] = alloc[Complex](
        num_samples
    )

    # Outer loop: iterate through each time sample n
    for n in range(num_samples):
        var sum = Complex(0.0, 0.0)

        # Inner loop: sum all frequency contributions for this time instant
        # Each frequency k contributes e^(j*2π*k*n/N) scaled by X[k]
        for k in range(num_samples):
            # Positive angle this time! (opposite of DFT)
            var angle = (
                2.0 * pi * Float64(k) * Float64(n) / Float64(num_samples)
            )

            var twiddle = Complex(1.0, angle, True)

            # Add this frequency's contribution to the sum
            sum = sum + (freq_bins[k] * twiddle)

        # Normalize by dividing by N
        results[n] = sum * (1.0 / Float64(num_samples))

    return results


# ============================================================================
# Spectrum Analysis Functions
# ============================================================================
# These functions extract useful information from DFT output:
#   - Magnitude: how loud is each frequency?
#   - Phase: where is each frequency in the cycle?
#   - Power: how much energy at each frequency?


fn compute_magnitude_spectrum(
    dft_output: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
) -> Tuple[UnsafePointer[Float64, MutExternalOrigin], Int]:
    """
    Extracts the magnitude spectrum from DFT output.

    Magnitude tells us "how much" of each frequency is present.
    It's the distance from the origin in the complex plane.

    Mathematical Definition:
        |X[k]| = sqrt(X[k].re² + X[k].im²)

    For Real Signals:
        Real signals have symmetric spectra (complex conjugate property):
            X[N-k] = conj(X[k]) for k = 1, 2, ..., N/2-1

        This means:
            - Frequencies above Nyquist mirror frequencies below Nyquist
            - We only need the first N/2+1 bins (0 to Nyquist)
            - DC (k=0) and Nyquist (k=N/2) don't have mirrors

    Scaling:
        - Bin 0 (DC): Keep as-is
        - Bins 1 to N/2: Multiply by 2/N

        Why scale?
            We discarded half the spectrum, so we multiply by 2
            to conserve total energy. Dividing by N is standard
            DFT normalization.

    Parameters:
        dft_output: Complex DFT output X[k]
        num_samples: Original sample count N

    Returns:
        Tuple of (magnitudes array, num_magnitudes)
        magnitudes[k] = |X[k]| * 2/N for k > 0
    """
    # Positive frequencies only: 0 to Nyquist (fs/2)
    # Plus one includes both endpoints
    var num_positive = num_samples // 2 + 1
    var magnitudes = alloc[Float64](num_positive)

    for i in range(num_positive):
        var mag = dft_output[i].magnitude()
        if i > 0:
            # Scale by 2/N to conserve energy
            mag = mag * 2.0 / Float64(num_samples)
        magnitudes[i] = mag

    return (magnitudes, num_positive)


fn compute_phase_spectrum(
    dft_output: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
) -> Tuple[UnsafePointer[Float64, MutExternalOrigin], Int]:
    """
    Extracts the phase spectrum from DFT output.

    Phase tells us "where in the cycle" each frequency is at t=0.
    It's the angle from the positive real axis in the complex plane.

    Mathematical Definition:
        ∠X[k] = atan2(X[k].im, X[k].re)

    Phase is measured in radians, typically in range [-π, π] or [0, 2π].

    What Does Phase Mean?
        Phase = 0:      Peak at t=0
        Phase = π/2:    Zero crossing going positive at t=0
        Phase = π:       Trough at t=0
        Phase = 3π/2:   Zero crossing going negative at t=0

    Phase Matters For:
        - Waveform shape (phase determines where peaks/troughs are)
        - Time-domain reconstruction
        - Causal vs acausal filters
        - Minimum/maximum phase systems

    Note:
        Phase is only meaningful for bins with significant magnitude.
        For noise-like bins, phase is essentially random.
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

    Power spectrum shows how power is distributed across frequencies.
    Power is the square of magnitude.

    Mathematical Definition:
        P[k] = |X[k]|² = X[k].re² + X[k].im²

    Why Power?
        - Energy is proportional to amplitude squared
        - Power makes small differences more visible
        - Logarithmic (dB) scale often used

    Scaling:
        Same as magnitude spectrum: 2/N scaling for k > 0

    Decibel Scale:
        Power in dB = 10 * log10(P[k])
        Magnitude in dB = 20 * log10(|X[k]|)  # Note: factor of 2!

        The factor of 2 difference is because power ∝ magnitude²
    """
    var num_positive = num_samples // 2 + 1
    var power = alloc[Float64](num_positive)

    for i in range(num_positive):
        var mag = dft_output[i].magnitude()
        if i > 0:
            mag = mag * 2.0 / Float64(num_samples)
        # Power = magnitude squared
        power[i] = mag * mag

    return (power, num_positive)


# ============================================================================
# Energy and Parseval's Theorem
# ============================================================================


fn compute_spectral_energy(
    dft_output: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
) -> Float64:
    """
    Computes total energy from frequency domain.

    Uses Parseval's Theorem:
        Energy in time domain = Energy in frequency domain

        Σ |x[n]|² = (1/N) * Σ |X[k]|²

    This is a fundamental result - energy is conserved in the transform.

    Note:
        This uses the unscaled magnitude (no 2/N) to match the
        mathematical formulation of Parseval's theorem.
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
    Computes total energy from time domain.

    Energy in time domain:
        E = Σ |x[n]|² = Σ x[n]² (for real signals)

    This should equal the spectral energy (see Parseval's theorem).
    Use this to verify your FFT implementation!

    Example Test:
        signal = generate_sine_wave(...)
        dft = compute_dft_raw(signal, N)

        time_energy = compute_time_domain_energy(signal, N)
        freq_energy = compute_spectral_energy(dft, N)

        assert |time_energy - freq_energy| < tolerance
    """
    var energy: Float64 = 0.0

    for i in range(num_samples):
        var sample = samples[i]
        energy = energy + (sample * sample)

    return energy


# ============================================================================
# Fast Fourier Transform (FFT)
# ============================================================================
# The FFT is an O(N log N) algorithm for computing the DFT.
# For N = 1024:
#   - DFT: ~1,000,000 operations (O(N²))
#   - FFT: ~10,000 operations (O(N log N))
#
# That's 100x faster!
#
# The FFT works by recursively breaking the DFT into smaller pieces.
# This is the Cooley-Tukey radix-2 decimation-in-time algorithm.


fn _fft_recursive(
    samples: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
) -> UnsafePointer[Complex, MutExternalOrigin]:
    """
    Internal recursive FFT implementation.

    This is the Cooley-Tukey decimation-in-time (DIT) algorithm.

    The Key Insight:
        Instead of computing DFT directly (N² operations), we can split
        the problem into two smaller DFTs:

        X[k] = E[k] + W_N^k * O[k]

        Where:
            E[k] = FFT of even-indexed samples
            O[k] = FFT of odd-indexed samples
            W_N^k = e^(-j*2π*k/N) = twiddle factor

    Recursive Breakdown:
        DFT of N samples
            ├── DFT of N/2 even samples ─┐
            │                             ├──→ X[0..N/2-1] = E + W*O
            └── DFT of N/2 odd samples ──┘
                                        └──→ X[N/2..N-1] = E - W*O

    Butterfly Diagram:
        For each k in 0..N/2-1:

            even[k] ─────┬────→ + ──→ X[k]
                         │
            twiddle(k) ──┤
                         │
            odd[k]  ────┴──→ - ──→ X[k+N/2]

    Base Case:
        N = 1: FFT of single sample is just that sample.
        This terminates the recursion.

    Twiddle Factors:
        W_N^k = e^(-j*2π*k/N) = cos(2πk/N) - j*sin(2πk/N)

        For N=8, k=1: W_8 = e^(-j*π/4) = 0.707 - j*0.707

    Requirements:
        N must be a power of 2 for radix-2 FFT.
    """
    # Base case: DFT of 1 sample is itself
    if num_samples == 1:
        var result = alloc[Complex](1)
        result[0].re = samples[0].re
        result[0].im = samples[0].im
        return result

    # Split into even and odd indexed samples
    var half_size = num_samples // 2
    var even = alloc[Complex](half_size)
    var odd = alloc[Complex](half_size)

    # Distribute samples
    for i in range(half_size):
        even[i].re = samples[2 * i].re
        even[i].im = samples[2 * i].im
        odd[i].re = samples[2 * i + 1].re
        odd[i].im = samples[2 * i + 1].im

    # Recursively compute FFT of halves
    # This is the "decimation" step - we split and conquer
    var even_fft = _fft_recursive(even, half_size)
    var odd_fft = _fft_recursive(odd, half_size)

    # Free temporary arrays
    even.free()
    odd.free()

    # Combine: butterfly operations with twiddle factors
    var result = alloc[Complex](num_samples)

    for k in range(half_size):
        # Compute twiddle factor for this k
        var twiddle_angle = -2.0 * pi * Float64(k) / Float64(num_samples)
        var twiddle_re = cos(twiddle_angle)
        var twiddle_im = sin(twiddle_angle)

        # Multiply odd FFT by twiddle
        var odd_re = odd_fft[k].re
        var odd_im = odd_fft[k].im
        var twiddled_re = twiddle_re * odd_re - twiddle_im * odd_im
        var twiddled_im = twiddle_re * odd_im + twiddle_im * odd_re

        # Butterfly: add for lower half, subtract for upper half
        result[k].re = even_fft[k].re + twiddled_re
        result[k].im = even_fft[k].im + twiddled_im

        result[k + half_size].re = even_fft[k].re - twiddled_re
        result[k + half_size].im = even_fft[k].im - twiddled_im

    # Free FFT results
    even_fft.free()
    odd_fft.free()

    return result


fn compute_fft_recursive(
    samples: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
) raises -> UnsafePointer[Complex, MutExternalOrigin]:
    """
    Computes Fast Fourier Transform (FFT) using recursive Cooley-Tukey.

    This is the public interface for FFT computation.

    FFT vs DFT:
        DFT:  O(N²) operations - for N=1024: ~1 million operations
        FFT:   O(N log N) operations - for N=1024: ~10 thousand operations

        Speedup: ~100x for N=1024, ~1000x for N=1024!

    Parameters:
        samples: Pointer to real-valued time-domain samples
        num_samples: Number of samples N

    Returns:
        Complex frequency domain representation

    Power of 2 Requirement:
        The radix-2 FFT requires N to be a power of 2.
        If N is not a power of 2, the signal is zero-padded to the
        next power of 2.

    What the FFT Output Means:
        X[k] contains complex values representing frequency k:
            k = 0:       DC offset (average value)
            k = 1..N/2: Positive frequencies (0 to Nyquist)
            k = N/2+1:  Negative frequencies (mirror of positive)
            k = N-1:    -fs/N (just below 0 Hz)

        For real input signals, X[k] and X[N-k] are complex conjugates:
            X[N-k] = conj(X[k])

    Example:
        Input:  1024 samples at 44100 Hz
        Output: 1024 frequency bins

        Bin 0:   0 Hz (DC)
        Bin 10:  430 Hz
        Bin 512: 22050 Hz (Nyquist)

    Note:
        This implementation is recursive. For very large N, an iterative
        implementation would be more efficient (no recursion overhead).
    """
    var size = num_samples

    # Pad to power of 2 if necessary
    if not is_power_of_2(size):
        print("Warning: N =", size, "is not a power of 2.")
        print("Padding to next power of 2.")

        size = next_power_of_2(size)

        # Copy original samples and zero-pad
        var padded = alloc[Float64](size)
        for i in range(num_samples):
            padded[i] = samples[i]
        for i in range(num_samples, size):
            padded[i] = 0.0

        # Convert real to complex (imaginary part = 0)
        var complex_samples = alloc[Complex](size)
        for i in range(size):
            complex_samples[i].re = padded[i]
            complex_samples[i].im = 0.0

        padded.free()

        # Compute FFT
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
