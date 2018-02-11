import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import Pong 1.0

ApplicationWindow {
	id: window
	visible: true
	width: Screen.desktopAvailableWidth * 0.8
	height: Screen.desktopAvailableHeight * 0.8
	title: "Pong"

	function rel_to_abs_x(x) {
		var width = window.width - paddleLeft.width - paddleRight.width - ball.width;
		return (x * width/100) + paddleLeft.width;
	}
	function rel_to_abs_y(y) {
		var height = window.height - ball.height
		return y * height/100
	}
	function abs_to_rel_x(x) {
		x -= paddleLeft.width
		var width = window.width - paddleLeft.width - paddleRight.width - ball.width;
		return x * 100/width
	}
	function abs_to_rel_y(y) {
		var height = window.height - ball.height
		return y * 100/height
	}

	Rectangle {
		// line in the middle
		// handles input
		focus: true
		Keys.onPressed: {
			if (event.key == Qt.Key_W) {
				frame.leftPaddle.down()
				event.accepted = true;
			} else if (event.key == Qt.Key_S) {
				frame.leftPaddle.up()
				event.accepted = true;
			}
			if (event.key == Qt.Key_Up) {
				frame.rightPaddle.down()
				event.accepted = true;
			} else if (event.key == Qt.Key_Down) {
				frame.rightPaddle.up()
				event.accepted = true;
			}
    }
		Keys.onReleased: {
			if (event.key == Qt.Key_W
			||  event.key == Qt.Key_S) {
				frame.leftPaddle.stop()
				event.accepted = true;
			}
			if (event.key == Qt.Key_Up
			||  event.key == Qt.Key_Down) {
				frame.rightPaddle.stop()
				event.accepted = true;
			}
		}
		id: "line"
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: 5
		color: "grey"
	}
	Text {
		id: scoreLeft
		color: "grey"
		anchors.topMargin: window.height/15
		anchors.top: parent.top
		anchors.right: parent.horizontalCenter
		anchors.rightMargin: window.height/15
		font.pointSize: window.height/5
		font.family: "Bit5x3"
		text: "97"
	}
	Text {
		id: scoreRight
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
		id: ball
		width: 40
		height: width
		x: window.width/2 - width/2
		y: window.height/2 - width/2
		radius: width/2
		color: "red"
		ParallelAnimation {
			id: moveBall
			PropertyAnimation {
				target: ball
				properties: "x"
				to: rel_to_abs_x(frame.to_x)
				duration: frame.time
			}
			PropertyAnimation {
				target: ball
				properties: "y"
				to: rel_to_abs_y(frame.to_y)
				duration: frame.time
			}
			onRunningChanged: {
				if (!moveBall.running) {
					frame.stoped()
					frame.bounce(abs_to_rel_x(ball.x), abs_to_rel_y(ball.y))
					//moveBall.start()
				}
			}
		}
	}
	Rectangle {
		id: paddleRight
		anchors.leftMargin: 10
		anchors.right: parent.right
		y: right.pos*(window.height/100) - height/2
		width: window.width/70
		height: 2 * right.size * (window.height/100)
		color: "black"
	}
	Rectangle {
		id: paddleLeft
		anchors.rightMargin: 10
		anchors.left: parent.left
		y: left.pos*(window.height/100) - height/2
		width: window.width/70
		height: 2 * left.size * (window.height/100)
		color: "green"
	}
	Paddle {
		id: right
		side: -1
		pos: 50
		size: 15
		onMove: {
			paddleRight.y = pos*(window.height/100) - paddleRight.height/2
			moveBall.start()
		}
	}
	Paddle {
		id: left
		side: 1
		pos: 50
		size: 15
		onMove: {
			paddleLeft.y = pos*(window.height/100) - paddleLeft.height/2
			moveBall.start()
		}
	}
	Frame {
		id: frame
		leftPaddle: left
		rightPaddle: right
		height: window.height
		width: window.width
		onRunBall: {
			//ball.x = rel_to_abs_x(50)
			//ball.y = rel_to_abs_y(50)
			moveBall.start()
			count = count + 1
		}
	}
}
