from std.math import log10, sqrt, pi
from std.memory import alloc
from .core import Complex


fn is_power_of_2(n: Int) -> Bool:
    """
    Returns True if n is a power of 2.
    """
    return n > 0 and (n & (n - 1)) == 0


fn next_power_of_2(n: Int) -> Int:
    """
    Returns the smallest power of 2 that is >= n.

    If n is already a power of 2, returns n.
    """
    var p = 1
    while p < n:
        p = p * 2
    return p


fn pad_to_power_of_2[
    num_samples: Int
](
    samples: UnsafePointer[Float64, MutExternalOrigin],
) -> Tuple[
    UnsafePointer[Float64, MutExternalOrigin], Int, Int
]:
    """
    Pads samples to the next power of 2 length.

    Params:
        samples: Pointer to the input samples.
        num_samples: Number of input samples.

    Returns:
        A tuple of (padded_samples, new_num_samples, padding_added).
        The caller must free the padded_samples pointer.
    """
    var new_size = next_power_of_2(num_samples)
    var padding = new_size - num_samples

    var padded = alloc[Float64](new_size)

    for i in range(num_samples):
        padded[i] = samples[i]

    for i in range(padding):
        padded[num_samples + i] = 0.0

    return (padded, new_size, padding)


fn reverse_bits(index: Int, num_bits: Int) -> Int:
    """
    Reverses the bits of an index.

    Example: index=3 (binary: 011), num_bits=3 → 110 = 6

    Params:
        index: The index to reverse.
        num_bits: Number of bits to consider.

    Returns:
        The bit-reversed index.
    """
    var reversed = 0
    for i in range(num_bits):
        if ((index >> i) & 1) == 1:
            reversed = reversed | (1 << (num_bits - 1 - i))
    return reversed


fn bit_reverse_array(
    data: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
) -> None:
    """
    Performs in-place bit reversal of a complex array.

    This is used to unscramble the output of the recursive FFT.

    Params:
        data: Pointer to the complex array to bit-reverse.
        num_samples: Number of elements in the array.
    """
    var num_bits = 0
    var temp = num_samples
    while temp > 0:
        num_bits = num_bits + 1
        temp = temp >> 1

    for i in range(num_samples):
        var j = reverse_bits(i, num_bits)
        if i < j:
            var temp_re = data[i].re
            var temp_im = data[i].im
            data[i].re = data[j].re
            data[i].im = data[j].im
            data[j].re = temp_re
            data[j].im = temp_im


fn allocate_buffer(
    num_elements: Int,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Allocates a buffer of Float64 values initialized to zero.

    Params:
        num_elements: Number of Float64 elements to allocate.

    Returns:
        Pointer to the allocated buffer (must be freed by caller).
    """
    var buf = alloc[Float64](num_elements)
    for i in range(num_elements):
        buf[i] = 0.0
    return buf


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


fn calculate_power(
    signal: UnsafePointer[Float64, MutExternalOrigin], num_samples: Int
) -> Float64:
    """
    Calculates the average power of a signal.

    Power = (1/N) * Σ(x²)

    Params:
        signal: Pointer to the signal samples.
        num_samples: Number of samples.

    Returns:
        Average power of the signal.
    """
    var sum_sq: Float64 = 0.0
    for i in range(num_samples):
        sum_sq = sum_sq + signal[i] * signal[i]
    return sum_sq / Float64(num_samples)


fn calculate_snr(
    signal: UnsafePointer[Float64, MutExternalOrigin],
    noise: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
) -> Float64:
    """
    Calculates Signal-to-Noise Ratio in decibels (dB).

    SNR_dB = 10 * log10(signal_power / noise_power)

    Params:
        signal: Pointer to the clean signal samples.
        noise: Pointer to the noise samples.
        num_samples: Number of samples.

    Returns:
        SNR in decibels.
    """
    var signal_power = calculate_power(signal, num_samples)
    var noise_power = calculate_power(noise, num_samples)

    if noise_power <= 0.0:
        return 100.0

    return 10.0 * log10(signal_power / noise_power)


fn calculate_noise_std_for_snr(target_snr_db: Float64) -> Float64:
    """
    Calculates the noise standard deviation needed to achieve a target SNR.

    Given a signal amplitude of 1.0, the noise std dev is:
    noise_std = 1.0 / (10^(SNR_dB / 20))

    Example:
        For 20 dB SNR: noise_std = 1.0 / 10 = 0.1
        For 10 dB SNR: noise_std = 1.0 / 3.16 ≈ 0.316

    Params:
        target_snr_db: Target SNR in decibels.

    Returns:
        Standard deviation for the noise.
    """
    return 1.0 / (10.0 ** (target_snr_db / 20.0))


fn add_noise_at_snr(
    signal: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
    target_snr_db: Float64,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Adds Gaussian noise to a signal to achieve a target SNR.

    This function generates noise with the appropriate standard deviation
    and adds it to the signal.

    Params:
        signal: Pointer to the clean signal samples.
        num_samples: Number of samples.
        target_snr_db: Target SNR in decibels.

    Returns:
        Pointer to signal with added noise.
    """
    var noise_std = calculate_noise_std_for_snr(target_snr_db)

    var result = alloc[Float64](num_samples)
    for i in range(num_samples):
        result[i] = signal[i]

    from std.random import randn

    randn[DType.float64](
        result, num_samples, mean=0.0, standard_deviation=noise_std
    )

    return result


fn omega_to_hz(omega: Float64, sample_rate: Float64) -> Float64:
    """
    Converts angular frequency (omega) to frequency in Hz.

    The relationship between angular frequency and frequency is:
        omega = 2 * pi * f

    Args:
        omega: Angular frequency in radians per sample.
        sample_rate: Sample rate in samples per second (Hz).

    Returns:
        Frequency in Hz.

    Example:
        omega = pi (Nyquist) at fs=44100 → f = 22050 Hz
    """
    return omega * sample_rate / (2.0 * pi)


fn magnitude_to_db(magnitude: Float64, floor: Float64 = -100.0) -> Float64:
    """
    Converts magnitude to decibels (dB).

    dB = 20 * log10(|magnitude|)

    For magnitudes near zero, this function returns a floor value to avoid
    -infinity results.

    Args:
        magnitude: The linear magnitude value (non-negative).
        floor: Minimum dB value to return for very small magnitudes.
               Defaults to -100.0 dB.

    Returns:
        Magnitude in decibels.

    Example:
        magnitude = 1.0  → 0 dB
        magnitude = 0.5  → -6 dB
        magnitude = 0.1  → -20 dB
    """
    if magnitude < 1e-10:
        return floor
    return 20.0 * log10(magnitude)
