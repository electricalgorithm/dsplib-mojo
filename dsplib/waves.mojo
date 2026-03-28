from std.math import sin, pi, iota, align_down
from std.memory import alloc
from std.random import rand, randn
from .utils import sign


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
struct SquareWaveConfig(ImplicitlyCopyable):
    """
    Holds the configuration of a square wave function generator.
    """

    # Frequency of the square wave in Hertz.
    var frequency_hz: Float64
    # Sample rate in samples per second.
    var sample_rate_ss: Float64
    # Duration of the wave in seconds.
    var duration_s: Float64
    # Duty cycle percentage (0-100). Default is 50.
    var duty_cycle_perc: Float64
    # Amplitude scaling factor. Default is 1.0.
    var amplitude: Float64
    # Phase offset in radians. Default is 0.0.
    var phase_rad: Float64
    # DC offset (vertical shift). Default is 0.0.
    var offset: Float64

    fn get_angular_frequency(self) -> Float64:
        return 2.0 * pi * self.frequency_hz / self.sample_rate_ss

    fn get_number_of_samples(self) -> Int:
        return Int(self.sample_rate_ss * self.duration_s)


################
# Wave Structs #
################


@fieldwise_init
struct SineWave:
    """A struct to calculate sin waves with SIMD."""

    var samples: UnsafePointer[Float64, MutExternalOrigin]
    var wave_config: WaveConfig

    @always_inline
    fn generate[width: Int](self, i: Int):
        var indices: SIMD[DType.float64, width] = iota[
            DType.float64, width
        ]() + Float64(i)
        # Calculate the value as := A*sin(indices*omega + phi) + DC
        var values = (
            self.wave_config.amplitude
            * sin(
                indices * self.wave_config.get_angular_frequency()
                + self.wave_config.phase_rad
            )
            + self.wave_config.offset
        )
        self.samples.store(i, values)


@fieldwise_init
struct SquareWave:
    """A struct to calculate square waves with SIMD."""

    var samples: UnsafePointer[Float64, MutExternalOrigin]
    var config: SquareWaveConfig

    @always_inline
    fn generate[width: Int](self, i: Int):
        # Prepare the indices vector.
        var indices: SIMD[DType.float64, width] = iota[
            DType.float64, width
        ]() + Float64(i)

        # Calculate the angle first, and normalize it to [0, 2pi)
        var angle = (
            indices * self.config.get_angular_frequency()
            + self.config.phase_rad
        )
        var two_pi = SIMD[DType.float64, width](2.0 * pi)
        var normalized = angle % two_pi

        # Set a threshold for duty-cycle calculations and prepare a mask vector.
        var threshold = (
            SIMD[DType.float64, width](self.config.duty_cycle_perc / 100.0)
            * two_pi
        )
        var mask = normalized.lt(threshold)

        # Apply the mask with True encodes as 1.0 and False as -1.0.
        var square_vals = mask.select(1.0, -1.0)

        # Calculate the values.
        var values = self.config.amplitude * square_vals + self.config.offset
        self.samples.store(i, values)


########################
# Function Generators  #
########################


def generate_sine_wave_raw(
    wave_config: WaveConfig,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a sine wave using SIMD instructions.

    Params:
      wave_config: A WaveConfig struct that holds signal parameters.

    Returns:
      An array of int(sample_rate * duration) samples.
    """
    var num_samples: Int = wave_config.get_number_of_samples()

    var samples = alloc[Float64](num_samples)

    var wave = SineWave(samples, wave_config)

    comptime simd_width = 8

    var simd_end = Int(align_down(UInt(num_samples), UInt(simd_width)))
    for i in range(0, simd_end, simd_width):
        wave.generate[simd_width](i)

    for i in range(simd_end, num_samples):
        wave.generate[1](i)

    return samples


def generate_cosine_wave_raw(
    wave_config: WaveConfig,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a cosine wave using SIMD instructions.

    Cosine is just sine with a +π/2 phase shift: cos(ωt) = sin(ωt + π/2)

    Params:
      wave_config: A WaveConfig struct that holds signal parameters.
                   The phase_rad field will be offset by +π/2 internally.

    Returns:
      An array of int(sample_rate * duration) samples.
    """
    var cosine_config = WaveConfig(
        wave_config.frequency_hz,
        wave_config.amplitude,
        wave_config.phase_rad + pi / 2.0,
        wave_config.offset,
        wave_config.sample_rate_ss,
        wave_config.duration_s,
    )
    return generate_sine_wave_raw(cosine_config)


def generate_square_wave_raw(
    config: SquareWaveConfig,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a square wave using SIMD instructions.

    A square wave oscillates between +amplitude and -amplitude.

    Params:
      config: A SquareWaveConfig struct that holds signal parameters.

    Returns:
      An array of int(sample_rate * duration) samples.
    """
    var num_samples: Int = config.get_number_of_samples()

    var samples = alloc[Float64](num_samples)

    var wave = SquareWave(samples, config)

    comptime simd_width = 8

    var simd_end = Int(align_down(UInt(num_samples), UInt(simd_width)))
    for i in range(0, simd_end, simd_width):
        wave.generate[simd_width](i)

    for i in range(simd_end, num_samples):
        wave.generate[1](i)

    return samples


def generate_random_normal_noise_raw(
    sample_rate: Float64,
    duration: Float64,
    mean: Float64 = 0.0,
    std_dev: Float64 = 1.0,
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
    randn[DType.float64](
        samples, num_samples, mean=mean, standard_deviation=std_dev
    )
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
    var result: UnsafePointer[Float64, MutExternalOrigin] = alloc[Float64](
        num_samples
    )

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
