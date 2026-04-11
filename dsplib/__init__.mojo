from .core import Complex
from .utils import (
    is_power_of_2,
    next_power_of_2,
    pad_to_power_of_2,
    reverse_bits,
    bit_reverse_array,
    sign,
    generate_time_array,
    calculate_power,
    calculate_snr,
    calculate_noise_std_for_snr,
    add_noise_at_snr,
    allocate_buffer,
)
from .waves import (
    WaveConfig,
    SawtoothWaveConfig,
    TriangleWaveConfig,
    SquareWaveConfig,
    generate_sine_wave_raw,
    generate_cosine_wave_raw,
    generate_sawtooth_wave_raw,
    generate_triangle_wave_raw,
    generate_square_wave_raw,
    generate_random_normal_noise_raw,
    generate_random_uniform_noise_raw,
    add_waves,
)
from .fourier import (
    compute_dft_raw,
    compute_idft_raw,
    compute_fft_recursive,
    compute_magnitude_spectrum,
    compute_phase_spectrum,
    compute_power_spectrum,
    compute_spectral_energy,
    compute_time_domain_energy,
)
from .plotting import (
    plot_wave,
    plot_frequency_domain,
    plot_spectrum_db,
    plot_bode_magnitude,
    plot_bode_phase,
    plot_bode,
    plot_bode_combined,
    compute_bode_response,
    plot_unit_circle,
    plot_complex_points,
)
from .audio import write_wav, write_wav_mono, write_wav_stereo
from .windows import (
    generate_rectangular_window,
    generate_hann_window,
    generate_hamming_window,
    generate_blackman_window,
    generate_cosine_window,
    apply_window,
)
from .filters import freqz
