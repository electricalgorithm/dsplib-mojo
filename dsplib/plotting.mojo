from std.math import cos, pi
from std.python import Python
from .core import Complex
from .utils import generate_time_array
from .windows import apply_window


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

    Params:
      wave: Pointer to the signal samples.
      sample_rate: Sample rate in samples per second.
      num_samples: Number of samples to plot.
      file_name: Output file name.
      title: Plot title.
      xlabel: X-axis label.
      ylabel: Y-axis label.
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    var out = np.empty(num_samples, dtype="float64")
    for i in range(num_samples):
        out[i] = wave[i]

    var time = generate_time_array(sample_rate, num_samples)
    var time_np = np.empty(num_samples, dtype="float64")
    for i in range(num_samples):
        time_np[i] = time[i]
    time.free()

    plt.figure()
    plt.plot(time_np, out)
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.grid(True)
    plt.savefig(file_name)


def plot_frequency_domain(
    bins: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
    sample_rate: Float64,
    file_name: String,
) raises:
    """
    Plots the magnitude spectrum of frequency bins.

    Params:
      bins: Pointer to the complex frequency domain bins.
      num_samples: Number of bins.
      sample_rate: Sample rate in samples/second.
      file_name: Output file name.
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    var half = num_samples // 2
    var magnitudes = np.empty(half, dtype="float64")
    var frequencies = np.empty(half, dtype="float64")

    for i in range(half):
        magnitudes[i] = bins[i].magnitude()
        frequencies[i] = (Float64(i) * sample_rate) / Float64(num_samples)

    plt.figure()
    plt.plot(frequencies, magnitudes)
    plt.title("Frequency Domain (Spectrum)")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude")
    plt.grid(True)
    plt.savefig(file_name)


def plot_fft_db(
    signal: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
    sample_rate: Float64,
    file_name: String,
    title: String = "Frequency Spectrum",
    window: Optional[UnsafePointer[Float64, MutExternalOrigin]] = None,
) raises:
    """
    Computes FFT using our own implementation and plots amplitude in dB vs frequency in Hz.

    The spectrum shows only positive frequencies (0 to Nyquist).
    Optionally applies a window function to reduce spectral leakage.

    Amplitude in dB: 20 * log10(|X[k]|)

    Windowing:
        If a window is provided, the signal is multiplied by the window before FFT.
        This reduces spectral leakage at the cost of wider main lobe.
        Common windows: Hann, Hamming, Blackman (see windows.mojo).

    Params:
      signal: Pointer to the time-domain signal samples.
      num_samples: Number of samples.
      sample_rate: Sample rate in samples/second.
      file_name: Output file name for the plot.
      title: Plot title.
      window: Optional window function pointer. If provided, the signal is
              windowed before FFT. If None, no windowing is applied.
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    from .fourier import compute_fft_recursive

    var fft_result: UnsafePointer[Complex, MutExternalOrigin]

    if window.__bool__():
        var window_ptr = window.value()

        if num_samples <= 8:
            var windowed = apply_window[8](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
        elif num_samples <= 16:
            var windowed = apply_window[16](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
        elif num_samples <= 32:
            var windowed = apply_window[32](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
        elif num_samples <= 64:
            var windowed = apply_window[64](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
        elif num_samples <= 128:
            var windowed = apply_window[128](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
        elif num_samples <= 256:
            var windowed = apply_window[256](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
        elif num_samples <= 512:
            var windowed = apply_window[512](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
        elif num_samples <= 1024:
            var windowed = apply_window[1024](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
        elif num_samples <= 2048:
            var windowed = apply_window[2048](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
        elif num_samples <= 4096:
            var windowed = apply_window[4096](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
        elif num_samples <= 8192:
            var windowed = apply_window[8192](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
        else:
            var windowed = apply_window[16384](signal, window_ptr)
            fft_result = compute_fft_recursive(windowed, num_samples)
            windowed.free()
    else:
        fft_result = compute_fft_recursive(signal, num_samples)

    var half = num_samples // 2 + 1
    var frequencies = np.empty(half, dtype="float64")
    var db_values = np.empty(half, dtype="float64")

    for i in range(half):
        frequencies[i] = (Float64(i) * sample_rate) / Float64(num_samples)

        var magnitude = fft_result[i].magnitude()
        magnitude = magnitude * 2.0 / Float64(num_samples)
        if i == 0:
            magnitude = magnitude * 0.5

        db_values[i] = 20.0 * np.log10(magnitude + 1e-12)

    fft_result.free()

    plt.figure()
    plt.plot(frequencies, db_values)
    plt.title(title)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Amplitude (dB)")
    plt.grid(True)
    plt.savefig(file_name)


def plot_unit_circle(
    num_points: Int,
    file_name: String,
    title: String = "Unit Circle",
) raises:
    """
    Plots the unit circle with evenly spaced points around it.

    This visualizes the complex plane basis vectors used in DFT/FFT.

    Params:
      num_points: Number of points to plot around the circle (e.g., 8, 16, N).
      file_name: Output file name.
      title: Plot title.
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    var angles = np.linspace(0.0, 2.0 * pi, num_points)
    var x = np.cos(angles)
    var y = np.sin(angles)

    plt.figure()
    var theta = np.linspace(0.0, 2.0 * pi, 100)
    plt.plot(
        np.cos(theta), np.sin(theta), "b-", linewidth=1.0, label="Unit Circle"
    )
    plt.plot(x, y, "ro", markersize=8)
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
    Plots complex numbers as vectors (arrows) from the origin on the complex plane.

    This is useful for visualizing phasors, DFT bins, or any complex-valued data.

    Params:
      points: Pointer to array of complex numbers to plot.
      num_points: Number of points to plot.
      file_name: Output file name.
      title: Plot title.
      show_unit_circle: Whether to draw the unit circle for reference.
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    plt.figure()

    if show_unit_circle:
        var theta = np.linspace(0.0, 2.0 * pi, 100)
        plt.plot(np.cos(theta), np.sin(theta), "k--", linewidth=1.0, alpha=0.5)

    var ax = plt.gca()

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
