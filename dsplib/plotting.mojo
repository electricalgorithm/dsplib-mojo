"""
===============================================================================
PLOTTING MODULE FOR DSP VISUALIZATION
===============================================================================

This module provides functions to visualize signals and their frequency content.
Each function is designed to be educational, showing not just the plot but
explaining the underlying DSP concepts.

===============================================================================
FUNDAMENTAL CONCEPTS
===============================================================================

1. DECIBELS (dB)
   Decibels express ratios logarithmically, matching human perception better
   than linear values. The formula is:
   
       dB = 20 * log10(A1 / A2)
   
   where A1 and A2 are amplitudes. For voltage/current ratios.
   
   Why use dB?
   - Compresses huge range (1 to 1,000,000) into manageable numbers
   - Multiplication becomes addition: +6dB = double the power
   - Human hearing and vision are naturally logarithmic
   - Log scale shows small details at low amplitudes
   
   Reference levels:
       0 dB  = reference level (e.g., unity gain)
      +6 dB  = ~2x amplitude, ~4x power
      -6 dB  = ~0.5x amplitude, ~0.25x power
     -20 dB  = 10x reduction in amplitude
     -60 dB  = 1000x reduction (often the noise floor)

2. LOGARITHMIC FREQUENCY SCALE
   Traditional frequency plots use log scale because:
   
   - Human perception of pitch is logarithmic (octaves)
   - Musical notes are logarithmically spaced
   - We care about equal "ratios" not equal "differences"
   - Low frequencies need more visual space than high frequencies
   
   On a log plot from 20 Hz to 20 kHz:
   - 20 Hz to 200 Hz gets the same space as 2 kHz to 20 kHz
   - This is because an octave (2x frequency) takes equal visual space

3. MAGNITUDE VS FREQUENCY
   The magnitude spectrum shows "how much" of each frequency exists:
   
       |X[k]| = sqrt(X_re[k]² + X_im[k]²)
   
   For a pure sine wave at frequency f:
   - Only one bin has non-zero magnitude
   - All other bins are zero (or near-zero due to noise)
   
   For a square wave:
   - Fundamental frequency has largest magnitude
   - Odd harmonics (3f, 5f, 7f...) are visible
   - Each harmonic is smaller than the previous

4. PHASE SPECTRUM
   The phase tells us "where in the cycle" each frequency is at t=0:
   
       ∠X[k] = atan2(X_im[k], X_re[k])
   
   Phase is measured in degrees or radians:
       0°      = peak at t=0
      90°      = zero-crossing going positive at t=0
     180°      = trough at t=0
     -90°      = zero-crossing going negative at t=0
   
   Phase is "wrapped" - it repeats every 360° (or 2π radians).
   For an impulse response, phase should be 0° at all frequencies.

5. BODE PLOTS
   Bode plots show system frequency response, crucial for understanding
   how systems behave across all frequencies:
   
   - Magnitude plot: |H(jω)| in dB vs log frequency
   - Phase plot: ∠H(jω) in degrees/radians vs log frequency
   
   For a unity-gain system (impulse response):
   - Magnitude should be 0 dB at all frequencies
   - Phase should be 0° at all frequencies (linear phase)
   
   Bode plots help us:
   - See where a system amplifies or attenuates
   - Find the -3 dB cutoff frequency of filters
   - Understand phase distortion
   - Design stable control systems

6. FFT AND SPECTRAL LEAKAGE
   The FFT assumes our signal is one period of an infinitely repeating
   waveform. If the signal doesn't fit perfectly, we get spectral leakage:
   
   - Energy "spills" from one bin into neighboring bins
   - Sharp transients (like impulses) have leakage
   - Windowing functions reduce leakage but don't eliminate it
   
   Windowing applies a taper to the edges:
   - Hann window: cos² taper, good for general use
   - Hamming window: similar but better for sinusoids
   - Blackman window: sharper cutoff, more sidelobe suppression
===============================================================================
"""

from std.math import log10, pi
from std.memory import alloc
from std.python import Python
from .core import Complex
from .utils import generate_time_array
from .windows import apply_window
from .fourier import compute_fft_recursive


# ============================================================================
# TIME DOMAIN PLOTTING
# ============================================================================


def plot_wave(
    wave: UnsafePointer[Float64, MutExternalOrigin],
    sample_rate: Float64,
    num_samples: Int,
    file_name: String,
    title: String = "Waveform",
    xlabel: String = "Time (s)",
    ylabel: String = "Amplitude",
) raises:
    """
    Plots a time-domain signal with proper time axis.

    This is the simplest visualization: amplitude vs. time.

    What You'll See:
        - Oscillations: how the signal varies over time
        - DC offset: if the wave is centered at zero or not
        - Envelope: if the signal fades in/out
        - Transients: clicks, pops, or sudden changes

    What You Won't See:
        - Frequency content (that's what FFT is for)
        - Phase relationships between frequencies

    The time axis is computed as: t[n] = n / sample_rate

    Example:
        A 440 Hz sine wave at 44100 Hz sample rate:
        - Sample 0 is at t = 0/44100 = 0.0 seconds
        - Sample 441 is at t = 441/44100 = 0.01 seconds (1/100th second)

    Parameters:
        wave: Pointer to the signal samples.
        sample_rate: Sample rate in samples per second (Hz).
        num_samples: Number of samples to plot.
        file_name: Output file path (PNG recommended).
        title: Plot title.
        xlabel: X-axis label (usually "Time (s)").
        ylabel: Y-axis label (usually "Amplitude").

    Educational Note:
        The waveform shows you WHAT the signal does over time.
        The frequency plot shows you WHY it does it (sinusoidal components).
        Both views are needed for complete understanding.
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    # Convert signal to numpy array for plotting
    # This copies data from Mojo memory to Python memory
    var out = np.empty(num_samples, dtype="float64")
    for i in range(num_samples):
        out[i] = wave[i]

    # Generate time axis: t[n] = n / sample_rate
    # At 44100 Hz, sample 44100 occurs at t = 1 second
    var time = generate_time_array(sample_rate, num_samples)
    var time_np = np.empty(num_samples, dtype="float64")
    for i in range(num_samples):
        time_np[i] = time[i]
    time.free()

    # Create the plot
    plt.figure()
    plt.plot(time_np, out)
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.grid(True)
    plt.savefig(file_name)


# ============================================================================
# FREQUENCY DOMAIN PLOTTING
# ============================================================================


def plot_frequency_domain(
    bins: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
    sample_rate: Float64,
    file_name: String,
) raises:
    """
    Plots the linear magnitude spectrum from FFT output.

    This shows the raw frequency content without dB scaling.

    Mathematical Basis:
        The FFT output X[k] contains complex numbers for each frequency bin.
        The magnitude |X[k]| tells us "how much" of frequency f_k is present.

        Frequency of bin k: f_k = k * sample_rate / N
        where N is the FFT size.

    What You'll See:
        - DC component (bin 0): the average value of the signal
        - Positive frequencies (bins 0 to N/2): the real spectrum
        - Negative frequencies (bins N/2+1 to N-1): mirror of positive

    For Real Signals:
        The spectrum is symmetric: |X[k]| = |X[N-k]|
        This is because real signals can be written as sum of complex exponentials
        in conjugate pairs: cos(ωt) = (e^(jωt) + e^(-jωt)) / 2

    Scaling Note:
        The magnitude depends on:
        1. Signal amplitude
        2. Number of samples N
        3. Window function (if used)

    Parameters:
        bins: Pointer to complex FFT output (N complex numbers).
        num_samples: Number of FFT bins (N).
        sample_rate: Sample rate in Hz.
        file_name: Output file path.

    Example:
        1024 samples at 44100 Hz:
        - Bin 0: 0 Hz (DC)
        - Bin 1: 44100/1024 ≈ 43 Hz
        - Bin 512: 22050 Hz (Nyquist)
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    # Number of positive frequencies (0 to Nyquist, inclusive)
    var half = num_samples // 2

    # Create arrays for plotting
    var magnitudes = np.empty(half, dtype="float64")
    var frequencies = np.empty(half, dtype="float64")

    # Convert complex magnitudes and compute frequencies
    # Only need positive frequencies for real signals
    for i in range(half):
        # Magnitude: sqrt(re² + im²)
        magnitudes[i] = bins[i].magnitude()

        # Frequency of bin k: f_k = k * fs / N
        frequencies[i] = (Float64(i) * sample_rate) / Float64(num_samples)

    # Plot with linear frequency axis
    plt.figure()
    plt.plot(frequencies, magnitudes)
    plt.title("Frequency Domain (Spectrum)")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude")
    plt.grid(True)
    plt.savefig(file_name)


def plot_spectrum_db(
    signal: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
    sample_rate: Float64,
    file_name: String,
    title: String = "Frequency Spectrum",
    window: Optional[UnsafePointer[Float64, MutExternalOrigin]] = None,
    freq_scale: String = "linear",
) raises:
    """
    Plots the FFT magnitude spectrum in decibels (dB).

    This shows the raw frequency content of a signal with dB scaling.
    Unlike Bode plots (which normalize to DC), this shows absolute magnitude.

    Difference from Bode Plots:
        Bode plots: |X[k]| / |X[0]| → DC = 0 dB (for system analysis)
        Spectrum:    |X[k]|            → shows absolute magnitude (for signal analysis)

    What You'll See:
        - DC component: average value of signal (often 0 for centered signals)
        - Peaks: dominant frequencies in the signal
        - Noise floor: baseline level of random noise
        - Harmonics: multiples of fundamental frequency (for periodic signals)

    For a Sine Wave:
        A pure 440 Hz sine wave shows:
        - DC ≈ 0 (centered at zero)
        - Peak at 440 Hz (the fundamental)
        - All other frequencies ≈ -100 dB (near numerical precision)

    For a Square Wave:
        Shows odd harmonics: f, 3f, 5f, 7f...
        Each harmonic is smaller than the previous.

    For White Noise:
        Flat spectrum (equal energy at all frequencies)

    Parameters:
        signal: Pointer to time-domain signal.
        num_samples: Number of samples (N).
        sample_rate: Sample rate in Hz.
        file_name: Output file path.
        title: Plot title.
        window: Optional window function for leakage reduction.
                Windowing trades off between:
                - Main lobe width (resolution)
                - Sidelobe level (dynamic range)
        freq_scale: "linear" (default) or "log" for log frequency axis.

    dB Calculation:
        magnitude_dB = 20 * log10(|X[k]|)

        For a sine wave with amplitude A:
        - Peak magnitude ≈ A * N / 2
        - In dB: 20 * log10(A * N / 2)
        - Example: A=1, N=1024 → ~74 dB

    Example:
        # Plot spectrum of a 440 Hz sine wave
        var signal = generate_sine_wave(...)
        plot_spectrum_db(signal, 1024, 44100.0, "spectrum.png")
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    # Compute FFT (optionally with window)
    var fft_result: UnsafePointer[Complex, MutExternalOrigin]
    if window.__bool__():
        fft_result = _apply_window_and_fft(signal, window.value(), num_samples)
    else:
        fft_result = compute_fft_recursive(signal, num_samples)

    # Number of positive frequencies
    var half = num_samples // 2

    # Create arrays for plotting
    var magnitudes_db = np.empty(half, dtype="float64")
    var frequencies = np.empty(half, dtype="float64")

    for i in range(half):
        # Compute magnitude
        var magnitude = fft_result[i].magnitude()

        # Convert to dB
        if magnitude < 1e-10:
            magnitudes_db[i] = -100.0
        else:
            magnitudes_db[i] = 20.0 * log10(magnitude)

        # Frequency of bin k: f_k = k * fs / N
        frequencies[i] = (Float64(i) * sample_rate) / Float64(num_samples)

    fft_result.free()

    # Create the plot
    plt.figure()
    if freq_scale == "log":
        plt.semilogx(frequencies, magnitudes_db)
    else:
        plt.plot(frequencies, magnitudes_db)
    plt.title(title)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude (dB)")
    plt.grid(True)
    plt.savefig(file_name)


# ============================================================================
# BODE PLOT FUNCTIONS
# ============================================================================
# Bode plots show the frequency response of linear systems.
#
# The frequency response H(jω) describes how a system modifies:
#   - Amplitude (gain) of each frequency
#   - Phase (timing) of each frequency
#
# For a system with impulse response h[n], the frequency response is:
#   H(jω) = Σ h[n] * e^(-jωn) = |H(jω)| * e^(j∠H(jω))
#   (This is the Discrete-Time Fourier Transform at ω = 2πf)
#
# Bode Plot Characteristics:
#   - Logarithmic frequency axis (shows ratios, not differences)
#   - Magnitude in decibels (compresses range, shows details)
#   - Phase in degrees or radians
#
# For a Unity-Gain System (impulse response δ[n]):
#   - |H(jω)| = 1 for all ω → 0 dB flat line
#   - ∠H(jω) = 0 for all ω → 0° flat line
# ============================================================================


struct BodeResponse:
    """
    Container for Bode plot frequency response data.

    This struct holds the computed frequency response for a signal,
    which can be used for plotting or further analysis.

    Attributes:
        frequencies: Logarithmically spaced frequencies in Hz.
                    Range: 20 Hz to Nyquist (fs/2 Hz)
        magnitude_db: Magnitude response in decibels (dB).
                      Normalized so DC = 0 dB
        phase_deg: Phase response in degrees.
                   Range: typically -180° to +180°
        num_points: Number of data points (log-spaced frequencies)

    Why Log-Spaced Frequencies?
        Bode plots use logarithmic frequency spacing because:
        1. Physical systems often have bandwidth specified as ratios (octaves)
        2. Human perception of pitch and loudness is logarithmic
        3. Equal visual space for equal frequency ratios
        4. Multi-band systems (lowpass, bandpass) show clearly

    Memory Management:
        All arrays are allocated on the heap. Call .free() when done
        to prevent memory leaks:
            var result = compute_bode_response[500](signal, N, fs)
            # use result...
            result.free()

    Example:
        var result = compute_bode_response[500](signal, 1024, 44100.0)

        # Access individual points
        var freq_at_1000hz = result.frequencies[250]  # approximately
        var gain_at_1000hz = result.magnitude_db[250]
        var phase_at_1000hz = result.phase_deg[250]

        result.free()
    """

    var frequencies: UnsafePointer[Float64, MutExternalOrigin]
    var magnitude_db: UnsafePointer[Float64, MutExternalOrigin]
    var phase_deg: UnsafePointer[Float64, MutExternalOrigin]
    var num_points: Int

    fn __init__(
        out self,
        freq: UnsafePointer[Float64, MutExternalOrigin],
        mag: UnsafePointer[Float64, MutExternalOrigin],
        phase: UnsafePointer[Float64, MutExternalOrigin],
        n: Int,
    ):
        self.frequencies = freq
        self.magnitude_db = mag
        self.phase_deg = phase
        self.num_points = n

    fn free(self):
        """
        Frees all memory associated with this BodeResponse.

        IMPORTANT: Always call this when done using the result.
        Forgetting to call free() will cause memory leaks.

        Example:
            var result = compute_bode_response[500](signal, N, fs)
            # ... use result ...
            result.free()  # Don't forget this!
        """
        self.frequencies.free()
        self.magnitude_db.free()
        self.phase_deg.free()


fn compute_bode_response[
    num_points: Int
](
    signal: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
    sample_rate: Float64,
) raises -> BodeResponse:
    """
    Computes the frequency response for Bode plot visualization.

    This function performs the complete chain from time-domain signal
    to frequency response ready for plotting.

    What This Function Does:
        1. Computes FFT of the input signal (time → frequency)
        2. Extracts positive frequencies (0 to Nyquist)
        3. Normalizes magnitude to DC (so DC = 0 dB)
        4. Converts phase to degrees
        5. Creates logarithmically spaced frequency axis

    Mathematical Pipeline:
        Input: x[n] (time domain, N samples)
            ↓
        FFT: X[k] = Σ x[n] * e^(-j*2π*k*n/N)
            ↓
        Magnitude: |X[k]| = sqrt(X_re[k]² + X_im[k]²)
            ↓
        Normalization: |X[k]|_norm = |X[k]| / |X[0]|
            ↓
        dB Conversion: dB[k] = 20 * log10(|X[k]|_norm)
            ↓
        Phase: φ[k] = atan2(X_im[k], X_re[k]) * 180/π
            ↓
        Output: BodeResponse with log-spaced frequencies

    Frequency Range:
        - Minimum: 20 Hz (lower limit of human hearing, convention)
        - Maximum: Nyquist = sample_rate / 2 Hz
                  (highest frequency we can detect)

    Why 20 Hz?
        Audio systems typically start at 20 Hz because:
        - It's approximately the lower limit of human hearing
        - Going lower would add mostly numerical noise
        - It's a standard convention in audio/control systems

    Logarithmic Spacing:
        The frequencies are logarithmically spaced:
            f[i] = 10^(log10(f_min) + i * step)
        where step = (log10(f_max) - log10(f_min)) / (num_points - 1)

        This gives equal visual space to equal frequency ratios:
        - 20 Hz to 200 Hz (10x) gets same width as 2 kHz to 20 kHz (10x)

    Parameters:
        signal: Pointer to time-domain signal (impulse response h[n]).
                For a unity-gain system, use an impulse: signal[0] = 1
        num_samples: Number of samples in signal (N).
        sample_rate: Sample rate in Hz (e.g., 44100 for audio).

    Returns:
        BodeResponse containing log-spaced frequency response data.
        Remember to call .free() when done!

    Example:
        # Create impulse response (unity gain system)
        var signal = allocate_buffer(1024)
        signal[0] = 1.0
        for i in range(1, 1024):
            signal[i] = 0.0

        # Compute frequency response
        var result = compute_bode_response[500](signal, 1024, 44100.0)

        # For impulse response, expect:
        # - magnitude_db ≈ 0 dB for all frequencies
        # - phase_deg ≈ 0° for all frequencies

        result.free()
        signal.free()

    Educational Note:
        This function computes |H(jω)| and ∠H(jω) from the impulse response.
        The impulse response h[n] completely characterizes a linear system:
        - Any input can be expressed as sum of impulses
        - Each impulse produces h[n] shifted in time
        - The output is convolution: y[n] = x[n] * h[n]
        - In frequency domain: Y(ω) = X(ω) * H(ω)
    """
    # Allocate arrays for frequency response
    var frequencies = alloc[Float64](num_points)
    var magnitude_db = alloc[Float64](num_points)
    var phase_deg = alloc[Float64](num_points)

    # Define frequency range
    # f_min = 20 Hz: approximately lower limit of human hearing
    # f_max = fs/2: Nyquist frequency (highest we can measure)
    var f_min: Float64 = 20.0
    var f_max: Float64 = sample_rate / 2.0

    # Compute logarithmic spacing parameters
    # log10(20) ≈ 1.30, log10(22050) ≈ 4.34
    # We want num_points evenly spaced in log space
    var log_f_min = log10(f_min)
    var log_f_max = log10(f_max)
    var log_step = (log_f_max - log_f_min) / Float64(num_points - 1)

    var np = Python.import_module("numpy")

    # Step 1: Compute FFT of the signal
    # This transforms from time domain to frequency domain
    var fft_result = compute_fft_recursive(signal, num_samples)

    # Step 2: Get DC magnitude for normalization
    # Normalizing to DC ensures DC = 0 dB
    # This is essential for Bode plots of system gain
    var dc_magnitude = fft_result[0].magnitude()

    # Step 3: Compute frequency response at log-spaced points
    for i in range(num_points):
        # Convert log index to linear frequency
        var log_f = log_f_min + Float64(i) * log_step
        var f = 10.0**log_f
        frequencies[i] = f

        # Map frequency to nearest FFT bin
        # bin_index = round(f * N / fs)
        var bin_idx = Int(f * Float64(num_samples) / sample_rate)

        # Clamp to valid range (0 to N/2 for positive frequencies)
        var half = num_samples // 2 + 1
        if bin_idx >= half:
            bin_idx = half - 1
        if bin_idx < 0:
            bin_idx = 0

        # Step 4: Get magnitude at this frequency bin
        var magnitude = fft_result[bin_idx].magnitude()

        # Normalize to DC (so DC = 0 dB)
        # This shows "how much gain relative to DC"
        if dc_magnitude > 1e-10:
            magnitude = magnitude / dc_magnitude

        # Step 5: Convert magnitude to dB
        # dB = 20 * log10(magnitude) for amplitude
        # We clip very small values to avoid -infinity
        if magnitude < 1e-10:
            magnitude_db[i] = -100.0
        else:
            magnitude_db[i] = 20.0 * log10(magnitude)

        # Step 6: Get phase at this frequency bin
        # Phase is atan2(imaginary, real) in radians
        var phase_rad = fft_result[bin_idx].phase()

        # Convert phase to degrees for easier interpretation
        phase_deg[i] = phase_rad * 180.0 / pi

    # Clean up FFT result
    fft_result.free()

    return BodeResponse(frequencies, magnitude_db, phase_deg, num_points)


# Helper function for windowed FFT
fn _apply_window_and_fft(
    signal: UnsafePointer[Float64, MutExternalOrigin],
    window: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
) raises -> UnsafePointer[Complex, MutExternalOrigin]:
    """
    Internal helper: applies window function then computes FFT.

    Windowing reduces spectral leakage by tapering signal edges.

    What happens:
        1. windowed[n] = signal[n] * window[n]
        2. FFT(windowed) computes frequency content

    Why windowing helps:
        Without windowing, FFT assumes periodic extension.
        If signal doesn't fit exactly, edges create discontinuity.
        Windowing tapers edges to zero, reducing discontinuity.
    """
    var windowed = apply_window(signal, window, num_samples)
    var result = compute_fft_recursive(windowed, num_samples)
    windowed.free()
    return result


# ============================================================================
# MAGNITUDE PLOT (from signal)
# ============================================================================


def plot_bode_magnitude[
    num_points: Int = 500
](
    signal: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
    sample_rate: Float64,
    file_name: String,
    title: String = "Bode Plot - Magnitude",
    window: Optional[UnsafePointer[Float64, MutExternalOrigin]] = None,
) raises:
    """
    Plots Bode magnitude response (dB vs log frequency) from a signal.

    This function computes the frequency response and plots just the magnitude.

    What You'll See:
        - 0 dB line: frequencies that pass through unchanged
        - Peaks: frequencies that are amplified
        - Dips: frequencies that are attenuated
        - -3 dB point: often the "cutoff" of a filter
        - Roll-off: how fast magnitude drops at filter edges

    Reading a Magnitude Bode Plot:
        +20 dB: 10x voltage amplification
         0 dB: unity gain (no change)
         -6 dB: approximately half amplitude
        -20 dB: 10x voltage attenuation
        -60 dB: near noise floor

    Parameters:
        signal: Pointer to time-domain signal (impulse response).
        num_samples: Number of samples in signal.
        sample_rate: Sample rate in Hz.
        file_name: Output file path.
        title: Plot title.
        window: Optional window function pointer for leakage reduction.
                Common choices:
                    - Hann window: good general purpose
                    - Hamming window: slightly better for sinusoids
                    - Blackman window: sharper main lobe

    Example:
        # Plot magnitude of a lowpass filter
        var signal = create_lowpass_filter(...)
        plot_bode_magnitude[500](signal, 1024, 44100.0, "filter_mag.png")
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    # Compute FFT (optionally with window)
    var fft_result: UnsafePointer[Complex, MutExternalOrigin]
    if window.__bool__():
        fft_result = _apply_window_and_fft(signal, window.value(), num_samples)
    else:
        fft_result = compute_fft_recursive(signal, num_samples)

    # Define logarithmic frequency axis
    # Start at 20 Hz (lower hearing limit)
    # End at Nyquist (fs/2)
    var f_min: Float64 = 20.0
    var f_max: Float64 = sample_rate / 2.0
    var log_f_min = log10(f_min)
    var log_f_max = log10(f_max)
    var log_step = (log_f_max - log_f_min) / Float64(num_points - 1)

    # Normalize to DC for 0 dB reference
    var dc_magnitude = fft_result[0].magnitude()

    # Create arrays for plotting
    var freq_np = np.empty(num_points, dtype="float64")
    var mag_np = np.empty(num_points, dtype="float64")

    # Compute magnitude at each log-spaced frequency
    for i in range(num_points):
        # Log-spaced frequency
        var log_f = log_f_min + Float64(i) * log_step
        var f = 10.0**log_f
        freq_np[i] = f

        # Map frequency to FFT bin index
        var bin_idx = Int(f * Float64(num_samples) / sample_rate)
        var half = num_samples // 2 + 1
        if bin_idx >= half:
            bin_idx = half - 1
        if bin_idx < 0:
            bin_idx = 0

        # Get and normalize magnitude
        var magnitude = fft_result[bin_idx].magnitude()
        if dc_magnitude > 1e-10:
            magnitude = magnitude / dc_magnitude

        # Convert to dB
        if magnitude < 1e-10:
            mag_np[i] = -100.0
        else:
            mag_np[i] = 20.0 * log10(magnitude)

    fft_result.free()

    # Create the plot
    plt.figure()
    plt.semilogx(freq_np, mag_np)
    plt.title(title)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude (dB)")
    plt.grid(True, which="both", linestyle="-", alpha=0.3)
    plt.grid(True, which="major", linestyle="-", alpha=0.8)
    plt.axhline(y=0.0, color="k", linestyle="--", linewidth=0.5, alpha=0.5)
    plt.axhline(y=-3.0, color="r", linestyle="--", linewidth=0.5, alpha=0.5)
    plt.savefig(file_name)


# ============================================================================
# PHASE PLOT (from signal)
# ============================================================================


def plot_bode_phase[
    num_points: Int = 500
](
    signal: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
    sample_rate: Float64,
    file_name: String,
    title: String = "Bode Plot - Phase",
    window: Optional[UnsafePointer[Float64, MutExternalOrigin]] = None,
    phase_unit: String = "degrees",
) raises:
    """
    Plots Bode phase response from a signal.

    Phase tells us "where in the cycle" each frequency is at t=0.

    What Phase Means:
        Phase = 0°:   Peak occurs at t=0
        Phase = 90°:  Zero-crossing going positive at t=0
        Phase = 180°: Trough occurs at t=0
        Phase = -90°: Zero-crossing going negative at t=0

    Why Phase Matters:
        - Different arrival times = different phases
        - Phase distortion causes signal to "smear" in time
        - Audio: phase errors change timbre
        - Data: phase errors cause intersymbol interference

    For Unity-Gain System:
        Phase should be 0° at all frequencies (linear phase).
        Any deviation means the system delays some frequencies more.

    Parameters:
        signal: Pointer to time-domain signal.
        num_samples: Number of samples.
        sample_rate: Sample rate in Hz.
        file_name: Output file path.
        title: Plot title.
        window: Optional window function for leakage reduction.
        phase_unit: "degrees" (default) or "radians".

    Example:
        # Plot phase in radians instead of degrees
        plot_bode_phase[500](signal, 1024, 44100.0, "phase.png",
                             phase_unit="radians")
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    # Compute FFT (optionally with window)
    var fft_result: UnsafePointer[Complex, MutExternalOrigin]
    if window.__bool__():
        fft_result = _apply_window_and_fft(signal, window.value(), num_samples)
    else:
        fft_result = compute_fft_recursive(signal, num_samples)

    # Log-spaced frequency axis
    var f_min: Float64 = 20.0
    var f_max: Float64 = sample_rate / 2.0
    var log_f_min = log10(f_min)
    var log_f_max = log10(f_max)
    var log_step = (log_f_max - log_f_min) / Float64(num_points - 1)

    # Determine output unit
    var use_radians = phase_unit == "radians"

    var freq_np = np.empty(num_points, dtype="float64")
    var phase_np = np.empty(num_points, dtype="float64")

    for i in range(num_points):
        var log_f = log_f_min + Float64(i) * log_step
        var f = 10.0**log_f
        freq_np[i] = f

        var bin_idx = Int(f * Float64(num_samples) / sample_rate)
        var half = num_samples // 2 + 1
        if bin_idx >= half:
            bin_idx = half - 1
        if bin_idx < 0:
            bin_idx = 0

        # Get phase in radians, convert if needed
        var phase_rad = fft_result[bin_idx].phase()
        if use_radians:
            phase_np[i] = phase_rad
        else:
            phase_np[i] = phase_rad * 180.0 / pi

    fft_result.free()

    var ylabel = "Phase (radians)" if use_radians else "Phase (degrees)"

    plt.figure()
    plt.semilogx(freq_np, phase_np)
    plt.title(title)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel(ylabel)
    plt.grid(True, which="both", linestyle="-", alpha=0.3)
    plt.grid(True, which="major", linestyle="-", alpha=0.8)
    plt.axhline(y=0.0, color="k", linestyle="--", linewidth=0.5, alpha=0.5)
    plt.savefig(file_name)


# ============================================================================
# COMBINED BODE PLOT (from signal)
# ============================================================================


def plot_bode[
    num_points: Int = 500
](
    signal: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
    sample_rate: Float64,
    file_name: String,
    title: String = "Bode Plot",
    window: Optional[UnsafePointer[Float64, MutExternalOrigin]] = None,
    phase_unit: String = "degrees",
) raises:
    """
    Plots combined Bode magnitude and phase response (2-panel figure).

    This creates a two-panel figure showing both magnitude and phase
    on the same plot, which is the standard way to visualize frequency response.

    Top Panel (Magnitude):
        Shows gain in dB vs log frequency
        - 0 dB = unity gain
        - Peaks show amplification
        - Dips show attenuation
        - -3 dB often indicates filter cutoff

    Bottom Panel (Phase):
        Shows phase shift in degrees/radians vs log frequency
        - 0° = no phase shift
        - Negative phase = output lags input
        - Positive phase = output leads input
        - -180° to +180° range (wrapped)

    Why Two Panels?
        Magnitude and phase together fully describe a linear system:
            H(jω) = |H(jω)| * e^(j∠H(jω))

        Knowing only magnitude isn't enough:
            - Same magnitude can have different phases
            - Phase affects signal shape and timing

    Parameters:
        signal: Pointer to time-domain signal.
        num_samples: Number of samples.
        sample_rate: Sample rate in Hz.
        file_name: Output file path.
        title: Plot title (will have " - Magnitude" and " - Phase" appended).
        window: Optional window function.
        phase_unit: "degrees" (default) or "radians".

    Example:
        # Create impulse response for unity gain system
        var signal = allocate_buffer(1024)
        signal[0] = 1.0

        # Plot Bode (expect flat 0 dB, flat 0°)
        plot_bode[500](signal, 1024, 44100.0, "bode.png",
                      title="Unity Gain System")
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    # Compute FFT (optionally with window)
    var fft_result: UnsafePointer[Complex, MutExternalOrigin]
    if window.__bool__():
        fft_result = _apply_window_and_fft(signal, window.value(), num_samples)
    else:
        fft_result = compute_fft_recursive(signal, num_samples)

    # Log-spaced frequency axis
    var f_min: Float64 = 20.0
    var f_max: Float64 = sample_rate / 2.0
    var log_f_min = log10(f_min)
    var log_f_max = log10(f_max)
    var log_step = (log_f_max - log_f_min) / Float64(num_points - 1)

    # Normalize to DC and determine phase unit
    var dc_magnitude = fft_result[0].magnitude()
    var use_radians = phase_unit == "radians"

    var freq_np = np.empty(num_points, dtype="float64")
    var mag_np = np.empty(num_points, dtype="float64")
    var phase_np = np.empty(num_points, dtype="float64")

    for i in range(num_points):
        var log_f = log_f_min + Float64(i) * log_step
        var f = 10.0**log_f
        freq_np[i] = f

        var bin_idx = Int(f * Float64(num_samples) / sample_rate)
        var half = num_samples // 2 + 1
        if bin_idx >= half:
            bin_idx = half - 1
        if bin_idx < 0:
            bin_idx = 0

        # Magnitude (normalized to DC = 0 dB)
        var magnitude = fft_result[bin_idx].magnitude()
        if dc_magnitude > 1e-10:
            magnitude = magnitude / dc_magnitude
        if magnitude < 1e-10:
            mag_np[i] = -100.0
        else:
            mag_np[i] = 20.0 * log10(magnitude)

        # Phase
        var phase_rad = fft_result[bin_idx].phase()
        if use_radians:
            phase_np[i] = phase_rad
        else:
            phase_np[i] = phase_rad * 180.0 / pi

    fft_result.free()

    var phase_ylabel = "Phase (radians)" if use_radians else "Phase (degrees)"

    # Create two-panel figure
    plt.subplot(2, 1, 1)
    plt.semilogx(freq_np, mag_np)
    plt.title(title + " - Magnitude")
    plt.ylabel("Magnitude (dB)")
    plt.grid(True, which="both", linestyle="-", alpha=0.3)
    plt.grid(True, which="major", linestyle="-", alpha=0.8)
    plt.axhline(y=0.0, color="k", linestyle="--", linewidth=0.5, alpha=0.5)
    plt.axhline(y=-3.0, color="r", linestyle="--", linewidth=0.5, alpha=0.5)

    plt.subplot(2, 1, 2)
    plt.semilogx(freq_np, phase_np)
    plt.title(title + " - Phase")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel(phase_ylabel)
    plt.grid(True, which="both", linestyle="-", alpha=0.3)
    plt.grid(True, which="major", linestyle="-", alpha=0.8)
    plt.axhline(y=0.0, color="k", linestyle="--", linewidth=0.5, alpha=0.5)

    plt.tight_layout()
    plt.savefig(file_name)


# ============================================================================
# PRE-COMPUTED DATA PLOTTING
# ============================================================================
# These functions plot from pre-computed BodeResponse data.
# Use compute_bode_response() first, then plot_*() functions.
# ============================================================================


def plot_bode_magnitude(
    frequencies: UnsafePointer[Float64, MutExternalOrigin],
    magnitude_db: UnsafePointer[Float64, MutExternalOrigin],
    num_points: Int,
    file_name: String,
    title: String = "Bode Plot - Magnitude",
) raises:
    """
    Plots Bode magnitude from pre-computed data.

    Use this when you already have computed the frequency response
    using compute_bode_response() and want to plot just the magnitude.

    Parameters:
        frequencies: Array of frequencies in Hz (log-spaced).
        magnitude_db: Array of magnitude values in dB.
        num_points: Number of data points.
        file_name: Output file path.
        title: Plot title.
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    var freq_np = np.empty(num_points, dtype="float64")
    var mag_np = np.empty(num_points, dtype="float64")

    for i in range(num_points):
        freq_np[i] = frequencies[i]
        mag_np[i] = magnitude_db[i]

    plt.figure()
    plt.semilogx(freq_np, mag_np)
    plt.title(title)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude (dB)")
    plt.grid(True, which="both", linestyle="-", alpha=0.3)
    plt.grid(True, which="major", linestyle="-", alpha=0.8)
    plt.axhline(y=0.0, color="k", linestyle="--", linewidth=0.5, alpha=0.5)
    plt.axhline(y=-3.0, color="r", linestyle="--", linewidth=0.5, alpha=0.5)
    plt.savefig(file_name)


def plot_bode_phase(
    frequencies: UnsafePointer[Float64, MutExternalOrigin],
    phase_deg: UnsafePointer[Float64, MutExternalOrigin],
    num_points: Int,
    file_name: String,
    title: String = "Bode Plot - Phase",
    phase_unit: String = "degrees",
) raises:
    """
    Plots Bode phase from pre-computed data.

    Parameters:
        frequencies: Array of frequencies in Hz.
        phase_deg: Array of phase values in degrees.
        num_points: Number of data points.
        file_name: Output file path.
        title: Plot title.
        phase_unit: "degrees" (default) or "radians".
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    var use_radians = phase_unit == "radians"
    var deg_to_rad = pi / 180.0

    var freq_np = np.empty(num_points, dtype="float64")
    var phase_np = np.empty(num_points, dtype="float64")

    for i in range(num_points):
        freq_np[i] = frequencies[i]
        if use_radians:
            phase_np[i] = phase_deg[i] * deg_to_rad
        else:
            phase_np[i] = phase_deg[i]

    var ylabel = "Phase (radians)" if use_radians else "Phase (degrees)"

    plt.figure()
    plt.semilogx(freq_np, phase_np)
    plt.title(title)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel(ylabel)
    plt.grid(True, which="both", linestyle="-", alpha=0.3)
    plt.grid(True, which="major", linestyle="-", alpha=0.8)
    plt.axhline(y=0.0, color="k", linestyle="--", linewidth=0.5, alpha=0.5)
    plt.savefig(file_name)


def plot_bode_combined(
    frequencies: UnsafePointer[Float64, MutExternalOrigin],
    magnitude_db: UnsafePointer[Float64, MutExternalOrigin],
    phase_deg: UnsafePointer[Float64, MutExternalOrigin],
    num_points: Int,
    file_name: String,
    title: String = "Bode Plot",
    phase_unit: String = "degrees",
) raises:
    """
    Plots combined Bode magnitude and phase from pre-computed data.

    Parameters:
        frequencies: Array of frequencies in Hz.
        magnitude_db: Array of magnitude values in dB.
        phase_deg: Array of phase values in degrees.
        num_points: Number of data points.
        file_name: Output file path.
        title: Plot title.
        phase_unit: "degrees" (default) or "radians".
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    var use_radians = phase_unit == "radians"
    var deg_to_rad = pi / 180.0

    var freq_np = np.empty(num_points, dtype="float64")
    var mag_np = np.empty(num_points, dtype="float64")
    var phase_np = np.empty(num_points, dtype="float64")

    for i in range(num_points):
        freq_np[i] = frequencies[i]
        mag_np[i] = magnitude_db[i]
        if use_radians:
            phase_np[i] = phase_deg[i] * deg_to_rad
        else:
            phase_np[i] = phase_deg[i]

    var phase_ylabel = "Phase (radians)" if use_radians else "Phase (degrees)"

    plt.subplot(2, 1, 1)
    plt.semilogx(freq_np, mag_np)
    plt.title(title + " - Magnitude")
    plt.ylabel("Magnitude (dB)")
    plt.grid(True, which="both", linestyle="-", alpha=0.3)
    plt.grid(True, which="major", linestyle="-", alpha=0.8)
    plt.axhline(y=0.0, color="k", linestyle="--", linewidth=0.5, alpha=0.5)
    plt.axhline(y=-3.0, color="r", linestyle="--", linewidth=0.5, alpha=0.5)

    plt.subplot(2, 1, 2)
    plt.semilogx(freq_np, phase_np)
    plt.title(title + " - Phase")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel(phase_ylabel)
    plt.grid(True, which="both", linestyle="-", alpha=0.3)
    plt.grid(True, which="major", linestyle="-", alpha=0.8)
    plt.axhline(y=0.0, color="k", linestyle="--", linewidth=0.5, alpha=0.5)

    plt.tight_layout()


# ============================================================================
# UTILITY PLOTS
# ============================================================================


def plot_unit_circle(
    num_points: Int,
    file_name: String,
    title: String = "Unit Circle",
) raises:
    """
    Plots the unit circle with evenly spaced points around it.

    The unit circle is fundamental to understanding complex exponentials
    and the DFT. Each point on the circle represents e^(jθ).

    Why It Matters:
        The DFT uses "twiddle factors" W_N^k = e^(-j*2π*k/N)
        These are points equally spaced around the unit circle.

        For N=8:
            W_8^0 = 1.0 + j0.0 (angle 0°)
            W_8^1 = 0.707 - j0.707 (angle 45°)
            W_8^2 = 0.0 - j1.0 (angle 90°)
            ... and so on around the circle

    Visualizing the Unit Circle:
        - Real axis (x): cos(θ)
        - Imaginary axis (y): sin(θ)
        - Point at angle θ: (cos(θ), sin(θ))

    DFT Interpretation:
        DFT bin k "correlates" with frequency k/N of the unit circle.
        At bin k, we multiply signal by W_N^k and sum.

    Parameters:
        num_points: Number of points to plot around the circle (e.g., 8, 16).
        file_name: Output file name.
        title: Plot title.
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    # Generate angles from 0 to 2π
    var angles = np.linspace(0.0, 2.0 * pi, num_points)
    var x = np.cos(angles)
    var y = np.sin(angles)

    plt.figure()

    # Draw the unit circle
    var theta = np.linspace(0.0, 2.0 * pi, 100)
    plt.plot(
        np.cos(theta), np.sin(theta), "b-", linewidth=1.0, label="Unit Circle"
    )

    # Draw the sample points
    plt.plot(x, y, "ro", markersize=8)

    # Add axes
    plt.axhline(y=0.0, color="k", linewidth=0.5)
    plt.axvline(x=0.0, color="k", linewidth=0.5)
    plt.xlabel("Real")
    plt.ylabel("Imaginary")
    plt.title(title)
    plt.grid(True)
    plt.axis("equal")
    plt.savefig(file_name)


def plot_complex_points(
    points: UnsafePointer[Complex, MutExternalOrigin],
    num_points: Int,
    file_name: String,
    title: String = "Complex Numbers",
    show_unit_circle: Bool = False,
) raises:
    """
    Plots complex numbers as vectors (arrows) from the origin.

    This visualizes the complex plane representation of frequency bins.

    What Each Vector Represents:
        - Length (magnitude): how much of this frequency exists
        - Angle (phase): where this frequency is in its cycle at t=0

        Complex number a + jb plotted as vector from (0,0) to (a, b)

    Use Cases:
        - Visualize FFT output X[k] as phasors
        - See how adding complex numbers creates constructive/destructive interference
        - Understand phase relationships between frequency components

    Parameters:
        points: Pointer to array of complex numbers.
        num_points: Number of points to plot.
        file_name: Output file name.
        title: Plot title.
        show_unit_circle: Whether to draw unit circle for reference.

    Educational Example:
        A single-frequency signal at 440 Hz might show:
        - One vector at magnitude=1, angle=0° (DC or reference)
        - One vector at magnitude=1, angle=45° (the 440 Hz component)
        - All other vectors at magnitude≈0
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    plt.figure()

    # Optionally show unit circle for reference
    if show_unit_circle:
        var theta = np.linspace(0.0, 2.0 * pi, 100)
        plt.plot(np.cos(theta), np.sin(theta), "k--", linewidth=1.0, alpha=0.5)

    var ax = plt.gca()

    # Draw each complex number as an arrow
    for i in range(num_points):
        var re = points[i].re
        var im = points[i].im
        ax.arrow(
            0.0,
            0.0,
            re,
            im,
            head_width=0.05,
            head_length=0.03,
            fc="blue",
            ec="blue",
        )

    plt.axhline(y=0.0, color="k", linewidth=0.5)
    plt.axvline(x=0.0, color="k", linewidth=0.5)
    plt.xlabel("Real")
    plt.ylabel("Imaginary")
    plt.title(title)
    plt.grid(True)
    plt.axis("equal")
    plt.savefig(file_name)
