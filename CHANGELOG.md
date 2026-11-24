# Changelog
DeConverter — Developed by Rishi Busineni

## 2.0.1 (packaging round) — installer, website and licensing preparation (source; NOT built or tested on Windows)
* **Installer** (`packaging/installer/deconverter.iss`): output name `DeConverter-Setup-2.0.1-x64.exe` (version read from `app/branding.py`);
  default install for all users under Program Files (admin prompt) with "Install for me only" and a free choice of folder; desktop
  shortcut and Explorer right-click entry now on by default; Start Menu shortcut; "Launch DeConverter" runs as the normal user.
  The Explorer verbs are written by the installer itself (HKLM or HKCU, matching the install mode) and pointed at the native forwarder;
  the uninstaller removes exactly those keys plus any per-user verb that points into this install folder. Re-running the installer is
  an upgrade/repair: shortcuts replaced (not duplicated), stale Explorer paths rewritten. Settings/history are kept unless the user says
  yes (a silent uninstall keeps them). The installer no longer writes the Run key (Start-with-Windows stays a Settings switch).
* App: sets a Windows AppUserModelID so the taskbar uses the DeConverter identity/icon; right-click status also recognises machine-wide entries.
* Website rebuilt (dark navy, purple/blue/cyan gradients, responsive, reduced-motion aware): hero, features, why, screenshots of Convert / Batch /
  Tools / Settings / History, download table (version, size, SHA-256, release notes, requirements), install guide, FAQ. Download links still
  come only from a real `release.json`; the GitHub button stays hidden until `website/site.json` has the real repository URL.
* Licensing: `LICENSING.md`, `SOURCE_OFFER.md`, `LICENSES/AGPL-3.0.txt` added and shipped by the installer (AGPL route prepared; owner decision still to be confirmed).
* Website layout follows the requested structure: centred hero with a Windows-only badge, windowed app screenshot, How it works, Formats, Changelog sections.
* Installer renamed to `DeConverter_Setup.exe` and now defaults to a per-user install with no administrator rights ("all users" / Program Files offered on the first page). `RELEASE_NOTES.md` is attached to the GitHub Release by the workflow.
* Tests: 404 pass on Linux (new: installer script policy, HKLM/HKCU status, AppUserModelID, website content, release-notes URL).

## 2.0.1 — PDF import and batch fix (source; NOT yet built or tested on Windows)

### What was reported (real Windows 11 test of 2.0.0)
The Explorer donut menu worked and PDF -> JPG from it appeared to complete, but importing PDFs with the **Browse** button,
**drag-and-drop**, and **adding PDFs to Batch** did nothing. Images were reported to import correctly.

### Root cause (what was proven, and what was not)
Reproduced and proven on Linux with a real QML engine and the real application object:
1. **URL conversion bug (all three broken paths).** The file dialog and `DropArea` hand QML `url` values to Python as
   `QUrl` *objects*. `Backend.toLocalList()` called `str()` on each one. In PySide6 `str(QUrl)` is
   `PySide6.QtCore.QUrl('file:///C:/...')`, which is not a path and cannot be parsed back, so every imported "file" failed
   `is_file()` and was **silently skipped**. The Explorer path never touched this code: it passes plain strings from the command
   line / named pipe. That exactly matches: Explorer works, Browse / drop / Batch do not.
2. **PDF-specific detector defects** (each reproduced with a generated PDF):
   * Bytes before `%PDF-` (a BOM, blank lines, scanner/e-mail wrappers; allowed by the PDF spec within the first 1 KB) made the
     file be detected as **plain text**: wrong options, or "extension mismatch".
   * **Owner-password-only** PDFs (printing/copy restrictions, open without any password; very common) were flagged "encrypted"
     with one route, and Batch skipped them **silently**.
   * Header-only/truncated fragments were accepted: PyMuPDF "repairs" them into a zero-page PDF without raising, so 21
     conversions were offered that could only fail later.
   * Every PDF triggered a byte-scan reading up to **4 MB into RAM** (2 MB head + 2 MB tail, twice for small files) just to grep
     for `/Encrypt`, with possible false positives; failures were reported only as "could not be parsed".
3. **Batch design problems:** detection ran on the UI thread for every file (freezes on 100+ files), duplicates were checked
   in O(n^2), non-files/duplicates/no-choice rows/password rows were skipped with **no message**, and there was no progress,
   cancel or way to enter a PDF password.

**Not explained:** why *images* imported correctly for the tester. By the analysis above they should have failed the same way
through Browse/drop/Batch. Possible explanations I could not verify: images were added through a different page (the Tools page
converts a single file with a string-typed slot, which works), or a different PySide6 version formats `QUrl` differently. The fix
handles both representations. If a specific PDF still fails on your machine, run
`DeConverter.exe --diagnose "C:\path\file.pdf" --output d.txt` and send `d.txt`: it shows exactly what the app sees.

### Fix
* New `core/importer.py`: one place converts anything the UI hands over (QUrl, `file:///` URLs incl. UNC and drive letters,
  Windows paths, quoted paths, the broken `str(QUrl)` form) to a real path; long-path (`\\?\`) support; case-insensitive
  de-duplication on Windows.
* `importUrls()` is now the single QML entry point for Browse, drop, Batch and the radial menu; QML no longer converts URLs.
* Import runs in a **background worker pool** (configurable, `import_workers`, default 4) with progress, **cancel**, incremental
  UI updates, and only an 8 KB header read per file plus one PDF-engine open (cached; no repeated reads).
* Detector: tolerates junk before `%PDF-`; single engine open (no whole-file reads); owner-password-only PDFs are convertible;
  zero-page PDFs are corrupt; auto-repaired PDFs get a warning; exact engine errors are reported; thread-safe MuPDF access.
* **Nothing is rejected silently:** every file not added or not started appears in an on-screen panel with filename, exact error,
  reason and suggested fix, and in the log (`deconverter.import`).
* Password-protected PDFs: listed as "needs password", batch rows get a password field (checked immediately, kept in memory
  only, never saved to disk or the queue file); 15 conversions (PNG/JPG/TXT/HTML/PPTX/...) are offered with a password prompt;
  wrong passwords are reported, never guessed.
* Batch: add folders (subfolders only when "Include subfolders" is ticked), 100+ mixed files (PDF PNG JPG DOCX PPTX XLSX TXT MP3
  MP4 ZIP) each independently routed, more "Apply to all" targets.
* New `DeConverter.exe --diagnose FILE...`; `--selftest` now also checks the import pipeline inside the built exe.
* Unchanged: Explorer donut menu and right-click integration, all conversion engines, settings, history, notifications,
  branding (footer "DeConverter — Developed by Rishi Busineni").

### Tests added (Linux): 73+ new tests; whole suite 402 (400 pass, 2 opt-in Wine tests skipped)
Includes a layout guard: while screenshotting the new Batch page a width-overflow bug (12 pills in a RowLayout clipped buttons off the window) was found and fixed before release; a test now fails if any Batch row can lay out wider than the window.
See `docs/TEST_REPORT.md`. Windows CI and real-Windows results: **not run**.

## 2.0.0 Final Project drop (unreleased - source only; Windows artifacts not built or tested)
### Added since the first 2.0 source drop
- Persistent queue wired into real startup/recovery/shutdown; tests against the real application object.
- `--selftest` (15 real conversions with built-in engines) and `--selftest --engines --bundled-only` inside the built exe.
- Windows verification tooling: desktop self-test (`scripts/windows_selftest.py`, also built as `DeConverterSelfTest.exe`),
  Windows Sandbox harness (clean + optionally offline), portable-build test, installer test, benchmark + comparison tools,
  `RUN_BENCHMARK.bat`, license audit, engine smoke test, version resource, real screenshots on the website.
- Forwarder hardened: distinguishes busy from absent, never starts a second app, holds the launch mutex until the pipe exists.
- Release manifest with real asset URLs; CI verifies each URL before deploying the website.
### Fixed
- 'Start with Windows' registered the forwarder instead of the app; pipe reader could truncate chunked data;
  `benchmark.py` crashed on Windows (Unix-only `resource`); module versions blank in frozen builds; website download links
  would 404; PyMuPDF pinned `<2` (2.x pulled onnxruntime/numpy/networkx); earlier pdf2docx licence claim corrected.
### Earlier in 2.0
### Fixed
- **Radial menu not closing.** Dismissal no longer depends on Qt focus events (which never fire when Windows refuses
  to activate the menu). A 30 ms polling watchdog closes the menu on Esc, any outside click, Alt+Tab/focus change, or
  the originating Explorer window closing, and stops completely when the menu hides. No hooks. Transparent corners of
  the menu window are now click-through (circular window mask).
- Dependency status: tools are really executed (version check), modules really imported; "not found" no longer cached
  forever; winget (Links + Packages), Chocolatey/Scoop, Program Files and bundled folders are searched; FFprobe is found
  in a bundled `tools\ffmpeg\bin`.
- Explorer launches the verb once per selected file; a native 41 KB forwarder (`DeConverterShell.exe`) now hands paths
  to the running app instead of starting Python/Qt each time.
### Added
- Hardware-aware worker tuning, weighted slots, priorities, duplicate prevention, queue limit, memory guard.
- Persistent queue with crash recovery (poison-job guard, passwords never stored); ETA/throughput stats; retry failed.
- Settings redesign: Appearance, Performance, Output, Windows integration (status/repair/remove), Dependencies
  (version, path, source, required/optional), Privacy, Advanced, About.
- Offline engine bundling (pinned + SHA-256 verified): FFmpeg, FFprobe, Pandoc, Tesseract.
- Portable mode (`portable.flag`), installer components/upgrade/uninstall, benchmark tool, generated conversion docs.
- Developer attribution everywhere: "DeConverter — Developed by Rishi Busineni".

## 1.0.0
First release.
