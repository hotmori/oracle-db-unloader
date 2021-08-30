import subprocess
import re
import time


def disconnect_vpn():
  subprocess.run(["C:\Program Files (x86)\Common Files\Pulse Secure\JamUI\Pulse.exe", "-stop"])
  time.sleep(5)
  print("VPN disconnected")
