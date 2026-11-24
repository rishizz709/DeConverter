# DeConverter — *One File. Every Possibility.*

A universal Windows file-conversion and productivity app built around an animated **radial donut menu**. Pick a file, and DeConverter shows only the conversions that can really run on your machine.

> **Status: v2.0.1 source. NOT ready for public distribution.** The Windows installer, portable build, Explorer integration
> and offline operation have **not** yet been built or tested on Windows. Linux tests pass; Windows CI and real-Windows tests
> have not been run. See [docs/TEST_REPORT.md](docs/TEST_REPORT.md) (three separate result categories) and
> [docs/WINDOWS_TESTING.md](docs/WINDOWS_TESTING.md) (how to run them).

**DeConverter — Developed by Rishi Busineni**

## Quick start (Windows 10/11, 64-bit)
**From source:** extract, run **INSTALL.bat** (private Python environment; offers winget installs of engines), then **START.bat**.
**Build the real distributions:** run **BUILD.bat** (or the GitHub Actions workflow). Output: `DeConverter_Setup.exe` (installer,
Explorer integration, offline engines) and `DeConverter-Portable.zip` (settings beside the exe, no registry changes).

## Ways to open the menu
- **Drag & drop** a file onto the main window (always available).
- **Right-click → Convert with DeConverter** (Settings → Windows integration; per-user, reversible).
- **Shift + drag** a file in Explorer (opt-in). The hook never blocks Explorer; drop onto a segment to convert.
- **Ctrl+Alt+D** with a file selected in Explorer (configurable); or the tray icon.

## Features
- Radial menu: up to 9 ranked segments + “more”, real blurred-backdrop glass, hover details, keyboard (1–9, arrows, Enter, Esc), light/dark/auto theme, cursor-relative and multi-monitor-safe placement.
- Detection by magic bytes + container inspection; flags corrupt, mislabelled, encrypted and unknown files.
- Capability registry with dependency checks — missing engines hide routes instead of failing.
- Images, documents, slides, spreadsheets, PDF toolkit, audio, video, archives ([full table](docs/CONVERSION_SUPPORT.md)).
- Batch queue: parallel, per-file progress, pause/resume, cancel, retry, JSON/CSV report.
- Notification cards with progress, sizes, space saved, Open / Show in folder / Copy / Retry.
- History (SQLite), favourites, presets, naming rules, default output folder, watch folder.
- Offline document tools: summary, smart file name, key-info extraction, folder search, table extraction.
- Plugins (SHA-256-pinned trust). No telemetry, no uploads.

## Development
```
pip install -r requirements-dev.txt
QT_QPA_PLATFORM=offscreen pytest      # Windows PowerShell: $env:QT_QPA_PLATFORM="offscreen"
python -m app.main --check
```
Docs: [Architecture](docs/ARCHITECTURE.md) · [Installation](docs/INSTALLATION.md) · [Conversion support](docs/CONVERSION_SUPPORT.md) · [Performance](docs/PERFORMANCE.md) · [Test report](docs/TEST_REPORT.md) · [Windows testing](docs/WINDOWS_TESTING.md) · [License audit](docs/LICENSE_AUDIT.md) · [Security](docs/SECURITY.md) · [Contributing](docs/CONTRIBUTING.md) · [Third-party notices](THIRD_PARTY_NOTICES.md) · [Changelog](CHANGELOG.md)

## Troubleshooting
- *A conversion I expect is missing* → Settings → Dependencies; install the listed program and press Re-check.
- *Nothing appears when launching* → see `%APPDATA%\DeConverter\logs\deconverter.log`.
- *Shift+drag does nothing* → enable it in Settings; use the right-click menu or drop window if your security software blocks mouse hooks.

## Third-party software
Qt/PySide6 (LGPL-3 option), Pillow (MIT-CMU/HPND), pillow-heif (BSD, uses libheif LGPL), PyMuPDF (AGPL-3 **or** commercial: **decision required before distributing binaries**), pdf2docx / python-docx / python-pptx / openpyxl / pydantic (MIT), py7zr (LGPL). Bundled engines (separate programs): FFmpeg (GPL-3, includes x264/x265), Pandoc (GPL-2+), Tesseract (Apache-2). LibreOffice (MPL) is not bundled. See THIRD_PARTY_NOTICES.md and docs/LICENSE_AUDIT.md.

## License
MIT — see [LICENSE](LICENSE).

---
DeConverter — Developed by Rishi Busineni · No telemetry · Works offline after installation.
