import subprocess
import sys
import platform

def run_command(command):
    """Run a shell command and return the result."""
    try:
        result = subprocess.run(
            command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True
        )
        return result.returncode == 0, result.stdout.strip() or result.stderr.strip()
    except Exception as e:
        return False, str(e)

def check_runtime(name, check_command, install_command=None):
    """Check if a runtime is installed, and if not, optionally install it."""
    print(f"Checking {name}...")
    is_installed, output = run_command(check_command)
    
    if is_installed:
        print(f"{name} is installed: {output}")
    else:
        print(f"{name} is NOT installed.")
        if install_command:
            print(f"Attempting to install {name}...")
            success, install_output = run_command(install_command)
            if success:
                print(f"{name} installed successfully!")
            else:
                print(f"Failed to install {name}. Error: {install_output}")
        else:
            print(f"Auto-installation for {name} is not supported on this OS.")

def main():
    print("Checking runtime environments...\n")

    # Detect the operating system
    os_name = platform.system()
    print(f"Detected OS: {os_name}")

    # Define the commands based on the OS
    if os_name == "Linux":
        runtimes = [
            ("Python", "python3 --version", "sudo apt update && sudo apt install -y python3"),
            (".NET SDK", "dotnet --version", "sudo apt update && sudo apt install -y dotnet-sdk-6.0"),
            ("Lua", "lua -v", "sudo apt update && sudo apt install -y lua5.4"),
            ("Perl", "perl -v", "sudo apt update && sudo apt install -y perl"),
        ]
    elif os_name == "Darwin":  # macOS
        runtimes = [
            ("Python", "python3 --version", "brew install python3"),
            (".NET SDK", "dotnet --version", "brew install --cask dotnet-sdk"),
            ("Lua", "lua -v", "brew install lua"),
            ("Perl", "perl -v", "brew install perl"),
        ]
    elif os_name == "Windows":
        runtimes = [
            ("Python", "python --version", "choco install python"),
            (".NET SDK", "dotnet --version", "choco install dotnet-sdk"),
            ("Lua", "lua -v", "choco install lua"),
            ("Perl", "perl -v", "choco install strawberryperl"),
        ]
    else:
        print(f"Unsupported operating system: {os_name}")
        return

    # Check and install runtimes
    for name, check_cmd, install_cmd in runtimes:
        check_runtime(name, check_cmd, install_cmd)

    print("\nCheck complete!")

if __name__ == "__main__":
    main()

