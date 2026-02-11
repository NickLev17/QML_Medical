#ifndef CONTACTSMODEL_H
#define CONTACTSMODEL_H
#include <QAbstractListModel>
#include <QObject>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlTableModel>
#include <QAbstractTableModel>
#include <QStringList>
class MyModel : public QSqlTableModel
{
    Q_OBJECT
    const QString driverName="QSQLITE";
public:
    enum ContactRole {
        DateRole = Qt::UserRole + 1,
        ColorRole
    };
    explicit MyModel(QObject *parent = nullptr);
    bool m_state;
    Q_PROPERTY(bool state READ state WRITE setState NOTIFY changeState)
    void setState(bool newState);
    bool state() const;

    ~MyModel();
    Q_INVOKABLE void connectionDatabase();
    Q_INVOKABLE void initialModel(const QString& nameTable );
    Q_INVOKABLE void disconnectDatabase();
    Q_INVOKABLE QStringList getTables() const;
    Q_INVOKABLE QStringList getColumnTable() const;
    Q_INVOKABLE void sortTable(const int& column,Qt::SortOrder order);
    Q_INVOKABLE void selectTable(const QString& tableName);
    Q_INVOKABLE bool addRecord(const QString& name, const QString& category);
    Q_INVOKABLE bool removeRecord(const QString& name);

    virtual  int columnCount(const QModelIndex & parent) const override;
    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QVariant data(const QModelIndex &index, int role) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void changeState();


private:

    QSqlDatabase m_db;
    QSqlTableModel *m_model;
};

#endif
