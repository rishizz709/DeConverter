# DeConverter 2.0.1
DeConverter — Developed by Rishi Busineni.

## Downloads
* **DeConverter_Setup.exe** — Windows installer (Windows 10/11, 64-bit). Installs for you only, no administrator rights needed; choose "all users" on the first page if you prefer Program Files.
* **DeConverter-Portable.zip** — unzip and run, nothing is installed.
* **SHA256SUMS.txt** — checksums. In PowerShell: `Get-FileHash .\DeConverter_Setup.exe -Algorithm SHA256`, and compare.

## What's new
* Standalone Windows app: no Python, terminal or batch files needed.
* Installer with desktop and Start Menu shortcuts, Explorer right-click entry ("Convert with DeConverter"), launch-after-install option, upgrade/repair and uninstaller.
* Settings and history live in your user profile; upgrades never overwrite them. Uninstall asks before deleting them.
* More reliable PDF import and batch handling, with a clear reason for every file that cannot be converted.

## Good to know
* **Unsigned:** these files are not code-signed, so Windows SmartScreen may warn ("Windows protected your PC"). Check the SHA-256 first, then choose More info → Run anyway.
* On Windows 11 the right-click entry is under "Show more options".
* PyMuPDF (AGPL-3.0) is bundled; see `LICENSING.md`, `SOURCE_OFFER.md` and `THIRD_PARTY_NOTICES.md`.
* Word/Office to PDF needs LibreOffice installed separately.
