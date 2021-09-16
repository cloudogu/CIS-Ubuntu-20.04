# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Remove unnecessary test in 1.5.4
- Remove debug output from test script 6.2.5
- Some tests of chapter 4.1 now take into account that the value of UID_MIN can be customized
- Update tests of chapter 6 to match the requirements from the CIS document as described.

### Fixed
- Inverted return status check of test 4.4 to match the correct status code returned from grep if no line was found
- Fix newline mistakes in script 6.2.6
- Fix newline mistakes in script 6.2.7
- Fix additional partitions tests 1.1.10, 1.1.11, 1.1.15, 1.1.16 and 1.1.17

## [1.0.0] - 2021-06-15
### Added
- Tests for chapter 1
- Tests for chapter 2
- Tests for chapter 3
- Tests for chapter 4
- Tests for chapter 5
- Tests for chapter 6
