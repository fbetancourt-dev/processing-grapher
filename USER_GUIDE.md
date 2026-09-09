# Processing Grapher: Complete User Guide & Instructions

A comprehensive reference manual and operating guide for **Processing Grapher**, a real-time serial telemetry monitor, multi-channel plotter, and offline waveform analysis tool built for microcontrollers (Arduino, ESP32, STM32, Teensy, Raspberry Pi Pico) and serial devices.

Original software and design by **Simon Bluett** ([wired.chillibasket.com](https://wired.chillibasket.com/processing-grapher/)).  
Maintained and modernized for **Processing 4.x (Java 17)** by [Francisco Betancourt](https://github.com/fbetancourt-dev/processing-grapher).

---

## Table of Contents

1. [Introduction](#introduction)
2. [Quick Start & Setup](#quick-start--setup)
3. [Microcontroller Setup & Telemetry Protocol](#microcontroller-setup--telemetry-protocol)
4. [Tab 1: Serial Monitor](#tab-1-serial-monitor)
   - [Connecting to a Serial Device](#connecting-to-a-serial-device)
   - [Interactive Terminal Console](#interactive-terminal-console)
   - [Filtering & Hiding Graph Telemetry](#filtering--hiding-graph-telemetry)
   - [Keyword Color Tagging](#keyword-color-tagging)
   - [Text Selection & Clipboard](#text-selection--clipboard)
   - [Logging & Recording Serial Messages](#logging--recording-serial-messages)
5. [Tab 2: Live Graphing (Real-Time Plotting)](#tab-2-live-graphing-real-time-plotting)
   - [Message Protocol](#message-protocol)
   - [Multi-Graph Splitting (1 to 4 Graphs)](#multi-graph-splitting-1-to-4-graphs)
   - [Signal Routing & Reordering](#signal-routing--reordering)
   - [Custom X-Axis (XY Plotting)](#custom-x-axis-xy-plotting)
   - [Sample Rate & Auto-Detection](#sample-rate--auto-detection)
   - [Graph Display & Scaling Modes](#graph-display--scaling-modes)
   - [Pause, Resume & Clear Data](#pause-resume--clear-data)
   - [Recording Live Telemetry to CSV](#recording-live-telemetry-to-csv)
   - [Sending Serial Commands from Live Graph](#sending-serial-commands-from-live-graph)
6. [Tab 3: File Graph Analysis (Offline Inspection)](#tab-3-file-graph-analysis-offline-inspection)
   - [Loading and Inspecting CSV Data](#loading-and-inspecting-csv-data)
   - [Custom X-Axis Header Convention](#custom-x-axis-header-convention)
   - [Interactive Bounding-Box Zoom](#interactive-bounding-box-zoom)
   - [Vertical Marker Labels](#vertical-marker-labels)
   - [Digital Signal Processing (DSP) & Math Filters](#digital-signal-processing-dsp--math-filters)
   - [Exporting Filtered Datasets](#exporting-filtered-datasets)
7. [Application Settings & Preferences](#application-settings--preferences)
   - [UI Scaling & Dynamic Zoom](#ui-scaling--dynamic-zoom)
   - [Color Themes](#color-themes)
   - [Delimiters and Line Endings](#delimiters-and-line-endings)
   - [Diagnostic Overlay](#diagnostic-overlay)
8. [Keyboard Shortcuts Cheat Sheet](#keyboard-shortcuts-cheat-sheet)
9. [Troubleshooting & Linux Permissions](#troubleshooting--linux-permissions)

---

## Introduction

When developing embedded firmware and sensor prototypes, standard terminal monitors such as the Arduino IDE Serial Monitor often lack critical tools for quantitative signal validation. 

**Processing Grapher** bridges this gap by providing:
- High-throughput serial terminal logging with regex/keyword highlighting.
- Real-time plotting across up to 4 concurrent, independently scaled charts.
- Non-blocking streaming directly to comma-separated value (CSV) files.
- Advanced offline waveform inspection with signal filtering, FFT spectrum analysis, and hysteresis loop integration.

![](Images/LiveGraph_tab.jpg)

---

## Quick Start & Setup

### Requirements
- **Processing 4.x** (tested on Processing 4.5.6 with Java 17).
- Operating System: Linux (Ubuntu/Debian, Fedora, Arch), macOS, or Windows 10/11.

### Running the Program
1. **Via Processing IDE:**
   - Open `ProcessingGrapher/ProcessingGrapher.pde` in Processing 4.
   - Click the **Run** button (or press `Ctrl+R`).
2. **Via Command Line:**
   ```bash
   processing-java --sketch=/path/to/ProcessingGrapher --run
   ```
3. **Linux Desktop Shortcut:**
   Run the included installation script to add the desktop shortcut and system icon:
   ```bash
   ./install-desktop-shortcut.sh
   ```

---

## Microcontroller Setup & Telemetry Protocol

To transmit multi-channel real-time telemetry to Processing Grapher:
1. Values must be separated by a delimiter (default is comma `,`).
2. Each sample frame must terminate with a newline character (`\n` or `\r\n`).
3. Samples must be sent at a stable, periodic rate.

### Recommended Arduino / ESP32 Example (Non-blocking 100 Hz)

```cpp
/*
 * Processing Grapher Real-time Telemetry Example
 * Transmits 3 analog/sensor channels at 100 Hz (every 10 ms).
 */

const unsigned long SAMPLE_INTERVAL_MS = 10;
unsigned long lastSampleTime = 0;

void setup() {
  Serial.begin(115200);
  while (!Serial && millis() < 3000) {
    // Wait for native USB if using Leonardo, SAMD, Teensy, or ESP32-S3
  }
}

void loop() {
  unsigned long currentTime = millis();

  if (currentTime - lastSampleTime >= SAMPLE_INTERVAL_MS) {
    lastSampleTime = currentTime;

    // Read or compute sensor values
    int ch1 = analogRead(A0);
    float ch2 = sin(currentTime * 0.005f) * 500.0f + 512.0f;
    int ch3 = analogRead(A1);

    // Format: "val1,val2,val3\n"
    Serial.print(ch1);
    Serial.print(",");
    Serial.print(ch2, 2);
    Serial.print(",");
    Serial.println(ch3); // println transmits the terminating newline
  }
}
```

> **Note:** Use `Serial.print(",")` for separators and `Serial.println(...)` exclusively on the final signal. Do not append trailing commas before the newline.

---

## Tab 1: Serial Monitor

The **Serial** tab provides high-speed bi-directional ASCII communication with connected serial devices.

![](Images/SerialMonitor_tab.jpg)

### Connecting to a Serial Device
1. In the right-hand sidebar, click the **Port: [None]** dropdown button to choose your detected serial device (e.g., `/dev/ttyACM0`, `/dev/ttyUSB0`, or `COM3`). The device list auto-refreshes.
2. Click **Baud: [9600]** to select your target communication speed (e.g., `9600`, `115200`, `250000`, `500000`, `1000000`, or `2000000`).
3. Click **Connect** (or press `Ctrl+Q`).
4. To disconnect safely, press **Disconnect** (`Ctrl+Q`) *before* unplugging the hardware USB cable to prevent serial lockups.

### Interactive Terminal Console
- **Sending Messages:** Type text directly into the console prompt at the bottom and press `Enter` to transmit to the microcontroller.
- **Autoscroll:** Toggle **Autoscroll: On/Off** to pause text scrolling when reviewing historical messages.
- **Scroll Memory Jump:** When scrolling up to inspect past logs, a quick-jump button appears at the bottom-right of the terminal to return instantly to the latest line.
- **Clear Terminal:** Click **Clear Terminal** to purge the live display buffer.

### Filtering & Hiding Graph Telemetry
When transmitting rapid numeric telemetry (e.g., `120,450,89`), textual debug prints (such as `"Calibration Complete"` or `"Error: Sensor Offline"`) can become difficult to read.
- Click the **Hide Graph Data** toggle in the sidebar. Numeric telemetry lines conforming to the graph format are filtered out of the terminal view while remaining active on the **Live Graph** tab.

### Keyword Color Tagging
Highlight critical logs in real time using custom color tags:
1. Click **Add New Tag** in the sidebar.
2. Enter the target keyword (e.g., `ERROR`, `WARN`, `OK`, `TEMP`).
3. Click the colored swatch next to the created tag to open the native color picker and assign a distinct hue.
4. Any line received containing that keyword will instantly render in the assigned color.
5. Click `x` next to any tag to remove it.

### Text Selection & Clipboard
- Drag the mouse across text in the terminal window to highlight lines.
- Press `Ctrl+C` to copy the selected logs to your system clipboard.
- Press `Ctrl+V` to paste text from clipboard into the transmit buffer.
- Press `Ctrl+A` to select all visible text in the terminal.

### Logging & Recording Serial Messages
1. Click **Set Output File** (`Ctrl+S`) to select a target `.txt` or `.log` file path.
2. Click **Start Recording** (`Ctrl+R`) to begin logging incoming serial lines.
3. The active recording path and recorded line count are displayed in the bottom status bar.
4. Click **Stop Recording** (`Ctrl+R`) to flush and close the file.

---

## Tab 2: Live Graphing (Real-Time Plotting)

The **Live Graph** tab renders real-time streams across up to 4 synchronized or independent graphs.

![](Images/LiveGraph_tab.jpg)

### Message Protocol
Telemetry packets must be delimited numbers (e.g., `23.4,102.1,-4.5`) ending with a newline. Processing Grapher automatically parses the number of channels and creates corresponding signals.

### Multi-Graph Splitting (1 to 4 Graphs)
- In the right-hand sidebar under **Split**, click `1`, `2`, `3`, or `4`.
- The display divides into stacked horizontal plots, allowing you to separate signals with incompatible units or amplitudes (e.g., RPM vs Temperature vs Current).

### Signal Routing & Reordering
At the bottom of the right-hand sidebar, all detected signals are displayed:
- **Renaming Signals:** Click a signal's label to edit its display name (e.g., rename `Signal 1` to `Thermocouple`). *Note: Signal names cannot be changed while a CSV recording is active.*
- **Moving Across Graphs:** Click the **Up (▲)** and **Down (▼)** arrow buttons next to any signal to route it to Graph 1, 2, 3, or 4.
- **Hiding Unwanted Signals:** Move a signal below the active split or into the hidden group to prevent it from cluttering the display.

### Custom X-Axis (XY Plotting)
By default, the horizontal axis represents time in seconds.
- You can designate one signal as the custom X-axis (creating an XY phase-space plot, such as Voltage vs Current or Pressure vs Volume).
- Click the **Up (▲)** arrow on **Signal 1** (or the top signal on Graph 1) to assign it as the horizontal reference for all remaining signals.

### Sample Rate & Auto-Detection
- Processing Grapher automatically measures packet arrival intervals to determine frequency (e.g., `100 Hz`).
- To override automatic calculation, click **Rate: [Auto]** in the sidebar and specify an explicit frequency in Hertz (e.g., `250`). Clear the text field to restore automatic detection.

### Graph Display & Scaling Modes
Click directly on any graph to select it (its title turns red to confirm focus). The sidebar will display **Graph X - Options**:
- **Display Modes:**
  - `Line`: Continuous interpolated line plot.
  - `Dots`: Discrete scatter plot.
  - `Bar`: Vertical column bars.
- **Y-Axis Scaling Modes:**
  - `Scale: Auto Expand`: The Y-axis expands if signal peaks exceed current boundaries, but does not contract.
  - `Scale: Automatic`: The Y-axis continuously contracts and expands to fit visible data tightly.
  - `Scale: Manual`: The graph preserves static minimum and maximum bounds. Click the minimum and maximum numeric values on the Y-axis to input exact numerical limits.

### Pause, Resume & Clear Data
- Click **Pause** in the sidebar to freeze the live display for inspection. Incoming serial data continues to be buffered and recorded in the background.
- Click **Resume** to return to live scrolling.
- Click **Clear** to purge existing points from memory.

### Recording Live Telemetry to CSV
1. Click **Set Output File** (`Ctrl+S`) to choose a file path and file name (e.g., `telemetry_run1.csv`).
2. Click **Start Recording** (`Ctrl+R`). Incoming points are written to disk with high-precision timestamps.
3. For long-duration logging, Processing Grapher automatically partitions streams every 100,000 rows to ensure file integrity and compatibility with external spreadsheet tools.
4. Click **Stop Recording** (`Ctrl+R`) when finished.

### Sending Serial Commands from Live Graph
You do not need to switch back to the Serial tab to transmit control messages:
- Press `Ctrl+M` anywhere in the application.
- A popup dialog will prompt for the command string (e.g., `PID_KP=2.5` or `TARE`).
- Press `Enter` to transmit directly over the active serial port.

---

## Tab 3: File Graph Analysis (Offline Inspection)

The **File Graph** tab allows loading, analyzing, annotating, and filtering historical CSV datasets.

![](Images/FileGraph_tab.jpg)

### Loading and Inspecting CSV Data
1. Click **Open CSV File** (`Ctrl+O`) to launch the file browser.
2. Select any valid comma-separated values file. All contained signal columns are mapped and displayed immediately.
3. Signals are listed in the sidebar with assigned colors. Click the `x` button next to any signal to remove it from the visual chart.

### Custom X-Axis Header Convention
- If your CSV includes a time or position column, prefix its header name with `x:` (for example: `x:timestamp,voltage,current` or `x:seconds,accel_x,accel_y`).
- Processing Grapher will automatically recognize the column as the horizontal axis rather than plotting it as an amplitude signal.
- If no `x:` column is present, click **Rate: [100Hz]** in the sidebar to define the sampling frequency used to scale the timebase.

### Interactive Bounding-Box Zoom
1. Click the **Zoom** button in the sidebar (the cursor turns into a precision crosshair).
2. Click and drag or click two diagonal corners across the waveform segment you wish to inspect.
3. The graph view will zoom directly into the selected bounding box.
4. Press `Esc` while selecting to cancel an active zoom operation.
5. Click **Reset** in the sidebar to return to the full unzoomed view.

### Vertical Marker Labels
1. Click **Add Label** in the sidebar.
2. Click anywhere on the waveform to place a vertical marker at that timestamp or X coordinate.
3. A marker dialog allows naming the annotation (e.g., `"Ignition"`, `"Step Response Start"`).
4. Placed markers are saved into the dataset as a dedicated label signal.

### Digital Signal Processing (DSP) & Math Filters
Click **Apply a Filter** in the sidebar to open the DSP filter library:

#### 1. Noise Removal Filters
- **Moving Average (`avg`):** Smooths high-frequency noise using a sliding window. Prompts for window size $N$.
- **1D Total Variance (`tv`):** Preserves sharp transitions while attenuating stochastic noise.
- **RC Low-Pass Filter (`lp`):** First-order infinite impulse response (IIR) low-pass filter. Prompts for cutoff frequency $f_c$.
- **RC High-Pass Filter (`hp`):** Removes DC bias and slow drift, passing AC fluctuations above cutoff frequency $f_c$.

#### 2. Mathematical Transformations
- **Absolute Value (`abs`):** Computes $|x(t)|$, rectifying bipolar oscillations.
- **Squared (`squ`):** Computes $x^2(t)$, useful for energy and power estimations.
- **Derivative (`Δ/dt`):** Computes instantaneous rate of change $\frac{\Delta x}{\Delta t}$ (e.g., velocity from position).
- **Integral (`Σdt`):** Computes discrete numerical accumulation $\sum x(t) \cdot \Delta t$ (e.g., distance from velocity).

#### 3. Signal Analysis
- **Fourier Transform (FFT) (`fft`):** Computes the frequency spectrum of the signal, plotting frequency (Hz) vs magnitude.
- **Enclosed Area (`ea`):** For cyclic or closed XY loops (such as hysteresis, thermodynamic $P\text{-}V$ diagrams, or stress-strain cycles), calculates the total enclosed surface area via numerical line integration.

*When a filter is applied, the calculated result is added as a new signal track, preserving your original raw data.*

### Exporting Filtered Datasets
- Click **Save Changes** (`Ctrl+S`) to export the modified dataset (including generated DSP tracks and markers) to a new CSV file.

---

## Application Settings & Preferences

Click the **Gear / Settings icon** in the top-right corner of the window to access global preferences.

### UI Scaling & Dynamic Zoom
- The user interface supports high-DPI displays and custom window dimensions.
- Use the sidebar controls or press `Ctrl +` to enlarge the interface and `Ctrl -` to reduce it (scaling factor from `0.5x` to `2.0x`).

### Color Themes
Switch between 3 bundled palettes:
- **Monokai:** High-contrast dark theme with vivid syntax accents.
- **One Dark Gravity:** Modern dark slate theme designed for low-light lab environments.
- **Celeste:** Clean, light palette ideal for daylight readability, exports, and presentations.

### Delimiters and Line Endings
Configure serial packet parsing to match your hardware firmware:
- **Supported Delimiters:** Comma (`,`), Semicolon (`;`), Tab (`\t`), Colon (`:`), Space (` `), Underscore (`_`), Vertical Bar (`|`).
- **Line Terminations:** `\n` (LF), `\r\n` (CRLF), or `\r` (CR).

### Diagnostic Overlay
- Toggle **Show FPS** to display a real-time rendering frame-rate monitor in the top header.
- Toggle **Show Startup Guides** to hide or show onboarding hint banners.

---

## Keyboard Shortcuts Cheat Sheet

| Shortcut | Context | Action |
|---|---|---|
| **Ctrl + Q** | Global | Connect / Disconnect active serial port |
| **Ctrl + Tab** | Global | Cycle to the next tab (Serial → Live Graph → File Graph) |
| **Ctrl + S** | Serial / Live Graph | Set output file path for recording |
| **Ctrl + S** | File Graph | Save changes and export modified CSV |
| **Ctrl + R** | Serial / Live Graph | Start / Stop data recording toggle |
| **Ctrl + O** | File Graph | Open CSV data file |
| **Ctrl + M** | Global | Open quick-transmit serial command dialog |
| **Ctrl + +** / **Ctrl + =** | Global | Increase UI scaling |
| **Ctrl + -** / **Ctrl + _** | Global | Decrease UI scaling |
| **Ctrl + C** | Serial Monitor | Copy selected text to clipboard |
| **Ctrl + V** | Serial Monitor | Paste clipboard text into transmit line |
| **Ctrl + A** | Serial Monitor | Select all lines in terminal |
| **Esc** | File Graph / Modals | Cancel active zoom box or dismiss modal alerts |
| **Page Up** / **Page Down** | Serial Monitor | Fast-scroll terminal history |
| **Up** / **Down** | Right Sidebar | Scroll menus or move signal assignments |
| **Enter** / **Return** | Serial Monitor | Transmit input text |

---

## Troubleshooting & Linux Permissions

### 1. `Permission Denied` on Linux Serial Ports
On Linux systems, access to `/dev/ttyUSB*` and `/dev/ttyACM*` requires membership in the `dialout` and `tty` user groups:
```bash
sudo usermod -a -G dialout $USER
sudo usermod -a -G tty $USER
```
*You must log out and back in (or reboot) for group changes to take effect.*

### 2. Serial Port Disappears After Disconnecting Cable
If a USB cable is unplugged while the port is still connected, the underlying operating system handle may lock up.
- Always click **Disconnect** (`Ctrl+Q`) before removing hardware.
- If locked, restart Processing Grapher or reset the USB controller:
  ```bash
  sudo udevadm trigger
  ```

### 3. Graphs Show Erratic Spikes or Missing Values
- Ensure baud rate in Processing Grapher matches `Serial.begin(...)` in your firmware exactly.
- Verify that every transmitted frame ends with `\n` (`Serial.println()`).
- Verify that no extraneous debug strings are interleaved into the CSV stream without using the **Hide Graph Data** option.

---

## License & Credits

- **Original Author:** Simon Bluett ([wired.chillibasket.com](https://wired.chillibasket.com/processing-grapher/))
- **License:** [GNU General Public License v3.0 (GPL-3.0)](LICENSE)
- **Processing 4 Fork:** [https://github.com/fbetancourt-dev/processing-grapher](https://github.com/fbetancourt-dev/processing-grapher)
