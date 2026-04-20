import socket
import concurrent.futures
from threading import Lock
import sys

ALLOWED_PORTS = [80, 443]

def scan_port(host, port, lock, open_ports):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.4)
        result = s.connect_ex((host, port))
    if result == 0:
        with lock:
            open_ports.append(port)
            print(f"Port {port} is open", flush=True)

def scan_all_ports(host):
    open_ports = []
    lock = Lock()
    with concurrent.futures.ThreadPoolExecutor(max_workers=5000) as executor:
        futures = [executor.submit(scan_port, host, port, lock, open_ports) for port in range(1, 65536)]
        concurrent.futures.wait(futures)
    open_ports.sort()
    return open_ports

def main():
    if len(sys.argv) != 2:
        print("Usage: python scanner.py <ip>")
        sys.exit(1)

    host = sys.argv[1]
    print(f"Scanning {host}...")

    open_ports = scan_all_ports(host)

    print(f"\nOpen ports: {open_ports}")

    unexpected = [p for p in open_ports if p not in ALLOWED_PORTS]

    if unexpected:
        print(f"\nUNEXPECTED PORTS DETECTED: {unexpected}")
        sys.exit(1)
    else:
        print("\nAll good - only expected ports are open")
        sys.exit(0)

if __name__ == "__main__":
    main()
