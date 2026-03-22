import dsplib

# The main entry function, could raise an exception.
def main() raises:
  var sample_rate: Float64 = 44100.0 # samples/sec
  var duration = 0.05 # seconds (reduced slightly for faster DFT calculation)
  var num_samples = Int(sample_rate * duration)

  # Implement a wave signal and save it.
  var wave_a = dsplib.generate_sine_wave_raw(440.0, sample_rate, duration)
  dsplib.plot_wave(wave_a, num_samples, "wave_a.png")
  wave_a.free()
  
  print("DSPLib is imported, and works great. Feel free to check examples!")
