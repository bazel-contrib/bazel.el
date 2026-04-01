# Copyright 2021, 2022, 2023, 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SHELL := /bin/sh

.DEFAULT: all
.SUFFIXES:

BAZEL := bazel
BAZELFLAGS :=

# All potentially supported Emacs versions.
versions := 29 30

# Test both default toolchain and versioned toolchains.
all: check $(versions)

check:
	$(BAZEL) test --test_output=errors $(BAZELFLAGS) -- //...

COVERAGE_BAZELFLAGS = $(BAZELFLAGS) --lockfile_mode=off
GENHTML = genhtml
GENHTMLFLAGS = --branch-coverage \
  --demangle-cpp='$(CPPFILT)' --demangle-cpp='--no-strip-underscore'
CPPFILT = c++filt

coverage:
	$(BAZEL) coverage --combined_report=lcov $(COVERAGE_BAZELFLAGS) -- //...
	$(GENHTML) --output-directory=coverage-report $(GENHTMLFLAGS) \
	  -- bazel-out/_coverage/_coverage_report.dat

$(versions):
	$(MAKE) check BAZELFLAGS='$(BAZELFLAGS) --extra_toolchains=@phst_rules_elisp//elisp:emacs_$@_toolchain'

.PHONY: all check coverage $(versions)
