# CMake-gitinfo

[![Travis](https://img.shields.io/travis/RWTH-ELP/CMake-gitinfo/master.svg?style=flat-square)](https://travis-ci.org/RWTH-ELP/CMake-gitinfo) [![](https://img.shields.io/github/issues-raw/RWTH-ELP/CMake-gitinfo.svg?style=flat-square)](https://github.com/RWTH-ELP/CMake-gitinfo/issues)
[![modified BSD license](http://img.shields.io/badge/license-modified BSD-blue.svg?style=flat-square)](LICENSE)

CMake module to get information about current git status.


## Usage

To use [FindGitInfo.cmake](cmake/FindGitInfo.cmake), simply add this repository as git submodule into your own repository
```Shell
mkdir externals
git submodule add git://github.com/RWTH-ELP/CMake-gitinfo.git externals/CMake-gitinfo
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

## Contribute

Anyone is welcome to contribute. Simply fork this repository, make your changes **in an own branch** and create a pull-request for your change. Please do only one change per pull-request.

You found a bug? Please fill out an [issue](https://github.com/RWTH-ELP/CMake-gitinfo/issues) and include any data to reproduce the bug.


#### Contributors

* [Jean-Christophe Fillion-Robin](https://github.com/jcfr)
* [Alexander Haase](https://github.com/alehaa)
