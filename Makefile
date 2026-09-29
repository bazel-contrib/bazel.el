# Copyright 2021-2023, 2026 Google LLC
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

.POSIX:
.PHONY: all check coverage info install
.PHONY: MODULE.bazel.lock
.SUFFIXES:

SHELL = /bin/sh

BAZEL ?= bazel
BAZELFLAGS =
INSTALL ?= install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644
INSTALL_BAZELFLAGS = --config=release $(BAZELFLAGS)
GIT = git
GH = gh

all: MODULE.bazel.lock
	$(BAZEL) build $(BAZELFLAGS) -- //...

MODULE.bazel.lock:
	$(BAZEL) mod graph > /dev/null

# Test both default toolchain and versioned toolchains.
check:
	$(BAZEL) test $(BAZELFLAGS) -- //...
	$(BAZEL) test \
	  --extra_toolchains=@rules_elisp//elisp:emacs_30_toolchain \
	  $(BAZELFLAGS) -- //...
	$(BAZEL) test \
	  --extra_toolchains=@rules_elisp//elisp:emacs_31_toolchain \
	  $(BAZELFLAGS) -- //...

COVERAGE_BAZELFLAGS = $(BAZELFLAGS) --lockfile_mode=off
GENHTML ?= genhtml
GENHTMLFLAGS = --branch-coverage

coverage:
	$(BAZEL) coverage --combined_report=lcov $(COVERAGE_BAZELFLAGS) -- //...
	$(GENHTML) --output-directory=coverage-report $(GENHTMLFLAGS) \
	  -- bazel-out/_coverage/_coverage_report.dat

MAKEINFO ?= makeinfo

info:
	$(BAZEL) build --action_env='MAKEINFO=$(MAKEINFO)' $(BAZELFLAGS) \
	  -- //:bazel.el.info

prefix = /usr/local
datarootdir = $(prefix)/share
lispdir = $(datarootdir)/emacs/site-lisp
infodir = $(datarootdir)/info

install:
	$(INSTALL) -d -- '$(DESTDIR)$(lispdir)' '$(DESTDIR)$(infodir)'
	$(INSTALL_DATA) -- bazel.el '$(DESTDIR)$(lispdir)/bazel.el'
	$(BAZEL) build $(INSTALL_BAZELFLAGS) -- //:bazel
	$(INSTALL_DATA) -- bazel-bin/bazel.elc '$(DESTDIR)$(lispdir)/bazel.elc'
	$(BAZEL) build --action_env='MAKEINFO=$(MAKEINFO)' \
	  $(INSTALL_BAZELFLAGS) -- //:bazel.el.info
	$(INSTALL_DATA) -- bazel-bin/bazel.el.info \
	  '$(DESTDIR)$(infodir)/bazel.el.info'
	$(POST_INSTALL)
	install-info -- '$(DESTDIR)$(infodir)/bazel.el.info' \
	  '$(DESTDIR)$(infodir)/dir'
