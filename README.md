# proximityLock

**proximityLock** is a native macOS app that automatically locks your Mac based on the distance from your selected Bluetooth device.  
It uses the device’s **RSSI (Received Signal Strength Indicator)** to estimate proximity, no companion app or setup required. 

Bluetooth devices constantly emit RSSI signals, which indicate how strong or weak the connection is.  
Because RSSI can fluctuate in different environments, proximityLock uses a **Kalman filter** to smooth out noisy data.  
You can also customize the RSSI threshold to suit your environment and sensitivity preferences.

> **Important:**  
> proximityLock requires you to enable the macOS setting that locks your Mac when the screen saver is active.  
> This is necessary because Apple does not provide a public API to directly lock the Mac without third-party utilities.

The project is currenlty a work in progress, but feel free to test it out!
---

### Features
- Native macOS app 
- Uses Bluetooth Low Energy (BLE) RSSI for proximity detection
- Adjustable RSSI threshold
- Kalman filtering for stable signal readings

---

