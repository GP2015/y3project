#![no_std]
#![no_main]

use core::{arch, hint, panic::PanicInfo, ptr};

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {
        hint::spin_loop();
    }
}

const LED_REG: *mut u32 = 0x1000_0000 as *mut u32;

fn write_led_reg(value: u32) {
    unsafe { ptr::write_volatile(LED_REG, value) }
}

fn read_led_reg() -> u32 {
    unsafe { ptr::read_volatile(LED_REG) }
}

fn delay<const CYCLES: usize>() {
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

#[unsafe(no_mangle)]
pub extern "C" fn _start() -> ! {
    write_led_reg(0);
    let mut led_value = 0u32;

    loop {
        delay::<1_000_000>();
        led_value += 1;
        write_led_reg(led_value);
    }
}
