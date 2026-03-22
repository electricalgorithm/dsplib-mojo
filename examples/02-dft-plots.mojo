import dsplib

# The main entry function, could raise an exception.
def main() raises:
  var sample_rate: Float64 = 44100.0 # samples/sec
  var duration = 0.05 # seconds (reduced slightly for faster DFT calculation)
  var num_samples = Int(sample_rate * duration)

  # Generate waves.
  var wave_a = dsplib.generate_sine_wave_raw(440.0, sample_rate, duration)
  var wave_b = dsplib.generate_sine_wave_raw(880.0, sample_rate, duration)
  var wave_uniform_noisy = dsplib.generate_random_uniform_noise_raw(sample_rate, duration)
  var wave_normal_noisy = dsplib.generate_random_normal_noise_raw(sample_rate, duration)
  var wave_a_plus_b = dsplib.add_waves(wave_a, wave_b, num_samples)

  # Save time-domain waves.
  print("Plotting time domain waves...")
  dsplib.plot_wave(wave_a, num_samples, "wave_a.png")
  dsplib.plot_wave(wave_b, num_samples, "wave_b.png")
  dsplib.plot_wave(wave_a_plus_b, num_samples, "wave_a_plus_b.png")

  # Calculate and Plot Frequency Domain (DFT).
  # This is O(N^2), so we do it for the requested waves.
  print("Calculating and plotting frequency domains (DFT)...")

  print("  Processing Wave A (440Hz)...")
  var dft_a = dsplib.compute_dft_raw(wave_a, num_samples)
  dsplib.plot_frequency_domain(dft_a, num_samples, sample_rate, "dft_a.png")
  dft_a.free()

  print("  Processing Wave B (392Hz)...")
  var dft_b = dsplib.compute_dft_raw(wave_b, num_samples)
  dsplib.plot_frequency_domain(dft_b, num_samples, sample_rate, "dft_b.png")
  dft_b.free()

  print("  Processing Uniform Noise...")
  var dft_uni = dsplib.compute_dft_raw(wave_uniform_noisy, num_samples)
  dsplib.plot_frequency_domain(dft_uni, num_samples, sample_rate, "dft_uniform_noise.png")
  dft_uni.free()

  print("  Processing Normal Noise...")
  var dft_norm = dsplib.compute_dft_raw(wave_normal_noisy, num_samples)
  dsplib.plot_frequency_domain(dft_norm, num_samples, sample_rate, "dft_normal_noise.png")
  dft_norm.free()

  print("  Processing Wave A + B...")
  var dft_ab = dsplib.compute_dft_raw(wave_a_plus_b, num_samples)
  dsplib.plot_frequency_domain(dft_ab, num_samples, sample_rate, "dft_a_plus_b.png")
  dft_ab.free()

  # Free the individual time-domain waves.
  wave_a.free()
  wave_b.free()
  wave_uniform_noisy.free()
  wave_normal_noisy.free()
  wave_a_plus_b.free()

  print("Completed.")
