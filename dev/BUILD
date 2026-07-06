# Copyright 2026 Philipp Stephani
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@bazel_skylib//rules:select_file.bzl", "select_file")
load("@rules_pkg//pkg:tar.bzl", "pkg_tar")

package(
    default_applicable_licenses = ["//:license"],
    default_visibility = ["//visibility:private"],
)

licenses(["notice"])

pkg_tar(
    name = "release",
    srcs = [
        ":bazel.elc",
        "//:bazel.el",
        "//:bazel.el.info",
    ],
    mode = "0444",
    tags = ["manual"],
)

select_file(
    name = "bazel.elc",
    srcs = "//:bazel",
    subpath = "bazel.elc",
)
