from std.math import sin, pi, iota, align_down
from std.memory import alloc
from std.random import rand, randn

@fieldwise_init
struct WaveConfig(ImplicitlyCopyable):
  """
  Holds the configuration of wave function generators.
  """
  # Signal Parameters
  var frequency_hz: Float64
  var amplitude: Float64
  var phase_rad: Float64
  var offset: Float64
  # Quantization Parameters
  var sample_rate_ss: Float64
  # Time Parameters
  var duration_s: Float64

  def get_angular_frequency(self) -> Float64:
    """Calculate and return sample rate in radians/seconds."""
    return 2.0 * pi * self.frequency_hz / self.sample_rate_ss 

  def get_number_of_samples(self) -> Int:
    """Calculate and return number of samples."""
    return Int(self.sample_rate_ss * self.duration_s)


@fieldwise_init
struct SineWave:
    """A struct to calculate sin waves with SIMD."""

    var samples: UnsafePointer[Float64, MutExternalOrigin]
    var wave_config: WaveConfig

    @always_inline
    fn generate[width: Int](self, i: Int):
        var indices: SIMD[DType.float64, width] = iota[DType.float64, width]() + Float64(i)
        # Calculate the value as := A*sin(indices*omega + phi) + DC
        var values = \
            self.wave_config.amplitude * \
            sin(indices * self.wave_config.get_angular_frequency() + self.wave_config.phase_rad) + \
            self.wave_config.offset
        self.samples.store(i, values)


def generate_sine_wave_raw(wave_config: WaveConfig) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    This function generates Sine waves using CPU's SIMD instructions.

    Params:
      wave_config: A WaveConfig struct that holds signal parameters.

    Returns:
      An array of int(sample_rate * duration) items.
    """

    # Amount of samples to calculate the wave.
    # sample_rate := samples/second
    # duration := seconds
    var num_samples: Int = wave_config.get_number_of_samples()

    # Allocate heap array.
    var samples = alloc[Float64](num_samples)

    # Initialize the struct with the allocated memory and frequency.
    var wave = SineWave(samples, wave_config)

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
    sample_rate: Float64, duration: Float64, mean: Float64 = 0.0, std_dev: Float64 = 1.0
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
    num_samples: Int,
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
