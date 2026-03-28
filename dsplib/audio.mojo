from std.python import Python
from std.memory import alloc


fn write_wav(
    filename: String,
    sample_rate: Int,
    samples: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
) raises:
    """
    Writes audio samples to a WAV file (16-bit PCM).

    Params:
        filename: Path to save the WAV file.
        sample_rate: Sample rate in samples per second.
        samples: Pointer to the audio samples.
        num_samples: Number of samples.
    """
    var wavfile = Python.import_module("scipy.io.wavfile")
    var np = Python.import_module("numpy")

    var data_np = np.zeros(num_samples, dtype=np.float64)
    for i in range(num_samples):
        data_np[i] = samples[i]

    var int_data = (data_np * 32767.0).astype(np.int16)
    wavfile.write(filename, sample_rate, int_data)


fn write_wav_mono(
    filename: String,
    sample_rate: Int,
    samples: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
    bits_per_sample: Int = 16,
) raises:
    """
    Writes mono audio samples to a WAV file with specified bit depth.

    Params:
        filename: Path to save the WAV file.
        sample_rate: Sample rate in samples per second.
        samples: Pointer to the audio samples.
        num_samples: Number of samples.
        bits_per_sample: Bit depth (16 or 32). Default is 16.
    """
    var wavfile = Python.import_module("scipy.io.wavfile")
    var np = Python.import_module("numpy")

    var data_np = np.zeros(num_samples, dtype=np.float64)
    for i in range(num_samples):
        data_np[i] = samples[i]

    if bits_per_sample == 32:
        var int_data = (data_np * 2147483647.0).astype(np.int32)
        wavfile.write(filename, sample_rate, int_data)
    else:
        var int_data = (data_np * 32767.0).astype(np.int16)
        wavfile.write(filename, sample_rate, int_data)


fn write_wav_stereo(
    filename: String,
    sample_rate: Int,
    left: UnsafePointer[Float64, MutExternalOrigin],
    right: UnsafePointer[Float64, MutExternalOrigin],
    num_samples: Int,
) raises:
    """
    Writes stereo audio samples to a WAV file.

    Params:
        filename: Path to save the WAV file.
        sample_rate: Sample rate in samples per second.
        left: Pointer to left channel samples.
        right: Pointer to right channel samples.
        num_samples: Number of samples per channel.
    """
    var wavfile = Python.import_module("scipy.io.wavfile")
    var np = Python.import_module("numpy")

    var left_np = np.zeros(num_samples, dtype=np.float64)
    var right_np = np.zeros(num_samples, dtype=np.float64)

    for i in range(num_samples):
        left_np[i] = left[i]
        right_np[i] = right[i]

    # We have to use column_stack with 2 different NumPy arrays
    # since Mojo's Tuples cannot be converted to Python tuples.
    # This means that I cannot create a numpy array with (num_samples, 2)
    # size.
    var stereo_np = np.column_stack(left_np, right_np)
    var int_data = (stereo_np * 32767.0).astype(np.int16)
    wavfile.write(filename, sample_rate, int_data)
