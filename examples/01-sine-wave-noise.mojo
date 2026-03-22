import dsplib

# The main entry function, could raise an exception.
def main() raises:
  var sample_rate: Float64 = 44100.0 # samples/sec
  var duration = 0.1 # seconds
  var num_samples = Int(sample_rate * duration)

  # Generate sine wave.
  var wave_a = dsplib.generate_sine_wave_raw(440.0, sample_rate, duration)
  var wave_b = dsplib.generate_sine_wave_raw(392.0, sample_rate, duration)
  var wave_uniform_noisy = dsplib.generate_random_uniform_noise_raw(sample_rate, duration)
  var wave_normal_noisy = dsplib.generate_random_normal_noise_raw(sample_rate, duration)

  # Add waves.
  var wave_a_uni_noise = dsplib.add_waves(wave_a, wave_uniform_noisy, num_samples)
  var wave_b_uni_noise = dsplib.add_waves(wave_b, wave_uniform_noisy, num_samples)
  var wave_a_normal_noise = dsplib.add_waves(wave_a, wave_normal_noisy, num_samples)
  var wave_b_normal_noise = dsplib.add_waves(wave_b, wave_normal_noisy, num_samples)
  var wave_a_plus_b = dsplib.add_waves(wave_a, wave_b, num_samples)
  var wave_a_plus_b_plus_uni_noise = dsplib.add_waves(wave_a_plus_b, wave_uniform_noisy, num_samples)
  var wave_a_plus_b_plus_normal_noise = dsplib.add_waves(wave_a_plus_b, wave_normal_noisy, num_samples)

  # Save waves.
  dsplib.plot_wave(wave_a, num_samples, "wave_a.png")
  dsplib.plot_wave(wave_b, num_samples, "wave_b.png")
  dsplib.plot_wave(wave_uniform_noisy, num_samples, "wave_uniform_noisy.png")
  dsplib.plot_wave(wave_normal_noisy, num_samples, "wave_normal_noisy.png")
  dsplib.plot_wave(wave_a_normal_noise, num_samples, "wave_a_normal_noise.png")
  dsplib.plot_wave(wave_a_uni_noise, num_samples, "wave_a_uniform_noise.png")
  dsplib.plot_wave(wave_b_normal_noise, num_samples, "wave_b_normal_noise.png")
  dsplib.plot_wave(wave_b_uni_noise, num_samples, "wave_b_uniform_noise.png")
  dsplib.plot_wave(wave_a_plus_b, num_samples, "wave_a_plus_b.png")
  dsplib.plot_wave(wave_a_plus_b_plus_normal_noise, num_samples, "wave_a_plus_b_plus_normal_noise.png")
  dsplib.plot_wave(wave_a_plus_b_plus_uni_noise, num_samples, "wave_a_plus_b_plus_uni_noise.png")

  # Free the individual waves.
  wave_a.free()
  wave_b.free()
  wave_uniform_noisy.free()
  wave_normal_noisy.free()
  wave_a_uni_noise.free()
  wave_b_uni_noise.free()
  wave_a_plus_b.free()
  wave_a_plus_b_plus_uni_noise.free() 
  wave_a_normal_noise.free()
  wave_b_normal_noise.free()
  wave_a_plus_b_plus_normal_noise.free() 


  print("Completed.")
