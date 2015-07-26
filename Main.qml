/***************************************************************************
*    AcidHub SDDM theme
*    Copyright © 2015 - AcidHub <acidhub@craft.net.br>
*
*    This program is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
***************************************************************************/

import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    width: 800
    height: 600

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        onLoginSucceeded: {
        }
        onLoginFailed: {
        }
    }

    Repeater {
        model: screenModel
        Background {
            x: geometry.x; y: geometry.y; width: geometry.width; height:geometry.height
            source: config.background
            fillMode: Image.Stretch
            onStatusChanged: {
                if (status == Image.Error && source != config.defaultBackground) {
                    source = config.defaultBackground
                }
            }
        }
    }

    Rectangle {
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
        color: "transparent"

        Rectangle {
            width: 520; height: 310
            color: "#00000000"

            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 25

            Image {
                anchors.fill: parent
                source: "images/rectangle.png"
            }

            Image {
                anchors.fill: parent
                source: "images/rectangle_overlay.png"
                opacity: 0.1
            }

            Item {
                anchors.margins: 20
                anchors.fill: parent

                Text {
                    height: 50
                    anchors.top: parent.top
                    anchors.left: parent.left; anchors.right: parent.right

                    color: "black"

                    text: ("Welcome to ") + sddm.hostName
                    font.capitalization: Font.AllUppercase 
                    font.bold: true
                    font.pixelSize: 20
                    style: Text.Outline
                    styleColor: "white"

                }

                Column {
                    anchors.centerIn: parent

                    Row {
                        Image { source: "images/user_icon.png" }

                        TextBox {
                            id: user_entry

                            width: 150; height: 30
                            anchors.verticalCenter: parent.verticalCenter;

                            text: userModel.lastUser

                            font.pixelSize: 14

                            KeyNavigation.backtab: layoutBox; KeyNavigation.tab: pw_entry
                        }
                    }

                    Row {

                        Image { source: "images/lock.png" }

                        PasswordBox {
                            id: pw_entry
                            width: 150; height: 30
                            anchors.verticalCenter: parent.verticalCenter;

                            tooltipBG: "CornflowerBlue"

                            font.pixelSize: 14

                            KeyNavigation.backtab: user_entry; KeyNavigation.tab: login_button

                            Keys.onPressed: {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    sddm.login(user_entry.text, pw_entry.text, menu_session.index)
                                    event.accepted = true
                                }
                            }
                        }
                    }
                }

                ImageButton {
                    id: login_button
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 20

                    source: "images/login_normal.png"

                    onClicked: sddm.login(user_entry.text, pw_entry.text, menu_session.index)

                    KeyNavigation.backtab: pw_entry; KeyNavigation.tab: session_button
                }

                Item {
                    height: 20
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left; anchors.right: parent.right

                    Row {
                        id: buttonRow
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: 8

                        ImageButton {
                            id: session_button
                            source: "images/session_normal.png"
                            onClicked: if (menu_session.state === "visible") menu_session.state = ""; else menu_session.state = "visible"

                            KeyNavigation.backtab: login_button; KeyNavigation.tab: system_button
                        }

                        ImageButton {
                            id: system_button
                            source: "images/system_shutdown.png"
                            onClicked: sddm.powerOff()

                            KeyNavigation.backtab: session_button; KeyNavigation.tab: reboot_button
                        }

                        ImageButton {
                            id: reboot_button
                            source: "images/system_reboot.png"
                            onClicked: sddm.reboot()

                            KeyNavigation.backtab: system_button; KeyNavigation.tab: suspend_button
                        }

                        ImageButton {
                            id: suspend_button
                            source: "images/system_suspend.png"
                            visible: sddm.canSuspend
                            onClicked: sddm.suspend()

                            KeyNavigation.backtab: reboot_button; KeyNavigation.tab: hibernate_button
                        }

                        ImageButton {
                            id: hibernate_button
                            source: "images/system_hibernate.png"
                            visible: sddm.canHibernate
                            onClicked: sddm.hibernate()

                            KeyNavigation.backtab: suspend_button; KeyNavigation.tab: session
                        }
                    }

                    Text {
                        id: time_label
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        text: Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy HH:mm AP")
                        horizontalAlignment: Text.AlignRight
                        font.capitalization: Font.AllUppercase 
                        color: "black"
                        font.bold: true
                        font.pixelSize: 14
                        style: Text.Outline
                        styleColor: "white"

                    }

                    Menu {
                        id: menu_session
                        width: 200; height: 0
                        anchors.top: buttonRow.bottom; anchors.left: buttonRow.left

                        model: sessionModel
                        index: sessionModel.lastIndex
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (user_entry.text === "")
            user_entry.focus = true
        else
            pw_entry.focus = true
    }
}
