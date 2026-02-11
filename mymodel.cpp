#include "mymodel.h"
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlError>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QModelIndex>
#include <QVariant>
#include <QDate>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlTableModel>
#include <QAbstractTableModel>
#include <QSqlRecord>
MyModel::MyModel(QObject *parent)
    : QSqlTableModel{parent} {

    m_model=nullptr;
}

MyModel::~MyModel()
{
}

void MyModel::connectionDatabase()
{
    m_db=QSqlDatabase::addDatabase(driverName);
    m_db.setDatabaseName("INTFETAL.sqlite");
    if(!m_db.open())
    {
        QSqlError err=m_db.lastError();
        setState(false);
        return;
    }
    setState(true);
}

void MyModel::initialModel(const QString& nameTable)
{
    m_model=new QSqlTableModel(this,m_db);
    m_model->setTable(nameTable);
    m_model->select();
}

void MyModel::disconnectDatabase()
{
    delete m_model;
    m_model=nullptr;
    m_db.close();
    setState(false);
}

int MyModel::columnCount(const QModelIndex &parent) const
{
    return  m_model->columnCount();
}


int MyModel::rowCount(const QModelIndex &parent) const
{
    return m_model->rowCount();
}

QVariant MyModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return QVariant();
    switch (role) {
    case DateRole:
        return m_model->data(index.sibling(index.row(), index.column()), Qt::DisplayRole);  // колонка 0
    case ColorRole:
    {
        if(m_model->tableName()=="PATIENTS")
        {
            QString tmp=m_model->data(index.sibling(index.row(), 1), Qt::DisplayRole).toString();
//            tmp.remove(0,6);
//            tmp.remove(4,tmp.size());
            QDate data;
            QString currentAge= data.currentDate().toString();
            currentAge.remove(0,currentAge.size()-4);

            int age=currentAge.toUInt()-tmp.toUInt();
            if (age <= 10) return "yellow";
            else if ((age>10)&& (age <= 20)) return "lightgreen";
            else if ((age>20) && (age <= 40)) return "green";
            else if ((age>40) && (age <= 60)) return "pink";
            else if (age>60) return "red";
        }
        else if(m_model->tableName()=="DOCTORS")
        {
            QString category=m_model->data(index.sibling(index.row(), 1), Qt::DisplayRole).toString();
            if (category== "Терапевт") return "yellow";
            else if (category== "Хирург") return "lightgreen";
            else if (category== "Гастроэнтеролог") return "green";
            else if (category== "Офтальмолог") return "darkCyan";
            else if (category== "Невролог") return "pink";
            else if (category== "Отоларинголог") return "grey";
        }
        else return "white";


    }
    default:
        return m_model->data(index, role);
    }
}


QHash<int, QByteArray> MyModel::roleNames() const
{
    QHash <int, QByteArray> roles;

    roles[DateRole] = "tableData";
    roles[ColorRole] = "ageColor";
    return roles;
}

QStringList MyModel::getTables() const
{
    return m_db.tables();
}

QStringList MyModel::getColumnTable() const
{
    QStringList list;
    for(int i=0; i<m_model->columnCount();i++)
    {
        list<<m_model->headerData(i, Qt::Horizontal, Qt::DisplayRole).toString();
    }
    return list;
}

void MyModel::sortTable(const int& column,Qt::SortOrder order)
{    m_model->sort(column,order);
     beginResetModel();
      m_model->select();
       endResetModel();
}

void MyModel::selectTable(const QString& tableName)
{      m_model->setTable(tableName);
       beginResetModel();
          m_model->select();
             endResetModel();
}

bool MyModel::removeRecord(const QString& name)
{
    int rows = m_model->rowCount();
    for(int i=rows - 1;i>0; i--)
    {
        QModelIndex index = m_model->index(i, 0);
        QString value = m_model->data(index).toString();

        if(value == name) {
            m_model->removeRow(i);
            m_model->submitAll();
            beginResetModel();
            m_model->select();
            endResetModel();
            return true;
        }
    }
    return false;
}

bool MyModel::addRecord( const QString &name, const QString &category)
{
    m_model->select();
    int row = m_model->rowCount();
    if(!m_model->insertRow(row)) {
        return false;
    }
    m_model->setData(m_model->index(row, 0), name);
    m_model->setData(m_model->index(row, 1), category);
    bool success = m_model->submitAll();
    beginResetModel();
    m_model->select();
    endResetModel();
    return success;
}

void MyModel::setState(bool newState)
{
    m_state=newState;
    emit changeState();
}

bool MyModel::state() const
{
    return m_state;
}

