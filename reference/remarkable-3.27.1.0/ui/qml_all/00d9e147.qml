import QtQuick
import QtQuick.Layouts
import com.remarkable
import common
import device.ui.controls
import device.ui.text
import device.ui.headers    // ActionBar
import device.view.experimental
import device.view.navigator // FilterDropdown
import xofm.libs.onboarding // OnboardingDialogue
import xofm.libs.orientation

import com.remarkable.devicetelemetry
import com.remarkable.telemetry as Telemetry

import ark.controls as ArkControls
import ark.tokens as ArkTokens

Background {
    id: root

    required property string rejectText
    property Item documentView

    property var supportedTemplatesModel: []
    property var unsupportedTemplatesModel: []
    property var appliedTemplate: null
    property var shownNewTemplates: []
    property var selectedTemplate: null
    required property size paperSize

    // index for the "All" tab in the templateTabs model
    readonly property int tabAllIndex: templateTabs.model.indexOf("All")

    property var categoryModel: []
    property var tabsModel: templatesController.getTabNames()
    property string selectedTab: templatesController.currentTab
    property string selectedCategory: templatesController.currentCategory
    required property Orientation orientation

    readonly property string tabDefault: tabsModel[TemplateSelectorModel.Tabs.Default]
    readonly property string tabMethods: tabsModel[TemplateSelectorModel.Tabs.Methods]
    readonly property bool selectedTabMethods: selectedTab === qsTr(tabMethods)
    readonly property bool shouldRestrictMethodsTemplates: !UserInfo.isSubscribed && selectedTab === tabMethods

    onSelectedCategoryChanged: {
        updateModel();
    }
    onApplied: (aTemplate) => {
        root.appliedTemplate = aTemplate;
    }

    signal hide
    signal rejected
    signal applied(var aTemplate, bool isTemplateApplied, bool shouldAddToRecents)

    CloseShortcut {
        onActivated: root.hide()
    }

    function open(template) {
        root.appliedTemplate = template;
        templateTabs.currentIndex = templateTabs.model.indexOf(getTabforCurrentTemplate());
        templatesController.isLandscape = !root.orientation.isPortraitOrientation;
        updateModel();
    }

    Component.onDestruction: {
        Templates.clearNewflag(root.shownNewTemplates);
    }

    Connections {
        target: Templates

        function onTemplatesAdded() {
            categoryFilter.shouldLandscapeShow = Qt.binding(function() {return categoryFilter.shouldShowOrientationButton(true);})
            categoryFilter.shouldPortraitShow = Qt.binding(function() {return categoryFilter.shouldShowOrientationButton(false);})
            updateModel();
        }

        function onTemplatesRemoved() {
            templateTabs.model = Templates.categories();

            if (!templateTabs.model.includes("Market")) {
                setAllTab();
            }
        }
    }

    Connections {
        target: orientation
        function onIsPortraitOrientationChanged() {
            // Ensure the filter change automatically when changing orientation.
            templatesController.isLandscape = !root.orientation.isPortraitOrientation;
        }
    }

    TemplateSelectorModel {
        id: templatesController
        onIsLandscapeChanged: {
            root.updateModel();
        }
    }

    MethodsTelemetry {
        id: methodsTelemetry
        dispatcher: Telemetry.Dispatcher
    }

    function selectTemplate(aTemplate) {
        root.selectedTemplate = aTemplate;
        templatesActionsHeader.visible = true;
    }

    function deselectTemplate() {
        root.selectedTemplate = null;
        templatesActionsHeader.rejected();
    }

    function deleteTemplate(aTemplate) {
        Templates.deleteTemplate(aTemplate);

        root.updateModel();
        templatesActionsHeader.rejected();
    }

    function scrollToTemplateView(templateView) {

        const columns = Math.floor(templateView.width / templateView.cellWidth);
        const rowIndex = Math.floor(templateView.currentIndex / columns);
        const maxScrollY = Math.min(scrollArea.contentHeight, scrollArea.height);
        let yPosition = rowIndex * templateView.cellHeight;

        if (templateView === unsupportedView) {
            // Unsupported templates is at the very bottom, so need to compensate
            // with the height of the supportedTemplatesView.
            yPosition += supportedView.contentHeight;
        }
        scrollArea.contentY = Math.max(0, Math.min(yPosition, (maxScrollY)));
    }

    function highlightCurrentTemplate() {
        const currentTemplate = getCurrentTemplateInModel(root.supportedTemplatesModel)
                             ?? getCurrentTemplateInModel(root.unsupportedTemplatesModel);

        // if the appliedTemplate is still null - update it to the current one.
        if (!appliedTemplate) {
            appliedTemplate = currentTemplate;
        }



        const doHighlightTemplate = (view, model, otherView) => {
            const currentTemplateIndex = model.indexOf(currentTemplate);
            if (currentTemplateIndex < 0) {
                return false;
            }
            view.currentIndex = currentTemplateIndex;
            scrollToTemplateView(view);
            otherView.currentIndex = -1;
            return true;
        };


        const didHighlightTemplate = doHighlightTemplate(supportedView, supportedTemplatesModel, unsupportedView) ||
                                     doHighlightTemplate(unsupportedView, unsupportedTemplatesModel, supportedView);
        if (!didHighlightTemplate) {
            // Unselect everything if not tempalte to hightlight.
            supportedView.currentIndex = -1;
            unsupportedView.currentIndex = -1;
            scrollArea.contentY = 0;
        }
    }

    function updateModel() {
        const { supported, unsupported } = buildTemplatesModels(root.selectedTab, root.selectedCategory, templatesController.isLandscape);
        root.supportedTemplatesModel = supported;
        root.unsupportedTemplatesModel = unsupported;
        root.highlightCurrentTemplate();
    }

    function addCustomTemplateToShownList(aTemplate) {
        if (aTemplate.isNew && !shownNewTemplates.find((templateId) =>
                templateId === aTemplate.customTemplateId)) {
            root.shownNewTemplates.push(aTemplate.customTemplateId);
        }
    }

    function setAllTab() {
        templateTabs.currentIndex = root.tabAllIndex;
    }

    function getCurrentTemplateInModel(templateModelToSearch) {
        const currentTemplateFileName = appliedTemplate?.filename;

        return templateModelToSearch.find(function (aTemplate) {
            return aTemplate.filename === currentTemplateFileName;
        });
    }

    function getTabforCurrentTemplate() {
        const localTemplates = templatesForTab(tabDefault);
        const currentTab = getCurrentTemplateInModel(localTemplates) ? tabDefault : tabMethods;

        return currentTab;
    }

    function templatesForTab(tabName) {
        const allTemplates = Templates.list();
        const isImported = tabName === tabMethods;
        const filteredTemplates = allTemplates.filter((t) => isImported === t.customTemplate);

        return filteredTemplates;
    }

    function filterTemplates(tabName, categoryName, isLandscape) {
        const templatesInTab = templatesForTab(tabName);
        const allTemplatesForCategory = Templates.listForCategory(categoryName, isLandscape);
        const filteredByTab = allTemplatesForCategory.filter((t) => {
            return templatesInTab.includes(t);
        });

        return filteredByTab;
    }

    function buildTemplatesList(tabName, categoryName, isLandscape) {
        let templatesList = filterTemplates(tabName, categoryName, isLandscape);

        if (0 === templatesList.length) {
            const templatesList = filterTemplates(tabName, categoryName, !isLandscape);
            if (0 < templatesList.length ) {
                templatesController.isLandscape = !isLandscape;
                return templatesList;
            }
        }

        return templatesList;
    }

    function buildTemplatesModels(tabName, categoryName, isLandscape) {
        const filteredByTab = buildTemplatesList(tabName, categoryName, isLandscape);

        // Find and split supported and unsupported templates.
        const [supported, unsupported] = filteredByTab.reduce(([supported, unsupported], t) => {
            if (!root.paperSize) {
                // Means we're in the create notepage view and don't have paper size yet.
                supported.push(t);
            } else if (t.isSupportingPaperSize(root.paperSize)) {
              supported.push(t);
            } else {
              unsupported.push(t);
            }
            return [supported, unsupported];
          },
          [[], []]
        );

        return {supported, unsupported};
    }

    function getAvailableCategories() {
        const allCategories = Templates.categories();
        const relevantCategories = [];

        for (const category of allCategories) {
            const templatesList= filterTemplates(root.selectedTab, category, templatesController.isLandscape);
            if (0 < templatesList.length) {
                relevantCategories.push(category);
            }
        }
        return relevantCategories;
    }

    height: parent.height
    width: parent.width

    MouseArea {
        anchors.fill: parent
        onPressed: (mouse) => {
            mouse.accepted = true;
        }
        onClicked: (mouse) => {
            mouse.accepted = true;
        }
    }

    ScrollArea {
        id: scrollArea
        anchors {
            left: parent.left
            right: parent.right
            top: templateTabs.bottom
            bottom: parent.bottom
            topMargin: ArkControls.Values.margin.vertical.small
            leftMargin: ArkControls.Values.margin.horizontal.small
            rightMargin: ArkControls.Values.margin.horizontal.small
        }

        contentWidth: width
        contentHeight: column.implicitHeight
        enableScrollbar: true
        scrollbarRightMargin: 0

        clip: Experimental.smoothScroll.enabled

        readonly property bool hasUnsupportedTemplates: root.unsupportedTemplatesModel.length > 0

        ColumnLayout {
            id: column

            visible: !emptyImportedTemplates.visible
            width: scrollArea.width

            TemplateGridView {
                id: supportedView

                Layout.fillWidth: true
                Layout.preferredHeight: calculatePreferredHeight()

                selectedTemplate: root.selectedTemplate
                model: supportedTemplatesModel
                shouldRestrict: root.shouldRestrictMethodsTemplates

                onAddCustomTemplateToShownList: (customTemplate) => {
                    root.addCustomTemplateToShownList(customTemplate);
                }
                onApplied: (aTemplate, isTemplateApplied, shouldAddToRecents) => {
                    root.applied(aTemplate, isTemplateApplied, shouldAddToRecents);
                }
                onDeselectTemplate: root.deselectTemplate()
                onRestrict: restrictMethodsDialogue.visible = true
            }

            RowLayout {
                visible: scrollArea.hasUnsupportedTemplates
                Layout.fillWidth: true
                spacing: ArkControls.Values.spacing.large

                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    color: "black"
                }
                ArkControls.Label {
                    type: ArkControls.Label.Medium
                    text: qsTr("Not supported by page width")
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    color: "black"
                }
            }

            TemplateGridView {
                id: unsupportedView

                Layout.fillWidth: true
                Layout.preferredHeight: calculatePreferredHeight()

                visible: scrollArea.hasUnsupportedTemplates
                selectedTemplate: root.selectedTemplate
                model: unsupportedTemplatesModel
                shouldRestrict: root.shouldRestrictMethodsTemplates

                onAddCustomTemplateToShownList: (customTemplate) => {
                    root.addCustomTemplateToShownList(customTemplate);
                }
                onApplied: (aTemplate, isTemplateApplied, shouldAddToRecents) => {
                    root.applied(aTemplate, isTemplateApplied, shouldAddToRecents);
                }
                onDeselectTemplate: root.deselectTemplate()
                onRestrict: restrictMethodsDialogue.visible = true
            }
        }

    }

    EmptyViewItem {
        id: emptyImportedTemplates

        anchors {
            left: parent.left
            right: parent.right
            top: templateTabs.bottom
            bottom: parent.bottom
        }
        topPadding: {
            // since there're no templates in the model, the parent component's height is zero.
            // we need to calculate its height manually.
            const componentHeight = parent.height - templateTabs.height - templateSelectHeader.height;
            return componentHeight * Values.emptyViewTopMarginRatio;
        }

        visible: root.selectedTabMethods && (supportedTemplatesModel.length <= 0 && unsupportedTemplatesModel.length <= 0)
        onVisibleChanged: {
            if (visible) {
                methodsTelemetry.emptyStateShown(MethodsTelemetry.NoMethodsTemplatesDownloaded);
            }
        }

        emptyViewKey: "noMethodsTemplates"
    }

    ArkControls.NavigationBar {
        id: templateSelectHeader
        type: ArkTokens.NavigationBar.secondary
        visible: true
        antialiasing: true
        title: qsTr("Choose template")
        borderPosition: ArkControls.NavigationBar.Border.Bottom

        ArkControls.NavigationBar.Button {
            id: headerBackButton
            iconSource: "qrc:/ark/icons/chevron_left"
            focusPolicy: Qt.NoFocus
            text: qsTr(root.rejectText)
            onClicked: root.rejected()
        }
        // This item is used in the component to calculate the available space for the title
        Item {
            Layout.fillWidth: true
        }
    }

    TabControl {
        id: templateTabs
        objectName: "templateTabs"
        // provides translation for the tab titles:
        valueFunction: (index, model) => qsTranslate("Templates", model[index])
        anchors {
            top: templateSelectHeader.bottom
            left: parent.left
            right: parent.right
        }
        model: root.tabsModel
        onCurrentIndexChanged: {
            templatesController.currentTab = model[currentIndex];
            methodsTelemetry.templateOverviewTabSelected(templatesController.currentTab);
            root.updateModel();
        }

        FilterDropdown {
            id: categoryFilter
            objectName: "categoryFilter"
            visible: 0 < root.supportedTemplatesModel.length + root.unsupportedTemplatesModel.length
            keyTranslator: (key) => { return qsTranslate("Templates", key);  }
            anchors {
                right: parent.right
                bottom: parent.bottom
                rightMargin: Values.designGridMargin
            }
            categoriesModel: root.getAvailableCategories()
            isLandscape: templatesController.isLandscape
            selectedCategory: root.selectedCategory
            overlayRoot: root
            shouldPortraitShow: shouldShowOrientationButton(false)
            shouldLandscapeShow: shouldShowOrientationButton(true)
            onUpdateCategory: (currentCategory) => {
                methodsTelemetry.templatesFilterSet(templatesController.currentTab, currentCategory);
                templatesController.currentCategory = currentCategory;
            }
            onUpdateOrientation: (isLandscape) => {
                const orientation = isLandscape ? "Landscape" : "Portrait";
                methodsTelemetry.templatesFilterSet(templatesController.currentTab, orientation);
                templatesController.isLandscape = isLandscape;
            }

            function shouldShowOrientationButton(isLandscape) {
                return 0 < root.filterTemplates(root.selectedTab, root.selectedCategory, isLandscape).length;
            }
        }

        Rectangle {
            id: bottomBorder
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: -parent.anchors.margins
            anchors.bottomMargin: 0
            height: 2
            color: Values.colorBlack
        }
    }

    OnboardingDialogue {
        id: restrictMethodsDialogue
        visible: false
        initialModel: [{
            title: qsTr("Connect templates"),
            body: [{ "description":
                qsTr("Access your rM Methods templates and import more by activating Connect. Manage your subscription and free trials at my.remarkable.com.") }],
        }]
        customImage: Image {
            source: qrProvider.imageUrl
            fillMode: Image.PreserveAspectFit
            height: 250
            width: height
        }

        rightButtonText: qsTr("Close")

        onQuit: restrictMethodsDialogue.visible = false
        onFinished: restrictMethodsDialogue.visible = false

        QRCodeProvider {
            id: qrProvider
            text: "https://methods.remarkable.com?rm_utm_source=connect_restriction&rm_utm_campaign=template_selection"
        }
    }

    TemplatesActions {
        id: templatesActionsHeader
        visible: false
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        templateForActions: root.selectedTemplate

        onRejected: {
            templatesActionsHeader.visible = false;
            root.selectedTemplate = null;
        }

        onDeleteTemplate: (templateToDelete) => root.deleteTemplate(templateToDelete)
    }
}
