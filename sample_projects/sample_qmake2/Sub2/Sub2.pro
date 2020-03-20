TEMPLATE = lib
TARGET = sub2  # ./Sub2/libsub2.a

DEPENDPATH += .
INCLUDEPATH += .

CONFIG += staticlib
CONFIG -= qtcore
CONFIG -= gui
CONFIG -= qml

unix:DEFINES += __LINUX__
win32:DEFINES += __WIN32__

DEFINES += DEBUG

# unix	{
#	LIBS += -Wl,-v libsample_additional.a libs_for_linux.a -ldl
#	} win32-g++ {
#	LIBS += -Wl, -v libsame_syntax.a libin_gccwin.a -ldl
#	}

HEADERS +=	\
	Sub2.h

SOURCES +=	\
	Sub2.c

