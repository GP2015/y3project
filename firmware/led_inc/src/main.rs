#![no_std]
#![no_main]

use common::LED;
use core::{hint, panic::PanicInfo};

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {
        hint::spin_loop();
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn _start() -> ! {
    LED.write(0);
    let mut led_value = 0;

    loop {
        common::delay::<1_000_000>();
        led_value += 1;
        LED.write(led_value);
    }
}
