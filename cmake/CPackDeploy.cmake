################################################################################
#
#  This file is part of CMake-gitinfo.
#
#  Copyright (c) Kitware Inc.
#  Copyright (c) 2018 RWTH Aachen University, Federal Republic of Germany
#
#  See the LICENSE file in the package base directory for details.
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
################################################################################

# Add a custom deploy target.
#
# Projects using the `git_version_info` macro of the `FindGitInfo` module
# require a generated version file for builds without git, i.e. build from
# packed sources.
#
# Instead of using the default 'package_source' from `CPack`, the
# 'package_deploy' target adds neccessary files for building the project (and
# its included dependencies if these use `git_version_info`, too) without having
# access to the git repository by including generated version files.
#
# NOTE: For packing the deploy package, some assets need to be generated inside
#       the source directory. These will be removed automatically after
#       packaging.
get_property(VERSION_FILES GLOBAL PROPERTY GIT_GENERATED_VERSION_FILES)
add_custom_target(package_deploy
            COMMAND "${CMAKE_CPACK_COMMAND}"
                     "--config" "./CPackSourceConfig.cmake"
                     "${CMAKE_CURRENT_BINARY_DIR}/CPackSourceConfig.cmake"
            COMMENT "Packaging files ..."
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        DEPENDS project-version-files)
add_custom_command(TARGET package_deploy POST_BUILD
    COMMAND rm -f ${VERSION_FILES}
    COMMENT "Cleaning up package assets ...")
