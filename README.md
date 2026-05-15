# 🛡️ AdBlock - Twitch (Android & Windows)

[![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20Android-lightgrey)]()

This repository brings together the best strategies to block ads at every possible layer: DNS, applications, and browser extensions. The goal is to provide an ad-free experience on both Windows and Android, especially against intrusive advertisements.

**DNS Level** – Blocks up to 70% of ads system-wide.

**App Level (Android)** – Open-source alternative to the official Twitch app with support for adding a custom proxy.

---

# Windows (10/11)

1. Run the `DNS.bat` script to apply the custom AdGuard DNS.

2. If you want to disable it and restore the default settings, run the `disable.bat` script.

3. If the script does not work, manually configure the DNS by following the tutorial at: [AdGuard DNS](https://adguard-dns.io/en/public-dns.html)

### **Default Servers**
AdGuard DNS blocks ads and trackers.

```bash
IPv4: 94.140.14.14 | 94.140.15.15

IPv6: 2a10:50c0::ad1:ff | 2a10:50c0::ad2:ff
```

---

# Mobile (Android)

1. Install Xtra on your Android device: [Download](https://github.com/crackededed/Xtra/releases)

2. Open the settings and enable the custom proxy URL:

<img src="https://raw.githubusercontent.com/zRafaX/Twitch-AdBlock/refs/heads/main/Assets/01.png" alt="Configuration 2" width="300" style="margin:10px"/>

### Proxy

```bash
https://as.luminous.dev/live/$channel?allow_source=true&allow_audio_only=true&fast_bread=true
```

All ads will be blocked. If it stops working, update to a newer proxy.

---

# Browser Extension Add-on

### Extensions
1. AdGuard Extension: [Download](https://chromewebstore.google.com/detail/adguard-adblocker/bgnkhhnnamicmpeenaelnjfhikgbkllg?hl=en)
2. AdGuard Extra Extension: [Download](https://chromewebstore.google.com/detail/adguard-extra/gkeojjjcdcopjkbelgbcpckplegclfeg)

---

## Credits

[Xtra](https://github.com/crackededed/Xtra) and [AdGuard](https://adguard.com)