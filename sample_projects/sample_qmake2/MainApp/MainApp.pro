TEMPLATE = app
TARGET = sample_qmake_with_subs

equals(QT_MAJOR_VERSION, 5): QT += widgets
equals(QT_MAJOR_VERSION, 4): QT += gui 

DEPENDPATH += .
INCLUDEPATH += .

unix:DEFINES += __LINUX__
win32:DEFINES += __WIN32__

DEFINES += DEBUG
DEFINES += QDEBUG
DEFINES += QT_DEPRECATED_WARNINGS

CONFIG += c++11
QMAKE_CXXFLAGS += -std=c++11


unix:debug {
	LIBS += -Wl,-v \
	-L../Sub2/debug -lsub2 \
	-L../Sub3/debug -lsub3 \
	-ldl
	} unix:release {
	LIBS += -Wl,-v \
	-L../Sub2/release -lsub2 \
	-L../Sub3/release -lsub3 \
	-ldl
	} win32-g++:debug {
	LIBS += -Wl,-v \
	-L../Sub2/debug -lsub2 \
	-L../Sub3/debug -lsub3 \
	-ldl
	} win32-g++:release {
	LIBS += -Wl,-v \
	-L../Sub2/release -lsub2 \
	-L../Sub3/release -lsub3 \
	-ldl
	}


INCLUDEPATH += .
INCLUDEPATH += ../Sub2
INCLUDEPATH += ../Sub3


unix	{
	INCLUDEPATH += /usr/local/include
	INCLUDEPATH += /usr/include
	} win32-g++ {
	INCLUDEPATH += /usr/local/include
	INCLUDEPATH += /usr/include
	}

# Input
HEADERS += \
	MainApp.hpp

SOURCES += \
	MainApp.cpp

CODECFORTR += UTF8

TRANSLATIONS = \
	languages/mainlang_en.ts \
	languages/mainlang_de.ts
	
