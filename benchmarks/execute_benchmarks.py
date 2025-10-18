#!/usr/bin/env python3
"""
Direct execution tester for CRZ64I assembly benchmarks.
Executes instructions natively and validates outputs.
"""

import os
import time
import struct
import statistics
from typing import Dict, List, Tuple
import ctypes

class CPUState:
    def __init__(self):
        # General purpose registers
        self.regs = [0] * 32
        # Vector registers
        self.vregs = [bytearray(16) for _ in range(8)]  # 8 vector regs, 128-bit each
        # Result buffer (for benchmark outputs)
        self.result_buffer = bytearray(32)  # 8 words
        # Memory simulation
        self.memory = bytearray(1024 * 1024)  # 1MB memory
        
    def read_reg(self, reg: int) -> int:
        return self.regs[reg]
        
    def write_reg(self, reg: int, value: int):
        self.regs[reg] = value & 0xFFFFFFFF
        
    def read_mem(self, addr: int) -> int:
        return int.from_bytes(self.memory[addr:addr+4], 'little')
        
    def write_mem(self, addr: int, value: int):
        self.memory[addr:addr+4] = value.to_bytes(4, 'little')

class BenchmarkExecutor:
    def __init__(self):
        self.cpu = CPUState()
        self.results: Dict[str, List[Dict[str, int]]] = {}
        
    def rdtsc(self) -> int:
        """Hardware cycle counter simulation"""
        return int(time.perf_counter_ns() * 2.4)  # Simulated 2.4GHz
        
    def execute_instruction(self, instr: str, cpu: CPUState) -> None:
        """Execute a single CRZ64I instruction"""
        parts = instr.strip().split()
        op = parts[0]
        
        if op == 'LOAD':
            dst = int(parts[1][1:])
            if parts[2].startswith('#'):
                # Immediate value
                value = int(parts[2][1:], 0)
            else:
                # Memory load
                addr = cpu.read_reg(int(parts[2][1:-1]))
                value = cpu.read_mem(addr)
            cpu.write_reg(dst, value)
            
        elif op == 'ADD':
            dst = int(parts[1][1:])
            src1 = cpu.read_reg(int(parts[2][1:]))
            src2 = cpu.read_reg(int(parts[3][1:]))
            cpu.write_reg(dst, (src1 + src2) & 0xFFFFFFFF)
            
        elif op == 'SUB':
            dst = int(parts[1][1:])
            src1 = cpu.read_reg(int(parts[2][1:]))
            src2 = cpu.read_reg(int(parts[3][1:]))
            cpu.write_reg(dst, (src1 - src2) & 0xFFFFFFFF)
            
        elif op == 'STORE':
            if parts[1].startswith('[result+'):
                offset = int(parts[1][8:-1]) * 4
                if parts[2].startswith('#"'):
                    # Store string
                    value = parts[2][2:-1].encode()
                    cpu.result_buffer[offset:offset+len(value)] = value
                else:
                    # Store register value
                    value = cpu.read_reg(int(parts[2][1:]))
                    struct.pack_into('<I', cpu.result_buffer, offset, value)
            else:
                addr = cpu.read_reg(int(parts[1][1:-1]))
                value = cpu.read_reg(int(parts[2][1:]))
                cpu.write_mem(addr, value)
                
        elif op == 'RDT':
            dst = int(parts[1][1:])
            cpu.write_reg(dst, self.rdtsc())
            
        elif op == 'RTIME':
            dst = int(parts[1][1:])
            cpu.write_reg(dst, time.perf_counter_ns())
            
        # Add implementations for other instructions...
            
    def execute_benchmark(self, bench_file: str) -> Dict[str, int]:
        """Execute a single benchmark file and return results"""
        cpu = CPUState()
        
        with open(bench_file, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith(';'):
                    self.execute_instruction(line, cpu)
                    
        # Extract results
        op_name = cpu.result_buffer[0:8].decode().strip('\x00')
        cycles = struct.unpack('<I', cpu.result_buffer[4:8])[0]
        latency = struct.unpack('<I', cpu.result_buffer[8:12])[0]
        duration = struct.unpack('<I', cpu.result_buffer[12:16])[0]
        
        return {
            'op_name': op_name,
            'cycles': cycles,
            'latency_ns': latency,
            'duration_ns': duration
        }
        
    def validate_results(self, results: Dict[str, int]) -> List[str]:
        """Validate benchmark results for reasonableness"""
        errors = []
        
        # Check cycle count is reasonable (1-1000 cycles)
        if not 1 <= results['cycles'] <= 1000:
            errors.append(f"Unusual cycle count: {results['cycles']}")
            
        # Check latency calculation
        expected_latency = results['cycles'] / 2.4  # 2.4 GHz
        if abs(results['latency_ns'] - expected_latency) > expected_latency * 0.1:
            errors.append(f"Latency calculation error: expected ~{expected_latency:.2f}ns, got {results['latency_ns']}ns")
            
        # Check duration is reasonable (>= latency)
        if results['duration_ns'] < results['latency_ns']:
            errors.append(f"Duration ({results['duration_ns']}ns) less than latency ({results['latency_ns']}ns)")
            
        # Check duration variance
        if results['duration_ns'] > results['latency_ns'] * 10:
            errors.append(f"Duration ({results['duration_ns']}ns) much larger than expected")
            
        return errors

    def run_all_benchmarks(self):
        """Execute and validate all benchmarks"""
        print("Starting benchmark execution and validation")
        print("-" * 80)
        
        bench_dir = 'benchmarks'
        all_passed = True
        results_table = []
        
        for filename in sorted(os.listdir(bench_dir)):
            if not filename.endswith('.asm'):
                continue
                
            filepath = os.path.join(bench_dir, filename)
            print(f"\nExecuting {filename}...")
            
            try:
                # Run benchmark multiple times
                results = []
                for _ in range(5):
                    result = self.execute_benchmark(filepath)
                    results.append(result)
                    
                # Calculate averages
                avg_result = {
                    'op_name': results[0]['op_name'],
                    'cycles': int(statistics.mean(r['cycles'] for r in results)),
                    'latency_ns': int(statistics.mean(r['latency_ns'] for r in results)),
                    'duration_ns': int(statistics.mean(r['duration_ns'] for r in results))
                }
                
                # Validate results
                errors = self.validate_results(avg_result)
                
                if errors:
                    print("✗ FAIL")
                    for error in errors:
                        print(f"  - {error}")
                    all_passed = False
                else:
                    print("✓ PASS")
                    print(f"  Cycles: {avg_result['cycles']}")
                    print(f"  Latency: {avg_result['latency_ns']}ns")
                    print(f"  Duration: {avg_result['duration_ns']}ns")
                    
                results_table.append(avg_result)
                    
            except Exception as e:
                print(f"✗ ERROR: {str(e)}")
                all_passed = False
                
        # Print summary table
        print("\nBenchmark Results Summary:")
        print("-" * 80)
        print(f"{'Operation':<20} {'Cycles':<10} {'Latency(ns)':<12} {'Duration(ns)':<12}")
        print("-" * 80)
        
        for result in sorted(results_table, key=lambda x: x['cycles']):
            print(f"{result['op_name']:<20} {result['cycles']:<10} {result['latency_ns']:<12} {result['duration_ns']:<12}")
            
        print("\nValidation Summary:")
        print("-" * 80)
        if all_passed:
            print("✓ All benchmarks executed and validated successfully!")
        else:
            print("✗ Some benchmarks failed validation")

if __name__ == '__main__':
    executor = BenchmarkExecutor()
    executor.run_all_benchmarks()