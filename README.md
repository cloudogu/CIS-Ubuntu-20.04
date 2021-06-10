# CIS-Ubuntu-20.04

This repository holds automated tests for the CIS Ubuntu Linux 20.04 LTS Benchmark v1.1.0 in [bats](https://github.com/bats-core/bats-core) format.

## Setup

- Install bats on the target system: https://bats-core.readthedocs.io/en/latest/installation.html
    - On Ubuntu, simply use `sudo apt install bats`
- Copy this repository to the target system

## Run the tests

- Move to the tests directory
- Run all the tests via `bats -r .`
- Run specific test file e.g. via `bats 1-Initial-Setup/1.1-Filesystem-Configuration.bats`
