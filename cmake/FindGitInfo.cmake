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

# If the command line client executable is found the macro
#  GIT_WC_INFO(<dir> <var-prefix>)
# is defined to extract information of a git working copy at
# a given location.
#
# The macro defines the following variables:
#  <var-prefix>_WC_REVISION_HASH - Current SHA1 hash
#  <var-prefix>_WC_REVISION - Current SHA1 hash
#  <var-prefix>_WC_REVISION_NAME - Name associated with <var-prefix>_WC_REVISION_HASH
#  <var-prefix>_WC_URL - output of command `git config --get remote.origin.url'
#  <var-prefix>_WC_ROOT - Same value as working copy URL
#  <var-prefix>_WC_LAST_CHANGED_DATE - date of last commit
#  <var-prefix>_WC_GITSVN - Set to false
#  <var-prefix>_WC_LATEST_TAG - Latest tag found in history
#  <var-prefix>_WC_LATEST_TAG_LONG - <last tag>-<commits since then>-g<actual commit hash>
#
# ... and also the following ones if it's a git-svn repository:
#  <var-prefix>_WC_GITSVN - Set to True if it is a
#  <var-prefix>_WC_INFO - output of command `git svn info'
#  <var-prefix>_WC_URL - url of the associated SVN repository
#  <var-prefix>_WC_ROOT - root url of the associated SVN repository
#  <var-prefix>_WC_REVISION - current SVN revision number
#  <var-prefix>_WC_LAST_CHANGED_AUTHOR - author of last commit
#  <var-prefix>_WC_LAST_CHANGED_DATE - date of last commit
#  <var-prefix>_WC_LAST_CHANGED_REV - revision of last commit
#  <var-prefix>_WC_LAST_CHANGED_LOG - last log of base revision
#
# Example usage:
#   find_package(Git)
#   if(GIT_FOUND)
#    GIT_WC_INFO(${PROJECT_SOURCE_DIR} Project)
#    message("Current revision is ${Project_WC_REVISION_HASH}")
#    message("git found: ${GIT_EXECUTABLE}")
#   endif()
#

# Look for git. Respect the quiet and required flags passed to this module.
set(FIND_QUIETLY_FLAG "")
if (DEFINED GitInfo_FIND_QUIETLY)
    set(FIND_QUIETLY_FLAG "QUIET")
endif ()

set(FIND_REQUIRED_FLAG "")
if (DEFINED GitInfo_FIND_REQUIRED)
    set(FIND_REQUIRED_FLAG "REQUIRED")
endif ()

find_package(Git ${FIND_QUIETLY_FLAG} ${FIND_REQUIRED_FLAG})


if(GIT_FOUND)
  execute_process(COMMAND ${GIT_EXECUTABLE} --version
                  OUTPUT_VARIABLE git_version
                  ERROR_QUIET
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  if (git_version MATCHES "^git version [0-9]")
    string(REPLACE "git version " "" GIT_VERSION_STRING "${git_version}")
  endif()
  unset(git_version)

  macro(GIT_WC_INFO dir prefix)
    execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse --verify -q --short=7 HEAD
       WORKING_DIRECTORY ${dir}
       ERROR_VARIABLE GIT_error
       OUTPUT_VARIABLE ${prefix}_WC_REVISION_HASH
       OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(${prefix}_WC_REVISION ${${prefix}_WC_REVISION_HASH})
    if(NOT ${GIT_error} EQUAL 0)
      message(SEND_ERROR "Command \"${GIT_EXECUTBALE} rev-parse --verify -q --short=7 HEAD\" in directory ${dir} failed with output:\n${GIT_error}")
    else(NOT ${GIT_error} EQUAL 0)
      execute_process(COMMAND ${GIT_EXECUTABLE} name-rev ${${prefix}_WC_REVISION_HASH}
         WORKING_DIRECTORY ${dir}
         OUTPUT_VARIABLE ${prefix}_WC_REVISION_NAME
          OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif(NOT ${GIT_error} EQUAL 0)

    execute_process(COMMAND ${GIT_EXECUTABLE} config --get remote.origin.url
       WORKING_DIRECTORY ${dir}
       OUTPUT_VARIABLE ${prefix}_WC_URL
       OUTPUT_STRIP_TRAILING_WHITESPACE)

    execute_process(COMMAND ${GIT_EXECUTABLE} show -s --format="%ci" ${${prefix}_WC_REVISION_HASH}
       WORKING_DIRECTORY ${dir}
       OUTPUT_VARIABLE ${prefix}_show_output
       OUTPUT_STRIP_TRAILING_WHITESPACE)
    string(REGEX REPLACE "^([0-9][0-9][0-9][0-9]\\-[0-9][0-9]\\-[0-9][0-9]).*"
      "\\1" ${prefix}_WC_LAST_CHANGED_DATE "${${prefix}_show_output}")

    execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --abbrev=0
       WORKING_DIRECTORY ${dir}
       OUTPUT_VARIABLE ${prefix}_WC_LATEST_TAG
       OUTPUT_STRIP_TRAILING_WHITESPACE
       ERROR_QUIET)
    execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags
       WORKING_DIRECTORY ${dir}
       OUTPUT_VARIABLE ${prefix}_WC_LATEST_TAG_LONG
       OUTPUT_STRIP_TRAILING_WHITESPACE
       ERROR_QUIET)

    set(${prefix}_WC_GITSVN False)

    # Check if this git is likely to be a git-svn repository
    execute_process(COMMAND ${GIT_EXECUTABLE} config --get-regexp "^svn-remote"
      WORKING_DIRECTORY ${dir}
      OUTPUT_VARIABLE git_config_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )

    if(NOT "${git_config_output}" STREQUAL "")
      # In case git-svn is used, attempt to extract svn info
      execute_process(COMMAND ${GIT_EXECUTABLE} svn info
        WORKING_DIRECTORY ${dir}
        TIMEOUT 3
        ERROR_VARIABLE git_svn_info_error
        OUTPUT_VARIABLE ${prefix}_WC_INFO
        RESULT_VARIABLE git_svn_info_result
        OUTPUT_STRIP_TRAILING_WHITESPACE)

      if(${git_svn_info_result} EQUAL 0)
        set(${prefix}_WC_GITSVN True)
        string(REGEX REPLACE "^(.*\n)?URL: ([^\n]+).*"
          "\\2" ${prefix}_WC_URL "${${prefix}_WC_INFO}")
        string(REGEX REPLACE "^(.*\n)?Revision: ([^\n]+).*"
          "\\2" ${prefix}_WC_REVISION "${${prefix}_WC_INFO}")
        string(REGEX REPLACE "^(.*\n)?Repository Root: ([^\n]+).*"
          "\\2" ${prefix}_WC_ROOT "${${prefix}_WC_INFO}")
        string(REGEX REPLACE "^(.*\n)?Last Changed Author: ([^\n]+).*"
          "\\2" ${prefix}_WC_LAST_CHANGED_AUTHOR "${${prefix}_WC_INFO}")
        string(REGEX REPLACE "^(.*\n)?Last Changed Rev: ([^\n]+).*"
          "\\2" ${prefix}_WC_LAST_CHANGED_REV "${${prefix}_WC_INFO}")
        string(REGEX REPLACE "^(.*\n)?Last Changed Date: ([^\n]+).*"
          "\\2" ${prefix}_WC_LAST_CHANGED_DATE "${${prefix}_WC_INFO}")
      endif(${git_svn_info_result} EQUAL 0)
    endif(NOT "${git_config_output}" STREQUAL "")

    # If there is no 'remote.origin', default to "NA" value and print a warning message.
    if(NOT ${prefix}_WC_URL)
      message(WARNING "No remote origin set for git repository: ${dir}" )
      set( ${prefix}_WC_URL "NA" )
    else()
      set(${prefix}_WC_ROOT ${${prefix}_WC_URL})
    endif()

  endmacro(GIT_WC_INFO)


  # Get the version info from the latest tag and set it as the projects version.
  #
  # WARNING: This macro overwrites previously set versions.
  #
  macro(GIT_VERSION_INFO)
    if (EXISTS "${PROJECT_SOURCE_DIR}/.git")
      find_package(GitInfo REQUIRED)
      git_wc_info(${PROJECT_SOURCE_DIR} GIT)

    # If git is not available (e.g. this git was packed as .tar.gz), try to read
    # the version-info from a hidden file in the root directory. This file
    # should not be versioned, but added at packaging time.
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/.version")
      file(READ "${PROJECT_SOURCE_DIR}/.version" GIT_WC_LATEST_TAG_LONG)

    # If no version could be gathered by git or the version file, print a
    # warning, so the user has to define a version in the backup version file.
    else ()
      message(FATAL_ERROR "No version provided by .version file")
    endif ()

    if (GIT_WC_LATEST_TAG_LONG MATCHES
        "^([^0-9]*)([0-9]+)[.]([0-9]+)(.*)-([0-9]+)-")
      set(prefix ${CMAKE_PROJECT_NAME})

      set(${prefix}_VERSION ${GIT_WC_LATEST_TAG_LONG} CACHE STRING "" FORCE)
      set(${prefix}_MAJOR_VERSION ${CMAKE_MATCH_2} CACHE STRING "" FORCE)
      set(${prefix}_MINOR_VERSION ${CMAKE_MATCH_3} CACHE STRING "" FORCE)
      set(${prefix}_PATCH_VERSION ${CMAKE_MATCH_5} CACHE STRING "" FORCE)

      mark_as_advanced(${prefix}_VERSION ${prefix}_MAJOR_VERSION
                       ${prefix}_MINOR_VERSION ${prefix}_PATCH_VERSION)
    else ()
      message(FATAL_ERROR "Invalid version info: '${GIT_WC_LATEST_TAG_LONG}'.")
	endif ()
  endmacro()
endif(GIT_FOUND)
