# CMake-gitinfo

[![Travis](https://img.shields.io/travis/RWTH-HPC/CMake-gitinfo/master.svg?style=flat-square)](https://travis-ci.org/RWTH-HPC/CMake-gitinfo)
[![](https://img.shields.io/github/issues-raw/RWTH-HPC/CMake-gitinfo.svg?style=flat-square)](https://github.com/RWTH-HPC/CMake-gitinfo/issues)
[![](https://img.shields.io/badge/license-modified_BSD-blue.svg?style=flat-square)](LICENSE)

CMake module to get information about current git status.


## Usage

To use [FindGitInfo.cmake](cmake/FindGitInfo.cmake), simply add this repository as git submodule into your own repository
```Shell
mkdir externals
git submodule add git://github.com/RWTH-HPC/CMake-gitinfo.git externals/CMake-gitinfo
```
and adding ```externals/cmake-gitinfo/cmake``` to your ```CMAKE_MODULE_PATH```
```CMake
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/externals/cmake-gitinfo/cmake" ${CMAKE_MODULE_PATH})
```

If you don't use git or dislike submodules you can copy the [FindGitInfo.cmake](cmake/FindGitInfo.cmake) files into your repository. *Be careful and keep updates in mind!*

Now you can simply run ```find_package``` in your CMake files:
```CMake
find_package(GitInfo)
git_wc_info(${PROJECT_SOURCE_DIR} VARPREFIX)

message(STATUS "The current git hash is ${VARPREFIX_WC_REVISION_HASH}")
```


## Available variables

| variable  | description |
|-----------|-------------|
| ``<PREFIX>_WC_REVISION_HASH`` | Current SHA1 hash |
| ``<PREFIX>_WC_REVISION_NAME`` | Name associated with ``<PREFIX>_WC_REVISION_HASH`` |
| ``<PREFIX>_WC_LAST_CHANGED_DATE`` | Date of last commit |
| ``<PREFIX>_WC_LATEST_TAG`` | Latest tag found in history |
| ``<PREFIX>_WC_LATEST_TAG_LONG`` | Latest tag found in history as long version. |
| ``<PREFIX>_WC_GITSVN`` | Indicate if git is a git svn |

The value of the following variables depends on ``<PREFIX>_WC_GITSVN``:

| variable  | ``<PREFIX>_WC_GITSVN`` ``true`` | ``<PREFIX>_WC_GITSVN`` ``false`` |
|-----------|-------------|-------------|
| ``<PREFIX>_WC_REVISION`` | Current SVN revision number | Same as ``<PREFIX>_WC_REVISION_HASH`` |
| ``<PREFIX>_WC_URL``, ``<PREFIX>_WC_ROOT`` | URL of the associated SVN repository | Output of command ``git config --get remote.origin.url`` |
| ``<PREFIX>_WC_INFO`` | Output of command ``git svn info`` | not available |
| ``<PREFIX>_WC_LAST_CHANGED_AUTHOR`` | Author of last commit | not available |
| ``<PREFIX>_WC_LAST_CHANGED_REV`` | Revision of last commit | not available |
| ``<PREFIX>_WC_LAST_CHANGED_LOG`` | Last log of base commit | not available |


## Additional macros

* **git_version_info(PREFIX)**

  This macro sets your projects `*_VERSION` variables by versions found by `git describe --tags`. All you need to do is setting a tag like `vX.Y` and you'll get a version like `vX.Y-Z-<hash>`, were `Z` is the number of commits since the last tag and `hash` the short hash of the current `HEAD`. All formats of tags are supported, but they have to include two numbers separated by a dot.

  You may pass a combination of these variables to the `VERSION` argument of `project`, e.g. `${NAME_VERSION_MAJOR}.${NAME_VERSION_MINOR}.${NAME_VERSION_PATCH}`.

  Example:
  ```CMake
  find_package(Gitinfo)
  git_version_info(NAME)

  message(STATUS "Configuring NAME version: ${NAME_VERSION}
                 "(${NAME_VERSION_MAJOR}.${NAME_VERSION_MINOR}.
                 "${NAME_VERSION_PATCH})")
  ```
  ```
  ~:$git describe --tags
  v1.5-beta-3-g7184473
  ~:$cmake ..
  [...]
  -- Configuring NAME version v1.5-beta-3-g7184473 (1.5.3)
  ```

  For packaging a `.version` file should be added, containing the output of `git describe --tags` of the packed git version. The `project-version-files-${PREFIX}` target generates this file, but is excluded from main. To generate all version files (even those of subprojects) before deploy, just depend on `project-version-files`. A list of all generated version files is accessible via the `GIT_GENERATED_VERSION_FILES` `GLOBAL` property. *NOTE: You may want to include `CPackDeploy` after `CPack` to add the `package_deploy` target, which handles source packaging with version files automatically.

  If even no `.version` file could be found, the version won't be set and may be empty. Like in `find_package` you may add the `REQUIRED` parameter to `git_version_info`, so it will print an error message instead of a warning, which will stop the execution of `CMake`.


## Contribute

Anyone is welcome to contribute. Simply fork this repository, make your changes **in an own branch** and create a pull-request for your change. Please do only one change per pull-request.

You found a bug? Please fill out an [issue](https://github.com/RWTH-HPC/CMake-gitinfo/issues) and include any data to reproduce the bug.


#### Contributors

* [Jean-Christophe Fillion-Robin](https://github.com/jcfr)
* [Alexander Haase](https://github.com/alehaa)
