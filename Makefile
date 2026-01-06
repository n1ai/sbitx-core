# sBitx controller for HERMES
#
# Copyright (C) 2024 Rhizomatica
# Author: Rafael Diniz <rafael@riseup.net>
#
# This is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this software; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.
#

uname_p := $(shell uname -m)

CC=gcc
#LDFLAGS=-lwiringPi -li2c
LDFLAGS=/home/pi/WiringPi/wiringPi/libwiringPi.so.3.16 -li2c

ifeq (${uname_p},aarch64)
# aarch64 Raspberry Pi 4 or better
	CFLAGS=-O3 -Wall -std=gnu11 -fstack-protector -moutline-atomics -march=armv8-a+crc
# for Pi 5 use:
#	CFLAGS=-O3 -Wall -std=gnu11 -pthread -fstack-protector -march=armv8.2-a+crypto+fp16+rcpc+dotprod -I/usr/include/iniparser
else
# x86_64 with SSE 4.2 level or better
	CFLAGS=-O3 -Wall -std=gnu11 -fstack-protector -march=x86-64-v2
endif

OBJS = sbitx_i2c.o sbitx_core.o sbitx_gpio.o sbitx_si5351.o detect_pi5.o

.PHONY: clean

all: simple_radio ptt_on sbitx_ctrl

simple_radio: $(OBJS) simple_radio.o
	$(CC) -o simple_radio simple_radio.o $(OBJS) $(LDFLAGS)

ptt_on: $(OBJS) ptt_on.o
	$(CC) -o ptt_on ptt_on.o $(OBJS) $(LDFLAGS)

sbitx_ctrl: $(OBJS) sbitx_ctrl.o
	$(CC) -o sbitx_ctrl sbitx_ctrl.o $(OBJS) $(LDFLAGS)

ptt_on.o: ptt_on.c
	$(CC) -c $(CFLAGS) ptt_on.c -o ptt_on.o

simple_radio.o: simple_radio.c
	$(CC) -c $(CFLAGS) simple_radio.c -o simple_radio.o

sbitx_gpio.o: sbitx_gpio.c sbitx_gpio.h
	$(CC) -c $(CFLAGS) sbitx_gpio.c -o sbitx_gpio.o

sbitx_i2c.o: sbitx_i2c.c sbitx_i2c.h
	$(CC) -c $(CFLAGS) sbitx_i2c.c -o sbitx_i2c.o

sbitx_core.o: sbitx_core.c sbitx_core.h
	$(CC) -c $(CFLAGS) sbitx_core.c -o sbitx_core.o

sbitx_si5351.o: sbitx_si5351.c sbitx_si5351.h
	$(CC) -c $(CFLAGS) sbitx_si5351.c -o sbitx_si5351.o

detect_pi5.o: detect_pi5.c 
	$(CC) -c $(CFLAGS) detect_pi5.c -o detect_pi5.o

install_simple_radio: simple_radio
	install -m 755 simple_radio /usr/local/bin/simple_radio

install_ptt_on: ptt_on
	install -m 755 ptt_on /usr/local/bin/ptt_on

install_sbitx_ctrl: sbitx_ctrl
	install -m 755 sbitx_ctrl /usr/local/bin/sbitx_ctrl

install: install_simple_radio install_ptt_on install_sbitx_ctrl

clean:
	rm -f simple_radio ptt_on sbitx_ctrl $(OBJS)
