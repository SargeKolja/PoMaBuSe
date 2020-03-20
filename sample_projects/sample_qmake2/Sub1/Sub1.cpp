#include <QApplication>
#include <QPushButton>
#include <QTranslator>
#include <QDebug>

#include <Sub1.hpp>
#include <Sub2.h>
#include <Sub3.hpp>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QTranslator Lang;
    Lang.load("mainlang_de"); // or "..._en"
    app.installTranslator( &Lang );

    QString NonSense( QObject::tr("Give me a Number","just some text without any meaning") );
    qDebug() << "Text1=" << NonSense;
    int x = Sub2_foo( qPrintable( NonSense ) );

    QString moreNonSense( QString( QObject::tr("Hello %1\n","%1 gets replaced with a noun ('world','moon',...) at runtime") )
                             .arg( QObject::tr("world","the noun") ) );

    qDebug() << "Text2=" << moreNonSense;
    QString Greetings = Sub3_foo( x, moreNonSense );
    qDebug() << "Greet=" << Greetings;

    QPushButton hello( Greetings );

    hello.show();
    return app.exec();
}
