TEMPLATE = app
TARGET = sample_qmake

equals(QT_MAJOR_VERSION, 5): QT += widgets
equals(QT_MAJOR_VERSION, 4): QT += gui 

INCLUDEPATH += .

DEFINES += QT_DEPRECATED_WARNINGS

# Input
SOURCES += helloworld_qt.cpp
