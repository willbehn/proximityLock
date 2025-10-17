# ProximityLock
<img width="960" height="540" alt="Presentation2" src="https://github.com/user-attachments/assets/4bef1d01-b376-4151-b0cc-f85673183f1b" />

**proximityLock** is a native macOS app that automatically locks your Mac based on the distance from your selected Bluetooth device.  
It uses the device’s **RSSI (Received Signal Strength Indicator)** to estimate proximity, no companion app or setup required. 
The project is currently a work in progress, but feel free to test it out!

Because RSSI can fluctuate in different environments, proximityLock uses a **Kalman filter** to smooth out noisy data.  
You can also customize the RSSI threshold to suit your environment and sensitivity preferences.

> **Important:**  
> proximityLock requires you to enable the macOS setting that locks your Mac when the screen saver is active.  
> This is necessary because Apple does not provide a public API to directly lock the Mac without third-party utilities.

---

### Features
- Native macOS app 
- Uses Bluetooth Low Energy (BLE) RSSI for proximity detection
- Adjustable RSSI threshold to fit your environment
- Kalman filtering for stable signal readings
---

