#include <QString>

QString Sub3_foo(int x, const QString& dummyStr)
{
    QString Result( "Hello Zero!\n" );
    if( x > 0)
	return dummyStr;
    return Result;
}
