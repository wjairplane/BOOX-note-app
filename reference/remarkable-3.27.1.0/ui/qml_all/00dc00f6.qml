pragma Singleton
import QtQuick

QtObject {
    /*
        Calculation the distance between two Qt.points.
    */
    function distance(p1, p2) {
        const a = p1.x - p2.x;
        const b = p1.y - p2.y;
        return Math.sqrt(a * a + b * b);
    }

    /*
        Check if a point is inside a rectangle.
    */
    function pointInRect(point, rect) {
        return (point.x >= rect.x
            && point.x < rect.x + rect.width
            && point.y >= rect.y
            && point.y < rect.y + rect.height);
    }

    /*
        Returns a Qt.rect that is the smallest possible integer rectangle that completely contains \a r.
    */
    function toAlignedRect(r) {
        const left = Math.floor(r.x);
        const top = Math.floor(r.y);
        const right = Math.ceil(r.x + r.width);
        const bottom = Math.ceil(r.y + r.height);
        return Qt.rect(left, top, right - left, bottom - top);
    }

    /*
        Returns an aligned Qt.rect in view coordinates
    */
    function sceneToViewAligned(tileManager, viewRect) {
        const r = tileManager.sceneToView(viewRect);
        return toAlignedRect(r);
    }
}
