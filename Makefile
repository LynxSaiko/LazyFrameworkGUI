# Makefile LazyFramework – NAMA RESMI: lazyframework
# 100% TAB indent, tidak error lagi!

NAME            := lazyframework
VERSION         := 2.6.0
INSTALL_DIR     := /usr/share/$(NAME)
BIN_DIR         := /usr/bin
DESKTOP_DIR     := /usr/share/applications
ICON_DIR        := /usr/share/icons/hicolor/scalable/apps

PYTHON          := python3
PIP             := pip3
REQUIREMENTS    := requirements.txt

.PHONY: all install uninstall clean install-deps install-binary install-console install-desktop install-icon info

all: install

install: install-deps install-binary install-console install-desktop install-icon
	@echo ""
	@echo "LazyFramework $(VERSION) berhasil diinstall!"
	@echo "   lazyframework  → GUI langsung (tanpa terminal)"
	@echo "   lzfconsole     → mode console klasik"
	@echo "   Desktop entry  : $(DESKTOP_DIR)/lazyframework.desktop"
	@echo ""

install-deps:
	@echo "Installing dependencies..."
	@$(PIP) install -q rich PyQt6 PyQt6-WebEngine stem requests || \
	 $(PIP) install rich PyQt6 PyQt6-WebEngine stem requests

install-binary:
	@echo "Installing application & GUI launcher..."
	@sudo mkdir -p $(INSTALL_DIR)
	@sudo cp -r *.py bin modules core data themes $(INSTALL_DIR)/ 2>/dev/null || true
	@sudo cp lzfconsole $(INSTALL_DIR)/lzfconsole 2>/dev/null || true
	@sudo cp $(REQUIREMENTS) $(INSTALL_DIR)/ 2>/dev/null || true
	
	# GUI Launcher (no terminal) - langsung panggil dengan --gui
	@echo '#!/bin/bash' | sudo tee $(BIN_DIR)/lazyframework > /dev/null
	@echo 'cd /usr/share/lazyframework' | sudo tee -a $(BIN_DIR)/lazyframework > /dev/null
	@echo 'exec python3 lzfconsole --gui "$$@"' | sudo tee -a $(BIN_DIR)/lazyframework > /dev/null
	@sudo chmod +x $(BIN_DIR)/lazyframework

install-console:
	@echo "Installing console launcher..."
	@if [ -f "lzfconsole" ]; then \
		sudo cp lzfconsole $(BIN_DIR)/lzfconsole; \
		sudo chmod +x $(BIN_DIR)/lzfconsole; \
	else \
		echo '#!/bin/bash' | sudo tee $(BIN_DIR)/lzfconsole > /dev/null; \
		echo 'cd /usr/share/lazyframework && exec python3 lzfconsole "$$@"' | sudo tee -a $(BIN_DIR)/lzfconsole > /dev/null; \
		sudo chmod +x $(BIN_DIR)/lzfconsole; \
	fi

install-desktop:
	@echo "Installing desktop entry..."
	@sudo mkdir -p $(DESKTOP_DIR)
	@echo '[Desktop Entry]' | sudo tee $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'Version=1.0' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'Type=Application' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'Name=LazyFramework' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'GenericName=Penetration Testing Framework' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'Comment=Professional Exploitation & Security Testing Framework' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'Exec=lazyframework' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'Icon=lazyframework' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'Categories=LEAKOS-exploit-test;' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'Terminal=false' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'StartupNotify=true' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'StartupWMClass=LazyFrameworkGUI' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'Keywords=security;pentest;exploit;lazyframework;tor;reverse;' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@echo 'MimeType=;' | sudo tee -a $(DESKTOP_DIR)/lazyframework.desktop > /dev/null
	@sudo chmod 644 $(DESKTOP_DIR)/lazyframework.desktop
	@echo "✓ Desktop entry created: $(DESKTOP_DIR)/lazyframework.desktop"

install-icon:
	@echo "Installing icon..."
	@sudo mkdir -p $(ICON_DIR)
	@echo '<?xml version="1.0" encoding="UTF-8"?>' | sudo tee $(ICON_DIR)/lazyframework.svg > /dev/null
	@echo '<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">' | sudo tee -a $(ICON_DIR)/lazyframework.svg > /dev/null
	@echo '<rect width="256" height="256" fill="#0d1117" rx="30"/>' | sudo tee -a $(ICON_DIR)/lazyframework.svg > /dev/null
	@echo '<rect x="28" y="28" width="200" height="200" fill="#161b22" rx="15"/>' | sudo tee -a $(ICON_DIR)/lazyframework.svg > /dev/null
	@echo '<text x="128" y="105" text-anchor="middle" font-family="Arial, sans-serif" font-size="36" font-weight="bold" fill="#50fa7b">LF</text>' | sudo tee -a $(ICON_DIR)/lazyframework.svg > /dev/null
	@echo '<text x="128" y="145" text-anchor="middle" font-family="Arial, sans-serif" font-size="18" fill="#8be9fd">Framework</text>' | sudo tee -a $(ICON_DIR)/lazyframework.svg > /dev/null
	@echo '<path d="M60 170 H196 M60 185 H180 M60 200 H160" stroke="#6272a4" stroke-width="4" stroke-linecap="round"/>' | sudo tee -a $(ICON_DIR)/lazyframework.svg > /dev/null
	@echo '</svg>' | sudo tee -a $(ICON_DIR)/lazyframework.svg > /dev/null
	@sudo gtk-update-icon-cache /usr/share/icons/hicolor/ -t 2>/dev/null || true
	@echo "✓ Icon installed: $(ICON_DIR)/lazyframework.svg"

uninstall:
	@echo "Uninstalling LazyFramework..."
	@sudo rm -rf $(INSTALL_DIR)
	@sudo rm -f $(BIN_DIR)/lazyframework $(BIN_DIR)/lzfconsole
	@sudo rm -f $(DESKTOP_DIR)/lazyframework.desktop
	@sudo rm -f $(ICON_DIR)/lazyframework.svg
	@echo "Uninstall selesai!"

clean:
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

info:
	@echo "LazyFramework – Installation Info"
	@echo "   Command  : lazyframework   (GUI langsung)"
	@echo "   Console  : lzfconsole"
	@echo "   Desktop  : $(DESKTOP_DIR)/lazyframework.desktop"
	@echo "   Icon     : $(ICON_DIR)/lazyframework.svg"
	@echo ""
	@echo "Current status:"
	@if [ -f "$(BIN_DIR)/lazyframework" ]; then echo "✓ lazyframework command installed"; else echo "✗ lazyframework command missing"; fi
	@if [ -f "$(BIN_DIR)/lzfconsole" ]; then echo "✓ lzfconsole command installed"; else echo "✗ lzfconsole command missing"; fi
	@if [ -f "$(DESKTOP_DIR)/lazyframework.desktop" ]; then echo "✓ Desktop entry installed"; else echo "✗ Desktop entry missing"; fi
	@if [ -f "$(ICON_DIR)/lazyframework.svg" ]; then echo "✓ Icon installed"; else echo "✗ Icon missing"; fi