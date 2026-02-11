import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import mymodel 1.0

Window {
    id: root
    width: 1120
    height: 650
    visible: true
    title: "Регистратура"
    color: "#dde6ef"

    MyModel {
        id: _model
        state: false
    }

    GridLayout {
        anchors.fill: parent
        rowSpacing: 10
        columnSpacing: 10
        columns: 2
        rows: 3

        Rectangle {
            id: rec_table
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10
            color: "#f8f9fa"
            Layout.minimumWidth: 800

            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                anchors.margins: 10


                TableView {
                    id: _table
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    columnWidthProvider: function(column) {
                        let totalCols = _model ? _model.columnCount() : 1
                        return width / totalCols
                    }

                    model: null
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.horizontal: ScrollBar { }
                    ScrollBar.vertical: ScrollBar { }

                    delegate: Rectangle {
                        implicitWidth: 150
                        implicitHeight: 35
                        color: ageColor
                        border.color: "black"

                        Text {
                            anchors.centerIn: parent
                            text: tableData
                        }
                    }
                }
            }
        }
        ColumnLayout
        {
            anchors.top: parent.top
            spacing: 10
            Layout.preferredWidth: 220

            anchors.margins: 10
            Text {
                text: _comboBox_table.currentText
                color:"black"
                font.pointSize: 12
            }
            Rectangle
            {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 2
                color: "#ffffff"
            }
            Button {id: _startButton
                Layout.preferredWidth: 200
                Layout.preferredHeight: 50
                text: _model.state ? "ОТКЛЮЧИТЬ БД" : "ПОДКЛЮЧИТЬ БД"

                onClicked: {
                    if (!_model.state) {
                        _model.connectionDatabase()
                        if (_model.state) {
                            _model.initialModel("PATIENTS")
                            _table.model = _model
                            _comboBox_table.model = _model.getTables()
                            _model.selectTable("PATIENTS")
                            _comboBox_Column.model = _model.getColumnTable()
                            let index = _comboBox_table.find("PATIENTS")
                            _comboBox_table.currentIndex = index
                        }
                    } else {
                        _model.disconnectDatabase()
                        _table.model = null
                        _comboBox_table.model = null
                        _comboBox_Column.model = null
                    }
                }
            }

            Button
            { id: btn_addRecord
                Layout.preferredWidth: 200
                Layout.preferredHeight: 50
                text: "Добавить запись"
                onClicked:
                {
                    if((_textFieldCategory.text=="") || (_textFieldName.text==""))
                    {
                        _txtStatusBar.text="Заполните поля для корректной записи данных"
                    }
                    else
                    {
                        _model.selectTable(_comboBox_table.currentText)
                        if(_model.addRecord(_textFieldName.text,_textFieldCategory.text))
                        {
                            _model.selectTable(_comboBox_table.currentText)
                            _txtStatusBar="Данные успешно записаны в БД"
                        }
                        else
                        {
                            _txtStatusBar="Записать данные в базу не удалось, попробуйте снова"
                        }
                    }
                }
            }

            Button
            { id: btn_removeRecord
                Layout.preferredWidth: 200
                Layout.preferredHeight: 50
                text: "Удалить запись"
                onClicked:
                {
                    if(_textFieldName.text!="")
                    {
                        _txtStatusBar.text="Заполните поля для корректной записи данных"
                        if( _model.removeRecord(_textFieldName.text))
                        {
                            _txtStatusBar.text=" Данные успешно удалены"
                            _model.selectTable(_comboBox_table.currentText)
                        }
                        else
                        {
                            _txtStatusBar.text="Данные отсутствуют в текущей БД"
                        }

                    }
                    else
                    {
                        _txtStatusBar.text="Введите в поле ввода имя, чью запись хотите удалить "
                    }
                }
            }
            Text {
                text: "Сортировка"
                color:"black"
                font.pointSize: 12
            }

            Rectangle
            {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 2
                color: "#ffffff"
            }
            Button
            { id: btn_sortAscend
                text: "Сортировать вверх"
                Layout.preferredWidth: 200
                Layout.preferredHeight: 50

                onClicked:
                {
                    _model.sortTable(_comboBox_Column.currentIndex,Qt.AscendingOrder) // сортировка
                }

            }

            Button
            { id: btn_sortDescend
                Layout.preferredWidth: 200
                Layout.preferredHeight: 50
                text: "Сортировать вниз"
                onClicked:
                {
                    _model.sortTable(_comboBox_Column.currentIndex,Qt.DescendingOrder) // сортировка
                }

            }

            Button
            { id: btn_sortCancell
                Layout.preferredWidth: 200
                Layout.preferredHeight: 50
                text: "Отмена сортировки"
                onClicked:
                {
                    _model.sortTable(-1,Qt.DescendingOrder)
                }

            }

            ColumnLayout {
                Layout.preferredWidth: 220
                spacing: 5
                Layout.alignment: Qt.AlignRight

                Text {
                    horizontalAlignment: Text.AlignHCenter
                    color: "black"
                    font.pointSize: 12
                    text: qsTr("Критерий сортировки")
                    Layout.alignment: Qt.AlignLeft
                }
                Rectangle
                {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 2
                    color: "#ffffff"
                }
                ComboBox {
                    id: _comboBox_Column
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 30
                    model: null

                    delegate: ItemDelegate {
                        contentItem: Text {
                            text: modelData
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            Rectangle
            {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 2
                color: "#ffffff"
            }
        }

        RowLayout {
            Layout.columnSpan: 2
            Layout.fillWidth: true

            ColumnLayout {
                Layout.preferredWidth: 220
                spacing: 5
                Layout.alignment: Qt.AlignLeft
                Text {
                    horizontalAlignment: Text.AlignHCenter
                    color: "black"
                    font.pointSize: 12
                    text: qsTr("Выбор таблицы")
                    Layout.alignment: Qt.AlignHCenter
                }

                ComboBox {
                    id: _comboBox_table
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 30
                    model: null
                    delegate: ItemDelegate {
                        contentItem: Text {
                            text: modelData
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    onActivated: {
                        _model.selectTable(currentText)
                        _comboBox_Column.model = _model.getColumnTable()
                    }
                }
            }

            Item { width:100 }

            TextField {
                id: _textFieldName
                placeholderText: qsTr("Введите имя")
            }
            Item { width:100 }
            TextField {
                id: _textFieldCategory
                placeholderText: qsTr("Введите категорию")
            }
        }

        Rectangle {
            Layout.columnSpan: 2
            id: _statusBar
            Layout.fillWidth: root.width
            Layout.preferredHeight: 25
            color: "lightgray"
            border.color: "black"

            Text {
                id: _txtStatusBar
                anchors.centerIn: parent
                anchors.verticalCenter: parent.verticalCenter
            }
        }



    }

    Connections {
        target: _model
        function onStateChanged() {
            _txtStatusBar.text = _model.state ? "Отключить БД" : "Подключиться к БД"

        }
    }
}
