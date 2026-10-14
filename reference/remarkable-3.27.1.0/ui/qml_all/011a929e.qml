pragma Singleton
import QtQuick

/**
 * \ingroup ark_controls
 * \brief Provides positioning logic for tooltips.
 *
 * This singleton provides functions to determine the best position for tooltips
 * relative to a target point and container boundaries.
 *
 * \see TooltipPane
 *
 * @{
 */
QtObject {
    function makeRectangle(left, top, right, bottom) {
        return Qt.rect(left, top, right - left, bottom - top);
    }
    function makeHarbor(pos, pointTo, container, minimumWidth, hint) {
        let harbor = {
            "position": pos,
            "area": 0
        }
        switch (pos) {
            case Qt.LeftEdge:
                harbor.anchor = Qt.point(pointTo.x + pointTo.width, pointTo.y + pointTo.height/2);
                harbor.bay = makeRectangle(pointTo.right, container.top, container.right, container.bottom);
                break;
            case Qt.RightEdge:
                harbor.anchor = Qt.point(pointTo.x, pointTo.y + pointTo.height/2);
                harbor.bay = makeRectangle(container.left, container.top, pointTo.left, container.bottom);
                break;
            case Qt.TopEdge:
                harbor.anchor = Qt.point(pointTo.x + pointTo.width/2, pointTo.y + pointTo.height);
                harbor.bay = makeRectangle(container.left, pointTo.bottom, container.right, container.bottom);
                break;
            case Qt.BottomEdge:
                harbor.anchor = Qt.point(pointTo.x + pointTo.width/2, pointTo.y);
                harbor.bay = makeRectangle(container.left, container.top, container.right, pointTo.top);
                break;
        }

        if (harbor.bay.width > minimumWidth) {
            harbor.area = harbor.bay.width * harbor.bay.height;
            if (hint === pos) {
                harbor.area *= 1.5; // give preference to hinted position
            }
        }

        return harbor;
    }

    function compareHarbor(a, b) {
        return b.area - a.area;
    }

    function bestPosition(pointTo, container, minimumWidth, positionHint = 0) {
        
        const p = Qt.rect(pointTo.x, pointTo.y, pointTo.width, pointTo.height);
        const c = Qt.rect(container.x, container.y, container.width, container.height);
      
        let r = [
            makeHarbor(Qt.RightEdge, p, c, minimumWidth, positionHint & Qt.RightEdge),
            makeHarbor(Qt.LeftEdge, p, c, minimumWidth, positionHint & Qt.LeftEdge),
            makeHarbor(Qt.TopEdge, p, c, minimumWidth, positionHint & Qt.TopEdge),
            makeHarbor(Qt.BottomEdge, p, c, minimumWidth, positionHint & Qt.BottomEdge)
        ];
        return r.sort(compareHarbor)[0];
    }

    function getX(item, harbor) {
        switch(harbor.position) {
            case Qt.RightEdge:
                return harbor.anchor.x - item.width
            case Qt.LeftEdge:
                return harbor.anchor.x
            case Qt.TopEdge:
            case Qt.BottomEdge:
                return Math.min(Math.max(harbor.bay.x, harbor.anchor.x - item.width/2), harbor.bay.right - item.width);
        }
        return 0;
    }
   
    function getY(item, harbor) {
        switch(harbor.position) {
            case Qt.TopEdge:
                return harbor.anchor.y
            case Qt.BottomEdge:
                return harbor.anchor.y - item.height
            case Qt.RightEdge:
            case Qt.LeftEdge:
                return Math.min(Math.max(harbor.bay.y, harbor.anchor.y - item.height/2), harbor.bay.bottom - item.height);
        }
        return 0;
    }

    function getMaxWidth(harbor) {
        return harbor.bay.width;
    }
}
/** @}*/
