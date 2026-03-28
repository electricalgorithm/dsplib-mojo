import dsplib
from std.math import cos, sin, pi
from std.memory import alloc
from std.python import Python


fn plot_dft_basis_vectors(num_samples: Int, file_name: String) raises:
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    var angles = np.empty(num_samples, dtype="float64")
    var x = np.empty(num_samples, dtype="float64")
    var y = np.empty(num_samples, dtype="float64")

    for i in range(num_samples):
        var angle = -2.0 * pi * Float64(i) / Float64(num_samples)
        angles[i] = angle
        x[i] = cos(angle)
        y[i] = sin(angle)

    plt.figure()
    var theta = np.linspace(0.0, 2.0 * pi, 100)
    plt.plot(
        np.cos(theta), np.sin(theta), "b-", linewidth=1.0, label="Unit Circle"
    )
    plt.plot(x, y, "ro", markersize=8, label="DFT Points")

    plt.axhline(y=0.0, color="k", linewidth=0.5)
    plt.axvline(x=0.0, color="k", linewidth=0.5)
    plt.xlabel("Real")
    plt.ylabel("Imaginary")
    plt.title("DFT Basis Vectors (Unit Circle Sampling)")
    plt.grid(True)
    plt.axis("equal")
    plt.legend()
    plt.savefig(file_name)


fn plot_dft_phasors(
    bins: UnsafePointer[dsplib.Complex, MutExternalOrigin],
    num_samples: Int,
    file_name: String,
) raises:
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    plt.figure()

    var theta_circle = np.linspace(0.0, 2.0 * pi, 100)
    plt.plot(
        np.cos(theta_circle),
        np.sin(theta_circle),
        "k--",
        linewidth=1.0,
        alpha=0.3,
    )

    var ax = plt.gca()

    for i in range(num_samples):
        var re = bins[i].re
        var im = bins[i].im
        var mag = bins[i].magnitude()

        if mag > 0.01:
            ax.arrow(
                0.0,
                0.0,
                re,
                im,
                head_width=0.03,
                head_length=0.015,
                fc="blue",
                ec="blue",
                alpha=0.7,
            )

    plt.axhline(y=0.0, color="k", linewidth=0.5)
    plt.axvline(x=0.0, color="k", linewidth=0.5)
    plt.xlabel("Real")
    plt.ylabel("Imaginary")
    plt.title("DFT Bins as Phasors")
    plt.grid(True)
    plt.axis("equal")
    plt.savefig(file_name)


fn plot_dft_phasors_highlighted(
    bins: UnsafePointer[dsplib.Complex, MutExternalOrigin],
    num_samples: Int,
    highlight_indices: UnsafePointer[Int, MutExternalOrigin],
    num_highlight: Int,
    file_name: String,
) raises:
    var np = Python.import_module("numpy")
    var plt = Python.import_module("matplotlib.pyplot")

    plt.figure()

    var theta_circle = np.linspace(0.0, 2.0 * pi, 100)
    plt.plot(
        np.cos(theta_circle),
        np.sin(theta_circle),
        "k--",
        linewidth=1.0,
        alpha=0.3,
    )

    var ax = plt.gca()

    for i in range(num_samples):
        var re = bins[i].re
        var im = bins[i].im
        var mag = bins[i].magnitude()

        var is_highlighted = False
        for j in range(num_highlight):
            if highlight_indices[j] == i:
                is_highlighted = True

        if is_highlighted:
            ax.arrow(
                0.0,
                0.0,
                re,
                im,
                head_width=0.08,
                head_length=0.04,
                fc="red",
                ec="red",
                linewidth=2.5,
            )
        elif mag > 0.01:
            ax.arrow(
                0.0,
                0.0,
                re,
                im,
                head_width=0.03,
                head_length=0.015,
                fc="blue",
                ec="blue",
                alpha=0.6,
            )

    plt.axhline(y=0.0, color="k", linewidth=0.5)
    plt.axvline(x=0.0, color="k", linewidth=0.5)
    plt.xlabel("Real")
    plt.ylabel("Imaginary")
    plt.title("DFT Bins with Highlighted Frequencies")
    plt.grid(True)
    plt.axis("equal")
    plt.savefig(file_name)


def main() raises:
    print("Example 03: DFT and the Unit Circle")
    print("=" * 40)

    var config = dsplib.WaveConfig(
        frequency_hz=882.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=44100.0,
        duration_s=0.01,
    )
    var N = 16

    print("\n1. Visualizing DFT basis vectors (unit circle sampling)...")
    plot_dft_basis_vectors(N, "dft_unit_circle.png")

    print(
        "\n2. Generating a simple sine wave (2 complete cycles in N samples)..."
    )
    var wave = dsplib.generate_sine_wave_raw(config)
    dsplib.plot_wave(wave, 44100.0, N, "wave_time_domain.png")

    print("\n3. Computing DFT to get frequency bins...")
    var dft_result = dsplib.compute_dft_raw(wave, N)
    wave.free()

    print("\n4. Visualizing DFT bins as phasors on the unit circle...")
    print("   Each arrow shows: magnitude (length) and phase (direction)")
    plot_dft_phasors(dft_result, N, "dft_phasors.png")

    print("\n5. Standard frequency spectrum for comparison...")
    dsplib.plot_frequency_domain(
        dft_result, N, config.sample_rate_ss, "dft_frequency_spectrum.png"
    )

    print("\n6. Highlighting specific frequency bins...")
    var indices = alloc[Int](2)
    indices[0] = 2
    indices[1] = N - 2
    plot_dft_phasors_highlighted(
        dft_result, N, indices, 2, "dft_phasors_highlighted.png"
    )
    indices.free()

    dft_result.free()

    print("\n" + "=" * 40)
    print("Generated files:")
    print(
        "  - dft_unit_circle.png        : The N sampling points on unit circle"
    )
    print("  - wave_time_domain.png       : Time-domain signal")
    print("  - dft_phasors.png           : DFT bins as phasors")
    print("  - dft_frequency_spectrum.png: Magnitude vs frequency")
    print("  - dft_phasors_highlighted.png: Same with key bins highlighted")
    print("\nThe DFT is essentially asking:")
    print("'How much does my signal correlate with each spinning probe?'")
