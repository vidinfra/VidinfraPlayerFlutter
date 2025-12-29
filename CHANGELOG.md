# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.5] - 2025-12-21

### Added
- Comprehensive documentation samples in SAMPLES.md
- Customizable player controls support

### Documentation
- Added detailed usage examples and samples documentation

## [0.0.4] - 2025-12-09

### Fixed
- Updated video URL and sprite path to use a consistent domain

### Changed
- Added repository and issue tracker links to pubspec.yaml

## [0.0.3] - 2025-12-07

### Added
- Ability to disable player branding
- MIT License

### Fixed
- Fixed sprites always being visible issue

### Changed
- Enhanced README.md with detailed documentation about features, installation, and usage examples
- Updated homepage URL in pubspec.yaml

## [0.0.2] - 2025-12-07

### Added
- Sprite/thumbnail preview functionality
- Offline support for sprite thumbnails
- Download only highest quality HLS streams

### Changed
- Improved download functionality and quality selection

## [0.0.1] - 2025-11-25

### Added
- Initial release of Vidinfra Player SDK for Flutter
- Embeddable video player widget (`VidinfraPlayerView`)
- Playback controller (`VidinfraPlayerController`)
- AES authentication helpers for secure video delivery
- Downloader functionality (`VidinfraDownloader`) with start/remove/list/status helpers
- Media model with subtitles, sprite thumbnails, and chapter VTT fields
- Basic player UI with controls
- Settings menu
- Seek forward/backward functionality
- Volume control
- iOS downloader support
- HLS video playback support
- Integration with `kvideo` for low-level playback control
