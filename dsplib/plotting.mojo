from std.python import Python
from .core import Complex


def plot_wave(
    wave: UnsafePointer[Float64, MutExternalOrigin], num_samples: Int, file_name: String
) raises:
    """
    This function plots a given wave for the amount of num_samples.
    """
    # Import Pythonic modules.
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    # Generate an replicate NumPy array to visualize.
    var out = np.empty(num_samples, dtype="float64")
    for i in range(num_samples):
        out[i] = wave[i]

    # Plot the array.
    plt.figure()
    plt.plot(out)
    plt.title("Wave Diagram")
    plt.xlabel("Samples")
    plt.ylabel("Amplitude")
    plt.grid(True)
    plt.savefig(file_name)


def plot_frequency_domain(
    bins: UnsafePointer[Complex, MutExternalOrigin],
    num_samples: Int,
    sample_rate: Float64,
    file_name: String,
) raises:
    """
    Plots the magnitude of the frequency bins.

    Params:
      bins (UnsafePointer): Pointer to the complex frequency domain bins.
      num_samples (Int): Number of bins.
      sample_rate (Float64): in samples/second
      file_name (String): Target file name.
    """
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    # We only plot the first half (0 to Nyquist) because real signals are symmetrical.
    var half = num_samples // 2
    var magnitudes = np.empty(half, dtype="float64")
    var frequencies = np.empty(half, dtype="float64")

    for i in range(half):
        # magnitude() on our Complex struct gives its volume.
        magnitudes[i] = bins[i].magnitude()
        # Calculate the actual frequency in Hz for the X-axis.
        frequencies[i] = (Float64(i) * sample_rate) / Float64(num_samples)

    plt.figure()
    plt.plot(frequencies, magnitudes)
    plt.title("Frequency Domain (Spectrum)")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude")
    plt.grid(True)
    plt.savefig(file_name)
