import QtQuick
import QtQuick.Shapes
import org.kde.kirigami as Kirigami
import org.kde.layershell as LayerShell

// A notch on the right screen edge with one ring per agent, showing the percent
// left of its weekly usage window. Collapsed, only a thin strip shows;
// hovering the strip slides the notch out, and hovering a ring opens a card
// with every window. Clicking a ring refreshes all agents.
//
// The window is a layer-shell surface: it stays above other windows without
// taking space from them. Only its visible parts take mouse input (see
// InputRegion in agent_notch.py), so the transparent parts let clicks through to
// the windows below.
Window {
    id: root

    // Agents and InputRegion, from agent_notch.py
    required property var agents
    required property var inputRegion

    // icons from Custom Icon Fonts, the same ones nvim uses
    // (vim/.config/nvim/lua/shared/glyphs.lua)
    readonly property var glyphs: ({
            claude: "",
            codex: ""
        })

    readonly property int notchW: 76
    readonly property int shoulder: 22 // where the body curves into the screen edge
    readonly property int bodyX: 6 // left edge of the body, inside the notch
    readonly property int cornerR: 18
    readonly property int ringSize: 46
    readonly property int ringBlockH: ringSize + 4 + 18 // ring, spacing, percentage
    readonly property int ringSpacing: 18
    readonly property int cardW: 300
    readonly property int cardGap: 10
    readonly property int stripW: 3
    readonly property int stripH: 60

    readonly property var list: agents.agents
    readonly property int notchH: 2 * shoulder + 28 + list.length * ringBlockH + (list.length - 1) * ringSpacing

    property bool expanded: false
    property int hoveredIndex: -1
    // 0 = collapsed, 1 = fully out
    property real reveal: expanded ? 1 : 0
    Behavior on reveal {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    property real now: Date.now() / 1000
    Timer {
        interval: 30 * 1000
        running: root.reveal > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = Date.now() / 1000
    }

    width: notchW + cardGap + cardW
    height: notchH + 160
    color: "transparent"
    visible: true

    // [x, y, width, height] of each part that takes mouse input: the strip when
    // collapsed, otherwise the notch and the open card
    readonly property var inputRects: reveal === 0 ? [[width - stripW, (height - stripH) / 2, stripW, stripH]] : [[width - notchW, notch.y, notchW, notchH]].concat(card.visible ? [[card.x, card.y, card.width, card.height]] : [])
    onInputRectsChanged: inputRegion.set(inputRects)
    Component.onCompleted: inputRegion.set(inputRects)

    // KWin picks the window type from the scope (kwin src/layershellv1window.cpp,
    // scopeToType()); an unknown scope makes a normal window, which "Show
    // desktop" hides, while a dock stays, like Plasma's panels
    LayerShell.Window.scope: "dock"
    LayerShell.Window.anchors: LayerShell.Window.AnchorRight
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.exclusionZone: 0
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone

    // the window's own colors (Window color set of the Plasma color scheme)
    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false
    readonly property color bg: Kirigami.Theme.backgroundColor
    readonly property color fg: Kirigami.Theme.textColor
    readonly property color dim: Kirigami.Theme.disabledTextColor
    readonly property color track: Qt.tint(bg, Qt.rgba(fg.r, fg.g, fg.b, 0.1))

    function levelColor(left) {
        return left < 20 ? Kirigami.Theme.negativeTextColor : left < 50 ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.positiveTextColor;
    }

    // a window whose reset time has passed is full again, even before the next fetch
    function leftOf(w) {
        return w.resetsAt && w.resetsAt <= now ? 100 : w.left;
    }

    function windowLabel(name) {
        return name === "5h" ? "5h session" : name;
    }

    function resetText(t) {
        if (!t)
            return "";
        const d = t - now;
        if (d <= 0)
            return "Reset";
        if (d < 3600)
            return "Resets in " + Math.max(1, Math.round(d / 60)) + " min";
        const date = new Date(t * 1000);
        return "Resets " + (d < 20 * 3600 ? Qt.formatTime(date, "HH:mm") : Qt.formatDateTime(date, "ddd HH:mm"));
    }

    function isStale(agent) {
        return agent.asOf > 0 && now - agent.asOf > 15 * 60;
    }

    function hasError(agent) {
        return agent.error !== "" && agent.errorKind !== "rate_limited";
    }

    Timer {
        id: collapseTimer
        interval: 400
        onTriggered: {
            root.expanded = false;
            root.hoveredIndex = -1;
        }
    }

    Item {
        anchors.fill: parent

        HoverHandler {
            onHoveredChanged: {
                if (hovered) {
                    collapseTimer.stop();
                    root.expanded = true;
                } else {
                    collapseTimer.restart();
                }
            }
        }

        // collapsed state: a thin strip in the accent color
        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: root.stripW
            height: root.stripH
            radius: width / 2
            color: Kirigami.Theme.highlightColor
            opacity: 0.8 * (1 - root.reveal)
        }

        Shape {
            id: notch
            width: root.notchW
            height: root.notchH
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width - width * root.reveal
            visible: root.reveal > 0
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.96)
                strokeColor: "transparent"
                startX: notch.width
                startY: 0
                PathCubic {
                    x: notch.width - root.shoulder
                    y: root.shoulder
                    control1X: notch.width
                    control1Y: root.shoulder * 0.55
                    control2X: notch.width - root.shoulder * 0.45
                    control2Y: root.shoulder
                }
                PathLine {
                    x: root.bodyX + root.cornerR
                    y: root.shoulder
                }
                PathQuad {
                    x: root.bodyX
                    y: root.shoulder + root.cornerR
                    controlX: root.bodyX
                    controlY: root.shoulder
                }
                PathLine {
                    x: root.bodyX
                    y: notch.height - root.shoulder - root.cornerR
                }
                PathQuad {
                    x: root.bodyX + root.cornerR
                    y: notch.height - root.shoulder
                    controlX: root.bodyX
                    controlY: notch.height - root.shoulder
                }
                PathLine {
                    x: notch.width - root.shoulder
                    y: notch.height - root.shoulder
                }
                PathCubic {
                    x: notch.width
                    y: notch.height
                    control1X: notch.width - root.shoulder * 0.45
                    control1Y: notch.height - root.shoulder
                    control2X: notch.width
                    control2Y: notch.height - root.shoulder * 0.55
                }
                PathLine {
                    x: notch.width
                    y: 0
                }
            }

            Column {
                x: root.bodyX
                y: root.shoulder + 14
                width: notch.width - root.bodyX
                spacing: root.ringSpacing

                Repeater {
                    // a count, not the list: every fetch sends a new list, and a
                    // list model would rebuild the delegates, whose new
                    // HoverHandlers briefly all sit at y = 0 and leave
                    // hoveredIndex on the last ring
                    model: root.list.length
                    delegate: Item {
                        id: ringBlock
                        required property int index
                        readonly property var agent: root.list[index]
                        // the general weekly window, or the first one when an agent has none
                        readonly property var shown: agent.windows.find(w => w.name === "Weekly") || agent.windows[0] || null
                        readonly property real pctLeft: shown ? root.leftOf(shown) : 0

                        width: parent.width
                        height: root.ringBlockH

                        HoverHandler {
                            onHoveredChanged: if (hovered)
                                root.hoveredIndex = ringBlock.index
                        }
                        TapHandler {
                            onTapped: root.agents.refresh()
                        }

                        Item {
                            id: ring
                            width: root.ringSize
                            height: root.ringSize
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: root.hoveredIndex === ringBlock.index ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
                            }
                            Shape {
                                anchors.fill: parent
                                preferredRendererType: Shape.CurveRenderer
                                ShapePath {
                                    fillColor: "transparent"
                                    strokeColor: root.track
                                    strokeWidth: 4
                                    PathAngleArc {
                                        centerX: root.ringSize / 2
                                        centerY: root.ringSize / 2
                                        radiusX: root.ringSize / 2 - 4
                                        radiusY: root.ringSize / 2 - 4
                                        startAngle: 0
                                        sweepAngle: 360
                                    }
                                }
                                ShapePath {
                                    fillColor: "transparent"
                                    strokeColor: root.levelColor(ringBlock.pctLeft)
                                    strokeWidth: 4
                                    capStyle: ShapePath.RoundCap
                                    PathAngleArc {
                                        centerX: root.ringSize / 2
                                        centerY: root.ringSize / 2
                                        radiusX: root.ringSize / 2 - 4
                                        radiusY: root.ringSize / 2 - 4
                                        startAngle: -90
                                        sweepAngle: ringBlock.shown ? 3.6 * ringBlock.pctLeft : 0
                                    }
                                }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: root.glyphs[ringBlock.agent.id] || ""
                                font.family: "Custom Icon Fonts"
                                font.pixelSize: 20
                                color: root.fg
                            }
                            // a failed fetch other than "asked too often"
                            Rectangle {
                                visible: root.hasError(ringBlock.agent)
                                width: 9
                                height: 9
                                radius: 4.5
                                x: parent.width - width
                                y: 0
                                color: Kirigami.Theme.negativeTextColor
                                border.color: root.bg
                                border.width: 1.5
                            }
                        }
                        Text {
                            anchors.top: ring.bottom
                            anchors.topMargin: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: ringBlock.shown ? Math.round(ringBlock.pctLeft) + "%" : "--"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: root.isStale(ringBlock.agent) ? root.dim : root.fg
                        }
                    }
                }
            }
        }

        // card for the hovered ring
        Item {
            id: card
            readonly property var agent: root.hoveredIndex >= 0 ? root.list[root.hoveredIndex] : null
            readonly property real ringCenterY: notch.y + root.shoulder + 14 + Math.max(0, root.hoveredIndex) * (root.ringBlockH + root.ringSpacing) + root.ringSize / 2

            visible: agent !== null && root.reveal === 1
            width: root.cardW
            height: content.implicitHeight + 32
            x: 0
            y: Math.max(0, Math.min(parent.height - height, ringCenterY - 40))

            // pointer towards the ring
            Rectangle {
                width: 12
                height: 12
                rotation: 45
                x: card.width - 7
                y: card.ringCenterY - card.y - 6
                color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.97)
            }
            Rectangle {
                anchors.fill: parent
                radius: 14
                color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.97)
            }

            Column {
                id: content
                x: 16
                y: 16
                width: card.width - 32
                spacing: 12

                Row {
                    spacing: 8
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: card.agent ? root.glyphs[card.agent.id] || "" : ""
                        font.family: "Custom Icon Fonts"
                        font.pixelSize: 18
                        color: root.fg
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: card.agent ? card.agent.name + " usage" : ""
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: root.fg
                    }
                }

                Repeater {
                    model: card.agent ? card.agent.windows : []
                    delegate: Column {
                        required property var modelData
                        readonly property real pctLeft: root.leftOf(modelData)
                        width: content.width
                        spacing: 6

                        Item {
                            width: parent.width
                            height: 16
                            Text {
                                text: root.windowLabel(modelData.name)
                                font.pixelSize: 12
                                color: root.fg
                            }
                            Text {
                                anchors.right: parent.right
                                text: root.resetText(modelData.resetsAt)
                                font.pixelSize: 12
                                color: root.dim
                            }
                        }
                        Rectangle {
                            width: parent.width
                            height: 6
                            radius: 3
                            color: root.track
                            Rectangle {
                                width: parent.width * parent.parent.pctLeft / 100
                                height: parent.height
                                radius: 3
                                color: root.levelColor(parent.parent.pctLeft)
                            }
                        }
                        Text {
                            text: Math.round(parent.pctLeft) + "% left"
                            font.pixelSize: 12
                            color: root.dim
                        }
                    }
                }

                Text {
                    visible: card.agent !== null && card.agent.error !== ""
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: card.agent ? card.agent.error : ""
                    font.pixelSize: 12
                    color: card.agent && root.hasError(card.agent) ? Kirigami.Theme.negativeTextColor : root.dim
                }

                Text {
                    visible: card.agent !== null && card.agent.asOf > 0 && (root.isStale(card.agent) || card.agent.error !== "")
                    text: card.agent ? "as of " + Qt.formatTime(new Date(card.agent.asOf * 1000), "HH:mm") : ""
                    font.pixelSize: 11
                    color: root.dim
                }
            }
        }
    }
}
