from std.math import log10, sqrt
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
