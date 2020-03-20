TEMPLATE = lib
TARGET = sub3  # ./Sub3/libsub3.a

DEPENDPATH += .
INCLUDEPATH += .

CONFIG += staticlib
CONFIG -= qtcore
CONFIG -= gui
CONFIG -= qml

CODECFORTR += UTF8

unix:DEFINES += __LINUX__
win32:DEFINES += __WIN32__

DEFINES += DEBUG

CONFIG += c++11
QMAKE_CXXFLAGS += -std=c++11

# unix	{
#	LIBS += -Wl,-v libsample_additional.a libs_for_linux.a -ldl
#	} win32-g++ {
#	LIBS += -Wl, -v libsame_syntax.a libin_gccwin.a -ldl
#	}

HEADERS +=	\
	Sub3.hpp

SOURCES +=	\
	Sub3.cpp

#	TRANSLATIONS = \
#		languages/libsub3_en.ts \
#		languages/libsub3_en.de \
#	

