"""
Windowing Functions for Spectral Analysis

When we compute the FFT of a finite signal, we implicitly assume the signal
repeats periodically forever. In reality, our signal is a "snapshot" that may
not align with its natural period. This creates a discontinuity at the boundaries
when the signal repeats, causing energy to "leak" into adjacent frequency bins.

Windowing functions taper the edges of the signal to reduce this discontinuity.

Resources:
  1. https://www.gaussianwaves.com/2011/01/fft-and-spectral-leakage-2/
  2. https://www.gaussianwaves.com/2020/09/window-function-figure-of-merits/
  3. https://download.ni.com/evaluation/pxi/Understanding%20FFTs%20and%20Windowing.pdf
"""

from std.math import cos, sin
from std.memory import alloc


fn generate_rectangular_window(
    num_samples: Int,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a rectangular window.

    Mathematical Definition:
        w[n] = 1, for n = 0, 1, 2, ..., N-1

    The rectangular window is the simplest window — it applies no tapering.
    It's equivalent to just taking N samples of a longer signal.

    Characteristics:
        - Main lobe width: 2 bins (narrowest of all windows)
        - First sidelobe: -13 dB (highest sidelobe level)
        - Sidelobe rolloff: -6 dB/octave (slowest decay)

    When to Use:
        - Transient detection (sharp onsets need sharp edges)
        - Signals where you want maximum frequency resolution
        - Signals already periodic in your sample length

    When Not to Use:
        - Continuous tones (will show spectral leakage)
        - When comparing amplitudes of nearby frequencies
    """
    var window = alloc[Float64](num_samples)
    for i in range(num_samples):
        window[i] = 1.0
    return window


fn generate_hann_window(
    num_samples: Int,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a Hann window (also called Hanning window).

    Mathematical Definition:
        w[n] = 0.5 * (1 - cos(2πn / (N-1))), for n = 0, 1, 2, ..., N-1

    The Hann window uses a single cosine cycle to taper from 1 at the edges
    to 0 at the center. The name comes from Julius von Hann, an Austrian
    meteorologist who used it for weather data analysis.

    Characteristics:
        - Main lobe width: 4 bins
        - First sidelobe: -31 dB
        - Sidelobe rolloff: -18 dB/octave

    When to Use:
        - General-purpose spectral analysis
        - Speech processing
        - Audio applications
        - Most cases where you're unsure which window to use

    Why "0.5 * (1 - cos(...))"?
        - cos(0) = 1, so at n=0: w = 0.5 * (1 - 1) = 0 ✓
        - cos(π) = -1, so at n=N/2: w = 0.5 * (1 + 1) = 1 (peak in middle)
        - cos(2π) = 1, so at n=N-1: w = 0.5 * (1 - 1) = 0 ✓
    """
    var window = alloc[Float64](num_samples)
    for i in range(num_samples):
        var n = Float64(i)
        var N = Float64(num_samples - 1)
        window[i] = 0.5 * (1.0 - cos(2.0 * n * 3.141592653589793 / N))
    return window


fn generate_hamming_window(
    num_samples: Int,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a Hamming window.

    Mathematical Definition:
        w[n] = 0.54 - 0.46 * cos(2πn / (N-1)), for n = 0, 1, 2, ..., N-1

    The Hamming window is similar to Hann but uses different coefficients (0.54
    and 0.46 instead of 0.5 and 0.5). This slight adjustment makes the
    sidelobes much lower, though the first sidelobe doesn't decay as fast.

    Named after Richard Hamming, who worked at Bell Labs on communications
    and signal processing.

    Characteristics:
        - Main lobe width: 4 bins
        - First sidelobe: -43 dB (much lower than Hann!)
        - Sidelobe rolloff: -6 dB/octave (slower than Hann)

    When to Use:
        - Speech processing (vocoders, formants)
        - When you need better sidelobe suppression than Hann
        - Communication systems

    Hann vs Hamming:
        - Hann: First sidelobe is lower overall, but decays faster
        - Hamming: First sidelobe is higher, decays slower
        - Hamming is better at suppressing the first sidelobe specifically
    """
    var window = alloc[Float64](num_samples)
    for i in range(num_samples):
        var n = Float64(i)
        var N = Float64(num_samples - 1)
        window[i] = 0.54 - 0.46 * cos(2.0 * n * 3.141592653589793 / N)
    return window


fn generate_blackman_window(
    num_samples: Int,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a Blackman window.

    Mathematical Definition:
        w[n] = 0.42 - 0.5 * cos(2πn / (N-1)) + 0.08 * cos(4πn / (N-1))
               for n = 0, 1, 2, ..., N-1

    The Blackman window uses two cosine terms (instead of one like Hann/Hamming)
    to create a more gradual taper. The coefficients are carefully chosen to
    minimize the first sidelobe while keeping the main lobe reasonably narrow.

    Named after Frank Blackman, who worked with Tukey on spectral analysis.

    Characteristics:
        - Main lobe width: 6 bins (widest common window)
        - First sidelobe: -58 dB
        - Sidelobe rolloff: -18 dB/octave

    When to Use:
        - When you need excellent sidelobe suppression
        - Analyzing signals with large dynamic range
        - When you can afford the wider main lobe
    """
    var window = alloc[Float64](num_samples)
    for i in range(num_samples):
        var n = Float64(i)
        var N = Float64(num_samples - 1)
        var a0 = 0.42
        var a1 = 0.5
        var a2 = 0.08
        window[i] = (
            a0
            - a1 * cos(2.0 * n * 3.141592653589793 / N)
            + a2 * cos(4.0 * n * 3.141592653589793 / N)
        )
    return window


fn generate_cosine_window(
    num_samples: Int,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a cosine window (also called sine window).

    Mathematical Definition:
        w[n] = sin(πn / (N-1)), for n = 0, 1, 2, ..., N-1

    The cosine window uses a single half-sine cycle. It's the simplest
    taper that ensures zero at both ends, making it useful when you need
    smooth edges without the DC component offset of Hann/Hamming.

    Characteristics:
        - Main lobe width: ~3 bins
        - First sidelobe: -23 dB
        - Sidelobe rolloff: -12 dB/octave

    When to Use:
        - When you need a simple, smooth taper
        - Interpolating or resampling applications
        - Weighted least-squares filter design

    Relationship to Other Windows:
        - Hann window = 0.5 * (1 - cos) = 0.5 * (1 + cosine_window) - 1
        - The cosine window is essentially the Hann window shifted
    """
    var window = alloc[Float64](num_samples)
    for i in range(num_samples):
        var n = Float64(i)
        var N = Float64(num_samples - 1)
        window[i] = sin(3.141592653589793 * n / N)
    return window


fn apply_window(
    signal: UnsafePointer[Float64, MutExternalOrigin],
    window: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Applies a window function to a signal.

    This is the pointwise multiplication:
        windowed_signal[n] = signal[n] * window[n]

    Note: This creates a new array; neither the original signal nor
    window is modified. The caller is responsible for freeing the returned
    pointer.

    Params:
        signal: Pointer to the input signal samples.
        window: Pointer to the window function (must have num_samples elements).
        num_samples: Number of samples.

    Returns:
        Pointer to the windowed signal (must be freed by caller).
    """
    var result = alloc[Float64](num_samples)
    for i in range(num_samples):
        result[i] = signal[i] * window[i]
    return result
