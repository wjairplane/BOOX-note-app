import QtQuick

/*
    The purpose of this component is to add some convenience
    to the repeater so that you can provide a string, a string list
    or and object list and be guaranteed to get an array of
    { description: .. } objects.
*/

Repeater {

    property var sourceModel

    model: {
        if (typeof sourceModel === 'string') {
            return [ { description: sourceModel } ];
        } else {
            console.assert(Array.isArray(sourceModel));
            return sourceModel;
        }
    }

    // Returns an object for a given index with
    // 'description' set
    function item(index) {
        if (repeater.model[index] === 'string') {
            return { description: repeater.model[index] };
        }
        return repeater.model[index];
    }
}
