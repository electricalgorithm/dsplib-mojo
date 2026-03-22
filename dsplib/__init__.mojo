from std.math import sin, pi, iota, align_down
from std.algorithm import vectorize
from std.memory import alloc
from std.python import Python
from std.random import rand, randn


def plot_wave(
    wave: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
    file_name: String
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


@fieldwise_init
struct SineWave:
  """A struct to calculate sin waves with SIMD."""
  var samples: UnsafePointer[Float64, MutExternalOrigin]
  var angular_freq: Float64

  @always_inline
  fn generate[width: Int](self, i: Int):
    var indices: SIMD[DType.float64, width] = iota[DType.float64, width]() + Float64(i)
    var values = sin(indices * self.angular_freq)
    self.samples.store(i, values)


def generate_sine_wave_raw(
    frequency: Float64,
    sample_rate: Float64,
    duration: Float64) -> UnsafePointer[Float64, MutExternalOrigin]:
  """
  This function generates Sine waves using CPU's SIMD instructions.

  Params:
    frequency (Float64): in Hertz.
    sample_rate (Float64): in samples/seconds
    duration (Float64): in seconds.

  Returns:
    An array of int(sample_rate * duration) items.
  """

  # Amount of samples to calculate the wave.
  # sample_rate := samples/second
  # duration := seconds
  var num_samples: Int = Int(sample_rate * duration)

  # Calculate angular frequency (in radians).
  # sample_rate := samples/second
  # frequency := 1/second
  var angular_freq = 2.0 * pi * frequency / sample_rate

  # Allocate heap array.
  var samples = alloc[Float64](num_samples)

  # Initialize the struct with the allocated memory and frequency.
  var wave = SineWave(samples, angular_freq)
  
  # How many parallelization we want from SIMD. Must be a power of 2.
  comptime simd_width = 8 
 
  # Instead of vectorize (which has closure/struct limitations in this version),
  # we perform the SIMD loop manually for maximum performance.
  var simd_end = Int(align_down(UInt(num_samples), UInt(simd_width)))
  for i in range(0, simd_end, simd_width):
    wave.generate[simd_width](i)
  
  # Handle the remaining samples (tail).
  # We do not need to go with 4, 2 since 1 will be already fast.
  for i in range(simd_end, num_samples):
    wave.generate[1](i)

  return samples

def generate_random_normal_noise_raw(
    sample_rate: Float64,
    duration: Float64,
    mean: Float64 = 0.0,
    std_dev: Float64 = 1.0
    ) -> UnsafePointer[Float64, MutExternalOrigin]:
  """
  This function generates a white noise signal.

  Params:
    sample_rate (Float64): in samples/second
    duration (Float64): in seconds
    mean (Float64): Mean of the normal distribution
    std_dev (Float64): Standard Deviation of the normal distribution
  """
  var num_samples = Int(sample_rate * duration)
  var samples = alloc[Float64](num_samples)
  randn[DType.float64](samples, num_samples, mean=mean, standard_deviation=std_dev)
  return samples

def generate_random_uniform_noise_raw(
    sample_rate: Float64,
    duration: Float64,
    amplitude: Float64 = 1.0,
    ) -> UnsafePointer[Float64, MutExternalOrigin]:
  """
  This function generates a white noise signal.

  Params:
    sample_rate (Float64): in samples/second
    duration (Float64): in seconds
    amplitude (Float64): No unit
  """
  var num_samples = Int(sample_rate * duration)
  var samples = alloc[Float64](num_samples)
  rand[DType.float64](samples, num_samples, min=-amplitude, max=amplitude)
  return samples

def add_waves(
    a: UnsafePointer[Float64, MutExternalOrigin],
    b: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int
    ) -> UnsafePointer[Float64, MutExternalOrigin]:
  """
  This function adds to waves together up to num_samples.

  Params:
    a (UnsafePointer): Pointer to the first wave.
    b (UnsafePointer): Pointer to the second wave.
    num_samples (Int): Number of samples for the new resulting array.
                       This sample amount will be cropped from arrays.

  Returns:
    UnsafePointer[Float64, MutExternalOrigin]: An array of a plus b.
  """
  var result: UnsafePointer[Float64, MutExternalOrigin] = alloc[Float64](num_samples)

  # We do the same SIMD hack here as well.
  # For every 8 (SIMD Width) go with SIMD.
  # Remaining list elements should go one by one.
  comptime simd_width = 8
  var simd_end = Int(align_down(UInt(num_samples), UInt(simd_width)))
  for i in range(0, simd_end, simd_width):
      var va = a.load[width=simd_width](i)
      var vb = b.load[width=simd_width](i)
      var vr = va + vb
      result.store(i, vr)
  for i in range(simd_end, num_samples):
    result[i] = a[i] + b[i]
  return result
