import QtQuick 2.2
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Example 1.0

ApplicationWindow {
    visible: true
    width: 200
    height: 200
    title: "Pong"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        TextField {
            placeholderText: "Input"
            text: "0"
            id: textField
        }
				RowLayout {
					width: parent.width
					Button {
						text: '+'
						implicitWidth: height
						onClicked: fizzBuzz.plus()
					}
					Button {
						text: '-'
						implicitWidth: height
						onClicked: fizzBuzz.minus()
					}
				}
        Text {
            id: text
            text: fizzBuzz.result
        }
        Button {
            text: 'Quit'
            onClicked: fizzBuzz.quit()
        }
        Text {
            id: lastFizzBuzz
        }
    }
		//Box {
		//	// TODO
		//}
}
