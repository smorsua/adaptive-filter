import numpy as np
import matplotlib.pyplot as plt
import cocotb
from cocotb.binary import BinaryValue
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from fixedpoint import FixedPoint
from threading import Event

def filter_synthesis_input(f, a, ph, c, fs, ns):
    t = np.linspace(0, 1/fs*ns, ns)
    
    input_wave = np.zeros(len(t))
    desired_wave = np.zeros(len(t))
    
    for (freq, amp, phase, coeff) in zip(f,a,ph,c):
        input_wave_local = coeff*np.sin(2*np.pi*freq*t)
        input_wave = np.add(input_wave, input_wave_local)
        
        desired_wave_local = amp*coeff*np.sin(2*np.pi*freq*t+phase)
        desired_wave = np.add(desired_wave, desired_wave_local)
    
    return (input_wave, desired_wave)


async def generate_clock(dut, e_done):
    while e_done.is_set() == False:
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

async def drive_input(dut, x_input, x_desired, e_done):
    for (x_in, x_des) in zip(x_input, x_desired):
        await RisingEdge(dut.clk)
        dut.i_din.value = x_in
        dut.i_desired.value = x_des
        
    e_done.set()

async def monitor_weights(dut, num, e_done):
    weights = []
    i = 0
    while e_done.is_set() == False:
        await RisingEdge(dut.clk)
        curr_weights = dut.o_weights.value
        # print(f"i={i} curr_weights={curr_weights} signal={dut.next_weights.value}")
        i += 1
        weights.append(curr_weights)
        
@cocotb.test()
async def filter_synthesis_test(dut):
    (x_input, x_desired) = filter_synthesis_input([1e3], [1], [np.pi], [1], 44.1e3, 1000)
    
    # fig, ax = plt.subplots()
    # ax.plot(x_input)
    # ax.plot(x_desired)
    # plt.show()
    
    width = 32
    frac = 20
    
    x_input_fp = [FixedPoint(val, signed=True, m=width-frac, n=frac, str_base=2) for val in x_input]
    x_desired_fp = [FixedPoint(val, signed=True, m=width-frac, n=frac, str_base=2) for val in x_desired]
    
    x_input_bin = [BinaryValue(str(val), width) for val in x_input_fp]
    x_desired_bin = [BinaryValue(str(val), width) for val in x_desired_fp]
    
    step_size = 0.2
    step_size_fp = FixedPoint(step_size, signed=True, m=width-frac, n=frac, str_base=2)
    
    step_size_bin = BinaryValue(str(step_size_fp), width)
    
    e_done = Event()
    await cocotb.start(generate_clock(dut, e_done))  # run the clock "in the background"
    
    print(dut.o_weights.value)
    
    await FallingEdge(dut.clk)
    dut.rstn.value = 0
    await FallingEdge(dut.clk)
    dut.rstn.value = 1
    
    
    print(dut.o_weights.value)
    await RisingEdge(dut.clk)
    print(dut.o_weights.value)
    
    
    
    dut.i_step_size.value = step_size_bin
    dut.i_ovr.value = 0
    
    
    await cocotb.start(drive_input(dut, x_input_bin, x_desired_bin, e_done))
    weights = await monitor_weights(dut, 1, e_done)
    print(weights)
    
import os
from pathlib import Path

from cocotb.runner import get_runner

def filter_synthesis_test_runner():
    sim = "icarus"

    # proj_path = Path(__file__).resolve().parent

    sources = [
        "C:\\Users\\SMoreno\\Desktop\\adaptive-filter\\design\\direct_fir.sv",
        "C:\\Users\\SMoreno\\Desktop\\adaptive-filter\\design\\fadd.sv",
        "C:\\Users\\SMoreno\\Desktop\\adaptive-filter\\design\\fmult.sv",
        "C:\\Users\\SMoreno\\Desktop\\adaptive-filter\\design\\fixed_point_converter.sv",
        "C:\\Users\\SMoreno\\Desktop\\adaptive-filter\\design\\lms.sv",
        "C:\\Users\\SMoreno\\Desktop\\adaptive-filter\\design\\tapped_delay_line.sv",
        "C:\\Users\\SMoreno\\Desktop\\adaptive-filter\\design\\transposed_fir.sv",
        "C:\\Users\\SMoreno\\Desktop\\adaptive-filter\\design\\adaptive_filter.sv",
    ]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="adaptive_filter",
        waves=True
        # timescale=("1ns", "1ps")
    )

    runner.test(hdl_toplevel="adaptive_filter", test_module="filter_synthesis_test")


if __name__ == "__main__":
    filter_synthesis_test_runner()    
   