import QtQuick

import xofm.libs.toolbar

Item {
    id: root

    required property int toolbarPosition
    property Item dragTarget
    required property bool dragging

    readonly property int dragTargetCenterOffset: dragTarget.width / 2
    readonly property int dropZoneIndicatorSize: 12

    property int zone: {
        switch (root.toolbarPosition) {
            case ToolbarPositioner.Position.Left:
                return Toolbar.Zone.Left;
            case ToolbarPositioner.Position.Right:
                return Toolbar.Zone.Right;
            case ToolbarPositioner.Position.Top:
                return Toolbar.Zone.Top;
            case ToolbarPositioner.Position.Bottom:
                return Toolbar.Zone.Bottom;
        }
        return Toolbar.Zone.Left;
    }

    QtObject {
        id: internals

        property int threshold: 160
        readonly property variant beams: {
            "top" : {
                "close": Math.PI * 1/6, // 30 degrees
                "wide": Math.PI * 7/180 // 7 degrees
            },
            "right" : {
                "close": Math.PI * 1/12, //15 degrees
                "wide": Math.PI * 1/6 // 30 degrees
            },
            "bottom" : {
                "close": Math.PI * 1/6, // 30 degrees
                "wide": Math.PI * 7/180 // 7 degrees
            },
            "left" : {
                "close": Math.PI * 1/12, //15 degrees
                "wide": Math.PI * 1/6 // 30 degrees
            }
        }

        function origin() {
            switch(root.toolbarPosition) {
                case ToolbarPositioner.Position.Left:
                    return Qt.point(0, 0);
                case ToolbarPositioner.Position.Right:
                    return Qt.point(root.width, 0);
                case ToolbarPositioner.Position.Top:
                    return Qt.point(0, 0);
                case ToolbarPositioner.Position.Bottom:
                    return Qt.point(0, root.height);
            }
        }

        function mapFromToolbarPosition() {
            switch (root.toolbarPosition) {
                case ToolbarPositioner.Position.Left:
                    return Toolbar.Zone.Left;
                case ToolbarPositioner.Position.Right:
                    return Toolbar.Zone.Right;
                case ToolbarPositioner.Position.Top:
                    return Toolbar.Zone.Top;
                case ToolbarPositioner.Position.Bottom:
                    return Toolbar.Zone.Bottom;
            }
            return Toolbar.Zone.None;
        }

        function angleForPoint(point) {
            const origin = internals.origin();
            const xInvertFactor = root.toolbarPosition === ToolbarPositioner.Position.Right ? -1 : 1;
            const yInvertFactor = root.toolbarPosition === ToolbarPositioner.Position.Bottom ? -1 : 1;
            const relX = (point.x - origin.x) * xInvertFactor;
            const relY = (point.y - origin.y) * yInvertFactor;
            let angle = Math.atan2(relY, relX);
            // clamp the angle between 0 and 90 degrees
            angle = Math.min(Math.max(angle, 0), Math.PI / 2);
            return angle;
        }

        function getDropZoneByAngle(angle) {
            const AnglePosition = {
                None: 0,
                CloseBeam: 1,
                BetweenBeams: 2,
                WideBeam: 3
            };

            const closeBeam = (() => {
                switch(root.toolbarPosition) {
                    case ToolbarPositioner.Position.Left:
                        return internals.beams.left.close;
                    case ToolbarPositioner.Position.Right:
                        return internals.beams.right.close;
                    case ToolbarPositioner.Position.Top:
                        return internals.beams.top.close;
                    case ToolbarPositioner.Position.Bottom:
                        return internals.beams.top.close;
                }
            })();

            const wideBeam = (() => {
                switch(root.toolbarPosition) {
                    case ToolbarPositioner.Position.Left:
                        return Math.PI / 2 - internals.beams.left.wide;
                    case ToolbarPositioner.Position.Right:
                        return Math.PI / 2 - internals.beams.right.wide;
                    case ToolbarPositioner.Position.Top:
                        return Math.PI / 2 - internals.beams.top.wide;
                    case ToolbarPositioner.Position.Bottom:
                        return Math.PI / 2 - internals.beams.top.wide;
                }
            })();

            const position = (() => {
                if (angle < closeBeam) {
                    return AnglePosition.CloseBeam;
                }
                if (angle >= closeBeam && angle < wideBeam) {
                    return AnglePosition.BetweenBeams;
                }
                if (angle >= wideBeam && angle < Math.PI / 2) {
                    return AnglePosition.WideBeam;
                }
                return AnglePosition.None;
            })();

            switch(position) {
                case AnglePosition.CloseBeam:
                    return internals.dropZoneForCloseBeam();
                case AnglePosition.BetweenBeams:
                    return internals.dropZoneForBetweenBeams();
                case AnglePosition.WideBeam:
                    return internals.dropZoneForWideBeam();
            }
            return Toolbar.Zone.None;
        }

        function dropZoneForCloseBeam() {
            switch(internals.mapFromToolbarPosition()) {
                case Toolbar.Zone.Top:
                    return Toolbar.Zone.Right;
                case Toolbar.Zone.Right:
                    return Toolbar.Zone.Top;
                case Toolbar.Zone.Bottom:
                    return Toolbar.Zone.Right;
                case Toolbar.Zone.Left:
                    return Toolbar.Zone.Top;
            }
        }

        function dropZoneForWideBeam() {
            switch(internals.mapFromToolbarPosition()) {
                case Toolbar.Zone.Top:
                    return Toolbar.Zone.Left;
                case Toolbar.Zone.Right:
                    return Toolbar.Zone.Bottom;
                case Toolbar.Zone.Bottom:
                    return Toolbar.Zone.Left;
                case Toolbar.Zone.Left:
                    return Toolbar.Zone.Bottom;
            }
        }

        function dropZoneForBetweenBeams() {
            switch(internals.mapFromToolbarPosition()) {
                case Toolbar.Zone.Top:
                    return Toolbar.Zone.Bottom;
                case Toolbar.Zone.Right:
                    return Toolbar.Zone.Left;
                case Toolbar.Zone.Bottom:
                    return Toolbar.Zone.Top;
                case Toolbar.Zone.Left:
                    return Toolbar.Zone.Right;
            }
        }
    }

    function isCurrentlyActiveZone(zone) {
        if (!root.dragging) {
            return false;
        }

        const dropZonePoint = Qt.point(dragTarget.x + root.dragTargetCenterOffset, dragTarget.y + root.dragTargetCenterOffset);
        const angle = internals.angleForPoint(dropZonePoint);
        return internals.getDropZoneByAngle(angle) === zone;
    }

    function isWithinThresholdZone(zone) {
        if (!root.dragging) {
            return false;
        }

        if (zone === internals.mapFromToolbarPosition()) {
            return false;
        }

        switch (zone) {
            case Toolbar.Zone.Left:
                return dragTarget.x + root.dragTargetCenterOffset < internals.threshold;
            case Toolbar.Zone.Right:
                return dragTarget.x + root.dragTargetCenterOffset > root.width - internals.threshold;
            case Toolbar.Zone.Top:
                return dragTarget.y + root.dragTargetCenterOffset < internals.threshold;
            case Toolbar.Zone.Bottom:
                return dragTarget.y + root.dragTargetCenterOffset > root.height - internals.threshold;
        }
        return false;
    }

    function hasMovedSignificantly() {
        const dropZonePoint = Qt.point(dragTarget.x + root.dragTargetCenterOffset, dragTarget.y + root.dragTargetCenterOffset);
        return root.distanceFromOrigin(dropZonePoint) > internals.threshold * 1.5;
    }

    function distanceFromOrigin(point) {
        const origin = internals.origin();
        return Math.sqrt(Math.pow(point.x - origin.x, 2) + Math.pow(point.y - origin.y, 2));
    }

    // Greedily find the closest zone based on threshold and angle
    function findClosestZone() {
        const zoneRules = [
            {
                zone: Toolbar.Zone.Left,
                checkThreshold: () => root.isWithinThresholdZone(Toolbar.Zone.Left),
                checkAngle: () => root.isCurrentlyActiveZone(Toolbar.Zone.Left)
            },
            {
                zone: Toolbar.Zone.Top,
                checkThreshold: () => root.isWithinThresholdZone(Toolbar.Zone.Top),
                checkAngle: () => root.isCurrentlyActiveZone(Toolbar.Zone.Top)
            },
            {
                zone: Toolbar.Zone.Right,
                checkThreshold: () => root.isWithinThresholdZone(Toolbar.Zone.Right),
                checkAngle: () => root.isCurrentlyActiveZone(Toolbar.Zone.Right)
            },
            {
                zone: Toolbar.Zone.Bottom,
                checkThreshold: () => root.isWithinThresholdZone(Toolbar.Zone.Bottom),
                checkAngle: () => root.isCurrentlyActiveZone(Toolbar.Zone.Bottom)
            }
        ];

        if (!root.hasMovedSignificantly()) {
            return Toolbar.Zone.None;
        }

        // Check first for threshold zone, then angle zone
        for (const checker of zoneRules) {
            if (checker.checkThreshold()) {
                return checker.zone;
            }
        }

        for (const checker of zoneRules) {
            if (checker.checkAngle()) {
                return checker.zone;
            }
        }

        return Toolbar.Zone.None;
    }

    Rectangle {
        id: topDropZone
        color: "black"
        visible: root.dragging && root.zone === Toolbar.Zone.Top
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: root.dropZoneIndicatorSize
    }
    Rectangle {
        id: bottomDropZone
        color: "black"
        visible: root.dragging && root.zone === Toolbar.Zone.Bottom
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: root.dropZoneIndicatorSize
    }
    Rectangle {
        id: leftDropZone
        color: "black"
        visible: root.dragging && root.zone === Toolbar.Zone.Left
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: root.dropZoneIndicatorSize
    }
    Rectangle {
        id: rightDropZone
        color: "black"
        visible: root.dragging && root.zone === Toolbar.Zone.Right
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: root.dropZoneIndicatorSize
    }
}
