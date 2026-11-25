#![no_std]
#![no_main]

use common::{LED, SWITCHES};
use core::{hint, panic::PanicInfo};

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {
        hint::spin_loop();
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn _start() -> ! {
    loop {
        LED.write(SWITCHES.read());
    }
}
