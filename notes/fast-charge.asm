.global _start
_start:
.org 0x10000
.byte 0

# Standard variables from the EC.
.org 0x1011a - 2
acpi_60_design_cap:
.org 0x1011e - 2
acpi_64_bat_voltage:
.org 0x10124 - 2
acpi_6a_present_rate:

# Variables defined by me.
.org 0x10b00 - 2
bat_rate_temp_buf:
.org 0x10b02 - 2
bat_cells_detected:

.org 0x23262 - 2
	# 100W input current is ludicrous ... how about 80W.
	MOVW $4000, r0

.org 0x232b2 - 2
patch_from:
	BR charge_current_patch@l

.org 0x232e8 - 2
patch_to:

.org 0x2c930 - 2
charge_current_patch:
	# Put the desired current in r0 later.
	LOADW *acpi_64_bat_voltage, r0
	CMPW $11100, r0
	BHI *sixorninecell
	
	# 4 cell battery, limit to 1.5A.
	MOVW $1500, r0
	BR patch_to@l

sixorninecell:
	LOADW *acpi_60_design_cap, r0
	CMPW $6600, r0
	BLO *ninecell
	# 3S2P pack, charge at charge at 12.8V (4.26V/cell), 3A
	MOVW $3000, r0
	BR patch_to@l

ninecell:
	# 3S3P pack, charge at 12.8V (4.26V/cell), 4A, inductor current
	# limit is 4.5A so we back off a little to be safe
	MOVW $4000, r0
	BR patch_to@l
