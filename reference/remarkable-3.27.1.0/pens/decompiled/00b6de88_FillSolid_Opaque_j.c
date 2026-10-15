
void FUN_00b6de88(int param_1,float param_2,float param_3,float param_4)

{
  undefined8 uVar1;
  undefined8 *puVar2;
  undefined4 *puVar3;
  int iVar4;
  int iVar5;
  undefined8 *puVar6;
  undefined4 uVar7;
  uint uVar8;
  int iVar9;
  float fVar10;
  uint uVar11;
  uint uVar12;
  float fVar13;
  float fVar14;
  float fVar15;
  float fVar16;
  float fVar17;
  float fVar18;
  float fVar19;
  float fVar20;
  float fVar21;
  float fVar22;
  float fVar23;
  float fStack00000004;
  float fStack00000008;
  float fStack0000000c;
  float in_stack_00000010;
  float in_stack_00000014;
  float in_stack_00000018;
  
  fVar14 = in_stack_00000018;
  fVar10 = param_2;
  fVar21 = param_3;
  fVar13 = param_4;
  if (in_stack_00000010 < param_3) {
    fVar20 = param_4;
    fVar15 = param_3;
    fVar23 = in_stack_00000010;
    fVar22 = param_2;
    if (in_stack_00000010 == in_stack_00000018 ||
        in_stack_00000010 < in_stack_00000018 != (NAN(in_stack_00000010) || NAN(in_stack_00000018)))
    goto LAB_00b6e040;
  }
  else {
    fVar20 = param_2;
    fVar15 = in_stack_00000010;
    fVar23 = param_3;
    fVar22 = param_4;
    if (param_3 == in_stack_00000018 ||
        param_3 < in_stack_00000018 != (NAN(param_3) || NAN(in_stack_00000018))) {
LAB_00b6e040:
      fVar14 = fVar23;
      in_stack_00000010 = fVar15;
      fVar10 = in_stack_00000014;
      fVar15 = in_stack_00000014;
      in_stack_00000014 = fVar20;
      fVar23 = in_stack_00000010;
      fVar21 = in_stack_00000018;
      fVar13 = fVar22;
      if (in_stack_00000018 < in_stack_00000010) goto LAB_00b6def0;
    }
    else {
      fVar15 = param_2;
      fVar20 = in_stack_00000014;
      fVar23 = in_stack_00000010;
      in_stack_00000018 = param_3;
      if (param_3 < in_stack_00000010) goto LAB_00b6def0;
    }
  }
  fVar15 = fVar13;
  fVar20 = in_stack_00000014;
  fVar23 = fVar21;
  in_stack_00000018 = in_stack_00000010;
  fVar22 = fVar10;
LAB_00b6def0:
  fStack00000004 = param_2;
  fStack00000008 = param_3;
  fStack0000000c = param_4;
  fVar10 = floorf(fVar14);
  fVar21 = 0.5;
  if (0.5 < fVar14 - fVar10) {
    fVar21 = 1.5;
  }
  fVar10 = fVar10 + fVar21;
  if (in_stack_00000018 != fVar14) {
    fVar16 = (fVar15 - fVar20) / (in_stack_00000018 - fVar14);
    fVar13 = (fVar22 - fVar20) / (fVar23 - fVar14);
    fVar17 = fVar20 + fVar16 * (fVar10 - fVar14) + 0.5;
    fVar18 = fVar20 + fVar13 * (fVar10 - fVar14) + 0.5;
    fVar21 = fVar16;
    fVar19 = fVar17;
    if (fVar16 != fVar13 && fVar16 < fVar13 == (NAN(fVar16) || NAN(fVar13))) {
      fVar21 = fVar13;
      fVar13 = fVar16;
      fVar19 = fVar18;
      fVar18 = fVar17;
    }
    if (fVar10 < in_stack_00000018) {
      do {
        uVar11 = (uint)fVar19;
        uVar12 = (uint)fVar18;
        if ((int)uVar11 < (int)uVar12) {
          iVar5 = *(int *)(param_1 + 4);
          iVar9 = *(int *)(param_1 + 8) * (int)fVar10;
          if (uVar11 < uVar12) {
            uVar8 = uVar12 - uVar11;
            if ((uVar8 - 1 < 6) ||
               (puVar2 = (undefined8 *)(iVar5 + (iVar9 + uVar11) * 4),
               puVar2 < (undefined8 *)(param_1 + 0x10) &&
               param_1 + 0xcU < iVar5 + (iVar9 + uVar12) * 4)) {
              puVar3 = (undefined4 *)(iVar5 + (uVar11 + 0x3fffffff + iVar9) * 4);
              do {
                puVar3 = puVar3 + 1;
                *puVar3 = *(undefined4 *)(param_1 + 0xc);
              } while ((undefined4 *)(iVar5 + -4 + (iVar9 + uVar12) * 4) != puVar3);
            }
            else {
              uVar1 = CONCAT44(*(undefined4 *)(param_1 + 0xc),*(undefined4 *)(param_1 + 0xc));
              puVar6 = puVar2 + (uVar8 >> 2) * 2;
              do {
                *puVar2 = uVar1;
                puVar2[1] = uVar1;
                puVar2 = puVar2 + 2;
              } while (puVar2 != puVar6);
              iVar4 = (uVar8 & 0xfffffffc) + uVar11;
              if ((uVar8 & 3) != 0) {
                uVar7 = *(undefined4 *)(param_1 + 0xc);
                *(undefined4 *)(iVar5 + (iVar9 + iVar4) * 4) = uVar7;
                if (iVar4 + 1U < uVar12) {
                  *(undefined4 *)(iVar5 + (iVar9 + iVar4 + 1U) * 4) = uVar7;
                  if (iVar4 + 2U < uVar12) {
                    *(undefined4 *)(iVar5 + (iVar9 + iVar4 + 2U) * 4) =
                         *(undefined4 *)(param_1 + 0xc);
                  }
                }
              }
            }
          }
        }
        fVar10 = fVar10 + 1.0;
        fVar19 = fVar19 + fVar21;
        fVar18 = fVar18 + fVar13;
      } while (fVar10 < in_stack_00000018);
    }
  }
  if (fVar23 != in_stack_00000018) {
    fVar13 = (fVar22 - fVar15) / (fVar23 - in_stack_00000018);
    fVar14 = (fVar22 - fVar20) / (fVar23 - fVar14);
    fVar21 = (fVar22 - fVar13 * (fVar23 - fVar10)) + 0.5;
    fVar20 = (fVar22 - fVar14 * (fVar23 - fVar10)) + 0.5;
    if (fVar21 == fVar20 || fVar21 < fVar20 != (NAN(fVar21) || NAN(fVar20))) {
      fVar15 = fVar13;
      fVar13 = fVar20;
      if (fVar23 == fVar10 || fVar23 < fVar10 != (NAN(fVar23) || NAN(fVar10))) {
        return;
      }
    }
    else {
      fVar15 = fVar14;
      fVar14 = fVar13;
      fVar13 = fVar21;
      fVar21 = fVar20;
      if (fVar23 == fVar10 || fVar23 < fVar10 != (NAN(fVar23) || NAN(fVar10))) {
        return;
      }
    }
    do {
      uVar11 = (uint)fVar21;
      uVar12 = (uint)fVar13;
      if ((int)uVar11 < (int)uVar12) {
        iVar5 = *(int *)(param_1 + 4);
        iVar9 = *(int *)(param_1 + 8) * (int)fVar10;
        if (uVar11 < uVar12) {
          uVar8 = uVar12 - uVar11;
          if ((uVar8 - 1 < 6) ||
             (puVar2 = (undefined8 *)(iVar5 + (iVar9 + uVar11) * 4),
             puVar2 < (undefined8 *)(param_1 + 0x10) &&
             param_1 + 0xcU < iVar5 + (iVar9 + uVar12) * 4)) {
            puVar3 = (undefined4 *)(iVar5 + (uVar11 + 0x3fffffff + iVar9) * 4);
            do {
              puVar3 = puVar3 + 1;
              *puVar3 = *(undefined4 *)(param_1 + 0xc);
            } while (puVar3 != (undefined4 *)(iVar5 + -4 + (iVar9 + uVar12) * 4));
          }
          else {
            uVar1 = CONCAT44(*(undefined4 *)(param_1 + 0xc),*(undefined4 *)(param_1 + 0xc));
            puVar6 = puVar2 + (uVar8 >> 2) * 2;
            do {
              *puVar2 = uVar1;
              puVar2[1] = uVar1;
              puVar2 = puVar2 + 2;
            } while (puVar6 != puVar2);
            iVar4 = (uVar8 & 0xfffffffc) + uVar11;
            if ((uVar8 & 3) != 0) {
              uVar7 = *(undefined4 *)(param_1 + 0xc);
              *(undefined4 *)(iVar5 + (iVar9 + iVar4) * 4) = uVar7;
              if (iVar4 + 1U < uVar12) {
                *(undefined4 *)(iVar5 + (iVar9 + iVar4 + 1U) * 4) = uVar7;
                if (iVar4 + 2U < uVar12) {
                  *(undefined4 *)(iVar5 + (iVar9 + iVar4 + 2U) * 4) = *(undefined4 *)(param_1 + 0xc)
                  ;
                }
              }
            }
          }
        }
      }
      fVar10 = fVar10 + 1.0;
      fVar21 = fVar21 + fVar15;
      fVar13 = fVar13 + fVar14;
    } while (fVar23 != fVar10 && fVar23 < fVar10 == (NAN(fVar23) || NAN(fVar10)));
  }
  return;
}

