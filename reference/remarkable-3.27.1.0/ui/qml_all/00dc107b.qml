pragma Singleton
import QtQuick

QtObject {
    /*!
        Filters tags so the returned list contains active tags
        with no duplicates.

        Input:

        taggedPageslist - List of pages that are tagged
        tagMap - A map of tags

        Returns a list of tag names with duplicates removed.
    */
    function filter(taggedPagesList, tagMap) {
        const filterTags = [];
        for (let tag in tagMap) {
            if (tagMap[tag] === 1) {
                filterTags.push(tag);
            }
        }
        if (filterTags.length) {
            return taggedPagesList.filter(taggedPage => {
                const tags = taggedPage.tags;
                for (let tag of filterTags) {
                    if (tags.indexOf(tag) === -1) {
                        return false;
                    }
                }
                return true;
            });
        }
        return taggedPagesList;
    }

    /*
        Given a list of tags, returns a list of pages matching the tags.
    */
    function getPagesFromSelectedTags(document, selectedTags, pageTagMap) {
        if (!document || !document.pageCount) {
            return 0;
        }
        const pages = []
        for (let i = 0; i < document.pageCount; ++i) {
            if (!!selectedTags && selectedTags.length) {
                const _tags = pageTagMap[i];
                if (!_tags) {
                    continue;
                }
                let match = true;
                for (let tag of selectedTags) {
                    if (_tags.indexOf(tag) === -1) {
                        match = false;
                        break;
                    }
                }
                if (match) {
                    pages.push(i);
                }
            } else {
                pages.push(i);
            }
        }
        return pages;
    }

    function getNoTagsMessage(selectedTags) {
        if (selectedTags.length > 0) {
            return qsTr("You can sort your pages after combination of tags. \nSelect one that matches what you're looking for.");
        }
        return qsTr("You can tag pages, files, and folders to find them faster. All your tagged content will appear here so you can easily sort and filter notes and documents.");
    }

    function sortVisibleTags(allTags, selectedTags, partiallySelectedTags) {
        let updatedTags = partiallySelectedTags.slice(0).concat(selectedTags).reverse();
        for (let tag of allTags) {
            if (updatedTags.indexOf(tag) === -1) {
                updatedTags.push(tag);
            }
        }
        return updatedTags;
    }

    // Opens the "View all" tags window.
    //
    // Pass either:
    // - live getters (e.g. () => root.selectedTags) which will be converted to bindings by the window, or
    // - direct values which is passed as-is to the window.
    function openAllTagsWindow(windowNavigator, selectedTags, tagsModel, onTagSelected, onClose) {
        if (!windowNavigator || typeof windowNavigator.open !== "function") {
            console.error("TagUtils.openAllTagsWindow: invalid windowNavigator");
            return;
        }

        if (selectedTags === undefined || tagsModel === undefined) {
            console.error("TagUtils.openAllTagsWindow: missing selectedTags/tagsModel");
            return;
        }

        windowNavigator.open("tags/window/all-tags", {
            selectedTags,
            tagsModel,
            onTagSelected,
            onClose,
        });
    }

    // Returns a new array with `value` toggled on/off.
    function toggledInList(list, value) {
        const array = Array.from(list ?? []);
        const index = array.indexOf(value);
        if (index === -1) {
            array.push(value);
        } else {
            array.splice(index, 1);
        }
        return array;
    }

    function removedFromList(list, value) {
        const array = Array.from(list ?? []);
        return array.filter(item => item !== value);
    }

    function setTagOnSelections(_pageTagSelection, _model, _selectedTags, _partiallySelectedTags) {
        if (_pageTagSelection) {
            let selection = _pageTagSelection.slice(0); // Since it is cleared once we change it
            let selectionkeys = Object.keys(selection);

            // Since the selection can contain multiple pages from the same document,
            // we create a map of pages for each documentId so we avoid writing to the same document more
            // than once
            let documentPages = []; // A map from documentIds to page numbers
            for (let index of selectionkeys) {
                if (selection[index] === true) {
                    const pageTag = _model[index];
                    if (!pageTag) {
                        console.warn("invalid page tag");
                        continue;
                    }
                    const docId = pageTag.documentId;
                    if (documentPages[docId]) {
                        documentPages[docId].push(pageTag.page);
                    } else {
                        documentPages[docId] = [pageTag.page];
                    }
                }
            }
            const documentIds = Object.keys(documentPages);
            for (let id of documentIds) {
                LibraryController.setPageTags(id, documentPages[id], _selectedTags, _partiallySelectedTags);
            }
        }

        // Handle documents
        if (Library.documentSelection.hasContent) {
            let entries = Library.documentSelection.ids.slice(0);
            for (let entryId of entries) {
                LibraryController.setEntryTags(entryId, _selectedTags, _partiallySelectedTags);
            }
        }
    }
}
