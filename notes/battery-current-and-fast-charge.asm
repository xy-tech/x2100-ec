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

.org 0x2305a - 2
charger_set_current_and_voltage:
# R2 = current (mA)
# R3 = voltage (mV)

.org 0x23382 - 2
bat_changed_patch_from:
	BR bat_changed_patch@l
.org 0x23388 - 2
bat_changed_patch_ret:


.org 0x2c930 - 2
bat_changed_patch:
	# Load battery rate in.
	LOADW *bat_rate_temp_buf, r0
	STORW r0, *acpi_6a_present_rate
	
	LOADB *bat_cells_detected, r1
	
	# Check for 4-cell battery by seeing if voltage_min_design > 11100
	# (3.7V * 3 cells)
	LOADW *acpi_64_bat_voltage, r0
	CMPW $11100, r0
	BHS *sixorninecell
	# yes, it's a 4c battery
	MOVB $4, r0
	CMPB r0, r1
	BEQ *nochange
	
	# and we need to update
	STORB r0, *bat_cells_detected
	
	# 4S1P pack, so charge at 17.0V (4.25V/cell), 1.5A
	MOVW $1500, r2
	MOVW $17000, r3
	BAL (ra),*charger_set_current_and_voltage

	BR *nochange
	
sixorninecell:
	# Look for a 6-cell battery by seeing if charge_full_design < 6600
	# (2200 mAh / cell)
	LOADW *acpi_60_design_cap, r0
	CMPW $6600, r0
	BLO *ninecell
	
	# yes, it's a 6c battery
	MOVB $6, r0
	CMPB r0, r1
	BEQ *nochange
	
	# do the update
	STORB r0, *bat_cells_detected
	
	# 3S2P pack, charge at 12.8V (4.26V/cell), 3A
	MOVW $3000, r2
	MOVW $12800, r3
	BAL (ra),*charger_set_current_and_voltage

	BR *nochange

ninecell:
	# it's a 9c battery
	MOVB $9, r0
	CMPB r0, r1
	BEQ *nochange

	# do the update
	STORB r0, *bat_cells_detected
	
	# 3S3P pack, charge at 12.8V (4.26V/cell), 3.5A, inductor current
	# limit is 4.5A so we back off a little to be safe (and also because
	# x2100 "hiccups" on charger at 4A)
	MOVW $3500, r2
	MOVW $12800, r3
	BAL (ra),*charger_set_current_and_voltage

nochange:
	
	# instruction overwritten by patch
	.byte 0x77, 0x00, 0x01, 0x00, 0x30, 0x01
	#MOVD $0x10130:l, (r8,r7)
	BR *bat_changed_patch_ret:l
 