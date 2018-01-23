################################################################################
#
#  Program: FindGitInfo from Slicer
#
#  Copyright (c) Kitware Inc.
#
#  See COPYRIGHT.txt
#  or http://www.slicer.org/copyright/copyright.txt for details.
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  This file was originally developed by Jean-Christophe Fillion-Robin,
#  Kitware Inc. and was partially funded by NIH grant 3P41RR013218-12S1
#
################################################################################


# project information
cmake_minimum_required(VERSION 2.8)

if (POLICY CMP0048)
  cmake_policy(SET CMP0048 NEW)
endif()

project("test" C)

# cmake configuration
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})


# search for FindGitInfo
find_package(GitInfo REQUIRED)
git_wc_info(${PROJECT_SOURCE_DIR} VAR)

message(STATUS "GIT_WC_INFO:")
message(STATUS "  WC_REVISION_HASH:     ${VAR_WC_REVISION_HASH}")
message(STATUS "  WC_REVISION:          ${VAR_WC_REVISION}")
message(STATUS "  WC_REVISION_NAME:     ${VAR_WC_REVISION_NAME}")
message(STATUS "  WC_URL:               ${VAR_WC_URL}")
message(STATUS "  WC_ROOT:              ${VAR_WC_ROOT}")
message(STATUS "  WC_LAST_CHANGED_DATE: ${VAR_WC_LAST_CHANGED_DATE}")
message(STATUS "  WC_LATEST_TAG:        ${VAR_WC_LATEST_TAG}")
message(STATUS "  WC_LATEST_TAG_LONG:   ${VAR_WC_LATEST_TAG_LONG}")


git_version_info(NAME)
message(STATUS "Configuring NAME version: ${NAME_VERSION} "
               "(${NAME_VERSION_MAJOR}.${NAME_VERSION_MINOR}"
               ".${NAME_VERSION_PATCH}.${NAME_VERSION_TWEAK})")
