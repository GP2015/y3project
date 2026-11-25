#![no_std]

use core::{arch, ptr};
use num_traits::PrimInt;

pub const LED: MmioReg<u16> = MmioReg::new(0x1000_0000 as _);
pub const SWITCHES: MmioReg<u16> = MmioReg::new(0x1000_0004 as _);
pub const MIC_LVL: MmioReg<u16> = MmioReg::new(0x1000_0008 as _);
pub const MIC_RDY: MmioReg<u8> = MmioReg::new(0x1000_000C as _);

pub struct MmioReg<T> {
    ptr: *mut T,
}

impl<T: PrimInt> MmioReg<T> {
    pub const fn new(ptr: *mut T) -> Self {
        Self { ptr }
    }

    pub fn write(&self, val: T) {
        unsafe { ptr::write_volatile(self.ptr, val) }
    }

    pub fn write_bit(&self, bit: usize, state: bool) {
        let current_reg = unsafe { ptr::read_volatile(self.ptr) };

        let new_reg = if state {
            current_reg | (T::one() << bit)
        } else {
            current_reg & !(T::one() << bit)
        };

        unsafe { ptr::write_volatile(self.ptr, new_reg) }
    }

    #[must_use]
    pub fn read(&self) -> T {
        unsafe { ptr::read_volatile(self.ptr) }
    }

    #[must_use]
    pub fn read_bit(&self, bit: usize) -> bool {
        let reg = unsafe { ptr::read_volatile(self.ptr) };
        (reg >> bit) & T::one() == T::one()
    }
}

pub fn delay<const CYCLES: usize>() {
    unsafe {
        arch::asm!(
            "li {reg}, {cycles}",
            "2:",
            "addi {reg}, {reg}, -1",
            "bnez {reg}, 2b",
            cycles = const CYCLES,
            reg = out(reg) _,
            options(nostack, nomem)
        );
    }
}
