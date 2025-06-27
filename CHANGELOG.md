# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2024-12-19

### Added
- Added `context` method to ValidatorFn module for scoped evaluation
  - Allows using ValidatorFn methods directly within a block without module prefix
  - Provides isolated environment that doesn't pollute caller's namespace
  - Similar to FnReader's context method but scoped to ValidatorFn

### Changed
- Updated fn_reader declaration to include the new context method

## [0.5.0] - Previous Release

### Added
- Enhanced validation capabilities
- Improved error handling and messaging
- Support for complex nested structures

## [0.4.0] - Previous Release

### Added
- Core validation functions
- Hash and array validation
- Type checking utilities
