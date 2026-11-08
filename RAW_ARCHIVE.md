# Raw experimental evidence archive

This archive contains **4718** text-based experiment evidence files, preserving their original relative directory layout. Files larger than 250 KB are gzip-compressed individually. Published bytes: **77,150,675**.

The archive includes JSON/JSONL run outputs, Lean snippets, logs, Markdown reports, tabular records and configuration text, except exclusions recorded in `data/excluded-files.csv`. All included files are indexed in `data/raw-file-manifest.csv`, including original SHA-256 and published path.

**Sensitive data**: 15617 pattern matches redacted (credentials, local user paths, email addresses). This is automated screening and cannot guarantee complete detection. No vendor dependencies, compiled binaries, database files or build caches are included. A source SHA-256 identifies the original private file; it is not the checksum of the redacted public copy.

The directory is an evidence dump, not a ready-to-run project. Use `gzip -d -k <file.gz>` to expand compressed artifacts. Large JSON files may be very large when expanded. Repeated source snapshots and repeated runs are intentionally preserved.

## Large files

Additional large JSON evidence files were processed and compressed; the manifest includes their original SHA-256. Total raw experiment files published: **4718**. Remaining exclusions: **0**.
