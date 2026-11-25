#![no_std]
#![no_main]

use common::{LED, MIC_LVL, MIC_RDY};
use core::{hint, panic::PanicInfo};

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {
        hint::spin_loop();
    }
}

const BUFFER_SIZE: usize = 512;

#[unsafe(no_mangle)]
pub extern "C" fn _start() -> ! {
    let mut buffer = [0; BUFFER_SIZE];
    let mut index = 0;

    loop {
        if MIC_RDY.read() > 0 {
            let mic_read = (MIC_LVL.read() as i32) - 128;
            buffer[index] = mic_read;
            index = (index + 1) % BUFFER_SIZE;

            if index == 0 {
                let mut zero_crossings = 0;
                let mut sign = 1;

                for item in buffer {
                    if item.signum() != 0 && item.signum() != sign {
                        zero_crossings += 1;
                        sign *= -1;
                    }
                }

                let lights_on = 1 + (zero_crossings * 16 / BUFFER_SIZE);
                let light_arr = (1 << lights_on) - 1;
                LED.write(light_arr);
            }
        }
    }
}
