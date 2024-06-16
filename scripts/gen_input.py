import argparse
import numpy as np


parser = argparse.ArgumentParser(
    prog="gen_input",
    description="Script to generate input sine wave",
    
)
parser.add_argument("-b", "--bits", type=int, help="Fractional bits of fixed point representation", action="store", required=True)
parser.add_argument("-f", "--frequency", type=float, action="store", required=True)
parser.add_argument("-s", "--samples", type=int, action="store", required=True)
parser.add_argument("-fs", type=float, action="store", required=True)

args = parser.parse_args()

frac_bits = args.bits
max_range = 2**frac_bits - 1
freq = args.frequency
t = np.arange(0, (args.samples - 1) / args.fs, 1/args.fs)
x = np.sin(2*np.pi*freq*t)
x_quantized = np.floor(max_range * x)
np.savetxt("input.txt", x_quantized, "%d")