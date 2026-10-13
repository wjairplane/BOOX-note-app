package app.inkbridge.rm.edit

import app.inkbridge.rm.io.*
import app.inkbridge.rm.scene.*
import java.util.UUID

/**
 * Minimal block skeleton for an empty notebook page: one author, one layer ("Layer 1").
 * The layout mirrors what real pages from 3.x firmware contain (checked against sample files in tests).
 * Pages that already exist on the tablet should be edited in place instead of rebuilt from this.
 */
object BlankPage {
    val LAYER_NODE = CrdtId(0, 11)

    fun blocks(authorUuid: UUID = UUID.randomUUID()): List<Block> = listOf(
        AuthorIdsBlock(mapOf(1 to authorUuid)).versions(1, 1),
        MigrationInfoBlock(CrdtId(1, 1), isDevice = true, unknown = null).versions(1, 1),
        PageInfoBlock(1, 0, 0, 0, null).versions(0, 1),
        SceneTreeBlock(LAYER_NODE, CrdtId(0, 0), true, SceneTree.ROOT_ID).versions(1, 1),
        TreeNodeBlock(Group(SceneTree.ROOT_ID)).versions(1, 1),
        TreeNodeBlock(Group(LAYER_NODE).apply { label = Lww(CrdtId(0, 12), "Layer 1") }).versions(1, 1),
        SceneItemBlock(
            SceneItemBlock.GROUP, SceneTree.ROOT_ID, CrdtId(0, 13), CrdtId.END_MARKER, CrdtId.END_MARKER, 0,
            value = LAYER_NODE, itemType = 2,
        ).versions(1, 1),
    )

    fun <B : Block> B.versions(min: Int, current: Int): B = also { minVersion = min; currentVersion = current }
}
