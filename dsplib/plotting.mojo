from std.math import cos, sin, pi
from std.python import Python
from .core import Complex
from .utils import generate_time_array


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
