.global _start
_start:
.org 0x10000
.byte 0

# Standard variables from the EC.
.org 0x10124 - 2
acpi_6a_present_rate:

# Variables defined by me.
.org 0x10b00 - 2
bat_rate_temp_buf:

.org 0x23170 - 2
patch_from:
	BR patch@l

.org 0x23176 - 2
patch_to:

.org 0x2c970 - 2
patch:
	LOADW *bat_rate_temp_buf, r0
	TBIT $15, r0
	BFC skip
	XORW $0xffff, r0
	ADDW $1, r0
skip:
	STORW r0, *acpi_6a_present_rate
	BR patch_to@l
