cmake_minimum_required(VERSION 3.2.2)

if(NOT SMOKE_QT_VERSION)
   project(commonqt LANGUAGES CXX)
   set(COMMONQT commonqt)
   set(SMOKE_QT_VERSION 5)
elseif (${SMOKE_QT_VERSION} EQUAL 6) 
   project(commonqt6 LANGUAGES CXX)
   set(COMMONQT commonqt6)
endif()	 

set(CMAKE_INCLUDE_CURRENT_DIR OFF)
set(CMAKE_AUTOMOC OFF)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QT_VERSION Qt${SMOKE_QT_VERSION})

if (Qt5_DIR)
   string(REPLACE "/lib/cmake/Qt5" "" Qt_ROOT_DIR ${Qt5_DIR})
elseif(Qt6_DIR)   
   string(REPLACE "/lib/cmake/Qt6" "" Qt_ROOT_DIR ${Qt6_DIR})
endif()   


find_package(${QT_VERSION} COMPONENTS Core REQUIRED)
find_package(${QT_VERSION} 
    COMPONENTS
    Gui
    Widgets	
    REQUIRED
)
find_package(${QT_VERSION}PrintSupport REQUIRED)
find_package(Smoke REQUIRED )

if (Qt6_FOUND)
   set(QT_CORE_VERSION ${Qt6Core_VERSION})
else()
   set(QT_CORE_VERSION ${Qt5Core_VERSION})
endif()	

message(STATUS "Found ${QT_VERSION}: version ${QT_CORE_VERSION}") 

message(STATUS "Found ${SMOKE_LIB}/include")

 
include_directories(${Qt_ROOT_DIR}/include/QtCore/${QT_CORE_VERSION} 
                    ${Qt_ROOT_DIR}/include/QtCore/${QT_CORE_VERSION}/QtCore 
	            ${SMOKE_LIB}/include)

link_directories(${SMOKE_LIB}/lib)

add_library(${COMMONQT} SHARED commonqt.cpp)

if (Qt6_FOUND)
   target_link_libraries(${COMMONQT} smokeqt6core smokebase ${QT_VERSION}::Widgets ${QT_VERSION}::PrintSupport)
else()
   target_link_libraries(${COMMONQT} smokeqtcore smokebase ${QT_VERSION}::Widgets ${QT_VERSION}::PrintSupport)
endif()  

string(REPLACE "." ";" VERSION_LIST ${QT_CORE_VERSION})
list(GET VERSION_LIST 0 VERSION_MAJOR)
list(GET VERSION_LIST 1 VERSION_MINOR)
list(GET VERSION_LIST 2 VERSION_PATCH)

set_target_properties(${COMMONQT}
    PROPERTIES
    VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
    SOVERSION ${VERSION_MAJOR}
    CXX_STANDARD 17
)

if(WIN32)
   install( TARGETS ${COMMONQT} RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
else()
   install( TARGETS ${COMMONQT} RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
endif()

# Taken from https://gitlab.kitware.com/cmake/community/-/wikis/FAQ#can-i-do-make-uninstall-with-cmake
# uninstall target
if(NOT TARGET uninstall)
  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

  add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
endif()
   
