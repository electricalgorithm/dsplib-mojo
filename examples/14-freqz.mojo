"""
Filter Frequency Response Example

This example demonstrates the freqz function for computing the frequency
response directly from filter coefficients (a and b).

Unlike FFT-based Bode plots (which compute frequency content of a signal),
freqz computes H(e^jω) directly from the transfer function coefficients.

The transfer function:
    H(z) = B(z) / A(z) = (b0 + b1*z^-1 + ...) / (a0 + a1*z^-1 + ...)

Where:
    - b coefficients: feedforward (zeros)
    - a coefficients: feedback (poles)

This example shows:
    1. Simple low-pass filter (from blog post)
    2. Simple high-pass filter
    3. Bode-style magnitude and phase plots using existing plotting functions
"""

import dsplib
from std import os
from std.math import pi
from std.memory import alloc
from std.python import Python


fn freqz_to_bode_data(
    omega: List[Float64],
    h: List[dsplib.Complex],
    sample_rate: Float64,
) raises -> Tuple[
    UnsafePointer[Float64, MutExternalOrigin],
    UnsafePointer[Float64, MutExternalOrigin],
    UnsafePointer[Float64, MutExternalOrigin],
    Int,
]:
    """
    Converts freqz output to Bode plot data (frequencies, magnitude_db, phase_deg).

    Args:
        omega: List of angular frequencies from freqz.
        h: List of complex frequency responses from freqz.
        sample_rate: Sample rate in Hz.

    Returns:
        Tuple of (frequencies_hz, magnitude_db, phase_deg, num_points).
        Caller must free all three pointers.
    """
    var num_points = len(omega)
    var freq_hz = alloc[Float64](num_points)
    var mag_db = alloc[Float64](num_points)
    var phase_deg = alloc[Float64](num_points)

    for i in range(num_points):
        freq_hz[i] = dsplib.omega_to_hz(omega[i], sample_rate)

        var mag = h[i].magnitude()
        mag_db[i] = dsplib.magnitude_to_db(mag)

        var phase = h[i].phase()
        phase_deg[i] = phase * 180.0 / pi

    return (freq_hz, mag_db, phase_deg, num_points)


def main() raises:
    var sample_rate: Float64 = 44100.0
    var num_points = 512

    os.makedirs("build/examples/freqz", exist_ok=True)

    print("Filter Frequency Response Example")
    print("==================================")
    print("Sample rate:", sample_rate, "Hz")
    print("Frequency points:", num_points)
    print("")

    print("1. Low-pass filter (zero at z=-1, pole at z=0)")
    print("   b = [1.0, 1.0], a = [1.0, 0.0]")
    var a_lp = List[Float64]()
    a_lp.append(1.0)
    a_lp.append(0.0)
    var b_lp = List[Float64]()
    b_lp.append(1.0)
    b_lp.append(1.0)
    var result_lp = dsplib.freqz(a_lp, b_lp, num_points)
    var (freq_lp, mag_lp, phase_lp, n_lp) = freqz_to_bode_data(
        result_lp[0], result_lp[1], sample_rate
    )
    dsplib.plot_bode_combined(
        freq_lp,
        mag_lp,
        phase_lp,
        n_lp,
        "build/examples/freqz/lowpass_filter.png",
        "Low-Pass Filter",
    )
    freq_lp.free()
    mag_lp.free()
    phase_lp.free()
    print("   Saved: lowpass_filter.png")
    print("")

    print("2. High-pass filter (zero at z=1, pole at z=0)")
    print("   b = [1.0, -1.0], a = [1.0, 0.0]")
    var a_hp = List[Float64]()
    a_hp.append(1.0)
    a_hp.append(0.0)
    var b_hp = List[Float64]()
    b_hp.append(1.0)
    b_hp.append(-1.0)
    var result_hp = dsplib.freqz(a_hp, b_hp, num_points)
    var (freq_hp, mag_hp, phase_hp, n_hp) = freqz_to_bode_data(
        result_hp[0], result_hp[1], sample_rate
    )
    dsplib.plot_bode_combined(
        freq_hp,
        mag_hp,
        phase_hp,
        n_hp,
        "build/examples/freqz/highpass_filter.png",
        "High-Pass Filter",
    )
    freq_hp.free()
    mag_hp.free()
    phase_hp.free()
    print("   Saved: highpass_filter.png")
    print("")

    print("========================================")
    print("")
    print("Generated plots:")
    print("  1. lowpass_filter.png - Low-pass filter response")
    print("  2. highpass_filter.png - High-pass filter response")
    print("")
    print("Look for:")
    print("  - -3 dB cutoff at ~11 kHz (half of Nyquist)")
    print("  - Phase response showing -90 degree shift for low-pass")
