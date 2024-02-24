import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import simps

# wavelength, x, y, z
cie_1931 = np.array([
    [380, 0.001368, 0.000039, 0.006450],
    [390, 0.004243, 0.000120, 0.020050],
    [400, 0.014310, 0.000396, 0.067850],
    [410, 0.043510, 0.001210, 0.207400],
    [420, 0.134380, 0.004000, 0.645600],
    [430, 0.283900, 0.011600, 1.385600],
    [440, 0.348280, 0.023000, 1.747060],
    [450, 0.336200, 0.038000, 1.772110],
    [460, 0.290800, 0.060000, 1.669200],
    [470, 0.195360, 0.090980, 1.287640],
    [480, 0.095640, 0.139020, 0.812950],
    [490, 0.032010, 0.208020, 0.465180],
    [500, 0.004900, 0.323000, 0.272000],
    [510, 0.009300, 0.503000, 0.158200],
    [520, 0.063270, 0.710000, 0.078250],
    [530, 0.165500, 0.862000, 0.042160],
    [540, 0.290400, 0.954000, 0.020300],
    [550, 0.433450, 0.994950, 0.008750],
    [560, 0.594500, 0.995000, 0.003900],
    [570, 0.762100, 0.952000, 0.002100],
    [580, 0.916300, 0.870000, 0.001650],
    [590, 1.026300, 0.757000, 0.001100],
    [600, 1.062200, 0.631000, 0.000800],
    [610, 1.002600, 0.503000, 0.000340],
    [620, 0.854450, 0.381000, 0.000190],
    [630, 0.642400, 0.265000, 0.000050],
    [640, 0.447900, 0.175000, 0.000020],
    [650, 0.283500, 0.107000, 0.000000],
    [660, 0.164900, 0.061000, 0.000000],
    [670, 0.087400, 0.032000, 0.000000],
    [680, 0.046770, 0.017000, 0.000000],
    [690, 0.022700, 0.008210, 0.000000],
    [700, 0.011359, 0.004102, 0.000000],
    [710, 0.005722, 0.002091, 0.000000],
    [720, 0.002855, 0.001047, 0.000000],
    [730, 0.001421, 0.000520, 0.000000],
    [740, 0.000706, 0.000249, 0.000000],
    [750, 0.000351, 0.000120, 0.000000],
    [760, 0.000175, 0.000060, 0.000000],
    [770, 0.000088, 0.000030, 0.000000],
    [780, 0.000044, 0.000015, 0.000000]
])

# Function to calculate spectral radiance using Planck's law
def planck(wavelength, temperature):
    # Constants
    h = 6.62607015e-34  # Planck's constant (m^2 kg / s)
    c = 299792458       # Speed of light in vacuum (m/s)
    k = 1.380649e-23    # Boltzmann constant (m^2 kg / (s^2 K))

    # Calculate spectral radiance
    wavelength_m = wavelength * 1e-9  # Convert wavelength from nm to meters
    numerator = 2 * h * c**2 / wavelength_m**5
    denominator = np.exp(h * c / (wavelength_m * k * temperature)) - 1
    return numerator / denominator

# Convert CIE XYZ to sRGB
def xyz_to_rgb(XYZ):
    # Conversion matrix from XYZ to linear RGB
    xyz_to_rgb_matrix = np.array([[3.2404542, -1.5371385, -0.4985314],
                                  [-0.9692660, 1.8760108, 0.0415560],
                                  [0.0556434, -0.2040259, 1.0572252]])

    # Apply the matrix transformation
    rgb_linear = np.dot(xyz_to_rgb_matrix, XYZ)

    return rgb_linear

def print_for_hlsl(arr):
    for sub_arr in arr:
        print("float3(", end="")
        for i, val in enumerate(sub_arr):
            val_float = float(val)
            if i < len(sub_arr) - 1:
                print(f"{val_float:.9}f, ", end="")
            else:
                print(f"{val_float:.9}f", end="")
        print("),")

# Generate wavelengths from 380nm to 780nm
wavelengths = np.linspace(380, 780, 128)  # Wavelengths from 380nm to 780nm

# Interpolate the color matching functions
x_interp = np.interp(wavelengths, cie_1931[:,0], cie_1931[:,1])
y_interp = np.interp(wavelengths, cie_1931[:,0], cie_1931[:,2])
z_interp = np.interp(wavelengths, cie_1931[:,0], cie_1931[:,3])

# Define temperatures (in Kelvin)
#temperatures = np.linspace(600, 1100, 64) # daily seen fire temperature range
temperatures = np.linspace(450, 8000, 64)

# Calculate spectral radiance for each temperature and convert to XYZ
XYZ_values = []
wavelengths_in_meter = wavelengths * 1e-9
for temperature in temperatures:
    spectral_radiance_data = planck(wavelengths, temperature)
    X = simps(spectral_radiance_data * x_interp, wavelengths_in_meter)
    Y = simps(spectral_radiance_data * y_interp, wavelengths_in_meter)
    Z = simps(spectral_radiance_data * z_interp, wavelengths_in_meter)
    XYZ_values.append((X, Y, Z))

# Convert XYZ to RGB
RGB_values = [xyz_to_rgb(XYZ) for XYZ in XYZ_values]

# Plot
bar_width = 0.2

r_positions = [i for i in range(len(temperatures))]
g_positions = [i + bar_width for i in range(len(temperatures))]
b_positions = [i + 2 * bar_width for i in range(len(temperatures))]

values_R = [rgb[0] for rgb in RGB_values]
plt.bar(r_positions, values_R, color='r', width=bar_width, label='R')
values_G = [rgb[1] for rgb in RGB_values]
plt.bar(g_positions, values_G, color='g', width=bar_width, label='G')
values_B = [rgb[2] for rgb in RGB_values]
plt.bar(b_positions, values_B, color='b', width=bar_width, label='B')

plt.xticks([i + bar_width for i in range(len(temperatures))], temperatures)

plt.xlabel('Temperature (K)')
plt.ylabel('Value')
plt.title('RGB Values at Different Temperatures')
plt.legend()

plt.savefig('black_body_radiation.png')

print_for_hlsl(RGB_values)
