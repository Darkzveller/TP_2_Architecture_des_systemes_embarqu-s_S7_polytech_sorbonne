# TP2 DE10-Lite - Quartus / Nios II 18.1 (Nios II Command Shell)
# Placer a la racine du depot. Ne pas remplacer les Makefile Altera.
SHELL := /bin/bash
.DEFAULT_GOAL := help
.NOTPARALLEL:

QUARTUS_ROOT ?= /cygdrive/c/intelFPGA_lite/18.1/quartus
export PATH := $(PATH):$(QUARTUS_ROOT)/bin64:$(QUARTUS_ROOT)/bin:$(QUARTUS_ROOT)/sopc_builder/bin
PROJECT := TP_2_Architecture_des_systemes_embarquees
REVISION := top_level
QSYS := nios2_system.qsys
SOPC := nios2_system.sopcinfo
SOF := output_files/top_level.sof
APP := software/tp_app
BSP := software/tp_bsp
ELF := $(APP)/tp_app.elf
CABLE ?= USB-Blaster [USB-0]
REQUIRED_MACRO ?= PWM0_BASE

.PHONY: help check jtag hardware bsp verify build program download terminal run full clean
help:
	@echo 'make check    : verifie les outils et fichiers'
	@echo 'make jtag     : verifie la detection USB-Blaster / MAX 10'
	@echo 'make hardware : genere Qsys et compile Quartus'
	@echo 'make bsp      : actualise le BSP depuis le sopcinfo'
	@echo 'make run      : compile C, telecharge ELF et ouvre la console'
	@echo 'make full     : hardware + BSP + compilation C + SOF + ELF + console'
	@echo 'make program  : charge uniquement le SOF existant'
	@echo 'make terminal : ouvre la console (Ctrl+C pour quitter)'
	@echo 'make clean    : nettoie uniquement les builds logiciels'

check:
	@set -e; for t in make nios2-elf-gcc nios2-bsp nios2-download nios2-terminal jtagconfig; do command -v "$$t" >/dev/null || { echo "Outil absent: $$t"; exit 1; }; done
	@set -e; for f in "$(PROJECT).qpf" "$(REVISION).qsf" "$(QSYS)" "$(APP)/Makefile" "$(BSP)/settings.bsp"; do test -f "$$f" || { echo "Fichier absent: $$f"; exit 1; }; done
	@nios2-elf-gcc --version | head -n 1
	@echo 'Outils logiciels et fichiers de base OK.'

jtag:
	@set -e; out="$$(jtagconfig)"; printf '%s\n' "$$out"; printf '%s\n' "$$out" | grep -Fq '$(CABLE)' || { echo 'USB-Blaster attendu non detecte'; exit 1; }; printf '%s\n' "$$out" | grep -Ei '10M50|031050DD' >/dev/null || { echo 'MAX 10 attendu non detecte'; exit 1; }

hardware: check
	@command -v qsys-generate >/dev/null || { echo 'qsys-generate absent du PATH'; exit 1; }
	@command -v quartus_sh >/dev/null || { echo 'quartus_sh absent du PATH'; exit 1; }
	qsys-generate "$(QSYS)" --synthesis=VHDL
	quartus_sh --flow compile "$(PROJECT)" -c "$(REVISION)"
	@test -s "$(SOF)" && test -s "$(SOPC)"

bsp: check
	@test -s "$(SOPC)" || { echo 'SOPCINFO absent : make hardware'; exit 1; }
	nios2-bsp hal "$(BSP)" "$(SOPC)" --set hal.stdin jtag_uart_0 --set hal.stdout jtag_uart_0 --set hal.stderr jtag_uart_0

verify:
	@test -s "$(BSP)/system.h" || { echo 'system.h absent : make bsp'; exit 1; }
	@grep -E '^#define[[:space:]]+ALT_(STDIN|STDOUT|STDERR)_TYPE[[:space:]]+"altera_avalon_jtag_uart"' "$(BSP)/system.h"; test "$$(grep -Ec '^#define[[:space:]]+ALT_(STDIN|STDOUT|STDERR)_TYPE[[:space:]]+"altera_avalon_jtag_uart"' "$(BSP)/system.h")" -eq 3 || { echo 'HAL JTAG UART incorrecte : make bsp'; exit 1; }
	@if [ -n "$(REQUIRED_MACRO)" ]; then grep -E '^#define[[:space:]]+$(REQUIRED_MACRO)[[:space:]]+' "$(BSP)/system.h" || { echo 'Peripherique absent du BSP : verifier Qsys puis make full'; exit 1; }; fi

build: check verify
	$(MAKE) -C "$(APP)" all
	@test -s "$(ELF)" || { echo 'ELF absent apres compilation'; exit 1; }

program: jtag
	@command -v quartus_pgm >/dev/null || { echo 'quartus_pgm absent du PATH'; exit 1; }
	@test -s "$(SOF)" || { echo 'SOF absent : make hardware'; exit 1; }
	quartus_pgm -c "$(CABLE)" -m jtag -o "P;$(SOF)"

# Cible Altera : conserve les verifications System ID / timestamp du BSP.
# Ne pas contourner ces verifications en cas de desynchronisation.
download: build jtag
	$(MAKE) -C "$(APP)" download-elf

terminal: jtag
	nios2-terminal

run: download
	$(MAKE) terminal

full: hardware bsp
	$(MAKE) clean
	$(MAKE) build
	$(MAKE) program
	$(MAKE) download
	$(MAKE) terminal

clean:
	$(MAKE) -C "$(APP)" clean
	$(MAKE) -C "$(BSP)" clean
