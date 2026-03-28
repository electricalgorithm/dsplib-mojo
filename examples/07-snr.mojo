import dsplib


def main() raises:
    print("Example 07: Signal-to-Noise Ratio (SNR)")
    print("=" * 50)

    var sample_rate: Float64 = 44100.0
    var duration: Float64 = 0.05
    var num_samples = Int(sample_rate * duration)

    print("\n1. Generate clean sine wave (440 Hz)...")
    var clean_config = dsplib.WaveConfig(
        frequency_hz=440.0,
        amplitude=1.0,
        phase_rad=0.0,
        offset=0.0,
        sample_rate_ss=sample_rate,
        duration_s=duration,
    )
    var clean = dsplib.generate_sine_wave_raw(clean_config)
    dsplib.plot_wave(clean, sample_rate, num_samples, "snr_clean.png")

    print("\n2. Adding noise at 30 dB SNR...")
    var noisy_30db = dsplib.add_noise_at_snr(clean, num_samples, 30.0)
    dsplib.plot_wave(noisy_30db, sample_rate, num_samples, "snr_30db.png")

    print("\n3. Adding noise at 20 dB SNR...")
    var noisy_20db = dsplib.add_noise_at_snr(clean, num_samples, 20.0)
    dsplib.plot_wave(noisy_20db, sample_rate, num_samples, "snr_20db.png")

    print("\n4. Adding noise at 10 dB SNR...")
    var noisy_10db = dsplib.add_noise_at_snr(clean, num_samples, 10.0)
    dsplib.plot_wave(noisy_10db, sample_rate, num_samples, "snr_10db.png")

    print("\n5. Adding noise at 5 dB SNR...")
    var noisy_5db = dsplib.add_noise_at_snr(clean, num_samples, 5.0)
    dsplib.plot_wave(noisy_5db, sample_rate, num_samples, "snr_5db.png")

    print("\n6. SNR reference table...")
    print("  | SNR (dB) | Signal/Noise Ratio | Quality      |")
    print("  |----------|-------------------|-------------|")
    print("  | 30 dB    | 1000:1            | Excellent   |")
    print("  | 20 dB    | 100:1             | Good        |")
    print("  | 10 dB    | 10:1              | Fair        |")
    print("  | 5 dB     | 3:1               | Poor        |")
    print("  | 0 dB     | 1:1               | Signal=Noise|")

    clean.free()
    noisy_30db.free()
    noisy_20db.free()
    noisy_10db.free()
    noisy_5db.free()

    print("\n" + "=" * 50)
    print("Generated files:")
    print("  - snr_clean.png : Clean signal (reference)")
    print("  - snr_30db.png  : SNR = 30 dB (high quality)")
    print("  - snr_20db.png  : SNR = 20 dB (good)")
    print("  - snr_10db.png  : SNR = 10 dB (fair)")
    print("  - snr_5db.png   : SNR = 5 dB (noisy)")
    print("")
    print("Formula: noise_std = 1.0 / 10^(SNR_dB / 20)")
    print("  30 dB -> std = 0.0316")
    print("  20 dB -> std = 0.1000")
    print("  10 dB -> std = 0.3162")
    print("   5 dB -> std = 0.5623")
