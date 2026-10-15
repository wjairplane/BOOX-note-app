
void FUN_00b66594(int param_1,int *param_2,undefined4 param_3)

{
  undefined2 uVar1;
  int iVar2;
  uint uVar3;
  int iVar4;
  undefined4 uVar5;
  undefined8 *puVar6;
  uint uVar7;
  undefined8 *puVar8;
  int iVar9;
  int iVar10;
  int iVar11;
  uint uVar12;
  int iVar13;
  int iVar14;
  undefined8 uVar15;
  undefined8 uVar16;
  undefined8 local_50;
  undefined8 local_48;
  undefined4 local_40;
  
  iVar10 = *(int *)(param_1 + 0xa8);
  iVar2 = QImage::format();
  if (((iVar2 == 6) || (iVar2 = QImage::format(), iVar2 == 4)) ||
     (iVar2 = QImage::format(), iVar2 == 7)) {
    QImage::rect();
    if (((*param_2 == (int)local_50) && (param_2[2] == (int)local_48)) &&
       ((param_2[1] == local_50._4_4_ && (param_2[3] == local_48._4_4_)))) {
      (*(code *)PTR_fill_0138c934)(iVar10,param_3);
      return;
    }
    iVar2 = QImage::depth();
    if (iVar2 == 0x20) {
      uVar3 = QColor::rgba();
    }
    else {
      uVar3 = QColor::rgba();
      uVar3 = uVar3 >> 8 & 0xf800 | uVar3 >> 5 & 0x7e0 | (uVar3 << 0x18) >> 0x1b;
    }
    iVar9 = *param_2;
    iVar13 = param_2[1];
    iVar11 = param_2[3] + 1;
    uVar12 = param_2[2] - iVar9;
    uVar7 = uVar12 + 1;
    iVar14 = uVar7 + iVar9;
    if (iVar13 < iVar11) {
      if (iVar2 == 0x20) {
        iVar2 = (uVar7 & 0xfffffffc) + iVar9;
        if (uVar12 < 3) {
          iVar2 = iVar9;
        }
        uVar15 = CONCAT44(uVar3,uVar3);
        uVar16 = uVar15;
        do {
          while (iVar4 = QImage::constScanLine(iVar10), iVar9 < iVar14) {
            if (uVar12 < 3) {
LAB_00b6685c:
              *(uint *)(iVar4 + iVar2 * 4) = uVar3;
              if ((iVar2 + 1 < iVar14) &&
                 (*(uint *)(iVar4 + (iVar2 + 1) * 4) = uVar3, iVar2 + 2 < iVar14)) {
                *(uint *)(iVar4 + (iVar2 + 2) * 4) = uVar3;
              }
            }
            else {
              puVar8 = (undefined8 *)(iVar4 + iVar9 * 4);
              puVar6 = puVar8 + (uVar7 >> 2) * 2;
              do {
                *puVar8 = uVar15;
                puVar8[1] = uVar16;
                puVar8 = puVar8 + 2;
              } while (puVar8 != puVar6);
              if ((uVar7 & 3) != 0) goto LAB_00b6685c;
            }
            iVar13 = iVar13 + 1;
            if (iVar11 == iVar13) {
              return;
            }
          }
          iVar13 = iVar13 + 1;
        } while (iVar13 != iVar11);
      }
      else {
        iVar2 = (uVar7 & 0xfffffff8) + iVar9;
        if (uVar12 < 7) {
          iVar2 = iVar9;
        }
        uVar1 = (undefined2)uVar3;
        uVar15 = CONCAT44(CONCAT22(uVar1,uVar1),CONCAT22(uVar1,uVar1));
        uVar16 = uVar15;
        do {
          while (iVar4 = QImage::constScanLine(iVar10), iVar9 < iVar14) {
            if (uVar12 < 7) {
LAB_00b66738:
              *(undefined2 *)(iVar4 + iVar2 * 2) = uVar1;
              if (((((iVar2 + 1 < iVar14) &&
                    (*(undefined2 *)(iVar4 + (iVar2 + 1) * 2) = uVar1, iVar2 + 2 < iVar14)) &&
                   (*(undefined2 *)(iVar4 + (iVar2 + 2) * 2) = uVar1, iVar2 + 3 < iVar14)) &&
                  ((*(undefined2 *)(iVar4 + (iVar2 + 3) * 2) = uVar1, iVar2 + 4 < iVar14 &&
                   (*(undefined2 *)(iVar4 + (iVar2 + 4) * 2) = uVar1, iVar2 + 5 < iVar14)))) &&
                 (*(undefined2 *)(iVar4 + (iVar2 + 5) * 2) = uVar1, iVar2 + 6 < iVar14)) {
                *(undefined2 *)(iVar4 + (iVar2 + 6) * 2) = uVar1;
              }
            }
            else {
              puVar8 = (undefined8 *)(iVar4 + iVar9 * 2);
              puVar6 = puVar8 + (uVar7 >> 3) * 2;
              do {
                *puVar8 = uVar15;
                puVar8[1] = uVar16;
                puVar8 = puVar8 + 2;
              } while (puVar6 != puVar8);
              if (uVar7 != (uVar7 & 0xfffffff8)) goto LAB_00b66738;
            }
            iVar13 = iVar13 + 1;
            if (iVar11 == iVar13) {
              return;
            }
          }
          iVar13 = iVar13 + 1;
        } while (iVar13 != iVar11);
      }
    }
  }
  else {
    iVar2 = FUN_00b6618c();
    if (*(char *)(iVar2 + 9) != '\0') {
      local_40 = *(undefined4 *)(iVar2 + 4);
      local_50 = DAT_00b66968;
      local_48 = 0;
      uVar5 = QImage::format();
      QMessageLogger::warning
                ((char *)&local_50,"fillRect_Quill() called with unsupported image format=%d",uVar5)
      ;
    }
  }
  return;
}

