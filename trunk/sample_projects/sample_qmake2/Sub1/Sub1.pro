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


unix	{
	LIBS += -Wl,-v \
	-L../Sub2 -lsub2 \
	-L../Sub3 -lsub3 \
	-ldl
	} win32-g++ {
	LIBS += -Wl,-v \
	-L../Sub2 -lsub2 \
	-L../Sub3 -lsub3 \
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
	Sub1.hpp

SOURCES += \
	Sub1.cpp

CODECFORTR += UTF8

TRANSLATIONS = \
	languages/mainlang_en.ts \
	languages/mainlang_de.ts
	
