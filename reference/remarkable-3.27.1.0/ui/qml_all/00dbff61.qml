pragma Singleton
import QtQuick

QtObject {
    /*
        Utility for delayed execution in QML, similar to setTimeout in JavaScript.

        Usage:
            import "qrc:/qml/common/TimerUtils.js" as TimerUtils

            TimerUtils.delay(() => {
                console.log("Executed after 100ms (default)");
            })

            TimerUtils.delay(() => {
                console.log("Executed after 50ms");
            }, 50)

            100ms is the default delay if not specified.
    */
    function delay(callback, ms = 100) {
        const timer = timerComponent.createObject(null, { "interval": ms });
        timer.triggered.connect(() => {
            callback();
            timer.destroy();
        });
        timer.start();
    }

    property Component timerComponent: Component {
        DelayTimer {}
    }
}
