#Changelog

## [Unreleased]

## [0.11.0] - 17/10/2018

### Changed
- Changed `Chunker.chunk/2` to `Chunker.get_chunk/2` to improve consistency.
- Added CHANGELOG.md.

### Removed
- Removed `Chunker.ChunkedFile.append/2` because it can be implemented with
  `Chunker.length/1` and `Chunker.insert_chunk/3` so an explicit protocol
  implementation is not needed.
