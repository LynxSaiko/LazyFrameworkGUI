# Makefile for LazyFramework – OFFICIAL NAME: lazyframework
# Version: 2.6.0
# Professional Makefile for Termux and regular Linux systems.

# Configuration Variables
NAME            := lazyframework
VERSION         := 2.6.0

# Detect system type
UNAME_S := $(shell uname -s)
TERMUX_PREFIX := $(shell echo $$PREFIX 2>/dev/null)

# Detect Linux distribution
ifeq ($(UNAME_S),Linux)
    ifeq ($(TERMUX_PREFIX),/data/data/com.termux/files/usr)
        # Termux Android
        IS_TERMUX := 1
        DISTRO_NAME := Termux (Android)
        INSTALL_DIR := /data/data/com.termux/files/home/$(NAME)
        BIN_DIR := /data/data/com.termux/files/usr/bin
        DESKTOP_DIR := $(HOME)/.local/share/applications
        ICON_DIR := $(HOME)/.local/share/icons/hicolor/scalable/apps
        PIP_CMD := pip
        NEED_SUDO := 0
        PKG_MGR := pkg
    else
        # Regular Linux - Detect distribution
        IS_TERMUX := 0
        NEED_SUDO := 1
        PKG_MGR := unknown
        
        # Try to detect distribution
        ifneq ($(wildcard /etc/os-release),)
            # Modern systems with os-release
            DISTRO_ID := $(shell grep -E '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
            DISTRO_NAME_TEMP := $(shell grep -E '^PRETTY_NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"' 2>/dev/null)
            ifneq ($(DISTRO_NAME_TEMP),)
                DISTRO_NAME := $(DISTRO_NAME_TEMP)
            else
                DISTRO_NAME := Linux
            endif
            
            # Set package manager based on distribution
            ifeq ($(DISTRO_ID),debian)
                PKG_MGR := apt-get
            else ifeq ($(DISTRO_ID),ubuntu)
                PKG_MGR := apt-get
            else ifeq ($(DISTRO_ID),kali)
                PKG_MGR := apt-get
            else ifeq ($(DISTRO_ID),parrot)
                PKG_MGR := apt-get
            else ifeq ($(DISTRO_ID),arch)
                PKG_MGR := pacman
            else ifeq ($(DISTRO_ID),manjaro)
                PKG_MGR := pacman
            else ifeq ($(DISTRO_ID),fedora)
                PKG_MGR := dnf
            else ifeq ($(DISTRO_ID),centos)
                PKG_MGR := yum
            else ifeq ($(DISTRO_ID),rhel)
                PKG_MGR := yum
            else ifeq ($(DISTRO_ID),opensuse)
                PKG_MGR := zypper
            else ifeq ($(DISTRO_ID),void)
                PKG_MGR := xbps
            else ifeq ($(DISTRO_ID),alpine)
                PKG_MGR := apk
            endif
        else ifneq ($(wildcard /etc/debian_version),)
            # Old Debian systems
            DISTRO_NAME := Debian Linux
            PKG_MGR := apt-get
        else ifneq ($(wildcard /etc/redhat-release),)
            # RedHat based systems
            DISTRO_NAME := RedHat Linux
            PKG_MGR := yum
        else ifneq ($(wildcard /etc/arch-release),)
            # Arch Linux
            DISTRO_NAME := Arch Linux
            PKG_MGR := pacman
        else ifneq ($(wildcard /etc/gentoo-release),)
            # Gentoo Linux
            DISTRO_NAME := Gentoo Linux
            PKG_MGR := emerge
        else
            # Unknown Linux
            DISTRO_NAME := Generic Linux
        endif
        
        # Set installation paths
        INSTALL_DIR := /usr/share/$(NAME)
        BIN_DIR := /usr/bin
        DESKTOP_DIR := /usr/share/applications
        ICON_DIR := /usr/share/icons/hicolor/scalable/apps
        PIP_CMD := pip3
    endif
else
    # Non-Linux systems
    IS_TERMUX := 0
    DISTRO_NAME := Non-Linux ($(UNAME_S))
    INSTALL_DIR := /usr/local/share/$(NAME)
    BIN_DIR := /usr/local/bin
    DESKTOP_DIR := /usr/local/share/applications
    ICON_DIR := /usr/local/share/icons/hicolor/scalable/apps
    PIP_CMD := pip3
    NEED_SUDO := 1
    PKG_MGR := unknown
endif

# Messages
MSG_INSTALL     := LazyFramework $(VERSION) successfully installed on $(DISTRO_NAME)!
MSG_GUI         := "   lazyframework  → GUI mode"
MSG_CONSOLE     := "   lzfconsole     → console mode"
MSG_DESKTOP     := "   Desktop entry  : $(DESKTOP_DIR)/lazyframework.desktop"
MSG_ICON        := "   Icon entry     : $(ICON_DIR)/lazyframework.svg"
MSG_UNINSTALL   := Uninstallation complete!
MSG_SUDO_WARN   := WARNING: This requires sudo/root privileges!
MSG_DEP_INSTALL := Installing system packages with $(PKG_MGR)...

# Phony targets
.PHONY: all install uninstall clean info check-env help install-deps-system

# Help target
help:
	@echo "LazyFramework $(VERSION) - Makefile Help"
	@echo "Detected system: $(DISTRO_NAME)"
	@echo "Package manager: $(PKG_MGR)"
	@echo ""
	@echo "Available targets:"
	@echo "  make install          - Install LazyFramework"
	@echo "  make install-deps     - Install Python dependencies only"
	@echo "  make install-deps-system - Install system packages"
	@echo "  make uninstall        - Uninstall LazyFramework"
	@echo "  make clean            - Clean temporary files"
	@echo "  make info             - Show installation info"
	@echo "  make check-env        - Check system environment"
	@echo ""
	@echo "Notes:"
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		echo "  - On $(DISTRO_NAME), you may need to use 'sudo make install'"; \
	else \
		echo "  - On $(DISTRO_NAME), no sudo needed"; \
	fi

# Check environment
check-env:
	@echo "=== System Detection ==="
	@echo "System: $(UNAME_S)"
	@echo "Distribution: $(DISTRO_NAME)"
	@echo "Package manager: $(PKG_MGR)"
	@echo "Termux PREFIX: $(TERMUX_PREFIX)"
	@echo "Is Termux: $(IS_TERMUX)"
	@echo "Install dir: $(INSTALL_DIR)"
	@echo "Bin dir: $(BIN_DIR)"
	@echo "Need sudo: $(NEED_SUDO)"
	@echo "========================"

# Main target
all: check-env install

# Installation process
install: install-deps install-binary install-console install-desktop install-icon
	@echo ""
	@echo "$(MSG_INSTALL)"
	@echo $(MSG_GUI)
	@echo $(MSG_CONSOLE)
	@if [ $(IS_TERMUX) -eq 0 ]; then \
		echo $(MSG_DESKTOP); \
		echo $(MSG_ICON); \
	fi
	@echo ""
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		echo "$(MSG_SUDO_WARN)"; \
	fi

# Install system packages (optional)
install-deps-system:
	@echo "=== Installing system packages ==="
	@echo "$(MSG_DEP_INSTALL)"
	@if [ $(IS_TERMUX) -eq 1 ]; then \
		echo "Installing Termux packages..."; \
		pkg update -y && pkg install -y python python-pip; \
	elif [ $(NEED_SUDO) -eq 1 ]; then \
		case "$(PKG_MGR)" in \
			apt-get|apt) \
				sudo apt-get update && sudo apt-get install -y python3 python3-pip python3-pyqt6 python3-pyqt6.qtwebengine; \
				;; \
			pacman) \
				sudo pacman -Sy --noconfirm python python-pip python-pyqt6 python-pyqt6-webengine; \
				;; \
			dnf) \
				sudo dnf install -y python3 python3-pip python3-qt6; \
				;; \
			yum) \
				sudo yum install -y python3 python3-pip python3-qt6; \
				;; \
			zypper) \
				sudo zypper install -y python3 python3-pip python3-qt6; \
				;; \
			apk) \
				sudo apk add python3 py3-pip py3-pyqt6 py3-pyqt6-webengine; \
				;; \
			xbps) \
				sudo xbps-install -S python3 python3-pip python3-PyQt6; \
				;; \
			emerge) \
				sudo emerge --ask n dev-python/PyQt6; \
				;; \
			*) \
				echo "Unknown package manager: $(PKG_MGR)"; \
				echo "Please install python3 and pip manually"; \
				;; \
		esac; \
	else \
		echo "No system packages to install or no sudo available"; \
	fi
	@echo "✓ System packages installed."

# Install Python dependencies
install-deps:
	@echo "=== Installing Python dependencies ==="
	@echo "Using pip: $(PIP_CMD)"
	@if [ $(IS_TERMUX) -eq 1 ]; then \
		echo "Installing Termux Python packages..."; \
		$(PIP_CMD) install --upgrade pip 2>/dev/null || true; \
		$(PIP_CMD) install rich PyQt6 PyQt6-WebEngine stem requests; \
	else \
		echo "Installing Linux Python packages..."; \
		$(PIP_CMD) install --upgrade pip 2>/dev/null || true; \
		$(PIP_CMD) install rich PyQt6 PyQt6-WebEngine stem requests; \
	fi
	@echo "✓ Python dependencies installed."

# Install application and binaries
install-binary:
	@echo "=== Installing application files ==="
	@# Create directories
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		sudo mkdir -p "$(INSTALL_DIR)" 2>/dev/null || mkdir -p "$(INSTALL_DIR)"; \
	else \
		mkdir -p "$(INSTALL_DIR)"; \
	fi
	
	@# Copy files
	@echo "Copying files to $(INSTALL_DIR)..."
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		sudo cp -r *.py "$(INSTALL_DIR)/" 2>/dev/null || true; \
		for dir in bin modules core data themes; do \
			if [ -d "$$dir" ]; then \
				sudo cp -r "$$dir" "$(INSTALL_DIR)/" 2>/dev/null || true; \
			fi; \
		done; \
		if [ -f "lzfconsole" ]; then \
			sudo cp lzfconsole "$(INSTALL_DIR)/" 2>/dev/null || true; \
		fi; \
		if [ -f "requirements.txt" ]; then \
			sudo cp requirements.txt "$(INSTALL_DIR)/" 2>/dev/null || true; \
		fi; \
	else \
		cp -r *.py "$(INSTALL_DIR)/" 2>/dev/null || true; \
		for dir in bin modules core data themes; do \
			if [ -d "$$dir" ]; then \
				cp -r "$$dir" "$(INSTALL_DIR)/" 2>/dev/null || true; \
			fi; \
		done; \
		if [ -f "lzfconsole" ]; then \
			cp lzfconsole "$(INSTALL_DIR)/" 2>/dev/null || true; \
		fi; \
		if [ -f "requirements.txt" ]; then \
			cp requirements.txt "$(INSTALL_DIR)/" 2>/dev/null || true; \
		fi; \
	fi
	
	@# Create GUI launcher
	@echo "Creating launcher in $(BIN_DIR)..."
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		sudo mkdir -p "$(BIN_DIR)"; \
		echo '#!/bin/bash' | sudo tee "$(BIN_DIR)/lazyframework" > /dev/null; \
		echo 'cd "$(INSTALL_DIR)"' | sudo tee -a "$(BIN_DIR)/lazyframework" > /dev/null; \
		echo 'exec python3 lzfconsole --gui "$$@"' | sudo tee -a "$(BIN_DIR)/lazyframework" > /dev/null; \
		sudo chmod +x "$(BIN_DIR)/lazyframework"; \
	else \
		mkdir -p "$(BIN_DIR)"; \
		echo '#!/bin/bash' > "$(BIN_DIR)/lazyframework"; \
		echo 'cd "$(INSTALL_DIR)"' >> "$(BIN_DIR)/lazyframework"; \
		echo 'exec python3 lzfconsole --gui "$$@"' >> "$(BIN_DIR)/lazyframework"; \
		chmod +x "$(BIN_DIR)/lazyframework"; \
	fi
	@echo "✓ Application installed."

# Install console launcher
install-console:
	@echo "=== Installing console launcher ==="
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		if [ -f "lzfconsole" ]; then \
			sudo cp lzfconsole "$(BIN_DIR)/" 2>/dev/null || true; \
			sudo chmod +x "$(BIN_DIR)/lzfconsole" 2>/dev/null || true; \
		fi; \
	else \
		if [ -f "lzfconsole" ]; then \
			cp lzfconsole "$(BIN_DIR)/" 2>/dev/null || true; \
			chmod +x "$(BIN_DIR)/lzfconsole" 2>/dev/null || true; \
		fi; \
	fi
	@echo "✓ Console launcher installed."

# Install desktop entry (Linux only)
install-desktop:
	@echo "=== Installing desktop entry ==="
	@if [ $(IS_TERMUX) -eq 1 ]; then \
		echo "Skipping desktop entry for Termux..."; \
	else \
		if [ $(NEED_SUDO) -eq 1 ]; then \
			sudo mkdir -p "$(DESKTOP_DIR)"; \
			sudo sh -c 'echo "[Desktop Entry]" > "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Version=1.0" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Type=Application" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Name=LazyFramework" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "GenericName=Penetration Testing Framework" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Comment=Professional Exploitation & Security Testing Framework" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Exec=lazyframework" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Icon=lazyframework" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Categories=Utility;Development;" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Terminal=false" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "StartupNotify=true" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "StartupWMClass=LazyFrameworkGUI" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo chmod 644 "$(DESKTOP_DIR)/lazyframework.desktop"; \
		else \
			mkdir -p "$(DESKTOP_DIR)"; \
			echo "[Desktop Entry]" > "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Version=1.0" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Type=Application" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Name=LazyFramework" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "GenericName=Penetration Testing Framework" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Comment=Professional Exploitation & Security Testing Framework" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Exec=lazyframework" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Icon=lazyframework" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Categories=Utility;Development;" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Terminal=false" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "StartupNotify=true" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "StartupWMClass=LazyFrameworkGUI" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			chmod 644 "$(DESKTOP_DIR)/lazyframework.desktop"; \
		fi; \
		echo "✓ Desktop entry installed."; \
	fi

# Install icon (Linux only)
install-icon:
	@echo "=== Installing icon ==="
	@if [ $(IS_TERMUX) -eq 1 ]; then \
		echo "Skipping icon for Termux..."; \
	else \
		if [ $(NEED_SUDO) -eq 1 ]; then \
			sudo mkdir -p "$(ICON_DIR)"; \
			sudo sh -c 'echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<svg width=\"256\" height=\"256\" viewBox=\"0 0 256 256\" xmlns=\"http://www.w3.org/2000/svg\">" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<rect width=\"256\" height=\"256\" fill=\"#0d1117\" rx=\"30\"/>" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<rect x=\"28\" y=\"28\" width=\"200\" height=\"200\" fill=\"#161b22\" rx=\"15\"/>" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<text x=\"128\" y=\"105\" text-anchor=\"middle\" font-family=\"Arial, sans-serif\" font-size=\"36\" font-weight=\"bold\" fill=\"#50fa7b\">LF</text>" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<text x=\"128\" y=\"145\" text-anchor=\"middle\" font-family=\"Arial, sans-serif\" font-size=\"18\" fill=\"#8be9fd\">Framework</text>" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<path d=\"M60 170 H196 M60 185 H180 M60 200 H160\" stroke=\"#6272a4\" stroke-width=\"4\" stroke-linecap=\"round\"/>" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "</svg>" >> "$(ICON_DIR)/lazyframework.svg"'; \
		else \
			mkdir -p "$(ICON_DIR)"; \
			echo '<?xml version="1.0" encoding="UTF-8"?>' > "$(ICON_DIR)/lazyframework.svg"; \
			echo '<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '<rect width="256" height="256" fill="#0d1117" rx="30"/>' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '<rect x="28" y="28" width="200" height="200" fill="#161b22" rx="15"/>' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '<text x="128" y="105" text-anchor="middle" font-family="Arial, sans-serif" font-size="36" font-weight="bold" fill="#50fa7b">LF</text>' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '<text x="128" y="145" text-anchor="middle" font-family="Arial, sans-serif" font-size="18" fill="#8be9fd">Framework</text>' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '<path d="M60 170 H196 M60 185 H180 M60 200 H160" stroke="#6272a4" stroke-width="4" stroke-linecap="round"/>' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '</svg>' >> "$(ICON_DIR)/lazyframework.svg"; \
		fi; \
		echo "✓ Icon installed."; \
	fi

# Uninstall LazyFramework
uninstall:
	@echo "=== Uninstalling LazyFramework ==="
	@echo "System: $(DISTRO_NAME)"
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		echo "Removing with sudo..."; \
		sudo rm -rf "$(INSTALL_DIR)" 2>/dev/null || true; \
		sudo rm -f "$(BIN_DIR)/lazyframework" "$(BIN_DIR)/lzfconsole" 2>/dev/null || true; \
		if [ $(IS_TERMUX) -eq 0 ]; then \
			sudo rm -f "$(DESKTOP_DIR)/lazyframework.desktop" 2>/dev/null || true; \
			sudo rm -f "$(ICON_DIR)/lazyframework.svg" 2>/dev/null || true; \
		fi; \
	else \
		echo "Removing without sudo..."; \
		rm -rf "$(INSTALL_DIR)" 2>/dev/null || true; \
		rm -f "$(BIN_DIR)/lazyframework" "$(BIN_DIR)/lzfconsole" 2>/dev/null || true; \
		if [ $(IS_TERMUX) -eq 0 ]; then \
			rm -f "$(DESKTOP_DIR)/lazyframework.desktop" 2>/dev/null || true; \
			rm -f "$(ICON_DIR)/lazyframework.svg" 2>/dev/null || true; \
		fi; \
	fi
	@echo "$(MSG_UNINSTALL)"

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.log" -delete 2>/dev/null || true
	@echo "✓ Temporary files cleaned."

# Display installation status information
info:
	@echo "=== LazyFramework Installation Info ==="
	@echo "System: $(DISTRO_NAME)"
	@echo "Distribution: $(DISTRO_NAME)"
	@echo "Package manager: $(PKG_MGR)"
	@echo "Installation directory: $(INSTALL_DIR)"
	@echo "Binary directory: $(BIN_DIR)"
	@echo ""
	@echo "Commands available:"
	@echo "  lazyframework   - GUI mode"
	@echo "  lzfconsole      - Console mode"
	@echo ""
	@echo "Current status:"
	@if [ -f "$(BIN_DIR)/lazyframework" ]; then echo "✓ lazyframework command installed"; else echo "✗ lazyframework command missing"; fi
	@if [ -f "$(BIN_DIR)/lzfconsole" ]; then echo "✓ lzfconsole command installed"; else echo "✗ lzfconsole command missing"; fi
	@if [ $(IS_TERMUX) -eq 0 ]; then \
		if [ -f "$(DESKTOP_DIR)/lazyframework.desktop" ]; then echo "✓ Desktop entry installed"; else echo "✗ Desktop entry missing"; fi; \
		if [ -f "$(ICON_DIR)/lazyframework.svg" ]; then echo "✓ Icon installed"; else echo "✗ Icon missing"; fi; \
	fi
	@echo "====================================="

# Test distribution detection
test-distro:
	@echo "Testing distribution detection..."
	@echo "UNAME_S: $(UNAME_S)"
	@echo "TERMUX_PREFIX: $(TERMUX_PREFIX)"
	@echo "DISTRO_NAME: $(DISTRO_NAME)"
	@echo "PKG_MGR: $(PKG_MGR)"
	@echo "IS_TERMUX: $(IS_TERMUX)"
	@echo "NEED_SUDO: $(NEED_SUDO)"
