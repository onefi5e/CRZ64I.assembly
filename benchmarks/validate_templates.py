#!/usr/bin/env python3
"""
Comprehensive validation for CRZ64I assembly benchmark templates.
Validates structure, output format, register usage, and timing measurements.
"""

import os
import re
import sys
from typing import List, Dict, Set

class BenchValidator:
    def __init__(self, bench_dir: str):
        self.bench_dir = bench_dir
        self.errors = []
        self.warnings = []
        
    def validate_file(self, filepath: str) -> bool:
        with open(filepath, 'r') as f:
            content = f.read()
        
        filename = os.path.basename(filepath)
        results = {
            'structure': self.check_structure(content, filename),
            'timing': self.check_timing_sequence(content, filename),
            'registers': self.check_register_usage(content, filename),
            'output': self.check_output_format(content, filename)
        }
        return all(results.values())

    def check_structure(self, content: str, filename: str) -> bool:
        required_sections = [
            '; BENCH_',
            '; op_NAME:',
            'RDT r10',
            'RTIME r20',
            'RDT r11',
            'RTIME r21',
            'SUB r12, r11, r10',
            'SUB r13, r21, r20',
            'STORE [result+'
        ]
        
        missing = [section for section in required_sections 
                  if section not in content]
        
        if missing:
            self.errors.append(f"{filename}: Missing required sections: {missing}")
            return False
        return True

    def check_timing_sequence(self, content: str, filename: str) -> bool:
        lines = content.split('\n')
        rdt_start = None
        rdt_end = None
        rtime_start = None
        rtime_end = None
        instruction_found = False
        
        for i, line in enumerate(lines):
            if 'RDT r10' in line:
                rdt_start = i
            elif 'RTIME r20' in line:
                rtime_start = i
            elif 'RDT r11' in line:
                rdt_end = i
            elif 'RTIME r21' in line:
                rtime_end = i
            elif not line.strip().startswith(';') and not line.strip().startswith('RDT') and not line.strip().startswith('RTIME') and not line.strip().startswith('SUB') and not line.strip().startswith('STORE') and line.strip():
                if rdt_start is not None and rtime_start is not None:
                    instruction_found = True

        if not all([rdt_start, rdt_end, rtime_start, rtime_end, instruction_found]):
            self.errors.append(f"{filename}: Invalid timing measurement sequence")
            return False
        
        if not (rdt_start < rtime_start < rdt_end < rtime_end):
            self.errors.append(f"{filename}: Incorrect order of timing measurements")
            return False
            
        return True

    def check_register_usage(self, content: str, filename: str) -> bool:
        lines = content.split('\n')
        used_registers = set()
        reserved_registers = {'r10', 'r11', 'r12', 'r13', 'r14', 'r30'}
        
        reg_pattern = r'r\d+'
        for line in lines:
            if line.strip().startswith(';'):
                continue
            regs = re.findall(reg_pattern, line)
            used_registers.update(regs)
        
        conflicts = reserved_registers & (used_registers - reserved_registers)
        if conflicts:
            self.errors.append(f"{filename}: Using reserved registers: {conflicts}")
            return False
            
        return True

    def check_output_format(self, content: str, filename: str) -> bool:
        required_outputs = [
            'STORE [result+0]',  # op_NAME
            'STORE [result+1]',  # cycles_per_op
            'STORE [result+2]',  # latency_ns
            'STORE [result+3]'   # duration_ns
        ]
        
        missing = [output for output in required_outputs 
                  if not any(line.strip().startswith(output) for line in content.split('\n'))]
        
        if missing:
            self.errors.append(f"{filename}: Missing required outputs: {missing}")
            return False
            
        return True

    def run_validation(self) -> bool:
        print(f"Starting validation of benchmark templates in {self.bench_dir}")
        print("-" * 80)
        
        all_passed = True
        for filename in sorted(os.listdir(self.bench_dir)):
            if not filename.endswith('.asm'):
                continue
                
            filepath = os.path.join(self.bench_dir, filename)
            print(f"Validating {filename}...", end=' ')
            
            if self.validate_file(filepath):
                print("✓ PASS")
            else:
                print("✗ FAIL")
                all_passed = False
        
        print("\nValidation Summary:")
        print("-" * 80)
        if self.errors:
            print("\nErrors:")
            for error in self.errors:
                print(f"  ✗ {error}")
        
        if self.warnings:
            print("\nWarnings:")
            for warning in self.warnings:
                print(f"  ! {warning}")
        
        if all_passed:
            print("\n✓ All templates passed validation!")
        else:
            print(f"\n✗ Found {len(self.errors)} errors and {len(self.warnings)} warnings")
            
        return all_passed

if __name__ == '__main__':
    bench_dir = 'benchmarks'
    validator = BenchValidator(bench_dir)
    success = validator.run_validation()
    sys.exit(0 if success else 1)