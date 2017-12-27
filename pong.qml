import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

ApplicationWindow {
	id: window
	visible: true
	width: 200
	height: 200
	title: "Pong"

	ColumnLayout {
		focus: true
		Keys.onPressed: {
			if (event.key == Qt.Key_Left) {
				console.log("move left");
				event.accepted = true;
			}
		}
		//Keys.onLeftPressed: console.log("move Left")
		Text {
			text: window.height
			id: textField
		}
		Text {
			text: window.width
		}
	}
	Rectangle {
		id: "line"
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: 5
		color: "grey"
	}
	Text {
		color: "grey"
		anchors.topMargin: window.height/15
		anchors.top: parent.top
		anchors.right: parent.horizontalCenter
		anchors.rightMargin: window.height/15
		font.pointSize: window.height/5
		font.family: "Bit5x3"
		text: "99"
	}
	Text {
		color: "grey"
		anchors.topMargin: window.height/15
		anchors.top: parent.top
		anchors.left: parent.horizontalCenter
		anchors.leftMargin: window.height/15
		font.pointSize: window.height/5
		font.family: "Bit5x3"
		text: "2"
	}
	Rectangle {
		id: padleRight
		anchors.leftMargin: 10
		anchors.left: parent.left
		//anchors.verticalCenter: parent.verticalCenter
		y: 0
		width: 25
		height: (window.height * 3)/10
		color: "black"
	}
	Rectangle {
		id: padleLeft
		anchors.rightMargin: 10
		anchors.right: parent.right
		y: 90
		width: 25
		height: (window.height * 3)/10
		color: "green"
	}
	/*
	 Keys.UpPressed: {
		 padleRight.y: padleRight.y + 10
	 }
	 Keys.DownPressed: {
		 padleRight.y: padleRight.y - 10
	 }
	 */
}
