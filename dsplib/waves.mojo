"""
Waveform Generation Module

This module generates common waveforms used in signal processing and audio synthesis.
Each waveform has distinct mathematical properties and frequency characteristics.

Wave Types:
    - Sine: Pure single frequency, no harmonics
    - Cosine: Sine shifted by 90 degrees (phase = π/2)
    - Sawtooth: Rich in harmonics, rises linearly
    - Triangle: Softer harmonics than sawtooth
    - Square: Contains only odd harmonics

The fundamental equation for all periodic waves is:
    x(t) = A * f(2πft + φ) + DC

Where:
    A = amplitude (loudness)
    f = frequency (pitch in Hz)
    t = time
    φ = phase offset (shift in time)
    DC = direct current offset (vertical shift)
"""

from std.math import sin, abs, pi, iota, align_down
from std.memory import alloc
from std.random import rand, randn
from .utils import sign


# ============================================================================
# Wave Configuration Structs
# ============================================================================
# These structs hold the parameters for wave generation. They separate
# configuration from computation, making code cleaner and more reusable.


@fieldwise_init
struct WaveConfig(ImplicitlyCopyable):
    """
    Holds the configuration for sine and cosine wave generators.

    The sine wave is the most fundamental waveform in signal processing.
    It represents pure, single-frequency oscillation with no harmonics.

    Mathematical Form:
        x[n] = A * sin(2πf n / fs + φ) + DC

    Where:
        n = sample index (0, 1, 2, ...)
        A = amplitude (peak value)
        f = frequency in Hz
        fs = sample rate in samples/second
        φ = phase in radians
        DC = DC offset

    Example:
        config = WaveConfig(
            frequency_hz=440.0,      # A4 note
            amplitude=0.5,            # Half amplitude
            phase_rad=0.0,           # Start at zero
            offset=0.0,              # No vertical shift
            sample_rate_ss=44100.0,   # CD quality
            duration_s=1.0,           # 1 second
        )
    """

    var frequency_hz: Float64
    var amplitude: Float64
    var phase_rad: Float64
    var offset: Float64
    var sample_rate_ss: Float64
    var duration_s: Float64

    def get_angular_frequency(self) -> Float64:
        """
        Converts frequency in Hz to angular frequency in radians/sample.

        Angular frequency ω relates to regular frequency f by:
            ω = 2πf / fs

        This is the rate of rotation in the unit circle per sample.
        One complete cycle (2π radians) = one period of the wave.
        """
        return 2.0 * pi * self.frequency_hz / self.sample_rate_ss

    def get_number_of_samples(self) -> Int:
        """Calculates how many samples we need based on duration and sample rate.
        """
        return Int(self.sample_rate_ss * self.duration_s)


@fieldwise_init
struct SawtoothWaveConfig(ImplicitlyCopyable):
    """
    Holds the configuration for sawtooth wave generation.

    A sawtooth wave rises linearly from 0 to 2π, then instantly drops to 0.
    It looks like a saw blade, hence the name.

    Mathematical Form:
        x[n] = 2 * (angle mod 2π) / 2π - 1

    Frequency Content:
        The sawtooth wave contains ALL harmonics (both even and odd):
        x(t) = (2A/π) * (sin(ωt) + sin(2ωt)/2 + sin(3ωt)/3 + ...)

        This rich harmonic content makes it useful for:
        - Synthesizing brass-like sounds
        - Subharmonics and overtone studies
        - Testing amplifier linearity (it has sharp transitions)

    The large number of harmonics means:
        - Rich, buzzy timbre
        - Can sound harsh at high frequencies
        - Excellent for additive synthesis
    """

    var frequency_hz: Float64
    var amplitude: Float64
    var phase_rad: Float64
    var offset: Float64
    var sample_rate_ss: Float64
    var duration_s: Float64

    fn get_angular_frequency(self) -> Float64:
        return 2.0 * pi * self.frequency_hz / self.sample_rate_ss

    fn get_number_of_samples(self) -> Int:
        return Int(self.sample_rate_ss * self.duration_s)


@fieldwise_init
struct TriangleWaveConfig(ImplicitlyCopyable):
    """
    Holds the configuration for triangle wave generation.

    A triangle wave rises and falls linearly, forming a triangular shape.
    It sounds softer than sawtooth due to its harmonic content.

    Mathematical Form:
        x[n] = 2 * |(angle mod 2π) / π - 1| - 1

    Frequency Content:
        The triangle wave contains ONLY ODD harmonics, like square wave,
        but they decay much faster (1/n² instead of 1/n):

        x(t) = (8A/π²) * (sin(ωt) - sin(3ωt)/9 + sin(5ωt)/25 - ...)

        Compared to square wave:
        - Triangle: 1st harmonic = 1.0, 3rd = 0.111, 5th = 0.040
        - Square:   1st harmonic = 1.0, 3rd = 0.333, 5th = 0.200

    The faster harmonic decay gives triangle:
        - Softer, mellower timbre
        - Less harsh than sawtooth or square
        - Useful for flute-like or woodwind-like sounds
    """

    var frequency_hz: Float64
    var amplitude: Float64
    var phase_rad: Float64
    var offset: Float64
    var sample_rate_ss: Float64
    var duration_s: Float64

    fn get_angular_frequency(self) -> Float64:
        return 2.0 * pi * self.frequency_hz / self.sample_rate_ss

    fn get_number_of_samples(self) -> Int:
        return Int(self.sample_rate_ss * self.duration_s)


@fieldwise_init
struct SquareWaveConfig(ImplicitlyCopyable):
    """
    Holds the configuration for square wave generation.

    A square wave oscillates between +A and -A, spending equal time at each.
    Named for its square shape when plotted.

    Mathematical Form:
        x[n] = +A if (angle mod 2π) < π
        x[n] = -A if (angle mod 2π) >= π

    Frequency Content:
        The square wave contains ONLY ODD harmonics:
        x(t) = (4A/π) * (sin(ωt) + sin(3ωt)/3 + sin(5ωt)/5 + ...)

        The harmonics decay as 1/n, so we have:
        - Strong fundamental
        - Significant 3rd harmonic (33% of fundamental)
        - Still noticeable 5th harmonic (20% of fundamental)

    This harmonic structure gives square waves:
        - Hollow, clarinet-like timbre
        - Bytebeat and chiptune aesthetics
        - Classic synthesizer sound

    Duty Cycle:
        By changing the duty cycle (default 50%), we can create:
        - 25%: More nasal sound, different harmonic balance
        - 75%: Similar effect in opposite direction
        - This creates "pulse waves" used in synthesizers
    """

    var frequency_hz: Float64
    var sample_rate_ss: Float64
    var duration_s: Float64
    var duty_cycle_perc: Float64
    var amplitude: Float64
    var phase_rad: Float64
    var offset: Float64

    fn get_angular_frequency(self) -> Float64:
        return 2.0 * pi * self.frequency_hz / self.sample_rate_ss

    fn get_number_of_samples(self) -> Int:
        return Int(self.sample_rate_ss * self.duration_s)


# ============================================================================
# Wave Generation Structs (SIMD-Accelerated)
# ============================================================================
# These structs use SIMD (Single Instruction Multiple Data) to generate
# multiple samples per CPU cycle. This provides significant speedup for
# audio processing and real-time applications.
#
# SIMD works by processing 8 samples simultaneously (with Float64 width 8),
# effectively doing 8x the work in the same time.


@fieldwise_init
struct SineWave:
    """
    Generates sine wave samples using SIMD for parallel processing.

    The sine wave is the foundation of all periodic waveforms.
    It traces a perfect circle when plotted against time.

    Why Sine?
        - Single frequency component (no harmonics)
        - Occurs naturally in springs, pendulums, AC circuits
        - Mathematically simple: sin(θ) = opposite/hypotenuse on unit circle

    The SIMD approach:
        1. Create index vector [i, i+1, i+2, ..., i+7]
        2. Compute all 8 sin values simultaneously
        3. Store all 8 results in one operation
    """

    var samples: UnsafePointer[Float64, MutExternalOrigin]
    var wave_config: WaveConfig

    @always_inline
    fn generate[width: Int](self, i: Int):
        # Create consecutive indices: [i, i+1, i+2, ..., i+width-1]
        # iota() generates [0, 1, 2, ..., width-1]
        # Adding i shifts to start at position i
        var indices: SIMD[DType.float64, width] = iota[
            DType.float64, width
        ]() + Float64(i)

        # Calculate x[n] = A * sin(ωn + φ) + DC
        # where ω = angular frequency (radians per sample)
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
struct SawtoothWave:
    """
    Generates sawtooth wave samples using SIMD.

    The sawtooth wave is created by taking the angle and wrapping it
    into [0, 2π) range using modulo, then normalizing.

    Algorithm:
        1. Compute angle = ωn + φ
        2. Wrap: angle' = angle mod 2π  (gives [0, 2π))
        3. Normalize: value = angle' / π - 1  (maps [0, 2π) to [-1, 1])
        4. Scale: value = A * value + DC
    """

    var samples: UnsafePointer[Float64, MutExternalOrigin]
    var config: SawtoothWaveConfig

    @always_inline
    fn generate[width: Int](self, i: Int):
        # Step 1: Create index vector
        var indices: SIMD[DType.float64, width] = iota[
            DType.float64, width
        ]() + Float64(i)

        # Step 2: Calculate angle
        var angle = (
            indices * self.config.get_angular_frequency()
            + self.config.phase_rad
        )

        # Pre-compute constants as SIMD vectors for efficiency
        var two_pi = SIMD[DType.float64, width](2.0 * pi)
        var one_pi = SIMD[DType.float64, width](pi)

        # Step 3: Wrap angle to [0, 2π), then normalize to [-1, 1]
        # angle % two_pi  →  [0, 2π)
        # ... / one_pi    →  [0, 2)
        # ... - 1.0       →  [-1, 1)
        var sawtooth = (angle % two_pi) / one_pi - SIMD[DType.float64, width](
            1.0
        )

        # Step 4: Scale by amplitude and add offset
        var values = self.config.amplitude * sawtooth + self.config.offset
        self.samples.store(i, values)


@fieldwise_init
struct TriangleWave:
    """
    Generates triangle wave samples using SIMD.

    The triangle wave is derived from the sawtooth wave using the formula:
        triangle = 2 * |sawtooth - 1| - 1

    Step-by-step transformation (for sawtooth value in [-1, 1]):
        sawtooth    →  [0, 2)     (add 1)
        shifted     →  [-1, 1)    (subtract 1)
        |shifted|   →  [0, 1]     (absolute value - folds the wave)
        * 2 - 1    →  [-1, 1]    (scale and shift back)

    Why This Works:
        The absolute value folds the linear ramp:
        - Rising edge (0 to 1): |0 to 1| = 0 to 1  ✓
        - Falling edge (-1 to 0): |-1 to 0| = 1 to 0  ✓

    Result: Triangle shape instead of sawtooth!
    """

    var samples: UnsafePointer[Float64, MutExternalOrigin]
    var config: TriangleWaveConfig

    @always_inline
    fn generate[width: Int](self, i: Int):
        var indices: SIMD[DType.float64, width] = iota[
            DType.float64, width
        ]() + Float64(i)
        var angle = (
            indices * self.config.get_angular_frequency()
            + self.config.phase_rad
        )

        var two_pi = SIMD[DType.float64, width](2.0 * pi)
        var one_pi = SIMD[DType.float64, width](pi)

        # Create sawtooth in [0, 2) range
        var sawtooth = (angle % two_pi) / one_pi

        # Transform: sawtooth → shifted → absolute → triangle
        # sawtooth:    [0, 2)
        # shifted:     [-1, 1)
        # |shifted|:   [0, 1]
        # triangle:    [-1, 1]
        var shifted = sawtooth - SIMD[DType.float64, width](1.0)
        var triangle = abs(shifted) * 2.0 - SIMD[DType.float64, width](1.0)

        var values = self.config.amplitude * triangle + self.config.offset
        self.samples.store(i, values)


@fieldwise_init
struct SquareWave:
    """
    Generates square wave samples using SIMD.

    The square wave uses SIMD masking to create the on/off pattern:
        - If angle < duty_cycle_threshold: output = +1
        - Otherwise: output = -1

    SIMD Masking:
        mask.lt(threshold) returns a SIMD vector of booleans
        mask.select(a, b) picks a where True, b where False

    This is highly efficient because:
        1. Compare all 8 samples to threshold (one operation)
        2. Select values based on mask (one operation)
        3. Store all 8 results (one operation)

    The duty cycle controls the ratio of positive to negative time:
        - 50%: Equal time at +1 and -1 (symmetric square wave)
        - < 50%: More time at -1 (narrower positive pulse)
        - > 50%: More time at +1 (wider positive pulse)
    """

    var samples: UnsafePointer[Float64, MutExternalOrigin]
    var config: SquareWaveConfig

    @always_inline
    fn generate[width: Int](self, i: Int):
        var indices: SIMD[DType.float64, width] = iota[
            DType.float64, width
        ]() + Float64(i)

        # Calculate angle and wrap to [0, 2π)
        var angle = (
            indices * self.config.get_angular_frequency()
            + self.config.phase_rad
        )
        var two_pi = SIMD[DType.float64, width](2.0 * pi)
        var normalized = angle % two_pi

        # Calculate threshold based on duty cycle
        # duty_cycle_perc / 100.0 converts percentage to [0, 1]
        # * 2π converts to radians threshold
        var threshold = (
            SIMD[DType.float64, width](self.config.duty_cycle_perc / 100.0)
            * two_pi
        )

        # Create mask: True where angle < threshold
        var mask = normalized.lt(threshold)

        # Select +1 where True, -1 where False
        var square_vals = mask.select(1.0, -1.0)

        # Scale and offset
        var values = self.config.amplitude * square_vals + self.config.offset
        self.samples.store(i, values)


# ============================================================================
# Wave Generation Functions
# ============================================================================
# These are the public API functions that allocate memory and generate waves.
# They handle SIMD processing internally for performance.


def generate_sine_wave_raw(
    wave_config: WaveConfig,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a sine wave.

    The sine wave is the most fundamental waveform. It has:
        - A single frequency component (no harmonics)
        - Perfect symmetry
        - Smooth, continuous derivative

    Mathematical Definition:
        x[n] = A * sin(2πfn/fs + φ) + DC

    Parameters:
        wave_config: Configuration struct containing:
            - frequency_hz: Frequency in Hz (e.g., 440 for A4)
            - amplitude: Peak amplitude (e.g., 1.0 for full scale)
            - phase_rad: Phase offset in radians (e.g., 0, π/2)
            - offset: DC offset (usually 0)
            - sample_rate_ss: Samples per second (e.g., 44100)
            - duration_s: Duration in seconds

    Returns:
        Pointer to array of samples. Caller must free with .free().

    Example:
        config = WaveConfig(frequency_hz=440.0, amplitude=1.0, ...)
        samples = generate_sine_wave_raw(config)
        # Use samples...
        samples.free()
    """
    var num_samples: Int = wave_config.get_number_of_samples()
    var samples = alloc[Float64](num_samples)

    var wave = SineWave(samples, wave_config)

    # Process 8 samples at a time with SIMD, then handle remainder
    comptime simd_width = 8
    var simd_end = Int(align_down(UInt(num_samples), UInt(simd_width)))
    for i in range(0, simd_end, simd_width):
        wave.generate[simd_width](i)

    # Handle remaining samples (less than SIMD width)
    for i in range(simd_end, num_samples):
        wave.generate[1](i)

    return samples


def generate_cosine_wave_raw(
    wave_config: WaveConfig,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a cosine wave.

    The cosine wave is identical to sine wave but shifted by 90° (π/2 radians).
    This relationship is fundamental:

        cos(θ) = sin(θ + π/2)
        sin(θ) = cos(θ - π/2)

    Why Cosine Matters:
        - Cosine waves have peak at n=0 (t=0)
        - Sine waves have zero crossing at n=0 (t=0)
        - This is important for phase relationships

    Phase Relationships:
        - 0° (0 rad):   sine
        - 90° (π/2):    cosine
        - 180° (π):     negative sine
        - 270° (3π/2):  negative cosine

    Note: This function reuses sine wave generation by shifting phase.
    """
    # Shift phase by π/2 to convert sine to cosine
    var cosine_config = WaveConfig(
        wave_config.frequency_hz,
        wave_config.amplitude,
        wave_config.phase_rad + pi / 2.0,  # This makes sin → cos
        wave_config.offset,
        wave_config.sample_rate_ss,
        wave_config.duration_s,
    )
    return generate_sine_wave_raw(cosine_config)


def generate_sawtooth_wave_raw(
    config: SawtoothWaveConfig,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a sawtooth wave.

    The sawtooth wave is named for its visual resemblance to saw teeth.
    It rises linearly from -A to +A, then drops sharply and repeats.

    Audio Characteristics:
        - Bright, buzzy timbre
        - Rich in harmonics
        - Common in synthesizers (VCOs - voltage controlled oscillators)

    Aliasing Warning:
        Due to its sharp transitions, sawtooth waves alias more easily
        than sine waves at high frequencies. Keep fundamental below
        fs/10 for clean reproduction.
    """
    var num_samples: Int = config.get_number_of_samples()
    var samples = alloc[Float64](num_samples)

    var wave = SawtoothWave(samples, config)

    comptime simd_width = 8
    var simd_end = Int(align_down(UInt(num_samples), UInt(simd_width)))
    for i in range(0, simd_end, simd_width):
        wave.generate[simd_width](i)

    for i in range(simd_end, num_samples):
        wave.generate[1](i)

    return samples


def generate_triangle_wave_raw(
    config: TriangleWaveConfig,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a triangle wave.

    The triangle wave has a linear rise and fall, creating a triangular shape.
    It sounds softer than sawtooth or square waves.

    Audio Characteristics:
        - Soft, mellow timbre
        - Fewer harmonics than sawtooth/square
        - Good for flute-like or soft synth sounds

    Mathematical Relationship:
        Triangle wave can be created from sawtooth by:
        1. Take sawtooth output
        2. Apply absolute value
        3. Scale and shift

        Or from sine by integration:
        triangle = integral(sin) = -cos

    This is why triangle waves have fewer harmonics - integration
    naturally attenuates high frequencies.
    """
    var num_samples: Int = config.get_number_of_samples()
    var samples = alloc[Float64](num_samples)

    var wave = TriangleWave(samples, config)

    comptime simd_width = 8
    var simd_end = Int(align_down(UInt(num_samples), UInt(simd_width)))
    for i in range(0, simd_end, simd_width):
        wave.generate[simd_width](i)

    for i in range(simd_end, num_samples):
        wave.generate[1](i)

    return samples


def generate_square_wave_raw(
    config: SquareWaveConfig,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates a square wave.

    The square wave is a pulse wave with 50% duty cycle (equal high/low time).
    It has a hollow, clarinet-like timbre due to its odd harmonic structure.

    Audio Characteristics:
        - Hollow, woody timbre
        - Contains only odd harmonics
        - Classic synthesizer sound

    Duty Cycle Variations:
        - 25%: Narrower positive pulse, nasal sound
        - 50%: Classic symmetric square wave
        - 75%: Wider positive pulse, different harmonic balance

    The duty cycle dramatically affects the harmonic content and
    perceived brightness of the sound.
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


# ============================================================================
# Noise Generation
# ============================================================================


def generate_random_normal_noise_raw(
    sample_rate: Float64,
    duration: Float64,
    mean: Float64 = 0.0,
    std_dev: Float64 = 1.0,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Generates Gaussian (normal) distributed white noise.

    White noise contains all frequencies at equal power (like white light).
    The samples follow a Gaussian (bell curve) distribution.

    Mathematical Definition:
        Each sample x[n] ~ N(μ, σ²) where:
        - μ (mean) = average value
        - σ² (variance) = spread of values

    Parameters:
        sample_rate: Samples per second (e.g., 44100)
        duration: Duration in seconds
        mean: Average value (usually 0 for audio)
        std_dev: Standard deviation (controls amplitude spread)

    Statistical Properties:
        - 68% of samples within ±1σ
        - 95% of samples within ±2σ
        - 99.7% of samples within ±3σ

    Uses:
        - Audio testing and measurement
        - Adding controlled noise to signals
        - Simulating thermal/electronic noise
        - Stochastic processes
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
    Generates uniformly distributed white noise.

    Unlike normal noise, each value is equally likely within the range.
    All frequencies still have equal power (white noise property).

    Mathematical Definition:
        Each sample x[n] ~ U(-A, A) where:
        - U = uniform distribution
        - A = amplitude (samples in [-A, A])

    Difference from Normal Noise:
        - Uniform: All values equally likely (flat histogram)
        - Normal: Values near mean more likely (bell curve)

    Uses:
        - Simple noise generation
        - Testing signal processing systems
        - Dithering in audio
    """
    var num_samples = Int(sample_rate * duration)
    var samples = alloc[Float64](num_samples)
    rand[DType.float64](samples, num_samples, min=-amplitude, max=amplitude)
    return samples


# ============================================================================
# Wave Operations
# ============================================================================


def add_waves(
    a: UnsafePointer[Float64, MutExternalOrigin],
    b: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
) -> UnsafePointer[Float64, MutExternalOrigin]:
    """
    Adds two waves element-wise.

    This is the principle of superposition in action:
        y[n] = a[n] + b[n]

    Physical Meaning:
        When two sound waves meet in the air, their amplitudes add.
        This is why chords contain multiple notes playing together.

    Important Notes:
        - Amplitude can exceed ±1.0 (clipping may occur)
        - No automatic normalization is applied
        - Both waves must have at least num_samples elements

    Superposition in Signal Processing:
        Linear systems obey superposition:
        - Additivity: L{x + y} = L{x} + L{y}
        - Homogeneity: L{ax} = aL{x}

    This is fundamental to:
        - Mixing audio
        - Creating chords
        - Combining signals
    """
    var result = alloc[Float64](num_samples)

    # SIMD-accelerated addition
    comptime simd_width = 8
    var simd_end = Int(align_down(UInt(num_samples), UInt(simd_width)))
    for i in range(0, simd_end, simd_width):
        var va = a.load[width=simd_width](i)
        var vb = b.load[width=simd_width](i)
        var vr = va + vb
        result.store(i, vr)

    # Handle remaining samples
    for i in range(simd_end, num_samples):
        result[i] = a[i] + b[i]

    return result
