
/* WARNING: Removing unreachable block (ram,0x00b609f0) */
/* WARNING: Removing unreachable block (ram,0x00b609f8) */
/* WARNING: Removing unreachable block (ram,0x00b60a14) */
/* WARNING: Removing unreachable block (ram,0x00b60a30) */
/* WARNING: Removing unreachable block (ram,0x00b60a34) */
/* WARNING: Removing unreachable block (ram,0x00b60a38) */
/* WARNING: Removing unreachable block (ram,0x00b60a40) */
/* WARNING: Removing unreachable block (ram,0x00b60a50) */
/* WARNING: Removing unreachable block (ram,0x00b60a5c) */
/* WARNING: Removing unreachable block (ram,0x00b60a60) */
/* WARNING: Removing unreachable block (ram,0x00b60a64) */
/* WARNING: Removing unreachable block (ram,0x00b60a68) */
/* WARNING: Removing unreachable block (ram,0x00b60b18) */
/* WARNING: Removing unreachable block (ram,0x00b60a70) */
/* WARNING: Removing unreachable block (ram,0x00b607d4) */

void FUN_00b6072c(int param_1,undefined4 *param_2)

{
  undefined4 uVar1;
  int iVar2;
  undefined4 uVar3;
  int iVar4;
  uint uVar5;
  int *piVar6;
  void *__dest;
  void *pvVar7;
  int iVar8;
  int *piVar9;
  int iVar10;
  int iVar11;
  uint uVar12;
  undefined4 local_30;
  undefined4 uStack_2c;
  undefined4 uStack_28;
  undefined2 local_24;
  
  piVar9 = *(int **)(param_1 + 0xc);
  iVar8 = *(int *)(param_1 + 0x14);
  if (piVar9 == (int *)0x0) {
    piVar6 = (int *)0x0;
LAB_00b60778:
    local_30 = *param_2;
    local_24 = *(undefined2 *)(param_2 + 3);
    uStack_2c = param_2[1];
    uStack_28 = param_2[2];
    if (piVar6 == (int *)0x0) {
LAB_00b607b0:
      FUN_0043865c(param_1 + 0xc,0,1,0);
      iVar4 = *(int *)(param_1 + 0x14);
      __dest = *(void **)(param_1 + 0x10);
    }
    else {
LAB_00b607a4:
      if ((1 < *piVar6) || (piVar9 == (int *)0x0)) goto LAB_00b607b0;
      pvVar7 = *(void **)(param_1 + 0x10);
      iVar2 = (int)pvVar7 - ((int)piVar9 + 0x13U & 0xfffffff8);
      iVar10 = iVar2 >> 1;
      iVar11 = piVar9[2];
      iVar4 = *(int *)(param_1 + 0x14);
      __dest = pvVar7;
      if (iVar11 + iVar10 * 0x49249249 <= iVar4) {
        if ((iVar2 < 1) || (iVar4 * 3 + iVar11 * -2 < 0 == SBORROW4(iVar4 * 3,iVar11 * 2)))
        goto LAB_00b607b0;
        __dest = (void *)(iVar10 * -2 + (int)pvVar7);
        if ((pvVar7 != __dest && iVar4 != 0) && (__dest != (void *)0x0 && pvVar7 != (void *)0x0)) {
          memmove(__dest,pvVar7,iVar4 * 0xe);
          iVar4 = *(int *)(param_1 + 0x14);
        }
        *(void **)(param_1 + 0x10) = __dest;
      }
    }
    pvVar7 = (void *)((int)__dest + iVar8 * 0xe);
    memmove((void *)((int)pvVar7 + 0xe),pvVar7,(iVar4 - iVar8) * 0xe);
    iVar10 = *(int *)(param_1 + 0x14);
    *(undefined4 *)((int)__dest + iVar8 * 0xe) = local_30;
    *(undefined4 *)((int)pvVar7 + 4) = uStack_2c;
    *(undefined4 *)((int)pvVar7 + 8) = uStack_28;
    *(undefined2 *)((int)pvVar7 + 0xc) = local_24;
    *(int *)(param_1 + 0x14) = iVar10 + 1;
    piVar9 = *(int **)(param_1 + 0xc);
LAB_00b60804:
    if (piVar9 != (int *)0x0) goto LAB_00b60810;
  }
  else {
    piVar6 = piVar9;
    if (1 < *piVar9) goto LAB_00b60778;
    uVar12 = *(uint *)(param_1 + 0x10);
    uVar5 = (int)piVar9 + 0x13U & 0xfffffff8;
    if (iVar8 == piVar9[2] + ((int)(uVar12 - uVar5) >> 1) * 0x49249249) {
      if (iVar8 != 0) {
        local_30 = *param_2;
        uStack_2c = param_2[1];
        uStack_28 = param_2[2];
        local_24 = *(undefined2 *)(param_2 + 3);
        goto LAB_00b607a4;
      }
      if (uVar12 == uVar5) goto LAB_00b60778;
      uVar1 = param_2[1];
      uVar3 = param_2[2];
      *(undefined4 *)(uVar12 - 0xe) = *param_2;
      *(undefined4 *)(uVar12 - 10) = uVar1;
      *(undefined4 *)(uVar12 - 6) = uVar3;
      *(undefined2 *)(uVar12 - 2) = *(undefined2 *)(param_2 + 3);
      *(uint *)(param_1 + 0x10) = uVar12 - 0xe;
      *(undefined4 *)(param_1 + 0x14) = 1;
      goto LAB_00b60804;
    }
    uVar1 = param_2[1];
    uVar3 = param_2[2];
    *(undefined4 *)(uVar12 + iVar8 * 0xe) = *param_2;
    iVar10 = uVar12 + iVar8 * 0xe;
    *(undefined4 *)(iVar10 + 4) = uVar1;
    *(undefined4 *)(iVar10 + 8) = uVar3;
    *(undefined2 *)(iVar10 + 0xc) = *(undefined2 *)(param_2 + 3);
    *(int *)(param_1 + 0x14) = iVar8 + 1;
LAB_00b60810:
    if (*piVar9 < 2) goto LAB_00b6082c;
  }
  FUN_0043865c(param_1 + 0xc,0,0);
LAB_00b6082c:
  if (2 < *(int *)(param_1 + 0x14)) {
    FUN_00b60560(param_1);
  }
  *(undefined4 *)(param_1 + 0x28) = 0;
  *(undefined4 *)(param_1 + 0x2c) = 0;
  *(undefined4 *)(param_1 + 0x30) = 0;
  *(undefined4 *)(param_1 + 0x34) = 0;
  *(undefined4 *)(param_1 + 0x38) = 0;
  *(undefined4 *)(param_1 + 0x3c) = 0;
  *(undefined4 *)(param_1 + 0x40) = 0;
  *(undefined4 *)(param_1 + 0x44) = 0;
  return;
}

