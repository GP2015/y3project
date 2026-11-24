#![no_std]
#![no_main]

use core::{hint, panic::PanicInfo, ptr};
use num_traits::PrimInt;

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {
        hint::spin_loop();
    }
}

struct MmioReg<T> {
    ptr: *mut T,
}

impl<T: PrimInt> MmioReg<T> {
    pub fn new(ptr: *mut T) -> Self {
        Self { ptr }
    }

    pub fn write(&mut self, val: T) {
        unsafe { ptr::write_volatile(self.ptr, val) }
    }

    pub fn write_bit(&mut self, bit: usize, state: bool) {
        let current_reg = unsafe { ptr::read_volatile(self.ptr) };

        let new_reg = if state {
            current_reg | (T::one() << bit)
        } else {
            current_reg & !(T::one() << bit)
        };

        unsafe { ptr::write_volatile(self.ptr, new_reg) }
    }

    pub fn read(&self) -> T {
        unsafe { ptr::read_volatile(self.ptr) }
    }

    pub fn read_bit(&self, bit: usize) -> bool {
        let reg = unsafe { ptr::read_volatile(self.ptr) };
        (reg >> bit.into()) & T::one() == T::one()
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn _start() -> ! {
    let mut leds = MmioReg::new(0x1000_0000 as *mut u16);
    let mic = MmioReg::new(0x1000_0200 as *mut i32);

    loop {
        let mic_read = mic.read();

        let lights_lit = (mic_read + 128) as usize * 15 / 256;

        let led_out = if lights_lit >= 15 {
            0xFFFF
        } else {
            (1u32 << (lights_lit + 1)) - 1
        };

        leds.write(led_out as u16);
    }
}
