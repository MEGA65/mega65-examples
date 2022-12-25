//! C64 Plasma Example (80 x 25 mode for mega65)
//!
//! - (w)2001 by groepaz; sourced from the CC65 /samples/cbm directory
//! - Cleanup and porting to CC65 by Ullrich von Bassewitz.
//! - Porting to Rust by Mikael Lund aka Wombat (2022)

#![no_std]
#![feature(start)]
#![feature(default_alloc_error_handler)]

extern crate mos_hardware;
extern crate ufmt_stdio;

use core::panic::PanicInfo;
use mos_hardware::*;
use ufmt_stdio::*;

/// Generate stochastic character set
fn make_charset(charset_ptr: *mut u8) {
    let generate_char = |sine| {
        const BITS: [u8; 8] = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80];
        let mut char_pattern: u8 = 0;
        BITS.iter()
            .filter(|_| mega65::rand8(u8::MAX) > sine)
            .for_each(|bit| {
                char_pattern |= bit;
            });
        char_pattern
    };

    repeat_element(SINETABLE.iter().copied(), 8)
        .enumerate()
        .for_each(|(cnt, sine)| {
            let character = generate_char(sine);
            unsafe {
                poke!(charset_ptr.offset(cnt as isize), character);
            }
            if cnt % 64 == 0 {
                print!(".");
            }
        });
}

/// Render entire screen
/// @todo Rename to meaningful variable names (reminiscence from C)
fn render_plasma(screen_ptr: *mut u8) {
    static mut C1A: u8 = 0;
    static mut C1B: u8 = 0;
    static mut C2A: u8 = 0;
    static mut C2B: u8 = 0;
    static mut XBUF: [u8; 80] = [0; 80];
    static mut YBUF: [u8; 25] = [0; 25];
    unsafe {
        let mut c1a = C1A;
        let mut c1b = C1B;
        for y in YBUF.iter_mut() {
            *y = SINETABLE[c1a as usize].wrapping_add(SINETABLE[c1b as usize]);
            c1a = c1a.wrapping_add(4);
            c1b = c1b.wrapping_add(9);
        }
        C1A = C1A.wrapping_add(3);
        C1B = C1B.wrapping_sub(5);

        let mut c2a = C2A;
        let mut c2b = C2B;
        for x in XBUF.iter_mut() {
            *x = SINETABLE[c2a as usize].wrapping_add(SINETABLE[c2b as usize]);
            c2a = c2a.wrapping_add(3);
            c2b = c2b.wrapping_add(7);
        }
        C2A = C2A.wrapping_add(2);
        C2B = C2B.wrapping_sub(3);

        let mut cnt: isize = 0;
        for y in YBUF.iter().copied() {
            for x in XBUF.iter().copied() {
                let sum = x.wrapping_add(y);
                poke!(screen_ptr.offset(cnt), sum);
                cnt += 1;
            }
        }
    }
}

#[start]
fn _main(_argc: isize, _argv: *const *const u8) -> isize {
    const CHARSET: u16 = 0x3000; // Custom charset
    const SCREEN1: u16 = 0x0800; // Set up two character screens...
    const SCREEN2: u16 = 0x2800; // ...for double buffering
    const PAGE1: u8 =
        vic2::ScreenBank::from_address(SCREEN1).bits() | vic2::CharsetBank::from(CHARSET).bits();
    const PAGE2: u8 =
        vic2::ScreenBank::from_address(SCREEN2).bits() | vic2::CharsetBank::from(CHARSET).bits();

    make_charset(CHARSET as *mut u8);
    mega65::speed_mode3(); // reduce CPU speed to 3.5 Mhz
    loop {
        render_plasma(SCREEN1 as *mut u8);
        unsafe { (*mega65::VICII).screen_and_charset_bank.write(PAGE1) };
        render_plasma(SCREEN2 as *mut u8);
        unsafe { (*mega65::VICII).screen_and_charset_bank.write(PAGE2) };
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    #[cfg(not(target_vendor = "nes-nrom-128"))]
    print!("!");
    loop {}
}
