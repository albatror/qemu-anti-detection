## Other Project
For Proxmox VE(PVE) Anti Detection, see https://github.com/zhaodice/proxmox-ve-anti-detection

# QEMU Anti Detection
A patch for various QEMU versions that aims to prevent VM detection methods based on data reported by the emulator. The "QEMU keyboard" for example is then renamed to "ASUS keyboard". Serial numbers, the VM bit in the guest's UEFI and the Boot Graphics Record Table are also modified. 
However, because of timing based attacks like RDTSC, [which is reported incorrectly in a VM](https://github.com/WCharacter/RDTSC-KVM-Handler), this is not a silver bullet. 
But changing this information of the virtual devices is still an integral part of creating an undetected virutal machine. 

 | Type       | Engine | Bypass |
 |------------|--------|--------|
 | AntiCheat  | Anti Cheat Expert (ACE) | ☑️ |
 | AntiCheat  | Easy Anti Cheat (EAC) | ☑️ | 
 | AntiCheat  | Gepard Shield | ☑️ (Needs patched kernel on host: https://github.com/WCharacter/RDTSC-KVM-Handler ) |
 | AntiCheat  | Mhyprot | ☑️ |
 | AntiCheat  | nProtect GameGuard (NP) | ☑️ | 
 | AntiCheat  | Roblox | ☑️ May work with Hyper-V in the guest: https://github.com/zhaodice/qemu-anti-detection/issues/56 | 
 | AntiCheat  | Vanguard | ‼️(1: Incorrect function) | 
 | Encrypt    | Enigma Protector | ☑️ | 
 | Encrypt    | Safegine Shielden | ☑️ |
 | Encrypt    | Themida | ☑️ |
 | Encrypt    | VMProtect | ☑️ | 
 | Encrypt    | VProtect | ☑️ |       

‼️ There are games that cannot run under this environment but I am not sure whether QEMU has been detected, because the game doesn't report "Virtual machine detected" specifically. 
If you have any clue, feel free to tell me :)

### Flaws this patch does not fix in QEMU's source:
These commands exit with "No instance(s) available" and could therefore EXPOSE THE VM. We do not yet know how to simulate this data.
```
wmic path Win32_Fan get *

wmic path Win32_CacheMemory get *

wmic path Win32_VoltageProbe get *

wmic path Win32_PerfFormattedData_Counters_ThermalZoneInformation get *

wmic path CIM_Memory get *

wmic path CIM_Sensor get *

wmic path CIM_NumericSensor get *

wmic path CIM_TemperatureSensor get *

wmic path CIM_VoltageSensor get *
```

## Build Dependencies
⚠️ _Always maintain an installation of QEMU managed by your package manager, because it may delete necessary runtime dependencies otherwise! The binaries you compile are saved in **/usr/local/bin**, so they will take precedence._

**Arch**:
`sudo pacman -S git wget base-devel glib2 ninja python`

**Ubuntu**:
`sudo apt install git build-essential ninja-build python-venv libglib2.0-0 flex bison`

## Patching and building QEMU
```
git clone https://github.com/zhaodice/qemu-anti-detection.git
wget https://download.qemu.org/qemu-8.2.2.tar.xz
tar xvJf qemu-8.2.2.tar.xz
cd qemu-8.2.2
git apply ../qemu-anti-detection/qemu-8.2.0.patch
./configure
sudo make install -j$(nproc)
```

# QEMU XML Config

Insert YOUR virtual machine's uuid.
```
<domain xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0" type="kvm">
  <name>Entertainment</name>
  <uuid>REPLACE YOUR UUID HERE!</uuid>
  <metadata>
    <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
      <libosinfo:os id="http://microsoft.com/win/10"/>
    </libosinfo:libosinfo>
  </metadata>
  <memory unit="KiB">1548288</memory>
  <currentMemory unit="KiB">1548288</currentMemory>
  <memoryBacking>
    <source type="memfd"/>
    <access mode="shared"/>
  </memoryBacking>
  <vcpu placement="static">12</vcpu>
  <os firmware="efi">
    <type arch="x86_64" machine="pc-q35-7.0">hvm</type>
    <loader/>
    <smbios mode="host"/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <hyperv mode="custom">
      <relaxed state="on"/>
      <vapic state="on"/>
      <spinlocks state="on" retries="8191"/>
      <vendor_id state="on" value="GenuineIntel"/>
    </hyperv>
    <kvm>
      <hidden state="on"/>
    </kvm>
    <vmport state="off"/>
    <smm state="on"/>
    <ioapic driver="kvm"/>
  </features>
  <cpu mode="host-passthrough" check="none" migratable="on">
    <feature policy="disable" name="hypervisor"/>
  </cpu>
  <clock offset="localtime">
    <timer name="rtc" tickpolicy="catchup"/>
    <timer name="pit" tickpolicy="delay"/>
    <timer name="hpet" present="no"/>
    <timer name="hypervclock" present="yes"/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <pm>
    <suspend-to-mem enabled="no"/>
    <suspend-to-disk enabled="no"/>
  </pm>
  <qemu:commandline>
    <qemu:arg value="-smbios"/>
    <qemu:arg value="type=0,version=UX305UA.201"/>
    <qemu:arg value="-smbios"/>
    <qemu:arg value="type=1,manufacturer=ASUS,product=UX305UA,version=2021.1"/>
    <qemu:arg value="-smbios"/>
    <qemu:arg value="type=2,manufacturer=Intel,version=2021.5,product=Intel i9-12900K"/>
    <qemu:arg value="-smbios"/>
    <qemu:arg value="type=3,manufacturer=XBZJ"/>
    <qemu:arg value="-smbios"/>
    <qemu:arg value="type=17,manufacturer=KINGSTON,loc_pfx=DDR5,speed=4800,serial=000000,part=0000"/>
    <qemu:arg value="-smbios"/>
    <qemu:arg value="type=4,manufacturer=Intel,max-speed=4800,current-speed=4800"/>
    <qemu:arg value="-cpu"/>
    <qemu:arg value="host,family=6,model=158,stepping=2,model_id=Intel(R) Core(TM) i9-12900K CPU @ 2.60GHz,vmware-cpuid-freq=false,enforce=false,host-phys-bits=true,hypervisor=off"/>
    <qemu:arg value="-machine"/>
    <qemu:arg value="q35,kernel_irqchip=on"/>
  </qemu:commandline>
</domain>
```
![Screenshot_20220819_230305](https://user-images.githubusercontent.com/63996691/185649897-b7609626-ee6d-42b1-bc5e-4465cb41a19a.png)

## Troubleshooting virt-manager/libvirt Integration

If you've compiled and installed a patched QEMU in \`/usr/local/bin\` (as per the instructions in this README) and are facing issues with \`virt-manager\` or \`libvirtd\` not recognizing it or failing to start VMs on distributions like Ubuntu, here are common causes and troubleshooting steps:

**1. Libvirt Not Finding the Custom QEMU Binaries:**

*   **PATH for \`libvirtd\` Service:** The \`libvirtd\` daemon might not have \`/usr/local/bin\` in its PATH. Services often run with a minimal, default PATH.
    *   **Check \`libvirtd\` PATH:** The method varies by system. For systemd, you can try:
        \`\`\`bash
        sudo systemctl show service libvirtd -p Environment --value
        \`\`\`
        Look for the PATH variable. If \`/usr/local/bin\` is missing, this is a likely cause.
    *   **QEMU Binary Configuration:** Libvirt can be configured to look for specific QEMU binaries. Check \`/etc/libvirt/qemu.conf\`. Look for lines like \`qemu_binary = "/usr/bin/qemu-system-x86_64"\` or \`emulator = ["/usr/bin/qemu-system-x86_64"]\` (the exact syntax may vary by version). If these point to the system QEMU, \`libvirtd\` won't use your custom build unless you change this.
        *   **To Check:** \`grep -E 'qemu_binary|emulator' /etc/libvirt/qemu.conf\`
        *   **Possible Solution:** If such a line exists and you want \`libvirtd\` to use your custom QEMU by default, you *could* change it to \`/usr/local/bin/qemu-system-x86_64\`. **However, ensure you understand the implications, and back up the configuration file first.** Restart \`libvirtd\` after changes: \`sudo systemctl restart libvirtd\`.

**2. Permissions and Security Modules (AppArmor/SELinux):**

*   Even if \`libvirtd\` *could* find the binary, security policies might prevent its execution.
    *   **User Permissions:** The QEMU process is often run as the \`libvirt-qemu\` user (or similar). Ensure this user can execute binaries from \`/usr/local/bin\`.
        *   **Test Execution (conceptual):**
            \`\`\`bash
            # First, find the QEMU binary libvirt is trying to use (see logs or qemu.conf)
            # Then, as root, try to run it as the libvirt-qemu user:
            sudo -u libvirt-qemu /usr/local/bin/qemu-system-x86_64 --version
            \`\`\`
            If this fails, it's a permission or security module issue.
    *   **AppArmor:** On systems like Ubuntu, AppArmor profiles can restrict what \`libvirtd\` can access.
        *   **Check Logs:** Look for AppArmor DENIAL messages in system logs: \`sudo journalctl | grep -i DENIED\` or check \`/var/log/audit/audit.log\` / \`/var/log/syslog\`.
        *   **Solution:** You may need to adjust the AppArmor profile for \`libvirtd\` (often found in \`/etc/apparmor.d/\`) to allow execution of and access to files in \`/usr/local/bin/\` or your specific QEMU path. Reload AppArmor profiles after changes.
    *   **SELinux:** On systems like Fedora/RHEL, SELinux might be the cause.
        *   **Check Logs:** Look for AVC denials: \`sudo ausearch -m avc -ts recent\`
        *   **Solution:** You may need to adjust SELinux policies (e.g., using \`chcon\` for temporary changes or writing custom policy modules for permanent ones) to allow \`libvirtd_t\` (or similar context) to execute your custom QEMU.

**3. Libvirt Logs:**

*   Libvirt logs are crucial for diagnosing issues.
    *   **QEMU Domain Logs:** Check logs in \`/var/log/libvirt/qemu/\` for the specific VM that fails to start.
    *   **Libvirtd Service Logs:** Use \`journalctl -u libvirtd\` to see general errors from the libvirt daemon. Look for messages about not being able to find or execute QEMU.

**Important Considerations:**

*   **Avoid Overwriting System Binaries:** As the user who opened the original issue suggested installing to \`/usr/bin\`, **DO NOT directly replace or overwrite QEMU binaries in \`/usr/bin\` with your custom versions.** This can break your system's package management, lead to instability, and make updates difficult. The installation to \`/usr/local/bin\` is correct; the integration with \`libvirt\` is the part that needs configuration.
*   **Keep Official QEMU Installed:** The main README already advises this for runtime dependencies. This is good practice. Your custom QEMU in \`/usr/local/bin\` should take precedence if the PATH is correctly handled by \`libvirt\`, or if \`libvirt\` is configured to point to it.

By systematically checking these areas, you should be able to identify why \`virt-manager\` is not working as expected with your custom QEMU build.
